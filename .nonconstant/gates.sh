#!/usr/bin/env bash
#
# nonconstant · criteria-guard
#
#   ⭐ 判据文件本身不得被被判定者修改 —— 考卷不能由考生自己改。
#   实证:DevLoop 三个月唯一一次真拦截 = 工人改动 tests/ 让自己过关。
#   ⇒ 它拦的是主动作弊,⛔ 不是手滑。
#
# 退出码(01-PLAN §5 P4 三级制 + DevLoop 三档约定):
#   0  过     —— 本次改动未触碰受保护路径
#   1  未过   —— 触碰了(hard,⛔ 不可 waiver)
#   2  闸自身故障 —— ⛔ 绝不因自身故障返回 0
#
# 用法:
#   bash .nonconstant/gates.sh              # 判工作树相对 HEAD 的改动
#   bash .nonconstant/gates.sh <base-ref>   # 判 <base-ref>..HEAD 的改动
#
# ⚠️ T5:任何可能失败的操作都必须查返回码。⛔ 本文件不得出现
#    `|| true` / `2>/dev/null` / 不查返回码的捕获。

set -u

CONFIG="nonconstant.yml"

die_broken() {
  printf '⛔ GATE BROKEN: %s\n' "$1" >&2
  exit 2
}

# ⭐⭐ 配置取值一律走 .nonconstant/config-read.sh —— ⛔ 本脚本内不再自行解析
#    (C12 第二形态:行尾注释/引号被吞进取值 ⇒ 恒不命中 ⇒ 判据静默失效)
NONCONSTANT_DIR=$(dirname "$0")
# shellcheck source=/dev/null
. "$NONCONSTANT_DIR/config-read.sh" || die_broken "读不到 $NONCONSTANT_DIR/config-read.sh —— ⛔ 取值出口缺失 ≠ 配置为空"

# ── 闸自身体检(⛔ 缺任何一样都不许返回 0)────────────────────────
git rev-parse --git-dir >/dev/null || die_broken "不在 git 仓库内"
[ -f "$CONFIG" ] || die_broken "找不到 $CONFIG"

# ── 读受保护路径清单 ────────────────────────────────────────────
# 取 `protected:` 与下一个顶层键之间的 `- ` 行。⛔ 不引入 YAML 依赖。
PATTERNS=$(nc_list "$CONFIG" protected)
[ -n "$PATTERNS" ] || die_broken "$CONFIG 的 protected 清单为空 —— 空清单会让本闸恒过(常量)"

# ── 取被判定的改动集合 ──────────────────────────────────────────
# ⭐⭐ base 只从配置取 —— ⛔ 不接受调用方参数(A004)。
# 被判定者若能自选 base,它可选一个「改完判据之后」的基线把改动藏进去
# ⇒ 差集为空 ⇒ 判绿 ⇒ 判定的输入被被判定者控制 ⇒ T1 失效。
# ⛔ 拒绝而非静默忽略:静默忽略会让调用方以为自己指定的 base 生效了。
[ "$#" -eq 0 ] || die_broken "⛔ 不接受调用方给 base(收到「$1」)—— base 只从 $CONFIG 取(A004)"

BASE=$(nc_top "$CONFIG" base) \
  || die_broken "读 base 失败"
[ -n "$BASE" ] || die_broken "$CONFIG 里没有顶层 base: —— ⛔ 没有基线不等于没有改动"
git rev-parse --verify "$BASE" >/dev/null || die_broken "配置里的 base 解析不了: $BASE"

TRACKED=$(git diff --name-only "$BASE" --) || die_broken "git diff 失败"
UNTRACKED=$(git ls-files --others --exclude-standard) || die_broken "git ls-files 失败"
CHANGED=$(printf '%s\n%s\n' "$TRACKED" "$UNTRACKED")

# ── 判定 ────────────────────────────────────────────────────────
HITS=""
while IFS= read -r f; do
  [ -n "$f" ] || continue
  while IFS= read -r pat; do
    [ -n "$pat" ] || continue
    # `**` 与 `*` 在 case 里都跨 / 匹配,统一成 `*`
    case "$f" in
      ${pat//\*\*/\*}) HITS="${HITS}${f}"$'\n' ;;
    esac
  done <<< "$PATTERNS"
done <<< "$CHANGED"

if [ -n "$HITS" ]; then
  printf '⛔ criteria-guard FAIL —— 被判定者改动了判据文件:\n' >&2
  printf '%s' "$HITS" | sed 's/^/   · /' >&2
  printf '⇒ 考卷不能由考生自己改。改判据须由操作者在 phase 边界外进行。\n' >&2
  exit 1
fi

printf '⭐ criteria-guard PASS —— 未触碰受保护路径\n'
exit 0
