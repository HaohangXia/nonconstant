# 同类工作扫描 —— ⛔ latch 的差异化不成立（2026-08-23）

> ⛔⛔ **本文是一次证伪。**上一轮我列了四条「latch 有、别人没有」的差异化，
> ⭐ 本轮逐条去核实 —— **四条全部落空**。
> ⚠️ 上限 60 行（`latch.yml:doc_budgets`）。⛔ 发布仍停。

## ⭐ 核实方法

⛔ 不看功能列表，⭐ 看它们**承认了什么** —— 因为「自曝边界」正是我以为的差异点。
证据来源：各项目 GitHub README 原文（`gh api repos/<r>/readme`，2026-08-23 取）。

## ⛔ 四条差异化，逐条落空

| # | latch 以为独有 | `ryangu00/axiom` 的对应物 |
|---|---|---|
| 1 | **判据不能是常量**（实证：判据 08-17 退化，3 天无人知） | ⛔⛔ **有**：「**A predicate is a letter, not a spirit.** `file_exists` passes on an empty file. Your predicates are the specification.」⇒ ⭐ 同一个「代用品判据」概念 |
| 2 | **静默失败必然累积**（实证：86 GB） | ⛔⛔ **有，且同形**：「a memory system that **reported healthy for 13 days while silently not writing**」⇒ ⭐ 那就是 T5，带自己的实证 |
| 3 | **判据的启用条件不得由被判对象提供**（C13 自遮蔽） | ⛔⛔ **有，且明说了后果**：「An agent with write access **can delete its own active claim**. Axiom raises the cost of a false "done" from free to deliberate; **it does not make it impossible**」 |
| 4 | **自曝覆盖比例（5/33）** | ⛔⛔ **有，且更彻底**：阈值标定 **n=1**、FP/FN 率是「**v1.2 commitment, not a v1 claim**」、独立的 `KNOWN-LIMITATIONS.md` + `FAQ.md`（正面回答「这不就是个 prompt 吗 / 沙箱才是真答案 / 没 benchmark 没证据」） |

⭐⭐ **最刺的一条**：axiom 写「邻居 `nah` 在公开语料（101,194 次工具调用）上标定，**that is the better standard and we say so**」
⇒ ⛔ **它主动承认竞品在某一维度上更强。**latch 至今没做过这件事。

## ⛔ 这个空间比预想拥挤得多

⭐ axiom 的 `Prior art & related work` 一节点名**六个**同域项目，且各附访问日期：

| 项目 | 做什么 | ⚠️ 相对 latch |
|---|---|---|
| `vnmoorthy/groundtruth` | Stop-hook 完成声明闸 | ⛔ **1,272 个真实 turn** 的标定 |
| `manuelschipper/nah` | PreToolUse 确定性权限 | ⛔ **101,194 次工具调用**的**公开**语料 |
| `ojuschugh1/claimcheck` | 事后 CLI，从 transcript 抽取声明 | — |
| `nizos/tdd-guard` | 同一 hook 层的 TDD 纪律 | — |
| `Yeachan-Heo/oh-my-claudecode` | Stop hook 查 TODO/stub/skipped-test | — |
| `OthmanAdi/planning-with-files` | 计划文件 + Stop 闸 | ⛔ **5+ 运行时适配** |
| `farhank15/mantiz` | 11 种作弊模式检测 + Trust Score | ⚠️ 黑客松产物；⛔ 未见自曝边界章节 |

⚠️ ⛔ **latch 的分发形态最弱**：axiom 有 4 个运行时适配（Claude Code · Codex CLI · hermes-agent · OpenClaw），latch 只有一个 shell 安装器。

## ⚠️ 一处可能仍成立的差异（⛔ 未穷尽，按 F3 标注）

⭐ **它们判的是「agent 的声明」；latch 有一层判的是「判据系统自身」**：

| latch 判据 | 判什么 |
|---|---|
| `meta-gate` | ⭐ **未演示「一过一失败」的判据不得启用** —— ⛔ 没演示的是常量 |
| `criteria-guard` | 判据文件被改即判红 |
| `waiver-expiry` | ⭐ 写下的到期没有判据 = 没有到期 |
| `doc-budget` | ⭐ 写下的上限没有判据 = 建议不是约束 |

⇒ ⭐ 别人做「**验证 agent**」，latch 有一部分在做「**验证你的验证**」。
⚠️ ⛔ **但这条只是「我在它们 README 里没看到」，⛔ 不是「它们没有」** —— ⛔ 未读 axiom 的
`docs/PRIOR-ART.md` · `KNOWN-LIMITATIONS.md` · `CONTRACTS.md` · `failure-modes.md`。
⇒ ⛔ **按 F3，否定命题须给覆盖范围** —— 本条覆盖范围仅为各项目 README 正文。

## ⛔ 结论

⭐ **latch 的差异化，按上一轮列的四条，不成立。**⛔ 且它在这个空间里**落后**：
无公开标定语料 · 单一运行时 · 无 prior-art 文档 · 未发布。
⇒ ⛔ **定位必须重写**，⛔ 发布继续停。⚠️ ⛔ 本轮未改 README、未定 Phase。
