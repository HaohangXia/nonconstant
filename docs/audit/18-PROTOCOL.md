# 18 · PROTOCOL —— 现行操作规则

> ⭐ 本文是**现行**操作规则,**会被订正**。
> ⛔ 历史与理由在 `03-LEDGER.md`。**冲突时以本文为准。**
> ⚠️ 与 `01-PLAN.md` 冲突时以 `01-PLAN.md` 为准 —— 本文管**怎么做事**,它管**做什么**。
>
> **上限:80 行 · 级别 soft**(依据 **A001** —— ⛔ 不另开 amendment,A001 的结论直接适用)。
> ⭐ 判据性质:**行数是代用品**,真正要防的是「**往里塞理由**」—— ⭐ **理由归 `03-LEDGER.md`,本文只放规则。**
> **soft** = 超限须登记 waiver(理由 + 到期),⛔ **不阻断**;⚠️ **waiver 机制未实现前,该上限实为建议**(同 `amendments/A001-*.md` `known_gaps` #1)。
> ⚠️ 「来源」列的条目 ID ⛔ 必须是 `03-LEDGER.md` 磁盘上真实存在的(`LATCH-cite-from-memory`)。

---

## §1 现行铁律(⭐ 替代已撤回的按形式禁令)

| # | 判据 | 规则 | 来源 |
|---|---|---|---|
| R1 | — 许可 | ⭐ **可以派 sub-agent**,只读任务鼓励派 | `LATCH-ban-by-feature-not-cause` · `LATCH-unexecutable-constraint` |
| R2 | ⚠️ 缺口(部分) | ⛔ sub-agent 与主 session **同样**:不得改判据 · 不得改 `01-PLAN.md` · 不得 commit | `LATCH-subagent-override` |
| R3 | ⛔ D5 | ⚠️ sub-agent 产出文件,主控**必须抽验引用**后才采信 | `LATCH-subagent-override` |
| R4 | ⛔ D5 | ⭐⭐ **发现必须说;实施须授权。**两件事分开 | `LATCH-ledger-extraction-gap` |
| R5 | ⚠️ 缺口(部分) | ⭐ **发现指令的清单不完整、引用不存在、或不可执行 ⇒ 必须报告** | `LATCH-incomplete-set` · `LATCH-cite-from-memory` · `LATCH-unexecutable-constraint` |
| R6 | ⛔ D5 | ⭐ 提案**可以提**,须**标为提案**,⛔ 不得自行实施 | `LATCH-ban-by-feature-not-cause` |
| R7 | ⚠️ 缺口(部分) | ⛔ **判据不通过就停下报告,不许改判据让它通过** | `LATCH-criterion-measures-wrong-thing` |
| R8 | ⭐ 已机器化(判定者=用户) | ⭐⭐ **下达方的回复必须含一节「自审」**:跑了几轮 · 找到几处 · 分别是什么。⛔ 该节不存在,或写「无问题」却未说明**检查了什么** ⇒ **视为未跑**,接收方应打回。<br>⭐ 要点:⛔ 不是「要自审」(不可验证的**意图**),⭐ 是「**自审必须留下产物**」(可验证的**输出**)—— 这是 **T1** 的应用。<br>⚠️ **能力边界**:只挡得住「完全没跑」,⛔ 挡不住「跑了但敷衍」(D5,不可根治)⇒ 与 hook 拦得住 `Write`/`Edit`、拦不住 `Bash` **同形** | `LATCH-directive-self-audit-3` · `LATCH-orchestration-boundary` |

## §2 保留的约束(⛔ 未变)

| # | 判据 | 规则 | 来源 |
|---|---|---|---|
| K1 | ⭐ 已机器化(Phase 7) | ⛔ 不改 `vendor/spec-kit/` | `CLAUDE.md` B2 |
| K2 | ⚠️ 缺口 | `01-PLAN.md` **§8 只增不删** | `01-PLAN.md` §8 |
| K3 | ⚠️ 缺口 | ⛔ **不 import DevLoop 一行代码** | `CLAUDE.md` B3 |
| K4 | ⛔ D5 | **白名单式 `git add`**,逐个文件点名 | Phase 0 / Phase 1 收尾惯例 |
| K5 | ⛔ D5 | ⭐ 跨 session 的结论**先落盘再讨论** | `01-PLAN.md` §7c |
| K6 | ⚠️ 缺口 | ⛔ 对已冻结契约的变更**走独立入口**(amendment),列影响面 + 要求重验 | `01-PLAN.md` §7c · `amendments/A001-*.md` |

## §3 事实核对(⭐ 三条,全部"以磁盘为准")

| # | 判据 | 规则 | 来源 |
|---|---|---|---|
| F1 | ⛔ D5(实例可) | 凡「**有多少个 X**」的断言,以磁盘 / 命令输出为准 | `LATCH-count-from-memory` |
| F2 | ⚠️ 缺口 | ⭐ 凡**引用任何条目 ID**,同样以磁盘为准 | `LATCH-cite-from-memory` |
| F3 | ⛔ D5 | 凡「**X 不存在 / A 不依赖 B**」的否定命题,须 ① 搜索模式覆盖所有已知形式 ② 给对照组 ③ 说明可能漏掉什么 | `LATCH-incomplete-set` |
| F4 | ⛔ D5 | ⭐ 凡「**某个数超了**」,先问**这个数在测什么**。⚠️ 本项目实例:`03-LEDGER.md` 行数未变而实际改动 **13 处指针** ⇒ ⛔ **行数亦不适合作为「改动量」的代用品** | `LATCH-proxy-criterion` |
| F5 | ⛔ D5 | ⭐ 任何**自律型预算**,须把「**修正自身**」排除在计数之外 | `LATCH-budget-eats-the-fix` · `LATCH-self-referential-deadlock` |
| F6 | ⛔ D5 | ⭐⭐ 凡「**这个做不到 / 太贵**」的断言,**须先量根因**;⛔ 未量根因的成本估算**不得作为放弃的依据** | `LATCH-cost-estimated-without-root-cause` |

## §4 判据纪律

| # | 判据 | 规则 | 来源 |
|---|---|---|---|
| C1 | ⚠️ 缺口(部分) | 判据 = **一条能跑的命令 + 期望退出码**;⛔ 写不成命令的停下报告 | `01-PLAN.md` §10 |
| C2 | ⭐ 已机器化 | ⭐ 新增或修改判据须**当场演示一过一失败**;⛔ 演示不出 = 常量,不是判据 | `LATCH-constant-criterion` · `LATCH-constant-criterion-inverse` |
| C3 | ⛔ D5 | ⭐ **红检对 fixture 跑,⛔ 不对真源跑**;fixture 用**真判据**,只有被测内容是假的 | `amendments/A001-*.md` §4.3 |
| C4 | ⚠️ 缺口 | ⛔ 判据不得引用不存在的路径(恒不命中 = 常量) | `CLAUDE.md` B4 |
| C5 | ⭐ 已机器化 | ⚠️ 闸的 **base 必须由操作者给**,⛔ 不得由被判定者给 | `LATCH-input-control` |
| C6 | ⚠️ 缺口(部分) | ⭐⭐ **闸门缺失必须比闸门判红更严重。**编排层 ⛔ 不得把「命令不存在」(**127**)等同于「未配置 ⇒ 跳过」 | `LATCH-missing-gate-is-silent` |
| C8 | ⭐ 已机器化 | ⭐⭐ **写下的上限必须有机器判据,⛔ 否则它是建议不是约束。**⚠️ 靠「每轮要求报数字」执行的上限是**人肉判据**,换 session 即失效 | `LATCH-uncheckable-limit` |
| C12 | ⚠️ 缺口(部分) | ⭐⭐ 以**匹配**定位被判对象的判据,须能区分「匹配失败」与「对象不存在」;⛔ 否则覆盖静默萎缩而判据全绿。⚠️ 仅 `status-facts` 已机器化(`expected_assertion_classes`),⛔ 其余判据未覆盖 | `LATCH-pattern-miss-reports-pass` |
| C11 | ⚠️ 缺口 | ⭐⭐ **标识符一旦被跨文件引用,它就是身份,⛔ 不再是序号。**⇒ 顺序改由**位置**承载,⛔ 不改编号 | `LATCH-id-is-identity-not-order` |
| C10 | ⚠️ 缺口 | ⭐⭐ **凡结论涉及上游行为,须在「用户实际安装形态」上复验**;⛔ 仅在 vendored 副本上验证的结论,**须标注该限制** | `LATCH-vendored-is-not-installed` |
| C9 | ⛔ D5(「是不是身份」是判断) | ⭐⭐ **fixture 复制得了内容,⛔ 复制不了身份。**当被测性质就是「身份」(是不是 submodule / 是不是真闸)时,⭐ **必须动真源**,C3 让位;⚠️ 但须 ① 当场复原 ② 复原后复跑绿检 ③ 报告中声明 | `LATCH-fixture-cannot-carry-identity` |
| C7 | ⚠️ 缺口 | ⭐ **ID 命名空间必须带作用域前缀。**本文条款 `R`/`K`/`F`/`C`+数字(全局唯一)· 完成报告内的契约 **`P<N>-`** 前缀(如 `P2-C1`,⛔ 仅报告内有效)· LEDGER 条目 `LATCH-<kebab>` · amendment `A<NNN>`。⇒ ⛔ **跨文件复用同一前缀 = 撞号** | 本轮 `C6` 撞号(协议 C6 vs Phase 2 报告 C6) |

## §5 ⛔ 已撤回的约束(⛔ 不要重新施加)

| 曾禁 | 为什么撤回 |
|---|---|
| ⛔ 不派 sub-agent | 绑**身份**而非动作;⛔ 解释不了「主 session 也会越权」 |
| ⛔ 不许用模糊表述凑数 | 判据是「措辞像不像模糊」⇒ 机器判不了(D5),已由 C1 覆盖 |
| ⛔ 不许压缩措辞蒙混 | ⚠️ **已被绕过**(两条未决各压一行)。该改的是判据,A001 已改 |
| ⛔ 不要写摘要 / 总结 | 顺带禁掉了有用的交接。⇒ 改为:**只传落盘产物,⛔ 不传对话记忆** |
| ⛔ 不要提出新方案 | ⛔ **在禁止最有价值的输出**。⇒ 由 R6 取代 |
| ⛔ 不要自作主张 | 与上条叠加 ⇒ 实际效果「发现了也别说」。⇒ 由 R4 取代 |
| ⛔ 不要新增未列出的条目 | ⛔⛔ **把下达方的盲区变成执行方的禁区**。⇒ 由 R5 取代 |

> ⭐ 共同根因:**看到一次坏结果 → 禁掉最近的相关特征 ⇒ 特征 ≠ 原因。**
> ⇒ ⭐⭐ **约束必须绑在可观察的动作上。**详见 `LATCH-ban-by-feature-not-cause`。
