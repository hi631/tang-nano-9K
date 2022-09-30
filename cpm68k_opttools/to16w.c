#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>

FILE *infil;
FILE *outfil;

char n2c(nib) int nib; {
  if(nib<10) return 0x30+nib;
  else       return 0x37+nib;
}
void to16t() {
  unsigned char buf[16];
  unsigned short ch,i,j,k,sum;
  k = 0; sum = 0;
  for(;;){
    j = fread(buf,1,1, infil);
    if(j==0) break;
    ch = buf[0]; sum = sum + (unsigned short)buf[0];
    buf[0] = n2c(ch>>4); buf[1] = n2c(ch & 0x0f); buf[2] = 0;
	fwrite(buf,2,1,outfil); //printf("%c%c", buf[0], buf[1]);
	k++; if((k & 0x1f) == 0) {
	  buf[0] = 0x0d; buf[1] = 0x0a; fwrite(buf,2,1,outfil); //printf("\n");
	}
  }
  printf("len = %d  sum = %X\n", k, sum);
}

unsigned int a2n(dt)
unsigned int dt;
{
  if(dt<='9') return (dt & 0x0f);
  else        return (dt & 0x0f) + 9;
}
void to16f(){
  unsigned char buf[16];
  unsigned short ch,i,j,k,sum,n1,n2;
  k = 0; sum = 0;
  for(;;){
    j = fread(buf,1,2,infil); //buf[2] =0; printf("%s:%d ", buf,j);
    if(j==2) {
	if(buf[0]>=0x20){
      n1 = a2n(buf[0]); n2 = a2n(buf[1]);
	  buf[0] = (n1 << 4) + n2;
	  fwrite(buf,1,1,outfil); /* printf("%c",ch); */
	  k++; sum = sum + (unsigned short)buf[0];
	}
	} else break;
  }
  printf("len = %d  sum = %X\n", k, sum);
}

int main(argc,argv)
int argc;
char *argv[];
{
  char *frmd, *fwmd;
  if (argc != 4) { printf("Usage: to16 -T/F file1 file2"); exit(1); }

  if ((infil = fopen(argv[2],"rb")) == NULL) { printf("Unable to open %s.", argv[2]); exit(1); }
  if ((outfil = fopen(argv[3],"wb")) == NULL) { printf("Unable to create %s.", argv[3]); exit(1); }

  if(*(argv[1]+1)=='t') to16t();
  else                  to16f();

  fclose(outfil);
  fclose(infil);

  return 0;
}
