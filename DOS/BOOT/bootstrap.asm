.186
.model tiny
.code

BIOSSIZE    EQU     16      ; sectors
;BOOTOFFSET  EQU     0fc00h  ; bootstrap code offset in segment 0f000h
BOOTOFFSET  EQU     0cc00h  ; bootstrap code offset in segment 0f000h
POFS        EQU     BOOTOFFSET - begin
MONSEG      EQU     0f000h
RSDATA		EQU		03fch	; 03f8h(com1)
RSRXBSY		EQU		03fdh	; 03f9h
RSTXRDY		EQU		03feh	; 03fah
BOOTSW		EQU		03ffh	;

WORKTOP		EQU		0C800h
SAVECS		EQU		WORKTOP+000h
SAVEIP		EQU		WORKTOP+002h
SAVESS		EQU		WORKTOP+004h
SAVESP		EQU		WORKTOP+006h
SAVEBX		EQU		WORKTOP+00eh
CMDBUF		EQU		WORKTOP+010h
WADDR		EQU		CMDBUF+020h
WDATA		EQU		WADDR+002h
WDTDL		EQU		WADDR+004h
WDT0		EQU		WADDR+006h
WSEG		EQU		WADDR+008h
; this code is for bootstrap deployment only, it will not be present in ROM (cache)
;---------------- EXECUTE -----------------

; Loads BIOS (8K = 16 sectors) from last sectors of SD card (if present)
; If no SD card detected, wait on RS232 115200bps and load program at F000:100h
; the following code is placed in the last 1kB of cache (last 4 lines), each with the dirty bit set
; the corresponding position in RAM will be F000:BOOTOFFSET
; ----------------- RS232 bootstrap - last 256byte cache line ---------------

		org		000h        ; this code is loaded at 0f000h:f000h
exec    label near
;-- Debug Program ------
memprg:
		mov		dx,ss
		mov		ax,0e000h
		mov		ss,ax
		mov		ax,01234h
		mov		bx,05678h
		push	ax
		pop		ax
		mov		ss,dx
		mov		cx,09abch
		ret
memprge:

dbgdmy:
        nop
		mov		ax,ss
		mov     word ptr ds:[SAVESS], ax
		mov		ax,sp
		mov     word ptr ds:[SAVESP], ax
		nop
        nop
        ret

retnmi:
        push    sp
		push    bx
        push    ss
		push    es
		push    ds
		push    cs
		push    bp
		push    di
		push    si
		push    dx
		push    cx
		push    bx
        push    ax
		
		push	cs
		pop		ds							; ds = cs
		mov		word ptr ds:[SAVESS],ss
		mov		word ptr ds:[SAVESP],sp
        mov     bx,sp						; bx = reg.arry.top
		mov		word ptr ds:[SAVEBX],bx
		mov		ax,ss:[bx+26]
		mov		word ptr ds:[SAVEIP],ax

		cli
		cld
		mov		ax, cs        ; cs = 0f000h
		mov		ds, ax
		mov		es, ax
		mov		ss, ax
		mov		sp, BOOTOFFSET-040h

		mov		ax,ds:[SAVESS]
		call	puth4
		call	putsp
		mov		ax,ds:[SAVESP]
		call	puth4
		call	putsp
		mov		ax,ds:[SAVEIP]
		call	puth4
		call	putsp
		call	putcrlf

		mov		bx,ds:[SAVEBX]
		call	bkdisp
		call	ipdisp

        call    dbgloop
		mov		ss,ds:[SAVESS]
		mov		sp,ds:[SAVESP]
;		call	settsig

        pop     ax
		pop     bx
		pop     cx
        pop     dx
		pop     si
		pop     di
		pop     bp
;		pop		sp
		add     sp,2		; skip
		pop     ds
		pop     es
;		pop     ss
		add     sp,2		; skip
		pop     bx
		pop     sp
        iret

ipdisp:
		call	putcrlf
		mov		si,ds:[SAVEIP]	; IP
		push	cs
		pop		es
		call	dpadr
		mov		cx,4
ipdisp2:mov		al,[si]
		call	puth2
		call	putsp
		inc		si
		loop	ipdisp2
		ret

;                 00              16        26
ppsregs  db      'AXBXCXDXSIDIBP  DSESSS  SPIPCSSF'
bkdisp:
        mov     cx,16
        mov		si,ppsregs + POFS
		mov		ax,ds:[SAVESS]
		mov		es,ax
;		call    putcrlf
rloop:  mov     al,[si]
        cmp     al,20h
		jnz     rloop2
		inc     si
		inc     si
		jmp     rloop3
rloop2: call    putch
		inc     si
		mov     al,[si]
		call    putch
		inc     si
		mov     al,3ah
		call    putch
        mov     ax,es:[bx]
        call    puth4
		call    putsp
rloop3:	inc     bx
		inc     bx
		cmp     cl,10
		jnz     rloop4
		call    putcrlf
rloop4:	loop    rloop
		ret

dtest:
		call	dtestex
		ret
dtestex:
		push	dx
		and		dl,0f0h
		jz		dtest0
        call    nmivset
		mov     dx,settsig+3 + POFS
		call    brkaset
dtest0:
		pop		dx
		and		dl,00fh
        cmp     dl,1
		jz      dtest1		; RAM No.CE
		cmp     dl,2
		jz      dtest2		; RAM One.CE
		cmp     dl,3
		jz      dtest3		; Dram Use.CE

dtest1: mov		si, memprg + POFS
		mov		di, 0c900h
		mov		cx, memprge - memprg
		rep		movsb
		mov		bx,0c900h
		mov     si,0c910h
		mov		di,0c920h
		jmp		dtest9

dtest2: mov		si, memprg + POFS
		mov		di, 0ca00h
		mov		cx, memprge - memprg
		rep		movsb
        mov     bx,0ca00h
		mov     si,0ca10h
		mov		di,0ca20h
		jmp		dtest9

dtest3:	mov		si, memprg + POFS
		mov		di, 0000h
		mov		cx, memprge - memprg
		rep		movsb
		mov     bx,0000h
		mov     si,0010h
		mov		di,0020h
dtest9:
		mov		cx,4
		call	settsig
		jmp		bx
settsig:
		mov		bp,0cfffh
		mov		al,cs:[bp]		; trigger
		ret

;-------------------------------
dbgcold:
		mov		DS:[WSEG],cs
		call	dinit
		mov		es,DS:[WSEG]
		call	bootchk
        mov		si,ppimsg + POFS
		call    puts
dbgloop:
		mov		es,DS:[WSEG]
        mov		si,ppcmsg + POFS
		call    puts
		call    getsb
        mov     si,CMDBUF+1
		mov     al,[si]
		cmp     al,66h
		jbe     dbgnx1          ; jmp al >= 'f'(66h)
		inc     si              ; cchhhh  cc:2byte cmd  hhhh:hexdata
dbgnx1:
		call    gethx           ; dx = Mem.Addr
		mov     di,CMDBUF
		mov     al,[di]
		mov     ah,[di+1]
		cmp     al,64h          ; d:dump
		jnz     dbgnx2
        cmp     ah,6eh          ; dn NMI.Test
		jnz     dbgnx12
        call    nmivset
		mov     dx,dbgdmy + POFS
		call    brkaset
		mov     ax,01234h
		mov     bx,05678h
		call    dbgdmy
		jmp     dbgnxe
dbgnx12:
        cmp     ah,74h          ; dt Test.Data
        jnz     dbgnx13
        call    dtest
        jmp     dbgnxe
dbgnx13:
		call    dump
		jmp     dbgnxe
dbgnx2:
		cmp     al,6dh          ; m:mem
		jnz     dbgnx3
		call    memrw
		jmp     dbgnxe
dbgnx3:
        cmp     al,73h          ; s:set
		jnz     dbgnx4
		cmp     ah,73h
		jnz     dbgnx32
		call    setes
		jmp     dbgnxe
dbgnx32:
        cmp     ah,70h
		jne     dbgnx4
		call    setpio
		jmp     dbgnxe
dbgnx4:
        cmp     al,66h          ; f:fill
		jnz     dbgnx5
		call    filldt
		jmp     dbgnxe
dbgnx5:
        cmp     al,69h          ; i:init
		jnz     dbgnx6
        call    dinit
        jmp     dbgnxe
dbgnx6:
dbgnx9:
dbgnx91:
		cmp     al,62h          ; b Boot
		jnz     dbgnx94
		cmp     ah,70h          ; bp
		jnz     dbgnx93
		mov		ax,si
		cmp		al,CMDBUF-WORKTOP+3		; bp+(ret)
		jnz		dbgnx92
		call	brkaclr
		jmp		dbgnxe
dbgnx92:call    brkaset
		call    nmivset
		jmp     dbgnxe
dbgnx93:
        call    dboot
		jmp     dbgnxe
dbgnx94:cmp     al,67h          ; g go/ret
		jnz     dbgnx96
		cmp		dh,0
		jz		dbgnx95
        call	dx
dbgnx95:ret
dbgnx96:
        cmp     al,74h          ; t trace
		jnz     dbgnxe
        call    trace
		ret
dbgnxe:	jmp     dbgloop

trace:
		mov		cx,dx
        mov     dx,ds:[SAVEIP]      ; next pc
		cmp		ah,73h				; s:ts trace.skip
		jnz		trace2
		add		dx,cx				; skip n
trace2:
		call    brkaset
		call    nmivset
		ret

brkaclr:
		mov		bh,80h
		jmp		brkaset2
brkaset:
		mov		bh,0
brkaset2:
		push	bx
		mov		ax,dx
		mov     dx,02f0h
		out     dx,ax
		mov     ax,DS:[WSEG]
		mov     al,ah
		shr     al,4
		pop     bx
		mov		ah,bh
		mov     dx,02f2h
		out     dx,ax
        ret
nmivset:
        mov     ax,0
		mov     si,ax
		push    es
		mov     es,ax
		mov     ax,retnmi + POFS
		mov     es:[si+8],ax
		mov     ax,0f000h
		mov     es:[si+10],ax
		pop     es
        ret

movbios:
		mov		si,0e000h
		mov		di,0e000h
		mov		cx,1000h
		rep		movsw			; bios_rom -> psram e000 - ffff
		ret
dboot:	                        ; bnnnn dx = nnnn
		call	movbios
        cmp     ah,62h          ; bb
		jne     dboot1
		mov     dx,0e05bh
		call    brkaset
		call    nmivset
		jmp		dbootgo
dboot1:
;		mov     ax,0f000h
;		mov     es,ax
		cmp     dl,1
        jne     dboot2
        call    bootbeg
		jmp     dboote
dboot2:
        cmp     dl,2
		jne     dbootgo
        call    bootbeg
		call    bootbeg2
		jmp     dboote
dbootgo:
		mov		dx,0e05bh
		jmp		dx
dboote: ret

dinit:
		call    initio
        call    initcrt
		call	dispmon
		call	sdinit_
		call	brkaclr
		call    nmivset
        ret

ppmimsg db      'm',1,'o',1,'n',1,'8',1,'6',1
dispmon:
		push	0b800h      ; clear screen
		pop		es
		mov		si,ppmimsg + POFS
		xor		di, di
        mov     cx,5h
		rep     movsw		; si -> di
		ret

filldt:
		cld
        mov     di,dx           ; addr
		call    gethx
		mov     cx,dx           ; dl
		call    gethx
		mov     ax,dx           ; data
		cmp     ah,0h
		jz      filldt2
		rep     stosw           ; ES:[DI] <- ax
		jmp     filldte
filldt2:rep     stosb           ; ES:[DI] <- al
filldte:ret

setpio:                         ; pohhhh xxxx
		cmp     ah,6fh          ; o.. po
		jz      setpio2
		call    setpal
		jmp     setpioe
setpio2:push    dx
		call    gethx
		mov     ax,dx
		pop     dx
		out     dx,ax
setpioe:ret

setes:
        mov     si,[CMDBUF+1]
		mov     ah,[si]
		cmp     ah,0dh          ; .
        jnz     setes2
		mov     dx,0f000h       ; init ES
setes2:	push    dx
		pop     es
		ret

memrw:
;		push	es
;		mov		es,DS:[WSEG]
        mov     di,CMDBUF+1
		mov     al,[di]
		cmp     al,74h          ; t
		jz      mtest
		mov     si,dx
memrw2:	call    dpadr
        mov     al,es:[si]
		call    puth2
memrw3:	call    putsp
		push    si
		call    getsb
        mov     si,CMDBUF
		mov     ah,[si]
		cmp     ah,2eh          ; .
		jz      memrwe
		cmp     ah,0dh
		jnz     memrw4
		pop     si
		jmp     memrw6
memrw4:	call    gethx           ; dx = Data
		pop     si
		cmp     dh,0
		jz      memrw5
		mov     es:[si],dx      ; 2Byte
		inc     si
		inc     si
        call    dpadr
        mov     ax,es:[si]
		call    puth4
		jmp     memrw3
memrw5:	mov     es:[si],dl      ; 1Byte
memrw6:	inc     si
        jmp     memrw2
memrwe: pop     si
;		pop		es
        ret

mtest:
		mov     bx,WADDR
        mov     word ptr ds:[WADDR],dx         ; wadr
        call    gethx
		mov     word ptr ds:[WDTDL],dx       ; wdl
        call    gethx
		mov     word ptr ds:[WDT0],dx       ; w0(ptn)

        mov     al,0
		mov     di,[bx+0]
        mov     cx,[bx+4]
mtestw:
        cmp     cl,0
		jnz     mtestw2
		add     al,DS:[WDT0]
mtestw2:
        mov     es:[di],al

        mov     ah,es:[di]
        cmp     al,ah
        jz      mtestw3
		push    ax
        call    putcrlf
		push    ax
		mov     si,di
		call    dpadr
		pop     ax
		call    puth2
		call    putsp
		mov     al,ah
		call    puth2
		pop     ax

mtestw3:
		inc     di
		add     al,DS:[WDT0]
        loop    mtestw
;		ret
        mov     al,2eh
		call    putch
;
        mov     al,0
		mov     di,DS:[WADDR]
        mov     cx,DS:[WDTDL]
mtestr:
        cmp     cl,0
		jnz     mtestr2
		add     al,DS:[WDT0]
mtestr2:
        mov     ah,es:[di]
        cmp     al,ah
        jz      mtestr3
		push    ax
        call    putcrlf
		push    ax
		mov     si,di
		call    dpadr
		pop     ax
		call    puth2
		call    putsp
		mov     al,ah
		call    puth2
		pop     ax
mtestr3:
		inc     di
		add     al,DS:[WDT0]
        loop    mtestr

        ret


getsb:
		mov     si,CMDBUF	;sbuf + POFS
		call    gets
        ret
dpadr:
		mov     ax,si
		shr     ax,4
		mov     dx,es
		add     ax,dx
		call    puth4
		mov     ax,si
		and     al,0fh
		call    puth1
		mov     al,3ah
		call    putch           ; addr:
		call    putsp
        ret

dump:
;		push	es
;		mov		es,DS:[WSEG]
		mov     si,dx
        mov     ch,4
dump2:
        call    dpadr
        mov     cl,16
dump3:  mov     al,es:[si]
        inc     si
		call    puth2
		call    putsp
		inc     dx
		dec     cl
		jnz     dump3
		call    putcrlf
        dec     ch
		jnz     dump2
;		pop		es
		ret

putsp:  push    ax
        mov     al,20h
        call    putch
		pop     ax
		ret
putcrlf:push    ax
        mov     al,0dh
        call    putch
		pop     ax
		ret

gethx:  push    ax          ; return dx <- hex
        push    cx
        mov     dx,0        ; res
        mov     cl,0
gethx1: mov     al,[si]
        cmp     al,20h
		jnz     gethx2
		inc     si
		jmp     gethx1
gethx2: mov     al,[si]
		inc     si
		call    as2hh       ; hex <- ascii(1char)
		cmp     al,0ffh
		jz      gethxe
		cmp     cl,4
		jz      gethx3
        inc     cl
        jmp     gethx4
gethx3: push    dx
        and     dx,0f000h
		mov		es,dx
		mov     DS:[WSEG],dx
		pop     dx
gethx4:	shl     dx,4
		or      dl,al
		jmp     gethx2
gethxe: pop     cx
        pop     ax
        ret

as2hh:
        cmp     al,30h
		jb      as2hxee     ; jmp al<30h
		cmp     al,40h
		jb      as2hh2      ; jmp <
		sub     al,37h      ; A - F
		and     al,0fh
		ret
as2hh2: sub     al,30h      ; 0 - 9
        ret
as2hxee:mov     ah,al       ; ah <- last.byte
        mov     al,0ffh
        ret

gets:   mov     ah,0
gets2:  call    getch
		cmp     al,08h      ; BS
		jnz     gets3
		cmp     ah,0
		jz      gets2
		call    putch
		dec     si
		dec     ah
		jmp     gets2
gets3:	call    putch
        mov     [si],al
		inc     si
		inc     ah
		cmp     al,0dh
		jnz     gets2
		ret

puth4:  push    ax
        mov     al,ah
		call    puth2
		pop     ax
		call    puth2
		ret

puth2:  push    ax
        push    ax
        shr     al,4
		call    puth1
		pop     ax
		and     al,0fh
		call    puth1
		pop     ax
		ret

puth1:  cmp     al,10
        jb      puth11      ; jmp <
		add     al,7
puth11: add     al,30h
        jmp     putch

bootchk:
		mov		dx, BOOTSW
		in      al,dx
		and		al,80h
		cmp		al,00h
		jnz		bootchke
		call	movbios
		mov		dx,0e05bh
		jmp		dx
bootchke:
		ret

getch:  push    dx
        mov		dx, RSRXBSY
getchlp:in      al,dx
		and		al,80h
		test	al, al
        jz      getchlp
		mov		dx, RSDATA
		in      al,dx
		pop     dx
        ret

putch:  push    dx
        push    ax
		mov     dx,RSTXRDY
putchlp:in      al,dx
		and		al,80h
        test    al,al
		jnz     putchlp
		pop     ax
		mov     dx,RSDATA
		out     dx,al
		pop     dx
		ret

puts:   mov     al,[si]
        test    al,al
		jz      putse
		call    putch
        inc     si
        jmp     puts
putse:  ret

ppimsg  db      0dh,'mon86',0
ppcmsg  db      0dh,3eh,0

;---------------------------------------------

        org     0C00h         ; Original Start
begin label far               ; this code is placed at F000:BOOTOFFSET
rststart:
		cli
		cld
		mov		ax, cs        ; cs = 0f000h
		mov		ds, ax
		mov		es, ax
		mov		ss, ax
		mov		sp, BOOTOFFSET
;;----------------------------
        jmp     dbgcold
;;----------------------------
bootbeg:
        call    initio
		call    initcrt
		call	sdinit_

		call    puth4
		call    putsp

		test	ax, ax
		jz		short RS232
		mov		dx, ax
		shr		dx, 6
		shl		ax, 10
		mov		cx, BIOSSIZE       ;  sectors
		sub		ax, cx
		sbb		dx, 0

		push    ax
        mov     ax,dx
        call    puth4
        call    putsp
        pop     ax
		call    puth4
		call    putcrlf
        ret

bootbeg2:
		xor		bx, bx       ; read BIOSSIZE/2 KB BIOS at 0f000h:0h
nextsect:
		push		ax
		push		dx
		push		cx
		call		sdread_
		dec		cx
		pop		cx
		pop		dx
		pop		ax
		jnz		short RS232  ; cx was not 1
		add		ax, 1
		adc		dx, 0
		add		bx, 512    
		loop	nextsect
		ret

bootbeg3:
		cmp		word ptr ds:[0], 'eN'
		jne		short RS232             
		cmp		word ptr ds:[2], 'tx'
		je		short   BIOSOK
        jmp     RS232

RS232: 
        call    initcrt
		call    initmsg

		mov		bx, 4000h
flush:        
		mov		al, [bx]
		sub		bx, 40h
		jnz		flush
	
		mov		si, 100h
		call		srecb
		mov		bh, ah
		call		srecb
		mov		bl, ah

sloop:	
		call		srecb
		mov		[si], ah
		inc		si
		dec		bx
		jnz		sloop
		xor		sp, sp
		mov		ss, sp
		db		0eah
		dw		100h,0f000h ; execute loaded program

BIOSOK:
		mov		si, reloc + BOOTOFFSET - begin
		mov		di, bx
		mov		cx, endreloc - reloc
		rep		movsb       ; relocate code from reloc to endreloc after loaded BIOS
		mov		di, -BIOSSIZE*512
		xor		si, si
		mov		cx, BIOSSIZE*512/2
		jmp		bx
reloc:      
		rep		movsw
		nop
		nop
		db		0eah
		dw		0, -1       ; CPU reset, execute BIOS
endreloc:

;----------------------
initio:
		xor		ax, ax        ; map seg0
		out		80h, ax
		mov		al, 0bh       ; map text segB
		out		8bh, ax
		mov		al, 0fh       ; map ROM segF
		out		8fh, ax

		mov		al, 34h
		out		43h, al
		xor		al, al
		out		40h, al
		out		40h, al       ; program PIT for RS232
        ret

initcrt:
        push    es
		mov		dx, 3c0h
		mov		al, 10h
		out		dx, al
		mov		al, 8h
		out		dx, al      ; set text mode
		mov		dx, 3d4h
		mov		al, 0ah
		out		dx, al
		inc		dx
		mov		al, 1 shl 5 ; hide cursor
		out		dx, al
		dec		dx
		mov		al, 0ch
		out		dx, al
		inc		dx
		mov		al, 0
		out		dx, al
		dec		dx
		mov		al, 0dh
		out		dx, al
		inc		dx
		mov		al, 0
		out		dx, al      ; reset video offset
      
		push	0b800h      ; clear screen
		pop		es
		xor		di, di
;		mov		cx, 25*80
;		xor		ax, ax
        mov     cx,0c00h
		mov     ax,012eh      ; .
		rep		stosw

;		xor		di, di
;		mov     ax,0141h        ; A
;		mov     cx,0004h
;		rep		stosw

		pop     es
setpal:	
		mov		dx, 3c8h    ; set palette entry 1
		mov		ax, 101h
		out		dx, al
		inc		dx
		mov		al, 2ah
		out		dx, al
		out		dx, al
		out		dx, al
		ret

initmsg:
        push    es
		mov     ax,0b800h
		mov     es,ax
		xor		di, di      
		mov		si, booterrmsg + BOOTOFFSET - begin
		mov     ah,01h
		lodsb
nextchar:
        call    putch       ; rs
		stosw
		lodsb
		test		al, al
		jnz		short nextchar
		pop     es
        ret

; ----------------  serial receive byte 115200 bps --------------
srecb:  
		mov		ah, 80h
		mov		dx, 3dah
		mov		cx, -5aeh ; (half start bit)
srstb:  
		in		al, dx
		shr		al, 2
		jc		srstb

		in		al, 40h ; lo counter
		add		ch, al
		in		al, 40h ; hi counter, ignore
l1:
		call		dlybit
		in		al, dx
		shr		al, 2
		rcr		ah, 1
		jnc		l1
dlybit:
		sub		cx, 0a5bh  ;  (full bit)
dly1:
		in		al, 40h
		cmp		al, ch
		in		al, 40h
		jnz		dly1
		ret

;---------------------  read/write byte ----------------------
sdrb:   
		mov		al, 0ffh
sdsb:               ; in AL=byte, DX = 03dah, out AX=result
		mov		ah, 1
sdsb1:
		out		dx, al
;		add		ax, ax
;		jnc		sdsb1
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		in		ax, dx
		ret

;---------------------  write block ----------------------
sdwblk:              ; in DS:SI=data ptr, DX=03dah, CX=size
		lodsb
		call		sdsb
		loop		sdwblk
		ret

;---------------------  read block ----------------------
sdrblk:              ; in DS:DI=data ptr, DX=03dah, CX=size
		call		sdrb
		mov		[di], ah
		inc		di
		loop		sdrblk
		ret

;---------------------  write command ----------------------
sdcmd8T:
		call	sdrb
sdcmd:              ; in DS:SI=6 bytes cmd buffer, DX=03dah, out AH = 0ffh on error
		mov		cx, 6
		call		sdwblk
sdresp:
		xor		si, si
sdresp1:
		call		sdrb
		inc		si
		jz		sdcmd1
		cmp		ah, 0ffh
		je		sdresp1
sdcmd1: 
		ret         

;---------------------  read one sector ----------------------
sdread_ proc near   ; DX:AX sector, DS:BX buffer, returns CX=read sectors
		push		ax
		mov		al, dl
		push		ax
		mov		dl, 51h     ; CMD17
		push		dx
		mov		si, sp

		mov		dx, 3dah
		mov		ah, 1
		out		dx, ax      ; CS on
		mov		byte ptr [si+5], 0ffh ; checksum
		call		sdcmd
		add		sp, 6
		or		ah, ah
		jnz		sdr1        ; error (cx=0)
		call		sdresp      ; wait for 0feh token
		cmp		ah, 0feh
		jne		sdr1        ; read token error (cx=0)
		mov		ch, 2       ; 512 bytes
		mov		di, bx
		call		sdrblk
		call		sdrb        ; ignore CRC
		call		sdrb        ; ignore CRC
		inc		cx          ; 1 block
 sdr1:       
		xor		ax, ax
		out		dx, ax
		call		sdrb        ; 8T
		ret     
sdread_ endp
        
;---------------------  init SD ----------------------
sdinit_ proc near       ; returns AX = num kilosectors
		mov		dx, 3dah
		mov		cx, 10
sdinit1:                   ; send 80T
		call		sdrb
		loop		sdinit1

		mov		ah, 1
		out		dx, ax       ; select SD

		mov		si, SD_CMD0 + BOOTOFFSET - begin
		call		sdcmd
		dec		ah
		jnz		sdexit      ; error
		
		mov		si, SD_CMD8 + BOOTOFFSET - begin
		call		sdcmd8T
		dec		ah
		jnz		sdexit      ; error
		mov		cl, 4
		sub		sp, cx
		mov		di, sp
		call		sdrblk
		pop		ax
		pop		ax
		cmp		ah, 0aah
		jne		sdexit      ; CMD8 error
repinit:        
		mov		si, SD_CMD55 + BOOTOFFSET - begin
		call		sdcmd8T
		call		sdrb
		mov		si, SD_CMD41 + BOOTOFFSET - begin
		call		sdcmd
		dec		ah
		jz		repinit
		
		mov		si, SD_CMD58 + BOOTOFFSET - begin
		call		sdcmd8T
		mov		cl, 4
		sub		sp, cx
		mov		di, sp
		call		sdrblk
		pop		ax
		test		al, 40h     ; test OCR bit 30 (CCS)
		pop		ax
		jz		sdexit      ; no SDHC

		mov		si, SD_CMD9 + BOOTOFFSET - begin ; get size info
		call		sdcmd8T
		or		ah, ah
		jnz		sdexit
		call		sdresp      ; wait for 0feh token
		cmp		ah, 0feh
		jne		sdexit
		mov		cl, 18      ; 16bytes + 2bytes CRC
		sub		sp, cx
		mov		di, sp
		call		sdrblk
		mov		cx, [di-10]
		xchg		cl, ch
		inc		cx
		mov		sp, di
sdexit: 
		xor		ax, ax      ; raise CS
		out		dx, ax
		call	sdrb
		mov		ax, cx       
		ret
sdinit_ endp

    
booterrmsg  db  'BIOS not present on SDCard last 8KB, waiting on RS232 (115200bps, f000:100) ...', 0
SD_CMD0		db		40h, 0, 0, 0, 0, 95h
SD_CMD8		db		48h, 0, 0, 1, 0aah, 087h
SD_CMD9		db		49h, 0, 0, 0, 0, 0ffh
SD_CMD41	db		69h, 40h, 0, 0, 0, 0ffh
SD_CMD55	db		77h, 0, 0, 0, 0, 0ffh
SD_CMD58	db		7ah, 0, 0, 0, 0, 0ffh


; ---------------- RESET ------------------
;		org 05f0h
		org 05f0h+0A00h
start:
		db		0eah
		dw		BOOTOFFSET, 0f000h
		db		0,0,0,0,0,0,0,0,0,0,0
       
end exec
