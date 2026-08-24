# A011 · 发布（§11 增设 Phase 14）

| 项 | 值 |
|---|---|
| 编号 | **A011** |
| 日期 | 2026-08-24 |
| 触发 | ⭐ Phase 13 改名完成 ⇒ **唯一的发布阻塞项已消除** |
| 状态 | ⭐ 已采纳 |
| B6 名额 | ⚠️ **动用 A003 预算外余量** —— `LICENSE`（⭐ 属①「修正自身的产物」：发布所必需的法律文件） |

---

## 1 · 改哪条

`docs/audit/01-PLAN.md` **§11** —— ⭐ 在 `Phase 9+` 之前插入 **Phase 14 · 发布**。

## 2 · 原冻结 commit

| 项 | 值 |
|---|---|
| 发布阻塞记录 | **`8394412`** `docs: record name collision — release blocked` |
| 改名完成 | **`8196615`** `refactor: rename latch → nonconstant` |
| 本次修改前 | **`c677aa8`** `docs: record global-replace-cannot-distinguish-ownership` |

## 3 · ⛔ 为什么现在做

⭐ **阻塞项只有一个，且已消除。**盘点（⛔ 逐条可核）：

| | 状态 |
|---|---|
| 十条判据 | ⭐ 全绿 |
| 可安装 | ⭐ `install.sh`，空仓实测通过 |
| 13 个 phase 报告 | ⭐ 各绑 commit，`report-pin` ⇒ 0 |
| README + demo | ⭐ demo 七步实测通过，`readme-runnable` ⇒ 0 |
| RETROSPECTIVE | ⭐ 160 行，⛔ 含四条差异化被自己证伪 |
| 名字 | ⭐ **`nonconstant`**，四处注册表全清，⛔ 无同域 |
| ⛔ **缺** | LICENSE · 归属声明 · 版本标签 |

## 4 · 新增 `### Phase 14 · 发布`

### ① LICENSE：**MIT**

⭐ 与上游 spec-kit 一致（它也是 MIT）。

### ② 归属章节 —— ⭐ 用**锚点**，⛔ 不绑措辞（沿用 P11-C3）

⚠️ ⛔ **四条一条不许少**：

| 归属对象 | 必须写清 |
|---|---|
| **spec-kit** | MIT；`vendor/` 是 submodule pin `bca6790`；⛔ **nonconstant 不含它的代码** |
| **DevLoop（v1）** | ⭐ 本项目的原则**指向它的具体事故**作为实证（判据 08-17 退化 · 86 GB）；⛔ **不 import 一行**（D-05） |
| **Loop Engineering（Addy Osmani）** | ⭐⭐ 定位句「**LE 是油门的工程学，这是刹车和仪表的工程学**」直接建在其框架上；**Maker/Checker 拆分来自 LE**；⭐ 本项目针对的**三个缺口**（验证责任 / comprehension debt / cognitive surrender）**是他自己列出的** |
| **同域项目** | ⭐ axiom · groundtruth · nah · Mantiz 等；⚠️ ⛔ **明写「如果你要一个成熟的工具，去看它们」**（RETROSPECTIVE 第五节已有，README 也要有） |

⛔⛔ **这些外部名字，任何脚本一个字不许改** —— ⚠️ 本项目刚踩过（`LATCH-global-replace-cannot-distinguish-ownership`）。

### ③ v1 标签 + 简短发布说明

⭐ **一段话即可**，⛔ 不是 CHANGELOG。

### ④ 推送 —— ⛔ **由用户执行，模型不代劳**

⭐ 但须把要敲的命令**逐条列出**。

## 5 · 推送前最后一遍（⛔ 缺一不可）

| # | 检 | ⛔ 不过则停 |
|---|---|---|
| 1 | 十条判据全绿 | ✔ |
| 2 | demo 在**全新空仓**跑通 | ✔ |
| 3 | `readme-runnable` ⇒ **0** | ✔ |
| 4 | ⚠️ clone 后 **submodule 未取回**的路径在 README 说清（⭐ Phase 8 实测：8 条 0、两条判 **2**、消息可行动） | ✔ |
| 5 | ⭐ **全仓 grep：残留 `latch` 字样按指涉分类** —— ⛔ 保留：`LATCH-` 条目 ID / 报告注记里的历史路径 / 外部项目名 / 自述改名；⛔ **本项目自称须已全改** | ✔ |

## 6 · 影响面

| # | 决定 | 是否失效 |
|---|---|---|
| 1 | **B1** 根目录路径表 | ⚠️ `LICENSE` 是新的根文件 —— ⭐ B1 只禁「新增**目录**」；⚠️ 表未列它 ⇒ **表不完整**（与 A008 #4 · A009 #1 同形），⛔ 非违规 |
| 2 | **B6** 名额 8/8 已满 | ⚠️ `LICENSE` 走 **A003 余量**，⭐ 登记在 Phase 14 报告 `known_gaps` |
| 3 | `readme-runnable` 的三个披露锚点 | ⭐ **不动** —— 归属是**第四个**锚点，⛔ 与它们并列不覆盖 |
| 4 | **C11** 编号 = 身份 | ⭐ 用**下一个未用编号 14**，⛔ 未重排 |
| 5 | `waiver-expiry` 的 `MAXP` | ⚠️ 13 → 14，⭐ 放宽，⛔ 不产生新的红 |

### ⇒ **重验要求：⭐ 有 —— §5 五项。**

**理由（第一性）**：发布是**不可逆**的对外动作 ⇒ ⛔ 与内部 phase 不同，发出去之后修的成本高一个量级（`LATCH-name-collision-blocks-release` 的教训）。

## 7 · known_gaps

| # | 缺口 | 说明 |
|---|---|---|
| 1 | ⚠️ **`.claude/` 三个文件名仍是 `latch-*`** | ⭐ **刻意保留** —— 它们不是产品，是用户敲命令的入口；改文件名 = 改 `/latch-audit` 这个命令 = 改用户的肌肉记忆。⭐ 内容已随改。⇒ ⭐⭐ **一个刻意保留的不一致，写下来就不是遗漏** |
| 2 | ⛔ **推送后仓名、任何 clone、任何引用都要改** | ⇒ ⭐ 所以 §5 五项必须全过再推 |
| 3 | ⚠️ **未验 Linux/macOS** | ⛔ 全部实测在 Windows + Git Bash |
