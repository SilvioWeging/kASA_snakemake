import sys, json, math

contentfile = open(sys.argv[1])
contentFile_negative = ""
if sys.argv[2] != "_":
	contentFile_negative = open(sys.argv[2])
kASAInput = json.load(open(sys.argv[3])) #at some point I'll have to make that in a more sophisticated way
resultfile = open(sys.argv[4], 'w')

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

for entry in kASAInput:
	name = (entry["Specifier from input file"]).split(";")
	origTax = accToTax[name[0]] if name[0] in accToTax else ""
	matched = entry["Top hits"]
	numberOfReads += 1
	
	if origTax != "":
		if len(matched) >= 2:
			matchedTaxIDs = []
			for elem in matched:
				matchedTaxIDs.append(elem["tax ID"])
			numberOfAssigned += 1
			wasHit = False
			for elem in matchedTaxIDs: # any hit taxon is either a true positive, a false positive or the expected taxon a false negative
				if elem == origTax:
					ambigCounter += 1
					sensitivity += 1
					confusionMatrixPerSpecies[elem][0] += 1
					wasHit = True
				else:
					confusionMatrixPerSpecies[elem][2] += 1
			if not wasHit:
				confusionMatrixPerSpecies[origTax][3] += 1
				#print(entry)
			for spec in confusionMatrixPerSpecies: # everything else is a true negative
				if spec != origTax and spec not in matchedTaxIDs:
					confusionMatrixPerSpecies[spec][1] += 1
		elif len(matched) == 1: # same here but without the loop
			numberOfAssigned += 1
			if matched[0]["tax ID"] == origTax:
				sensitivity += 1
				confusionMatrixPerSpecies[matched[0]["tax ID"]][0] += 1
			else:
				confusionMatrixPerSpecies[matched[0]["tax ID"]][2] += 1
				confusionMatrixPerSpecies[origTax][3] += 1
				#print(entry)
			for spec in confusionMatrixPerSpecies:
				if spec != origTax and spec != matched[0]["tax ID"]:
					confusionMatrixPerSpecies[spec][1] += 1
		else:
			#assigned == False so it's TN for everything other than the expected taxon
			confusionMatrixPerSpecies[origTax][3] += 1
			for spec in confusionMatrixPerSpecies:
				if spec != origTax:
					confusionMatrixPerSpecies[spec][1] += 1
	else:
		if name[0] in negatives:
			numberOfNegReads += 1
			if len(matched) == 0:
				specificity += 1
				for spec in confusionMatrixPerSpecies:
					confusionMatrixPerSpecies[spec][1] += 1
			else:
				matchedTaxIDs = []
				for elem in matched:
					matchedTaxIDs.append(elem["tax ID"]) # gather false positives
				for elem in matchedTaxIDs:
					confusionMatrixPerSpecies[elem][2] += 1
				for spec in confusionMatrixPerSpecies:
					if spec not in matchedTaxIDs:
						confusionMatrixPerSpecies[spec][1] += 1

numberOfReads -= numberOfNegReads # for sensitivity and precision, only the matchable reads matter

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
