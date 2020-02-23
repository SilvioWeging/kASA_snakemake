import sys

contentfile = open(sys.argv[1])
ClarkInput = open(sys.argv[2])
resultfile = open(sys.argv[3], 'w')

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
#ambigCounter = 0

next(ClarkInput)
for entry in ClarkInput:
	entry = entry.rstrip("\r\n")
	if entry == "":
		break
	entry = entry.split(",")
	name = entry[0]
	origTax = accToTax[name]
	matched = entry[2]
	#ambig = False
	correct = False
	assigned = True
	if matched != "NA":
		if matched == origTax:
			correct = True
	else:
		assigned = False
		
	sensitivity += 1 if correct else 0
	#ambigCounter += 1 if ambig else 0
	numberOfAssigned += 1 if assigned else 0
	numberOfReads += 1

#numberOfReads -= ambigCounter
truePositives = sensitivity
falsePositives = numberOfAssigned - sensitivity

if numberOfReads > 0:
	precision = sensitivity / numberOfAssigned
	sensitivity = sensitivity / numberOfReads

resultfile.write("Result:\nSensitivity: " + str(sensitivity) + "\nPrecision: " + str(precision) +"\nTrue positives: " + str(truePositives) + "\nFalse positives: " + str(falsePositives) + "\nNumber of Reads: " + str(numberOfReads) + "\n")
