# 改名候选与查重扫描（2026-08-23）

> ⭐ **起因**：`LATCH-name-collision-blocks-release` —— 名字在**同领域**已被占，发布已停。
> ⛔ **本文只做「查重与排序」，⛔ 未开始任何替换。**定名之前一个字不改。
> ⚠️ 上限 60 行（`latch.yml:doc_budgets`）。

## ⭐ 选名方向：⛔ 离开「闸门/控制」语义场

⚠️ ⛔ 撞车正是发生在那里：`gate` · `latch` · `control layer` · `mission control` 全被占。

⇒ ⭐ latch 的独特之处**不是**「有闸门」，⭐ 是 **判定者不能是被判定者**（T1）。
⇒ ⇒ 候选取自**司法回避 / 独立鉴定**语义场。

## 查重表（⛔ 逐项实测；⚠️ 判别：①同名不同域可共存 · ⛔②同名同域 ⇒ 淘汰）

| 候选 | 含义 | PyPI | npm | GitHub 同名仓 | 同域? | 判定 |
|---|---|---|---|---|---|---|
| ~~recuse~~ | 法官须回避自己是当事人的案子 | 404 | 404 | ⛔⛔ **`mthamil107/Recuse`** —— 「cooperative **AI-access governance**；compliant LLM agents **recuse themselves**」· Apache-2.0 · arXiv 2606.06460 · IETF draft · PyPI `recuse-signal` | ⛔⛔ **是** | ⛔ **淘汰(2026-08-24)** |
| ⭐⭐ **nonconstant** | **「不是常量」** —— 来自 `meta-gate`：⭐ **一条对任何输入都返回同一结果的检查，不是检查，是常量** | ⭐ 404 | ⭐ 404 | ⭐ **无精确同名仓**；5 个含该词的仓全为学术/物理（疲劳寿命 5★ · 光学仿真 1★ · LCL 分类器 0★ · HMAC 计时攻击 PoC 2★ · 二维 BVP 有限差分 0★） | ⭐⭐ **否** | ⭐⭐⭐ **采用** |
| **corroborant** | 波普尔：经受住检验而未被证伪的 | ⭐ 404 | ⭐ 404 | ⭐ 无 | ⭐ 否 | ⭐⭐ **存活** |
| **causasua** | *nemo iudex in causa sua*（无人可当自己案子的法官） | ⭐ 404 | ⭐ 404 | ⭐ 无 | ⭐ 否 | ⭐⭐ **存活** |
| **voirdire** | 庭前问询：查证陪审员是否**能公正**、证据是否可采 | ⭐ 404 | ⭐ 404 | 0★ `philfw/voirdire` | ⭐ 否 | ⭐ 存活 |
| **disinterest** | 法律义：**与本案无利害关系**（⛔ 非「不感兴趣」） | ⭐ 404 | ⭐ 404 | 1★ `stkterry/disinterest` | ⭐ 否 | ⭐ 存活 |
| **nemojudex** | 同 causasua，另一种拼法 | ⭐ 404 | ⭐ 404 | 0★ `Faruk2887/nemojudex` | ⭐ 否 | ⭐ 存活 |

⛔ **已淘汰(注册表被占或同域)**:`invigil` · `crossexam` · `hallmark` · `touchstone` · `assay` · `arbiter` · `iudex` · `deposition`。

⛔⛔ **`invigil` 是最险的一条**：PyPI 简介写着「Linters check your code. **Invigil checks whether your…**」—— ⭐ 那正是 latch 的位置。⚠️ ⛔ 若只查「仓名是否被占」而不看**它做什么**，这条会被判成「1★，可用」。

## ⭐ 我的排序

| # | 候选 | ⭐ 支持 | ⚠️ 反对 |
|---|---|---|---|
| **1** | **recuse** | ⭐⭐ **一个词说完 T1**：法官对自己的案子必须回避。⭐ 短（6 字母）、好读、命令行顺手（`recuse check`）。⭐ 四处全清 | ⚠️ 英文母语者会先想到「回避」而非「验证」 ⇒ ⛔ 需一句话定位撑住 |
| **2** | **voirdire** | ⭐ 语义最准：**开庭前查证「这个证据可不可采」**，正是判据在做的事。⭐ 独特，⛔ 几乎不可能重名 | ⚠️ 非法律圈不会念（vwahr-DEER）⇒ ⛔ 口口相传成本高 |
| **3** | **causasua** | ⭐ 直接引法谚，⭐ 唯一「零同名仓」的候选 | ⚠️ 拉丁文，⛔ 不可读、不可拼 |
| 4~6 | corroborant · disinterest · nemojudex | 语义各有准处 | ⛔ 太长 / ⛔⛔ 日常义反向误导 |

⇒ ⛔⛔ **`recuse` 已于 2026-08-24 撤回** —— 上表的判定基于**搜索的第一个结果**，⛔ 全量扫描后发现同域项目。
见 `03-LEDGER.md` 的 `LATCH-scan-top-result-only`。⚠️ ⭐ 本文原排序**不删**，作为「错在哪」的记录。

## ⭐⭐ 定名：`nonconstant`（2026-08-24）

⭐ **来源**：`meta-gate` 那条规矩 —— 新判据加入前必须演示「一过一失败」，
⭐ 因为**一条对任何输入都返回同一结果的检查，不是检查，是常量**。

⭐ 它概括了**全部已实证**的判据失效方式：永远判红（08-17 起，三天无人知）· 永远判绿 ·
静默少查一整类（`LATCH-pattern-miss-reports-pass`）· 自遮蔽（认不出自己要保护的文件，`LATCH-self-blinding`）
⇒ ⭐⭐ **全部可归为「它变成了常量」。**

⚠️ **拼写：不带连字符。**理由：① 技术写作标准（*nonconstant function*）；
② CLI 基础命令不带连字符（`git` / `docker` / `npm` / `cargo`）；
③ ⭐ 短形式 `nonconst` **只在不带连字符时成立** —— ⛔ `non-const` 会被读成 C++ 的 `const`。
⚠️ ⛔ **代价不掩饰**：`nonconstant` 与 `nonconst` 在 PyPI/npm 是**不同名字**，有人会打错。⛔ 不占第二个坑。

⭐ **复核（2026-08-24，⛔ 执行方独立复跑，⛔ 非采信下达方）**：PyPI 404 · npm 404 · ⛔ 无精确同名仓 ·
GitHub 全量 5 个结果逐条读描述，⛔ 无一同域 · 网络搜索无同名产品。

## ⛔ 待你与用户定，⛔ 我不自行开始替换。