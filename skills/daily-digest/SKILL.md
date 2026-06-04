---
name: daily-digest
description: Generate a structured, shareable daily report from memory.md, git log, and buglog.json. Use when the user says "日报" / "收工" / "wrap up" / "daily digest" / "今天做了什么".
metadata:
  short-description: 从 memory/buglog/git 生成结构化日报，可分享给团队
---

# /daily-digest — Structured Daily Report

从会话数据生成可分享的日报。没写代码的同事应该能看懂——用自然语言，不含 commit hash，有清晰的成果产出。

## 与 Superpowers 联动

```
/execute-plan → /obsidian → /daily-digest
       ↑             ↑             ↑
   "写了一天代码" "永久存档"   "到底做了什么"
```

这是 Superpowers 工作流的收尾环节。跑完 `/execute-plan` 后，`/daily-digest` 收束整天的产出。也适合在 `/openwolf check` 之后跑，把 check 发现的问题写进日报的 bug 段。

## Phased Workflow

### Phase 1: Collect Data Sources

收集今天所有可用数据。按本地日期过滤。

**源 A — memory.md:**
解析 `.wolf/memory.md`。格式为 `| HH:MM | description | file(s) | ~tokens |`。提取今天日期对应的条目。如果日期不明确，用最近 50 行按最新性过滤。

**源 B — git log:**
```bash
git log --since="today 00:00" --oneline --no-decorate
```
如果今天没有 commit，记下来——这也是有用信息。

**源 C — buglog.json:**
搜 `.wolf/buglog.json` 中 `timestamp` 或 `last_seen` 为今天的 bug。按 `occurrences` 区分"新发现"（=1）和"修复中/复发"（>1）。

**源 D — cerebrum.md:**
检查 `.wolf/cerebrum.md` 今天是否更新。记录更新的段。

### Phase 2: Synthesize Overview

写 1-2 句捕捉当天主题。这是 TL;DR——看一眼就能理解当天的产出焦点。

**好的 Overview:**
- "完成酒包ERP报价引擎v2重构，修复3个精度bug，新增21个测试"
- "深析Pro部署迁移到阿里云，podman cp流程优化，文档更新"

**差的 Overview:**
- "修改了多个文件"（太模糊）
- "feat: add pricing, fix: encoding, refactor: export"（这是 commit log，不是总结）

### Phase 3: Categorize Changes

把所有文件变更和 commit 归入六类：

| 类别 | 归入条件 |
|------|----------|
| 新功能 | 新能力、新端点、新组件 |
| 修复 | Bug 解决、错误纠正 |
| 重构 | 代码移动/重命名/拆分，行为不变 |
| 运维 | 部署、配置、CI/CD、依赖更新 |
| 文档 | Spec、README、注释、memory 文件 |
| 调研 | 研究、探索、调试（无代码变更） |

### Phase 4: Assemble Digest

按固定模板输出：

```markdown
# 日报 — [YYYY-MM-DD 星期X]

## 概览
[1-2 句当天主题和主要产出]

## 变更

### 新功能
- [一句话描述] — `file/path.py` (+N 行)
- [没有就说"无"]

### 修复
- [什么坏了 → 怎么修的] — `file/path.py`
- [关联 buglog ID: bug-042, bug-043]

### 重构
- [移动/拆分/重命名了什么 — 为什么]

### 运维
- [部署、配置变更、依赖更新]

### 文档
- [新建或更新的文档/spec]

## Bug 记录

### 新发现的 Bug
| ID | 描述 | 文件 | 状态 |
|----|------|------|------|
| bug-042 | 报价精度丢失 | pricing.py | 已修复 |
| bug-043 | SSH 连接池耗尽 | deploy.py | 待修复 |

### 已修复的 Bug
| ID | 描述 | 根因 | 修复方式 |
|----|------|------|----------|
| bug-040 | 百分比单位混用 | 前后端不一致 | 统一为0-1小数 |

[今天没 bug 就说: "今日无新bug / 无bug修复"]

## 决策
- [今天做的架构或技术决策]
- [没有就说"无重大决策"]

## Token 消耗
- **读取**: ~X,XXX tok (N files)
- **写入**: ~X,XXX tok (M files)
- **总计**: ~XX,XXX tok

## 明日待办
- [对话中明确提到的待办项]
- [今天未完成的事项]
- [不确定就说"待用户确认"]
```

### Phase 5: Persist and Distribute

1. 追加到 `.wolf/memory.md`:
   ```
   | HH:MM | 日报 — [overview 一句话] | [今天改过的文件们] | ~XX,XXX tok |
   ```

2. 提供复制到剪贴板（方便粘贴到团队群/日报系统/Obsidian）

## 日报质量标准

日报必须**可分享**——没写代码的同事应该能看懂：

- 完成了什么
- 什么坏了、修好了
- 做了什么决策
- 明天待办是什么

**好**: "修复报价引擎精度bug — 前端乘100后端不乘，统一为0-1小数，新增3个精度测试"
**差**: "fix: pricing precision"（太简略，没上下文）

**好**: "决定用podman cp代替podman build部署，节省15分钟/次"
**差**: "改用podman cp"（没有原因和影响）

## Rules

- **DO** 合成 Overview——不要只是拼接 commit message
- **DO** 用自然语言——"修复报价精度" 不是 "fix(engine): normalize decimal handling"
- **DO** 分类变更——原始文件列表不是日报
- **DO** 包含发现的 bug 和修复的 bug——两者都重要
- **DO** 列出明日待办——让日报有前瞻性
- **DO** 末尾提供剪贴板复制——日报是用来分享的
- **DON'T** 在正文中含 commit hash——对非开发是噪音
- **DON'T** 列举每个文件——按功能/主题分组
- **DON'T** 跳过 Overview——它是阅读量最高的一段
- **DON'T** 写太长——日报本身 500-1500 tok
- **DON'T** 没讨论就猜明日任务——写"待用户确认"
