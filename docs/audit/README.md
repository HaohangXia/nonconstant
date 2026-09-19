<p align="right">
  <strong>English</strong> · <a href="./README.zh-CN.md">简体中文</a>
</p>

# Audit record guide

> If any file in this directory conflicts with [`01-PLAN.md`](01-PLAN.md), the plan wins.
> Files numbered 04–15 are process records, not automatically current conclusions.

Some conclusions in the review exchanges were later disproved. Start with
[`STATUS.md`](STATUS.md), then read [`01-PLAN.md`](01-PLAN.md); opening a historical reply in
isolation can reconstruct an obsolete plan.

| File | Role | Authority |
|---|---|---|
| [`STATUS.md`](STATUS.md) | Current state, completed phases and unresolved items. | Current index; machine-checked where noted. |
| [`01-PLAN.md`](01-PLAN.md) | Design, phase plan and accepted reversals. | Primary source for the current plan. |
| [`03-LEDGER.md`](03-LEDGER.md) | Cross-session observations, rejected ideas and intent reconstruction. | Current evidence ledger. |
| [`18-PROTOCOL.md`](18-PROTOCOL.md) | Operating rules, corrected as evidence changes. | Current protocol; rationale remains in the ledger. |
| [`16-DECISIONS.md`](16-DECISIONS.md) | Decision rationale. | Historical but still authoritative for recorded decisions. |
| [`17-DEVLOOP-DECISIONS.md`](17-DEVLOOP-DECISIONS.md) | Decisions made on the DevLoop side of the review. | Historical decision record. |
| `14-*` / `15-*` | Orchestration verification and hook-lab observations. | Measurements at their recorded commits. |
| `04-*`, `06-*`, `08-*` | Back-and-forth audit documents. | Historical process only; re-check against the plan. |

Numbered replies 05, 07, 09, 10, 11, 12 and 13 are intentionally not in this repository.
Their accepted conclusions were folded into the plan; do not recreate placeholder files for
missing sequence numbers.
