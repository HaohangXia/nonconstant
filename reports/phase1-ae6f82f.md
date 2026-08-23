# Phase 1 · 测试守卫(判据文件不得被被判定者修改)—— 完成报告

> ⭐ **第一读者是下一个会话的模型,不是人。**
> ⚠️ 本报告绑定 commit **`ae6f82f`** —— ⛔ 脱离该 commit 的任何结论不可证伪。

> ⚠️ ⛔ **订正注记（2026-08-24，A010 改名；⛔ 原文一字未删）**
> 本报告正文里的 `.nonconstant/` 与 `nonconstant.yml`，在本报告**所绑定的那个 commit** 里
> 实际叫 `.latch/` 与 `latch.yml`。⭐ 项目已于 `8196615` 改名 `latch` → `nonconstant`
> （原名在**同领域**已被占，见 `LATCH-name-collision-blocks-release`）。
> ⛔ **历史未被改写** —— ⭐ 那个 commit 里就是旧名，那是事实；改了反而伪造。
> ⚠️ ⛔ **LEDGER 条目 ID 的 `LATCH-` 前缀一律保留** —— 标识符一旦被跨文件引用就是身份（**C11**）。

## pin

| 项 | 值 |
|---|---|
| 报告绑定 commit | **`ae6f82f`** `feat: lock Phase 1 criteria guard` |
| 上游 pin | `github/spec-kit` **v1.0.0** / `bca6790` / MIT |
| 阶段 | **Phase 1 · 测试守卫**(§3 排名 2,⭐ 唯一有真拦截实证的机制) |
| 日期 | 2026-08-22 |

## frozen_contracts

| ID | 契约 | 落点 |
|---|---|---|
| P1-C1 | **受保护路径 = `nonconstant.yml` + `.nonconstant/**`** —— 被判定者改动其一 ⇒ hard 红,⛔ 不可 waiver | `nonconstant.yml:protected` |
| P1-C2 | **判据清单与阈值在 `nonconstant.yml`,判定逻辑在 `.nonconstant/`** —— 兑现 `CLAUDE.md` B4 | `nonconstant.yml:gates` |
| P1-C3 | **三档退出码:`0` 过 / `1` 未过 / `2` 闸自身故障** —— ⛔ 闸绝不因自身故障返回 0 | `.nonconstant/gates.sh` |
| P1-C4 | **base 由调用方给**:无参 = 工作树相对 `HEAD`;带参 = `<base>..HEAD` | `.nonconstant/gates.sh` 用法 |

⛔ 改动上述任何一条 = **amendment**。

## references_contracts

| 上游契约 | 出处 | 本 phase 如何兑现 |
|---|---|---|
| B4 判据放 `.nonconstant/` + `nonconstant.yml`,⛔ 不得引用 `src/` | `CLAUDE.md` | ⭐ 已兑现;`protected` 清单内注明了 `src/**` 恒不命中 = 常量 |
| B6 新增文件 ≤ 8 | `CLAUDE.md` | 本轮用掉 **#2 `nonconstant.yml`**、**#3 `.nonconstant/gates.sh`** |
| §3 序 2 M1 判定者独立性 | `01-PLAN.md` | 判定者 = shell 退出码,⛔ 非模型意见 |
| §5 P4 闸门三级制(hard 不可 waiver) | `01-PLAN.md` | `nonconstant.yml:gates[0].level: hard` |
| D-17 红检必须配绿检 | `16-DECISIONS.md` | ⭐ 见 `gate_results`,红绿都做了 |
| §10 元判据(一过一失败) | `01-PLAN.md` | ⭐ **当场演示**,⛔ 未等 Phase 3 |

## gate_results

⭐ 全部在 **HEAD = `ae6f82f`、工作树干净** 的已提交基线上求值;每次探针后 `git checkout --` 复原,收尾时工作树 **0 项**。

| # | 检 | 命令 | 期望 | 实测退出码 |
|---|---|---|---|---|
| 1 | 基线 | `bash .nonconstant/gates.sh`(干净树) | 0 | ⭐ **0** |
| 2 | **绿检** | 只改普通文件(`docs/audit/README.md`)后 `bash .nonconstant/gates.sh` | 0 | ⭐ **0** |
| 3 | **红检 A** | 改 `nonconstant.yml` 后 `bash .nonconstant/gates.sh` | 非 0 | ⭐ **1** |
| 4 | **红检 B** | 改 `.nonconstant/gates.sh` 后 `bash .nonconstant/gates.sh` | 非 0 | ⭐ **1** |
| 5 | 故障档 | `bash .nonconstant/gates.sh no-such-ref` | 非 0 且 ≠ 1 | ⭐ **2** |
| 6 | 规避档 A | 删 `nonconstant.yml` 后跑闸 | 非 0 | ⭐ **2**(闸自身故障,⛔ 不是过) |
| 7 | 规避档 B | 删 `.nonconstant/gates.sh` 后跑闸 | 非 0 | ⚠️ **127**(shell 找不到命令,见 `known_gaps` #2) |

⇒ ⭐ **一过一失败已当场演示(#2 vs #3/#4)⇒ 该判据不是常量。**

## known_gaps

| # | 缺口 | 说明 |
|---|---|---|
| 1 | ⛔ **§10 Phase 1 的字面写法不成立** | §10 写的是 `touch nonconstant.yml && bash .nonconstant/gates.sh` ⇒ 非 0。**实测 ⇒ `0`** —— `touch` 只改 mtime,而内容判据看不见 mtime。⭐ 本轮验收改用本次指令的措辞(**「改」**nonconstant.yml)才成立。⇒ **与 `LATCH-constant-criterion` 同族第 3 例**。⛔ 未改 `01-PLAN.md`(余量 1 行,按铁律停下报告) |
| 2 | ⚠️ **「删掉闸」只靠调用方守住** | 删 `.nonconstant/gates.sh` 后退出码是 **127**(shell 报的),⛔ 不是 nonconstant 的 2。若编排层把「闸文件不存在」当成「没配闸 ⇒ 跳过」,就变成**静默通过** —— 正是 `dossier.py:147`「SKIP/VOID = 没验,⛔ 不是验过没事」那条教训。⇒ Phase 3 接 spec-kit 时必须验:**闸缺失判 FAIL/VOID,⛔ 绝不判 PASS** |
| 3 | ⚠️ **base 可被选择** | P1-C4 让调用方给 base。若被判定者能自己选 base,它可以选一个「改判据之后」的提交当基线 ⇒ 改动落在基线里,闸看不见。⇒ **base 必须由操作者给**,⛔ 不得由被判定者给。当前无编排层,⛔ 该约束尚无处安放 |
| 4 | ⚠️ **glob 表达力不足** | 用 bash `case` 匹配,`*` 与 `**` 都跨 `/` ⇒ ⛔ 表达不了「只匹配单层」。当前清单不需要,⚠️ 写更精细的清单时会踩 |
| 5 | ⚠️ **Q12 未触及** | B4 未区分「判据」与「判据比对的数据」。本轮受保护清单内**没有数据文件**,故未暴露;⛔ Phase 2 若引入 fixture 基准数据即会撞上 |
| 6 | ⚠️ **只验了本地工作树** | 未验「被判定者先 commit 再改写历史(`amend`/`rebase`)」这条路径 |

## next_entry_conditions

Phase 2(静默失败扫描)开工前须满足:

1. ⭐ 本报告已提交,`nonconstant.yml` + `.nonconstant/gates.sh` 在 `ae6f82f` 内 —— **已满足**
2. ⬜ 红/绿两条命令**先写出来**再写实现(⛔ 不许先实现后补判据)
3. ⬜ 决定 fixture 放哪 —— ⚠️ 直接触发 `known_gaps` #5 / **Q12**:基准数据若进 `.nonconstant/`,合法更新数据会被 criteria-guard 误报
4. ⬜ 扫描单位 ⛔ 必须是**函数作用域**,不用行数窗口(实测误报率 10% → 0)
5. ⚠️ `known_gaps` #1 不阻塞 Phase 2,但阻塞任何引用 §10 Phase 1 字面判据的动作

## explicitly_out_of_scope

⛔ 下一会话**不得重提**:

- ⛔ 把 criteria-guard 改成 mtime 判据(为了让 §10 的 `touch` 写法成立)—— 那是**改判据迁就措辞**
- ⛔ 给 hard 闸开 waiver 通道(`level: hard` 的定义就是不可 waiver)
- ⛔ 现在建编排层 / 定安装形态(**Q13**:Phase 1~3 完成后再定)
- ⛔ 修全局 hook `block-no-verify` 的误拦(属环境维护)
- ⛔ 实现隔离工位(§8 #15 撤回了「= git worktree」,目前无实现路径)
- ⛔ 改 `CLAUDE.md` B2 / B4(须走 amendment,见 Q12 / Q14)

## human_confirmation

⛔ **模型不得代填。**

- [ ] 我确认受保护清单 `nonconstant.yml` + `.nonconstant/**` 就是我要保护的范围
- [ ] 我确认 `known_gaps` #1(§10 字面写法不成立)的处置 = 记录而非改判据
- [ ] 我确认 Phase 1 可以关闭
