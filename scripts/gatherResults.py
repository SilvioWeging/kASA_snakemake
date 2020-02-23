import os, sys

path = sys.argv[1]
numberOfTools = int(sys.argv[2])
numberOfMuts = int(sys.argv[3])
outfileSens = open(sys.argv[4], 'w')
outfilePrec = open(sys.argv[5], 'w')
outfileF1 = open(sys.argv[6], 'w')

resultMatrixSens = [[""] * (numberOfMuts + 1) for i in range(numberOfTools + 1)]
resultMatrixPrec = [[""] * (numberOfMuts + 1) for i in range(numberOfTools + 1)]
resultMatrixF1 = [[""] * (numberOfMuts + 1) for i in range(numberOfTools + 1)]

toolNames = set()
mutationrates = set()

for file in os.listdir(path):
	if "result" in file:
		filenameArr = file.split("_")
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
	resultMatrixF1[counter][0] = entry
	counter += 1
counter = 1
for entry in mutationrates:
	entry = str(entry)
	mutations[entry] = counter
	resultMatrixSens[0][counter] = entry
	resultMatrixPrec[0][counter] = entry
	resultMatrixF1[0][counter] = entry
	counter += 1



for file in os.listdir(path):
	if "result" in file:
		filenameArr = file.split("_")
		tool = filenameArr[0]
		mutationrate = filenameArr[2]
		
		row = tools[tool]
		col = mutations[mutationrate]
		
		resultFile = open(path+file)
		next(resultFile)
		sens = (((next(resultFile)).split(" "))[1]).rstrip("\n\r")
		prec = (((next(resultFile)).split(" "))[1]).rstrip("\n\r")
		resultMatrixSens[row][col] = sens
		resultMatrixPrec[row][col] = prec
		sens = float(sens)
		prec = float(prec)
		if sens > 0 and prec > 0:
			resultMatrixF1[row][col] = str( (2*sens*prec/(sens+prec)))
		else:
			resultMatrixF1[row][col] = "0.0"

for i in range(numberOfTools + 1):
	outfileSens.write(resultMatrixSens[i][0])
	outfilePrec.write(resultMatrixPrec[i][0])
	outfileF1.write(resultMatrixF1[i][0])
	for j in range(1,numberOfMuts + 1):
		outfileSens.write("," + resultMatrixSens[i][j])
		outfilePrec.write("," + resultMatrixPrec[i][j])
		outfileF1.write("," + resultMatrixF1[i][j])
	outfileSens.write("\n")
	outfilePrec.write("\n")
	outfileF1.write("\n")