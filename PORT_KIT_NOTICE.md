<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Added for lyu323 4.9-port-kit (2026-11-24). New file; NOT upstream source. -->
# ⚠️ 这个仓库是什么 / 不是什么

**是**：官方 KernelSU **v0.9.5** 完整源码（逐字节未改）+ 针对 **Android 9 / 内核 4.9.117**
（vivo `PD1901_A_1.23.32`）的**移植准备工程**：逐文件 hook 清单、4.9 API 差异兜底、只读体检脚本、
配置片段、GPL 双许可合规说明。外加一个 Android 9 能装的**官方原版 Manager 面板**。

**不是**：

- ❌ 装上就有 root 的「适配版 APK」
- ❌ 可刷入的 `boot.img` / `kernelsu.ko` / AnyKernel3 包
- ❌ 官方支持的设备（官方 v1.0 起只支持 GKI 2.0 / 内核 5.10+，非 GKI 最低 4.14）

**原因**：KernelSU 的 root 在内核侧，官方明确不为非 GKI 设备提供 boot 镜像；4.9 低于官方基线，
只能用本机型内核源码**手动移植并编译**。任何声称「4.9 适配版 APK」的东西都是假的。

入口：[README_PORT.md](README_PORT.md) ｜ [移植清单](port-kit/PORT_PLAN.md) ｜
[合规](port-kit/COMPLIANCE.md) ｜ [官方 FAQ](https://kernelsu.org/zh_CN/guide/faq.html)
