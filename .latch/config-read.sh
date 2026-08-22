#!/usr/bin/env bash
#
# latch · config-read  —— ⭐⭐ 配置取值的**唯一**出口(⛔ 不可单独执行,只供 source)
#
#   ⛔ 为什么集中在一处:八个脚本各写一份剥离逻辑 ⇒ 下次改规则要改八处
#      ⇒ 修复成本随判据数量上升 ⇒ 与 `LATCH-budget-eats-the-fix` 同族(F5)。
#
#   ⭐⭐ 它防的是 C12 的**第二形态**:⛔ 不是「匹配不到」,而是
#      「**匹配到了,但取出的东西无法履行职责**」。两次实测:
#        · `- latch.yml            # 配置本体`
#          ⇒ criteria-guard 的 glob 变成含注释的字符串 ⇒ 恒不命中
#          ⇒ `git status` 明明是 ` M latch.yml`,而判据判 **0 PASS**(自遮蔽,C13)
#        · `exclude_sections: 2 8 9      # 档案，依据 A001，另见 10`
#          ⇒ 注释里的裸数字 `10` 变成被排除的章节 ⇒ 01-PLAN 超限**静默消失**(藏账)
#      见 03-LEDGER.md `LATCH-pattern-miss-reports-pass` · `LATCH-self-blinding`。
#
#   ⛔ 本文件不判定、不退出 —— 只做取值。判定与退出码归各判据自己(它们的
#      `die_broken` 语义不同)。⭐ 取不到一律返回**空串**,由调用方决定判 1 还是 2。

# ── 剥离:行尾注释 · 包裹引号 · 首尾空白 · CR ────────────────────────
# ⚠️ 行尾注释的判据是「**空白 + #**」—— 这是 YAML 的行内注释写法。
#    ⛔ 不剥「值开头就是 #」的情况:那在 YAML 里本就代表空值,交给调用方查空。
#    ⚠️ ⛔ 也不剥值**中间**的 `#`(如 glob `a#b`)—— 只有前面有空白才算注释。
latch_scrub() {   # latch_scrub <原始值>
  printf '%s' "${1-}" | sed -e 's/\r$//' \
                            -e 's/[ 	][ 	]*#.*$//' \
                            -e 's/^[ 	][ 	]*//' \
                            -e 's/[ 	][ 	]*$//' \
                            -e 's/^"\(.*\)"$/\1/' \
                            -e "s/^'\(.*\)'\$/\1/"
}

# ── subjects: 块取值 ────────────────────────────────────────────────
# ⭐ 原先这段在 4 个脚本里各有一份副本。⛔ 现在只有这一份。
latch_subject() { # latch_subject <配置文件> <键>
  latch_scrub "$(awk -v key="$2" '
    /^subjects:/ { inb = 1; next }
    /^[a-z_]/    { inb = 0 }
    inb && $0 ~ "^[ 	]+" key ":" { sub("^[ 	]+" key ":[ 	]*", ""); print; exit }
  ' "$1")"
}

# ── 顶层标量键取值 ──────────────────────────────────────────────────
latch_top() {     # latch_top <配置文件> <键>
  latch_scrub "$(awk -v key="$2" '
    $0 ~ "^" key ":" { sub("^" key ":[ 	]*", ""); print; exit }
  ' "$1")"
}

# ── 列表块取值:`<键>:` 与下一个顶层键之间的 `- ` 行,逐行剥离 ────────
# ⭐ 每行单独 scrub —— ⛔ 整块 scrub 会把第一行的注释规则套到全块上。
latch_list() {    # latch_list <配置文件> <键>
  awk -v key="$2" '
    $0 ~ "^" key ":" { inb = 1; next }
    inb && /^[a-z_]/ { inb = 0 }
    inb && /^[ 	]*-[ 	]*/ { sub(/^[ 	]*-[ 	]*/, ""); print }
  ' "$1" | while IFS= read -r ln; do
      v=$(latch_scrub "$ln")
      [ -z "$v" ] || printf '%s\n' "$v"
    done
}
