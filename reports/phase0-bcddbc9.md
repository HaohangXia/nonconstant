# Phase 0 · 边界锁定 —— 完成报告

> ⭐ **第一读者是下一个会话的模型,不是人。**
> ⚠️ 本报告绑定 commit **`bcddbc9`** —— ⛔ 脱离该 commit 的任何结论不可证伪。

> ⚠️ ⛔ **订正注记（2026-08-24，A010 改名；⛔ 原文一字未删）**
> 本报告正文里的 `.nonconstant/` 与 `nonconstant.yml`，在本报告**所绑定的那个 commit** 里
> 实际叫 `.latch/` 与 `latch.yml`。⭐ 项目已于 `8196615` 改名 `latch` → `nonconstant`
> （原名在**同领域**已被占，见 `LATCH-name-collision-blocks-release`）。
> ⛔ **历史未被改写** —— ⭐ 那个 commit 里就是旧名，那是事实；改了反而伪造。
> ⚠️ ⛔ **LEDGER 条目 ID 的 `LATCH-` 前缀一律保留** —— 标识符一旦被跨文件引用就是身份（**C11**）。

## pin

| 项 | 值 |
|---|---|
| 报告绑定 commit | **`bcddbc9`** `docs: lock Phase 0 module boundaries` |
| 上游 pin | `github/spec-kit` **v1.0.0** / `bca6790` / MIT |
| 阶段 | **Phase 0 · 边界锁定**(零代码) |
| 日期 | 2026-08-22 |

## frozen_contracts

本 phase 冻结的契约全部在 **`CLAUDE.md` §模块边界**(82 行),六条:

| ID | 契约 |
|---|---|
| B1 | 目录结构 —— 什么放哪 / 什么不许放;⛔ 根目录不得新增其它目录 |
| B2 | `vendor/spec-kit/` 只读,任何 phase 不得修改 |
| B3 | ⛔ nonconstant 不 import DevLoop 一行代码 |
| B4 | 判据实现在 `.nonconstant/`,清单与阈值在 `nonconstant.yml`;⭐ 二者为 Phase 1 受保护对象;⛔ 判据不得引用 `src/` |
| B5 | 完成报告路径 `reports/phase<N>-<HEAD 短 hash>.md` + 八个必填字段 |
| B6 | 新增文件 ≤ 8,已列出 1~7 与 1 个预留;⛔ 第 9 个 = amendment |

⛔ 改动上述任何一条 = **amendment**,须走独立入口 + 列影响面 + 要求下游重验。

## references_contracts

| 上游契约 | 出处 |
|---|---|
| §7a 复杂度预算(新增文件 ≤ 8) | `01-PLAN.md` §7a → 落点见 B6 |
| §7c 落盘纪律 / 契约变更走独立入口 | `01-PLAN.md` §7c → 落点见 `CLAUDE.md` 抬头 |
| §3 序 4 闸门可执行性(判据不得是常量) | `01-PLAN.md` §3 → 落点见 B4 |
| D-02 / D-03 上游只读、不删减 | `16-DECISIONS.md` → 落点见 B2 |
| D-05 不 import DevLoop | `16-DECISIONS.md` → 落点见 B3 |
| §10 Phase 3 报告绑 commit | `01-PLAN.md` §10 → 落点见 B5 |

## gate_results

⭐ 两条均在 **HEAD = `bcddbc9`、工作树干净(0 项)** 的**已提交**状态上求值。

| # | 命令 | 期望 | 实测退出码 |
|---|---|---|---|
| 1 | `test -f CLAUDE.md && grep -q '## 模块边界' CLAUDE.md` | 0 | ⭐ **0** |
| 2 | `[ "$(git status --porcelain -- '*.py' '*.sh' \| wc -l)" -eq 0 ]` | 0 | ⭐ **0** |

⚠️ 判据 2 由下达时的 `... | wc -l ⇒ 0` 订正而来 —— 原式 `wc` 退出码恒为 0,**是常量**,违反 §3 序 4。订正记于 `03-LEDGER.md` `LATCH-constant-criterion`。

## known_gaps

| # | 缺口 | 说明 |
|---|---|---|
| 1 | ⛔ **B2「未改上游」无可执行判据** | `vendor/` 在 `.gitignore` 内、未跟踪 ⇒ `git status` 看不见它。当前只靠"不去动它"。⭐ Phase 1 起须给出可执行判据(例:对 `vendor/spec-kit` 做内容指纹并比对) |
| 2 | ⚠️ **§10 Phase 3 的命名判据未定义求值时机** | `ls reports/phase$N-$(git rev-parse --short HEAD).md` 仅在「报告已写、**尚未提交**」的瞬间为真;报告一旦提交,HEAD 前移即失配 ⇒ 对提交后的仓库**恒假**(另一种常量)。⛔ 本轮未改 PLAN(余量 5 行),须在 Phase 3 前定清 |
| 3 | ⚠️ **两条判据只覆盖存在性,不覆盖内容正确性** | B1~B6 写得对不对,写不成退出码 ⇒ D5 可判定性天花板。⛔ 不得因两条绿就宣称"边界是对的" |
| 4 | ⚠️ **B6 的计数口径是本轮新定** | `docs/**` 与 `reports/**` 不计入 8 个文件预算 —— `01-PLAN.md` §7a 未写明此口径。⛔ 本轮未回写 PLAN |
| 5 | ⚠️ **`.nonconstant/` 与 `nonconstant.yml` 尚不存在** | B4 保护的对象要到 Phase 1 才被创建 ⇒ ⛔ 现在对它们做判据是常量,不得提前启用 |

## next_entry_conditions

Phase 1(测试守卫)开工前须全部满足:

1. ⭐ 本报告已提交,且 `CLAUDE.md` 在 `bcddbc9` 内 —— **已满足**
2. ⬜ 定下 `nonconstant.yml` 的受保护路径 glob 清单(至少含 `.nonconstant/**`、`nonconstant.yml`)
3. ⬜ 红检/绿检两条命令**先写出来**,再写实现(⛔ 不许先实现后补判据)
4. ⬜ 确认 `known_gaps` #5:Phase 1 创建 `.nonconstant/gates.sh` 与 `nonconstant.yml` 后,B4 的保护判据才非常量
5. ⚠️ `known_gaps` #2 不阻塞 Phase 1,但阻塞 Phase 3

## explicitly_out_of_scope

⛔ 下一会话**不得重提**以下已否决/未授权项:

- ⛔ 本 phase 写任何 `.py` / `.sh` / `.yml`(零代码是 Phase 0 的定义,不是保守)
- ⛔ 修全局 hook `block-no-verify` 的误拦(属环境维护,见 `STATUS.md` 已知债务)
- ⛔ 调整 §3 机制排名 / 给 hook 排期(等 **Q11**)
- ⛔ 实现隔离工位(§8 #15 撤回了「= git worktree」,目前无实现路径)
- ⛔ 删减或修改 `vendor/spec-kit/`(D-02 / D-03)

## human_confirmation

⛔ **模型不得代填。**

- [ ] 我读过 `CLAUDE.md` 的 B1~B6,确认它们是我要的边界
- [ ] 我确认 `known_gaps` #4 的计数口径(`docs/`、`reports/` 不计入 8 个文件)
- [ ] 我确认 Phase 0 可以关闭
