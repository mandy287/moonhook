# MoonHook 项目申报书

## 基本信息

- 项目名称：MoonHook：MoonBit 原生 WebHook 处理核心与调试工具
- 参赛者：zm200
- 联系方式：19864916652
- GitHub 仓库链接：[mandy287/moonhook.git](https://github.com/mandy287/moonhook.git)
- 项目方向：MoonBit 开发工具 / WebHook 处理框架 / 事件集成基础设施
- 是否为移植项目：否

## 项目简介

MoonHook 计划为 MoonBit 生态提供一套专注于 WebHook 请求处理生命周期的上层能力，包括请求验签、事件解析、按事件类型分发、delivery 去重、事件检查和 replay 调试。项目主要面向需要接收第三方事件回调或系统内部事件通知的 MoonBit 开发者，例如 GitHub 回调、部署触发器、表单提交通知以及系统间事件桥接。

MoonHook 不重复实现通用 HTTP Web 框架，而是优先复用 MoonBit 生态中已有的 HTTP、JSON 和基础工具能力，将主要开发工作放在统一请求模型、校验接口、事件路由、去重语义、调试与重放工具以及框架适配边界上。首版交付目标是形成一个可运行、可测试、可扩展的核心层，并提供本地可直接演示的 HTTP MVP，为后续接入 Halo、mars 等 MoonBit Web 能力提供稳定基础。

当前仓库已经完成 MoonBit 工程初始化，并实现首个可运行 MVP：能够启动本地 HTTP 服务，接收 GitHub 风格与通用 WebHook 请求，完成演示签名校验、JSON payload 解析、delivery 去重、handler 分发以及基本调试查询，供报名和后续开发验证使用。

## 项目现有基础

项目在报名阶段已完成以下工作：

- 初始化 `moonhook` MoonBit 模块和 Git 仓库结构；
- 配置项目名称、版本、仓库地址、关键词和 Apache-2.0 许可证；
- 实现 `WebhookRequest`、`WebhookEvent`、`Route`、`DispatchReport` 等核心数据模型；
- 实现演示签名方案 `mh1`，用于验证 MoonHook 的校验接口与调试流程；
- 实现通用请求解析器和 GitHub 风格请求头适配 demo；
- 实现基于 delivery id 的内存去重和事件路由分发；
- 实现本地 HTTP `serve` 入口以及 `/health`、`/deliveries` 调试接口；
- 提供可运行的 `demo`、`inspect`、`replay`、`github-demo`、`github-curl`、`serve` CLI 演示命令；
- 提供 MoonBit 自动化测试和 GitHub Actions CI 骨架；
- 提供中文 README，说明项目定位、当前范围、后续计划和开发命令；
- 完成本项目申报书，明确首版边界、技术路线和交付目标。

当前已完成首个可用的本地 MVP，后续将继续扩充校验能力、适配接口、文档和示例，并按验收要求发布到 mooncakes.io。

## 核心功能范围

- 提供框架无关的 `WebhookRequest` / `WebhookEvent` 数据模型；
- 提供通用 WebHook 请求头解析能力；
- 提供 GitHub 风格请求头适配 demo；
- 提供本地 HTTP WebHook 入口和基本调试接口；
- 提供统一的请求校验接口，首版内置 `mh1` 演示签名方案；
- 提供 JSON payload 解析和错误报告；
- 提供基于 `provider + event_name` 的路由匹配；
- 提供基于 `provider + delivery_id` 的内存去重；
- 提供 replay 演示能力，验证重复投递处理流程；
- 提供 CLI 演示命令，用于检查、演示和答辩展示；
- 提供 README、测试和 CI。

## 计划开发内容

### 第一阶段：核心模型与框架 demo

- 完善核心数据模型、错误模型与结果输出；
- 完善通用请求解析流程和 JSON payload 诊断；
- 完善 GitHub 风格请求头适配和示例请求夹具；
- 完成本地 HTTP MVP、CLI 演示与 replay 流程；
- 建立端到端示例和基础测试夹具。

### 第二阶段：增强校验与适配接口

- 将当前演示签名接口收敛成可替换 verifier 抽象；
- 增加更清晰的错误分类、去重语义和诊断输出；
- 为后续 Halo / mars 适配预留 request/header/body 边界；
- 完善事件路由规则、默认处理流程和调试示例。

### 第三阶段：通过初审后继续实现的范围

- 评估并实现 HMAC-SHA256 验签；
- 评估并实现文件化事件记录与本地 replay；
- 尝试增加一个实际 MoonBit Web 框架适配器；
- 完善 README、示例、测试和发布材料，并按要求发布到 mooncakes.io。

## 预期目标与技术路线

项目预计形成约 4,000 至 7,000 行有效 MoonBit 代码，采用“核心层 + 适配层”的分层设计：核心层负责事件校验、解析、分发、去重和 replay；适配层负责将具体 Web 框架的 request、header 和 body 映射为统一的 `WebhookRequest`。这样既能避免与通用 Web 框架重复建设，也能为不同 MoonBit HTTP 方案提供共同的上层抽象。

首版优先完成不依赖外部服务的本地 HTTP MVP，测试将覆盖签名校验、请求头解析、事件路由、重复投递、错误输入和 CLI 演示流程。项目会准备通用事件、GitHub 风格事件、重复投递和校验失败等不同示例，确保核心流程可以实际运行和展示。

## 实现边界与设计说明

MoonHook 首版会做以下取舍：

- 使用 MoonBit 原生包结构、类型系统、错误处理和测试方式组织代码，而不是把项目做成与某个单一 Web 框架强绑定的插件；
- 优先完成请求模型、校验接口、路由分发、去重与 replay 等核心能力，并提供一个用于本地演示和调试的最小 HTTP 入口；
- 首版提供 GitHub 风格请求头适配 demo 和通用事件模型，不一次性承诺支持大量第三方 provider；
- 首版使用演示签名方案验证接口和调试流程，后续再逐步补充更完整的 HMAC-SHA256 验签；
- 首版优先提供内存去重和 CLI 演示，不把数据库、消息队列、云服务或可视化后台同时纳入本期范围；
- 对后续实际框架适配器、文件记录和更完整事件样例保留清晰接口边界，避免首期范围失控。

## 预计完成的测试、文档与交付物

- 核心数据模型与错误模型；
- 通用解析入口和 GitHub 风格适配 demo；
- 验签接口与演示签名实现；
- 路由分发、delivery 去重、replay 演示；
- CLI 演示程序；
- 自动化测试；
- 中文 README；
- GitHub Actions CI；
- 项目边界、非目标和后续计划说明；
- 发布到 mooncakes.io 所需的基础元数据。

## 项目价值与维护计划

MoonBit 生态已经逐渐具备 HTTP、JSON 和通用基础能力，但围绕 WebHook 接收、校验、调试与回放的上层工具仍然缺乏统一抽象。MoonHook 的价值在于把这些在业务项目中反复出现的通用流程沉淀为可复用的软件，既可以服务第三方回调接入，也可以服务 MoonBit 项目内部的事件驱动集成场景。

验收后将继续跟进 MoonBit 工具链和相关依赖更新，维护核心解析流程、示例和兼容性测试。后续根据实际使用反馈，再评估更多 provider 适配器、更完整的验签方式和持久化能力，不在首期过度扩张范围。
