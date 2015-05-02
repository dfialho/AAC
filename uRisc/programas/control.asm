.module control
.pseg
main:
	loadlit r1,3
A:      deca r1,r1
        jf.zero A
        inca r2, r2
        inca r3, r3
        ; halt the processor
HLT:    j HLT
        nop
.dseg
ARR1:
      .word  1
      .word  1
.end
