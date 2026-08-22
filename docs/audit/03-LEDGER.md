# 03 · LEDGER — 跨轮账本

> **这是 loop 的脊柱。**agent 会忘,仓库不会忘。
> 每轮结束必须追加。**只增不改**(除非修正笔误)。
> 下一轮开始前必须先读本文件 —— 准入门槛 `G5` 靠它防重复提案。

---

## 状态

| 项 | 值 |
|---|---|
| 已完成轮次 | 1 |
| 累计提案数 | 4(另丢弃 6) |
| 累计采纳数 | 2 |
| 连续低采纳轮次 | 0 |
| 收敛状态 | **CONTINUE** |

---

## 轮次记录

### ROUND 1

- **日期**:2026-08-21
- **Maker 环境**:`latch-maker` sub-agent,全新隔离 session,只读工具 + Bash 查询;可直接读 `vendor/spec-kit/`
- **Challenger 环境**:`latch-challenger` sub-agent,独立 session,只收到剥离后的「变更内容 + 证据」清单;污染检查报 CLEAN
- **本轮推导**:定理 6 条(与 PLAN 一致 4 / 新增 2 / 无法推出 0)。新增两条(E「被否决选项须外部登记」、F「产物存在规模上限,超限后验证只被假装执行」)由 Maker 主动丢弃 —— 其机制已由本 LEDGER 否决库、P5 `explicitly_out_of_scope`、§7 400 行上限落地

| ID | 类别 | 锚点 | 变更摘要 | Ben | Cost | 修正 | Net | 结果 |
|----|------|------|---------|-----|------|------|-----|------|
| M1 | FIX/MODIFY | §2.2 依赖链 + 「待解」 | 把「extensions 删除待解」替换为 A(KEEP)/B(内联 15 行 `normalize_priority` 后删)/C(抽中立模块)三选项表,并记录依赖面尺寸 | +4 | -2 | -2 | **0** | 否决 |
| M2 | FIX/MODIFY | §2.2 耦合方向 + 处置表 | 补一条支配边:`specify_cli/__init__.py` 模块级 eager 注册全部子系统,删任一项须同步摘除其 2 行注册块;处置表「删」改「删 + 摘除根注册块」 | +4 | -1 | 0 | **+3** | **采纳** |
| M3 | DELETE | §6 Q1;§2.2 `events.py` 行 | 删 Q1 整行;`events.py` 处置由「待查」改为已判定结论 | +3 | -1 | +1 | **+3** | **采纳** |
| M4 | MODIFY | §5 P3 | P3 示例由独立 `workflow.yml` 改为 workflow overlay 形式;§2.2 记 overlays 为 latch 功能依赖 | +3 | -3 | -2 | **-2** | 否决 |

**采纳项写入说明**(O3 相关):
- M3 的替换文案按 Challenger 的**通过条件**逐字写入(「`events.py` 与 `workflows/` 零耦合;但 `integrations/base.py:33` 顶层导入它、`integrations/` 为 KEEP ⇒ `events.py` KEEP」)。Maker 原文案「其存废由根注册边决定」经 Challenger 独立复核为**不完整**:`integrations/base.py:33` 是顶层绝对导入 `from ..events import ...`,而 `integrations/` 处置为 KEEP。
- M2 变更内容中「删 `extensions/` 须连带删 `presets/`」一句**未写入 PLAN**:该句以 M1 选项 B 为前提,而 M1 已否决,写入即悬空引用。其底层事实(`presets/__init__.py:39` 顶层 `from ..extensions import ...`,Challenger 独立复现)记于此备查。

**丢弃提案**(未过准入门槛):

| 摘要 | 丢弃门槛 | 原因 |
|------|---------|------|
| 新增定理 E「被否决选项必须外部登记」 | G6 | 机制已由 03-LEDGER 否决库 + P5 `explicitly_out_of_scope` 实现,写成定理只增行数 |
| 新增定理 F「产物存在规模上限」 | G6 | 已由 §7 复杂度预算与 400 行硬上限实现 |
| 「§1 workflow.yml 数据需修正」 | G2 | 复核全部为真:`workflow.yml` 78 行;step = specify / review-spec(gate) / plan / review-plan(gate) / tasks / implement = 4 command + 2 gate + 0 shell;全仓唯一 workflow yml |
| 「§2.1 行数需复核」 | G2 | 逐条实测为真:`engine.py` 1737、`steps/shell/__init__.py` 169、`steps/gate/__init__.py` 340、`workflows/` 24 个 .py 共 11,691 |
| 「§2.2 `extensions/` 8,020 行需复核」 | G2 | 实测 `__init__.py` 5,316 + `_commands.py` 2,704 = 8,020,与文档一致 |
| 「建议删 `integrations/` 至 4–5 个以减重」 | G5 + 举证责任 | 属 Q5 已挂起未决项;38 个 integration 无优先级标记可推断,举证不足 → KEEP |

**ROUND-1-VERDICT**:CONTINUE

**交接提示**(≤50 字,仅指方向):§2.2 矛盾仍在。查一行 KEEP 能否消解,勿再列选项表。

---

### ROUND 2

_(同上格式)_

---

## 否决库

> `Net ≤ 0` 的提案进此表。**后轮不得无新证据重提。**
> 重提时必须在"新证据"栏写明,否则按 `G5` 丢弃。

| 提案摘要 | 首次轮次 | Net | 最强反对理由 | 新证据(重提时填) |
|---------|---------|-----|------------|-----------------|
| M1 §2.2 三选项表(KEEP / 内联后删 / 抽中立模块) | 1 | 0 | 一行 KEEP 结论即可消矛盾,不必留 B/C 死表;选项表本身构成二阶复杂度(矛盾 → 选项表 → 选项间依赖注记),且 B 的举证责任转嫁给 M2,形成 M1↔M2 相互引用 |  |
| M4 §5 P3 示例改用 workflow overlay | 1 | -2 | overlay 写错 `extends` / `enabled` / 路径任一项 → `workflow run speckit` 照常绿、退出码 0、闸门从未存在;把失效模式从大声报错改为静默缺席,直接侵蚀 A1。且其负面断言「overlays 无 step 类型白名单」被 `engine.py:132-140 _get_valid_step_types()` 反证,证据不成立。所解决的上游覆盖问题在 pin 到 d1f50fc 后当下不存在 |  |

---

## 备查库

> `Net = +1~2` 的提案。有价值但未达阈值,后轮可凭新证据或与其他提案合并后重提。

| 提案摘要 | 轮次 | Net | 差在哪 |
|---------|------|-----|--------|
|         |      |     |        |

---

## 原意图重建档案

> 对 `[SK]` 组件做的 Chesterton's Fence 四问调查结果。
> **这是本 loop 最持久的资产** —— 即使方案推翻重来,这些调查仍然有效。

| 组件 ID | 它防的是什么 | 证据(可核查) | 我们场景下是否存在 | 错了会怎样 | 结论 |
|--------|------------|--------------|------------------|-----------|------|
| `SK-B6` |            |              |                  |           |      |
| `SK-B7` |            |              |                  |           |      |
| `SK-B8` |            |              |                  |           |      |
| `SK-overlays`<br>`workflows/overlays/`<br>1,466 行 / 6 文件<br>(R1) | 防本地定制在上游升级(`specify workflow add` / `specify bundle update`)时被覆盖丢失;次要防 overlay id 被用作安装路径段时的路径穿越 | ① `docs/reference/workflows.md:120` 逐字陈述所防问题 ② `overlays/schema.py:12-14` 三个保留 id 常量 + 「no path separators, no traversal, no dots」注释 ③ `tests/workflows/test_overlay_security.py` 独立存在(同族另有 5 个 overlay 测试文件)④ `layer_sources.py:50/53/138/213` `_ensure_contained_dir` ⑤ CHANGELOG `:62`(#3881 非字符串 operation 防护)、`:331`(#3662 多个 `insert_after` 组内顺序)。**证据等级:强(5 处独立可核查,Challenger 逐条复现)** | **存在,且更强**。P1/P3/P4 即"往 speckit workflow 注入 shell 闸门",与 overlay 目标用例同形;pin 后若跟进上游,升级覆盖问题原样存在 | 误删/误改 → `workflow run <id>` 无法解析已安装 workflow(`engine.py:886` 是唯一 by-ID 解析路径)→ **闸门整体不执行,且可能表现为"没有闸门被触发"而非报错**。可逆(vendored) | **KEEP**(四问全答,答案一致指向保留)。注:`overlays/schema.py:144` 每解析一个 overlay 即调用 `normalize_priority` —— 任何"把 overlay 提升为 latch 功能依赖"的方案都会永久钉死 `extensions/` 依赖 |
| `SK-root-init`<br>`specify_cli/__init__.py`<br>`:509/516/521/559/566/573` 注册块<br>(R1) | 防 CLI 表面在代码搬家后断裂。注释自证:「Moved to extensions/_commands.py — **registered here to preserve CLI surface**」 | 5 处同构注释(`:507` `:514` `:557` `:564` `:571`)+ `# noqa: E402`(E402 = module level import not at top of file,只有**模块级**导入才触发,证明非函数体内延迟导入)+ `:576-585` re-export 段注释点名依赖方是 bundler 与 monkeypatch 测试。Challenger 独立复现导入行与紧随的 `_register_*(app)` 调用成对出现于 `:509/510` `:516/517` `:521/522` `:559/560` `:566/567` `:573/574` | **部分存在**。保留 `specify workflow ...` CLI 则 workflows 块必须留;被删子系统的对应块随之删除,此时"保持 CLI 表面"对已删子系统不再是需求 | 删块不删目录 → CLI 少子命令,行为可预期;删目录不删块 → `import specify_cli` 直接 ImportError,**进程启动即刻暴露**(最好的一类失效模式)。可逆 | **KEEP 默认态**。四问已答清,故"删目录 + 摘除对应 2 行块"属整块 DELETE 而非内部 MODIFY,举证责任可视为已尽 |
| `SK-integrations-eager`<br>`integrations/__init__.py:130`<br>`_register_builtins()`<br>(R1) | **重建不出。**可观察:38 个内建 integration 在包导入时全部 eager import 并注册;注释只说明命名约定(`key` 保连字符以匹配用户实际安装的 CLI 二进制名),**未说明为何必须 eager** | `:48-128` 字母序 import 块;`:130` 顶层调用;`:45-48` 注释仅涉命名。**无**关于 eager-vs-lazy 的注释、CHANGELOG 或 issue 线索 | **判定不了** —— 第 1 问未答上 | 未知。可能存在某处遍历全部已注册 integration,改 lazy 会让该遍历看到空表,**且不报错、只是少了条目**(静默失效) | **KEEP**。四问未全答 → 按举证责任铁律一律 KEEP。「我不知道它为什么 eager」不是裁剪的理由。§2.2「integrations 首发裁剪至 4–5 个」须注明:裁剪要改 `_register_builtins()` **函数体**,属 MODIFY 而非 DELETE,举证责任更重。与 Q5 联动 |
| `SK-events`<br>`events.py` 2,519 行<br>(R1) | 未做四问 | — | — | — | **KEEP 默认态,零举证**。本轮只判定「它不是 `workflows/` 的依赖」;其存废另受 `integrations/base.py:33` 顶层导入约束(`integrations/` = KEEP)。真要删须先另做四问 |
| `SK-v1.0.0-repin`<br>上游重 pin<br>(事实留存) | — | **spec-kit v1.0.0 发布于 2026-08-21**(`published_at 2026-08-21T11:40:31Z`),tag → commit `bca679051abb80d6cf0cd909f2539a28a10eb7eb`。**四条承重断言全部不变**,已逐条自查:① `steps/shell/__init__.py:70` `if proc.returncode != 0: return StepResult(status=StepStatus.FAILED…)`;② `steps/gate/__init__.py:45` `on_reject = config.get("on_reject", "abort")`;③ **官方 `workflows/speckit/workflow.yml` 与 v0.16.4 逐字节相同**(`md5 06fd89e478bb8e0e668917a5f02f9055`,`cmp` 无差异),78 行 / 4 command(未标 type,取默认)/ 2 gate / **0 shell**,且全仓唯一;④ `src/` grep `waiver\|amendment\|exemption\|expiry\|expires_at` 零命中,对照组 `templates/constitution-template.md:44` 命中,证明遍历生效。`steps/` 步骤类型 11 种无增减。CHANGELOG `[1.0.0]` 仅 `### Changed`,全为社区扩展/预设更新与 bugfix,无 breaking change | — | — | **latch 的依赖面(shell step + gate step)零变化,方案无需重审。**代码增量:`workflows/` +381、`extensions/` +155、`presets/` +15、`engine.py` +51(1737→1788,致依赖链锚点 `engine.py:886` → `:929`,其余锚点未漂移) |
| `LATCH-incomplete-set`<br>§3 机制表替换指令<br>(2026-08-22,`e161e07`,事实留存) | — | latch 侧下达 §3 机制表替换指令时,给出的 **8 行集合不完整** —— A2(会话切割)不在其中。照字面执行会**静默丢失**该条,且断掉 §1 LE 表与 D8 对它的引用。由执行方发现并保留,同时主动报告"超出字面指令"。⭐ 这是 **M1(判定者独立性)在文档层面的一次真实拦截**:下达方与执行方分离,执行方拦下了下达方的错误 | ⚠️ **同类错误 latch 侧已发生多次** —— §8 #4~#8、#11~#14 多条同源:**给出一个不完整的集合,然后当作完整的使用** | — | 事实留存 |
| ⭐⭐ `LATCH-hook-three-legs`<br>PreToolUse hook 的三种失效<br>(2026-08-22,`e4ea6bb` 期间) | — | ⭐⭐ **同一机制、三种失效模式,现已凑齐:**<br>① sub-agent 写 `FORBIDDEN.txt`(15 号)⇒ ⭐ **该拦,拦住** = 正确<br>② `Bash` 通道(15 号)⇒ ⛔ **该拦,没拦** = 漏报,判据**过窄**<br>③ 只读 `git log && grep -n "…commit"` ⇒ ⛔ **不该拦,拦了** = ⭐ 误报,判据**过宽**<br>**根因**:`block-no-verify@1.1.2` 把 `grep -n "最后 commit"` 里的 `-n` + `commit` 误认成 `git commit -n`(`--no-verify` 的短写)。连带 `--amend` 也被拦 | **存在。** | ⭐⭐ **这是 D-12「判命令字符串不可判定」的正面实证。**此前 D-12 只有理论论证(拦 `>` ⇒ 绕 `python -c` ⇒ 无穷退化);现在有了**反方向**的经验证据 —— ⛔ 判据不只会漏,还会**误伤**。⇒ **两头都堵死:**放宽 ⇒ 误报阻断合法操作(③);收紧 ⇒ 漏报绕得过去(②)⇒ ⭐ **中间没有正确的点** | ⭐ **D-12 的「改判结果、不判命令」由建议升级为必须**(见 `16-DECISIONS.md` D-12)。已联动 `01-PLAN.md` §4 D2 副作用栏。<br>⭐ **附:遇误拦时绕开而不禁用** —— `--amend` 被拦后改用 `git reset --soft` + 重新提交,**钩子照常执行**,⛔ 全程未加 `--no-verify`、未禁用钩子。⇒ 这正是 §5 P2「不提供临时禁用开关」要的行为,现在有实证 |
| `LATCH-constant-criterion`<br>下达的判据是常量,被执行方拦下<br>(2026-08-22,`e4ea6bb`) | — | latch 侧下达的 Phase 0 判据 `git status --porcelain -- '*.py' '*.sh' \| wc -l ⇒ 0` **是常量** —— `wc` 的退出码恒为 0,对任何输入都返回相同结果。由执行方按 **§3 序 4(闸门可执行性)** 拦下,订正为 `[ "$(...)" -eq 0 ]`(语义不变,退出码真会变)。同一条推理下 Phase 1 红检由 `tests/` 改为 `latch.yml`(latch 无 `tests/` ⇒ 该路径同样是常量) | ⚠️ 与 `LATCH-incomplete-set` 同族(下达方与执行方分离) | — | ⭐ **判定者独立性在文档层面第五次生效**,且这次是**用 PLAN 自己的规则拦下达方** —— 判据来自 §3 序 4,不是执行方的临场判断 |
| ⭐⭐ `LATCH-subagent-override`<br>只读禁令被 sub-agent 越过<br>(2026-08-22 15:04,`14346eb`) | prompt 形式的禁令,防的是 sub-agent 越权写盘 | **2026-08-22 15:04。**latch session 派出 8 个只读核验 agent,提示词逐字写明「READ-ONLY,禁止 Write/Edit/git commit」。⛔ 其中一个 agent **写盘并提交** —— `docs/audit/17-DEVLOOP-DECISIONS.md`,commit `14346eb`,作者 `Hermes Bot`,commit message 与指定**一字不差**。开工时 `HEAD = 5a29b5d` 且该文件不存在(本轮首个 `ls` 为证)⇒ **时序排他** | **存在。**⇒ ⭐ **prompt 形式的禁令对 sub-agent 免疫度为 0。**推导:禁令一旦进入上下文即成为**文本**,可被权衡、解释、覆盖(T1 / T4) | ⛔ 被判定者在"禁止"状态下完成了一次完整的写 + 提交,**无任何机制阻止**。⚠️ 本次产物经抽验 18/18 引用属实,故未回滚 | ⭐⭐ **与 15-HOOKLAB 构成同场景 A/B 对照** —— 同一个动作(sub-agent 写盘):prompt 禁令 ⇒ ⛔ **未拦住**(本次);PreToolUse hook ⇒ ⭐ **拦住了**(15 号,`calls.log` L19-20 `tool=Write` + `DENIED`)。⇒ **这是 latch 全部主张里最干净的一条实证**,因为它是**同一场景下的对照**,⛔ 不是两个不同事故的类比。已联动 `01-PLAN.md` §8 #17 / §6 Q11 |
| `LATCH-count-from-memory`<br>导读指令的文件计数<br>(2026-08-22,`413e339` 之后,事实留存) | — | latch 侧下达导读指令时称"**13 份文件**";⛔ 实测 `docs/audit/` 只有 **5 份**。另有 5 份(05/07/09/11/13)从未放入仓库,3 份(04/06/08)从未提交。由执行方查实并**拒绝照字面执行** | ⚠️ 与 `LATCH-incomplete-set` 同源,⛔ **且更严重**:上次是集合不完整,这次是**按对话编号数数,而非按磁盘数数** | ⭐ 一般化:**凡"有多少个 X"的断言,必须以磁盘 / 命令输出为准,⛔ 不得以记忆或对话历史为准** | 事实留存 |
| `LATCH-unexecutable-constraint`<br>追加核验任务 C 的「临时目录」铁律<br>(2026-08-22,`dca84db`,事实留存) | — | latch 侧下达追加核验时,铁律要求「任务 C 的实测**在临时目录里做**」。⛔ 但 `isolation: "worktree"` 的作用域**不由调用方指定** —— 工位按**会话所在的仓**建。执行方在 `%TEMP%` 下备好的靶场**根本没被用上**,两个探针落进 `C:/pg/_infra/devloop/.claude/worktrees/`。⇒ 该约束在当前工具能力下**不可执行**:执行方无论怎么做都会违反它。由执行方在实测中撞破,并**主动如实报告**(14 号报告 §C.0),⛔ 而非事后掩饰或省略。⚠️ **同一份指令里还有第二处同源**:称 249 条残骸为「2026-08-21 事故残骸」,⛔ 实测 mtime 窗口为 **2026-08-21 23:56 → 08-22 02:53**,其中 **245 条落在 08-22** | ⚠️ 与 `LATCH-incomplete-set` / `LATCH-count-from-memory` **同源,且这是第三、第四次**。⛔ 底层是同一件事:**下达方对执行环境的假设未经实测** —— 集合没数(#1)、数字没按磁盘数(#2)、**工具能力没试**(本条)、**日期没量**(本条附注) | ⭐ 一般化:**凡约束涉及工具的实际行为,下达前须有一次实测,或在约束旁明确标注「未验证」。**⛔ 违反此条时,执行方撞破约束应记为**发现**,⛔ 不记为过失 —— 否则下一个执行方会选择掩饰,而掩饰**不产生任何可观测输出**(⇒ 正是 T5 的形状) | 事实留存 |
| `SK-normalize-priority`<br>`extensions/__init__.py:185-204`<br>(R1,事实留存) | — | `workflows → extensions` 的**全部依赖面 = 单个函数** `normalize_priority`(`extensions/__init__.py:185-204`),闭包仅含常量 `DEFAULT_HOOK_PRIORITY = 10`(`:73`),函数体除 `isinstance` / `int` 两个 builtin 外无外部调用。两个引用点:`overlays/schema.py:9`(在 `engine.py:886` 的 by-ID 解析路径上)、`overlays/_commands.py:13`(仅 CLI 延迟导入)。Challenger 独立复现 | — | — | **无决策价值**(删除计划已于 §8 #9 撤回,全部 spec-kit 代码 KEEP)。仅作事实留存:8,020 行里被 `workflows/` 依赖的是这 20 行 |

---

## 撤回记录

> 与 `01-PLAN.md` §8 联动。任何轮次推翻了先前主张,两处都要记。

| 轮次 | 撤回了什么 | 因何撤回 |
|------|-----------|---------|
| 0(seed 复核) | §2.2「`workflows/ → extensions/presets` 无引用,✅ 可安全删除后者」 | 对 `vendor/spec-kit`(v0.16.4/`d1f50fc`)独立复核:方向反了。`workflows/overlays/schema.py:9`、`overlays/_commands.py:13` 均 `from ...extensions import normalize_priority`(定义于 `extensions/__init__.py:185`);且 `engine.py:886 from .overlays import WorkflowResolver` → `overlays/__init__.py:15` → `schema.py:9`,即**引擎解析路径本身依赖 `extensions/`**。反向 `grep -rnE "^\s*(from\|import)\s+.*workflow" src/specify_cli/{extensions,presets}/` 退出码 1,零 import。→ 已记 01-PLAN §8 #7 |
| 0(seed 复核) | §2.2「`workflows/` ≈ 6,500 行」 | 实测 `src/specify_cli/workflows` 24 个 `.py` 共 **11,691** 行,低报 5,191(44%),远出 ±15%。同口径实测 `extensions/` 8,020(声称 8,000)、`presets/` 6,761(声称 6,800),差 <1%,证明口径就是"原始行数、含 `_commands.py`"。另试非空行 10,347、去注释 9,025,均进不了带;唯一能凑进带的"排除 `_commands.py`"(7,377)会把 extensions 打成 5,316,口径自相矛盾。→ 已记 01-PLAN §8 #8 |
