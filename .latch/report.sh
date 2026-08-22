#!/usr/bin/env bash
#
# latch · report-pin  —— 完成报告绑 commit(§3 序 5)
#
#   ⭐ 报告文件名须含**它所描述的那个 commit** 的短 hash。
#   实证:DevLoop 91 条老行声称「闸过了」却不绑任何代码状态 ⇒ ⛔ 不可证伪。
#
#   ⚠️ ⛔ 判据不是「hash == 当前 HEAD」—— 那条在报告提交后恒假
#      (LATCH-constant-criterion-inverse)。
#   ⭐ 判据是:hash 在 git 历史中**存在**,且是 HEAD 的**祖先**
#      ⇒ 求值时机从「当下」变为「任何时候」。
#
# 退出码:
#   0  过     —— 每份报告名里的 hash 都是历史中的真实祖先提交
#   1  未过   —— 有报告的 hash 不存在 / 不是祖先 / 文件名不合规
#   2  闸自身故障
#
# 用法:  bash .latch/report.sh [报告目录]        # 默认 reports

set -u

die_broken() { printf '⛔ REPORT-PIN BROKEN: %s\n' "$1" >&2; exit 2; }

# ⭐⭐ 配置取值一律走 .latch/config-read.sh —— ⛔ 本脚本内不再自行解析
#    (C12 第二形态:行尾注释/引号被吞进取值 ⇒ 恒不命中 ⇒ 判据静默失效)
LATCH_DIR=$(dirname "$0")
# shellcheck source=/dev/null
. "$LATCH_DIR/config-read.sh" || die_broken "读不到 $LATCH_DIR/config-read.sh —— ⛔ 取值出口缺失 ≠ 配置为空"

DIR="${1:-}"
[ -f latch.yml ] || die_broken "找不到 latch.yml —— ⛔ 读不到 subjects,不得回落到默认路径"
[ -n "$DIR" ] || DIR=$(latch_subject latch.yml reports)
[ -n "$DIR" ] || die_broken "latch.yml 的 subjects 里没有 reports —— ⛔ 没配就判不了,不得猜"
git rev-parse --git-dir >/dev/null || die_broken "不在 git 仓库内"
[ -d "$DIR" ] || die_broken "报告目录不存在: $DIR —— ⛔ 没有报告不等于报告都合规"

FILES=$(find "$DIR" -maxdepth 1 -type f -name 'phase*.md' | sort) \
  || die_broken "find 失败"

BAD=""
N=0
for f in $FILES; do
  base=$(basename "$f" .md)
  case "$base" in
    phase*-*) : ;;
    *) BAD="${BAD}   · $f: ⛔ 文件名不含 hash 段(应为 phase<N>-<短 hash>.md)"$'\n'; continue ;;
  esac
  h=${base##*-}
  if [ -z "$h" ]; then
    BAD="${BAD}   · $f: ⛔ hash 段为空"$'\n'; continue
  fi
  case "$h" in
    *PENDING*) BAD="${BAD}   · $f: ⛔ 占位符 PENDING 未替换成真实 hash"$'\n'; continue ;;
  esac
  if ! git rev-parse --verify --quiet "${h}^{commit}" >/dev/null; then
    BAD="${BAD}   · $f: ⛔ hash「$h」在 git 历史中不存在 ⇒ 声明不可证伪"$'\n'; continue
  fi
  if ! git merge-base --is-ancestor "$h" HEAD; then
    BAD="${BAD}   · $f: ⛔ hash「$h」不是 HEAD 的祖先 ⇒ 它不是本线历史上的产物提交"$'\n'; continue
  fi
  N=$((N + 1))
done

if [ -n "$(printf '%s' "$BAD" | tr -d '[:space:]')" ]; then
  printf '⛔ report-pin FAIL —— 以下报告未绑到真实的产物提交:\n' >&2
  printf '%s' "$BAD" >&2
  printf '⇒ 不绑定状态的声明不可证伪(A3)。\n' >&2
  exit 1
fi

printf '⭐ report-pin PASS —— %s 份报告均绑到历史中的真实祖先提交\n' "$N"
exit 0
