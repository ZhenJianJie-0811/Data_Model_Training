SELECT
  title,       -- 直接透傳出來
  type,
  country,
  prob as risk_score
FROM (
  SELECT
    title, type, country, -- 透傳欄位
    (SELECT prob FROM UNNEST(predicted_future_removed_90d_probs) WHERE label = 1) as prob
  FROM ML.PREDICT(MODEL `data-model-final-project.netflix_final.netflix_churn_xgb_model`, (
    SELECT
      title, -- 記得在這裡選取 title
      DATE_DIFF(snapshot_date, date_added, DAY) AS days_since_added,
      release_year, popularity, vote_average, vote_count,
      country, language, type, rating,
      ARRAY_TO_STRING(genres_array, ', ') AS genres_combo,
      CAST(REGEXP_EXTRACT(duration, r'^([0-9]+)') AS INT64) AS duration_approx,
      future_removed_90d
    FROM `data-model-final-project.netflix_final.leaving_final_dataset_ready`
    WHERE MOD(ABS(FARM_FINGERPRINT(show_id)), 10) >= 8
  ))
)
WHERE prob > 0.7
ORDER BY prob DESC