#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Added for lyu323 4.9-port-kit (2026-11-24). New file; NOT upstream source.
#
# 只读体检：检查一份内核源码树，输出 4.9 手动集成 KernelSU 需要改哪些文件。
# 不修改任何文件、不编译、不刷机。用法：
#   bash scripts/check-kernel-source.sh /path/to/kernel/source

set -u
SRC="${1:-}"
if [ -z "$SRC" ] || [ ! -d "$SRC" ]; then
  echo "usage: bash scripts/check-kernel-source.sh <kernel-source-dir>" >&2
  exit 2
fi
cd "$SRC" || exit 2

echo "== KernelSU 4.9 移植体检（只读） =="
echo "   dir: $(pwd)"
echo

# 1) 内核版本
VER=$(grep -m1 '^VERSION = ' Makefile 2>/dev/null | awk '{print $3}')
PAT=$(grep -m1 '^PATCHLEVEL = ' Makefile 2>/dev/null | awk '{print $3}')
SUB=$(grep -m1 '^SUBLEVEL = ' Makefile 2>/dev/null | awk '{print $3}')
KVER="${VER:-?}.${PAT:-?}.${SUB:-?}"
echo "--- kernel version ---"
echo "  Makefile: $KVER"
if [ "${VER:-0}" -eq 4 ] 2>/dev/null && [ "${PAT:-0}" -eq 9 ] 2>/dev/null; then
  echo "  => 4.9 分支：低于官方 4.14 基线，属于实验性手动移植"
else
  echo "  => 非 4.9：请按实际版本重新核对 hook 签名"
fi
echo

# 2) 目录布局
echo "--- tree layout ---"
for d in drivers common/drivers fs/exec.c fs/open.c fs/read_write.c fs/stat.c fs/namespace.c fs/devpts/inode.c drivers/input/input.c; do
  [ -e "$d" ] && echo "  [ok]   $d" || echo "  [MISS] $d"
done
echo

# 3) 关键符号
echo "--- hook symbols (which ones exist) ---"
check() {
  local label="$1" file="$2" sym="$3"
  if [ -f "$file" ] && grep -q "$sym" "$file" 2>/dev/null; then
    printf '  [yes] %-22s %-24s in %s\n' "$label" "$sym" "$file"
  else
    printf '  [no ] %-22s %-24s in %s\n' "$label" "$sym" "$file"
  fi
}
check faccessat        fs/open.c        'do_faccessat'
check faccessat_syscall fs/open.c       'SYSCALL_DEFINE3(faccessat'
check execve           fs/exec.c        'do_execveat_common'
check execve_file      fs/exec.c        '__do_execve_file'
check vfs_read         fs/read_write.c  'vfs_read'
check statx            fs/stat.c        'vfs_statx'
check fstatat          fs/stat.c        'vfs_fstatat'
# path_umount 用「函数定义」匹配，避免把注释里的字样误判成已存在
if [ -f fs/namespace.c ] && grep -Eq 'path_umount[[:space:]]*\(' fs/namespace.c 2>/dev/null; then
  echo '  [yes] path_umount            (function present)    in fs/namespace.c'
  HAS_PATH_UMOUNT=1
else
  echo '  [no ] path_umount            (needs backport)      in fs/namespace.c'
  HAS_PATH_UMOUNT=0
fi
check devpts           fs/devpts/inode.c 'devpts_get_priv'
echo

# 4) 已有配置
echo "--- config state ---"
CFG=""
for c in .config arch/arm64/configs/*_defconfig arch/arm64/configs/vendor/*_defconfig; do
  [ -f "$c" ] && CFG="$c" && break
done
if [ -n "$CFG" ]; then
  echo "  config file: $CFG"
  for k in CONFIG_KSU CONFIG_KPROBES CONFIG_MODULES CONFIG_HAVE_KPROBES CONFIG_KPROBE_EVENTS; do
    v=$(grep -m1 -E "^${k}=|^# ${k} is not set" "$CFG" 2>/dev/null || echo '(not set)')
    echo "    $k -> $v"
  done
else
  echo "  (no .config / defconfig found yet; run your normal defconfig first)"
fi
echo

# 5) 结论
echo "--- conclusion ---"
echo "  1. 路线：手动挂 hook（4.9 上 kprobe 通常不可靠），并关闭 CONFIG_KPROBES。"
echo "  2. 必改文件：fs/exec.c、fs/open.c、fs/read_write.c、fs/stat.c。"
grep -q 'do_faccessat' fs/open.c 2>/dev/null \
  && echo "     open.c：用 do_faccessat" \
  || echo "     open.c：没有 do_faccessat -> 改挂 faccessat 系统调用入口"
grep -q 'vfs_statx' fs/stat.c 2>/dev/null \
  && echo "     stat.c：用 vfs_statx" \
  || echo "     stat.c：没有 vfs_statx -> 改挂 vfs_fstatat"
[ "${HAS_PATH_UMOUNT:-0}" -eq 0 ] \
  && echo "  3. fs/namespace.c 缺 path_umount 函数 -> 需回移植（内核 < 5.9，卸载模块功能）"
echo "  4. 建议补：fs/devpts/inode.c (devpts_get_priv, 修 pm)、drivers/input/input.c (安全模式)。"
echo "  5. 先原样编译能开机，再集成；fastboot boot 试刷不落盘，确认后再 flash。"
echo
echo "本脚本只读。它不验证厂商内核是否完整、不保证编译通过、不保证能开机。"
echo "详见 port-kit/PORT_PLAN.md 与官方归档文档。"
