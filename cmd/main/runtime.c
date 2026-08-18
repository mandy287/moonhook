#include <moonbit.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <winsock2.h>
#define close closesocket
static int wsa_ready = 0;
#else
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#endif

static int server_socket = -1;
static int client_socket = -1;
static int current_port = -1;

static int ensure_server(int32_t port) {
#ifdef _WIN32
  if (!wsa_ready) {
    WSADATA data;
    if (WSAStartup(MAKEWORD(2, 2), &data) != 0) return -1;
    wsa_ready = 1;
  }
#endif
  if (server_socket >= 0 && current_port == port) return 0;
  if (server_socket >= 0) {
    close(server_socket);
    server_socket = -1;
  }
  server_socket = (int)socket(AF_INET, SOCK_STREAM, 0);
  if (server_socket < 0) return -1;
  int yes = 1;
  setsockopt(
    server_socket,
    SOL_SOCKET,
    SO_REUSEADDR,
    (const char *)&yes,
    sizeof(yes)
  );
  struct sockaddr_in address;
  memset(&address, 0, sizeof(address));
  address.sin_family = AF_INET;
  address.sin_addr.s_addr = htonl(INADDR_ANY);
  address.sin_port = htons((uint16_t)port);
  if (bind(server_socket, (struct sockaddr *)&address, sizeof(address)) != 0) {
    close(server_socket);
    server_socket = -1;
    return -1;
  }
  if (listen(server_socket, 16) != 0) {
    close(server_socket);
    server_socket = -1;
    return -1;
  }
  current_port = port;
  return 0;
}

MOONBIT_FFI_EXPORT int32_t moonhook_start_server(int32_t port) {
  return ensure_server(port);
}

static int find_header_end(const char *buffer, int length) {
  for (int i = 0; i + 3 < length; ++i) {
    if (buffer[i] == '\r' && buffer[i + 1] == '\n' &&
        buffer[i + 2] == '\r' && buffer[i + 3] == '\n') {
      return i + 4;
    }
  }
  return -1;
}

static int parse_content_length(const char *buffer, int header_end) {
  const char *needle = "Content-Length:";
  int needle_len = (int)strlen(needle);
  for (int i = 0; i + needle_len < header_end; ++i) {
    if (strncmp(buffer + i, needle, (size_t)needle_len) == 0) {
      return atoi(buffer + i + needle_len);
    }
  }
  return 0;
}

MOONBIT_FFI_EXPORT moonbit_bytes_t moonhook_serve_once(int32_t port) {
  if (ensure_server(port) != 0) return moonbit_make_bytes(0, 0);
  if (client_socket >= 0) {
    close(client_socket);
    client_socket = -1;
  }
  client_socket = (int)accept(server_socket, NULL, NULL);
  if (client_socket < 0) return moonbit_make_bytes(0, 0);

  int capacity = 65536;
  char *buffer = (char *)malloc((size_t)capacity);
  if (!buffer) {
    close(client_socket);
    client_socket = -1;
    return moonbit_make_bytes(0, 0);
  }
  int length = 0;
  int header_end = -1;
  int content_length = 0;
  for (;;) {
    int received = (int)recv(
      client_socket,
      buffer + length,
      (size_t)(capacity - length),
      0
    );
    if (received <= 0) break;
    length += received;
    if (header_end < 0) {
      header_end = find_header_end(buffer, length);
      if (header_end >= 0) {
        content_length = parse_content_length(buffer, header_end);
      }
    }
    if (header_end >= 0 && length >= header_end + content_length) break;
    if (length == capacity) break;
  }

  moonbit_bytes_t result = moonbit_make_bytes(length, 0);
  if (length > 0) memcpy(result, buffer, (size_t)length);
  free(buffer);
  return result;
}

static const char *status_text(int32_t status) {
  switch (status) {
    case 200: return "200 OK";
    case 400: return "400 Bad Request";
    case 404: return "404 Not Found";
    case 405: return "405 Method Not Allowed";
    case 500: return "500 Internal Server Error";
    default: return "200 OK";
  }
}

MOONBIT_FFI_EXPORT int32_t moonhook_send_response(
  int32_t status,
  moonbit_bytes_t content_type,
  moonbit_bytes_t body
) {
  if (client_socket < 0) return -1;
  int32_t body_length = Moonbit_array_length(body);
  char header[512];
  int header_length = snprintf(
    header,
    sizeof(header),
    "HTTP/1.1 %s\r\nContent-Type: %s\r\nContent-Length: %d\r\nConnection: close\r\n\r\n",
    status_text(status),
    (const char *)content_type,
    body_length
  );
  send(client_socket, header, (size_t)header_length, 0);
  if (body_length > 0) {
    send(client_socket, (const char *)body, (size_t)body_length, 0);
  }
  close(client_socket);
  client_socket = -1;
  return 0;
}
