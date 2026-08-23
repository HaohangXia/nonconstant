#!/usr/bin/env bash
#
# nonconstant · upstream-semantics  —— 上游语义判据
#
#   ⭐ nonconstant 只依赖 spec-kit 的**两条语义**(Q14 实测):
#     ① shell step:退出码非 0 ⇒ FAILED(流水线停止);退出码 0 ⇒ COMPLETED
#     ② gate  step:非 TTY ⇒ PAUSED(⛔ 不自动放行),且 on_reject 默认解析为 abort
#
#   ⚠️ ⛔ **判语义,不判文件内容。**给 vendor/ 做指纹会因上游**合法升级**误报
#      (= LATCH-hook-three-legs 第三条腿)。⭐ 本判据**真跑那两个 step 并观察行为** ——
#      连 on_reject 的默认值也取自**引擎算出的结果对象**,⛔ 不是从源码里 grep 出来的。
#
# 退出码:
#   0  过     —— 两条语义均与 nonconstant 的依赖一致
#   1  未过   —— 语义已变 ⇒ ⛔ nonconstant 的立身之本失效,须重新设计
#   2  闸自身故障 / **判不了** —— ⛔ 绝不因判不了而返回 0
#      ⚠️ 「装不上、导不进、结构对不上」一律判 2:本判据的职责是回答「语义还在吗」,
#         ⛔ 答不出 ≠ 通过(C6)。
#
# 用法:  bash .nonconstant/upstream-semantics.sh [vendor 的 src 目录]

set -u

die_broken() { printf '⛔ UPSTREAM-SEMANTICS BROKEN: %s\n' "$1" >&2; exit 2; }

# ⭐⭐ 配置取值一律走 .nonconstant/config-read.sh —— ⛔ 本脚本内不再自行解析
#    (C12 第二形态:行尾注释/引号被吞进取值 ⇒ 恒不命中 ⇒ 判据静默失效)
NONCONSTANT_DIR=$(dirname "$0")
# shellcheck source=/dev/null
. "$NONCONSTANT_DIR/config-read.sh" || die_broken "读不到 $NONCONSTANT_DIR/config-read.sh —— ⛔ 取值出口缺失 ≠ 配置为空"

SRC="${1:-}"
[ -f nonconstant.yml ] || die_broken "找不到 nonconstant.yml —— ⛔ 读不到 subjects"
[ -n "$SRC" ] || SRC=$(nc_subject nonconstant.yml upstream_src)
[ -n "$SRC" ] || die_broken "nonconstant.yml 的 subjects 里没有 upstream_src —— ⛔ 没配就判不了,不得猜"
[ -d "$SRC" ] || die_broken "找不到上游源码目录: $SRC —— ⛔ 上游不在 ≠ 语义没变"
command -v python >/dev/null || die_broken "没有 python,跑不了行为探针"

# ⚠️ ⛔ 必须锁定 utf-8:Windows 控制台默认 gbk,探针里的中文/符号会让 print 抛异常
#    ⇒ 进程非 0 退出 ⇒ 具体诊断被替换成一句笼统的「进程异常退出」。
#    ⭐ 那不是「没报错」,是**报错了但读不出是什么** —— 与 Phase 4 的 awk 路径乱码同族。
OUT=$(SRC="$SRC" PYTHONIOENCODING=utf-8 python - <<'PY'
import os, sys, types

src = os.environ["SRC"]
sys.path.insert(0, src)

# ⭐ 上游包根是 eager import,会拉进一堆运行时依赖。本判据只关心两个 step 的行为,
#    故为缺失依赖注入桩 —— ⛔ 但**必须把桩过的模块名打印出来**:
#    一个静默的桩会让「语义没变」变得不可信(LATCH-waiver-must-announce 同形)。
stubbed = []
for _ in range(30):
    try:
        from specify_cli.workflows.base import StepContext, StepStatus
        from specify_cli.workflows.steps.shell import ShellStep
        from specify_cli.workflows.steps.gate import GateStep
        break
    except ModuleNotFoundError as e:
        name = e.name
        if name is None or name in stubbed or name.startswith("specify_cli"):
            print("BROKEN\t导入卡在 %s,⛔ 桩不掉(它属于上游自身)" % name)
            raise SystemExit(0)
        m = types.ModuleType(name)
        m.__getattr__ = lambda k: (lambda *a, **kw: None)
        sys.modules[name] = m
        stubbed.append(name)
    except Exception as e:
        print("BROKEN\t导入失败 %s: %s" % (type(e).__name__, str(e)[:120]))
        raise SystemExit(0)
else:
    print("BROKEN\t桩了 30 个模块仍导不进 —— ⛔ 结构已面目全非,判不了")
    raise SystemExit(0)

print("STUBBED\t%s" % (",".join(stubbed) if stubbed else "(无)"))

ctx = StepContext(project_root=".")

# ① shell step 的退出码语义
nonzero = ShellStep().execute({"run": "exit 3"}, ctx).status.name
zero = ShellStep().execute({"run": "exit 0"}, ctx).status.name
print("SHELL_NONZERO\t%s" % nonzero)
print("SHELL_ZERO\t%s" % zero)

# ② gate step 的不自动放行 + on_reject 默认值(⭐ 取自引擎算出的结果对象)
g = GateStep().execute({"message": "nonconstant-probe"}, ctx)
print("GATE_STATUS\t%s" % g.status.name)
out = g.output if isinstance(g.output, dict) else {}
print("GATE_ON_REJECT\t%s" % out.get("on_reject"))
PY
) || die_broken "行为探针进程异常退出"

case "$OUT" in
  *BROKEN*) die_broken "$(printf '%s' "$OUT" | sed 's/^BROKEN\t//;t;d')" ;;
esac

get() { printf '%s\n' "$OUT" | sed "s/^$1\\t//;t;d"; }

STUBS=$(get STUBBED)
printf '⚠️ 为导入而注入的依赖桩: %s(⛔ 不静默 —— 桩过的东西必须看得见)\n' "$STUBS"

BAD=""
[ "$(get SHELL_NONZERO)" = "FAILED" ] \
  || BAD="${BAD}   · shell step 退出码非 0 ⇒ 期望 FAILED,实测 $(get SHELL_NONZERO)"$'\n'
[ "$(get SHELL_ZERO)" = "COMPLETED" ] \
  || BAD="${BAD}   · shell step 退出码 0 ⇒ 期望 COMPLETED,实测 $(get SHELL_ZERO)"$'\n'
[ "$(get GATE_STATUS)" = "PAUSED" ] \
  || BAD="${BAD}   · gate step 非 TTY ⇒ 期望 PAUSED(不自动放行),实测 $(get GATE_STATUS)"$'\n'
[ "$(get GATE_ON_REJECT)" = "abort" ] \
  || BAD="${BAD}   · gate step on_reject 默认 ⇒ 期望 abort,实测 $(get GATE_ON_REJECT)"$'\n'

if [ -n "$(printf '%s' "$BAD" | tr -d '[:space:]')" ]; then
  printf '⛔ upstream-semantics FAIL —— nonconstant 依赖的上游语义已变:\n' >&2
  printf '%s' "$BAD" >&2
  printf '⇒ ⛔ 这不是「升级一下」的问题:shell 退出码与 gate 不自动放行是 nonconstant 的立身之本。\n' >&2
  exit 1
fi

printf '⭐ upstream-semantics PASS —— 两条语义均在(shell 退出码 · gate 不自动放行 + on_reject=abort)\n'
exit 0
