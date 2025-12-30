-- 比較 Gradient Boosted Tree vs Baseline
SELECT
  'Gradient_Boosted_Tree' AS model_name,
  roc_auc,
  accuracy,
  recall,
  f1_score,
  precision -- 這裡是指預設閾值 0.5 下的 Precision
FROM ML.EVALUATE(MODEL `data-model-final-project.models.model_gradient_boosted_tree`,
  (SELECT * EXCEPT(split_group) FROM `data-model-final-project.netflix_final.view_ml_input_refined` WHERE split_group = 'TEST'))

UNION ALL

SELECT
  'Baseline_Logistic_Regression' AS model_name,
  roc_auc,
  accuracy,
  recall,
  f1_score,
  precision
FROM ML.EVALUATE(MODEL `data-model-final-project.models.model_baseline_lr`,
  (SELECT * EXCEPT(split_group) FROM `data-model-final-project.netflix_final.view_ml_input_refined` WHERE split_group = 'TEST'));