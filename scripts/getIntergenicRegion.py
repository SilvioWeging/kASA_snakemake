import sys

#print(sys.argv[1], sys.argv[2], sys.argv[3])

fastaFile = open(sys.argv[1])
gffFile = open(sys.argv[2])
outFile1 = open(sys.argv[3]+"_ig.fasta", 'w')
outFile2 = open(sys.argv[3]+"_g.fasta", 'w')

numberOfBases = 0 
fastaString = ""
name = ""
for line in fastaFile:
	line = line.rstrip("\r\n")
	if line == "":
		continue
	if ">" in line:
		name = ((line.lstrip(">")).split(" "))[0]
		continue
	numberOfBases += len(line)
	fastaString += line
#print(len(fastaString), numberOfBases)

hugeArray = [True]*(numberOfBases+1)

for line in gffFile:
	line = line.rstrip("\r\n")
	if line == "" or '#' in line:
		continue
	line = line.split('\t')
	if line[2] != "region":
		for i in range(int(line[3]) - 1, int(line[4]) - 1): #gffs are one-based
			hugeArray[i] = False

#outFile1.write(">" + name + " intergenic\n")
#outFile2.write(">" + name + " genic\n")

before = False
dnaString = ""
counter = 1
for i in range(numberOfBases):
	if hugeArray[i]:
		if before == False:
			if len(dnaString) != 0:
				outFile2.write(">" + name + " " + str(counter) + " genic\n" + dnaString + "\n")
				dnaString = ""
				counter += 1
			before = True
		else:
			dnaString += fastaString[i]
	else:
		if before == True:
			if len(dnaString) != 0:
				outFile1.write(">" + name + " " + str(counter) + " intergenic\n" + dnaString + "\n")
				dnaString = ""
				counter += 1
			before = False
		else:
			dnaString += fastaString[i]

if len(dnaString) != 0:
	if before == False:
		outFile2.write(">" + name + " " + str(counter) + "\n" + dnaString + "\n")
	else:
		outFile1.write(">" + name + " " + str(counter) + "\n" + dnaString + "\n")
