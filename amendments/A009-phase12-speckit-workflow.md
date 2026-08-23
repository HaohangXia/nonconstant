# A009 · §11 增设 Phase 12 · 接上 spec-kit 执行引擎

| 项 | 值 |
|---|---|
| 编号 | **A009** |
| 日期 | 2026-08-23 |
| 触发 | ⭐ 「引擎」被拆成**执行引擎 / 生成引擎**两类后（`LATCH-engine-two-kinds`），nonconstant 缺的那一半变清楚了 |
| 状态 | ⭐ 已采纳，应用于 `docs/audit/01-PLAN.md` §11 |
| B6 名额 | ⭐ **用掉第 8 格** —— `workflows/nonconstant/workflow.yml`，空了十二个 phase |

---

## 1 · 改哪条

`docs/audit/01-PLAN.md` **§11 现行与待排阶段** —— ⭐ 在 `Phase 9+` 之前插入 **Phase 12**。

## 2 · 原冻结 commit

| 项 | 值 |
|---|---|
| §11 建节 | **`e31a6dc`** `fix: exclude completed phase blocks from PLAN budget` |
| B6 第 8 格指名 | **`bcddbc9`**（Phase 0 冻结）· 经 **A002** 对齐 |
| 本次修改前 | **`1b4dbc1`** `docs: define engine, correct portability claim` |

## 3 · ⛔ 为什么现在做

⚠️ ⛔ **本条不是 Q17（自动派单）。**⭐ 只做一件事：**让 workflow 调用 nonconstant 判据，判红时真的停。**

### ⭐ 两边各缺什么（⛔ 实测，非推断）

| | 有 | ⛔ 缺 |
|---|---|---|
| **spec-kit** | ⭐ 闸门能力：`shell` step，任何非 0 ⇒ `FAILED` | ⛔ **判据** —— 官方 workflow **78 行 · 0 个 shell step · 2 个人工 gate**（实测 `vendor/spec-kit/workflows/speckit/workflow.yml`） |
| **nonconstant** | ⭐ 十条判据 | ⛔ **时机** —— 靠手动敲，或 commit 时被动触发 |

### ⭐ 三条收益（⛔ Phase 12 须逐条确认或推翻）

| | 收益 | 实证依据 |
|---|---|---|
| a | ⭐ **判据需要固定触发点，否则退化成常量** | nonconstant 自己：一条判据 **08-17 退化，08-20 才发现，中间那条闸跑了 0 次** |
| b | ⭐ **pre-commit 只在提交那一刻检查**，而 agent 在**做任务的过程中**跑偏 ⇒ 等到 commit 已经晚了 | ⛔ workflow 能在**阶段之间**插闸 |
| c | ⭐ **127 那个洞（闸门缺失被当成跳过）只有编排层能验** | `LATCH-missing-gate-is-silent` · C6 |

### ⚠️ ⛔ 反面必须写清：**单用 nonconstant 完全可行**

⭐ 它**现在就在跑** —— `pre-commit` 已拦下**两次真实事故**（`status-facts` 判红、`doc-budget` 判红）。
⇒ ⭐⭐ **接 spec-kit 是增强，⛔ 不是必需。**⛔ Phase 12 不得把它写成前置条件。

## 4 · 新内容：`### Phase 12 · 接上 spec-kit 执行引擎`

**做**：`workflows/nonconstant/workflow.yml`，用 spec-kit **内建** `shell` step（⛔ 不写自定义 step），显式处理 **127**。

**⭐ 跑在哪**：**装了 nonconstant 的普通项目**（⛔ 不是 nonconstant 自己的仓）。
理由：Phase 8 的教训 —— `config-read.sh` 没被装过去，⛔ 而那在 nonconstant 自己的仓里**永远看不见**。
⚠️ 且 nonconstant 自己的仓有 `upstream-pin`（`scope: bootstrap`），⛔ 用户项目里根本没有这条 ⇒ 在自己仓里测等于测一个没人有的布局。

**验收（⛔ 必须真跑 `specify workflow run`，⛔ 不是读代码）**

| 档 | 期望 |
|---|---|
| 绿 | 全部判据绿 ⇒ CLI 退出码 **0** |
| 红 | 任一 hard 判红 ⇒ 退出码**非 0**，且**中止**（⛔ 不是「跑完了但标记失败」） |
| **127** | 删掉一个判据脚本 ⇒ **必须非 0**。⛔ 若当成「跳过」而返回 0 ⇒ **停下报告**（⭐ 那是真发现，⛔ 不是失败） |

**探针（⛔ 不扩充）**：soft 判红该停还是该过（须给理由）· workflow 里判据路径写错不得当成通过 · 兄弟交叉复跑。

**⭐ 收尾必答**：装了 nonconstant 的项目里，用户的日常动作是什么？`gates.sh` / `specify workflow run` / `pre-commit` 若并存，说清什么时候用哪个。⛔ 答不出来说明 nonconstant 还不能被用。

## 5 · 影响面

| # | 决定 | 出处 | 是否失效 |
|---|---|---|---|
| 1 | **B6 第 8 格**指名 `workflows/nonconstant/workflow.yml` | `CLAUDE.md` B6 | ⭐ **本 phase 正是兑现它** —— ⛔ 不动名额规则 |
| 2 | **B1** 根目录不得新增其它目录 | `CLAUDE.md` B1 | ⚠️ ⛔ **须注意**：`workflows/` 是**新的根目录**。⭐ 但 B6 表**早已指名** `workflows/nonconstant/workflow.yml` ⇒ 该目录是 Phase 0 就预期的，⛔ 非「新增其它目录」。⇒ ⚠️ B1 的表未列 `workflows/` ⇒ **表不完整**（与 A008 `known_gaps` #4 的 `README.md` 同形），⛔ 非违规 |
| 3 | `install.sh` 装哪些（`scope != bootstrap`） | `reports/phase8-*.md` | ⛔ **否** —— 本 phase ⛔ 不改安装器 |
| 4 | **Q17** 编排层的可自动化边界 | `01-PLAN.md` §6 | ⛔ **否** —— ⭐ 本 phase ⛔ 不做自动派单；Q17 保持未排期 |
| 5 | **C11** 编号 = 身份 | `18-PROTOCOL.md` | ⭐ 用**下一个未用编号 12**，⛔ 未重排 |
| 6 | `waiver-expiry` 用「已排最大 phase」 | `.nonconstant/waiver-expiry.sh` | ⚠️ `MAXP` 11 → 12，⭐ 方向是**放宽**，⛔ 不产生新的红 |

### ⇒ **重验要求：⛔ 无。**

**理由（第一性）**：本 amendment **只新增**一个 phase 块与一个早已指名的文件，⛔ 未改动任何既有编号、路径或契约条款 ⇒ ⛔ 没有任何已完成决定的输入发生变化。

## 6 · known_gaps

| # | 缺口 | 说明 |
|---|---|---|
| 1 | ⚠️ **`workflows/` 未列入 B1 路径表** | ⭐ B6 早已指名该文件，⛔ 但 B1 的目录表没有它。⇒ ⚠️ **表不完整**，与 A008 `known_gaps` #4 同形。⛔ 本轮不补（补 B1 是 amendment，⭐ 而它不阻塞 Phase 12） |
| 2 | ⛔ **workflow 装不进用户项目** | `workflows/nonconstant/workflow.yml` 在 nonconstant 仓里，⛔ 而 `install.sh` 不装它（⭐ 与 `.git/hooks/` 同类问题）。⇒ ⚠️ Phase 12 须在报告里说清用户怎么得到它 |
| 3 | ⚠️ **`specify` 必须已安装** | ⭐ 实测本机有 `specify`（`~/.local/bin/specify`）。⛔ 没装 spec-kit 的项目跑不了 workflow ⇒ ⭐ 那正是「接 spec-kit 是增强、⛔ 不是必需」的另一面 |
