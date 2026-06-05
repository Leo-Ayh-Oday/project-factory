# CI/CD Integration — 持续集成中运行规则审计

## GitHub Actions

```yaml
# .github/workflows/rules-audit.yml
name: Rules Audit

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Rules Audit
        run: |
          bash ~/.claude/skills/rules-audit/scripts/audit.sh --ci --json > audit-report.json
      - name: Check Score
        run: |
          SCORE=$(jq '.score' audit-report.json)
          if (( $(echo "$SCORE < 70" | bc -l) )); then
            echo "Audit score $SCORE is below 70 — failing"
            exit 1
          fi
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: audit-report
          path: audit-report.json
```

## GitLab CI

```yaml
# .gitlab-ci.yml
rules-audit:
  stage: test
  script:
    - bash ~/.claude/skills/rules-audit/scripts/audit.sh --ci --json > audit-report.json
    - |
      SCORE=$(jq '.score' audit-report.json)
      if (( $(echo "$SCORE < 70" | bc -l) )); then
        echo "FAIL: audit score $SCORE < 70"
        exit 1
      fi
  artifacts:
    paths:
      - audit-report.json
    expire_in: 30 days
  only:
    - merge_requests
    - main
```

## pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: rules-audit
        name: Rules Compliance Audit
        entry: bash ~/.claude/skills/rules-audit/scripts/audit.sh --fatal-only
        language: system
        pass_filenames: false
        always_run: true
```

## CI 模式参数

| 参数 | 含义 |
|------|------|
| `--ci` | CI 模式，自动修复不询问，非交互输出 |
| `--json` | 输出 JSON 到 stdout（禁止彩色/Markdown） |
| `--fatal-only` | 仅运行 fatal 级别规则 |
| `--preset <name>` | 只使用指定预设包 |
| `--scope <dir>` | 只扫描指定目录 |
| `--min-score <N>` | 最低通过分数，低于此分数 exit 1（默认 70） |

## 退出码

| 退出码 | 含义 |
|--------|------|
| 0 | 通过（分数 ≥ min-score 且无 fatal 违规） |
| 1 | 不通过（分数 < min-score） |
| 2 | 有 fatal 违规（一票否决） |
| 3 | 配置错误（预设包不存在、JSON 语法错误等） |

## 与已有 CI 工具并行

```
pre-commit:
  ├── prettier (格式化)
  ├── eslint (JS/TS 语法)
  ├── stylelint (CSS 语法)
  └── rules-audit (项目约定 + 设计约束)  ← 互补，不替换上面任何工具

CI pipeline:
  lint → type-check → test → rules-audit → build
```
