# latch · PLAN

| 项 | 值 |
|---|---|
| 项目名 | **latch** |
| 上游 pin | `github/spec-kit` **v0.16.4** / `d1f50fc` / MIT |
| 版本 | **v0.1**(已按实测代码修订,未经独立审计) |
| 收敛状态 | 未开始 |

> **本文档有硬上限:400 行。**超出时必须先删再加。
> 增长本身是失败信号 —— 目标是让它**变短且变准**,不是变全。

---

## §1 定位

### 一句话

> Spec Kit 的引擎能跑机器判定的闸门。它自己的工作流没用过一次。
> **latch 是把那个引擎真正用起来的方法论** —— 带判据、带证据、带技术债账期、带契约影响面追踪。

### 可核实的依据(任何人两分钟能验)

`workflows/speckit/workflow.yml` 共 78 行:

| step 类型 | 数量 |
|---|---|
| `command`(跑 prompt) | 4 |
| `gate`(**人工肉眼审批**) | 2 |
| **`shell`(机器判定)** | **0** |

两个 gate 都是 `message: "Review the ... before ..."` + `options: [approve, reject]`。无判据、无证据、无退出码。

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
| FAILED → `RunStatus.FAILED` → 流水线停止;`continue_on_error` 需显式开启 | `workflows/engine.py` 1737 行 | 默认即阻断 |
| `gate` step:交互审批,`on_reject: abort` 默认;非 TTY → `PAUSED`,可 `workflow resume` | `workflows/steps/gate/` 340 行 | 人在环 + 可恢复,已实现 |
| 控制流:`while_loop` / `do_while` / `fan_out` / `fan_in` / `switch` / `if_then` | `workflows/steps/` | 审计 loop 可直接用它编排 |

### 2.2 耦合方向(决定能删什么)

> ⚠️ 名字有二义:`workflows/`/`extensions/`/`presets/` 在仓库里**各有两份** ——
> 仓库根的资产目录,和 `src/specify_cli/` 下的 Python 包。本节讲代码,一律指后者。

```
workflows/  →  extensions/    2 处 import,且在引擎解析路径上   ❌ 不可直接删
workflows/  →  presets/       0 import(仅 steps/init 传 --preset 参数)
extensions/presets  →  workflows     0 import(只有注释与字符串)
```

依赖链(实测,路径+行号):
`engine.py:886 from .overlays import WorkflowResolver`
→ `overlays/__init__.py:15 from .schema import ...`
→ `overlays/schema.py:9 from ...extensions import normalize_priority`
→ 定义于 `extensions/__init__.py:185`

| 板块 | 行数 | 处置 |
|---|---|---|
| `workflows/` | **11,691**(实测 24 个 .py) | **保留,一行不改** |
| `extensions/` | **8,020**(实测) | **删除被上述依赖链阻断,待解** |
| `presets/` | **6,761**(实测) | 删 |
| `commands/bundle/` | ~1,100(未复核) | 删 |
| `integrations/` | ~7,000(未复核) | 保留,首发裁剪至 4–5 个 |
| `events.py` | 2,519(未复核) | **待查**:是否为 workflows 依赖 |

删除量与「不触碰引擎」的结论随 `extensions/` 一并**待重算**。

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

| ID | 机制 | 依据 | SK 状态 |
|---|---|---|---|
| A1 | **判定者独立性** —— pass/fail 由退出码决定,模型只出意见 | T1 | 引擎有能力,方法论零使用 |
| A2 | **会话切割** —— 一 phase 一 session。二等效果:**强制产物自足** | 公理 1 | 无(且非代码特性) |
| A3 | **commit-pinned 报告** —— 报告名含 commit hash | 不绑定状态的声明不可证伪 | 无 |
| A4 | **waiver 账期** —— 豁免须登记到期 phase,过期 → hard 阻断 | 刚性约束产生规避而非遵守;规避无声,故须提供有声通道 | 无 |
| A5 | **amendment 影响面** —— 改契约 → 列出引用它的后续 phase → 标记重验 | T3 | 无 |

**B 档(只是不同,不得当卖点):** 按架构层次分 phase;phase 状态按模块分片。

---

## §4 缺陷台账

> 副作用栏不得为空。无副作用的改进极可能没想清楚。

| ID | 缺陷 | 改法 | 副作用 |
|---|---|---|---|
| D1 | 独立判定只在 commit 一瞬成立,phase 内部全是模型自评 | stage 级检查点,只跑最便宜的 hard 判据 | 检查点太密 → 人机械点过 → 橡皮图章。建议仅 >2h 的 phase 启用 |
| D2 | 闸门密度低于错误被依赖速度(违反 T3) | P2 PreToolUse hook,下沉到工具调用层 | hook 写错阻断合法操作;escape hatch 本身是漏洞 |
| D3 | **人是瓶颈,与 LE 直接冲突** | 分级放行:`requires_human` 声明,低风险自动放行 | 分级可能定错。兜底:触发 amendment 无条件要人 |
| D4 | **Phase 0 悖论** —— 理解最浅时做最有约束力的决定 | amendment + `provisional: true` 契约,Phase 2 末强制复审 | provisional 会被滥用。限额 ≤ 30% |
| D5 | **可判定性天花板** —— "边界划得对不对"永远写不成退出码。**能硬化的恰恰不是最重要的** | 不能根治。① 承认;② Maker/Checker 交 Codex;③ 意见必须给行号 | token 翻倍;假阳性噪音 → 人忽略 advisory → 又回橡皮图章 |
| D6 | **只跑过 Phase 0,且是最易的**(约束本质是"什么都别改") | 用 latch 建 latch,Phase 1 起真改代码 | 可能发现方法论不好用需大改。**这个代价必须付** |
| D7 | 元工作膨胀 | 预算写进方法论当 invariant;**方法论须含"删自己"的机制** | 预算太紧则该有的约束写不下 |
| D8 | 理解债只解一半 —— 强制**产物**自足,未强制**人**读 | 报告加必须人填字段;Phase N 开始考 N-1 契约 | 会被敷衍。**本质无解,只降低无痛偷懒概率** |
| D9 | `CLAUDE.md` 是**上下文**非强制配置。「零源码改动」是事后审计,非实时阻断 | P2 | 见 D2 |

---

## §5 设计原型

### P1 三层闸门

```
第 3 层  commit 闸门      ← SK gate step 可用,但需补判据
第 2 层  stage 检查点     ← SK shell step 直接可用
第 1 层  PreToolUse hook  ← latch 新增(Claude Code 层)  ★最高优先级
```

### P2 PreToolUse hook ★

让「零源码改动」从**承诺**变成**物理不可能**:模型试图 `Edit` `src/` 下文件 → hook 拒绝 → 该次工具调用根本不发生。

**产品第一个 demo。**不是"闸门拒绝 commit"(事后),而是"**模型越界被当场挡住**"(真约束)。

限制:只拿得到工具名与参数,做不了语义判断。**[Q4]** escape hatch 如何不成为后门?

### P3 phase 表达为 workflow.yml

**不改引擎,只用引擎。**

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

`waivers/<date>-<module>-phase<NN>-<gate-id>.md`
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
| Q1 | `events.py`(2519 行)是否为 workflows 依赖?若是则不能随 extensions 一起删 | §2.2 删除清单 |
| Q2 | **stage 是否已是 BioGuard 既有概念?**(曾出现「stage self-checks」) | P1 第 2 层设计 |
| Q3 | 能写出几条**真可机器验证**的 invariant?若零,则回归带是空壳 | P3 |
| Q4 | PreToolUse escape hatch 如何不成为后门? | P2 |
| Q5 | integrations 首发保留哪 4–5 个? | §2.2 |
| Q6 | waiver 现在做还是等第一次真撞上?倾向后者 | P6 优先级 |

---

## §7 复杂度预算(硬约束)

| 项 | 上限 |
|---|---|
| 本文档 | **400 行** |
| `gate-check` 脚本 | 150 行 |
| 每 phase 判据 | 6 条 |
| latch 新增文件 | 8 |
| 元工作时间占比 | 15% |

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

---

## §9 诚实标注(对外必须写)

| 事项 | 怎么写 |
|---|---|
| 可判定性天花板 | 明说:能硬化的往往不是最重要的(D5) |
| 理解债 | 明说只降低偷懒概率,不解决(D8) |
| 验证程度 | **真跑完一个改代码的 phase 之前,不得宣称已验证**(D6) |
| 非原创部分 | phase-gate ← 传统工程;attestation ← 供应链安全;Maker/Checker ← Loop Engineering;引擎 ← Spec Kit。**原创在于组合 + 账期/影响面两个机制** |
