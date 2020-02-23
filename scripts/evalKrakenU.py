import sys

contentfile = open(sys.argv[1])
KrakenInput = open(sys.argv[2])
nodesFile = open(sys.argv[3])
resultfile = open(sys.argv[4], 'w')

accToTax = {}
for line in contentfile:
	line = line.rstrip("\r\n")
	if line != "":
		line = line.split("\t")
		accToTax[line[3]] = line[1]

sensitivity = 0.0
precision = 0.0
numberOfReads = 0
numberOfAssigned = 0
ambigCounter = 0

mapBetweenToGenus = {}

def recursiveAdding(nD, tax, specTaxID):
	if tax in nD and tax != "1":
		entry = nD[tax]
		mapBetweenToGenus[entry] = specTaxID
		recursiveAdding(nD,entry, specTaxID)
	else:
		mapBetweenToGenus[tax] = specTaxID

nodesDict = {}
for line in nodesFile:
	line = line.split('|')
	taxID = ((line[0]).rstrip('\t')).lstrip('\t')
	if taxID not in nodesDict:
		nodesDict[taxID] = ((line[1]).rstrip('\t')).lstrip('\t') #next higher

nodesFile.close()

for acc in accToTax:
	specTax = accToTax[acc]
	genusTax = nodesDict[specTax]
	mapBetweenToGenus[genusTax] = specTax
	recursiveAdding(nodesDict, genusTax, specTax)

for entry in KrakenInput:
	entry = entry.rstrip("\r\n")
	if entry == "":
		break
	entry = entry.split("\t")
	name = entry[1]
	origTax = accToTax[name]
	matched = entry[2]
	ambig = False
	correct = False
	assigned = True
	if entry[0] == "C":
		if matched == origTax:
			correct = True
		else:
			if matched in mapBetweenToGenus:
				if mapBetweenToGenus[matched] == origTax:
					ambig = True
	else:
		assigned = False
		
	sensitivity += 1 if correct else 0
	ambigCounter += 1 if ambig else 0
	numberOfAssigned += 1 if assigned else 0
	numberOfReads += 1

#numberOfReads -= ambigCounter
truePositives = sensitivity
falsePositives = numberOfAssigned - sensitivity - ambigCounter

if numberOfReads > 0:
	precision = sensitivity / numberOfAssigned
	sensitivity = sensitivity / numberOfReads

resultfile.write("Result:\nSensitivity: " + str(sensitivity) + "\nPrecision: " + str(precision) +"\nTrue positives: " + str(truePositives) + "\nFalse positives: " + str(falsePositives) + "\nAmbiguous Reads: " + str(ambigCounter) + "\nNumber of Reads: " + str(numberOfReads) + "\n")

#resultfile.write("Result:\nSensitivity: " + str(sensitivity) + "\nPrecision: " + str(precision) +"\nTrue positives: " + str(truePositives) + "\nFalse positives or abstracted taxa: " + str(falsePositives) + "\nNumber of Reads: " + str(numberOfReads) + "\n")


# import sys

# KUfile = open(sys.argv[1])

# histo = {}

# for line in KUfile:
	# line = line.split("\t")
	# if line[2] in histo:
		# histo[line[2]] += 1
	# else:
		# histo[line[2]] = 1

# outfile = open(sys.argv[2], 'w')
# for entry in histo:
	# outfile.write(entry + "\t" + str(histo[entry]) + "\n")