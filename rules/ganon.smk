####################### ganon ############################
rule ganon_build:
	input:
		db = config["path"] + "done/download.done",
		tax = config["path"]+"done/downloadTaxData.done"
	output:
		touch(config["path"] + "done/ganon_build.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/ganon_build.txt"
	shell:
		"""
		mkdir -p {config[path]}index/ganon
		export PATH=/gpfs1/data/idiv_gogoldoe/weging/ganon/bin:$PATH
		{config[ganonPath]}ganon build --db-prefix {config[path]}index/ganon/ganon --threads {threads} --input-files {config[path]}genomes/* --taxdump-file {config[path]}index/taxonomy/nodes.dmp {config[path]}index/taxonomy/names.dmp {config[path]}index/taxonomy/merged.dmp
		"""

rule ganon_identify:
	input:
		indexDone = config["path"] + "done/ganon_build.done",
		fastqsDone = config["path"]+"done/fastqs.done"
	output:
		touch(config["path"] + "done/ganon_identify.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/ganon_identify.txt"
	shell:
		"""
		export PATH=/gpfs1/data/idiv_gogoldoe/weging/ganon/bin:$PATH
		path={config[path]}
		for file in ${{path}}fastqs/*
		do
			temp=${{file#${{path}}fastqs/}}
			filename=${{temp%.fastq}}
			{config[ganonPath]}ganon classify --db-prefix ${{path}}index/ganon/ganon --threads {threads} -o ${{path}}results/ganon_${{filename}} --output-all --single-reads ${{file}} -n
		done
		"""

rule evalganon:
	input:
		config["path"] + "done/ganon_identify.done"
	output:
		touch(config["path"] + "done/ganon_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/ganon_*.all
		do
			temp=${{file#${{path}}results/}}
			filename=${{temp%.all}}
			python ${{path}}scripts/evalGanon.py {config[content]} {config[contentNegative]} {config[path]}index/taxonomy/nodes.dmp ${{file}} ${{path}}results/${{filename}}.unc ${{path}}results/${{filename}}_result.txt
		done
		"""