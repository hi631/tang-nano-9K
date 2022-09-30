.SUFFIXES : .x .o .c .s

CC=..\..\bin\hcc
TOP=..\..\bin\top
AS=..\..\bin\jas
LD=..\..\bin\ld
MF=..\..\bin\srec_cat
RM=del
INC= -I..\..\\include\\

all     :       mon68k


mon68k:  startup.o mon68k.o mon68k_dis.o
	$(LD) -o mon68k.bin startup.o mon68k.o mon68k_dis.o
	..\..\bin\bin2bin mon68k.bin mon68kH.bin FF4000
	..\..\bin\bin2mi mon68kh.bin mon68kh.mi 16 8192
	del mon68k.o mon68k.bin,startup.o mon68k_dis.o

clean:
	$(RM) *.o
	$(RM) mon68k.s
	$(RM) mon68k.bin

.c.o: 
	@-echo "Making component -> $*.o"
	$(CC) $(INC) $< 
	$(TOP) $*.s
	$(AS) $*.s

.c.s:;

.s.o:
	@-echo "Making component -> $*.o"
	$(AS) $(CDIR)$*.s


# dependencies -- DO NOT DELETE BELOW THIS LINE -- make depends on it.

mon68k.o   : mon68k.c
startup.o  : startup.s
mon68k_dis.o : mon68k_dis.s
