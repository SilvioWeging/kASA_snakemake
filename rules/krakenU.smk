####################### KrakenUniq ############################
rule krakenuniq_build:
	input:
		db = config["path"] + "done/download.done",
		tax = config["path"]+"done/downloadTaxData.done"
	output:
		touch(config["path"] + "done/krakenuniq_build.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/krakenUniq_build.txt"
	shell:
		"""
		mkdir -p {config[path]}index/krakenuniq
		mkdir -p {config[path]}index/krakenuniq/library
		ln -fs {config[path]}index/taxonomy/ {config[path]}index/krakenuniq/taxonomy
		python {config[path]}scripts/contentFileToAcc2TaxKU.py {config[content]} {config[path]}index/krakenuniq/seqid2taxid.map
		for file in {config[path]}genomes/*
		do
			cp ${{file}} {config[path]}index/krakenuniq/library/
		done
		
		{config[KrakenUniqPath]}krakenuniq-build --db {config[path]}index/krakenuniq --threads {threads}
		"""

rule krakenuniq_identify:
	input:
		indexDone = config["path"] + "done/krakenuniq_build.done",
		fastqsDone = config["path"]+"done/fastqs.done"
	output:
		touch(config["path"] + "done/krakenuniq_identify.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/krakenUniq_identify.txt"
	shell:
		"""
		path={config[path]}
		for file in ${{path}}fastqs/*
		do
			temp=${{file#${{path}}fastqs/}}
			filename=${{temp%.fastq}}
			{config[KrakenUniqPath]}krakenuniq --db ${{path}}index/krakenuniq --preload --threads {threads} --fastq-input ${{file}} > ${{path}}results/krakenuniq_${{filename}}.tsv
		done
		"""

rule evalkrakenuniq:
	input:
		config["path"] + "done/krakenuniq_identify.done"
	output:
		touch(config["path"] + "done/krakenuniq_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/krakenuniq_*.tsv
		do
			temp=${{file#${{path}}results/}}
			filename=${{temp%.tsv}}
			python ${{path}}scripts/evalKrakenU.py {config[content]} ${{file}} {config[path]}index/taxonomy/nodes.dmp ${{path}}results/${{filename}}_result.txt
		done
		"""