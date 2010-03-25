#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <search.h>
#include <ftw.h>
#include <errno.h>
#include <string.h>
#include <dirent.h>
#ifdef SVR3
#include <sys/statfs.h>
#include <sys/fstyp.h>
#  if defined(clipper) || defined(__clipper__)
#    include <sys/sysclip.h>
#  endif
#endif
#ifdef sgi
#  include <sys/syssgi.h>
#endif
#ifdef SVR4
#  include <sys/statvfs.h>
#  include <sys/fstyp.h>
#  include <sys/fsid.h>
#  ifndef sgi
#  include <sys/stropts.h>
#  include <sys/ethernet.h>
#  include <sys/dlpi.h>
#  endif
#endif
#ifdef SunOS_4
#  include <sys/vfs.h>
#  include <sys/param.h>
#  include <sys/socket.h>
#  include <sys/sockio.h>
#  include <sys/time.h>
#  include <net/if.h>
#  include <net/nit_if.h>
#  include <netinet/in.h>
#  include <netinet/if_ether.h>
#  include <stropts.h>
#endif
/* ifdef HP added for HP port -- MVR 7 May 1994 */
#ifdef HP_UX
#include <sys/vfs.h>
#include <sys/netio.h>
#endif
#ifdef _AIX
#  include <sys/statfs.h>
#  include <sys/device.h>
#  include <sys/devinfo.h>
#  include <sys/ioctl.h>
#  include <sys/comio.h>
#  include <sys/entuser.h>
#endif
#ifdef OSF
#  include <sys/mount.h>
#endif

#ifndef CDROM_DEVICE
#  if defined(clipper) || defined(__clipper__)
#    define CDROM_DEVICE	"/dev/dsk/cdrom"
#  endif
#  ifdef SunOS_4
#    define CDROM_DEVICE	"/dev/sr0"
#  endif
/* HP added here -- MVR 7 May 1994 */
#  ifdef HP_UX
#    define CDROM_DEVICE        "/dev/dsk/cdrom"
#  endif
#  if defined(sun) && defined(SVR4)
#    if defined(sparc)
#      define CDROM_DEVICE	"/dev/dsk/c0t6d0s2"
#    else
#      define CDROM_DEVICE	"/dev/dsk/cdrom"
#    endif
#  endif
#  ifdef _AIX
#    define CDROM_DEVICE	"/dev/cd0"
#  endif
#  ifdef sgi
#    define CDROM_DEVICE	"/dev/dsk/cdrom"
#  endif
#  ifdef SCO
#    define CDROM_DEVICE	"/dev/cd0"
#  endif
#endif

#ifdef SCO 
#include <sys/ioctl.h> 
#include <sys/macstat.h>
#include <sys/stropts.h>
#endif

/* HP added in the folowing list -- MVR 7 May 1994 */
#if defined(SVR3) || defined(_AIX) || defined(SunOS_4) || defined(HP_UX)
#  define BASEDIR	"/usr/ip32"
#  define KEYSPATH	"/deltools/keys"
#endif
#ifdef SVR4
#  ifdef NEWDIRS
#    ifdef sun
#      define BASEDIR	"/opt/ingr"
#    endif
#    ifdef sgi
#      define BASEDIR	"/var/opt/ingr"
#    endif
#    define KEYSPATH	"/deltools/keys"
#  else
#    define BASEDIR	"/usr/ip32"
#    define KEYSPATH	"/deltools/keys"
#  endif
#endif

extern char	*get_profile();
int		total_recs = 0;
char		eid[7];				/* last part of eid       */
char		*ingrhome = BASEDIR;



#ifdef SVR3
int strncasecmp(s1, s2, n)
const char *s1, *s2;
int n;
{
    n++;
    while (--n > 0 && tolower(*s1) == tolower(*s2++))
	if (*s1++ == '\0')
		return(0);

    return ((n == 0) ? 0 : (tolower(*s1) - tolower(*--s2)));
}
#endif

#if defined(clipper) || defined(__clipper__)
int get_ether_id(eid)
char eid[];
{
    unsigned char	addr[6];		/* hold result of sysid   */

    sysid(addr);
    sprintf(eid, "%02x%02x%02x", addr[3], addr[4], addr[5]);
    return(0);
}
#endif

/* HP method of getting the ethernet address. The method used is to scan
 * through the lanX devices till we get the first device which responds.
 * Then  we get the ethernet adderss associated with it throgh a ioctl
 * call. -- MVR 7 May 1994
*/

#ifdef HP_UX
int get_ether_id(eid)
char eid[];
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
        sprintf(eid,"%02x%02x%02x", arg.value.s[3], arg.value.s[4], arg.value.s[
5]);        return 0;
}

#endif /* HP_UX */

#ifdef sgi
int get_ether_id(eid)
char eid[];
{
    char	sysid[MAXSYSIDSIZE];

    syssgi(SGI_SYSID, sysid);
    sprintf(eid, "%02x%02x%02x", sysid[1], sysid[2], sysid[3]);
    return(0);
}
#endif
#ifdef sun 
#  ifdef SunOS_4
/* 
 * SunOS 4.x method of obtaining Ethernet address
 */

int get_ether_id(eid)
char eid[];
{
    int			nfd;
    int			if_index = 0, success = 0;
    struct strioctl	si;
    struct ifreq	ifr;
    static char		*interfaces[] = { "le0", "ie0", "" };
	

    /* Open the Streams NIT clone device */
    if ((nfd = open("/dev/nit", O_RDONLY)) < 0) {
	return(-1);
    }
    
    memset((char *)&si, 0, sizeof(struct strioctl));
    memset((char *)&ifr, 0, sizeof(struct ifreq));

    /* Bind the network connection to the Ethernet transport */
    while (!success && *interfaces[if_index]) {
	strncpy(ifr.ifr_name, interfaces[if_index], sizeof ifr.ifr_name);
	ifr.ifr_name[sizeof ifr.ifr_name - 1] = '\0';
	si.ic_cmd = NIOCBIND;
	si.ic_len = sizeof ifr;
	si.ic_dp = (char *)&ifr;
	if (ioctl(nfd, I_STR, (char *)&si) < 0) {
	    if (errno == ENXIO) {
		/*
		 * Bind failed because interface did not exist.
		 * Try the next one.
		 */
		if_index++;
		continue;
	    }
	    else {
		/*
		 * Failed for unknown reason.
		 * Get out.
		 */
		close(nfd);
		return(-1);
	    }
	}
	else
	    success = 1;
    }

    if (!success) {
	close(nfd);
	return(-1);
    }

    /* Now ask the connection for the Ethernet address */
    if (ioctl(nfd, SIOCGIFADDR, &ifr) < 0) {
	close(nfd);
	return(-1);
    }

    sprintf(eid, "%02x%02x%02x",
	    ifr.ifr_addr.sa_data[3] & 0xff,
	    ifr.ifr_addr.sa_data[4] & 0xff,
	    ifr.ifr_addr.sa_data[5] & 0xff);
    close(nfd);
    return(0);
}
#  else
/*
 * SVR4 Method of getting the hardware ethernet address using DLPI
 */
int get_ether_id(eid)
char eid[];
{
    int				nfd, flags, i;
    FILE			*lfd;
    unsigned char		eaddr[8];
    struct strbuf		ctlbuf;
    dl_attach_req_t		attach_req;
    dl_phys_addr_req_t		address_req;
    union DL_primitives		rcvbuf;
    char			*ingrhome, *c;
    char			iflist[256], netif[80];
    static char *interfaces[] = { "/dev/le",
                                  "/dev/ie",
                                  "/dev/el",
                                  "/dev/elx",
                                  "" };

    ingrhome = getenv("INGRHOME");
    if (ingrhome == NULL || *ingrhome == '\0')
	ingrhome = BASEDIR;

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

    /*
     * Send DL_ATTACH_REQ to attach to an instance number
     */
    attach_req.dl_primitive = DL_ATTACH_REQ;
    attach_req.dl_ppa = 0;                      /* Attach to instance 0 */

    ctlbuf.len = DL_ATTACH_REQ_SIZE;
    ctlbuf.buf = (char *)&attach_req;
    if (putmsg(nfd, &ctlbuf, NULL, 0) < 0) {
	perror("ATTACH_REQ putmsg() failed");
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
	perror("getmsg() failed");
	close(nfd);
	return(-1);
    }
    switch (rcvbuf.dl_primitive) {
    case DL_OK_ACK:
	/* Primitive acknowledged */
	break;
    case DL_ERROR_ACK:
	/* Get error information */
	fprintf(stderr, "ERROR: DL_ATTACH_REQ failed.\n");
	fprintf(stderr, "Primitive code:  %d\n",
		rcvbuf.error_ack.dl_errno);
	fprintf(stderr, "DLPI errno:  %d\n",
		rcvbuf.error_ack.dl_unix_errno);
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
	perror("PHYS_ADDR_REQ putmsg() failed");
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
	perror("getmsg() failed");
	close(nfd);
	return(-1);
    }
    switch (rcvbuf.dl_primitive) {
    case DL_PHYS_ADDR_ACK:
	/* Get information out of structure */
	memcpy(eaddr, ctlbuf.buf + rcvbuf.physaddr_ack.dl_addr_offset,
			    rcvbuf.physaddr_ack.dl_addr_length);
	sprintf(eid, "%02x%02x%02x",
		eaddr[3] & 0xff, eaddr[4] & 0xff, eaddr[5] & 0xff);
	break;
    case DL_OK_ACK:
	/* Primitive acknowledged */
	break;
    case DL_ERROR_ACK:
	/* Get error information */
	fprintf(stderr, "ERROR: DL_PHYS_ADDR_REQ failed.\n");
	fprintf(stderr, "Primitive code:  %d\n",
		rcvbuf.error_ack.dl_errno);
	fprintf(stderr, "DLPI errno:  %d\n",
		rcvbuf.error_ack.dl_unix_errno);
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
	perror("DETACH_REQ putmsg() failed");
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
	perror("getmsg() failed");
	close(nfd);
	return(-1);
    }
    switch (rcvbuf.dl_primitive) {
    case DL_OK_ACK:
	/* Primitive acknowledged */
	break;
    case DL_ERROR_ACK:
	/* Get error information */
	fprintf(stderr, "ERROR: DL_DETACH_REQ failed.\n");
	fprintf(stderr, "Primitive code:  %d\n",
		    rcvbuf.error_ack.dl_errno);
	fprintf(stderr, "DLPI errno:  %d\n",
		    rcvbuf.error_ack.dl_unix_errno);
	break;
    }
    close(nfd);
    return(0);
}
#  endif
#endif

#ifdef _AIX
int get_ether_id(eid)
char eid[];
{
    int		nfd;
    struct devinfo	di_blk;

    nfd = open("/dev/ent0", O_RDONLY);

    if (ioctl(nfd, IOCINFO, &di_blk) < 0) {
	perror("Ioctl failed.");
	return(-1);
    }

    sprintf(eid, "%02x%02x%02x",
	 di_blk.un.ethernet.haddr[3] & 0xff,
	 di_blk.un.ethernet.haddr[4] & 0xff,
	 di_blk.un.ethernet.haddr[5] & 0xff);

    return(0);
}
#endif
#ifdef SCO
/*++ jhb 14/may/93 : AST/SCO changes. ++*/
/*
** SCW  17 NOV 1994
**
** With other kinds of systems supporting SCO now,
** we can't rely on /dev/i3B0 like we used to on AST
** systems.  So we'll use a "table" approach like
** we do for Intel Solaris.
*/
int get_ether_id(eid)
char eid[];
{
    int                         nfd, i;
    struct strioctl		gea;
    unsigned char		addr[6];
    FILE			*lfd;
    char			*iflist, *c;
    char			netif[80];
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
    gea.ic_dp=addr;
    if (( ioctl(nfd,I_STR,&gea)) < 0) {
	perror("ioctl error");
	close(nfd);
    }
    close(nfd);
    sprintf(eid, "%02x%02x%02x", addr[3], addr[4], addr[5]);
    return(0);
}
#endif



#ifdef sgi
/*
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
 * We still assume that the CD-ROM is mounted on /del (it worked
 * for finding the .pfdb file, so we'll stick with it).
 */

char *get_release_date(fd)
int fd;
{
    static char rdate[7];
    char vbuf[1024];
    int fd1;
    char *c;

    memset(rdate, 0, 7);

    /*
     * check for the volume file, if not there then exit quietly
     */
    if (access("/del/volume", R_OK) == 0) {
	fd1 = open("/del/volume", O_RDONLY);
	if (fd1 < 0)
	    return("");
    }
    else if (access("/del/VOLUME", R_OK) == 0) {
	fd1 = open("/del/VOLUME", O_RDONLY);
	if (fd1 < 0)
	    return("");
    }
    else
	return("");

    /*
     *  Alright, now we've got the file open.
     *  Read the data, which is formatted as:
     *
     *  {Disc Title}#{Disc Date}#{Volume label}#{FMDA part number}
     */
    if (read (fd1, vbuf, 1024) < 0) {
	close(fd1);
	return("");
    }
    close(fd1);

    /*
     * Now, with the magic of strtok(), find the third field.
     */
    c = (char *)strtok(vbuf, "#");	/* Field 1 */
    c = strtok(NULL, "#");		/* Field 2 */
    c = strtok(NULL, "#");		/* Field 3 */

    if (c == NULL)
	return ("");
    else
	memcpy(rdate, c, 6);

    return(rdate);
}
#else /* not sgi */
# ifndef NEWSTYLE 
/*
 *  This is the way getting the release date of the CD-ROM has been
 *  done since "the old days", with additional stuff for ISO9660 CDs.  
 *
 *  For old Intergraph FFS CD-ROMs, you can just do a "statfs()" on
 *  the directory where the CD-ROM is mounted, then get the f_pack
 *  data.  (Assumption -- there's only one CD-ROM on the system, and
 *  it's mounted at "/del".)
 *
 *  For ISO9660 CD-ROMs it's not so simple, because statfs() doesn't
 *  doesn't get the volume description.  It's stuck in an area of the
 *  CD-ROM that you have to read manually (47 bytes into the 16th
 *  block on the CD).
 */
char *get_release_date(fd)
int fd;
{
    static char rdate[7];
# ifndef SVR4
    struct statfs statbuf;			/* file system  structure */
# else /*SVR4*/
    struct statvfs statbuf;			/* file system  structure */
# endif /*SVR4*/
    char answer[128];
    int fd2, result;

# if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
    statfs("/del", &statbuf, sizeof(struct statfs), 0);
    result = sysfs(GETFSTYP, statbuf.f_fstyp, answer);
    if ((strncmp(answer, "CDFS", 4) == 0) && (result == 0)) {
	/*
	 * Drag ISO9660 by its nose to look at the volume label
	 */
#  ifdef SYSV
	memset(rdate, 0, 7);
#  else  /*SYSV*/
	bzero(rdate, 7);
#  endif /* SYSV */
	fd2 = open(CDROM_DEVICE, O_RDONLY);
	lseek(fd2, (16*2048)+47, 0);
	read(fd2, rdate, 6);
	close(fd2);
    }
    else {
	/*
	 * Since it's not an ISO9660 CDROM, we can fstatfs it
	 */
	fstatfs(fd, &statbuf, sizeof(struct statfs), 0);
	strncpy(rdate, statbuf.f_fpack, 7);
    }
#  else /* !__clipper__ */
    /* 
     * Drag ISO9660 by its nose to look at the volume label
     */
#  ifdef SYSV
    memset(rdate, 0, 7);
#  else  /* SYSV */
    bzero(rdate, 7);
#  endif /* SYSV */
    fd2 = open(CDROM_DEVICE, O_RDONLY);
    lseek(fd2, (16*2048)+47, 0);
    read(fd2, rdate, 6);
    close(fd2);
#  endif /* __clipper__ */
    return(rdate);
}
# else /* NEWSTYLE */

/*
 * Trying this a different way...  (to get ready for systems with
 * multiple CD-ROMs mounted on them).  We can't assume that the
 * device that has the CD-ROM is the "one true" CD-ROM device node
 * on the system, or that it's mounted on "/del".
 *
 * "fd" is a file descriptor for the open "pfdb" file, which was opened
 * in the main() routine.  We can do an fstat() on the file to get the
 * dev_t information for the file (the device that has the file).
 * Then we can make a temporary device node from that information and
 * use it to get the volume date.
 *
 * This will all be much easier when delivery starts putting release
 * date information in a FILE on the CD-ROM instead of burying it.
 */

char *get_release_date(fd)
int fd;
{
    static char rdate[7];
#  ifndef SVR4
    struct statfs statbuf;			/* file system  structure */
#  else /* SVR4 */
    struct statvfs statbuf;			/* file system  structure */
#  endif /* SVR4 */
    struct stat sbuf;
    char cmd[128], answer[128];
    char devnm[32];
    int fd2, result;

    sprintf(devnm, "/tmp/dev.%d", getpid());
    fstat(fd, &sbuf);
    unlink(devnm);
    mknod(devnm, S_IFBLK | (0700), sbuf.st_dev);
#  ifdef SYSV
    memset(rdate, 0, 7);
#  else
    bzero(rdate, 7);
#  endif /* SYSV */
    fd2 = open(devnm, O_RDONLY);
    lseek(fd2, (16*2048)+47, 0);
    read(fd2, rdate, 6);
    close(fd2);
    unlink(devnm);
    return(rdate);
}
# endif /* NEWSTYLE */
#endif /* sgi */

/*
 * This routine compares two CD-ROM volume labels.  It returns 0 if
 * the volume labels are the same date; otherwise it returns <0 if
 * the first label is "earlier" than the second and >0 if the first
 * label is "later" than the second.
 *
 *  Assumptions:        the two labels are six digit strings in the
 *                      form mmddyy
 */
int     labelcmp(s1, s2)
char    *s1, *s2;
{
        char    ns1[7], ns2[7];

        /*
         * If we rearrange the strings so they're in the form
         * yymmdd instead of mmddyy, we can compare them directly.
         * That way, 931231 really IS less than 940101.
         *
         * (If you try to compare them without rearranging, you
         *  get bad results:  010194 < 123193...)
         */
        ns1[0] = *(s1+4);       ns2[0] = *(s2+4);
        ns1[1] = *(s1+5);       ns2[1] = *(s2+5);
        memcpy(ns1+2, s1, 4);
        memcpy(ns2+2, s2, 4);
        ns1[6] = '\0';
        ns2[6] = '\0';

        return(strncmp(ns1, ns2, 6));
}



int process_pfdb(path, statbuf, ftype)
char *path;
struct stat *statbuf;
int ftype;
{
    int		fd1;				/* file descriptor        */
    char	*c;
    char	keyfile[128];			/* file path name         */
    char	*keydir;			/* dir path name         */
    char	*profile;			/* customer's profile     */
    FILE	*fileptr;			/* file stuff             */

    /*
     * If it's not a file, get out.
     */
    if (ftype != FTW_F)
	return(0);

    /*
     * If the file name isn't in the format
     * .pfdb*, get out.
     */ 

    if (strncmp(path, "/del/.pfdb", 10) && strncmp(path, "/del/.PFDB", 10))
	return(0);

    if (access(path, R_OK) == 0) {
	fd1 = open(path, O_RDONLY);
	if (fd1 < 0) {
	    return(0);
	}
    }
    else {
	/*
	 * Try folding it to uppercase
	 */
	for (c = (path+5); *c; c++)
	    *c = toupper(*c);

	if (access(path, R_OK) == 0) {
	    fd1 = open(path, O_RDONLY);
	    if (fd1 < 0) {
		return(0);
	    }
	}
    }

    /*
     * Append profile data to the existing keyfile.
     */

    putchar('.');
    fflush(stdout);

    profile = get_profile(fd1, strtol(eid, (char **)NULL, 16));
    if (fd1)
    	close(fd1);

    if (profile != NULL) {
	sprintf(keyfile, "%s%s/keyfile", ingrhome, KEYSPATH);

	if ((fileptr = fopen(keyfile, "r"))) {
	    /*
	     * append data to file.
	     */
	    fclose(fileptr);
	    kf_append(keyfile, profile);
	} else {
	    /*
	     * make sure the keys directory exists
	     */
	    keydir = malloc(strlen(ingrhome) + strlen(KEYSPATH) + 1);
	    strcpy(keydir, ingrhome);
	    strcat(keydir, KEYSPATH);

	    if (access(keydir, 7))
		mkdir(keydir, 0755);

	    /*
	     * put profile in a file
	     */
	    if (!(fileptr = fopen(keyfile, "w")))
		exit(2);
	    fputs(profile, fileptr);
	    fclose(fileptr);
	}
	free(profile);
    }
    return(0);
}



main(argc, argv)
int argc;
char *argv[];
{
    int		i;
    char	*c, *eidinput;
    char	keyfile[128];			/* file path name         */
    struct stat	statbuf;
    DIR		*dirp;
    struct dirent	*dp;
    char	dbname[128];

    if (argc < 2) {
	/*
	 * get the network address
	 */
	if (get_ether_id(eid) < 0) {
	    fprintf(stderr, "Could not obtain system ethernet address.\n");
	    exit(1);
	}
    }
    else {
	/*
	 * Use address passed in on command line
	 */
 	eidinput = argv[1];
	c = argv[1];
	if (strchr(eidinput, '-') != NULL) {
	    /*
	     * Skip forward three dashes, then copy info into "eid"
	     */
	    for (i = 0; i < 3; i++) {
		c = strchr(c, '-');
		if (c) 
		    c++;
		else {
		    fprintf(stderr, "Invalid format for ethernet address\n");
		    exit(1);
		}
	    }

	    for (i = 0; i < 6; i++) {
		if (isxdigit(*c))
		    eid[i] = *c++;
		else {
		    fprintf(stderr, "Invalid format for ethernet address\n");
		    exit(1);
		}
		if (i == 1 || i == 3) {
		    if (*c == '-')
			c++;
		    else {
			fprintf(stderr, "Invalid format for ethernet address\n");
			exit(1);
		    }
		}
	    }
	}
	else if (strchr(eidinput, ':') != NULL) {
	    /*
	     * Skip forward three colons, then copy info into "eid"
	     */
	    for (i = 0; i < 3; i++) {
		c = strchr(c, ':');
		if (c)
		    c++;
		else {
		    fprintf(stderr, "Invalid format for ethernet address\n");
		    exit(1);
		}
	    }

	    for (i = 0; i < 6; i++) {
		if (isxdigit(*c))
		    eid[i] = *c++;
		else {
		    fprintf(stderr, "Invalid format for ethernet address\n");
		    exit(1);
		}
		if (i == 1 || i == 3) {
		    if (*c == ':')
			c++;
		    else {
			fprintf(stderr, "Invalid format for ethernet address\n");
			exit(1);
		    }
		}
	    }
	}
	else {
	    for (i = 0; i < 6; i++) {
		if (isxdigit(*c))
		    eid[i] = *c++;
		else {
		    fprintf(stderr, "Invalid format for ethernet address\n");
		    exit(1);
		}
	    }
	}
	eid[6] = 0;
    }

#if defined(SVR4) && defined(NEWDIRS)
    if ((c = (char *)getenv("INGRHOME")) && *c) {
	ingrhome = c;
	c = strchr(ingrhome, ':');
	if (c)
	    *c = '\0';
    }
#endif

    printf("Extracting load keys from CD-ROM...");
    fflush(stdout);

    /*
     * 94/03/11		SCW
     * 
     * "Pity us," the people in software distribution cried,
     * "the database is growing too big for our tools to be
     * able to sort it!  We have to split it into several
     * files!"
     * 
     * Their plan:  split the databases along platform code.
     *			(01, 05, 0H, 0J, 0L, etc.)
     *
     * The kicker:  Just because I am running on a CLIPPER
     *              system doesn't mean I won't have loadkeys
     *              for SCO or Sun or SGI products.  (Cross-platform
     *		    delivery nodes, don'tcha know?)
     *
     * The result:  We must find EVERY SINGLE file in /del that
     *              looks like ".pfdb??" and process it.
     *
     */

#ifdef USE_FTW
    ftw ("/del", process_pfdb, 0); 
#else
    dirp = opendir("/del");
    if (dirp != NULL) {
        while ((dp = readdir(dirp)) != NULL) {
            if (!strncasecmp(dp->d_name, ".pfdb", 5)) {
		strcpy(dbname, "/del/");
		strcat(dbname, dp->d_name);
		stat(dbname, &statbuf);
		process_pfdb(dbname, &statbuf, FTW_F);
            }
        }
        closedir(dirp);
    }
#endif

    printf("\n%d records extracted from database.\n", total_recs);

    /*
     * If the keyfile exists and we know that we've retrieved
     * keys this time around, then do a sort/merge on the resulting
     * table so it's in prod number order, and duplicate entries
     * are removed.
     */
    sprintf(keyfile, "%s%s/keyfile", ingrhome, KEYSPATH);
    if ((access(keyfile, R_OK) == 0) && total_recs)
	kf_sort();

    exit(0);
}

/*
 * this procedure appends the keys extracted this time around
 * to the existing keyfile.
 */

kf_append(keyfile, buff)
char	*keyfile;	/* deltools/keys file       */
char	*buff;		/* pointer to the customer profile         */
{
	FILE	*fileptr;

	/*
	 * Append our profile to the current file. Then re-read it and remove
	 * duplicate entries (by product number). This has the added effect of
	 * keeping any user's pre-defined keys.
	 */
	fileptr = fopen(keyfile, "a");
	if (fileptr == NULL) {
	    fprintf(stderr, "\nERROR: Cannot update %s: ", keyfile);
	    perror("");
	}
	else {
	    fputs(buff, fileptr);
	    fclose(fileptr);
	}

}


/*
 * This procedure performs a sort/merge on the resulting keyfile
 * so entries are listed in order of product number, AND duplicate
 * entries are deleted.
 */

kf_sort()
{
	char	oldfile[256], keyfile[256];
	struct stat	statbuf;
	char	command[512];
	int	retval;

	printf("Sorting / Merging load key table...\n");

	sprintf(oldfile, "%s%s/kf.old", ingrhome, KEYSPATH);
	sprintf(keyfile, "%s%s/keyfile", ingrhome, KEYSPATH);

	stat(keyfile, &statbuf);
        rename(keyfile, oldfile);

	sprintf(command, "sort -u +0 -1 %s > %s", oldfile, keyfile);
	retval = system(command) >> 8;

	if (retval == 0) {
	    chmod(keyfile, statbuf.st_mode);
	    chown(keyfile, statbuf.st_uid, statbuf.st_gid);
		
	    unlink(oldfile);
	    printf("Sort / Merge complete.\n");
	}
	else {
	    rename (oldfile, keyfile);
	    printf("Sort / Merge was unsuccessful.\n");
	    printf("The load key file may contain some duplicated entries.\n");
	}
}
