####################### kASA ############################

appendToFileName = ""
if largeFastqFlag:
	appendToFileName = "merged.jsonl"

rule createIndex_normal:
	input:
		contentFile = config["content"],
		genomesAreReady = config["path"]+"done/download.done"
	output:
		index = config["path"]+"index/kASA/index_s",
		kASAFinished = touch(config["path"]+"done/kASA_index.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_build.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		mkdir -p {config[path]}index/kASA
		{config[kASA]} build -c {input.contentFile} -d {config[path]}index/kASA/index -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -m {params.ram} {config[kASAParameters]} -x 1
		{config[kASA]} shrink -c {input.contentFile} -d  {config[path]}index/kASA/index -o {output.index} -s 2 -t {config[path]}temporary/
		rm {config[path]}index/kASA/index
		rm {config[path]}index/kASA/index_info.txt
		rm {config[path]}index/kASA/index_trie
		rm {config[path]}index/kASA/index_trie.txt
		rm {config[path]}index/kASA/index_f.txt
		"""


rule identify:
	input:
		contentFile = config["content"],
		index = config["path"]+"index/kASA/index_s",
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
		{config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA_{appendToFileName} -t {config[path]}temporary/ -n {threads} -m {params.ram} -r {config[kASAParameters]}
		"""

rule evalkASA:
	input:
		result = config["path"]+"done/kASA_identification.done",
	output:
		touch(config["path"]+"done/kASA_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/kASA_*.jsonl
		do
			temp=${{file#${{path}}results/}}
			filename=${{temp%.jsonl}}
			python ${{path}}scripts/evalJson.py {config[content]} {config[contentNegative]} ${{file}} ${{path}}results/${{filename}}_result.txt &
		done
		wait
		"""
