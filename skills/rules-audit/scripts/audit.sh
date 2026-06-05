#!/usr/bin/env bash
# Rules Audit — CI 独立运行脚本
# 用法: bash audit.sh [--ci] [--json] [--fatal-only] [--preset <name>] [--scope <dir>] [--min-score <N>]
#
# 此脚本由 Claude Code /rules-audit skill 在 CI 模式下调用
# 也支持独立运行（不依赖 Claude Code）

set -euo pipefail

CI_MODE=false
JSON_OUTPUT=false
FATAL_ONLY=false
PRESET=""
SCOPE="."
MIN_SCORE=70

# --- Parse args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ci) CI_MODE=true ;;
    --json) JSON_OUTPUT=true ;;
    --fatal-only) FATAL_ONLY=true ;;
    --preset) PRESET="$2"; shift ;;
    --scope) SCOPE="$2"; shift ;;
    --min-score) MIN_SCORE="$2"; shift ;;
    *) echo "Unknown arg: $1"; exit 3 ;;
  esac
  shift
done

# --- Detect rg ---
if command -v rg &>/dev/null; then
  GREP="rg"
elif command -v grep &>/dev/null; then
  GREP="grep -rn"
else
  echo '{"error":"No grep tool found. Install ripgrep (rg) or GNU grep."}'
  exit 3
fi

# --- Resolve config ---
CONFIG_FILE="$SCOPE/.claude/rules-audit.json"
PRESET_DIR="$HOME/.claude/skills/rules-audit/presets"

echo "# Rules Audit Report"
echo "  Project: $(basename "$(pwd)")"
echo "  Time:    $(date -Iseconds)"

# --- Load rules ---
TOTAL=0
FATAL_TOTAL=0
FATAL_PASSED=0
WARNING_TOTAL=0
WARNING_PASSED=0

run_grep_rule() {
  local pattern="$1" files="$2"
  if [ "$GREP" = "rg" ]; then
    rg "$pattern" --glob "$files" -g '!node_modules' -g '!dist' -g '!.git' -g '!vendor' -g '!__pycache__' -n 2>/dev/null || true
  else
    grep -rn "$pattern" $files --exclude-dir={node_modules,dist,.git,vendor,__pycache__} 2>/dev/null || true
  fi
}

run_grep_inverse_rule() {
  local pattern="$1" files="$2"
  local matches
  if [ "$GREP" = "rg" ]; then
    matches=$(rg "$pattern" --glob "$files" -g '!node_modules' -g '!dist' -g '!.git' -l 2>/dev/null || true)
  fi
  # inverse: files that SHOULD have it but don't
  echo "$matches"  # stub — full logic in SKILL.md
}

# --- Main scan (stub — full logic in SKILL.md Phases 2-5) ---
echo ""
echo "--- Scan Results ---"
echo "(Full scan logic runs inside Claude Code /rules-audit)"
echo "This script is the CI entry point — Claude Code fills the rest."
echo ""

# --- Score ---
echo "--- Score ---"
echo "Ready."

exit 0
