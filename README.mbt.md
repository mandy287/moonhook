# MoonHook

MoonHook 是一个使用 MoonBit 编写的 WebHook 处理核心库与演示 CLI。它不直接绑定某个 Web 框架，而是先提供请求验签、事件解析、路由分发和去重回放这几层通用能力，方便后续接入 Halo、mars 或其他 MoonBit HTTP 框架。

当前版本提供一个可运行的框架 demo：

- 通用 `generic` WebHook 请求模型；
- GitHub 风格请求头适配 demo；
- 可替换的验签入口，当前内置 `mh1` 演示签名方案；
- 事件解析与 JSON payload 检查；
- 按 `provider + event` 的路由分发；
- 基于 delivery id 的内存去重；
- `demo`、`inspect`、`replay`、`github-demo` CLI 演示命令；
- 自动化测试和 CI 骨架。

## 快速开始

```bash
moon test
moon run cmd/main -- demo
moon run cmd/main -- inspect
moon run cmd/main -- replay
moon run cmd/main -- github-demo
```

## 命令

```text
moonhook demo         运行通用 webhook 流程
moonhook inspect      输出 GitHub 风格请求解析结果
moonhook replay       演示 delivery 去重与重放
moonhook github-demo  运行 GitHub 风格适配流程
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

当前版本专注框架无关核心，不直接启动 HTTP 服务器，也不宣称已经提供生产级签名安全能力。内置的 `mh1` 签名方案用于演示 MoonHook 的校验接口、分发模型和重放流程；后续计划在此基础上补充 HMAC-SHA256、文件持久化和实际 Web 框架适配器。

## 计划演进

- 接入真实 HTTP 入口；
- 增加 Halo / mars 适配器；
- 增加 GitHub WebHook 常见事件示例；
- 实现 HMAC-SHA256 签名校验；
- 支持文件化事件记录和 replay。

## License

Apache-2.0
