# latch

> ⭐ 本文件是 **Phase 0 冻结的契约**。⛔ 后续 phase 不得违反其中任何一条。
> ⛔ 要改这里的任何一条 = **amendment**,须走独立入口、列影响面、要求下游重验(`01-PLAN.md` §7c / §8 #13)。
> ⚠️ 与 `01-PLAN.md` 冲突时以 `01-PLAN.md` 为准;本文件只把它的约束**落到路径上**。

| 项 | 值 |
|---|---|
| 上游 pin | `github/spec-kit` **v1.0.0** / `bca6790` / MIT |
| 当前阶段 | **Phase 0 · 边界锁定**(零代码) |

---

## 模块边界

### B1 · 目录结构 —— 什么放哪

| 路径 | 放什么 | ⛔ 不许放 |
|---|---|---|
| `CLAUDE.md` | 本文件。**唯一**的边界契约 | ⛔ 方案、待办、进度 |
| `latch.yml` | 项目配置:受保护路径 glob · 判据清单 · 预算 | ⛔ 判定逻辑(逻辑在 `.latch/`) |
| `.latch/` | **判据实现**(shell)。⭐ Phase 1 起为受保护对象 | ⛔ 业务代码、⛔ 与判定无关的工具 |
| `docs/audit/` | 往返审计、决策记录、账本、STATUS | ⛔ 可执行文件 |
| `reports/` | phase 完成报告(见 B5) | ⛔ 手写笔记、⛔ 无 commit hash 的报告 |
| `vendor/` | 上游只读副本(见 B2) | ⛔ latch 自己的任何文件 |

⛔ **根目录不得新增其它目录。**需要新目录 = amendment。

### B2 · `vendor/spec-kit/` 的地位

- ⛔ **只读。任何 phase 不得修改其中任何文件。**latch 全部是新增文件。
- ⚠️ `vendor/` 在 `.gitignore` 内(未跟踪)⇒ ⛔ **"未改上游"无法用 `git status` 证明**,当前只能靠不去动它。⇒ 记入 `known_gaps`,Phase 1 起须给出可执行判据。
- ⛔ 不 fork、不改 `HookExecutor`、不删 `extensions/` 或 `presets/`(`16-DECISIONS.md` D-02 / D-03)。

### B3 · latch 与 DevLoop 的边界

- ⛔ **latch 不 import DevLoop 一行代码**,不作为依赖、不作为子模块、不复制其源文件(D-05)。
- ⭐ 允许且**必须**的关联:每条机制**引用** DevLoop 的一次具体事故作为实证 —— 引用写在 `docs/`,⛔ 不进 `.latch/`。
- ⛔ DevLoop 是 v1 且**已归档**;维护中的产物不得依赖归档物。

### B4 · 判据文件放哪

- 判据实现一律在 **`.latch/`**;判据的**清单与阈值**在 **`latch.yml`**。⛔ 判据不得写在 `docs/` 里当文字。
- ⭐ **`.latch/**` 与 `latch.yml` 是 Phase 1「测试守卫」的受保护对象** —— 被判定者改动它们必须判红。
- ⛔ 判据不得引用 `src/`(latch 无 `src/`,该路径下的判据恒过 = 常量,违反 §3 序 4)。
- ⛔ 新增或修改判据须先演示"一过一失败"(元判据,§10 Phase 3),未演示者不得启用。

### B5 · 完成报告

- 路径:**`reports/phase<N>-<HEAD 短 hash>.md`**。
- ⭐ hash 指向**包含该 phase 产物的那个 commit** —— 报告在其后写出,单独提交。
- 必填字段:`pin` · `frozen_contracts` · `references_contracts` · `gate_results`(每条含命令与退出码)· `known_gaps` · `next_entry_conditions` · `explicitly_out_of_scope` · `human_confirmation`。
- ⛔ 无 hash 的报告不算报告;⛔ `gate_results` 不得只写结论、必须带命令与退出码。

### B6 · 复杂度预算的落点

`01-PLAN.md` §7a:latch 新增文件 **≤ 8**。⭐ 计数口径:**可执行文件与配置文件**;⛔ `docs/**` 与 `reports/**` 不计入。

⭐ **名额按实际消耗顺序编号**(A002 对齐;⛔ 原表把「排期顺序」当成了「名额编号」)。

| # | 文件 / 目录 | 何时 | 状态 |
|---|---|---|---|
| 1 | `CLAUDE.md` | Phase 0 | ⭐ 已用 |
| 2 | `latch.yml` | Phase 1 | ⭐ 已用 |
| 3 | `.latch/gates.sh` | Phase 1 | ⭐ 已用 |
| 4 | **`amendments/`(整个目录)** | A001 | ⭐ 已用 |
| 5 | `.latch/scan-silent.sh` | Phase 2 | ⭐ 已用 |
| 6 | `.latch/meta-gate.sh` | Phase 3 | ⬜ |
| 7 | `.latch/report.sh` | Phase 3 | ⬜ |
| 8 | `workflows/latch/workflow.yml` | 接 spec-kit `shell` step | ⬜ |

⚠️ ⛔ **原「#8 预留」已被 A002 的对齐吃掉** —— 8 个名额**全部指名**。见 `amendments/A002-b6-slot-alignment.md`。

⭐ **模型 = 8 个指名名额 + 预算外余量**(A003)。⛔ 预留不是「第 8 格」,是**预算之外的口子** —— 放在格子里就会被挤掉(F5)。

| | 余量 |
|---|---|
| 用途 | ⭐ ① 修正自身的产物(amendment · 协议 · 勘误);⚠️ ② 计划外发现所必需的最小文件。⛔ 其它一律走名额 |
| 上限 | ⛔ **不设** —— 设了就又是一个会被吃光的预算(F5) |
| 约束 | ⭐ **用了必须在该 phase 完成报告的 `known_gaps` 登记**:用了什么 · 属①还是② · 为什么名额装不下。⛔ **用了不登记 = 静默(T5)** |

⚠️ ⛔ `01-PLAN.md` §7a 尚未同步「余量不计入」⇒ 口径暂不一致,见 `amendments/A003-budget-headroom.md` `known_gaps` #1。

⛔ **第 9 个文件 = amendment。**⛔ 用"拆成多个小文件"绕过计数,同样是 amendment。

---

## ⛔ 零代码约束(仅 Phase 0)

Phase 0 期间 ⛔ 不得新增 `.py` / `.sh` / `.yml`。判据:

```
[ "$(git status --porcelain -- '*.py' '*.sh' | wc -l)" -eq 0 ]
```

⚠️ 该约束**随 Phase 1 开始自动解除** —— 解除不需要 amendment,因为它本就只约束 Phase 0。
