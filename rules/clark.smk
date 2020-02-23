####################### Clark ############################
rule clark_buildAndIdentify:
	input:
		db = config["path"] + "done/download.done",
		fastqsDone = config["path"]+"done/fastqs.done",
		taxonomy = config["path"]+"done/downloadTaxData.done"
	output:
		touch(config["path"] + "done/clark.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/clark_buildAndIdentify.txt"
	shell:
		"""
		mkdir -p {config[path]}index/clark
		mkdir -p {config[path]}index/clark/Custom
		cp {config[path]}index/taxonomy/custom.accession2taxid {config[path]}index/taxonomy/nucl_accss
		touch {config[path]}index/clark/.taxondata
		ln -sf {config[path]}index/taxonomy/ {config[path]}index/clark/taxonomy
		
		for file in {config[path]}genomes/*
		do
			cp ${{file}} {config[path]}index/clark/Custom/
		done
		{config[ClarkPath]}set_targets.sh {config[path]}index/clark custom --species
		
		path={config[path]}
		for file in ${{path}}fastqs/*
		do
			temp=${{file#${{path}}fastqs/}}
			filename=${{temp%.fastq}}
			{config[ClarkPath]}classify_metagenome.sh -O ${{file}} -n {threads} -R ${{path}}results/Clark_${{filename}}
		done
		"""

rule evalclark:
	input:
		config["path"] + "done/clark.done"
	output:
		touch(config["path"] + "done/clark_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/Clark_*.csv
		do
			temp=${{file#${{path}}results/}}
			filename=${{temp%.csv}}
			python ${{path}}scripts/evalClark.py {config[content]} ${{file}} ${{path}}results/${{filename}}_result.txt
		done
		"""