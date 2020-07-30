import os, sys

path = sys.argv[1]
numberOfTools = int(sys.argv[2])
numberOfMuts = int(sys.argv[3])
outfilePath = sys.argv[4]

resultMatrixSens = [[""] * (numberOfMuts + 1) for i in range(numberOfTools + 1)]
resultMatrixPrec = [[""] * (numberOfMuts + 1) for i in range(numberOfTools + 1)]
resultMatrixSpecificity = [[""] * (numberOfMuts + 1) for i in range(numberOfTools + 1)]
resultMatrixF1 = [[""] * (numberOfMuts + 1) for i in range(numberOfTools + 1)]
resultMatrixMCC = [[""] * (numberOfMuts + 1) for i in range(numberOfTools + 1)]


toolNames = set()
mutationrates = set()

for file in os.listdir(path):
	if "result" in file:
		filenameArr = file.split("_")
		if "kASA" in filenameArr:
			#tool = filenameArr[0] + "_" + filenameArr[1]
			#mutationrate = filenameArr[3]
			tool = filenameArr[0]
			mutationrate = filenameArr[2]
		else:
			if "metacache" in filenameArr[0]:
				tool = "MetaCache"
				mutationrate = (filenameArr[2].split("."))[0]
			else:
				tool = filenameArr[0]
				mutationrate = filenameArr[2]
		
		toolNames.add(tool)
		mutationrates.add(int(mutationrate))

tools = {}
mutationrates = sorted(list(mutationrates))
mutations = {}

counter = 1
for entry in toolNames:
	tools[entry] = counter
	resultMatrixSens[counter][0] = entry
	resultMatrixPrec[counter][0] = entry
	resultMatrixSpecificity[counter][0] = entry
	resultMatrixF1[counter][0] = entry
	resultMatrixMCC[counter][0] = entry
	counter += 1
counter = 1
for entry in mutationrates:
	entry = str(entry)
	mutations[entry] = counter
	resultMatrixSens[0][counter] = entry
	resultMatrixPrec[0][counter] = entry
	resultMatrixSpecificity[0][counter] = entry
	resultMatrixF1[0][counter] = entry
	resultMatrixMCC[0][counter] = entry
	counter += 1



for file in os.listdir(path):
	if "result" in file:
		filenameArr = file.split("_")
		if "kASA" in filenameArr:
			#tool = filenameArr[0] + "_" + filenameArr[1]
			#mutationrate = filenameArr[3]
			tool = filenameArr[0]
			mutationrate = filenameArr[2]
		else:
			if "metacache" in filenameArr[0]:
				tool = "MetaCache"
				mutationrate = (filenameArr[2].split("."))[0]
			else:
				tool = filenameArr[0]
				mutationrate = filenameArr[2]
		
		row = tools[tool]
		col = mutations[mutationrate]
		
		resultFile = open(path+file)
		next(resultFile)
		resultMatrixSens[row][col] = (((next(resultFile)).split(" "))[1]).rstrip("\n\r")
		resultMatrixPrec[row][col] = (((next(resultFile)).split(" "))[1]).rstrip("\n\r")
		resultMatrixSpecificity[row][col] = (((next(resultFile)).split(" "))[1]).rstrip("\n\r")
		resultMatrixF1[row][col] = (((next(resultFile)).split(" "))[1]).rstrip("\n\r")
		resultMatrixMCC[row][col] = (((next(resultFile)).split(" "))[1]).rstrip("\n\r")
		

outfileSens = open(outfilePath + "Sensitivity.txt", 'w')
outfilePrec = open(outfilePath + "Precision.txt", 'w')
outfileSpec = open(outfilePath + "Specificity.txt", 'w')
outfileF1 = open(outfilePath + "F1.txt", 'w')
outfileMCC = open(outfilePath + "MCC.txt", 'w')
for i in range(numberOfTools + 1):
	outfileSens.write(resultMatrixSens[i][0])
	outfilePrec.write(resultMatrixPrec[i][0])
	outfileSpec.write(resultMatrixSpecificity[i][0])
	outfileF1.write(resultMatrixF1[i][0])
	outfileMCC.write(resultMatrixMCC[i][0])
	for j in range(1,numberOfMuts + 1):
		outfileSens.write("," + resultMatrixSens[i][j])
		outfilePrec.write("," + resultMatrixPrec[i][j])
		outfileSpec.write("," + resultMatrixSpecificity[i][j])
		outfileF1.write("," + resultMatrixF1[i][j])
		outfileMCC.write("," + resultMatrixMCC[i][j])
	outfileSens.write("\n")
	outfilePrec.write("\n")
	outfileSpec.write("\n")
	outfileF1.write("\n")
	outfileMCC.write("\n")