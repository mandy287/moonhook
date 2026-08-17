///|
fn event_key(provider : String, delivery_id : String) -> String {
  provider + ":" + delivery_id
}

///|
fn route_matches(route : Route, event : WebhookEvent) -> Bool {
  let provider_match = route.provider == "*" || route.provider == event.provider
  let event_match = route.event_name == "*" ||
    route.event_name == event.event_name
  provider_match && event_match
}

///|
pub fn dispatch_event(
  routes : Array[Route],
  seen : Map[String, Bool],
  event : WebhookEvent,
) -> DispatchReport {
  let key = event_key(event.provider, event.delivery_id)
  let duplicate = seen.contains(key)
  if !duplicate {
    seen[key] = true
  }
  let handlers : Array[String] = []
  for route in routes {
    if route_matches(route, event) {
      handlers.push(route.handler)
    }
  }
  {
    provider: event.provider,
    event_name: event.event_name,
    delivery_id: event.delivery_id,
    handlers,
    duplicate,
    payload_preview: event.payload.stringify(indent=2),
  }
}

///|
pub fn handle_generic(
  routes : Array[Route],
  seen : Map[String, Bool],
  request : WebhookRequest,
  config : VerificationConfig,
) -> Result[DispatchReport, MoonHookError] {
  match parse_generic(request, config) {
    Ok(event) => Ok(dispatch_event(routes, seen, event))
    Err(error) => Err(error)
  }
}

///|
pub fn handle_github_demo(
  routes : Array[Route],
  seen : Map[String, Bool],
  request : WebhookRequest,
  config : VerificationConfig,
) -> Result[DispatchReport, MoonHookError] {
  match parse_github_demo(request, config) {
    Ok(event) => Ok(dispatch_event(routes, seen, event))
    Err(error) => Err(error)
  }
}

///|
pub fn demo_routes() -> Array[Route] {
  [
    {
      provider: "generic",
      event_name: "deploy.requested",
      handler: "queue_deploy",
    },
    { provider: "generic", event_name: "*", handler: "audit_log" },
    { provider: "github", event_name: "push", handler: "sync_repository" },
    { provider: "github", event_name: "*", handler: "write_delivery_log" },
  ]
}
