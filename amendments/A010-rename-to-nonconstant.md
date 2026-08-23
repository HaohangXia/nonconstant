# A010 · 改名 nonconstant → nonconstant（§11 增设 Phase 13）

| 项 | 值 |
|---|---|
| 编号 | **A010** |
| 日期 | 2026-08-24 |
| 触发 | `LATCH-name-collision-blocks-release` —— 名字在**同领域**已被占，发布已停 |
| 状态 | ⭐ 已采纳 |
| B6 名额 | ⛔ **不新增** —— ⭐ 改名是**重命名**，⛔ 不是新增文件 |

---

## 1 · 改哪条

⛔ **不是改某一条契约** —— ⭐ 是改**项目标识本身**：`.nonconstant/` → `.nonconstant/` · `nonconstant.yml` → `nonconstant.yml` · 全部文档中的名字字样。
⇒ ⚠️ 影响 `CLAUDE.md` B1/B4/B6 的路径表述、`nonconstant.yml` 全部自引用、十条判据的实现。

## 2 · 原冻结 commit

| 项 | 值 |
|---|---|
| 名字首次出现 | **`bcddbc9`** `docs: lock Phase 0 module boundaries` |
| 撞名发现 | **`8394412`** `docs: record name collision — release blocked` |
| `recuse` 撤回 | **`156bb29`** `docs: record scan-top-result-only, retract recuse` |
| 本次修改前 | **`156bb29`** |

## 3 · ⛔ 为什么当初是错的

⭐ **`nonconstant` 是通用英文词，且在 AI-agent 领域已被占满。**实测（`LATCH-name-collision-blocks-release`）：

| | 冲突 |
|---|---|
| ⛔⛔ 同域 | `latchagent/latch`「Control layer for autonomous AI agents」· `runlatch.sh`「Mission Control for AI Coding Agents」（点名 Claude Code / Codex / OpenClaw） |
| ⛔ 注册表 | GitHub `latch` 被 `latchbio/latch` 占（174★）· PyPI `latch` v2.77.0（活跃）· npm `latch` 已注册 |

⇒ ⭐ 撞名分两种：①同名不同域可共存；⛔②**同名同域** —— 用户搜到的是别人，而**定位词也一样** ⇒ ⛔ 不是排名问题，是**身份问题**。**本例是 ②。**

### ⛔ `recuse` 也出局（⭐ 记在这里，因为它是本 amendment 的直接前史）

2026-08-23 定 `recuse`，⛔ 依据是搜索的**第一个**结果。全量扫描后发现 `mthamil107/Recuse`：
「cooperative **AI-access governance** … compliant LLM agents **recuse themselves**」+ arXiv 2606.06460 + IETF draft + PyPI `recuse-signal`。
⇒ ⛔⛔ **同名 + 同域 + 同一个语义 punch line。**见 `LATCH-scan-top-result-only`。

## 4 · 新内容：`nonconstant`

⭐ **来源**：`meta-gate` 那条规矩 —— 新判据加入前必须演示「一过一失败」，
⭐ 因为**一条对任何输入都返回同一结果的检查，不是检查，是常量**。

⭐ 它概括了**全部已实证**的判据失效方式：

| 失效方式 | 实证 |
|---|---|
| 永远判红 | 08-17 退化，08-20 才发现，中间那条闸**跑了 0 次** |
| 永远判绿 | `src/**` 恒不命中（`nonconstant.yml:7` 明文禁止） |
| 静默少查一整类 | `LATCH-pattern-miss-reports-pass` |
| 自遮蔽（认不出自己要保护的文件） | `LATCH-self-blinding` |

⇒ ⭐⭐ **全部可归为「它变成了常量」。**

⚠️ **拼写不带连字符**：① 技术写作标准（*nonconstant function*）；② CLI 基础命令不带连字符（`git`/`docker`/`npm`/`cargo`）；③ ⭐ 短形式 `nonconst` **只在不带连字符时成立**（⛔ `non-const` 会被读成 C++ 的 `const`）。
⚠️ ⛔ **代价不掩饰**：`nonconstant` 与 `nonconst` 在 PyPI/npm 是不同名字，有人会打错。⛔ 不占第二个坑。

### ⭐ 复核（⛔ 执行方独立复跑，⛔ 非采信下达方）

PyPI **404** · npm **404** · ⛔ **无精确同名仓** · GitHub 全量 **5** 个结果逐条读描述（疲劳寿命 5★ · 光学仿真 1★ · LCL 分类器 0★ · **HMAC 计时攻击 PoC 2★** · **二维 BVP 有限差分 0★**）⇒ ⛔ **无一同域** · 网络搜索无同名产品。
⚠️ 后两个是**下达方清单里没有的** —— ⭐ 全量扫描才看得到，正是 `LATCH-scan-top-result-only` 要防的。

## 5 · 新增 `### Phase 13 · 改名`

**⭐ 关键在「原子」**：路径与引用**同一次改动内**一起改 ⇒ 判据看到的是**自洽状态** ⇒ 十条全绿 ⇒ hook 放行。
⇒ ⭐⭐ **不需要绕过 hook** —— hook 判的是「**提交后的状态**是否自洽」，⛔ 不是「你改了多少东西」。

⚠️ ⛔ `protected` 清单自己也要改 ⇒ `criteria-guard` **必判红** ⇒ ⭐ 由 `pre_commit: advisory` 那档接住（**F5**：自律机制须把「修正自身」排除在自己的执行之外）。
⇒ ⭐⭐ **上一轮那个 advisory 偏离，恰好是改名的前提条件。**

**验收（⛔ 三件缺一不可）**：① 十条判据复跑全绿；② ⭐ **复跑 README 的 demo 命令序列**（⛔ 只跑判据不够 —— `.nonconstant/` 出现在 demo 里）；③ **装进全新空仓再跑一遍**（⚠️ Phase 8 教训：`config-read.sh` 没被装过去，在自己仓里永远看不见）。

⛔ **11 份完成报告不改历史** —— ⭐ 只加订正注记：报告绑的 commit 里路径**本来就是旧名**，那是**事实**，⛔ 改了反而伪造。

## 6 · 影响面

| # | 决定 | 是否失效 |
|---|---|---|
| 1 | 11 份报告记录的 `.nonconstant/` 路径 | ⚠️ **措辞过期，⛔ 事实不变** —— ⭐ 加注记，⛔ 不改历史 |
| 2 | **C11** 编号 = 身份 | ⭐ 用**下一个未用编号 13**，⛔ 未重排 |
| 3 | `criteria-guard` 的 `protected` 清单 | ⭐ 随改；⛔ 改动本身判红 ⇒ 由 F5 那档接住 |
| 4 | `install.sh` 生成的用户侧配置 | ⭐ 随改（它读 `nonconstant.yml` 的路径） |
| 5 | `.git/hooks/pre-commit` 的 shim | ⚠️ **须同步** —— ⛔ 它写死了 `.nonconstant/pre-commit.sh` |
| 6 | `workflows/nonconstant/workflow.yml` | ⭐ 随改（路径 + 目录名） |
| 7 | `vendor/spec-kit` | ⛔ **不动** |

### ⇒ **重验要求：⭐ 有 —— 三件验收（§5）。**

**理由（第一性）**：改名动的是**每一条判据的输入路径** ⇒ ⛔ 与 A007/A008/A009 那种「只新增、不改既有输入」不同 ⇒ **必须全量重验**。

## 7 · known_gaps

| # | 缺口 | 说明 |
|---|---|---|
| 1 | ⚠️ **`nonconstant` 与 `nonconst` 是两个名字** | ⛔ 不占第二个坑 ⇒ 打错的人会 404。⭐ 接受 |
| 2 | ⚠️ **git 历史里旧名永远在** | ⭐ 那是事实，⛔ 不改写历史 |
| 3 | ⚠️ **11 份报告只加注记** | ⛔ 报告正文仍写 `.nonconstant/` ⇒ ⭐ 读者须看注记才知道 |
