#!/usr/bin/env bash
# codex-image 一鍵安裝器（根目錄即技能佈局）
# 兩種執行情境皆支援：
#   A) repo 已被 clone 到 ~/.claude/skills/codex-image（一句話安裝路徑）→ 原地使用，跳過複製
#   B) repo 在任何其他位置（下載解壓／clone 到別處）→ 複製 skill 後完成檢查
# 全程只寫入你自己的 ~/.claude/，可安全重複執行（idempotent）。
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
SKILL_DEST="${CLAUDE_DIR}/skills/codex-image"

say(){ printf '%s\n' "$*"; }
die(){ printf 'ERROR: %s\n' "$*" >&2; exit 1; }

say "== codex-image 安裝器 v1.0 =="

[ -f "${SELF_DIR}/SKILL.md" ] || die "找不到 ${SELF_DIR}/SKILL.md（請在 repo 資料夾內執行本腳本）。"

# ---- 1. 前置檢查：Codex CLI（生圖引擎，必要）----
if command -v codex >/dev/null 2>&1; then
  say "✓ codex CLI：$(codex --version 2>&1 | head -1)"
  if codex login status >/dev/null 2>&1; then
    say "✓ codex 已登入（ChatGPT 帳號 → 走訂閱額度）"
  else
    say "⚠ codex 尚未登入——裝完請執行： codex login"
    say "  （瀏覽器開啟後用 ChatGPT 帳號登入即可；**絕對不要貼 API key**，貼了就變按量付費。）"
  fi
else
  say "⚠ 找不到 codex CLI——skill 已可安裝，但生圖前請先安裝並登入："
  say "    brew install codex && codex login"
fi

# ---- 2. 省錢守門：API key 環境變數 ----
if [ -n "${OPENAI_API_KEY:-}" ] || [ -n "${CODEX_API_KEY:-}" ]; then
  say "⚠ 偵測到 OPENAI_API_KEY / CODEX_API_KEY 環境變數。"
  say "  codex exec 會優先用它們 = 改走按量付費 API（不是訂閱額度）。"
  say "  生圖前請先： unset OPENAI_API_KEY CODEX_API_KEY"
else
  say "✓ 沒有 API key 環境變數（訂閱模式 OK）"
fi

# ---- 3. 安裝 skill ----
mkdir -p "${CLAUDE_DIR}/skills"
if [ "${SELF_DIR}" = "${SKILL_DEST}" ]; then
  say "✓ 偵測到 repo 已在 ${SKILL_DEST}（一句話安裝路徑）——原地使用，跳過複製"
else
  mkdir -p "${SKILL_DEST}/scripts"
  cp "${SELF_DIR}/SKILL.md" "${SELF_DIR}/STYLE.md" "${SKILL_DEST}/"
  cp "${SELF_DIR}/scripts/gen_image.sh" "${SKILL_DEST}/scripts/"
  say "✓ skill 已複製到 ${SKILL_DEST}"
fi
chmod +x "${SKILL_DEST}/scripts/"*.sh

# ---- 4. 煙霧測試（零 token）----
say ""
say "== 煙霧測試（零 token）=="
bash -n "${SKILL_DEST}/scripts/gen_image.sh" \
  && say "✓ gen_image.sh 語法檢查通過" || die "gen_image.sh 語法異常，請回報"
[ -x "${SKILL_DEST}/scripts/gen_image.sh" ] \
  && say "✓ gen_image.sh 有執行權限" || die "gen_image.sh 缺執行權限"

say ""
say "== 安裝完成 =="
say "① 重開一個 Claude Code session 讓 skill 生效。"
say "② 想要品牌風格一致：把 ${SKILL_DEST}/STYLE.md 複製到你的專案根目錄並填寫。"
say "③ 之後在 Claude Code 說「幫我生一張…的圖」就會自動觸發；"
say "   或手動： bash \"${SKILL_DEST}/scripts/gen_image.sh\" \"圖片描述\" output/圖.png"
say "④ 解除安裝： bash \"${SELF_DIR}/uninstall.sh\""
