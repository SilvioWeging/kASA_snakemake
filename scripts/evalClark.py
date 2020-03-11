import sys, math

contentfile = open(sys.argv[1])
contentFile_negative = open(sys.argv[2]) 
nodesFile = open(sys.argv[3])
ClarkInput = open(sys.argv[4])
resultfile = open(sys.argv[5], 'w')

confusionMatrixPerSpecies = {}
accToTax = {}
for line in contentfile:
	line = line.rstrip("\r\n")
	if line != "":
		line = line.split("\t")
		accToTax[line[3]] = line[1]
		confusionMatrixPerSpecies[line[1]] = [0,0,0,0] # TP,TN,FP,FN

negatives = {}
if contentFile_negative != "":
	for line in contentFile_negative:
		line = line.rstrip("\r\n")
		if line != "":
			line = line.split("\t")
			negatives[line[3]] = line[1]

# Clark is set to species level, if we encounter a taxID higher than 'sequence' take the 'species' id instead
mapToSpecies = {}

def recursiveAdding(acc, nD, tax, specTaxID):
	if tax in nD and tax != "1":
		entry = nD[tax]
		mapToSpecies[acc][entry] = specTaxID
		recursiveAdding(acc, nD,entry, specTaxID)
	else:
		mapToSpecies[acc][tax] = specTaxID

nodesDict = {}
for line in nodesFile:
	line = line.split('|')
	taxID = ((line[0]).rstrip('\t')).lstrip('\t')
	if taxID not in nodesDict:
		nodesDict[taxID] = ((line[1]).rstrip('\t')).lstrip('\t') #next higher

nodesFile.close()

for acc in accToTax:
	specTax = accToTax[acc]
	higherTax = nodesDict[specTax]
	mapToSpecies[acc] = {}
	mapToSpecies[acc][higherTax] = specTax
	recursiveAdding(acc, nodesDict, higherTax, specTax)
	mapToSpecies[acc][specTax] = specTax


sensitivity = 0.0
specificity = 0.0
numberOfReads = 0
numberOfNegReads = 0
numberOfAssigned = 0
ambigCounter = 0


next(ClarkInput)
for entry in ClarkInput:
	entry = entry.rstrip("\r\n")
	if entry == "":
		break
	entry = entry.split(",")
	name = ((entry[0]).split(";"))[0]
	origTax = accToTax[name] if name in accToTax else ""
	matched = entry[2]
	numberOfReads += 1
	
	if origTax != "":
		if matched != "NA":
			numberOfAssigned += 1
			if matched in mapToSpecies[name]:
				matched = mapToSpecies[name][matched] #get down to the lowest level
			if matched == origTax:
				sensitivity += 1
				confusionMatrixPerSpecies[matched][0] += 1
			else:
				confusionMatrixPerSpecies[matched][2] += 1
				confusionMatrixPerSpecies[origTax][3] += 1
			for spec in confusionMatrixPerSpecies:
				if spec != origTax and spec != matched:
					confusionMatrixPerSpecies[spec][1] += 1
		else:
			#assigned == False
			confusionMatrixPerSpecies[origTax][3] += 1
			for spec in confusionMatrixPerSpecies:
				if spec != origTax:
					confusionMatrixPerSpecies[spec][1] += 1
	else:
		if name in negatives:
			numberOfNegReads += 1
			if matched == "NA":
				specificity += 1
				for spec in confusionMatrixPerSpecies:
					confusionMatrixPerSpecies[spec][1] += 1
			else:
				metaTaxon = matched
				for elem in mapToSpecies: # get corresponding tax id from the content file
					if matched in mapToSpecies[elem]:
						metaTaxon = mapToSpecies[elem][matched]
						break
				confusionMatrixPerSpecies[metaTaxon][2] += 1
				for spec in confusionMatrixPerSpecies:
					if spec != metaTaxon:
						confusionMatrixPerSpecies[spec][1] += 1

numberOfReads -= numberOfNegReads

precision = 0.0
f1 = 0.0
if numberOfReads > 0 and numberOfAssigned > 0:
	precision = sensitivity / numberOfAssigned
	sensitivity = sensitivity / numberOfReads
	f1 = 2*(sensitivity*precision)/(sensitivity+precision)

if numberOfNegReads > 0:
	specificity = specificity / numberOfNegReads

MetaMCC = 0.0
MCCs = []
for entry in confusionMatrixPerSpecies:
	TP = confusionMatrixPerSpecies[entry][0]
	TN = confusionMatrixPerSpecies[entry][1]
	FP = confusionMatrixPerSpecies[entry][2]
	FN = confusionMatrixPerSpecies[entry][3]
	#print(entry, TP, TN, FP, FN)
	MCC = 0
	if (TN > 0 or TP > 0) and (TP+FP)*(TP+FN)*(TN+FP)*(TN+FN) > 0:
		MCC = (TP*TN - FP*FN)/math.sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN))
	MetaMCC += MCC
	MCCs.append((entry,MCC))

MetaMCC = MetaMCC / len(confusionMatrixPerSpecies)


resultfile.write("Result:\nSensitivity: " + str(sensitivity) 
+ "\nPrecision: " + str(precision) 
+ "\nSpecificity: " + str(specificity) 
+ "\nF1: " + str(f1)
+ "\nMCC: "+ str(MetaMCC) 
+ "\nAmbiguous Reads: " + str(ambigCounter) 
+ "\nNumber of Reads: " + str(numberOfReads) 
+ "\nNumber of negative Reads: " + str(numberOfNegReads) 
+ "\n\n")

resultfile.write("MCCs:\n")
for entry in MCCs:
	resultfile.write(entry[0] + "\t" + str(entry[1]) + "\n")

