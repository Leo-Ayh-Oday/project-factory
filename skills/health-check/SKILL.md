---
name: health-check
description: Run a comprehensive project health check: dependency vulnerabilities, outdated packages, test coverage, code quality, tech debt signals. Triggered by "体检" / "health check" / "健康检查" / "项目检查" / "audit".
metadata:
  short-description: 项目全身体检：依赖安全 + 版本过期 + 覆盖率 + 技术债信号
---

# /health-check — Project Health Audit

定期体检，在问题变成 bug 之前发现它。

## 与 Superpowers 联动

```
/openwolf check → /health-check → /learn-from-bugs → /brainstorm → /estimate → /write-plan
  上下文同步         体检报告          挖掘模式         讨论方案        评估范围       执行修复
                        ↑
               "哪里有问题、多严重"
```

`/openwolf check` 保证上下文是新的 → `/health-check` 扫描发现问题 → 有 bug 模式丢给 `/learn-from-bugs` 深挖 → `/brainstorm` 讨论怎么修 → `/estimate` 评估 → `/write-plan` 执行。

也适合合并前跑（替代手动 reviewer 检查清单），和 `/daily-digest` 之前跑（把问题写进日报）。

## Phased Workflow

### Phase 1: Dependency Audit

```bash
# Python
pip list --outdated
pip-audit  # 安全漏洞

# Node
npm outdated
npm audit --json

# 通用
check: pyproject.toml / package.json / go.mod — 是否有 unpinned deps
```

输出：
| 级别 | 问题 | 包 | 当前 | 最新 | 修复 |
|------|------|-----|------|------|------|
| CRITICAL | CVE-2024-xxxx | flask | 2.0 | 3.1 | `pip install flask>=3.1` |
| HIGH | 2 major behind | react | 17 | 19 | 需手动迁移 |
| LOW | patch missing | ruff | 0.8 | 0.8.1 | `pip install --upgrade` |

### Phase 2: Test Coverage

```bash
pytest --cov --cov-report=json  # Python
npx vitest --coverage           # Node
```

- 总覆盖率 %
- <80% 的文件列表（标红）
- 零覆盖的新文件（最近 3 次 commit）

### Phase 3: Code Quality Scan

不用跑 linter（OpenWolf 已经管了），聚焦：

- **巨型文件**: >800 行
- **巨型函数**: >50 行
- **深层嵌套**: >4 层
- **重复代码**: 同逻辑出现在 ≥2 处
- **TODO/FIXME/HACK**: 积压的注释
- **死代码**: 无导入/无调用的函数

### Phase 4: Tech Debt Signals

- **依赖圈数**: import 循环？模块之间耦合？
- **文件热点**: buglog 中 ≥3 个 bug 的文件 → 建议重构
- **规则违反**: cerebrum Do-Not-Repeat 中是否还有实例？
- **文档过期**: anatomy.md 中标记 `[stale]` 的文件

### Phase 5: Output Report

```
## /health-check: [项目名] 体检报告

**日期**: 2026-06-04 | **得分**: 72/100

### 🔴 Critical (立即修复)
| 问题 | 文件/包 | 行动 |
|------|---------|------|
| CVE in flask 2.0 | requirements.txt | pip install flask>=3.1 |

### 🟡 Warning (本周修复)
| 问题 | 详情 |
|------|------|
| 3 files <80% coverage | engine/pricing.py (42%), ... |
| 2 god files >800 lines | api/main.py (2341), ... |

### 🟢 OK
- 测试覆盖率: 83% ✓
- 安全漏洞: 1 critical (见上)
- 过期依赖: 4 (2 major, 2 patch)

### 建议行动
1. 先修 CRITICAL 安全漏洞
2. engine/pricing.py 拆分（历史 5 bugs）
3. 考虑: /learn-from-bugs 深挖 pricing 文件

### 联动提示
→ /learn-from-bugs 深挖 engine/pricing.py 的 5 个历史 bug
→ /brainstorm 讨论 flask 升级方案
→ /estimate 评估修复范围
```

## Rules

- **DO** 先跑 `/openwolf check` 确保数据最新
- **DO** 区分 CRITICAL/WARNING/OK 三级
- **DO** 每条问题给出具体修复命令
- **DO** 体检结束给出联动建议（→ 下一步用哪个 skill）
- **DON'T** 自动修复 — 体检只诊断，不治疗
- **DON'T** 跳过依赖安全扫描 — 这是最高价值的检查
- **DON'T** 只报问题不报好消息 — OK 的部分也很重要
