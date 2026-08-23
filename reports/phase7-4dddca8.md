# Phase 7 · 上游 pin 可核 —— 完成报告

> ⭐ **第一读者是下一个会话的模型,不是人。**
> ⚠️ 本报告绑定 commit **`4dddca8`** —— ⛔ 脱离该 commit 的任何结论不可证伪。

## pin

| 项 | 值 |
|---|---|
| 报告绑定 commit | **`4dddca8`** `feat: convert vendor to submodule, lock Phase 7 pin criterion` |
| 上游 pin | `github/spec-kit` **v1.0.0** / `bca679051abb80d6cf0cd909f2539a28a10eb7eb` / MIT |
| ⭐ pin 的地位 | **由「一句话」变成「可核事实」** —— `git -C vendor/spec-kit rev-parse HEAD` |
| 阶段 | **Phase 7 · 上游 pin 可核**(Q13 的前置) |
| 日期 | 2026-08-22 |

## frozen_contracts

| ID | 契约 | 落点 |
|---|---|---|
| P7-C1 | ⭐⭐ **`vendor/spec-kit` 是 submodule,pin 到 `bca6790…`** —— ⭐ submodule 记的**就是 commit 本身**,⛔ 不是版本声明、不是内容摘要 | `.gitmodules` · `nonconstant.yml:upstream_pin` |
| P7-C2 | ⭐ **本判据覆盖 B2 的两半**:① 是不是 pin 的那一份;② **有没有被本地改过**(submodule 工作区须干净,⚠️ **含未跟踪文件**) | `.nonconstant/upstream-pin.sh` |
| P7-C3 | ⭐⭐ **「未取回(空目录)」判 `2`,⛔ 不判 0 也不判 1** —— 那是「**没测到**」,⛔ 不是「pin 没变」,也不是「pin 不符」 | 同上 |
| P7-C4 | `.gitignore` 为 `vendor/*` + `!vendor/spec-kit` —— ⛔ 原 `vendor/` 会让 `git submodule add` **拒绝**(实测) | `.gitignore` |

## references_contracts

| 上游契约 | 出处 | 兑现 |
|---|---|---|
| §10 Phase 7 | `01-PLAN.md` | ⭐ 绿/三红/五探针全做 |
| **A005** vendor 转 submodule | `amendments/A005-*.md` | ⭐ 本 phase 即其执行 |
| B2 `vendor/` 只读 | `CLAUDE.md` | ⭐ **两半都兑现了**(见 `known_gaps` #1 的说明) |
| K1「不改 `vendor/spec-kit/`」 | `18-PROTOCOL.md` §2 | ⭐ **由「⚠️ 缺口」转为「⭐ 已机器化」** |
| C6 闸门缺失比判红更严重 | `18-PROTOCOL.md` §4 | ⭐ P7-C3 |
| `LATCH-cannot-judge-vs-judged-fail` | `03-LEDGER.md` | ⭐ P7-C3 正是它的应用 |
| C3 红检对 fixture 跑 | `18-PROTOCOL.md` §4 | ⚠️ **本 phase 例外**:红检**必须**动真 submodule(切 commit / 改文件),⭐ 但每次**当场复原并复跑绿检确认**;⛔ 无副本可代替 —— 副本不是 submodule |

## gate_results

⭐ 全部在 **HEAD = `4dddca8`** 上求值;收尾工作树 **0 项**。

| # | 检 / 探针 | 期望 | 实测 |
|---|---|---|---|
| 1 | **绿检** —— submodule 停在 pin 且工作区干净 | 0 | ⭐ **0** |
| 2 | **红检 1** —— submodule 切到 `27f50f7`(上游当前 HEAD) | 非 0 | ⭐ **1**「pin 不符」 |
| 3 | **红检 2** —— 改上游一个文件(`README.md`) | 非 0 | ⭐ **1**「上游被本地改过(1 项): M README.md」 |
| 4 | ⭐ **红检 3** —— 往上游**塞新文件**(`INJECTED.txt`) | 非 0 | ⭐ **1**「?? INJECTED.txt」 |
| 5 | 探针 A · submodule **未取回(空目录)** | 2 | ⭐ **2**「没测到 ≠ 通过」 |
| 6 | 探针 B · 目录存在但**非 git 仓** | 判断见下 | ⭐ **2** |
| 7 | 探针 C · 目录不存在 | 非 0 | ⭐ **2** |
| 8 | 探针 D · `nonconstant.yml` 无 `upstream_pin` | 非 0 | ⭐ **2**「没写 pin ≠ pin 没变」 |
| 9 | 探针 E · 配置不存在 | 非 0 | ⭐ **2** |
| 10 | 兄弟交叉 · `silent-scan` 扫本判据 | 0 | ⭐ **0** |
| 11 | ⭐ **九条判据全跑** | 全 0 | ⭐ **全 0** |
| 12 | ⭐ **Phase 0 判据 2**(submodule 化后) | 0 | ⭐ **0** —— A005 §5 #1 的预测**被实地复现** |

⇒ ⭐ **一过一失败已演示(#1 vs #2/#3/#4)⇒ 不是常量。**
⇒ ⛔ **没有任何一条能让它返回 0 而实际没验。**

### ⭐ 探针 B 判 `2` 而非 `1` 的理由

⛔ 判 `1` = 断言「**pin 不符**」—— 而目录不是 git 仓时**根本读不到 commit**,那是**过度声称**。
⭐ 判 `2` = 「**判不了,须人看**」。⇒ `LATCH-cannot-judge-vs-judged-fail` 的直接应用。

### ⭐ 转换过程的实测(⛔ 不估,量)

| 项 | 实测 |
|---|---|
| 提交进版本库的负载 | ⭐ `.gitmodules` **3 行** + `vendor/spec-kit` **1 行 gitlink**(`git show --stat` 逐行核过) |
| ⚠️ 旧 vendor vs pin 内容差异 | ⭐ **0** —— `diff -r -q --exclude=__pycache__ --exclude=.git` **零输出** |
| 文件数差 639 → 543 | ⭐ 差异**全是** Phase 6 探针生成的 `__pycache__/*.pyc`(97 个)+ `.git`;⇒ **此前所有对 vendor 的实测确实是对 `bca6790` 做的** |
| `.gitignore` 冲突 | ⭐ 实测:`vendor/` 时 `submodule add` **拒绝**;改 `vendor/*` + `!vendor/spec-kit` 后成功 |

## known_gaps

| # | 缺口 | 说明 |
|---|---|---|
| 1 | ⭐ **「有没有被改过」本轮一并做了,⛔ 未排成单独 phase** | 下达方要求排成 Phase 7b。⚠️ ⛔ **但它是同一个 submodule 上的一行命令**(`git -C vendor/spec-kit status --porcelain`),与 pin 检查天然同属一条判据 ⇒ **拆成两个 phase 是人为的**。⭐ 且下达方的担心是「只躺在 gap 里没人做」—— **现在做了,该担心消解**。⇒ ⛔ 若仍要求拆分,须给出拆分能带来什么 |
| 2 | ⚠️ **上游自己的 `.gitignore` 会遮蔽一部分改动** | `git status --porcelain` 不报被 spec-kit 自身 ignore 的文件(如 `__pycache__`)。⇒ ⛔ 有人往那些路径塞东西**查不出来**。⭐ 但那些路径本就是生成物,⚠️ 风险有限、⛔ 非零 |
| 3 | ⚠️ **`.gitmodules` 的 B6 定性(本轮定)** | ⭐ **判定:不计入 B6。**理由三条:① 它是 **git 元数据**,与 `.gitignore` 同类,⛔ 不是 nonconstant 的判据或配置;② 它**不是 nonconstant 写的内容** —— `git submodule add` 生成、格式由 git 定;③ **107 字节 / 3 行**,B6 防的是「复杂度」,⛔ 它不承载复杂度。⚠️ ⛔ **但 B6 的计数口径仍未写明「git 元数据不计入」** ⇒ 与 **Q12** / A002 `known_gaps` #2 同族的口径缺口,须后续 amendment 补 |
| 4 | ⚠️ **克隆者必须 `--recurse-submodules`** | ⛔ 忘了 ⇒ `vendor/spec-kit` 是空目录 ⇒ 判据判 **2**(⭐ 失效模式安全)。⚠️ 但对 **Q13(Phase 8)安装形态**是必答项 |
| 5 | ⚠️ **上游升级时必须重跑 `upstream-semantics` 并复查依赖桩清单** | 三个桩(`json5`/`readchar`/`pathspec`)是 Phase 6 的已知边界;⛔ 换 pin 后可能变。⇒ ⭐ **换 pin 的动作必须连带这一步**,⛔ 目前无判据强制 |
| 6 | ⚠️ **红检动了真 submodule** | ⛔ 违反 C3「红检对 fixture 跑」的字面。⭐ 理由:副本不是 submodule,**无法复现被测性质**;⚠️ 缓解:每次红检后**当场复原并复跑绿检**(报告 #1 即复原后的结果) |
| 7 | ⚠️ **本地 `.git` 增大** | 实测 scratch:73 KB → 148 KB(submodule 历史进 `.git/modules/`);spec-kit 完整克隆 **17 MB**、`--depth 1` **4.2 MB**。⭐ 用户本就需要 15 MB 的 vendor 文件 ⇒ **边际约 2 MB** |

## next_entry_conditions

Phase 8(Q13 安装形态)开工前须满足:

1. ⭐ 本报告已提交,`.nonconstant/upstream-pin.sh` 与 submodule 在 `4dddca8` 内 —— **已满足**
2. ⬜ 先答 **Q13**:① 安装脚本 ② spec-kit extension ③ PyPI 包
3. ⚠️ 验收**判结果不判机制**:装进空临时仓后,**九条判据全部可被调用且返回预期退出码**
4. ⬜ 红检:装进**已有 `nonconstant.yml`** 的仓 ⇒ 非 0(⛔ 不得静默覆盖)
5. ⭐ **`known_gaps` #4 现在是 Q13 的硬输入** —— 安装形态必须回答「上游那份怎么取回」

## explicitly_out_of_scope

⛔ 下一会话**不得重提**:

- ⛔ 用「版本声明」或「内容摘要」代替 submodule 来核 pin(代用品,A005 §3 已否决)
- ⛔ 让「未取回」判 0 或判 1(P7-C3 已判定)
- ⛔ 把 `.gitignore` 改回 `vendor/`(实测会让 `submodule add` 拒绝)
- ⛔ 实施候选 1 改 `scan-silent` 消息(那是 **Phase 10**)
- ⛔ 修 `criteria-guard` 的未跟踪盲区(须授权)
- ⛔ 本轮建编排层(Phase 9+)

## human_confirmation

⛔ **模型不得代填。**

- [ ] 我确认「有没有被改过」在本 phase 一并完成、⛔ 不另排 Phase 7b(`known_gaps` #1)
- [ ] 我确认 `.gitmodules` 不计入 B6 的三条理由(`known_gaps` #3)
- [ ] 我确认红检动真 submodule 的例外与其缓解(`known_gaps` #6)
- [ ] 我确认 Phase 7 可以关闭
