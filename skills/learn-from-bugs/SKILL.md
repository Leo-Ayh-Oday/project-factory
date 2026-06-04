---
name: learn-from-bugs
description: Analyze buglog.json to find recurring failure patterns, cross-reference with cerebrum.md Do-Not-Repeat, and generate actionable recommendations. Use when the user says "分析bug" / "learn from bugs" / "bug patterns" / "为什么老出错".
metadata:
  short-description: 从 buglog 挖掘重复错误模式，生成 cerebrum 条目和修复建议
---

# /learn-from-bugs — Bug Pattern Analysis

从 `.wolf/buglog.json` 中挖掘重复失败模式，交叉比对 `.wolf/cerebrum.md` Do-Not-Repeat，输出排序后可执行的修复建议和 cerebrum 条目。

## 与 Superpowers 联动

```
/markitdown 日志.pdf → /learn-from-bugs → /brainstorm → /estimate → /write-plan → /execute-plan → /obsidian
                            ↑                                                   ↑              ↑
                        "哪里最痛"                                      "系统性修复"    "永久存档"
```

在 `/brainstorm` 之前跑，让讨论有数据支撑："过去 30 天我们有 5 个超时 bug，不是偶然的"。输出中的 "Suggested Cerebrum Entry" 可以直接写入 cerebrum，下次会话自动加载。

## Phased Workflow

### Phase 1: Load Bug Data

读取两个 buglog 源（如果存在）：

1. 项目级: `.wolf/buglog.json`
2. 全局级: `~/.claude/.wolf/buglog.json`（跨项目参考，权重低）

解析 bugs 数组，提取: `id`, `file`, `root_cause`, `tags`, `occurrences`, `last_seen`。

### Phase 2: Group Into Clusters

三维聚类，一个 bug 可以出现在多个集群。

**维度 A — 同文件（热点检测）：**
按 `file` 分组。标记 ≥3 个不同 bug 的文件。

**维度 B — 同根因关键词：**
标准化 root_cause：转小写、去标点。用子串匹配，不做精确匹配——"SSH连接超时" 和 "SSH连接失败" 应归为一类。≥2 即标记。

**维度 C — 同 tag 组合：**
按排序后拼接的 tags 分组。≥2 即标记。

### Phase 3: Cross-Reference Cerebrum

对每个标记集群，检查 `.wolf/cerebrum.md` Do-Not-Repeat：

- **已知但复发**: 团队知道这个模式但它又出现了 → **HIGH severity**（预防措施失效）
- **新发现**: 不在 cerebrum 中 → **MEDIUM severity**（新洞察）

### Phase 4: Rank Findings

| 因子 | 权重 | 理由 |
|------|------|------|
| 发生次数 | 40% | 重复最多的代价最高 |
| Cerebrum 失配（已知但复发） | 30% | 已有预防失败，需升级 |
| 最近性（last_seen） | 20% | 近期 bug 比陈旧的更相关 |
| 跨项目信号 | 10% | 多项目出现 = 系统性问题 |

### Phase 5: Output Report

每个 finding 输出：

```
## Finding N: [模式名称]
**Severity**: HIGH / MEDIUM / LOW
**Evidence**: N bugs across M files, last seen YYYY-MM-DD
**Impact**: [一句话解释为什么这很重要]
**Recommendation**: [具体行动]
**Suggested Cerebrum Entry**:
  - [YYYY-MM-DD] **[一句话规则]** — 给下次会话的上下文
```

末尾汇总表：

| Rank | Pattern | Bugs | Known? | Action |
|------|---------|------|--------|--------|
| 1 | SSH 连接池耗尽 | 5 | Yes - recurred | 写自动检查脚本 |
| 2 | 中文编码错乱 | 3 | No - new | 加到 cerebrum |

## Pattern Recognition Heuristics

**阈值故意设低**: 2 次 = 模式。抓第 2 次防止第 3 次，等到 5 次太晚了。

**关键词相似度**: "超时" 匹配 "timeout" 匹配 "连接失败"——当它们都与网络可靠性相关时。用判断力，不只是字符串匹配。用一句话解释归类逻辑。

**文件热点 vs 根因系统性**:
- 同文件 5 个不同根因的 bug = **复杂度热点**（建议重构该文件）
- 同根因跨 5 个文件的 bug = **系统性缺陷**（建议架构/流程修复）

报告中必须区分这两种。

## Rules

- **DO** 同时读项目和全局 buglog.json
- **DO** ≥2 次就标记 —— 低阈值是故意的
- **DO** 解释 WHY 每个模式重要，不只是报告 THAT 它存在
- **DO** 给 copy-paste-ready 的 cerebrum Do-Not-Repeat 条目
- **DO** 区分"已知但复发"（更高 severity）和"新发现"
- **DO** 用子串匹配做根因聚类 —— 精确匹配太严格
- **DON'T** 按表面相似性分组（如"都是 Python 文件"）
- **DON'T** 不理解根因就建议修复 —— 每条建议必须引用 buglog 中的具体 root_cause
- **DON'T** 自动写 cerebrum.md —— 用户确认后再写
- **DON'T** 跳过 Phase 3 交叉比对 —— 这是本 skill 的核心价值
