#!/usr/bin/env bash
#
# latch · waiver-expiry  —— 豁免到期判据
#
#   ⭐ 写下的到期没有判据 = 没有到期(= LATCH-uncheckable-limit 同族)。
#   实证:`latch.yml` 已有多处豁免形态,⛔ 到期从未被任何东西检查。
#
#   判红的三种情形:
#     ① until 里没有「Phase <n>」  ⇒ ⛔ 不是具体 phase,等于「以后」
#     ② n ∈ 已完成集合             ⇒ ⛔ 已过期未清
#     ③ n >  §10 已排的最大 phase  ⇒ ⛔ 指向一个不存在的阶段 = 「以后」换个写法
#
#   ⭐ 已完成集合 = reports/phase<N>-*.md 里出现过的**全部**编号(⛔ 不是最大值);
#     已排最大 phase 取自 01-PLAN.md 的 `### Phase <n>` 标题(⛔ 与顺序无关)。
#
# 退出码:
#   0  过     —— 每条豁免都指向一个**尚未到达且已排期**的 phase
#   1  未过   —— 有豁免过期 / 不是具体 phase / 指向未排期的 phase
#   2  闸自身故障
#
# 用法:  bash .latch/waiver-expiry.sh [配置文件] [PLAN 文件]

set -u

die_broken() { printf '⛔ WAIVER-EXPIRY BROKEN: %s\n' "$1" >&2; exit 2; }

# ⭐⭐ 配置取值一律走 .latch/config-read.sh —— ⛔ 本脚本内不再自行解析
#    (C12 第二形态:行尾注释/引号被吞进取值 ⇒ 恒不命中 ⇒ 判据静默失效)
LATCH_DIR=$(dirname "$0")
# shellcheck source=/dev/null
. "$LATCH_DIR/config-read.sh" || die_broken "读不到 $LATCH_DIR/config-read.sh —— ⛔ 取值出口缺失 ≠ 配置为空"

CONFIG="${1:-latch.yml}"
PLAN="${2:-}"
[ -f "$CONFIG" ] || die_broken "找不到 $CONFIG —— ⛔ 读不到 subjects"
[ -n "$PLAN" ] || PLAN=$(latch_subject "$CONFIG" plan)
[ -n "$PLAN" ] || die_broken "$CONFIG 的 subjects 里没有 plan —— ⛔ 没配就判不了,不得猜"
[ -f "$CONFIG" ] || die_broken "找不到 $CONFIG —— ⛔ 没有配置不等于没有过期豁免"
[ -f "$PLAN" ]   || die_broken "找不到 $PLAN —— ⛔ 算不出已排到第几 phase"
REPORTS=$(latch_subject "$CONFIG" reports)
[ -n "$REPORTS" ] || die_broken "$CONFIG 的 subjects 里没有 reports —— ⛔ 没配就判不了"
[ -d "$REPORTS" ] || die_broken "报告目录不存在: $REPORTS —— ⛔ 算不出当前 phase,不得当成「没有过期」"

# ⭐⭐ 进度 = **已完成 phase 的集合**,⛔ 不是「最大编号」。
#    A007 之后编号 = 身份 ≠ 顺序 ⇒ 可能先跑 Phase 10 再跑 Phase 8。
#    ⛔ 用最大编号当进度,跑完 10 后会把 until: Phase 8 误判成「已过期」——
#    而 Phase 8 根本还没跑。⇒ 「已过期」的准确定义是「**那个 phase 已完成**」,
#    ⭐ 即编号落在已完成集合里,⛔ 与大小无关。
DONE=$(ls "$REPORTS"/ | sed 's/^phase\([0-9]\+\)-.*\.md$/\1/;t;d' | sort -n -u) \
  || die_broken "扫 reports/ 失败"
[ -n "$DONE" ] || die_broken "$REPORTS 下一份 phase 报告都没有 —— ⛔ 算不出已完成哪些 phase"
DONE_LIST=$(printf '%s' "$DONE" | tr '\n' ' ')

MAXP=$(grep '^### Phase ' "$PLAN" | sed 's/^### Phase \([0-9]\+\).*/\1/;t;d' | sort -n | tail -1) \
  || die_broken "扫 $PLAN 的 phase 标题失败"
[ -n "$MAXP" ] || die_broken "$PLAN 里没有 '### Phase <n>' 标题 —— ⛔ 判不了「已排期」"

# 取所有到期字段:`until:` 与 `waiver_until:`,连同它所在的行号
ENTRIES=$(grep -n '^[ \t]*\(waiver_\)\?until:' "$CONFIG" \
          | sed 's/^\([0-9]*\):[ \t]*\(waiver_\)\?until:[ \t]*/\1\t/') \
  || ENTRIES=""

BAD=""
N=0
while IFS=$'\t' read -r lineno val; do
  [ -n "${lineno:-}" ] || continue
  N=$((N + 1))
  n=$(printf '%s' "$val" | sed 's/.*[Pp]hase[ \t]*\([0-9]\+\).*/\1/;t;d')
  if [ -z "$n" ]; then
    BAD="${BAD}   · $CONFIG:$lineno ⛔ until 里没有「Phase <n>」:「$val」⇒ 不是具体 phase,等于「以后」"$'\n'
    continue
  fi
  if printf '%s\n' "$DONE" | grep -qx "$n"; then
    BAD="${BAD}   · $CONFIG:$lineno ⛔ 已过期:until = Phase $n,而 Phase $n 已完成(已完成: $DONE_LIST)"$'\n'
    continue
  fi
  if [ "$n" -gt "$MAXP" ]; then
    BAD="${BAD}   · $CONFIG:$lineno ⛔ Phase $n 尚未排期(§10 只排到 Phase $MAXP)⇒ 「以后」换个写法"$'\n'
    continue
  fi
done <<EOF
$ENTRIES
EOF

# ⛔ vacuous 防线:一条豁免都没有 ⇒ 判 0 是**正确**的 ——
#    本判据断言的是「**每一条**豁免都未过期」,零条时该断言为真。
#    ⚠️ 与 status-facts 不同:那里零断言 = 未履行职责;⭐ 这里零豁免 = 本来就没欠债。
if [ "$N" -eq 0 ]; then
  printf '⭐ waiver-expiry PASS —— %s 里一条豁免都没有(已完成: %s)\n' "$CONFIG" "$DONE_LIST"
  exit 0
fi

if [ -n "$(printf '%s' "$BAD" | tr -d '[:space:]')" ]; then
  printf '⛔ waiver-expiry FAIL —— 以下豁免不合格(已完成: %s· 已排到 Phase %s):\n' "$DONE_LIST" "$MAXP" >&2
  printf '%s' "$BAD" >&2
  printf '⇒ 写下的到期没有判据 = 没有到期。⛔ 修豁免,不是修判据。\n' >&2
  exit 1
fi

printf '⭐ waiver-expiry PASS —— %s 条豁免均指向尚未完成且已排期的 phase(已完成: %s)\n' "$N" "$DONE_LIST"
exit 0
