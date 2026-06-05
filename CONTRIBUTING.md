# Contributing to Project Factory

Thanks for helping build the skills ecosystem.

## Ways to Contribute

- **Submit a new skill** — create `skills/<name>/SKILL.md` following the [skill template](#skill-structure)
- **Improve existing skills** — fix bugs, add edge cases, update references
- **Report issues** — open a GitHub issue for bugs, ideas, or skill requests

## Skill Structure

Each skill follows this template:

```
skills/<skill-name>/
├── SKILL.md              # Required: main skill file
├── references/           # Optional: reference docs
│   ├── *.md
│   └── *.json
├── hooks/                # Optional: hooks.json
├── scripts/              # Optional: helper scripts
└── presets/              # Optional: preset data files
```

### SKILL.md Requirements

- Frontmatter: `name`, `description`, `metadata.short-description`
- Clear trigger words for auto-invocation
- Phased workflow with explicit instructions
- Input/output specification
- Token budget (for heavy skills)

## Commit Conventions

```
feat: add /new-skill-name — one-line description
fix: correct behavior in /skill-name when X happens
docs: update skill-name reference guide
```

## Pull Request Checklist

- [ ] SKILL.md follows the template above
- [ ] Tested with Claude Code (not just reading, actually invoked)
- [ ] No hardcoded personal paths or credentials
- [ ] README.md updated if adding a new skill

## License

All contributions are MIT licensed.
