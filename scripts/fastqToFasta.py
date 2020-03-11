import sys, getopt, re, threading, os
from itertools import islice

def fastqToFasta(argv):
    
    inPath1 = ''
    outPath = ''
    
    try:
        opts, args = getopt.getopt(argv, "i:o:", [])
    except getopt.GetoptError:
        print 'you failed'
    
    for opt, arg in opts:
        if opt in ("-i",):
            inPath1 = arg
        elif opt in ("-o",):
            outPath = arg
    
    inFile1 = open(inPath1, 'r')
    outFile = open(outPath, 'w')

    for name in inFile1:
        name = (name.lstrip('@')).rstrip('\n')
        seq = (inFile1.next()).rstrip('\n')
        plus = inFile1.next()
        qual = inFile1.next()
        outFile.write('>' + name + '\n' + seq + '\n')
    
    inFile1.close()
    outFile.close()
    
#end of fastqToFasta

fastqToFasta(sys.argv[1:])