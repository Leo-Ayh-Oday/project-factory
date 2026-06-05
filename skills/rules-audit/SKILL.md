# /rules-audit — 项目规则合规审计

确定性规则扫描 + 自动修复 + 评分报告。不依赖模型"尽力遵守"，grep/AST 告诉你哪儿真违规了。

## When to Use

- 写完代码后，提交前检查合规
- CI/CD 流水线中作为质量门禁
- 新人入职时检查是否遵守项目规范
- 代码审查前自动扫一遍

## 与已有工具的分工

| 工具 | 管什么 | 不管什么 |
|------|--------|---------|
| ESLint | JS/TS 语法规则 | CSS 设计约束、项目约定 |
| Stylelint | CSS 语法 | 你的设计系统 token 规范 |
| **Rules Audit** | **项目约定 + 设计约束 + 安全红线** | 语法正确性（那是 linter 的事） |

## Phased Workflow

### Phase 1: Load Config

1. 读取项目根目录 `.claude/rules-audit.json`（如果存在）
2. 解析 `extends` → 加载内置预设包
3. 合并自定义规则 + 预设规则
4. 解析 `exclude` 路径
5. 如果没有配置文件 → 交互式引导用户选择预设

### Phase 2: Deterministic Scan (Layer 1)

按规则类型分组执行扫描：

**grep 类规则：**
```bash
rg "<pattern>" --glob "<files>" -n -g '!node_modules' -g '!dist' -g '!.git'
```

**grep-inverse 类规则：**
- 搜索应存在但找不到的模式 → 违规

**file-exists 类规则：**
- PowerShell: `Test-Path` 检查文件对（如组件→测试文件）

**line-count 类规则：**
- `wc -l` 统计文件行数，超过 max 则违规

Powershell 兼容规则见 `references/grepping-guide.md`。

### Phase 3: Semantic Check (Layer 2, 可选)

仅当用户指定 `--semantic` 或配置中有 `type: "semantic"` 规则时触发。

每条语义规则 fork 一个独立 agent 审查，避免上下文污染。Agent 只回答 YES/NO + 证据行号。

### Phase 4: Auto-Fix (Layer 3)

对 `autofix` 不为 false 的规则，自动执行修复：

1. **简单替换**：regex search → replace
2. **映射替换**：值 → 变量名（如 `1000` → `var(--z-modal)`）
3. **智能替换**：capture groups 正则

每个修复记录到 `autofix_applied` 字段。

### Phase 5: Score & Report

**三级严重度：**

| 级别 | 含义 | 一票否决？ |
|------|------|-----------|
| 🔴 fatal | 必须修复才能提交 | ✅ 是 |
| 🟡 warning | 应该修复，强烈建议 | ❌ 否 |
| 🔵 suggestion | 建议改进，可选 | ❌ 否 |

**评分公式（默认权重）：**
```
Fatal 通过率 × 0.40
+ Warning 通过率 × 0.35
+ Suggestion 采纳 × 0.15
+ 语义检查通过率 × 0.10
= 总分 / 100
```

**评级：**
- 90-100: 🟢 优秀
- 70-89: 🟡 合格
- 50-69: 🟠 需改进
- < 50: 🔴 不合格

### Phase 6: Output

两份输出：

1. **终端 Markdown 报告**（人类可读，含具体行号和修复建议）
2. **JSON 报告** → `.claude/audit-report.json`（CI 消费）

## 交互模式

### 模式 1: 快速扫描
```
/rules-audit
```
→ 加载项目配置 → 扫描 → 报告

### 模式 2: 指定预设
```
/rules-audit --preset web-common,typescript
```
→ 只用指定预设，不读项目配置

### 模式 3: 检查特定目录
```
/rules-audit --scope src/components/
```
→ 只扫描指定目录

### 模式 4: 仅 fatal
```
/rules-audit --fatal-only
```
→ 只跑 fatal 级别规则，用于快速门禁

### 模式 5: CI 模式
```
/rules-audit --ci --json
```
→ 输出 JSON 到 stdout，适合流水线

## File Structure

```
~/.claude/skills/rules-audit/
├── SKILL.md                     ← 本文件
├── references/
│   ├── rule-dsl.md              ← 规则 DSL 完整参考
│   ├── grepping-guide.md        ← 跨平台 grep 技巧
│   ├── autofix-patterns.md      ← 自动修复模式
│   └── ci-integration.md        ← CI/CD 集成
├── presets/
│   ├── web-common.json          ← 通用 Web 规则 (~12条)
│   ├── typescript.json          ← TypeScript 规则 (~8条)
│   └── motion.json              ← 动效设计规则 (~26条)
└── scripts/
    └── audit.sh                 ← CI 独立运行脚本
```

## Rules

- **DO** 先读配置再扫描，尊重 exclude 路径
- **DO** 自动修复前展示 diff，等用户确认（交互模式）
- **DO** CI 模式下自动修复直接应用，不询问
- **DO** 规则文件本身就是文档，`.json` 可读
- **DO** 64 位系统用 `rg`，32 位 fallback 到 PowerShell Select-String
- **DON'T** 替换 ESLint/Stylelint — 本工具管约定不管语法
- **DON'T** 跳过 fatal 规则 — 一票否决制
- **DON'T** 在 exclude 目录中扫描

## 联动

```
/rules-audit → 扫描代码 → 报告 + 修复
       ↓
如果全部 fatal 通过 → 继续 /code-review
如果 fatal 未通过 → 自动修复 → 重新扫描
       ↓
/daily-digest → 引用今日审计分数
```
