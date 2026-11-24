<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Added for lyu323 4.9-port-kit (2026-11-24). New file; NOT upstream source. -->
# 合规说明（GPL 双许可）

## 1. 许可证

| 范围 | 许可证 | 文件 |
| --- | --- | --- |
| `kernel/**` | **GPL-2.0-only** | `kernel/LICENSE`（18 KB 全文） |
| 其余（`userspace/`、`manager/`、`scripts/`、`docs/` …） | **GPL-3.0-or-later** | `LICENSE`（35 KB 全文） |

两份许可证全文**逐字节未改**，随仓库与每个 Release 资产分发。

## 2. 源码来源与改动

- 本仓库的根目录源码 = 官方 `tiann/KernelSU` 的 **v0.9.5 tag**，commit
  `b766b98513b5a7eb33bc1c4a76b5702bf1288f07`，**逐字节未改动**（从官方 codeload zip 展开）。
- 本仓库**新增**的文件只有：`port-kit/**`、`PORT_KIT_NOTICE.md`、`README_PORT.md`、
  `.github/workflows/fetch-official-manager.yml`、`PORT_KIT_RELEASE_NOTES.md`。
  每个新增文件都带 `SPDX-License-Identifier: GPL-3.0-or-later` 与日期声明。
- 这些新增文件是**移植准备材料（文档 + 只读脚本 + 配置片段）**，不是 KernelSU 的修改版实现；
  没有改动 upstream 的任何 `.c` / `.h` / `.kt` / Makefile，本仓库新增文件里也没有任何二进制。
- 需注意：官方 v0.9.5 源码树**本身**自带少量预编译工具（`userspace/ksud/bin/*/{busybox,ksuinit}`、
  `manager/app/src/main/jniLibs/*/libmagiskboot.so` 等）。这些是上游原样内容、逐字节未改，
  其对应源码同在本仓库；本仓库没有往里添加任何新的二进制。

## 3. 分发义务（按你补充的合规背景）

> KernelSU 上游是 GPL 开源协议，任何修改后再分发的版本，都必须随包提供对应源码并保留许可证；
> 私有仓库只适合你自己留存构建产物，不能据此对外闭源分发。

本仓库据此执行：

1. 任何基于本仓库构建并对外分发的二进制（**包括你将来编出的 `boot.img`、`kernelsu.ko`、
   重新编译的 Manager APK**），必须随附**该次构建的对应源码**与两份许可证全文。
2. 若你修改了 `kernel/**`，GPL-2.0-only 部分按 GPL-2.0 §2(a) 标注改动文件与日期；
   其余按 GPL-3.0 §5(a) 同样标注。
3. **私有仓库只适合自留构建产物**，不能据此对外闭源分发。本仓库是 public。
4. 与之前「ChmlFrp/Cpolar 自写 App 可抽掉内核二进制」不同：这次分发的是**上游 GPL 源码本身**，
   因此**必须完整公开、不能裁剪核心代码**。这是协议要求，不是疏漏。

## 4. 官方原版 Manager APK

Release 里的 `KernelSU_v0.9.5_11872-release.apk` 是从**官方 v0.9.5 Release** 取回的未修改二进制，
仅作 Android 9 可安装的管理面板参考。它的对应源码即本仓库 `manager/` 树（GPL-3.0-or-later），
两份许可证随包。它不是本仓库编译产物，也不声称「适配 4.9」。

## 5. 明确不提供

- 预编译 `boot.img` / `.ko` / AnyKernel3 包
- 任何「适配版 / 一键 root」APK
- 绕过安全补丁、exploit 调参或刷机担保

官方非 GKI 文档原文：*Due to the fragmentation of non-GKI kernels, we don't have a universal way
to build them; therefore, we cannot provide a non-GKI boot.img.*
