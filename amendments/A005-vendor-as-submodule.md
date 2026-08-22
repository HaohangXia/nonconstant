# A005 · `vendor/spec-kit` 改为 git submodule

| 项 | 值 |
|---|---|
| 编号 | **A005** |
| 日期 | 2026-08-22 |
| 触发 | Phase 7 排期:「pin 不可核」—— ⛔ 磁盘那份无法被证明是 `bca6790` |
| 状态 | ⭐ 已采纳,应用于 `CLAUDE.md` B2 |
| B6 名额 | ⛔ **不新增**(`amendments/` 目录整体已占第 4 格) |

---

## 1 · 改哪条

`CLAUDE.md` **B2 · `vendor/spec-kit/` 的地位** 中「**`vendor/` 在 `.gitignore` 内(未跟踪)**」这一层。
⭐ **「只读」不变** —— ⛔ 仍不修改上游任何文件。

## 2 · 原冻结 commit

| 项 | 值 |
|---|---|
| B2 冻结于 | **`bcddbc9`** `docs: lock Phase 0 module boundaries` |
| 本次修改前 | `87bb97f` |

## 3 · ⛔ 为什么当初是错的

⭐ **latch 声称 pin 到 `v1.0.0` / `bca6790`,⛔ 而没有任何东西能证明磁盘那份就是它。**

⇒ 「pin」目前**是一句话,不是一个可核事实** —— 正是 D9 那种状态(承诺 ≠ 判据)。

⚠️ 三条可能的核验路径,**实测全部走不通**:

| 路 | 实测 |
|---|---|
| `git -C vendor/spec-kit rev-parse HEAD` | ⛔ **没有 `.git`** —— vendor 是解包的源码树 |
| 逐字比对 / 内容摘要 | ⛔ 只能证明「**自我们记录以来没变**」(TOFU),⛔ **不是「等于 `bca6790`」** |
| 树内自带 commit 标记 | ⛔ **不存在**。只有 `pyproject.toml: version = "1.0.0"` —— 那是**声明的版本**,⛔ 不是 commit |

⇒ ⭐⭐ **submodule 记的就是 commit 本身** —— ⛔ 不是版本声明、不是内容摘要,⭐ 是那个 commit 的**身份**。**这是唯一非代用品的解法。**

⚠️ ⛔ 「不把 vendor 纳入版本控制」这条禁令**未经查证**,且它排除了上述唯一解 —— 已记 `03-LEDGER.md` `LATCH-unverified-ban-forced-deadlock`。

## 4 · 新内容

⭐ `vendor/spec-kit` 由**解包源码树**改为 **git submodule**,pin 到 `bca679051abb80d6cf0cd909f2539a28a10eb7eb`。

| | 旧 | ⭐ 新 |
|---|---|---|
| 版本控制 | ⛔ `.gitignore: vendor/` | `.gitignore: vendor/*` + `!vendor/spec-kit` |
| 可核性 | ⛔ 无 | ⭐ `git -C vendor/spec-kit rev-parse HEAD` |
| 只读 | ⭐ 是 | ⭐ **不变** |

### 4.1 ⭐ 实测数字(⛔ 不估,量)

| 项 | 实测 |
|---|---|
| **a · 仓库净增量** | ⭐ **`.gitmodules` 107 字节 + 一个 gitlink 条目** —— 提交进版本库的全部负载。⚠️ scratch 仓实测 |
| a' · 本地 `.git/modules/` | ⚠️ 会多出 submodule 的历史副本(见 b) |
| **b · 完整克隆 spec-kit** | **17 MB**;`--depth 1` 浅克隆 **4.2 MB**(实测) |
| b' · 对照 | ⚠️ 用户**本来就需要** vendor 的 **15 MB / 639 个文件** 才能用 latch ⇒ ⭐ **边际成本约 2 MB** |
| **c · `.gitignore` 冲突** | ⭐ **真冲突,已实测**:`vendor/` 被 ignore 时 `git submodule add` **拒绝**(「The following paths are ignored」)。改成 `vendor/*` + `!vendor/spec-kit` 后**实测成功** |
| 附 · pin 可达性 | ⭐ `bca679051…` 在完整克隆里 `cat-file -t` ⇒ **commit**(实测)⇒ submodule 能 pin 到它 |

⇒ ⭐ **「仓库暴涨」量级差约五个数量级;「与只读参考矛盾」不成立。**

## 5 · 影响面

⭐ 查:**有没有决定依赖「vendor 不在版本控制」?**(⛔ 不是搜"提到过")

| # | 决定 | 出处 | 是否失效 |
|---|---|---|---|
| 1 | **Phase 0 判据 2** `[ "$(git status --porcelain -- '*.py' '*.sh' \| wc -l)" -eq 0 ]` ⇒ 0 | `reports/phase0-bcddbc9.md` | ⛔ **否 —— 已实测。**scratch 仓里往**脏 submodule** 塞 `.py` 后,`git status --porcelain -- '*.py' '*.sh'` **仍为空**(submodule 只以 ` M vendor/probe` 单条出现,pathspec 不匹配)⇒ 判据仍返回 **0** |
| 2 | Phase 0 `known_gaps` #1「B2 未改上游无可执行判据」 | 同上 | ⭐ **不失效,是被解决**(部分) |
| 3 | Phase 6 `known_gaps` #5「无法确认工作区那份就是 pin」 | `reports/phase6-33a1b16.md` | ⭐ **不失效,是被解决** |
| 4 | Phase 6 `upstream-semantics` 判据 | 同上 | ⛔ **否** —— 它读 `vendor/spec-kit/src`,submodule 化后**路径不变** |
| 5 | B6 计数口径 | `CLAUDE.md` | ⛔ **否** —— `.gitmodules` 是 git 元数据,⚠️ ⛔ 但见 `known_gaps` #1 |

### ⇒ **重验要求:⛔ 无。**

**理由(第一性):**⭐ A005 **只改「上游那份从哪来、能不能被证明」**,⛔ 不改上游内容、不改路径、不改任何判据的输入。唯一可能受影响的 Phase 0 判据 2 **已实测仍返回 0**,⛔ 不是推断。

## 6 · known_gaps

| # | 缺口 | 说明 |
|---|---|---|
| 1 | ⚠️ **`.gitmodules` 算不算 B6 的一个文件?** | 它是 git 元数据(107 字节),⛔ 不是 latch 的判据或配置。⭐ 本文判定**不计入** B6 —— 与 `.gitignore` 同类。⚠️ ⛔ 但 B6 的计数口径未写明「git 元数据不计入」⇒ 与 **Q12 / A002 `known_gaps` #2** 同族的口径缺口 |
| 2 | ⛔ **submodule 化本身不阻止有人改 vendor 内容** | 改了会让 submodule 变脏(` M vendor/spec-kit`),⚠️ **但 Phase 0 判据 2 看不见它**(§5 #1 实测)。⇒ ⭐ **「未改上游」仍需一条独立判据** —— 归 **Phase 7** |
| 3 | ⚠️ **克隆者必须 `--recurse-submodules`** | ⛔ 忘了就得到一个**空的 `vendor/spec-kit`** ⇒ 判据判 2(不是 0)⭐ 失效模式安全,⚠️ 但对 **Q13(Phase 8)安装形态**是必须回答的一环 |
| 4 | ⚠️ **上游升级时须重跑 `upstream-semantics` 并复查依赖桩清单** | 三个桩(`json5`/`readchar`/`pathspec`)是 Phase 6 的已知边界;⛔ 换 pin 后可能变 |
