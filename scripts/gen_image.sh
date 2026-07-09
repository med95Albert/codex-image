#!/usr/bin/env bash
# gen_image.sh — 透過 Codex CLI（ChatGPT 訂閱額度）生圖
#
# 用法：
#   scripts/gen_image.sh "<圖片描述>" <輸出路徑.png> ["<風格補充(可選)>"]
#
# 範例：
#   scripts/gen_image.sh "復健中心溫暖明亮的等候區，扁平插畫風" output/lobby.png
#   scripts/gen_image.sh "下肢肌力訓練示意圖" output/leg.png "留白多一點、用品牌主色"
#
# 設計重點：
#   1. 自動載入工作目錄的 STYLE.md，注入每次生圖指令 → 風格一致。
#   2. 守門 OPENAI_API_KEY / CODEX_API_KEY：存在就擋下，避免誤走付費 API。
#   3. QR code／圖表等要求 Codex「用程式生成」，確保像素級正確、中文不亂碼。

set -euo pipefail

# ---- 0. 參數檢查 ----
if [[ $# -lt 2 ]]; then
  echo "用法：$0 \"<圖片描述>\" <輸出路徑.png> [\"<風格補充>\"]" >&2
  exit 1
fi

PROMPT_DESC="$1"
OUT_PATH="$2"
STYLE_EXTRA="${3:-}"

# ---- 1. 環境守門：避免誤用按量付費 API ----
if [[ -n "${OPENAI_API_KEY:-}" || -n "${CODEX_API_KEY:-}" ]]; then
  echo "⚠️  偵測到 OPENAI_API_KEY / CODEX_API_KEY 環境變數。" >&2
  echo "    codex exec 會優先用它們 = 改走按量付費 API（不是訂閱額度）。" >&2
  echo "    若要省錢走訂閱，請先執行： unset OPENAI_API_KEY CODEX_API_KEY" >&2
  exit 1
fi

# ---- 2. 確認 codex 已安裝並登入 ----
if ! command -v codex >/dev/null 2>&1; then
  echo "❌ 找不到 codex CLI。請先安裝： brew install codex" >&2
  exit 1
fi
if ! codex login status >/dev/null 2>&1; then
  echo "❌ Codex 尚未登入。請先執行： codex login（用 ChatGPT 帳號，別貼 API key）" >&2
  exit 1
fi

# ---- 3. 載入 STYLE.md（若存在於目前工作目錄）----
STYLE_BLOCK=""
if [[ -f "STYLE.md" ]]; then
  STYLE_BLOCK="$(cat STYLE.md)"
else
  echo "ℹ️  未找到 STYLE.md——本次直接用描述生圖。" >&2
  echo "    想要品牌風格一致，可請 Claude：「幫我建 STYLE.md」（給它網址／圖片／文字描述，AI 幫你總結）" >&2
fi

# ---- 4. 準備輸出資料夾 ----
OUT_DIR="$(dirname "$OUT_PATH")"
mkdir -p "$OUT_DIR"

# ---- 5. 組合給 Codex 的指令 ----
INSTRUCTION="你是生圖助手。請使用 Codex 內建的圖片生成工具（image generation / image_gen tool）產生一張圖片，並存成 PNG 檔到指定路徑。

【輸出路徑】
${OUT_PATH}

【圖片描述】
${PROMPT_DESC}

【本次風格補充】
${STYLE_EXTRA:-（無）}

【專案風格指南 STYLE.md】
${STYLE_BLOCK:-（此專案未提供 STYLE.md）}

【規則】
1. 一般插畫／示意圖：用內建圖片工具（gpt-image）生成。
2. 程式化元素（QR code、圖表、需要像素級正確或精確中文排版）：務必「用程式生成」
   （例如 Python 的 qrcode / matplotlib / Pillow），不要用 AI 繪圖近似，以確保 QR code 可掃、
   數據正確、中文不亂碼。
3. 嚴格存檔到上面的【輸出路徑】，完成後在最後一行輸出實際存檔的檔案路徑。"

# ---- 6. 執行 ----
echo "🎨 生圖中… → ${OUT_PATH}"
codex exec --sandbox workspace-write --skip-git-repo-check "$INSTRUCTION"

# ---- 7. 回報 ----
if [[ -f "$OUT_PATH" ]]; then
  echo "✅ 完成： ${OUT_PATH}"
else
  echo "⚠️  指令已執行，但找不到 ${OUT_PATH}。" >&2
  echo "    請查看上方 Codex 輸出確認實際存檔位置。" >&2
  exit 1
fi
