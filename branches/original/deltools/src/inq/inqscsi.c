#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/gs.h>
#include <sys/buf.h>
#include <fcntl.h>
#include <errno.h>

extern char *sys_errlist[];

#define BUFSIZE			1024
#define SENSESIZE		18
#define	TEST_UNIT_READY		0x0
#define	INQUIRY			0x12
#define	REQEST_SENSE		0x03

int	fildes;
struct gsioc gsbuf;

int	SendCommand()
{
    memset(gsbuf.dataaddr, (char) 0, gsbuf.datasize);
    if (ioctl(fildes, GS_CMD, &gsbuf))
	return(-1);
    
    if (gsbuf.retsensesize)
	memset(gsbuf.senseaddr, (char) 0, gsbuf.sensesize);
    
    memset(gsbuf.cmdaddr, (char) 0, gsbuf.cmdsize);
    
    return(gsbuf.reterror);
}


int	main(argc, argv)
int	argc;
char	*argv[];
{
    int	c, s, u, d, dev, i;
    int	verbose = 0;
    int	debug	= 0;
    int status = 0;
    char	vendor_id[9];
    char	product_id[17];
    char	rev_level[5];
    
    while ((c = getopt(argc, argv, "vx")) != EOF) {
	switch (c) {
	case 'v':
	    verbose++;
	    break;
	case 'x':
	    debug++;
	    break;
	default:
	    printf("Usage: %s [-v][-x]\n", argv[0]);
	    return(2);
	}
    }
    
    gsbuf.dataaddr = (unsigned char *) malloc(BUFSIZE);
    gsbuf.senseaddr = (unsigned char *) malloc(SENSESIZE);
    gsbuf.cmdaddr = (unsigned char *) malloc(BUFSIZE);
    gsbuf.datasize = BUFSIZE;
    gsbuf.sensesize = SENSESIZE;
    gsbuf.cmdsize = BUFSIZE;
    
    /*
     * Open the SCSI connection and make sure that
     * there is a SCSI to talk to.
     */
    if ((fildes = open("/dev/gs/scsi", O_RDWR)) < 0) {
	printf("Error: cannot open /dev/gs/scsi device.\n");
	perror("open");
	exit(-1);
    }
    
    for (c = 0; c < GS_NCHAN; ++c) {
	for (s = 0; s < GS_NSCSI; ++s) {
	    for (u = 0; u < GS_NLUN; ++u) {
		
		dev = (s << 3) | u;
		
		if (c < 4)
		    dev |= (24 << 8) | (c << 6);
		else if (c < 8)
		    dev |= (30 << 8) | ((c-4) << 6);
		else
		    dev |= (31 << 8) | ((c-8) << 6);
		
		if (debug)
		    printf("Checking channel %d, SCSI ID %d, LUN %d\n", c, s, u);
		
		if (ioctl(fildes, GS_CONN, &dev)) {
		    if (debug || errno != ENXIO && errno != ENODEV)
			printf("Connect ioctl failure on Channel %d, SCSI ID %d, LUN %d.  Error: %s\n", c, s, u, sys_errlist[errno]);
		    continue;
		}
		
		/* Do an Inquiry */
		gsbuf.dir = B_READ;
		gsbuf.cmdsize = 6;
		gsbuf.cmdaddr[0] = INQUIRY;
		gsbuf.cmdaddr[4] = 98;
		status=SendCommand();
	        if (status == 4){
	    	    printf("Device on %d.%d.%d.is busy\n", c, s, u);
	    	    continue;
	        }
		else if (status == 1) {
		    continue;
		}
		else if (status){
		    printf("Inquiry Error for channel %d. scsi %d. unit %d.: error= \n", c, s, u, status);
		    continue;
		}

		/* Peripheral Qualifier */
		switch ((gsbuf.dataaddr[0] & 0xE0) >> 5) {
		case 0: /* connected */
		    break;
		case 1: /* capable but not connected */
		    printf("Device not connected\n");
		    break;
		case 2: /* reserved */
		    printf("Reserved\n");
		    break;
		case 3: /* not capable of supporting physical device */
		    continue;
		default: /* vendor unique */
		    printf("Peripheral qualifier error on %d.%d.%d. :error=%d\n", c, s, u, ((gsbuf.dataaddr[0] & 0xE0) >> 5) );
		    continue;
		}
		
		printf("CHAN: %d SCSI: %d UNIT: %d\n", c, s, u);
		
		/* Peripheral Device Type */
		switch (gsbuf.dataaddr[0] & 0x1F) {
		case 0:
		    printf("\tDirect-access\n");
		    break;
		case 1:
		    printf("\tSequential-access\n");
		    break;
		case 2:
		    printf("\tPrinter\n");
		    break;
		case 3:
		    printf("\tProcessor\n");
		    break;
		case 4:
		    printf("\tWrite-once read-multiple\n");
		    break;
		case 5:
		    printf("\tRead-only direct-access\n");
		    break;
		case 6:
		    printf("\tScanner\n");
		    break;
		case 7:
		    printf("\tOptical Memory\n");
		    break;
		case 8:
		    printf("\tChanger\n");
		    break;
		case 9:
		    printf("\tCommunication\n");
		    break;
		default:
		    printf("\tUnknown device type\n");
		    break;
		}
		
		if (gsbuf.dataaddr[1] & 0x80)
		    printf("\tHas removable media\n");
		
		if (verbose) {
		    printf("\tDevice-Type Qualifier:\t%02X\n", gsbuf.dataaddr[1] & 0x7F);
		    printf("\tISO  Version:\t%02X", gsbuf.dataaddr[2] & 0xC0);
		    printf("\tECMA Version:\t%02X", gsbuf.dataaddr[2] & 0x38);
		    printf("\tANSI Version:\t%02X\n", gsbuf.dataaddr[2] & 0x07);
		    printf("\tResponse Data Format:\t%02X\n", gsbuf.dataaddr[3] & 0x0F);
		    printf("\tAdditional Length:\t%02X\n", gsbuf.dataaddr[4]);
		}
		
		if (gsbuf.dataaddr[3] & 0x80)
		    printf("\tCapable of generating asynchronous events\n");
		
		if (gsbuf.dataaddr[7] & 0x80)
		    printf("\tRelative addressing mode supported\n");
		
		if (gsbuf.dataaddr[7] & 0x40)
		    printf("\tWide bus 32-bit supported\n");
		
		if (gsbuf.dataaddr[7] & 0x20)
		    printf("\tWide bus 16-bit supported\n");
		
		if (gsbuf.dataaddr[7] & 0x10)
		    printf("\tSynchronous data transfer supported\n");
		
		if (gsbuf.dataaddr[7] & 0x08)
		    printf("\tLinked commands supported\n");
		
		if (gsbuf.dataaddr[7] & 0x04)
		    printf("\tCaching supported\n");
		
		if (gsbuf.dataaddr[7] & 0x02)
		    printf("\tCommand queueing supported\n");
		
		memset(vendor_id, 0, 17);
		printf("\tVendor ID:\t");
		for (d = 8, i = 0; d < 16; ++d, ++i) {
		    printf("%c", gsbuf.dataaddr[d]);
		    vendor_id[i] = gsbuf.dataaddr[d];
		}
		printf("\n");
		
		memset(product_id, 0, 17);
		printf("\tProduct ID:\t");
		for (d = 16, i = 0; d < 32; ++d, ++i) {
		    printf("%c", gsbuf.dataaddr[d]);
		    product_id[i] = gsbuf.dataaddr[d];
		}
		printf("\n");
		
		memset(rev_level, 0, 5);
		printf("\tRevision Level:\t");
		for (d = 32, i = 0; d < 36; ++d, ++i) {
		    printf("%c", gsbuf.dataaddr[d]);
		    rev_level[i] = gsbuf.dataaddr[d];
		}
		printf("\n");
		
		printf("\tVendor Info:\t");
		for (d = 36; d < 44; ++d)
		    printf("%c", gsbuf.dataaddr[d]);
		printf("\n\n");
		
		/*
		 * Warning Will Robinson!
		 * You are now entering the realm of
		 * gross, twisted special cases that
		 * we have to handle to avoid being screwed
		 * over by some particular controller bugs.
		 *
		 */
		
		/*
		 * GTSC # 1 - Certain devices have controllers that
		 * will behave very badly if you try to access them
		 * with LUN's above 0.  They have a nasty habit of 
		 * hanging the SCSI bus -- your only recourse is to
		 * reboot.
		 *
		 * The current guilty device types are :
		 *
		 *  5	CD-ROM	("Read-only direct access")
		 *  6	Scanners
		 *  7   Optical devices
		 * 
		 * You may have to add others in the future.
		 */
		if ((gsbuf.dataaddr[0] & 0x1F) == 5 ||
		    (gsbuf.dataaddr[0] & 0x1F) == 6 || 
		    (gsbuf.dataaddr[0] & 0x1F) == 7)
		    break;
		
		/*
		 * GTSC # 2 - Maxtor XT-8380S drives with
		 * revision B5IN controller f/w, h/w will
		 * hang the bus if you attempt to use 
		 * an LUN above 2 with it.  Since it's an
		 * embedded SCSI drive anyway, we'll just keep
		 * from looking at anything above 0
		 */
		
		if ((strncmp("MAXTOR", vendor_id, 6) == 0) &&
		    (strncmp("XT-8380S", product_id, 8) == 0) &&
		    (strncmp("B5IN", rev_level, 4) == 0))
		    break;
		
	    }
	}
    }
    close(fildes);
    /*
     * TR 289300221
     * Add an explicit return value (otherwise random
     * exit code is returned).
     */
    return(0);
}
