# Security Policy

## Reporting a Vulnerability

**Do not open a public issue.** Email [2115464137@qq.com](mailto:2115464137@qq.com) with:

- A clear description of the vulnerability
- Steps to reproduce
- Any potential impact

Response within **48 hours**.

## Scope

- Skill prompt injection or manipulation
- Malicious skill code execution
- Sensitive data leakage through skill output

## Best Practices

1. **Review skills before installing** — check SKILL.md and any scripts
2. **Keep skills updated** — `git pull` regularly
3. **Audit hooks** — hooks in `openwolf/hooks/` run on your machine, review them first
