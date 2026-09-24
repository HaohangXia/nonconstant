<p align="right">
  <strong>English</strong> ·
  <a href="./README.zh-CN.md"><img alt="阅读中文版" src="https://img.shields.io/badge/Language-中文-0F766E?style=flat-square"></a>
</p>

# nonconstant

**Verification gates for AI-assisted coding: turn “I checked it” into a command and an exit code.**

An AI agent can report that the tests passed when the tests genuinely passed, when the
acceptance criteria were edited until they passed, or when the test never reached the
changed code. The sentence looks the same in all three cases.

nonconstant separates the work from the judgement. It provides ten non-interactive shell
gates with a fail-closed three-state contract:

```text
0  pass        1  fail        2  cannot judge
```

The third state is the important one. A missing target, absent configuration or broken
dependency is not reported as green merely because no defect was observed.

> **Project status:** a small, inspectable verification toolkit and research artefact. It is
> installable, but it is not a hosted service, a complete orchestrator or a guarantee that
> an agent's reasoning is correct.

## A small, repeatable demonstration

The core gate protects the file that defines what is protected. Changing the marking
criteria therefore becomes evidence against the change itself.

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
echo $?   # 0: the protected criteria are unchanged

awk '{ sub(/^  - \.nonconstant\/\*\*$/, "  - nothing/**"); print }' nonconstant.yml > nonconstant.yml.tmp
mv nonconstant.yml.tmp nonconstant.yml
bash .nonconstant/gates.sh
echo $?   # 1: the criteria file was changed
```

The example needs Bash, Git and standard Unix command-line tools. The installer also probes
Python if available; `upstream-semantics` requires Python. The recorded environment is
Windows with Git Bash; Linux, macOS and WSL are not validated by this release.

On an otherwise clean clone with the repository's configuration, omitting the submodule
leaves the eight unrelated gates at 0, while `upstream-pin` and `upstream-semantics` return 2
and explain that the upstream code cannot be judged. Restore it from the clone's root with:

```bash
git submodule update --init --recursive
```

## How it works

```text
agent changes repository
          |
          v
declared gates inspect evidence
          |
          +------ 0  claim is supported
          +------ 1  claim is contradicted
          `------ 2  the gate cannot make a valid judgement
```

Each gate is a script. Configuration, protected paths and document budgets live in
[`nonconstant.yml`](nonconstant.yml); implementations live in [`.nonconstant/`](.nonconstant/).
The repository uses the same gates to check itself.

| Gate | Question answered |
|---|---|
| `criteria-guard` | Did the evaluated change alter the files that define its own criteria? |
| `silent-scan` | Do Python or shell files contain any of four known failure-suppression patterns? |
| `meta-gate` | Has every enabled gate declared both a passing and a failing demonstration? |
| `report-pin` | Does a completion report point to a real commit in this history? |
| `status-facts` | Do machine-checkable status claims still match the repository? |
| `waiver-expiry` | Has a declared exception reached its explicit expiry point? |
| `upstream-semantics` | Does the pinned upstream still exhibit the behaviours this project relies on? |
| `upstream-pin` | Is the upstream submodule at the declared commit and unmodified? |
| `doc-budget` | Are controlled documents within their declared size budgets? |
| `readme-runnable` | Do shell-script tokens in README Bash blocks resolve to files, and are the three mandatory limitation disclosures plus the attribution anchor present? |

For plain-language explanations and limits of all ten gates, see the
[bilingual ten-gate guide](docs/TEN-GATES.zh-CN.md).

## Install it in another repository

Run the installer from a clone of nonconstant:

```bash
bash install.sh /path/to/your/git-repository
```

The installer refuses to overwrite an existing `nonconstant.yml`. It prepares files in a
staging directory, copies only distributable gates, and leaves project-specific fields
unconfigured rather than guessing incorrect paths. It does not install a Git hook, provide
a sandbox or change access permissions. Review and commit your target repository first.

After installation:

1. Set `subjects`, `protected` paths, `doc_budgets` and
   `status-facts.expected_assertion_classes` in `nonconstant.yml`.
2. Commit the installed baseline so change detection has a real reference point.
3. Run each enabled gate and preserve its exit code.
4. Wire the gate runner into your own hook or orchestration layer if required.

The installed `status-facts` gate still recognises nonconstant's documented assertion
formats; it is not a general natural-language status checker. Pointing it at an arbitrary
status page is not sufficient. Unconfigured status/plan paths, document budgets or assertion
counts cause the affected gates to return 2; a missing upstream installation does the same
for `upstream-semantics`. The small demonstration above exercises only `criteria-guard`.

```bash
while read -r gate; do
  bash "$gate"
  status=$?
  printf '%s=%s\n' "$gate" "$status"
done < <(awk '/^[[:space:]]+impl:/ { print $2 }' nonconstant.yml)
```

Do not pipe a gate into another command when you need its status: a shell pipeline normally
reports the final command's exit code, not the gate's. This loop displays individual results;
it does not aggregate them into a release decision or stop a workflow automatically.

## Evidence and design records

This repository treats claims as pointers to inspectable artefacts rather than as marketing
copy:

- [`docs/audit/STATUS.md`](docs/audit/STATUS.md) is the current-state index.
- [`docs/audit/03-LEDGER.md`](docs/audit/03-LEDGER.md) records observations and reversals.
- [`reports/`](reports/) contains phase reports pinned to the commits they describe.
- [`amendments/`](amendments/) records changes to frozen contracts.
- [`docs/RETROSPECTIVE.md`](docs/RETROSPECTIVE.md) explains the failures that shaped the gates.

The pinned [`github/spec-kit`](https://github.com/github/spec-kit) dependency is included as
a Git submodule. nonconstant does not fork or modify its source; it checks the upstream pin
and executes the specific upstream behaviours it depends on.

## Boundaries and known limitations

<!-- nonconstant:disclosure:checkable-not-correct -->

### Checkable does not mean correct

The gates can test whether a declared claim is consistent with repository evidence. They
cannot prove that the reasoning behind the claim is correct, that the acceptance criteria
are complete, or that a model understood the user's intent.

The criteria guard compares the working tree with the configured Git baseline. It does not
prevent writes or make that baseline immutable. Keep the verifier and its baseline outside
the worker's control when independence is required; this toolkit does not implement that
isolation. Likewise, `meta-gate` checks recorded demonstrations, not whether they ran.

<!-- nonconstant:disclosure:mechanized-ratio -->

### Only part of the operating protocol is mechanised

At the recorded measurement point, 5 of this project's 33 operating rules had executable
enforcement. The rest were either unimplemented or not mechanically decidable. Installing
nonconstant does not turn prose rules into working controls.

That ratio was measured on **23 August 2026** and can change. Recount the read-only
classification column with:

```bash
awk -F'|' '/^\| *(R|K|F|C)[0-9]+ *\|/ { n++; if ($3 ~ /已机器化/) m++ } END { printf "%d / %d\n", m, n }' docs/audit/18-PROTOCOL.md
```

<!-- nonconstant:disclosure:known-gaps -->

### Four documented gaps remain

The current plan records four deferred hardening gaps: gate failures do not yet expose a
machine-readable reason code; a crafted inline comment can make one protected glob stop
matching; failing demonstrations do not independently prove their baseline first; and one
status column is not checked. See
[`docs/audit/01-PLAN.md`, Q19](docs/audit/01-PLAN.md) for the authoritative record and trigger.

These gaps matter. This project therefore does not claim to be tamper-proof or suitable as
a sole production control.

<!-- nonconstant:disclosure:attribution -->

## Lineage and attribution

- **[github/spec-kit](https://github.com/github/spec-kit)** provides the upstream workflow
  implementation, pinned at `bca679051abb80d6cf0cd909f2539a28a10eb7eb` (v1.0.0). Both
  projects use the MIT licence. nonconstant's own implementation does not copy spec-kit
  source: the upstream is referenced as a Git submodule, not a modified fork.
- **[DevLoop v1](https://github.com/HaohangXia/devloop-v1)** is the historical predecessor.
  nonconstant imports none of its code; it uses concrete incidents as evidence: one gate
  degraded into a constant on 17 August and went unnoticed until 20 August after running
  zero times, while accumulated temporary directories later reached 86 GB and filled the
  C: drive.
- The maker/checker split comes from Addy Osmani's
  [Loop Engineering](https://addyosmani.com/blog/loop-engineering/) framework. **Loop
  Engineering is the engineering of the accelerator; nonconstant is the engineering of the
  brakes and instruments.** The three gaps this project responds to—verification
  responsibility, comprehension debt and cognitive surrender—are gaps Osmani identifies,
  not claims of novelty by nonconstant.
- Related projects recorded in the [prior-art review](docs/audit/21-PRIOR-ART.md) include
  [axiom](https://github.com/ryangu00/axiom),
  [groundtruth](https://github.com/vnmoorthy/groundtruth),
  [nah](https://github.com/manuelschipper/nah) and
  [Mantiz](https://github.com/farhank15/mantiz). **If you need a mature tool, look at those
  projects** and assess their current fit; the historical review is not a current feature
  ranking or security certification. nonconstant is one shell installer for
  one runtime with no public calibration corpus. Its distinctive evidence is the recorded
  process by which its claims were challenged and narrowed; see
  [`docs/RETROSPECTIVE.md`](docs/RETROSPECTIVE.md).

## Repository map

| Path | Purpose |
|---|---|
| [`.nonconstant/`](.nonconstant/) | Executable gate implementations and shared shell helpers. |
| [`nonconstant.yml`](nonconstant.yml) | Gate registry, protected paths, evidence pointers and budgets. |
| [`install.sh`](install.sh) | Staged installer for another Git repository. |
| [`workflows/nonconstant/`](workflows/nonconstant/) | spec-kit workflow integration. |
| [`docs/audit/`](docs/audit/) | Plans, status, decisions, observations and protocol records. |
| [`reports/`](reports/) | Commit-pinned completion reports. |
| [`amendments/`](amendments/) | Explicit changes to frozen design contracts. |
| [`vendor/spec-kit/`](vendor/spec-kit/) | Read-only pinned upstream submodule. |

## Licence

[MIT](LICENSE)
