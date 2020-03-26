import sys, json

contentfile = open(sys.argv[1])
kASAInput = open(sys.argv[2])
resultfile = open(sys.argv[3], 'w')

accToTax = {}
for line in contentfile:
	line = line.rstrip("\r\n")
	if line != "":
		line = line.split("\t")
		accToTax[line[3]] = line[1]



sensitivity_ig = 0.0
precision_ig = 0.0
numberOfReads_ig = 0
numberOfAssigned_ig = 0
ambig_ig = 0
sensitivity_g = 0.0
precision_g = 0.0
numberOfReads_g = 0
numberOfAssigned_g = 0
ambig_g = 0


for line in kASAInput:
	entry = json.loads(line)
	name = (entry["Specifier from input file"]).split(" ")
	name[0] = ((name[0]).split(";"))[0]
	origTax = accToTax[name[0]] if name[0] in accToTax else ""
	igOrG = name[2] == "genic"
	matched = entry["Top hits"]
	ambig = False
	correct = False
	assigned = True
	if origTax != "":
		if len(matched) >= 2:
			ambig = True
			for elem in matched:
				if elem["tax ID"] == origTax:
					correct = True
					break
		elif len(matched) == 1:
			if matched[0]["tax ID"] == origTax:
				correct = True
		else:
			assigned = False
	
	#if assigned and not correct and not ambig:
		#print(entry["Specifier from input file"], entry["Top hits"], entry["Further hits"])
	
	if igOrG:
		sensitivity_g += 1 if correct else 0
		ambig_g += 1 if ambig else 0
		numberOfAssigned_g += 1 if assigned else 0
		numberOfReads_g += 1
	else:
		sensitivity_ig += 1 if correct else 0
		ambig_ig += 1 if ambig else 0
		numberOfAssigned_ig += 1 if assigned else 0
		numberOfReads_ig += 1

truePositives_g = sensitivity_g
falsePositives_g = numberOfAssigned_g - sensitivity_g
truePositives_ig = sensitivity_ig
falsePositives_ig = numberOfAssigned_ig - sensitivity_ig


if numberOfReads_g > 0 and numberOfAssigned_g > 0:
	precision_g = sensitivity_g / numberOfAssigned_g
	sensitivity_g = sensitivity_g / numberOfReads_g
if numberOfReads_ig > 0 and numberOfAssigned_ig > 0:
	precision_ig = sensitivity_ig / numberOfAssigned_ig
	sensitivity_ig = sensitivity_ig / numberOfReads_ig

resultfile.write("Genic:\nSensitivity: " + str(sensitivity_g) + "\nPrecision: " + str(precision_g) + "\nTrue positives: " + str(truePositives_g) + "\nFalse positives: " + str(falsePositives_g) + "\nAmbiguous Reads: " + str(ambig_g) + "\nNumber of Reads(unamb.): " + str(numberOfReads_g) + "\n\nIntergenic:\nSensitivity " + str(sensitivity_ig) + "\nPrecision: " + str(precision_ig) + "\nTrue positives: " + str(truePositives_ig) + "\nFalse positives: " + str(falsePositives_ig)  + "\nAmbiguous Reads: " + str(ambig_ig) + "\nNumber of Reads(unamb.): " + str(numberOfReads_ig) + "\n")
