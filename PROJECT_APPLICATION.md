# MoonHook 项目申报书

## 基本信息

- 项目名称：MoonHook：MoonBit 原生 WebHook 处理核心与调试工具
- 参赛者：zm200
- 联系方式：19864916652
- GitHub 仓库链接：[mandy287/moonhook.git](https://github.com/mandy287/moonhook.git)
- 项目方向：MoonBit 开发工具 / WebHook 处理框架 / 事件集成基础设施
- 是否为移植项目：否

## 项目简介

MoonHook 计划为 MoonBit 生态提供一套专注于 WebHook 请求处理生命周期的上层能力，包括请求验签、事件解析、按事件类型分发、delivery 去重、事件检查和 replay 调试。项目不重复实现通用 HTTP Web 框架，而是作为框架无关的核心层，后续通过适配器接入 Halo、mars 等 MoonBit HTTP 能力。

项目主要面向需要接收第三方事件回调或系统内部事件通知的 MoonBit 开发者，例如 GitHub 回调、支付结果通知、部署触发器、表单提交通知和系统间事件桥接。MoonHook 首版以可运行的核心 demo 为交付目标，优先完成通用请求模型、GitHub 风格请求头适配、校验接口、分发模型、内存去重、CLI 演示、README、测试和 CI。

当前仓库已经完成 MoonBit 工程初始化，并实现了首个可运行 demo：能够构造通用与 GitHub 风格的示例请求，完成演示签名校验、JSON payload 解析、delivery 去重和 handler 分发，供报名和后续开发验证使用。

## 项目现有基础

项目当前已经具备以下基础：

- 初始化 `moonhook` MoonBit 模块和 Git 仓库结构；
- 实现 `WebhookRequest`、`WebhookEvent`、`Route`、`DispatchReport` 等核心数据模型；
- 实现演示签名方案 `mh1`，用于验证 MoonHook 的校验接口与调试流程；
- 实现通用请求解析器和 GitHub 风格请求头适配 demo；
- 实现基于 delivery id 的内存去重和事件路由分发；
- 提供 `demo`、`inspect`、`replay`、`github-demo` CLI 演示命令；
- 提供 MoonBit 自动化测试和 CI 骨架；
- 提供中文 README 和本项目申报书。

这些内容已经能够支撑一个范围明确的框架 demo，也为通过初审后的继续开发提供了稳定起点。

## 核心功能范围

- 提供框架无关的 `WebhookRequest` / `WebhookEvent` 数据模型；
- 提供通用 WebHook 请求头解析能力；
- 提供 GitHub 风格请求头适配 demo；
- 提供统一的请求校验接口，首版内置 `mh1` 演示签名方案；
- 提供 JSON payload 解析和错误报告；
- 提供基于 `provider + event_name` 的路由匹配；
- 提供基于 `provider + delivery_id` 的内存去重；
- 提供 replay 演示能力，验证重复投递处理流程；
- 提供 CLI 演示命令，用于检查、演示和答辩展示；
- 提供 README、测试和 CI。

## 本次计划开发内容

### 第一阶段：核心模型与框架 demo

- 完善核心数据模型与错误模型；
- 完善通用请求解析流程；
- 完善 GitHub 风格请求头适配；
- 完成 CLI 演示与 replay 流程；
- 完成基础测试、README 和 CI。

### 第二阶段：增强校验与适配接口

- 将当前演示签名接口收敛成可替换 verifier 抽象；
- 增加更清晰的错误分类与输出；
- 为后续 Halo / mars 适配预留 request/response 边界；
- 完善事件路由规则和示例。

### 第三阶段：通过初审后继续实现的范围

- 评估并实现 HMAC-SHA256 验签；
- 评估并实现文件化事件记录；
- 尝试增加一个实际 MoonBit Web 框架适配器；
- 完善文档与发布材料，并按要求发布到 mooncakes.io。

## 预期目标与技术路线

项目首版目标是形成一个可运行、可测试、可讲清楚的 MoonBit WebHook 处理核心，而不是一次性实现完整 HTTP 服务器。技术上采用“核心层 + 适配层”的分层设计：核心层负责事件校验、解析、分发、去重和 replay；适配层负责将具体 Web 框架的 request/header/body 映射为统一的 `WebhookRequest`。

首版优先完成不依赖外部服务的框架 demo，确保：

- 可以通过 `moon test` 验证核心逻辑；
- 可以通过 CLI 演示请求校验、事件解析、分发和 replay；
- 可以为后续接入真实 HTTP 框架提供稳定接口；
- 文档、测试和边界说明与实际代码一致。

本项目本次申报不承诺一次性完成完整的生产级 HTTP 服务、数据库持久化、多 provider 全量适配或企业级安全加固，以避免项目范围失控。

## 预计完成的功能、测试和文档

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

## 非目标与边界约束

为保证本次项目真实可交付，以下内容不列入首版强制范围：

- 不重做通用 HTTP Web 框架；
- 不在首版同时支持大量第三方 provider；
- 不承诺数据库、消息队列或云服务集成；
- 不承诺生产级签名安全与运维能力在首版全部完成；
- 不把 WebHook 发送端、调度中心和可视化后台同时纳入首版范围。

## 项目价值与维护计划

MoonBit 生态已经逐渐具备 HTTP 与通用基础能力，但围绕 WebHook 接收、校验、调试与回放的上层工具仍然缺乏统一抽象。MoonHook 的价值在于把这些在业务项目中重复出现的通用流程沉淀为可复用的基础设施，降低第三方集成与事件驱动开发的重复成本。

通过初审后，项目将继续朝“核心库 + 真实框架适配器 + 更完整验签能力”的方向演进，并根据实际开发反馈补充事件样例、接口文档、测试和发布说明，保持项目边界清晰、功能逐步落地。
