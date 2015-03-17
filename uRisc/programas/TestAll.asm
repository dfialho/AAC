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
passnotb r4,r0
addinc r4,r4,r4
jt.overflow J3
loadlit r3,3
J3: jt.overflow
loadlit r3,4
J4: zeros r4
and r4,r4,r2
or r4,r4,r2
jt.overflow J5
loadlit r3,5
J5: ornota r4,r2,r4
jt.negative J6
loadlit r3,6
J6: ornotb r4,r2,r4
jf.negative J7
loadlit r3,7
J7: loadlit r4,256
lcl r4, LOWBYTE 128
passb r2,r4
add r2,r4,r2
store r4,r1
jt.carry J8
loadlit r3,8
J8: passa r2,r0
load r2,r4
lcl r4, LOWBYTE J9
lch r4, HIGHBYTE J9
jal r4
HLT: j HLT
J9: lsl r1,r1
asr r2,r2
jr r7
.end
