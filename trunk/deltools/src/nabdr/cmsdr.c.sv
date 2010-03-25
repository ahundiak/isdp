/*
** Copyright 1993 Intergraph Corporation
** All Rights Reserved
**
** This is the source code for the Intergraph CD-ROM
** load-key verifier.  It is placed on each CD-ROM and
** named ".CMSDR.{platform}".  The actual loadkey encrypting
** code is in the function "gk1()" (for old style loadkeys)
** and "gk2()" (for the new 21 character loadkey)
**
** This is VERY sensitive code.  If it gets into the wrong
** hands, then folks could generate loadkeys for any product
** they wanted.  Divulge ONLY ** on a need-to-know bases.
**
*/

#include <sys/param.h>
#ifdef SunOS_4
#include <sys/socket.h>
#include <sys/sockio.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <net/if.h>
#include <net/nit_if.h>
#include <netinet/in.h>
#include <netinet/if_ether.h>
#include <stropts.h>
#endif
/* HP added here -- MVR 7 May 1994 */
#ifdef HP_UX
#include <sys/netio.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <errno.h>
/*#include <fcntl.h>*/
#endif
#if defined(sun) && defined(SVR4)
#include <sys/statvfs.h>
#include <sys/stropts.h>
#include <sys/ethernet.h>
#include <sys/dlpi.h>
#endif
#ifdef SVR3
#include <sys/statfs.h>
#endif
#ifdef sgi
#include <sys/types.h>
#include <sys/syssgi.h>
#include <sys/stat.h>
#endif
#ifdef SCO
#include <sys/ioctl.h>
#include <sys/macstat.h>
#include <sys/stropts.h>
#endif
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>

#include "esapi.h"
#include "msapi.h"
#include "wsapi.h"
#include "myctype.h"
#ifndef sgi
#  include "mytypes.h"
#endif

#define suser()	(geteuid() == 0)

#if defined(sun) && defined(SVR4)
#define nap(X)	sleep((X)/HZ)
#define XXX_DECL
#ifndef CDROM_DEVICE
#  if defined(sparc)
#    define CDROM_DEVICE	"/dev/dsk/c0t6d0s2"
#  else
#    define CDROM_DEVICE	"/dev/dsk/cdrom"
#  endif
#endif
#define INGRHOME	"/opt/ingr"
#endif

#ifdef SunOS_4
#define nap(X)	sleep((X)/HZ)
#define XXX_DECL	static
#ifndef CDROM_DEVICE
#define CDROM_DEVICE	"/dev/sr0"
#endif
#endif
/* HP added here -- MVR 7 May 1994 */
#ifdef HP_UX
#define nap(X)	sleep((X)/HZ)
#define XXX_DECL	/* Take out static for HP_UX jhb 2/27/95 */
#ifndef CDROM_DEVICE
#define CDROM_DEVICE	"/dev/dsk/cdrom"
#endif
#endif

#ifdef sgi
#define nap(X)  sleep((X)/HZ)
#define XXX_DECL	static
#ifndef CDROM_DEVICE
#define CDROM_DEVICE	"/dev/dsk/cdrom"
#endif
#endif

#ifdef SCO
#define nap(X)	sleep((X)/HZ)
#define XXX_DECL	static
#ifndef CDROM_DEVICE
#define CDROM_DEVICE	"/dev/cd0"
#endif
#endif

#if defined(__clipper__)
#define XXX_DECL	static
#ifndef CDROM_DEVICE
#define CDROM_DEVICE	"/dev/dsk/cdrom"
#endif
#endif

#define OIP	 0
#define OFP	 64
#define O1C	 128
#define O1D	 156
#define O2C	 184
#define O2D	 208

char tbuf[62*1024];
char system_id[6];
unsigned int mnabdr;

struct nabdri_t {
	int	fd;
	char	*gprodnumber;
	char	*gstr;
	char	*gprodflag;
	int	iproc;
	char	*gprodversion;
};

struct nabdrt_t {
	char	*b;	/* pointer to the buffer */
	int	bs;	/* size of the buffer */
	int	iproc;	/* index to process table */
};

extern char *getenv();

/*
 * Initial permutation,
 */
XXX_DECL char IP[64] = {
        58,50,42,34,26,18,10, 2,
        60,52,44,36,28,20,12, 4,
        62,54,46,38,30,22,14, 6,
        64,56,48,40,32,24,16, 8,
        57,49,41,33,25,17, 9, 1,
        59,51,43,35,27,19,11, 3,
        61,53,45,37,29,21,13, 5,
        63,55,47,39,31,23,15, 7,
};

/*
 * Final permutation, FP = IP^(-1)
 */
XXX_DECL char FP[64] = {
        40, 8,48,16,56,24,64,32,
        39, 7,47,15,55,23,63,31,
        38, 6,46,14,54,22,62,30,
        37, 5,45,13,53,21,61,29,
        36, 4,44,12,52,20,60,28,
        35, 3,43,11,51,19,59,27,
        34, 2,42,10,50,18,58,26,
        33, 1,41, 9,49,17,57,25,
};

/*
 * Permuted-choice 1 from the key bits
 * to yield C and D.
 * Note that bits 8,16... are left out:
 * They are intended for a parity check.
 */
XXX_DECL char PC1_C[28] = {
         1,58,50,42,34,26,18,
        21,13, 5,28,20,12, 4,
        63,55,47,39,31,23,15,
        10, 2,59,51,43,35,27,
};

XXX_DECL char PC1_D[28] = {
         7,62,54,46,38,30,22,
        19,11, 3,60,52,44,36,
        57,49,41,33,25,17, 9,
        14, 6,61,53,45,37,29,
};

/*
 * Permuted-choice 2, to pick out the bits from
 * the CD array that generate the key schedule.
 */
XXX_DECL char PC2_C[24] = {
        14,17,11,24, 1, 5,
         3,28,15, 6,21,10,
        23,19,12, 4,26, 8,
        16, 7,27,20,13, 2,
};

XXX_DECL char PC2_D[24] = {
        41,52,31,37,47,55,
        30,40,51,45,33,48,
        44,49,39,56,34,53,
        46,42,50,36,29,32,
};

/*
 * Sequence of shifts used for the key schedule.
 */
XXX_DECL char shifts[16] = { 1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1, };

/*
 * The C and D arrays used to calculate the key schedule.
 */

XXX_DECL char C[28];
XXX_DECL char D[28];
/*
 * The key schedule.
 * Generated from the key.
 */
XXX_DECL char KS[16][48];

/*
 * The E bit-selection table.
 */
XXX_DECL char E[48];
XXX_DECL char e2[48] = {
	32, 1, 2, 3, 4, 5,
	 4, 5, 6, 7, 8, 9,
	 8, 9,10,11,12,13,
	12,13,14,15,16,17,
	16,17,18,19,20,21,
	20,21,22,23,24,25,
	24,25,26,27,28,29,
	28,29,30,31,32, 1,
};

/*
 * Set up the key schedule from the key.
 */

void sk(key)
char	*key;
{
	int	i, j, k;
	int	t;

	i = 0; j = 0; k = 0;

	/*
	 * First, generate C and D by permuting
	 * the key.  The low order bit of each
	 * 8-bit char is not used, so C and D are only 28
	 * bits apiece.
	 */
	for(i=0; i < 28; i++) {
		C[i] = key[PC1_C[i]-1];
		D[i] = key[PC1_D[i]-1];
	}
	/*
	 * To generate Ki, rotate C and D according
	 * to schedule and pick up a permutation
	 * using PC2.
	 */
	for(i=0; i < 16; i++) {
		/*
		 * rotate.
		 */
		for(k=0; k < shifts[i]; k++) {
			t = C[0];
			for(j=0; j < 28-1; j++)
				C[j] = C[j+1];
			C[27] = t;
			t = D[0];
			for(j=0; j < 28-1; j++)
				D[j] = D[j+1];
			D[27] = t;
		}
		/*
		 * get Ki. Note C and D are concatenated.
		 */
		for(j=0; j < 24; j++) {
			KS[i][j] = C[PC2_C[j]-1];
			KS[i][j+24] = D[PC2_D[j]-28-1];
		}
	}

	for(i=0; i < 48; i++)
		E[i] = e2[i];
}

/*
 * The 8 selection functions.
 * For some reason, they give a 0-origin
 * index, unlike everything else.
 */
XXX_DECL char S[8][64] = {
	14, 4,13, 1, 2,15,11, 8, 3,10, 6,12, 5, 9, 0, 7,
	 0,15, 7, 4,14, 2,13, 1,10, 6,12,11, 9, 5, 3, 8,
	 4, 1,14, 8,13, 6, 2,11,15,12, 9, 7, 3,10, 5, 0,
	15,12, 8, 2, 4, 9, 1, 7, 5,11, 3,14,10, 0, 6,13,

	15, 1, 8,14, 6,11, 3, 4, 9, 7, 2,13,12, 0, 5,10,
	 3,13, 4, 7,15, 2, 8,14,12, 0, 1,10, 6, 9,11, 5,
	 0,14, 7,11,10, 4,13, 1, 5, 8,12, 6, 9, 3, 2,15,
	13, 8,10, 1, 3,15, 4, 2,11, 6, 7,12, 0, 5,14, 9,

	10, 0, 9,14, 6, 3,15, 5, 1,13,12, 7,11, 4, 2, 8,
	13, 7, 0, 9, 3, 4, 6,10, 2, 8, 5,14,12,11,15, 1,
	13, 6, 4, 9, 8,15, 3, 0,11, 1, 2,12, 5,10,14, 7,
	 1,10,13, 0, 6, 9, 8, 7, 4,15,14, 3,11, 5, 2,12,

	 7,13,14, 3, 0, 6, 9,10, 1, 2, 8, 5,11,12, 4,15,
	13, 8,11, 5, 6,15, 0, 3, 4, 7, 2,12, 1,10,14, 9,
	10, 6, 9, 0,12,11, 7,13,15, 1, 3,14, 5, 2, 8, 4,
	 3,15, 0, 6,10, 1,13, 8, 9, 4, 5,11,12, 7, 2,14,

	 2,12, 4, 1, 7,10,11, 6, 8, 5, 3,15,13, 0,14, 9,
	14,11, 2,12, 4, 7,13, 1, 5, 0,15,10, 3, 9, 8, 6,
	 4, 2, 1,11,10,13, 7, 8,15, 9,12, 5, 6, 3, 0,14,
	11, 8,12, 7, 1,14, 2,13, 6,15, 0, 9,10, 4, 5, 3,

	12, 1,10,15, 9, 2, 6, 8, 0,13, 3, 4,14, 7, 5,11,
	10,15, 4, 2, 7,12, 9, 5, 6, 1,13,14, 0,11, 3, 8,
	 9,14,15, 5, 2, 8,12, 3, 7, 0, 4,10, 1,13,11, 6,
	 4, 3, 2,12, 9, 5,15,10,11,14, 1, 7, 6, 0, 8,13,

	 4,11, 2,14,15, 0, 8,13, 3,12, 9, 7, 5,10, 6, 1,
	13, 0,11, 7, 4, 9, 1,10,14, 3, 5,12, 2,15, 8, 6,
	 1, 4,11,13,12, 3, 7,14,10,15, 6, 8, 0, 5, 9, 2,
	 6,11,13, 8, 1, 4,10, 7, 9, 5, 0,15,14, 2, 3,12,

	13, 2, 8, 4, 6,15,11, 1,10, 9, 3,14, 5, 0,12, 7,
	 1,15,13, 8,10, 3, 7, 4,12, 5, 6,11, 0,14, 9, 2,
	 7,11, 4, 1, 9,12,14, 2, 0, 6,10,13,15, 3, 5, 8,
	 2, 1,14, 7, 4,10, 8,13,15,12, 9, 0, 3, 5, 6,11,
};

/*
 * P is a permutation on the selected combination
 * of the current L and key.
 */
XXX_DECL char P[32] = {
	16, 7,20,21,
	29,12,28,17,
	 1,15,23,26,
	 5,18,31,10,
	 2, 8,24,14,
	32,27, 3, 9,
	19,13,30, 6,
	22,11, 4,25,
};

/*
 * The current block, divided into 2 halves.
 */
XXX_DECL char L[32], R[32];
XXX_DECL char tempL[32];
XXX_DECL char f[32];

/*
 * The combination of the key and the input, before selection.
 */
XXX_DECL char preS[48];

#ifdef SunOS_4
int gaddr(ea)
unsigned char ea[];
{
    int			fd;
    int			if_index = 0, success = 0;
    struct strioctl	si;
    struct ifreq	ifr;
    static char		*interfaces[] = { "le0", "ie0", "" };

    /* Open the Streams NIT clone device */
    if ((fd = open("/dev/nit", O_RDONLY)) < 0) {
	return(-1);
    }

    /* Bind the network connection to the Ethernet transport */
    while (!success && *interfaces[if_index]) {
	strcpy(ifr.ifr_name, interfaces[if_index]);
	si.ic_cmd = NIOCBIND;
	si.ic_len = sizeof ifr;
	si.ic_dp = (char *)&ifr;
	if (ioctl(fd, I_STR, (char *)&si) < 0) {
	    if (errno == ENXIO) {
		/*
		 * Bind failed because interface didn't exist
		 * Try the next one.
		 */
		if_index++;
		continue;
	    }
	    else {
		/*
		 * Unknown error.  Just get out.
		 */
		close(fd);
		return(-1);
	    }
	}
	else
	    success = 1;
    }

    if (!success) {
	close(fd);
	return(-1);
    }

    strcpy(ifr.ifr_name, interfaces[if_index]);

    /* Now ask the connection for the Ethernet address */
    if (ioctl(fd, SIOCGIFADDR, &ifr) < 0) {
	close(fd);
	return(-1);
    }

    ea[0] = ifr.ifr_addr.sa_data[0] & 0xff;
    ea[1] = ifr.ifr_addr.sa_data[1] & 0xff;
    ea[2] = ifr.ifr_addr.sa_data[2] & 0xff;
    ea[3] = ifr.ifr_addr.sa_data[3] & 0xff;
    ea[4] = ifr.ifr_addr.sa_data[4] & 0xff;
    ea[5] = ifr.ifr_addr.sa_data[5] & 0xff;

    close(fd);
    return(0);
}

#endif


/*mvr:05/07/94 module for getting ethernet address on HP.the method is to scan 
 * through the /dev/lanX devices till we get the first device which responds. 
 * Then  we get the ethernet adderss associated with it throgh a ioctl call
 * MVR 7 May 1994 
*/

#ifdef HP_UX
int gaddr(ea)
unsigned char ea[];
{
	int lan_fd;
	struct fis arg;
	int if_index = 0, success = 0;
	static char *interfaces[] = {
					"/dev/lan0", "/dev/lan1",
					"/dev/lan2", "/dev/lan3",
					"/dev/lan4", ""};

	while (!success && interfaces[if_index]) {
		if ((lan_fd = open(interfaces[if_index], O_RDONLY)) < 0) {
			if (errno == ENXIO) {
				/* no device. Try next one */	
				if_index++;
				continue;
			}
			else {
				/* Failed for unknown reason. Let's return */ 
				return -1;
			}
		}
		else
			success = 1;
		
	}

	if (!success)
		return -1;
	
	/* We found the device.Let's get ethernet address. -- MVR 7 May 1994 */
	arg.reqtype = LOCAL_ADDRESS;
	arg.vtype = 6;

	if ((ioctl(lan_fd, NETSTAT, &arg)) < 0) {
		perror("Ioctl error! \n");
		close(lan_fd);
		return -1;
	}
	close(lan_fd);
	ea[0] = arg.value.s[0];
	ea[1] = arg.value.s[1];
	ea[2] = arg.value.s[2];
	ea[3] = arg.value.s[3]&0xff;
	ea[4] = arg.value.s[4]&0xff;
	ea[5] = arg.value.s[5]&0xff;
	return 0;
}

#endif /* HP_UX */

#if defined(sun) && defined(SVR4)
int gaddr(ea)
unsigned char ea[];
{
    /*
     * SVR4 Method of getting the hardware ethernet address using DLPI
     */
    int                         nfd, flags, i;
    FILE			*lfd;
    unsigned char               eaddr[8];
    struct strbuf               ctlbuf;
    dl_attach_req_t             attach_req;
    dl_phys_addr_req_t          address_req;
    union DL_primitives         rcvbuf;
    char			*ingrhome, *c;
    char			iflist[256], netif[80];
    static char *interfaces[] = { "/dev/le",
   				  "/dev/ie",
				  "/dev/el",
				  "/dev/elx",
				  "" };

    ingrhome = getenv("INGRHOME");
    if (ingrhome == NULL || *ingrhome == '\0')
        ingrhome = INGRHOME;

    strcpy(iflist, ingrhome);
    strcat(iflist, "/deltools/interfaces");
    lfd = fopen(iflist, "r");
    if (lfd) {
	nfd = -1;
        while (fgets(netif, 80, lfd)) {

	    if (*netif == '#')
		continue;

            /*
            ** Strip off newline
            */
            c = strchr(netif, '\n');
            if (c)
                *c = '\0';

            if ((nfd = open(netif, O_RDWR)) >= 0)
                break;
        }
        fclose(lfd);

        if (nfd < 0)
            return(-1);
    }
    else {
	/*
	** If we couldn't find the interface list file,
	** try a small set of "known" interfaces.
	*/
	for (nfd = -1, i = 0; *interfaces[i]; i++) {
	    if ((nfd = open(interfaces[i], O_RDWR)) >= 0)
		break;
	}

	/* See if we got a valid file descriptor */
	if (nfd < 0)
	    return(-1);
    }
    /*
     * Send DL_ATTACH_REQ to attach to an instance number
     */
    attach_req.dl_primitive = DL_ATTACH_REQ;
    attach_req.dl_ppa = 0;                      /* Attach to instance 0 */

    ctlbuf.len = DL_ATTACH_REQ_SIZE;

    ctlbuf.buf = (char *)&attach_req;
    if (putmsg(nfd, &ctlbuf, NULL, 0) < 0) {
	close(nfd);
	return(-1);
    }

    /*
     *  Wait for OK_ACK, indicating successful attach
     */
    ctlbuf.maxlen = sizeof(union DL_primitives);
    ctlbuf.len = 0;
    ctlbuf.buf = (char *)&rcvbuf;
    flags = RS_HIPRI;

    if (getmsg(nfd, &ctlbuf, NULL, &flags) < 0) {
	close(nfd);
	return(-1);
    }
    switch (rcvbuf.dl_primitive) {
    case DL_OK_ACK:
	/* Primitive acknowledged */
	break;
    case DL_ERROR_ACK:
	/* Get error information */
	close(nfd);
	return(-1);
	break;
    }

    /*
     * Now send DL_PHYS_ADDR_REQ to get the actual 6 octet ethernet
     * address (returned in DL_PHYS_ADDR_ACK).
     */
    address_req.dl_primitive = DL_PHYS_ADDR_REQ;
    address_req.dl_addr_type = DL_FACT_PHYS_ADDR; /* get factory address */

    ctlbuf.len = DL_PHYS_ADDR_REQ_SIZE;
    ctlbuf.buf = (char *) &address_req;
    if (putmsg(nfd, &ctlbuf, NULL, 0) < 0) {
	close(nfd);
	return(-1);
    }

    /*
     * Now pull up the response.
     */
    ctlbuf.maxlen = sizeof(union DL_primitives);
    ctlbuf.len = 0;
    ctlbuf.buf = (char *)&rcvbuf;
    flags = RS_HIPRI;

    if (getmsg(nfd, &ctlbuf, NULL, &flags) < 0) {
	close(nfd);
	return(-1);
    }
    switch (rcvbuf.dl_primitive) {
    case DL_PHYS_ADDR_ACK:
	/* Get information out of structure */
	memcpy(ea, ctlbuf.buf + rcvbuf.physaddr_ack.dl_addr_offset,
			    rcvbuf.physaddr_ack.dl_addr_length);
	break;
    case DL_OK_ACK:
	/* Primitive acknowledged */
	break;
    case DL_ERROR_ACK:
	/* Get error information */
	close(nfd);
	return(-1);
	break;
    }

    /*
     * Now detach.  You'd think this would be done automatically
     * upon closing, but apparently not (after running a test
     * program several times, the system couldn't do any more
     * DLPI bindings)
     */
    attach_req.dl_primitive = DL_DETACH_REQ;
    attach_req.dl_ppa = 0;                  /* Detach from instance 0 */

    ctlbuf.len = DL_DETACH_REQ_SIZE;
    ctlbuf.buf = (char *)&attach_req;
    if (putmsg(nfd, &ctlbuf, NULL, 0) < 0) {
	close(nfd);
	return(-1);
    }

    /*
     *  Wait for OK_ACK, indicating successful attach
     */
    ctlbuf.maxlen = sizeof(union DL_primitives);
    ctlbuf.len = 0;
    ctlbuf.buf = (char *)&rcvbuf;
    flags = RS_HIPRI;

    if (getmsg(nfd, &ctlbuf, NULL, &flags) < 0) {
	close(nfd);
	return(-1);
    }

    switch (rcvbuf.dl_primitive) {
    case DL_OK_ACK:
	/* Primitive acknowledged */
	break;
    case DL_ERROR_ACK:
	/* Get error information */
	break;
    }
    close(nfd);
    return(0);
}
#endif

#ifdef sgi
int gaddr(ea)
unsigned char ea[];
{
    char sysid[MAXSYSIDSIZE];

    if (syssgi(SGI_SYSID, sysid) < 0)
	return(-1);

    ea[2] = sysid[0];
    ea[0] = 0x08;
    ea[3] = sysid[1];
    ea[1] = 0x00;
    ea[4] = sysid[2];
    ea[5] = sysid[3];

    return(0);
}
#endif

#ifdef SCO
/*++ jhb 18/may/93 : AST/SCO changes. ++*/
/*
** 17 NOV 1994   SCW
**
** New ISMP systems have different ethernet hardware and hence,
** different device names.  Start using the same kind of "interfaces"
** file that we implemented for Intel Solaris so we can add support
** for new supported interfaces quickly.
*/
int gaddr(ea)
unsigned char ea[];
{
    int                         nfd, i;
    struct strioctl             gea;
    char			*iflist, *c;
    char			netif[80];
    FILE			*lfd;
    static char *interfaces[] = { "/dev/pnt0",
                                  "/dev/i3B0",
                                  "/dev/e3B0",
                                  "" };

    iflist = "/usr/ip32/deltools/interfaces";
    lfd = fopen(iflist, "r");
    if (lfd) {
        nfd = -1;
        while (fgets(netif, 80, lfd)) {

            if (*netif == '#')
                continue;

            /*
            ** Strip off newline
            */
            c = strchr(netif, '\n');
            if (c)
                *c = '\0';

            if ((nfd = open(netif, O_RDWR)) >= 0)
                break;
        }
        fclose(lfd);

        if (nfd < 0)
            return(-1);
    }
    else {
        /*
        ** Couldn't open any "interface" list.
        ** try a small list of known interfaces.
        */
        for (nfd = -1, i = 0; *interfaces[i]; i++) {
            if ((nfd = open(interfaces[i], O_RDWR)) >= 0)
                break;
        }

        /* See if we got a valid file descriptor */
        if (nfd < 0)
            return(-1);
    }

    gea.ic_cmd=MACIOC_GETRADDR;
    gea.ic_timout=INFTIM;
    gea.ic_len=6;
    gea.ic_dp=ea;
    if (( ioctl(nfd,I_STR,&gea)) < 0) {
        perror("getraddr ioctl error");
        close(nfd);
    }
    close(nfd);
    return(0);
}
/*--*/
#endif

/* same as the strcat() function */
char *addon(s,t)
char *s, *t;
{
        while (*s++ != 0)
                ;
        s--;
        while ((*s++ = *t++) != 0)
                ;
	return(s);
}

/* same as atoi() function */
int chnge(t)
char *t;
{
        int     mult=1, min=1;
        int     tot=0;
        char    *s;

        if (*t=='-') {
                min= -1;
                t++;
        }
        s=t;
        while (*s!=0 && *s>='0' && *s<='9') {
                s++;
                mult*=10;
        }
        while (*t!=0 && *t>='0' && *t<='9')
                tot += (*t++ - '0') * (mult/=10);
        return min*tot;
}


/*
 * The payoff: encrypt a block.
 */

void ecpt(block, fake)
char	*block;
int	fake;
{
	int	i, ii;
	int	t, j, k;

	/*
	 * First, permute the bits in the input
	 */
	for(j=0; j < 64; j++)
		L[j] = block[IP[j]-1];
	/*
	 * Perform an encryption operation 16 times.
	 */
	for(ii=0; ii < 16; ii++) {
		/*
		 * Set direction
		 */
		if(fake)
			i = 15-ii;
		else
			i = ii;
		/*
		 * Save the R array,
		 * which will be the new L.
		 */
		for(j=0; j < 32; j++)
			tempL[j] = R[j];
		/*
		 * Expand R to 48 bits using the E selector;
		 * exclusive-or with the current key bits.
		 */
		for(j=0; j < 48; j++)
			preS[j] = R[E[j]-1] ^ KS[i][j];
		/*
		 * The pre-select bits are now considered
		 * in 8 groups of 6 bits each.
		 * The 8 selection functions map these
		 * 6-bit quantities into 4-bit quantities
		 * and the results permuted
		 * to make an f(R, K).
		 * The indexing into the selection functions
		 * is peculiar; it could be simplified by
		 * rewriting the tables.
		 */
		for(j=0; j < 8; j++) {
			t = 6*j;
			k = S[j][(preS[t+0]<<5)+
				(preS[t+1]<<3)+
				(preS[t+2]<<2)+
				(preS[t+3]<<1)+
				(preS[t+4]<<0)+
				(preS[t+5]<<4)];
			t = 4*j;
			f[t+0] = (k>>3)&01;
			f[t+1] = (k>>2)&01;
			f[t+2] = (k>>1)&01;
			f[t+3] = (k>>0)&01;
		}
		/*
		 * The new R is L ^ f(R, K).
		 * The f here has to be permuted first, though.
		 */
		for(j=0; j < 32; j++)
			R[j] = L[j] ^ f[P[j]-1];
		/*
		 * Finally, the new L (the original R)
		 * is copied back.
		 */
		for(j=0; j < 32; j++)
			L[j] = tempL[j];
	}
	/*
	 * The output L and R are reversed.
	 */
	for(j=0; j < 32; j++) {
		t = L[j];
		L[j] = R[j];
		R[j] = t;
	}
	/*
	 * The final output
	 * gets the inverse permutation of the very original.
	 */
	for(j=0; j < 64; j++)
		block[j] = L[FP[j]-1];
}

/* the crypt function */
char *cpt(pw, salt)
char	*pw, *salt;
{
	int	i, j, c;
	int	temp;
	static char block[66], iobuf[18];

	for(i=0; i < 66; i++)
		block[i] = 0;
	for(i=0; (c= *pw) && i < 64; pw++) {
		for(j=0; j < 7; j++, i++)
			block[i] = (c>>(6-j)) & 01;
		i++;
	}
	
	sk(block);
	
	for(i=0; i < 66; i++)
		block[i] = 0;

	for(i=0; i < 2; i++) {
		c = *salt++;
		iobuf[i] = c;
		if(c > 'Z')
			c -= 6;
		if(c > '9')
			c -= 7;
		c -= '.';
		for(j=0; j < 6; j++) {
			if((c>>j) & 01) {
				temp = E[6*i+j];
				E[6*i+j] = E[6*i+j+24];
				E[6*i+j+24] = temp;
			}
		}
	}
	
	for(i=0; i < 25; i++)
		ecpt(block, 0);

	/*
	 * convert the final output to be nnnnnnaa format
	 */
	for(i=0; i < 8; i++) {
		c = 0;
		for(j=0; j < 6; j++) {
			c <<= 1;
			c |= block[6*i+j];
		}
		/* post process the output */
		c += '.';
		if (c > '9')
			c += 7;
		if (c > 'Z')
			c += 6;
		iobuf[i] = c;
	}
	iobuf[i] = 0;
	return(iobuf);
}

XXX_DECL char	X1[16] = {
	7, 12, 5, 15,
	9, 0, 11, 3,
	14, 1, 13, 4,
	10, 2, 6, 8,
	};

XXX_DECL char	X2[21] = {
	10, 15,  6, 20, 12,
	 0, 13,  2, 18,  4,
	11,  3, 19,  1, 16,
	 5, 17,  7,  9, 14,
	 8 };


/*
 * generate key from netaddr, volume, product number
 */

char *gk1(num, ntr, vol)
char *num, *vol;
unsigned char *ntr;	/* net address */
{
	int	i, j, lasti;
	char	t[3], d[4];
	char	a[17], b[17];
	static	char keystr[20];
	char	nstr[3];

	/*
	 * Convert the date stamp - mmddyy
	 * into [A-Z] and put the result in d[0] d[1] d[2] d[3]
	 *                               and a[0] a[1] a[2]
	 */
	t[2] = 0;
	d[3] = 0;
	for (j = 0, i = 0; i < 3; i++) {
	    t[0] = vol[j++];
	    t[1] = vol[j++];
	    d[i] = (chnge(t) % 26) + 'A';
	    a[i] = d[i];
	}

	/*
	 * Convert the the ntr[3] [4] [5]
	 * put the result in a[3] a[4] a[5] a[6] a[7] a[8] as hex characters
	 */
	for (j = 3, i = 0; i < 3; i++) {
		a[j++] = (ntr[i + 3] & 0x0f) + 'j';
		a[j++] = ((unsigned char)(ntr[i + 3] & 0xf0) >> 4) + 'J';
	}

	/*
	 * Put the product number - SSS456789 in
	 *	a[9] a[10] a[11] a[12] a[13] a[14] a[15]
	 * (Product numbers used to be only 7 characters and would fit
	 * into the 7 character space exactly.  Product numbers are now
	 * 9 characters, so we have to squeeze .  The first three
	 * characters are alpha, so we leave them unmodified.  The last
	 * six are taken IN PAIRS and encoded into binary.  This leaves
	 * us room for future expansion.  NOTE THAT IF YOU HAVE AN ODD
	 * NUMBER OF DIGITS IN THE NUMBER, SSS0000001 (10 char pn) will
	 * encode into the same value as SSS00000001 (11 char pn) because
	 *  
	 *                    atoi("01") == atoi("1")
	 * 
	 *
	 */
	if (strlen(num) == 7) {
	    for (i = 0; i < 7; i++)
		a[i + 9] = num[i];
	}
	else {
	    for (i = 0; i < 3; i++) {
		a[i + 9] = num[i];
	    }
	    nstr[2] = 0;
	    for (i = 3; (i < 7) && (num[(2*i)-3] != '\0'); i++) {
		nstr[0] = num[(2 * i) - 3];
                nstr[1] = num[(2 * i) - 2];
		a[i + 9] = chnge(nstr);
	    }
	    while (i < 7) {
		a[i + 9] = 0;
		i++;
	    }
	}
        lasti = i + 9;
	a[16] = 0;

	/*
	 * now permute the 16 byte string for input into crypt
	 */
	for (i = 0; (i < 16); i++)
		b[i] = a[X1[i]];
	b[16] = 0;

	/*
	 * encrypt the 16 bytes in two passes, use the release date as the salt
	 * for the first pass and the netaddr as the salt for the second pass
	 */
	strcpy(a, cpt(b, &a[5]));
	addon(a, cpt(&b[8], a));

	/*
	 * permute the encrypted string
	 */
	for (i = 0; (i < 16) && (i < lasti); i++)
		b[i] = a[X1[15 - i]];
	b[16] = 0;

	strcpy(keystr, d);
	addon(keystr, b);
	return(keystr);
}

char *gk2(num, ntr, vol)
char *num, *vol;
unsigned char *ntr;	/* net address */
{
	int	i, j;
	char	a[25], b[25], c[25];
	static	char keystr[25];
	char	nstr[8];


	memset(a, 0, 25);
	memset(b, 0, 25);
	memset(c, 0, 25);


	/*
	 * Convert the the ntr[3] [4] [5]
	 * put the result in a[0] through a[5]
	 * as hex characters
	 */
	for (j = 0, i = 0; i < 3; i++) {
		a[j++] = (ntr[i + 3] & 0x0f) + 'j';
		a[j++] = ((unsigned char)(ntr[i + 3] & 0xf0) >> 4) + 'J';
	}

	/*
	 * Put the product number - SS3456789012345 in
	 *	a[6] through a[20]
	 */
	for (i = 0; i < 15; i++) {
	    a[i+6] = num[i];
	}
	a[21] = 0;

	/*
	 * now permute the 21 byte string for input into crypt
	 */
	for (i = 0; (i < 21); i++)
		b[i] = a[X2[i]];
	b[21] = 0;

	/*
	 * encrypt the 21 bytes in three passes (8, 8, and 5)
         *      Pass 1: Part of ethernet id is salt
	 *      Pass 2: Platform code is salt
         *      Pass 3: Major version number is salt
	 */
	strcpy(c, cpt(b, &a[0]));
	addon(c, cpt(&b[8], &a[8]));
	addon(c, cpt(&b[16], &a[16]));


	/*
	 * permute the encrypted string
	 */
	for (i = 0; (i < 21); i++)
		b[i] = c[X2[20 - i]];
	b[21] = 0;

	strcpy(keystr, b);
	return(keystr);
}

#ifdef sgi
/*
 * Find the pathname to the mount point of the passed in directory
 * Return NULL if the file doesn't exist or isn't an absolute path
 * (4/17/91 SCW -- NOT NECESSARILY... see below!)
 */
char  *GetMountPoint(path)
char  *path;
{
      dev_t   dev;
      char    *c;
      int     result;
      static char     p[256];
      struct stat     statbuf;
      extern char     *strrchr();

      if (path[0] != '/')
              return(NULL);

      strcpy(p, path);

      while ((*p != '\0') &&
             (((result = stat(p, &statbuf)) < 0) && (errno == ENOENT))) {
          /* We can't simply return NULL if the file doesn't exist.
           * If we're installing a new product, the destination directory
           * won't be out there yet.  We still have to get its mount point
           * though.  So start taking things off the back until we do
           * have a directory that exists.  If we get all the way back
           * the beginning, or if stat() fails for some other reason
           * we'll go ahead and return NULL.
           */
          c = strrchr(p, '/');
          *c = '\0';
      }

      if (*p == '\0')         /* No element of the path existed at all */
          return(NULL);

      if ((result < 0) && (errno != ENOENT)) /* Some other stat() error */
          return(NULL);

      /* NOW we have remaining directory.   Let 'er rip */
      dev = statbuf.st_dev;

      for (;;) {
              c = strrchr(p, '/');
              *c = '\0';
              if (c == p)
                      stat("/", &statbuf);
              else
                      stat(p, &statbuf);
              if (statbuf.st_dev != dev)
                      break;
              else if (c == p) {
                      p[1] = '\0';
                      break;
              }
      }
      *c = '/';
      return(p);
}


/*
 * Prompt for the directory where the delivery tree files will be put.
 * CD-ROM handling for SGI IRIX is complicated by the fact that they
 * don't implement the CD-ROM as a "standard" disk device.  It's handled
 * strictly through a "generic" SCSI device node, which you must open
 * and then send SCSI commands to in order to perform any operations with
 * the drive.
 *
 * Further complicating this is the fact that the generic SCSI devices
 * are implemented as "exclusive open" devices; only one process can
 * have the device open at any time.  So if the CD-ROM is mounted, you
 * can't do any other operations with the device.
 *
 * This makes getting the volume label extremely difficult.  Our only
 * possibility is to look for a "volume" file (which is only present
 * on CD's made for ISS 7.00 or later) and pull the CD-ROM release
 * date out of it instead.
 *
 */
getpack(fd, pn)
int fd;
char pn[];
{
    char label[7];
    char vbuf[1024];
    int cfd;
    char *c, *mp;
    char *fname = getenv("KF");
    char vname[128];

    memset(label, 0, 7);
    memset(pn, 0, 7);

    mp = GetMountPoint(fname);
    if (mp == NULL)
	return(0);

    strcpy(vname, mp);
    strcat(vname, "/volume");
    /*
     * check for the volume file, if not there then exit quietly
     */
    if (access(vname, R_OK) == 0) {
	cfd = open(vname, O_RDONLY);
	if (cfd < 0)
	    return(0);
    }
    else {
	for (c = vname + strlen(mp); *c; c++)
		*c = toupper(*c);
	if (access(vname, R_OK) == 0) {
	    cfd = open(vname, O_RDONLY);
	    if (cfd < 0)
		return(0);
	}
	else
	    return(0);
    }

    /*
     *  Alright, now we've got the file open.
     *  Read the data, which is formatted as:
     *
     *  {Disc Title}#{Disc Date}#{Volume label}#{FMDA part number}
     */
    if (read (cfd, vbuf, 1024) < 0) {
	close(cfd);
	return(0);
    }
    close(cfd);

    /*
     * Now, with the magic of strtok(), find the third field.
     */
    c = (char *)strtok(vbuf, "#");	/* Field 1 */
    c = (char *)strtok(NULL, "#");	/* Field 2 */
    c = (char *)strtok(NULL, "#");	/* Field 3 */

    if (c == NULL)
	return(0);

    pn[5] = *(c+5);
    pn[3] = *(c+3);
    pn[0] = *c;
    pn[1] = *(c+1);
    pn[4] = *(c+4);
    pn[2] = *(c+2);
}

#else /* sgi */
getpack(fd, pn)
int fd;
char pn[];
{
	int cfd;
	char label[7];

	cfd = open(CDROM_DEVICE, O_RDONLY);
	lseek(cfd, (16*2048+47), 0);
	read(cfd, label, 6);
	close(cfd);
	
	pn[5] = label[5];
	pn[3] = label[3];
	pn[0] = label[0];
	pn[1] = label[1];
	pn[4] = label[4];
	pn[2] = label[2];
}
#endif /* sgi */


/* confirm access */
nabdrinit(uap)
struct nabdri_t *uap;
{
	char		vol[7];
	unsigned char	ntr[6];		/* net address */
	int		x, y, i;
	char		str[22], *rt;
	char		prodnumber[16];
	char		prodflag[15];
	char		pack[7];
	unsigned char	ea[6];
	int		sernoauth();
	char		serno[15];
	if (!suser()) {
		errno = EPERM;
		return(-1);
	}
	mnabdr = 0;

	for (x=0; x<22; str[x++]='\0')
		;
	x=0;
	while (str[x++] = *(uap->gstr++))
		if (x >= 22)
			break;

	for (x=0; x<16; prodnumber[x++]='\0')
		;
	x=0;
	while (prodnumber[x++] = *(uap->gprodnumber++))
		if (x >= 16)
			break;

	/*
	** For 7.5, product numbers must be padded to 15
	** characters.  If the product number is only seven
	** characters long, pad it with "AA-0000A".  If the
	** product number is nine characters long, pad it with
	** "-0000A"
	*/

	switch (strlen(prodnumber)) {
	    case 7:
		strcat(prodnumber, "AA-0000A");
		break;
	    case 9:
		strcat(prodnumber, "-0000A");
		break;
	}

	/*
	** Software Distribution needs us to map part
	** numbers that have "00" as their eighth and
	** ninth characters to "AA".
	*/
	if (prodnumber[7] == '0' && prodnumber[8] == '0') {
	    prodnumber[7] = 'A';
	    prodnumber[8] = 'A';
	}


        /*
	** New loadkeys will also use major/minor version info.
	** CLIX products will not have this in their 15 character
	** part numbers, so we must specifically put it there.
	*/

        prodnumber[10] = uap->gprodversion[0];
        prodnumber[11] = uap->gprodversion[1];
        prodnumber[12] = uap->gprodversion[3];
        prodnumber[13] = uap->gprodversion[4];

	for (x=0; x<15; prodflag[x++]='\0')
		;
	x=0;
	while (prodflag[x++] = *(uap->gprodflag++))
		if (x >= 15)
			break;

	/* get salt from mounted filesystem with open descriptor fd */
        getpack(uap->fd, pack);

	/*
	 *  The following is the same as:	
	 * 	strncpy(vol, statfsbuf.f_fpack, 6);
	 */
	vol[0] = pack[0];
	vol[3] = pack[3];
	vol[2] = pack[2];
	vol[5] = pack[5];
	vol[1] = pack[1];
	vol[4] = pack[4];
	vol[6] = 0;

	if (str && prodnumber) {
#if defined(clipper) || defined(__clipper__)
	    /* get the network address */
	    sysid(system_id);
	    for (i = 5; i > 2; i--)
		system_id[i-3] = system_id[i];

	    ntr[3] = system_id[0];
	    ntr[0] = 0x08;
	    ntr[2] = 0x36;
	    ntr[4] = system_id[1];
	    ntr[1] = 0x00;
	    ntr[5] = system_id[2];
#endif
/* HP added here -- MVR -- 7 May 1994 */
#if defined(sun) || defined(sgi) || defined(SCO) || defined(HP_UX)
	    if (gaddr(ea) < 0) {
		goto bl;
	    }

	    /* get the network address */
	    ntr[3] = ea[3];
	    ntr[0] = ea[0];
	    ntr[2] = ea[2];
	    ntr[4] = ea[4];
	    ntr[1] = ea[1];
	    ntr[5] = ea[5];
#endif

	    if (strlen(str) == 14) {
		if (sernoauth(str) == -1)
			goto bl;
	    }
	    /*
	     *  The following code is an obtuse way to do this:
	     *
	     *	if (strcmp(str, gk(prodnumber, ntr, vol))) {
	     *	        delay(3*HZ);
	     *		u.u_error = EACESS;
	     *		return;
	     *	}
	     */

       	    else if (strlen(str) == 19) {
		rt = gk1(prodnumber, ntr, vol);

		for (i=5; i>=0; i--)
		    if (str[i] != rt[i])
			goto bl;
		if (str[19] != rt[19])
		    goto bl;
		if (str[18] != rt[18])
		    goto bl;
		i = 6;
		while (i<18) {
		    if (str[i] != rt[i])
			goto bl;
		    i++;
		}
	    }
	    else {
		rt = gk2(prodnumber, ntr, vol);
		
		for (i=5; i>=0; i--)
		    if (str[i] != rt[i])
			goto bl;
		if (str[20] != rt[20])
		    goto bl;
		if (str[19] != rt[19])
		    goto bl;
		i = 6;
		while (i<19) {
		    if (str[i] != rt[i])
			goto bl;
		    i++;
		}
	    }
	}
	x = chnge(prodflag);
	y = chnge(vol);
	mnabdr = x*x*x + y*y + 1;
	return(0);

/* do this if they gave the wrong key */
bl:     nap(3*HZ);
	errno = EACCES;
	return(-1);
}


main(argc, argv)
int argc;
char *argv[];
{
    extern char *crypt();
    int	 tcnt;
    char *key = getenv("KDATA");
    char *prodnumber = getenv("PRODNUMBER");
    char *flags = getenv("FLAGS");
    char *file = getenv("KF");
    char *version = getenv("PRODVERSION");

    struct nabdri_t ua;
    struct nabdrt_t ut;
    char timestr[32];

    printf (" key=%s\n prodnumber=%s\n flags=%s\n file=%s\n version=%s\n", key,prodnumber,flags,file,version);

    if (key == NULL || prodnumber == NULL || flags == NULL ||
   	 file == NULL || version == NULL) {
	printf("ERROR 1\n");
	exit(1);
    }

    if (*key == '\0' || *prodnumber == '\0' || *flags == '\0' ||
   	 *file == '\0' || *version == '\0') {
	printf("ERROR 2\n");
	exit(1);
    }

    if (argc != 2) {
	printf("ERROR 3\n");
	exit(1);
    }


/*
    sprintf(timestr, "%d", time(0)/2);

    if (strcmp(argv[1], crypt(timestr, "sw"))) {
	printf("ERROR 4\n");
	exit(1);
    }
*/

    ua.gprodnumber = prodnumber;
    ua.gstr = key;
    ua.gprodflag = flags;
    ua.gprodversion = version;

    if ((ua.fd = open(file, O_RDONLY)) < 0) {
	printf("ERROR 6\n");
	exit(1);
    }
    if (nabdrinit(&ua) < 0) {
	printf("ERROR 7\n");
	exit(1);
    }
    else {
	printf("%d\n", mnabdr);
	close(ua.fd);
	exit(0);
    }
}

/** Serialno Authentication **/
int sernoauth(snbr)
char *snbr;
{
     extern int Msnbr_auth(), Esnbr_auth(), Wsnbr_auth();

     int i;
     printf("snbr=%s\n",snbr);
     for (i=0;i<14;++i) {
	printf("%d:%c\n", i, snbr[i]);
     }

#ifdef Sernotest
    char *sernopf = getenv("SERNOTEST");
		if (strcmp(sernopf, "PASS") == 0) {
			return(0); /* Customer ID's match */
		}
		else if (strcmp(sernopf, "FAIL") == 0) {
			return(-1); /* Customer ID's match */
		}
		else {
/*			Just do whatever */
		}
#endif

     printf("sernoauth:snbr=%s\n",snbr);
     if (snbr[0] == 'M' || snbr[0] == 'm') {
	/* Maintenance Serial No. */
	return(Msnbr_auth(snbr));
     }
     else if (snbr[0] == 'E' || snbr[0] == 'e') {
	/* Evaluation Serial No. */
	return(Esnbr_auth(snbr));
     }
     else
	/* Assume Warranty Serial No. */	
	return(Wsnbr_auth(snbr));
}
Msnbr_auth(snbr)
char *snbr;
{
extern int MaintenanceSnbrOK();
/* Authenticate Maintenance Serial No. */
    if (MaintenanceSnbrOK(snbr)) {
        printf("\nMaintenance Serial number is OK.\n\n");
	return(0);
    }
    else {
        printf("\nMaintenance Serial number is corrupt.\n\n");
	return(-1);
    }


#ifdef oldcode
     char serno_cid[81];
     char *cid;
     extern int ExtractCustomerID();
	if (ExtractCustomerID(snbr,serno_cid)) {
		printf("\nCould not extract CustomerID.\n\n");
		return(-1); 
	}
	else {
		cid=getenv("CUSTID");
		if (strcmp(serno_cid, cid) == 0) {
			printf("\nCustomerID match = %s\n",cid);
			return(0); /* Customer ID's match */
		}
		else {
			printf("\nCustomerIDs don't match: cid='%s' --- serno_cid='%s'\n",cid,serno_cid);
			return(-1);
		}
	}
#endif /*oldcode*/
}
int Esnbr_auth(snbr)
char *snbr;
{
/* Authenticate Evaluation Serial No. */
     char *cid;
     EvalSNumberRec *CreateEvalSNumberRec();
     void DeleteEvalSNumberRec();
     void InitEvalSNumberRec();
     int EvalLicAvailable();
	    EvalSNumberRec erec;
	    InitEvalSNumberRec(&erec);
/** Fill in snbr ; customer-id **/
	    strcpy(erec.snbr,snbr);
	    cid=getenv("CUSTID");
	    strcpy(erec.customer,cid);

	    if (EvalLicAvailable(&erec)){
		printf("An evaluation license is available.\n");
		return(0);
	    }
	    else {
		printf("Eval. Serial No. Failure with code %d\n",erec.errcode);
		return(-1);
	    }
}

Wsnbr_auth(snbr)
char *snbr;
{
     extern int WarrantySnbrOK();
	/* Authenticate Warranty Serial No. */	
	if (WarrantySnbrOK(snbr)) {
		printf("\nThis serial number is OK.\n\n");
		return(0);  /* serial number is OK */
	}
	else {
		printf("\nThis serial number has a bad checksum.\n\n");
		return(-1); /* serial number has a bad checksum */
	}
}
