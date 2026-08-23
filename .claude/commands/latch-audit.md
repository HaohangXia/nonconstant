---
description: 跑一轮 nonconstant 方案审计 —— 自动派发隔离的 maker 与 challenger sub-agent,打分,判定收敛
---

跑 nonconstant 审计的**一轮**。你是主控,不亲自提意见也不亲自打分。

## 前置检查

读 `docs/audit/03-LEDGER.md` 的状态区。若 `收敛状态 = CONVERGED`,直接报告"已收敛,无需再跑"并停止。

## 执行顺序

### 1 · 派发 Maker

用 Task 工具启动 `nonconstant-maker` sub-agent。给它:

- `docs/audit/01-PLAN.md` 路径
- `docs/audit/03-LEDGER.md` 路径(供 G5 去重)
- 若存在 `vendor/spec-kit/`,告知路径供其核查证据
- 上一轮的交接提示(若有,≤50 字)

**不要**给它本 session 的任何讨论内容。

### 2 · 剥离,派发 Challenger

从 Maker 输出中**只提取**每条提案的 `变更内容` 与 `证据` 两栏,组装成一份干净清单。

**必须剥掉**:推导过程、动机、Benefit 分、Maker 的任何倾向性表述。

用 Task 工具启动 `nonconstant-challenger` sub-agent,给它:

- `docs/audit/01-PLAN.md` 路径
- 上一步剥离后的提案清单

若 Challenger 报告 `CONTAMINATED`,说明剥离失败 —— **重做第 2 步,不要将就**。

### 3 · 汇总打分

```
Net = Benefit + Cost + 修正

修正:
  +1  类别为 DELETE 或 SIMPLIFY 且 Challenger 标 NO-CAPABILITY-LOSS: TRUE
  -1  导致 01-PLAN.md 超 400 行,或突破 §7 任一预算
  -2  二阶复杂度(为解决 X 引入 Y,而 Y 又需要 Z)
```

| Net | 结果 |
|---|---|
| ≥ +3 | **采纳** |
| +1 ~ +2 | 备查(后轮可凭新证据重提) |
| ≤ 0 | 否决(无新证据不得重提) |

### 4 · 更新文件

- `docs/audit/01-PLAN.md`:**只写入采纳项。**改完检查行数,超 400 行则报告并停止,等人决定删什么
- `docs/audit/03-LEDGER.md`:追加本轮全部提案(含丢弃与否决)、更新状态区、Chesterton 调查结果填入原意图重建档案

### 5 · 打印收敛报告(原样输出,不可省略)

```
=== ROUND-N SUMMARY ===
Pin: spec-kit v0.16.4 / d1f50fc
推导: 一致 X / 新增 Y / 推不出 Z
PLAN 行数: NNN / 400

| ID | 类别 | 锚点 | Ben | Cost | 修正 | Net | 结果 |
|----|------|------|-----|------|------|-----|------|

丢弃: N 条    采纳: N 条    连续低采纳轮次: N

ROUND-N-VERDICT: CONVERGED | CONTINUE
=======================
```

### 收敛条件(任一成立即 CONVERGED)

| # | 条件 |
|---|---|
| C1 | 本轮无提案 Net ≥ +3 |
| C2 | 连续两轮采纳数 ≤ 1 |
| C3 | 已达第 5 轮 → 强制停止,标注 `FORCED-STOP: 未自然收敛` |

### 若 CONTINUE

输出一行**交接提示**,≤50 字,只说下一轮该重点看哪个方向。

**不要写摘要,不要总结本轮发现** —— 那些已在 PLAN 和 LEDGER 里,重复写会污染下一轮。

## 主控的铁律

| # | 规则 |
|---|---|
| O1 | **不要自己提意见。**你是主控,不是 Maker |
| O2 | **不要自己打 Cost 分。**Challenger 说了算 |
| O3 | **不要"帮忙润色"采纳项。**原样写入,失真即失效 |
| O4 | 采纳数为 0 是**好结果**,如实报告,不要找补 |
| O5 | 跑完这一轮就停。**下一轮由人开新 session 触发** |
