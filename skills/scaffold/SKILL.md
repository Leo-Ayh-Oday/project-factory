---
name: scaffold
description: Generate boilerplate code (CRUD, routes, components, tests) from data models and specs. Use after /init-project and /setup-rules to turn a skeleton into working code. Triggered by "生成代码" / "scaffold" / "搭架子" / "generate boilerplate".
metadata:
  short-description: 数据模型/spec → 批量生成样板代码（CRUD + 路由 + 组件 + 测试）
---

# /scaffold — Boilerplate Code Generator

把 `/init-project` 创建的骨架、`/setup-rules` 总结的约定，批量转化成可运行的样板代码。不是写业务逻辑，是生成重复性代码框架。

## 与 Superpowers 联动

```
/init-project → /setup-rules → /scaffold → /execute-plan
   骨架+结构        规则+约定      样板代码     具体实现
                    ↑              ↑
              "这个项目怎么写"   "自动生成 80%"
```

`/scaffold` 是 Foundation 到 Skills Pack 的**桥梁**——骨架有了、规则定了，现在批量生成代码，然后交给 `/execute-plan` 填业务逻辑。

## Phased Workflow

### Phase 1: Read Context

读三个上游产出：

1. **项目结构**: `.wolf/anatomy.md` — 当前目录树、已有文件
2. **项目规则**: `CLAUDE.md` / `AGENTS.md` — `/setup-rules` 生成的约定
3. **数据模型**: 用户提供的 spec、PRD 中的数据定义，或从 `plan.md` 提取

提取：
- 有哪些实体（User, Order, Product...）
- 技术栈（框架、ORM、CSS 方案）
- 命名约定（camelCase / snake_case，文件命名模式）

### Phase 2: Determine What to Generate

根据技术栈自动匹配生成模板：

| 层 | 检测信号 | 生成内容 |
|----|---------|---------|
| 数据层 | SQLAlchemy/Prisma/TypeORM | Model class + migration |
| API 层 | FastAPI/Express/Hono | CRUD routes + validation schema |
| 业务层 | Service pattern | Service class with stubs |
| 前端 | React/Vue/Next | Component + hook + type |
| 测试 | pytest/vitest/jest | Test file per module |
| 配置 | .env / docker-compose | 环境变量模板 |

### Phase 3: Generate Per Convention

严格遵循 `/setup-rules` 输出的规则：

- 文件命名：用项目的实际模式（如 `user_service.py` vs `UserService.ts`）
- 导入路径：用项目实际的前缀（`from engine.x` vs `@/lib/x`）
- 错误处理：用项目约定的模式（exception vs Result type vs error response）
- 测试结构：`test/` vs `__tests__/`，与已有测试一致

### Phase 4: Output Summary

生成后给出清单：

```
## /scaffold 生成报告

| 实体 | 数据层 | API | 前端 | 测试 | 总计 |
|------|--------|-----|------|------|------|
| User | model.py | routes/users.py | UserForm.tsx | test_users.py | 4 files |
| Order | model.py | routes/orders.py | OrderTable.tsx | test_orders.py | 4 files |

**生成**: 8 文件, ~1,200 行样板代码
**节省**: ~2 小时手工搭建
**下一步**: /execute-plan 填业务逻辑
```

### Phase 5: Update Anatomy

新生成的文件批量追加到 `.wolf/anatomy.md`。

## Rules

- **DO** 读完 `/setup-rules` 输出再生成 — 不知道约定就不写
- **DO** 匹配已有文件的风格 — 看 2-3 个旧文件确认模式
- **DO** 每个文件附带一个 stub test — 保持 TDD 习惯
- **DO** 输出生成清单 — 让用户知道自动生成了什么
- **DON'T** 写业务逻辑 — 只写样板，业务留给 `/execute-plan`
- **DON'T** 覆盖已有文件 — 生成前检查冲突
- **DON'T** 忽略项目规则 — 它怎么说就怎么写
- **DON'T** 生成超过 15 个文件不确认 — 批量生成前先展示计划
