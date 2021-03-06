configfile: "snake_ig_g_config.json"


def tools():
	listOfTools = []
	#if config["Kraken2Path"] != "":
		#listOfTools.append(config["path"] + "done/kraken2_eval.done")
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
		mkdir -p {config[path]}genomes
		mkdir -p {config[path]}gffs
		mkdir -p {config[path]}index
		mkdir -p {config[path]}index/taxonomy
		mkdir -p {config[path]}done
		mkdir -p {config[path]}fastqs
		"""

rule downloadGenomeAndGffs:
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
					
					callToWget =  "\"https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?db=nuccore&report=gff3&id=" + accnr + "\"" #eutils doesn't offer gff3 format output
					callToShell = "if [[ `wget -S --spider " + callToWget + " 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then wget -nc -O " + config["path"]+"gffs/" + accnr + ".gff " + callToWget + "; fi"
					shell(callToShell)#gff

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

rule divideInGenicAndIntergenic:
	input:
		downloadDone = config["path"]+"done/download.done"
	output:
		touch(config["path"]+"done/division.done")
	shell:
		"""
			path={config[path]}
			for file in ${{path}}genomes/*
			do
				temp=${{file#${{path}}genomes/}}
				filename=${{temp%.fasta}}
				python ${{path}}scripts/getIntergenicRegion.py $file ${{path}}gffs/${{filename}}.gff ${{path}}temporary/${{filename}}
			done
		"""

rule catEverythingTogether:
	input:
		divisionDone = config["path"]+"done/division.done"
	output:
		largeFasta = config["path"]+"merged.fasta"
	shell:
		"""
		for file in {config[path]}temporary/*
		do
			cat $file >> {config[path]}merged.fasta
		done
		"""

rule mutateAndGenerateFastq:
	input:
		largeFasta = config["path"]+"merged.fasta"
	output:
		largeFastq = config["path"]+"fastqs/merged.fastq",
		fqdone = touch(config["path"]+"done/fastqs.done")
	shell:
		"python {config[path]}scripts/fastaToFastqRandomMutate.py -i {input.largeFasta} -o {output.largeFastq} -m {config[mutationProbability]}"

largeFastqFlag=True

if config["kASA"] != "":
	include: config["path"] + "rules/kASA_ig_g.smk"

#if config["Kraken2Path"] != "":
	#include: config["path"] + "rules/kraken2.smk"
