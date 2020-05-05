#!/bin/bash
path=/gpfs1/work/weging/snakemakePipeline/
# for file in ${path}results/kASA_*.jsonl
# do
	# temp=${file#${path}results/}
	# filename=${temp%.json}
	# python ${path}scripts/evalJson.py /gpfs1/work/weging/snakemakePipeline/content.txt /gpfs1/work/weging/snakemakePipeline/content_negative.txt ${file} ${path}results/${filename}_result_0.5.txt 0.5 &
# done
# wait

arr=(0.001 0.01 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0)
for i in "${arr[@]}"
do
	python ${path}scripts/evalJson.py /gpfs1/work/weging/snakemakePipeline/content.txt /gpfs1/work/weging/snakemakePipeline/content_negative.txt /gpfs1/work/weging/snakemakePipeline/results/kASA_merged_0.jsonl ${path}results/kASA_merged_0_result_${i}.txt $i &
	python ${path}scripts/evalJson.py /gpfs1/work/weging/snakemakePipeline/content.txt /gpfs1/work/weging/snakemakePipeline/content_negative.txt /gpfs1/work/weging/snakemakePipeline/results/kASA_merged_10.jsonl ${path}results/kASA_merged_10_result_${i}.txt $i &
done
wait
