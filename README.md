# Data_Model_Training
Netflix 串流數據分析專案：使用 BigQuery ML 預測內容爆紅與下架趨勢之模型訓練程式碼。
# 🎬 Netflix Content Analytics: 爆紅與下架預測系統 (Viral & Removal Prediction)

> 基於 Google BigQuery ML 的大規模串流影音數據分析與預測模型
> *A BigQuery ML-based system to predict content viral hits and removal risks.*

## 📖 專案背景 (Business Scenario)

[cite_start]隨著 Netflix 內容數量呈指數級增長，行銷團隊面臨的核心挑戰並非缺乏內容，而是**如何將有限的資源分配給真正具備潛力的作品** [cite: 8-9]。

[cite_start]目前的決策多依賴歷史榜單或直覺，缺乏前瞻性。本專案旨在解決兩大商業問題 [cite: 10-26]：
1.  **🚀 爆紅預測 (Viral Hit Prediction):** 提前 14 天預測哪些新作品會進入全球 Top 10，協助行銷團隊搶佔先機。
2.  **📉 下架預測 (Removal Risk Prediction):** 提前 90 天識別高風險下架作品，協助版權與營運團隊進行續約評估或最後一波推廣。

---

## 🏗️ 模型架構與方法 (Models & Methodology)

[cite_start]本專案利用 **Google BigQuery ML (BQML)** 進行 In-Database Training，避免了大規模數據移動，並實現了高效的特徵工程與模型迭代 [cite: 135-137]。我們為兩個預測任務分別建立了 Logistic Regression (Baseline) 與 Gradient Boosted Tree (Final Model) 進行比較。

### 1. 爆紅預測模型 (Viral Hit Prediction)
* [cite_start]**預測目標:** 作品上架後 **14 天內** 是否進入全球 Top 10 排行榜 [cite: 162-163]。
* **使用模型:** Gradient Boosted Tree (GBT) vs. Logistic Regression。
* **關鍵技術:** Precision@K 評估、對數轉換 (Log Transformation) 處理票房與預算特徵。

### 2. 下架預測模型 (Removal Risk Analysis)
* **預測目標:** 作品在特定時間點後的 **90 天內** 是否會被下架。
* **使用模型:** XGBoost vs. Logistic Regression。
* **關鍵技術:** * **Threshold Moving:** 針對資料不平衡問題，調整信心門檻以提升 Precision。
    * **Snapshot Logic:** 建立時間切片嚴格防止 Data Leakage。

---

## 📂 檔案結構與說明 (File Structure)

本 Repository 的 `sql/` 資料夾包含了完整的模型訓練與評估流程，檔案對應功能如下：

### 🛠️ 資料前處理 (Preprocessing)
* `Feature engineering.sql`: 執行通用的特徵工程，包含資料清洗、對數轉換與類別特徵處理。

### 🚀 爆紅預測任務 (Viral Prediction)
**模型訓練 (Training)**
* `Logistic Regression.sql`: 訓練 Baseline 線性模型。
* `Gradient Boosted Tree.sql`: 訓練最終 GBT 模型 (效能較佳)。

**模型評估 (Evaluation)**
* `ROC-AUC, Accuracy, Recall, F1,Precision.sql`: 計算各項標準分類指標。
* `Precision@K & Feature Importance.sql`: 計算 Precision@50 (模擬推薦前50部作品的命中率) 以及輸出特徵重要性排行。

### 📉 下架預測任務 (Removal Prediction)
**模型訓練 (Training)**
* `removed_logistic.sql`: 訓練 Baseline 線性模型。
* `remove_XGB.sql`: 訓練最終 XGBoost 模型。

**模型評估與優化 (Evaluation & Tuning)**
* `eval_logistic_Remove.sql`: 評估 Baseline 模型效能。
* `eval_XGB_Remove.sql`: 評估 XGBoost 模型效能。
* `Threshold Moving.sql`: 測試不同信心門檻 (Threshold) 下的 Precision 與 Recall 變化，尋找最佳切點。

**分析與輸出 (Analysis & Output)**
* `feature_importancde_logistic_remove.sql`: 分析 Logistic Regression 的係數權重。
* `feature_importance_XGB_remove.sql`: 分析 XGBoost 的特徵重要性 (Feature Gain)。
* `outputRemoveList.sql`: 根據最佳門檻值，輸出最終的高風險下架清單供營運團隊參考。

---

## 📊 模型績效與成果 (Performance & Results)

### 🚀 爆紅預測表現
[cite_start]模型展現了極佳的排序能力，能有效輔助精準行銷 [cite: 194-206]。
* **ROC-AUC:** **0.956** (顯著優於 Baseline Logistic Regression 的 0.836)。
* **Precision@50:** **38%**。這意味著在模型推薦的前 50 部作品中，有 19 部實際成為全球爆款。相較於隨機投放 (<5%)，提升了 **7 倍** 以上的效率。

### 📉 下架預測表現
[cite_start]針對極度不平衡的下架數據，我們採用「高信心門檻」策略來鎖定高風險名單 [cite: 253-255]。
* **ROC-AUC:** **0.582** (優於 Baseline 的 0.533)。
* **商業價值 (Lift):** 當信心門檻設定為 0.7 時 (詳見 `Threshold Moving.sql`)，Precision 達到 **42.9%**。相較於隨機抽查 (11%)，模型提供了近 **4 倍** 的效率提升。

---

## 💡 關鍵洞察 (Key Insights)

透過特徵重要性分析 (Feature Importance)，我們發現：

1.  [cite_start]**爆紅靠「勢」不靠「分」:** 影響爆紅的最關鍵因素是 **票房 (Revenue)** 與 **聲量 (Votes)**，而非 IMDb 評分。這顯示「市場動能」比「內容品質」更能預測短期爆發力 [cite: 207-208]。
2.  [cite_start]**下架看「合約」與「片齡」:** 預測下架與否的核心因子是 **作品類型 (Type)** 與 **發行年份 (Release Year)**，反映了電影與影集在授權合約結構上的本質差異 [cite: 287-288]。
