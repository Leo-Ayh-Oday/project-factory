---
name: screenshot-to-spec
description: Read a screenshot image, analyze UI/UX structure, and generate a structured feature specification with component breakdown and implementation hints. Use when user provides a screenshot and says "转成需求" / "写 spec" / "screenshot to spec" / "分析这个界面".
metadata:
  short-description: 截图→结构化需求文档，含组件树+数据流+实现建议
---

# /screenshot-to-spec — Screenshot-Driven Feature Spec

把 UI 截图或设计稿转成结构化、可执行的功能需求文档。产出直接喂给 `/write-plan` 或 planner agent。

## 与 Superpowers 联动

```
/markitdown 原型.pdf → /screenshot-to-spec → /estimate → /write-plan → /execute-plan → /obsidian → /daily-digest
                             ↑                   ↑            ↑                        ↑
                        "我要做这个"        "改动多大"    "怎么写"              "永久存档"
```

截图转 spec → estimate 评估影响 → write-plan 写执行计划 → execute-plan 写代码 → daily-digest 记录日报。一整条流水线。spec 中的 `[需要确认]` 项可以在 `/brainstorm` 阶段讨论。

## Phased Workflow

### Phase 1: Read the Screenshot

用 Read 工具读取用户提供的截图路径。如果是 URL，让用户先下载或提供本地路径。

多张截图按给定顺序处理（如 "1-home.png, 2-detail.png"——视为一个流程）。

### Phase 2: Analyze Structure

从截图提取以下维度。区分 VISIBLE（可见）和 INFERRED（推断）。

**布局结构：**
```
- 顶层容器: [header/sidebar/main/footer — 逐一识别]
- 内容区域: [列出每个视觉区域]
- 网格/弹性布局: [元素如何空间排列]
- 响应式暗示: [mobile? desktop? 什么断点?]
```

**UI 组件检测：**
每个组件标注：类型（table/form/card/modal/nav/button group/chart 等）、大致位置、关键内容（标签、数据字段、占位文本）、交互元素（按钮、链接、输入框、下拉、标签页）

**数据展示：**
- 展示了什么数据字段？（如 "客户名, 订单ID, 状态徽章"）
- 数据格式？（如 "货币 2 位小数", "日期 YYYY-MM-DD"）
- 是否有分页/无限滚动/"加载更多"？

**隐含交互：**
- 点击 X 会怎样？
- 可能的表单提交？
- 可见的导航路径？
- 有 hover/focus/active 状态吗？

**需考虑的状态（即使截图没展示也要列）：**
- Loading（骨架屏？spinner？空壳？）
- Empty（暂无数据）
- Error（API 失败、校验错误）
- Success（操作后确认）
- Edge cases（超长文本、大量条目、特殊字符）

### Phase 3: Cross-Reference Project Anatomy

搜 `.wolf/anatomy.md` 找已有组件或模式：

- **可复用**: "这个表格像 `components/MarketTable.tsx`"
- **需新建**: "没有现成 modal 匹配——需要新 `ConfirmDialog`"
- **API 端点**: 把展示的数据映射到可能的已有 API 路由

### Phase 4: Generate Structured Spec

```markdown
# Spec: [功能名称]

> From: [截图路径] | Date: [今天] | Status: DRAFT — [N] 项 [需要确认]

## 1. 功能描述
[2-3 句——这个界面做什么，解决什么用户目标]

## 2. 组件树
[缩进表示父子关系]
- PageContainer
  - HeaderBar
    - BreadcrumbNav
    - ActionButton ("新建")
  - MainContent
    - FilterBar [需要确认: 有哪些筛选项？]
    - DataTable
      - StatusBadge (复用 components/StatusBadge.tsx)
      - ActionMenu (行内操作)
    - PaginationFooter
  - [NEW] ConfirmDialog (删除确认弹窗)

## 3. 数据流
- **数据源**: [已有 API 或需要新建的]
- **数据形态**: [关键字段+类型]
- **加载模式**: [mount 时请求？分页？无限滚动？]
- **变更操作**: [create/update/delete — 哪些操作改数据]

## 4. 边界情况 & 状态
| 状态 | 处理方式 |
|------|----------|
| Loading | 骨架行匹配表格列数 |
| Empty | "暂无数据" 插画 + "创建第一条" CTA |
| Error | Toast 通知，表格保留上次成功数据 |
| 长文本 | 截断+tooltip（客户名最多 20 字） |
| 多行 | 服务端分页，每页 20 条 [需要确认] |

## 5. 实现提示
- **Agent 分配**: planner → tdd-guide → code-reviewer
- **参考代码**:
  - `components/MarketTable.tsx` — 类似表格模式
  - `api/main.py` — 可能的端点位置
- **潜在陷阱**（来自 cerebrum Do-Not-Repeat）:
  - [相关 cerebrum 条目]
- **可能需要的新文件**:
  - `components/orders/OrderTable.tsx`
  - `components/orders/ConfirmDialog.tsx`

## 6. [需要确认] 项
1. [问题 1 — 解释为什么重要]
2. [问题 2 — 解释对实现的影响]
```

### Phase 5: Present and Iterate

展示 spec 给用户，特别询问 `[需要确认]` 项。用户可以回答→更新 spec，或者提供更多截图→从 Phase 1 重来，或者说"开始实现"→交给 `/write-plan`。

## Visual Analysis Heuristics

**用视觉线索检测组件：**
- 重复矩形卡片结构相同 → 列表/网格项
- 一行按钮组合 → ButtonGroup / Toolbar
- 文本+线+文本+线模式 → Key-Value 列表或详情
- 彩色圆点/徽章+短文本 → 状态指示器
- 背景略暗的方框 → Card 或 surface 容器

**不确定时：**
- 写 `[需要确认]`——不要猜
- 聚焦可见内容，不想象不存在的东西
- 不发明截图里没有的功能

## Rules

- **DO** 先读截图——它是核心输入
- **DO** 显式标记未知为 `[需要确认]`——猜测制造返工
- **DO** 交叉比对 anatomy.md 找可复用组件——别重造轮子
- **DO** 查 cerebrum Do-Not-Repeat 找相关警告
- **DO** 列出 ALL 状态（loading/empty/error/success）即使截图没展示
- **DO** 用 TypeScript 记法提示数据类型（当项目用 TS 时）
- **DON'T** 猜测不可见的内容——"这大概还有个设置页吧"
- **DON'T** 写实现代码——本 skill 产出 SPEC，不是代码
- **DON'T** 跳过边界情况段——这是对规划最有价值的部分
- **DON'T** 假设截图展示了所有状态——它只展示了一种
