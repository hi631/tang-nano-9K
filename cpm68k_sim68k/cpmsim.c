/*
  MC68000 simulation taylored to support CP/M-68K. It includes:

  16MB of memory. (Flat, function codes and address space types ignored.)

  Console I/O using a MC6850 like serial port with interrupts.

  Simulated disk system:

  I was going to just read a file system image into memory and map it into
  the unusable (in a MC68000) address space above the 16MB physical limit.
  Alas, the simulator is simulating that physical limit and a quick check of
  the code hasn't revealed a simple way to defeat that. So plan B.

  Since the intent is to support CP/M-68K and it does disk I/O in 128 byte
  chunks, so will this. Control is via several registers mapped into memory:

  Offset       function
   0           DMA             address to read/write data to
   4           drive           select disk drive
   8           read sector     sector (128 byte) offset on disk
   12          write sector    sector (128 byte) offset on disk
   16          status          read status of operation

   Operation is simple: set the drive and DMA address and then write the
   sector number to the sector register. This write triggers the requested
   operation. The status of the operation can be determined by reading the
   status register.
   A zero indicates that no error occured.

   Note that these operations invoke read() and write() system calls directly
   so that they will alter the image on the hard disk. KEEP BACKUPS!

   In addition Linux will buffer the writes so they may note be really complete
   for a while. The BIOS flush function invokes a fsync on all open files.

   There are two options for booting CPM:

   S-records: This loads CPM in two parts. The first is in cpm400.bin which
   is created from the srecords in cpm400.sr. The second is in simbios.bin
   which contains the BIOS. Both of these files must be binaries and not
   srecords.
   
   If you want to alter the bios, rebuild simbios.bin using:

   asl simbios.s
   p2bin simbios.p

   This option is requested using "-s" on the command line.

   Boot track: A CPM loader is in the boot track of simulated drive C. 32K of
   data is loaded from that file to memory starting at $400. This is the
   default option.

  Uses the example that came with the Musashi simulator as a skeleton to
  build on.

 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdarg.h>
#include <ctype.h>
#include <time.h>
#include <signal.h>
#define __USE_GNU
#include <unistd.h>
#include <errno.h>
#include "sim.h"
#include "m68k.h"


/* Memory-mapped IO ports */

/* 6850 serial port like thing
   Implements a reduced set of functionallity.
 */
#define MC6850_STAT  0xff1000L     // command/status register
#define MC6850_DATA  0xff1002L     // receive/transmit data register

/* Memory mapped disk system */

#define DISKC_FILENAME "diskc.cpm.fs"
#define DISK_BASE       0xff0000L
#define DISK_SET_DMA   (DISK_BASE)
#define DISK_SET_DRIVE (DISK_BASE+4)
#define DISK_SET_SECTOR (DISK_BASE+8)
#define DISK_READ      (DISK_BASE+12)
#define DISK_WRITE     (DISK_BASE+16)
#define DISK_STATUS    (DISK_BASE+20)
#define DISK_FLUSH     (DISK_BASE+24)

#define SDCD_SETCMD    (DISK_BASE+0x100L)
#define SDCD_SETADR    (DISK_BASE+0x102L) // 4byte
#define SDCD_BUF       (DISK_BASE+0x200L)
#define SDCD_SELECT    0x0000 // 0x0080			// 0000 = not.use

#define RAMDISK                   // create a simulated 16MB RAM disk on M:
#define RAM_DRIVE   ('M'-'A')
#define RAMDISK_SIZE  0x1000000

#define CPM_IMAGE  "cpm400.bin"
#define BDOS_START  0x0000
#define BIOS_START  0x6000
//#define CPM_IMAGE  "cpm15000.bin"
//#define BDOS_START  0x15000
//#define BIOS_START  0x1B000
#define BIOS_IMAGE "simbios.bin"

/* Miscilaneous */

#define S_TIME          (0xff7ff8)  // read long to get time in seconds
#define CPM_EXIT        (0xff7ffc)

/* IRQ connections */
#define IRQ_NMI_DEVICE 7
#define IRQ_MC6850     5


/* ROM and RAM sizes */
#define MAX_ROM 0           // all RAM
#define MAX_RAM 0xffffff    // 16MB of RAM


/* Read/write macros */
#define READ_BYTE(BASE, ADDR) (BASE)[ADDR]
#define READ_WORD(BASE, ADDR) (((BASE)[ADDR]<<8) |	\
			       (BASE)[(ADDR)+1])
#define READ_LONG(BASE, ADDR) (((BASE)[ADDR]<<24) |	\
			       ((BASE)[(ADDR)+1]<<16) |	\
			       ((BASE)[(ADDR)+2]<<8) |	\
			       (BASE)[(ADDR)+3])

#define WRITE_BYTE(BASE, ADDR, VAL) (BASE)[ADDR] = (VAL)&0xff
#define WRITE_WORD(BASE, ADDR, VAL) (BASE)[ADDR] = ((VAL)>>8) & 0xff;	\
  (BASE)[(ADDR)+1] = (VAL)&0xff
#define WRITE_LONG(BASE, ADDR, VAL) (BASE)[ADDR] = ((VAL)>>24) & 0xff;	\
  (BASE)[(ADDR)+1] = ((VAL)>>16)&0xff;					\
  (BASE)[(ADDR)+2] = ((VAL)>>8)&0xff;					\
  (BASE)[(ADDR)+3] = (VAL)&0xff


/* Prototypes */
void exit_error(char* fmt, ...);
int osd_get_char(void);

unsigned int cpu_read_byte(unsigned int address);
unsigned int cpu_read_word(unsigned int address);
unsigned int cpu_read_long(unsigned int address);
void cpu_write_byte(unsigned int address, unsigned int value);
void cpu_write_word(unsigned int address, unsigned int value);
void cpu_write_long(unsigned int address, unsigned int value);
void cpu_pulse_reset(void);
void cpu_set_fc(unsigned int fc);
int cpu_irq_ack(int level);

void nmi_device_reset(void);
void nmi_device_update(void);
int nmi_device_ack(void);

void int_controller_set(unsigned int value);
void int_controller_clear(unsigned int value);

void get_user_input(void);


/* Data */
unsigned int g_quit = 0;			/* 1 if we want to quit */
unsigned int g_nmi  = 0;				/* 1 if nmi pending */
unsigned int g_runf = 0;
struct termios newattr,oldattr;

int g_MC6850_receive_data = -1;		/* Current value in input device */
int g_MC6850_status = 2;                /* MC6850 status register */
int g_MC6850_control = 0;               /* MC6850 control register */

int g_disk_fds[16];
int g_disk_size[16];
int srecord = 0;
int g_trace = 0;

unsigned int g_int_controller_pending = 0;	/* list of pending interrupts */
unsigned int g_int_controller_highest_int = 0;	/* Highest pending interrupt */

unsigned char g_rom[MAX_ROM+1];					/* ROM */
unsigned char g_ram[MAX_RAM+1];					/* RAM */

#ifdef RAMDISK
unsigned char g_ramdisk[RAMDISK_SIZE];
#endif

unsigned int g_fc;       /* Current function code from CPU */


/* OS-dependant code to get a character from the user.
 */

#include <termios.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/time.h>
 
struct termios oldattr;

int sleepct = 0;
int kbhit(void)
{
  struct timeval timeout;
  fd_set rdset;

  FD_ZERO(&rdset);
  FD_SET(STDIN_FILENO, &rdset);
  timeout.tv_sec  = 0;
  timeout.tv_usec = 0;

  int rc = select(STDIN_FILENO + 1, &rdset, NULL, NULL, &timeout);
  if(rc!=0) sleepct = 0;
  else {
    if(sleepct<10000) sleepct++;
    else              usleep(10);
  }
  return rc;
}

void memdump(int start, int end)
{
  int i = 0;
  while(start < end)
    {
      if((i++ & 0x0f) == 0)
	fprintf(stderr, "\r\n%08x:",start);
      fprintf(stderr, "%02x ", g_ram[start++]);
    }
}


void termination_handler(int signum)
{
  int i;

  tcsetattr(STDIN_FILENO, TCSANOW, &oldattr);  // restore terminal settings

  for(i = 0; i < 16; i++)
    {
      if(g_disk_fds[i] != -1)
	{
	  lseek(g_disk_fds[i], 0, 0);
	  lockf(g_disk_fds[i], F_ULOCK, 0);
	  close(g_disk_fds[i]);
	}
    }
  //  fprintf(stderr, "\nFinal PC=%08x\n",m68k_get_reg(NULL, M68K_REG_PC));
  tcsetattr(STDIN_FILENO, TCSANOW, &oldattr);

  exit(0);
}

/* Exit with an error message.  Use printf syntax. */
void exit_error(char* fmt, ...)
{
  va_list args;

  tcsetattr(STDIN_FILENO, TCSANOW, &oldattr);  // restore terminal settings


  va_start(args, fmt);
  vfprintf(stderr, fmt, args);
  va_end(args);
  fprintf(stderr, "\n");

  tcsetattr(STDIN_FILENO, TCSANOW, &oldattr);

  exit(EXIT_FAILURE);
}


/* Implementation for the MC6850 like device

   Only those bits of the control register that enable/disable receive and
   transmit interrupts are implemented.

   In the status register, the Receive Data Register Full, Transmit Data
   Register Empty, and IRQ flags are implemented. Although the transmit
   data register is always empty.
 */

void MC6850_reset(void)
{
  g_MC6850_control = 0;
  g_MC6850_status = 2;
  int_controller_clear(IRQ_MC6850);
}

void input_device_update(void){
  if(kbhit()){
      g_MC6850_status |= 1;
      if((g_MC6850_control & 0x80) && !(g_MC6850_status & 0x80)){
	      int_controller_set(IRQ_MC6850);
	      g_MC6850_status |= 0x80;
	    }
  }
}

int input_device_ack(void)
{
  return M68K_INT_ACK_AUTOVECTOR;
}

char keysave = 0;
unsigned int MC6850_data_read(void)
{
  char ch;

  int_controller_clear(IRQ_MC6850);
  g_MC6850_status &= ~0x81;          // clear data ready and interrupt flag

  if(read(STDIN_FILENO, &ch, 1) == 1)
    { keysave = ch; return ch; }
  else 
    return -1;
}

int MC6850_status_read()
{
  return g_MC6850_status;
}


/* Implementation for the output device */

void output_device_update(void)
{
  
}

int MC6850_device_ack(void)
{
  return M68K_INT_ACK_AUTOVECTOR;
}

void MC6850_data_write(unsigned int value)
{
  char ch;
  int rc;
  ch = value;
  rc = write(STDOUT_FILENO, &ch, 1);
  rc = rc; // Dumy
  //  putc(value, stdout);

  if((g_MC6850_control & 0x60) == 0x20)   // transmit interupt enabled?
    {
      int_controller_clear(IRQ_MC6850);
      int_controller_set(IRQ_MC6850);
    }
}

void MC6850_control_write(unsigned int val)
{
  g_MC6850_control = val;
}

/*
  Disk devices
 */

int g_disk_dma;
int g_disk_drive;
int g_disk_status;
int g_disk_sector;

int g_track;
int g_sector;

void savecpm(){
    int fd,dm;
    fd = g_disk_fds[2];
    if(fd == -1) { printf("Open.Err\n"); return; }
    lseek(fd, 0x1000000L, SEEK_SET);
    dm=write(fd, &g_ram[0xfe0000L], 32768); dm=dm;
    printf("Write fe0000-fe7fff to 1000000\n");
}

void dumpmem(int adr, int dl){
	printf("\n\r");
    for(int nl=0; nl<dl/16; nl++){
      printf("%06x: ", adr);
      for( int nb=0; nb<16; nb++){ printf("%02x ", g_ram[adr+nb]); }
      for( int nb=0; nb<16; nb++){
        int ch = g_ram[adr+nb]; if(ch<0x20 || ch>0x7f) ch = '.';
        printf("%c", ch);
      }
      printf("\n\r"); adr = adr + 16;
    }
}

int dumpf = 0;
unsigned int sdcd_sector = 0;
void sdcd_rw512(unsigned int cmd, unsigned int sector){
  int i, fd;
  char mode;

  mode=' ';
  if((cmd & 1)!=0) mode = 'R';
  if((cmd & 2)!=0) mode = 'W';

  WRITE_WORD(g_ram, SDCD_SETCMD, SDCD_SELECT+1);
  g_disk_status = -1;
  fd = g_disk_fds[g_disk_drive];
  if(fd == -1) {fprintf(stderr,"fd.err"); cmd = 0; }
  //if(fd == -1 || sector*512 > g_disk_size[g_disk_drive]) {fprintf(stderr,"size.err"); cmd = 0; }
  if(lseek(fd, sector * 512, SEEK_SET) != sector * 512)  {fprintf(stderr,"seek.err"); cmd = 0; }
  if((cmd & 1)!=0){ // read
    i = read(fd, &g_ram[SDCD_BUF], 512);
  } else
  if((cmd & 2)!=0){ // write
    i = write(fd, &g_ram[SDCD_BUF], 512);
  }
  if(i == 512) g_disk_status = 0;
  else fprintf(stderr,"%c.Err %d %x", mode,i,sector);
  WRITE_WORD(g_ram, SDCD_SETCMD, SDCD_SELECT+0);
  
  if(sector>=0x888000) {
    int sofs;
    sofs = 0x80 * (g_disk_sector & 3);
    fprintf(stderr,"\r\n[%c D:%x S:%x S:%x %x]", mode,g_disk_drive,sector,g_disk_sector, sofs);
    dumpmem(SDCD_BUF+sofs,128);
  }
}

void disk_read(int sector)
{
  int i, fd;

    //fprintf(stderr,"r%x:",g_disk_sector);
    //fprintf(stderr,"\n\r[Read  %d:%x %x %x]", g_disk_drive,sector,sector*128,g_disk_dma);
 
  g_disk_status = -1;

#ifdef RAMDISK
  if(g_disk_drive == RAM_DRIVE)
    {
      if(sector > (sizeof(g_ramdisk)/128 - 128))
	return;
      g_disk_status = 0;
      for(i = 0; i < 128; i++)
	WRITE_BYTE(g_ram, g_disk_dma+i, g_ramdisk[sector*128 + i]);
      return;
    }
#endif

  fd = g_disk_fds[g_disk_drive];

  if(fd == -1)                   // verify file is opened
    return;

   // seek to set sector
  if(lseek(fd, sector * 128, SEEK_SET) != sector *128)
    return;

  i = read(fd, &g_ram[g_disk_dma], 128); // read the data

  if(i == 128)
    g_disk_status = 0;

    //if(g_disk_sector==0x600){
    //  fprintf(stderr,"\n\r[Read %d:%x %x %x]", g_disk_drive,sector,sector*128,g_disk_dma);
    //  dumpmem(g_disk_dma,0x80);
    //}
    //fprintf(stderr,"\n\r[Read %d:%x %x]", g_disk_drive,sector*128,g_disk_dma);
    //for(int i=0; i<16; i++) { fprintf(stderr," %02x", g_ram[g_disk_dma+i]);}



  if(g_trace)
    {
      if(sector == 7536)
	memdump(0x500,0x600);
      fprintf(stderr, "\r\n%08x:%dR\r\n", g_disk_dma, sector);
    }

}
/*
  While refreshing my memory of the write() system call I noticed that it
  mentioned that an interrupt could prevent a write from completing and that
  errno should be checked for the value EINTR to see if a retry is in order.
  Or to use the macro TEMP_FAILURE_RETRY. Which isn't provided by all UNIX
  like systems. This substitute was suggested on comp.os.cpm:
 */
#ifdef __FreeBSD__
#define TEMP_FAILURE_RETRY(expr) \
     ({ long int _res; \
         do _res = (long int) (expr); \
         while (_res == -1L && errno == EINTR); \
         _res; })
#endif 

void disk_write(int sector)
{
  int i, fd, count;

    //fprintf(stderr,"w%x:",g_disk_sector);
    //fprintf(stderr,"\n\r[Write %d:%x %x %x]", g_disk_drive,sector,sector*128,g_disk_dma);

  fd = g_disk_fds[g_disk_drive];
  g_disk_status = -1;

#ifdef RAMDISK
  if(g_disk_drive == RAM_DRIVE)
    {
      if(sector > (sizeof(g_ramdisk)/128 - 128))
	return;
      g_disk_status = 0;
      for(i = 0; i < 128; i++)
	g_ramdisk[sector*128 + i] = READ_BYTE(g_ram, g_disk_dma+i);

      return;
    }
#endif

  if(fd == -1 || sector*128 > g_disk_size[g_disk_drive])
    return;

  if(lseek(fd, sector * 128, SEEK_SET) != sector*128)   // seek to set sector
    return;

  count = 128;
  do {
    i = TEMP_FAILURE_RETRY(write(g_disk_fds[g_disk_drive],
				 &g_ram[g_disk_dma+128-count], count)); 
    if(i == -1)
      return;
    count -= i;
  } while(count > 0);

  if(dumpf==1){
    fprintf(stderr,"\n\r[Write %d:%x %x]\n\r", g_disk_drive,sector*128,g_disk_dma);
    dumpmem(g_disk_dma,0x80);
  }
  g_disk_status = 0;
}

void disk_flush(void)
{
  int i;

  for(i = 0; i < 16; i++)
    if(g_disk_fds[i] != -1)
      fsync(g_disk_fds[i]);
}

/*
  Open a file for use as a CP/M file system. Must specify the drive number,
  filename, and mode.
 */
void open_disk(int fn, char *fname, mode_t flags)
{
  if((g_disk_fds[fn] = open(fname, flags)) == -1)
    {
      fprintf(stderr, "Disk image %s doesn't exist! \n", fname);
      g_disk_size[fn] = 0;
      return;
    }
  lseek(g_disk_fds[fn], 0, 0);         // make sure at start of file
  if(lockf(g_disk_fds[fn], F_TLOCK, 0) == -1)
    {
      close(g_disk_fds[fn]);
      fprintf(stderr, "File %s locked\nOpening read only.\n", fname);
      g_disk_fds[fn] = open(fname, O_RDONLY);
    }
  g_disk_size[fn] = lseek(g_disk_fds[fn], 0, SEEK_END);
}

void init_disks(void)
{
  int i;

  for(i = 0; i < 16; i++)
    g_disk_fds[i] = -1;
  WRITE_WORD(g_ram, SDCD_SETCMD, SDCD_SELECT+0);
}

int ost;
/* Read data from RAM */
unsigned int cpu_read_byte(unsigned int address)
{
  int rc;
  switch(address)
    {
    case MC6850_DATA:
      rc = MC6850_data_read();
      //printf("  [D%x]", rc);
      return rc;
    case MC6850_STAT:
      rc = MC6850_status_read();
      //if(rc!=ost) {printf("  [S%x]", rc); ost=rc; }
      return rc;
    default:
      break;
    }

  return READ_BYTE(g_ram, address);
}

unsigned int cpu_read_word(unsigned int address)
{
  switch(address)
    {
    case DISK_STATUS:
      if(g_disk_status!=0) fprintf(stderr,"[%x]",g_disk_status);
      return g_disk_status;
    default:
      break;
    }

  return READ_WORD(g_ram, address);
}

unsigned int cpu_read_long(unsigned int address)
{
  switch(address)
    {
    case DISK_STATUS:
      if(g_disk_status!=0) fprintf(stderr,"[%x]",g_disk_status);
      return g_disk_status;
    case S_TIME:
      return time(NULL);
    default:
      break;
    }
  return READ_LONG(g_ram, address);
}


/* Write data to RAM or a device */
void cpu_write_byte(unsigned int address, unsigned int value)
{
  switch(address)
    {
    case MC6850_DATA:
      MC6850_data_write(value&0xff);
      return;
    case MC6850_STAT:
      MC6850_control_write(value&0xff);
      return;
    default:
      break;
    }

 WRITE_BYTE(g_ram, address, value);
}

void cpu_write_word(unsigned int address, unsigned int value)
{
  switch(address){
    case SDCD_SETCMD:
      sdcd_rw512(value,sdcd_sector);
      return;
    case SDCD_SETADR:
      sdcd_sector = (sdcd_sector & 0xffff) | (value << 16); return;
    case SDCD_SETADR+2:
      sdcd_sector = (sdcd_sector & 0xffff0000) | value;     return;
    default:
      break;
    }
  WRITE_WORD(g_ram, address, value);
}

void cpu_write_long(unsigned int address, unsigned int value)
{
  switch(address){
    case DISK_SET_DRIVE:
      g_disk_drive = value;
      return;
    case DISK_SET_DMA:
      g_disk_dma = value;
      return;
    case DISK_SET_SECTOR:
      g_disk_sector = value;
      return;
    case DISK_READ:
      disk_read(value);
      return;
    case DISK_WRITE:
      disk_write(value);
      if(g_disk_status == -1)
	    fprintf(stderr, "\r\nwrite error: drive:%c  sector: %d\r\n",
	    g_disk_drive+'A', g_disk_sector);
      return;
    case DISK_FLUSH:
      disk_flush();
      return;
    case CPM_EXIT:
      fprintf(stderr, "CP/M-68K terminating normally\r\n");
      termination_handler(0);
      return;
    case SDCD_SETADR:
      sdcd_sector = value; return;
    default:
      break;
    }

  WRITE_LONG(g_ram, address, value);
}

/* Called when the CPU pulses the RESET line */
void cpu_pulse_reset(void)
{
  nmi_device_reset();
  MC6850_reset();
}

/* Called when the CPU changes the function code pins */
void cpu_set_fc(unsigned int fc)
{
  g_fc = fc;
}

/* Called when the CPU acknowledges an interrupt */
int cpu_irq_ack(int level)
{
  switch(level)
    {
    case IRQ_NMI_DEVICE:
      return nmi_device_ack();
    case IRQ_MC6850:
      return MC6850_device_ack();
    }
  return M68K_INT_ACK_SPURIOUS;
}




/* Implementation for the NMI device */
void nmi_device_reset(void)
{
  g_nmi = 0;
}

void nmi_device_update(void)
{
  if(g_nmi)
    {
      g_nmi = 0;
      int_controller_set(IRQ_NMI_DEVICE);
    }
}

int nmi_device_ack(void)
{
  printf("\nNMI\n");fflush(stdout);
  int_controller_clear(IRQ_NMI_DEVICE);
  return M68K_INT_ACK_AUTOVECTOR;
}



/* Implementation for the interrupt controller */
void int_controller_set(unsigned int value)
{
  unsigned int old_pending = g_int_controller_pending;

  g_int_controller_pending |= (1<<value);

  if(old_pending != g_int_controller_pending && value > g_int_controller_highest_int)
    {
      g_int_controller_highest_int = value;
      m68k_set_irq(g_int_controller_highest_int);
    }
}

void int_controller_clear(unsigned int value)
{
  g_int_controller_pending &= ~(1<<value);

  for(g_int_controller_highest_int = 7;g_int_controller_highest_int > 0;g_int_controller_highest_int--)
    if(g_int_controller_pending & (1<<g_int_controller_highest_int))
      break;

  m68k_set_irq(g_int_controller_highest_int);
}

unsigned int m68k_read_disassembler_16(unsigned int address)
{
  return cpu_read_word(address);
}

unsigned int m68k_read_disassembler_32(unsigned int address)
{
  return cpu_read_long(address);
}
    
/*
  Print some information on the instruction and state.
 */
int dispregs = 0xc0008307;
void trace_disp(){
  char buf[256], bbf[16], wbf[256];
  int pc, rc,i,j;

  int dpl = 0;
  wbf[0] = 0;
  pc = m68k_get_reg(NULL, M68K_REG_PC);
  if(dispregs & 0x80000000) { fprintf(stderr, "PC:%06x ", pc); dpl = dpl + 10; }

  if(dispregs & 0x40000000) { 
    rc = m68k_disassemble(buf, pc, M68K_CPU_TYPE_68000);
    strcat(buf, "                                "); buf[28] = 0; dpl = dpl + 28;
	fprintf(stderr, "%s", buf);

    if(dispregs & 0x20000000) { 
	  buf[0] = 0;
      for(i=0; i<8; i++)
        if(i<rc){ sprintf(bbf, "%02x", g_ram[pc+i]);  strcat(buf,bbf); }
        else      strcat(buf,"..");
      fprintf(stderr, "%s ", buf); dpl = dpl + 17;
    }
  }
  if(dispregs & 0x08000000) { fprintf(stderr, " SS:%08x", m68k_get_reg(NULL, M68K_REG_SP)); dpl = dpl + 12; }
  if(dispregs & 0x04000000) { fprintf(stderr, " US:%08x", m68k_get_reg(NULL, M68K_REG_USP)); dpl = dpl + 12; }
  if(dispregs & 0x02000000) { fprintf(stderr, " SR:%04x", m68k_get_reg(NULL, M68K_REG_SR)); dpl = dpl + 8; }
  if(dispregs & 0x01000000) { fprintf(stderr,"\r\n"); dpl = 0; }

  int rbase, regpt;
  char rnam;
  regpt=0x01;
  for( j=0; j<2; j++) {
    if(j==0){ rbase = M68K_REG_D0; rnam = 'D'; }
    if(j==1){ rbase = M68K_REG_A0; rnam = 'A'; }
    for( i=0; i<8; i++) {
	  if((dispregs & regpt)!=(int)0) {
	    sprintf(buf, "%c%d:%08x ", rnam, i, m68k_get_reg(NULL, rbase+i));
	    strcat(wbf, buf); dpl = dpl + 12;
	  }
	  if(dpl>=108) { fprintf(stderr," %s\r\n",wbf); wbf[0] = 0; dpl = 0; }
	  regpt = regpt << 1; 
	}
  }

  if(dpl!=0) fprintf(stderr," %s\r\n",wbf);
  
  /* Output Traceout.txt
    int fd;
    char *bname = "traceout.txt";
    if((fd = open( bname, O_WRONLY | O_APPEND)) == -1) exit_error("Unable to open %s", bname);
    rc = write(fd,wbf,strlen(wbf));
    close(fd);
  */
}

//Load binary files including cpm400.bin produced from the s-records in cpm400.sr.
void load_srecords(void){
  int i, fd;
/*
  if((fd = open(BIOS_IMAGE, O_RDONLY)) == -1) exit_error("Unable to open %s", BIOS_IMAGE);
  if(read(fd, g_ram, 8) == -1) exit_error("Error reading %s", BIOS_IMAGE);
  lseek(fd, BIOS_START, SEEK_SET);         // skip to BIOS at 0x6000/15000
  if((i = read(fd, &g_ram[BIOS_START], 32768)) == -1) exit_error("Error reading %s", BIOS_IMAGE);
  fprintf(stderr, "Read %6d bytes of CP/M-68K BIOS image. %x\n", i, BIOS_START);
  close(fd);

  if((fd = open(CPM_IMAGE, O_RDONLY)) == -1) exit_error("Unable to open %s", CPM_IMAGE);
  if((i = read(fd, &g_ram[BDOS_START], 32768)) == -1) exit_error("Error reading %s", CPM_IMAGE);
  fprintf(stderr, "Read %6d bytes of CP/M-68K BDOS image. %x\n", i, BDOS_START);
  close(fd);
*/
  if((fd = open("cpm.sys", O_RDONLY)) == -1) exit_error("Unable to open cpm.sys");
  lseek(fd, 28, SEEK_SET); // Header skip
  if((i = read(fd, &g_ram[0xfe0000L], 32768)) == -1) exit_error("Error reading %s", CPM_IMAGE);
  fprintf(stderr, "\n\rRead %6d bytes of CP/M-68K BDOS image. FE0000", i);
  close(fd);
/*
  if((fd = open("simbios.bin", O_RDONLY)) == -1) exit_error("Unable to open simbios.bin");
  if((i = read(fd, &g_ram[0xfe5000L], 8192)) == -1) exit_error("Error reading simbios.bin");
  fprintf(stderr, "\n\rRead %6d bytes of CP/M-68K BIOS image. FE5000", i);
  close(fd);
*/
  WRITE_LONG(g_ram, 0, 0xfe0000);	// SP
  WRITE_LONG(g_ram, 4, 0x000400);    // PC

}

void load_boot_track(void){
  int i;
  if(g_disk_fds[2] == 0) { fprintf(stderr, "No boot drive available!\n"); exit(1); }
  lseek(g_disk_fds[2], 0, SEEK_SET);
  i =read(g_disk_fds[2], &g_ram[0x400], 32*1024);
  fprintf(stderr, "Read %d bytes from boot track\n", i);
  // Now put in values for the stack and PC vectors
  WRITE_LONG(g_ram, 0, 0xfe0000);   // SP
  WRITE_LONG(g_ram, 4, 0x400);      // PC
}

void load_debug(char *bname){
  int fd;
  int rc;
  if((fd = open( bname, O_RDONLY)) == -1) exit_error("Unable to open %s", bname);
  rc = read(fd, g_ram, MAX_RAM+1); rc = rc; // Dumy
  close(fd);
}
void getstr(char buf[]) {
  char ch = 0; int ct = 0;
  while(ch!=0x0d) { 
    ch = getchar();
    if(ch>='a' && ch<'z') ch = ch - 0x20;
    if(ch==0x7f) {if(ct!=0) {putchar(0x08);putchar(0x20);putchar(0x08); ct--; } }
    else   { putchar(ch); buf[ct++] = ch; }
  }
  printf("\n");
}

int getdec(char *buf){
  int num,ch;
  while(*buf==' ') buf++; // sp
  num = 0;
  while(1){
    ch = *buf++;
    if(ch>='0' && ch<='9') num = num * 10 + ch - 0x30;
    else return num;
  }
}

void puth(dt) int dt;{ if(dt<10) putchar(0x30+dt); else putchar(0x37+dt); }
void puth2(dt) int dt;{ puth((dt >> 4) & 0xf); puth(dt & 0xf); }
void puth4(dt) int dt;{ puth2((dt >> 8) & 0xff); puth2(dt & 0xff); }
void puth6(dt) long dt;{ int dh,dl; dh = dt >> 16; dl = dt & 0xffff; puth2(dh); puth4(dl); }
void puth8(dt) long dt;{ int dh,dl; dh = dt >> 16; dl = dt & 0xffff; puth4(dh); puth4(dl); }

int gethex(char *buf){
  int num,ch;
  while(*buf==' ') buf++; // sp
  num = 0;
  while(1){
    ch = *buf++;
    if(ch>='0' && ch<='9') num = num * 16 + ch - 0x30;
    else if(ch>='A' && ch<='F') num = num * 16 + ch - 0x37;
    else if(ch>='a' && ch<='f') num = num * 16 + ch - 0x57;
    else return num;
  }
}

int ishex(ch) char ch;{
  int hd;
  if(ch>='0' && ch<='9') hd = ch - 0x30;
  else if(ch>='A' && ch<='F') hd = ch - 0x37;
  else if(ch>='a' && ch<='f') hd = ch - 0x57;
  else hd = -1;
  return hd;
}
long gets2h(buf) char **buf;{
  long num = 0; int hd;
  while(**buf==' ') (*buf)++; /* spip sp*/
  if(**buf==0x0d) return -1;
  while( (hd=ishex(**buf)) != -1){ num = num * 16 + hd; (*buf)++; }
  return num;
}

int keybreak(){
  int kb = kbhit();
  if(kb==1) {
    kb = getchar(); 
    if(kb==0x1b) return 1;
    else         return 0;
  }else return 0;
}

int geth1b(){ 
  int dt;
  dt = ishex(getchar()) * 16 + ishex(getchar());
  puth2(dt);
  return dt;
}
unsigned int geth2b(){ return geth1b() * 256 + geth1b(); }

void loadhex(){
  int i,ll;
  unsigned char dt, mf;
  long adr;
  int eof = 0;
  while(eof==0){
    while(getchar()!=':') ;
    ll = geth1b(); adr = geth2b(); mf = geth1b();
    /*adr = 0xfe0000 + adr;*/
    if(mf==0x01) {dt = geth1b(); eof = 1;}
    else
      for(i=0; i<ll; i++){ dt = geth1b(); g_ram[adr++] = dt; }
    puts("\r\n");
  }
  getchar();
  puts("\r\n");
}

int breakmode = 1;
int  tracect = 0;
int  tracead[16];
char tracebk[16];
char tracemd, dumytm;
void running(){
  int bwct = 0;
  int i, pc, opc, cpc;
  g_runf = 1; opc = m68k_get_reg(NULL, M68K_REG_PC);
  while(g_runf==1){
    m68k_execute(1);
    pc = m68k_get_reg(NULL, M68K_REG_PC);
	if(tracect!=0 && breakmode==1){
	  if(tracemd==',') cpc = pc; else cpc = opc;
	  for( i=0; i<tracect; i++)
	    if(cpc==tracead[i]) {
		  if(tracebk[i]==' ') g_runf = 0;   // Stop.Run
		  else                trace_disp(); // Trace Disp.Regs
		}
	}
	opc = pc;
    //unsigned int *wp = (unsigned int *)&g_ram[pc]; 
	//if(*wp==0x724e0460) g_runf = 0;             // Break,Set At Target.Program
    // asm(" dc.w $6004,$4e72,$0000,$4e71");    /* bra *+4; stop; nop;nop; */
    if(bwct++==1000) {
      bwct = 0; 
      if(keysave==0x11 && breakmode==1) { g_runf = 0; keysave = 0;} // Ctrl + Q
      output_device_update(); input_device_update(); nmi_device_update();
    }
  }
  fprintf(stderr,"\n\r");
  trace_disp();
}

//***************************************
// The main loop
//***************************************
int main(int argc, char* argv[]){
  int c;
  init_disks();

  while((c = getopt(argc, argv, "sta:b:")) != -1) {
      switch(c)	{
	      case 'a': open_disk(0, optarg, O_RDWR); break;
	      case 'b': open_disk(1, optarg, O_RDWR); break;
	      case 's': srecord = 1; break;
	      case 't': g_trace = 1; break;
	      case '?':
	        if(optopt == 'a' || optopt == 'b') fprintf(stderr, "Option -%c requires an argument.\n", optopt);
	        else if (isprint (optopt)) fprintf (stderr, "Unknown option `-%c'.\n", optopt);
	        else fprintf (stderr, "Unknown option character `\\x%x'.\n", optopt);
	      default: exit(1);
	}
    }
  open_disk(2, DISKC_FILENAME, O_RDWR);
  if(optind != argc) exit_error("Usage: cpmsim -a diskimage -s");
  g_disk_fds[0] = g_disk_fds[2]; g_disk_fds[1] = g_disk_fds[2]; // Dumy.File

  if(srecord) load_srecords();
  else        load_boot_track();

  //  Install a handler for various termination events so that we have the
  //  opportunity to write the simulated file systems back. Plus clean up
  //  anything else required.
  //if (signal (SIGINT, termination_handler) == SIG_IGN)  signal (SIGINT, SIG_IGN);
  //if (signal (SIGHUP, termination_handler) == SIG_IGN)  signal (SIGHUP, SIG_IGN);
  //if (signal (SIGTERM, termination_handler) == SIG_IGN) signal (SIGTERM, SIG_IGN);

  /*
    Set the terminal to raw mode (no echo and not cooked) so that it looks
    like a dumb serial port.
   */
  tcgetattr(STDIN_FILENO, &oldattr); newattr = oldattr; cfmakeraw(&newattr);

  if(g_trace) newattr.c_lflag |= ISIG;    // uncomment to process ^C

  tcgetattr(STDIN_FILENO,&oldattr);
  newattr.c_cc[VMIN] = 1;       // block until at least one char available
  newattr.c_cc[VTIME] = 0;
  tcsetattr(STDIN_FILENO, TCSANOW, &newattr);

  m68k_pulse_reset(); MC6850_reset(); nmi_device_reset();

  int adr,ade,pc,adro,dt,dtr,wk;
  char cbuf[128],obuf[128],buf[256];
  int rnum,cmdx,rno,mmd;
  unsigned short *wrp;
  char cmd, *cbp, **cbpp;

  printf("\n\r* CPM68KSim                   *\n\r* Ctrl+Q to return to monitor *\n");
  running();
  cmdx = 0; cbpp = &cbp; rnum = 0;adro = 0;
  while(cmdx==0){
    printf("\r>"); strcpy(obuf,cbuf); 
    getstr(cbuf); 
    if(cbuf[0]==0x0d) { cbuf[0] = obuf[0]; cbuf[1] = 0x0d;}
    cmd = cbuf[0]; cbp = &cbuf[1];
    switch(cmd){
      case 'M':
        mmd = 1;
        if(*cbp=='W'){ mmd = 2; cbp++; }
        if(*cbp=='C') { g_ram[1] = 0xfc; cmd = '.'; }
        if(*cbp=='E') { g_ram[1] = 0xfe; cmd = '.'; }
        adr = gets2h(cbpp);
        while(cmd!='.'){
          puth6(adr); putchar(':');
          putchar(' '); puth2(g_ram[adr]); if(mmd==2) puth2(g_ram[adr+1]);
          putchar(' '); 
          getstr(cbuf); cbp = &cbuf[0];
          dt = gets2h(cbpp); dtr = 0; cmd = *cbp;
          if(cmd==0x0d && dt>=0){
            if(mmd==1){
              if(dt>=0) {
                g_ram[adr] = dt; dtr = g_ram[adr]; 
              } 
            } else {
              wrp = (unsigned short *)&g_ram[adr];
              if(dt>=0) {
                dt = (dt >>8) | ((dt & 0xff)<<8); // swap
                *wrp = dt; dtr = *wrp;
              }
            }
          }
		  if(dt==dtr) {
            if(cmd=='-') adr = adr - mmd;
            else         adr = adr + mmd;
		  }
        }
        break;
      case 'D' : 
        adr = gets2h(cbpp);
        if(adr==-1) adr = adro;
        dumpmem(adr,0x80);
        adro = adr;
        break;
      case 'Q' :
	    rnum = gets2h(cbpp);
	    if(rnum==-1) cmdx =1;
		else         breakmode = rnum;
		break;
      case 'A' :
	    if(cbuf[1]==',') pc = m68k_get_reg(NULL, M68K_REG_PC);
        else             pc = gets2h(cbpp);
		rnum = gets2h(cbpp); if(rnum<1) rnum = 0x10;
        for(int nl=0; nl<rnum; nl++){
          int rc = m68k_disassemble(buf, pc, M68K_CPU_TYPE_68000);
		  strcat(buf, "                                "); buf[28] = 0;
		  fprintf(stderr,"%06x %s\r\n", pc, buf);
          pc = pc + rc;
        }
        
        break;
      case 'L':
        puts("Load(Intel Hex)\r\n");
        loadhex();
        break;
      case 'G' :
      case 'T' :
	    if(cbuf[1]==',' || cbuf[1]=='.') {  // G/T,adr0 adr1 adr2 ... <- Trace adr0,1,2
		  tracemd = cbuf[1];                // G/T,adr0,adr1 adr2 ... <- break.adr0 Trace adr1,2
          if(cbuf[2]!=0x0d){
            cbp++; tracect = 0; adr = 0;
            while(adr!=-1){
              adr = gets2h(cbpp);
              if(adr!=-1) { 
                tracead[tracect] = adr; 
                if(*cbp==',') { tracebk[tracect] = ','; cbp++; }
                else            tracebk[tracect] = ' ';
                tracect++;
			  }
            }
		  }
		  if(cmd=='G') running();
        } else {                    // G : Go xxxx
          rnum = getdec(&cbuf[1]);
		  if(cmd=='G'){
            if(rnum!=0) m68k_set_reg(M68K_REG_PC, rnum);
            running();
		  } else {                  // Txx : Trace xx.step
            if(rnum==0) rnum = 1;
            for(int tct=0; tct<rnum; tct++){
              m68k_execute(1);
              output_device_update(); input_device_update(); nmi_device_update();
              trace_disp();
            }
		  }
		}
		break;
      case 'R':
        switch(cbuf[1]){
          case 'P': rnum = gethex(&cbuf[2]); m68k_set_reg(M68K_REG_PC, rnum); break;
          case 'D': rno = cbuf[2] & 15; rnum = gethex(&cbuf[3]); m68k_set_reg(M68K_REG_D0+rno, rnum); break;
          case 'A': rno = cbuf[2] & 15; rnum = gethex(&cbuf[3]); m68k_set_reg(M68K_REG_A0+rno, rnum); break;
          case 'R': m68k_pulse_reset(); MC6850_reset(); nmi_device_reset(); printf("CPU_Reset\n\r"); break;
          case 'M': dispregs = gethex(&cbuf[2]); break;
          default :
		    rnum = dispregs; dispregs = 0x8100ffff;   // disp pc/d0-d7/a0-a7
            trace_disp();  dispregs = rnum;
            break;
        }
        break;
      case 'F':
        adr = gets2h(cbpp); cbp++; ade = gets2h(cbpp); cbp++; dt  = gets2h(cbpp);
        for(wk=adr; wk<ade; wk++) g_ram[wk] = dt;
        break;
      default:
        printf("??\n");
        break;
    }
  }
  tcsetattr(STDIN_FILENO, TCSANOW, &oldattr);
  printf("\n"); 
  return 0;
}
