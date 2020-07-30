####################### metacache ############################
rule metacache_build:
	input:
		db = config["path"] + "done/download.done",
		tax = config["path"]+"done/downloadTaxData.done"
	output:
		touch(config["path"] + "done/metacache_build.done")
	benchmark:
		config["path"] + "benchmarks/metacache_build.txt"
	shell:
		"""
		mkdir -p {config[path]}index/metacache
		
		for file in {config[path]}genomes/*
		do
			cat $file >> {config[path]}merged_metacache.fasta
		done
		
		{config[metacachePath]}metacache build {config[path]}index/metacache/index {config[path]}merged_metacache.fasta -taxonomy {config[path]}index/taxonomy/
		"""

rule metacache_identify:
	input:
		indexDone = config["path"] + "done/metacache_build.done",
		fastqsDone = config["path"]+"done/fastqs.done"
	output:
		touch(config["path"] + "done/metacache_identify.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/metacache_identify.txt"
	shell:
		"""
		path={config[path]}
		{config[metacachePath]}metacache query ${{path}}index/metacache/index ${{path}}fastqs/ -lowest species -highest species -taxids -threads {threads} -split-out ${{path}}results/metacache
		"""

rule evalmetacache:
	input:
		config["path"] + "done/metacache_identify.done"
	output:
		touch(config["path"] + "done/metacache_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/metacache_*.txt
		do
			temp=${{file#${{path}}results/}}
			filename=${{temp%.txt}}
			python ${{path}}scripts/evalMetaCache.py {config[content]} {config[contentNegative]} {config[path]}index/taxonomy/nodes.dmp ${{file}} ${{path}}results/${{filename}}_result.txt
		done
		"""