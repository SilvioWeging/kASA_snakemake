####################### kASA ############################

appendToFileName = ""
if largeFastqFlag:
	appendToFileName = "merged.json"

rule createIndex:
	input:
		contentFile = config["content"],
		genomesAreReady = config["path"]+"done/download.done"
	output:
		index = config["path"]+"index/kASA/index",
		kASAFinished = touch(config["path"]+"done/kASA_index.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_build.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		mkdir -p {config[path]}index/kASA
		{config[kASA]} build -c {input.contentFile} -d {output.index} -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -m {params.ram}
		"""

# rule identify:
	# input:
		# contentFile = config["content"],
		# index = config["path"]+"index/kASA/index",
		# indexDone = config["path"]+"done/kASA_index.done",
		# largeFastq = config["path"]+"done/fastqs.done"
	# output:
		# touch(config["path"]+"done/kASA_identification.done")
	# threads: config["threads"]
	# benchmark:
		# config["path"] + "benchmarks/kASA_identify.txt"
	# params:
		# ram = config["ram"]
	# shell:
		# """
		# (/usr/bin/time {config[kASA]} identify -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA_7_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 12 7) &>> {config[path]}/benchmarks/kASA_7.txt
		# (/usr/bin/time {config[kASA]} identify -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA_8_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 12 8) &>> {config[path]}/benchmarks/kASA_8.txt
		# (/usr/bin/time {config[kASA]} identify -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA_9_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 12 9) &>> {config[path]}/benchmarks/kASA_9.txt
		# (/usr/bin/time {config[kASA]} identify -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA_10_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 12 10) &>> {config[path]}/benchmarks/kASA_10.txt
		# (/usr/bin/time {config[kASA]} identify -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA_11_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 12 11) &>> {config[path]}/benchmarks/kASA_11.txt
		# (/usr/bin/time {config[kASA]} identify -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA_12_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -k 12 12) &>> {config[path]}/benchmarks/kASA_12.txt
		# """

rule identify:
	input:
		contentFile = config["content"],
		index = config["path"]+"index/kASA/index",
		indexDone = config["path"]+"done/kASA_index.done",
		largeFastq = config["path"]+"done/fastqs.done"
	output:
		touch(config["path"]+"done/kASA_identification.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_identify.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		{config[kASA]} identify -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r {config[kASAParameters]}
		"""

rule computeSensAndPrec:
	input:
		result = config["path"]+"done/kASA_identification.done"
	output:
		touch(config["path"]+"done/kASA_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/kASA_*.json
		do
			temp=${{file#${{path}}results/}}
			filename=${{temp%.json}}
			python ${{path}}scripts/evalJson.py {config[content]} {config[contentNegative]} ${{file}} ${{path}}results/${{filename}}_result.txt &
		done
		wait
		"""
