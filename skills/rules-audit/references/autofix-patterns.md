# Autofix Patterns — 自动修复模式参考

## 三种修复策略

### 1. 简单替换 (search/replace)

对 grep 匹配到的每行执行正则替换。

```jsonc
{
  "id": "no-transition-all",
  "type": "grep",
  "pattern": "transition:\\s*all",
  "severity": "fatal",
  "autofix": {
    "search": "transition:\\s*all\\s+([\\d.]+s)\\s+ease",
    "replace": "transition: transform $1 var(--ease-out-expo)"
  }
}
```

匹配 `transition: all 0.3s ease` → 替换为 `transition: transform 0.3s var(--ease-out-expo)`

### 2. 映射替换 (value → token)

将裸值映射为设计 token 变量。

```jsonc
{
  "id": "no-bare-zindex",
  "type": "grep",
  "pattern": "z-index:\\s*\\d+",
  "severity": "fatal",
  "autofix": {
    "map": {
      "1000": "var(--z-modal)",
      "1100": "var(--z-notification)",
      "500":  "var(--z-dropdown)",
      "200":  "var(--z-sticky)",
      "100":  "var(--z-raised)",
      "1":    "var(--z-base)"
    }
  }
}
```

按 `map` 中定义的值逐项替换。未在 map 中的值不自动修（标注需要手动修复）。

### 3. 智能替换 (capture groups)

```jsonc
{
  "id": "no-bare-font-size",
  "type": "grep",
  "pattern": "font-size:\\s*\\d+px",
  "severity": "warning",
  "autofix": {
    "search": "font-size:\\s*(\\d+)px",
    "replace": "font-size: clamp($1px, $1 / 16 * 1rem, $1 * 1.2px)"
  }
}
```

## 自动修复执行规则

| 场景 | 行为 |
|------|------|
| 交互模式（默认） | 展示 diff → 用户确认 → 执行 |
| CI 模式（--ci） | 直接执行，不询问 |
| autofix: false | 只报告，不修复 |
| map 中无对应值 | 报告违规 + 标注"需要手动修复" |
| 替换后文件语法错误 | 回滚该条修复，报告失败 |

## 修复确认提示格式

```
🔧 准备自动修复 3 项：

1. src/styles/card.css:42
   transition: all 0.3s ease;
   → transition: transform 0.3s var(--ease-out-expo)

2. src/components/Modal.tsx:56
   z-index: 1000;
   → z-index: var(--z-modal)

3. src/styles/theme.css:18
   color: #f5f5f5;
   → color: oklch(from #f5f5f5 l c h)

应用以上修复？(y/n/a)  [y=是 n=否 a=全部应用不再询问]
```

## 预定义的 autofix 规则参考

### transition: all → 精确属性
```jsonc
{"search": "transition:\\s*all\\s+([\\d.]+s)\\s+(ease[\\w-]*)", "replace": "transition: transform $1 $2, opacity $1 $2"}
```

### HEX → OKLCH（近似）
```jsonc
{"search": "(color|background|border-color):\\s*(#[0-9a-fA-F]{3,6})", "replace": "$1: oklch(from $2 l c h)"}
```

### px font-size → clamp()
```jsonc
{"search": "font-size:\\s*(\\d+)px", "replace": "font-size: clamp($1px, calc($1 / 16 * 1rem), $1 * 1.2px)"}
```

### console.log → 删除
```jsonc
{"search": "\\s*console\\.(log|debug|info)\\([^)]*\\);?\\s*\\n", "replace": ""}
```
