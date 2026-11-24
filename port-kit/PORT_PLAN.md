<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Added for lyu323 4.9-port-kit (2026-11-24). New file; NOT upstream source. -->
# 4.9 内核手动集成 KernelSU（v0.9.5）逐文件清单

> 依据：官方已归档文档 [Integrate for non-GKI devices](https://kernelsu.org/guide/how-to-integrate-for-non-gki.html)
> 与 v0.9.5 `kernel/setup.sh`。**4.9 低于官方 4.14 基线，属于实验性手动移植，不保证成功。**

## 0. 前置（缺一不可）

- 本机型可编译、可开机的内核源码（vivo 开源站查 `PD1901`）
- 原厂 `boot.img`（**必须与当前系统版本完全一致**）、其压缩格式（gz / lz4 / 未压缩）
- 已解锁 Bootloader、fastboot 可用、交叉工具链（arm64 用 `aarch64-linux-android-`）、mkbootimg
- 完整数据备份；最好有一条救砖刷回原厂包的通路

## 1. 把 KernelSU 加进内核树

在内核源码根目录执行（**注意参数是 v0.9.5，不是 main**）：

```bash
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/v0.9.5/kernel/setup.sh" | bash -s v0.9.5
```

脚本会：`git clone` KernelSU 并 checkout 指定 tag → 在 `drivers/`（或 `common/drivers/`）建 `kernelsu` 软链 →
往 `drivers/Makefile` 加 `obj-$(CONFIG_KSU) += kernelsu/` → 往 `drivers/Kconfig` 加 `source "drivers/kernelsu/Kconfig"`。

本仓库已经把 v0.9.5 源码原样放在根目录，你也可以直接把 `kernel/` 软链/复制到 `drivers/kernelsu`，
并手工补上面两行 Makefile / Kconfig（效果相同）。

## 2. 路线选择：4.9 走**手动集成**

| 路线 | 4.9 上的判断 |
| --- | --- |
| kprobe 自动 | 官方文档说内核 < 4.8 必须手动；4.9 紧贴边界且厂商内核 kprobe 常有 bug，**不推荐** |
| 手动挂 hook | **本仓库推荐**。手动集成时**必须关闭 `CONFIG_KPROBES`**，否则开机按音量下会误触 KernelSU 安全模式 |

配置（`port-kit/config/manual-4.9.cfg`）：

```
CONFIG_KSU=y
CONFIG_MODULES=y
# CONFIG_KPROBES is not set
# CONFIG_HAVE_KPROBES is not set
# CONFIG_KPROBE_EVENTS is not set
```

（`CONFIG_MODULES` 视内核情况；若走 kprobe 路线才用 `config/kprobe-route.cfg`。）

## 3. 四个必须挂的 hook（4.9 特有差异）

官方给的参考补丁基于较新内核，4.9 要按下面兜底：

| # | 新版符号 | 文件 | 4.9 上的实际做法 |
| --- | --- | --- | --- |
| 1 | `do_faccessat` | `fs/open.c` | **4.9 没有 `do_faccessat`（4.17 才引入）** → 在 `SYSCALL_DEFINE3(faccessat, ...)` / `sys_faccessat` 函数体入口、`lookup_flags` 定义之后，插入 `ksu_handle_accessat(&dfd, &filename, &mode, NULL)`，用 `#ifdef CONFIG_KSU` 包裹并声明 extern |
| 2 | `do_execveat_common` / `__do_execve_file` | `fs/exec.c` | 4.9 多为 `do_execveat_common(int fd, struct filename *, ...)` 或 `__do_execve_file`。在变量声明之后、实际执行之前插 `ksu_handle_execveat(...)` / `ksu_handle_execveat_sucompat(...)`；**注意 C89 风格：变量定义不能在语句之后**，别把 hook 插到声明中间 |
| 3 | `vfs_read` | `fs/read_write.c` | 在 `vfs_read` 入口插 `ksu_handle_vfs_read(...)`；4.9 签名与新版接近但仍需核对 `struct file *`、`char __user *`、`size_t`、`loff_t *` |
| 4 | `vfs_statx` | `fs/stat.c` | **4.9 没有 `vfs_statx`** → 改挂 `vfs_fstatat`（`ksu_handle_stat` 系列），对照官方 stat.c 补丁改参数 |

所有插入都用 `#ifdef CONFIG_KSU ... #endif` 包裹，extern 声明放在文件顶部或函数前。

## 4. 三个可选但强烈建议的补丁

| 文件 | 作用 | 4.9 必要性 |
| --- | --- | --- |
| `fs/devpts/inode.c` → `devpts_get_priv` | 修 root 后 `pm` 命令失效 | **建议加**（老内核常见） |
| `drivers/input/input.c` | KernelSU 安全模式（组合键） | **建议加**；但手动路线已关 KPROBES，仍建议保留输入通路 |
| `fs/namespace.c` ← 回移植 `path_umount` | 「卸载模块」功能 | **内核 < 5.9 必需**，4.9 一定要做（参考官方 PR #1464 与归档文档末尾补丁） |

## 5. 编译与验证（顺序不能跳）

```bash
# 5.1 先原样编译一次，确认能开机（不加 KernelSU）
make ARCH=arm64 <defconfig> && make ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- -j$(nproc)

# 5.2 集成后编译
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- -j$(nproc) Image.gz
mkbootimg --kernel Image.gz --ramdisk <原厂ramdisk> -o boot-ksu.img

# 5.3 先试刷，不落盘（关键！）
fastboot boot boot-ksu.img

# 5.4 确认开机、Manager 识别、`su` 可用，才落盘
fastboot flash boot boot-ksu.img && fastboot reboot
```

**压缩格式必须和原厂一致**（gz / lz4 / 未压缩），格式刷错同样不开机。

## 6. 排错

| 症状 | 原因 | 处理 |
| --- | --- | --- |
| 卡 logo / bootloop | kprobe 损坏或 hook 插错位置 | `fastboot flash boot` 刷回原厂；注释 `kernel/ksu.c` 里 `ksu_sucompat_init()` / `ksu_ksud_init()` 验证是否 kprobe 问题；改走手动路线并关 KPROBES |
| 菜单里找不到 `CONFIG_KSU` | setup.sh 没跑 / Kconfig 没 source | 检查 `drivers/Kconfig` 与软链 |
| 开机误入安全模式 | 手动集成却没关 `CONFIG_KPROBES` | 关闭后重编 |
| `pm` 命令异常 | 缺 devpts hook | 补 `fs/devpts/inode.c` |
| 卸载模块不生效 | 缺 `path_umount` 回移植 | 补 `fs/namespace.c` |
| 面板显示 Unsupported | 内核没真正集成或没刷入新内核 | 确认当前启动的是你编译的内核 |

## 7. 本仓库不提供

- ❌ 预编译 `boot.img` / `kernelsu.ko` / AnyKernel3 包（官方也没有）
- ❌ 「适配版」Manager APK（root 不在 APK 里）
- ❌ 自动移植脚本（4.9 碎片化太重，必须人肉核对函数签名）
- ❌ 真机验证 / 刷机担保

`scripts/check-kernel-source.sh` 只做**只读体检**，把上面这些「有没有」先查清楚，不替你改一行代码。
