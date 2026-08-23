# A006 · 可分发性做成判据的一个字段

| 项 | 值 |
|---|---|
| 编号 | **A006** |
| 日期 | 2026-08-22 |
| 触发 | Phase 8 前置:`upstream-pin` 在用户项目里**恒返回 2** ⇒ §10 Phase 8 的绿检「九条判据全部可调用」**不可满足** |
| 状态 | ⭐ 已采纳。⛔ **本轮不实现**(实现属 Phase 8) |
| B6 名额 | ⛔ **不新增**(`amendments/` 目录整体已占第 4 格) |

---

## 1 · 改哪条

`01-PLAN.md` **§10 Phase 8 的绿检**:「装进一个空的临时仓后,**九条判据全部可被调用且返回预期退出码**」。

## 2 · 原冻结 commit

| 项 | 值 |
|---|---|
| Phase 8 验收定于 | **`18f6f2c`** `docs: reorder §10 — upstream-semantics to Phase 6, tighten Q13 acceptance` |
| 本次修改前 | `3afcfd5` |

## 3 · ⛔ 为什么当初是错的

⭐ **§10 的验收把两类判据混为一谈了。**

| 类 | 判什么 | 在用户项目里 |
|---|---|---|
| ⭐ 判 **nonconstant 自己产物** | 判据文件 · 报告 · STATUS · 文档预算 · 豁免账期 | 装上就能跑 |
| ⛔ 判 **nonconstant 与上游的关系** | 上游语义 · 上游 pin | 依赖用户环境 |

**实测(⛔ 不是推测):**

- spec-kit 是**当 CLI 工具装**的(`uv tool install specify-cli`;`[project.scripts] specify = "specify_cli:main"`),`specify init` **脚手架**用户项目 ⇒ ⛔ **它不 vendor 进用户项目**。
- ⇒ 用户那份**没有 `.git`、没有 commit**,只有 `version = "1.0.0"`。
- ⇒ ⛔ **`upstream-pin` 在用户项目里恒返回 2** —— ⭐ **一个恒返回同值的判据就是常量**(违反 §3 序 4)。

⚠️ ⛔ **而「哪些判据可分发」若靠人记,又是一条无判据的规则**(`LATCH-protocol-has-no-teeth`)。

## 4 · 新内容

⭐ **每条判据显式声明 `scope` 字段**,⛔ 不是「排除两条」。

| 取值 | 含义 | 可分发 |
|---|---|---|
| `project` | 判**被装项目自己的产物** —— 路径可配,结构上不依赖 nonconstant 仓布局 | ⭐ 是 |
| `upstream` | 判**上游** —— ⭐ 指向用户实际会跑的那份 spec-kit | ⭐ 是(⚠️ 需用户已装 spec-kit) |
| `bootstrap` | ⛔ **仅 nonconstant 自举** —— 结构上依赖 nonconstant 仓自己的 submodule | ⛔ 否 |

⇒ **可分发 ≡ `scope != bootstrap`**。

### 4.1 三条硬要求

1. ⭐ **`meta-gate` 须查「每条判据都声明了 `scope`,且取值合法」** —— ⛔ 缺失或非法 ⇒ **判红**。
2. ⭐ Phase 8 绿检改为:**所有 `scope != bootstrap` 的判据全部可调用且返回预期退出码**。
   ⛔ **不写死条数** —— ⚠️ 写死会在加判据时过期(= `LATCH-renumber-breaks-reference` 同形)。
3. ⭐ **安装脚本据此决定装哪些**,⛔ 不靠人挑。

### 4.2 现有九条的归类

| 判据 | scope | 理由 |
|---|---|---|
| `criteria-guard` · `silent-scan` · `meta-gate` · `report-pin` · `status-facts` · `waiver-expiry` · `doc-budget` | `project` | 判的全是被装项目自己的产物,路径均可配 |
| `upstream-semantics` | **`upstream`** | 见 §4.3 |
| `upstream-pin` | **`bootstrap`** | ⛔ 结构上需要一个 **submodule**;用户那份是 tool 安装,⛔ 没有 commit 可比 |

### 4.3 ⭐ `upstream-semantics` 归 `upstream`(可分发)的理由

1. **参数化** —— 它接受源码目录参数 ⇒ 指向用户装好的 `specify_cli` 即可,⛔ 结构上不绑 nonconstant 仓。
2. ⭐ **在用户侧更对** —— 它验的是「**用户实际会跑的那份**」,⛔ 而不是某个 vendored 副本。
3. ⭐⭐ **已实地验证**(⛔ 不是推断):本轮装了 `specify-cli`(pin 到同一个 `bca6790`),对**真实安装**跑 ⇒ **`0`**。
4. ⚠️ ⛔ **若因「当前环境演示不了」而标 `bootstrap`,那是把「环境缺口」藏进「作用域标签」** —— 代用品。⇒ ⛔ 不做。

## 5 · 影响面

⭐ 查:**有没有决定依赖「九条判据全部可分发」?**

| # | 决定 | 出处 | 是否失效 |
|---|---|---|---|
| 1 | **§10 Phase 8 绿检「九条判据」** | `01-PLAN.md` §10 | ⭐ **正是本文所改** |
| 2 | `STATUS.md`「9 条判据」 | `docs/audit/STATUS.md` | ⛔ **否** —— 那是**存在数**,⛔ 不是可分发数 |
| 3 | `meta-gate` 现有检查项 | `.nonconstant/meta-gate.sh` | ⛔ **否** —— A006 **新增**一项检查,⛔ 不改已有项 |
| 4 | Phase 7 的 `upstream-pin` 判据 | `reports/phase7-4dddca8.md` | ⛔ **否** —— 它在 nonconstant 仓内照常工作;A006 只是**声明它不分发** |
| 5 | Phase 6 的 `upstream-semantics` 判据 | `reports/phase6-33a1b16.md` | ⛔ **否**,⭐ **且被加强** —— 见 `known_gaps` #2 |

### ⇒ **重验要求:⛔ 无。**

**理由(第一性):**⭐ A006 **只增加一个声明字段并改一条尚未执行的验收**,⛔ 不改任何已通过判据的逻辑或输入。Phase 8 **尚未开工** ⇒ 没有已完成决定依赖那条验收。

## 6 · known_gaps

| # | 缺口 | 说明 |
|---|---|---|
| 1 | ⛔⛔ **本轮只记不实现** | `nonconstant.yml` 尚未写 `scope` 字段,`meta-gate` 尚未查它,§10 Phase 8 的绿检**仍写着「九条」** ⇒ ⚠️ **口径暂不一致**(与 **A003** `known_gaps` #1 同形)。⇒ **Phase 8 开工第一件事:落 `scope` 字段 + 改 §10** |
| 2 | ⭐ **Phase 6 的「三个依赖桩」不确定性在真实环境中消失** | 本轮实测:对 `uv tool` 安装跑 `upstream-semantics`,**注入的桩为「(无)」** —— 真实安装自带 `json5`/`readchar`/`pathspec`。⇒ ⭐ **那个不确定性是 vendored 源码树的产物,⛔ 不是判据的缺陷**。⚠️ ⛔ 但 Phase 6 报告 `known_gaps` #2 的措辞据此**过宽**,须在 Phase 8 订正 |
| 3 | ⚠️ **`scope: project` 的判据仍有 nonconstant 专用默认路径** | 如 `waiver-expiry` 默认读 `docs/audit/01-PLAN.md` 取 phase 编号、`status-facts` 默认读 `docs/audit/STATUS.md`。⭐ 均**可传参**,⛔ 但**默认值**是 nonconstant 自己的布局 ⇒ 安装时须一并配置 |
| 4 | ⚠️ **`scope` 的取值正确性判不了** | `meta-gate` 只能查「声明了且取值合法」,⛔ **查不了「归类对不对」**(把 `bootstrap` 写成 `project` 照样过)⇒ **D5**,与 `LATCH-criteria-cannot-test-reasoning` 同族 |
| 5 | ⚠️ **新引入一个不在版本控制里的依赖** | 本轮装了 `specify-cli`(`uv tool`,pin 到 `bca6790`)。⭐ 与 nonconstant 已有的 `python` / `git` / `bash` 同类(Phase 6 `known_gaps` #6 已记),⛔ 但数量又多一个 |
