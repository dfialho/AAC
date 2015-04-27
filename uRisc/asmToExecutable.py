import sys
import os
import platform # determine the OS 
from subprocess import call

################ Initializations #################################
ROMfile = "IR.vhd"
RAMfile = "ram.vhd"

memInitLine = "\tconstant InitValue : MEM_TYPE := (\n"
memEndLine  = "\tothers => X\"0000\");\n"

currentDir = os.path.dirname(sys.argv[0])
if currentDir != '':
    currentDir = currentDir + '/'

################ Function Declarations ##########################

def getAppName ():     #plataform test
    if platform.system() == "Linux":
        return "OK"
    else:
        return "Unsupported"

def check_args():
    clean = 0

    if len(sys.argv) != 2:
        print ("(E) Usage: python " + sys.argv[0] + " <file.asm>\n")
        exit()
    
    if sys.argv[1] == "clean":
       clean = 1
       print "work in progress"
       exit()

    completeFileName = currentDir + sys.argv[1]

    if completeFileName[-len(".asm"):] != ".asm":
        print ("file provided does not have a '.asm' extension\n")
        exit()
	
    return completeFileName, clean

def cleanOutFile(filename):
    ROM = [] # programa
    RAM = [] # dados

    try:
        f = open(filename, 'rU')
    except IOError:
        print ("(E) Failed to open '" + filename + "'.")
        exit()
    
    lines = f.readlines()
    del lines[0] # ignore first line "adress 0000"
    
    i, isData = 0, False
    for line in lines:
        if line.split(" ")[0] == "address":
            i, isData = 0, True
            
            k = int(line.split(" ")[1], 16)
            while k > 0:
				#RAM.append('\t' + str(i) + "\t=> X\"0000\",\n")
				i += 1
				k -= 1
            
        else:
            if isData == True:
				RAM.append('\t' + str(i) + " \t=> X\"" + line.split("\n")[0] + "\",\n")
            else :
				ROM.append('\t' + str(i) + " \t=> X\"" + line.split("\n")[0] + "\",\n")
            i += 1        
    
    f.close()    
    return ROM, RAM

def writeToMemory(memfile, toBeWritten):
    try:
        f = open(memfile, 'r')
    except IOError:
        print ("(E) Failed to open '" + memfile)
        exit()

    #backup the beginning of the file
    beginningOfFile = []    
    line = f.readline()
    while line != memInitLine:
        beginningOfFile.append(line)

        line = f.readline()
        if line == '':
            print memfile + " does not have the line \"" + memInitLine + "\""
            f.close
            exit()

    beginningOfFile.append(line) #append memInitLine

    #backup the end of the file
    endOfFile = []    
    line = f.readline()
    while line != memEndLine:
        line = f.readline()
        
        if line == '':
            print memfile + " does not have the line \"" + memEndLine + "\""
            f.close
            exit()

    #write everything to the file
    while line != '':
        endOfFile.append(line)
        line = f.readline()

    f.close

    try:
        f = open(memfile, 'w')
    except IOError:
        print ("(E) Failed at writing to " + memfile)
        exit()

    f.writelines(beginningOfFile)
    f.writelines(toBeWritten)
    f. writelines(endOfFile)

    f.close

################ SCRIPT BEGIN ####################################

if getAppName() != "OK":
    print "Script only works on Linux."
    exit()

completeFileName, clean = check_args()
filename = completeFileName[:-len(".asm")]

if clean == 1:
    call(["rm " + filename + ".obj " + filename + ".lis " + filename + ".out"], shell=True)
    print "cleaned up"
    exit()

call(["./urasm " + completeFileName], shell=True) 
call(["./urlink " + filename + ".obj " + "-o" + filename + ".out"], shell=True)

ROM, RAM = cleanOutFile(filename + ".out")
writeToMemory(ROMfile, ROM)
writeToMemory(RAMfile, RAM)

call(["rm " + filename + ".obj " + filename + ".lis " + filename + ".out"], shell=True)
print "done!"
