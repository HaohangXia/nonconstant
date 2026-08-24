#!/usr/bin/env bash
#
# nonconstant · readme-runnable  —— README 里的命令必须真能跑
#
#   ⭐ 一份 README 最常见的失效方式:命令曾经能跑,后来文件改名了。
#      ⛔ 而 README 不会因此报错 —— 它只是**悄悄变成假的**(T5 形状)。
#
#   本判据查两件事:
#     ① README 的 ```bash 块里凡引用 `.nonconstant/<x>.sh` / `install.sh` 的,
#        那个文件**必须存在**
#     ② ⭐ **三条必含内容必须在文中**(A008 §4)——
#        隐去任一条 = 把 nonconstant 卖成「装上就不会错」
#
#   ⚠️ ⛔ 本判据**查不了**「README 有没有说服力」—— 那是 D5,A008 已承认。
#
# 退出码:
#   0  过
#   1  未过 —— 有命令指向不存在的文件,或必含内容缺失
#   2  闸自身故障
#
# 用法:  bash .nonconstant/readme-runnable.sh [README 路径]

set -u

die_broken() { printf '⛔ README-RUNNABLE BROKEN: %s\n' "$1" >&2; exit 2; }

# ⭐⭐ 配置取值一律走 .nonconstant/config-read.sh —— ⛔ 本脚本内不再自行解析
NONCONSTANT_DIR=$(dirname "$0")
# shellcheck source=/dev/null
. "$NONCONSTANT_DIR/config-read.sh" || die_broken "读不到 $NONCONSTANT_DIR/config-read.sh —— ⛔ 取值出口缺失 ≠ 配置为空"

CONFIG="nonconstant.yml"
[ -f "$CONFIG" ] || die_broken "找不到 $CONFIG —— ⛔ 读不到 subjects"
DOC="${1:-}"
[ -n "$DOC" ] || DOC=$(nc_subject "$CONFIG" readme)
[ -n "$DOC" ] || die_broken "$CONFIG 的 subjects 里没有 readme —— ⛔ 没配就判不了,不得猜"
[ -f "$DOC" ] || die_broken "找不到 $DOC —— ⛔ README 不存在 ≠ README 没问题"

BAD=""
note() { BAD="${BAD}   · ${1}"$'\n'; }

# ── ① 命令引用的文件必须存在 ──────────────────────────────────────
# 只取 ```bash 围栏内的行,再抽出形如 .nonconstant/x.sh 或 install.sh 的 token
REFS=$(awk '
  /^```bash$/ { inb = 1; next }
  /^```/      { inb = 0 }
  inb         { print }
' "$DOC" | grep -o '\(\.nonconstant/\)\?[A-Za-z0-9_-]\+\.sh' | sort -u)

NREF=0
for r in $REFS; do
  NREF=$((NREF + 1))
  [ -f "$r" ] || note "README 的命令引用了不存在的文件:$r"
done
[ "$NREF" -gt 0 ] || note "README 的 \`\`\`bash 块里一条 nonconstant 命令都没有 —— ⛔ 一份没有可跑命令的 README 与没有 README 无法区分"

# ── ② 三条必含内容 ────────────────────────────────────────────────
# ⭐ 查的是**标记**,⛔ 不是措辞 —— 措辞会改,标记是契约(与 C12 第二形态同一教训:
#    ⛔ 别把判据绑在人类可读文案上)。README 里以 HTML 注释形式落这三个锚。
# ⭐ 第四个锚点(归属)由 A011 加入 —— ⛔ 外部项目的名字必须留在文中,
#    ⚠️ 而它们正是「为什么改名」的证据(LATCH-global-replace-cannot-distinguish-ownership)。
for anchor in nonconstant:disclosure:mechanized-ratio \
              nonconstant:disclosure:checkable-not-correct \
              nonconstant:disclosure:known-gaps \
              nonconstant:disclosure:attribution; do
  grep -qF "$anchor" "$DOC" \
    || note "README 缺少必含内容锚点:$anchor(A008 §4 · A011 —— 隐去 = 把 nonconstant 卖成「装上就不会错」)"
done

if [ -n "$(printf '%s' "$BAD" | tr -d '[:space:]')" ]; then
  printf '⛔ readme-runnable FAIL —— %s 不合格:\n' "$DOC" >&2
  printf '%s' "$BAD" >&2
  printf '⇒ ⛔ 一份命令跑不通、或隐去已知缺口的 README,比没有 README 更坏。\n' >&2
  exit 1
fi

printf '⭐ readme-runnable PASS —— %s:%s 条命令引用均存在,四条必含内容齐全\n' "$DOC" "$NREF"
exit 0
