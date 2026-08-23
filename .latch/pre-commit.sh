#!/usr/bin/env bash
#
# latch · pre-commit  —— ⭐ latch 自己用 latch
#
#   ⚠️ ⛔ **latch 是一个闸门工具,而它自己的提交此前没有闸门。**
#      实证:「提交前先跑判据」是一条**无判据的规则** ⇒ 靠人记 ⇒
#      **已自然发生两次**(2026-08-23 两次在 hard 判据判红时提交,
#      两次都靠事后 `--amend` 补救)。⇒ ⭐ git 恰好提供执行点。
#
#   ⭐ 这**不是加固**:与 Q19 那些「探针刻意构造的脚枪」性质不同 ——
#      ⛔ 它已自然发生,且发生了两次。见 `LATCH-hardening-recursion` 的判别。
#
#   ⚠️ ⛔ 作用范围:**仅 latch 自举**。`.git/hooks/` 不受版本控制 ⇒
#      ⛔ 装不进用户项目,`install.sh` **不装它**。⭐ README 告诉用户可以自己建。
#
#   判定:
#     hard 判红(1) ⇒ ⛔ **拒绝提交**
#     soft 判红(1) ⇒ ⭐ 打印但**放行** —— soft 的含义是「不拦你」
#     任一判 2     ⇒ ⛔ **拒绝** —— 闸自身故障比判红更严重(C6)
#
# 退出码:  0 放行 / 1 拒绝 / 2 本脚本自身故障
#
# 用法:  bash .latch/pre-commit.sh        # 由 .git/hooks/pre-commit 调用

set -u

# ⭐⭐ ⛔ **必须先清掉 git 传进来的环境变量。**
#    实证(本 hook 首跑即撞上):`git commit` 会设 GIT_DIR / GIT_INDEX_FILE,
#    子进程里 `git -C vendor/spec-kit ...` 于是操作的是**主仓的 .git**
#    ⇒ `upstream-pin` 报「上游被本地改过 577 项」判红 —— ⛔ 而它直接跑是 0。
#    ⇒ ⭐ 这是 `LATCH-harness-failure-looks-like-red` 的又一形态:
#      ⛔ 不是判据判红,是**运行环境**让它判红。
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

die_broken() { printf '⛔ PRE-COMMIT BROKEN: %s\n' "$1" >&2; exit 2; }

LATCH_DIR=$(dirname "$0")
# shellcheck source=/dev/null
. "$LATCH_DIR/config-read.sh" || die_broken "读不到 $LATCH_DIR/config-read.sh —— ⛔ 取值出口缺失 ≠ 配置为空"

CONFIG="latch.yml"
[ -f "$CONFIG" ] || die_broken "找不到 $CONFIG"

# id｜impl｜level 三元组 —— ⭐ 从配置取,⛔ 不在本脚本里列判据
GATES=$(awk '/^gates:/{g=1;next} /^[a-z_]/{g=0}
  g && /^[ \t]*-[ \t]*id:/ { sub(/^[ \t]*-[ \t]*id:[ \t]*/,""); id=$0 }
  g && /^[ \t]*level:/     { sub(/^[ \t]*level:[ \t]*/,"");     lv=$0 }
  g && /^[ \t]*pre_commit:/ { sub(/^[ \t]*pre_commit:[ \t]*/,""); pc=$0 }
  g && /^[ \t]*impl:/      { sub(/^[ \t]*impl:[ \t]*/,"");      print id "|" $0 "|" lv "|" pc; pc="" }
' "$CONFIG") || die_broken "读判据清单失败"
[ -n "$GATES" ] || die_broken "$CONFIG 里一条判据都没有 —— ⛔ 空清单会让本 hook 恒放行(常量)"

# ⭐ 扫描目标不再由本脚本传 —— `.latch/scan-silent.sh` 自己从 subjects.scan_target 取(A006)。
#    ⚠️ Phase 12 改的:编排层若写死目标,判定的输入就又被调用方控制了(Q16 同族)。

HARD_RED=""; SOFT_RED=""; BROKEN=""
while IFS='|' read -r id impl level pc; do
  [ -n "${impl:-}" ] || continue
  [ -f "$impl" ] || { BROKEN="${BROKEN}   · $id: 实现不存在 $impl"$'\n'; continue; }
  # ⛔ 单独跑、直接读 $? —— **不接管道**。
  #    实证:管道会把退出码换成管道末端命令的(本项目已踩 3 次),
  #    ⇒ 「工具没跑起来」会被读成「判据判红了」(LATCH-harness-failure-looks-like-red)。
  bash "$impl" >/dev/null 2>&1
  code=$?
  case "$code" in
    0) : ;;
    1) if [ "$level" = "soft" ]; then SOFT_RED="${SOFT_RED}   · $id(soft)"$'\n'
       elif [ "${pc:-}" = "advisory" ]; then
         SOFT_RED="${SOFT_RED}   · $id(advisory —— 理由见 latch.yml,F5)"$'\n'
       else HARD_RED="${HARD_RED}   · $id ($impl)"$'\n'; fi ;;
    *) BROKEN="${BROKEN}   · $id: 退出码 $code(闸自身故障 / 命令缺失)"$'\n' ;;
  esac
done <<EOF
$GATES
EOF

[ -z "$(printf '%s' "$SOFT_RED" | tr -d '[:space:]')" ] || {
  printf '⚠️ 以下判据判红但**放行**(soft = 不拦你;advisory = F5,理由在 latch.yml):\n' >&2
  printf '%s' "$SOFT_RED" >&2
}

if [ -n "$(printf '%s' "$BROKEN" | tr -d '[:space:]')" ]; then
  printf '⛔ 提交被拒 —— 闸自身故障(⭐ 比判红更严重,C6):\n' >&2
  printf '%s' "$BROKEN" >&2
  exit 1
fi

if [ -n "$(printf '%s' "$HARD_RED" | tr -d '[:space:]')" ]; then
  printf '⛔ 提交被拒 —— 以下 hard 判据判红:\n' >&2
  printf '%s' "$HARD_RED" >&2
  printf '⇒ ⭐ 修到它们判 0 再提交。⛔ 不要改判据让它通过(R7)。\n' >&2
  exit 1
fi

printf '⭐ pre-commit PASS —— 全部判据已跑,无 hard 判红\n'
exit 0
