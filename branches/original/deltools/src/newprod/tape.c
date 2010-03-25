#include	<stdlib.h>
#include	<stdio.h>
#include	<fcntl.h>
#include	<sys/types.h>
#include	<sys/ioctl.h>
#include	<errno.h>
#if defined(_AIX) || defined(SCO)
#  include	<sys/tape.h>
#else
#  include	<sys/mtio.h>
#endif
#include	"defs.h"

#define PRODHEADERMAGIC	"PRODUCT HEADER"
#define TAPEHEADERMAGIC	"Intergraph Workstation Delivery Tape"

int	tapef;		/*file id for the tape device in case of tape delivery*/
int	fileloc;	/*current file (beginning of) location of tape head*/
char	tapeversion;	/* version code char 'e', 'A' - 'Z' of tape format */

extern	void	terminate();
extern char	*tape_device;
extern short	debug;

#define	blocksize	8192 /* used to be 512 - 31-MAR-1989 bpm */

/*
 * This routine makes the shell environment variable GETTAPEFILE to be used by
 * install scripts. This way install scripts can be independent of the BLOCKING
 * factor at which the tape was cut. Also, an environment variable SKIPTAPEFILE
 * is formed. The variable TAPEDEV is the device spec for the tape device used.
 */
void	get_tape_file()
{
	char	*envstr;
	int	td_len;

	td_len = strlen(tape_device);

	envstr = (char *)malloc(td_len + 9);
	sprintf(envstr, "TAPEDEV=%s", tape_device);
	putenv(envstr);

	putenv("SKIPTAPEFILE=mt fsf"); /* mt -f tapedev not working!! */

	envstr = (char *)malloc(td_len + 35);
	sprintf(envstr, "GETTAPEFILE=dd if=%s", tape_device);
	putenv(envstr);
}

/*
 * read the /tmp/.tapeloc file. Set by installation scripts.
 */
int	loc_read()
{
	int	f;
	FILE	*loc;

	f = 0;
	if ((loc = fopen("/tmp/.loc", "r"))) {
		fscanf(loc, "%d", &f);
		fclose(loc);
	}
	return(f);
}

/*
 * write the /tmp/.tapeloc file for use by installation scripts.
 */
void	loc_write(f)
int	f;
{
	FILE	*loc;

	if ((loc = fopen("/tmp/.loc", "w"))) {
		fprintf(loc, "%d\n", f);
		fclose(loc);
	}
}

/*
 * Simply opens the tape device for read only access.
 * Returns negative value upon failure. Also, sets the current fileloc value.
 */
int	open_tape()
{
	int	i;
	
	sleep(1);

	for (i=0; i < 10; ++i) {
		if ((tapef = open(tape_device, O_RDONLY)) >= 0)
			break;
		/*
		 * Pause here.  If tape was busy, give it a bit more
		 * time to get un-busy.
		 */
		if (errno == EBUSY && debug)
		    PRINT "Tape busy.  Waiting 1 second before retry.\n");
		sleep(1);
	}
	fileloc = loc_read();
	return(tapef);
}

/*
 * Close the tape drive and free it for install.sh access. Write the current
 * file location to /tmp/.tapeloc for use by installation scripts.
 */
void	close_tape()
{
	loc_write(fileloc);
	close(tapef);
	sleep(1);
}

#ifdef _AIX
/*
 * This routine facilitates the tape handling for newprod. It simply
 * centralizes the ioctl call and error handling here. If any errors
 * occur during an ioctl call to the tape device, then we terminate.
 */
int     tape_op(op, count, err)
unsigned int    op, count, err;
{
    struct stop     stop;
    extern int      errno;

    stop.st_op = op;        /* operation to do*/
    stop.st_count = count;
    if (ioctl(tapef, STIOCTOP, &stop) < 0)
    {
	if (err) {
	    PRINT "Error tape ioctl: Op: %d Count: %d Errno: %d.\n",
			op, count, errno);
	    terminate(9);
	}
	else
	    return(-1);
    }
    sleep(1);
    return(0);
}
#elif defined(SCO)
/*
 * This routine facilitates the tape handling for newprod. It simply
 * centralizes the ioctl call and error handling here. If any errors
 * occur during an ioctl call to the tape device, then we terminate.
 */
int     tape_op(op, count, err)
unsigned int    op, count, err;
{
    extern int      errno;
    int i;

    for (i = 0; i < count; i++) {
	if (ioctl(tapef, op, NULL) < 0) {
	    if (err) {
		PRINT "Error tape ioctl: Op: %d Count: %d Errno: %d.\n",
			    op, count, errno);
		terminate(9);
	    }
	    else
		return(-1);
	}
    }
    sleep(1);
    return(0);
}
#else
/*
 * This routine facilitates the tape handling for newprod. It simply
 * centralizes the ioctl call and error handling here. If any errors
 * occur during an ioctl call to the tape device, then we terminate.
 */
int	tape_op(op, count, err)
unsigned int	op, count, err;
{
    struct mtop	mtop;	/*tape command structure */
    extern int	errno;

    mtop.mt_op = op;	/* operation to do*/
    mtop.mt_count = count;
    if (ioctl(tapef, MTIOCTOP, &mtop) < 0) {
	    if (err) {
		PRINT "Error tape ioctl: Op: %d Count: %d Errno: %d.\n",
				op, count, errno);
		terminate(9);
	    }
	    else
		return(-1);
    }
    sleep(1);
    return(0);
}
#endif



/*
 * This routine reads in the next file from tape into the UNIX file name given
 * as its argument.
 */
int	read_file_from_tape(destfname)
char	*destfname;
{
	char	*buf;
	unsigned	rbytes;
	int	f;

	if ((f = creat(destfname, 0666)) < 0) {
		PRINT "Error in creating file %s for writing.\n", destfname);
		terminate(8);
	}
	buf = (char *)malloc(blocksize);
	while ((rbytes = read(tapef, buf, blocksize)) != 0) /* 0 from read*/
		write(f, buf, rbytes);		        /* means EOF */
	close(f);
	free(buf);
	++fileloc;	/* one file has been read */
	return(0);
}

/*
 * This routine simply rewinds the tape and checks the first block for
 * proper credentials. This block must have the correct magic string as
 * its first line, then a copyright notice, then the name of the prodlist
 * file, and finally the date of the tape itself. For example:
 *
 * Intergraph Workstation Delivery Tape - Version A
 * Copyright (c) 1987
 * ws_s.prods ws_ad.prods
 * Wed Jun  3 09:13:29 CDT 1987
 *
 * If neither the magic string nor the prodlist agree, then this routine
 * terminates newprod.
 */
void	confirm_delivery_tape(prodlist)
char	*prodlist;
{
	int	found;
	char	*buf, *c;

#ifdef _AIX
        tape_op(STREW, 1, 1);
#elif defined(SCO)
	tape_op(MT_REWIND, 1, 1);           /* rewind the tape */
#else
        tape_op(MTREW, 1, 1);           /* rewind the tape */
#endif

	buf = (char *)malloc(blocksize);
	buf[0]='\0';
	read(tapef, buf, blocksize);
	if (strncmp(buf, TAPEHEADERMAGIC, sizeof(TAPEHEADERMAGIC)-1)) {
	    PRINT "This is not a workstation delivery tape.\n");
	    terminate(7);
	}

	for (c = buf; *c != '\n'; ++c)	/* skip to first NL */
	    ;
	tapeversion = *(c - 1);
	for (++c; *c != '\n'; ++c)	/* skip to second NL */
	    ;

	found = 0;
	for (++c; *c != '\n' && !found; ++c)
	    if (!strncmp(prodlist, c, strlen(prodlist)))
		++found;

	if (!found) {
	    PRINT "This tape is not intended to be delivered to this workstation.\n");
	    terminate(7);
	}

	if (read(tapef, buf, blocksize) != 0)	/* 0 from read is EOF */
#ifdef _AIX
	    tape_op(STFSF, 1, 1);           /* skip to next file */
#elif defined(SCO)
	    tape_op(MT_RFM, 1, 1);           /* skip to next file */
#else
	    tape_op(MTFSF, 1, 1);           /* skip to next file */
#endif

	fileloc = 2;

	free(buf);
}
