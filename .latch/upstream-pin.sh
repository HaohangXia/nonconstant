#!/usr/bin/env bash
#
# latch · upstream-pin  —— 上游 pin 可核 + 未被本地改过
#
#   ⭐ 在 A005 之前,「pin 到 bca6790」**是一句话,不是可核事实** ——
#      vendor 是解包的源码树,⛔ 树上没有任何东西把它绑到某个 commit。
#   ⇒ ⭐⭐ submodule 记的**就是 commit 本身**,⛔ 不是版本声明、不是内容摘要。
#      **这是唯一非代用品的解法。**
#
#   本判据管两件事(⭐ B2 的两半):
#     ① 是不是 pin 的那一份  —— submodule HEAD == latch.yml:upstream_pin
#     ② 有没有被本地改过     —— submodule 工作区必须干净
#   ⚠️ ⛔ 只做 ① 不够:submodule 停在正确 commit 上,内容照样可以被改;
#      改了在超级项目里只显示为 ` M vendor/spec-kit`,⛔ 而 Phase 0 判据 2 看不见它。
#
# 退出码:
#   0  过     —— pin 相符,且上游未被本地改过
#   1  未过   —— pin 不符 / 上游被改过
#   2  闸自身故障 / **判不了** —— ⛔ 绝不因判不了而返回 0
#      ⚠️ 「未取回(空目录)」判 2:那是「**没测到**」,⛔ 不是「pin 没变」
#         (LATCH-cannot-judge-vs-judged-fail)
#
# 用法:  bash .latch/upstream-pin.sh [配置文件] [submodule 路径]

set -u

die_broken() { printf '⛔ UPSTREAM-PIN BROKEN: %s\n' "$1" >&2; exit 2; }

CONFIG="${1:-latch.yml}"
SUB="${2:-vendor/spec-kit}"

[ -f "$CONFIG" ] || die_broken "找不到 $CONFIG —— ⛔ 没有配置就没有 pin 可比"

WANT=$(sed 's/^upstream_pin:[ \t]*//;t;d' "$CONFIG") || die_broken "读 upstream_pin 失败"
[ -n "$WANT" ] || die_broken "$CONFIG 里没有 upstream_pin —— ⛔ 没写 pin ≠ pin 没变"

[ -d "$SUB" ] || die_broken "$SUB 不存在 —— ⛔ 上游不在 ≠ pin 没变"
if [ -z "$(ls -A "$SUB")" ]; then
  die_broken "$SUB 是空目录(submodule 未取回)—— ⛔ 没测到 ≠ 通过;请跑 git submodule update --init"
fi
git -C "$SUB" rev-parse --git-dir >/dev/null \
  || die_broken "$SUB 不是 git 仓 —— ⛔ 判不了它是哪个 commit(⚠️ 判 2 而非 1:没测到 ≠ pin 不符)"

HAVE=$(git -C "$SUB" rev-parse HEAD) || die_broken "读 $SUB 的 HEAD 失败"

BAD=""
if [ "$HAVE" != "$WANT" ]; then
  BAD="${BAD}   · pin 不符:配置要求 $WANT,实测 $HAVE"$'\n'
fi

# ② 上游未被本地改过。⚠️ 含未跟踪文件(`??`)—— 往上游塞新文件同样是「改了上游」。
DIRTY=$(git -C "$SUB" status --porcelain) || die_broken "读 $SUB 的工作区状态失败"
if [ -n "$DIRTY" ]; then
  BAD="${BAD}   · 上游被本地改过($(printf '%s\n' "$DIRTY" | sed '/^$/d' | wc -l) 项):"$'\n'
  BAD="${BAD}$(printf '%s\n' "$DIRTY" | sed '/^$/d;s/^/       /')"$'\n'
fi

if [ -n "$(printf '%s' "$BAD" | tr -d '[:space:]')" ]; then
  printf '⛔ upstream-pin FAIL —— 上游那份不是说好的那份:\n' >&2
  printf '%s' "$BAD" >&2
  printf '⇒ B2:vendor 只读,且必须是 pin 的那个 commit。⛔ 改上游要走 amendment,不是就地改。\n' >&2
  exit 1
fi

printf '⭐ upstream-pin PASS —— %s 停在 %s 且工作区干净\n' "$SUB" "$(git -C "$SUB" rev-parse --short HEAD)"
exit 0
