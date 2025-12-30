-- 1. 計算 Precision@K
DECLARE K INT64 DEFAULT 50; -- 你可以在這裡隨意更改 K 值，例如 100

WITH predictions AS (
  SELECT
    future_viral_14d AS actual_label,
    probs.prob as predicted_prob
  FROM ML.PREDICT(MODEL `data-model-final-project.models.model_gradient_boosted_tree`,
    (SELECT * EXCEPT(split_group) FROM `data-model-final-project.netflix_final.view_ml_input_refined` WHERE split_group = 'TEST')),
  UNNEST(predicted_future_viral_14d_probs) AS probs
  WHERE probs.label = 1
),

ranked_predictions AS (
  SELECT 
    actual_label,
    predicted_prob,
    -- 使用 ROW_NUMBER 對機率進行排名 (1, 2, 3...)
    ROW_NUMBER() OVER(ORDER BY predicted_prob DESC) as rank
  FROM predictions
)

SELECT
  'Precision@' || K AS metric_name,
  COUNTIF(actual_label = 1) AS correct_hits,   -- 在前 K 名中猜對幾個
  K AS total_recommendations,
  ROUND(COUNTIF(actual_label = 1) / K, 4) AS precision_at_k_score
FROM ranked_predictions
WHERE rank <= K; -- ✅ 這裡可以使用變數 K 進行篩選


-- 2. 查看 Feature Importance (這段原本沒問題，直接執行即可)
SELECT
  feature,
  importance_gain,  -- 資訊增益 (數值越大代表對模型越重要)
  importance_weight -- 被用來做分類節點的次數
FROM ML.FEATURE_IMPORTANCE(MODEL `data-model-final-project.models.model_gradient_boosted_tree`)
ORDER BY importance_gain DESC
LIMIT 15;