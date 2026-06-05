# Project Factory

两层架构的 Claude Code 技能包：**Project Foundation** 管项目从 0 到 1，**Skills Pack** 管日常开发从 1 到 N。

[![Stars](https://img.shields.io/github/stars/Leo-Ayh-Oday/project-factory?style=social)](https://github.com/Leo-Ayh-Oday/project-factory/stargazers)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/Leo-Ayh-Oday/project-factory/releases)
[![License](https://img.shields.io/badge/license-MIT-purple)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-12-blue)](skills/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)](CONTRIBUTING_CN.md)

**Topics:** `claude-code` `skills-pack` `project-factory` `openwolf` `ai-tools` `developer-tools` `claude-skills` `project-management` `knowledge-base` `obsidian` `markitdown`

## 架构总览

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Claude Code Skills Pack                        │
├────────────────────────────┬────────────────────────────────────────┤
│   Layer 1: Foundation      │   Layer 2: Skills Pack                │
│   项目底座（0→1）            │   日常开发（1→N）                      │
├────────────────────────────┼────────────────────────────────────────┤
│  /init-project  创建项目骨架 │  /markitdown         任意格式→md       │
│  /setup-rules   生成项目规则 │  /screenshot-to-spec 截图→需求文档     │
│  /openwolf      上下文自动化 │  /learn-from-bugs    挖掘错误模式      │
│                            │  /estimate          评估改动范围       │
│                            │  /obsidian          产出→永久笔记      │
│                            │  /daily-digest      生成日报          │
└────────────────────────────┴────────────────────────────────────────┘
```

## 完整工作流

```
Day 0 — 新项目启动 (Foundation):
  /brainstorm → /write-plan → /init-project → /setup-rules
      ↑                             ↑               ↑
  想清楚做什么              搜同类项目+生成底座   搜坑+写规则

Day 1..N — 日常开发 (Skills Pack):
  /openwolf check ────────────────────────────────────── (后台保持上下文健康)
      ↓
  /markitdown → /learn-from-bugs → /brainstorm → /estimate → /write-plan → /execute-plan
      ↓              ↓                                                ↓          ↓
  文件转md      挖掘错误模式                                      /obsidian  /daily-digest
                                                                 永久笔记    收工日报
```

## 快速开始

```bash
# 1. 克隆技能包
git clone https://github.com/Leo-Ayh-Oday/project-factory.git
cp -r project-factory/skills/* ~/.claude/skills/

# 2. 安装可选依赖
pip install "markitdown[all]"        # /markitdown — 任意格式转 Markdown

# 3. 配置 Obsidian vault 路径（可选，用于 /obsidian）
# 在 ~/.claude/settings.json 的 env 中添加：
# "OBSIDIAN_VAULT_PATH": "/path/to/your/obsidian/vault"
```

## Layer 1: Project Foundation

项目全生命周期工具包 — 从零到有、从写到管。

### 技能清单

| 技能 | 用途 | 调用时机 |
|------|------|---------|
| `/init-project` | 读计划 → 搜 GitHub 同类项目 → 生成项目骨架 | 新项目启动时 |
| `/setup-rules` | 扫描项目 → 搜真实坑位 → 生成项目规则 | 骨架生成后、方向变更时 |
| `/openwolf` | anatomy 同步、bug 记录、cerebrum 学习 | 开发过程中持续运行 |
| `/scaffold` | 脚手架代码生成 | 项目骨架就绪后 |
| `/handoff` | 项目/任务交接文档生成 | 换人接手/阶段性总结 |

### 工作流

```
/brainstorm → /write-plan → /init-project → /setup-rules → /execute-plan
  Superpowers              Project Foundation              Superpowers

开发过程中:
  /openwolf check   → 检查 anatomy 过期、未记录 bug、缺失学习
  /openwolf update  → 自动修复 → 继续写
```

## Layer 2: Skills Pack

日常开发流水线 — 从输入到输出。

### 技能清单

| 层级 | 技能 | 用途 | 触发词 |
|------|------|------|--------|
| 输入 | `/markitdown` | 任意文件 → Markdown | 转markdown / convert to md |
| 输入 | `/screenshot-to-spec` | 截图 → 结构化需求文档 | 转成需求 / screenshot to spec |
| 分析 | `/learn-from-bugs` | 从 buglog 挖掘重复错误模式 | 分析bug / bug patterns |
| 分析 | `/estimate` | 评估需求改动范围和风险等级 | 评估 / estimate / 复杂度 |
| 管理 | `/health-check` | 项目健康度全面检查 | 健康检查 / 项目体检 / health check |
| 输出 | `/obsidian` | AI 产出 → Obsidian 永久笔记 + 多层分类 | 存到obsidian / 归档 |
| 输出 | `/daily-digest` | 生成可分享的结构化日报 | 日报 / 收工 / wrap up |

### 工作流

```
/markitdown 需求.pdf → /screenshot-to-spec → /learn-from-bugs → /brainstorm → /estimate → /write-plan → /execute-plan
       ↑                     ↑                      ↑                                                    ↓
  任意格式输入          截图转需求            数据驱动的讨论                                    /obsidian → /daily-digest
                                                                                              永久笔记      日报
```

## 联动关系

```
Foundation 负责「落地 + 管理」    Skills Pack 负责「想清楚 + 执行 + 沉淀」

/init-project ──→ 项目骨架      /markitdown ──→ 格式输入
/setup-rules  ──→ 项目规则      /learn-from-bugs → 错误分析    /obsidian ──→ 知识归档
/openwolf     ──→ 持续管理      /estimate ──────→ 风险评估    /daily-digest → 日报输出
                                /screenshot-to-spec → 需求转换
```

## 配置

### 环境变量

在 `~/.claude/settings.json` 的 `env` 中设置：

```json
{
  "env": {
    "OBSIDIAN_VAULT_PATH": "/path/to/your/obsidian/vault"
  }
}
```

### Obsidian 自定义分类（可选）

在 vault 根目录创建 `.claude-categories.json`：

```json
{
  "bug_analysis": "bugs/{project}/{date}",
  "tech_spec": "知识库/{domain}/{topic}",
  "daily_digest": "日记/{YYYY-MM}",
  "decision": "项目/{project}/decisions",
  "learning": "知识库/{domain}/learnings"
}
```

## 设计原则

- **纯 prompt 驱动**：核心 skill 是 SKILL.md prompt 文件，零脚本依赖
- **只读分析，写入确认**：分析类 skill 只读数据源，写操作需用户确认
- **数据源联动**：统一读取 `.wolf/anatomy.md` + `buglog.json` + `cerebrum.md`
- **路径可配置**：零硬编码路径，通过 env var 配置
- **管道式组合**：每个 skill 独立可用，也可串联成完整流水线
- **两层解耦**：Foundation 和 Skills Pack 独立运行，通过 OpenWolf 共享上下文

## 前置依赖

本技能包部分 Skill 依赖以下开源工具。未安装时对应 Skill 会自动提示配置方法，不影响其他 Skill 使用。

| 依赖 | 被哪些 Skill 使用 | 安装/获取 |
|------|-------------------|-----------|
| [OpenWolf](https://github.com/openwolf/openwolf) | `/openwolf` `/init-project` `/setup-rules` | `npm i -g openwolf` |
| [Obsidian](https://obsidian.md) | `/obsidian` | [obsidian.md](https://obsidian.md) 下载 |
| [markitdown](https://github.com/microsoft/markitdown) | `/markitdown` | `pip install "markitdown[all]"` |
| [Superpowers](https://github.com/anthropics/superpowers) | 工作流联动（brainstorm/plan/execute） | Claude Code 内置 |

> **不需要全部安装。** 只用你需要的 Skill，装对应的依赖即可。

## 目录结构

```
~/.claude/skills/
├── README.md                    ← 本文件（总入口）
│
├── init-project/SKILL.md        ← Foundation: 项目骨架生成
├── setup-rules/SKILL.md         ← Foundation: 项目规则生成
├── openwolf/                    ← Foundation: 上下文自动化
│   ├── SKILL.md
│   ├── hooks/hooks.json
│   └── scripts/buglog.py
├── scaffold/SKILL.md            ← Foundation: 脚手架生成
├── handoff/SKILL.md             ← Foundation: 交接文档
│
├── markitdown/SKILL.md          ← Skills Pack: 格式转换
├── screenshot-to-spec/SKILL.md  ← Skills Pack: 截图转需求
├── learn-from-bugs/SKILL.md     ← Skills Pack: bug 模式挖掘
├── estimate/SKILL.md            ← Skills Pack: 风险评估
├── health-check/SKILL.md        ← Skills Pack: 健康检查
├── obsidian/SKILL.md            ← Skills Pack: 知识归档
└── daily-digest/SKILL.md        ← Skills Pack: 日报生成
```

## 参与贡献

欢迎提 PR！详见 [CONTRIBUTING_CN.md](CONTRIBUTING_CN.md)。

本项目遵循 [Contributor Covenant](CODE_OF_CONDUCT.md) 行为准则。
安全漏洞请查看 [SECURITY_CN.md](SECURITY_CN.md) 了解报告流程。

## License

MIT
