<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Added for lyu323 4.9-port-kit (2026-11-24). New file; NOT upstream source. -->
# KernelSU 4.9 非 GKI 移植准备包（Android 9 / 内核 4.9.117）

> **先读这句**：这个仓库**不是「装上就有 root 的适配版 APK」**。
> KernelSU 的 root 能力在**内核侧**，而官方明确不为非 GKI 设备提供 boot 镜像。
> 本仓库交付的是：**官方 v0.9.5 完整源码**（逐字节未改）+ **针对 4.9 内核的移植准备工程** +
> 一个 Android 9 能装的**官方原版 Manager 面板**。真正能用的 boot 镜像必须由你用本机型内核源码编译。

## 适用设备（来自「关于手机」截图）

| 项 | 值 |
| --- | --- |
| Android | 9（Funtouch OS 9） |
| 内核 | `4.9.117+` |
| 安全补丁 | 2021-10-01 |
| 软件版本 | `PD1901_A_1.23.32` |
| 内存 / CPU | 4 GB / 八核 2.3 GHz |
| 架构 | 大概率 arm64（请用 `getprop ro.product.cpu.abi` 确认） |

## 为什么没有现成 APK

1. 官方主线 **v1.0 起只支持 GKI 2.0（内核 5.10+）**；非 GKI 路线最低回移到 **4.14**，4.9 低于基线，官方标为「需手动移植、实验性」。
2. 已归档的官方非 GKI 文档写明：**由于碎片化，官方无法为非 GKI 设备提供 boot 镜像**。
3. 官方 v3.3.1 的 16 个 LKM 资产全是 `android12-5.10` ~ `android17-6.18`；历史 51 个 Release 里**没有任何 4.9 / non-GKI 产物**。v3.x Manager 还是 minSdk 31（Android 12+），Android 9 连装都装不上。
4. 因此本仓库用 **v0.9.5**（最后一个支持非 GKI 的版本，commit `b766b98513b5a7eb33bc1c4a76b5702bf1288f07`）作为源码基线。

## 仓库里有什么

| 路径 | 内容 |
| --- | --- |
| `kernel/`、`userspace/`、`manager/` … | 官方 v0.9.5 tag 完整源码，**逐字节未改** |
| `LICENSE` / `kernel/LICENSE` | GPL-3.0-or-later / GPL-2.0-only 全文，逐字节未改 |
| `port-kit/PORT_PLAN.md` | 4.9 手动集成的逐文件步骤、API 差异兜底、验收流程 |
| `port-kit/scripts/check-kernel-source.sh` | **只读**检查你手上的内核源码树，输出该改哪些文件、走哪条路线 |
| `port-kit/config/*.cfg` | kprobe 路线 / 手动路线所需的内核配置片段 |
| `port-kit/COMPLIANCE.md`、`NOTICE` | GPL 双许可、上游 commit、分发义务 |
| `PORT_KIT_NOTICE.md` | 顶层说明 |
| `README_PORT.md` | 中文快速入口 |
| `.github/workflows/fetch-official-manager.yml` | CI：取回官方 v0.9.5 Manager APK 并发布 Release |

## 三步走（真正的路径）

1. **拿源码**：到 vivo 开源站 http://opensource.vivo.com/ 找 `PD1901` / `PD1901_A_1.23.32` 对应的内核源码包（GPL 义务要求厂商公开内核源码）。同时备份原厂 `boot.img`。
2. **先证明能编译**：用该源码 + 对应交叉工具链，**不加任何修改**编出一个能正常开机的 boot 镜像。这一步过不了，后面都别做。
3. **再集成**：按 `PORT_PLAN.md` 手动挂 4 个 hook（4.9 的 API 与新版不同，脚本会帮你定位），开 `CONFIG_KSU=y`、**关 `CONFIG_KPROBES`**，编译 → `fastboot boot` 试刷（不落盘）→ 能开机且面板识别 → 才 `fastboot flash boot`。

> ⚠️ 需要**解锁 Bootloader**；刷错内核会变砖；务必先备份原厂镜像与数据。本仓库不提供、也不代为生成 boot.img / `.ko` / 一键 root。

## 那个官方 Manager APK 是什么

`KernelSU_v0.9.5_11872-release.apk` 是**官方原版面板**（不是适配版、不是我们编译的）。Android 9 可安装，打开后大概率显示「未安装 / Unsupported」——这是**正确状态**：没有内核侧 KSU 就不会有 root。它只是将来内核编译成功后的管理界面。

## 合规

见 `port-kit/COMPLIANCE.md`：`kernel/**` = GPL-2.0-only，其余 = GPL-3.0-or-later。
任何基于本仓库构建并对外分发的二进制，必须随附**该次构建的对应源码**与两份许可证全文；
私有仓库只适合自留构建产物，不能据此对外闭源分发。
