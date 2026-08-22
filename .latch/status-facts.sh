#!/usr/bin/env bash
#
# latch · status-facts  —— STATUS 事实判据
#
#   ⭐ `STATUS.md` 写的是「**现在是什么状态**」,而状态由**仓库**决定
#      ⇒ 每条断言都有对应物 ⇒ ⭐ **它的失真不是 D5,是「还没做」。**
#      ⚠️ 对照:`01-PLAN.md` 写的是「该怎么做」,⛔ 没有对应物 ⇒ 那才是 D5。
#
#   实证:2026-08-22 实测 STATUS 同时有三句假话 ——
#     「零行代码」(实为 5 条判据已提交)·「Phase 0 可以开工」(实为 0~3 全完成)·
#     「最后 commit」停在十几个 commit 之前。⛔ doc-budget 一句都抓不到。
#   见 03-LEDGER.md `LATCH-uncheckable-limit`。
#
# 退出码:
#   0  过     —— 每条可核对的断言都与仓库一致
#   1  未过   —— 有断言与仓库不符,或 STATUS 未声明任何可核对的状态
#   2  闸自身故障
#
# 用法:  bash .latch/status-facts.sh [STATUS 文件] [配置文件]

set -u

die_broken() { printf '⛔ STATUS-FACTS BROKEN: %s\n' "$1" >&2; exit 2; }

STATUS="${1:-docs/audit/STATUS.md}"
CONFIG="${2:-latch.yml}"
[ -f "$STATUS" ] || die_broken "找不到 $STATUS —— ⛔ STATUS 不存在 ≠ 没有失真"
[ -f "$CONFIG" ] || die_broken "找不到 $CONFIG —— ⛔ 没有对照物就判不了真伪"
git rev-parse --git-dir >/dev/null || die_broken "不在 git 仓库内"

BAD=""
CHECKED=0
note() { BAD="${BAD}   · ${1}"$'\n'; }

# ── 断言 1:判据条数 ⇔ latch.yml 的 `- id:` 计数 ───────────────────
CLAIM=$(awk 'match($0, /([0-9]+) 条判据/, m) { print m[1]; exit }' "$STATUS")
REAL=$(grep -c '^[ \t]*-[ \t]*id:' "$CONFIG") || die_broken "数 latch.yml 判据失败"
if [ -n "$CLAIM" ]; then
  CHECKED=$((CHECKED + 1))
  [ "$CLAIM" = "$REAL" ] || note "判据条数:STATUS 称 $CLAIM 条,⛔ latch.yml 实为 $REAL 条"
fi

# ── 断言 2:已完成 phase ⇔ reports/phase*.md 的最大编号 ────────────
CLAIMP=$(awk 'match($0, /Phase 0~([0-9]+) 全部完成/, m) { print m[1]; exit }' "$STATUS")
[ -d reports ] || die_broken "reports/ 目录不存在 —— ⛔ 数不出已完成阶段"
REALP=$(ls reports/ | sed 's/^phase\([0-9]\+\)-.*\.md$/\1/;t;d' | sort -n | tail -1) \
  || die_broken "扫 reports/ 失败"
[ -n "$REALP" ] || die_broken "reports/ 下一份 phase 报告都没有 —— ⛔ 数不出已完成阶段"
if [ -n "$CLAIMP" ]; then
  CHECKED=$((CHECKED + 1))
  [ "$CLAIMP" = "$REALP" ] || note "已完成阶段:STATUS 称 Phase 0~$CLAIMP,⛔ reports/ 实为 0~$REALP"
fi

# ── 断言 3:清单里的文件路径都存在 ────────────────────────────────
# ⛔⛔ **只查表格行(`|` 开头)**,⛔ 不查正文。
#    根因:正文**可以合法地提到一个路径,正是为了说它不存在**
#    ——「⛔ 无 workflows/latch/workflow.yml」这句是**真的**。
#    ⇒ 「凡提到的路径都须存在」是**过宽的判据** ⇒ 必然误报
#      (= LATCH-hook-three-legs 第三条腿)。实测首跑即撞上。
#    ⭐ 表格行是**清单**,语义就是「这些东西存在」⇒ 结构性判据,⛔ 非启发式猜测。
# ⚠️ 只取反引号里、带已知扩展名、⛔ 不含 * 或 ~ 的 token(通配与区间不是具体路径)
PATHS=$(grep '^|' "$STATUS" \
        | grep -o '`[A-Za-z0-9_./-]\+\.\(md\|sh\|yml\|log\)`' \
        | tr -d '`' | sort -u)
# ⛔ 上面**不加** `|| true`:管道以 sort 收尾,无匹配时 sort 仍返回 0 ⇒
#    `|| true` 只会吞掉真实故障(T5),⛔ 且它本身就是 silent-scan 要抓的模式。
for p in $PATHS; do
  case "$p" in *'*'*|*'~'*) continue ;; esac
  CHECKED=$((CHECKED + 1))
  [ -e "$p" ] || [ -e "docs/audit/$p" ] \
    || note "路径不存在:STATUS 引用了 \`$p\`,⛔ 磁盘上没有"
done

# ── vacuous 防线 ──────────────────────────────────────────────────
# ⛔ 一个不含任何可核对断言的 STATUS,与「没有 STATUS」无法区分。
#    此时返回 0 会被读成「STATUS 准确」⇒ 必须判红。⭐ 这是判据的缺陷吗?不是 ——
#    是**被判定物**的缺陷,故判 1 而非 2。
if [ "$CHECKED" -eq 0 ]; then
  printf '⛔ status-facts FAIL —— %s 里找不到任何可核对的断言\n' "$STATUS" >&2
  printf '⇒ 一个不声明状态的 STATUS,与没有 STATUS 无法区分。⛔ 不得判绿。\n' >&2
  exit 1
fi

if [ -n "$(printf '%s' "$BAD" | tr -d '[:space:]')" ]; then
  printf '⛔ status-facts FAIL —— STATUS 与仓库不符:\n' >&2
  printf '%s' "$BAD" >&2
  printf '⇒ 说假话的 STATUS 会误导后面每一个 phase。⛔ 修 STATUS,不是修判据。\n' >&2
  exit 1
fi

printf '⭐ status-facts PASS —— %s 条断言与仓库一致\n' "$CHECKED"
exit 0
