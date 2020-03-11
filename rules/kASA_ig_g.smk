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
		"{config[kASA]} identify -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r -v"

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
			python ${{path}}scripts/evalJson_ig_g.py {config[content]} ${{file}}  ${{path}}results/${{filename}}_result.txt &
		done
		wait
		"""
