CREATE OR REPLACE MODEL `data-model-final-project.models.model_baseline_lr`
OPTIONS(
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['future_viral_14d'],
  enable_global_explain = TRUE,
  data_split_method = 'CUSTOM',
  data_split_col = 'is_train'
) AS
SELECT 
  * EXCEPT(split_group), -- 排除 split_group 標籤，它不是特徵
FROM `data-model-final-project.netflix_final.view_ml_input_refined`
WHERE split_group = 'TRAIN_EVAL'; -- 只使用訓練和驗證資料