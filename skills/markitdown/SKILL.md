---
name: markitdown
description: Convert any file (PDF, Word, Excel, PPT, images, audio, HTML, ZIP, email, EPUB) to Markdown using Microsoft's markitdown. Use when user says "转markdown" / "markitdown" / "convert to md" / "这个文件转成md".
metadata:
  short-description: 任意文件格式 → Markdown，基于微软 markitdown，pipeline 前置步骤
---

# /markitdown — Any File to Markdown

基于 [microsoft/markitdown](https://github.com/microsoft/markitdown) 的格式转换 skill。20+ 格式入，Markdown 出。

## 与 Superpowers 联动

```
/markitdown 需求.pdf → /brainstorm → /estimate → /write-plan → /execute-plan
/markitdown 会议录音.m4a → /daily-digest
/markitdown 竞品分析.docx → /screenshot-to-spec 的参考输入
```

本 skill 是**流水线入口**——把任意格式的输入统一成 Markdown，下游 skill 直接消费。

## Setup

```bash
pip install "markitdown[all]"
```

验证安装：
```bash
markitdown --version
```

如果未安装，本 skill 会输出安装命令并退出。

## Phased Workflow

### Phase 1: Detect Input

识别输入来源：

| 输入类型 | 示例 | 处理方式 |
|----------|------|----------|
| 本地文件 | `/path/to/file.pdf` | 直接传 markitdown CLI |
| 目录 | `/path/to/docs/` | 递归查找所有支持格式 |
| URL | `https://example.com/report.pdf` | 先 `curl -O` 再转换 |
| 剪贴板图片 | 截图 | 保存为临时文件再转 |

支持的格式列表（自动检测 `.pdf .docx .xlsx .xls .pptx .html .htm .csv .json .xml .zip .msg .epub .ipynb .mp3 .wav .m4a .png .jpg .jpeg .gif .bmp .tiff`）

### Phase 2: Convert

```bash
# 单文件
markitdown input.pdf -o output.md

# 批量（同目录下多格式）
for f in *.pdf *.docx *.xlsx; do
  markitdown "$f" -o "${f%.*}.md"
done
```

大文件（>50MB PDF、>1h 音频）提示用户确认，避免长时间等待。

### Phase 3: Post-Process

- **Office 文档**: 检查表格是否完整（markitdown 对复杂表格有时丢列）
- **图片**: OCR 结果可能含噪声——标注 `[OCR 结果，可能需要人工校对]`
- **音频**: 转录文本无标点——标注 `[原始转录，未分段]`
- **网页**: 保留源 URL 在文件头 `> Source: https://...`

### Phase 4: Output

- 默认输出到与原文件同目录的 `.md` 文件
- 用户指定 `-o` 时输出到指定路径
- 转换结果也直接在对话中展示，供下游 skill 消费

## Rules

- **DO** 先检查 markitdown CLI 是否可用
- **DO** 大文件（>50MB）先询问用户确认
- **DO** 标注 OCR/转录的质量警告
- **DO** 保留原始来源 URL
- **DON'T** 对已转换的内容重复转换
- **DON'T** 跳过安装检查——直接调用会报错
- **DON'T** 删除原始文件——只读转换
- **DON'T** 假设用户安装了 `[all]` extras——给出明确安装命令
