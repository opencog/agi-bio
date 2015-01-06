# To be sourced in test.sh

moses \
    -i "$data_basename_train" \
    --log-level $log_level \
    --output-score 0 \
    --output-with-labels 1 \
    --output-format scheme \
    --jobs $jobs \
    --max-evals $(hr2i $evals) \
    --random-seed $init_seed \
    --result-count $max_candidates \
    --target-feature age \
    --output-file $moses_output_file \
    --enable-fs 1 \
    --fs-target-size $fsm_nfeats \
    --fs-focus all \
    --fs-algo random \
    --fs-scorer mi
