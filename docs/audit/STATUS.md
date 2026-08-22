# STATUS — 现在做什么

> **本文件是唯一记录"现在做什么"的地方。**
> `01-PLAN.md` 记"方案是什么"。两者职责不同,不要混写。
> ⛔ 上限 60 行。

## 当前状态

| 项 | 值 |
|---|---|
| 日期 | 2026-08-22 |
| 最后 commit | `14346eb`(17 号决策记录);本文件随后一次 docs 提交更新 |
| 上游 pin | spec-kit **v1.0.0** / `bca6790` |

## latch 现在有什么

⛔ **零行代码。**只有 `docs/` + `.claude/agents/` + `vendor/spec-kit`(只读参考)。

## DevLoop 侧进度

| | 项 | 内容 |
|---|---|---|
| ✅ | 第 0 条 | 提交 + phase 报告(`a69c7c7`) |
| ✅ | Q1 | fixture 动态复制,仓库内零静态副本 |
| ✅ | Q2 | 换函数作用域扫描 ⇒ 0 处真静默(原 10 处含误报) |
| ✅ | 核验 | 六项任务完成,产出五条推翻(已折进 `01-PLAN.md`) |
| ✅ | 追加核验 | 编排三层归类 + Task 工具实测(`dca84db`,14 号) |
| ✅ | 决策记录 | DevLoop 侧独有的技术决定(`14346eb`,17 号) |
| ⬜ | ① | 验扫描器:在清理修复**之前**的 commit 上跑,必须命中 `worktree.py::remove` |
| ⬜ | ② | 三处 helper:改成非零即抛,或开一条 waiver |
| ⬜ | ④ | 第七项(pytest 闸)拿到首个非 FAIL |
| ⬜ | ③ | 三次取上界 → 定预算 → 落元判据 |
| ⬜ | ⑤ | 接 spec-kit 内建 shell step,红检 + 绿检都做 |

## latch 侧下一步

- ✅ **Q8 答死**(`dca84db`):Task 工具的隔离**不够** —— 作用域不可控 + 不拦跨边界写
- ✅ **hook 实验已跑**(`5a29b5d`,15 号):`Write`/`Edit` 事前阻断(主会话 **与** sub-agent);⛔ `Bash` 两次均未拦
- ⬜ **Phase 0 · 边界锁定**(`01-PLAN.md` §10)—— 零代码,可以开工
- ⛔ **Phase 4(hook)不排期**,等 Q11

## ⛔ 当前阻塞(两条,都不挡 Phase 0)

1. **Q11 · hook 排名重估** —— 实证已从「只覆盖架构 A」收窄为「覆盖 A + B 的一半」(§8 #17)
2. **隔离工位怎么实现** —— §3 排名第 1,但 §8 #15 撤回了「= git worktree」⇒ ⛔ 目前无实现路径

## ⚠️ 2026-08-22 越权事件(已落盘)

只读禁令下,一个 sub-agent 写盘并提交(`14346eb`)。⇒ **prompt 禁令对 sub-agent 免疫度为 0。**
⭐ 与 15 号构成同场景 A/B 对照(prompt 未拦住 / hook 拦住了)。详见 `03-LEDGER.md` `LATCH-subagent-override`。

## ⚠️ 已知债务(⛔ 不属 latch 核验范围)

⭐ **`01-PLAN.md` 行数预算已由 A001 改范围 + 降级**(`amendments/A001-line-budget-scope-and-level.md`):
现行结论(档案 = §2/§8/§9,**其余一律计入**)**295 / 400**,余量 105;全文 407 行。级别 **soft**。
⛔ **但 waiver 机制未实现** ⇒ 在它存在之前该上限**实为建议**(A001 `known_gaps` #1)。
⚠️ ⭐ 该上限本身是**代用品判据**(§6 Q15),⛔ 精简前先看 `03-LEDGER.md` `LATCH-proxy-criterion` —— 搬去 LEDGER 不算精简。

⚠️ 全局 hook(`block-no-verify`,`~/.claude` 侧)**误拦**含 `grep -n` + `commit` 的命令,连带拦 `--amend`。
根因见 `03-LEDGER.md` `LATCH-hook-three-legs`。⭐ 规避:命令里避开 `-n` 与 `commit` 同时出现。
⚠️ **复发计数:4 次**(A001 轮 3 次连拦 + C7 轮 1 次)。⭐ **2026-08-22 重估:维持「⛔ 不修」** ——
代价经查**仅为多跑几条命令**,⛔ **未曾改变任何做法或产物**(逐条核过,见该轮报告)。
⚠️ 复发次数须持续更新 —— ⛔ 一个不更新的计数等于没计数(F1)。

DevLoop 侧 `%TEMP%` 下残留 **249** 条 worktree 登记(目录仍在,不算 prunable)。
来源 = 闸自己的一次性 worktree(`devloop/gates.py:619`,`prefix="devloop-wt-"`)。
⛔ 清理属 **DevLoop 维护**。
