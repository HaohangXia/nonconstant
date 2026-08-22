#!/usr/bin/env bash
#
# latch · silent-failure-scan  (T5)
#
#   ⭐ T5:任何可能失败的操作,若其失败不改变任何可观测输出,
#      则该失败必然被累积到灾难规模。⛔ 与失败率无关,只与速率是否 > 0 有关。
#      实证:86 GB 撑爆 C 盘(2,983 个泄漏工位 ≈26 GB + pytest 临时目录 60 GB)。
#
#   ⚠️ ⛔ 扫描单位必须是**函数作用域**,⛔ 不用行数窗口。
#      实证:行数窗口(8 行)误报率 10%,函数作用域降到 0。
#      误报根因:捕获在这一行,查返回码可以在函数任何位置 —— 8 行窗口够不着。
#      见 16-DECISIONS D-15。
#
# 退出码:
#   0  过     —— 未发现静默失败
#   1  未过   —— 发现静默失败(逐条列出 路径:行号)
#   2  扫描器自身故障 —— ⛔ 绝不因自身故障返回 0
#
# 用法:  bash .latch/scan-silent.sh <目录>

set -u

die_broken() {
  printf '⛔ SCAN BROKEN: %s\n' "$1" >&2
  exit 2
}

TARGET="${1:-}"
[ -n "$TARGET" ]  || die_broken "未给扫描目标 —— ⛔ 没有目标不等于没有静默失败"
[ -e "$TARGET" ]  || die_broken "扫描目标不存在: $TARGET —— ⛔ 不得当成「没有静默失败 ⇒ 放行」"
[ -d "$TARGET" ]  || die_broken "扫描目标不是目录: $TARGET"

CONFIG="latch.yml"
[ -f "$CONFIG" ] || die_broken "找不到 $CONFIG —— ⛔ 没有配置不等于没有静默失败"

# ⛔ 显式豁免清单来自 latch.yml,⛔ 不硬编码在本脚本里。
# ⭐ 它受 Phase 1 测试守卫保护:改豁免 = 改判据 ⇒ criteria-guard 判红。
EXCLUDES=$(awk '
  /^[ \t]*exclude:/ { e = 1; next }
  /^[a-z_]/         { e = 0 }
  e && /^[ \t]*-[ \t]*path:/ { sub(/^[ \t]*-[ \t]*path:[ \t]*/, ""); print }
' "$CONFIG") || die_broken "读豁免清单失败"

FILES=$(find "$TARGET" -type f \( -name '*.py' -o -name '*.sh' \) | sort) \
  || die_broken "find 失败"

# 逐条剔除豁免项,并把剔除结果**打印出来** —— ⛔ 豁免不得静默生效(T5)
for ex in $EXCLUDES; do
  [ -n "$ex" ] || continue
  if printf '%s\n' "$FILES" | grep -qxF "$ex"; then
    printf '⚠️ 已豁免(latch.yml 显式登记): %s\n' "$ex"
    FILES=$(printf '%s\n' "$FILES" | grep -vxF "$ex")
  fi
done

FINDINGS=""

# ── 第一类:点位判据(与作用域无关 —— 信号在该处就被丢弃)──────────
# ⭐⭐ Phase 10:消息文本用**模式的名字**(OR-TRUE / STDERR-DEVNULL),
#    ⛔ 不嵌模式本身 —— 否则本文件会命中自己,而那需要一条豁免来遮盖。
#    ⚠️ 实测:这是自扫豁免的**全部**根因(恰好 2 处,都在 printf 里,⛔ 不在正则里);
#    改两句措辞即消除,**0 净增行**。⛔ 「要真解析器才能消」已被证伪。
#    ⇒ ⛔ 谁把字面模式写回消息里,自扫立刻判红 —— ⭐ 那是自防,不是故障。
# `|| true` / `2>/dev/null` / `except ...: pass`
for f in $FILES; do
  [ -r "$f" ] || die_broken "读不了 $f"
  hits=$(awk '
    /^[ \t]*#/                  { prev = $0; next }   # ⛔ 注释行不是代码,跳过
    /\|\|[ \t]*true/            { printf "%s:%d\tOR-TRUE 惯用法 —— 失败被吞\n", FILENAME, NR }
    /2>[ \t]*\/dev\/null/       { printf "%s:%d\tSTDERR-DEVNULL 惯用法 —— 错误输出被丢弃\n", FILENAME, NR }
    /except[^:]*:[ \t]*pass[ \t]*$/ { printf "%s:%d\texcept: pass —— 异常被吞\n", FILENAME, NR }
    /^[ \t]*pass[ \t]*$/ && prev ~ /^[ \t]*except/ { printf "%s:%d\texcept: pass(跨行)—— 异常被吞\n", FILENAME, NR }
    { prev = $0 }
  ' "$f") || die_broken "点位扫描失败于 $f"
  [ -z "$hits" ] || FINDINGS="${FINDINGS}${hits}"$'\n'
done

# ── 第二类:函数作用域判据 ─────────────────────────────────────────
# capture_output=True,而**整个函数体内**都没有 returncode / .stdout /
# .stderr / check=True ⇒ 捕获了却没人看 ⇒ 静默。
# ⭐ 判定范围是函数,⛔ 不是固定行数 —— 查返回码可以在函数任何位置。
for f in $FILES; do
  case "$f" in *.py) ;; *) continue ;; esac
  hits=$(awk '
    function flush(   i, cap, capline, seen) {
      cap = 0
      for (i = 1; i <= n; i++)
        if (body[i] ~ /capture_output[ \t]*=[ \t]*True/) { cap = 1; capline = ln[i]; break }
      if (cap) {
        seen = 0
        for (i = 1; i <= n; i++)
          if (body[i] ~ /returncode|\.stdout|\.stderr|check[ \t]*=[ \t]*True/) { seen = 1; break }
        if (!seen)
          printf "%s:%d\tcapture_output=True 但作用域「%s」内全程未查 returncode/.stdout/.stderr/check\n", FILENAME, capline, scope
      }
      n = 0
    }
    BEGIN { scope = "<模块级>"; find = -1; n = 0 }
    {
      match($0, /^[ \t]*/); ind = RLENGTH
      if ($0 ~ /^[ \t]*def [A-Za-z_]/) {
        flush()
        find = ind; scope = $0
        sub(/^[ \t]*def[ \t]+/, "", scope); sub(/\(.*/, "", scope)
        next
      }
      if (find >= 0 && $0 !~ /^[ \t]*$/ && $0 !~ /^[ \t]*#/ && ind <= find) {
        flush(); find = -1; scope = "<模块级>"
      }
      if ($0 ~ /^[ \t]*#/) next                      # ⛔ 注释行不进函数体
      n++; body[n] = $0; ln[n] = NR
    }
    END { flush() }
  ' "$f") || die_broken "函数作用域扫描失败于 $f"
  [ -z "$hits" ] || FINDINGS="${FINDINGS}${hits}"$'\n'
done

# ── 判定 ──────────────────────────────────────────────────────────
if [ -n "$(printf '%s' "$FINDINGS" | tr -d '[:space:]')" ]; then
  printf '⛔ silent-failure-scan FAIL —— 发现静默失败:\n' >&2
  printf '%s' "$FINDINGS" | sed '/^$/d; s/^/   · /' >&2
  printf '⇒ T5:失败不改变可观测输出 ⇒ 无人知晓 ⇒ 无人修 ⇒ 必然累积到灾难规模。\n' >&2
  printf '⚠️ 若命中落在**判据自身的消息文本**里(不是真的静默失败)——\n' >&2
  printf '   ⭐ 改那句措辞(用模式的名字,别嵌模式本身),⛔ 不要开豁免。见 Phase 10。\n' >&2
  exit 1
fi

printf '⭐ silent-failure-scan PASS —— 扫描 %s 个文件,未发现静默失败\n' \
  "$(printf '%s\n' "$FILES" | sed '/^$/d' | wc -l)"
exit 0
