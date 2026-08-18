///|
test "parse raw http request and normalize headers" {
  let raw = "POST /webhooks/github HTTP/1.1\r\nX-GitHub-Event: push\r\nX-GitHub-Delivery: abc\r\nContent-Type: application/json\r\n\r\n{\"ok\":true}"
  match parse_http_request(raw) {
    Err(error) => fail(error.to_string())
    Ok(request) => {
      assert_eq(request.verb, "POST")
      assert_eq(request.path, "/webhooks/github")
      assert_eq(request.headers.get_or_default("x-github-event", ""), "push")
      assert_eq(request.body, "{\"ok\":true}")
    }
  }
}

///|
test "process health endpoint" {
  let response = process_http_request(
    { verb: "GET", path: "/health", headers: Map([]), body: "" },
    demo_routes(),
    Map([]),
    [],
    VerificationConfig::default(),
    4000,
  )
  assert_eq(response.status, 200)
  assert_true(response.body.contains("\"status\": \"ok\""))
}

///|
test "process github webhook over http request" {
  let config = VerificationConfig::default()
  let sample = sample_github_request(config.secret)
  let request : HttpRequest = {
    verb: "POST",
    path: "/webhooks/github",
    headers: sample.headers,
    body: sample.body,
  }
  let seen : Map[String, Bool] = Map([])
  let history : Array[DispatchReport] = []
  let response = process_http_request(
    request,
    demo_routes(),
    seen,
    history,
    config,
    4000,
  )
  assert_eq(response.status, 200)
  assert_eq(history.length(), 1)
  assert_true(response.body.contains("\"ok\": true"))
  assert_true(response.body.contains("\"delivery\": \"gh-delivery-001\""))
}

///|
test "invalid github curl command uses bad signature" {
  let command = invalid_github_curl_command(4001, "demo")
  assert_true(command.contains("/webhooks/github"))
  assert_true(command.contains("X-Hub-Signature-Demo: mh1:invalid"))
}

///|
test "duplicate github curl command keeps delivery id stable" {
  let command = duplicate_github_curl_command(4001, "demo")
  assert_true(command.contains("gh-delivery-repeat"))
  assert_true(command.contains("duplicate=true"))
}
