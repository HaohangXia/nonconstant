<p align="right">
  <a href="./README.md">English</a> · <strong>中文</strong>
</p>

# 绑定提交的完成报告

每个 `phase<N>-<短提交哈希>.md` 文件记录一个已完成阶段的验证结果。文件名中的哈希必须
解析到当前分支历史中的真实祖先提交；[`.nonconstant/report.sh`](../.nonconstant/report.sh) 会检查
提交是否存在以及祖先关系。报告是否准确描述了该提交中的产物，仍需人工复核。

有效报告会记录冻结契约、命令与退出码、已知缺口、后续工作的入口条件、明确排除项和需要
人工确认的边界。这些文件是证据快照，不替代当前状态。阅读应从
[`../docs/audit/STATUS.md`](../docs/audit/STATUS.md) 开始。
