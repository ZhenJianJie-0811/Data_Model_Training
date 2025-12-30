CREATE OR REPLACE MODEL `data-model-final-project.netflix_final.netflix_churn_lr_model`
OPTIONS(
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['future_removed_90d'], -- 修正 1: 目標欄位名稱改對了
  enable_global_explain = TRUE,
  auto_class_weights = TRUE
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
  rating, -- 截圖顯示是 FLOAT，若有些是字串可能需轉型，目前先保持
  
  -- 4. 處理 Array (類型)
  ARRAY_TO_STRING(genres_array, ', ') AS genres_combo,
  
  -- 5. 處理 Duration (簡易版：直接取出數字部分)
  -- 假設 duration 格式為 "90 min" 或 "2 Seasons"，取出前面的數字
  CAST(REGEXP_EXTRACT(duration, r'^([0-9]+)') AS INT64) AS duration_approx,

  -- 6. 目標 Label
  future_removed_90d

FROM
  `data-model-final-project.netflix_final.leaving_final_dataset_ready`

WHERE
  -- 修正 2: 替代 is_train，使用 show_id 進行隨機切分 (80% 訓練)
  MOD(ABS(FARM_FINGERPRINT(show_id)), 10) < 8