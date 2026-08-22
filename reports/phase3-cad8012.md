# Phase 3 · 判据可执行性 + 报告绑 commit —— 完成报告

> ⭐ **第一读者是下一个会话的模型,不是人。**
> ⚠️ 本报告绑定 commit **`cad8012`** —— ⛔ 脱离该 commit 的任何结论不可证伪。

## pin

| 项 | 值 |
|---|---|
| 报告绑定 commit | **`cad8012`** `feat: lock Phase 3 meta-gate and report-pin` |
| 上游 pin | `github/spec-kit` **v1.0.0** / `bca6790` / MIT |
| 阶段 | **Phase 3 · 判据可执行性(§3 序 4)+ 报告绑 commit(§3 序 5)** |
| 日期 | 2026-08-22 |

## frozen_contracts

| ID | 契约 | 落点 |
|---|---|---|
| P3-C1 | ⭐ **判据必须登记「一过一失败」**:`demo_pass_exit` 须为 `0`,`demo_fail_exit` 须非 `0`,并给 `demo_report`。⛔ 未登记 ⇒ 拒绝启用 | `latch.yml:gates[*]` · `.latch/meta-gate.sh` |
| P3-C2 | ⭐⭐ **判据的 `impl` 不存在 ⇒ 退出码 `2`,比「判红」更严重**(协议 **C6**)。⛔ 绝不等同于「未配置 ⇒ 跳过」 | `.latch/meta-gate.sh` |
| P3-C3 | ⭐ **报告名里的 hash 须在 git 历史中存在且是 `HEAD` 的祖先** —— ⛔ 不是「等于当前 HEAD」(那条恒假) | `.latch/report.sh` |
| P3-C4 | ⭐⭐ **base 只从 `latch.yml:base` 取;调用方给 base ⇒ 拒绝,退出码 `2`** | `latch.yml:base` · `.latch/gates.sh`(**A004** 取代 P1-C4) |
| P3-C5 | 四条判据全部**非交互、以退出码作答**,可被 spec-kit `shell` step 一行调用 | 见 `next_entry_conditions` |

## references_contracts

| 上游契约 | 出处 | 兑现 |
|---|---|---|
| §3 序 4 闸门可执行性 | `01-PLAN.md` | ⭐ `.latch/meta-gate.sh` |
| §3 序 5 M3 报告绑 commit | `01-PLAN.md` | ⭐ `.latch/report.sh` |
| D-16 判据不能是常量 | `16-DECISIONS.md` | ⭐ 元判据即其机器化 |
| D-17 红检必须配绿检 | `16-DECISIONS.md` | ⭐ 两条判据各做红绿 |
| 协议 **C6** 闸门缺失比判红更严重 | `18-PROTOCOL.md` §4 | ⭐ **P3-C2**,并见 `gate_results` #9/#10 |
| 协议 **C5** base 由操作者给 | `18-PROTOCOL.md` §4 | ⭐ **P3-C4**(A004) |
| 协议 **C3** 红检对 fixture 跑 | `18-PROTOCOL.md` §4 | ⭐ fixture 由**真配置动态复制**后变异,`$TEMP` 内,仓库零静态副本 |
| §6 **Q16** · `LATCH-input-control` | `01-PLAN.md` | ⭐ 已关(仅 `criteria-guard` 一侧,见 `known_gaps` #3) |
| B6 名额 | `CLAUDE.md` | 用掉 **#6 `.latch/meta-gate.sh`**、**#7 `.latch/report.sh`** ⇒ **7/8 指名**;⛔ **未动用预算外余量** |

## gate_results

⭐ 全部在 **HEAD = `cad8012`、工作树干净** 上求值;收尾工作树 **0 项**。
⭐ fixture 由 `cp latch.yml` **动态复制**后变异,⛔ 仓库内零静态副本。

| # | 检 / 探针 | 期望 | 实测 |
|---|---|---|---|
| 1 | **元判据 绿检** —— 真源 `latch.yml`(4 条判据均登记双向演示) | 0 | ⭐ **0** |
| 2 | **元判据 红检 1** —— 删掉 `demo_fail_exit`(只演示了「过」) | 非 0 | ⭐ **1** |
| 3 | **元判据 红检 2** —— `demo_fail_exit: 0`(两次演示同向 = 仍是常量) | 非 0 | ⭐ **1** |
| 4 | **report-pin 绿检** —— 真源 `reports/`(3 份) | 0 | ⭐ **0** |
| 5 | **report-pin 红检** —— 伪 hash `deadbee` | 非 0 | ⭐ **1** |
| 6 | 探针 · `PENDING` 占位符未替换 | 非 0 | ⭐ **1** |
| 7 | 探针 · 报告目录不存在 | 非 0 | ⭐ **2** |
| 8 | 探针 · 空报告目录 | — | ⚠️ **0**(vacuous,见 `known_gaps` #2) |
| 9 | ⭐⭐ 探针 A-1 · 判据的 `impl` 不存在 | 非 0 **且 ≠ 1** | ⭐ **2** —— ⛔ 比判红更严重(C6) |
| 10 | ⭐⭐ 探针 A-2 · **元判据自身被删** | 非 0 | ⚠️ **127**(shell)⭐ **但 `criteria-guard` 同时判 `1`** —— 删闸不再无声,见下 |
| 11 | ⭐⭐ 探针 B · **base 由调用方给**(`gates.sh HEAD~1`) | 拒绝 | ⭐ **2** ⛔ 拒绝而非静默忽略 |
| 12 | 收尾 · `criteria-guard` | 0 | ⭐ **0** |

⇒ ⭐ **一过一失败已演示:元判据 #1 vs #2/#3;report-pin #4 vs #5 ⇒ 两条都不是常量。**
⇒ ⭐⭐ **元判据满足了自己**(硬前置 C):它是 `latch.yml` 里的第 3 条判据,登记了自己的双向演示,并在 #1 中被自己检查通过;#2/#3 证明它**拦得下**一条常量判据。

## known_gaps

| # | 缺口 | 说明 |
|---|---|---|
| 1 | ⛔⛔ **元判据只查「登记了没有」,⛔ 查不了「演示是否真跑过」** | `demo_*_exit` 是**写在配置里的数字**。一个不老实的登记者可以填 `demo_fail_exit: 1` 而从未跑过。⇒ ⭐ 与协议 **R8** 的能力边界**完全同形**:只挡得住「完全没做」,⛔ 挡不住「做了但敷衍」(D5,不可根治)。⚠️ 可能的收紧方向:让元判据**真去跑**那两条演示命令 —— ⛔ 本轮未做,那需要在配置里存可执行命令,是另一个量级 |
| 2 | ⚠️ **`latch.yml` 里两条新判据的 `demo_report` 仍是 `phase3-PENDING.md`** | 元判据对 `*PENDING*` 放行(源码内显式白名单)⇒ ⛔ **一条判据可以永远声称 PENDING 而不可核查**。⇒ **下一 phase 开工第一件事:改成 `reports/phase3-cad8012.md`**。⛔ 本轮不改 —— 改它要动 `latch.yml`,而报告须单独提交 |
| 3 | ⚠️ **A004 只关了 `criteria-guard` 的输入口子** | `scan-silent.sh <目录>` · `meta-gate.sh <配置>` · `report.sh <目录>` 的路径参数仍由调用方给。⭐ 区别已辨析于 `amendments/A004-*.md` `known_gaps`:base 是**基线**(可用来藏改动),后三者是**被判定的对象本身**(换掉等于换考卷)。⚠️ 仍须在编排层固定 ⇒ **Q17** |
| 4 | ⚠️ **空报告目录 ⇒ 0**(#8) | vacuous pass 与真 pass 在退出码上**不可区分** —— 与 `dossier.py:147`「SKIP/VOID ＝ 没验,⛔ 不是验过没事」同族。⇒ 需要第四态(fail/unknown/pass/vacuous),⛔ 本轮未做。<br>⭐ **判断(2026-08-22 补):可接受,⛔ 不改。**三条理由:① **空集上返回 0 是该判据的正确语义** —— 它断言的是「**每一份**报告都绑到真实提交」,零份时该断言为真,⛔ 不是「没检查」;② ⛔ **该状态不可持久** —— `reports/` 一定会有报告(每个 phase 必产一份),⇒ 它不是**常量**,只是**当前输入恰好为空**,与「判据对任何输入都返回同值」有本质区别;③ 对照 Phase 0 的「零代码」判据同为 vacuous-true 且当时接受。<br>⚠️ **接受的前提**:上述 ② —— 若某天出现「报告目录被清空却仍判绿」的路径,该理由立即失效。⇒ ⭐ 真正的隐患不是空集,是**没人保证报告一定会产出**,那归编排层(**Q17**) |
| 5 | ⚠️ **`latch.yml:base` 恒为 `HEAD`** | 「基线可配」这一能力**从未在非 `HEAD` 取值上测过** |
| 6 | ⚠️ **删闸仍返回 shell 的 127** | ⭐ 但本轮起有**两道独立覆盖**:① 元判据查 `impl` 存在性 ⇒ **2**;② `criteria-guard` 把删除视为对受保护路径的改动 ⇒ **1**(#10 实测)。⇒ ⛔ 编排层**仍须**显式处理 127(协议 C6),⛔ 不得依赖这两道兜底 |
| 7 | ⚠️ **未接 spec-kit** | 四条判据均已验证非交互、以退出码作答(**P3-C5**),⛔ 但 `workflows/latch/workflow.yml`(B6 #8)本轮未建 —— 那是 **Q17**,§10 未列 |

## next_entry_conditions

1. ⭐ 本报告已提交,四条判据在 `cad8012` 内 —— **已满足**
2. ⬜ ⛔ **先把 `latch.yml` 两处 `phase3-PENDING.md` 改为 `reports/phase3-cad8012.md`**(`known_gaps` #2)
3. ⬜ 决定是否收紧元判据:让它**真跑**演示命令(`known_gaps` #1)
4. ⬜ **Q17** 编排层:接 spec-kit `shell` step,⛔ 必须显式处理 **127**,并固定所有判据的路径参数(`known_gaps` #3/#6)
5. ⬜ **Q13** 安装形态 —— 触发条件「Phase 1~3 完成后」**现已满足**

## explicitly_out_of_scope

⛔ 下一会话**不得重提**:

- ⛔ 让 `gates.sh` 重新接受调用方 base(A004 已定;那是 T1 失效)
- ⛔ 把 `demo_*_exit` 改成「可选字段」以让配置更好写 —— 那是**改判据迁就使用者**
- ⛔ 为了让空目录判红而给 `report.sh` 加最小报告数阈值 —— ⚠️ 那是**用常量掩盖 vacuous 问题**,正解是第四态
- ⛔ 本轮建 `workflows/latch/workflow.yml` 或任何编排层(Q17)
- ⛔ 改回行数窗口(Phase 2 探针 F 已证伪)
- ⛔ 实现隔离工位(§8 #15,目前无实现路径)

## human_confirmation

⛔ **模型不得代填。**

- [ ] 我确认元判据「只查登记、不查真跑」(`known_gaps` #1)这个边界可以接受
- [ ] 我确认 `PENDING` 白名单(`known_gaps` #2)在下一 phase 开工时立即清掉
- [ ] 我确认 A004 用 amendment 改掉 P1-C4 的做法正确
- [ ] 我确认 Phase 3 可以关闭
