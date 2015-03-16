import sys
import os
import platform # determine the OS 
from subprocess import call

myAlphabet = '0123456789abcdefghijklmnopqrstuvwxyz'

def getAppName ():     #plataform test
    if platform.system() != "Linux":
        return "OK"
    else:
        return "Unsupported"

currentDir = os.path.dirname(sys.argv[0])
if currentDir != '':
    currentDir = currentDir + '/'

def check_args():

    if len(sys.argv) != 2:
        print ("(E) Usage: python " + sys.argv[0] + " <file.asm>\n")
        exit()
    
	completeFileName = currentDir + sys.argv[1]
	
	if completeFileName[:-len(".asm")] != ".asm":
		print ("file provided does not have a '.asm' extension\n")
		exit()
	
    return completeFileName

completeFileName = check_args()
filename = completeFileName[:-len(".asm")]

call(["urasm", completeFileName]) 
call(["urlink", filename + ".obj", "-o " + filename + ".out"])

print "done!"
