# Phase 2 · 静默失败扫描(T5)—— 完成报告

> ⭐ **第一读者是下一个会话的模型,不是人。**
> ⚠️ 本报告绑定 commit **`5a3420d`** —— ⛔ 脱离该 commit 的任何结论不可证伪。

## pin

| 项 | 值 |
|---|---|
| 报告绑定 commit | **`5a3420d`** `feat: lock Phase 2 silent-failure scan` |
| 上游 pin | `github/spec-kit` **v1.0.0** / `bca6790` / MIT |
| 阶段 | **Phase 2 · 静默失败扫描**(§3 排名 3,T5,86 GB 实证) |
| 日期 | 2026-08-22 |

## frozen_contracts

| ID | 契约 | 落点 |
|---|---|---|
| C6 | ⭐ **扫描单位 = 函数作用域,⛔ 不用行数窗口** | `.latch/scan-silent.sh` 第二类判据 |
| C7 | **两类判据分开**:① 点位类(`\|\| true` · `2>/dev/null` · `except: pass`)—— 信号在该处即被丢弃,与作用域无关;② 作用域类(`capture_output=True` 全函数未查返回码) | 同上 |
| C8 | **三档退出码**:`0` 过 / `1` 未过 / `2` 扫描器自身故障 —— ⛔ **目标不存在、参数缺失、目标非目录一律判 2,绝不判 0** | 同上 |
| C9 | ⛔ **注释行不是代码**,不参与判定 | 同上 |
| C10 | 新闸 `silent-scan` 登记于 `latch.yml`,`level: hard` | `latch.yml:gates[1]` |

## references_contracts

| 上游契约 | 出处 | 兑现 |
|---|---|---|
| §3 序 3 T5 静默失败扫描 | `01-PLAN.md` | ⭐ 已实现 |
| D-15 ⚠️ 扫描单位必须函数作用域 | `16-DECISIONS.md` | ⭐ 已实现,并**当场复现了行数窗口的误报**(见 gate_results 探针 F) |
| D-17 红检必须配绿检 | `16-DECISIONS.md` | ⭐ 红绿都做 |
| C2 新判据须演示一过一失败 | `18-PROTOCOL.md` §4 | ⭐ 当场演示 |
| C3 红检对 fixture 跑,fixture 用真判据 | `18-PROTOCOL.md` §4 | ⭐ fixture 动态构造于 `$TEMP`,**仓库内零静态副本**;判定者是同一个扫描器 |
| B4 判据在 `.latch/`,清单在 `latch.yml` | `CLAUDE.md` | ⭐ 已兑现 |
| B6 新增文件 ≤ 8 | `CLAUDE.md` | 本轮用掉 **`.latch/scan-silent.sh`**(103 行,§7a 上限 150) |

## gate_results

⭐ 红绿检在 `$TEMP/latch-p2/` 动态构造的 fixture 上求值;⛔ 不对真源跑。收尾工作树 **0 项**。

| # | 检 / 探针 | 命令 | 期望 | 实测 |
|---|---|---|---|---|
| 1 | **红检** | `bash .latch/scan-silent.sh <dirty>` | 非 0 | ⭐ **1**(4 条,四类各中:`capture_output` 未查 · `except: pass` 跨行 · `\|\| true` · `2>/dev/null`)|
| 2 | **绿检** | `bash .latch/scan-silent.sh <clean>` | 0 | ⭐ **0** |
| 3 | 探针 A · 空目录 | `bash .latch/scan-silent.sh <empty>` | 0 | ⭐ **0** |
| 4 | 探针 B · 目标不存在 | `bash .latch/scan-silent.sh <nope>` | 非 0 | ⭐ **2** ⛔ 未当成「没有静默失败 ⇒ 放行」 |
| 5 | 探针 C · 不给参数 | `bash .latch/scan-silent.sh` | 非 0 | ⭐ **2** |
| 6 | 探针 D · 目标是文件 | `bash .latch/scan-silent.sh <a.py>` | 非 0 | ⭐ **2** |
| 7 | 探针 E · 扫描器被删 | 删后跑 | 非 0 | ⚠️ **127**(shell 报的,见 `known_gaps` #1)|
| 8 | ⭐⭐ 探针 F · **行数窗口回归对照** | 对 clean fixture 做 `grep -A8 capture_output \| grep returncode` | — | ⛔ **窗口内找不到 `returncode` ⇒ 8 行窗口会误报;⭐ 函数作用域判 PASS** |
| 9 | 探针 G · 自扫 `.latch/`(狗粮) | `bash .latch/scan-silent.sh .latch` | — | ⚠️ **1**,**2 条全为假阳性**(见 `known_gaps` #2)|

⇒ ⭐ **一过一失败已演示(#1 vs #2)⇒ 该判据不是常量。**
⇒ ⭐⭐ **探针 F 是本 phase 最有价值的结果**:它**证明**函数作用域是必要的,⛔ 不只是被选中的 —— 同一段干净代码,行数窗口判红、函数作用域判绿。这是 DevLoop `dispatch.py:183` 那个误报在 latch 内的**独立复现**。

## known_gaps

| # | 缺口 | 说明 |
|---|---|---|
| 1 | ⚠️ **「删掉扫描器」返回 127,⛔ 不是 latch 的 2** | 与 Phase 1 `known_gaps` #2 **同源复发**。若编排层把「脚本不存在」当成「没配这道闸 ⇒ 跳过」就是**静默通过**。⇒ Phase 3 接编排层时必须显式处理 127 |
| 2 | ⛔ **扫描器不区分「代码」与「字符串字面量」** | 自扫 `.latch/` 出 2 条,**全为假阳性** —— 是 `scan-silent.sh` 自己 `printf` 里的模式文本(`:44` `:45`)。注释行已由 **C9** 排除(假阳性 6 → 2),⛔ 但字符串字面量需要真解析器。⇒ ⚠️ **当前若把 `silent-scan` 接到 `.latch/` 上,它会对自己判红** |
| 3 | ⚠️ **假阳性率未在真实语料上测过** | 只在自造 fixture 与 `.latch/`(2 个文件)上跑过。⛔ DevLoop 侧「行数窗口 10% → 函数作用域 0%」是**别处的数**,⛔ 不是 latch 的数 |
| 4 | ⚠️ **`silent-scan` 未接入编排层** | 当前必须显式给扫描目录;⛔ 没有任何东西**保证**它会被跑到。⇒ 与 `LATCH-input-control` 同族:**判定的输入(扫哪里)由调用方给** |
| 5 | ⚠️ **只覆盖 `.py` / `.sh`** | 其它语言、以及 `subprocess.Popen` / `os.system` / `check_output` 等变体未覆盖 |
| 6 | ⚠️ **B6 的「名额」与表中行号已错位** | B6 表列 `#4 = .latch/scan-silent.sh`,⛔ 但第 4 个**实际消耗**的名额是 `amendments/`(见 `LATCH-budget-eats-the-fix`)。本文件是**第 5 个**已用名额。⇒ B6 需要一次 amendment 来对齐,⛔ 本轮不做 |

## next_entry_conditions

Phase 3(判据可执行性 + 报告绑 commit)开工前须满足:

1. ⭐ 本报告已提交,`.latch/scan-silent.sh` 与 `latch.yml` 在 `5a3420d` 内 —— **已满足**
2. ⬜ 红/绿两条命令**先写出来**再写实现
3. ⬜ ⛔ **必须显式处理 127**(`known_gaps` #1,已两次同源复发)
4. ⬜ 决定 `silent-scan` 的扫描目标由谁给(`known_gaps` #4 · **Q16** · `LATCH-input-control`)
5. ⚠️ `known_gaps` #2 会在「把闸接到 `.latch/` 上」时立刻咬人 —— Phase 3 接编排层前须处置

## explicitly_out_of_scope

⛔ 下一会话**不得重提**:

- ⛔ 改回行数窗口(探针 F 已证明它会误报)
- ⛔ 为了让自扫变绿而删掉扫描器里的模式文本 —— 那是**改被测内容迁就判据**
- ⛔ 给 hard 闸开 waiver 通道
- ⛔ 现在建编排层 / 定安装形态(**Q13**:Phase 1~3 完成后再定)
- ⛔ 改 `CLAUDE.md` B4 / B6(须走 amendment,见 **Q12** · `known_gaps` #6)
- ⛔ 实现隔离工位(§8 #15 撤回了「= git worktree」,目前无实现路径)

## human_confirmation

⛔ **模型不得代填。**

- [ ] 我确认四类扫描模式就是我要扫的范围(`known_gaps` #5 列出了未覆盖的)
- [ ] 我确认 `known_gaps` #2(字符串字面量假阳性)可以留到 Phase 3 前处置
- [ ] 我确认 Phase 2 可以关闭
