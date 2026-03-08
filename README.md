# graduation_thesis（卒業論文リポジトリ）

インドネシアの ADM2（郡相当）×年のパネルを構築し、森林減少（deforestation）と Integrated Alerts の関係を推定（FE-OLS / 2SLS / 動学IV）するための再現用コード一式。

* 研究計画書: `研究計画書.pdf`
* 主要レポート（出力）: `reports/graduation_thesis.html` / `reports/graduation_thesis.Rmd`

---

## 1. ディレクトリ構成（要点）

### データ

* `data/raw/`：GEE等から取得した生データ（CSV/TIF/shape）

  * alerts（年別CSV）: `data/raw/alerts/idn_integrated_alerts_adm2_yearly_2019.csv` … `2025.csv`
  * clouds（地域別CSV）: `data/raw/clouds/IDN_cloud_ADM2_*.csv`
  * burned area（地域×期間CSV）: `data/raw/burned_area/*.csv`
  * forest loss（地域×期間CSV）: `data/raw/forestloss/*.csv`
  * 行政界（GAUL2015 ADM2）: `data/raw/IDN_adm2_gaul2015/*`
  * NTL（tif）は格納されているが、本研究では使用しない想定

* `data/interim/`：raw を整形して parquet 化した中間データ

  * `alerts_year.parquet`, `clouds_year.parquet`, `burned_period.parquet`, `forestloss_year.parquet`, `modis_lc_adm2_2019_2024.parquet` 等

* `data/processed/`：分析用に結合・整形した最終パネル（＋派生サンプル）

  * `adm2_panel.parquet`（統合パネル）
  * `adm2_reg_2019_2024.parquet`（回帰用）
  * `reg_dyn_*`（サンプル別の動学回帰用）など

### コード

* `gee/`：Google Earth Engine（取得用 JS）

  * alerts 年別: `gee/alerts/alerts_2019.js` … `alerts_2025.js`
  * `burnedarea.js`, `clouds.js`, `forestloss.js`, `landcover.js`, `precipitation.js`

* `scripts/`：R による整形〜推定〜図表作成

  * `scripts/00_run_rscripts.R`：全工程の一括実行（source の順番が定義されている）
  * `scripts/10_clean/`：raw → interim（parquet）
  * `scripts/20_build/`：interim → processed（統合）
  * `scripts/30_regprep/`：回帰用データセット作成（2019–2024、ログ、ラグ、サンプル定義）
  * `scripts/40_models/`：推定（FE-OLS / IV / 動学IV）
  * `scripts/50_tables/`：LaTeX 表出力（`outputs/tables`）
  * `scripts/60_figures/`：ヒストグラム、階級区分図、散布図（`outputs/figures`）

* `R/utils_io.R`：入出力ユーティリティ

### 出力

* `outputs/models/`：推定結果（`.rds`）
* `outputs/tables/`：論文貼り付け用（`.tex`）
* `outputs/figures/`：図（choropleth / hist / scatter）

---

## 2. 再現手順（R 側）

### 前提

* RStudio で `graduation_thesis.Rproj` を開き、プロジェクト直下を working directory にする
* 必要パッケージ（少なくとも）：`fixest`, `arrow`, `dplyr`, `modelsummary`, `sf`, `ggplot2`, `tidyr`, `stringr`, `knitr`, `kableExtra`, `rprojroot`, `viridis`

### 一括実行（推奨）

**実行場所：RStudio の Console（プロジェクト直下で）**

```
source("scripts/00_run_rscripts.R")
```

このスクリプトが、clean → build → regprep → models → tables → figures の順に全て `source()` します。

---

## 3. 生成される主要ファイル

* 回帰用パネル（例）

  * `data/processed/adm2_panel.parquet`（統合パネル、先に build が必要）
  * `data/processed/adm2_reg_2019_2024.parquet`（2019–2024、ログ変換）

* 図表（例）

  * 階級区分図：`outputs/figures/choropleth/*.png`
  * ヒストグラム：`outputs/figures/hist/*.png` / `histograms_all.pdf`
  * 散布図：`outputs/figures/scatter/*.png`
  * 表（LaTeX）：`outputs/tables/*.tex`

---

## 4. データ作成（GEE）

GEE 側の取得コードは `gee/` に集約されています（alerts / clouds / forestloss / burnedarea / landcover / precipitation）。
取得した CSV/TIF は `data/raw/` に保存し、R の `scripts/10_clean/*` が parquet 化します（例：burned area は `data/raw/burned_area/*.csv` を結合して `data/interim/burned_period.parquet` を作成）。

---

## 5. 注意事項（重要）

* `data/raw/idn_integrated_alerts_adm2_yearly_2016_2025.csv` は **全欠損で使用不可**（このプロジェクトでは年別CSVを使用）。
* hotspot と NTL は **用いない**方針（`data/raw/ntl/` は存在するが分析対象外）。
* `scripts/99_*` は試行/補助用。少なくとも `00_run_rscripts.R` の一括実行フローには含まれていません。

---

## 6. 参考（成果物）

* 進捗ログ等：`reports/20251205_progress.Rmd` / `.html` / `.pdf`
* 本文レポート：`reports/graduation_thesis.Rmd` → `reports/graduation_thesis.html`

---

必要なら、この README を「あなたの論文の章立て（どの表・図が本文/付録のどこに対応するか）」まで追記した版に拡張できます。
