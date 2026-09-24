<p align="right">
  <a href="./README.md"><img alt="Read in English" src="https://img.shields.io/badge/Language-English-0F766E?style=flat-square"></a>
  · <strong>中文</strong>
</p>

# nonconstant

**给 AI 辅助编码工作流增加独立验证闸：把“我检查过了”变成一条命令和一个退出码。**

当 AI Agent 说测试已经通过时，实际可能是测试真的通过了、验收标准被改到能够通过，
或者测试根本没有触达变更代码。三种情况最后都可能变成同一句“全部通过”。

nonconstant 将执行工作与判断结果分开。它提供 10 条非交互式 Shell 闸，并使用三态、
失败闭合的退出码契约：

```text
0  通过        1  失败        2  无法判断
```

第三种状态是关键：目标不存在、配置缺失或依赖损坏时，系统不会因为“没有观察到问题”
就错误地报告绿色。

> **项目状态：**这是一个小型、可检查的验证工具与研究型工程产物。它可以安装，
> 但不是托管服务、完整编排器，也不能保证 Agent 的推理本身正确。

## 一个可重复的小演示

核心闸会保护定义“哪些文件受保护”的配置文件。因此，修改判定标准本身就会成为反对该
修改的证据。

```bash
git clone --recurse-submodules https://github.com/HaohangXia/nonconstant.git
cd nonconstant

mkdir demo && cd demo
git init -q
git config user.email you@example.com
git config user.name you

bash ../install.sh .
git add -A && git commit -q -m "chore: install nonconstant"

bash .nonconstant/gates.sh
echo $?   # 0：受保护的判定标准没有变化

awk '{ sub(/^  - \.nonconstant\/\*\*$/, "  - nothing/**"); print }' nonconstant.yml > nonconstant.yml.tmp
mv nonconstant.yml.tmp nonconstant.yml
bash .nonconstant/gates.sh
echo $?   # 1：判定标准文件已被修改
```

该示例需要 Bash、Git 和常见 Unix 命令行工具。安装器还会在 Python 可用时探测它；
`upstream-semantics` 需要 Python。已有记录的验证环境是 Windows + Git Bash；
本次发布没有验证 Linux、macOS 或 WSL。

在其他内容干净且沿用本仓配置的 clone 中，如果漏掉了子模块，其余 8 道闸仍返回 0，
`upstream-pin` 与 `upstream-semantics` 返回 2，并说明目前无法判断上游。
可在 clone 的根目录运行以下命令恢复：

```bash
git submodule update --init --recursive
```

## 工作方式

```text
Agent 修改仓库
      |
      v
声明的验证闸检查证据
      |
      +------ 0  证据支持声明
      +------ 1  证据反驳声明
      `------ 2  验证闸无法作出有效判断
```

每条闸都是一个脚本。配置、受保护路径和文档预算位于
[`nonconstant.yml`](nonconstant.yml)，实现位于 [`.nonconstant/`](.nonconstant/)。
本仓库也使用同一套验证闸检查自身。

| 验证闸 | 回答的问题 |
|---|---|
| `criteria-guard` | 被检查的变更是否修改了定义自身判定标准的文件？ |
| `silent-scan` | Python 或 Shell 文件是否出现 4 类已知的失败抑制模式？ |
| `meta-gate` | 每条启用的闸是否都声明了一个通过演示和一个失败演示？ |
| `report-pin` | 完成报告是否指向当前历史中真实存在的提交？ |
| `status-facts` | 可机器检查的状态声明是否仍与仓库一致？ |
| `waiver-expiry` | 已声明的例外是否到达明确的到期节点？ |
| `upstream-semantics` | 固定版本的上游是否仍表现出本项目依赖的行为？ |
| `upstream-pin` | 上游子模块是否停在声明的提交且未被修改？ |
| `doc-budget` | 受控文档是否仍处于声明的体量预算内？ |
| `readme-runnable` | README Bash 代码块中的脚本 token 是否指向真实文件，3 个强制边界披露与 1 个归属锚点是否存在？ |

每条检查的通俗解释、例子和适用边界，见[十条检查简明指南](docs/TEN-GATES.zh-CN.md)。

## 安装到另一个仓库

在 nonconstant 的 clone 中运行：

```bash
bash install.sh /path/to/your/git-repository
```

安装器不会覆盖已有的 `nonconstant.yml`。它会先在暂存目录准备文件，只复制可分发的闸；
无法确定的项目路径会保持未配置，而不是猜测一个错误答案。它不安装 Git hook，
不提供沙箱，也不修改访问权限。运行前请先检查并提交目标仓库的现有内容。

安装后：

1. 在 `nonconstant.yml` 中填写 `subjects`、`protected`、`doc_budgets`，以及
   `status-facts` 条目中的 `expected_assertion_classes`。
2. 提交安装基线，让变更检测拥有真实参照点。
3. 运行每条启用的验证闸并保留退出码。
4. 如有需要，将闸接入你自己的 hook 或编排层。

安装后的 `status-facts` 仍然识别 nonconstant 已记录的断言格式，不是通用的自然语言状态
检查器；仅把它指向任意状态文档并不够。状态／计划路径、文档预算或断言类数没有配置时，
相应闸会返回 2；没有上游安装时，`upstream-semantics` 同样返回 2。
前面的小演示只验证 `criteria-guard`，不代表其他闸已配置完成。

```bash
while read -r gate; do
  bash "$gate"
  status=$?
  printf '%s=%s\n' "$gate" "$status"
done < <(awk '/^[[:space:]]+impl:/ { print $2 }' nonconstant.yml)
```

需要读取退出码时，不要随意把验证闸放进管道；Shell 管道通常返回最后一个命令的退出码，
而不是验证闸的退出码。这个循环只展示每条结果，不会将它们汇总成发布结论，也不会自动
停止工作流。

## 证据与设计记录

本仓库尽量将结论指向可检查的产物，而不是只写成宣传文案：

- [`docs/audit/STATUS.md`](docs/audit/STATUS.md) 是当前状态索引。
- [`docs/audit/03-LEDGER.md`](docs/audit/03-LEDGER.md) 记录观察结果与被推翻的结论。
- [`reports/`](reports/) 保存绑定具体提交的阶段报告。
- [`amendments/`](amendments/) 记录对冻结契约的修改。
- [`docs/RETROSPECTIVE.md`](docs/RETROSPECTIVE.md) 解释促成这些闸的失败案例。

固定版本的 [`github/spec-kit`](https://github.com/github/spec-kit) 以 Git 子模块存在。
nonconstant 不 fork 或修改它的源码，而是检查上游 pin，并直接运行本项目依赖的上游行为。

## 边界与已知限制

<!-- nonconstant:disclosure:checkable-not-correct -->

### 可检查不等于正确

验证闸能够检查一项声明是否与仓库证据一致，但无法证明声明背后的推理正确、验收标准完整，
也无法证明模型准确理解了用户意图。

判据守卫比较的是工作树与配置中的 Git 基线；它不会阻止写入，也不会让基线不可修改。
需要独立验证时，应让验证器和基线处于执行者不能修改的位置；本工具并未实现这种隔离。
同样，`meta-gate` 检查的是演示登记，不会验证演示是否真的运行过。

<!-- nonconstant:disclosure:mechanized-ratio -->

### 只有部分操作协议已经机器化

在有记录的测量时点，本项目 33 条操作规则中只有 5 条拥有可执行约束；其余规则尚未实现，
或原则上无法由机器判定。安装 nonconstant 不会自动把文字规则变成有效控制。

这一比例测定于 **2026 年 8 月 23 日**，之后可能变化。可用以下命令只读复算分类列：

```bash
awk -F'|' '/^\| *(R|K|F|C)[0-9]+ *\|/ { n++; if ($3 ~ /已机器化/) m++ } END { printf "%d / %d\n", m, n }' docs/audit/18-PROTOCOL.md
```

<!-- nonconstant:disclosure:known-gaps -->

### 仍有 4 项已记录的缺口

当前计划保留了 4 项延后加固：失败结果尚无机器可读的原因码；一条精心构造的行尾注释可以
使某个受保护 glob 不再匹配；失败演示没有先独立证明自己的基线；一个状态列尚未被检查。
权威记录与触发条件见 [`docs/audit/01-PLAN.md` 的 Q19](docs/audit/01-PLAN.md)。

因此，本项目不声称自己不可篡改，也不适合被单独作为生产环境控制。

<!-- nonconstant:disclosure:attribution -->

## 项目沿革与归属

- **[github/spec-kit](https://github.com/github/spec-kit)** 提供上游工作流实现；本项目把它固定在
  `bca679051abb80d6cf0cd909f2539a28a10eb7eb`（v1.0.0）。两个项目均采用 MIT License。
  nonconstant 自己的实现不复制 spec-kit 源码：上游通过 Git submodule 引用，
  不是修改后的 fork，也没有改动上游源码。
- **[DevLoop v1](https://github.com/HaohangXia/devloop-v1)** 是历史前身。nonconstant 不导入
  其中任何代码，只把具体事故作为新验证闸的证据：一道闸在 8 月 17 日退化成常量，直到
  8 月 20 日才被发现，其间实际运行 0 次；另一次临时目录累积到 86 GB 并撑满 C 盘。
- Maker/Checker 的拆分来自 Addy Osmani 的
  [Loop Engineering](https://addyosmani.com/blog/loop-engineering/) 框架。**Loop Engineering 是
  油门的工程学；nonconstant 是刹车与仪表的工程学。**本项目回应的 verification responsibility、
  comprehension debt 与 cognitive surrender 三个缺口由 Osmani 提出，并非 nonconstant 声称的创新。
- [已有工具调研](docs/audit/21-PRIOR-ART.md) 记录了
  [axiom](https://github.com/ryangu00/axiom)、
  [groundtruth](https://github.com/vnmoorthy/groundtruth)、
  [nah](https://github.com/manuelschipper/nah) 和
  [Mantiz](https://github.com/farhank15/mantiz)。**如果你需要的是一个成熟工具，请优先查看这些项目**，
  再判断它们当前是否适合你的需求；历史调研不代表当前功能排名或安全认证。
  nonconstant 目前只有一个 Shell 安装器、一个运行时，而且没有公开标定语料。
  它最有价值的证据，是项目如何逐步质疑并收窄自身结论的完整过程；见
  [`docs/RETROSPECTIVE.md`](docs/RETROSPECTIVE.md)。

## 仓库地图

| 路径 | 用途 |
|---|---|
| [`.nonconstant/`](.nonconstant/) | 可执行验证闸及共享 Shell 辅助函数。 |
| [`nonconstant.yml`](nonconstant.yml) | 验证闸清单、受保护路径、证据指针与预算。 |
| [`install.sh`](install.sh) | 面向其他 Git 仓库的暂存式安装器。 |
| [`workflows/nonconstant/`](workflows/nonconstant/) | spec-kit 工作流集成。 |
| [`docs/audit/`](docs/audit/) | 计划、状态、决策、观察与协议记录。 |
| [`reports/`](reports/) | 绑定具体提交的完成报告。 |
| [`amendments/`](amendments/) | 对冻结设计契约的显式修改。 |
| [`vendor/spec-kit/`](vendor/spec-kit/) | 只读、固定提交的上游子模块。 |

## 许可

[MIT](LICENSE)
