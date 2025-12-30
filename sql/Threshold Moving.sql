SELECT
  threshold,
  COUNTIF(prob > threshold) AS predicted_removed_count, -- 預測會下架的數量
  COUNTIF(prob > threshold AND future_removed_90d = 1) AS true_positive, -- 真正抓到的數量
  
  -- 計算新的 Precision (準確率)：抓到的真下架 / 所有發出的警報
  SAFE_DIVIDE(COUNTIF(prob > threshold AND future_removed_90d = 1), COUNTIF(prob > threshold)) AS new_precision,
  
  -- 計算新的 Recall (召回率)：抓到的真下架 / 實際上所有的下架片
  SAFE_DIVIDE(COUNTIF(prob > threshold AND future_removed_90d = 1), COUNTIF(future_removed_90d = 1)) AS new_recall

FROM (
  SELECT
    future_removed_90d,
    -- 取出模型預測為 1 (下架) 的機率
    (SELECT prob FROM UNNEST(predicted_future_removed_90d_probs) WHERE label = 1) AS prob
  FROM
    ML.PREDICT(MODEL `data-model-final-project.netflix_final.netflix_churn_xgb_model`, (
      SELECT
        DATE_DIFF(snapshot_date, date_added, DAY) AS days_since_added,
        release_year, popularity, vote_average, vote_count,
        country, language, type, rating,
        ARRAY_TO_STRING(genres_array, ', ') AS genres_combo,
        CAST(REGEXP_EXTRACT(duration, r'^([0-9]+)') AS INT64) AS duration_approx,
        future_removed_90d
      FROM
        `data-model-final-project.netflix_final.leaving_final_dataset_ready`
      WHERE
        MOD(ABS(FARM_FINGERPRINT(show_id)), 10) >= 8 -- 測試集
    ))
),
UNNEST([0.5, 0.6, 0.7, 0.8, 0.9]) AS threshold -- 測試不同的門檻值

GROUP BY threshold -- ⚠️ 修正重點：必須加上這一行！

ORDER BY threshold