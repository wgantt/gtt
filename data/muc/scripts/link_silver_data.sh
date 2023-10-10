#!/bin/bash

MULTIMUC_DIR=/brtx/601-nvme1/wgantt/multimuc/data
ANNOTATED_DATA_DIR=$MULTIMUC_DIR/annotations/
SILVER_DATA_DIR=$MULTIMUC_DIR/updated_sent/updated_indexes/silver_data/
OUTPUT_DIR=/brtx/601-nvme1/wgantt/gtt-fork/data/muc/processed/silver_data/
LANGS=("ar" "ko" "ru" "zh" "fa")
LANG_FILE_PREFIXES=("ara_Arab" "kor" "rus" "zho_Hans" "fas")

mkdir -p $OUTPUT_DIR

for i in "${!LANGS[@]}"; do
	LANG=${LANGS[$i]}
	LANG_PREFIX=${LANG_FILE_PREFIXES[$i]}
	mkdir -p $OUTPUT_DIR/$LANG
	# training and validation data is the silver data
	ln -sf $SILVER_DATA_DIR/$LANG_PREFIX.silver-train.json $OUTPUT_DIR/$LANG/train.json
	ln -sf $SILVER_DATA_DIR/$LANG_PREFIX.silver-dev.json $OUTPUT_DIR/$LANG/dev.json
	# ln -sf $ANNOTATED_DATA_DIR/$LANG/json/untokenized/dev.json $OUTPUT_DIR/$LANG/dev.json
	# validation and test data is still the annotated data
	# test data is the annotated data
	ln -sf $ANNOTATED_DATA_DIR/$LANG/json/untokenized/test.json $OUTPUT_DIR/$LANG/test.json
done