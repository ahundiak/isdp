#include <stdlib.h>
#include <stdio.h>
#include "defs.h"
#include "main.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mtio.h>
#include <unistd.h>
#include <string.h>
#include <utime.h>
#include <errno.h>
#if defined(clipper) || defined(__clipper__)
#include <sys/sysingr.h>
#else
#include <sys/param.h>
#endif

extern short	srcmedia;
extern short	debug;
extern short	passed_prodlist;
extern int	fileloc;
extern char	*net_receive();
extern short	iso_9660;
extern short	foldcase;
extern char	*machine;
extern char	*prodlist;
extern char	*installscript;

#define DIRNAME	"/usr"
#define RING	".cmsdr."

#if (defined(clipper) || defined(__clipper__)) && defined(SVR3)
#define ARCH_MAGIC      0000577
#endif
#if (defined(clipper) || defined(__clipper__)) && defined(SVR4)
#define ARCH_MAGIC      0000577
#endif
#ifdef SunOS_4
#define ARCH_MAGIC	0100403
#endif
#if defined(sun) && defined(SVR4)
#define ARCH_MAGIC	077505
#endif
#ifdef _AIX
#define ARCH_MAGIC	0000737
#endif
#ifdef sgi
#define	ARCH_MAGIC	0000540
#endif

#define SLOT    623691234

unsigned int decode_slot;
extern char	*ldirname;
char    action = INSTALL; /* default action is to install products */
char    basedir[STRSIZ];       /* directory where user wants ws stuff*/
char	mountpoint[STRSIZ];	/* filesys mounted for ws stuff*/
char    sharedfs[STRSIZ];       /* directory to put shared ws stuff*/
char    ws_prodlist[STRSIZ];    /* name of file where prodlist goes*/
char    makenodedir[STRSIZ];    /* directory where products will go for node */
char    makenodelist[STRSIZ];   /* product list name */
char    ws_script[STRSIZ];      /*name of file where script goes*/
char    ws_beta_script[STRSIZ]; /*name of file where beta script goes*/


int	copy_coded_file(infile, outfile, salt)
char *infile;
char *outfile;
unsigned int	salt;
{
        int     inf, outf;
        int     rcount;
	char	*buf, *bp;
        struct utimbuf	times;
	struct stat statbuf;

        if ((inf = open(infile, O_RDONLY)) < 0) {
                return(1);
        }
 
        if (fstat(inf, &statbuf)) {
                close(inf);
                return(1);
        }
 
        if ((outf = creat(outfile, statbuf.st_mode)) < 0) {
                close(inf);
                return(1);
	}
  
	buf = (char *)malloc(62*1024);
	while ((rcount = read(inf, buf, 62*1024)) > 0) {
	    if (salt) {
		for (bp = buf; bp < (buf+rcount); bp += 4)
		    *((unsigned int *)bp) ^= salt;
            }
	    if (write(outf, buf, rcount) != rcount) {
		free(buf);
		close(inf);
		close(outf);
		return(-1);
	    }
	}
	free(buf);
	close(inf);
	close(outf);
        times.actime = statbuf.st_atime;
        times.modtime = statbuf.st_mtime;
        utime(outfile, &times);
        chown(outfile, statbuf.st_uid, statbuf.st_gid);
        if (rcount < 0)
                return(-1);
	return(0);
}

void	get_ring(source_file, dest_file)
char	*source_file;
char	*dest_file;
{
    int	fd;
    unsigned short magic;
	
    if ((fd = open(source_file, O_RDONLY)) < 0)
	return;
    else {
	/* Snip the magic number out of the file */
	read(fd, &magic, sizeof magic);
	close(fd);

	/* If it corresponds to the valid magic number for
         * one of our executables, then copy it directly.
	 * Otherwise, it's been stored in encrypted form,
	 * and we need to decode it as we copy it down.
	 */

	if (magic == ARCH_MAGIC) 
	    copy_file(source_file, dest_file, FALSE, 0);
	else {
	    copy_coded_file(source_file, dest_file, SLOT);
	}
    }
}


/*****************************************************************************
 * Function:		get_prod_list()
 *
 * Purpose:		copy product list from media to /usr/tmp for use
 *
 * Globals used:	srcmedia - delivery media type
 *			fileloc  - place on media
 *
 * Parameter(s):	none
 *
 * Return Value:	0 if successful,
 *			1 if unsuccessful.
 *
 * History:		01/17/91  01.00.00	Initial development
 *****************************************************************************/

int	get_prod_list()
{
    int     retval = 0;
    short   got_prodlist = 0;
    char    srcprodlist[STRSIZ];    /*name of source product list file*/
    char    source_script[STRSIZ];  /*name of source script file*/
    char    source_beta_script[STRSIZ];/*name of source beta script file*/
    char    source_ring[STRSIZ];
    char    ws_ring[STRSIZ];
    char    *envstr;                /*temporary string for environment */
    char    *errstr;		    /*error string for FMU calls*/
    char    *cp;
    char    *tmpprodlist;
    extern  short sssn;

    if (!passed_prodlist)
	prodlist = PRODLIST;

    /* 
     * Define pathnames for product lists and scripts
     */
    sprintf(ws_prodlist, "/usr/tmp/%s", PRODLIST);
    sprintf(ws_script, "/usr/tmp/%s", SCRIPT);
    sprintf(ws_beta_script, "/usr/tmp/%s", BETA_SCRIPT);
    /*
     * force their removal so they're not confused from a previous 
     * delivery....
     */
    unlink(ws_prodlist);
    unlink(ws_script);
    unlink(ws_beta_script);

    envstr = (char *)malloc(strlen(ws_prodlist)+10);
    strcpy(envstr, "PRODLIST=");
    putenv(strcat(envstr, ws_prodlist));

    switch (srcmedia) {
    case TAPE:
	confirm_delivery_tape(prodlist);
	read_file_from_tape(ws_prodlist);
	read_file_from_tape(ws_script);
	putenv("SRCMEDIA=-T");
	break;

    case FLOPPY:
	fileloc = 1;
	sprintf(srcprodlist, "%s/%s", FMNTDIR, prodlist);
	if (copy_file(srcprodlist, ws_prodlist, FALSE, 0)) {
#ifndef VPROD
	    PRINT "Could not copy product list.\n");
#endif
	    retval = 1;
	}
	else {
	    sprintf(source_script, "%s/%s", FMNTDIR, SCRIPT);
	    copy_file(source_script, ws_script, FALSE, 0);
	    putenv("SRCMEDIA=-F");
	}
	break;

    case CDROM:
	sprintf(srcprodlist, "%s/%s", MNTDIR, prodlist);

	if (iso_9660) {
	    /*
	     * First, see if the CD/ROM is able to support access
	     * to file names using lower case letters (this can
	     * be done if both the CD/ROM and the ISO9660 file
	     * system driver support the Rock Ridge Interchange
	     * Protocol, or if the disc has been mastered using
	     * ILLEGAL lower-case file names, or if the file system
	     * driver automatically converts file names to upper
	     * case itself {SunOS}).  If we can't access files using
	     * lower case file names, then set a flag to notify
	     * everyone to fold their CD/ROM file names to upper case.
	     */

	    if (access(srcprodlist, R_OK) != 0) {
		/*
		 * Lower case access failed.  Let's try UPPER CASE.
		 */
		for (cp = srcprodlist + strlen(MNTDIR); *cp; cp++)
		    *cp = toupper(*cp);

		if (access(srcprodlist, R_OK) == 0) {
		    foldcase = UPPER;
		    putenv("FOLDCASE=UPPER");
		}
	    }
	    else {
#if defined(sgi) || defined(SCO)
		foldcase = LOWER;
		putenv("FOLDCASE=LOWER");
#else
		foldcase = 0;
#endif
	    }
	}

	if (debug)
	    PRINT "Trying to access %s\n", srcprodlist);
	if (access(srcprodlist, R_OK)) {
#ifndef VPROD
	    PRINT "Cannot read product list file.\n");
#endif
	    retval = 1;
	}
	else {
	    copy_file(srcprodlist, ws_prodlist, FALSE, 0); 

	    sprintf(source_script, "%s/%s", MNTDIR, SCRIPT);
	    copy_file(source_script, ws_script, FALSE, 0);

#ifdef OLD_LOADKEY_METHOD
	    if (iso_9660) {
		sprintf(source_ring, "%s/%s%s", MNTDIR, RING, machine);
		if (foldcase) {
		    for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
			*cp = (foldcase == UPPER) ? toupper(*cp) : tolower(*cp);
		}
		sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
		unlink(ws_ring);
		get_ring(source_ring, ws_ring);
		chmod(ws_ring, 0500);
	    }
#else
	    /*
	     * We don't need to copy a loadkey verifier off of the product
	     * CD any more.  It's internal to DELTOOLS now.
	     */
#endif

	    putenv("SRCMEDIA=-C");
	}
	break;

    case LOCAL_DIR:
	got_prodlist = 0;
	if (passed_prodlist) {
	    sprintf(srcprodlist, "%s", prodlist);
	    if (copy_file(srcprodlist, ws_prodlist, FALSE, 0)) {
		/*
		 * Didn't work, so strip the directory
		 * pathname off and keep trying with localdir
		 */
		tmpprodlist = prodlist;
		prodlist = strrchr(tmpprodlist, '/');
		if (prodlist == NULL)
		    prodlist = tmpprodlist;
		sprintf(srcprodlist, "%s/%s", ldirname, prodlist);
	    }
	    else
		got_prodlist++;
	}
	else
	    sprintf(srcprodlist, "%s/%s", ldirname, prodlist);

	if (!got_prodlist) {
	    if (copy_file(srcprodlist, ws_prodlist, FALSE, 0)) {
#ifndef VPROD
		PRINT "Can't access local directory.\n");
#endif
#ifndef XFORMS
		cleanup(4);
#else
		return(4);
#endif
		retval = 1;
		break;
	    }
	}
	
	sprintf(source_script, "%s/%s", ldirname, SCRIPT);
	copy_file(source_script, ws_script, FALSE, 0);
	sprintf(source_beta_script, "%s/%s", ldirname, BETA_SCRIPT);
	copy_file(source_beta_script, ws_beta_script, FALSE, 0);
	putenv("SRCMEDIA=-D");
	break;

#ifdef XNS_NET
    case VAX:
	sprintf(srcprodlist, "%s/%s", VAX_DIR, prodlist);
	if (errstr = fmu_receive(srcprodlist, ws_prodlist)) {
	    net_error(NET_READ, errstr, TRUE);
	    cleanup(2);
	    retval = 1;
	}
	else {
	    sprintf(source_beta_script, "%s%s", VAX_SCRIPT_DIR, BETA_SCRIPT);
	    sprintf(source_script, "%s%s", VAX_SCRIPT_DIR, SCRIPT);
	    fmu_receive(source_script, ws_script);
	    fmu_receive(source_beta_script, ws_beta_script);
	    putenv("SRCMEDIA=-V");
	}
	break;

    case WORKSTATION:
	sprintf(srcprodlist, "%s%s", WS_DIR, prodlist);
	if (errstr = fmu_receive(srcprodlist, ws_prodlist)) {
	    sprintf(srcprodlist, "/%s", prodlist);
	    if (errstr = fmu_receive(srcprodlist, ws_prodlist)) {
		net_error(NET_READ, errstr, TRUE);
		cleanup(2);
		retval = 1;
	    }
	}
	if (retval != 1) {
	    sprintf(source_beta_script, "%s%s", WS_DIR, BETA_SCRIPT);
	    sprintf(source_script, "%s%s", WS_DIR, SCRIPT);
	    fmu_receive(source_script, ws_script);
	    fmu_receive(source_beta_script, ws_beta_script);
	    putenv("SRCMEDIA=-W");
	}
	break;
#endif
    case TCPIP:
	got_prodlist = 0;
	if (net_get_server_version()) {
	    cleanup(2);
	    retval = 1;
	}
	else {
	    if (passed_prodlist) {
		/* User passed their own prodlist in.
		 * Try it as an absolute path first
		 */
		sprintf(srcprodlist, "%s", prodlist);
		if (errstr = net_receive(srcprodlist, ws_prodlist, 0)) {
		    /* Didn't work, so strip the directory
		     * pathname off and keep trying with WS_DIR
		     * and "/"
		     */
		    tmpprodlist = prodlist;
		    prodlist=strrchr(tmpprodlist, '/');
		    if (prodlist == NULL)
			prodlist = tmpprodlist;
		    sprintf(srcprodlist, "%s%s", WS_DIR, prodlist);
		}
		else
		    got_prodlist++;
	    }
	    else
		sprintf(srcprodlist, "%s%s", WS_DIR, prodlist);

	    if (!got_prodlist) {
		if (errstr = net_receive(srcprodlist, ws_prodlist, 0)) {
		    sprintf(srcprodlist, "/%s", prodlist);
		    if (errstr = net_receive(srcprodlist, ws_prodlist, 0)) {
			net_error(NET_READ, errstr, TRUE);
			cleanup(2);
			retval = 1;
		    }
		}
	    }
	    if (retval != 1) {
		sprintf(source_script, "%s%s", WS_DIR, SCRIPT);
		if (net_receive(source_script, ws_script, 0)) {
		    sprintf(source_script, "/%s", SCRIPT);
		    net_receive(source_script, ws_script, 0);
		}
		sprintf(source_beta_script, "%s%s", WS_DIR, BETA_SCRIPT);
		net_receive(source_beta_script, ws_beta_script, 0);
		putenv("SRCMEDIA=-N");
	    }
	}
	break;

    case NETCDROM:
	if (net_get_server_version()) {
	    cleanup(2);
	    retval = 1;
	}
	else {
	    sprintf(srcprodlist, "%s/%s", MNTDIR, prodlist);
	    if (errstr = net_receive(srcprodlist, ws_prodlist, 0)) {
		net_error(NET_READ, errstr, TRUE);
		cleanup(2);
		retval = 1;
	    }
	    else {
		sprintf(source_script, "%s/%s", WS_DIR, SCRIPT);
		if (net_receive(source_script, ws_script, 0)) {
		    sprintf(source_script, "/%s", SCRIPT);
		    if (net_receive(source_script, ws_script, 0)) {
			sprintf(source_script, "%s/%s", MNTDIR, SCRIPT);
			net_receive(source_script, ws_script,0);
		    }
		}
		sprintf(source_beta_script, "%s%s", WS_DIR, BETA_SCRIPT);
		net_receive(source_beta_script, ws_beta_script, 0);
		net_get_load_key_file();
	        if (sssn)
		    net_get_sn_file();
		putenv("SRCMEDIA=-R");
	    }
	}
	break;

    default:
#ifndef VPROD
	PRINT "Illegal media type.\n");
#endif
	retval = 1;
	break;
    }
    return(retval);
}


/*****************************************************************************
 * Function:		cleanup
 *
 * Purpose:		perform appropriate cleanup after a failure to
 *			perform an installation from a device.
 *
 * Globals used:	srcmedia - delivery media type
 *
 * Parameter(s):	code - exit code
 *
 * Return Value:	not useful
 *
 * History:		01/17/91  01.00.00	Initial development
 *****************************************************************************/

int	cleanup(code)
int	code;
{
    int     i;
    extern short    fsmounted;
    char ws_ring[STRSIZ];
#ifdef sgi
    char command[STRSIZ];
#endif

    switch (srcmedia) {
    case TAPE:
#ifndef _AIX
	    tape_op(MTREW, 1, 0); /* rewind the tape */
#else
	    tape_op(STREW, 1, 0); 
#endif
	    close_tape();
	    break;

    case FLOPPY:
#ifdef SunOS_4
	    unmountfs(FMNTDIR);
#else
	    umount(FLOP_DEVICE);
#endif
	    break;

    case CDROM:
	    sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
	    if (!fsmounted) {
#ifdef SunOS_4
		if ((unmountfs(MNTDIR) < 0) && (errno != EINVAL))
			perror("Unmount of /dev/sr0 failed");
#else
#  ifdef sgi
		sprintf(command, "/etc/umount %s", CDROM_DEVICE);
		system(command);
#  else
		if ((umount(CDROM_DEVICE) < 0) && (errno != EINVAL))
			perror("Umount of /dev/dsk/cdrom failed") ;
#  endif
#endif
	    }
	    if (access(ws_ring, F_OK) == 0)
	      unlink(ws_ring);
	    break;
#ifdef XNS_NET
    case WORKSTATION:
    case VAX:
	fmu_disconnect();
	break;
#endif
    case NETCDROM:
    case TCPIP:
	net_disconnect();
	break;
    }

    sync(); sync();

#if defined(clipper) || defined(__clipper__)
    for (i = 3; i < _NFILE; ++i)
	close(i);
#else
    for (i = 3; i < NOFILE; i++)
	close(i);
#endif

    return(code);
}


/*
 * This subroutine is invoked whenever any signals that would normally
 * result in termination are detected. It will close any open files
 * and, if installing from floppy, attempt to unmount the floppy file
 * system. At any rate, this guy calls exit(2) and we are done.
 */
void	terminate(status)
int	status;
{
	int	i;
	extern short	fsmounted;
	char ws_ring[STRSIZ];
#ifdef sgi
	char command[STRSIZ];
#endif

	switch (srcmedia) {
	case TAPE:
#ifndef _AIX
		tape_op(MTREW, 1, 0); /* rewind the tape */
#else
		tape_op(STREW, 1, 0); 
#endif
		close_tape();
		break;

	case FLOPPY:
#ifdef SunOS_4
		unmountfs(FMNTDIR);
#else
		umount(FLOP_DEVICE);
#endif
		break;

	case CDROM:
		sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
		if (!fsmounted) {
#ifdef SunOS_4
		    if ((unmountfs(MNTDIR) < 0) && (errno != EINVAL))
			perror("Unmount of /dev/sr0 failed");
#else
#  ifdef sgi
		    sprintf(command, "/etc/umount %s", CDROM_DEVICE);
		    system(command);
#  else
		    if ((umount(CDROM_DEVICE) < 0) && (errno != EINVAL))
			perror("Umount of /dev/dsk/cdrom failed") ;
#  endif
#endif
		}
		if (access(ws_ring, F_OK) == 0)
			unlink(ws_ring);
		break;

#ifdef XNS_NET
	case WORKSTATION:
	case VAX:
		fmu_disconnect();
		break;
#endif
	case NETCDROM:
	case TCPIP:
		net_disconnect();
		break;
	}

	sync(); sync();

#if defined(clipper) || defined(__clipper__)
	for (i = 3; i < _NFILE; ++i)
		close(i);
#else
	for (i = 3; i < NOFILE; ++i)
		close(i);
#endif

	exit(status);
}

