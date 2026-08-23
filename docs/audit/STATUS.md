# STATUS — 现在做什么

> **本文件是唯一记录"现在做什么"的地方。**
> `01-PLAN.md` 记"方案是什么";⛔ **历史与理由归 `03-LEDGER.md`,不在这里复述。**
> ⛔ 上限 60 行,由 `.latch/doc-budget.sh` 机器检查(C8)。⭐ 每句归谁守:`19-STATUS-ASSERTIONS.md`。

## 当前状态

| 项 | 值 |
|---|---|
| 日期 | 2026-08-22(⛔ 无判据) |
| 上游 pin | spec-kit v1.0.0(⛔ 无判据)/ `bca6790`(⭐ 有判据) |
| §10 阶段 | ⭐ **Phase 0~8 + 10~11 全部完成**(⭐ 编号 = 身份,⛔ 非顺序) |

## latch 现在有什么

⭐ **10 条判据,全部以退出码作答、非交互:**

| 判据 | 实现 | 级别 |
|---|---|---|
| `criteria-guard` | `.latch/gates.sh` | hard |
| `silent-scan` | `.latch/scan-silent.sh` | hard |
| `meta-gate` | `.latch/meta-gate.sh` | hard |
| `report-pin` | `.latch/report.sh` | hard |
| `status-facts` | `.latch/status-facts.sh` | hard |
| `waiver-expiry` | `.latch/waiver-expiry.sh` | hard |
| `upstream-semantics` | `.latch/upstream-semantics.sh` | hard |
| `upstream-pin` | `.latch/upstream-pin.sh` | hard |
| `doc-budget` | `.latch/doc-budget.sh` | soft |
| `readme-runnable` | `.latch/readme-runnable.sh` | hard |

配置 `latch.yml` · 边界 `CLAUDE.md` · 修正 `amendments/A001~A008` · 报告 `reports/phase0~8,10~11-*.md`
⛔ **未接编排层**,⛔ 无 `workflows/latch/workflow.yml`。⚠️ **B6 指名已满 8/8** ⇒ 后续新文件一律走 **A003 预算外余量**并在报告 `known_gaps` 登记。

## ⭐⭐ 三条未决已解锁(⛔ 本轮未处理 · ⛔ 无判据,靠人读)

| 项 | 内容 |
|---|---|
| **Q19** | ⛔ 判据加固四项已推迟 —— 触发:首个外部用户报告 |
| **Q17** | 编排层的可自动化边界 |
| **T6 候选** | 「凡让修复成本随时间上升的机制,必然固化错误」升格为定理 |

## ⛔ 下一 phase 开工前必做(⛔ 无判据,靠人读 —— 是计划,无对应物)

1. ⬜ 决定先做 **Q17**(编排层)还是 **T6** —— ⭐ Q13 已由 Phase 8 关闭
2. ⬜ 元判据「只查登记、不查真跑」的边界 —— 已在 `latch.yml` 就地标注,⛔ 判定为**不修**
3. ⬜ Q11 · hook 排名重估(§8 #17);Q16 已由 **A004** 关闭
4. ⬜ **隔离工位怎么实现** —— §3 排名第 1,⛔ §8 #15 撤回「= git worktree」后**无实现路径**

## DevLoop 侧待办(⛔ 不属 latch ⇒ ⛔ 无判据:别的仓,latch 看不见)

⬜ ① 验扫描器(在清理修复**之前**的 commit 上跑)· ⬜ ② 三处 helper 非零即抛或开 waiver
⬜ ③ 三次取上界 → 定预算 → 落元判据 · ⬜ ④ 第七项(pytest 闸)拿到首个非 FAIL · ⬜ ⑤ 接 spec-kit 内建 shell step,红绿都做

## ⚠️ 已知债务(⛔ 无判据,靠人读 —— 计数与能力判断无对应物)

⚠️ **全局 hook** `block-no-verify` 误拦含 `grep -n` + `commit` 的命令,连带拦 `--amend`。
**复发 4 次**;维持「⛔ 不修」(代价仅多跑几条命令)。⭐ 规避:避开 `-n` 与 `commit` 同现。⚠️ 计数须更新(F1)。根因 `LATCH-hook-three-legs`。
⚠️⚠️ **红检可信度有限**:基线自检未引入前,⛔「工具没跑起来」与「判据判红」不可区分(`LATCH-harness-failure-looks-like-red`)。
⚠️ **waiver 机制只做了一半**:到期检查已有,⛔ 过期只判红、无强制清理(`A001` #1)。⚠️ DevLoop 侧 `%TEMP%` 残留 **249** 条 worktree(`devloop/gates.py:619`)⇒ ⛔ 属 DevLoop。
