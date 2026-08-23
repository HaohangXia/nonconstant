# A002 · B6 名额表与实际消耗顺序对齐

| 项 | 值 |
|---|---|
| 编号 | **A002** |
| 日期 | 2026-08-22 |
| 触发 | `reports/phase2-5a3420d.md` `known_gaps` #6 —— 表内行号与实际消耗者已错位 |
| 状态 | ⭐ 已采纳,应用于 `CLAUDE.md` B6 |
| B6 名额 | ⛔ **不新增** —— `amendments/` 作为目录整体已占一个名额(A001 §7) |

---

## 1 · 改哪条

`CLAUDE.md` **B6 · 复杂度预算的落点** 的文件表。

## 2 · 原冻结 commit

| 项 | 值 |
|---|---|
| B6 首次冻结 | **`bcddbc9`** `docs: lock Phase 0 module boundaries` |
| 本次修改前 | `34cc98f` |

## 3 · ⛔ 为什么当初是错的

⭐ **B6 表把「排期顺序」当成了「名额编号」,而两者在 A001 之后分了叉。**

A001 追加 `amendments/`(作为**一个目录整体**占一个名额,理由:若每份 amendment 各占一个,八个名额会被 amendment 吃光 ⇒ 修正契约的成本随次数上升 ⇒ **契约固化,正是 M4 要防的**),⛔ **但未回写 B6 表**。

⇒ 从那一刻起:

| | B6 表说 | 实际消耗 |
|---|---|---|
| 第 4 个 | `.nonconstant/scan-silent.sh` | ⛔ `amendments/` |
| 第 5 个 | `.nonconstant/meta-gate.sh` | ⛔ `.nonconstant/scan-silent.sh` |

⚠️ 一个错位的预算表,**后面每次动用名额都要重新解释一遍** —— 而「需要每次口头解释的表」正是 `LATCH-proxy-criterion` 那一类:数字还在,但已不测它该测的东西。

## 4 · 新内容

⭐ **名额按实际消耗顺序编号:**

| # | 文件 / 目录 | 何时 | 状态 |
|---|---|---|---|
| 1 | `CLAUDE.md` | Phase 0 | ⭐ 已用 |
| 2 | `nonconstant.yml` | Phase 1 | ⭐ 已用 |
| 3 | `.nonconstant/gates.sh` | Phase 1 | ⭐ 已用 |
| 4 | **`amendments/`(整个目录)** | A001 | ⭐ 已用 |
| 5 | `.nonconstant/scan-silent.sh` | Phase 2 | ⭐ 已用 |
| 6 | `.nonconstant/meta-gate.sh` | Phase 3 | ⬜ |
| 7 | `.nonconstant/report.sh` | Phase 3 | ⬜ |
| 8 | `workflows/nonconstant/workflow.yml` | 接 spec-kit `shell` step | ⬜ |

⚠️ ⛔ **原表的「#8 预留」被这次对齐吃掉了** —— 8 个名额现已**全部指名**,不再有预留。
⇒ ⭐ 这是 A002 的**真实代价**,⛔ 不掩饰:此后任何计划外的新文件都要走 amendment。

⛔ **第 9 个文件 = amendment**(原规则不变)。⛔ 用「拆成多个小文件」绕过计数,同样是 amendment。

## 5 · 影响面

⭐ 查的是:**Phase 0/1/2 有没有因为「B6 的某个名额编号」而做出过某个决定?**(⛔ 不是搜"提到过")

| # | 决定 | 出处 | 是否失效 |
|---|---|---|---|
| 1 | Phase 1 用掉 `nonconstant.yml` + `.nonconstant/gates.sh` | `reports/phase1-ae6f82f.md:31` | ⛔ **否** —— 引用的是**文件名**,#2/#3 编号未变 |
| 2 | Phase 2 用掉 `.nonconstant/scan-silent.sh` | `reports/phase2-5a3420d.md:35` | ⛔ **否** —— 该报告**未写编号**,只写文件名;`known_gaps` #6 已预先声明错位 |
| 3 | A001 记「B6 已用 4/8,#4 = `amendments/`」 | `amendments/A001-*.md:121` | ⛔ **否** —— A002 正是把该行**升格为表内事实**,方向一致 |
| 4 | Phase 0 `known_gaps` #4:计数口径(`docs/**`、`reports/**` 不计入) | `reports/phase0-bcddbc9.md:59` | ⛔ **否** —— A002 只动**编号顺序**,⛔ 未动计数口径 |
| 5 | Phase 2 把 `known_gaps` 写进报告而非 PLAN | `reports/phase2-*.md` | ⛔ **否** —— 由 B5 决定,与 B6 无关 |

### ⇒ **重验要求:⛔ 无。**

**理由(第一性):**⭐ **此前所有决定引用的都是「文件名」,⛔ 没有一处引用「名额编号」。**编号只在 A001 §7 与本表内部使用,而两者本次已同步。
⇒ 重编号**改变不了任何已完成决定的输入**,故无失效可能。

## 6 · known_gaps

| # | 缺口 | 说明 |
|---|---|---|
| 1 | ⛔ **预留名额归零** | 见 §4。8 个名额全部指名 ⇒ 计划外文件必走 amendment。⚠️ 与 `LATCH-budget-eats-the-fix` 同族风险:若 amendment 本身再消耗名额,修正成本会上升 —— ⭐ 已由「`amendments/` 目录整体占一格」挡住 |
| 2 | ⚠️ **B6 仍未区分「文件」与「文件类别」** | A002 只对齐编号,⛔ **未修 Q12 那个根本缺口**(`amendments/` 按目录计、其余按文件计,规则不统一)。⇒ 留给后续 amendment |
| 3 | ⚠️ **名额与「排期」仍耦合** | 表内同时承载「第几个名额」与「哪个 phase 用」。若 Phase 3 顺序变化,表又会错位。⇒ ⛔ 本轮不拆 |

---

⚠️ ⭐ **本文已被 A003 进一步修正** —— A002 让预留归零(F5 复发);A003 把预留移出计数,改为「预算外余量 + 用了必须登记」。见 `amendments/A003-budget-headroom.md`。⛔ A002 本身不撤回。
