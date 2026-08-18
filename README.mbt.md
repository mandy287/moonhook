# MoonHook

MoonHook 是一个使用 MoonBit 编写的 WebHook 处理核心库与本地调试工具。它不直接绑定某个 Web 框架，而是先提供请求验签、事件解析、路由分发和去重回放这几层通用能力，并提供一个可运行的本地 HTTP MVP，方便后续接入 Halo、mars 或其他 MoonBit HTTP 框架。

当前版本已经包含一个可实际运行的 MVP：

- 通用 `generic` WebHook 请求模型；
- GitHub 风格请求头适配 demo；
- 本地 HTTP `serve` 命令，可接收真实 `POST /webhooks/github` 请求；
- `GET /health` 与 `GET /deliveries` 调试接口；
- 可替换的验签入口，当前内置 `mh1` 演示签名方案；
- 事件解析与 JSON payload 检查；
- 按 `provider + event` 的路由分发；
- 基于 delivery id 的内存去重；
- `demo`、`inspect`、`replay`、`github-demo`、`github-curl`、`serve` CLI 演示命令；
- 自动化测试和 CI 骨架。

## 快速开始

```bash
moon test
moon run --target native cmd/main -- serve 4010
moon run --target native cmd/main -- github-curl 4010
```

然后在另一个终端执行生成出来的 `curl` 命令，即可向本地服务发送一个 GitHub 风格 webhook 请求。

## 本地 MVP 演示

1. 启动本地服务：

```bash
moon run --target native cmd/main -- serve 4010
```

2. 检查服务状态：

```bash
curl http://127.0.0.1:4010/health
```

3. 生成示例请求：

```bash
moon run --target native cmd/main -- github-curl 4010
```

4. 执行该 `curl` 命令后，再查看已处理 delivery：

```bash
curl http://127.0.0.1:4010/deliveries
```

## 命令

```text
moonhook demo         运行通用 webhook 流程
moonhook inspect      输出 GitHub 风格请求解析结果
moonhook replay       演示 delivery 去重与重放
moonhook github-demo  运行 GitHub 风格适配流程
moonhook github-curl  输出可直接测试的 GitHub 风格 curl 命令
moonhook serve        启动本地 webhook MVP 服务
```

## MoonBit API

```moonbit nocheck
let config = @moonhook.VerificationConfig::default()
let routes = @moonhook.demo_routes()
let seen : Map[String, Bool] = Map()
let request = @moonhook.sample_generic_request(config.secret)

match @moonhook.handle_generic(routes, seen, request, config) {
  Ok(report) => println(report.payload_preview)
  Err(error) => println(error.to_string())
}
```

## 当前范围

当前版本已经提供本地 HTTP MVP，但仍然专注于框架无关核心，不宣称已经提供生产级签名安全能力。内置的 `mh1` 签名方案用于演示 MoonHook 的校验接口、分发模型和重放流程；后续计划在此基础上补充 HMAC-SHA256、文件持久化和实际 Web 框架适配器。

## 计划演进

- 增加 Halo / mars 适配器；
- 增加 GitHub WebHook 常见事件示例；
- 实现 HMAC-SHA256 签名校验；
- 支持文件化事件记录和 replay。

## License

Apache-2.0
