# SITCON 星際探索

SITCON 大地遊戲的 Flutter iOS／Android 玩家 App。支援離線試玩與連線測試；後端 API 和管理後台位於 `2027-game`。

## 專案結構

- `lib/views/`、`lib/viewmodels/`：畫面與狀態
- `lib/services/`：遊戲、NTAG 掃描與裝置設定
- `lib/l10n/`：繁體中文與英文語系
- `packages/sitcon_backend/`：離線遊戲引擎

## 快速開始

先[安裝 mise](https://mise.jdx.dev/getting-started.html)，再於專案根目錄執行 `mise install`，安裝 `mise.toml` 指定的 Flutter 和 Java。
安裝最新的 Android Studio、Xcode 與模擬器，並在 VS Code 安裝 Flutter 與 Dart 擴充套件。

### 離線試玩

在 App 專案根目錄執行，不需要後端或實體 NTAG：

```bash
mise exec -- flutter pub get
mise exec -- flutter run --dart-define=APP_MODE=demo
```

可使用模擬掃描；離線進度只儲存在裝置上。

### 連線測試

在 `2027-game` 執行 `npm run dev` 啟動 API 與管理後台。Android debug 裝置可用 `adb reverse tcp:8787 tcp:8787` 連回工作站；iOS 模擬器可直接使用 loopback。

在 App 專案根目錄執行：

```bash
mise exec -- flutter run \
  --dart-define=APP_MODE=server \
  --dart-define=API_BASE_URL=http://127.0.0.1:8787
```

遠端測試請在 App 輸入 HTTPS API 網址。需要模擬感應時，加上 `--dart-define=TEST_GAMEPLAY=true`。連線失敗不會切換成離線資料。

### VS Code

將 `.env.example` 複製成 `.env`，設定測試網址，再從 **Run and Debug** 選擇 **Debug** 或 **Release**。這些設定會打包進 App，不要放入憑證。

## 常用指令

- 靜態檢查：`mise exec -- flutter analyze`
- 測試：`mise exec -- flutter test`
- 離線測試 APK：`mise exec -- flutter build apk --release --dart-define=APP_MODE=demo`

## 多語系

1. 在 `lib/l10n/app_en.arb` 新增或修改英文文字；有參數時在 `@key` 設定 placeholder 的名稱與型別。
2. 在 `app_zh.arb` 和 `app_zh_TW.arb` 更新同一個 key，保留相同的 placeholder 名稱。
3. 執行 `mise exec -- flutter gen-l10n`，一併提交 ARB 與產生的 `app_localizations*.dart`，不要手動編輯產生檔。

畫面文字使用 `context.l10n`（從 `lib/l10n/localization.dart` 匯入）。遊戲或 API 回傳的訊息代碼在 `lib/l10n/game_text.dart` 透過 `gameText` 轉成顯示文字。

## 補充

- 實體掃描支援 NTAG213／215／216，只讀取 UID；請用真機驗證 NFC。
- 自訂發卡站和打卡小石可在管理後台綁定實體 NTAG。活動進行中，已報到的玩家請用一般玩家模式掃描；發卡站也須開放領取。
- 離線示範可直接點選所有本機發卡站來模擬掃描。連線測試的快捷清單只提供內建站；自訂站可在「測試掃描」輸入實際綁定的 UID。
