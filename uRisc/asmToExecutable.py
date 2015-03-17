import sys
import os
import platform # determine the OS 
from subprocess import call

################ Initializations #################################
memfile = "IR.vhd"
memInitLine = "  constant InitValue : MEM_TYPE := (\n"
memEndLine  = "  others => X\"0000\"); -- value for all addresses not previously defined\n"

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
    toBeWritten = []

    try:
        f = open(filename, 'rU')
    except IOError:
        print ("(E) Failed to open '" + filename + "'.")
        exit()
    
    lines = f.readlines()
    i = 0
    for line in lines:
        if line.split(" ")[0] == "address":
            k = int(line.split(" ")[1], 16) - i        

            if i == int(line.split(" ")[1], 16) and i != 0:
                return toBeWritten
                #toBeWritten.append('\t' + "others\t=> X\"0000\");")

            while k > 0:
                toBeWritten.append('\t' + str(i) + "\t=> X\"0000" + "\",\n") # NOP 
                i += 1
                k -= 1
            
        else:
            toBeWritten.append('\t' + str(i) + "\t=> X\"" + line.split("\n")[0] + "\",\n")
            i += 1        
    
    f.close()
    
    return toBeWritten

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

toBeWritten = cleanOutFile(filename + ".out")
#for line in toBeWritten:
#    print line

writeToMemory(memfile, toBeWritten)

call(["rm " + filename + ".obj " + filename + ".lis"], shell=True)

print "done!"
