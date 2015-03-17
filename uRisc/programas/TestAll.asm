.module TestAll
.pseg
main:
loadlit r3,0
loadlit r0,7
inca r1,r0
deca r1,r1
subdec r2,r1,r0
jt.zero J1 ; deve saltar
loadlit r3,1
J1: sub r2,r0,r1
jf.zero J2 ; deve saltar
loadlit r3,2
J2: add r0,r0,r1

.end
