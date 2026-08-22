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

# 生成用户侧 latch.yml:只留可分发判据,⛔ 且 demo_report 指向随装的证据清单
awk -v keep="$KEEP" '
  BEGIN { n=split(keep,rows,"\n"); for(i=1;i<=n;i++){ split(rows[i],f,"\t"); ok[f[1]]=1 } }
  /^[ \t]*-[ \t]*id:/ { id=$0; sub(/^[ \t]*-[ \t]*id:[ \t]*/,"",id); skip=!(id in ok) }
  /^[ \t]*impl:/ && !skip { sub(/\.latch\/[^ ]*/, ".latch/" substr($0, match($0,/[^\/]*$/))) }
  /^[ \t]*demo_report:/ && !skip { print "    demo_report: .latch/EVIDENCE.md"; next }
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
mv "$STAGE/latch.yml" "$DST/latch.yml" || die_broken "落位 latch.yml 失败"
for f in "$STAGE"/*; do
  [ -e "$f" ] || continue
  mv "$f" "$DST/.latch/$(basename "$f")" || die_broken "落位失败: $f"
done

printf '⭐ latch 已装入 %s —— %s 条可分发判据(scope != bootstrap)\n' "$DST" "$N"
printf '⚠️ 下一步:① 按本项目实际改 latch.yml 的 protected / doc_budgets;② git add 后提交,否则 criteria-guard 会判红\n'
exit 0
