<p align="right">
  <strong>English</strong> · <a href="./README.zh-CN.md">简体中文</a>
</p>

# Commit-pinned completion reports

Each `phase<N>-<short-commit>.md` file records the verification performed for one completed
phase. The hash in the filename must resolve to a real ancestor commit in this branch's
history; [`.nonconstant/report.sh`](../.nonconstant/report.sh) checks existence and ancestry.
Whether the report accurately describes the artefacts at that commit still requires human
review.

A valid report records frozen contracts, commands and exit codes, known gaps, entry conditions
for later work, explicit exclusions and the human confirmation boundary. These files are
evidence snapshots, not a substitute for current status. Start with
[`../docs/audit/STATUS.md`](../docs/audit/STATUS.md).
