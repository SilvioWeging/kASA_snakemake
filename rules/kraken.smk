####################### kraken ############################
rule kraken_build:
	input:
		db = config["path"] + "done/download.done",
		tax = config["path"]+"done/downloadTaxData.done"
	output:
		touch(config["path"] + "done/kraken_build.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kraken_build.txt"
	shell:
		"""
		mkdir -p {config[path]}index/kraken
		ln -fs {config[path]}index/taxonomy/ {config[path]}index/kraken/taxonomy
		
		for file in {config[path]}genomes/*
		do
			{config[KrakenPath]}kraken-build --add-to-library ${{file}} --db {config[path]}index/kraken
		done
		
		{config[KrakenPath]}kraken-build --build --db {config[path]}index/kraken --threads {threads}
		"""

rule kraken_identify:
	input:
		indexDone = config["path"] + "done/kraken_build.done",
		fastqsDone = config["path"]+"done/fastqs.done"
	output:
		touch(config["path"] + "done/kraken_identify.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kraken_identify.txt"
	shell:
		"""
		path={config[path]}
		for file in ${{path}}fastqs/*
		do
			temp=${{file#${{path}}fastqs/}}
			filename=${{temp%.fastq}}
			{config[KrakenPath]}kraken --db ${{path}}index/kraken --threads {threads} --preload --output ${{path}}results/kraken_${{filename}}.tsv ${{file}}
		done
		"""

rule evalkraken:
	input:
		config["path"] + "done/kraken_identify.done"
	output:
		touch(config["path"] + "done/kraken_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/kraken_*.tsv
		do
			temp=${{file#${{path}}results/}}
			filename=${{temp%.tsv}}
			python ${{path}}scripts/evalKrakenU.py {config[content]} {config[contentNegative]} {config[path]}index/taxonomy/nodes.dmp ${{file}} ${{path}}results/${{filename}}_result.txt
		done
		"""