# latch · PLAN

| 项 | 值 |
|---|---|
| 项目名 | **latch** |
| 上游 pin | `github/spec-kit` **v1.0.0** / `bca6790` / MIT |
| 版本 | **v0.1**(已按实测代码修订,未经独立审计) |
| 收敛状态 | 未开始 |

> **本文档有硬上限:400 行。**超出时必须先删再加。
> 增长本身是失败信号 —— 目标是让它**变短且变准**,不是变全。

---

## §1 定位

### 一句话

> spec-kit 已发布 1.0。它的引擎能跑机器判定的闸门 —— 而它自己的官方 workflow,78 行,依然是 0 个 shell step、2 个纯人工点批准。**这不是尚未完成,是设计选择。**
> **latch 是把那个引擎真正用起来的方法论** —— 带判据、带证据、带技术债账期、带契约影响面追踪。

### 可核实的依据(任何人两分钟能验)

`workflows/speckit/workflow.yml` 共 78 行:

| step 类型 | 数量 |
|---|---|
| `command`(跑 prompt) | 4 |
| `gate`(**人工肉眼审批**) | 2 |
| **`shell`(机器判定)** | **0** |

两个 gate 都是 `message: "Review the ... before ..."` + `options: [approve, reject]`。无判据、无证据、无退出码。

### 覆盖架构(A / B)

| 架构 | 形态 | 被判定者 | 实例 |
|---|---|---|---|
| A | 人在 Claude Code 里跑 | Claude 自己 | BioGuard |
| B | orchestrator 派单给子进程 agent | 子进程工人 | DevLoop |

**latch 覆盖 A + B。**§3 前五条机制在两种架构下都成立;**只有 M5(PreToolUse hook)挑架构** —— 它只在 A 下拦得住被判定者。

### 与 DevLoop 的关系

| | 状态 | 定位 |
|---|---|---|
| v1 · DevLoop | 公开、**归档** | 「我想做什么,做到一半发现 spec-kit 开源了」 |
| v2 · latch | 公开、**维护中** | 建在 spec-kit v1.0.0 上 |

- latch **不 import DevLoop 一行代码**。实测通用内核约 880 行,重写比搬运便宜。
- 但每条原则**指向 DevLoop 的一次具体事故**作为实证 —— 见 §3 实证栏。

### 三条公理

| # | 公理 |
|---|---|
| 公理 1 | 模型在两次运行之间遗忘一切 |
| 公理 2 | 生成成本崩塌,验证成本不变 |
| 公理 3 | 错误成本三重不对称:生成≈0 / 发现=高 / 修复已被依赖的错误=指数增长 |

### 四条定理

| # | 定理 | 源 |
|---|---|---|
| T1 | 约束的强度 = 判定者对被判定者的免疫程度 | 公理 1 |
| T2 | 工程价值已从生成侧转移到验证侧 | 公理 2 |
| T3 | 检查点必须密于错误被依赖的速度 | 公理 3 |
| T4 | 意图持有者只有三种:人的记忆(可被说服)/ 文件(可被改写)/ 程序(两者皆否) | 公理 1 |

### 与 Loop Engineering 的关系

LE 自己承认三个未解问题,latch 对应三个解:

| LE 的风险 | latch | 覆盖 |
|---|---|---|
| 验证仍是你的责任 | shell 判据 + 退出码 | ✅ |
| Comprehension debt | 会话切割强制产物自足 | ⚠️ 见 D8 |
| Cognitive surrender | 分级放行,人只在高风险处 | ⚠️ 见 D3 |

> LE 是油门的工程学。latch 是刹车和仪表的工程学。

---

## §2 实测事实(已核实,非预判)

### 2.1 Spec Kit 已有的能力

| 事实 | 位置 | 对 latch 的意义 |
|---|---|---|
| `shell` step 真跑 `subprocess.run`,`returncode != 0` → `StepStatus.FAILED` | `workflows/steps/shell/` 169 行 | **`gate-check.sh` 的语义已实现,不用写** |
| FAILED → `RunStatus.FAILED` → 流水线停止;`continue_on_error` 需显式开启 | `workflows/engine.py` 1788 行 | 默认即阻断 |
| `gate` step:交互审批,`on_reject: abort` 默认;非 TTY → `PAUSED`,可 `workflow resume` | `workflows/steps/gate/` 340 行 | 人在环 + 可恢复,已实现 |
| 控制流:`while_loop` / `do_while` / `fan_out` / `fan_in` / `switch` / `if_then` | `workflows/steps/` | 审计 loop 可直接用它编排 |

### 2.2 上游代码盘点(背景资料,不驱动任何决策)

> **处置已定:保留全部 spec-kit 代码,vendor 化,只读。**
> latch 全部是新增文件,不修改 `vendor/spec-kit/` 任何内容。
> 以下依赖关系仅供理解引擎怎么跑,**不驱动删除决策**。

> ⚠️ 名字有二义:`workflows/`/`extensions/`/`presets/` 在仓库里**各有两份** ——
> 仓库根的资产目录,和 `src/specify_cli/` 下的 Python 包。本节讲代码,一律指后者。

```
workflows/  →  extensions/    2 处 import,在引擎按 ID 解析 workflow 的路径上
workflows/  →  presets/       0 import(仅 steps/init 传 --preset 参数)
extensions/presets  →  workflows     0 import(只有注释与字符串)

specify_cli/__init__.py  →  extensions / integrations / presets / commands.bundle / workflows
                            模块级 eager import,包根一执行即注册全部子系统
```

依赖链(实测,路径+行号):
`engine.py:929 from .overlays import WorkflowResolver`
→ `overlays/__init__.py:15 from .schema import ...`
→ `overlays/schema.py:9 from ...extensions import normalize_priority`
→ 定义于 `extensions/__init__.py:185`

| 板块 | 行数 | 处置 |
|---|---|---|
| `workflows/` | **12,072**(实测 24 个 .py) | 保留,只读 |
| `extensions/` | **8,175**(实测) | 保留,只读 |
| `presets/` | **6,776**(实测) | 保留,只读 |
| `commands/bundle/` | **1,103**(实测) | 保留,只读 |
| `integrations/` | **10,410**(实测) | 保留,只读 |
| `events.py` | **2,570**(实测) | 保留,只读 |

### 2.3 改名工作量

| 词 | 出现次数 |
|---|---|
| `specify` | 9,064 |
| `speckit` | 5,177 |
| `spec-kit` | 1,962 |
| `Spec Kit` | 821 |

⚠️ `specify` 混有大量英文动词("specify the timeout"),**不可无脑 sed**,需按上下文分批。

### 2.4 确认为 latch 原创

`src/` 全仓 grep `waiver | amendment | exemption | expiry | expires_at` → **零命中**(仅 `constitution-template.md` 用了 amendment 的普通词义)。

---

## §3 latch 净增量

> 按「实证 / 通用 / 是否地基」重排。**分割线以上五条有实证,这五条就是 latch。**

| 序 | 机制 | 实证 | 通用性 / 是否地基 |
|---|---|---|---|
| 1 | **隔离工位** —— 判定发生在被判定者改不动的地方 | DevLoop 三个月最常用、最少出问题 | **A1 的物理前提**,不是并列机制。否则 A1 当场失效 |
| 2 | **M1 闸判据 + 测试守卫**(A1 判定者独立性) | ⭐ 拦下过作弊:工人改动 `tests/` 让自己过关 | 380 行通用内核;A/B 两种架构都成立 |
| 3 | **T5 静默失败扫描** | ⭐ 86 GB 事故 | 通用 |
| 4 | **闸门可执行性** —— 判据必须仍是判据 | ⭐ 08-17 退化成常量 | 通用 |
| 5 | **M3 报告绑 commit**(A3) | ⭐ 91 条老行不可证伪 | 170 行 |
| — | ─────── 以上五条有实证 ─────── | | |
| 6 | M5 PreToolUse hook | ⭐ **实测拦住过 sub-agent 的 `Write`**(15 号,`calls.log` L19-20);⛔ 但 `Bash` 通道两次均未拦 | ⚠️ 覆盖架构 A **+ 架构 B 的一半**(Claude Code 派出的 sub-agent);⛔ 拦不住另起进程的工人。见 §6 Q11 |
| 7 | M2 waiver(A4 账期) | ⛔ 零实证 —— 三个月 157 单一次未被需要 | → 降为**设计假说,待验证**。⚠️ ⭐ **A001 已产生首个真实需求**(soft 上限超限须登记 waiver,而机制不存在)见 `amendments/A001-line-budget-scope-and-level.md` |
| 8 | M4 amendment(A5 影响面) | ⛔ 零实证。唯一实证是我们自己违反了它(§8 #13) | → 降为**设计假说,待验证** |

> 另:A2 **会话切割**(一 phase 一 session,二等效果:强制产物自足)保留,本轮未重新评级。

**B 档(只是不同,不得当卖点)** —— **[示例]** BioGuard 形态示例,latch 不内建这两种切法:按架构层次分 phase;phase 状态按模块分片。

---

## §4 缺陷台账

> 副作用栏不得为空。无副作用的改进极可能没想清楚。

| ID | 缺陷 | 改法 | 副作用 |
|---|---|---|---|
| D1 | 独立判定只在 commit 一瞬成立,phase 内部全是模型自评 | stage 级检查点,只跑最便宜的 hard 判据 | 检查点太密 → 人机械点过 → 橡皮图章。何时启用由项目决定 |
| D2 | 闸门密度低于错误被依赖速度(违反 T3) | P2 PreToolUse hook,下沉到工具调用层 | hook 写错阻断合法操作(⭐ **2026-08-22 已有实证** —— 误拦只读命令,见 `03-LEDGER.md` `LATCH-hook-three-legs`);escape hatch 本身是漏洞 |
| D3 | **人是瓶颈,与 LE 直接冲突** | 分级放行:`requires_human` 声明,低风险自动放行 | 分级可能定错。兜底:触发 amendment 无条件要人 |
| D4 | **Phase 0 悖论** —— 理解最浅时做最有约束力的决定 | amendment + `provisional: true` 契约,到期强制复审(相对到期,默认 +2 phase) | provisional 会被滥用。限额 ≤ 30%(可覆盖默认) |
| D5 | **可判定性天花板** —— "边界划得对不对"永远写不成退出码。**能硬化的恰恰不是最重要的** | 不能根治。① 承认;② Maker/Checker 交与 maker 不同的独立 checker(后端可配,例:Codex);③ 意见必须给行号 | token 翻倍;假阳性噪音 → 人忽略 advisory → 又回橡皮图章 |
| D6 | **只跑过 Phase 0,且是最易的**(约束本质是"什么都别改")。**[示例]** latch 自举验证记录,不列入产品能力 | 用 latch 建 latch,Phase 1 起真改代码 | 可能发现方法论不好用需大改。**这个代价必须付** |
| D7 | 元工作膨胀 | 预算写进方法论当 invariant;**方法论须含"删自己"的机制** | 预算太紧则该有的约束写不下 |
| D8 | 理解债只解一半 —— 强制**产物**自足,未强制**人**读 | 报告加必须人填字段;Phase N 开始考 `references_contracts` 指向的上游契约 | 会被敷衍。**本质无解,只降低无痛偷懒概率** |
| D9 | `CLAUDE.md` 是**上下文**非强制配置。「零源码改动」是事后审计,非实时阻断 | P2 | 见 D2 |

---

## §5 设计原型

### P1 三层闸门

```
第 0 层  隔离工位          ← 判定的物理前提(见 §3 序 1)
第 3 层  commit 闸门      ← SK gate step 可用,但需补判据
第 2 层  stage 检查点     ← SK shell step 直接可用
第 1 层  PreToolUse hook  ← latch 新增(Claude Code 层)  ⚠️ 只对 Write/Edit 事前阻断
```

### P2 PreToolUse hook

让「零源码改动」从**承诺**变成**物理不可能**:模型试图 `Edit` 受保护路径下的文件 → hook 拒绝 → 该次工具调用根本不发生。受保护路径是 glob 清单,由项目填(默认示例 `src/**`);拦截器由 latch 提供。

~~产品第一个 demo。~~ 已撤回(§8 #11)。**第一个 demo 改为「测试守卫」** —— 工人改动 `tests/` 让自己过关,被当场拦下。它拦的是**主动作弊**,且在 A/B 两种架构下都成立;比"拦模型写 `src/`"(拦手滑)有力得多。

**⭐ 实测能力边界(15 号靶场,两轮):**

| 通道 | 触发 | 阻断 | 能力 |
|---|---|---|---|
| `Write` / `Edit`(主会话 **与** sub-agent) | ⭐ 是 | ⭐ 是 | **事前阻断**,文件不存在 |
| `Bash`(`echo >` / `python -c`) | ⭐ 是 | ⛔ **否**,两次都写成了 | ⇒ 改为**当场发现**:执行前后快照受保护路径,变了判红 |
| 阶段边界 | — | — | 事后判定(shell gate 退出码) |

⛔ Bash 漏的原因是**判据不全**,非能力缺失 —— `tool_input.command` 已在手上,判定分支没检查它。⛔ 但不可判命令字符串(拦 `>` ⇒ 绕 `python -c` ⇒ 无穷退化),故只能判结果。

限制:① 只拿得到工具名与参数,做不了语义判断;② ⚠️ **`session=` 字段不区分主会话与 sub-agent**(两轮均复现)⇒ 归属靠时序夹逼 + 计数吻合,**并发场景下这两样都会失效**。**[Q4]** escape hatch 如何不成为后门?

### P3 phase 表达为 workflow.yml

**不改引擎,只用引擎。**

> **示例:路径与文案按项目替换。**

```yaml
steps:
  - id: gate-no-src-change
    type: shell
    run: "git diff --quiet HEAD -- src/"      # 退出码非 0 → 自动 abort
  - id: human-release
    type: gate
    message: "Phase 0 gates green. Release?"
    on_reject: abort
```

### P4 闸门三级制

| 级别 | 判定者 | 阻断 | 豁免 |
|---|---|---|---|
| Hard | shell 退出码 | ✅ | ❌ |
| Soft | shell 退出码 | ✅ | ⚠️ 需 waiver |
| Advisory | LLM | ❌ | — |

**写不成 shell 的判据只能是 advisory —— 诚实承认它是意见,不是闸门。**

### P5 完成报告 schema

**第一读者是下一个会话的模型,不是人。**

`pin` / `frozen_contracts` / `references_contracts`(A5 的数据基础)/ `gate_results` / `known_gaps` / `next_entry_conditions` / `explicitly_out_of_scope`(防下一会话重提已否决方案)/ `human_confirmation`(D8,模型不得代填)

### P6 waiver

`waivers/<date>-phase<NN>-<gate-id>.md`
字段:闸门 / 实际值 vs 阈值 / 理由 / 补偿措施 / **到期 phase** / 批准
过期未清 → hard 阻断

### P7 amendment

入口独立(不能 phase 中途顺手改)。必填:改哪条 / 原冻结 commit / **为什么当时是错的** / 新内容。
自动按 `references_contracts` 列出受影响 phase → `needs-revalidation` → 未重验则阻断。

| | waiver | amendment |
|---|---|---|
| 处理 | 达不到的**标准** | 定错的**契约** |
| 代价 | 到期必须清 | 触发下游重验 |

### P8 fail path

hard 失败 → 阻断;soft 失败 → 修复或开 waiver;advisory → 记 `known_gaps` 不阻断;
**phase 整体不可行 → 回退上一 commit 重写 intent。这是合法路径,不是失败。**

---

## §6 未决问题

| ID | 问题 | 阻塞 |
|---|---|---|
| Q2 | **stage 是否已是 BioGuard 既有概念?**(曾出现「stage self-checks」) | P1 第 2 层设计 |
| Q3 | 能写出几条**真可机器验证**的 invariant?若零,则回归带是空壳 | P3 |
| Q4 | PreToolUse escape hatch 如何不成为后门? | P2 |
| Q6 | waiver 现在做还是等第一次真撞上?倾向后者 | P6 优先级 |
| Q8 | ~~Task 工具 + spec-kit `fan_out` 够不够替代 DevLoop 编排层?~~ ⭐ **已答:不够**(`dca84db`)—— 作用域不可控 + 不拦跨边界写 | — |
| Q12 | ⛔ **B4 未区分「判据」与「判据比对的数据」** —— 若把 vendor 指纹这类**基准数据**放进受保护的 `.latch/`,上游每次合法升级都会触发误报(= `LATCH-hook-three-legs` 第三条腿的形状)。⛔ 改 B4 须走 amendment | Phase 1 受保护集合的定义 |
| Q11 | ⭐ **hook 在 §3 的排名要重估到第几?** 实证已从「只覆盖架构 A」收窄为「覆盖 A + B 的一半」,且它是**唯一被证实拦得住 sub-agent** 的机制。⛔ 本轮不改排名 | §3 序位 · Phase 4 |
| Q13 | ⛔ **安装形态未定。**候选:① 安装脚本 ② spec-kit extension ③ PyPI 包。⚠️ ② 的陷阱:扩展命令被迫叫 `speckit.latch.xxx`,且要接触 **D-03 决定不碰**的扩展系统(8,000 行) | ⛔ **Phase 1~3 完成后再定** —— 分发的前提是有东西可分发;⛔ 现在定 = 给一个还不存在的东西设计包装 |
| Q18 | ⛔ **`until` 用 phase 编号是跨项目脆弱的。**⭐ 根治方向:改成**可核的条件**(如「`latch.yml` 中不再存在该 exclude 项」)⇒ 跨项目也成立,且不受重排影响。⚠️ 会改 `waiver-expiry` 的判据语义 | ⛔ 触发:**Phase 8 之后**;⭐ 实证见 `amendments/A007-*.md` |
| **Q19** | ⛔⛔ **判据加固已推迟的四项**(⭐ 全部已有 LEDGER 条目,⛔ 带着文档化的已知缺口发布):**A** 判据 id 对齐 + 失败类型码(`silent-scan` vs `silent-failure-scan`;`GATE`/`SCAN` BROKEN 前缀不一致;⛔ 无机器可读失败类型)· **B** 自遮蔽配套(①「每条模式至少命中一个现存对象」+ ③「显式声明允许为空」,见 `LATCH-self-blinding`)· **C** C14 红检基线自检 + 「soft 判红不得提交」条款(`LATCH-harness-failure-looks-like-red`)· **D** B6 表判据(⭐ 状态列已订正为事实 ⇒ ⛔ 当前无假话 ⇒ 不建判据也能发) | ⛔ **触发:首个外部用户报告相关问题**,⛔ 不是「有空就做」。⭐ 依据:自然发生率 **1 次**(`status-facts` 断言 2,且被下一轮扫出),⛔ 其余全由探针刻意构造 ⇒ **是脚枪,不是漏洞** |
| Q17 | ⛔ **编排层的可自动化边界。**完整论证见 `03-LEDGER.md` `LATCH-orchestration-boundary` | ⛔ 触发:**Phase 3 后** |
| T6 候选 | ⭐ **凡让「修复成本随时间上升」的机制,必然固化错误。**T5 / 自指死锁 / 预算吃掉修正三者共用母题。见 `03-LEDGER.md` `LATCH-fix-cost-monotonicity` | ⛔ 升格进 §1 定理表须走 amendment。**归属:与 Q17 同批,⛔ 触发 = Phase 3 后** —— 编排层上线后 LEDGER 增速数量级上升,复查缺口那时才真正咬人;⛔ 提前处理是预先建设 |
| Q16 | ⛔ **闸的 base 由谁提供未强制。**被判定者自选 base ⇒ 可先改判据、再把 base 设成改后状态 ⇒ 差集为空 ⇒ 判绿。⭐ **判定的输入被被判定者控制 ⇒ T1 失效**(见 `03-LEDGER.md` `LATCH-input-control`) | ⛔ 触发:**Phase 3 接编排层**时解决 |
| Q15 | ⛔ **§7a「`01-PLAN.md` ≤ 400 行」是代用品判据。**它测的是**行数**,想测的是「文档膨胀成没人读的东西」。⭐ 本轮实证:两条未决被各**压成一行**塞入 —— 行数达标而信息密度反升 ⇒ **Goodhart**。⚠️ 完整论证待补,归 `16-DECISIONS.md` | ⛔ 改 §7a 走 **amendment**。触发:**Phase 1 完成后** |
| Q14 | ⛔ **B2 未声明对 spec-kit 的接口面。**实测 latch 只依赖两条语义:`shell` step 退出码非 0 ⇒ 流水线停止(`workflows/steps/shell/__init__.py:70`)· `gate` step `on_reject` 默认 `abort`(`workflows/steps/gate/__init__.py:45`)⇒ ⭐ 上游升级只需验这两条(v0.16.4 → v1.0.0 两处**一字未改**)。⭐ 附:latch 真正依赖的只是"**能跑 shell 并检查退出码的东西**",⛔ 不一定非得是 spec-kit(Makefile / CI / 脚本皆可)—— ⛔ 不写进 v1 宣传,先在 spec-kit 上做扎实 | B2 的缺口,与 **Q12 同族**。⛔ 改 B2 走 amendment |

---

## §7 复杂度预算(硬约束)

### 7a latch 自律上限(用户看不见)

| 项 | 上限 |
|---|---|
| 本文档 · ⭐ **仅现行结论**(§1 §3 §4 §5 §6 §7 §10) | **400 行** · 级别 **soft** |
| 档案(§2 §8 §9) | ⛔ **不计入**。⭐ **分区规则:档案仅此三节,其余章节一律计入现行结论;新增章节默认计入**,除非在 A00x 中显式划为档案 |
| `gate-check` 脚本 | 150 行 |
| latch 新增文件 | **8** 个**指名**名额 + **预算外余量**;⚠️ 余量仅限「修正自身的产物」与「计划外必需」,⛔ 用了必须在完成报告 `known_gaps` 登记。依据 **A003** |

> ⚠️ **soft** = 超限须登记 **waiver**(理由 + 到期 phase),⛔ **不阻断**。⭐ 这是「记录自身缺陷」的通道 —— ⛔ 不需要另开例外。
> ⛔ **waiver 机制尚未实现**(§10 Phase 0~3 均未排)⇒ 在它存在之前,该上限**实为建议**。见 `amendments/A001-line-budget-scope-and-level.md` `known_gaps` #1。
> ⚠️ 为何是**代用品判据**见 §6 **Q15**;计数命令与红绿实测见 **A001** §4.3。

### 7b 默认预算(施加给用户,可覆盖)

| 项 | 默认值 |
|---|---|
| 每 phase 判据 | 6 条 |
| 元工作时间占比 | 15% |

### 7c 落盘纪律(硬约束)

> 过去三天跑偏的根因。它此前**只存在于对话里**,所以每次换 session 就丢。

- **任何跨 session 的结论,必须先落盘再讨论。**
  顺序:产出 → 写入 `docs/audit/` + commit → 才进入讨论。
  ⛔ 反过来(先讨论、事后决定写不写)会让状态只活在对话上下文,换 session 即丢失 ⇒ **必然漂移**。
- **任何对已冻结契约的变更,必须走独立入口**,⛔ 不得混在技术回复里。
  须列**影响面** + 要求下游**重验**。(实证:§8 #13)

**明确不做:** Web UI;改 workflows 引擎;phase 状态机的程序化编排(人在环是特性);CI 集成。

---

## §8 已撤回的主张(只增不删)

| # | 曾声称 | 撤回原因 |
|---|---|---|
| 1 | 「phase 只进不退」 | 从名字 `ratchet` 倒推,非观察所得,且与 P8 合法回退矛盾。**修正:单向的不是 phase,是"已冻结契约"集合** |
| 2 | 「你的闸门比 SK 更硬」(无限定) | 仅**设计**更硬,**执行**只在 Phase 0 验证过,而那是最易过的闸门。见 D6 |
| 3 | 「`CLAUDE.md` 里的边界是硬约束」 | 它是上下文非强制配置。见 D9 |
| 4 | **「Spec Kit 无 runtime,结构上无法阻断」** | **错。**v0.16.4 有 1737 行工作流引擎,`shell` step 查退出码,`gate` step 可 abort。**修正:能力存在,方法论零使用** |
| 5 | **「必须自建 CLI」** | 由 #4 推出,随之失效。改为建在其引擎上 |
| 6 | **「硬闸门装进它的机箱会变软」** | 由 #4 推出,随之失效 |
| 7 | **「`workflows/` 不引用 `extensions/`,可安全删除后者」**(原 §2.2) | **错,方向是反的。**`overlays/schema.py:9` 与 `overlays/_commands.py:13` 均 `from ...extensions import normalize_priority`;`engine.py:886` 又 `from .overlays import WorkflowResolver`。**引擎按 ID 解析 workflow 的路径硬依赖 `extensions/`**;反向 0 import。**修正:删 `extensions/` 会打断引擎** |
| 8 | 「`workflows/` ≈ 6,500 行」(原 §2.2) | **实测 11,691 行**,低报 44%。同口径下 `extensions/` 8,020、`presets/` 6,761 与原值差 <1%,故口径无疑,仅此项错 |
| 9 | **「删 `extensions/` / `presets/` 以减重」** | 撤回。latch 的价值是新增契约治理层,不是精简上游。KEEP 零举证,删除需举证 —— 我们制造了一个本不需要论证的问题并为它消耗了三轮 |
| 10 | **§7 混用了两种性质的预算** | latch 对自己的自律与施加给用户的默认值,已拆为 §7a/§7b |
| 11 | **「M5 PreToolUse hook 是最高优先级、第一个 demo」** | **撤回。**DevLoop 实测:M5 存在(402 + 223 行),但工人跑在子进程里、**不过 hook**。按 T1,M5 对"工人"这个被判定者免疫度为 **0** —— 它保护的是**操作者**,不是被判定者。且只覆盖架构 A |
| 12 | **「五机制齐全」** | **撤回。**漏了地基:**隔离工位**。判定必须发生在被判定者改不动的地方,否则 A1 当场失效。隔离是 A1 的**物理前提**,不是并列机制 |
| 13 | **「DevLoop 是实验室、不发布」** | **撤回,且这是一次无声契约变更。**用户 2026-08-21 裁定「DevLoop 作为模组挂进 spec-kit」;07 号 §5.3 我改成「实验室、不发布」——⛔ 混在技术回复的摘要表里没走独立入口;⛔ 没列影响面(影响 04 号立论、阶段三、要不要接 spec-kit);⛔ 没要求重验;DevLoop 侧问过用户两次、两次未获答复却已标"✅ 采纳";⛔ 13 号我自己判 CONVERGED 把它一并确认。⭐ **我设计了 M4,然后完整违反了 M4 的每一条 —— 它是 M4 的第一条实证。原文摘录见表下,#13 不依赖外部文件** |
| 14 | **「M2 waiver / M4 amendment 是核心机制」** | 降为**设计假说,待验证**。三个月 157 单,DevLoop 两者都没有,一次都没被需要 |
| 15 | **「隔离工位 = git worktree」** | **撤回。**实测两个 sub-agent 从"隔离"工位**写进了主仓**(`shared.txt` 含 `A-touched-main` + `B-touched-main`)。worktree 隔离的是 **checkout**,进程写文件用绝对路径 ⇒ 它是 VCS 便利设施,**从来不是沙箱**。⇒ §3 排名第 1 的隔离工位**目前不知道怎么实现**(`dca84db`) |
| 16 | **「hook 放 Phase 1」** | 撤回(与 #11 同源)。⛔ 违反"按 §3 实测排名"这条铁律 —— 排名第 6 的机制因为**最近讨论过**被提到第一个做 |
| 17 | **「M5 只覆盖架构 A」** | ⚠️ **收窄,不完全撤回。**2026-08-22 的越权发生在**架构 B**(sub-agent),而 hook 是当前唯一被证实拦得住它的机制(15 号)。准确表述:hook 拦得住 **Claude Code 派出的 sub-agent**,⛔ 拦不住**另起进程的工人**(DevLoop 形态)—— 两者都属架构 B,hook 只覆盖前者。⇒ 排名待重估,记 §6 Q11 |

### #13 原文摘录(使该条自足)

> 原出处 `07-REPLY-to-06.md` **不在本仓库**(见 `README.md`)。引用不可查的出处 = 不是实证,故在此直录。

**被撤回的原文**(出自 07 号 §5.3):

> 「DevLoop 是实验室,latch 是产品。latch = 从 DevLoop 提炼的最小可发布内核 + spec-kit 集成层。DevLoop 继续私用、继续演进、**不发布**。」

**它取代的原契约**(用户 2026-08-21 原话):

> 「工作流引擎 分析我和它的区别 尽量把我融入进它的里面 或者 可以把我的部分作为一个模组加载吗?」

⛔ 变更时:未走独立入口(混在技术回复的摘要表里)、未列影响面、未要求下游重验;DevLoop 侧两次问询用户均未获答复,却已标"✅ 采纳",并被 13 号连同其余项判为 CONVERGED。

⭐ 现状:用户 **2026-08-22 明确作废该裁定**,改为 v1 / v2 双公开(见 §1「与 DevLoop 的关系」)。⇒ 这是 **M4(amendment)的第一条实证**。

---

## §9 诚实标注(对外必须写)

| 事项 | 怎么写 |
|---|---|
| 可判定性天花板 | 明说:能硬化的往往不是最重要的(D5) |
| 理解债 | 明说只降低偷懒概率,不解决(D8) |
| 验证程度 | **真跑完一个改代码的 phase 之前,不得宣称已验证**(D6) |
| 非原创部分 | phase-gate ← 传统工程;attestation ← 供应链安全;Maker/Checker ← Loop Engineering;引擎 ← Spec Kit。**原创在于组合 + 账期/影响面两个机制** |

---

## §10 阶段划分

> **三条铁律:**① 顺序严格按 §3 实测排名,⛔ 不按讨论热度;② 验收判据 = **一条能跑的命令 + 期望退出码**;③ ⛔ 写不成命令的,停下报告,不许用模糊表述凑数。
> ⚠️ **latch 零代码** ⇒ ⛔ 任何引用 `src/` 的判据都是常量(恒过),不许用。受保护集合 = `.latch/**` + `latch.yml`,⭐ 它们由 Phase 1 自己创建,故非常量。

### Phase 0 · 边界锁定(零代码)

- `test -f CLAUDE.md && grep -q '## 模块边界' CLAUDE.md` ⇒ **0**
- `[ "$(git status --porcelain -- '*.py' '*.sh' | wc -l)" -eq 0 ]` ⇒ **0**

### Phase 1 · 测试守卫(§3 排名 2,⭐ 唯一有真拦截实证)

**做:** 判据文件本身不得被被判定者修改。

- 红检 `printf '\n#p\n' >> latch.yml && bash .latch/gates.sh` ⇒ **非 0** —— ⛔ 须**改内容**;`touch` 只改 mtime,内容判据看不见(实测 `touch` ⇒ 0)
- 绿检 `touch docs/probe.md && bash .latch/gates.sh` ⇒ **0**
- ⚠️ `tests/` 一并进受保护集合,⛔ 但 latch 现无 `tests/` ⇒ 该路径**在有测试之前是常量**,不得单独作红检

### Phase 2 · 静默失败扫描(T5,86 GB 实证)

⚠️ ⛔ **必须用函数作用域,不用行数窗口**(行数窗口实测误报率 10%)。

- 红检 `bash .latch/scan-silent.sh fixtures/dirty` ⇒ **非 0**
- 绿检 `bash .latch/scan-silent.sh fixtures/clean` ⇒ **0**

### Phase 3 · 判据可执行性 + 报告绑 commit

- 元判据 新判据未演示"一过一失败" → `bash .latch/gates.sh --meta` ⇒ **非 0**
- 报告绑定 `git merge-base --is-ancestor "$(ls reports/phase$N-*.md | sed 's/.*-//;s/\.md$//')" HEAD` ⇒ **0** —— ⭐ 报告名 = **它所描述的那个 commit**,⛔ 非当下 HEAD ⇒ 求值时机从「当下」变为「任何时候」(实测 绿 0 / 红 128)

### Phase 4 · STATUS 事实判据(⭐ 地基:说假话的 STATUS 会误导后面每一个 phase)

**实证:**2026-08-22 实测 `STATUS.md` 同时有三句假话 ——「零行代码」(实为 5 条判据已提交)·「Phase 0 可以开工」(实为 0~3 全完成)·「最后 commit」停在十几个 commit 之前。⛔ `doc-budget` 一句都抓不到。

⭐ **可判定**,因为 STATUS 写的是**状态**,而状态由仓库决定 ⇒ 每条断言都有对应物。

- 绿检 `bash .latch/status-facts.sh` ⇒ **0**
- 红检 `bash .latch/status-facts.sh <fixture:把判据条数改错>` ⇒ **非 0**
- ⚠️ 至少覆盖:判据条数 ⇔ `latch.yml` 的 `- id:` 计数 · 已完成 phase ⇔ `reports/phase*.md` · 文中每个文件路径存在

### Phase 5 · waiver 到期判据(⛔ 现有 3 条 waiver,一条都没人查到期)

**实证:**`latch.yml` 已有三处豁免形态(自扫排除 · `doc-budget` 的 `waiver_*` · A001 的 soft 上限),⛔ **到期从未被检查** —— 这与 `LATCH-uncheckable-limit` **完全同族**:写下的到期没有判据 = 没有到期。

- 绿检 `bash .latch/waiver-expiry.sh` ⇒ **0**
- 红检 `bash .latch/waiver-expiry.sh <fixture:把某 until 设为已完成的 Phase 1>` ⇒ **非 0**
- ⚠️ 当前 phase 取自 `reports/phase*.md` 的最大编号;⛔ `until` 不是具体 phase ⇒ 判红

### Phase 6 · 上游语义判据(⭐ 比分发更地基:决定 latch 能否**安全跟随上游**)

⛔ 给整个 `vendor/` 做指纹 ⇒ 上游每次**合法升级**都误报(= `LATCH-hook-three-legs` 第三条腿)。
⭐ **判语义、⛔ 不判文件内容** —— 验 **Q14** 实测出的那两条,上游怎么改都行,只要语义不变:

| 语义 | 出处 |
|---|---|
| `shell` step:退出码非 0 ⇒ 流水线停止 | `workflows/steps/shell/__init__.py` |
| `gate` step:`on_reject` 默认 `abort` | `workflows/steps/gate/__init__.py` |

- 绿检 当前 `vendor/`(v1.0.0)⇒ **0**
- 红检 fixture 里把 `shell` step 改成忽略退出码 ⇒ **非 0**

### Phase 7 · 上游 pin 可核(⭐ Q13 的前置:安装形态必须回答「上游那份从哪来」)

⛔ **「pin」目前是一句话,不是可核事实** —— 磁盘那份无法被证明是 `bca6790`。
⇒ ⭐ 由 **A005** 把 `vendor/spec-kit` 改为 **submodule**:⭐ 它记的**就是 commit 本身**,⛔ 不是版本声明、不是内容摘要 —— **唯一非代用品的解法**。

- 可核 `[ "$(git -C vendor/spec-kit rev-parse HEAD)" = "$(sed 's/^upstream_pin: //;t;d' latch.yml)" ]` ⇒ **0**
- 红检 把 submodule 切到**任一别的 commit** 后同一条 ⇒ **非 0**
- ⚠️ 未取回(空目录)⇒ **2**,⛔ 不得当成「pin 没变 ⇒ 放行」

⚠️ ⛔ **本 phase 只解决「是不是那一份」,⛔ 不解决「有没有被改过」** —— 后者 submodule 只显示为 ` M vendor/spec-kit`,而 Phase 0 判据 2 **实测看不见它**(A005 §5 #1)⇒ 须一并给出独立判据。

> ⭐⭐ **编号 = 身份,⛔ 不是顺序**(A007)。编号一经排定不再变动 ⇒ 跨文件引用永久有效;
> **执行顺序 = 下面块的物理位置**。⇒ 当前下一个是 **Phase 10**,⛔ 不是 Phase 8。

### Phase 10 · 消除自扫豁免(⛔ 目标不是「引入解析器」)

⚠️ ⛔ **phase 名不写方案** —— 「引入解析器」是**一个实现**,把它写进 phase 名会提前锁死解法。
⚠️ Phase 2 当时判「⛔ 要真解析器才能消」—— ⭐ **实测证伪**:那是在**没找替代方案**的情况下下的结论。

**⭐ 实测(2026-08-22,`$TEMP` 内,⛔ 未动真源):**自扫命中**恰好 2 处**,都在 `printf` 的**消息文本**里(`scan-silent.sh:64` `:65`),⛔ **不在正则里**。⇒ **只改那两句消息措辞,豁免即完全消失,且红检仍为 1。**

| 候选 | 估行数 | ⛔ 失效模式 |
|---|---|---|
| ⭐ **1 · 消息文本不含模式串** | **0 净增**(改 2 行字符串) | ⚠️ 将来写新消息又嵌入模式串 ⇒ 复现;⭐ **但自扫解禁后它会当场判红 ⇒ 自防**。⚠️ 代价:消息可读性下降 |
| 2 · 模式与消息移到数据文件 | +15~25,新增 1 文件(走余量) | ⛔ **不成立** —— 数据文件本身含模式串 ⇒ 豁免只是**搬家**(= `LATCH-proxy-criterion` 藏账同形);除非豁免数据文件,那又回到原点。⚠️ 正是 **Q12** 那个洞 |
| 3 · 整文件豁免收窄到**指定行**豁免 | +8~12 | ⛔ 行号随代码变动而**漂**;漂后要么误报要么**漏报**,⚠️ 而漏报是**静默的**(T5) |
| 4 · 只扫「非字符串区域」 | +40~70 ⇒ ⚠️ 逼近 §7a 的 150 行 | ⛔ 引号配对(shell 单双引号 / 转义 / here-doc / awk 内嵌;python 三引号 / f-string)做不全 ⇒ **漏扫且静默**。⭐ 但它是唯一**通用**解 —— 其余三个只解决自扫 |

⇒ ⭐ **本 phase 只定目标与验收,⛔ 不预先选候选** —— 选哪个由实现时按上表权衡。

**验收(三条,⛔ 缺一不可):**

- 豁免已**消除** `grep -q 'path: .latch/scan-silent.sh' latch.yml` ⇒ **非 0**(⭐ 证明是消除,⛔ 不是满足)
- 绿检 `bash .latch/scan-silent.sh .latch` ⇒ **0**
- 红检 `bash .latch/scan-silent.sh <脏 fixture>` ⇒ **非 0**(⭐ 证明判据未被削弱)

⚠️ ⇒ 本 phase 排定后,自扫豁免的 `until` 才**有可指的具体 phase**(即 `Phase 10`)⇒ 解开 Phase 5 的死结。

### Phase 8 · Q13 安装形态

⭐ 验收**判结果、⛔ 不判机制**(D-12)—— 无论用脚本 / extension / PyPI,后置条件相同:

- 绿检 装进一个**空的临时仓**后,**所有 `scope != bootstrap` 的判据**全部可调用且返回**各自预期的**退出码
  ⛔ **不写死条数** —— ⚠️ 写死会在加判据时过期(= `LATCH-renumber-breaks-reference` 同形)。依据 **A006**
  ⚠️ ⛔ 只验 `meta-gate` 返回 0 不够 —— 那验的是「**装完能跑**」,⛔ 不验「**装对了**」
- 红检 装进一个**已有 `latch.yml`** 的仓 ⇒ **非 0**(⛔ 不得静默覆盖)

### Phase 9+ · Q17 编排层

⛔ **本轮不排。**⚠️ 它的形态取决于 Q13 的答案(装成 spec-kit extension ⇒ `workflow.yml`;独立 ⇒ 另一套)。
⇒ ⛔ 在 Q13(Phase 8)答完之前,验收命令写不出来 —— **按铁律不得列为阶段目标**。
⚠️ 它须一并吞掉:**127 显式处理**(C6)· 判据路径参数固定(A004 `known_gaps`)· 空目录 vacuous 第四态。

⚠️ **⛔ Q11(hook 排名重估)不单列 phase** —— 它是**判断**,验收写不成命令。⇒ 归入 Phase 9 的准入条件。
