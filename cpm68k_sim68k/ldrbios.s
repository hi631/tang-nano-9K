*****************************************************************
*                                                               *
*               CP/M-68K Loader BIOS                            *
*       Basic Input/Output Subsystem                            *
*       For simulated 68000 system                              *
*                                                               *
* Simulated memory runs from 0 to $ffffff with simulated        *
* peripherals in some locations above $ff0000.                  *
*                                                               *
* A prebooter is not required since the entire system track     *
* gets loaded to address $400                                   *
*                                                               *
*****************************************************************

        .globl  _bios

DMA:    .equ    $ff0000
DRIVE:  .equ    $ff0004
SECTOR: .equ    $ff0008
READ:   .equ    $ff000c
WRITE:  .equ    $ff0010
STAT:   .equ    $ff0014
FLUSH:  .equ    $ff0018

SYSMODE  .equ   $FF0F00
ACIASTAT .equ   $ff1000
ACIADATA .equ   $ff1002

C_SETCMD: .equ $ff0100
C_SETADR: .equ $ff0102
C_BUF:    .equ $FF0200

        .text

_init:  lea.l   initmsg,a1      * print startup message
        bsr     prtstr
        rts

_bios:  cmp     #nfuncs,d0
        bge     trapng
        lsl     #2,d0           * multiply bios function by 4
        lea.l   biosbase,a0     * get handler address
        move.l  (a0,d0),a0
        jmp     (a0)            * call handler

trapng: move.l  #1,d0
        rts



* Conole I/O uses a simulated 6850 ACIA

conout: btst    #1,ACIASTAT     * check for transmitter buffer empty
        beq     conout          * wait until port is ready
        move.b  d1,ACIADATA     * and output it
        rts                     * and exit

*       select disk C
seldsk: move.l  #dph2,d0
        rts

settrk: move.w d1,track
        rts
setsec: move.w  d1,sector
        rts

*       translate sector in d1 with translate table pointed to by d2
*       result in d0
*       No translation required here
sectran:
        move.l  d1,d0
        rts

setdma: move.l  d1,DMA
        move.l  d1,_dma
        rts

*read:   move.l  #2,DRIVE
*        move.w  dpb2,d1         * get sectors/track
*        move.w  track,d0
*        mulu    d1,d0           * calculate sector address
*        move.w  sector,d1
*        ext.l   d1
*        add.l   d1,d0
*        move.l  d0,SECTOR       * set sector address
*        move.l  d0,READ         * send disk command
*        move.l  STAT,d0         * get result
*        rts

read:   move.l  #READ,a1        * load read command address
        move.w  #2,drive
        bra     diskio
write:  move.l  #WRITE,a1       * load write command

diskio:
*	move.w	C_SETCMD,d0
*  	btst.l	#7,d0				* Disk.io ORG/NEW Select
*    beq		diskioorg
*    dc.w    $6004,$4e72,$0000,$4e71 * Break

diskionew:
    clr.l       d0      ;
    move.w      drive,d0        ; get drive number
    
    cmp.w	#2,d0
    bne		diskion2
    move.l	#$0000,d1			; sector offset C:0000 - A:8000 - B:8800
    bra		diskion4
diskion2:
    cmp.w	#1,d0
    bne 	diskion3
    move.l	#$8800,d1
    bra		diskion4
diskion3:
	cmp.w	#0,d0
    bne		diskerr
    
*    move.w	track,d1
*    bsr		h4out
*    bsr		spout
*    move.w	sector,d1
*    bsr		h4out
    
    move.l	#$8000,d1
    
diskion4:
    move.l      d0,DRIVE
	move.l		d1,-(a7)
    asl.l       #2,d0           ; index into dph table
    lea.l       dphtab,a0
    move.l      0(a0,d0),d0     ; get dph address
    beq         diskerr
    move.l      d0,a0
    move.l      14(a0),a0       ; load dpb address
    move.w      (a0),d1         ; and finally, sectors/track
    move.w      track,d0        ;
    mulu        d1,d0       	; 
    clr.l       d1
    move.w      sector,d1
    add.l       d1,d0			; d0 = sector

*	tst.w	C_DBGFLG
    btst.b  #1,SYSMODE+1
	beq		diskionx
	movem.l d0/d1/a0/a1,-(a7)
	move.l	d0,d1	; !
	bsr		h8out	; !
	bsr		spout	; !
	movem.l (a7)+,d0/d1/a0/a1
diskionx:

    move.l      d0,SECTOR       ; set sector

    move.l  d0,d1
    and.l   #3,d1
    asl.l   #7,d1          ; d1 = 0 - $80 - $100 - $180 Data.Point
    asr.l   #2,d0          ; 512B/Sector Sector.Addr
    
    move.l  #C_BUF,a0      ;
    add.l   d1,a0

	move.l		(a7)+,d1
    add.l		d1,d0			; add offset(A:B:C:)

    cmp.l   rdsect,d0
    beq     diskion5		; Already read 

    move.l  d0,rdsect
    move.w  d0,C_SETADR+2
    swap.w  d0
    move.w  d0,C_SETADR
	move.l 	#2,DRIVE		; Selct SDCD
    move.w  #$0001,C_SETCMD ; Read 512B
    bsr     cmdchk
*    move.l  rdsect,d0
*    bsr     sctout1

diskion5:
*    bsr     sctout2
    move.w  #32-1,d0
    cmp.l   #WRITE,a1
    beq     sdwr

sdrd:
    move.l  _dma,a1
sdrlp:
    move.l  (a0)+,(a1)+   ; SD -> DMA
    dbra    d0,sdrlp
    bra     diskend

sdwr:
    move.l  _dma,a1
sdwlp:
    move.l  (a1)+,(a0)+   ; DMA -> SD
    dbra    d0,sdwlp
    move.w  #$0002,C_SETCMD ; write 512B
    bsr     cmdchk

diskend:
    move.l  STAT,d0
    rts

cmdchk:
	move.w	C_SETCMD,d0
    btst.l	#0,d0
    bne		cmdchk
    rts

diskioorg:
	clr.l   d0
    move.w  drive,d0
    move.l  d0,DRIVE
    asl     #2,d0
    lea.l   dphtab,a0       * index into dph table to get tracks/sector
    move.l  (a0,d0.w),d0
    beq     diskerr         * invalid dph
    move.l  d0,a0
    move.l  14(a0),a0       * get dpb address
    move.w  (a0),d1         * tracks/sector
    move.w  track,d0
    mulu    d1,d0           * calculate sector address
    clr.l   d1
    move.w  sector,d1
    add.l   d1,d0

    move.l  d0,SECTOR       * set sector address
    move.l  d0,d1                   * dump
    move.l  d0,(a1)         * send disk command
    move.l  #0,d0
    move.l  STAT,d0         * get result
    rts
diskerr:
    move.l  #1,d0
    rts

dumpd:
    movem.l d0/d1/a0/a1,-(a7)
    bsr     h8out
    move.w  d0,d1
    bsr     h4out
    bsr     spout
    move.l  _dma,a1
    move.l  #128-1,d0
dumpd2:
    move.b  (a1)+,d1
    bsr     h2out
    bsr     spout
    dbra    d0,dumpd2
    bsr     crout
    movem.l (a7)+,d0/d1/a0/a1
        rts
h1out:                          * input D1
        and.b   #$000f,d1
    cmp.b       #9,d1
    ble         h1out1
        add.w   #7,d1
h1out1:
        add.b   #$30,d1
    bsr         conout
    rts
h2out:
        and.w   #$00ff,d0
        move.w  d1,-(a7)
    asr.w       #4,d1
    bsr         h1out
    move.w      (a7)+,d1
    and.w       #$f,d1
    bsr         h1out
    rts
h4out:
        move.w  d1,-(a7)
        asr.w   #8,d1
    bsr         h2out
    move.w      (a7)+,d1
    and.w       #$00ff,d1
    bsr         h2out
    rts
h8out:
        move.w  d1,-(a7)
        swap.w  d1
    bsr         h4out
    move.w      (a7)+,d1
        bsr             h4out
    move.b      #$20,d1
    bsr         conout
    rts
spout:
        move    #$20,d1
    bra         cxout
crout:
        move.b  #$0d,d1
    bsr         conout
    move.b      #$0a,d1
    bsr         conout
    rts
cxout:
    bsr         conout
    rts


getseg:
        move.l  #memrgn,d0      * return address of mem region table
        rts

* Set an exception vector.

setexc:
        andi.l  #$ff,d1         * do only for exceptions 0 - 255
        lsl     #2,d1           * multiply exception nmbr by 4
        movea.l d1,a0
        move.l  (a0),d0         * return old vector value
        move.l  d2,(a0)         * insert new vector
noset:  rts

prtstr: move.b  (a1)+,d1
        beq     prdone
        bsr     conout
prdone: rts

        .data
initmsg:
        .dc.b   13,10,'CP/M-68K Loader Ver. 1.0',13,10,0
        .even
biosbase:
        .dc.l  _init
        .dc.l  trapng
        .dc.l  trapng
        .dc.l  trapng
        .dc.l  conout
        .dc.l  trapng
        .dc.l  trapng
        .dc.l  trapng
        .dc.l  trapng
        .dc.l  seldsk
        .dc.l  settrk
        .dc.l  setsec
        .dc.l  setdma
        .dc.l  read
        .dc.l  trapng
        .dc.l  trapng
        .dc.l  sectran
        .dc.l  trapng
        .dc.l  getseg
        .dc.l  trapng
        .dc.l  trapng
        .dc.l  trapng
        .dc.l  setexc

        nfuncs=(*-biosbase)/4

track:  .dc.w   0       * track requested by settrk
sector: .dc.w   0
rdsect:	.dc.l	0

memrgn: dc.w    1       * Not used in loader
        dc.l    $0000
        dc.l    $7e0000

* add

drive:  .dc.w   0
*track:  .dc.w   0       * track requested by settrk
*sector: .dc.w   0
_dma:   .dc.l   0

* Table of pointers to dph structures
* A zero entry indicates that the drive doesn't exist
dphtab: .dc.l   dph0    * A
        .dc.l   dph1    * B
        .dc.l   dph2    * C
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   dphM    * M
        .dc.l   0
        .dc.l   0
        .dc.l   0

* disk parameter headers
*
* dph0 and dph1 are simulated removable floppy disks so they have a check
* vector.

dph0:   .dc.l   xlt0
        .dc.w   0
        .dc.w   0
        .dc.w   0
        .dc.l   dirbuf  * ptr to directory buffer
        .dc.l   dpb0    * ptr to disk parameter block
        .dc.l   ckv0    * ptr to check vector
        .dc.l   alv0    * ptr to allocation vector

dph1:   .dc.l   xlt1
        .dc.w   0       * dummy
        .dc.w   0
        .dc.w   0
        .dc.l   dirbuf  * ptr to directory buffer
        .dc.l   dpb1    * ptr to disk parameter block
        .dc.l   ckv1    * ptr to check vector
        .dc.l   alv1    * ptr to allocation vector

dph2:   .dc.l   0       * no skew on simulated harddisk
        .dc.w   0       * dummy
        .dc.w   0
        .dc.w   0
        .dc.l   dirbuf  * ptr to directory buffer
        .dc.l   dpb2    * ptr to disk parameter block
        .dc.l   0       * ptr to check vector
        .dc.l   alv2    * ptr to allocation

dphM:   .dc.l   0       * no skew on simulated harddisk
        .dc.w   0       * dummy
        .dc.w   0
        .dc.w   0
        .dc.l   dirbuf  * ptr to directory buffer
        .dc.l   dpb2    * ptr to disk parameter block
        .dc.l   0       * ptr to check vector
        .dc.l   alvM    * ptr to allocation

* sector translate table

xlt0:   .dc.w   0,6,12,18,24,4,10,16,22,2,8,14,20
        .dc.w   1,7,13,19,25,5,11,17,23,3,9,15,21
xlt1:   .dc.w   0,1,2,3,4,5,6,7
        .dc.w   16,17,18,19,20,21,22,23
        .dc.w   32,33,34,35,36,37,38,39
        .dc.w   8,9,10,11,12,13,14,15
        .dc.w   24,25,26,27,28,29,30,31


**********
* orignal
**********

* disk parameter block

* Simulated standard 8" SS SD drive
dpb0:   .dc.w   26      * sectors per track
        .dc.b   3       * block shift
        .dc.b   7       * block mask
        .dc.b   0       * extent mask
        .dc.b   0       * dummy fill
        .dc.w   242     * disk size
        .dc.w   63      * 192 directory entries
        .dc.w   $0000   * directory mask
        .dc.w   16      * directory check size
        .dc.w   2       * track offset

* Simulated 5.25" DSDD 80 track disk of 800K
* Use eagle4 entry in cpmtools diskdefs

dpb1:   .dc.w   40      * sectors per track
        .dc.b   4       * block shift
        .dc.b   15      * block mask
        .dc.b   0       * extent mask
        .dc.b   0       * dummy fill
        .dc.w   392     * disk size
        .dc.w   191     * 64 directory entries
        .dc.w   $0000   * directory mask
        .dc.w   48      * directory check size
        .dc.w   2       * track offset

* Simulated 16MB hard disk
dpb2:   .dc.w   256     * sectors per track
        .dc.b   4       * block shift (2K block size)
        .dc.b   15      * block mask
        .dc.b   0       * extent mask
        .dc.b   0       * dummy fill
        .dc.w   8176    * disk size
        .dc.w   4095    * 4096 directory entries
        .dc.w   0       * directory mask
        .dc.w   0       * directory check size
        .dc.w   1       * track offset

*dph2:   .dc.l   0       * no skew on simulated harddisk
*        .dc.w   0       * dummy
*        .dc.w   0
*        .dc.w   0
*        .dc.l   dirbuf  * ptr to directory buffer
*        .dc.l   dpb2    * ptr to disk parameter block
*        .dc.l   0       * ptr to check vector
*        .dc.l   0       * ptr to allocation vector

* Simulated 16MB hard disk
*dpb2:   .dc.w   256     * sectors per track
*        .dc.b   4       * block shift (2K block size)
*        .dc.b   15      * block mask
*        .dc.b   0       * extent mask
*        .dc.b   0       * dummy fill
*        .dc.w   8191    * disk size
*        .dc.w   4095    * 4096 directory entries
*        .dc.w   0
*        .dc.w   0       * directory check size
*        .dc.w   1       * track offset

        .bss

*dirbuf: .ds.b   128     * directory buffer


* add

        .bss

*rdsector:
*                ds.l    0


dirbuf: .ds.b   128     * directory buffer

ckv0:   .ds.b   18      * check vector
ckv1:   .ds.b   48

alv0:   .ds.b   64      * allocation vector
alv1:   .ds.b   64
alv2:   .ds.b   1024
alvM:   .ds.b   1024

        .end
