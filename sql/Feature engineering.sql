CREATE OR REPLACE VIEW `data-model-final-project.netflix_final.view_ml_input_refined` AS
SELECT
  -- 1. Target Label (預測目標)
  future_viral_14d,

  -- 2. 類別特徵 (經過降維與清洗)
  IFNULL(type, 'Unknown') AS type,
  
  -- [關鍵優化] Genres: 只取第一個逗號前的分類 (Primary Genre)，避免組合過多卡死模型
  IFNULL(SPLIT(genres, ',')[SAFE_OFFSET(0)], 'Unknown') AS primary_genre,
  
  -- [關鍵優化] Country: 補 Unknown，保留完整資訊讓模型自己判斷
  IFNULL(country, 'Unknown') AS country,
  
  IFNULL(language, 'Unknown') AS language,

  -- 3. 數值特徵 (Missing Handling)
  -- IMDB & TMDB 評分
  IFNULL(rating, 0) AS imdb_rating,
  IFNULL(popularity, 0) AS tmdb_popularity,
  IFNULL(vote_count, 0) AS tmdb_vote_count,
  IFNULL(vote_average, 0) AS tmdb_vote_average,
  
  -- 財務資訊 (預算與票房，取 Log 避免數值差異過大，+1 避免 log(0))
  LOG(IFNULL(budget, 0) + 1) AS log_budget,
  LOG(IFNULL(revenue, 0) + 1) AS log_revenue,
  
  -- 年份
  release_year,

  -- 4. 特徵工程: Duration (字串轉數字)
  CAST(REGEXP_EXTRACT(duration, r'(\d+)') AS INT64) AS duration_val,

  -- 5. 資料切分 (Train / Eval / Test)
  -- 使用 UID 雜湊，產生布林值 is_train (True=訓練, False=驗證)
  -- 排除 MOD=9 的資料作為最終測試集 (Test Set)
  CASE 
    WHEN MOD(ABS(FARM_FINGERPRINT(uid)), 10) < 8 THEN TRUE
    ELSE FALSE 
  END AS is_train,
  
  -- 保留一個標記給最後評估用 (不會進模型訓練)
  CASE 
    WHEN MOD(ABS(FARM_FINGERPRINT(uid)), 10) = 9 THEN 'TEST'
    ELSE 'TRAIN_EVAL'
  END AS split_group

FROM `data-model-final-project.netflix_final.final_dataset_ready`
WHERE future_viral_14d IS NOT NULL;