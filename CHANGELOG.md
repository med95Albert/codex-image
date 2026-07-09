# CHANGELOG

## v1.0.0（2026-07-09）

首次公開發佈。

- `SKILL.md`：skill 本體 — 觸發判斷（少量走訂閱／大量擋下改建議 API）、前置設定、成本規則。
- `scripts/gen_image.sh`：生圖腳本 — 自動注入工作目錄 `STYLE.md`、守門 `OPENAI_API_KEY`／`CODEX_API_KEY` 避免誤走付費 API、QR code 等程式化元素強制「用程式生成」。
- `STYLE.md`：品牌風格指南範本（複製到專案根目錄填寫）。
- `install.sh`／`uninstall.sh`：一鍵安裝與解除，idempotent，只寫入 `~/.claude/`。
- `.claude-plugin/`：原生 plugin 支援（`/plugin marketplace add med95Albert/codex-image`）。
- `docs/`：GitHub Pages 白話懶人包。

維護註記：skill 檔案的正本在 repo 根目錄；`skills/codex-image/` 是給 plugin 系統的鏡像副本，改動根目錄檔案後請同步。
