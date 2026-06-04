# Project Factory

两层架构的 Claude Code 技能包：**Project Foundation** 管项目从 0 到 1，**Skills Pack** 管日常开发从 1 到 N。

## 架构总览

```
┌───────────────────────────────────────────────────────────────────────────┐
│                          Project Factory (12 skills)                       │
├──────────────────────────────────┬────────────────────────────────────────┤
│   Layer 1: Foundation (0→1)      │   Layer 2: Skills Pack (1→N)           │
│   创建 + 规则 + 生成 + 检查 + 交接 │   输入 + 分析 + 评估 + 实现 + 归档 + 日报  │
├──────────────────────────────────┼────────────────────────────────────────┤
│  /init-project   创建项目骨架      │  /markitdown         任意格式 → md      │
│  /setup-rules    生成项目规则      │  /screenshot-to-spec 截图 → 需求文档    │
│  /scaffold       批量生成样板代码   │  /learn-from-bugs    挖掘错误模式       │
│  /health-check   项目体检          │  /estimate          评估改动范围        │
│  /handoff        交接文档包        │  /obsidian          产出 → 永久笔记     │
│  /openwolf       上下文自动化       │  /daily-digest      生成日报           │
└──────────────────────────────────┴────────────────────────────────────────┘
```

## 完整工作流

```
Day 0 — 新项目启动 (Foundation):
  /brainstorm → /write-plan → /init-project → /setup-rules → /scaffold
      ↑              ↑              ↑              ↑             ↑
  想清楚做什么    写执行计划    搜同类+骨架    搜坑+规则    批量生成代码

Day 1..N — 日常开发 (Skills Pack):
  /openwolf check ──────────────────────────────────────── (后台保持上下文)
      ↓
  /markitdown → /learn-from-bugs → /brainstorm → /estimate → /write-plan → /execute-plan
      ↓              ↓              ↓             ↓            ↓              ↓
  文件转md      挖掘错误模式    方案讨论      风险评估     执行计划       写代码
                                                                              ↓
                                                                     /obsidian → /daily-digest
                                                                     永久笔记      日报

周期维护:
  /openwolf check → /health-check → /learn-from-bugs → /brainstorm → /estimate → /write-plan
                      体检报告         深挖问题         讨论方案        评估范围       修复计划

项目交接:
  /execute-plan → /handoff → /obsidian
                     ↓           ↓
              架构+入门+部署   永久归档
```

## 联动关系

```
Foundation 管「落地 + 管理」          Skills Pack 管「输入 + 执行 + 沉淀」

/init-project  → 项目骨架             /markitdown         → 格式统一入口
/setup-rules   → 项目规则             /screenshot-to-spec → 截图转需求
/scaffold      → 批量代码             /learn-from-bugs    → 数据驱动讨论
/health-check  → 体检诊断             /estimate           → 量化评估
/handoff       → 交接文档             /obsidian           → 知识永存
/openwolf      → 持续追踪             /daily-digest       → 每日收尾

桥梁: /scaffold (Foundation → Skills Pack)   /health-check (Skills Pack → Foundation)
```

## 快速开始

```bash
git clone https://github.com/Leo-Ayh-Oday/project-factory.git
cp -r project-factory/skills/* ~/.claude/skills/

# 可选依赖
pip install "markitdown[all]"        # /markitdown

# 配置 Obsidian vault 路径（可选）
# 在 ~/.claude/settings.json 的 env 中添加:
# "OBSIDIAN_VAULT_PATH": "/path/to/your/obsidian/vault"
```

## Layer 1: Project Foundation

从零到有，把一个想法变成一个可运行的项目。

### 技能清单

| 技能 | 用途 | 触发词 | 在 pipeline 中的位置 |
|------|------|--------|-------------------|
| `/init-project` | 读计划 → 搜 GitHub 同类 → 生成骨架 | 初始化项目 | brainstorm → write-plan 之后 |
| `/setup-rules` | 扫描项目 → 搜坑 → 生成规则 | 写项目规则 | init-project 之后 |
| `/scaffold` | 数据模型 → 批量样板代码 | 生成代码 / scaffold | setup-rules 之后，execute-plan 之前 |
| `/health-check` | 依赖安全+覆盖+技术债 | 体检 / health check | openwolf check 之后，定期跑 |
| `/handoff` | 生成交接文档包 | 交接 / handoff | execute-plan 之后，项目收尾 |
| `/openwolf` | anatomy 同步+bug 记录+学习 | openwolf check | 全流程持续运行 |

### 工作流

```
新项目:
  /brainstorm → /write-plan → /init-project → /setup-rules → /scaffold → /execute-plan
   Superpowers                   Project Foundation                     Superpowers

维护:
  /openwolf check → /health-check → /learn-from-bugs → /brainstorm → /estimate → /write-plan
    Foundation        Foundation     Skills Pack    Superpowers  Skills Pack  Superpowers

交接:
  /execute-plan → /handoff → /obsidian
   Superpowers    Foundation   Skills Pack
```

## Layer 2: Skills Pack

日常开发流水线，从输入到输出。

### 技能清单

| 层级 | 技能 | 用途 | 触发词 |
|------|------|------|--------|
| 输入 | `/markitdown` | 任意文件 → Markdown | 转markdown |
| 输入 | `/screenshot-to-spec` | 截图 → 结构化需求文档 | 转成需求 |
| 分析 | `/learn-from-bugs` | 从 buglog 挖掘重复错误模式 | 分析bug |
| 分析 | `/estimate` | 评估需求改动范围和风险 | 评估 / estimate |
| 输出 | `/obsidian` | AI 产出 → Obsidian 永久笔记 | 存到obsidian |
| 输出 | `/daily-digest` | 生成结构化日报 | 日报 / 收工 |

### 工作流

```
/markitdown → /screenshot-to-spec → /learn-from-bugs → /brainstorm → /estimate → /write-plan → /execute-plan
   输入              输入                 分析           Superpowers   分析       Superpowers   Superpowers
                                                                                         ↓
                                                                                /obsidian → /daily-digest
                                                                                  输出         输出
```

## 配置

```json
// ~/.claude/settings.json
{
  "env": {
    "OBSIDIAN_VAULT_PATH": "/path/to/your/obsidian/vault"
  }
}
```

## 设计原则

- **纯 prompt 驱动**：核心 skill 是 SKILL.md 文件，零脚本依赖
- **只读分析，写入确认**：分析类 skill 只读数据源，写操作需用户确认
- **数据源联动**：统一读取 `.wolf/anatomy.md` + `buglog.json` + `cerebrum.md`
- **管道式组合**：每个独立可用，也可串联成完整流水线
- **两层解耦**：Foundation 和 Skills Pack 独立运行，通过 OpenWolf 共享上下文

## 前置依赖

| 依赖 | 用途 | 安装 |
|------|------|------|
| [OpenWolf](https://github.com/openwolf/openwolf) | `.wolf/` 上下文管理 | Foundation 核心 |
| [markitdown](https://github.com/microsoft/markitdown) | 文件格式转换 | `pip install "markitdown[all]"` |
| [Obsidian](https://obsidian.md) | 知识库笔记 | 仅 `/obsidian` |

## 目录结构

```
~/.claude/skills/
├── README.md                    ← 总入口
│
├── init-project/SKILL.md        ← Foundation: 项目骨架
├── setup-rules/SKILL.md         ← Foundation: 项目规则
├── scaffold/SKILL.md            ← Foundation: 批量代码
├── health-check/SKILL.md        ← Foundation: 项目体检
├── handoff/SKILL.md             ← Foundation: 交接文档
├── openwolf/                    ← Foundation: 上下文自动化
│
├── markitdown/SKILL.md          ← Skills Pack: 格式转换
├── screenshot-to-spec/SKILL.md  ← Skills Pack: 截图转需求
├── learn-from-bugs/SKILL.md     ← Skills Pack: bug 挖掘
├── estimate/SKILL.md            ← Skills Pack: 风险评估
├── obsidian/SKILL.md            ← Skills Pack: 知识归档
└── daily-digest/SKILL.md        ← Skills Pack: 日报生成
```

## License

MIT
