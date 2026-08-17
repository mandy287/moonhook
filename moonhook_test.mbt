///|
test "sign and verify demo request" {
  let signature = sign_demo("secret", 42, "{\"ok\":true}")
  assert_true(verify_demo_signature("secret", 42, "{\"ok\":true}", signature))
  assert_false(verify_demo_signature("secret", 42, "{\"ok\":false}", signature))
}

///|
test "parse generic request" {
  let config : VerificationConfig = { secret: "demo", tolerance_seconds: 300 }
  let request = sample_generic_request("demo")
  match parse_generic(request, config) {
    Err(error) => fail(error.to_string())
    Ok(event) => {
      assert_eq(event.provider, "generic")
      assert_eq(event.event_name, "deploy.requested")
      assert_eq(event.delivery_id, "evt-demo-001")
    }
  }
}

///|
test "reject invalid signature" {
  let config : VerificationConfig = { secret: "demo", tolerance_seconds: 300 }
  let request : WebhookRequest = {
    provider: "generic",
    headers: Map([
      ("x-moonhook-event", "deploy.requested"),
      ("x-moonhook-delivery", "evt-demo-002"),
      ("x-moonhook-timestamp", "1723881600"),
      ("x-moonhook-signature", "mh1:bad"),
    ]),
    body: "{\"repository\":\"moonhook\"}",
  }
  assert_true(parse_generic(request, config) is Err(_))
}

///|
test "dispatch matches wildcard handlers and deduplicates deliveries" {
  let config : VerificationConfig = { secret: "demo", tolerance_seconds: 300 }
  let routes = demo_routes()
  let seen : Map[String, Bool] = Map([])
  let request = sample_generic_request("demo")
  let first = match handle_generic(routes, seen, request, config) {
    Ok(report) => report
    Err(error) => fail(error.to_string())
  }
  assert_false(first.duplicate)
  assert_eq(first.handlers.length(), 2)
  let second = match handle_generic(routes, seen, request, config) {
    Ok(report) => report
    Err(error) => fail(error.to_string())
  }
  assert_true(second.duplicate)
}

///|
test "github demo adapter uses github style headers" {
  let config : VerificationConfig = { secret: "octo", tolerance_seconds: 300 }
  let routes = demo_routes()
  let seen : Map[String, Bool] = Map([])
  let request = sample_github_request("octo")
  match handle_github_demo(routes, seen, request, config) {
    Err(error) => fail(error.to_string())
    Ok(report) => {
      assert_eq(report.provider, "github")
      assert_eq(report.event_name, "push")
      assert_true(report.handlers.contains("sync_repository"))
    }
  }
}
