import sys

content = open(sys.argv[1])
outfile = open(sys.argv[2], 'w')

for line in content:
	if ";" in line:
		line = (line.rstrip("\n")).split("\t")
		accnrs = line[3].split(";")
		for entry in accnrs:
			outfile.write(entry + "\t" + line[1] + "\t" + line[0] +  "\n")
	else:
		line = (line.rstrip("\n")).split("\t")
		outfile.write(line[3] + "\t" + line[1] + "\t" + line[0] +  "\n")
