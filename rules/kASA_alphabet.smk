####################### kASA different alphabets ############################

appendToFileName = ""
if largeFastqFlag:
	appendToFileName = "merged.jsonl"

rule createIndex_alphabet:
	input:
		contentFile = config["content"],
		genomesAreReady = config["path"]+"done/download.done"
	output:
		index = config["path"]+"index/kASA/index_27",
		kASAFinished = touch(config["path"]+"done/kASA_index_27.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_build_27.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		mkdir -p {config[path]}index/kASA
		{config[kASA]} build -c {input.contentFile} -d {config[path]}index/kASA/index_27 -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -a {config[path]}table.prt 27,3 -m {params.ram} {config[kASAParameters]} -x 2
		"""

rule identify_alphabet:
	input:
		contentFile = config["content"],
		index = config["path"]+"index/kASA/index_27",
		indexDone = config["path"]+"done/kASA_index_27.done",
		largeFastq = config["path"]+"done/fastqs.done"
	output:
		touch(config["path"]+"done/kASA_identification_27.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_identify_27.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		{config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-a27_{appendToFileName} -t {config[path]}temporary/ -a {config[path]}table.prt 27,3 -n {threads} -m {params.ram} -r -x 2 {config[kASAParameters]}
		"""

rule createIndex_alphabet16:
	input:
		contentFile = config["content"],
		genomesAreReady = config["path"]+"done/download.done"
	output:
		index = config["path"]+"index/kASA/index_16",
		kASAFinished = touch(config["path"]+"done/kASA_index_16.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_build_16.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		mkdir -p {config[path]}index/kASA
		{config[kASA]} build -c {input.contentFile} -d {config[path]}index/kASA/index_16 -i {config[path]}genomes/ -t {config[path]}temporary/ -n {threads} -a {config[path]}table.prt 16,1 -m {params.ram} {config[kASAParameters]} -x 3
		"""

rule identify_alphabet16:
	input:
		contentFile = config["content"],
		index = config["path"]+"index/kASA/index_16",
		indexDone = config["path"]+"done/kASA_index_16.done",
		largeFastq = config["path"]+"done/fastqs.done"
	output:
		touch(config["path"]+"done/kASA_identification_16.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_identify_16.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		{config[kASA]} identify_multiple -c {input.contentFile} -d {input.index} -i {config[path]}fastqs/ -q {config[path]}results/kASA-a16_{appendToFileName} -t {config[path]}temporary/ -a {config[path]}table.prt 16,1 -n {threads} -m {params.ram} -r -x 3 {config[kASAParameters]}
		"""

rule evalkASA_alphabet:
	input:
		result2 = config["path"]+"done/kASA_identification_27.done",
		result4 = config["path"]+"done/kASA_identification_16.done",
	output:
		touch(config["path"]+"done/kASA_eval_alphabets.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/kASA-a*.jsonl
		do
			temp=${{file#${{path}}results/}}
			filename=${{temp%.jsonl}}
			python ${{path}}scripts/evalJson.py {config[content]} {config[contentNegative]} ${{file}} ${{path}}results/${{filename}}_result.txt &
		done
		wait
		"""
