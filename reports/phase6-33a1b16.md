# Phase 6 · 上游语义判据 —— 完成报告

> ⭐ **第一读者是下一个会话的模型,不是人。**
> ⚠️ 本报告绑定 commit **`33a1b16`** —— ⛔ 脱离该 commit 的任何结论不可证伪。

## pin

| 项 | 值 |
|---|---|
| 报告绑定 commit | **`33a1b16`** `feat: lock Phase 6 upstream-semantics criterion` |
| 上游 pin | `github/spec-kit` **v1.0.0** / `bca6790` / MIT |
| 阶段 | **Phase 6 · 上游语义判据**(⭐ 比分发更地基:决定 nonconstant 能否安全跟随上游) |
| 日期 | 2026-08-22 |

## ⭐⭐ a / b 方案的选择:**选 b(真跑,观察行为)**

| 方案 | 判定 |
|---|---|
| a · 读源码找那两行 | ⛔ **否决** —— 那仍是**判内容**,只是范围小。上游把 `returncode != 0` 重构成 `proc.returncode` 或提早 return,语义没变而判据判红 ⇒ **合法升级即误报**(= `LATCH-hook-three-legs` 第三条腿) |
| b · 真跑最小探针,观察行为 | ⭐ **采纳,且实测跑得起来** |

**⭐ b 可行的关键实测:**

1. 上游包根是 eager import,缺 `json5` / `readchar` / `pathspec` 三个运行时依赖 ⇒ ⛔ 直接 import 失败。
   ⇒ ⭐ **为缺失依赖注入桩**(⛔ 只在探针进程内,⛔ 不改 vendor),三个桩即可导入。
2. `ShellStep().execute({"run":"exit 3"})` ⇒ **`FAILED`**;`{"run":"exit 0"}` ⇒ **`COMPLETED`**。
3. `GateStep().execute({...})` 在非 TTY ⇒ **`PAUSED`**(⛔ 不自动放行)。
4. ⭐⭐ **决定性发现:**该 `PAUSED` 结果的 `output` 里**带着引擎算出的 `on_reject: "abort"`** ——
   ⇒ 连「默认值」这一条也是**观察行为**得来的,⛔ **不是从源码 grep 出来的**。

⇒ ⭐ **两条语义 100% 由行为验证,a 方案不必退回。**

## frozen_contracts

| ID | 契约 | 落点 |
|---|---|---|
| P6-C1 | ⭐ **判语义,⛔ 不判文件内容** —— 判据必须**执行**上游代码并观察返回,⛔ 不得比对源码文本或指纹 | `.nonconstant/upstream-semantics.sh` |
| P6-C2 | nonconstant 依赖的语义**恰为两条**:`shell` 退出码非 0 ⇒ `FAILED` / 0 ⇒ `COMPLETED`;`gate` 非 TTY ⇒ `PAUSED` 且 `on_reject` 默认 `abort` | 同上 |
| P6-C3 | ⭐⭐ **「判不了」判 `2`,⛔ 绝不判 0** —— 上游缺失 / 导不进 / 结构对不上,一律 2 | 同上 |
| P6-C4 | ⭐ **注入的依赖桩必须打印出来** —— ⛔ 静默的桩会让「语义没变」变得不可信 | 同上 |

## references_contracts

| 上游契约 | 出处 | 兑现 |
|---|---|---|
| §10 Phase 6 | `01-PLAN.md` | ⭐ 绿/红 + 四类探针全做 |
| **Q14** 两条语义的出处 | `01-PLAN.md` §6 | ⭐ 本判据即其机器化;⛔ Q14 记的是**文件位置**,本判据改判**行为** |
| B2 `vendor/` 只读 | `CLAUDE.md` | ⭐ 红检用**副本**(`$TEMP`),⛔ 真 vendor 一字未改;红检后复跑真源 ⇒ 0 |
| C6 闸门缺失比判红更严重 | `18-PROTOCOL.md` §4 | ⭐ P6-C3 |
| `LATCH-waiver-must-announce` | `03-LEDGER.md` | ⭐ P6-C4:桩不静默 |
| C3 红检对 fixture 跑 | `18-PROTOCOL.md` §4 | ⭐ fixture 由 `cp -r vendor/spec-kit/src` 动态复制后变异,⛔ 仓库零静态副本 |

## gate_results

⭐ 全部在 **HEAD = `33a1b16`** 上求值;收尾工作树 **0 项**。

| # | 检 / 探针 | 期望 | 实测 |
|---|---|---|---|
| 1 | **绿检** —— 当前 `vendor/`(v1.0.0) | 0 | ⭐ **0**,并打印桩 `json5,readchar,pathspec` |
| 2 | **红检** —— 副本里把 `shell` step 的 `FAILED` 全改成 `COMPLETED` | 非 0 | ⭐ **1**「退出码非 0 ⇒ 期望 FAILED,实测 COMPLETED」 |
| 3 | 探针 A · 上游目录不存在 | 非 0 | ⭐ **2**「⛔ 上游不在 ≠ 语义没变」 |
| 4 | 探针 B · 目录存在但结构完全不同 | 判断见下 | ⭐ **2**「导入卡在 `specify_cli`,桩不掉」 |
| 5 | 探针 C · `gate` step 整个被删 | 非 0 | ⭐ **2**「导入卡在 `...steps.gate`」 |
| 6 | 探针 D · 判据自身被删(**已提交版本**) | 非 0 | ⚠️ **127**,⭐ 且 `criteria-guard` 判 **1** |
| 7 | 兄弟交叉 · `silent-scan` 扫本判据 | 0 | ⭐ **0** |

⇒ ⭐ **一过一失败已演示(#1 vs #2)⇒ 不是常量。**
⇒ ⛔ **没有任何一条能让它返回 0 而实际没验。**

### ⭐ 探针 B/C 判 `2` 而非 `1` 的理由(P6-C3)

⛔ 判 `1` 等于断言「**语义已变**」—— 而结构对不上时我们**根本没测到语义**,那是**过度声称**。
⭐ 判 `2` 的含义是「**判不了,须人看**」。⚠️ 两者都非 0,⇒ **不变的是:什么都不会被静默放行。**

### ⚠️ 一处中途发现并修掉的缺陷

探针 B/C 首次跑时**退出码正确(2),但诊断信息丢了** —— 显示的是笼统的「行为探针进程异常退出」。
根因:Windows 控制台默认 **gbk**,探针里的中文/符号让 `print` 抛 `UnicodeEncodeError` ⇒ 进程非 0 退出 ⇒ 真正的诊断被替换。
⇒ ⭐ **修根因**(锁定 `PYTHONIOENCODING=utf-8`),⛔ 不是改措辞。⚠️ 与 Phase 4 的 awk 路径乱码**同族:报错了,但读不出是什么。**

## known_gaps

| # | 缺口 | 说明 |
|---|---|---|
| 1 | ⚠️ **动用了预算外余量,登记如下**(A003) | **用了什么:**`.nonconstant/upstream-semantics.sh`(110 行)。**属哪类:**⭐ **②计划外发现所必需** —— 该 phase 由 Phase 5 收尾时扫出的 `phase0 known_gaps #1`(B2 无可执行判据)提出,⛔ §10 原先没有它。**为什么名额装不下:**B6 八格**全部指名**,第 8 格留给 Phase 7/8 的 `workflow.yml`(A003 §3 已否决挤占) |
| 2 | ⛔⛔ **三个依赖桩是本判据最大的不确定性** | 桩掉 `json5`/`readchar`/`pathspec` 后,⛔ **无法保证被测路径完全没碰到它们**。⭐ 现有证据:`gate/__init__.py` 源码内 `readchar` 零命中(已查),`shell` step 只用 `subprocess`。⚠️ 但**上游升级后可能改变**。⇒ ⭐ 桩名已强制打印(P6-C4),⛔ 但「桩是否污染了结果」本身**无判据**。<br>⚠️ ⛔ **订正(2026-08-22,A006 轮;⛔ 原文不删):本条措辞过宽。**⭐ 实测对**真实安装**(`uv tool install specify-cli`,pin 同为 `bca6790`)跑本判据 ⇒ **0**,且**注入的桩为「(无)」**—— 真实安装自带那三个依赖。⇒ ⭐⭐ **该不确定性是 vendored 源码树的产物,⛔ 不是判据的缺陷。**⚠️ 但由此暴露更大的一条:**「读 vendor」与「跑真实安装」是两个不同的对象** ⇒ 见 `LATCH-vendored-is-not-installed` 与协议 **C10**。 |
| 3 | ⚠️ **只验两条语义** | nonconstant 若将来依赖第三条(如 `continue_on_error` 默认 false、`fan_out` 语义),⛔ **静默失去覆盖**(T5 形状)。⇒ 新增依赖时必须同步扩本判据 |
| 4 | ⚠️ **未验 `vendor/` 是否被改** | 本判据验的是**语义在不在**,⛔ 不是**上游有没有被动过**。⇒ B2「未改上游」仍无判据(`phase0 known_gaps` #1 **只解决了一半**) |
| 5 | ⚠️ **`vendor/` 在 `.gitignore` 内** | ⇒ 判据跑的是**工作区里的那份**,⛔ 无法确认它就是 pin 的 `bca6790`。⭐ 与 `LATCH-untracked-invisible` 同一根因的另一面 |
| 6 | ⚠️ **依赖本机 `python`** | 版本/环境不同可能改变行为。实测环境:**Python 3.14.3** |

## next_entry_conditions

Phase 7(Q13 安装形态)开工前须满足:

1. ⭐ 本报告已提交,`.nonconstant/upstream-semantics.sh` 在 `33a1b16` 内 —— **已满足**
2. ⬜ 先答 **Q13**:① 安装脚本 ② spec-kit extension ③ PyPI 包
3. ⚠️ 验收**判结果不判机制**:装进空临时仓后,**八条判据全部可被调用且返回预期退出码**(⛔ 只验一条 = 只验「装完能跑」,不验「装对了」)
4. ⬜ 红检:装进**已有 `nonconstant.yml`** 的仓 ⇒ 非 0(⛔ 不得静默覆盖)
5. ⚠️ `known_gaps` #5 会直接影响 Q13 —— **`vendor/` 未跟踪** ⇒ 安装形态必须回答「上游那份从哪来」

## explicitly_out_of_scope

⛔ 下一会话**不得重提**:

- ⛔ 改成读源码找那两行(a 方案已否决:合法升级即误报)
- ⛔ 给 `vendor/` 做指纹(同上;⛔ 且 §10 Phase 6 明确写了「判语义不判文件内容」)
- ⛔ 让探针 B/C 判 1(P6-C3 已判定:没测到语义就声称语义已变 = 过度声称)
- ⛔ 去掉依赖桩的打印(P6-C4)
- ⛔ 实施候选 1 改 `scan-silent` 消息(那是 **Phase 9**)
- ⛔ 修 `criteria-guard` 的未跟踪盲区(须授权)

## human_confirmation

⛔ **模型不得代填。**

- [ ] 我确认 b 方案(真跑观察行为)与三个依赖桩的做法可以接受
- [ ] 我确认 `known_gaps` #2(桩是否污染结果无判据)这个不确定性可以接受
- [ ] 我确认探针 B/C 判 2 而非 1 的理由成立
- [ ] 我确认 `upstream-semantics.sh` 动用预算外余量的登记(`known_gaps` #1)
- [ ] 我确认 Phase 6 可以关闭
