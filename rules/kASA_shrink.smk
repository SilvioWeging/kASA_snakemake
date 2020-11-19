####################### kASA shrink ############################

appendToFileName = ""
if largeFastqFlag:
	appendToFileName = "merged.jsonl"

rule shrinkCreateIndex:
	input:
		contentFile = config["content"],
		genomesAreReady = config["path"]+"done/download.done"
	output:
		kASAFinished = touch(config["path"]+"done/kASA_index_shrink.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_build_shrink.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		mkdir -p {config[path]}index/kASA
		{config[kASA]} build -c {input.contentFile} -d {config[path]}index/kASA/index_100 -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -m {params.ram} {config[kASAParameters]} -x 1
		{config[kASA]} build -c {input.contentFile} -d {config[path]}index/kASA/index_90 -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -m {params.ram} {config[kASAParameters]} -x 1 -g 10
		{config[kASA]} build -c {input.contentFile} -d {config[path]}index/kASA/index_80 -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -m {params.ram} {config[kASAParameters]} -x 1 -g 20
		{config[kASA]} build -c {input.contentFile} -d {config[path]}index/kASA/index_70 -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -m {params.ram} {config[kASAParameters]} -x 1 -g 30
		{config[kASA]} build -c {input.contentFile} -d {config[path]}index/kASA/index_60 -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -m {params.ram} {config[kASAParameters]} -x 1 -g 40
		{config[kASA]} build -c {input.contentFile} -d {config[path]}index/kASA/index_50 -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -m {params.ram} {config[kASAParameters]} -x 1 -g 50
		{config[kASA]} build -c {input.contentFile} -d {config[path]}index/kASA/index_40 -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -m {params.ram} {config[kASAParameters]} -x 1 -g 60
		{config[kASA]} build -c {input.contentFile} -d {config[path]}index/kASA/index_30 -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -m {params.ram} {config[kASAParameters]} -x 1 -g 70
		{config[kASA]} build -c {input.contentFile} -d {config[path]}index/kASA/index_20 -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -m {params.ram} {config[kASAParameters]} -x 1 -g 80
		{config[kASA]} build -c {input.contentFile} -d {config[path]}index/kASA/index_10 -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -m {params.ram} {config[kASAParameters]} -x 1 -g 90
		"""

rule shrinkIdentify:
	input:
		contentFile = config["content"],
		indexDone = config["path"]+"done/kASA_index_shrink.done",
		largeFastq = config["path"]+"done/fastqs.done"
	output:
		touch(config["path"]+"done/kASA_identification_shrink.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_identify_shrink.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		{config[kASA]} identify_multiple -c {input.contentFile} -d {config[path]}index/kASA/index_100 -i {config[path]}fastqs/ -q {config[path]}results/kASA-100_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r {config[kASAParameters]} -x 2
		{config[kASA]} identify_multiple -c {input.contentFile} -d {config[path]}index/kASA/index_90 -i {config[path]}fastqs/ -q {config[path]}results/kASA-90_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r {config[kASAParameters]} -x 2
		{config[kASA]} identify_multiple -c {input.contentFile} -d {config[path]}index/kASA/index_80 -i {config[path]}fastqs/ -q {config[path]}results/kASA-80_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r {config[kASAParameters]} -x 2
		{config[kASA]} identify_multiple -c {input.contentFile} -d {config[path]}index/kASA/index_70 -i {config[path]}fastqs/ -q {config[path]}results/kASA-70_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r {config[kASAParameters]} -x 2
		{config[kASA]} identify_multiple -c {input.contentFile} -d {config[path]}index/kASA/index_60 -i {config[path]}fastqs/ -q {config[path]}results/kASA-60_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r {config[kASAParameters]} -x 2
		{config[kASA]} identify_multiple -c {input.contentFile} -d {config[path]}index/kASA/index_50 -i {config[path]}fastqs/ -q {config[path]}results/kASA-50_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r {config[kASAParameters]} -x 2
		{config[kASA]} identify_multiple -c {input.contentFile} -d {config[path]}index/kASA/index_40 -i {config[path]}fastqs/ -q {config[path]}results/kASA-40_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r {config[kASAParameters]} -x 2
		{config[kASA]} identify_multiple -c {input.contentFile} -d {config[path]}index/kASA/index_30 -i {config[path]}fastqs/ -q {config[path]}results/kASA-30_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r {config[kASAParameters]} -x 2
		{config[kASA]} identify_multiple -c {input.contentFile} -d {config[path]}index/kASA/index_20 -i {config[path]}fastqs/ -q {config[path]}results/kASA-20_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r {config[kASAParameters]} -x 2
		{config[kASA]} identify_multiple -c {input.contentFile} -d {config[path]}index/kASA/index_10 -i {config[path]}fastqs/ -q {config[path]}results/kASA-10_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r {config[kASAParameters]} -x 2
		"""

rule shrinkEvalkASA:
	input:
		result = config["path"]+"done/kASA_identification_shrink.done"
	output:
		touch(config["path"]+"done/kASA_eval_shrink.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/kASA-*.jsonl
		do
			temp=${{file#${{path}}results/}}
			filename=${{temp%.jsonl}}
			python ${{path}}scripts/evalJson.py {config[content]} {config[contentNegative]} ${{file}} ${{path}}results/${{filename}}_result.txt &
		done
		wait
		"""