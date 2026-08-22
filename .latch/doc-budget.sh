#!/usr/bin/env bash
#
# latch · doc-budget  —— 文档预算判据
#
#   ⭐ 一个从不被机器检查的约束,等于不存在 ——
#      ⚠️ 而且比「没有约束」更坏,因为它让人**以为**有约束。
#   实证:STATUS.md 的「60 行」上限从未被任何东西检查,
#        进入 2026-08-22 那轮时已 77 行,无人知晓。
#        ⛔ 01-PLAN / 18-PROTOCOL 的上限之所以「有效」,是因为下达方每轮
#        要求报行数 ⇒ **人肉判据,换 session 即失效**。
#   见 03-LEDGER.md `LATCH-uncheckable-limit`,协议 C8。
#
#   ⭐ 计数范围支持 A001 的 scope 模型:exclude_sections 列出的 `## §<n>` 章节不计入。
#
# 退出码:
#   0  过     —— 每个文件都在预算内,或超限但已登记 waiver(⭐ 运行时打印)
#   1  未过   —— 有文件超限且**未登记 waiver**
#   2  闸自身故障
#
# 用法:  bash .latch/doc-budget.sh [配置文件]     # 默认 latch.yml

set -u

die_broken() { printf '⛔ DOC-BUDGET BROKEN: %s\n' "$1" >&2; exit 2; }

CONFIG="${1:-latch.yml}"
[ -f "$CONFIG" ] || die_broken "找不到配置 $CONFIG —— ⛔ 没有配置不等于都在预算内"

FILES=$(awk '/^[ \t]*-[ \t]*file:/ { sub(/^[ \t]*-[ \t]*file:[ \t]*/, ""); print }' "$CONFIG") \
  || die_broken "读 doc_budgets 失败"
[ -n "$FILES" ] || die_broken "$CONFIG 里没有 doc_budgets —— ⛔ 空清单会让本闸恒过(常量)"

field() {   # field <file> <key>
  awk -v want="$1" -v key="$2" '
    /^[ \t]*-[ \t]*file:/ {
      cur = $0; sub(/^[ \t]*-[ \t]*file:[ \t]*/, "", cur); inb = (cur == want); next
    }
    inb && $0 ~ "^[ \t]*" key ":" { sub("^[ \t]*" key ":[ \t]*", ""); print; exit }
  ' "$CONFIG"
}

count_lines() {   # count_lines <file> <exclude_sections>
  awk -v ex="$2" '
    BEGIN { n = split(ex, a, /[ \t]+/); for (i = 1; i <= n; i++) if (a[i] != "") EX[a[i]] = 1 }
    /^## §[0-9]+ / { s = $0; sub(/^## §/, "", s); sub(/ .*/, "", s); skip = (s in EX) }
    !skip { c++ }
    END { print c + 0 }
  ' "$1"
}

BAD=""
OK=0
for f in $FILES; do
  [ -f "$f" ] || die_broken "预算表里的文件不存在: $f —— ⛔ 文件缺失 ≠ 在预算内(C6)"
  max=$(field "$f" max_lines)
  case "$max" in
    ''|*[!0-9]*) die_broken "$f 的 max_lines 不是数字:「${max:-空}」" ;;
  esac
  ex=$(field "$f" exclude_sections)
  n=$(count_lines "$f" "$ex")

  if [ "$n" -le "$max" ]; then
    OK=$((OK + 1)); continue
  fi

  wr=$(field "$f" waiver_reason)
  wu=$(field "$f" waiver_until)
  if [ -n "$wr" ] && [ -n "$wu" ]; then
    # ⛔ 豁免不得静默生效(LATCH-waiver-must-announce)
    printf '⚠️ 已豁免(latch.yml 登记): %s  %s/%s 行 · 理由「%s」· 到期「%s」\n' \
      "$f" "$n" "$max" "$wr" "$wu"
    OK=$((OK + 1)); continue
  fi
  BAD="${BAD}   · $f: ⛔ $n / $max 行,超 $((n - max)) 行,且**未登记 waiver**"$'\n'
done

if [ -n "$(printf '%s' "$BAD" | tr -d '[:space:]')" ]; then
  printf '⛔ doc-budget FAIL —— 以下文件超出预算:\n' >&2
  printf '%s' "$BAD" >&2
  printf '⇒ 超限须在 latch.yml 登记 waiver(reason + until 具体 phase)。⛔ 写下的上限必须有机器判据(C8)。\n' >&2
  exit 1
fi

printf '⭐ doc-budget PASS —— %s 个文件均在预算内(或已登记豁免)\n' "$OK"
exit 0
