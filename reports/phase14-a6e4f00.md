# Phase 14 · 发布 —— 完成报告

> ⭐ **第一读者是下一个会话的模型，不是人。**
> ⚠️ 本报告绑定 commit **`a6e4f00`** —— ⛔ 脱离该 commit 的任何结论不可证伪。
> ⚠️ ⛔ **推送尚未发生** —— ⭐ 那一步由用户执行（A011 §4 ④）。本报告交付的是「可推送状态」。

## pin

| 项 | 值 |
|---|---|
| 报告绑定 commit | **`a6e4f00`** `docs: license and attribution` |
| 上游 pin | `github/spec-kit` **v1.0.0** / `bca6790` |
| 阶段 | **Phase 14 · 发布**（依据 `amendments/A011-release.md`） |
| 日期 | 2026-08-24 |

## frozen_contracts

| ID | 契约 | 落点 |
|---|---|---|
| P14-C1 | ⭐ **许可 = MIT**，与上游一致 | `LICENSE` |
| P14-C2 | ⭐⭐ **归属四条一条不许少**，且绑在**锚点**上（⛔ 不绑措辞）—— spec-kit · DevLoop v1 · Loop Engineering · 同域项目 | `README.md` `nonconstant:disclosure:attribution` |
| P14-C3 | ⛔⛔ **归属里的外部项目名，任何脚本一个字不许改** —— ⚠️ 它们正是「为什么改名」的**证据本身** | `LATCH-global-replace-cannot-distinguish-ownership` |
| P14-C4 | ⛔ **推送由用户执行，模型不代劳** —— ⭐ 但命令逐条列出 | 本报告 §推送命令 |

## references_contracts

| 上游契约 | 出处 | 兑现 |
|---|---|---|
| **A011** 四件 + 推送前五项 | `amendments/A011-release.md` | ⭐ 全做 |
| **P11-C3** 披露绑锚点 ⛔ 不绑措辞 | `reports/phase11-*.md` | ⭐ 归属是**第四个**锚点，⛔ 与前三个并列 |
| **C2** 一过一失败 | `18-PROTOCOL.md` | ⭐ 归属锚点当场演示（绿 0 / 抹掉锚点 1） |
| **C11** 编号 = 身份 | 同上 | ⭐ 用**下一个未用编号 14** |
| `LATCH-name-collision-blocks-release` | `03-LEDGER.md` | ⭐⭐ **阻塞已解除**（Phase 13 改名） |

## gate_results

### ⭐ 推送前最后一遍（A011 §5，⛔ 缺一不可）

| # | 检 | 实测 |
|---|---|---|
| 1 | **十条判据** | ⭐ **全 0** |
| 2 | **demo 在全新空仓** | ⭐ 安装 0 · 提交 0 · **绿 0** · ⛔⛔ **红 1** · **回绿 0** |
| 3 | `readme-runnable` | ⭐ **0**（「2 条命令引用均存在，**四条**必含内容齐全」） |
| 4 | ⚠️ **clone 后 submodule 未取回** | ⭐ **实测与 README 所写完全一致**：`vendor/spec-kit` **0 项** ⇒ 八条判 **0**、`upstream-pin` 与 `upstream-semantics` 判 **2**，消息「submodule 未取回 —— ⛔ 没测到 ≠ 通过；请跑 `git submodule update --init`」 |
| 5 | ⭐ **全仓 `latch` 字样分类** | ⭐ **全部应保留**（见下）。⚠️ ⛔ **订正（2026-08-24）**：本行原写「36 处」—— ⛔ 那是在**不完整集合**上数的（`grep --include` 只覆盖 `.md/.yml/.sh/.py`）。⭐ 不限扩展名的全量重扫为 **309 处**，⛔ 分类结论不变（全部应保留），⚠️ 但**数字曾是假的** ⇒ `LATCH-incomplete-set` 同族 |

### ⭐ 残留 `latch` 字样的分类（⛔ 逐条，⛔ 非抽样）

| 类 | 处数 | 判定 |
|---|---|---|
| ① LEDGER 条目 ID（`LATCH-`） | **5 行**（涉 46 个 ID） | ⭐ **保留** —— 标识符 = 身份（**C11**） |
| ② 外部项目名（`latchagent` · `latchbio` · `runlatch`） | **5** | ⭐ **保留** —— ⛔ 别人的项目，改了就是假话 |
| ③ 报告注记里的历史路径（`.latch/`） | **13** | ⭐ **保留** —— 那个 commit 里就是旧名 |
| ④ 自述改名 + `.claude/` 文件名 | **8** | ⭐ **保留** |
| ⑤ 明标「旧名 `latch`」 | **2** | ⭐ **保留** |
| ⑥ 其余（`A010` 描述改名本身：`.latch/` → `.nonconstant/`） | **3** | ⭐ **保留** —— 逐条读过 |
| ⑦ ⛔ **上轮漏扫**：`docs/audit/15-HOOKLAB-calls.log` | **42 行** | ⭐ **保留** —— 那是 2026-08-22 的**真实 hook 日志**，里面的 `C:\pg\latch` 与临时目录 `latch-hooklab` 当时**就是那个路径**。⛔ 改了等于伪造日志（与「报告不改历史」同一条原则）。<br>⚠️ ⛔ **漏扫根因**：`.log` 不在我扫描与改名脚本的扩展名白名单里 |
| **⛔ 本项目自称** | **0** | ⭐ **已全改** |

### ⭐ 归属锚点的红绿（C2）

| 检 | 实测 |
|---|---|
| 绿 · 真源 README | ⭐ **0**「四条必含内容齐全」 |
| 红 · 抹掉 `nonconstant:disclosure:attribution` | ⭐ **1** · 点名缺哪个锚点 |

⚠️ ⛔ **判据本身也改了** —— 加锚点前它只查三条，⭐ 第四条**没人守**。⇒ 现在 `readme-runnable` 查四条。

## ⭐ 归属章节：锚点与位置

| | |
|---|---|
| 锚点 | `<!-- nonconstant:disclosure:attribution -->` |
| 位置 | `README.md` `## 归属` 之前，⭐ 紧接「装之前先知道这些」（submodule 说明）之后 |

四条内容：

| 归属对象 | 写清了什么 |
|---|---|
| **spec-kit** | MIT · submodule pin `bca679051abb…` · ⛔ **不含其代码**；⭐ 依赖的两条行为语义 + `upstream-semantics` 真跑验证 |
| **DevLoop（v1，已归档）** | ⭐ 每条原则**指向具体事故**（08-17 退化 3 天无人知 · 86 GB 撑爆 C 盘）；⛔ **不 import 一行** |
| **Loop Engineering（Addy Osmani）** | ⭐⭐ 定位句「**LE 是油门的工程学；这是刹车和仪表的工程学**」建在其框架上 · **Maker/Checker 来自 LE** · ⭐ **三个缺口是他自己列的** |
| **同域项目** | axiom · groundtruth · nah · Mantiz，各附**它们强在哪**（4 个运行时 / 1,272 turns / 101,194 次公开语料）；⚠️ ⛔ 明写「**如果你要的是一个成熟的工具，去看它们**」 |

## ⭐ 推送命令（⛔ 由用户执行，⛔ 模型不代劳）

⚠️ ⛔ **先在 GitHub 上手动建一个空仓，名字必须叫 `nonconstant`**（⛔ 不要勾选 README/LICENSE/gitignore）。

```bash
git remote add origin https://github.com/<你的用户名>/nonconstant.git
git tag -a v1.0.0 -m "nonconstant v1 — see RELEASE-NOTES.md"
git push -u origin master
git push origin v1.0.0
```

⚠️ 推完再验一次「别人 clone 下来是什么样」：

```bash
git clone --recurse-submodules https://github.com/<你的用户名>/nonconstant.git /tmp/nc-check
```

## known_gaps

| # | 缺口 | 说明 |
|---|---|---|
| 1 | ⚠️ **动用 A003 预算外余量，登记如下** | **用了什么**：`LICENSE`（21 行）· `RELEASE-NOTES.md`（18 行）。**属哪类**：⭐ **① 修正自身的产物** —— 发布所必需的法律文件与说明。**为什么名额装不下**：B6 八格全部兑现（Phase 12 用掉第 8 格） |
| 2 | ⚠️ **`.claude/` 三个文件名仍是 `latch-*`** | ⭐⭐ **刻意保留**：它们不是产品，是用户敲命令的入口；改文件名 = 改 `/latch-audit` = 改用户的肌肉记忆。⭐ 内容已随改。⇒ ⭐ **一个刻意保留的不一致，写下来就不是遗漏** |
| 3 | ⛔ **推送尚未发生** | ⭐ 本报告交付的是**可推送状态**，⛔ 不是「已发布」。⇒ ⚠️ 推完须复验 clone |
| 4 | ⚠️ **GitHub 仓名须手动建对** | ⛔ 无判据 —— ⭐ 建错了整个改名白做 |
| 5 | ⚠️ **未验 Linux/macOS** | ⛔ 全部实测在 Windows + Git Bash |
| 6 | ⚠️ **本地目录名仍是 `C:/pg/latch`** | ⭐ 与项目标识无关，⛔ 不影响发布 |

## next_entry_conditions

1. ⭐ 本报告已提交，`LICENSE` + 归属在 `a6e4f00` 内 —— **已满足**
2. ⬜ **用户执行推送**（命令见上）
3. ⚠️ 推送后复验：`git clone --recurse-submodules` ⇒ 十条判据全绿
4. ⚠️ **Q17 / Q19** 触发条件不变 —— ⭐ Q19 的触发条件（**首个外部用户报告**）从推送那一刻起**才可能被满足**

## explicitly_out_of_scope

⛔ 下一会话**不得重提**：

- ⛔ 删掉归属四条中的任何一条（P14-C2；⭐ 判据会当场判红）
- ⛔ 让脚本碰归属里的外部项目名（P14-C3）
- ⛔ 改 `.claude/` 三个文件名（`known_gaps` #2：**刻意保留**）
- ⛔ 模型代替用户推送（P14-C4）
- ⛔ 把发布说明扩成 CHANGELOG（A011 §4 ③：一段话即可）

## human_confirmation

⛔ **模型不得代填。**

- [ ] 我确认 MIT 许可
- [ ] 我确认归属四条的内容与措辞（尤其 Loop Engineering 那条）
- [ ] 我确认「如果你要的是一个成熟的工具，去看它们」这句留在 README 里
- [ ] 我确认 `.claude/` 三个文件名刻意保留
- [ ] 我已执行推送命令，并复验了 clone
- [ ] 我确认 Phase 14 可以关闭
