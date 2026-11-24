#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Added for lyu323 4.9-port-kit (2026-11-24). New file; NOT upstream source.
# 只读自检：确认 kit 完整、许可证齐全、没有二进制/密钥混入。
set -u
R="${1:-.}"
echo "== port-kit 自检 =="
ok=0; bad=0
need() { if [ -e "$R/$1" ]; then echo "  [ok]   $1"; ok=$((ok+1)); else echo "  [MISS] $1"; bad=$((bad+1)); fi }
need LICENSE
need kernel/LICENSE
need kernel/setup.sh
need port-kit/README.md
need port-kit/PORT_PLAN.md
need port-kit/COMPLIANCE.md
need port-kit/NOTICE
need port-kit/config/manual-4.9.cfg
need port-kit/scripts/check-kernel-source.sh
need PORT_KIT_NOTICE.md
echo
echo "--- 许可证全文长度 ---"
wc -c "$R/LICENSE" "$R/kernel/LICENSE" 2>/dev/null
echo "--- 新增文件里的二进制 / 私钥 / 令牌扫描（应为空）---"
echo "  (官方 v0.9.5 源码树自带 busybox / ksuinit / libmagiskboot.so 等预编译工具，属上游原样内容，不在本项检查范围)"
find "$R/port-kit" -type f \( -name '*.apk' -o -name '*.img' -o -name '*.ko' -o -name '*.so' -o -name '*.jks' -o -name '*.keystore' \) -print
grep -rIlE 'ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|BEGIN (RSA |EC )?PRIVATE KEY' "$R/port-kit" "$R"/*.md 2>/dev/null || true
echo
echo "result: ok=$ok miss=$bad"
echo "本仓库源码 = 官方 tiann/KernelSU v0.9.5 (b766b98513b5a7eb33bc1c4a76b5702bf1288f07)"
