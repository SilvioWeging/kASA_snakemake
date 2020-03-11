import sys, getopt, os, random

def testIfStringIsValid(bases):
	numOfNs = bases.count('N')
	if numOfNs <= len(bases)*0.1:
		return True
	return False
	

def mutateSequence(bases, mutationprob, readLength):
	basesArray = {}
	basesArray["A"] = ["C","G","T", "", "AA", "AG", "AT", "AC"]
	basesArray["C"] = ["A","G","T", "", "CA", "CG", "CT", "CC"]
	basesArray["G"] = ["A","C","T", "", "GA", "GG", "GT", "GC"]
	basesArray["T"] = ["A","C","G", "", "TA", "TG", "TT", "TC"]
	lengthOfLS = len(bases)
	numOfMutations = int(float(lengthOfLS)/readLength * mutationprob)
	randIndices = random.sample(range(lengthOfLS), numOfMutations)
	sorted(randIndices)
	
	for index in randIndices:
		base = bases[index].upper()
		if base != 'C' or base != 'A' or base != 'T' or base != 'G':
			bases = bases[:index] + 'N' + bases[(index+1):]
		else:
			randBase = basesArray[base][(random.sample(range(3), 1))[0]]
			bases = bases[:index] + randBase + bases[(index+1):]
	return bases


def generateReads(fastqFile, numberOfReads, name, bases, mutationprob, readLength):
	lengthOfLS = len(bases)
	windowSize = readLength
	if numberOfReads == 0:
		numberOfReads = lengthOfLS / windowSize
	
	name = name.split(" ")
	counter = 0
	while counter < numberOfReads:
		randIndex = random.randrange(lengthOfLS-windowSize)
		chunk = bases[randIndex:randIndex+windowSize]
		if testIfStringIsValid(chunk):
			accAndCounter = name[0] + ";" + str(counter)
			concatName = accAndCounter + " "
			for i in range(1,len(name)):
				concatName += name[i] + " "
			fastqFile.write('@' + concatName + '\n')
			if mutationprob > 0.0:
				chunk = mutateSequence(chunk, mutationprob, readLength)
			fastqFile.write(chunk)
			fastqFile.write('\n' + '+' + '\n')
			for i in range(0,len(chunk)):
				fastqFile.write("I")
			fastqFile.write('\n')
			counter += 1

def fastaToFastqRandomMutate(argv):
	
	random.seed(100)
	
	fastaFile = ''
	fastqFile = ''
	numberOfReads = 0
	mutationprob = 0.01
	readLength = 100
	
	try:
		opts, args = getopt.getopt(argv, "i:o:n:m:r:", [])
	except getopt.GetoptError:
		sys.exit(2)
	
	for opt, arg in opts:
		if opt in ("-i",):
			fastaFile = open(arg)
		elif opt in ("-o",):
			fastqFile = open(arg, 'w')
		elif opt in ("-n",):
			numberOfReads = int(arg)
		elif opt in ("-m",):
			mutationprob = float(arg)
		elif opt in ("-r",):
			readLength = int(arg)

	name = ""
	bases = ""
	line = next(fastaFile)
	
	while True:
		try:
			while '>' not in line and line.rstrip('\r\n') != "": # get DNA
				line = line.rstrip('\r\n')
				bases += line
				line = next(fastaFile)
			line = line.rstrip('\r\n')
			if line == "":
				line = next(fastaFile)
				continue
			if '>' in line:
				line = line.lstrip('>')
				# write into fastq
				if len(bases) > readLength and testIfStringIsValid(bases):
					generateReads(fastqFile, numberOfReads, line, bases, mutationprob, readLength)
				
				name = line
				bases = ""
				line = ""#next(fastaFile)
				continue
				
		except:
			break # file is empty

	if len(bases) > readLength and testIfStringIsValid(bases):
		generateReads(fastqFile, numberOfReads, name, bases, mutationprob, readLength)
	

#end of fastaToFastq

fastaToFastqRandomMutate(sys.argv[1:])
