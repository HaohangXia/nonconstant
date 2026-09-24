# nonconstant 的十条检查 / The ten verification gates

这十条是本仓库当前在 [`nonconstant.yml`](../nonconstant.yml) 中登记的检查器。每条由一个脚本检查一件具体的事，返回 `0`（通过）、`1`（发现问题）或 `2`（缺少条件，无法判断）。它们不是每个 AI 任务都必须跑的十项业务测试；实际运行哪些，取决于项目如何接入这些脚本。

1. **`criteria-guard` — Protect the acceptance criteria（保护验收标准）**：比较 Git 基线和当前改动，指出用来验收 AI 工作的受保护文件是否被改过。它报告改动，不负责锁住文件，也不判断验收标准本身是否正确。
2. **`silent-scan` — Catch known silent-failure patterns（发现已知的静默失败写法）**：扫描指定目录中的 Python 和 Shell 文件，寻找几种可能把错误吞掉的写法，例如丢弃错误输出。它检查的是已知代码模式，不证明运行时绝不会出错。
3. **`meta-gate` — Check the checks（检查检查器）**：确认启用的检查脚本存在，并且配置中登记了应通过和应失败的演示及其预期结果。登记不等于这次真的重新运行了演示。
4. **`report-pin` — Make reports traceable（让完成报告可追溯）**：核对阶段报告文件名引用的 Git 提交是否真实存在于当前项目历史中。提交真实存在，不等于报告正文全部属实。
5. **`status-facts` — Compare status with repository facts（核对进度记录）**：把状态文档中能机器核对的说法与仓库对照。例如文档写“有十条检查”，脚本就数配置中登记的检查是否为十条；它不会理解整篇自然语言说明。
6. **`waiver-expiry` — Check temporary exceptions（检查临时例外）**：核对已登记的豁免是否到了约定的阶段，避免临时跳过某项要求却一直不处理。
7. **`upstream-semantics` — Verify relied-on behaviour（验证上游关键行为）**：实际运行本项目依赖的上游工作流步骤，确认检查失败仍会失败、人工确认步骤不会自动放行。它只验证指定行为，不测试上游工具的全部功能。
8. **`upstream-pin` — Verify the pinned dependency（核对固定的上游版本）**：确认本仓库的上游子模块停在配置指定的 Git 提交，而且工作区没有本地改动。这条主要服务于 nonconstant 自己的开发环境。
9. **`doc-budget` — Check document size budgets（检查文档长度预算）**：按配置检查指定文档是否超过行数上限。在当前配置中它是提醒性质的 *soft* 检查。
10. **`readme-runnable` — Check README references（检查使用说明）**：确认 README 的 Bash 示例引用的脚本文件存在，并且规定要说明的限制与来源还写在文档里。它不会逐条执行 README 中的命令；这条主要检查 nonconstant 自己的 README。

**什么时候运行？** nonconstant 自己的提交前检查会从配置中读取这些条目并运行；另一个工作流只接入其中适用的部分。安装到别的项目时，安装器不会自动装 Git hook 或定时触发器，需要项目自己决定何时调用哪些检查。`0` 只代表这一条检查通过，不代表整个 AI 任务或项目测试都已验收。
