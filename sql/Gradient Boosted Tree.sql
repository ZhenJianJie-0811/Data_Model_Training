CREATE OR REPLACE MODEL `data-model-final-project.models.model_gradient_boosted_tree`
OPTIONS(
  model_type = 'BOOSTED_TREE_CLASSIFIER', 
  input_label_cols = ['future_viral_14d'],
  max_tree_depth = 6,
  learn_rate = 0.1,
  early_stop = TRUE,
  enable_global_explain = TRUE,
  data_split_method = 'CUSTOM',
  data_split_col = 'is_train'
) AS
SELECT 
  * EXCEPT(split_group)
FROM `data-model-final-project.netflix_final.view_ml_input_refined`
WHERE split_group = 'TRAIN_EVAL';