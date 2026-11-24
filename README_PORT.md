<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Added for lyu323 4.9-port-kit (2026-11-24). New file; NOT upstream source. -->
# 快速入口（中文）

| 我想… | 去这里 |
| --- | --- |
| 知道为什么没有现成 APK | [port-kit/README.md](port-kit/README.md) |
| 看 4.9 具体要改哪些内核文件 | [port-kit/PORT_PLAN.md](port-kit/PORT_PLAN.md) |
| 先体检一下我手上的内核源码 | `bash port-kit/scripts/check-kernel-source.sh <内核源码目录>` |
| 看内核配置片段 | [port-kit/config/manual-4.9.cfg](port-kit/config/manual-4.9.cfg) |
| 看 GPL 合规与分发义务 | [port-kit/COMPLIANCE.md](port-kit/COMPLIANCE.md) |
| 下载官方 v0.9.5 Manager 面板 | 本仓库 Release `port-kit-1` |

**一句话**：仓库给的是「源码 + 施工图」，不是「成品」。
要成品，需要你提供本机型内核源码包、原厂 `boot.img`、已解锁的 Bootloader，
然后按施工图编译；刷机风险自担。

源码基线：`tiann/KernelSU` **v0.9.5** · commit `b766b98513b5a7eb33bc1c4a76b5702bf1288f07`
