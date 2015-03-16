import sys
import os
import platform # determine the OS 
from subprocess import call

################ Initializations #################################

myAlphabet = '0123456789abcdefghijklmnopqrstuvwxyz'

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

call(["rm " + filename + ".obj " + filename + ".lis"], shell=True)

print "done!"
