///|
fn parse_int(value : String, fallback : Int) -> Int {
  let parsed = try @string.parse_int(value) |> Ok catch {
    _ => Err(())
  }
  match parsed {
    Ok(number) => number
    Err(_) => fallback
  }
}

///|
fn require_header(
  headers : Map[String, String],
  primary : String,
  fallback? : String = "",
) -> String? {
  match headers.get(primary) {
    Some(value) => Some(value)
    None => if fallback != "" { headers.get(fallback) } else { None }
  }
}

///|
fn parse_payload(body : String) -> Result[Json, MoonHookError] {
  Ok(@json.parse(body)) catch {
    error => Err({ stage: "parse", message: error.to_string() })
  }
}

///|
fn build_event(
  request : WebhookRequest,
  config : VerificationConfig,
  event_header : String,
  delivery_header : String,
  signature_header : String,
) -> Result[WebhookEvent, MoonHookError] {
  let event_name = match require_header(request.headers, event_header) {
    Some(value) => value
    None =>
      return Err({ stage: "parse", message: "missing header \{event_header}" })
  }
  let delivery_id = match require_header(request.headers, delivery_header) {
    Some(value) => value
    None =>
      return Err({
        stage: "parse",
        message: "missing header \{delivery_header}",
      })
  }
  let signature = match require_header(request.headers, signature_header) {
    Some(value) => value
    None =>
      return Err({
        stage: "verify",
        message: "missing header \{signature_header}",
      })
  }
  let timestamp_text = match
    require_header(request.headers, "x-moonhook-timestamp") {
    Some(value) => value
    None =>
      return Err({
        stage: "verify",
        message: "missing header x-moonhook-timestamp",
      })
  }
  let timestamp = parse_int(timestamp_text, -1)
  if timestamp < 0 {
    return Err({
      stage: "verify",
      message: "invalid timestamp \{timestamp_text}",
    })
  }
  if !verify_demo_signature(config.secret, timestamp, request.body, signature) {
    return Err({ stage: "verify", message: "signature mismatch" })
  }
  let payload = match parse_payload(request.body) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  Ok({
    provider: request.provider,
    event_name,
    delivery_id,
    timestamp,
    signature,
    payload,
  })
}

///|
pub fn parse_generic(
  request : WebhookRequest,
  config : VerificationConfig,
) -> Result[WebhookEvent, MoonHookError] {
  build_event(
    request, config, "x-moonhook-event", "x-moonhook-delivery", "x-moonhook-signature",
  )
}

///|
pub fn parse_github_demo(
  request : WebhookRequest,
  config : VerificationConfig,
) -> Result[WebhookEvent, MoonHookError] {
  build_event(
    request, config, "x-github-event", "x-github-delivery", "x-hub-signature-demo",
  )
}

///|
pub fn sample_generic_request(secret : String) -> WebhookRequest {
  let body = "{\"repository\":\"moonhook\",\"action\":\"deploy\",\"branch\":\"main\"}"
  let timestamp = 1723881600
  {
    provider: "generic",
    headers: Map([
      ("x-moonhook-event", "deploy.requested"),
      ("x-moonhook-delivery", "evt-demo-001"),
      ("x-moonhook-timestamp", timestamp.to_string()),
      ("x-moonhook-signature", sign_demo(secret, timestamp, body)),
    ]),
    body,
  }
}

///|
pub fn sample_github_request(secret : String) -> WebhookRequest {
  let body = "{\"repository\":{\"full_name\":\"lizhentao/moonhook\"},\"ref\":\"refs/heads/main\"}"
  let timestamp = 1723881605
  {
    provider: "github",
    headers: Map([
      ("x-github-event", "push"),
      ("x-github-delivery", "gh-delivery-001"),
      ("x-moonhook-timestamp", timestamp.to_string()),
      ("x-hub-signature-demo", sign_demo(secret, timestamp, body)),
    ]),
    body,
  }
}
