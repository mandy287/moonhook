///|
extern "c" fn start_server_raw(port : Int) -> Int = "moonhook_start_server"

///|
extern "c" fn serve_once_raw(port : Int) -> Bytes = "moonhook_serve_once"

///|
#borrow(content_type, body)
extern "c" fn send_response_raw(
  status : Int,
  content_type : Bytes,
  body : Bytes,
) -> Int = "moonhook_send_response"

///|
fn start_server(port : Int) -> Int {
  start_server_raw(port)
}

///|
fn serve_once(port : Int) -> String {
  @utf8.decode_lossy(serve_once_raw(port))
}

///|
fn send_response(response : @moonhook.HttpResponse) -> Int {
  send_response_raw(
    response.status,
    @utf8.encode(response.content_type),
    @utf8.encode(response.body),
  )
}
