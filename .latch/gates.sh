#!/usr/bin/env bash
#
# latch · criteria-guard
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
#   bash .latch/gates.sh              # 判工作树相对 HEAD 的改动
#   bash .latch/gates.sh <base-ref>   # 判 <base-ref>..HEAD 的改动
#
# ⚠️ T5:任何可能失败的操作都必须查返回码。⛔ 本文件不得出现
#    `|| true` / `2>/dev/null` / 不查返回码的捕获。

set -u

CONFIG="latch.yml"

die_broken() {
  printf '⛔ GATE BROKEN: %s\n' "$1" >&2
  exit 2
}

# ── 闸自身体检(⛔ 缺任何一样都不许返回 0)────────────────────────
git rev-parse --git-dir >/dev/null || die_broken "不在 git 仓库内"
[ -f "$CONFIG" ] || die_broken "找不到 $CONFIG"

# ── 读受保护路径清单 ────────────────────────────────────────────
# 取 `protected:` 与下一个顶层键之间的 `- ` 行。⛔ 不引入 YAML 依赖。
PATTERNS=$(
  sed -n '/^protected:/,/^[a-z_]*:/p' "$CONFIG" \
    | sed -n 's/^[[:space:]]*-[[:space:]]*//p'
)
[ -n "$PATTERNS" ] || die_broken "$CONFIG 的 protected 清单为空 —— 空清单会让本闸恒过(常量)"

# ── 取被判定的改动集合 ──────────────────────────────────────────
if [ "$#" -ge 1 ]; then
  BASE="$1"
  git rev-parse --verify "$BASE" >/dev/null || die_broken "解析不了 base ref: $BASE"
  CHANGED=$(git diff --name-only "$BASE"..HEAD --) || die_broken "git diff 失败"
else
  TRACKED=$(git diff --name-only HEAD --) || die_broken "git diff 失败"
  UNTRACKED=$(git ls-files --others --exclude-standard) || die_broken "git ls-files 失败"
  CHANGED=$(printf '%s\n%s\n' "$TRACKED" "$UNTRACKED")
fi

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
