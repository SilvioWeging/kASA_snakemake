import sys, math

contentfile = open(sys.argv[1])
contentFile_negative = ""
if sys.argv[2] != "_":
	contentFile_negative = open(sys.argv[2]) 
nodesFile = open(sys.argv[3])
MetaCacheInput = open(sys.argv[4])
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

sensitivity = 0.0
specificity = 0.0
numberOfReads = 0
numberOfNegReads = 0
numberOfAssigned = 0
ambigCounter = 0

mapHigherTaxIdsToSpecies = {}

def recursiveAdding(acc, nD, tax, specTaxID):
	if tax in nD and tax != "1":
		entry = nD[tax]
		mapHigherTaxIdsToSpecies[acc][entry] = specTaxID
		recursiveAdding(acc, nD,entry, specTaxID)
	else:
		mapHigherTaxIdsToSpecies[acc][tax] = specTaxID

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
	mapHigherTaxIdsToSpecies[acc] = {}
	mapHigherTaxIdsToSpecies[acc][genusTax] = specTax
	recursiveAdding(acc, nodesDict, genusTax, specTax)
	mapHigherTaxIdsToSpecies[acc][specTax] = specTax

for entry in MetaCacheInput:
	entry = entry.rstrip("\r\n")
	if entry == "" or '#' in entry or "None of the input" in entry:
		continue
	entry = entry.split("\t")
	name = ((entry[0]).split(";"))[0]
	origTax = accToTax[name] if name in accToTax else ""
	matched = ""
	if entry[2] != "--":
		matched = ((entry[2].split('('))[1]).rstrip(")")
	numberOfReads += 1
	
	
	if origTax != "":
		if matched != "": #something was hit
			numberOfAssigned += 1
			if matched == origTax: #the correct taxon was hit on the correct level
				sensitivity += 1
				confusionMatrixPerSpecies[matched][0] += 1
				for spec in confusionMatrixPerSpecies:
					if spec != origTax:
						confusionMatrixPerSpecies[spec][1] += 1
			else:
				if matched in mapHigherTaxIdsToSpecies[name]:
					if mapHigherTaxIdsToSpecies[name][matched] == origTax: #the correct taxon is in the tax path
						ambigCounter += 1
						metaTaxon = mapHigherTaxIdsToSpecies[name][matched]
						#print("correct tax path: ", entry)
						sensitivity += 1
						confusionMatrixPerSpecies[metaTaxon][0] += 1
						for acc in accToTax:
							if acc != name:
								if matched in mapHigherTaxIdsToSpecies[acc]: #but everything else inside this tax path is a FP
									confusionMatrixPerSpecies[accToTax[acc]][2] += 1
									#print("FP:", accToTax[acc])
								else:
									confusionMatrixPerSpecies[accToTax[acc]][1] += 1 #or a TN if it is not inside this path
									#print("TN:", accToTax[acc])
					else: #the tax path is wrong, thus everything inside it is a FP
						#print("incorrect tax path: ", entry)
						for acc in accToTax:
							if matched in mapHigherTaxIdsToSpecies[acc]:
								confusionMatrixPerSpecies[accToTax[acc]][2] += 1
							else: #and everything outside of it a TN
								confusionMatrixPerSpecies[accToTax[acc]][1] += 1
						confusionMatrixPerSpecies[origTax][3] += 1 #since the read was not correctly assigned
				else: # not matched, thus the matched taxon is a FP and the expected one gets a FN
					#print("not matched: ", entry)
					metaTaxon = ""
					for elem in mapHigherTaxIdsToSpecies: # get corresponding tax id from the content file
						if matched in mapHigherTaxIdsToSpecies[elem]:
							metaTaxon = mapHigherTaxIdsToSpecies[elem][matched]
							break
					confusionMatrixPerSpecies[metaTaxon][2] += 1
					confusionMatrixPerSpecies[origTax][3] += 1
					for spec in confusionMatrixPerSpecies:
						if spec != origTax and spec != metaTaxon: #everything else is a TN
							confusionMatrixPerSpecies[spec][1] += 1
		else:
			#not assigned, thus only FNs and TNs
			confusionMatrixPerSpecies[origTax][3] += 1
			for spec in confusionMatrixPerSpecies:
				if spec != origTax:
					confusionMatrixPerSpecies[spec][1] += 1
	else:
		if name in negatives:
			numberOfNegReads += 1
			if matched == "":
				specificity += 1
				for spec in confusionMatrixPerSpecies:
					confusionMatrixPerSpecies[spec][1] += 1
			else:
				metaTaxon = matched
				for elem in mapHigherTaxIdsToSpecies: # get corresponding tax id from the content file
					if matched in mapHigherTaxIdsToSpecies[elem]:
						metaTaxon = mapHigherTaxIdsToSpecies[elem][matched]
						break
				#print(entry)
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