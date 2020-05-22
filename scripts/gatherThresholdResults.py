import os, sys

path = sys.argv[1]
prefix = sys.argv[2]
outfilePath = sys.argv[3]

thresholds = set()

for file in os.listdir(path):
	if prefix in file:
		file = file.rstrip(".txt")
		thrsld = file[(len(prefix)):len(file)]
		thresholds.add(float(thrsld))

numberOfThreshold = len(thresholds)
resultMatrixSens = [""] * (numberOfThreshold + 1)
resultMatrixSpecificity = [""] * (numberOfThreshold + 1)

thresholds = sorted(list(thresholds))

thresholds_dict = {}
counter = 0
for entry in thresholds:
	entry = str(entry)
	thresholds_dict[entry] = counter
	counter += 1

for file in os.listdir(path):
	if prefix in file:
		fileTemp = file.rstrip(".txt")
		thrsld = fileTemp[(len(prefix)):len(file)]
		
		col = thresholds_dict[thrsld]
		
		resultFile = open(path+file)
		next(resultFile)
		resultMatrixSens[col] = (((next(resultFile)).split(" "))[1]).rstrip("\n\r")
		next(resultFile)
		resultMatrixSpecificity[col] = (((next(resultFile)).split(" "))[1]).rstrip("\n\r")

outFile = open(outfilePath, 'w')
for elem in thresholds:
	outFile.write("," + str(elem))
outFile.write("\n")
outFile.write("Sensitivity")
for i in range(len(thresholds)):
	outFile.write("," + resultMatrixSens[i])
outFile.write("\n")
outFile.write("Specificity")
for i in range(len(thresholds)):
	outFile.write("," + resultMatrixSpecificity[i])
outFile.write("\n")