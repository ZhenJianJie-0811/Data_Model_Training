SELECT
  *
FROM
  ML.EVALUATE(MODEL `data-model-final-project.netflix_final.netflix_churn_lr_model`, (
    SELECT
      -- 必須重複訓練時的特徵計算邏輯
      DATE_DIFF(snapshot_date, date_added, DAY) AS days_since_added,
      release_year,
      popularity,
      vote_average,
      vote_count,
      country,
      language,
      type,
      rating,
      ARRAY_TO_STRING(genres_array, ', ') AS genres_combo,
      CAST(REGEXP_EXTRACT(duration, r'^([0-9]+)') AS INT64) AS duration_approx,
      
      -- 答案 (Ground Truth)
      future_removed_90d
    FROM
      `data-model-final-project.netflix_final.leaving_final_dataset_ready`
    WHERE
      -- ⚠️ 關鍵：取餘數 >= 8，代表這是訓練時沒看過的那 20% 資料
      MOD(ABS(FARM_FINGERPRINT(show_id)), 10) >= 8
  ))