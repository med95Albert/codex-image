#!/usr/bin/env bash
# codex-image 解除安裝：移除 ~/.claude/skills/codex-image。
# 不動你的 codex 登入、不動任何已生成的圖片。
set -euo pipefail

SKILL_DEST="${HOME}/.claude/skills/codex-image"

if [ -d "${SKILL_DEST}" ]; then
  rm -rf "${SKILL_DEST}"
  echo "✓ 已移除 ${SKILL_DEST}"
else
  echo "（${SKILL_DEST} 不存在，無需移除）"
fi

echo "✓ 解除安裝完成。codex CLI 登入狀態與已生成圖片皆未變動。"
echo "  重開一個 Claude Code session 後生效。"
