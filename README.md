# codex-image — 在 Claude Code 裡用 Codex 生圖（吃訂閱額度）

讓 Claude Code 把生圖任務交給 **OpenAI Codex CLI** 的內建圖片工具（gpt-image）。因為用 ChatGPT 帳號登入，生圖消耗的是**訂閱方案的 agentic 用量、不另外付 API 費**。Claude 負責讀專案脈絡＋注入你的品牌風格指南（`STYLE.md`），Codex 負責畫——比直接在 ChatGPT 網頁生圖更貼合你的專案與品牌。

白話懶人包（機制、省錢原理、誠實限制）👉 https://med95albert.github.io/codex-image/

---

## 安裝（三選一）

### ① 一句話安裝（推薦，零技術門檻）

打開 Claude Code，貼上這句話：

> 幫我把 github.com/med95Albert/codex-image 這個技能裝到 ~/.claude/skills/codex-image，然後執行裡面的 install.sh 完成安裝檢查

裝完重開一個 Claude Code session 即生效。

### ② Plugin 兩行（原生外掛）

```
/plugin marketplace add med95Albert/codex-image
/plugin install codex-image@codex-image
```

重開 session 生效。

### ③ 手動

```bash
git clone https://github.com/med95Albert/codex-image ~/.claude/skills/codex-image
bash ~/.claude/skills/codex-image/install.sh
```

---

## 前置需求

| 需求 | 必要性 |
|---|---|
| Claude Code | 必要 |
| OpenAI Codex CLI（`brew install codex`） | 必要——生圖引擎 |
| ChatGPT Plus 以上訂閱，且 `codex login` 用 **ChatGPT 帳號**登入 | 必要——這是「不另付 API 費」的關鍵 |
| shell 裡**沒有** `OPENAI_API_KEY` / `CODEX_API_KEY` | 必要——存在就會改走按量付費 API，腳本會自動偵測並擋下 |

> ⚠️ `codex login` 時**絕對不要貼 API key**。一旦輸入 API key，就從「訂閱額度」切換成「按量付費」。

## 怎麼用

裝好後在 Claude Code 直接說「幫我生一張…的圖」「做個示意圖」「生個 QR code」就會自動觸發。也可手動：

```bash
# 基本：描述 + 輸出路徑
bash ~/.claude/skills/codex-image/scripts/gen_image.sh "復健中心溫暖明亮的等候區，扁平插畫風" output/lobby.png

# 加風格補充
bash ~/.claude/skills/codex-image/scripts/gen_image.sh "下肢肌力訓練示意圖" output/leg.png "留白多一點、用品牌主色"
```

### 讓風格穩定一致（強烈建議）

把本 repo 的 `STYLE.md` 範本複製到**你的專案根目錄**並填寫品牌色、字體、插畫風格、禁用元素。腳本每次生圖都會自動注入它——這就是「比直接在 ChatGPT 生圖更貼合你偏好」的來源。也可放 `AGENTS.md`（Codex 的專案記憶檔）讓 Codex 理解整個專案脈絡。

### QR code 等程式化元素

生 QR code、圖表、需要像素級正確的東西時，指令已要求 Codex「**用程式生成**（qrcode／matplotlib／Pillow），不要 AI 繪圖近似」——確保 QR code 能掃、數據正確、中文不亂碼。

## 成本與用量（務必懂）

- 生圖消耗訂閱的 **agentic 用量額度**，跟 ChatGPT 網頁版「每日幾張圖」是不同的池子。
- 生圖**比文字任務燒額度快約 3～5 倍**：偶爾生一兩張幾乎無感，連續大量就會很快見底。
- 決策規則：**少量、要精準／一致 → 走這條（訂閱）。大量批次（數十張以上）→ 改用 OpenAI 按量付費 API。** skill 內建這條判斷，遇到批次需求會主動擋下並改建議。

## 誠實限制

- **要養 ChatGPT 訂閱**——Plus 以上，且 Codex CLI 已登入；沒有它整條路不通。
- **額度是共用池**——生圖跟你其他 Codex agentic 任務搶同一份訂閱額度。
- **AI 繪圖部分不保證每次一致**——`STYLE.md` 大幅收斂風格，但 gpt-image 仍有隨機性；程式化元素（QR code／圖表）才有像素級保證。
- **憑證安全**——`codex login` 的憑證在 `~/.codex/auth.json`，當密碼看待，別進 git。

## 解除安裝

```bash
bash ~/.claude/skills/codex-image/uninstall.sh
```

不動你的 codex 登入、不動已生成的圖片。

---

MIT License ・ 環境：Claude Code × OpenAI Codex CLI ・ 作者：[楊為傑](https://github.com/med95Albert)
