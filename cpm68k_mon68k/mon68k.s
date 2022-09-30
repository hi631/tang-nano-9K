	.text
	.globl	_exec
_exec:
	link	a6,#0
	jsr	_EXEC
	unlk	a6
	rts
	.text
	.globl	_puts
_puts:
	link	a6,#0
L6:
	move.l	8(a6),a0
	tst.b	(a0)
	beq	L5
	move.l	8(a6),a0
	addq.l	#1,8(a6)
	move.b	(a0),d0
	ext.w	d0
	move.w	d0,-(sp)
	jsr	_OUTCH
	addq.w	#2,sp
	bra	L6
L5:
	unlk	a6
	rts
	.text
	.globl	_gets
_gets:
	link	a6,#-4
	movem.l	d3/d4,-(sp)
	clr.b	d3
	clr.w	d4
L11:
	cmp.b	#13,d3
	beq	L10
	jsr	_INCH
	move.b	d0,d3
	cmp.b	#8,d3
	bne	L13
	tst.w	d4
	beq	L11
	move.w	#8,-(sp)
	jsr	_OUTCH
	move.w	#32,(sp)
	jsr	_OUTCH
	move.w	#8,(sp)
	jsr	_OUTCH
	addq.w	#2,sp
	subq.w	#1,d4
	bra	L11
L13:
	move.b	d3,d0
	ext.w	d0
	move.w	d0,-(sp)
	jsr	_OUTCH
	addq.w	#2,sp
	move.w	d4,d0
	addq.w	#1,d4
	ext.l	d0
	add.l	8(a6),d0
	move.l	d0,a0
	move.b	d3,(a0)
	bra	L11
L10:
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
	.text
	.globl	_puth
_puth:
	link	a6,#0
	cmp.w	#10,8(a6)
	bge	L19
	move.w	8(a6),d0
	add.w	#48,d0
	move.w	d0,-(sp)
	jsr	_OUTCH
L18:
	unlk	a6
	rts
L19:
	move.w	8(a6),d0
	add.w	#55,d0
	move.w	d0,-(sp)
	jsr	_OUTCH
	bra	L18
	.text
	.globl	_puth2
_puth2:
	link	a6,#0
	move.w	8(a6),d0
	asr.w	#4,d0
	and.w	#15,d0
	move.w	d0,-(sp)
	jsr	_puth
	move.w	8(a6),d0
	and.w	#15,d0
	move.w	d0,(sp)
	jsr	_puth
	unlk	a6
	rts
	.text
	.globl	_puth4
_puth4:
	link	a6,#0
	move.w	8(a6),d0
	asr.w	#8,d0
	and.w	#255,d0
	move.w	d0,-(sp)
	jsr	_puth2
	move.w	8(a6),d0
	and.w	#255,d0
	move.w	d0,(sp)
	jsr	_puth2
	unlk	a6
	rts
	.text
	.globl	_puth6
_puth6:
	link	a6,#-4
	move.l	8(a6),d0
	moveq.l	#16,d1
	asr.l	d1,d0
	move.w	d0,-2(a6)
	move.l	8(a6),d0
	and.l	#65535,d0
	move.w	d0,-4(a6)
	move.w	-2(a6),-(sp)
	jsr	_puth2
	move.w	-4(a6),(sp)
	jsr	_puth4
	unlk	a6
	rts
	.text
	.globl	_puth8
_puth8:
	link	a6,#-4
	move.l	8(a6),d0
	moveq.l	#16,d1
	asr.l	d1,d0
	move.w	d0,-2(a6)
	move.l	8(a6),d0
	and.l	#65535,d0
	move.w	d0,-4(a6)
	move.w	-2(a6),-(sp)
	jsr	_puth4
	move.w	-4(a6),(sp)
	jsr	_puth4
	unlk	a6
	rts
	.text
	.globl	_setsup
_setsup:
	link	a6,#0
	move.l	d3,-(sp)
	move.l	8(a6),d3
L36:
	move.l	d3,a0
	cmp.b	#13,(a0)
	beq	L37
	move.l	d3,a0
	cmp.b	#97,(a0)
	blt	L38
	move.l	d3,a0
	cmp.b	#122,(a0)
	bgt	L38
	move.l	d3,a0
	move.b	(a0),d0
	ext.w	d0
	sub.w	#32,d0
	move.l	d3,a0
	move.b	d0,(a0)
L38:
	addq.l	#1,d3
	bra	L36
L37:
	moveq.l	#0,d3
	move.l	(sp)+,d3
	unlk	a6
	rts
	.text
	.globl	_ishex
_ishex:
	link	a6,#-2
	movem.l	d3/d4,-(sp)
	move.b	9(a6),d3
	cmp.b	#48,d3
	blt	L42
	cmp.b	#57,d3
	bgt	L42
	move.b	d3,d0
	ext.w	d0
	sub.w	#48,d0
	move.w	d0,d4
L43:
	move.w	d4,d0
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
L42:
	cmp.b	#65,d3
	blt	L44
	cmp.b	#70,d3
	bgt	L44
	move.b	d3,d0
	ext.w	d0
	sub.w	#55,d0
	move.w	d0,d4
	bra	L43
L44:
	moveq.l	#-1,d4
	bra	L43
	.text
	.globl	_gets2h
_gets2h:
	link	a6,#-6
	movem.l	d3/d4/d5,-(sp)
	move.l	8(a6),d3
	moveq.l	#0,d4
L49:
	move.l	d3,a0
	move.l	(a0),a0
	cmp.b	#32,(a0)
	beq	L51
	move.l	d3,a0
	move.l	(a0),a0
	cmp.b	#44,(a0)
	bne	L50
L51:
	move.l	d3,a0
	addq.l	#1,(a0)
	bra	L49
L50:
	move.l	d3,a0
	move.l	(a0),a0
	cmp.b	#32,(a0)
	bge	L53
	moveq.l	#-1,d0
L48:
	movem.l	(sp)+,d3/d4/d5
	unlk	a6
	rts
L53:
	move.l	d3,a0
	move.l	(a0),a0
	move.b	(a0),d0
	ext.w	d0
	move.w	d0,-(sp)
	jsr	_ishex
	addq.w	#2,sp
	move.w	d0,d5
	cmp.w	#-1,d5
	beq	L54
	move.l	d4,d0
	asl.l	#4,d0
	move.w	d5,d1
	ext.l	d1
	add.l	d1,d0
	move.l	d0,d4
	move.l	d3,a0
	addq.l	#1,(a0)
	bra	L53
L54:
	move.l	d4,d0
	bra	L48
	.text
	.globl	_geth1b
_geth1b:
	link	a6,#-2
	jsr	_INCH
	move.w	d0,-(sp)
	jsr	_ishex
	asl.w	#4,d0
	move.w	d0,(sp)
	jsr	_INCH
	move.w	d0,-(sp)
	jsr	_ishex
	addq.w	#2,sp
	add.w	(sp)+,d0
	move.w	d0,-2(a6)
	move.w	d0,-(sp)
	jsr	_puth2
	move.w	-2(a6),d0
	unlk	a6
	rts
	.data
	.globl	_mbase
_mbase:
	.dc.l	0
	.text
	.globl	_geth2b
_geth2b:
	link	a6,#0
	jsr	_geth1b
	asl.w	#8,d0
	move.w	d0,-(sp)
	jsr	_geth1b
	add.w	(sp)+,d0
	unlk	a6
	rts
	.text
	.globl	_putadrhd
_putadrhd:
	link	a6,#0
	move.w	#10,-(sp)
	jsr	_OUTCH
	addq.w	#2,sp
	move.l	8(a6),-(sp)
	jsr	_puth6
	addq.w	#4,sp
	move.w	#58,-(sp)
	jsr	_OUTCH
	unlk	a6
	rts
	.text
	.globl	_getssu
_getssu:
	link	a6,#0
	move.l	8(a6),-(sp)
	jsr	_gets
	move.l	8(a6),(sp)
	jsr	_setsup
	unlk	a6
	rts
	.text
	.globl	_loadhex
_loadhex:
	link	a6,#-14
	clr.w	-14(a6)
L70:
	tst.w	-14(a6)
	bne	L71
L72:
	jsr	_INCH
	cmp.w	#58,d0
	bne	L72
	jsr	_geth1b
	move.w	d0,-6(a6)
	jsr	_geth2b
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d1,-12(a6)
	jsr	_geth1b
	move.b	d0,-8(a6)
	cmp.b	#1,d0
	bne	L74
	jsr	_geth1b
	move.b	d0,-7(a6)
	move.w	#1,-14(a6)
L75:
	move.l	#L79,-(sp)
	jsr	_puts
	addq.w	#4,sp
	bra	L70
L74:
	clr.w	-4(a6)
L76:
	move.w	-4(a6),d0
	cmp.w	-6(a6),d0
	bge	L75
	jsr	_geth1b
	move.b	d0,-7(a6)
	move.l	-12(a6),d0
	addq.l	#1,-12(a6)
	add.l	_mbase,d0
	move.l	d0,a0
	move.b	-7(a6),(a0)
	addq.w	#1,-4(a6)
	bra	L76
L71:
	jsr	_INCH
	unlk	a6
	rts
	.text
	.globl	_strlen
_strlen:
	link	a6,#-2
	clr.w	-2(a6)
L83:
	move.l	8(a6),a0
	addq.l	#1,8(a6)
	tst.b	(a0)
	beq	L84
	addq.w	#1,-2(a6)
	bra	L83
L84:
	move.w	-2(a6),d0
	unlk	a6
	rts
	.text
	.globl	_strcat
_strcat:
	link	a6,#0
	movem.l	d3/d4,-(sp)
	move.l	12(a6),d4
	move.l	8(a6),d3
	move.l	d3,-(sp)
	jsr	_strlen
	addq.w	#4,sp
	ext.l	d0
	add.l	d3,d0
	move.l	d0,d3
L88:
	move.l	d4,a0
	tst.b	(a0)
	beq	L89
	move.l	d4,d0
	addq.l	#1,d4
	move.l	d0,a0
	move.l	d3,d0
	addq.l	#1,d3
	move.l	d0,a1
	move.b	(a0),(a1)
	bra	L88
L89:
	move.l	d3,a0
	clr.b	(a0)
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
	.text
	.globl	_strcpy
_strcpy:
	link	a6,#0
L93:
	move.l	12(a6),a0
	tst.b	(a0)
	beq	L94
	move.l	12(a6),a0
	addq.l	#1,12(a6)
	move.l	8(a6),a1
	addq.l	#1,8(a6)
	move.b	(a0),(a1)
	bra	L93
L94:
	move.l	8(a6),a0
	clr.b	(a0)
	unlk	a6
	rts
	.text
	.globl	_dispr1
_dispr1:
	link	a6,#0
	move.l	8(a6),-(sp)
	jsr	_puts
	move.l	12(a6),(sp)
	jsr	_puth8
	unlk	a6
	rts
	.text
	.globl	_dispregs
_dispregs:
	link	a6,#-182
	movem.l	d3/d4/d5/d6/d7,-(sp)
	move.l	12(a6),d6
	move.l	8(a6),d5
	clr.w	d3
	tst.w	16(a6)
	bne	L101
	move.l	#16715520,a0
	move.l	a0,-16(a6)
	move.l	4(a0),d7
L102:
	move.l	d6,d0
	and.l	#-2147483648,d0
	beq	L103
	move.l	#L104,-(sp)
	jsr	_puts
	move.l	d7,(sp)
	jsr	_puth6
	addq.w	#4,sp
	move.w	#32,-(sp)
	jsr	_OUTCH
	addq.w	#2,sp
	move.w	d3,d0
	add.w	#10,d0
	move.w	d0,d3
L103:
	move.l	d6,d0
	and.l	#1073741824,d0
	beq	L105
	pea	-162(a6)
	move.l	d7,-(sp)
	jsr	_DISASM
	addq.w	#8,sp
	move.l	d0,-8(a6)
	sub.l	d7,d0
	move.w	d0,-24(a6)
	move.l	#L106,-(sp)
	pea	-162(a6)
	jsr	_strcat
	addq.w	#8,sp
	clr.b	-134(a6)
	move.w	d3,d0
	add.w	#28,d0
	move.w	d0,d3
	pea	-162(a6)
	jsr	_puts
	addq.w	#4,sp
	clr.b	-162(a6)
	move.l	d6,d0
	and.l	#536870912,d0
	beq	L105
	clr.w	d4
L108:
	cmp.w	#8,d4
	bge	L110
	move.w	d4,d0
	ext.l	d0
	add.l	d7,d0
	move.l	d0,-182(a6)
	move.w	d4,d0
	cmp.w	-24(a6),d0
	bge	L111
	move.l	-182(a6),a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,-(sp)
	jsr	_puth2
	addq.w	#2,sp
L109:
	addq.w	#1,d4
	bra	L108
L111:
	move.l	#L113,-(sp)
	jsr	_puts
	addq.w	#4,sp
	bra	L109
L110:
	move.w	d3,d0
	add.w	#17,d0
	move.w	d0,d3
L105:
	move.l	d5,a0
	move.l	(a0),d0
	and.l	#-1,d0
	move.w	d0,-34(a6)
	and.w	#8192,d0
	beq	L114
	move.l	d5,a0
	lea	12(a0),a0
	move.l	d5,a1
	move.l	(a0),80(a1)
L115:
	move.l	d6,d0
	and.l	#134217728,d0
	beq	L116
	move.l	#L117,-(sp)
	jsr	_puts
	move.l	d5,a0
	move.l	12(a0),(sp)
	jsr	_puth8
	addq.w	#4,sp
	move.w	d3,d0
	add.w	#12,d0
	move.w	d0,d3
L116:
	move.l	d6,d0
	and.l	#67108864,d0
	beq	L118
	move.l	#L119,-(sp)
	jsr	_puts
	move.l	d5,a0
	move.l	16(a0),(sp)
	jsr	_puth8
	addq.w	#4,sp
	move.w	d3,d0
	add.w	#12,d0
	move.w	d0,d3
L118:
	move.l	d6,d0
	and.l	#33554432,d0
	beq	L120
	move.l	#L121,-(sp)
	jsr	_puts
	addq.w	#4,sp
	move.w	-34(a6),-(sp)
	jsr	_puth4
	addq.w	#2,sp
	move.w	d3,d0
	addq.w	#8,d0
	move.w	d0,d3
L120:
	move.l	d6,d0
	and.l	#16777216,d0
	beq	L122
	move.l	#L123,-(sp)
	jsr	_puts
	addq.w	#4,sp
	clr.w	d3
L122:
	move.b	#32,-31(a6)
	move.b	#58,-28(a6)
	clr.b	-27(a6)
	move.l	#1,-12(a6)
	clr.w	d4
L124:
	cmp.w	#3,d4
	bge	L126
	tst.w	d4
	bne	L127
	move.b	#68,-30(a6)
L128:
	clr.w	-22(a6)
L131:
	cmp.w	#8,-22(a6)
	bge	L125
	move.w	d3,d0
	cmp.w	18(a6),d0
	blt	L134
	move.w	#13,-(sp)
	jsr	_OUTCH
	addq.w	#2,sp
	clr.w	d3
L134:
	move.l	d6,d0
	and.l	-12(a6),d0
	beq	L135
	move.w	-22(a6),d0
	add.w	#48,d0
	move.b	d0,-29(a6)
	move.w	d4,d0
	asl.w	#3,d0
	asl.w	#2,d0
	ext.l	d0
	add.l	d5,d0
	move.w	-22(a6),d1
	asl.w	#2,d1
	ext.l	d1
	add.l	d1,d0
	add.l	#20,d0
	move.l	d0,a0
	move.l	(a0),-(sp)
	pea	-31(a6)
	jsr	_dispr1
	addq.w	#8,sp
	move.w	d3,d0
	add.w	#12,d0
	move.w	d0,d3
L135:
	move.l	-12(a6),d0
	asl.l	#1,d0
	move.l	d0,-12(a6)
	addq.w	#1,-22(a6)
	bra	L131
L125:
	addq.w	#1,d4
	bra	L124
L127:
	cmp.w	#1,d4
	bne	L129
	move.b	#65,-30(a6)
	bra	L128
L129:
	move.b	#87,-30(a6)
	bra	L128
L126:
	tst.w	d3
	beq	L136
	move.w	#13,-(sp)
	jsr	_OUTCH
	addq.w	#2,sp
L136:
	move.l	-24(a6),d0
	movem.l	(sp)+,d3/d4/d5/d6/d7
	unlk	a6
	rts
L114:
	move.l	d5,a0
	lea	16(a0),a0
	move.l	d5,a1
	move.l	(a0),80(a1)
	bra	L115
L101:
	move.l	d5,a0
	move.l	8(a0),d7
	bra	L102
	.text
	.globl	_sec1rw
_sec1rw:
	link	a6,#-14
	movem.l	d3/d4/d5/d6/d7,-(sp)
	move.l	8(a6),d7
	move.l	#16711936,d3
	move.l	d7,d0
	moveq.l	#16,d1
	asr.l	d1,d0
	move.l	d3,a0
	move.w	d0,2(a0)
	move.l	d7,d0
	and.l	#65535,d0
	move.l	d3,a0
	move.w	d0,4(a0)
	move.l	d3,a0
	move.w	12(a6),(a0)
L140:
	move.l	d3,a0
	move.w	(a0),d0
	and.w	#1,d0
	cmp.w	#1,d0
	beq	L140
	move.l	#16715520,d3
	move.l	d3,a0
	move.w	(a0),d0
	and.w	#1,d0
	bne	L142
	tst.w	14(a6)
	beq	L139
	move.w	#46,-(sp)
	jsr	_OUTCH
	addq.w	#2,sp
L139:
	movem.l	(sp)+,d3/d4/d5/d6/d7
	unlk	a6
	rts
L142:
	clr.w	d4
	move.l	#16712192,d6
	clr.w	d4
	clr.w	d5
L145:
	cmp.w	#256,d5
	bcc	L147
	move.l	d6,d0
	addq.l	#1,d6
	move.l	d0,a0
	clr.w	d0
	move.b	(a0),d0
	add.w	d4,d0
	move.w	d0,d4
	addq.w	#1,d5
	bra	L145
L147:
	move.w	#91,-(sp)
	jsr	_OUTCH
	move.w	d4,(sp)
	jsr	_puth4
	move.w	#93,(sp)
	jsr	_OUTCH
	addq.w	#2,sp
	bra	L139
	.text
	.globl	_dumpdt
_dumpdt:
	link	a6,#-4
	move.l	12(a6),d0
	asr.l	#4,d0
	move.l	d0,12(a6)
	clr.w	-2(a6)
L151:
	move.w	-2(a6),d0
	ext.l	d0
	cmp.l	12(a6),d0
	bge	L150
	move.l	8(a6),-(sp)
	jsr	_putadrhd
	addq.w	#4,sp
	clr.w	-4(a6)
L154:
	cmp.w	#16,-4(a6)
	bge	L152
	move.w	#32,-(sp)
	jsr	_OUTCH
	move.l	8(a6),d0
	addq.l	#1,8(a6)
	add.l	_mbase,d0
	move.l	d0,a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,(sp)
	jsr	_puth2
	addq.w	#2,sp
	addq.w	#1,-4(a6)
	bra	L154
L152:
	addq.w	#1,-2(a6)
	bra	L151
L150:
	unlk	a6
	rts
	.text
	.globl	_checkyn
_checkyn:
	link	a6,#-2
	move.l	d3,-(sp)
	move.l	#L160,-(sp)
	jsr	_puts
	addq.w	#4,sp
	jsr	_INCH
	move.b	d0,d3
	cmp.b	#96,d3
	blt	L161
	move.b	d3,d0
	ext.w	d0
	sub.w	#32,d0
	move.b	d0,d3
L161:
	cmp.b	#89,d3
	bne	L162
	moveq.l	#-1,d0
L159:
	move.l	(sp)+,d3
	unlk	a6
	rts
L162:
	clr.w	d0
	bra	L159
	.text
	.globl	_memset
_memset:
	link	a6,#-6
	move.l	8(a6),-4(a6)
	clr.w	-6(a6)
L167:
	move.w	-6(a6),d0
	cmp.w	14(a6),d0
	bge	L166
	move.l	-4(a6),a0
	addq.l	#1,-4(a6)
	move.b	13(a6),(a0)
	addq.w	#1,-6(a6)
	bra	L167
L166:
	unlk	a6
	rts
	.data
L340:	.dc.b	$3f,$a
	.dc.b	0
L320:	.dc.b	$4c,$6f,$61,$64,$28,$49,$6e,$74,$65,$6c,$20
	.dc.b	$48,$65,$78,$29,$a
	.dc.b	0
L257:	.dc.b	$a,$2a
	.dc.b	0
L204:	.dc.b	$53,$74,$61,$72,$74,$3f,$28,$59,$2f,$4e,$29
	.dc.b	$20,$3d,$20
	.dc.b	0
L202:	.dc.b	$72,$65,$63,$6f,$76,$65,$72,$2e,$61,$6c,$6c
	.dc.b	$28,$39,$30,$30,$30,$2d,$31,$31,$66,$66,$66,$20,$2d,$3e,$20,$30
	.dc.b	$2d,$39,$30,$30,$30,$29,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.dc.b	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.dc.b	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$7c
	.dc.b	$a
	.dc.b	0
L199:	.dc.b	$73,$61,$76,$65,$2e,$61,$6c,$6c,$28,$30,$2d
	.dc.b	$38,$66,$66,$66,$20,$2d,$3e,$20,$39,$30,$30,$30,$2d,$31,$31,$66
	.dc.b	$66,$66,$29,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.dc.b	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.dc.b	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$7c
	.dc.b	$a
	.dc.b	0
L179:	.dc.b	$a,$3e
	.dc.b	0
L177:	.dc.b	$42,$4f,$d
	.dc.b	0
L173:	.dc.b	$4d,$6f,$6e,$36,$38,$4b,$a
	.dc.b	0
L160:	.dc.b	$53,$74,$61,$72,$74,$3f,$28,$59,$2f,$4e,$29
	.dc.b	$20,$3d,$20
	.dc.b	0
L123:	.dc.b	$a
	.dc.b	0
L121:	.dc.b	$20,$53,$52,$3a
	.dc.b	0
L119:	.dc.b	$20,$55,$53,$3a
	.dc.b	0
L117:	.dc.b	$20,$53,$53,$3a
	.dc.b	0
L113:	.dc.b	$2e,$2e
	.dc.b	0
L106:	.dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.dc.b	$20,$20,$20,$20,$20
	.dc.b	0
L104:	.dc.b	$50,$43,$3a
	.dc.b	0
L79:	.dc.b	$a
	.dc.b	0
	.text
	.globl	_main
_main:
	link	a6,#-598
	movem.l	d3/d4/d5/d6/d7,-(sp)
	clr.l	-518(a6)
	lea	-500(a6),a0
	move.l	a0,d4
	clr.l	-12(a6)
	clr.l	-60(a6)
	clr.w	-92(a6)
	clr.l	-64(a6)
	move.w	#96,-94(a6)
	move.l	#-1073708793,-44(a6)
	move.l	#16715520,a0
	move.l	a0,-84(a6)
	move.l	#-1,4(a0)
	move.l	-84(a6),a0
	move.l	#-1,8(a0)
	move.l	-84(a6),a0
	move.l	#-1,12(a0)
	move.l	#L173,-(sp)
	jsr	_puts
	addq.w	#4,sp
L174:
	move.l	8(a6),a0
	move.l	(a0),d0
	and.l	#4194304,d0
	beq	L176
	move.l	#L177,-(sp)
	pea	-240(a6)
	jsr	_strcpy
	addq.w	#8,sp
	move.l	8(a6),a0
	move.l	(a0),d0
	and.l	#-4194305,d0
	move.l	8(a6),a0
	move.l	d0,(a0)
L178:
	lea	-240(a6),a0
	move.l	a0,-500(a6)
	addq.l	#1,-500(a6)
	move.b	(a0),d5
	clr.w	d0
	move.b	d5,d0
	cmp.w	#65,d0
	blt	L339
	cmp.w	#87,d0
	bgt	L339
T133:
	sub.w	#65,d0
	ext.l	d0
	asl.l	#2,d0
	move.l	4(pc,d0.l),a0
	jmp	(a0)
	.dc.l	L312
	.dc.l	L183
	.dc.l	L339
	.dc.l	L288
	.dc.l	L339
	.dc.l	L258
	.dc.l	L322
	.dc.l	L339
	.dc.l	L339
	.dc.l	L339
	.dc.l	L339
	.dc.l	L319
	.dc.l	L262
	.dc.l	L339
	.dc.l	L339
	.dc.l	L339
	.dc.l	L336
	.dc.l	L291
	.dc.l	L215
	.dc.l	L326
	.dc.l	L339
	.dc.l	L339
	.dc.l	L210
L181:
	move.l	#16715520,d6
	move.l	d6,a0
	move.w	(a0),-110(a6)
L341:
	tst.w	-92(a6)
	beq	L342
	clr.b	-514(a6)
	cmp.w	#2,-92(a6)
	beq	L344
	cmp.w	#3,-92(a6)
	bne	L343
L344:
	move.l	d6,a0
	move.w	(a0),d0
	or.w	#2048,d0
	move.l	d6,a0
	move.w	d0,(a0)
L343:
	cmp.w	#1,-92(a6)
	bne	L345
	move.l	8(a6),-(sp)
	jsr	_exec
	addq.w	#4,sp
	clr.w	-92(a6)
	move.b	#1,-514(a6)
L345:
	cmp.w	#2,-92(a6)
	bne	L346
	tst.l	-64(a6)
	beq	L347
	move.l	8(a6),-(sp)
	jsr	_exec
	addq.w	#4,sp
	subq.l	#1,-64(a6)
	move.b	#1,-514(a6)
L346:
	cmp.w	#3,-92(a6)
	bne	L349
	tst.l	-518(a6)
	beq	L349
	move.l	8(a6),-(sp)
	jsr	_exec
	addq.w	#4,sp
	move.l	8(a6),a0
	move.l	8(a0),-68(a6)
	clr.l	-48(a6)
L350:
	move.l	-48(a6),d0
	cmp.l	-518(a6),d0
	bge	L349
	move.l	-48(a6),d0
	asl.l	#2,d0
	lea	-582(a6),a0
	add.l	d0,a0
	move.l	-68(a6),d0
	cmp.l	(a0),d0
	bne	L351
	move.b	#1,-514(a6)
	lea	-598(a6),a0
	add.l	-48(a6),a0
	cmp.b	#32,(a0)
	bne	L351
	clr.w	-92(a6)
L351:
	addq.l	#1,-48(a6)
	bra	L350
L349:
	move.l	d6,a0
	move.w	(a0),d0
	and.w	#32768,d0
	beq	L355
	clr.w	-92(a6)
L355:
	cmp.b	#1,-514(a6)
	bne	L341
	move.w	-94(a6),-(sp)
	clr.w	-(sp)
	move.l	-44(a6),-(sp)
	move.l	8(a6),-(sp)
	jsr	_dispregs
	lea	12(sp),sp
	bra	L341
L347:
	clr.w	-92(a6)
	bra	L346
L342:
	move.l	d6,a0
	move.w	-110(a6),(a0)
	bra	L174
L339:
	move.l	#L340,-(sp)
	jsr	_puts
	addq.w	#4,sp
	bra	L181
L176:
	move.l	#L179,-(sp)
	jsr	_puts
	addq.w	#4,sp
	pea	-240(a6)
	jsr	_getssu
	addq.w	#4,sp
	cmp.b	#13,-240(a6)
	bne	L180
	pea	-368(a6)
	pea	-240(a6)
	jsr	_strcpy
	addq.w	#8,sp
L180:
	pea	-240(a6)
	pea	-368(a6)
	jsr	_strcpy
	addq.w	#8,sp
	bra	L178
L183:
	move.l	-500(a6),a0
	move.b	(a0),d5
	cmp.b	#80,d5
	bne	L184
	addq.l	#1,-500(a6)
	move.l	d4,-(sp)
	jsr	_gets2h
	move.l	d0,-4(a6)
	move.l	-84(a6),a0
	move.l	-4(a6),8(a0)
	move.l	d4,(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,-4(a6)
	move.l	-84(a6),a0
	move.l	-4(a6),12(a0)
	bra	L181
L184:
	moveq.l	#0,d3
	move.l	#16711936,-98(a6)
	cmp.b	#79,d5
	bne	L186
	clr.l	-32(a6)
	moveq.l	#64,d3
	move.l	#1024,d6
L186:
	cmp.b	#76,d5
	bne	L187
	move.l	#32768,-32(a6)
	moveq.l	#64,d3
	move.l	#16646144,d6
L187:
	tst.l	d3
	beq	L188
	move.w	#1024,-(sp)
	clr.w	-(sp)
	clr.l	-(sp)
	jsr	_memset
	addq.w	#8,sp
	clr.l	-48(a6)
L189:
	move.l	-48(a6),d0
	cmp.l	d3,d0
	bge	L191
	move.w	#1,-(sp)
	move.w	#1,-(sp)
	move.l	-32(a6),-(sp)
	jsr	_sec1rw
	addq.w	#8,sp
	move.l	#16712192,-106(a6)
	clr.l	-52(a6)
L192:
	cmp.l	#256,-52(a6)
	bge	L194
	move.l	-106(a6),a0
	addq.l	#2,-106(a6)
	move.l	d6,a1
	addq.l	#2,d6
	move.w	(a0),(a1)
	addq.l	#1,-52(a6)
	bra	L192
L194:
	addq.l	#1,-32(a6)
	addq.l	#1,-48(a6)
	bra	L189
L191:
	cmp.b	#79,d5
	bne	L181
	addq.l	#1,-500(a6)
	move.l	d4,-(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,d3
	cmp.l	#-1,d3
	bne	L181
	move.l	8(a6),a0
	move.l	#1024,8(a0)
	move.l	#1,-64(a6)
	move.w	#1,-92(a6)
	clr.b	-368(a6)
	bra	L181
L188:
	cmp.b	#83,d5
	bne	L198
	clr.l	-32(a6)
	move.l	#36864,-36(a6)
	move.l	#36864,d3
	move.l	#L199,-(sp)
	jsr	_puts
	addq.w	#4,sp
L200:
	move.l	#L204,-(sp)
	jsr	_checkyn
	addq.w	#4,sp
	move.w	d0,-112(a6)
	move.w	#13,-(sp)
	jsr	_OUTCH
	addq.w	#2,sp
	tst.w	-112(a6)
	beq	L181
	tst.l	d3
	beq	L181
	clr.l	-48(a6)
L206:
	move.l	-48(a6),d0
	cmp.l	d3,d0
	bge	L181
	move.l	-48(a6),d0
	and.l	#511,d0
	bne	L209
	move.w	#46,-(sp)
	jsr	_OUTCH
	addq.w	#2,sp
L209:
	clr.w	-(sp)
	move.w	#1,-(sp)
	move.l	-32(a6),-(sp)
	jsr	_sec1rw
	addq.w	#8,sp
	clr.w	-(sp)
	move.w	#2,-(sp)
	move.l	-36(a6),-(sp)
	jsr	_sec1rw
	addq.w	#8,sp
	addq.l	#1,-32(a6)
	addq.l	#1,-36(a6)
	addq.l	#1,-48(a6)
	bra	L206
L198:
	cmp.b	#82,d5
	bne	L181
	move.l	#36864,-32(a6)
	clr.l	-36(a6)
	move.l	#36864,d3
	move.l	#L202,-(sp)
	jsr	_puts
	addq.w	#4,sp
	bra	L200
L210:
	move.l	-500(a6),a0
	move.b	(a0),d5
	cmp.b	#77,d5
	bne	L181
	move.l	#16728064,d6
	clr.l	-48(a6)
L212:
	cmp.l	#8192,-48(a6)
	bge	L181
	move.l	d6,a0
	move.l	d6,a1
	move.w	(a0),(a1)
	addq.l	#2,d6
	addq.l	#1,-48(a6)
	bra	L212
L215:
	move.l	-500(a6),a0
	addq.l	#1,-500(a6)
	move.b	(a0),d5
	cmp.b	#70,d5
	bne	L216
	moveq.l	#5,d7
L217:
	move.l	#16711936,-98(a6)
	move.l	d4,-(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,-4(a6)
	cmp.w	#5,d7
	bne	L224
	move.l	d4,-(sp)
	jsr	_gets2h
	move.l	d0,d3
	move.l	d4,(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,-24(a6)
	move.l	#16712192,-500(a6)
	clr.l	-48(a6)
L225:
	cmp.l	#512,-48(a6)
	bge	L227
	move.l	-500(a6),a0
	addq.l	#1,-500(a6)
	move.b	-21(a6),(a0)
	addq.l	#1,-48(a6)
	bra	L225
L227:
	clr.l	-32(a6)
L228:
	move.l	-32(a6),d0
	cmp.l	d3,d0
	bge	L181
	clr.w	-(sp)
	move.w	#2,-(sp)
	move.l	-4(a6),d0
	add.l	-32(a6),d0
	move.l	d0,-(sp)
	jsr	_sec1rw
	addq.w	#8,sp
	addq.l	#1,-32(a6)
	bra	L228
L224:
	cmp.w	#3,d7
	bge	L232
	clr.w	-(sp)
	move.w	d7,-(sp)
	move.l	-4(a6),-(sp)
	jsr	_sec1rw
	addq.w	#8,sp
	move.l	#512,-(sp)
	move.l	#16712192,-(sp)
	jsr	_dumpdt
	addq.w	#8,sp
	bra	L181
L232:
	cmp.w	#3,d7
	bne	L234
	move.l	-4(a6),d0
	add.l	#131072,d0
	move.l	d0,-4(a6)
L234:
	move.l	d4,-(sp)
	jsr	_gets2h
	move.l	d0,d3
	move.l	d4,(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,-24(a6)
	move.l	-4(a6),-8(a6)
	move.l	-24(a6),-28(a6)
	clr.l	-32(a6)
L235:
	move.l	-32(a6),d0
	cmp.l	d3,d0
	bge	L237
	cmp.w	#3,d7
	bne	L238
	move.l	#16712192,-500(a6)
L239:
	clr.l	-48(a6)
L240:
	cmp.l	#512,-48(a6)
	bge	L242
	move.l	-28(a6),d0
	add.l	-48(a6),d0
	and.l	#255,d0
	move.l	-500(a6),d1
	addq.l	#1,-500(a6)
	move.l	d1,a0
	move.b	d0,(a0)
	addq.l	#1,-48(a6)
	bra	L240
L242:
	cmp.w	#3,d7
	bne	L243
	clr.w	-(sp)
	move.w	#2,-(sp)
	move.l	-4(a6),-(sp)
	jsr	_sec1rw
	addq.w	#8,sp
L243:
	addq.l	#1,-4(a6)
	move.l	-28(a6),d0
	add.l	-24(a6),d0
	move.l	d0,-28(a6)
	move.w	#46,-(sp)
	jsr	_OUTCH
	addq.w	#2,sp
	addq.l	#1,-32(a6)
	bra	L235
L238:
	move.l	-4(a6),d0
	moveq.l	#9,d1
	asl.l	d1,d0
	move.l	d0,-500(a6)
	bra	L239
L237:
	move.l	-8(a6),-4(a6)
	move.l	-24(a6),-28(a6)
	clr.l	-32(a6)
L244:
	move.l	-32(a6),d0
	cmp.l	d3,d0
	bge	L181
	cmp.w	#3,d7
	bne	L247
	move.l	#16712192,-500(a6)
	clr.l	-48(a6)
L248:
	cmp.l	#512,-48(a6)
	bge	L250
	move.l	-500(a6),a0
	addq.l	#1,-500(a6)
	clr.b	(a0)
	addq.l	#1,-48(a6)
	bra	L248
L250:
	clr.w	-(sp)
	move.w	#1,-(sp)
	move.l	-4(a6),-(sp)
	jsr	_sec1rw
	addq.w	#8,sp
L247:
	cmp.w	#3,d7
	bne	L251
	move.l	#16712192,-500(a6)
L252:
	clr.l	-48(a6)
L253:
	cmp.l	#512,-48(a6)
	bge	L255
	move.l	-500(a6),a0
	addq.l	#1,-500(a6)
	move.b	(a0),-512(a6)
	move.l	-28(a6),d0
	add.l	-48(a6),d0
	and.l	#255,d0
	move.b	d0,-513(a6)
	move.b	-512(a6),d0
	cmp.b	-513(a6),d0
	beq	L254
	move.l	#L257,-(sp)
	jsr	_puts
	move.l	-4(a6),(sp)
	jsr	_puth8
	addq.w	#4,sp
	move.w	#58,-(sp)
	jsr	_OUTCH
	move.w	-46(a6),(sp)
	jsr	_puth4
	move.w	#32,(sp)
	jsr	_OUTCH
	clr.w	d0
	move.b	-513(a6),d0
	move.w	d0,(sp)
	jsr	_puth2
	move.w	#62,(sp)
	jsr	_OUTCH
	clr.w	d0
	move.b	-512(a6),d0
	move.w	d0,(sp)
	jsr	_puth2
	addq.w	#2,sp
L254:
	addq.l	#1,-48(a6)
	bra	L253
L255:
	addq.l	#1,-4(a6)
	move.l	-28(a6),d0
	add.l	-24(a6),d0
	move.l	d0,-28(a6)
	move.w	#33,-(sp)
	jsr	_OUTCH
	addq.w	#2,sp
	addq.l	#1,-32(a6)
	bra	L244
L251:
	move.l	-4(a6),d0
	moveq.l	#9,d1
	asl.l	d1,d0
	move.l	d0,-500(a6)
	bra	L252
L216:
	cmp.b	#77,d5
	bne	L218
	moveq.l	#4,d7
	bra	L217
L218:
	cmp.b	#84,d5
	bne	L220
	moveq.l	#3,d7
	bra	L217
L220:
	cmp.b	#87,d5
	bne	L222
	moveq.l	#2,d7
	bra	L217
L222:
	moveq.l	#1,d7
	bra	L217
L258:
	move.l	d4,-(sp)
	jsr	_gets2h
	move.l	d0,-4(a6)
	addq.l	#1,-500(a6)
	move.l	d4,(sp)
	jsr	_gets2h
	move.l	d0,d3
	addq.l	#1,-500(a6)
	move.l	d4,(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,-16(a6)
	clr.l	-24(a6)
L259:
	move.l	-24(a6),d0
	cmp.l	d3,d0
	bge	L181
	move.l	-4(a6),d0
	addq.l	#1,-4(a6)
	add.l	_mbase,d0
	move.l	d0,a0
	move.b	-13(a6),(a0)
	addq.l	#1,-24(a6)
	bra	L259
L262:
	move.l	-500(a6),a0
	cmp.b	#83,(a0)
	bne	L263
	moveq.l	#9,d7
	addq.l	#1,-500(a6)
L264:
	move.l	d4,-(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,-4(a6)
	cmp.w	#9,d7
	bne	L269
	move.l	#16715520,d6
	move.l	d6,a0
	move.w	-2(a6),(a0)
	bra	L181
L269:
	cmp.w	#8,d7
	bne	L276
	move.l	d4,-(sp)
	jsr	_gets2h
	move.l	d0,-24(a6)
	move.l	d4,(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,d3
	move.l	-4(a6),-500(a6)
	move.l	-24(a6),-508(a6)
	clr.l	-48(a6)
L272:
	move.l	-48(a6),d0
	cmp.l	d3,d0
	bge	L181
	move.l	-500(a6),a0
	addq.l	#1,-500(a6)
	move.l	-508(a6),a1
	addq.l	#1,-508(a6)
	move.b	(a0),(a1)
	addq.l	#1,-48(a6)
	bra	L272
L276:
	cmp.b	#46,d5
	beq	L181
	move.l	-4(a6),-(sp)
	jsr	_putadrhd
	addq.w	#4,sp
	move.w	#32,-(sp)
	jsr	_OUTCH
	move.l	_mbase,d0
	add.l	-4(a6),d0
	move.l	d0,a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,(sp)
	jsr	_puth2
	addq.w	#2,sp
	cmp.w	#2,d7
	bne	L278
	move.l	-4(a6),d0
	addq.l	#1,d0
	add.l	_mbase,d0
	move.l	d0,a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,-(sp)
	jsr	_puth2
	addq.w	#2,sp
L278:
	move.w	#32,-(sp)
	jsr	_OUTCH
	addq.w	#2,sp
	pea	-240(a6)
	jsr	_getssu
	lea	-240(a6),a0
	move.l	a0,-500(a6)
	move.l	d4,(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,-16(a6)
	move.l	-500(a6),a0
	move.b	(a0),d5
	cmp.b	#13,d5
	bne	L279
	tst.l	-16(a6)
	blt	L279
	cmp.w	#1,d7
	bne	L280
	tst.l	-16(a6)
	blt	L279
	move.l	_mbase,d0
	add.l	-4(a6),d0
	move.l	d0,a0
	move.b	-13(a6),(a0)
	move.l	_mbase,d0
	add.l	-4(a6),d0
	move.l	d0,a0
	moveq.l	#0,d0
	move.b	(a0),d0
	move.l	d0,-20(a6)
	move.b	-13(a6),d0
	cmp.b	-17(a6),d0
	beq	L279
	subq.l	#1,-4(a6)
L279:
	cmp.b	#45,d5
	bne	L286
	move.w	d7,d0
	ext.l	d0
	move.l	-4(a6),d1
	sub.l	d0,d1
	move.l	d1,-4(a6)
	bra	L276
L286:
	move.w	d7,d0
	ext.l	d0
	add.l	-4(a6),d0
	move.l	d0,-4(a6)
	bra	L276
L280:
	move.l	_mbase,d0
	add.l	-4(a6),d0
	move.l	d0,d6
	tst.l	-16(a6)
	blt	L279
	move.l	d6,a0
	move.w	-14(a6),(a0)
	move.l	d6,a0
	moveq.l	#0,d0
	move.w	(a0),d0
	move.l	d0,-20(a6)
	move.w	-14(a6),d0
	cmp.w	-18(a6),d0
	beq	L279
	move.l	-4(a6),d0
	subq.l	#2,d0
	move.l	d0,-4(a6)
	bra	L279
L263:
	move.l	-500(a6),a0
	cmp.b	#77,(a0)
	bne	L265
	moveq.l	#8,d7
	addq.l	#1,-500(a6)
	bra	L264
L265:
	move.l	-500(a6),a0
	cmp.b	#87,(a0)
	bne	L267
	moveq.l	#2,d7
	addq.l	#1,-500(a6)
	bra	L264
L267:
	moveq.l	#1,d7
	bra	L264
L288:
	move.l	d4,-(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,-4(a6)
	cmp.l	#-1,d0
	bne	L289
	move.l	-60(a6),-4(a6)
L289:
	move.l	d4,-(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,d3
	cmp.l	#-1,d3
	bne	L290
	move.l	#128,d3
L290:
	move.l	d3,-(sp)
	move.l	-4(a6),-(sp)
	jsr	_dumpdt
	addq.w	#8,sp
	move.l	-4(a6),d0
	add.l	d3,d0
	move.l	d0,-60(a6)
	bra	L181
L291:
	move.l	-500(a6),a0
	addq.l	#1,-500(a6)
	move.b	(a0),d5
	clr.w	-108(a6)
	cmp.b	#68,d5
	bne	L292
	move.w	#5,-108(a6)
L293:
	tst.w	-108(a6)
	bls	L304
	cmp.w	#1,-108(a6)
	bne	L305
	move.l	d4,-(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,-4(a6)
	move.l	8(a6),d6
	move.l	-4(a6),d0
	and.l	#65535,d0
	move.l	d6,a0
	move.w	d0,2(a0)
L304:
	move.l	-44(a6),-24(a6)
	cmp.b	#77,d5
	beq	L311
	move.l	#-16711681,-44(a6)
L311:
	move.w	-94(a6),-(sp)
	move.w	#1,-(sp)
	move.l	-44(a6),-(sp)
	move.l	8(a6),-(sp)
	jsr	_dispregs
	lea	12(sp),sp
	move.l	-24(a6),-44(a6)
	bra	L181
L305:
	cmp.w	#2,-108(a6)
	bls	L307
	move.l	-500(a6),a0
	addq.l	#1,-500(a6)
	clr.w	d0
	move.b	(a0),d0
	sub.w	#48,d0
	add.w	-108(a6),d0
	move.w	d0,-108(a6)
L307:
	move.l	d4,-(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,-4(a6)
	move.w	-108(a6),d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	8(a6),d1
	move.l	d1,a0
	move.l	-4(a6),(a0)
	cmp.w	#20,-108(a6)
	bne	L304
	move.l	8(a6),a0
	move.l	(a0),d0
	and.l	#8192,d0
	beq	L309
	move.l	8(a6),a0
	move.l	-4(a6),12(a0)
	bra	L304
L309:
	move.l	8(a6),a0
	move.l	-4(a6),16(a0)
	bra	L304
L292:
	cmp.b	#65,d5
	bne	L294
	move.w	#13,-108(a6)
	bra	L293
L294:
	cmp.b	#87,d5
	bne	L296
	move.w	#21,-108(a6)
	bra	L293
L296:
	cmp.b	#80,d5
	bne	L298
	move.w	#2,-108(a6)
	bra	L293
L298:
	cmp.b	#83,d5
	bne	L300
	move.w	#1,-108(a6)
	bra	L293
L300:
	cmp.b	#77,d5
	bne	L293
	clr.w	-108(a6)
	move.l	d4,-(sp)
	jsr	_gets2h
	move.l	d0,-44(a6)
	move.l	d4,(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.w	d0,-94(a6)
	cmp.w	#-1,d0
	bne	L293
	move.w	#96,-94(a6)
	bra	L293
L312:
	cmp.b	#44,-239(a6)
	bne	L313
	addq.l	#1,-500(a6)
	move.l	8(a6),a0
	move.l	8(a0),-4(a6)
L314:
	move.l	d4,-(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,d3
	cmp.l	#1,d3
	bge	L315
	moveq.l	#16,d3
L315:
	clr.l	-48(a6)
L316:
	move.l	-48(a6),d0
	cmp.l	d3,d0
	bge	L181
	move.l	-4(a6),-(sp)
	jsr	_putadrhd
	addq.w	#4,sp
	pea	-496(a6)
	move.l	-4(a6),-(sp)
	jsr	_DISASM
	addq.w	#8,sp
	move.l	d0,-4(a6)
	move.w	#32,-(sp)
	jsr	_OUTCH
	addq.w	#2,sp
	pea	-496(a6)
	jsr	_puts
	addq.w	#4,sp
	addq.l	#1,-48(a6)
	bra	L316
L313:
	move.l	d4,-(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,-4(a6)
	bra	L314
L319:
	move.l	#L320,-(sp)
	jsr	_puts
	addq.w	#4,sp
	jsr	_loadhex
	move.l	-500(a6),a0
	cmp.b	#71,(a0)
	bne	L181
	clr.l	-56(a6)
	move.l	-56(a6),a0
	lea	4(a0),a0
	move.l	8(a6),a1
	move.l	(a0),8(a1)
	move.l	#1,-64(a6)
	move.w	#1,-92(a6)
	bra	L181
L322:
	move.l	-500(a6),a0
	cmp.b	#44,(a0)
	beq	L323
	move.l	d4,-(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,-4(a6)
	cmp.l	#-1,d0
	beq	L323
	move.l	8(a6),a0
	move.l	-4(a6),8(a0)
L323:
	move.l	-500(a6),a0
	cmp.b	#44,(a0)
	bne	L325
	addq.l	#1,-500(a6)
	move.l	d4,-(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,-4(a6)
	move.l	-84(a6),a0
	move.l	-4(a6),4(a0)
L325:
	move.l	#1,-64(a6)
	move.w	#1,-92(a6)
	bra	L181
L326:
	move.l	-500(a6),a0
	cmp.b	#44,(a0)
	bne	L327
	cmp.b	#13,-238(a6)
	beq	L328
	addq.l	#1,-500(a6)
	clr.l	-518(a6)
	clr.l	-4(a6)
L329:
	cmp.l	#-1,-4(a6)
	beq	L328
	move.l	d4,-(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,-4(a6)
	cmp.l	#-1,d0
	beq	L329
	move.l	-518(a6),d0
	asl.l	#2,d0
	lea	-582(a6),a0
	add.l	d0,a0
	move.l	-4(a6),(a0)
	move.l	-500(a6),a0
	cmp.b	#44,(a0)
	bne	L332
	lea	-598(a6),a0
	add.l	-518(a6),a0
	move.b	#44,(a0)
	addq.l	#1,-500(a6)
L333:
	addq.l	#1,-518(a6)
	bra	L329
L332:
	lea	-598(a6),a0
	add.l	-518(a6),a0
	move.b	#32,(a0)
	bra	L333
L328:
	move.w	#3,-92(a6)
	bra	L181
L327:
	move.l	d4,-(sp)
	jsr	_gets2h
	addq.w	#4,sp
	move.l	d0,d3
	cmp.l	#-1,d3
	bne	L335
	moveq.l	#1,d3
L335:
	move.l	d3,-64(a6)
	move.w	#2,-92(a6)
	bra	L181
L336:
	move.l	#16715520,d6
	move.l	-500(a6),a0
	cmp.b	#48,(a0)
	bne	L337
	move.l	d6,a0
	move.w	(a0),d0
	or.w	#8192,d0
	move.l	d6,a0
	move.w	d0,(a0)
	bra	L181
L337:
	move.l	d6,a0
	move.w	(a0),d0
	and.w	#57343,d0
	move.l	d6,a0
	move.w	d0,(a0)
	bra	L181
