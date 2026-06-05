# Rule DSL — 规则定义语言完整参考

## 规则类型概览

| type | 引擎 | 速度 | 典型用途 |
|------|------|------|---------|
| `grep` | ripgrep | <0.1s | 禁止模式：裸z-index、console.log、硬编码密钥 |
| `grep-inverse` | ripgrep | <0.1s | 必须模式：font-display: swap、alt属性 |
| `file-exists` | shell test | <0.1s | 文件对关系：组件↔测试、README |
| `line-count` | wc -l | <0.5s | 文件大小上限 |
| `ast-nesting` | tree-sitter | <1s | 嵌套深度 |
| `ast-function-size` | tree-sitter | <1s | 函数长度 |
| `semantic` | LLM agent | 5-15s | 模糊判断：函数职责单一吗 |

## 通用字段（所有类型共用）

```jsonc
{
  "id": "kebab-case 唯一标识符",
  "type": "grep | grep-inverse | file-exists | line-count | ast-nesting | ast-function-size | semantic",
  "files": "glob 模式，如 *.tsx, *.css, *.{ts,tsx}",
  "severity": "fatal | warning | suggestion",
  "message": "违规时的提示消息，支持 {count} {file} {line} 占位符",
  "autofix": false  // 或 autofix 对象，见 autofix-patterns.md
}
```

## type: grep

搜索禁止出现的模式。找到任一行匹配 → 违规。

```jsonc
{
  "id": "no-console-log",
  "type": "grep",
  "pattern": "console\\.(log|debug|info)\\(",
  "files": "*.{ts,tsx,js,jsx}",
  "severity": "fatal",
  "message": "禁止在生产代码中使用 console.log，使用结构化日志"
}
```

**pattern** 是标准正则表达式（ripgrep 兼容）。

## type: grep-inverse

必须出现的模式。在指定文件中找不到匹配 → 违规。

```jsonc
{
  "id": "must-have-font-display",
  "type": "grep-inverse",
  "pattern": "font-display:\\s*swap",
  "files": "*.css",
  "severity": "warning",
  "message": "@font-face 必须设置 font-display: swap 避免 FOIT"
}
```

## type: file-exists

检查文件存在性。`for` 匹配到的每个文件必须在 `expect` 路径有对应文件。

```jsonc
{
  "id": "component-has-test",
  "type": "file-exists",
  "check": {
    "for": "src/components/**/*.tsx",
    "expect": "src/components/**/__tests__/{basename}.test.tsx"
  },
  "severity": "warning",
  "message": "{file} 缺少对应的测试文件"
}
```

`{basename}` 替换为匹配文件名（不含扩展名）。

## type: line-count

检查文件行数上限。

```jsonc
{
  "id": "file-under-800",
  "type": "line-count",
  "max": 800,
  "files": "*.{ts,tsx,js,jsx,py,go,rs}",
  "severity": "warning",
  "message": "{file} 有 {count} 行，超过 {max} 行上限"
}
```

## type: ast-nesting

使用 tree-sitter 检查嵌套深度（if/for/while/函数嵌套）。

```jsonc
{
  "id": "nesting-under-4",
  "type": "ast-nesting",
  "max": 4,
  "files": "*.*",
  "severity": "warning",
  "message": "{file}:{line} 嵌套深度 {count}，超过 {max} 层上限"
}
```

## type: ast-function-size

使用 tree-sitter 检查单个函数/方法体行数。

```jsonc
{
  "id": "function-under-50",
  "type": "ast-function-size",
  "max": 50,
  "files": "*.{ts,tsx,go,py,rs}",
  "severity": "suggestion",
  "message": "{file}:{line} 函数 `{name}` 有 {count} 行，建议拆分"
}
```

## type: semantic

提交给独立 agent 做语义判断。

```jsonc
{
  "id": "single-responsibility",
  "type": "semantic",
  "question": "这个函数是否职责单一？如果不是，指出哪部分应该拆分。",
  "files": "*.{ts,tsx}",
  "severity": "suggestion",
  "agent_model": "haiku"
}
```

`agent_model` 控制用哪个模型做判断（haiku 省钱，sonnet 更准）。

## 项目配置文件格式

`.claude/rules-audit.json`：

```jsonc
{
  "extends": ["web-common", "typescript"],  // 继承的预设
  "rules": [
    // 自定义规则...
  ],
  "exclude": [
    "node_modules", "dist", ".git",
    "vendor", "__pycache__", "*.generated.*"
  ],
  "scoring": {
    "fatal_weight": 0.40,
    "warning_weight": 0.35,
    "suggestion_weight": 0.15,
    "semantic_weight": 0.10
  }
}
```

`extends` 可选，不继承任何预设时从零开始。
