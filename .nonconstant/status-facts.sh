#!/usr/bin/env bash
#
# nonconstant · status-facts  —— STATUS 事实判据
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
# 用法:  bash .nonconstant/status-facts.sh [STATUS 文件] [配置文件]

set -u

die_broken() { printf '⛔ STATUS-FACTS BROKEN: %s\n' "$1" >&2; exit 2; }

# ⭐⭐ 配置取值一律走 .nonconstant/config-read.sh —— ⛔ 本脚本内不再自行解析
#    (C12 第二形态:行尾注释/引号被吞进取值 ⇒ 恒不命中 ⇒ 判据静默失效)
NONCONSTANT_DIR=$(dirname "$0")
# shellcheck source=/dev/null
. "$NONCONSTANT_DIR/config-read.sh" || die_broken "读不到 $NONCONSTANT_DIR/config-read.sh —— ⛔ 取值出口缺失 ≠ 配置为空"

CONFIG="${2:-nonconstant.yml}"
STATUS="${1:-}"
[ -f "$CONFIG" ] || die_broken "找不到 $CONFIG —— ⛔ 读不到 subjects"
[ -n "$STATUS" ] || STATUS=$(nc_subject "$CONFIG" status)
[ -n "$STATUS" ] || die_broken "$CONFIG 的 subjects 里没有 status —— ⛔ 没配就判不了,不得猜"
[ -f "$STATUS" ] || die_broken "找不到 $STATUS —— ⛔ STATUS 不存在 ≠ 没有失真"
[ -f "$CONFIG" ] || die_broken "找不到 $CONFIG —— ⛔ 没有对照物就判不了真伪"
git rev-parse --git-dir >/dev/null || die_broken "不在 git 仓库内"

BAD=""
CHECKED=0
note() { BAD="${BAD}   · ${1}"$'\n'; }

# ══ C12 · 覆盖面自检 ══════════════════════════════════════════════
# ⭐⭐ 本判据用正则「匹配」来**定位被判断言**。⛔ 匹配失败与「没有该断言」不可区分
#    ⇒ STATUS 措辞一变,某一整类就被静默跳过,⛔ 而判据照样报 PASS。
#    ⚠️ 实测两次:断言 2 的区间正则、amendments 断言写死目录名。
#    见 03-LEDGER.md `LATCH-pattern-miss-reports-pass` · 协议 C12。
#
# ⭐ 修法:⛔ 不去识别「STATUS 里有没有这句话」(那要先解决同一个问题),
#    ⭐ 而是让**判据声明自己该查几类**,再对照实际匹配到几类:
#      N = nonconstant.yml 声明的期望类数(⛔ 不在本脚本里,⇒ 改脚本改不掉它)
#      I = 本脚本实际实现的类数
#      M = 本次运行真正匹配到的类数
#    ⇒ I ≠ N ⇒ **2**(闸自身与契约不符,判不了它该判的)
#    ⇒ M < I ⇒ **1**(被判对象少了一整类断言)
CLASS_IDS="gate-count phase-set gate-table upstream-pin amendments table-paths"
CLASS_SEEN=""
seen_class() { CLASS_SEEN="${CLASS_SEEN}$1 "; }
count_words() { printf '%s\n' $1 | sed '/^$/d' | wc -l; }

# ── 断言 1:判据条数 ⇔ nonconstant.yml 的 `- id:` 计数 ───────────────────
CLAIM=$(awk 'match($0, /([0-9]+) 条判据/, m) { print m[1]; exit }' "$STATUS")
REAL=$(grep -c '^[ \t]*-[ \t]*id:' "$CONFIG") || die_broken "数 nonconstant.yml 判据失败"
if [ -n "$CLAIM" ]; then
  seen_class gate-count
  CHECKED=$((CHECKED + 1))
  [ "$CLAIM" = "$REAL" ] || note "判据条数:STATUS 称 $CLAIM 条,⛔ nonconstant.yml 实为 $REAL 条"
fi

# ── 断言 2:已完成 phase ⇔ reports/ 的**编号集合** ─────────────────
# ⭐⭐ 与 P10-C4 同一修法:比**集合**,⛔ 不比最大编号 —— 编号 = 身份 ≠ 顺序(C11)。
# ⚠️ ⛔ 原实现的正则是 `Phase 0~<n> 全部完成`,只认连续区间;
#    STATUS 一改成「Phase 0~7 + 10 全部完成」它就**匹配不上 ⇒ 静默跳过**,
#    而判据照样报 PASS。⇒ ⭐ 现在:**取出所有数字,展开 a~b 区间,当集合比**。
CLAIMLINE=$(grep -o 'Phase [0-9~ +,]*全部完成' "$STATUS" | head -1)
# ⭐⭐ 只在 STATUS **真的声称了** phase 集合时才索要 reports/ ——
#    ⛔ 求了用不上的数据、再因为拿不到而判 2,会让本判据在**每个新装环境**恒 2 = 常量。
#    ⚠️ 实测(Phase 8 绿检):新装环境 reports/ 是空的,而那份 STATUS 根本没做 phase 断言。
if [ -n "$CLAIMLINE" ]; then
  seen_class phase-set
  REPORTS=$(nc_subject "$CONFIG" reports)
  [ -n "$REPORTS" ] || die_broken "$CONFIG 的 subjects 里没有 reports —— ⛔ STATUS 声称了 phase 集合却无从核对"
  [ -d "$REPORTS" ] || die_broken "报告目录不存在: $REPORTS —— ⛔ 数不出已完成阶段"
  REALSET=$(ls "$REPORTS"/ | sed 's/^phase\([0-9]\+\)-.*\.md$/\1/;t;d' | sort -n -u | tr '\n' ' ')
  [ -n "$REALSET" ] || die_broken "$REPORTS 下一份 phase 报告都没有 —— ⛔ STATUS 声称完成了 phase,而磁盘上一份报告都没有"
  CHECKED=$((CHECKED + 1))
  CLAIMSET=$(printf '%s' "$CLAIMLINE" | awk '
    { gsub(/Phase|全部完成/, "")
      n = split($0, parts, /[ ,+]+/)
      for (i = 1; i <= n; i++) {
        if (parts[i] ~ /^[0-9]+~[0-9]+$/) {
          split(parts[i], r, "~"); for (k = r[1]; k <= r[2]; k++) print k
        } else if (parts[i] ~ /^[0-9]+$/) print parts[i]
      } }' | sort -n -u | tr '\n' ' ')
  [ "$CLAIMSET" = "$REALSET" ] \
    || note "已完成阶段:STATUS 称「$CLAIMSET」,⛔ reports/ 实为「$REALSET」"
fi

# ── 断言 4:判据表三元组 ⇔ nonconstant.yml 的 id / impl / level ──────────
# ⭐⭐ 严格强于旧的「数条数 + 查文件在不在」:
#    ⛔ 条数对不代表 id 对;⛔ 文件在不代表它是**这条 id 的** impl。
CFG_TRI=$(awk '/^gates:/{g=1;next} /^[a-z_]/{g=0}
  g && /^[ \t]*-[ \t]*id:/    { sub(/^[ \t]*-[ \t]*id:[ \t]*/,"");   id=$0 }
  g && /^[ \t]*level:/        { sub(/^[ \t]*level:[ \t]*/,"");       lv=$0 }
  g && /^[ \t]*impl:/         { sub(/^[ \t]*impl:[ \t]*/,"");        printf "%s|%s|%s\n", id, $0, lv }
' "$CONFIG" | sort) || die_broken "解析 $CONFIG 的 gates 失败"
# STATUS 侧:表格行 `| `id` | `impl` | level |`
ST_TRI=$(grep '^| *`' "$STATUS" | awk -F'|' 'NF>=4 {
    for (i = 2; i <= 4; i++) { gsub(/[` \t]/, "", $i) }
    if ($2 != "" && $3 != "" && $4 != "") printf "%s|%s|%s\n", $2, $3, $4
  }' | sort)
if [ -n "$ST_TRI" ]; then
  seen_class gate-table
  while IFS= read -r row; do
    [ -n "$row" ] || continue
    CHECKED=$((CHECKED + 1))
    printf '%s\n' "$CFG_TRI" | grep -qxF "$row" \
      || note "判据表:STATUS 的「$row」(id|impl|level)⛔ 在 $CONFIG 里找不到完全相同的一行"
  done <<EOF
$ST_TRI
EOF
  ST_N=$(printf '%s\n' "$ST_TRI" | sed '/^$/d' | wc -l)
  CFG_N=$(printf '%s\n' "$CFG_TRI" | sed '/^$/d' | wc -l)
  [ "$ST_N" -eq "$CFG_N" ] \
    || note "判据表:STATUS 列了 $ST_N 条,⛔ $CONFIG 实有 $CFG_N 条(⛔ 少列 = 静默漏报)"
fi

# ── 断言 5:上游 pin ⇔ nonconstant.yml:upstream_pin ─────────────────────
# ⚠️ STATUS 写短 hash,配置写全 hash ⇒ ⭐ 判「是不是前缀」,⛔ 不判相等。
CFG_PIN=$(sed -n 's/^upstream_pin:[ \t]*//p' "$CONFIG" | head -1)
ST_PIN=$(grep -o '上游 pin.*`[0-9a-f]\{7,\}`' "$STATUS" \
         | grep -o '[0-9a-f]\{7,\}' | head -1)
if [ -n "$ST_PIN" ]; then
  seen_class upstream-pin
  CHECKED=$((CHECKED + 1))
  if [ -z "$CFG_PIN" ]; then
    note "上游 pin:STATUS 称 $ST_PIN,⛔ 但 $CONFIG 里没有 upstream_pin"
  else
    case "$CFG_PIN" in
      "$ST_PIN"*) ;;
      *) note "上游 pin:STATUS 称 $ST_PIN,⛔ $CONFIG 实为 $CFG_PIN" ;;
    esac
  fi
fi

# ── 断言 6:amendments 编号区间 ⇔ amendments/ 目录实况 ─────────────
# ⭐ 本轮的触发点:`A001~A005` 在 A006/A007 出现后变成假话,连续四次靠人肉发现。
# ⚠️ ⛔ 目录名**不写进正则** —— 写死 `amendments/` 的话,断言换个目录就匹配不上
#    ⇒ 静默跳过 ⇒ 判据报 PASS 而实际没查。⭐ 与断言 2 原实现同一个病(实测抓到)。
ST_AMD=$(grep -o '[A-Za-z0-9_.-]\+/A[0-9]\+~A[0-9]\+' "$STATUS" | head -1)
if [ -n "$ST_AMD" ]; then
  seen_class amendments
  CHECKED=$((CHECKED + 1))
  # ⭐ 目录名取自**断言自身**(`<dir>/A00x~A00y`),⛔ 不硬编码 —— A006:
  #    硬编码的目录名装到别的项目里就是空转。
  AMD_DIR=${ST_AMD%%/*}
  LO=${ST_AMD#*/}; HI=${LO#*~}; LO=${LO%%~*}
  if [ ! -d "$AMD_DIR" ]; then
    note "amendments:STATUS 称 $ST_AMD,⛔ 但目录 $AMD_DIR 不存在"
  else
    REAL_LO=$(ls "$AMD_DIR"/ | sed 's/^\(A[0-9]\+\).*/\1/;t;d' | sort -u | head -1)
    REAL_HI=$(ls "$AMD_DIR"/ | sed 's/^\(A[0-9]\+\).*/\1/;t;d' | sort -u | tail -1)
    [ "$LO" = "$REAL_LO" ] && [ "$HI" = "$REAL_HI" ] \
      || note "amendments:STATUS 称 $LO~$HI,⛔ $AMD_DIR/ 实为 $REAL_LO~$REAL_HI"
  fi
fi

# ── 断言 3:清单里的文件路径都存在 ────────────────────────────────
# ⛔⛔ **只查表格行(`|` 开头)**,⛔ 不查正文。
#    根因:正文**可以合法地提到一个路径,正是为了说它不存在**
#    ——「⛔ 无 workflows/nonconstant/workflow.yml」这句是**真的**。
#    ⇒ 「凡提到的路径都须存在」是**过宽的判据** ⇒ 必然误报
#      (= LATCH-hook-three-legs 第三条腿)。实测首跑即撞上。
#    ⭐ 表格行是**清单**,语义就是「这些东西存在」⇒ 结构性判据,⛔ 非启发式猜测。
# ⚠️ 只取反引号里、带已知扩展名、⛔ 不含 * 或 ~ 的 token(通配与区间不是具体路径)
PATHS=$(grep '^|' "$STATUS" \
        | grep -o '`[A-Za-z0-9_./-]\+\.\(md\|sh\|yml\|log\)`' \
        | tr -d '`' | sort -u)
# ⛔ 上面**不加** `|| true`:管道以 sort 收尾,无匹配时 sort 仍返回 0 ⇒
#    `|| true` 只会吞掉真实故障(T5),⛔ 且它本身就是 silent-scan 要抓的模式。
[ -z "$PATHS" ] || seen_class table-paths
for p in $PATHS; do
  case "$p" in *'*'*|*'~'*) continue ;; esac
  CHECKED=$((CHECKED + 1))
  [ -e "$p" ] || [ -e "docs/audit/$p" ] \
    || note "路径不存在:STATUS 引用了 \`$p\`,⛔ 磁盘上没有"
done

# ══ C12 · 覆盖面判定 ══════════════════════════════════════════════
# ⭐ N 从 nonconstant.yml 读 —— ⛔ 不在本脚本里。改脚本(删掉一整类)改不掉 N ⇒ 判 2。
#   ⚠️ 且 nonconstant.yml 在 protected 清单内 ⇒ 改 N 会被 criteria-guard 判红。
EXP_N=$(awk '
  /^[ \t]*-[ \t]*id:[ \t]*status-facts[ \t]*$/ { g = 1; next }
  g && /^[ \t]*-[ \t]*id:/                     { g = 0 }
  g && /^[ \t]*expected_assertion_classes:/ {
    sub(/^[ \t]*expected_assertion_classes:[ \t]*/, ""); print; exit }
' "$CONFIG")
[ -n "$EXP_N" ] || die_broken \
  "$CONFIG 的 status-facts 条目里没有 expected_assertion_classes —— ⛔ 不声明该查几类,就无法发现「少查了一类」(C12)"
case "$EXP_N" in ''|*[!0-9]*) die_broken "expected_assertion_classes 不是数字:「$EXP_N」" ;; esac

IMPL_N=$(count_words "$CLASS_IDS")
SEEN_N=$(count_words "$CLASS_SEEN")

# ⭐⭐ N = **本项目承诺检查的类数下界**,⛔ 不是「脚本实现了几类」。
#    ⚠️ 实测(Phase 8):新装项目没有 amendments/ 也没有 phase 报告 ⇒ 做不出那两类断言。
#    ⛔ 若强求 N == I,等于把 nonconstant 自己的仓结构强加给每个用户。
# ⛔ N > I ⇒ 2:承诺查的比脚本实现的还多 ⇒ **它判不了它承诺的**。
#    ⭐ 同时专治「有人从脚本里删掉一整类」—— 那时 N 不变、I 少了 ⇒ N > I ⇒ 判 2。
[ "$EXP_N" -le "$IMPL_N" ] || die_broken \
  "覆盖面契约不符:$CONFIG 承诺查 $EXP_N 类,⛔ 本脚本只实现了 $IMPL_N 类($CLASS_IDS)⇒ 删类不得静默"

# ⛔ M < N ⇒ 1:承诺的类数没凑齐 ⇒ **被判对象少了一整类断言**。
if [ "$SEEN_N" -lt "$EXP_N" ]; then
  MISSING=""
  for c in $CLASS_IDS; do
    printf '%s\n' $CLASS_SEEN | grep -qx "$c" || MISSING="${MISSING}$c "
  done
  printf '⛔ status-facts FAIL —— 覆盖面萎缩:承诺查 %s 类,本次只匹配到 %s 类\n' "$EXP_N" "$SEEN_N" >&2
  printf '   · 未匹配到的类:%s\n' "$MISSING" >&2
  printf '⇒ ⛔ 「匹配不到」与「没有该断言」不可区分 ⇒ 若放行,覆盖面会静默萎缩而判据全绿(C12)。\n' >&2
  printf '⇒ ⭐ 要么补回 %s 里那类断言,要么改 %s 的 expected_assertion_classes(⚠️ 后者会被 criteria-guard 判红,⭐ 那是有意的)。\n' "$STATUS" "$CONFIG" >&2
  exit 1
fi

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
