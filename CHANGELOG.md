# Changelog

## 0.1.0

- Scaffolded the MoonHook core package and CLI.
- Added webhook request/event models, demo signing, parsing, routing, and
  in-memory delivery deduplication.
- Added a native local HTTP MVP server with `/health`, `/deliveries`,
  `/webhooks/github`, and `/webhooks/generic` endpoints.
- Added command helpers for valid, duplicate, and invalid GitHub-style webhook
  requests.
- Added tests covering signing, parsing, routing, HTTP request handling,
  invalid signatures, and duplicate request command generation.
