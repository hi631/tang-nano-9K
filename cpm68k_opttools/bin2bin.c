#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

long str2hex(char buf[]){
	long ans, num, cp, eflg, dt;
    ans = 0; cp = 0; eflg = 0;
    while(1){
    	dt = buf[cp++];
        if(dt>='0' && dt<='9') ans = ans * 16 + (dt-0x30);
        else
        if(dt>='A' && dt<='F') ans = ans * 16 + (dt-0x37);
        else break;
    }
    return ans;
}
int main(int argc,char *argv[])
{
	char buf[65536];
	unsigned char c;
	int rmd,bc,bd;
	long adr, dl, hdt, bcnt;
	struct stat st;
	
	stat(argv[1], &st);
	FILE *fpr = fopen(argv[1], "rb");
    if(fpr==NULL) { printf("%s Not>Found\n",argv[1]); exit(1); }
    FILE *fpw = fopen(argv[2], "wb");

	adr = str2hex(argv[3]);	// start addr
    fseek(fpr, adr, SEEK_SET);
	dl = fread( buf,1,65536,fpr);
    printf("%x %x",adr, dl);
	fwrite(buf, dl,1,fpw);

    fclose(fpr); fclose(fpw);
	return 0;
}
