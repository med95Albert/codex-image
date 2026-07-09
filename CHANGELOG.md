# CHANGELOG

## v1.2.1（2026-07-09）

QR code 鐵律——事故驅動修補。

實測事故：Codex 沙箱內沒有 `qrcode` 套件、連不上 PyPI，於是**手寫純 Python QR 編碼器**並「自我驗證通過」；但 Apple Vision 完全解不出該圖（手寫編碼器自洽但不合規，真實掃描器讀不了）。修補：

- `scripts/gen_image.sh` 指令新增 QR 鐵律：①只准標準編碼器（Python `qrcode`/`segno`、`qrencode`、macOS CoreImage `CIQRCodeGenerator`），嚴禁手寫編碼演算法；②驗證必須用與編碼器不同來源的獨立解碼器（Vision／zbar／OpenCV），自編自解不算驗證；③沒有標準編碼器且裝不了→誠實回報失敗，不硬做。
- `SKILL.md`：記錄事故與鐵律；建議 Claude 端收到 QR 成品後獨立複驗（macOS 上 CoreImage 生成＋Vision 解碼皆內建、零安裝）。

## v1.2.0（2026-07-09）

多風格支援——一個專案可養多套畫風，點名即切換。

- 檔案佈局：`STYLE.md` = 預設風格兼品牌基底（沒指定就用它，行為與 v1.1 完全相容）；`styles/<名稱>.md` = 具名變體，檔名即風格名，內容只寫與基底的差異。
- `scripts/gen_image.sh`：新增 `--style <風格名>` 參數——變體與基底**同時注入**，prompt 內聲明「衝突處以變體為準、品牌恆定項仍適用」（合併交給模型，bash 不解析 markdown）。指定不存在的風格會列出現有風格再退出。
- `SKILL.md`：新增「風格決定流程」——使用者點名風格→匹配 `styles/` 檔名；沒點名→預設，不多問。風格管理自然語言化：「列出我的風格」「新增一種風格」「把○○設為預設」（先把舊預設備份成變體，再把新變體合併進 STYLE.md）、「刪掉○○風格」（先確認）。建立訪談支援直接建具名變體。
- 新增觸發詞：「用○○風格生」「換個風格」「列出我的風格」「把○○設為預設風格」。

## v1.1.0（2026-07-09）

新增「風格訪談流程」——解決多數人沒有 STYLE.md 的問題。

- `SKILL.md`：生圖前檢查工作目錄的 `STYLE.md`；不存在時先問使用者三選一——
  ① 給參考素材（網址→WebFetch 分析、圖片→讀圖取色、文字描述→展開），AI 總結成 STYLE.md 草稿（含具體 hex 色碼）供確認後存檔；
  ② 從預設風格挑一種（扁平插畫／水彩手繪／極簡線條／寫實攝影感）；
  ③ 本次跳過，直接生圖。
  也新增觸發詞：「建 STYLE.md」「幫我定義圖片風格」。
- `scripts/gen_image.sh`：找不到 STYLE.md 時印出提示（可請 Claude 幫建），不再靜默略過。

## v1.0.0（2026-07-09）

首次公開發佈。

- `SKILL.md`：skill 本體 — 觸發判斷（少量走訂閱／大量擋下改建議 API）、前置設定、成本規則。
- `scripts/gen_image.sh`：生圖腳本 — 自動注入工作目錄 `STYLE.md`、守門 `OPENAI_API_KEY`／`CODEX_API_KEY` 避免誤走付費 API、QR code 等程式化元素強制「用程式生成」。
- `STYLE.md`：品牌風格指南範本（複製到專案根目錄填寫）。
- `install.sh`／`uninstall.sh`：一鍵安裝與解除，idempotent，只寫入 `~/.claude/`。
- `.claude-plugin/`：原生 plugin 支援（`/plugin marketplace add med95Albert/codex-image`）。
- `docs/`：GitHub Pages 白話懶人包。

維護註記：skill 檔案的正本在 repo 根目錄；`skills/codex-image/` 是給 plugin 系統的鏡像副本，改動根目錄檔案後請同步。
