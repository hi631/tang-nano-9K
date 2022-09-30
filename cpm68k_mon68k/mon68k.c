/* Setup-> gowin_prom Depth:8192 Width:16 Files:mon68kh.mi */
extern void OUTCH();
extern int INCH();
extern int KBHIT();
extern void EXEC();
extern long DISASM();

#define SDCDCTL 0xff0100L
#define SDCDBUF 0xff0200L
#define SYSMODE 0xff0f00L
#define getch() INCH()
#define putch(ch) OUTCH(ch)

void exec(lstp) long *lstp;{  EXEC(); }
void puts(buf) char *buf;{ while(*buf!=0) putch(*buf++); }
void gets(buf) char buf[];{
  char ch = 0; int ct = 0;
  while(ch!=0x0d) { 
    ch = getch();
    if(ch==0x08) {if(ct!=0) {putch(0x08);putch(0x20);putch(0x08); ct--; } }
    else   { putch(ch); buf[ct++] = ch; }
  }
}
void puth(dt) int dt;{ if(dt<10) putch(0x30+dt); else putch(0x37+dt); }
void puth2(dt) int dt;{ puth((dt >> 4) & 0xf); puth(dt & 0xf); }
void puth4(dt) int dt;{ puth2((dt >> 8) & 0xff); puth2(dt & 0xff); }
void puth6(dt) long dt;{ int dh,dl; dh = dt >> 16; dl = dt & 0xffff; puth2(dh); puth4(dl); }
void puth8(dt) long dt;{ int dh,dl; dh = dt >> 16; dl = dt & 0xffff; puth4(dh); puth4(dl); }
void setsup(buf) char *buf;{
  while(*buf!=0x0d){
   if( *buf>='a' && *buf<='z') *buf = *buf - 0x20;
   buf++;
  }
  buf = 0;
}
int ishex(ch) char ch;{
  int hd;
  if(ch>='0' && ch<='9') hd = ch - 0x30;
  else if(ch>='A' && ch<='F') hd = ch - 0x37;
  else hd = -1;
  return hd;
}
long gets2h(buf) char **buf;{
  long num = 0; int hd;
  while(**buf==' ' || **buf==',') (*buf)++; /* spip sp*/
  if(**buf<' ') return -1;
  while( (hd=ishex(**buf)) != -1){ num = num * 16 + hd; (*buf)++; }
  return num;
}
int geth1b(){ 
  int dt;
  dt = ishex(getch()) * 16 + ishex(getch());
  puth2(dt);
  return dt;
}
unsigned int geth2b(){ return geth1b() * 256 + geth1b(); }

unsigned char  *mbase= (unsigned char *)0x000000;
void putadrhd(adr) long adr;{putch('\n'); puth6(adr); putch(':');}
void getssu(cbuf) char *cbuf;{ gets(cbuf); setsup(cbuf);}

void loadhex(){
  char ch;
  int i,ll;
  unsigned char dt, mf;
  long adr;
  int eof = 0;
  while(eof==0){
    while(getch()!=':') ;
    ll = geth1b(); adr = geth2b(); mf = geth1b();
    /*adr = 0xfe0000 + adr;*/
    if(mf==0x01) {dt = geth1b(); eof = 1;}
    else
      for(i=0; i<ll; i++){ dt = geth1b(); mbase[adr++] = dt; }
    puts("\n");
  }
  getch();
}

int strlen(buf) char *buf;{
  int rc = 0;
  while(*buf++!=0) rc++;
  return rc;
}
void strcat(pd,ps) char *pd; char *ps;{
  pd = pd + strlen(pd);
  while(*ps!=0) *pd++ = *ps++;
  *pd = 0;
}
void strcpy(ds,ss) char *ds; char *ss; {
  while(*ss!=0) *ds++ = *ss++;
  *ds = 0;
}

void dispr1(lab,dt) char *lab; long dt;{ puts(lab); puth8(dt); }
void dispregs(lstp, regmd, pcmd, dplen) long *lstp; long regmd; int pcmd; int dplen; {
  long pc, npc, regbp, *lsmp; 
  int srreg, i,j,rc,dpl; char lbf[5];
  unsigned int regsr;
  char buf[128], bbf[16];
  unsigned char *cp;
  dpl = 0;
  
  if(pcmd==0) { lsmp = (long *)SYSMODE; pc = *(lsmp+1); }   /* Exec pc */
  else          pc = *(lstp+2);                             /* Next pc */
  if(regmd & 0x80000000) { puts("PC:"); puth6(pc); putch(' '); dpl = dpl + 10; }
  if(regmd & 0x40000000) { 
    npc = DISASM( pc, &buf[0]); rc = npc - pc;
    strcat(buf, "                                "); buf[28] = 0; dpl = dpl + 28;
	puts(buf); buf[0] = 0;
    if(regmd & 0x20000000) { 
      for(i=0; i<8; i++){
	    cp = (unsigned char *)(pc + (long)i);
        if(i<rc) puth2(*cp);
        else     puts("..");
      }
      dpl = dpl + 17;
    }
  }

  regsr = (unsigned int)(*(lstp+0) & (long)0xffff);
  if((regsr & 0x2000)!=0) *(lstp+20) = *(lstp+3); /* A7 <- SSP */
  else                    *(lstp+20) = *(lstp+4); /* A7 <- USP */
  if(regmd & 0x08000000) { puts(" SS:"); puth8(*(lstp+3)); dpl = dpl + 12; }
  if(regmd & 0x04000000) { puts(" US:"); puth8(*(lstp+4)); dpl = dpl + 12; }
  if(regmd & 0x02000000) { puts(" SR:"); puth4(regsr); dpl = dpl + 8; }
  if(regmd & 0x01000000) { puts("\n"); dpl = 0; }

  lbf[0] = ' '; lbf[3] = ':'; lbf[4] = 0;
  regbp = 0x000001;
  for(i=0; i<3; i++){
    if(i==0)      lbf[1] = 'D'; 
    else if(i==1) lbf[1] = 'A';
    else          lbf[1] = 'W';
    for(j=0; j<8; j++){ 
	  if(dpl>=dplen) { putch(0x0d); dpl = 0;}
	  if(regmd & regbp) {lbf[2] = 0x30+j; dispr1( lbf, *(lstp+5+i*8+j)); dpl = dpl + 12;}
	  regbp = regbp << 1;
	}
  }
  if(dpl!=0) putch(0x0d);
  return rc;
}

void sec1rw(sct,rwmd,dpmd)
    long sct; 
    unsigned int rwmd, dpmd;
{
    unsigned int *cmp, sum, i, j;
    unsigned char *sbp;
    cmp = (unsigned int *)SDCDCTL;
    *(cmp+1) = sct >> 16; *(cmp+2) = sct & 0xffff;
    *cmp = rwmd;              /* Read.Secter */
    while((*cmp & 1)==1) ;  /* Busy.Wait */
	cmp = (unsigned int *)SYSMODE;
	if((*cmp & 1)==0) {
	    if(dpmd!=0) putch('.');
	} else {
	    sum = 0;sbp = (unsigned char *)SDCDBUF; sum = 0; /* サム値の表示 */
        for(j=0; j<256; j++) { sum = sum + (unsigned int)*sbp++; }
	    putch('['); puth4(sum); putch(']');
	}
}

void dumpdt(adr,sl) long adr, sl; {
    int i,j;
    sl = sl >> 4; 
    for(i=0; i<sl; i++){
      putadrhd(adr);
      for(j=0; j<16; j++) { putch(' '); puth2(mbase[adr++]); }
    }
}

int checkyn(msg) char *msg; {
  char ch;
  puts("Start?(Y/N) = "); ch = getch();
  if(ch>=0x60) ch = ch - 0x20;
  if(ch=='Y') return -1;
  else        return 0;
}

void memset(ad,ch,dl) long ad; int ch, dl; {
  unsigned char *cbp;
  int i;
  cbp = (unsigned char *)ad;
  for(i=0; i<dl; i++) *cbp++ = ch;
}

int main(lstp) long *lstp; {	/* lstp = svstop */
  long adr,ade,adro,dt,dtr,wk,wk2,sct,scr,sl,regmd, i,j, *lwk;
  long dmpo, trcct, pc, rpc, rss;
  long *lp, *lsmp;
  int mmd,idt, exf, bctl, displen;
  unsigned int * cmp, *wrp, *sbp, rno, wd, rc;
  unsigned char cbuf[128], cbufo[128], abuf[128], *cbp, **cbpp, *cbp2;
  unsigned char cmd, cmdo, ch, cdt, cd2, dprreq;

  long  tracect = 0;
  long  tracead[16];
  char tracebk[16];
  
  cbpp = &cbp; adro = 0; dmpo = 0; bctl = 0; trcct = 0; displen = 96;
  regmd = 0xc0008107; /* PC:ASM:D0/D1/D2:A0/A7 */
  lsmp = (long *)SYSMODE;
  /* *(lsmp+1) = 0xffffffff; */
  *(lsmp+1) = 0xffffffff; *(lsmp+2) = 0xffffffff; *(lsmp+3) = 0xffffffff; /*brk.clear*/
  puts("Mon68K\n");     /* Reset.Ent */
  while(1){
    if((*lstp & 0x00400000L)!=0){
	  strcpy(cbuf, "BO\r"); *lstp = *lstp & 0xffbfffff;
	} else {
      puts("\n>"); getssu(cbuf);
      if(cbuf[0]==0x0d) strcpy(cbuf, cbufo);
      strcpy(cbufo,cbuf);
	}
    cbp = &cbuf[0]; cmd = *cbp++;
    switch(cmd){
      case 'B':
        cmd = *cbp;
		if(cmd=='P') {  /* >bp adr0 adr1 */
		    cbp++;
            adr = gets2h(cbpp); *(lsmp+2) = adr;  /* brk1 */
            adr = gets2h(cbpp); *(lsmp+3) = adr;  /* brk2 */
		} else {
            sl = 0; cmp = (unsigned int *)SDCDCTL;
            if(cmd=='O'){ sct = 0x0000; sl = 64; wrp = (unsigned int *)0x000400L; }
            if(cmd=='L'){ sct = 0x8000; sl = 64; wrp = (unsigned int *)0xFE0000L; }
            if(sl!=0){
              memset((long)0,(int)0,(int)0x400);
              for(i=0; i<sl; i++){
                sec1rw(sct, (int)0x01, (int)1);             /* Sector Read */
                sbp = (unsigned int *)SDCDBUF;
                for(j=0; j<256; j++) { *wrp++ = *sbp++; }
                sct++;　
              }
              if(cmd=='O') {
                cbp++; sl = gets2h(cbpp);
                if(sl==-1) { 
				  *(lstp+2) = 0x400L; 
				  trcct = 1; bctl = 1; cbufo[0] = 0;
				}
              }
            } else {
              if(cmd=='S'){ sct = 0     ; scr = 0x9000; sl = 0x9000; 
                puts("save.all(0-8fff -> 9000-11fff)..........................................|\n");}
              else if(cmd=='R'){ sct = 0x9000; scr = 0     ; sl = 0x9000; 
                puts("recover.all(9000-11fff -> 0-9000).......................................|\n");}
              else break;
			  rc = checkyn("Start?(Y/N) = "); putch(0x0d);
              if(rc!=0 && sl!=0){
                for(i=0; i<sl;i++){
                  if((i & 0x1ff)==0) putch('.');
                  sec1rw(sct, (int)0x01, (int)0); sec1rw(scr, (int)0x02, (int)0);   /* R&W */
                  sct++; scr++; 
                }
              }
            }
        }
        break;
      case 'W':
        cmd = *cbp;
        if(cmd=='M'){
          wrp = (unsigned int *)0xff4000L;	/* Mon Adr */
          for(i=0; i<8192; i++) { *wrp = *wrp; wrp++; }  /* ROM -> RAM */
        }
        break;
      case 'S': /* SDカード動作確認 */
	  	cmd = *cbp++;
	  	if     (cmd=='F') mmd = 5;  /* SFxx yy zz ; SD書き込み xxから長さyyにzzパターンを書く */
	  	else if(cmd=='M') mmd = 4;  /* SMxx yy zz ; メモリテスト xxから長さyyにzzパターンを書く */
	  	else if(cmd=='T') mmd = 3;  /* CTxx yy zz : ＳＤテスト xxから長さyyにzzパターンを書く */
        else if(cmd=='W') mmd = 2;  /* SWxx 　　　: ＳＤのxxの場所にバッファのデータを書く */
        else              mmd = 1;  /* SRxx 　　　: ＳＤのxxの場所のデータをバッファに読む */
       	cmp = (unsigned int *)SDCDCTL;
        adr = gets2h(cbpp);
		if(mmd==5) {
			sl = gets2h(cbpp);		/* 実行長さ */
			wk = gets2h(cbpp);
			cbp = (unsigned char *)SDCDBUF;
		    for(i=0; i<512; i++) *cbp++ = (unsigned char)wk;
			for(sct=0; sct<sl; sct++){
			    sec1rw(adr+sct,(int)0x02, (int)0);  /* パターンを書込む */
			}
		} else 
		if(mmd<3) {
			sec1rw(adr, mmd, (int)0);
			dumpdt(SDCDBUF,512L);
		} else {
			if(mmd==3) adr = adr + 0x20000;	/* 開始位置(SDの未使用領域) */
			sl = gets2h(cbpp);		/* 実行長さ */
			wk = gets2h(cbpp);		/* 実行オフセット*/
			ade = adr; wk2 = wk;
			for(sct=0; sct<sl; sct++){
            	if(mmd==3) cbp = (unsigned char *)SDCDBUF;
				else       cbp = (unsigned char *)(adr << 9);
            	for(i=0; i<512; i++) *cbp++ = (unsigned char)((wk2 + i) & 0xff);
				if(mmd==3){
				    sec1rw(adr,(int)0x02, (int)0);   /* Write */
				}
				adr++; wk2 = wk2 + wk; putch('.');
			}
			adr = ade; wk2 = wk;
			for(sct=0; sct<sl; sct++){
				if(mmd==3){
				    cbp = (unsigned char *)SDCDBUF;
					for(i=0; i<512; i++) *cbp++ = 0;
					sec1rw(adr, (int)0x01, (int)0);
				}
            	if(mmd==3) cbp = (unsigned char *)SDCDBUF;
				else       cbp = (unsigned char *)(adr << 9);
            	for(i=0; i<512; i++) {
					cdt = (unsigned char)*cbp++; cd2 = (unsigned char)((wk2 + i) & 0xff);
					if(cdt != cd2){
						puts("\n*"); puth8(adr); putch(':'); puth4((int)i);
						putch(' '); puth2((int)(cd2)); putch('>'); puth2((int)cdt);
					}
				}
				adr++; wk2 = wk2 + wk; putch('!');
			}
		}
        break;
      case 'F':
        adr = gets2h(cbpp); cbp++;
        sl  = gets2h(cbpp); cbp++;
        dt  = gets2h(cbpp);
        for(wk=0; wk<sl; wk++) mbase[adr++] = dt;
        break;
      case 'M':
        if     (*cbp=='S'){ mmd = 9; cbp++; }
        else if(*cbp=='M'){ mmd = 8; cbp++; }
        else if(*cbp=='W'){ mmd = 2; cbp++; }
		else                mmd = 1;
        adr = gets2h(cbpp);
		
		if(mmd==9) {wrp = (unsigned int *)SYSMODE; *wrp = adr;}
		else 
        if(mmd==8) {
		  wk = gets2h(cbpp); sl = gets2h(cbpp);
		  cbp = (unsigned char *)adr; cbp2 = (unsigned char *)wk; 
		  /* puth8(cbp); putch(' '); puth8(cbp2); putch(' '); puth8(sl); */
		  for(i=0; i<sl; i++) *cbp2++ = *cbp++;
		} else
        while(cmd!='.'){
          putadrhd(adr); 
          putch(' '); puth2(mbase[adr]); if(mmd==2) puth2(mbase[adr+1]);
          putch(' '); 
          getssu(cbuf); cbp = &cbuf[0];
          dt = gets2h(cbpp); cmd = *cbp;
          if(cmd==0x0d && dt>=0){
            if(mmd==1){
              if(dt>=0) {
                mbase[adr] = dt; dtr = mbase[adr]; 
                if((unsigned char)dt!=(unsigned char)dtr) adr--;
              } 
            } else {
              wrp = (unsigned int *)&mbase[adr];
              if(dt>=0) {
                *wrp = dt; dtr = *wrp; 
                if((unsigned int)dt!=(unsigned int)dtr) adr = adr - 2;
              }
            }
          }
          if(cmd=='-') adr = adr - mmd;
          else         adr = adr + mmd;
        }
        break;
      case 'D': 
        adr = gets2h(cbpp);
        if(adr==-1) adr = dmpo;
		sl = gets2h(cbpp); if(sl==-1) sl = 128;
        dumpdt(adr, sl);
        dmpo = adr+sl;
        break;
      case 'R': 
        cmd = *cbp++; rno = 0;
        if     (cmd=='D') rno = 1+4;
        else if(cmd=='A') rno = 1+4+8;
        else if(cmd=='W') rno = 1+4+8+8;
        else if(cmd=='P') rno = 1+1;
        else if(cmd=='S') rno = 1;
        else if(cmd=='M') {
		  rno = 0; regmd = gets2h(cbpp); displen = gets2h(cbpp);
		  if(displen==-1) displen = 96;
		}
        if(rno>0){
		  if(rno==1){ /* SR */
		    adr = gets2h(cbpp); 
			wrp = (unsigned int *)lstp; *(wrp+1) = adr & 0xffff;
		  } else {
            if(rno>2) rno = rno + (*cbp++ - 0x30);
            adr = gets2h(cbpp); *(lstp+rno) = adr;
            if(rno==(1+4+8+7))  
              if((*lstp & 0x2000L)!=0) *(lstp+3) = adr; 
              else                     *(lstp+4) = adr; 
		  }
        }
		wk = regmd; if(cmd!='M') regmd = 0xff00ffff; /* Disp All */
		dispregs(lstp, regmd, 1, displen); regmd = wk;
        break;
      case 'A':
	    if(cbuf[1]==',') { cbp++; adr = *(lstp+2); }
        else             adr = gets2h(cbpp);
		sl  = gets2h(cbpp); if(sl<1) sl = 16;
		for( i=0; i<sl; i++){ putadrhd(adr); adr = DISASM(adr, &abuf[0]); putch(' '); puts(abuf);}
        break;
      case 'L':
        puts("Load(Intel Hex)\n"); loadhex();
		if(*cbp=='G') { lwk = 0l; *(lstp+2) = *(lwk+1); trcct = 1; bctl = 1;}
        break;
      case 'G':
		if(*cbp!=','){
          adr = gets2h(cbpp); 
          if(adr!=-1) *(lstp+2) = adr;
	    }
		if(*cbp==','){
		  cbp++;
          adr = gets2h(cbpp); *(lsmp+1) = adr;  /* Set brk0 */
        }
	    trcct = 1; bctl = 1;
        break;
      case 'T':
		if(*cbp==','){
          if(cbuf[2]!=0x0d){
            cbp++; tracect = 0; adr = 0;
            while(adr!=-1){
              adr = gets2h(cbpp);
              if(adr!=-1) { 
                tracead[tracect] = adr; 
                if(*cbp==',') { tracebk[tracect] = ','; cbp++; }
                else          {  tracebk[tracect] = ' '; }
                tracect++;
              }
              /* puth8(tracect); putch(' ');  puth8(adr); putch(':'); */
            }
		  }
          bctl = 3;
		} else {
	      sl = gets2h(cbpp); if(sl==-1) sl = 1; /* Txx: Trace xxcycl */
		  trcct = sl;	bctl = 2;
		}
        break;
      case 'Q':
	    wrp = (unsigned int *)SYSMODE;
	    if(*cbp=='0') *wrp = *wrp | 0x2000;
		else          *wrp = *wrp & 0xdfff;
	    break;
      default: puts("?\n");
    }

    wrp = (unsigned int *)SYSMODE; wd = *wrp;
    while(bctl!=0){
	  dprreq = 0;
	  if(bctl==2 || bctl==3) *wrp = *wrp | 0x0800;
	  
      if(bctl==1) { exec(lstp); bctl = 0; dprreq = 1; } 
	  
	  if(bctl==2) {
	    if(trcct!=0L) { exec(lstp); trcct--; dprreq = 1; }
		else          { bctl = 0; }
	  }
	  
      if(bctl==3 && tracect!=0){
	      exec(lstp); pc = *(lstp+2);
          for( i=0; i<tracect; i++) {
            if(pc==tracead[i]) {
			  dprreq = 1;
              if(tracebk[i]==' ') bctl = 0;
            }
		  }
      }
	  
      if((*wrp & 0x8000)!=0) bctl = 0;  /* Ctrl+Q request */
      if(dprreq==1) dispregs(lstp, regmd, 0, displen);
    }
	*wrp = wd;  /* Trace.End */
  }
  return 0;

}

