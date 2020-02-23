####################### Centrifuge ############################
rule Centrifuge_build:
	input:
		db = config["path"] + "done/download.done",
		tax = config["path"]+"done/downloadTaxData.done",
		largeFasta = config["path"]+"merged.fasta"
	output:
		touch(config["path"] + "done/Centrifuge_build.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/Centrifuge_build.txt"
	shell:
		"""
		mkdir -p {config[path]}index/Centrifuge
		sed -n '1!p' {config[path]}index/taxonomy/custom.accession2taxid | cut -f 2,3 > {config[path]}index/taxonomy/centrifuge.acc2tax
		{config[CentrifugePath]}centrifuge-build -p {threads} --conversion-table {config[path]}index/taxonomy/centrifuge.acc2tax --taxonomy-tree {config[path]}index/taxonomy/nodes.dmp --name-table {config[path]}index/taxonomy/names.dmp {input.largeFasta} {config[path]}index/Centrifuge/Centrifuge
		"""

rule Centrifuge_identify:
	input:
		indexDone = config["path"] + "done/Centrifuge_build.done",
		fastqsDone = config["path"]+"done/fastqs.done"
	output:
		touch(config["path"] + "done/Centrifuge_identify.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/Centrifuge_identify.txt"
	shell:
		"""
		path={config[path]}
		for file in ${{path}}fastqs/*
		do
			temp=${{file#${{path}}fastqs/}}
			filename=${{temp%.fastq}}
			{config[CentrifugePath]}centrifuge -x ${{path}}index/Centrifuge/Centrifuge -p {threads} -t -q -S ${{path}}results/Centrifuge_${{filename}}.tsv -U ${{file}}
		done
		"""

rule evalCentrifuge:
	input:
		config["path"] + "done/Centrifuge_identify.done"
	output:
		touch(config["path"] + "done/Centrifuge_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/Centrifuge_*.tsv
		do
			temp=${{file#${{path}}results/}}
			filename=${{temp%.tsv}}
			python ${{path}}scripts/evalCentrifuge.py {config[content]} ${{file}} {config[path]}index/taxonomy/nodes.dmp ${{path}}results/${{filename}}_result.txt
		done
		"""