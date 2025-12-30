-- 刪除舊模型 (如果名稱衝突) 或建立新名稱
CREATE OR REPLACE MODEL `data-model-final-project.netflix_final.netflix_churn_xgb_model`
OPTIONS(
  model_type = 'BOOSTED_TREE_CLASSIFIER', -- 核心改變：切換為樹模型
  input_label_cols = ['future_removed_90d'],
  
  -- XGBoost 特定參數建議 (先用穩健的預設值微調)
  max_iterations = 50,     -- 樹的數量 (相當於 n_estimators)
  learn_rate = 0.3,        -- 學習率
  max_tree_depth = 6,           -- 樹的深度 (太深容易過擬合，6 是不錯的起點)
  early_stop = TRUE,       -- 如果沒進步就提早停，節省時間
  auto_class_weights = TRUE -- 繼續保持，對抗不平衡資料
) AS
SELECT
  -- 1. 特徵工程：計算上架天數
  DATE_DIFF(snapshot_date, date_added, DAY) AS days_since_added,
  
  -- 2. 數值特徵
  release_year,
  popularity,
  vote_average,
  vote_count,
  
  -- 3. 類別特徵
  country,
  language,
  type,
  rating, 
  
  -- 4. 處理 Array (類型)
  ARRAY_TO_STRING(genres_array, ', ') AS genres_combo,
  
  -- 5. 處理 Duration
  CAST(REGEXP_EXTRACT(duration, r'^([0-9]+)') AS INT64) AS duration_approx,

  -- 6. 目標 Label
  future_removed_90d

FROM
  `data-model-final-project.netflix_final.leaving_final_dataset_ready`

WHERE
  -- 保持原本的隨機切分
  MOD(ABS(FARM_FINGERPRINT(show_id)), 10) < 8