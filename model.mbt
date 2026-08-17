///|
pub let version : String = "0.1.0"

///|
pub(all) struct VerificationConfig {
  secret : String
  tolerance_seconds : Int
}

///|
pub fn VerificationConfig::default() -> VerificationConfig {
  { secret: "moonhook-demo-secret", tolerance_seconds: 300 }
}

///|
pub(all) struct WebhookRequest {
  provider : String
  headers : Map[String, String]
  body : String
}

///|
pub(all) struct WebhookEvent {
  provider : String
  event_name : String
  delivery_id : String
  timestamp : Int
  signature : String
  payload : Json
}

///|
pub(all) struct Route {
  provider : String
  event_name : String
  handler : String
}

///|
pub(all) struct DispatchReport {
  provider : String
  event_name : String
  delivery_id : String
  handlers : Array[String]
  duplicate : Bool
  payload_preview : String
}

///|
pub(all) struct MoonHookError {
  stage : String
  message : String
}

///|
pub impl Show for MoonHookError with fn to_string(self) {
  "\{self.stage} error: \{self.message}"
}
