#!/bin/bash
#SBATCH --partition=brtx6
#SBATCH --gpus=1
#SBATCH --time=24:0:0
export CONDAROOT=/home/wgantt/miniconda3
export PATH=$CONDAROOT/condabin:$PATH
export PYTHONPATH="$PYTHONPATH:."
source $HOME/.bashrc
export MKL_THREADING_LAYER=GNU
conda activate gtt

export MAX_LENGTH_SRC=435
export MAX_LENGTH_TGT=75

export MODEL_TYPE=bert
export BERT_MODEL=bert-base-multilingual-cased
# export BERT_MODEL=bert-base-chinese

export LANG=zh

# Gold English data
# export DATA_DIR=../data/muc/processed/

# Mono Uncorrected (uncorrected silver data)
export DATA_DIR=../data/muc/processed/silver_data/$LANG

# Mono Corrected (alignment-corrected silver data)
# export DATA_DIR=/brtx/601-nvme1/wgantt/multimuc/data/annotations/$LANG/json/untokenized/

# Joint (English + corrected silver data)
# export DATA_DIR=/brtx/601-nvme1/wgantt/multimuc/data/annotations/$LANG/json/untokenized/en_$LANG/

export BATCH_SIZE=1
export NUM_EPOCHS=30
export SEED=2

export OUTPUT_DIR_NAME=mbert-base-cased-$LANG-silver-filtered-v2
export CURRENT_DIR=${PWD}
export OUTPUT_DIR=${CURRENT_DIR}/${OUTPUT_DIR_NAME}
mkdir -p $OUTPUT_DIR

# Add parent directory to python path to access transformer_base.py
export PYTHONPATH="../":"${PYTHONPATH}"

# for th in 100 200 300 400 500 600 700 800 900 1000  # 1 10 100 1000 10000 100000, 100 200 300 400 500
# for th in 10 20 30 40 50 60 70 80 90 100
# for th in 100
# for th in 10 50 60 70 80 90 100 110 120 130 140 150
for th in 80
do
echo "=========================================================================================="
echo "                                           threshold (${th})                              "
echo "=========================================================================================="
# Training
python3 run_pl_gtt.py  \
--data_dir $DATA_DIR \
--model_type $MODEL_TYPE \
--model_name_or_path $BERT_MODEL \
--output_dir $OUTPUT_DIR \
--max_seq_length_src  $MAX_LENGTH_SRC \
--max_seq_length_tgt $MAX_LENGTH_TGT \
--num_train_epochs $NUM_EPOCHS \
--train_batch_size $BATCH_SIZE \
--eval_batch_size $BATCH_SIZE \
--seed $SEED \
--n_gpu 1 \
--thresh $th \
--overwrite_cache \
--do_train

# Inference
python3 run_pl_gtt.py  \
--data_dir $DATA_DIR \
--model_type $MODEL_TYPE \
--model_name_or_path $BERT_MODEL \
--output_dir $OUTPUT_DIR \
--max_seq_length_src  $MAX_LENGTH_SRC \
--max_seq_length_tgt $MAX_LENGTH_TGT \
--num_train_epochs $NUM_EPOCHS \
--train_batch_size $BATCH_SIZE \
--eval_batch_size $BATCH_SIZE \
--seed $SEED \
--n_gpu 1 \
--thresh $th \
--overwrite_cache \
--do_predict
done