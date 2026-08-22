# STATUS — 现在做什么

> **本文件是唯一记录"现在做什么"的地方。**
> `01-PLAN.md` 记"方案是什么"。两者职责不同,不要混写。
> ⛔ 上限 60 行。

## 当前状态

| 项 | 值 |
|---|---|
| 日期 | 2026-08-22 |
| 最后 commit | `dca84db` |
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
| ⬜ | ① | 验扫描器:在清理修复**之前**的 commit 上跑,必须命中 `worktree.py::remove` |
| ⬜ | ② | 三处 helper:改成非零即抛,或开一条 waiver |
| ⬜ | ④ | 第七项(pytest 闸)拿到首个非 FAIL |
| ⬜ | ③ | 三次取上界 → 定预算 → 落元判据 |
| ⬜ | ⑤ | 接 spec-kit 内建 shell step,红检 + 绿检都做 |
| ✅ | 追加核验 | 编排三层归类 + Task 工具实测(`dca84db`,14 号报告)|

## latch 侧下一步

- ✅ **Q8 答死**(`dca84db`):Task 工具的隔离**不够** —— 作用域不可控 + 不拦跨边界写
- ⬜ **hook 实验**:靶场已备好,⛔ 必须换新 session 跑(见下)
- ⬜ 然后才写第一行代码

## ⛔ 当前唯一阻塞

**架构 B 有没有强制层,未测。**worktree 已确证不拦 ⇒ 只剩 PreToolUse hook。

- 靶场:`%TEMP%/latch-hooklab/`,步骤见其中 `RUN-ME.md`
- ⛔ **不能在 DevLoop session 里跑** —— 工位会落进 DevLoop 仓
- ⭐ 会拦 ⇒ M5 是架构 B 下**唯一**能强制的机制,重提优先级
- ⛔ 不会拦 ⇒ 架构 B 在 Claude Code 里**没有任何强制层**,须重估可行性

## ⚠️ 已知债务(⛔ 不属 latch 核验范围)

DevLoop 侧 `%TEMP%` 下残留 **249** 条 worktree 登记(目录仍在,不算 prunable)。
来源 = 闸自己的一次性 worktree(`devloop/gates.py:619`,`prefix="devloop-wt-"`),
mtime 窗口 **2026-08-21 23:56 → 08-22 02:53**(≈84 个/小时)。
⛔ 清理属 **DevLoop 维护**,不属 latch 核验范围。
