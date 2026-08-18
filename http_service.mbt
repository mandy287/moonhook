///|
fn json_string(value : String) -> Json {
  Json::string(value)
}

///|
fn report_json(report : DispatchReport) -> Json {
  let handlers = report.handlers.map(fn(name) { Json::string(name) })
  Json::object(
    Map([
      ("provider", json_string(report.provider)),
      ("event", json_string(report.event_name)),
      ("delivery", json_string(report.delivery_id)),
      ("duplicate", Json::boolean(report.duplicate)),
      ("handlers", Json::array(handlers)),
    ]),
  )
}

///|
fn text_response(status : Int, body : String) -> HttpResponse {
  { status, content_type: "text/plain; charset=utf-8", body }
}

///|
fn json_response(status : Int, body : Json) -> HttpResponse {
  {
    status,
    content_type: "application/json; charset=utf-8",
    body: body.stringify(indent=2),
  }
}

///|
fn root_text(port : Int) -> String {
  let out = StringBuilder()
  out.write_string("MoonHook local MVP server is running.\n\n")
  out.write_string("Endpoints:\n")
  out.write_string("  GET  /               Show this help\n")
  out.write_string("  GET  /health         Show server status\n")
  out.write_string("  GET  /deliveries     Show handled deliveries\n")
  out.write_string(
    "  POST /webhooks/github  Handle GitHub-style webhook demo\n",
  )
  out.write_string("  POST /webhooks/generic Handle generic webhook demo\n\n")
  out.write_string("Try:\n")
  out.write_string("  moon run --target native cmd/main -- github-curl ")
  out.write_string(port.to_string())
  out.to_string()
}

///|
pub fn github_curl_command(port : Int, secret : String) -> String {
  github_curl_command_with(port, secret, "gh-delivery-001", false)
}

///|
pub fn invalid_github_curl_command(port : Int, secret : String) -> String {
  github_curl_command_with(port, secret, "gh-delivery-invalid", true)
}

///|
pub fn duplicate_github_curl_command(port : Int, secret : String) -> String {
  let first = github_curl_command_with(
    port, secret, "gh-delivery-repeat", false,
  )
  let second = github_curl_command_with(
    port, secret, "gh-delivery-repeat", false,
  )
  first + "\n\n# Run the same request again to see duplicate=true\n" + second
}

///|
fn github_curl_command_with(
  port : Int,
  secret : String,
  delivery_id : String,
  invalid_signature : Bool,
) -> String {
  let request = sample_github_request(secret)
  let event = request.headers.get_or_default("x-github-event", "push")
  let timestamp = request.headers.get_or_default(
    "x-moonhook-timestamp", "1723881605",
  )
  let signature = if invalid_signature {
    "mh1:invalid"
  } else {
    sign_demo(secret, 1723881605, request.body)
  }
  let out = StringBuilder()
  out.write_string("curl -i -X POST http://127.0.0.1:")
  out.write_string(port.to_string())
  out.write_string("/webhooks/github \\\n")
  out.write_string("  -H 'Content-Type: application/json' \\\n")
  out.write_string("  -H 'X-GitHub-Event: ")
  out.write_string(event)
  out.write_string("' \\\n")
  out.write_string("  -H 'X-GitHub-Delivery: ")
  out.write_string(delivery_id)
  out.write_string("' \\\n")
  out.write_string("  -H 'X-MoonHook-Timestamp: ")
  out.write_string(timestamp)
  out.write_string("' \\\n")
  out.write_string("  -H 'X-Hub-Signature-Demo: ")
  out.write_string(signature)
  out.write_string("' \\\n")
  out.write_string("  --data '")
  out.write_string(request.body)
  out.write_string("'")
  out.to_string()
}

///|
fn make_webhook_request(
  provider : String,
  request : HttpRequest,
) -> WebhookRequest {
  { provider, headers: request.headers, body: request.body }
}

///|
fn report_response(report : DispatchReport) -> HttpResponse {
  json_response(
    200,
    Json::object(
      Map([
        ("ok", Json::boolean(true)),
        ("provider", Json::string(report.provider)),
        ("event", Json::string(report.event_name)),
        ("delivery", Json::string(report.delivery_id)),
        ("duplicate", Json::boolean(report.duplicate)),
        (
          "handlers",
          Json::array(report.handlers.map(fn(name) { Json::string(name) })),
        ),
        ("payload", Json::string(report.payload_preview)),
      ]),
    ),
  )
}

///|
fn error_response(status : Int, error : MoonHookError) -> HttpResponse {
  json_response(
    status,
    Json::object(
      Map([
        ("ok", Json::boolean(false)),
        ("stage", Json::string(error.stage)),
        ("message", Json::string(error.message)),
      ]),
    ),
  )
}

///|
fn method_not_allowed() -> HttpResponse {
  text_response(405, "Method Not Allowed")
}

///|
pub fn process_http_request(
  request : HttpRequest,
  routes : Array[Route],
  seen : Map[String, Bool],
  history : Array[DispatchReport],
  config : VerificationConfig,
  port : Int,
) -> HttpResponse {
  match (request.verb, request.path) {
    ("GET", "/") => text_response(200, root_text(port))
    ("GET", "/health") =>
      json_response(
        200,
        Json::object(
          Map([
            ("status", Json::string("ok")),
            ("deliveries", Json::number(history.length().to_double())),
          ]),
        ),
      )
    ("GET", "/deliveries") =>
      json_response(200, Json::array(history.map(report_json)))
    ("GET", "/sample/github") =>
      text_response(200, github_curl_command(port, config.secret))
    ("POST", "/webhooks/github") =>
      match
        handle_github_demo(
          routes,
          seen,
          make_webhook_request("github", request),
          config,
        ) {
        Ok(report) => {
          history.push(report)
          report_response(report)
        }
        Err(error) => error_response(400, error)
      }
    ("POST", "/webhooks/generic") =>
      match
        handle_generic(
          routes,
          seen,
          make_webhook_request("generic", request),
          config,
        ) {
        Ok(report) => {
          history.push(report)
          report_response(report)
        }
        Err(error) => error_response(400, error)
      }
    _ =>
      if request.verb == "GET" || request.verb == "POST" {
        text_response(404, "Not Found")
      } else {
        method_not_allowed()
      }
  }
}
