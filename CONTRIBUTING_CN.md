# 贡献指南

欢迎为 Project Factory 贡献 Skill。

## 贡献方式

- **提交新 Skill** — 在 `skills/<名称>/SKILL.md` 下按模板创建
- **改进现有 Skill** — 修 bug、加边界处理、更新引用
- **报告问题** — 在 GitHub Issues 提 bug、建议或 Skill 请求

## Skill 结构

```
skills/<skill-name>/
├── SKILL.md              # 必须：主 Skill 文件
├── references/           # 可选：参考文档
│   ├── *.md
│   └── *.json
├── hooks/                # 可选：hooks.json
├── scripts/              # 可选：辅助脚本
└── presets/              # 可选：预设数据
```

### SKILL.md 要求

- 前导元数据：`name`、`description`、`metadata.short-description`
- 明确的触发词
- 分阶段工作流，每步显式指令
- 输入/输出说明

## 提交规范

```
feat: 新增 /skill-name — 一句话说明
fix: 修复 /skill-name 在 X 场景下的行为
docs: 更新 skill-name 参考文档
```

## PR 检查清单

- [ ] SKILL.md 符合上述模板
- [ ] 已在 Claude Code 中实测通过
- [ ] 无硬编码路径或凭据
- [ ] 如新增 Skill 已更新 README.md

## 许可证

所有贡献采用 MIT 协议。
