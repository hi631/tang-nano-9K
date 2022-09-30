#define ACIAS   0xff1000
#define ACIAD   0xff1002

int infil,outfil;

putch(ch) char ch; {
  char *bp;
  bp = ACIAS;
  while((*bp & 2)==0) ;
  bp = ACIAD; *bp = ch;
}

int kbhit(){
  char *bp;
  bp = ACIAS;
  return (*bp & 1);
}
int getch(){
  char *bp;
  bp = ACIAS;
  while((*bp & 1)==0) ;
  bp = ACIAD; return *bp;
}
char n2c(nib) int nib; {
  if(nib<10) return 0x30+nib;
  else       return 0x37+nib;
}
to16t() {
  char buf[16];
  long k;
  unsigned int ch,i,j,sum;
  k = 0;
  for(;;){
    j = read(infil,buf,1);
    if(j==0) break;
    ch = buf[0]; sum = sum + ch;
    buf[0] = n2c(ch>>4); buf[1] = n2c(ch & 0x0f); buf[2] = 0;
	write(outfil,&buf,2); /* printf("%c%c", buf[0], buf[1]); */
	k++; if((k & 0x1f) == 0) {
	  buf[0] = 0x0d; buf[1] = 0x0a; 
	  write(outfil,&buf,2); /* printf("\n"); */
	}
  }
  printf("len = %ld  sum = %x\n", k, sum);
}

int read1(ch)
char *ch;
{
  int j;
  *ch = 0; j = 1;
  while(*ch<0x30 && j==1) j = read(infil, ch,1);
  return j;
}
int a2n(dt)
int dt;
{
  if(dt<='9') return (dt & 0x0f);
  else        return (dt & 0x0f) + 9;
}
to16f(){
  char buf[16];
  unsigned int ch,i,j,sum,n1,n2;
  long k;
  k = 0; sum = 0;
  for(;;){
    /* j = read(infil,buf,2); */

	j = read1(&buf[0]); if(j==0) break;
	j = read1(&buf[1]); if(j==0) break;
	/* buf[2] =0; printf("%s", buf); */
    n1 = a2n(buf[0]); n2 = a2n(buf[1]);
	ch = (n1 << 4) + n2;
	buf[0] = ch;
	write(outfil,&buf,1); /* printf("%c",ch); */
    k++; sum = sum + ch;
  }
  printf("len = %ld  sum = %x\n", k, sum);
}

char buf[0x100000];
to16i(){
  long bfp,i;
  char ch;
  bfp = 0;
  printf("press Ctrl+Z after pasting the source\n");
  while(1){
    ch = getch();
    putch(ch);
    buf[bfp++] = ch;
    if(ch==0x1a) break;
  }
  printf("\n\nlen = %ld\n", bfp);
  buf[bfp++] = 0x0a;
  
  for(i=0; i<bfp; i++){
    ch = buf[i];
    write(outfil,&ch,1);
	if(ch==0x0d){ ch = 0x0a; write(outfil,&ch,1); }
  }

}

int main(argc,argv)
int argc;
char *argv[];
{
  char md;
  if (argc != 4) 
    { printf("Usage: to16 -t/f/i file1/CON: file2"); exit(1); }
  md = *(argv[1]+1);
  if(md!='i')
    if ((infil = openb(argv[2],0)) == -1) 
      { printf("Unable to open %s.", argv[2]); exit(1); }
  if ((outfil = creatb(argv[3],1)) == -1) 
    { printf("Unable to create %s.", argv[3]); exit(1); }

  if     (md=='t') to16t();
  else if(md=='f') to16f();
  else if(md=='i') to16i();
  
  close(outfil);
  close(infil);

  return 0;
}
