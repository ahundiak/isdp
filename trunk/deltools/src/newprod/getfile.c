#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <sys/utsname.h>
#include <sys/types.h>
#include <sys/stat.h>
#if defined(clipper) || defined(__clipper__)
#  ifdef SYSV
#    include <sys/sysingr.h>
#    include <sys/mtio.h>
#  else
#    include <sys/mount.h>
#    include <machine/mtio.h>
#  endif
#endif
#ifdef sun
#include <sys/param.h>
#include <sys/mtio.h>
#  ifdef SunOS_4
#    include <sun/dkio.h>
#  else
#    include <sys/fdio.h>
#  endif
#endif
/* ifdef HP added -- MVR 30 Apr 1994 */
#ifdef HP_UX
#include  <limits.h>
#include <sys/mtio.h>
#endif
#if defined(_AIX) || defined(SCO)
#include <sys/tape.h>
#endif
#ifdef sgi
#include <sys/mtio.h>
#endif
#include "defs.h"

#define FL_IOCTL_TYPE	4
#define TAPESIZE	8192	/* used to be 512 */
#define	RECSIZE		256
#if defined(clipper) || defined(__clipper__) || defined(sgi)
#define PIPESIZE	(10 * 512)
/* The limit on max. automic writable bytes for HPUX_SOURCE is 
 * PIPE_MAX which is MAX_INT. But as we need to allocate the 
 * memory for this size at a later stage lets go for a reasonalble 
 * value, say 8096 bytes ! -- MVR 30 Apr 1994. 
*/
#elif defined(HP_UX)
#define PIPESIZE 	8096
#else
#define PIPESIZE	PIPE_BUF
#endif

extern char	*GetMountPoint();

#ifdef XNS_NET
extern char	*fmu_receive();
extern char	*fmu_connect();
extern char	*fmu_set();
#endif

extern  char *cpu_types[];
extern  unsigned long my_arch;

extern int	tapef;	/*file id for the tape device in case of tape delivery*/
extern int	fileloc;
extern unsigned int	decode_slot;
extern short	verbose;
extern short	debug;
extern short	srcmedia;
extern char	*tape_device;
extern struct utsname	un;
extern struct stat	statbuf;
extern char	progname[STRSIZ];
char	gf_flag = 0;

int	findfileinfo(prodlist, prodline, prodnumber, filename)
char	*prodlist, *prodline, *prodnumber, *filename;
{
    char	*c;
    FILE	*tmpf;
    short	errflg = 0;

    if ((tmpf = fopen(prodlist, "r")) == NULL) {
	PRINT "getfile: cannot open prodlist file %s.\n", prodlist);
	return(1);
    }

    /*
     * read down to the prodlist entry for prodnumber
     */
    for (;;) {
	if (fgets(prodline, RECSIZE, tmpf) == NULL) {
	    ++errflg;
	    break;
	}

	/*
	 * convert prodnumber field to upper case
	 */
	for (c = prodline; *c != '#'; ++c)
	    *c = toupper(*c);

	if (!strncmp(prodline, prodnumber, strlen(prodnumber)))
	    break;	/* found it! */
    }

    /*
     * read down to the filename entry
     */
    for (; !errflg;) {
	if (fgets(prodline, RECSIZE, tmpf)==NULL || prodline[0] != '#'){
	    ++errflg;
	    break;
	}
    
	/*
	 * skip over leading #, blanks or tabs
	 */
	for (c = prodline; *c == '#' || *c == ' ' || *c=='\t'; ++c)
	    ;
	if (!strncmp(c, filename, strlen(filename)))
	    break; /* found it! */
    }
    close(tmpf);
    return(errflg);
}

int	getfile(argc, argv)
int	argc;
char	**argv;
{
	char	*filename, *source;
	char	*outfile = "-";
	char	*prodlist, *srcdata, *srcslot, *srcdir, *flags;
	char	*protocol, *fold, *iso_9660;
	char	*b, *c;
	char	*cp;
	char	srcfile[RECSIZE];
	char	prodline[RECSIZE];
	int	out = 1; /* output file descriptor -- stdout by default */
	int	in, rcount = 0;
	int	toloc;
	int	flopnum;
	int	fsize = 0;
	int	flopsize;
	short	foldcase = 0;

#ifdef sun
#ifdef SVR4
	struct	fd_char flopstats;
#else
	struct	fdk_char flopstats;
#endif
#endif

	int	i, retstat;
	struct tran_s {
		int	*buf;
		int	bufcnt;
		int	iproc;
	}	tran;
	struct prodnode	pptr;
	extern char	*optarg;
	extern int	optind, opterr; /* "getopt" variables */

        strcpy(progname, argv[0]);
        gf_flag = 1;

	while ((i = getopt(argc, argv, "o:")) != EOF) {
		switch (i) {
		case 'o': /* establish output file name */
			outfile = optarg;
			if ((out = open(outfile, O_WRONLY|O_CREAT|O_TRUNC, 0664)) == -1) {
				PRINT "getfile: Cannot create %s\n", outfile);
				return(1);
			}
			break;
		}
	}

	/*
	 * if not more args on the command line or the environment
	 * variable PRODLIST isn't defined, then exit
	 */
	if (optind == argc || (prodlist = getenv("PRODLIST")) == NULL) {
		PRINT "Usage: getfile [ -o outfile ] filename\n");
		return(1);
	}

	filename = argv[optind];

	if ((cp = getenv("VERBOSE")) && !strcmp(cp, "-v"))
		++verbose;

	if ((cp = getenv("DEBUG")) && !strcmp(cp, "y"))
		++debug;

	tape_device = getenv("TAPEDEV");
	source = getenv("SRCMEDIA");
	srcdata = getenv("SRCDATA");
	srcdir = getenv("SRCDIR");
	iso_9660 = getenv("ISO9660");
	protocol = getenv("PROTOCOL");
	if (fold = getenv("FOLDCASE")) {
	    if (strcmp(fold, "UPPER") == 0)
		foldcase = UPPER;
	    if (strcmp(fold, "LOWER") == 0)
		foldcase = LOWER;
	}

	strncpy(pptr.prodname, getenv("PRODNAME"), PRODNAME_LEN);
	strncpy(pptr.prodnumber, getenv("PRODNUMBER"), PRODNUM_LEN);

	flags = getenv("FLAGS");
	if (flags)
		strncpy(pptr.flags, flags, FLAGS_LEN);
	srcslot = getenv("SRCSLOT");
	if (srcslot)
		decode_slot = atoi(srcslot);

	for (c = pptr.prodnumber; *c != '\0'; ++c)
		*c = toupper(*c);

	sprintf(srcfile, "%s%s", srcdir, filename);

	switch(source[1]) {
#ifdef XNS_NET
	case 'V':
		/*
		 * VAX network delivery
		 */
		srcmedia = VAX;
		if ((c = fmu_connect(srcdata))) {
			net_error(NET_CONNECT, c, TRUE);
			return(1);
		}
		if (verbose)
			fmu_set("VERBOSE");
		if ((c = fmu_receive(srcfile, outfile))) {
			net_error(NET_READ, c, TRUE);
			return(1);
		}
		fmu_disconnect();
		break;
	case 'W':
               srcmedia = WORKSTATION;
                /*
                 * Workstation/server network delivery
                 */
                uname(&un);
                for (b = un.nodename, c = srcdata; *c != '.' && *b != '\0';
                        c++, b++)
                        if (*c != *b)
                                break;
                if (*c == '.' && *b == '\0') {
                        if (verbose)
                                PRINT "Getting file from local disk - %s",
                                        filename);
                        in = open(srcfile, O_RDONLY);
                        c = (char *)malloc(PIPESIZE);
                        while ((rcount = read(in, c, PIPESIZE)) > 0) {
                                if (write(out, c, rcount) != rcount) {
                                        PRINT "\ngetfile: write failure.\n");
                                        return(1);
                                }
                                if (verbose)
                                        PRINT ".");
                        }
                        if (verbose)
                                PRINT "\n");
                        close(in);
                        if (rcount < 0) {
                                PRINT "\ngetfile: file read failure.\n");
                                return(1);
                        }
                } else {
                        if ((c = fmu_connect(srcdata))) {
                                net_error(NET_CONNECT, c, TRUE);
                                return(1);
                        }
                        if (verbose)
                                fmu_set("VERBOSE");
                        if ((c = fmu_receive(srcfile, outfile))) {
                                net_error(NET_READ, c, TRUE);
                                return(1);
                        }
                        fmu_disconnect();
                }
                break;

#endif
	case 'N':
		/*
		 * TCPIP network delivery
		 */
		srcmedia = TCPIP;
		uname(&un);
		for (b = un.nodename, c = srcdata; *c != '.' && *b != '\0';
			c++, b++)
			if (*c != *b)
				break;
		if (*c == '.' && *b == '\0') {
			if (verbose)
				PRINT "Getting file from local disk - %s",
					filename);
			in = open(srcfile, O_RDONLY);
			c = (char *)malloc(PIPESIZE);
			while ((rcount = read(in, c, PIPESIZE)) > 0) {
				if (write(out, c, rcount) != rcount) {
					PRINT "\ngetfile: write failure.\n");
					return(1);
				}
				if (verbose)
					PRINT ".");
			}
			if (verbose)
				PRINT "\n");
			close(in);
			if (rcount < 0) {
				PRINT "\ngetfile: file read failure.\n");
				return(1);
			}
		} else {
			if (verbose)
				PRINT "Getting file from network - %s", filename);
			if ((c = (char *)net_connect(srcdata))) {
				net_error(NET_CONNECT, c, TRUE);
				return(1);
			}
			net_get_server_version();
			if ((c = (char *)net_receive(srcfile, outfile, &pptr))) {
				net_error(NET_READ, c, TRUE);
				return(1);
			}
			net_disconnect();
		}
		break;

	case 'R':
		srcmedia = NETCDROM;
		/*
		 * Remote CDROM delivery
		 */
		if (verbose)
			PRINT "Getting file from remote CD/ROM - %s", filename);
#ifdef XNS_NET
		if ((protocol != NULL) && (strcmp(protocol, "XNS") == 0)) {
		    if ((c = (char *)xns_connect(srcdata))) {
			net_error(NET_CONNECT, c, TRUE);
			return(1);
		    }
		}
		else {
		    if ((c = (char *)net_connect(srcdata))) {
			net_error(NET_CONNECT, c, TRUE);
			return(1);
		    }
		}
#else
		if ((c = (char *)net_connect(srcdata))) {
		    net_error(NET_CONNECT, c, TRUE);
		    return(1);
		}
#endif
		net_get_server_version();
		if ((c = (char *)net_receive(srcfile, outfile, &pptr))) {
			net_error(NET_READ, c, TRUE);
			return(1);
		}
		net_disconnect();
		break;

	case 'T':
		/*
		 * Tape delivery
		 * find out where the file exists
		 * compare that with where we are - look in /tmp/.tapeloc
		 * seek to the appropriate spot if needed
		 * get the file off
		 * update /tmp/.tapeloc
		 */
		srcmedia = TAPE;

		if (findfileinfo(prodlist,prodline,pptr.prodnumber,filename)) {
			if (verbose)
				PRINT "Info on %s for product %s (%s) not found.\n",
					filename, pptr.prodname, pptr.prodnumber);
			return(1);
		}

		if (verbose)
			PRINT "Getting file from TAPE - %s", filename);

		if (open_tape() < 0) {
			PRINT "Error opening tape device %s.\n", tape_device);
			terminate(8);
		}

		/*
		 * skip filename and blanks to file number
		 */
		for (c = &prodline[1]; *c != ' '; ++c)
			;
		for (; *c == ' '; ++c)
			;
		toloc = atoi(c);

		if (toloc > fileloc)	/* skip to the file */
#ifdef _AIX
                    tape_op(STFSF, toloc - fileloc, 1);
#elif defined(SCO)
		    tape_op(MT_RFM, toloc - fileloc, 1);
#else
		    tape_op(MTFSF, toloc - fileloc, 1);
#endif

		else if (toloc < fileloc) {
		    /* rewind and skip to the file */
		    /*
		     * TESTING PURPOSES ONLY: (see Chris Davis)
		     * If the BSFTAPE variable is set, then back-skip-files.
		     * Otherwise, use old-style rewind and skip forward. 
		     */
		    if (getenv("BSFTAPE") != NULL) {
#ifdef _AIX
                        tape_op(STRSF, fileloc - toloc + 1, 1);
#elif defined(SCO)
                        tape_op(MT_REWIND, 1, 1);
                        tape_op(MT_RFM, toloc - 1, 1);
#else
                        tape_op(MTBSF, fileloc - toloc + 1, 1);
#endif
		    }
		    else {
#ifdef _AIX
                        tape_op(STREW, 1, 1);
                        tape_op(STFSF, toloc - 1, 1);
#elif defined(SCO)
                        tape_op(MT_REWIND, 1, 1);
                        tape_op(MT_RFM, toloc - 1, 1);
#else
                        tape_op(MTREW, 1, 1);
                        tape_op(MTFSF, toloc - 1, 1);
#endif

		    }
		}

		/* write file */
		c = (char *)malloc(TAPESIZE);
		retstat = 0;
		while (!retstat && ((rcount = read(tapef, c, TAPESIZE)) > 0)) {
			if (write(out, c, rcount) != rcount)
				++retstat;
			if (verbose)
				PRINT ".");
		}
		if (verbose)
			PRINT "\n");
		free(c);
		fileloc = toloc + 1;
		close_tape();
		if (retstat || rcount < 0) {
				PRINT "\ngetfile: read/write failure, retstat: %d, rcount: %d.\n",
				retstat, rcount);
			return(1);
		}
		break;

	case 'F':
		/*
		 * floppy delivery
		 * read prodlist file and find how floppies are set up
		 * read loc file and find out which floppy is in drive
		 * find where file exists
		 * switch on the situation
		 *		m:multi volume, p:product floppy, fn:filesys
		 * get the file and update the location file
		 */
		srcmedia = FLOPPY;

		if (findfileinfo(prodlist,prodline,pptr.prodnumber,filename)) {
			PRINT "Info for file %s in product %s (%s) not found\n",
				filename, pptr.prodname, pptr.prodnumber);
			return(1);
		}

		if (verbose)
			PRINT "Getting file from FLOPPY - %s", filename);

		/* skip filename and blanks to file location type */
		for (c = &prodline[1]; *c != '#' && *c != ' ' && *c != '\t';++c)
			;
		for (; *c == '#' || *c == ' ' || *c == '\t'; ++c)
			;

		flopnum = atoi(strchr(c, ' ')); 
		fileloc = loc_read();

		if (fileloc != flopnum) {
			/*
			 * positive values of fileloc imply mounted floppies
			 */
			if (fileloc > 0)
/* added HP here - MVR 15 May 1994 */
#if defined(SunOS_4) || defined(HP_UX)
				unmountfs(FMNTDIR);
#endif
#ifdef OSF
				umount(FMNTDIR, MNT_NOFORCE);
#endif
#ifdef SYSV
				umount(FLOP_DEVICE);
#endif

			/*
			 * prompt for floppy flopnum
			 * and mount it if required
			 */
			PRINT "Insert the %s (%s) floppy #%d and press <RETURN> ",
				pptr.prodname, pptr.prodnumber, flopnum);
			getc(stdin);
			if (*c == 'p' || *c == 'P' || *c == 'f' || *c == 'F') {
				if (mountfs(FLOP_DEVICE, FMNTDIR, 1) == -1) {
					PRINT "Cannot mount %s on %s\n",
						FLOP_DEVICE, FMNTDIR);
					terminate(4);
				}
			}
			fileloc = flopnum;
			loc_write(fileloc);
		}

		switch(*c) {
		case 'p':	/* file exists on product floppy */
		case 'P':
			sprintf(srcfile,"%s/%s/%s", FMNTDIR, srcdir, filename);
			c = (char *)malloc(PIPESIZE);
			in = open(srcfile, O_RDONLY);
			while ((rcount = read(in, c, PIPESIZE)) > 0) {
				if (write(out, c, rcount) != rcount) {
					PRINT "\ngetfile: write failure.\n");
					return(1);
				}
				if (verbose)
					PRINT ".");
			}
			if (verbose)
				PRINT "\n");
			close(in);
			free(c);
			if (rcount < 0) {
				PRINT "\ngetfile: file read failure.\n");
				return(1);
			}
			break;
		case 'f':	/* file on a file system floppy */
		case 'F':
			if (verbose)
				PRINT "\n");

			if (verbose)
				PRINT "Reading");
			sprintf(srcfile, "%s/%s", FMNTDIR, filename);
			c = (char *)malloc(PIPESIZE);
			retstat = 0;
			if ((in = open(srcfile, O_RDONLY)) < 0) {
				PRINT "Fatal: Cannot open %s for reading.\n", srcfile);
				++retstat;
			} else {
				fstat(in, &statbuf);
				fsize = statbuf.st_size;
			}
			if (retstat || (rcount = read(in, c, PIPESIZE)) < 0)
				++retstat;
			while (!retstat && (rcount > 0) && (fsize > rcount)) {
				if (write(out, c, rcount) != rcount)
					++retstat;
				fsize -= rcount;
				if (verbose)
					PRINT ".");
				if ((rcount = read(in, c, PIPESIZE)) < 0)
					++retstat;
			}
			if (verbose)
				PRINT "\n");
			close(in);

			if (write(out, c, rcount) != rcount)
				++retstat;
			free(c);
			if (retstat) {
				PRINT "\ngetfile: write failure.\n");
				return(1);
			}
			break;
		case 'm':	/* file is a multi volume set */
		case 'M':
			retstat = 0;
			fsize = atoi((char *)(strchr(c, '#') + 1)); 
			if ((in = open(FLOP_RAW_DEVICE, O_RDONLY)) < 0) {
				PRINT "Fatal: Cannot open %s for reading.\n",
					FLOP_RAW_DEVICE);
				++retstat;
			}

#if defined(clipper) || defined(__clipper__)
			ioctl(in, FL_IOCTL_TYPE, &flopsize);
			flopsize = (flopsize ? 2880 : 2400) * 512;
#endif
#ifdef sun
#ifdef SVR4
			ioctl(in, FDIOGCHAR, &flopstats);
			flopsize = flopstats.fdc_ncyl * flopstats.fdc_secptrack *
					 flopstats.fdc_nhead * flopstats.fdc_sec_size;
#else
			ioctl(in, FDKIOGCHAR, &flopstats);
			flopsize = flopstats.ncyl * flopstats.secptrack *
					 flopstats.nhead * flopstats.sec_size;
#endif
#endif
			c = (char *)malloc(flopsize);
			toloc = 0;
			if (verbose)
				PRINT "Reading");
			if (retstat || (rcount = read(in, c, 120*512)) < 0)
				++retstat;
			while (!retstat && (rcount > 0) && (fsize > rcount)) {
				if (verbose)
					PRINT ".");
				if (write(out, c, rcount) != rcount)
					++retstat;
				fsize -= rcount;
				toloc += rcount;
				if ((toloc % flopsize) == 0) {
					close(in);
					PRINT "\nInsert the %s (%s) floppy #%d and press <RETURN> ",
						pptr.prodname, pptr.prodnumber, flopnum + toloc / flopsize);
					getc(stdin);
					if ((in = open(FLOP_RAW_DEVICE,
						O_RDONLY)) < 0) {
						PRINT "Fatal: Cannot open %s for reading.\n",
							FLOP_RAW_DEVICE);
						++retstat;
					}
					fileloc++;
					if (verbose)
						PRINT "Reading");
				}
				if ((rcount = read(in, c, 120*512)) < 0)
					++retstat;
			}
			close(in);

			if (write(out, c, rcount) != rcount)
				++retstat;
			loc_write(-fileloc);
			free(c);
			if (retstat) {
				PRINT "\ngetfile: write failure.\n");
				return(1);
			}
			break;
		}
		break;

	case 'D':
		/*
		 * local directory delivery
		 */

		srcmedia = DIRECTORY;
		if (verbose)
			PRINT "Getting file from local disk - %s", filename);

		sprintf(srcfile, "%s/%s", srcdir, filename);

		if (verbose)
			PRINT "\n");

		if (verbose)
			PRINT "Reading");
		c = (char *)malloc(PIPESIZE);
		retstat = 0;
		if ((in = open(srcfile, O_RDONLY)) < 0) {
			PRINT "Fatal: Cannot open %s for reading.\n", srcfile);
			++retstat;
		} else {
			fstat(in, &statbuf);
			fsize = statbuf.st_size;
		}
		if (retstat || (rcount = read(in, c, PIPESIZE)) < 0)
			++retstat;
		while (!retstat && (rcount > 0) && (fsize > rcount)) {
			if (write(out, c, rcount) != rcount)
				++retstat;
			fsize -= rcount;
			if (verbose)
				PRINT ".");
			if ((rcount = read(in, c, PIPESIZE)) < 0)
				++retstat;
		}
		if (verbose)
			PRINT "\n");
		close(in);

		if (write(out, c, rcount) != rcount)
			++retstat;
		free(c);
		if (retstat) {
			PRINT "\ngetfile: write failure.\n");
			return(1);
		}
		break;

	case 'C':
		/*
		 * CDROM delivery
		 * assume that CDROM is currently in drive and mounted
		 */

		srcmedia = CDROM;
		if (verbose)
			PRINT "Getting file from CD/ROM - %s", filename);

		sprintf(srcfile, "%s/%s", srcdir, filename);

		/* IF the CD/ROM is in IS09660 format, the filenames are
		 * in UPPERCASE.  Some systems have requirements to
		 * ask for ISO9660 files in ALL CAPS or all lower.
		 */
		if (iso_9660 && (strcmp(iso_9660, "Y") == 0) && foldcase ) {
		    for (cp = srcfile + strlen(GetMountPoint(srcfile));
					*cp != '\0'; cp++)
			*cp = (foldcase == UPPER) ? (char)toupper(*cp) :
						    (char)tolower(*cp);
		}

#define CDROMSIZE	(62 * 1024)
		c = (char *)malloc(CDROMSIZE);
		in = open(srcfile, O_RDONLY);
		tran.buf = (int *)c;
		tran.iproc = decode_slot;
		retstat = atoi(pptr.flags);
		while ((rcount = read(in, c, CDROMSIZE)) > 0) {
			if (retstat) {
				tran.bufcnt = rcount;
#if (defined(clipper) || defined (__clipper__)) && defined(SYSV)
# ifdef ANCIENT
			    if (iso_9660 && strcmp(iso_9660, "Y") == 0)
				nabdrtran(&tran);
			    else
				syscall(125, SINGRNABDRTRAN, &tran);
# else
			    nabdrtran(&tran);
# endif /* ANCIENT */
#else
			    nabdrtran(&tran);
#endif
			}
			if (write(out, c, rcount) != rcount) {
				PRINT "\ngetfile: write failure.\n");
				return(1);
			}
			if (verbose)
				PRINT ".");
		}
		if (verbose)
			PRINT "\n");
		close(in);
		free(c);
		if (rcount < 0) {
			PRINT "\ngetfile: file read failure.\n");
			return(1);
		}
		break;
	}

	/*
	 * If using the -o option, then check the size of the output file.
	 * Close it and if zero length, remove it.
	 */
	if (out != 1) {
		retstat = fstat(out, &statbuf);
		close(out);
		if (retstat || statbuf.st_size == 0)
			unlink(outfile);
	}

	return(0);
}
