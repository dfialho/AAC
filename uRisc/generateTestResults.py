import sys

if len(sys.argv) != 3:
    print "needs 2 arguments, A and B"
    exit()
 
A = int(sys.argv[1])
B = int(sys.argv[2])

print "AVISO: DEVIDO A PREGUICA ESTE SCRIPT USA INTEIROS DE 32 BITS"
print "A: " + str(A) + "\tB: " + str(B) + '\n'

print "00000 - A+B            : "  + str(A + B) 
print "00001 - A+B+1          : "  + str(A + B + 1)
print "00011 - A+1            : "  + str(A + 1)
print "00100 - A-B-1          : "  + str(A - B -1)
print "00101 - A-B            : "  + str(A - B)  
print "00110 - A-1            : "  + str(A - 1)
print
print "01000 - SLL            : "  + str(A << 1)  
print "01001 - SRA            : "  + str(A >> 1)
print
print "01100 - CONST11        : "  + str(B)
print "01110 - CONST8L        : "  + str(B & 0x00FF)
print "01111 - CONST8H        : "  + str(B & 0xFF00)
print
print "10000 - ZEROS          : "  + str(0)
print "11111 - ONES           : "  + str(-1)
print "10101 - A              : "  + str(A)
print "11010 - not A          : "  + str(~A)
print "10011 - B              : "  + str(B)
print "11100 - not B          : "  + str(~B)
print
print "10111 - A or B         : "  + str(A | B)
print "11011 - not A or B     : "  + str(~A | B)
print "11101 - A or not B     : "  + str(A | ~B)
print "11110 - not A or not B : "  + str(~A | ~B)
print
print "10001 - A and B        : "  + str(A & B)
print "10010 - not A and B    : "  + str(~A & B)
print "10100 - A and not B    : "  + str(A & ~B)
print "11000 - not A and not B: "  + str(~A & ~B)
print
print "10110 - A xor B        : "  + str(A ^ B)
print "11001 - A xnor B       : "  + str(~(A ^ B))