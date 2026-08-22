#!/usr/bin/env bash
#
# latch · meta-gate  —— 判据可执行性(§3 序 4)
#
#   ⭐ 一条判据加入或修改时,必须先证明它**能产出非常量结果**:
#      登记至少一次「过」与至少一次「失败」的演示。
#      ⛔ 未登记 ⇒ 拒绝启用。⛔ 不是「先用着,回头补」。
#
#   实证:DevLoop 某判据 08-17 退化成必然红,08-20 才被发现 ——
#   而 08-17→08-20 之间闸跑了 0 次(16-DECISIONS D-16)。
#
#   ⭐⭐ 本闸自身也是一条判据 ⇒ 它必须先满足自己(见 latch.yml 的 meta-gate 条目)。
#
# 退出码:
#   0  过     —— 每条判据都登记了双向演示,且 impl 存在
#   1  未过   —— 有判据缺演示 / 双向同号 / 演示报告不存在 ⇒ 拒绝启用
#   2  闸自身故障 —— ⛔ 绝不因自身故障返回 0
#
#   ⭐⭐ 「闸门缺失」判 2,⛔ 比「判红」更严重(协议 C6):
#      ⛔ 编排层不得把它等同于「未配置 ⇒ 跳过」。
#
# 用法:  bash .latch/meta-gate.sh [配置文件]     # 默认 latch.yml

set -u

die_broken() { printf '⛔ META-GATE BROKEN: %s\n' "$1" >&2; exit 2; }

CONFIG="${1:-latch.yml}"
[ -f "$CONFIG" ] || die_broken "找不到配置 $CONFIG —— ⛔ 没有配置不等于判据都合格"
# ⭐⭐ 配置取值一律走 .latch/config-read.sh —— ⛔ 本脚本内不再自行解析
#    (C12 第二形态:行尾注释/引号被吞进取值 ⇒ 恒不命中 ⇒ 判据静默失效)
LATCH_DIR=$(dirname "$0")
# shellcheck source=/dev/null
. "$LATCH_DIR/config-read.sh" || die_broken "读不到 $LATCH_DIR/config-read.sh —— ⛔ 取值出口缺失 ≠ 配置为空"

IDS=$(awk '/^[ \t]*-[ \t]*id:/ { sub(/^[ \t]*-[ \t]*id:[ \t]*/, ""); print }' "$CONFIG" | while IFS= read -r ln; do latch_scrub "$ln"; printf "\n"; done | sed '/^$/d') \
  || die_broken "读判据清单失败"
[ -n "$IDS" ] || die_broken "$CONFIG 里一条判据都没有 —— ⛔ 空清单会让本闸恒过(常量)"

field() {   # field <id> <key>  —— 取某条判据块内的某个字段
  latch_scrub "$(awk -v want="$1" -v key="$2" '
    /^[ \t]*-[ \t]*id:/ {
      cur = $0; sub(/^[ \t]*-[ \t]*id:[ \t]*/, "", cur); inb = (cur == want); next
    }
    inb && $0 ~ "^[ \t]*" key ":" {
      sub("^[ \t]*" key ":[ \t]*", ""); print; exit
    }
  ' "$CONFIG")"
}

FAILS=""
note() { FAILS="${FAILS}   · ${1}"$'\n'; }

# ── subjects 块:每个键的值必须非空(A006 探针 4)──────────────────
# ⭐ 查「声明了且非空」;⛔ **不查路径是否存在** —— 那是各判据自己的职责(C6),
#    且新装环境里对象本来就还没有,抢着查会让本闸先判红。
SUBJ=$(awk '/^subjects:/ { inb=1; next } /^[a-z_]/ { inb=0 }
            inb && /^[ \t]+[a-z_]+:/ { print }' "$CONFIG") || die_broken "读 subjects 失败"
while IFS= read -r line; do
  [ -n "${line:-}" ] || continue
  k=$(printf '%s' "$line" | sed 's/^[ \t]*\([a-z_]*\):.*/\1/')
  v=$(printf '%s' "$line" | sed 's/^[ \t]*[a-z_]*:[ \t]*//')
  [ -n "$v" ] || note "subjects.$k: ⛔ 值为空 —— ⛔ 空路径会让判据回落到猜(A006)"
done <<EOF
$SUBJ
EOF

for id in $IDS; do
  impl=$(field "$id" impl)
  pexit=$(field "$id" demo_pass_exit)
  fexit=$(field "$id" demo_fail_exit)
  prep=$(field "$id" demo_report)

  # ── A · 闸门缺失比判红更严重(协议 C6)────────────────────────────
  if [ -z "$impl" ]; then
    die_broken "判据 $id 没有 impl 字段 —— ⛔ 无实现的判据不是「未配置」,是配置错误"
  fi
  if [ ! -f "$impl" ]; then
    die_broken "判据 $id 的实现不存在: $impl —— ⛔ 闸门缺失 ≠ 未配置 ⇒ 绝不跳过(C6)"
  fi

  # ── A' · scope 必须声明且合法(A006)────────────────────────────
  # ⛔ 「哪些判据可分发」若靠人记,又是一条无判据的规则
  #    (= LATCH-protocol-has-no-teeth)⇒ 写进配置,由本闸查。
  # ⚠️ 能力边界:本闸只查「声明了且取值合法」,⛔ 查不了「归类对不对」
  #    (把 bootstrap 写成 project 照样过)⇒ D5,同 LATCH-criteria-cannot-test-reasoning。
  sc=$(field "$id" scope)
  case "${sc:-}" in
    project|upstream|bootstrap) : ;;
    '') note "$id: ⛔ 未声明 scope —— ⛔ 「可不可分发」不得靠人记(A006)" ; continue ;;
    *)  note "$id: ⛔ scope 取值非法「$sc」—— 只许 project / upstream / bootstrap" ; continue ;;
  esac

  # ── B · 双向演示 ────────────────────────────────────────────────
  if [ -z "$pexit" ] || [ -z "$fexit" ]; then
    note "$id: ⛔ 缺演示登记(demo_pass_exit=「${pexit:-空}」 demo_fail_exit=「${fexit:-空}」)⇒ 拒绝启用"
    continue
  fi
  if [ "$pexit" != "0" ]; then
    note "$id: ⛔ demo_pass_exit=$pexit,不是 0 ⇒ 「过」这一侧没演示成功"
    continue
  fi
  if [ "$fexit" = "0" ]; then
    note "$id: ⛔ demo_fail_exit=0 ⇒ 两次演示同向 = 仍是常量,不是判据"
    continue
  fi
  if [ -z "$prep" ]; then
    note "$id: ⛔ 缺 demo_report —— ⛔ 不可核查的演示等于没演示"
    continue
  fi
  # ⛔⛔ 源码里不得有任何「放行」白名单 —— 那是**不受 criteria-guard 保护**的逃逸口。
  # ⭐ 若确需「暂未演示」这个状态,必须走 latch.yml 的豁免形态:显式列出哪条判据 ·
  #    reason · until(⛔ 须是具体 phase,不得是「以后」)· 运行时打印「已豁免」。
  # 见 03-LEDGER.md `LATCH-hardcoded-escape-hatch`。
  [ -f "$prep" ] || note "$id: ⛔ demo_report 不存在: $prep ⇒ 演示不可核查"
done

if [ -n "$(printf '%s' "$FAILS" | tr -d '[:space:]')" ]; then
  printf '⛔ meta-gate FAIL —— 以下判据未证明自己不是常量:\n' >&2
  printf '%s' "$FAILS" >&2
  printf '⇒ 判据加入或修改时,必须演示至少一次过 + 至少一次失败。⛔ 未演示者不得启用。\n' >&2
  exit 1
fi

printf '⭐ meta-gate PASS —— %s 条判据均已登记双向演示且实现存在\n' \
  "$(printf '%s\n' "$IDS" | sed '/^$/d' | wc -l)"
exit 0
