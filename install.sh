#!/usr/bin/env bash
#
# latch · installer  (Q13 = ① 安装脚本)
#
#   ⭐ 选 ① 的理由:latch 的产物是 **shell 脚本 + YAML** ——
#     ⛔ ② spec-kit extension:命令被迫叫 speckit.latch.xxx,且要碰 D-03 决定不碰的
#        扩展系统(16-DECISIONS 已记,⛔ 不重议)
#     ⛔ ③ PyPI 包:装的是「项目里的文件」,⛔ 不是「一个命令」——
#        形态不符,且为一件 cp 的事引入发布流水线
#
#   ⭐ 装哪些由 latch.yml 的 scope 决定(A006):**scope != bootstrap** 才装。
#      ⛔ 不靠人挑,⛔ 不写死条数。
#
# 退出码:
#   0  装成功
#   1  拒绝安装(目标已有 latch.yml / 目标不是 git 仓)
#   2  安装器自身故障
#
# 用法:  bash install.sh <目标仓库目录>

set -u

die_broken() { printf '⛔ INSTALL BROKEN: %s\n' "$1" >&2; exit 2; }
refuse()     { printf '⛔ 拒绝安装:%s\n' "$1" >&2; exit 1; }

SRC=$(cd "$(dirname "$0")" && pwd) || die_broken "定位不了 latch 源目录"
DST="${1:-}"
[ -n "$DST" ] || die_broken "未给目标目录"
[ -d "$DST" ] || die_broken "目标目录不存在: $DST"
[ -f "$SRC/latch.yml" ] || die_broken "源目录里没有 latch.yml: $SRC"

# ── 拒绝档 ────────────────────────────────────────────────────────
# ⛔ 已有 latch.yml ⇒ 拒绝,⛔ 不静默覆盖 —— latch.yml 是**用户配置**
#    (受保护路径 · 文档预算 · 豁免),覆盖它等于把用户的判据悄悄换掉。
#    ⛔ 不提供 --force:那是逃逸口(LATCH-hardcoded-escape-hatch)。
[ -e "$DST/latch.yml" ] && refuse "$DST 已有 latch.yml —— ⛔ 不覆盖用户配置;要重装请先自行移除"

# ⚠️ 目标不是 git 仓 ⇒ 判 1 而非 2:这是**测定了的**否定结论(⛔ 不是「没测到」)
#    —— latch 的判据依赖 git(diff 基线 · 报告绑 commit)。可行动:先 git init。
git -C "$DST" rev-parse --git-dir >/dev/null 2>&1 \
  || refuse "$DST 不是 git 仓库 —— latch 的判据依赖 git(基线比对 · 报告绑 commit);请先 git init"

# ── 取可分发清单(scope != bootstrap)──────────────────────────────
KEEP=$(awk '
  /^[ \t]*-[ \t]*id:/    { id=$0; sub(/^[ \t]*-[ \t]*id:[ \t]*/,"",id); sc=""; im="" }
  /^[ \t]*scope:/        { sc=$0; sub(/^[ \t]*scope:[ \t]*/,"",sc) }
  /^[ \t]*impl:/         { im=$0; sub(/^[ \t]*impl:[ \t]*/,"",im)
                           if (id != "" && sc != "" && sc != "bootstrap") print id "\t" im }
' "$SRC/latch.yml") || die_broken "读 scope 清单失败"
[ -n "$KEEP" ] || die_broken "没有一条可分发判据 —— ⛔ 空清单会让安装恒成功(常量)"

# ── 半装防线:先装进暂存目录,全部就绪才落位 ──────────────────────
# ⛔ 装到一半失败绝不留半装状态 —— 那会让用户以为装好了。
STAGE="$DST/.latch.staging.$$"
cleanup_stage() { [ -d "$STAGE" ] && rm -rf "$STAGE"; }
trap 'cleanup_stage' EXIT
mkdir -p "$STAGE" || die_broken "建不了暂存目录"

N=0
while IFS=$'\t' read -r id impl; do
  [ -n "${impl:-}" ] || continue
  [ -f "$SRC/$impl" ] || die_broken "判据实现缺失: $impl(闸门缺失 ≠ 未配置,C6)"
  cp "$SRC/$impl" "$STAGE/$(basename "$impl")" || die_broken "复制失败: $impl"
  N=$((N + 1))
done <<EOF
$KEEP
EOF

# ⭐ 探测用户实际装的 spec-kit —— ⛔ 不猜、⛔ 不回落到 latch 自己的 vendor 布局。
#    探不到就**留空**:upstream-semantics 会判 2(没配就判不了),
#    ⛔ 而不是指向一个错的路径然后声称验过了。
UPSTREAM_SRC=""
if command -v python >/dev/null; then
  UPSTREAM_SRC=$(python - <<'PYX'
import importlib.util, os
spec = importlib.util.find_spec("specify_cli")
print(os.path.dirname(os.path.dirname(spec.origin)) if spec and spec.origin else "")
PYX
  ) || die_broken "探测 specify_cli 失败"
fi
if [ -z "$UPSTREAM_SRC" ] && command -v uv >/dev/null; then
  UV_TOOLS=$(uv tool dir) || die_broken "uv tool dir 失败"
  CAND="$UV_TOOLS/specify-cli/Lib/site-packages"
  [ -d "$CAND" ] && UPSTREAM_SRC="$CAND"
fi

# 生成用户侧 latch.yml:只留可分发判据,⛔ 且 demo_report 指向随装的证据清单
UP="$UPSTREAM_SRC" awk -v keep="$KEEP" '
  BEGIN { n=split(keep,rows,"\n"); for(i=1;i<=n;i++){ split(rows[i],f,"\t"); ok[f[1]]=1 } }
  /^[ 	]*-[ 	]*id:/ { id=$0; sub(/^[ 	]*-[ 	]*id:[ 	]*/,"",id); skip=!(id in ok) }
  /^[ 	]*impl:/ && !skip { sub(/\.latch\/[^ ]*/, ".latch/" substr($0, match($0,/[^\/]*$/))) }
  /^[ 	]*demo_report:/ && !skip { print "    demo_report: .latch/EVIDENCE.md"; next }
  # 用 ENVIRON 取路径,不用 -v:awk 会把 Windows 路径里的反斜杠序列当成转义吃掉
  #    —— Phase 4 同族 bug 复发,已实测
  /^[ 	]+upstream_src:/ { print "  upstream_src: " ENVIRON["UP"]; next }
  # status / plan 安装器猜不到 ⇒ 整键省略,不写一个指向 latch 布局的错路径
  #    键缺失 ⇒ 对应判据判 2 并指名「没配就判不了」,比指错路径诚实
  /^[ 	]+(status|plan):/ { if (!hint++) print "  # 请填 status: 与 plan: —— 指向本项目的 STATUS 与阶段计划"; next }
  /^doc_budgets:/ { inb=1
      print "# ⚠️ 本项目的文档预算由你自己填 —— ⛔ latch 自己那几份不在这里。"
      print "doc_budgets: []"; next }
  inb && /^[a-z_#]/ { inb=0 }
  inb { next }
  !skip { print }
' "$SRC/latch.yml" > "$STAGE/latch.yml" || die_broken "生成 latch.yml 失败"

# ⛔ 不用 `2>/dev/null || echo unknown` 兜底 —— 那会把「读不到 latch 版本」吞掉,
#    而 EVIDENCE.md 的**全部价值**就是指出演示做在哪个 commit 上。读不到 ⇒ 判 2。
if git -C "$SRC" rev-parse --git-dir >/dev/null; then
  SRC_REV=$(git -C "$SRC" rev-parse --short HEAD) || die_broken "读 latch 源仓 HEAD 失败"
else
  die_broken "latch 源目录不是 git 仓 —— ⛔ 记不下演示所在的 commit,证据即不可核"
fi

{
  printf '# latch · 判据演示证据\n\n'
  printf '⭐ 下列判据的「一过一失败」演示**由 latch 上游完成**,⛔ 不是在本项目里做的。\n'
  printf '⚠️ 这是一个**信任转移**:你信的是 latch 的完成报告,⛔ 不是本地实测。\n\n'
  printf '| 判据 | 演示所在的 latch commit |\n|---|---|\n'
  printf '%s\n' "$KEEP" | while IFS=$'\t' read -r id impl; do
    [ -n "${id:-}" ] && printf '| `%s` | `%s` |\n' "$id" "$SRC_REV"
  done
  printf '\n⛔ 要在本项目独立复验,请按各判据的红/绿检自行演示。\n'
} > "$STAGE/EVIDENCE.md" || die_broken "生成 EVIDENCE.md 失败"

# ── 落位(到这一步才动目标目录)────────────────────────────────────
mkdir -p "$DST/.latch" || die_broken "建不了 $DST/.latch"
# ⭐⭐ 创建 reports/ —— ⛔ 让「目录不存在」重新成为**异常**,而不是**必然**。
#    否则 report-pin 在每个新装环境里恒判 2 ⇒ 那就是常量(§3 序 4)。
#    ⚠️ 建完是**空目录** ⇒ report-pin 判 0(「每份报告都绑真实提交」在零份时为真,Phase 3 已裁定)。
REPORTS_DIR=$(awk '/^subjects:/{i=1;next} /^[a-z_]/{i=0}
                   i && /^[ \t]+reports:/{sub(/^[ \t]+reports:[ \t]*/,"");print;exit}' "$STAGE/latch.yml") \
  || die_broken "读生成的 subjects.reports 失败"
[ -n "$REPORTS_DIR" ] || die_broken "生成的 latch.yml 里没有 subjects.reports"
mkdir -p "$DST/$REPORTS_DIR" || die_broken "建不了 $DST/$REPORTS_DIR"
mv "$STAGE/latch.yml" "$DST/latch.yml" || die_broken "落位 latch.yml 失败"
for f in "$STAGE"/*; do
  [ -e "$f" ] || continue
  mv "$f" "$DST/.latch/$(basename "$f")" || die_broken "落位失败: $f"
done

printf '⭐ latch 已装入 %s —— %s 条可分发判据(scope != bootstrap)\n' "$DST" "$N"
printf '⚠️ 下一步:① 按本项目实际改 latch.yml 的 protected / doc_budgets;② git add 后提交,否则 criteria-guard 会判红\n'
exit 0
