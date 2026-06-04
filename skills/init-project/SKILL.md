---
name: init-project
description: Initialize a new project with best-practice scaffolding. Read project plans, search GitHub for similar projects, extract the best patterns, then generate a customized project base (directory structure, configs, CI, tests, rules). Use this when starting a new project, after discussing a project idea, or when the user says "初始化项目" / "搭建项目" / "创建项目".
metadata:
  short-description: Initialize project from plans + similar projects research
---

# Init Project

Start new projects the smart way — learn from others before writing a single line.

## Core Principle

**Don't guess. Search first.** Before generating anything, find 2-3 successful open-source projects that solve similar problems. Learn their structure, then adapt — don't blindly copy or template.

## Workflow

### Phase 0: Understand (from plans, free)

Read the project plan from 4 sources (same as setup-rules):

1. **Current conversation** — what did the user just discuss?
2. **Project directory** — plan.md, PRD.md, architecture.md, .wolf/cerebrum.md
3. **Claude Code memory** — `~/.claude/memory/MEMORY.md`, search project name
4. **Codex memory** — `~/.codex/memories/MEMORY.md`, search project name

Extract:
- **Purpose** — what problem does this project solve?
- **Tech hints** — languages, frameworks, databases mentioned
- **Constraints** — deadlines, scale, compliance, team size
- **Phase plan** — P0→P1→P2 if the plan has one

Stop here. If the plan is vague (no tech stack decided), ask the user 2-3 focused questions. Don't generate a base from thin air.

### Phase 1: Search Similar Projects (network, ~2000 token)

Based on the tech hints from Phase 0, search for real-world references:

```
WebSearch: "<tech stack> <domain> open source project structure 2025 2026"
WebSearch: "<framework> project template best practices directory layout"
gh search repos --sort stars --limit 5 "<tech> <domain>"
```

Pick the **top 2-3** projects. For each, analyze:

| What to look at | Why |
|----------------|-----|
| Directory structure | How do they organize modules? |
| pyproject.toml / package.json | What deps? What versions? What tool config? |
| CI config (.github/workflows/) | What checks do they run? |
| Tests directory | How do they structure tests? |
| Dockerfile / deploy config | How do they deploy? |

**Output**: a comparison table of the 2-3 projects, highlighting the best pattern in each category.

### Phase 2: Ask the Gaps

Phase 0-1 covers 80%. Now ask the user only what's still unclear:

| Already known (from plans + search) | Still needs asking |
|-------------------------------------|-------------------|
| Python + FastAPI (from plan) | PostgreSQL or SQLite? |
| pytest + ruff (from reference projects) | Frontend needed? |
| Docker deploy (from reference projects) | Windows-only or cross-platform? |
| Module structure (from best reference) | Project name? |

**Max 3 questions.** If more than 3 things are unclear, go back to Phase 1 and search more specifically.

### Phase 3: Generate Base

Generate the project skeleton. Every file must have a reason — either from the plan, a reference project, or a user answer.

```
<project-name>/
├── pyproject.toml          # deps + tool config (ruff, pytest, mypy)
├── .gitignore              # Python + IDE + .env + OS-specific
├── .env.example            # all needed env vars, documented
├── Dockerfile              # from reference projects, adapted
├── docker-compose.yml      # app + DB + optional services
├── .github/workflows/      # CI: lint, test, security scan
│   └── ci.yml
├── .pre-commit-config.yaml # ruff format + lint + bandit
├── src/                    # main package
│   ├── __init__.py
│   └── main.py             # entry point
├── tests/
│   ├── __init__.py
│   └── conftest.py         # fixtures: test client, test DB
├── docs/                   # empty, ready for docs
├── CLAUDE.md               # auto-generated via setup-rules
└── AGENTS.md               # auto-generated via setup-rules
```

Key principles:
- **Minimal but complete** — every file serves a purpose, no boilerplate filler
- **Adapt to phase** — P0 prototype? Skip Docker, use SQLite. P3 production? Full CI + PG + monitoring.
- **Match reference patterns** — directory layout should feel familiar to anyone who knows the framework
- **Config over code** — use pyproject.toml for all tool config, avoid separate config files

### Phase 4: Run Setup-Rules

Immediately invoke `/setup-rules` on the new project. This:

1. Generates CLAUDE.md + AGENTS.md with project-specific rules
2. Since the project is brand new (no git history yet), it'll focus on domain pitfalls + conventions
3. The rules will grow with the project via `--update`

### Phase 5: Init Git & First Commit

```bash
git init && git add -A && git commit -m "chore: init project base"
```

### Phase 6: Quick Verify

- Run `pytest` — should pass with 0 tests (or a single placeholder)
- Run `ruff check .` — should pass with 0 errors
- If Docker was requested, `docker compose up` should start

## Token Budget

| Phase | Max tokens |
|-------|-----------|
| Understand (plans) | 500 |
| Search similar projects | 2000 |
| Ask gaps | 200 |
| Generate base | 1000 |
| Setup-rules | 3700 |
| Init git + verify | 200 |
| **Total** | **~7600** |

## Rules

- DO NOT generate a base without first searching similar projects
- DO NOT ask more than 3 questions in Phase 2
- DO NOT include boilerplate the user didn't ask for
- DO match the phase: prototype → simple, production → complete
- DO use the reference projects' exact versions for key dependencies
- DO run setup-rules as part of init — rules from day one
- DO NOT generate README.md or other documentation files unless asked
- Every generated file must justify its existence: "this is here because <reference project X does this, or user explicitly asked for it>"
