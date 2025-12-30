SELECT * FROM ML.EVALUATE(MODEL `data-model-final-project.netflix_final.netflix_churn_xgb_model`, (
  -- 這裡放測試集的子查詢 (WHERE ... >= 8)，記得特徵要和上面一模一樣
  SELECT
    DATE_DIFF(snapshot_date, date_added, DAY) AS days_since_added,
    release_year, popularity, vote_average, vote_count,
    country, language, type, rating,
    ARRAY_TO_STRING(genres_array, ', ') AS genres_combo,
    CAST(REGEXP_EXTRACT(duration, r'^([0-9]+)') AS INT64) AS duration_approx,
    future_removed_90d
  FROM `data-model-final-project.netflix_final.leaving_final_dataset_ready`
  WHERE MOD(ABS(FARM_FINGERPRINT(show_id)), 10) >= 8
))