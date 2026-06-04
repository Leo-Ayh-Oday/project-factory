---
name: setup-rules
description: Scan a project, search for real-world pitfalls, extract implicit conventions, and generate concise CLAUDE.md / AGENTS.md rules. Use this when starting a new project, after adding new dependencies, or when the project changes direction. Supports --update for incremental refresh.
metadata:
  short-description: Generate project rules from real pitfalls + conventions
---

# Setup Rules

Generate project rules that actually prevent bugs — not generic best practices the model already knows.

## When to Use

- `/setup-rules` — first run, generate rules from scratch
- `/setup-rules --update` — incremental refresh (see --update logic below)
- User says "给我写项目规则" / "生成 CLAUDE.md"

### --update Logic

When `--update` is passed, don't redo all phases. Instead:

1. Read existing `CLAUDE.md`, extract its last-modified timestamp
2. Run `git log --oneline --since="<that date>"` — only look at commits AFTER the last rules update
3. If 0 new fix/revert commits: **stop and say "规则已是最新，无需更新"** — don't waste tokens
4. If new commits found: run Phase 3 on the new commits only, append to History section
5. Also re-run Phase 4 (dependency audit) — vulns are time-sensitive
6. Skip all other phases unless the user explicitly says the project changed direction

## Core Principle

**Don't tell the AI what it already knows.** Skip "use meaningful names", "write tests", "handle errors". Skip framework 101 (FastAPI lifespan, CORS config — Claude knows these). Focus on:

1. **This project's scars** — what actually broke before (git fix/revert commits)
2. **This domain's traps** — industry-specific gotchas (mm vs cm, 酒精度 vs 温度, 天地盖 vs 双插盒)
3. **This team's decisions** — architectural choices from plan files and discussions
4. **This codebase's conventions** — implicit patterns a newcomer would miss

## Workflow

### Phase 0: Identity (free, local)

Read the best of these, stop at first hit:

```
README.md / README_CN.md / README / description in pyproject.toml
```

Also scan for plan/design docs:

```
plan.md / PRD.md / architecture.md / docs/ / specs/ / .wolf/
```

Extract:
- **What this project IS** — one sentence positioning
- **Who it's for** — industry, user persona
- **Key architectural decisions** from plans — "we chose X over Y because Z"

**Output**: project identity, ≤50 words. + 0-2 architectural decisions.

### Phase 1: Structure & Conventions (free, local)

**Directory structure** — top 2 levels, draw a tree like:

```
project/
├── engine/          # core logic
├── api/             # FastAPI routes
├── tests/           # pytest
└── static/          # frontend assets
```

**Import patterns** — read 3 random source files. Detect:
- Import order convention
- `from engine.x import y` → `engine/` is the core module
- Which modules import which → dependency direction (engine → api? api → engine?)

**Build/Run/Test** — exact commands from:
- `pyproject.toml` `[project.scripts]`
- `run.py` / `start.bat` / `Makefile` / npm scripts
- `[tool.pytest.ini_options]` or `jest.config`

**Lint/Format** — from `ruff.toml`, `.pre-commit-config.yaml`, `.eslintrc`

**Rules**: 2-4 items. Each ≤2 lines. Only include what's non-obvious.

### Phase 2: Plans & Decisions (4 sources)

Plans live in four places. Check them in order, stop after finding 2+ relevant items:

**Source 1 — Project directory** (Phase 0 already scanned):
```
plan.md / PRD.md / architecture.md / design.md / docs/ / specs/ / .wolf/cerebrum.md
```

**Source 2 — Claude Code global state**:
```
~/.claude/plans/                          # plan mode outputs
~/.claude/projects/<project-hash>/memory/ # per-project memory
~/.claude/memory/MEMORY.md                # check for entries matching this project name
```
Search MEMORY.md for the project name or its key modules. Read matching memory files.

**Source 3 — Codex global state**:
```
~/.codex/memories/MEMORY.md               # check for entries matching this project name
~/.codex/skills/<project-related>/        # custom skills built for this project
```

**Source 4 — Current conversation context**:
The AI already has this. Ask yourself: "Did the user and I just discuss a plan, architecture, or roadmap for this project?" If yes, extract the decisions directly from context — no file read needed.

**From all sources, extract**:

| Plan content | Rule type |
|---|---|
| "Phase 1 will use X, Phase 2 migrate to Y" | Architecture constraint — don't build on X for long-lived features |
| "We decided on PostgreSQL over MongoDB because..." | Runtime constraint — PostgreSQL-specific features only |
| Module priority table (P0→P3) | Implementation order — P0 modules are critical path |
| "Integration points: A calls B via REST, C via MQ" | Module boundary — respect the chosen protocol per pair |

**Rules**: 0-5 items. The more sources hit, the better the rules. Context (source 4) is free — always check it first.

### Phase 3: Git History (PRIMARY RULE SOURCE)

```bash
git log --oneline -30
```

This is the **most valuable phase**. These rules come from real blood:

- **Revert commits** (`Revert "..."`): the reverted change is a direct anti-rule
- **Bug fixes** (`fix: ...`): the bug's root cause IS the rule
- **Repeated refactoring of same file/area**: that module is fragile
- **`fix: revert image_gen timeout to 45s`** → "生图超时不能超 45s，API 限流"
- **`fix: MCP tools DB injection`** → "MCP tool handler 禁止拼接 SQL"

For each fix/revert commit, read the diff to understand the actual bug:

```bash
git show <commit> --stat
```

**Rules**: 2-5 items. These are your highest-quality rules. Each with commit hash.

### Phase 4: Dependency Audit

Auto-install and run the matching tool:

| Project type | Install | Run |
|-------------|---------|-----|
| `pyproject.toml` / `requirements.txt` | `pip install pip-audit -q` | `pip-audit --format json` |
| (Windows 中文路径 fallback) | `pip install safety -q` | `safety scan --json` |
| `package.json` | (npm audit 自带) | `npm audit --json` |
| `Cargo.toml` | (cargo audit 自带) | `cargo audit --json` |

If audit finds known vulns, add 1-2 rules with the fix version. If install fails, skip silently.

### Phase 5: Domain Pitfalls (network)

**Do NOT search for framework pitfalls.** Claude already knows FastAPI, React, Docker.

Search for **industry/domain-specific** traps:

```
WebSearch: "<行业> <技术> 常见错误 参数 单位"
WebSearch: "<业务领域> 踩坑 设计 尺寸 生产"
```

Examples:
- 包装行业: "天地盖 尺寸 单位 mm cm 常见错误"
- 量化交易: "A股 除权除息 复权 回测 常见坑"
- 医疗: "HL7 FHIR 字段映射 常见错误 编码"

Also search the project's own GitHub issues — these are higher quality than web search:

```bash
# Check if gh CLI is available and repo has a remote
gh auth status 2>/dev/null && git remote get-url origin 2>/dev/null
```

If both pass:
```bash
# Closed bugs — the scars that made it to production
gh issue list --limit 30 --state closed --search "bug" --json title,body,labels,closedAt 2>/dev/null

# Also check for "mistake", "wrong", "error", "failed", "crash"
gh issue list --limit 20 --state closed --search "fix mistake wrong error" --json title,body,labels 2>/dev/null
```

Look for:
- Issues with `bug` label that were closed by a PR → the PR's fix is a rule
- Issues that mention the same module/file repeatedly → that module is error-prone
- Issues with titles like "X always fails when Y" → the Y condition is the rule trigger

**Rules**: 2-4 items. Must be domain-specific, not framework-generic. Include source (issue # or URL).

### Phase 6: Assemble

Combine all rules. Output format:

```markdown
# <Project Name>
<一句话定位>

## Tech Stack
- 后端: Python 3.10+ / FastAPI 0.115 / CadQuery 2.7
- 数据库: LanceDB (本地) / PostgreSQL (生产)
- 部署: uvicorn --host 0.0.0.0 --port 8000

## Project Structure
<directory tree, top 2 levels with brief annotations>

## Module Priorities
<from plan files, if any. P0→P1→P2 table>

## Architecture Rules
<from Phase 1 import patterns + Phase 2 decisions>
- X 操作统一走 `engine/`，不要在各处直接调用

## Conventions
<from Phase 1>
- 导入顺序: stdlib → 三方 → 本地
- 测试: `tests/test_*.py`，pytest

## Domain Pitfalls
<from Phase 5 — industry traps>
- 天地盖参数单位是 mm，不是 cm — 之前生成过 10x 尺寸 (git: abc123)

## History
<from Phase 3 — scars with commit hashes>
- `fix: revert image_gen timeout to 45s` — 生图超时不能超 45s (git: def456)
- `fix: MCP tools DB injection` — 禁止拼接 SQL (git: a28ac91)

## Dependencies
<from Phase 4 — vuln fixes, if any>
- `sqlalchemy>=2.0.27` — 2.0.23 有连接池泄漏 (CVE-2024-xxxx)
```

### Phase 7: Write

Write to `<project_root>/CLAUDE.md` and `<project_root>/AGENTS.md`.

- First run: create the file
- `--update`: read existing file, only appending new rules that don't overlap

### Phase 8: Self-Check (validate before reporting done)

After writing, take the **most recent 2-3 git fix commits** and do a counterfactual test:

> "Given rule X (just written), would it have **prevented** bug Y (from commit Z)?"

For each pair:
- **Caught** — the rule directly blocks the bug → ✅
- **Missed** — the bug would still happen despite the rule → 🔴 **Go back and add a rule that would have caught it.**
- **Unrelated** — the bug is in a different area → skip

If any `🔴 Missed`, revise the rules before reporting done. This is the quality gate — don't ship rules that wouldn't have caught the project's own recent bugs.

Output at the end of the run:
```
Self-check: 3 recent fixes tested, 2 caught, 0 missed, 1 unrelated → PASS ✅
```

## Token Budget

| Phase | Max tokens |
|-------|-----------|
| Identity + Plans | 500 |
| Structure scan | 300 |
| Git history (primary) | 200 |
| Dependency audit | 100 |
| Domain pitfalls | 2000 |
| GitHub Issues | 300 |
| Self-check | 300 |
| **Generated rules** | **≤500** |
| **Total consumed** | **~3700** |

## Rules

- DO NOT generate generic advice the model already knows
- DO NOT explain framework basics (CORS, lifespan, async patterns)
- DO NOT generate more than 15 rules total
- DO specify exact versions, paths, commands, commit hashes
- DO prioritize git history over web search — scars > hearsay
- DO search for domain-specific pitfalls, not framework 101
- DO preserve any existing user-written rules
- DO run Phase 8 self-check before reporting done — if a recent bug would still happen, fix the rules
- For `--update`: only process git commits newer than the existing CLAUDE.md; if 0 new commits, stop early
- **Output must include**: project identity line + directory tree + at least one git-history rule (if repo exists) + self-check PASS/FAIL result
