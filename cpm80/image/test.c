#include <stdio.h>
dump(sa) int sa;{
    char *ma;
    int i,j,dt;
    ma = sa;
    for(j=0;j<8; j++){
        printf("\n%x: ", ma);
        for(i=0; i<16; i++){
            dt = *ma++; if(dt<16) putchar('0');
            printf("%x ", dt);
        }
    }
}
main(){
    int rc;
    BIOS( 9,0); /* Drive */ BIOS(10,0); /* Trck */ BIOS(11,1); /* Sector */
    BIOS(12,0x1000); /* DMA */ rc = BIOS(13);   /* Read */
    printf("\nrc=%d", rc);
    dump(0x1000);
}
