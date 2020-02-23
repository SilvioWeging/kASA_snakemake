####################### Kraken2 ############################
rule kraken2_build:
	input:
		db = config["path"] + "done/download.done",
		taxonomyFiles = config["path"]+"done/downloadTaxData.done"
	output:
		touch(config["path"] + "done/kraken2_build.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kraken2_build.txt"
	shell:
		"""
		mkdir -p {config[path]}index/Kraken2
		ln -fs {config[path]}index/taxonomy {config[path]}index/Kraken2/taxonomy
		
		for file in {config[path]}genomes/*
		do
			{config[Kraken2Path]}kraken2-build --add-to-library ${{file}} --db {config[path]}index/Kraken2 --no-masking
		done
		
		{config[Kraken2Path]}kraken2-build --build --db {config[path]}index/Kraken2 --threads 1 --no-masking --max-db-size {config[Kraken2MaxDBSize]}
		"""

rule kraken2_identify:
	input:
		indexDone = config["path"] + "done/kraken2_build.done",
		fastqsDone = config["path"]+"done/fastqs.done"
	output:
		touch(config["path"] + "done/kraken2_identify.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kraken2_identify.txt"
	shell:
		"""
		path={config[path]}
		for file in ${{path}}fastqs/*
		do
			temp=${{file#${{path}}fastqs/}}
			filename=${{temp%.fastq}}
			{config[Kraken2Path]}kraken2 --db ${{path}}index/Kraken2 --threads 1 --output ${{path}}results/Kraken2_${{filename}}.tsv ${{file}}
		done
		"""

rule evalKraken2:
	input:
		config["path"] + "done/kraken2_identify.done"
	output:
		touch(config["path"] + "done/kraken2_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/Kraken2_*.tsv
		do
			temp=${{file#${{path}}results/}}
			filename=${{temp%.tsv}}
			python ${{path}}scripts/evalKrakenU.py {config[content]} ${{file}} {config[path]}index/taxonomy/nodes.dmp ${{path}}results/${{filename}}_result.txt
		done
		"""