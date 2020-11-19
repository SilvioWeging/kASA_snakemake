import os, sys

path = sys.argv[1]
numberOfTools = 1
numberOfMuts = int(sys.argv[2])
outfilePath = sys.argv[3]

resultMatrixSens = [[""] * (numberOfMuts + 1) for i in range(numberOfTools + 1)]
resultMatrixPrec = [[""] * (numberOfMuts + 1) for i in range(numberOfTools + 1)]
resultMatrixSpecificity = [[""] * (numberOfMuts + 1) for i in range(numberOfTools + 1)]
resultMatrixF1 = [[""] * (numberOfMuts + 1) for i in range(numberOfTools + 1)]
resultMatrixMCC = [[""] * (numberOfMuts + 1) for i in range(numberOfTools + 1)]


toolNames = set()
toolNames.add("kASA")
mutationrates = set()

for file in os.listdir(path):
	if "result" in file:
		filenameArr = file.split("_")
		if "kASA" in filenameArr and ".json" not in filenameArr:
			if len(filenameArr) == 5:
				tool = filenameArr[0]
				mutationrate = filenameArr[3]
				mutationrates.add(int(mutationrate))
			elif len(filenameArr) == 4:
				tool = filenameArr[0]
				mutationrate = filenameArr[2]
				mutationrates.add(int(mutationrate))
			else:
				continue
			#tool = filenameArr[0] + "_" + filenameArr[1]
			#mutationrate = filenameArr[3]
			

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
		if "kASA" in filenameArr and ".json" not in filenameArr:
			if len(filenameArr) == 5:
				tool = filenameArr[0]
				mutationrate = filenameArr[3]
			elif len(filenameArr) == 4:
				tool = filenameArr[0]
				mutationrate = filenameArr[2]
			else:
				continue
			#tool = filenameArr[0] + "_" + filenameArr[1]
			#mutationrate = filenameArr[3]
			
			
			row = tools[tool]
			col = mutations[mutationrate]
			
			resultFile = open(path+file)
			next(resultFile)
			resultMatrixSens[row][col] = (((next(resultFile)).split(" "))[1]).rstrip("\n\r")
			resultMatrixPrec[row][col] = (((next(resultFile)).split(" "))[1]).rstrip("\n\r")
			resultMatrixSpecificity[row][col] = (((next(resultFile)).split(" "))[1]).rstrip("\n\r")
			resultMatrixF1[row][col] = (((next(resultFile)).split(" "))[1]).rstrip("\n\r")
			resultMatrixMCC[row][col] = (((next(resultFile)).split(" "))[1]).rstrip("\n\r")
		

outfile = open(outfilePath + "kASA_GatheredResults.txt", 'w')

outfile.write("Sensitivity\n")
outfile.write(resultMatrixSens[0][0])
for j in range(1,numberOfMuts + 1):
	outfile.write("," + resultMatrixSens[0][j])
outfile.write("\n")
for j in range(1,numberOfMuts + 1):
	outfile.write("," + resultMatrixSens[1][j])
outfile.write("\n")

outfile.write("Precision\n")
outfile.write(resultMatrixPrec[0][0])
for j in range(1,numberOfMuts + 1):
	outfile.write("," + resultMatrixPrec[0][j])
outfile.write("\n")
for j in range(1,numberOfMuts + 1):
	outfile.write("," + resultMatrixPrec[1][j])
outfile.write("\n")

outfile.write("F1\n")
outfile.write(resultMatrixF1[0][0])
for j in range(1,numberOfMuts + 1):
	outfile.write("," + resultMatrixF1[0][j])
outfile.write("\n")
for j in range(1,numberOfMuts + 1):
	outfile.write("," + resultMatrixF1[1][j])
outfile.write("\n")

outfile.write("Specificity\n")
outfile.write(resultMatrixSpecificity[0][0])
for j in range(1,numberOfMuts + 1):
	outfile.write("," + resultMatrixSpecificity[0][j])
outfile.write("\n")
for j in range(1,numberOfMuts + 1):
	outfile.write("," + resultMatrixSpecificity[1][j])
outfile.write("\n")

outfile.write("MCC\n")
outfile.write(resultMatrixMCC[0][0])
for j in range(1,numberOfMuts + 1):
	outfile.write("," + resultMatrixMCC[0][j])
outfile.write("\n")
for j in range(1,numberOfMuts + 1):
	outfile.write("," + resultMatrixMCC[1][j])
