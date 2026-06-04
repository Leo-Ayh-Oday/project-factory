---
name: estimate
description: Estimate affected files, token cost, and risk level for a one-line requirement using anatomy.md + buglog.json + cerebrum.md. Use when the user describes a task and asks "评估" / "estimate" / "复杂度" / "这要改多少".
metadata:
  short-description: 基于 anatomy/buglog/cerebrum 评估需求的改动范围和风险等级
---

# /estimate — Task Complexity & Risk Estimator

写代码之前，先评估你要碰什么。用 `.wolf/anatomy.md` 做文件清单、`.wolf/buglog.json` 查 bug 历史、`.wolf/cerebrum.md` 查已知警告。

## 与 Superpowers 联动

```
/markitdown 需求.pdf → /learn-from-bugs → /brainstorm → /estimate → /write-plan → /execute-plan → /obsidian
                                                                  ↑                                        ↑
                                                         "想法很好，但改动多大？"                   "永久存档"
```

`/brainstorm` 产出想法后，`/estimate` 给出量化的改动范围和风险。如果风险 HIGH/CRITICAL，建议先开 plan mode。如果是 LOW/MEDIUM，可以直接进 `/execute-plan`。也适合在 `/write-plan` 写完后二次评估——计划是否覆盖了所有高风险文件。

## Phased Workflow

### Phase 1: Parse Requirement Into Keywords

从用户描述中提取可搜索的关键词：

1. **模块名**: 目录、包、子系统（如 "auth", "quote", "engine"）
2. **功能动词**: 表示改动的动词（如 "加接口", "修编码", "重构定价"）
3. **文件模式**: 明确提到的文件或强烈暗示的路径

如果需求太模糊提取不到关键词，问用户一个澄清问题。不要猜。

### Phase 2: Search Anatomy for Matching Files

在 `.wolf/anatomy.md` 中对每个关键词做模糊匹配：

- **精确匹配**: 关键词出现在文件路径或描述中
- **模糊匹配**: 关键词与文件共享目录前缀或词干
- **无匹配**: 关键词无命中——标记为不确定项

对每个匹配文件记录：路径、token 估算（`(~N tok)` 标记）、一行描述。

### Phase 3: Check Buglog for File History

对每个匹配文件查 `.wolf/buglog.json`：

- 该文件有几个历史 bug？
- 根因是什么？
- 最近 7 天有无新 bug？

有近期 bug 历史的文件改动风险更高。

### Phase 4: Check Cerebrum for Warnings

对每个匹配文件和关键词，扫 `.wolf/cerebrum.md`：

- **Do-Not-Repeat**: 是否有匹配文件/模块/模式的条目？
- **Key Learnings**: 是否有影响实现的约定？
- **Decision Log**: 是否有必须遵守的架构约束？

有 cerebrum 警告的文件需要额外小心。

### Phase 5: Compute Risk Score

```
risk = (file_size_weight × 0.4) + (bug_history_weight × 0.35) + (cerebrum_warning_weight × 0.25)
```

- **file_size_weight**: `min(token_estimate / 2000, 1.0)` — 超 2000 tok 为满风险
- **bug_history_weight**: `min(bug_count / 3, 1.0)` — 3+ bugs = 满风险
- **cerebrum_warning_weight**: 有 Do-Not-Repeat 匹配 = 1.0，否则 0.0

单文件风险标签: `≥0.7` → HIGH | `≥0.4` → MEDIUM | `<0.4` → LOW

### Phase 6: Output Estimate

```
## /estimate: [需求一句话总结]

### 受影响文件
| 文件 | Tokens | Bugs | 警告 | 风险 |
|------|--------|------|------|------|
| engine/pricing.py | ~1193 | 2 | Yes: 百分比单位 | HIGH |
| api/main.py | ~5913 | 0 | None | MEDIUM |
| data/materials.json | ~846 | 0 | None | LOW |

### 总结
- **涉及文件**: N 个
- **Token 估算**: ~X,XXX tok（读+写）
- **整体风险**: LOW / MEDIUM / HIGH / CRITICAL

### 风险评估
[1-2 句解释整体风险等级的含义]

### 建议
- **LOW/MEDIUM**: 可以直接做，不需要 plan mode
- **HIGH**: 建议用 plan mode 或 `/write-plan`。考虑分阶段
- **CRITICAL**: 停止。至少一个文件 HIGH + cerebrum 警告 + 近期 bug。建议拆成 2-3 个小任务

### 不确定项
- [需求中提到但 anatomy 中没找到的文件/概念]
- [需要澄清的需求歧义]
```

## 风险等级指南

| 等级 | 条件 | 行动 |
|------|------|------|
| LOW | 全文件 <800 tok, 无 bug, 无警告 | 直接做 |
| MEDIUM | 部分文件 800-2000 tok, 少量 bug | 小心做 |
| HIGH | 文件 >2000 tok 或 ≥2 bugs 或 cerebrum 匹配 | 开 plan mode |
| CRITICAL | ≥3 HIGH 文件或同文件 bug 复发 | 强制拆分 |

**宁高勿低**。高估浪费一次规划。低估浪费整个会话。

## Rules

- **DO** 先提取关键词再搜索
- **DO** 用 anatomy.md 作为主文件清单 —— 它是最快的索引
- **DO** 近期 bug 权重高于陈旧 bug
- **DO** cerebrum Do-Not-Repeat 匹配自动标 HIGH
- **DO** 显式标记不确定项 —— "anatomy 中未找到" 是重要信息
- **DO** 宁高勿低 —— 低估代价远大于高估
- **DON'T** 猜测不在 anatomy.md 里的文件路径
- **DON'T** 评估时读取源文件 —— anatomy.md 就是摘要
- **DON'T** 给时间估算（小时/天）—— 用 token 数代替
- **DON'T** 从这个 skill 直接开始写代码 —— 交给 `/execute-plan` 或 planner agent
