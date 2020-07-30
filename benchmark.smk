configfile: "snake_config.json"


def tools():
	listOfTools = []
	if config["Kraken2Path"] != "":
		listOfTools.append(config["path"] + "done/kraken2_eval.done")
	if config["kASA"] != "":
		listOfTools.append(config["path"] + "done/kASA_eval.done")
	if config["ClarkPath"] != "":
		listOfTools.append(config["path"] + "done/clark_eval.done")
	if config["KrakenPath"] != "":
		listOfTools.append(config["path"] + "done/kraken_eval.done")
	if config["CentrifugePath"] != "":
		listOfTools.append(config["path"] + "done/Centrifuge_eval.done")
	if config["KrakenUniqPath"] != "":
		listOfTools.append(config["path"] + "done/krakenuniq_eval.done")
	if config["metacachePath"] != "":
		listOfTools.append(config["path"] + "done/metacache_eval.done")
	if config["ganonPath"] != "":
		listOfTools.append(config["path"] + "done/ganon_eval.done")
	
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
		mkdir -p {config[path]}genomes
		mkdir -p {config[path]}negatives
		mkdir -p {config[path]}index
		mkdir -p {config[path]}index/taxonomy
		mkdir -p {config[path]}done
		mkdir -p {config[path]}fastqs
		"""

rule downloadTaxData:
	input:
		folder = config["path"]+"done/folders.done"
	output:
		touch(config["path"]+"done/downloadTaxData.done")
	shell:
		"""
		cd {config[path]}index/taxonomy
		wget -nc ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
		if [ -s taxdump.tar.gz ]; then
			tar -zxf taxdump.tar.gz
		else
			echo "Download of taxonomy data failed"
			exit 1
		fi
		python {config[path]}scripts/contentFileToAcc2Tax.py {config[content]} {config[path]}index/taxonomy/custom.accession2taxid
		"""

rule downloadGenome:
	input:
		infolder= config["path"]+"done/folders.done"
	output:
		touch(config["path"]+"done/download.done")
	run:
		import urllib.request
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
		contentFile = open(config["contentNegative"])
		for line in contentFile:
			line = line.rstrip("\r\n")
			if line == "":
				continue
			accnrs = (line.split("\t"))[3]
			for accnr in accnrs.split(";"):
				if accnr != "":
					outfileForGenome = open(config["path"]+"negatives/" + accnr + ".fasta", 'wb')
					callToNCBI = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=" + accnr + "&rettype=fasta&retmode=text"
					outfileForGenome.write((urllib.request.urlopen(callToNCBI)).read())#genome
					outfileForGenome.close()

rule catEverythingTogether:
	input:
		divisionDone = config["path"]+"done/download.done"
	output:
		largeFasta = config["path"]+"merged.fasta"
	shell:
		"""
		for file in {config[path]}genomes/*
		do
			cat $file >> {config[path]}merged.fasta
		done
		for file in {config[path]}negatives/*
		do
			cat $file >> {config[path]}merged.fasta
		done
		"""

rule mutateAndGenerateFastq:
	input:
		largeFasta = config["path"]+"merged.fasta"
	output:
		touch(config["path"]+"done/fastqs.done")
	shell:
		"""
		for mutVal in {config[mutationProbabilities]}
		do
			python {config[path]}scripts/fastaToFastqRandomMutate.py -i {input.largeFasta} -o {config[path]}fastqs/merged_${{mutVal}}.fastq -m ${{mutVal}} -r {config[readLength]} &
		done
		wait
		"""

largeFastqFlag=False

if config["kASA"] != "":
	include: config["path"] + "rules/kASA.smk"

if config["Kraken2Path"] != "":
	include: config["path"] + "rules/kraken2.smk"

if config["KrakenPath"] != "":
	include: config["path"] + "rules/kraken.smk"

if config["ClarkPath"] != "":
	include: config["path"] + "rules/clark.smk"

if config["CentrifugePath"] != "":
	include: config["path"] + "rules/Centrifuge.smk"

if config["KrakenUniqPath"] != "":
	include: config["path"] + "rules/krakenU.smk"

if config["metacachePath"] != "":
	include: config["path"] + "rules/metacache.smk"

if config["ganonPath"] != "":
	include: config["path"] + "rules/ganon.smk"