# GitHub Push WebHook MVP Demo

This example shows MoonHook's local MVP flow for a GitHub-style `push`
webhook.

## Start The Server

```bash
moon run --target native cmd/main -- serve 4010
```

Expected startup output:

```text
MoonHook MVP server listening on http://127.0.0.1:4010
Health: http://127.0.0.1:4010/health
```

## Send A Valid Request

```bash
moon run --target native cmd/main -- github-curl 4010
```

Run the generated `curl` command. The response should include:

```json
{
  "ok": true,
  "provider": "github",
  "event": "push",
  "delivery": "gh-delivery-001",
  "duplicate": false,
  "handlers": [
    "sync_repository",
    "write_delivery_log"
  ]
}
```

## Send A Duplicate Request

```bash
moon run --target native cmd/main -- duplicate-curl 4010
```

Run both generated `curl` commands in order. The second response should include:

```json
{
  "ok": true,
  "duplicate": true
}
```

## Send An Invalid Signature

```bash
moon run --target native cmd/main -- invalid-curl 4010
```

Run the generated `curl` command. The response should include:

```json
{
  "ok": false,
  "stage": "verify",
  "message": "signature mismatch"
}
```

## Inspect Deliveries

```bash
curl http://127.0.0.1:4010/deliveries
```

The response lists the accepted deliveries that were handled by MoonHook.
