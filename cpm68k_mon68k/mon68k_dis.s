        .globl _DISASM

acias    .equ   $ff1000
aciad    .equ   $ff1002
cr       .equ     $0d
lf       .equ     $0a
nul      .equ     $00

diswk   .equ    $ff3000                 ; ff24f0
exam    .equ    diswk+0                 ;memory examination pointer
writm   .equ    diswk+2
t1      .equ    diswk+4                 ;temporary work area
t2      .equ    diswk+6
t3      .equ    diswk+8
t4      .equ    diswk+10
t5      .equ    diswk+12
siz     .equ    diswk+14

_DISASM:
	    link	a6,#-4

	    move.l	8(a6),a1                ; adr
	    move.l  12(a6),a3               ; abuf
ass20:  jsr     ass1    
        move.l  a1,d0                   ; next adr
        move.b  #$00,(a3)+              ; tremnate
	    unlk	a6
		rts

writs:  move.b  (a0)+,d0                ;a0 is address of string
        beq     dwrts
        bsr     writ
        bra     writs
dwrts:  rts

writb:  move.w  #$1,t1                  ;t1 is the number of bytes
        bra     wr
writw:  move.w  #$3,t1
        bra     wr
writl:  move.w  #$7,t1
wr:     movem.l d1/d2/a0/a6,-(a7)       ;save registers d1,d2,a0,a6
        move.w  t1,d2                   ;set count
        move.b  #$00,t5+1               ;set a null at end
        lea     t5+1,a6                 ;use temps as a stack
alp:    move.b  d0,d1                   ;make each hex digit a
        and.b   #$0f,d1                 ;writable ascii byte
        cmp.b   #$0a,d1                 ;check for abcdef
        blt     or3
        or.b    #$40,d1
        sub.b   #$09,d1
        bra     m1
or3:    or.b    #$30,d1                 ;set high-order bits
m1:     
        move.b  d1,-(a6)                ;put on stack
        lsr.l   #$4,d0                  ;get next hex digit
        dbf     d2,alp
        movea.l a6,a0                   ;write the stack with writs
m2:
        cmp.b   #$30,(a0)
		bne     m3
		cmp.b   #$30,1(a0)
		bne     m3
		add.l   #1,a0
		bra     m2
m3:
        bsr     writs
        movem.l (a7)+,d1/d2/a0/a6       ;restore registers d1,d2,a0,a6
        rts

writ:
        move.b  d0,(a3)+
		rts

OUTCH:  move.w	d0,-(sp)
OUTCH2: move.b  acias,d0
        btst    #$1,d0
        beq     OUTCH2
        move.w	(sp)+,d0
        move.b  d0,aciad
        rts

getch:
INCH:   move.b  acias,d0
        btst    #$00,d0
        beq     INCH
        clr.l   d0
        move.b  aciad,d0
        rts
;

ass1:   move.l  a1,d0           ;load the address
;        bsr     writa           ;print it out
;        bsr     spc
        move.w  (a1)+,d0        ;load the instruction word
        move.w  d0,d1           ;make a copy
        rol.w   #$06,d0         ;get a longword offset for
        and.w   #$003c,d0       ;the instruction group (most sig. 4 bits)
        lea     grtab,a2        ;load the address of the group table
        adda.w  d0,a2           ;add the group offset
        movea.l (a2),a2         ;get the actual address
        jsr     (a2)            ;jump to the appropriate subroutine
        rts                     ;exit

disend: 
;        bra     crlf            ;send crlf after instruction
        rts                     ;return from instruction subroutine

cf:     dc.b    cr,lf,nul,nul
crlf:   lea     cf,a0
        bsr     writs
        rts

grtab:  dc.l    gr0
        dc.l    gr1
        dc.l    gr2
        dc.l    gr3
        dc.l    gr4
        dc.l    gr5
        dc.l    gr6
        dc.l    gr7
        dc.l    gr8
        dc.l    gr9
        dc.l    gra
        dc.l    grb
        dc.l    grc
        dc.l    grd
        dc.l    gre
        dc.l    grf

gr0:    move.w  d1,d0
        cmpi.w  #$023c,d0       ;is it ANDIccr?
        bne     ANDIsr          ;no.
        lea     mANDI,a0        ;yes, print
        bsr     writs           ;write it
        bsr     spc
        bsr     pound
        bsr     dollar
        move.w  (a1)+,d0        ;load the operand
        bsr     writb           ;write it
        bsr     comma
        lea     mccr,a0         ;load "ccr"
        bsr     writs
        bra     disend
ANDIsr: cmpi.w  #$027c,d0       ;is it ANDIsr?
        bne     EORIcr          ;no.
        lea     mANDI,a0        ;yes, print
        bsr     writs           ;write it
        bsr     spc
        bsr     pound
        bsr     dollar
        move.w  (a1)+,d0        ;load the operand
        bsr     writw           ;write it
        bsr     comma
        lea     msr,a0          ;load "sr"
        bsr     writs
        bra     disend
EORIcr: cmpi.w  #$0a3c,d0       ;is it EORIccr?
        bne     EORIsr          ;no.
        lea     mEORI,a0        ;yes, print
        bsr     writs           ;write it
        bsr     spc
        bsr     pound
        bsr     dollar
        move.w  (a1)+,d0        ;load the operand
        bsr     writb           ;write it
        bsr     comma
        lea     mccr,a0         ;load "ccr"
        bsr     writs
        bra     disend
EORIsr: cmpi.w  #$0a7c,d0       ;is it EORIsr?
        bne     ORIccr          ;no.
        lea     mEORI,a0        ;yes, print
        bsr     writs
        bsr     spc
        bsr     pound
        bsr     dollar
        move.w  (a1)+,d0        ;load the operand
        bsr     writw           ;write it
        bsr     comma
        lea     msr,a0          ;load "sr"
        bsr     writs           ;write it
        bra     disend
ORIccr: cmpi.w  #$003c,d0       ;is it ORIccr?
        bne     ORIsr           ;no.
        lea     mORI,a0         ;yes, print
        bsr     writs           ;write it
        bsr     spc
        bsr     pound
        bsr     dollar
        move.w  (a1)+,d0        ;load the operand
        bsr     writb           ;write it
        bsr     comma
        lea     mccr,a0         ;load "ccr"
        bsr     writs
        bra     disend
ORIsr:  cmpi.w  #$007c,d0       ;is it ORIsr?
        bne     ADDI            ;no.
        lea     mORI,a0         ;yes, print
        bsr     writs           ;write it
        bsr     spc
        bsr     pound
        bsr     dollar
        move.w  (a1)+,d0        ;load the operand
        bsr     writw           ;write it
        bsr     comma
        lea     msr,a0          ;load "sr"
        bsr     writs
        bra     disend
ADDI:   andi.w  #$0f00,d0       ;mask operation bits
        cmpi.w  #$0600,d0       ;is it ADDI?
        bne     ANDI            ;no.
        lea     mADDI,a0        ;yes, print
        bsr     writs           ;write it
        bra     iops            ;go print operands
ANDI:   cmpi.w  #$0200,d0       ;is it ANDI?
        bne     CMPI            ;no.
        lea     mANDI,a0        ;yes, print
        bsr     writs           ;write it
        bra     iops            ;go print operands
CMPI:   cmpi.w  #$0c00,d0       ;is it CMPI?
        bne     EORI            ;no.
        lea     mCMPI,a0        ;yes, print
        bsr     writs           ;write it
        bra     iops            ;go print operands
EORI:   cmpi.w  #$0a00,d0       ;is it EORI?
        bne     ORI             ;no.
        lea     mEORI,a0        ;yes, print
        bsr     writs           ;write it
        bra     iops            ;go print operands
ORI:    cmpi.w  #$0000,d0       ;is it ORI?
        bne     SUBI            ;no.
        lea     mORI,a0         ;yes, print
        bsr     writs           ;write it
        bra     iops            ;go print operands
SUBI:   cmpi.w  #$0400,d0       ;is it SUBI?
        bne     MOVEP           ;no.
        lea     mSUBI,a0        ;yes, print
        bsr     writs           ;write it
iops:   move.w  d1,d0
        andi.w  #$00c0,d0       ;check the size to see if it is legal
        cmpi.w  #$00c0,d0       ;is it size 11?
        bne     lops            ;if not, it is legal
        bsr     spc           ;if so, it is not legal
        bsr     spc
        bra     ILLEG
lops:   bsr     dot
        move.w  d1,d0
        bsr     findsiz         ;print the operand size
        bsr     spc
        bsr     pound
        bsr     dollar
        cmpi.b  #$62,siz        ;is byte?
        bne     iopsw           ;no
        move.w  (a1)+,d0        ;yes
        bsr     writb
        bra     iopsc
iopsw:  cmpi.b  #$77,siz        ;is word?
        bne     iopsl           ;no
        move.w  (a1)+,d0        ;yes
        bsr     writw
        bra     iopsc
iopsl:  move.l  (a1)+,d0        ;size long
        bsr     writl
iopsc:  bsr     comma
        move.w  d1,d0
        bsr     writea          ;write the operand
        bra     disend
MOVEP:  move.w  d1,d0
        andi.w  #$0138,d0       ;mask MOVEP bits
        cmpi.w  #$0108,d0       ;is it a MOVEP?
        bne     bitop           ;if not, it's a bit operation
        lea     mMOVEP,a0       ;load "MOVEP"
        bsr     writs           ;write it
        bsr     dot
        move.w  d1,d0
        andi.w  #$0040,d0       ;word or longword
        bne     movepl          ;longword
        move.b  #$77,d0         ;load a 'W'
        bsr     writ            ;write it
        bra     moveps          ;go write operands
movepl: move.b  #$6C,d0         ;load an 'L'
        bsr     writ            ;write it
moveps: bsr     spc
        move.w  d1,d0
        andi.w  #$0080,d0       ;mask direction bit
        beq     movepr          ;if zero, move to reg
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask data reg
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;write it
        bsr     comma
        bsr     lparen
        move.w  (a1)+,d0
        bsr     writw           ;write the address
        bsr     comma
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask address reg
        bsr     wareg           ;write it
        bsr     rparen
        bra     disend
movepr: move.w  d1,d0
        bsr     lparen
        move.w  (a1)+,d0
        bsr     writw           ;write the address
        bsr     comma
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask address reg
        bsr     wareg           ;write it
        bsr     rparen
        bsr     comma
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask data reg
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;write it
        bra     disend
bitop:  move.w  d1,d0
        andi.w  #$0f00,d0       ;mask the subgroup bits
        cmpi.w  #$0e00,d0       ;and make sure this is not illegal, since
        beq     ILLEG           ;a non-MOVEP 00001110xxxxxxxx is invalid
        move.w  d1,d0
        andi.w  #$00c0,d0       ;mask bitop select bits
        bne     BCHG            ;it's not BTST
        lea     mBTST,a0        ;load "BTST"
        bsr     writs           ;write it
        bra     bitop2          ;go print operands
BCHG:   cmpi.w  #$0040,d0
        bne     BCLR            ;it's not BCHG
        lea     mBCHG,a0        ;load "BCHG"
        bsr     writs           ;write it
        bra     bitop2          ;go print operands
BCLR:   cmpi.w  #$0080,d0
        bne     BSET            ;it's not BCLR
        lea     mBCLR,a0        ;load "BCLR"
        bsr     writs           ;write it
        bra     bitop2          ;go print operands
BSET:   lea     mBSET,a0        ;load "BSET"
        bsr     writs           ;write it
bitop2: bsr     spc
        move.w  d1,d0
        andi.w  #$0100,d0       ;is it reg or immediate operand?
        bne     bitopr          ;if nonzero, it's a reg operand
        bsr     pound
        move.w  (a1)+,d0        ;get the bit number
        andi.b  #$07,d0         ;modulo 8
        bsr     writb           ;write it
        bsr     comma
        move.w  d1,d0
        bsr     writea          ;write the destination operand
        bra     disend
bitopr: move.w  d1,d0
        andi.w  #$0e00,d0       ;mask off the reg number
        rol.w   #$07,d0         ;get it into rightmost bits
        bsr     wdreg           ;write it
        bsr     comma
        move.w  d1,d0
        bsr     writea          ;write the destination operand
        bra     disend

gr1:    move.b  #$62,siz        ;make MOVE a byte operation
        bra     MOVE            ;go parse the command type
gr2:    move.b  #$6c,siz        ;make MOVE a word operation
        bra     MOVE            ;go parse the command type
gr3:    move.b  #$77,siz        ;make MOVE a long operation
MOVE:   move.w  d1,d0
        andi.w  #$01c0,d0       ;mask the destination opmode
        cmpi.w  #$0040,d0       ;is it MOVEA?
        beq     MOVEA           ;if so, go do MOVEA
        lea     mMOVE,a0        ;load "MOVE"
        bsr     writs           ;write it
        bsr     dot
        bsr     findend         ;write the size
        bsr     spc
        move.w  d1,d0
        bsr     writea          ;write source operand
        bsr     comma
        move.w  d1,d0
        ror.w   #$01,d0         ;these rols and rors make dest. op. std.
        rol.b   #$03,d0
        ror.w   #$08,d0
        ror.b   #$03,d0
        ror.w   #$05,d0         ;dest. op. now looks like source op.
        bsr     writea          ;write it
        bra     disend
MOVEA:  move.b  siz,d0          ;load the size.
        cmpi.b  #$42,d0         ;is it a byte?
        beq     ILLEG           ;if so, this is not a valid instruction
        lea     mMOVEA,a0       ;load "MOVEA"
        bsr     writs           ;write it
        bsr     dot
        bsr     findend         ;write the size
        bsr     spc
        move.w  d1,d0
        bsr     writea          ;write source operand
        bsr     comma
        move.w  d1,d0
        rol.w   #$07,d0         ;get destination into rightmost
        andi.w  #$07,d0         ;mask off the destination bits
        bsr     wareg           ;write it
        bra     disend

gr4:    move.w  d1,d0
NOP:    cmpi.w  #$4e71,d0       ;is it a NOP?
        bne     RESET           ;no
        lea     mNOP,a0         ;yes, print
        bsr     writs           ;write it
        bra     disend
RESET:  cmpi.w  #$4e70,d0       ;is it RESET?
        bne     RTE             ;no
        lea     mRESET,a0       ;yes, print
        bsr     writs           ;write it
        bra     disend
RTE:    cmpi.w  #$4e73,d0       ;is it RTE?
        bne     RTR             ;no
        lea     mRTE,a0         ;yes, print
        bsr     writs           ;write it
        bra     disend
RTR:    cmpi.w  #$4e77,d0       ;is it RTR?
        bne     RTS             ;no
        lea     mRTR,a0         ;yes, print
        bsr     writs           ;write it
        bra     disend
RTS:    cmpi.w  #$4e75,d0       ;is it RTS?
        bne     STOP            ;no
        lea     mRTS,a0         ;yes, print
        bsr     writs           ;write it
        bra     disend
STOP:   cmpi.w  #$4e72,d0       ;is it STOP?
        bne     TRAPV           ;no
        lea     mSTOP,a0        ;yes, print
        bsr     writs           ;write it
        bsr     spc
        bsr     pound
        bsr     dollar
        move.w  (a1)+,d0        ;load data word
        bsr     writw           ;write it
        bra     disend
TRAPV:  cmpi.w  #$4e76,d0       ;is it TRAPV?
        bne     JMP             ;no
        lea     mTRAPV,a0       ;yes, print
        bsr     writs           ;write it
        bra     disend
JMP:    andi.w  #$0fc0,d0       ;mask bits for one <ea> operations
        cmpi.w  #$0ec0,d0       ;is it JMP?
        bne     JSR             ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        beq     ILLEG
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        cmpi.w  #$0018,d0       ;valid modes with
        beq     ILLEG
        cmpi.w  #$0020,d0       ;this instruction
        beq     ILLEG
        lea     mJMP,a0         ;yes, print
        bsr     writs
        bra     gtea0           ;go write operand
JSR:    cmpi.w  #$0e80,d0       ;is it JSR?
        bne     MOVtc           ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        beq     ILLEG
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        cmpi.w  #$0018,d0       ;valid modes with
        beq     ILLEG
        cmpi.w  #$0020,d0       ;this instruction
        beq     ILLEG
        lea     mJSR,a0         ;yes, print
        bsr     writs
        bra     gtea0           ;go write operand
MOVtc:  cmpi.w  #$04c0,d0       ;is it MOVEtoccr?
        bne     MOVfc           ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        lea     mMOVE,a0        ;yes, print
        bsr     writs
        bsr     spc
        move.w  d1,d0
        bsr     writea          ;write the source operand
        bsr     comma
        lea     mccr,a0         ;load "ccr"
        bsr     writs
        bra     disend
MOVfc:  cmpi.w  #$02c0,d0       ;is it MOVEfromccr?
        bne     MOVts           ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        lea     mMOVE,a0        ;yes, print
        bsr     writs
        bsr     spc
        lea     mccr,a0         ;load "ccr"
        bsr     writs           ;write it
        bsr     comma
        move.w  d1,d0
        bsr     writea          ;write the operand
        bra     disend
MOVts:  cmpi.w  #$06c0,d0       ;is it MOVEtosr?
        bne     MOVfs           ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        lea     mMOVE,a0        ;yes, print
        bsr     writs
        bsr     spc
        move.w  d1,d0
        bsr     writea          ;write the source operand
        bsr     comma
        lea     msr,a0          ;load "sr"
        bsr     writs
        bra     disend
MOVfs:  cmpi.w  #$00c0,d0       ;is it MOVEfromsr?
        bne     NBCD            ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        lea     mMOVE,a0        ;yes, print
        bsr     writs
        bsr     spc
        lea     msr,a0          ;load "sr"
        bsr     writs
        bsr     comma
        move.w  d1,d0
        bsr     writea          ;write the operand
        bra     disend
NBCD:   cmpi.w  #$0800,d0       ;is it NBCD?
        bne     PEA             ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        lea     mNBCD,a0        ;yes, print
        bsr     writs
        bra     gtea0           ;go write operand
PEA:    cmpi.w  #$0840,d0       ;is it PEA?
        bne     TAS             ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        beq     SWAP
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        cmpi.w  #$0018,d0       ;valid modes with
        beq     ILLEG
        cmpi.w  #$0020,d0       ;this instruction
        beq     ILLEG
        lea     mPEA,a0         ;yes, print
        bsr     writs
        bra     gtea0           ;go write operand
TAS:    cmpi.w  #$0AC0,d0       ;is it TAS?
        bne     CLR             ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if a valid mode
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        cmpi.w  #$0038,d0       ;special modes
        bne     tasok
        move.w  d1,d0
        andi.w  #$0006,d0
        bne     ILLEG           ;certain of them are bad
tasok:  lea     mTAS,a0         ;yes, print
        bsr     writs
gtea0:  bsr     spc
        move.w  d1,d0
        bsr     writea          ;write the operand
        bra     disend
CLR:    andi.w  #$0f00,d0       ;mask <ea> + <size> operations
        cmpi.w  #$0200,d0       ;is it clr?
        bne     NEG             ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        lea     mCLR,a0         ;yes, print
        bsr     writs
        bra     gtea1           ;go write operand
NEG:    cmpi.w  #$0400,d0       ;is it NEG?
        bne     NEGX            ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        lea     mNEG,a0         ;yes, print
        bsr     writs
        bra     gtea1           ;go write operand
NEGX:   cmpi.w  #$0000,d0       ;is it NEGX?
        bne     NOT             ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        lea     mNEGX,a0        ;yes, print
        bsr     writs
        bra     gtea1           ;go write operand
NOT:    cmpi.w  #$0600,d0       ;is it NOT?
        bne     TST             ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        lea     mNOT,a0         ;yes, print
        bsr     writs
        bra     gtea1           ;go write operand
TST:    cmpi.w  #$0A00,d0       ;is it TST?
        bne     BKPT            ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        lea     mTST,a0         ;yes, print
        bsr     writs
gtea1:  bsr     dot
        move.w  d1,d0
        bsr     findsiz         ;print the operand length
        bsr     spc
        move.w  d1,d0
        bsr     writea          ;print the operand
        bra     disend
BKPT:   move.w  d1,d0
        andi.w  #$fff8,d0       ;mask out the operand
        cmpi.w  #$4848,d0       ;is it BKPT?
        bne     LINK            ;no
        lea     mBKPT,a0        ;yes, print
        bsr     writs           ;write it
        bsr     spc
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask BKPT number
        addi.b  #$30,d0         ;make it an ascii numeral
        bsr     writ            ;write it
        bra     disend
LINK:   move.w  d1,d0
        andi.w  #$0f00,d0       ;look at bits 8-11
        cmpi.w  #$0e00,d0       ;is it an E?
        bne     SWAP            ;no
        move.w  d1,d0
        andi.w  #$fff8,d0       ;mask off reg number
        cmpi.w  #$4e50,d0       ;is it a LINK?
        bne     MOVEsp          ;no
        lea     mLINK,a0        ;load "LINK"
        bsr     writs           ;write it
        bsr     spc
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask reg bits
        bsr     wareg           ;write it
        bsr     comma
        bsr     pound
        bsr     dollar
        move.w  (a1)+,d0        ;load displacement
        bsr     writw           ;write it
        bra     disend
MOVEsp: move.w  d1,d0
        andi.w  #$fff0,d0       ;mask off operand bits
        cmpi.w  #$4e60,d0       ;is it MOVEusp?
        bne     TRAP            ;no
        lea     mMOVE,a0        ;yes, so load "MOVE"
        bsr     writs           ;write it
        bsr     spc
        move.w  d1,d0
        andi.w  #$0008,d0       ;mask direction bit
        bne     MOVEts          ;if zero, move to usp
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask reg bits
        bsr     wareg           ;write it
        bsr     comma
        lea     musp,a0         ;load "usp"
        bsr     writs           ;write it
        bra     disend
MOVEts: lea     musp,a0         ;load "usp"
        bsr     writs           ;write it
        bsr     comma
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask reg bits
        bsr     wareg           ;write it
        bra     disend
TRAP:   move.w  d1,d0
        andi.w  #$fff0,d0       ;mask operand if TRAP
        cmpi.w  #$4e40,d0       ;is it TRAP?
        bne     SWAP            ;no
        lea     mTRAP,a0        ;yes
        bsr     writs
        bsr     spc
        bsr     pound
        bsr     dollar
        move.b  d1,d0
        andi.b  #$0f,d0         ;mask off trap number
        bsr     writb           ;write it
        bra     disend
SWAP:   move.w  d1,d0
        andi.w  #$fff8,d0       ;mask off operand if SWAP
        cmpi.w  #$4840,d0       ;is it SWAP?
        bne     UNLK            ;no
        lea     mSWAP,a0        ;load "swap"
        bsr     writs           ;write it
        bsr     spc
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask off the reg bits
        bsr     wdreg           ;write the reg
        bra     disend
UNLK:   cmpi.w  #$4e58,d0       ;is it UNLK?
        bne     LEA             ;no
        lea     mUNLK,a0        ;load "UNLK"
        bsr     writs           ;write it
        bsr     spc
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask off reg number
        bsr     wareg           ;write it
        bra     disend
LEA:    move.w  d1,d0
        andi.w  #$f1c0,d0       ;mask for lea
        cmpi.w  #$41c0,d0       ;is it LEA?
        bne     CHK             ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        beq     ILLEG
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        cmpi.w  #$0018,d0       ;valid modes with
        beq     ILLEG
        cmpi.w  #$0020,d0       ;this instruction
        beq     ILLEG
        lea     mLEA,a0         ;load "LEA"
        bsr     writs           ;write it
        bsr     spc
        move.w  d1,d0
        bsr     writea          ;write source op
        bsr     comma
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask reg number
        rol.w   #$07,d0         ;get reg in rightmost bits
        bsr     wareg           ;write it
        bra     disend
CHK:    cmpi.w  #$4180,d0       ;is it CHK?
        bne     EXT             ;no
        move.w  d1,d0
        andi.w  #$0038,d0       ;check to see if it's a valid mode
        cmpi.w  #$0008,d0       ;these are not
        beq     ILLEG
        lea     mCHK,a0         ;load "CHK"
        bsr     writs           ;write it
        move.b  #$77,siz        ;size is word
        bsr     spc
        move.w  d1,d0
        bsr     writea          ;write source operand
        bsr     comma
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask reg number
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;write it
        bra     disend
EXT:    move.w  d1,d0
        andi.w  #$ffb8,d0       ;mask all pertinent bits
        cmpi.w  #$4880,d0       ;is it EXT?
        bne     MOVEC           ;no
        lea     mEXT,a0         ;yes, load "EXT"
        bsr     writs           ;write it
        bsr     dot
        move.w  d1,d0
        andi.w  #$0040,d0       ;mask the size bit
        bne     lext            ;size long
        move.b  #$77,d0         ;size word, load 'W'
        bsr     writ            ;write it
        bra     ext1
lext:   move.b  #$6c,d0         ;load 'L'
        bsr     writ            ;write it
ext1:   bsr     spc
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask the reg number
        bsr     wdreg           ;write it
        bra     disend
MOVEC:  move.w  d1,d0
        andi.w  #$fffe,d0       ;mask in appropriate bits
        cmpi.w  #$4e7b,d0       ;is it a MOVEC?
        bne     MOVEM           ;no
        lea     mCOPOUT,a0      ;yes, so load "COPOUT"
        bsr     writs           ;write it
        move.w  (a1)+,d0        ;compensate for the operand word
        bra     disend
MOVEM:  move.w  d1,d0
        andi.w  #$fb80,d0       ;mask bits
        cmpi.w  #$4880,d0       ;is it MOVEM?
        bne     ILLEG           ;no
        lea     mMOVEM,a0       ;yes, load "MOVEM"
        bsr     writs
        bsr     dot
        move.w  d1,d0
        andi.w  #$0040,d0       ;mask MOVEM size bit
        bne     MOVEMl          ;if nonzero, longword operand
        move.b  #$77,d0         ;load 'W'
        move.b  d0,siz          ;save size as 'W'
        bsr     writ            ;write it
        bsr     spc
        bra     MOVEMo          ;go write operands
MOVEMl: move.b  #$6c,d0         ;load 'L'
        move.b  d0,siz          ;save size as 'L'
        bsr     writ            ;write it
        bsr     spc
MOVEMo: move.w  d1,d0
        andi.w  #$0400,d0       ;which direction?
        bne     MOVEMr          ;to reg
        bsr     dollar
        move.w  (a1)+,d0        ;load the reg list
        bsr     writw           ;write it
        bsr     comma
        move.w  d1,d0
        bsr     writea          ;write the address
        bra     disend
MOVEMr: move.w  (a1)+,t1        ;save the reg list
        move.w  d1,d0
        bsr     writea          ;write the address
        bsr     comma
        bsr     dollar
        move.w  t1,d0           ;reload the reg list
        bsr     writw           ;write it
        bra     disend
ILLEG:  lea     mILLEG,a0       ;yes, print
        bsr     writs           ;write it
        bra     disend

gr5:    move.w  d1,d0           ;refresh the instruction word
        and.w   #$00c0,d0       ;mask bits 6-7
        cmp.w   #$00c0,d0       ;DBcc/Scc?
        bne     addqx            ;no
        move.w  d1,d0           ;yes
        andi.w  #$0038,d0       ;mask DB/S bit
        cmpi.w  #$0008,d0       ;DBcc?
        bne     Sxx             ;no
        move.b  #$64,d0         ;load D into d0
        bsr     writ            ;write it
        move.b  #$62,d0         ;load B into d0
        bsr     writ            ;write it
        move.w  d1,d0           ;refresh
        bsr     findcon         ;print condition
        bsr     spc
        move.w  d1,d0           ;refresh
        andi.w  #$0007,d0       ;mask out reg
        bsr     wdreg           ;write reg
        bsr     comma
        clr.w   d0              ;zero d0 so wdis looks for word disp.
        bsr     wdis            ;print the address
        bra     disend

Sxx:    move.b  #$72,d0         ;load S into d0
        bsr     writ            ;write it
        move.w  d1,d0           ;refresh
        bsr     findcon         ;print condition
        bsr     spc
        move.w  d1,d0
        bsr     writea          ;write operand
        bra     disend

findcon:lea     contab,a0       ;load location of beginning of table
        andi.w  #$0f00,d0       ;mask off the condition
        ror.w   #$07,d0         ;make condition a word offset
        adda.w  d0,a0           ;add to table location to get ascii
        move.b  (a0)+,d0        ;load the first byte
        bsr     writ            ;write it
        move.b  (a0)+,d0        ;load the second byte
        bsr     writ            ;write it
        rts

contab: dc.b    "t "
        dc.b    "f "
        dc.b    "hi"
        dc.b    "ls"
        dc.b    "cc"
        dc.b    "cs"
        dc.b    "ne"
        dc.b    "eq"
        dc.b    "vc"
        dc.b    "vs"
        dc.b    "pl"
        dc.b    "mi"
        dc.b    "ge"
        dc.b    "lt"
        dc.b    "gt"
        dc.b    "le"

addqx:   move.w  d1,d0
        andi.w  #$0100,d0       ;addq/subq
        bne     subqx
        lea     mADDQ,a0        ;load "addq"
        bra     qwrit
subqx:   lea     mSUBQ,a0        ;load "subq"
qwrit:  bsr     writs           ;write it
        bsr     dot
        move.w  d1,d0
        bsr     findsiz         ;write size of operand
        bsr     spc
        bsr     pound
        bsr     dollar
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask data
        rol.w   #$07,d0         ;get into rightmost bits
        bne     q8              ;if nonzero, range is 1-7
        move.b  #$08,d0         ;if zero, range is 8
q8:     bsr     writb           ;write byte
        bsr     comma
        move.w  d1,d0
        bsr     writea          ;write dest
        bra     disend

gr6:    move.w  d1,d0
        andi.w  #$0f00,d0       ;mask the cond bit
        bne     BSR             ;not BRA
        lea     mBRA,a0         ;load "bra"
        bsr     writs           ;write it
        bra     Bccw            ;go write operand
BSR:    cmp.w   #$0100,d0       ;BSR?
        bne     Bcc             ;no
        lea     mBSR,a0         ;load "bsr"
        bsr     writs           ;write it
        bra     Bccw            ;go write operand
Bcc:    move.b  #$62,d0         ;load a B
        bsr     writ            ;write it
        move.w  d1,d0
        bsr     findcon         ;print the condition
Bccw:   bsr     spc
        move.w  d1,d0
        bsr     wdis            ;write the address
        bra     disend

gr7:    move.w  d1,d0
        andi.w  #$0100,d0       ;check to make sure
        bne     ILLEG
        lea     mMOVEQ,a0       ;load "MOVEQ"
        bsr     writs           ;write it
        bsr     spc
        bsr     pound
        bsr     dollar
        move.b  d1,d0           ;load data
        bsr     writb           ;write it
        bsr     comma
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask off the reg bits
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;write it
        bra     disend

gr8:    move.w  d1,d0
        andi.w  #$01f0,d0       ;mask for SBCD.
        cmpi.w  #$0100,d0       ;is it SBCD?
        bne     DIVS
        lea     mSBCD,a0        ;load "SBCD"
xBCD:   bsr     writs           ;write it
        move.w  d1,d0
        andi.w  #$0008,d0       ;mask reg/memory bit
        beq     sbcdrg          ;reg to reg op
        bsr     spc
        bsr     minus
        bsr     lparen
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask source reg
        bsr     wareg           ;print it
        bsr     rparen
        bsr     comma
        bsr     minus
        bsr     lparen
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask destination reg
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wareg           ;print it
        bsr     rparen
        bra     disend
sbcdrg: bsr     spc
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask source reg
        bsr     wdreg
        bsr     comma
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask destination reg
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;print it
        bra     disend

DIVS:   move.w  d1,d0
        andi.w  #$00c0,d0       ;mask mode bits
        cmpi.w  #$00c0,d0       ;is this a DIV operation
        bne     OR              ;no.
        move.w  d1,d0           ;yes.
        andi.w  #$0100,d0       ;mask the sign bit
        beq     DIVU            ;it's unsigned divide
        lea     mDIVS,a0        ;load "DIVS"
        bsr     writs           ;write it
        bra     divprt          ;go decode the rest of the command
DIVU:   lea     mDIVU,a0        ;load "DIVU"
        bsr     writs           ;write it
divprt: bsr     spc
        move.w  d1,d0
        bsr     writea
        bsr     comma
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask data reg
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;print it
        bra     disend

OR:     lea     mOR,a0          ;load "OR"
ANDent: bsr     writs           ;write it
        bsr     dot
        move.w  d1,d0
        bsr     findsiz         ;print operand size
        bsr     spc
        move.w  d1,d0
        andi.w  #$0100,d0       ;find destination
        beq     ordreg          ;if zero, data reg
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask the reg bits
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;and print it
        bsr     comma
        move.w  d1,d0
        bsr     writea          ;write the destination
        bra     disend
ordreg: move.w  d1,d0
        bsr     writea          ;write the source
        bsr     comma
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask the reg bits
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;and print it
        bra     disend

gr9:    lea     mSUB,a0         ;load "SUB"
        bsr     writs           ;write it
ax:     move.w  d1,d0
        andi.w  #$00c0,d0       ;mask the size bits
        cmpi.w  #$00c0,d0       ;is it ADDA or SUBA?
        bne     SUB             ;no
        move.b  #$61,d0         ;yes, so load an 'A'
        bsr     writ            ;write it
        bsr     dot
        move.w  d1,d0
        andi.w  #$0100,d0       ;mask size bit
        bne     SUBAl           ;if set, longword operand
        move.b  #$77,d0         ;load 'W'
        bsr     writ            ;write it
        bra     axa             ;go print operands
SUBAl:  move.b  #$6c,d0         ;load 'L'
        bsr     writ            ;write it
        bra     axa             ;go print operands
SUB:    move.w  d1,d0
        andi.w  #$0130,d0       ;mask appropriate bits
        cmpi.w  #$0100,d0       ;is it ADDX or SUBX?
        beq     SUBX            ;yes
        bsr     dot             ;no, so continue
        move.w  d1,d0
        bsr     findsiz         ;print the size of the operand
axa:    bsr     spc
        move.w  d1,d0
        andi.w  #$00c0,d0       ;mask the size bits
        cmpi.w  #$00c0,d0       ;is it ADDA or SUBA
        beq     subea1          ;if so, <ea> is first operand
        move.w  d1,d0
        andi.w  #$0100,d0       ;mask direction bit
        bne     subea2          ;if bit is set, <ea> is last operand
        move.w  d1,d0
        bsr     writea          ;write the first operand
        bsr     comma
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask the reg bits
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;print it
        bra     disend
subea1: move.w  d1,d0
        bsr     writea          ;write the first operand
        bsr     comma
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask the reg bits
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wareg           ;print it
        bra     disend
subea2: move.w  d1,d0
        andi.w  #$0e00,d0       ;mask the reg bits
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;print it
        bsr     comma
        move.w  d1,d0
        bsr     writea          ;write second operand
        bra     disend

SUBX:   move.b  #$78,d0         ;load an 'X'
        bsr     writ            ;write it
        bsr     dot
        move.w  d1,d0
        bsr     findsiz         ;write the operand length
        bsr     spc
        move.w  d1,d0
        andi.w  #$0008,d0       ;mask reg/memory bit
        beq     SUBXdr          ;reg to reg op
        bsr     minus
        bsr     lparen
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask source reg
        bsr     wareg           ;print it
        bsr     rparen
        bsr     comma
        bsr     minus
        bsr     lparen
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask destination reg
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wareg           ;print it
        bsr     rparen
        bra     disend
SUBXdr: move.w  d1,d0
        andi.w  #$0007,d0       ;mask source reg
        bsr     wdreg
        bsr     comma
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask destination reg
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;print it
        bra     disend

gra:    bra     ILLEG           ;not a valid instruction

grb:    move.w  d1,d0
        andi.w  #$00c0,d0       ;mask size bits
        cmpi.w  #$00c0,d0       ;size = 11 ?
        bne     CMP             ;no.
        lea     mCMPA,a0        ;yes, so load "CMPA"
        bsr     writs           ;write it
        bsr     dot
        move.w  d1,d0
        andi.w  #$0100,d0       ;mask CMPA size bit
        bne     CMPAl           ;if nonzero, longword operand
        move.b  #$77,d0         ;load 'W'
        move.b  d0,siz          ;save size as 'W'
        bsr     writ            ;write it
        bra     CMPAop          ;go write operands
CMPAl:  move.b  #$6c,d0         ;load 'L'
        move.b  d0,siz          ;save size as 'L'
        bsr     writ            ;write it
CMPAop: bsr     spc
        move.w  d1,d0
        bsr     writea          ;go write source operand
        bsr     comma
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask reg number
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wareg           ;write it
        bra     disend
CMP:    move.w  d1,d0
        andi.w  #$0100,d0       ;mask CMP/CMPM bit
        bne     CMPM            ;if nonzero, it's CMPM
        lea     mCMP,a0         ;load "CMP"
        bsr     writs           ;write it
        bsr     dot
        move.w  d1,d0
        bsr     findsiz         ;write size of operand
        bsr     spc
        move.w  d1,d0
        bsr     writea          ;write source operand
        bsr     comma
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask reg number
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;write it
        bra     disend
CMPM:   move.w  d1,d0
        andi.w  #$0038,d0       ;mask mode bits
        cmpi.w  #$0008,d0       ;is it address reg mode?
        bne     EOR             ;if not, it's an EOR
        lea     mCMPM,a0        ;load "CMPM"
        bsr     writs           ;write it
        bsr     dot
        move.w  d1,d0
        bsr     findsiz         ;write the operand size
        bsr     spc
        bsr     lparen
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask source reg bits
        bsr     wareg           ;write it
        bsr     rparen
        bsr     plus
        bsr     comma
        bsr     lparen
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask destination reg bits
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wareg           ;write it
        bsr     rparen
        bsr     plus
        bra     disend
EOR:    lea     mEOR,a0         ;load "EOR"
        bsr     writs           ;write it
        bsr     dot
        move.w  d1,d0
        bsr     findsiz         ;write operand size
        bsr     spc
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask reg number
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;write it
        bsr     comma
        move.w  d1,d0
        bsr     writea          ;write destination
        bra     disend

grc:    move.w  d1,d0
        andi.w  #$01f0,d0       ;mask for ABCD
        cmpi.w  #$0100,d0       ;is it ABCD?
        bne     MULS            ;no.
        lea     mABCD,a0        ;load "ABCD"
        bra     xBCD            ;go print everything
MULS:   move.w  d1,d0
        andi.w  #$00c0,d0       ;mask mode bits
        cmpi.w  #$00c0,d0       ;is this a MUL operation?
        bne     EXG             ;no.
        move.w  d1,d0           ;yes.
        andi.w  #$0100,d0       ;mask the sign bit
        beq     MULU            ;it's unsigned multiply
        lea     mMULS,a0        ;load "MULS"
        bsr     writs           ;write it
        bra     divprt          ;go decode the rest of the command
MULU:   lea     mMULU,a0        ;load "MULU"
        bsr     writs           ;write it
        bra     divprt          ;go decode the rest of the command
EXG:    move.w  d1,d0
        andi.w  #$0130,d0       ;mask for EXG
        cmpi.w  #$0100,d0       ;is it EXG?
        bne     AND             ;no.
        lea     mEXG,a0         ;yes, print
        bsr     writs           ;write it
        bsr     spc
        move.w  d1,d0
        andi.w  #$00f8,d0       ;mask op-mode bits
        cmpi.w  #$0040,d0       ;is it Di,Dj?
        bne     EXGaa           ;no
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask source reg number
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;write it
        bsr     comma
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask destination reg number
        bsr     wdreg           ;write it
        bra     disend
EXGaa:  cmpi.w  #$0048,d0       ;is it Ai,Aj?
        bne     EXGda           ;no
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask source reg number
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wareg           ;write it
        bsr     comma
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask destination reg number
        bsr     wareg           ;write it
        bra     disend
EXGda:  cmpi.w  #$0088,d0       ;is it Di,Aj?
        bne     ILLEG
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask source reg number
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;write it
        bsr     comma
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask destination reg number
        bsr     wareg           ;write it
        bra     disend
AND:    lea     mAND,a0         ;load "AND"
        bra     ANDent          ;go write the operation

grd:    lea     mADD,a0         ;load "ADD"
        bsr     writs           ;write it, then find out which ADD
        bra     ax              ;go find out which ADD it is

gre:    move.w  d1,d0
        move.w  d1,t1           ;save an extra copy of opcode
        andi.w  #$00c0,d0       ;is this an <ea> instruction?
        cmpi.w  #$00c0,d0
        bne     fshf            ;if not, find out which shift
        move.w  d1,d0           ;else adjust the saved opcode
        ror.w   #$06,d0         ;rightward by six bits to allow proper
        move.w  d0,t1           ;decoding of the shift type
fshf:   move.w  t1,d0           ;load the properly adjusted opcode
        andi.w  #$0018,d0       ;mask operation bits of adjusted opcode
        bne     LS              ;not AS
        lea     mAS,a0          ;load "AS"
        bra     lr              ;find the direction
LS:     cmpi.w  #$0008,d0       ;is it LS?
        bne     ROX             ;no
        lea     mLS,a0          ;yes, so load "LS"
        bra     lr              ;find the direction
ROX:    cmpi.w  #$0010,d0       ;is it ROX?
        bne     RO              ;no
        lea     mROX,a0         ;yes, so load "ROX"
        bra     lr
RO:     lea     mRO,a0          ;load "RO"
lr:     bsr     writs           ;write the operation
        move.w  d1,d0
        andi.w  #$0100,d0       ;mask the direction bit
        bne     lsh             ;left shift if bit set
        move.b  #$72,d0         ;load 'r'
        bra     shtyp           ;go find the shift type
lsh:    move.b  #$6c,d0         ;load 'l'
shtyp:  bsr     writ            ;write the direction
        move.w  d1,d0
        andi.w  #$00c0,d0       ;mask the size bits
        cmpi.w  #$00c0,d0       ;is the size 11?
        bne     regsh           ;if not, it's a reg shift
        bsr     spc
        move.w  d1,d0
        bsr     writea          ;write the operand
        bra     disend
regsh:  bsr     dot
        move.w  d1,d0
        bsr     findsiz         ;print the operand length
        bsr     spc
        move.w  d1,d0
        andi.w  #$0020,d0       ;mask the immediate/reg bit
        beq     immsh           ;if bit clear, it's an immediate shift
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask the count reg
        rol.w   #$07,d0         ;get into rightmost bits
        bsr     wdreg           ;write count reg
        bsr     comma
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask destination reg
        bsr     wdreg           ;write destination reg
        bra     disend
immsh:  bsr     spc
        bsr     pound
        bsr     dollar
        move.w  d1,d0
        andi.w  #$0e00,d0       ;mask the count bits
        rol.w   #$07,d0         ;get into rightmost bits
        bne     sh17            ;if not zero, 1-7 bit shift
        move.b  #$08,d0         ;if zero, 8 bit shift
sh17:   bsr     writb           ;write it
        bsr     comma
        move.w  d1,d0
        andi.w  #$0007,d0       ;mask the reg bits
        bsr     wdreg           ;write the destination reg
        bra     disend

grf:    bra     ILLEG           ;not a valid instruction

;
;       message table -- the ascii strings for the instructions
;
mCOPOUT: dc.b   "COPOUT",0
mABCD:   dc.b   "abcd",0
mADD:    dc.b   "add",0
mADDA:   dc.b   "adda",0
mADDI:   dc.b   "addi",0
mADDQ:   dc.b   "addq",0
mADDX:   dc.b   "addx",0
mAND:    dc.b   "and",0
mANDI:   dc.b   "andi",0
mAS:     dc.b   "as",0
mBCHG:   dc.b   "bchg",0
mBCLR:   dc.b   "bclr",0
mBKPT:   dc.b   "bkpt",0
mBRA:    dc.b   "bra",0
mBSET:   dc.b   "bset",0
mBSR:    dc.b   "bsr",0
mBTST:   dc.b   "btst",0
mCHK:    dc.b   "chk",0
mCLR:    dc.b   "clr",0
mCMP:    dc.b   "cmp",0
mCMPA:   dc.b   "cmpa",0
mCMPI:   dc.b   "cmpi",0
mCMPM:   dc.b   "cmpm",0
mDIVS:   dc.b   "divs",0
mDIVU:   dc.b   "divu",0
mEOR:    dc.b   "eor",0
mEORI:   dc.b   "eori",0
mEORIcr: dc.b   "eoriccr",0
mEXG:    dc.b   "exg",0
mEXT:    dc.b   "ext",0
mILLEG:  dc.b   "ILLEGAL",0
mJMP:    dc.b   "jmp",0
mJSR:    dc.b   "jsr",0
mLEA:    dc.b   "lea",0
mLINK:   dc.b   "link",0
mLS:     dc.b   "ls",0
mMOVE:   dc.b   "move",0
mMOVEA:  dc.b   "movea",0
mMOVEC:  dc.b   "movec",0
mMOVEM:  dc.b   "movem",0
mMOVEP:  dc.b   "movep",0
mMOVEQ:  dc.b   "moveq",0
mMULS:   dc.b   "muls",0
mMULU:   dc.b   "mulu",0
mNBCD:   dc.b   "nbcd",0
mNEG:    dc.b   "neg",0
mNEGX:   dc.b   "negx",0
mNOP:    dc.b   "nop",0
mNOT:    dc.b   "not",0
mOR:     dc.b   "or",0
mORI:    dc.b   "ori",0
mPEA:    dc.b   "pea",0
mRESET:  dc.b   "reset",0
mRO:     dc.b   "ro",0
mROX:    dc.b   "rox",0
mRTE:    dc.b   "rte",0
mRTR:    dc.b   "rtr",0
mRTS:    dc.b   "rts",0
mSBCD:   dc.b   "sbcd",0
mSTOP:   dc.b   "stop",0
mSUB:    dc.b   "sub",0
mSUBA:   dc.b   "suba",0
mSUBI:   dc.b   "subi",0
mSUBQ:   dc.b   "subq",0
mSUBX:   dc.b   "subx",0
mSWAP:   dc.b   "swap",0
mTAS:    dc.b   "tas",0
mTRAP:   dc.b   "trap",0
mTRAPV:  dc.b   "trapv",0
mTST:    dc.b   "tst",0
mUNLK:   dc.b   "unlk",0
mccr:    dc.b   "ccr",0
msr:     dc.b   "sr",0
musp:    dc.b   "usp",0

spc:    move.b  #$20,d0         ;load a spc
        bsr     writ            ;write it
        rts

comma:  move.b  #$2c,d0         ;load a comma
        bsr     writ            ;write it
        rts

lparen: move.b  #$28,d0         ;load a left parenthesis
        bsr     writ            ;write it
        rts

rparen: move.b  #$29,d0         ;load a right parenthesis
        bsr     writ            ;write it
        rts

pound:  move.b  #$23,d0         ;load a pound sign
        bsr     writ            ;write it
        rts

dot:    move.b  #$2e,d0         ;load a period
        bsr     writ            ;write it
        rts

plus:   move.b  #$2b,d0         ;load a plus
        bsr     writ            ;write it
        rts

minus:  move.b  #$2d,d0         ;load a minus
        bsr     writ            ;write it
        rts

dollar: move.b  #$24,d0         ;load a dollar sign
        bsr     writ            ;write it
        rts

findsiz:andi.w  #$00c0,d0       ;mask out the size bits
        bne     wsize           ;if nonzero, it's not a byte
        move.b  #$62,siz        ;set size to byte
        bra     findend
wsize:  cmpi.w  #$0040,d0       ;is it a word operand?
        bne     lsize           ;no.
        move.b  #$77,siz        ;set size to word
        bra     findend
lsize:  move.b  #$6c,siz        ;set size to longword
findend:move.b  siz,d0
        bsr     writ            ;write the size
        rts

wareg:  swap    d0              ;save the reg number in upper 16 bits
        move.b  #$61,d0         ;load 'a'
        bsr     writ            ;write it
        swap    d0              ;restore the reg number
        ori.b   #$30,d0         ;add offset to get digit
        bsr     writ            ;write it
        rts

wdreg:  swap    d0              ;save the reg number in upper 16 bits
        move.b  #$64,d0         ;load 'a'
        bsr     writ            ;write it
        swap    d0              ;restore the reg number
        ori.b   #$30,d0         ;add offset to get digit
        bsr     writ            ;write it
        rts

mPC:    dc.b    "pc",0
mIAM:   dc.b    "ILLEGAL ADDRESS MODE",0
writea: move.b  d0,writm        ;save the important part of the opcode
        andi.b  #$38,d0         ;mask off all but the mode bits
        bne     mode1           ;if zero, it's data reg direct
        move.b  writm,d0
        andi.b  #$07,d0         ;mask the reg number
        bsr     wdreg           ;write the data reg
        bra     eaout
mode1:  cmpi.b  #$08,d0         ;is it address reg direct?
        bne     mode2           ;no
        move.b  writm,d0        ;yes
        andi.b  #$07,d0         ;mask reg number
        bsr     wareg           ;write address reg
        bra     eaout
mode2:  cmpi.b  #$10,d0         ;is it address reg indirect?
        bne     mode3           ;no
        bsr     lparen          ;yes
        move.b  writm,d0
        andi.b  #$07,d0         ;mask reg number
        bsr     wareg           ;write address reg
        bsr     rparen
        bra     eaout
mode3:  cmpi.b  #$18,d0         ;is it postincrement?
        bne     mode4           ;no
        bsr     lparen          ;yes
        move.b  writm,d0
        andi.b  #$07,d0         ;mask reg number
        bsr     wareg           ;write address reg
        bsr     rparen
        bsr     plus
        bra     eaout
mode4:  cmpi.b  #$20,d0         ;is it predecrement?
        bne     mode5           ;no
        bsr     minus           ;yes
        bsr     lparen
        move.b  writm,d0
        andi.b  #$07,d0         ;mask reg number
        bsr     wareg           ;write address reg
        bsr     rparen
        bra     eaout
mode5:  cmpi.b  #$28,d0         ;is it reg indirect w/ displacement?
        bne     mode6           ;no
        bsr     dollar
        move.w  (a1)+,d0        ;yes, so load 16 bit displacement
        bsr     writw           ;write it
        bsr     lparen
        move.b  writm,d0
        andi.b  #$07,d0         ;mask reg number
        bsr     wareg           ;write address reg
        bsr     rparen
        bra     eaout
mode6:  cmpi.b  #$30,d0         ;is it reg indirect w/ index?
        bne     mode7           ;no
        bsr     dollar
        move.w  (a1),d0         ;load the index word
        bsr     writb           ;write the 8 bit displacement
        bsr     lparen
        move.b  writm,d0
        andi.b  #$07,d0         ;mask reg number
        bsr     wareg           ;write address reg
        bsr     comma
m6ad:   move.w  (a1),d0         ;load index word again
        bpl     m6d             ;if MSB of index word is 0, data reg
        rol.w   #$04,d0         ;rotate reg number into rightmost bits
        andi.w  #$0007,d0       ;mask reg number
        bsr     wareg           ;write address reg
        bra     m6no
m6d:    rol.w   #$04,d0         ;rotate reg number into rightmost bits
        andi.w  #$0007,d0       ;mask reg number
        bsr     wdreg           ;write data reg
m6no:   bsr     dot
        move.w  (a1)+,d0        ;load the index reg a final time
        andi.w  #$0800,d0       ;mask the length bit
        bne     m6l             ;if nonzero, long reg index
        move.b  #$77,d0         ;load 'w'
        bsr     writ            ;write it
        bsr     rparen
        bra     eaout
m6l:    move.b  #$6c,d0         ;load 'l'
        bsr     writ            ;write it
        bsr     rparen
        bra     eaout
mode7:  move.b  writm,d0        ;mode seven, so decode reg number
        andi.w  #$07,d0         ;mask reg number
        bne     m71             ;if zero, absolute.w
        bsr     dollar
        move.w  (a1)+,d0        ;move the address into d0
        bsr     writw           ;write it
        bra     eaout
m71:    cmpi.b  #$01,d0         ;is it absolute.l?
        bne     m72             ;no
        bsr     dollar
        move.l  (a1)+,d0        ;yes, so move the address into d0
        bsr     writl           ;write it
        bra     eaout
m72:    cmpi.b  #$02,d0         ;is it relative w/ displacement?
        bne     m73             ;no
        bsr     dollar
        move.w  (a1)+,d0        ;yes, so load displacement into d0
        bsr     writw           ;write it
        bsr     lparen
        lea     mPC,a0          ;load "PC"
        bsr     writs           ;write it
        bsr     rparen
        bra     eaout
m73:    cmpi.b  #$03,d0         ;is it relative w/ index?
        bne     m74             ;no
        bsr     dollar
        move.w  (a1),d0         ;load the index word
        bsr     writb           ;write the 8 bit displacement
        bsr     lparen
        lea     mPC,a0          ;load "PC"
        bsr     writs           ;write it
        bsr     comma
        bra     m6ad            ;go to reg. indir. routine to finish
m74:    cmpi.b  #$04,d0         ;is it immediate?
        bne     m75             ;no
        bsr     pound
        bsr     dollar
        move.b  siz,d0          ;load the size byte
        cmpi.b  #$62,d0         ;is it byte data?
        bne     m74w            ;no
        move.w  (a1)+,d0        ;yes, so load immediate data
        bsr     writb           ;write byte data
        bra     eaout
m74w:   cmpi.b  #$77,d0         ;is it word data?
        bne     m74l            ;no
        move.w  (a1)+,d0        ;yes, so load immediate data
        bsr     writw           ;write word data
        bra     eaout
m74l:   move.l  (a1)+,d0        ;load long immediate data
        bsr     writl           ;write long data
        bra     eaout
m75:    lea     mIAM,a0         ;load illegal mode message
        bsr     writs           ;write it
eaout:  rts

wdis:   swap    d0              ;save opcode in upper 16 so we can
        bsr     dollar          ;hexidecimalize the displacement
        swap    d0              ;get it back in lower 16
        move.l  a1,d1           ;copy current address to d1
        tst.b   d0              ;is displacement zero?
        beq     wdisw           ;if so, word displacement
        andi.l  #$00ff,d0       ;mask off the displacement
        ext.w   d0              ;sign extend the displacement
        ext.l   d0              ;to word size
        add.l   d0,d1           ;add 8-bit displacement to address
        move.l  d1,d0           ;copy into d0
        bsr     writl           ;write address
        bra     wdiso
wdisw:  move.w  (a1)+,d0        ;load the displacement word
        ext.l   d0              ;sign extend it
        add.l   d0,d1           ;add displacement
        move.l  d1,d0           ;copy to d0
        bsr     writl
wdiso:  rts
;
