#!/usr/bin/env bash
#
# latch · waiver-expiry  —— 豁免到期判据
#
#   ⭐ 写下的到期没有判据 = 没有到期(= LATCH-uncheckable-limit 同族)。
#   实证:`latch.yml` 已有多处豁免形态,⛔ 到期从未被任何东西检查。
#
#   判红的三种情形:
#     ① until 里没有「Phase <n>」  ⇒ ⛔ 不是具体 phase,等于「以后」
#     ② n <= 当前 phase            ⇒ ⛔ 已过期未清
#     ③ n >  §10 已排的最大 phase  ⇒ ⛔ 指向一个不存在的阶段 = 「以后」换个写法
#
#   当前 phase 取自 reports/phase<N>-*.md 的最大编号;
#   已排最大 phase 取自 01-PLAN.md 的 `### Phase <n>` 标题。
#
# 退出码:
#   0  过     —— 每条豁免都指向一个**尚未到达且已排期**的 phase
#   1  未过   —— 有豁免过期 / 不是具体 phase / 指向未排期的 phase
#   2  闸自身故障
#
# 用法:  bash .latch/waiver-expiry.sh [配置文件] [PLAN 文件]

set -u

die_broken() { printf '⛔ WAIVER-EXPIRY BROKEN: %s\n' "$1" >&2; exit 2; }

# ⭐ 被判定对象来自 latch.yml 的 subjects:(A006 探针 4)。⛔ 无硬编码默认值 ——
#    硬编码会悄悄指向 latch 自己的仓布局。⚠️ argv 仍可覆盖(红检指向 fixture,C3)。
subject_of() {   # subject_of <配置文件> <键>
  awk -v key="$2" '
    /^subjects:/ { inb = 1; next }
    /^[a-z_]/    { inb = 0 }
    inb && $0 ~ "^[ 	]+" key ":" { sub("^[ 	]+" key ":[ 	]*", ""); print; exit }
  ' "$1"
}

CONFIG="${1:-latch.yml}"
PLAN="${2:-}"
[ -f "$CONFIG" ] || die_broken "找不到 $CONFIG —— ⛔ 读不到 subjects"
[ -n "$PLAN" ] || PLAN=$(subject_of "$CONFIG" plan)
[ -n "$PLAN" ] || die_broken "$CONFIG 的 subjects 里没有 plan —— ⛔ 没配就判不了,不得猜"
[ -f "$CONFIG" ] || die_broken "找不到 $CONFIG —— ⛔ 没有配置不等于没有过期豁免"
[ -f "$PLAN" ]   || die_broken "找不到 $PLAN —— ⛔ 算不出已排到第几 phase"
REPORTS=$(subject_of "$CONFIG" reports)
[ -n "$REPORTS" ] || die_broken "$CONFIG 的 subjects 里没有 reports —— ⛔ 没配就判不了"
[ -d "$REPORTS" ] || die_broken "报告目录不存在: $REPORTS —— ⛔ 算不出当前 phase,不得当成「没有过期」"

CUR=$(ls "$REPORTS"/ | sed 's/^phase\([0-9]\+\)-.*\.md$/\1/;t;d' | sort -n | tail -1) \
  || die_broken "扫 reports/ 失败"
[ -n "$CUR" ] || die_broken "$REPORTS 下一份 phase 报告都没有 —— ⛔ 算不出当前 phase"

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
  if [ "$n" -le "$CUR" ]; then
    BAD="${BAD}   · $CONFIG:$lineno ⛔ 已过期:until = Phase $n,而当前已到 Phase $CUR"$'\n'
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
  printf '⭐ waiver-expiry PASS —— %s 里一条豁免都没有(当前 Phase %s)\n' "$CONFIG" "$CUR"
  exit 0
fi

if [ -n "$(printf '%s' "$BAD" | tr -d '[:space:]')" ]; then
  printf '⛔ waiver-expiry FAIL —— 以下豁免不合格(当前 Phase %s,已排到 Phase %s):\n' "$CUR" "$MAXP" >&2
  printf '%s' "$BAD" >&2
  printf '⇒ 写下的到期没有判据 = 没有到期。⛔ 修豁免,不是修判据。\n' >&2
  exit 1
fi

printf '⭐ waiver-expiry PASS —— %s 条豁免均指向尚未到达且已排期的 phase(当前 Phase %s)\n' "$N" "$CUR"
exit 0
