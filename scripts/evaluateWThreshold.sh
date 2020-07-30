#!/bin/bash
path=/gpfs1/work/weging/snakemakePipeline/

arr=(0.001 0.01 0.03 0.05 0.07 0.09 0.2 0.3 0.4)
for i in "${arr[@]}"
do
	python ${path}scripts/evalJson.py ${path}content.txt ${path}content_negative.txt ${path}results/kASA_merged_5.jsonl ${path}results/kASA_merged_5_result_${i}.txt $i &
	python ${path}scripts/evalJson.py ${path}content.txt ${path}content_negative.txt ${path}results/kASA_merged_10.jsonl ${path}results/kASA_merged_10_result_${i}.txt $i &
done
wait
