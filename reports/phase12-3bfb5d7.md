# Phase 12 · 接上 spec-kit 执行引擎 —— 完成报告

> ⭐ **第一读者是下一个会话的模型，不是人。**
> ⚠️ 本报告绑定 commit **`3bfb5d7`** —— ⛔ 脱离该 commit 的任何结论不可证伪。

> ⚠️ ⛔ **订正注记（2026-08-24，A010 改名；⛔ 原文一字未删）**
> 本报告正文里的 `.nonconstant/` 与 `nonconstant.yml`，在本报告**所绑定的那个 commit** 里
> 实际叫 `.latch/` 与 `latch.yml`。⭐ 项目已于 `8196615` 改名 `latch` → `nonconstant`
> （原名在**同领域**已被占，见 `LATCH-name-collision-blocks-release`）。
> ⛔ **历史未被改写** —— ⭐ 那个 commit 里就是旧名，那是事实；改了反而伪造。
> ⚠️ ⛔ **LEDGER 条目 ID 的 `LATCH-` 前缀一律保留** —— 标识符一旦被跨文件引用就是身份（**C11**）。

## pin

| 项 | 值 |
|---|---|
| 报告绑定 commit | **`3bfb5d7`** `feat: lock Phase 12 — spec-kit workflow integration` |
| 上游 pin | `github/spec-kit` **v1.0.0** / `bca6790` |
| 阶段 | **Phase 12 · 接上 spec-kit 执行引擎**（依据 `amendments/A009-*.md`） |
| 日期 | 2026-08-23 |

## frozen_contracts

| ID | 契约 | 落点 |
|---|---|---|
| P12-C1 | ⭐⭐ **workflow 的每一步是「一条命令」，⛔ 零内联 shell 逻辑** —— 需要逻辑的，逻辑归**判据自己** | `workflows/nonconstant/workflow.yml` |
| P12-C2 | ⛔⛔ **绝不给 nonconstant 的 step 加 `continue_on_error: true`** —— 那会让判红只记日志然后继续跑 = 闸门形同虚设 | 同上（⭐ 一处都没有） |
| P12-C3 | ⭐ **`silent-scan` 的扫描目标由判据自己从 `subjects.scan_target` 取**，⛔ 编排层不得写死 | `.nonconstant/scan-silent.sh` |
| P12-C4 | ⭐ **soft 判据排在最后并吞掉退出码** —— soft 的定义就是「不阻断」；⛔ 排在最后才不会掩盖 hard | `workflows/nonconstant/workflow.yml` |
| P12-C5 | ⭐ **C6 由 `meta-gate` 兑现，⛔ 不在 YAML 里重写存在性检查** —— 它逐条查 `impl:` 是否存在，缺失判 **2** | `.nonconstant/meta-gate.sh:79` |
| P12-C6 | ⭐⭐ **A006 完整兑现：十条判据全部由 `nonconstant.yml` 驱动。**`silent-scan` 曾是**最后一条**需要调用方硬编码输入的判据（Phase 2 `known_gaps` #4 · Q16 · `LATCH-input-control` 同族：「判定的输入由调用方给」）。改成从 `subjects.scan_target` 取之后，⛔ **没有任何一条判据的输入还由调用方决定** | `.nonconstant/scan-silent.sh` · `nonconstant.yml:subjects` |

## references_contracts

| 上游契约 | 出处 | 兑现 |
|---|---|---|
| **A009** 三档验收 + 三个探针 | `amendments/A009-*.md` | ⭐ 全做，见 `gate_results` |
| **C6** 闸门缺失比闸门判红更严重 | `18-PROTOCOL.md` | ⭐ 实测：删掉一个判据脚本 ⇒ `meta-gate` 判 **2**（⛔ 非「跳过」） |
| **A006** 判据输入不得硬编码在调用方 | `amendments/A006-*.md` | ⭐ P12-C3 —— ⚠️ 这是**最后一条**还要调用方给输入的判据，本 phase 关掉 |
| **B6 第 8 格** `workflows/nonconstant/workflow.yml` | `CLAUDE.md` | ⭐ **兑现** —— 空了十二个 phase |
| ⛔ 不写自定义 step | 本轮铁律 | ⭐ 只用内建 `shell` step |

## gate_results

⭐ 全部在 **HEAD = `3bfb5d7`** 上求值。⭐⭐ **跑在装了 nonconstant 的普通临时项目里**（⛔ 非 nonconstant 自己的仓）。

### ⭐ 前置：为什么跑在用户项目（A009 §4）

Phase 8 的教训：`config-read.sh` 没被装过去 ⇒ 装出来的每条判据都判 2，⛔ **而那在 nonconstant 自己的仓里永远看不见**。
⚠️ 且 nonconstant 自己的仓有 `upstream-pin`（`scope: bootstrap`），⛔ 用户项目根本没有这条 ⇒ 在自己仓里测等于测一个没人有的布局。

### 三档验收（⛔ 真跑 `specify workflow run`）

| 档 | 场景 | 期望 | 实测 |
|---|---|---|---|
| **绿** | 八条判据全绿 | 0 | ⭐ `Status: completed` · CLI **0** · 八步全跑 |
| **红** | `status-facts` 判红（STATUS 称「99 条判据」） | 非 0 且**中止** | ⭐⭐ CLI **1** · 跑到 `[status-facts]` 即停 ⇒ `waiver-expiry` / `upstream-semantics` / `doc-budget` **未执行** |
| **127** | 删掉 `.nonconstant/report.sh` | 非 0 | ⭐⭐ CLI **1**，且**先于 127** —— `meta-gate` 判 **2** 并点名缺哪条 |
| **127（纯）** | 删掉第一步自己的 `.nonconstant/meta-gate.sh` | 非 0 | ⭐ CLI **1** · 错误串 `Shell command exited with code 127.` |

⇒ ⛔ **停机条件未触发** —— 127 **没有**被当成「跳过」。

### ⚠️ 中途删掉的一步：`gates-present`（⭐ 重复造轮子）

⛔ 我最初在 workflow 里写了一个 `gates-present` step，用内联 shell 遍历 `impl:` 查文件是否存在。
⭐ 后来发现 **`meta-gate` 已经在做这件事**，而且做得更好 —— `.nonconstant/meta-gate.sh:79`：
「判据 `<id>` 的实现不存在: `<impl>` —— ⛔ 闸门缺失 ≠ 未配置 ⇒ 绝不跳过(C6)」，且判 **2**（⛔ 不是 1）。

⇒ ⭐ 删掉那一步，改为把 **`meta-gate` 排在第一位**。两条收益：
① ⛔ 少一段内联 shell（`known_gaps` #2 说明了为什么那很危险）；
② ⭐ C6 由**真判据**兑现，⛔ 不由 YAML 里的临时脚本兑现 —— 后者没有红绿演示，按 **C2** 根本不该被当成判据。

### 探针

| # | 探针 | 期望 | 实测 |
|---|---|---|---|
| 1 | workflow 里判据路径写错（`typo-report.sh`） | 非 0 | ⭐ CLI **1** · `code 127` ⇒ ⛔ 不得当成通过 |
| 2 | **soft 判红**（`doc-budget` 超限，其余全绿） | 见下 | ⭐ CLI **0**，八步全跑完 |
| 3 | 兄弟交叉 · 用户项目八条 | 全 0 | ⭐ 全 **0**，workflow **0** |
| 4 | 兄弟交叉 · nonconstant 自身十条 | 全 0 | ⭐ 全 **0** |

⚠️ ⛔ 探针 2 首次做**无效**：我加了两行但没超 60 行上限，`doc-budget` 判 **0** ⇒ ⛔ 那不是 soft 场景。
第二次改 `max_lines` 又触发了 `criteria-guard`（`nonconstant.yml` 受保护）⇒ ⛔ 测的是别的闸。
⭐ 第三次才构造出**纯 soft 场景**：往 STATUS 加 70 行 ⇒ `doc-budget=1` · `criteria-guard=0` · `status-facts=0`。

### ⭐ soft 判红该停还是该过：**该过**

**理由（⛔ 不是「方便」）**：`soft` 的定义就是「不阻断」（`01-PLAN` §5 P4）。⛔ 若让它中止 workflow，soft 与 hard 就没有区别 —— ⚠️ 而那会让人**为了通过而删掉 soft 判据**，比放行更坏。
⚠️ ⛔ **代价不掩饰**：workflow 退出码**不反映 soft 判红**。⇒ ⭐ 所以它排在**最后**，前面的 hard 不会被它的 0 掩盖，且判据自己仍把原因打到 stderr。

## ⭐ A009 三条收益：逐条确认或推翻

| | 收益 | 判定 |
|---|---|---|
| **a** | 判据需要固定触发点，否则退化成常量 | ⭐ **确认，但要精确**：workflow **提供了**触发点，⛔ 但**它自己不会自动跑** —— 没人敲 `specify workflow run` 时它同样是 0 次。⇒ ⚠️ 真正解决「跑 0 次」的是**能自动触发的东西**（pre-commit / CI），⛔ 而 workflow 是**手动**的。⇒ ⛔ 这条**只兑现了一半** |
| **b** | pre-commit 只在提交那一刻检查；workflow 能在阶段之间插闸 | ⭐ **确认，且实测支持**：红检里 workflow 跑到判红那步**就停**，后续步骤不执行 ⇒ 若后面是 `speckit.implement`，它不会在判据判红后继续改代码。⭐ 这是 pre-commit 做不到的 —— 提交时代码已经写完了 |
| **c** | 127 那个洞只有编排层能验 | ⛔ **推翻**。⭐ pre-commit hook **也验**（它把非 0/非 1 归入「闸自身故障 ⇒ 拒绝」）。⇒ ⭐ 编排层的贡献不是「能验 127」，是**验的时机更早**（任务过程中 vs 提交时） |

### ⚠️ ⛔ 反面（A009 要求写清）：**单用 nonconstant 完全可行**

⭐ 它**现在就在跑** —— pre-commit 已拦下**两次真实事故**（`status-facts` 判红、`doc-budget` 判红）。
⇒ ⭐⭐ **接 spec-kit 是增强，⛔ 不是必需。**⛔ 且它引入一个新依赖（`specify` 必须已安装）。

### ⭐ pre-commit 五档复跑（⚠️ `scan-silent` 改成无参**之后**重验）

⚠️ `.nonconstant/pre-commit.sh` 原先给 `silent-scan` 传 `$SCAN_TARGET`；本 phase 改成统一 `bash "$impl"`（目标由判据自己取）⇒ ⛔ 调用形态变了，**必须重验各档**：

| 档 | 场景 | 期望 | 实测 |
|---|---|---|---|
| ① 基线 | 干净树 | 0 | ⭐ **0** |
| ② **hard 判红** | `status-facts`（STATUS 称「99 条判据」）| 拒绝 | ⭐ **1** · 点名 `status-facts` |
| ③ **soft 判红** | `doc-budget` 超限，`criteria-guard` 为 0 | 放行 | ⭐ **0** · 打印「`doc-budget`(soft)」 |
| ④ **判 2** | `subjects.status` 指向不存在的文件 | 拒绝 | ⭐ **1** ·「闸自身故障（比判红更严重，C6）」|
| ⑤ **脚本被删** | `rm .nonconstant/report.sh` | 拒绝 | ⭐ **1** —— ⭐⭐ 两条**独立**抓到：`meta-gate: 退出码 2` **与** `report-pin: 实现不存在` |

⇒ ⭐ ③ 证明 soft/hard 的区别在 hook 层**真的存在**；⑤ 证明 C6 在 hook 层有**两道**独立防线。

## ⭐ 收尾必答：装了 nonconstant 的项目里，用户日常敲什么

⭐ **三者并存，各管一个时机 —— ⛔ 不是三选一：**

| 时机 | 敲什么 | 为什么是它 |
|---|---|---|
| **随手查一条** | `bash .nonconstant/<gate>.sh` | ⭐ **唯一能看到诊断串的方式**（见 `known_gaps` #1） |
| **提交前**（自动） | ⛔ 什么都不敲 —— `.git/hooks/pre-commit` 自己跑 | ⭐ 唯一**自动**的一档；⛔ 但只在提交那一刻 |
| **任务过程中 / CI** | `specify workflow run workflows/nonconstant/workflow.yml` | ⭐ 唯一能**在阶段之间**插闸的；⛔ 手动触发 |

⇒ ⭐ **一句话**：`pre-commit` 是底线（自动、晚）；`workflow` 是过程闸（早、手动）；`bash .nonconstant/x.sh` 是诊断（看原因）。
⚠️ ⛔ **缺的那一格是「早 + 自动」** —— 那才是 Q17，⛔ 本 phase 未做。

## known_gaps

| # | 缺口 | 说明 |
|---|---|---|
| 1 | ⛔⛔ **判据的诊断串在 workflow 里读不到** | ① spec-kit `capture_output=True` ⇒ ⛔ 不回显；② ⛔⛔ 更糟：Windows 上 `text=True` 用 **gbk** 解码，而 nonconstant 判据打 UTF-8 ⇒ `UnicodeDecodeError` 在 reader 线程抛出，**stdout/stderr 直接丢失**。⚠️ ⭐ **退出码不受影响**（三档验收全部正确），⛔ 但「为什么红」只能靠 `bash .nonconstant/<x>.sh` 复跑。⇒ ⛔ 改不了（vendor 只读，且用户装的是他自己那份）。<br>⭐ **实际后果（⛔ 说清）**：workflow 层**只看得到退出码**，⛔ 看不到 nonconstant 的诊断 ⇒ ⚠️ 用户排查时**必须自己单独跑一遍那条判据**。<br>⭐ **规避方案（⛔ 只记，本轮不实施）**：判据侧改用 **ASCII 诊断**（或 `LC_ALL` 探测后降级）。⛔ 不做的理由：那要改**十条判据的输出串**，而输出串正是 **Q19-A**（失败类型码）要动的东西 ⇒ ⭐ 两件事该一起做，⛔ 分两次做等于改两遍。⚠️ 且 `readme-runnable` 与红检都依赖现有措辞。 |
| 2 | ⛔⛔ **`shell=True` 在 Windows 上是 `cmd.exe`，⛔ 不是 bash** | ⭐ 实测：`echo COMSPEC=%COMSPEC% DOLLAR0=$0` 写出 `COMSPEC=C:\WINDOWS\system32\cmd.exe DOLLAR0=$0`。⚠️ ⛔ **而那一步判 0「通过」** —— POSIX 单行不报错、悄悄什么也没做 ⇒ ⭐⭐ **T5 出现在编排层**。⚠️ 且 cmd.exe **不认单引号** ⇒ `bash -c '...'` 根本没分组。⇒ ⭐ 本文件因此**零内联 shell 逻辑**（P12-C1） |
| 3 | ⛔ **workflow 装不进用户项目** | `install.sh` **不装** `workflows/`。⇒ ⚠️ 用户须自己把 `workflows/nonconstant/workflow.yml` 拷过去。⭐ 与 `.git/hooks/` 同类问题，⛔ 本 phase 未修 |
| 4 | ⛔ **workflow 不会自己跑** | ⭐ 见「三条收益 a」：它只是**提供**触发点。⇒ ⚠️ 「判据跑 0 次」这个根问题，⛔ 手动 workflow **解决不了** |
| 5 | ⚠️ **B1 路径表未列 `workflows/`** | ⭐ B6 早已指名该文件，⛔ 但 B1 的目录表没有它 ⇒ **表不完整**（与 A008 `known_gaps` #4 的 `README.md` 同形）。⛔ 本轮不补 |
| 6 | ⚠️ **只在 Windows + Git Bash 验过** | ⛔ Linux/macOS 上 `shell=True` 是 `/bin/sh` ⇒ ⭐ `bash .nonconstant/x.sh` 与 `\|\| exit 0` 两边都跑得动，⚠️ 但**未实测** |
| 7 | ⭐ **本 phase 未动用预算外余量** | ⛔ 零新增文件 —— `workflows/nonconstant/workflow.yml` 是 **B6 第 8 格**（早已指名）。⭐ B6 现 **8/8 全部兑现** |

## next_entry_conditions

1. ⭐ 本报告已提交，`workflows/nonconstant/workflow.yml` 在 `3bfb5d7` 内 —— **已满足**
2. ⛔⛔ **发布仍阻塞** —— 名字在同领域已被占（`LATCH-name-collision-blocks-release`），⭐ 已定改名为 `recuse`，⛔ 未开始替换
3. ⚠️ **Q17（早 + 自动）** 仍未排期 —— ⭐ 但本 phase 让它的价值变具体了：见 `known_gaps` #4
4. ⚠️ **Q19 四项**触发条件不变：首个外部用户报告相关问题

## explicitly_out_of_scope

⛔ 下一会话**不得重提**：

- ⛔ 在 workflow YAML 里写内联 shell 逻辑（P12-C1；⭐ `known_gaps` #2 已证明为什么）
- ⛔ 给 nonconstant 的 step 加 `continue_on_error`（P12-C2）
- ⛔ 在 YAML 里重写闸门存在性检查（P12-C5：`meta-gate` 已经做了）
- ⛔ 让 soft 判据中止 workflow（⭐ 理由已写明）
- ⛔ 改 spec-kit 来修 gbk 解码（vendor 只读，且用户装的是自己那份）
- ⛔ 把「接 spec-kit」写成必需（⭐ 单用 nonconstant 完全可行）

## human_confirmation

⛔ **模型不得代填。**

- [ ] 我确认 workflow 只做「挂判据 + 判红即停」，⛔ 不做自动派单
- [ ] 我确认 soft 判红放行的理由成立
- [ ] 我确认收益 c 被推翻（pre-commit 也能验 127）
- [ ] 我确认 `known_gaps` #1（诊断串丢失）与 #4（workflow 不自动跑）可以接受
- [ ] 我确认 Phase 12 可以关闭
