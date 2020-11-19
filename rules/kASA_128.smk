####################### kASA 128 bit, k->25 ############################

appendToFileName = ""
if largeFastqFlag:
	appendToFileName = "merged.jsonl"

rule createIndex_128:
	input:
		contentFile = config["content"],
		genomesAreReady = config["path"]+"done/download.done"
	output:
		index = config["path"]+"index/kASA/index_128",
		kASAFinished = touch(config["path"]+"done/kASA_128_index.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_build_128.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		{config[kASA]} build -c {input.contentFile} -d {config[path]}index/kASA/index_128 -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -m {params.ram} {config[kASAParameters]} --kH 25 -x 128
		"""

rule identify_k:
	input:
		contentFile = config["content"],
		index = config["path"]+"index/kASA/index_128",
		indexDone = config["path"]+"done/kASA_128_index.done",
		largeFastq = config["path"]+"done/fastqs.done"
	output:
		touch(config["path"]+"done/kASA_128_identification_k.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_128_identify_multiple.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_1_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 1 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_1.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_2_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 2 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_2.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_3_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 3 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_3.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_4_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 4 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_4.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_5_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 5 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_5.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_6_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 6 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_6.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_7_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 7 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_7.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_8_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 8 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_8.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_9_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 9 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_9.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_10_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 10 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_10.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_11_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 11 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_11.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_12_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 12 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_12.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_13_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 13 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_13.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_14_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 14 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_14.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_15_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 15 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_15.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_16_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 16 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_16.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_17_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 17 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_17.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_18_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 18 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_18.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_19_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 19 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_19.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_20_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 20 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_20.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_21_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 21 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_21.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_22_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 22 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_22.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_23_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 23 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_23.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_24_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 24 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_24.txt
		(/usr/bin/time {config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-128_25_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 25 25 -x 128 {config[kASAParameters]}) &>> {config[path]}/benchmarks/kASA-128_25.txt
		"""

rule evalkASA_128:
	input:
		result1 = config["path"]+"done/kASA_128_identification_k.done"
	output:
		touch(config["path"]+"done/kASA_128_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/kASA-128_*.jsonl
		do
			temp=${{file#${{path}}results/}}
			filename=${{temp%.jsonl}}
			python ${{path}}scripts/evalJson.py {config[content]} {config[contentNegative]} ${{file}} ${{path}}results/${{filename}}_result.txt &
		done
		wait
		"""