# 安全政策

## 报告漏洞

**请勿公开提 Issue。** 发送邮件至 [2115464137@qq.com](mailto:2115464137@qq.com)，包含漏洞描述和复现步骤。48 小时内回复。

## 范围

- Skill prompt 注入或操纵
- 恶意 Skill 代码执行
- 通过 Skill 输出泄露敏感数据

## 最佳实践

1. **安装前审查 Skill** — 检查 SKILL.md 和所有脚本
2. **保持更新** — 定期 `git pull`
3. **审计 Hook** — `openwolf/hooks/` 中的 hook 在你的机器上运行，先审查再启用
