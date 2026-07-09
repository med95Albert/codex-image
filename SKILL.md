---
name: codex-image
description: "在 Claude Code 裡透過 Codex CLI 生圖，吃 ChatGPT 訂閱額度、不另外付 API 費。適合少量、需要高精準度／一致風格的圖（含程式化生成的 QR code、圖表、精確中文排版）。Use whenever the user wants Claude Code to generate or edit an image, make a picture/diagram/QR code, or produce visuals consistent with their brand style. Trigger on：生圖, 產生圖片, 做一張圖, 幫我生個圖, 出張圖, Codex 生圖, gpt-image, 生 QR code, 做示意圖, generate image, make an image。也在使用者想建立或更新圖片風格指南時觸發：建 STYLE.md, 幫我定義圖片風格, 風格指南。大量批次生圖(數十張以上)請改用按量付費 API，否則會撞訂閱用量上限。"
---

# codex-image ・ 用 Codex CLI 生圖（吃訂閱額度）v1.1

**做什麼**：在 Claude Code session 裡，把生圖任務交給 Codex CLI 的內建圖片工具(gpt-image-2)。
因為用 ChatGPT 帳號登入，生圖消耗訂閱方案的 agentic 用量、**不另外收 API 費**。

**為什麼走這條路而不是直接在 ChatGPT 生圖**：

- Claude Code 有專案脈絡（讀資料夾、AGENTS.md / STYLE.md），下給 Codex 的 prompt 更精準、風格更一致。
- 程式化元素（QR code、圖表、精確中文排版）用「程式生成」而非「AI 繪圖近似」，差一點點 QR code 就連不到正確網址，這條路能保證正確。

---

## 內容物（本 skill 資料夾結構）

```
codex-image/
├── SKILL.md            ← 本說明
├── scripts/
│   └── gen_image.sh    ← 實際生圖腳本（呼叫 codex exec）
└── STYLE.md            ← 品牌風格範本（複製到你的專案根目錄後填寫）
```

> `STYLE.md` 是「範本」。實際生圖時，腳本讀的是**目前工作目錄**裡的 `STYLE.md`，
> 所以請把它複製到你的專案根目錄並填上你的品牌設定。

---

## 觸發判斷

### 觸發

- 「幫我生一張…圖」「做個示意圖」「出張…的圖」「生個 QR code」
- 任何要產出圖片、且希望風格與品牌一致的少量需求

### 非觸發（要擋下並改建議）

- **大量批次**（例如一次幾十～幾百張，像之前復健網站 378 張）：訂閱額度會很快撞上限、要一直等。
  → 建議改用 OpenAI 按量付費 API（gpt-image 系列）跑批次，該花的錢花。
- 純文字任務、不需要圖。

---

## 生圖前：風格檢查（沒有 STYLE.md 時的訪談流程）

每次生圖前，先看**目前工作目錄**有沒有 `STYLE.md`：

- **有** → 直接用，照常生圖。
- **沒有** → 先別急著生圖。用 AskUserQuestion（或直接問）讓使用者選一條路：

### 選項 1：給我參考素材，AI 幫你總結成 STYLE.md（推薦）

使用者提供任一種（可混搭）：

| 素材類型 | 怎麼分析 |
|---|---|
| **網址**（品牌官網、喜歡的網站、作品集連結） | 用 WebFetch 讀取，觀察配色、字體氣質、視覺語言、留白密度 |
| **圖片檔**（logo、過去的設計、喜歡的範例圖） | 用 Read 讀圖，抽出主色（給具體 hex 色碼）、線條風格、構圖習慣 |
| **文字描述**（「溫暖、手繪感、莫蘭迪色」） | 直接展開成可操作的風格條目 |

分析後按 `STYLE.md` 範本結構（品牌色／字體／插畫風格／構圖偏好／禁用元素）寫出**草稿**，
先給使用者過目確認，再存到專案根目錄。要點：

- 顏色寫**具體 hex 色碼**（從網站或圖片實際取色），不要只寫「藍色」。
- 每個欄位一定要可操作——寫「細線條、圓角、無粗黑邊」，不寫「有質感」。
- 「禁用元素」主動幫使用者想：浮水印、無意義文字、雜亂背景是常見默認項。

### 選項 2：從預設風格挑一種

給 3～4 個常用預設讓使用者挑，選了就用該預設寫一份精簡 STYLE.md：

- **扁平插畫**（flat illustration）：色塊、無漸層、幾何簡化——衛教圖、示意圖首選
- **水彩手繪**：柔和暈染、手繪線條——溫暖親子感
- **極簡線條**：單色細線、大量留白——圖示、知性內容
- **寫實攝影感**：自然光、真實場景——形象照風格的情境圖

### 選項 3：這次先跳過

不建 STYLE.md，本次直接用使用者的描述生圖。之後想建，隨時說「幫我建 STYLE.md」。

> 建好的 `STYLE.md` 屬於**該專案**（存在工作目錄根部），之後每次生圖自動注入。
> 換專案要重建，或把現成的複製過去再微調。

---

## 前置設定（只做一次）

1. 安裝 Codex CLI（macOS）：

   ```bash
   brew install codex          # 或 curl -fsSL https://chatgpt.com/codex/install.sh | sh
   ```

2. 登入——**這步是省錢的關鍵**：

   ```bash
   codex login                 # 瀏覽器會開啟，用「ChatGPT 帳號」登入(Plus 以上)
   ```

   **絕對不要在登入畫面貼 API key。** 一旦輸入 API key，就會從「訂閱額度」切換成「按量付費」。

3. 確認走的是訂閱模式：

   ```bash
   codex login status          # 已登入會 exit 0
   ```

   並確保 shell 裡**沒有**設 `OPENAI_API_KEY` / `CODEX_API_KEY`——這兩個若存在，`codex exec` 會優先用它們(=付費 API)。腳本會自動偵測並擋下。

4. 給腳本執行權限（第一次）：

   ```bash
   chmod +x scripts/gen_image.sh
   ```

---

## 用法

```bash
# 基本：描述 + 輸出路徑
scripts/gen_image.sh "復健中心溫暖明亮的等候區，扁平插畫風" output/lobby.png

# 加風格補充
scripts/gen_image.sh "下肢肌力訓練示意圖" output/leg.png "留白多一點、用品牌主色"
```

腳本會：載入工作目錄的 `STYLE.md`(若有) → 組好指令 → 跑 `codex exec --sandbox workspace-write --skip-git-repo-check` 生圖並寫檔 → 回報存檔路徑。（加 `--skip-git-repo-check` 是因為實測：不在 git 專案裡跑時，Codex 預設會卡住，加了才能在任何資料夾運作。）

### 讓風格穩定一致（強烈建議）

- 在專案根目錄放一個 **`STYLE.md`**：寫品牌色、字體、插畫風格、構圖偏好、禁用元素。腳本會自動把它注入每次生圖指令，這就是「比直接在 ChatGPT 生圖更貼合你喜好」的來源。
- 不會寫？不用自己寫——走上面的「風格檢查訪談流程」，丟網址／圖片／文字描述給 AI 總結即可。
- 也可放 **`AGENTS.md`**（Codex 的專案記憶檔，相當於 Claude 的 CLAUDE.md）。Codex 每次都會讀，用來理解整個專案脈絡。

---

## 成本與用量（務必懂）

- 生圖消耗的是訂閱的 **agentic 用量額度**，跟 ChatGPT 網頁版「每日幾張圖」的限制是**不同的池子**。
- 生圖**比文字任務燒額度快很多（約 3～5 倍）**。偶爾生一兩張幾乎無感；連續生大量就會很快見底——這正是 378 張那種情境會卡住的原因。
- 決策規則：**少量、要精準／一致 → 走這條(訂閱)。大量批次 → 走按量付費 API。**

---

## QR code 等程式化元素

生 QR code、圖表、需要像素級正確的東西時，指令裡已要求 Codex「用程式生成、不要 AI 繪圖」。
Codex 會實際跑程式(如 `qrcode`/`matplotlib`)產出，確保 QR code 能掃、能連到正確網址，中文不亂碼。

---

## 安全提醒

- `codex login` 的憑證存在 `~/.codex/auth.json`，當密碼看待，別進 git、別外流。
- 含病人可識別資訊的素材，沿用既有去識別化流程後再處理。
