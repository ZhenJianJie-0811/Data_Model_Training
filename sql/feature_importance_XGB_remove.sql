SELECT
  *
FROM
  ML.FEATURE_IMPORTANCE(MODEL `data-model-final-project.netflix_final.netflix_churn_xgb_model`)
ORDER BY
  importance_gain DESC -- 依據「能帶來多少資訊增益」排序，這比 weight 更準
LIMIT 15