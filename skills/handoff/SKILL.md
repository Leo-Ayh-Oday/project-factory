---
name: handoff
description: Generate a complete project handoff package: architecture overview, onboarding guide, deployment docs, known pitfalls, and decision log. Triggered by "交接" / "handoff" / "项目文档" / "onboarding" / "新人指南".
metadata:
  short-description: 生成完整交接文档包：架构+入手指南+部署+坑位+决策记录
---

# /handoff — Project Handoff Package

把项目的隐性知识变成文档。下一个开发者（或六个月后的你）能在 30 分钟内上手。

## 与 Superpowers 联动

```
/execute-plan → /handoff → /obsidian → /daily-digest
    代码写完        交接包     永久归档      日报
                    ↑
           "这个项目怎么接手"
```

项目写完（或里程碑结束），`/handoff` 把散落在 `.wolf/`、buglog、cerebrum、git log 中的隐性知识聚合成一份完整文档。然后 `/obsidian` 归档，`/daily-digest` 在日报里记一笔。

## Phased Workflow

### Phase 1: Collect Knowledge Sources

不凭空写，从已有数据源提取：

| 数据源 | 提取内容 |
|--------|---------|
| `.wolf/anatomy.md` | 完整文件清单 + token 估算 |
| `.wolf/cerebrum.md` | Key Learnings + Do-Not-Repeat + Decision Log |
| `.wolf/buglog.json` | 高频 bug 文件 + 根因摘要 |
| `.wolf/memory.md` | 开发时间线 + 关键节点 |
| `CLAUDE.md` / `AGENTS.md` | 项目规则和约定 |
| `git log --oneline` | 最近 50 条提交摘要 |
| `README.md` | 已有的项目介绍 |

### Phase 2: Generate Docs

输出一个文档包，每个文件 ≤500 行：

#### 1. `docs/ARCHITECTURE.md` — 架构概览（新人先读这个）
```markdown
# [项目名] 架构概览

## 一句话定位
## 核心模块（来自 anatomy.md）
## 数据流（关键路径）
## 技术选型（+ Decision Log 引用）
## 外部依赖（API、数据库、服务）
```

#### 2. `docs/ONBOARDING.md` — 30 分钟入手指南
```markdown
# 入手指南

## 环境搭建（5 min）
## 跑起来（5 min）
## 项目结构导览（10 min）
## 修改第一个功能（10 min）
## 常见问题
```

#### 3. `docs/DEPLOYMENT.md` — 部署手册
```markdown
# 部署手册

## 环境变量
## 构建
## 部署步骤
## 回滚
## 监控和告警
```

#### 4. `docs/PITFALLS.md` — 已知坑位（来自 buglog + cerebrum）
```markdown
# 已知坑位

## 容易出错的地方（Top 10 bug 根因）
## 不要碰的代码（"Don't touch unless..."）
## 约定陷阱（不直观但故意的设计）
```

### Phase 3: Cross-Link Everything

- 每个 doc 首尾有 `← 返回 [README](../README.md)` 
- PITFALLS 中每个条目引用 buglog ID
- ARCHITECTURE 中模块名链接到 anatomy.md
- DECISIONS 中引用 cerebrum Decision Log

### Phase 4: Summary

```
## /handoff: [项目名] 交接包

| 文档 | 行数 | 主要受众 |
|------|------|---------|
| ARCHITECTURE.md | ~300 | 架构师、Tech Lead |
| ONBOARDING.md | ~200 | 新开发者 |
| DEPLOYMENT.md | ~150 | DevOps、SRE |
| PITFALLS.md | ~250 | 所有人 |

**知识来源**: anatomy (37KB), buglog (217KB), cerebrum (14KB), memory (120KB)
**预计上手时间**: 30 分钟（阅读 ONBOARDING + ARCHITECTURE）
**下一步**: /obsidian 归档全部文档
```

## Rules

- **DO** 从已有数据源提取，不凭空写
- **DO** 区分四种文档的受众 — 架构师 vs 新人 vs DevOps
- **DO** 引用具体 bug ID 和 cerebrum 条目
- **DO** 每个 doc 末尾给出「下一步读什么」
- **DON'T** 写超过 500 行的文档 — 超过就拆分
- **DON'T** 重复 README 已有的内容 — 链接过去
- **DON'T** 猜测不确定的信息 — 写 `[待确认]` 比写错好
