<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Added for lyu323 4.9-port-kit (2026-11-24). New file; NOT upstream source. -->
# Release `port-kit-1` · KernelSU 4.9 移植准备包

## 资产

| 文件 | 说明 |
| --- | --- |
| `KernelSU_v0.9.5_11872-release.apk` | **官方原版** v0.9.5 Manager 面板，Android 9 可安装；非适配版、不给 root |
| `KernelSU-v0.9.5-source.zip` | 官方 v0.9.5 tag 完整源码（逐字节未改），commit `b766b985…` |
| `port-kit.zip` | 移植准备工程：PORT_PLAN、只读体检脚本、配置片段、合规文档 |
| `LICENSE` | GPL-3.0-or-later 全文 |
| `kernel-LICENSE` | GPL-2.0-only 全文 |
| `README-zh.md` | 中文交付说明 |

## 适用与不适用

适用：vivo `PD1901_A_1.23.32` / Android 9 / Funtouch OS 9 / 内核 `4.9.117+` 这类**非 GKI 老内核**的
KernelSU 源码级移植准备。

不适用：想要一个装上就 root 的 APK。官方 v1.0 起只支持 GKI 2.0（5.10+），非 GKI 最低 4.14 且
「需自行编译内核」，**官方不提供非 GKI boot 镜像**。4.9 属实验性手动移植。

## 合规

`kernel/**` = GPL-2.0-only，其余 = GPL-3.0-or-later，两份全文随包。
任何基于本仓库构建并对外分发的二进制，必须随附该次构建的对应源码与两份许可证；
私有仓库只适合自留产物，不能据此对外闭源分发。

## 风险

需要解锁 Bootloader、备份原厂镜像、自行编译内核；刷错可能变砖。
本 Release 不含 boot.img / .ko / 一键 root，**未做真机验证**。
