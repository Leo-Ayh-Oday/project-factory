# Grepping Guide — 跨平台 grep 扫描技巧

## 工具选择

| 系统 | 首选 | 备选 |
|------|------|------|
| macOS / Linux | `rg` (ripgrep) | `grep -rn` |
| Windows (64-bit) | `rg` (via choco/scoop) | PowerShell `Select-String` |
| Windows (32-bit) | PowerShell `Select-String` | — |

## ripgrep 常用参数

```bash
# 基础搜索
rg "pattern" --glob "*.tsx" -n

# 排除目录
rg "pattern" -g '!node_modules' -g '!dist' -g '!.git'

# 仅列出文件名
rg "pattern" -l

# 计数模式
rg "pattern" -c

# 多行模式
rg "pattern" -U --multiline

# JSON 输出（方便解析）
rg "pattern" --json
```

## PowerShell 备选

```powershell
# 基础搜索
Get-ChildItem -Recurse -Include "*.tsx","*.ts" | Select-String "console\.log"

# 排除目录
Get-ChildItem -Recurse -Include "*.css" |
  Where-Object { $_.FullName -notmatch 'node_modules|dist' } |
  Select-String "z-index:\s*\d+"

# 计数
(Get-ChildItem -Recurse -Include "*.tsx" | Select-String "pattern").Count
```

## 常见 grep 规则模板

### 搜索裸 z-index
```bash
rg "z-index:\s*\d+" --glob "*.css" -g '!node_modules'
```
Regex: `z-index:\s*\d+`

### 搜索 console.log/debug/info
```bash
rg "console\.(log|debug|info|warn)\(" --glob "*.{ts,tsx,js,jsx}" -g '!node_modules'
```
Regex: `console\.(log|debug|info|warn)\(`

### 搜索硬编码密钥
```bash
rg "(api[_-]?key|secret|token|password)\s*[:=]\s*['\"]\w{8,}" --glob "*.{ts,tsx,js,jsx,py,go}" -i
```
Regex: `(api[_-]?key|secret|token|password)\s*[:=]\s*['"]\w{8,}`

### 搜索 transition: all
```bash
rg "transition:\s*all\b" --glob "*.css"
```
Regex: `transition:\s*all\b`

### 搜索 outline: none（无障碍违规）
```bash
rg "outline:\s*none" --glob "*.css"
```
Regex: `outline:\s*none`

### 搜索 innerHTML / dangerouslySetInnerHTML
```bash
rg "(\.innerHTML|dangerouslySetInnerHTML)" --glob "*.{ts,tsx,js,jsx}"
```
Regex: `(\.innerHTML|dangerouslySetInnerHTML)`

### 搜索 HEX 颜色（应该用 OKLCH）
```bash
rg "#[0-9a-fA-F]{3,8}" --glob "*.css" -g '!node_modules'
```
Regex: `#[0-9a-fA-F]{3,8}`

### 搜索裸字号（应用 clamp()）
```bash
rg "font-size:\s*\d+px" --glob "*.css"
```
Regex: `font-size:\s*\d+px`

## grep-inverse 规则模板

grep-inverse 的逻辑：搜了找不到 = 违规。

### 必须有 font-display: swap
```bash
# 1. 找到所有 @font-face 声明的文件
# 2. 在那些文件中搜 font-display: swap
# 3. 有 @font-face 但没 font-display: swap = 违规
```

### 图片必须有 alt 属性
```bash
rg "<img[^>]*>" --glob "*.{html,tsx,jsx}" | rg -v "alt="
```

## 性能注意事项

- 总在开始时排除 `node_modules`, `dist`, `.git`
- 大仓库（>1000 文件）用 `rg` 不用 PowerShell Select-String
- `rg` 默认忽略 `.gitignore` 中的文件，不需要手动排除
- 多个 pattern 可以合并到一个 `rg` 调用：`rg "pat1|pat2|pat3"`
