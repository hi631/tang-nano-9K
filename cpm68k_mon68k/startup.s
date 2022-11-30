;-------------------------------------------------------
;
;       Sega startup code for the Sozobon C compiler
;       Written by Paul W. Lee
;       Modified from Charles Coty's code
;
;-------------------------------------------------------
        .globl _OUTCH
        .globl _INCH
        .globl _KBHIT
        .globl _EXEC

prgbase .equ   $ff4000		; Hi_Mon68K Start.Addr
;prgbase .equ   $000000		;    Mon68K Start.Addr
mramtop .equ   $ff2000
monsp   .equ   $ff4000-4	; Hi_Mon68K Stack
wkbase  .equ   $ff2400

mramsize .equ   $002000
runssp   .equ   $7e0000-4
runusp   .equ   runssp-$10000
sysport  .equ   $ff0f00
acias    .equ   $ff1000
aciad    .equ   $ff1002

svtop   .equ   wkbase+0
svmode	.equ   svtop+0
svsr    .equ   svtop+2
svstpct .equ   svtop+1*4          ; Stop.counte
svpc    .equ   svtop+2*4          ; (4)
svssp   .equ   svtop+3*4          ; ssp work
svusp   .equ   svtop+4*4
svd0    .equ   svtop+5*4          ; D0-D7/A0-A6/
sva7    .equ   svd0+15*4          ; A7
svw0	.equ   sva7+1*4
svw1	.equ   svw0+1*4
svw2	.equ   svw0+2*4
svw3	.equ   svw0+3*4
svw4	.equ   svw0+4*4
svw5	.equ   svw0+5*4
svw6	.equ   svw0+6*4
svw7	.equ   svw0+7*4		    ; D0-D7/A0-A6/
svtmp   .equ   svw7+1*4
svmr0	.equ   svw7+2*4			; regsave(for mon)

    org    prgbase+$0

	dc.l monsp,coldent
	dc.l trap02,trap03,trap04,trap05,trap06,trap07         ;
	dc.l trap08,trap09,trap0a,trap0b,trap0c,trap0d,trap0d,trap0f ; $20
	dc.l trapxx,trapxx,trapxx,trapxx,trapxx,trapxx,trapxx,trapxx ; $40
	dc.l trapxx,trapxx,trapxx,trapxx,trapxx,trapxx,trapxx,NMI    ; $60
	dc.l trapxx,trapxx,trapxx,trapxx,trapxx,trapxx,trapxx,trapxx ; $80
	dc.l trapxx,trapxx,trapxx,trapxx,trapxx,trapxx,trapxx,trapxx ; $A0
	dc.l trapxx,trapxx,trapxx,trapxx,trapxx,trapxx,trapxx,trapxx ; $C0
	dc.l trapxx,trapxx,trapxx,trapxx,trapxx,trapxx,trapxx,trapxx ; $E0

	    org    prgbase+$100
		bra     t_sp
		bra     t_move
		bra     t_sr
		bra     t_rw
		bra     t_outch

t_sp:   nop
        move.l  a7,$3fc
		lea     $3f8,a7
		lea     $3e8,a0
        move.w  #$1234,d6
		move.w  #$5678,d7
		move.b  d7,-(a0)
		move.b  d7,-(sp)
		nop
		move.b  d6,-(a0)
		move.b  d6,-(sp)
        nop
		move.b  (sp)+,d0    ; b -> b
		move.w  d7,-(sp)
		move.b  (sp)+,d1    ; w -> b
		move.b  d7,-(sp)
		move.w  (sp)+,d2    ; b -> w
		move.l  $3fc,a7
		nop
		rts

t_move:	nop
        move.l  #$11111111,d0
		move.l  #$22222222,d0
		move.l  #$33333333,d0
		move.l  #$44444444,d0
		move.l  #$55555555,d0
		nop
		rts

t_sr:   nop
        move.w  #$2700,sr
        nop
		move.l  a7,d0
		move.l  usp,a0
		move.w  #$0700,sr
		nop
		move.l  a7,d0
		move.l  usp,a0      ; trap=08
		nop
		nop
		nop
        rts

t_rw:   nop
		move.w  #$1234,$200
		nop
		move.w  $200,d0
		rts

t_outch:
		move.b  #$03,acias
        move.b  #$15,acias
t_outch2:
        move.b  #$4D,d0
        bsr     OUTCH
        move.b  #$4F,d0
        bsr     OUTCH
        move.b  #$4E,d0
        bsr     OUTCH
        move.b  #$20,d0
        bsr     OUTCH
		bra		t_outch2

		org    prgbase+$400
coldent:
        move.l	#monsp,a7
        bsr     setsio
		bsr     clrregw

hi_mon:
        move.l  #prgbase,d0
        cmp.l   #0,d0
        beq     cmain
		move.w  #$00c0,d0       ; Start.up CP/M-68K
;		move.w  #$0080,d0       ; Start.up Monitor
		move.w  d0,sysport      ; CutOff BaseROM
		move.w	d0,svmode
        bsr		movevct         ; mon.vect -> (0)
cmain:  
        bsr     disphl
        move.w	ssrn,svsr
        move.l	#monsp,a7
		bsr     setwsp
		move.l  #NMI,$7c        ; Vector(NMI) set
        bclr.b  #4,sysport      ; Break(NMI).Disable

        move.l	#svtop,-(sp)    ; Reg.Work.Top
		jsr     _main
        addq.w	#4,sp
        bra     coldent

setsio: move.b  #$03,acias
        move.b  #$15,acias
        move.b  #$0d,d0
        bsr     OUTCH
        rts
setwsp: move.l  #runssp,svssp
		move.l	#execrtn,runssp
        move.l  #runusp,svusp
		move.l	#execrtn,runusp
        rts
disphl: btst    #7,svmode+1
		bne     disphle
        move.b  #$5f,d0         ; _
        bsr     OUTCH
disphle:rts
clrregw:move.l  #svtop,a0
		move.l  #63,d0
clrreg2:move.l  #0,(a0)+
        dbra    d0,clrreg2
        rts
movevct:
		move.l	#prgbase,a0
		move.l  #0,a1
        move.l	#64-1,d0        ; 0 - $100
movevct2:
		move.l	(a0)+,(a1)+
        dbra	d0,movevct2
        rts

_EXEC:
		cmp.l   #prgbase+$400,svpc
		bge     execrtn1

		movem.l d0-d7/a0-a7,svmr0	; save monitor regs
		move.l  #NMI,$7c              ; Vector(NMI) set
		move.l  svssp,sp            ; Set ssp
		move.l  svusp,a0
		move.l  a0,usp              ; Set usp
    	move.l	svpc,-(a7)          ; Set Trarget pc
        move.w	svsr,-(a7)
        movem.l svd0,d0-d7/a0-a6	; load target.regs
        bset.b  #4,sysport          ; Break(NMI).Enable
    	rte							; jump target
execrtn:
        bclr.b  #4,sysport
        movem.l d0-d7/a0-a6,svd0    ; save target.regs
        move.l  sp,svssp
        move.l  usp,a0
        move.l  a0,svusp
execrtn1:
        bset.b  #5,svmode           ; return form rts
		lea 	rts_rtn,a0
		bsr     puts
       	movem.l svmr0,d0-d7/a0-a7   ; load mon.regs
        bra     cmain               ; retrun to monitor
rts_rtn: dc.b   $0a,$0d,"(rts)",$0a,$0d,0

NMI:
INT:
        move.w  $0(a7),svsr			; Save SR
        move.l  $2(a7),svpc         ; Save PC
        add.l	#6,a7               ; Stack.Data Clear
execrtn2:
        bclr.b  #4,sysport
        movem.l d0-d7/a0-a6,svd0    ; save target.regs
        move.l  sp,svssp
        move.l  usp,a0
        move.l  a0,svusp
		btst.b  #5,svsr             ; run system/user
		beq     execrtn3
		move.l  sp,a0
execrtn3:
        move.l  a0,sva7
        move.w  ssrn,sr             ; Set  SR(disable interrupts)
       	movem.l svmr0,d0-d7/a0-a7   ; load mon.regs
        rts							; retrun to monitor

trapxx:
        move.w  #$ff,-(sp)
trapin:
        move.w  (sp)+,svtmp         ; Trap.No
        movem.l d0/a0,-(sp)
		lea 	er_trap,a0
		bsr     puts
		move.w  svtmp,d0
		bsr     h2out
		lea     tb_crlf,a0
		bsr     puts
        movem.l (sp)+,d0/a0
        bra     NMI
er_trap:dc.b    $0a,$0d,"Trap=",0
tb_crlf:dc.b    $0a,$0d,0,0

ssri:   dc.w    $2000
ssrn:   dc.w    $2700               ;same w/o interrupts

;-- Trap Table ----------------
trap02: move.w  #$02,-(sp)
        bra     trapin
trap03: move.w  #$03,-(sp)
        bra     trapin
trap04: move.w  #$04,-(sp)
        bra     trapin
trap05: move.w  #$05,-(sp)
        bra     trapin
trap06: move.w  #$06,-(sp)
        bra     trapin
trap07: move.w  #$07,-(sp)
        bra     trapin
trap08: move.w  #$08,-(sp)
        bra     trapin
trap09: move.w  #$09,-(sp)
        bra     trapin
trap0a: move.w  #$0a,-(sp)
        bra     trapin
trap0b: move.w  #$0b,-(sp)
        bra     trapin
trap0c: move.w  #$0c,-(sp)
        bra     trapin
trap0d: move.w  #$0d,-(sp)
        bra     trapin
trap0e: move.w  #$0e,-(sp)
        bra     trapin
trap0f: move.w  #$0f,-(sp)
        bra     trapin

;-- Basic I/O -------------------
puts:   cmp.b   #0,(a0)
        beq     putse
		move.b  (a0)+,d0
		bsr     OUTCH
		bra     puts
putse:  rts

_OUTCH: 
	link	a6,#0
	move.b	9(a6),d0
	ext.w	d0
	move.w	d0,-(sp)
	jsr	    OUTCH
	unlk	a6
	rts

OUTCH:  move.w	d0,-(sp)
OUTCH2: move.b  acias,d0
        btst    #$1,d0
        beq     OUTCH2
        move.w	(sp)+,d0
        move.b  d0,aciad
        rts

_INCH:
INCH:   move.b  acias,d0
        btst    #$00,d0
        beq     INCH
        clr.l   d0
        move.b  aciad,d0
        rts

spout:
        move    #$20,d0
        bra     OUTCH
h1out:
        and.b   #$000f,d0
        cmp.b   #9,d0
        ble     h1out1
        add.w   #7,d0
h1out1:
        add.b   #$30,d0
        bsr     OUTCH
        rts
h2out:
        and.w   #$00ff,d0
        move.w  d0,-(a7)
        asr.w   #4,d0
        bsr     h1out
        move.w  (a7)+,d0
        and.w   #$f,d0
        bsr     h1out
        rts
h4out:
        move.w  d0,-(a7)
        asr.w   #8,d0
        bsr     h2out
        move.w  (a7)+,d0
        and.w   #$00ff,d0
        bsr     h2out
        rts
h8out:
        move.l  d0,-(a7)
        move.w  (a7)+,d0
        bsr     h4out
        move.w  (a7)+,d0
        bsr     h4out
        rts

_KBHIT: clr.l   d0
        move.b  acias,d0
        and.b   #$01,d0
        rts

; --- Do nothing for this demo ---
HBL:
	rte

; --- Do nothing for this demo ---
VBL:
	rte
