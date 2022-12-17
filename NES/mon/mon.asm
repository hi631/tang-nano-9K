	LIST
;*********************************************
; NES Hello World
; Made by: Pedro A. Fabri
; Based on Nerdy Nights Tutorials
;*********************************************
      .include "apu_util.asm"
;*********************************************
; Variables
;*********************************************
  .rsset $0000

;*********************************************
; NES Header
;*********************************************
  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring

  
;*********************************************
; Bank 0
;*********************************************
  .bank 0

  .org $C000 

;*********************************************
; Bank 1 - DBs
;*********************************************
  .bank 1
  .org $E000


RESET:
;  JMP RSTART	; monitor


WORM:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

  JSR vblankwait

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0200, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0300, x
  INX
  BNE clrmem

  JSR vblankwait

;*********************************************
; Load Palettes
;*********************************************
LoadPalettes:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$3F
  STA $2006             ; write the high byte of $3F00 address
  LDA #$00
  STA $2006             ; write the low byte of $3F00 address
  LDX #$00              ; start out at 0
LoadPalettesLoop:
  LDA palette, x        ; load data from address (palette + the value in x)
  STA $2007             ; write to PPU
  INX                   ; X = X + 1
  CPX #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  BNE LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero

;*********************************************
; Load Sprites
;*********************************************
LoadSprites:
  LDX #$00              ; start at 0
LoadSpritesLoop:
  LDA sprites, x        ; load data from address (sprites +  x)
  STA $0200, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$28              ; Compare X to hex $14, decimal 20
  BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
            
  LDA #%10001000        ; enable NMI, sprites from Pattern Table 1
  STA $2000

  LDA #%00010000        ; enable sprites
  STA $2001

;*********************************************
; Main Logic
;*********************************************

Forever:
;  JMP Forever     ;jump back to Forever, infinite loop
   JMP CmdLoop

;*********************************************
; NMI Interrupt
;*********************************************
NMI:

  LDA #$00
  STA $2003       ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014       ; set the high byte (02) of the RAM address, start the transfer



  RTI             ; return from interrupt

;*********************************************
; General Functions
;*********************************************
;*********************************************
; VBlank Wait
;*********************************************
vblankwait:
  BIT $2002
  BPL vblankwait
  RTS

;*********************************************
; Read Buttons
;*********************************************

  RTS

  .org $EE00

palette:

  .db $0F,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$0F
  .db $0F,$1C,$15,$14,$31,$02,$38,$3C,$0F,$1C,$15,$14,$31,$02,$38,$3C

sprites:
     ; X  tile  attr  Y
  .db $60, $11, $00, $68   ; H
  .db $60, $0E, $00, $70   ; E
  .db $60, $15, $00, $78   ; L
  .db $60, $15, $00, $80   ; L
  .db $60, $18, $00, $88   ; O
  .db $70, $20, $00, $68   ; W
  .db $70, $18, $00, $70   ; O
  .db $70, $1B, $00, $78   ; R
  .db $70, $15, $00, $80   ; L
  .db $70, $0D, $00, $88   ; D


;*********************************************
; Test Dumy Data
;*********************************************
	org $F000
dumydata:
  .db $F0,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
  .db $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F
  .db $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F
  .db $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F

;*********************************************
; mango1 monitor+
;*********************************************
Temp        equ $2a
Addr        equ $2c
Work		equ	$2e

rsrcvdt		equ	$4020
rsrcvclr	equ	$4021
rssndst		equ	$4022
rssnddt		equ	$4022

	org $FE00	; starting address

RSTART
        sei
        cld
        ldx #$ff
        txs

;サウンド有効化  
    lda    #$1F  
    sta    $4015  

;再生  
    lda    #$ff  
    sta    $4000  
    lda    #$00  
    sta    $4001  
    lda    #$7e  
    sta    $4002  
    lda    #$00  
    sta    $4003  

CmdLoop
        jsr DoCommand
        jmp CmdLoop	; endless loop
DoCommand
        jsr PutCR

        lda #'#'	; prompt
        jsr PutChar

        jsr GetChar
        cmp #'R'
        beq DumpBytes
        cmp #'W'
        beq WriteBytes
        cmp #'G'
        beq GotoAddr
        cmp #'I'
        beq GoInit
        cmp #13
        beq DumpNext
Invalid
        jsr PutCR
        lda #'?'
        jsr PutChar
        jmp DoCommand

GoInit
		jmp WORM
DumpBytes
        jsr GetHexWord
		lda #$04
		sta <Work
DumpNext
        jsr PutHexAddr
        lda #':'
        jsr PutChar
DumpLoop
        lda #' '
        jsr PutChar
        ldy #0
        lda [Addr],y
        jsr PutHexByte
        jsr IncAddr
        lda <Addr
        and #$0F
        bne DumpLoop
		jsr PutCR
		dec <Work
		lda <Work
		and #$03
		bne DumpNext
        rts
WriteBytes
        jsr GetHexWord
WriteBytes2
        jsr PutHexAddr
        lda #':'
        jsr PutChar
        jsr GetHexByte
		bcc WriteBytes3
		jsr PutChar
		rts
WriteBytes3
        ldy #0
        sta [Addr],y
		jsr IncAddr
		jsr PutCR
		jmp WriteBytes2
        rts

GotoAddr
        jsr GetHexWord
        jmp (Addr)

GetHexWord
        lda #0
        sta <Addr
        sta <Addr+1
        jsr GetHexDigit
        bcs Bailout
        beq GetHexWord        ; eat leading zeroes
NextHexDigit
        asl A
        asl A
        asl A
        asl A
        ldy #4
ShiftAddr
        asl A
        rol <Addr
        rol <Addr+1
        dey
        bne ShiftAddr
        jsr GetHexDigit
        bcs Bailout
        jmp NextHexDigit
GetHexByte
        jsr GetHexDigit
        bcs Bailout
        asl A
        asl A
        asl A
        asl A
        sta <Temp
        jsr GetHexDigit
        bcs Bailout
        ora <Temp
Success
        clc
        rts
GetHexDigit
        jsr GetChar
        sec
        sbc #'0'
        cmp #10
        bcc Return
        sbc #('A'-'0')        ; carry already set
        cmp #6
        bcs Bailout
        clc
        adc #10
        rts
Bailout
        sec
Return
        rts
PutCR
        lda #13
        jmp PutChar
GetChar
        lda rsrcvdt
        bpl GetChar
        sta rsrcvclr
        and #$7f
		cmp #'Z'
		bcc PutChar
		sbc #$20
PutChar
        bit rssndst
        bmi PutChar
        sta rssnddt
        rts
PutHexAddr
        lda <Addr+1
        jsr PutHexByte
        lda <Addr
PutHexByte
        pha
        lsr A
        lsr A
        lsr A
        lsr A
        jsr PutHexDigit
        pla
PutHexDigit
        and #$0f
        clc
        adc #'0'
        cmp #':'
        bcc PutChar
        adc #'A'-':'-1
        bcc PutChar
IncAddr
        inc <Addr
        bne Return
        inc <Addr+1
        rts

  .org $FFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
  .dw RESET      ;when the processor first turns on or is reset, it will jump
;  .dw RSTART
  .dw 0          ;external interrupt IRQ is not used in this tutorial

;*********************************************
; Bank 2 - Graphic Binary
;*********************************************
  .bank 2

  .org $0000

  .incbin "mon.chr"   ;includes 8KB graphics file from SMB1