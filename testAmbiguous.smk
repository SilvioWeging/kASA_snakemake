configfile: "snake_ambig_config.json"

def tools():
	listOfTools = []
	if config["KrakenUniqPath"] != "":
		listOfTools.append(config["path"] + "done/krakenuniq_eval.done")
	if config["kASA"] != "":
		listOfTools.append(config["path"] + "done/kASA_eval.done")
	return listOfTools

rule all:
	input:	*tools()

rule createAllFolders:
	output:
		touch(config["path"]+"done/folders.done")
	shell:
		"""
		mkdir -p {config[path]}results
		mkdir -p {config[path]}temporary
		mkdir -p {config[path]}fastqs
		mkdir -p {config[path]}genomes
		mkdir -p {config[path]}index
		mkdir -p {config[path]}index/taxonomy
		mkdir -p {config[path]}done
		"""

rule downloadGenome:
	input:
		infolder= config["path"]+"done/folders.done"
	output:
		touch(config["path"]+"done/download.done")
	run:
		contentFile = open(config["content"])
		for line in contentFile:
			line = line.rstrip("\r\n")
			if line == "":
				continue
			accnrs = (line.split("\t"))[3]
			for accnr in accnrs.split(";"):
				if accnr != "":
					outfileForGenome = open(config["path"]+"genomes/" + accnr + ".fasta", 'wb')
					callToNCBI = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=" + accnr + "&rettype=fasta&retmode=text"
					outfileForGenome.write((urllib.request.urlopen(callToNCBI)).read())#genome
					outfileForGenome.close()

rule downloadTaxData:
	input:
		folder = config["path"]+"done/folders.done"
	output:
		touch(config["path"]+"done/downloadTaxData.done")
	shell:
		"""
		cd {config[path]}index/taxonomy
		wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
		if [ -s taxdump.tar.gz ]; then
			tar -zxf taxdump.tar.gz
		else
			echo "Download of taxonomy data failed"
			exit 1
		fi
		python {config[path]}scripts/contentFileToAcc2Tax.py {config[content]} {config[path]}index/taxonomy/custom.accession2taxid
		"""

rule mutateAndGenerateFastq:
	input:
		fastasDone = config["path"]+"done/download.done"
	output:
		touch(config["path"]+"done/fastqs.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}genomes/*
		do
			temp=${{file#${{path}}genomes/}}
			filename=${{temp%.fasta}}
			python ${{path}}scripts/fastaToFastqRandomMutate.py -i ${{file}} -o ${{path}}fastqs/${{filename}}.fastq -m {config[mutationProbability]}
		done
		"""
largeFastqFlag = False

if config["kASA"] != "":
	include: config["path"] + "rules/kASA.smk"

if config["KrakenUniqPath"] != "":
	include: config["path"] + "rules/krakenU.smk"