# latch

**给 AI 编码工作流装一道闸：让「我检查过了」变成一条能跑的命令。**

---

## 问题

你让一个 agent 实现功能并跑测试。它报告：**全部通过。**

三种情况会产生同一句话：

| | 实际发生的 |
|---|---|
| 1 | 测试真的通过了 |
| 2 | ⛔ 测试被改成了能通过的样子 |
| 3 | ⛔ 测试根本没跑到那段代码 |

**你从报告里分辨不出是哪一种。**

而这不是模型不够好的问题 —— 是**判定者与被判定者是同一方**的问题。考卷由考生自己批改，无论考生多诚实，结果都不可核。

## latch 做什么

latch 把「检查」从**一句话**变成**一条命令 + 一个退出码**。

```
0  过        1  未过        2  ⛔ 闸自身故障 —— 判不了
```

⭐ 第三档是关键：**latch 绝不因为「判不了」而返回 0。**扫描目标不存在、配置缺失、上游导不进来 —— 一律判 2，⛔ 而不是「没发现问题 ⇒ 放行」。

判据全部非交互、全部以退出码作答（⛔ 条数不在这里复述——见 `docs/audit/STATUS.md`，那里有 `status-facts` 盯着）：

| 判据 | 它回答的问题 |
|---|---|
| `criteria-guard` | 被判定者改动判据文件了吗？ |
| `silent-scan` | 有失败被吞掉、不产生任何可观测输出吗？ |
| `meta-gate` | 每条判据都演示过「一过一失败」吗？（⛔ 没演示的是常量，不是判据） |
| `report-pin` | 完成报告绑到真实存在的提交了吗？ |
| `status-facts` | 「现在什么状态」这份文档，和仓库对得上吗？ |
| `waiver-expiry` | 写下的豁免到期了吗？（⛔ 没判据的到期 = 没有到期） |
| `upstream-semantics` | 上游的行为语义还是我们依赖的那两条吗？ |
| `upstream-pin` | 上游那份就是说好的那份吗？ |
| `doc-budget` | 写下的行数上限有人查吗？ |
| `readme-runnable` | 本文里的命令还能跑吗？三条披露还在吗？（⛔ `bootstrap`，不随安装分发） |

## 30 秒 demo：考卷不能由考生自己改

⭐ 这一条演示 latch 的**核心主张**。全程约 30 秒，在一个全新空目录里跑：

```bash
mkdir demo && cd demo && git init -q
git config user.email you@example.com && git config user.name you
```

装进来（`<latch>` 换成你 clone 下来的 latch 目录）：

```bash
bash <latch>/install.sh .
git add -A && git commit -q -m "chore: install latch"
```

⭐ **绿**：干净状态下，判据守着的文件没被动过 ——

```bash
bash .latch/gates.sh
```

⇒ 退出码 **0**。

⛔ 现在扮演一个想让自己过关的 agent：**把判据清单改掉**，让它不再保护自己。

```bash
sed -i 's|^  - .latch/\*\*$|  - nothing/**|' latch.yml
bash .latch/gates.sh
```

⇒ 退出码 **1**，并打印出被动过的文件。

⭐⭐ **这就是全部**：判据的清单存放在**它自己保护的文件**里 —— 改它，当场判红。⛔ 一句「我没动过判据」做不到这件事。

复原：

```bash
git checkout -- latch.yml
```

## 装完之后怎么用

安装器只装**可分发**的判据（`scope != bootstrap`），⛔ 不装 latch 自举专用的那条。装完后有四处需要你填 —— ⭐ 每一处**没填时对应判据判 2 并指名缺什么**，⛔ 不会悄悄放行：

| 填什么 | 不填的后果 |
|---|---|
| `subjects.status` / `subjects.plan` | `status-facts` / `waiver-expiry` ⇒ **2** |
| `doc_budgets` | `doc-budget` ⇒ **2** |
| `expected_assertion_classes` | `status-facts` ⇒ **2** |
| `protected`（改成你项目的路径） | ⚠️ ⛔ **无判据** —— 见下面第三条已知缺口 |

跑全部判据：

```bash
for g in .latch/*.sh; do bash "$g" >/dev/null 2>&1; echo "$g=$?"; done
```

⭐ **想让它在提交时自动跑?**建一个 `.git/hooks/pre-commit`,里面调一个跑全部判据的脚本
(latch 自己就这么做的,见 `.latch/pre-commit.sh`)。⚠️ ⛔ 安装器**不装它** —— `.git/hooks/`
不受版本控制,装了也不会跟着仓库走。

⚠️ ⛔ 别用管道读退出码 —— 你读到的会是管道最后一个命令的。这个坑 latch 自己踩过两次。

## ⛔ latch 不做什么

<!-- latch:disclosure:checkable-not-correct -->

⭐⭐ **判据保证「声明可核」，⛔ 不保证「判断正确」。**

latch 能测：**你说的和仓库里的是否一致**。
latch ⛔ **测不了**：你说的那句话背后的**推理**对不对。

⚠️ 实例（本项目自己踩的）：一条判据声明「这个到期了」，判据如实判红 —— ⛔ 但它不会告诉你「你当初估的原因就是错的」。解开那个结的是一次证伪，**不是判据**。那一步仍然靠人。

<!-- latch:disclosure:mechanized-ratio -->

⭐⭐ **latch 自己的操作协议有 33 条，其中只有 5 条是机器化的。**

⛔ 其余 28 条要么是尚未实现的缺口，要么是**原理上不可判定**（比如「发现必须说」——机器判不了你有没有发现）。⇒ ⛔ 装上 latch **不等于**那 33 条都被执行了。

⚠️ 这个比例会变。测定于 **2026-08-23**，复算 —— ⭐ 只读**分类列**：

```bash
awk -F'|' '/^\| *(R|K|F|C)[0-9]+ *\|/ { n++; if ($3 ~ /已机器化/) m++ } END { printf "%d / %d\n", m, n }' docs/audit/18-PROTOCOL.md
```

⛔ 别直接 `grep -c 已机器化` —— 会多数一条，因为 C12 的**规则正文里**也含这三个字。⚠️ 这个坑写本文时当场踩到。

<!-- latch:disclosure:known-gaps -->

⭐⭐ **四项已知缺口，全部有据可查（`01-PLAN.md` §6 Q19）：**

| | 缺口 |
|---|---|
| A | 判据的失败输出**没有机器可读的类型码**，⇒ 红检只能靠退出码，⛔ 而「工具没跑起来」也返回非 0 |
| B | ⛔⛔ **自遮蔽**：给 `protected` 条目加个行尾注释，glob 就变成恒不命中 ⇒ **改着被保护文件却判 0**。⇒ ⛔ 上面 demo 演示的那道防线，**可以用一行注释绕过** |
| C | 红检**没有基线自检** ⇒ 探针本身失败会被记成「判据判红了」 |
| D | `CLAUDE.md` 的预算表状态列**没有判据**盯着 |

⛔ **这些不是「以后会修」的场面话** —— 触发条件写死了：**首个外部用户报告相关问题**。⚠️ 在那之前不修，因为无使用者时可靠性的边际收益为零，⭐ 而机会成本是全部。

## 与 spec-kit 的关系

latch 建在 [github/spec-kit](https://github.com/github/spec-kit) **v1.0.0**（`bca6790`）之上，作为 git submodule 固定。

- ⛔ **不 fork、不改上游一个字符** —— `upstream-pin` 判据盯着这一点
- ⭐ latch 依赖上游的**两条行为语义**（`shell` step 的退出码语义、`gate` step 非 TTY 不自动放行）
- ⭐ `upstream-semantics` **真跑上游代码观察行为**来验证，⛔ 不比对源码文本 —— 否则一次合法重构就会误报

## 现状

| | |
|---|---|
| 阶段 · 判据条数 · 现在做什么 | ⭐ 见 `docs/audit/STATUS.md` —— ⛔ 这里不复述：复述的数字会过期，而 `status-facts` 只盯着 STATUS |
| 可安装 | ⭐ 是（`install.sh`） |
| 编排层 | ⛔ 无（Q17，⚠️ 未排期） |

每个阶段有一份绑定 commit 的完成报告（`reports/`），每次契约变更有一份 amendment（`amendments/`），每条经验事实有一个可核条目（`docs/audit/03-LEDGER.md`）。

## 许可

上游 spec-kit 为 MIT。latch 自身的文件见仓库根目录。
