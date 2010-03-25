#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/utsname.h>
#if (defined(clipper) || defined(__clipper__))
#  ifdef SYSV
#    include <sys/sysingr.h>
#  else
#    include <sys/mount.h>
#  endif
#endif
#include <unistd.h>
#include <time.h>
#include <utime.h>
#include <signal.h>
#include <fcntl.h>
#include <search.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#ifdef SVR4
#include <libgen.h>
#endif
#include "defs.h"

#define TMPDIRMODE	0040777 /*mode of temp directory created*/
#define README_FILE	"README"
#define DESC_FILE	"DESCRIPTION"
#define FIXES_FILE	"fixes.com"
#define CERTNOTE_FILE	"certnote.com"
#define FEATURES_FILE	"features.com"
#define POSTSCRIPTNAME	"postinstall.sh"
#define LICENSE_DATA	"rule.dat"
#define LICENSE_MERGE	"ilicense/.rules/extract"
#define TRUNCATE_SIZ	10 * BUFFSIZ	/*#bytes in 10 blocks*/
#define SUBSHELL_ARGS	7	/*#args passed*/
#define ELSIZE		256
#define TABSIZE		8192
#define EXECUTABLE	0111
#define BOMFILE		"components"

extern void	lostpeer();
extern void	terminate();
extern int	fileloc;
extern unsigned int	decode_slot;
extern char	*ingrhome;
extern char	warnfile[STRSIZ];
extern char	basedir[STRSIZ];	/* where user wants to put files */
extern char	mountpoint[STRSIZ];	/* mount point of basedir */
extern char	ws_prodlist[STRSIZ];	/* product list file location */
extern char	makenodelist[STRSIZ];	/* product list location for makenode */
extern char	sharedfs[STRSIZ];
extern char	localdir[STRSIZ];
extern char	connstr[STRSIZ];	/* logical name/address of delivery node */
extern char	cdrel[16];
extern char	installscript[15];
extern char	removescript[15];
extern char	tapeversion;	/*version code 'e', 'A' - 'Z' of tape format */
extern short	takedefaults;	/*set if "-y" or "-d" by cmd line option*/
extern short	verbose;	/*set if "-v" cmd line option present*/
extern short	debug;		/*set if "-X" cmd line option present*/
extern short	minus_x;	/*set if "-x" passed to subshell*/
extern short	srcmedia;	/*FLOPPY, VAX, WORKSTATION, TCPIP, TAPE or CDROM */
extern short	shared;
extern short	enforce_approved_configurations;
extern short	iso_9660;
extern short	foldcase;
extern short	no_ksh;
extern unsigned long	my_arch;
extern unsigned long	filter_arch;
extern struct prodnode	header;
extern struct stat	statbuf;
extern struct utsname	un;
extern char	*machine;
extern char	*shell;
extern char	*configfile;
extern FILE	*logf;

struct tran_s {
    int		*buf;
    int		bufcnt;
    unsigned int	iproc;
};

struct extract_error {
    int		code;
    char	*message;
} extract_errs[] = {
    { 1, "Memory Allocation Error" },
    { 4, "File open error" },
    { 6, "File seek error" },
    { 7, "File Read Error" },
    { 8, "File Write Error" },
    { 11, "CRC Validation of Rules database failed" },
    { 12, "Rules database has improper revision" },
    { 17, "Machine ID Error" },
    { 22, "Could not lock Rules database" },
    { 23, "Licensing rules are corrupt" },
    { 99, "Fatal error" },
    { -1, "" },
};


#ifdef L_ENDIAN
#define htocl(x)	(x)
#define ctohl(x)	(x)
#else /* Sun */
extern unsigned long htocl();
#define ctohl(x)	htocl(x)
#endif

static char	ptmpdir[STRSIZ];

short	reboot = 0;
extern char	*cpu_types[NUM_ARCH];
short	cdrom_key_ok;
char	*dashes = {"-------------------------------------------------------------------------------"};

extern char	*GetMountPoint();

/*
 * This routine is called to create a temporary directory to install
 * a product into. If the directory is successfully created, then
 * a change directory call is executed so that the installation
 * scripts are in the correct directory to download their product.
 * NULL is returned to indicate success.
 */
int	mktmpdir(dirname, fullpathname)
char	*dirname, *fullpathname;
{
    char	command[STRSIZ];
    struct stat	statbuf;	
    int		tmp_is_symlinked = 0;

    LPRINT "mktmpdir:dirname=%s  fullpathname=%s\n",dirname, fullpathname);
    sprintf(command, "%s/tmp", mountpoint);
    if (lstat(command, &statbuf) < 0)
	tmp_is_symlinked = 1;
    else if (S_ISLNK(statbuf.st_mode))
	tmp_is_symlinked = 1;
 
    if (shared || tmp_is_symlinked) {
#if defined(SVR4) && defined(NEWDIRS)
	sprintf(fullpathname, "%s/ingr/%s", basedir, dirname);
#else
	sprintf(fullpathname, "%s/ip32/%s", basedir, dirname);
#endif
    }
    else
	sprintf(fullpathname, "%s/tmp/%s", mountpoint, dirname);
    
    /* clean up previous directory if it exists */
    if (access(fullpathname, F_OK) == 0) {
	sprintf(command, "rm -rf %s", fullpathname);
	system(command);
    }
    if (makedir(fullpathname, 040775, 0, 0))
	return(-1);		/* error from "makedir" */
    return(chdir(fullpathname));    /* "cd" to tmp directory */
}


int     nabdrtran(tp)
struct tran_s *tp;
{
    int n, nbyte;
    int *kp;
    register i;
    register i2 = 0;
    char *base;

    if ((int)tp->buf & 3) {
        errno = EFAULT;
        return(-1);
    }

    base = (char *)tp->buf;
    n = (tp->bufcnt + 3) & ~3;

    nbyte = n;
    while (n > 0) {
        /*
         * Decode the page of data.
         */
        kp = (int *) base;
        for (i = 0; i < nbyte; i += 4, i2 += 4, kp++)
            *kp = htocl(ctohl(*kp) ^ (((tp->iproc + (i2 * i2)) |
                           0x94DA77A3) * 0xD4E6A91B));

        n -= nbyte;
        base += nbyte;
    }
    return (0);
}


/*
 * This routine is used to copy a file from one place to another. A
 * return value of 0 indicates a successful copy.
 */
int	copy_file(infile, outfile, care, flg)
char	*infile, *outfile;
int	care, flg;
{
    int			inf, outf, rcount;
    struct utimbuf	times;
    struct tran_s	tran;
    
    char *mpoint, *cp;
    
    if (iso_9660 && foldcase) {
	mpoint = GetMountPoint(infile);
	for (cp = infile + strlen(mpoint); *cp != '\0'; cp++)
	    *cp = (foldcase == UPPER) ? (char)toupper(*cp) : (char)tolower(*cp);
    }

    if ((inf = open(infile, O_RDONLY)) < 0) {
	if (care)
	    PRINT "Cannot open %s for reading.\n", infile);
        return(1);
    }

    if (fstat(inf, &statbuf)) {
	if (care)
	    PRINT "Cannot stat %s.\n", infile);
	close(inf);
        return(1);
    }

    if ((outf = creat(outfile, statbuf.st_mode)) < 0) {
        if (care)
	    PRINT "Cannot open %s for writing.\n", outfile);
	close(inf);
	return(1);
    }

    tran.iproc = decode_slot;
    tran.buf = (int *)malloc(62 * 1024);

    while ((rcount = read(inf, (char *)tran.buf, 62 * 1024)) > 0) {
	if (srcmedia == CDROM && flg) {
	    tran.bufcnt = rcount;
#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
	    if (iso_9660)
		nabdrtran(&tran);
	    else
                syscall(125, SINGRNABDRTRAN, &tran);
#else
	    nabdrtran(&tran);
#endif
	}
	if (write(outf, (char *)tran.buf, rcount) != rcount) {
	    free(tran.buf);
	    close(inf);
	    close(outf);
	    return(-1);
	}
    }

    free(tran.buf);
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

#define GET_FIXFILE	0
#define GET_SCRIPT	1
#define GET_FEATURES	2
#define GET_CERTNOTE	3
#define GET_REMOVESH	4
#define GET_PRODDEF	5
#define GET_README	6
#define GET_DESC	7
#define GET_PS_README	8   /* Platform specific README file */

int    get_file(pptr, which)
register struct prodnode *pptr;
int	which;
{
    int	retval = 0;
    int	care = 0;
    char	snstr[44];
    char	*c, *dname = NULL, *sname = NULL;
    char	*errstr = 0;
    char	srcfile[STRSIZ];	/*build filename in this guy*/
    char	command[44];		/*command string for getfile*/
    extern int	check_key();
    extern char	*net_receive();

    switch(which) {
    case GET_PS_README:
	sprintf(snstr, "%s.%s", README_FILE, machine);
	sname = snstr;
	dname = README_FILE;
	break;

    case GET_README:
	sname = README_FILE;
	dname = README_FILE;
	++care;
	break;
	
    case GET_FIXFILE:
	sname = FIXES_FILE;
	dname = sname;
	++care;
	break;
	
    case GET_SCRIPT:
	sname = installscript;
	dname = installscript;
	++care;
	break;
	
    case GET_DESC:
	sname = DESC_FILE;
	dname = sname;
	++care;
	break;
	
    case GET_FEATURES:
	sname = FEATURES_FILE;
	dname = sname;
	break;
	
    case GET_CERTNOTE:
	sname = CERTNOTE_FILE;
	dname = sname;
	break;
	
    case GET_REMOVESH:
	sname = removescript;
	dname = sname;
	break;
	
    case GET_PRODDEF:
	sname = "product.def";
	dname = sname;
	++care;
	break;
	
    }
    
    switch(srcmedia) {
#ifdef XNS_NET
    case VAX:
	if (which == GET_FIXFILE || which == GET_CERTNOTE ||
	    which == GET_FEATURES) {
	    c = strchr(sname, '.');
	    *c = '\0';
	    sprintf(srcfile, "%s%s_%s.com",
		    pptr->srcdir, sname, pptr->prodnumber);
	    *c = '.';
	} else
	    sprintf(srcfile, "%s%s", pptr->srcdir, sname);
	
	errstr = fmu_receive(srcfile, dname);
	if (errstr) {
	    retval = -1;
	    if (care && which != GET_README && which != GET_PS_README &&
		which != GET_FIXFILE)
		net_error(NET_READ, errstr, care);
	}
	break;

    case WORKSTATION:
	sprintf(srcfile, "%s%s", pptr->srcdir, sname);
	errstr = fmu_receive(srcfile, dname);
	if (errstr) {
	    retval = -1;
	    if (care && which != GET_README && which != GET_PS_README &&
		which != GET_FIXFILE)
		net_error(NET_READ, errstr, care);
	}
	break;
#endif
	
    case TCPIP:
	/*
	 * if we're connected via TCP/IP and a product has
	 * a flags entry -- then the remote media must be
	 * remote CD/ROM -- fall through
	 */
	if (!pptr->flags[0]) {
	    sprintf(srcfile, "%s%s", pptr->srcdir, sname);
	    errstr = net_receive(srcfile, dname, pptr);
	    if (errstr) {
		retval = -1;
		if (care && which != GET_README && which != GET_PS_README &&
		    which != GET_FIXFILE)
		    net_error(NET_READ, errstr, care);
	    }
	    break;
	} else
	    srcmedia = NETCDROM;
	
	/* fall through to NETCDROM */
	
    case NETCDROM:
	sprintf(srcfile, "%s%s", pptr->srcdir, sname);
	if (iso_9660 && foldcase) {
	    for (c = srcfile + strlen(GetMountPoint(srcfile)); *c; c++)
		*c = (foldcase == UPPER) ? toupper(*c) : tolower(*c);
	}
	if (which == GET_DESC)
	    errstr = net_receive(srcfile, dname, 0);
	else if (!cdrom_key_ok) {
	    if (which != GET_README && which != GET_PS_README &&
		which != GET_FIXFILE && which != GET_PRODDEF)
		return(-1);
	    if (check_key(srcfile, pptr))
		return(-1);
	    ++cdrom_key_ok;
	}
	errstr = net_receive(srcfile, dname, pptr);
	
	if (errstr) {
	    retval = -1;
	    if (care && which != GET_README && which != GET_PS_README &&
		which != GET_FIXFILE && which != GET_PRODDEF)
		net_error(NET_READ, errstr, care);
	}
	break;
	
    case CDROM:
	sprintf(srcfile, "%s%s", pptr->srcdir, sname);

	if (iso_9660 && foldcase) {
	    for (c = srcfile + strlen(GetMountPoint(srcfile)); *c; c++)
		*c = (foldcase == UPPER) ? toupper(*c) : tolower(*c);
	}

	if (which == GET_DESC) {
	    retval = copy_file(srcfile, dname, care, 0);
	    break;
	}
	if (!cdrom_key_ok) {
	    if (which != GET_README && which != GET_PS_README &&
		which != GET_FIXFILE && which != GET_PRODDEF)
		return(-1);
	    if (check_key(srcfile, pptr))
		return(-1);
	    ++cdrom_key_ok;
	}
	retval = copy_file(srcfile, dname, care, atoi(pptr->flags));
	break;
	
    case DIRECTORY:
	sprintf(srcfile, "%s%s", pptr->srcdir, sname);
	retval = copy_file(srcfile, dname, care, 0);
	break;
	
    case FLOPPY:
	sprintf(srcfile, "%s/%s/%s", FMNTDIR, pptr->srcdir, sname);
	if (fileloc != 1) {
	    /*
	     * positive values of fileloc imply mounted floppies
	     */
	    if (fileloc > 0)
/* Add HP here -- MVR 25 May 1994 */
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
	     * prompt for floppy #1
	     * mount floppy
	     */
	    PRINT "\n\nInsert the %s (%s) floppy #1 and press <RETURN> ",
	    		pptr->prodname, pptr->prodnumber);
	    getchar();
	    if (mountfs(FLOP_DEVICE, FMNTDIR, 1)) {
		PRINT "Cannot mount %s on %s\n", FLOP_DEVICE,
					FMNTDIR);
	        terminate(4);
    	    }
	}
	retval = copy_file(srcfile, dname, care, 0);
	if (retval == 0)
	fileloc = 1;
	break;

    case TAPE:
    	close_tape();
	sprintf(command, "getfile -o %s %s", dname, sname);
	retval = system(command);
	if (open_tape() < 0) {
	    PRINT "Cannot open tape device\n");
	    exit(1);
	}
        break;
    }

    if (!retval)
	chmod(dname, (mode_t)(which == GET_REMOVESH ? 0754 : 0644));
    if (retval && verbose)
	PRINT "VERBOSE:\t%s: file \"%s\" not found on media.\n",
    			care ? "Error" : "Notice", sname);

    return((care || (which == GET_PS_README)) ? retval : 0);
}

/*
 * This routine is called to create a subprocess to execute the
 * product-specific shell script. It will fork and exec the child
 * process and wait on the return value from the child. The value
 * returned by the child is passed back as the return value of this
 * function.
 */
int	execute_script(srcdir, ws_destdir, scriptname)
char	*srcdir, *ws_destdir, *scriptname;
{
    int		i = 1;		/* used to fill args */
    int		rstat;		/* routine retval, also syscall return values*/
    char	*args[SUBSHELL_ARGS+1];	/*build execv args here*/
    static char	envstr1[STRSIZ];
    static char	envstr2[STRSIZ];
    extern char	*shell;
    extern short	waitfor;
    extern void	shellcmd();

   LPRINT "execute_script:srcdir=%s ws_destdir=%s scriptname=%s\n",srcdir, ws_destdir, scriptname);
#ifndef OSF
    if (no_ksh) {
        /*
         * Check again to see if "ksh" has been installed since the
	 * last time we passed through...
         */
        if (access("/bin/ksh", X_OK) == 0) {
                shell = "/bin/ksh";
                putenv("SHELL=/bin/ksh");
                putenv("ENV=");         /* clear the ENV variable */
		no_ksh = 0;
        }
    }
#endif
    if (waitfor) {
	LPRINT "waitfor\n");
	shellcmd();
    } 
    if ((rstat = fork()) >= 0) {
	if (rstat)
	    wait(&rstat);
	else {
	    chmod(scriptname, SCRIPTMODE);
	    args[0] = shell;
	    if (minus_x) {
		args[1] = "-x";
		i = 2;
	    }
	    args[i++] = scriptname;
	    switch (srcmedia) {
	    case VAX:
		args[i++] = "-V";
		break;
	    case WORKSTATION:
		args[i++] = "-W";
		break;
	    case TCPIP:
		args[i++] = "-N";
		break;
	    case NETCDROM:
		args[i++] = "-R";
		break;
	    case DIRECTORY:
		args[i++] = "-D";
		break;
	    case FLOPPY:
		args[i++] = "-F";
		break;
	    case CDROM:
		args[i++] = "-C";
		break;
	    case TAPE:
		args[i++] = "-T";
		break;
	    }
	    args[i] = args[i-1]; /* the connstr argument */
	    ++i;
	    args[i++] = srcdir;
	    args[i++] = ws_destdir;	/* $4 */
	    args[i++] = (takedefaults ? "-y" : "");
	    args[i] = NULL;
	    strcpy(envstr1, "DESTDIR=");
	    putenv(strcat(envstr1, ws_destdir));
	    if (shared) {
		strcpy(envstr2, "CLIENTDESTDIR=");
		putenv(strcat(envstr2, (ws_destdir+strlen(sharedfs))));
	    }
	    putenv(minus_x ? "NULL=/dev/tty" : "NULL=/dev/null");
	    if ((rstat = execv(shell, args)) < 0) {
		PRINT "Error in exec of %s.\n", shell);
		LPRINT "Error in exec of %s.\n", shell);
	        _exit(1);   /*don't perform any cleanup*/
	    }
	}
    }
    else {
        PRINT "Error in fork of install script.");
	LPRINT "execute_script:Error in fork of install script.\n");
        return(-1);
    }
    LPRINT "execute_script:return %d\n",(rstat >> 8) & 0xff);
    return((rstat >> 8) & 0xff);	/* shift the shell exit status down */
}

/*
 * This routine is called to remove the contents of the temporary
 * directory created prior to the download of a product's fixes and
 * shell script files.
 */
void    my_rmdir(dirname)
register char	*dirname;
{
    char	command[STRSIZ];
    
    chdir("/");	/* "cd" to / directory, get out of tmp where ever */
    sprintf(command, "rm -rf %s", dirname);
    system(command);
}

/*
 * This routine compares two product entries based on the name, number,
 * and pathname. When products have the same name or number AND the same
 * path, then they are considered equal. Otherwise, it returns the difference
 * in product name (for alphabetizing.)
 * SS01191#ACC#Apogee C Compiler#05.00.01.24#13-SEP-1990#/usr/ingr/comp/acc#
 */
int	confcmp(s1, s2)
char	*s1, *s2;
{
    register int	i, numdiff;
    
    /*
     * first get the number difference
     */
    for (; *s1 != '#' && *s1 != '\0' && *s1 == *s2; ++s1, ++s2)
	;
    numdiff = *s1 - *s2;
    
    /*
     * move up to the next field
     */
    for (; *s1 != '#'; ++s1)
	;
    for (; *s2 != '#'; ++s2)
	;
    ++s1;
    ++s2;
    
    /*
	 * now get the name difference
	 */
    for (; *s1 != '#' && *s1 != '\0' && *s1 == *s2; ++s1, ++s2)
	;
    
    if ((*s1 - *s2) && numdiff)
	return (*s1 - *s2);
    
    /*
     * Since the name or number is the same, then check the paths.
     * Make sure we're up to the next field mark first.
     */
    for (; *s1 != '#'; ++s1)
	;
    for (; *s2 != '#'; ++s2)
	;
    
    /*
     * Now test the path, but first move up to the path field.
     */
    for (i = 0; i < 3; ++i) {
	for (++s1; *s1 != '#'; ++s1)
	    ;
	for (++s2; *s2 != '#'; ++s2)
	    ;
    }
    ++s1;
    ++s2;
    for (; *s1 != '#' && *s1 != '\0' && *s1 == *s2; ++s1, ++s2)
	;
    /*
     * Return the path difference.
     */
    return (*s1 - *s2);
}

/* This routine compares two products based upon their product number and
 * their architecture.
 * It is used to find pre-existing products that have been "makenode"ed
 * for a platform.
 */
int	prodcmp(s1, s2)
char	*s1, *s2;
{ 
    register int	i, numdiff;
    
    for (; *s1 != '#' && *s1 != '\0' && *s1 == *s2; ++s1, ++s2)
	;
    numdiff = *s1 - *s2;
    
    if (numdiff)
	return (numdiff);
    else {
	/*
	 * Now move to the DELarch field
	 */
	for (i = 0; (i < 11) && *s1 && *s2; ++i) {
	    for (++s1; (*s1 != '#') && *s1; ++s1)
		;
	    for (++s2; (*s2 != '#') && *s2; ++s2)
		;
	}
	if (*s1)
	    ++s1;
	if (*s2)
	    ++s2;
	return(*s1 - *s2);
    }
}

/*
 * This routine compares two product numbers based on the first chars
 * up to the # delimiter. It returns a value like strcmp() does.
 */
int	numcmp(s1, s2)
char	*s1, *s2;
{
    for (; *s1 != '#' && *s1 != '\0' && *s1 == *s2; ++s1, ++s2)
	;
    return(*s1 - *s2);
}

/*
 * This routine makes the configuration file entry for a product. It uses
 * lsearch to do the dirty work.
 */
void	make_config_entry(pptr, unixdir)
struct prodnode	*pptr;
char	*unixdir;
{
    unsigned	nel = 0;
    int	i;
    time_t	t;
    char	line[ELSIZE], tab[TABSIZE][ELSIZE];
    char	config[STRSIZ];
    char	mediaspec[STRSIZ];
    char	*c, *u;
    struct tm	*now;
    FILE	*f;
    extern time_t	time();
    extern struct tm	*localtime();
    
    u = unixdir;
    config[0] = '\0';
    if (shared) {
	/*
	 * Did DISKLESS pass in its own idea of where the config
	 * file is?  
	 * If so, use it instead of the "sharedfs/CONFIGFILE" combo
	 */
	if (configfile)
	    strcpy(config, configfile);
	else {
	    /*
	     * since we're installing shared, only save the unixdir portion
	     * after the sharedfs path.
	     */
	    u += strlen(sharedfs);
	    sprintf(config, "%s/%s/%s", sharedfs, unixdir, CONFIGFILE);
	}
    }
    else {
	sprintf(config, "%s/%s", ingrhome, CONFIGFILE);
    }

    if ((f = fopen(config, "r")) == NULL) {
	f = fopen(config, "w");	/* create the file */
	fclose(f);
	f = fopen(config, "r");
    }
    
    while (fgets(line, ELSIZE, f) != NULL && nel < TABSIZE)
	lsearch(line, (char *)tab, (size_t *)&nel, ELSIZE, (int(*)(const void*, const void*))confcmp);
    fclose(f);
    
    time(&t);
    now = localtime(&t);
    switch (srcmedia) {
    case VAX:
	sprintf(mediaspec, "VAX: %s", NodeAndUser(connstr, line));
	break;
    case WORKSTATION:
	sprintf(mediaspec, "XNS: %s", NodeAndUser(connstr, line));
	break;
    case TCPIP:
	sprintf(mediaspec, "TCPIP: %s", NodeAndUser(connstr, line));
	break;
    case NETCDROM:
	sprintf(mediaspec, "Remote CD/ROM: %s %s", cdrel, NodeAndUser(connstr, line));
	break;
    case DIRECTORY:
	sprintf(mediaspec, "Local Directory: %s", localdir);
	break;
    case CDROM:
	sprintf(mediaspec, "Local CD/ROM: %s", cdrel);
	break;
    case FLOPPY:
	strcpy(mediaspec, "Floppy");
	break;
    case TAPE:
	strcpy(mediaspec, "Tape");
	break;
    }
    
    sprintf(line, "%s#%s#%s#%s#%s#%s#%02d:%02d:%02d %02d/%02d/%02d#%s#\n",
	pptr->prodnumber, pptr->prodname, pptr->prodtitle, pptr->prodversion, pptr->date, u,
	now->tm_hour, now->tm_min, now->tm_sec, now->tm_mon+1, now->tm_mday, now->tm_year%100,
	    mediaspec);
    c = (char *)lsearch(line, (char *)tab, (size_t *)&nel, ELSIZE, (int(*)(const void*, const void*))confcmp);
    strcpy(c, line);
    
    f = fopen(config, "w");	/* open for writing */
    for (i = 0; i < nel; ++i)
	fprintf(f, "%s", tab[i]);
    fclose(f);
}

/*
 * check_for_approved_configuration
 *
 * Purpose:     Scan the product.def file for the #AC section, which
 *              describes the platforms against which the product has
 *              been certified.  These entries are in regex format,
 *              and the machine type is compared against each
 *              machine type listed.  If any successfully match
 *
 * Parameters:          machine (from global utsname variable)
 *
 * Return Values:       0 for success
 *                      -1 for failure
 *
 */

int
check_for_approved_configuration(machine)
char    *machine;
{
    FILE        *fp;
    short       found = 0, modifier = 0;
    char        str[STRSIZ];
    char        *c, *t, *result;

/* HP added here -- MVR 5 May 1994 */
#if defined(SVR3) || defined(HP_UX)
    extern      char *regcmp(), *regex();
#endif
#ifdef SunOS_4
    extern      char *re_comp();
    extern      int re_exec();
#endif

#define	ABORT	1
#define	WARNING	2

    if ((fp = fopen("product.def", "r")) == NULL) {
        return(-1);
    }

    while (fgets(str, STRSIZ, fp) && !found)  {
        if (strncmp(str, "#AC", 3) == 0) {
            found++;
            break;
	}
    }
    fclose(fp);

    if (found) {
        c = &str[0] + 3;
        while (*c && isspace(*c))
            c++;

        /*
         * For each entry listed (comma-separated), compile the
         * regular expression and check this machine's name against
         * it.
         *
         * Special case: A '!' character negates the result of the
         * comparison.
         *
         */

        found = 0;
        t = (char *)strtok(c, " ,\n");

        while (t != NULL) {
            while (*t == ' ')
                t++;

            if (*t == '!') {
		modifier = ABORT;
                t++;
            }
	    else if (*t == '%') {
		modifier = WARNING;
		t++;
	    }
            else
                modifier = 0;

            /*
             * Compile the regular expression
             */

/* HP added here -- MVR 5 May 1994 */
#if defined(SYSV) || defined(HP_UX)
	    result = regcmp(t, (char *)0);
            if (result) {
                if (regex(result, machine)) {
		    free(result);
		    if (modifier == ABORT)
			return(-1);
		    else if (modifier == WARNING)
			return(1);
		    else
			return(0);
                }
		free(result);
            }
#endif
#ifdef SunOS_4
            result = re_comp(t);
            if (!result) {
                if (re_exec(machine)) {
                    if (modifier == ABORT)
                        return(-1);
		    else if (modifier == WARNING)
			return(1);
                    else
                        return(0);
                }
            }
#endif
            t = (char *)strtok(NULL, " ,\n");
        }
        /*
         *  No matches found.   Let it go.
         */
        return(0);
    }
    else {
        /*
         * No list of approved configurations found.
	 * Let it go.
         */
        return(0);
    }
}



/*
 * This routine is called to install a product. A pointer to the product
 * to be installed is passed in. The actual installation is done by a
 * product-specific installation shell script. This routine performs
 * free space checks, creates a temporary directory to put the new
 * product in, brings down the fixes.com file, brings down the
 * product installation script, and, assuming that all the above is
 * completed successfully, executes the product installation script
 * and waits for the return status from the child. The return status
 * determines whether or not the files in the temporary directory are
 * moved to the normal product directory. Finally the temporary
 * directory and its contents are removed.
 */
int    install(currloc, pptr)
int	currloc;	/* non-zero if product should go into current location */
register struct prodnode *pptr;
{
    int		rstat = -1;		/* load rstat, initialize to failure */
    int		result, i;
    short	vardirexists = 0;
    char	*c;
    char	tmpdirname[STRSIZ];	/* this is where new product received */
    char	vardirname[STRSIZ];
    char	unixdir[STRSIZ];	/* product's final resting place */
    char	tmpmntpoint[STRSIZ];	
    char	post[STRSIZ];		/* postinstall.sh pathname */
    char	command[256];
    char	lic_data[256];
    static char	savefs[STRSIZ] = ""; /* holding space for installing */
    static char	envstr1[STRSIZ];
    static char	envstr2[STRSIZ];
    FILE	*warnings = NULL;
    time_t	warn_time;
    char	warnstr[64];

    reboot = 0;
    PRINT "\n%s\n", dashes);
    PRINT "Installing: %s (%s)\n", pptr->prodname, pptr->prodnumber);
    LPRINT "Installing: %s (%s)\n", pptr->prodname, pptr->prodnumber);

    /*
     * set basedir and mountpoint to point to where the product is
     * going to install so that free space check works right.
     */
    strcpy(savefs, basedir);	/* save basedir to be restored later */

    if (currloc && pptr->loadeddir[0] != '\0') {
        strcpy(unixdir, pptr->loadeddir);
        strcpy(basedir, GetMountPoint(unixdir));
	strcpy(mountpoint, basedir);
    } else if (pptr->unixdir[0] == '/') { /* handle absolute path */
        strcpy(unixdir, pptr->unixdir);
	strcpy(basedir, GetMountPoint(unixdir));
	strcpy(mountpoint, basedir);
    } else {
        sprintf(unixdir, "%s/%s", basedir, pptr->unixdir);
    }

    strcpy(tmpmntpoint, mountpoint);
    if (free_space_check(mountpoint, pptr, 0)) {
	VPRINT("Insufficient free space for installation on ", mountpoint);
        LPRINT "Insufficient free space on %s for installation.\n", mountpoint);
        strcpy(basedir, savefs);
	strcpy(mountpoint, GetMountPoint(basedir));
	goto finishup;
    }

    VPRINT1("Making temporary directory.");
    if (mktmpdir(pptr->prodnumber, tmpdirname)) {
        strcpy(basedir, savefs);
        strcpy(mountpoint, GetMountPoint(basedir));
        goto finishup;
    }
    if (shared) {
        c = strchr(pptr->unixdir, '/');
	if (c == NULL)
	    c = pptr->unixdir;
	else
	    ++c;
#if defined(SVR4) && defined(NEWDIRS)
        sprintf(vardirname, "%s/var/opt/ingr/%s", sharedfs, c);
#else
        sprintf(vardirname, "%s/var/ingr/%s", sharedfs, c);
#endif
        if (access(vardirname, F_OK)) {
	    VPRINT1("Making configuration directory.");
            makedir(vardirname, 040777, 0, 0);
        } else
	    ++vardirexists;
	strcpy(envstr2, "VARDIR=");
	putenv(strcat(envstr2, vardirname));
    }

    /*
     * restore basedir to be what user requested, before product was loaded.
     */
    strcpy(basedir, savefs);
    strcpy(mountpoint, GetMountPoint(basedir));

    cdrom_key_ok = 0;
    VPRINT1("Copying the README file.");
    NVPRINT("Installing");

    /* Try to get platform specific readme file README.sun or README.clip
     * first.  If that fails, get the generic README file.  If THAT fails,
     * try to get the cruddy old fixes/features/certnote.com files.
     */
    if (get_file(pptr, GET_PS_README)) {
	if (get_file(pptr, GET_README)) {
	    VPRINT1("Copying the fixes file.");
	    if (get_file(pptr, GET_FIXFILE))
       	        goto finishup;

	    VPRINT1("Copying the features file.");
	    get_file(pptr, GET_FEATURES);
	    NVPRINT(".");

	    VPRINT1("Copying the certnote file.");
	    get_file(pptr, GET_CERTNOTE);
	    NVPRINT(".");
	}
    }

    if (srcmedia != TAPE || (srcmedia == TAPE && tapeversion == 'A')) {
	VPRINT1("Copying the remove script.");
	get_file(pptr, GET_REMOVESH);
	NVPRINT(".");

	VPRINT1("Copying the product definition file.");
	get_file(pptr, GET_PRODDEF);
	NVPRINT(".");
    }

    result = check_for_approved_configuration(un.machine);
    if (result != 0) {
        if (result == -1 && enforce_approved_configurations) {
            PRINT "\nERROR: This product is NOT certified for use on your system hardware.\n");
            PRINT "Installation of the product will not continue.  Please contact\n");
            PRINT "Intergraph support for information on a fully certified version\n");
            PRINT "of the product.\n");
 
            LPRINT "\nERROR: This product is NOT certified for use on your system hardware.\n");
            LPRINT "Installation of the product will not continue.  Please contact\n");
            LPRINT "Intergraph support for information on a fully certified version\n");
            LPRINT "of the product.\n");
 
#if defined(__clipper__) || defined(clipper)
            warnings = fopen(warnfile, "a");
            if (warnings) {
                time(&warn_time);
                cftime(warnstr, "%b %e %T", &warn_time);
                fprintf(warnings, "%s : %s (%s): ERROR: Installation aborted\n",
                                warnstr, pptr->prodname, pptr->prodnumber);
                fprintf(warnings, "\tProduct is NOT certified for use on your system hardware.\n");
                fprintf(warnings, "\tPlease contact Intergraph support for information on a\n");
                fprintf(warnings, "\tfully certified version of the product.\n\n");
                fclose(warnings);
            }
#endif
            rstat = -1;
            goto install_errors;
        }
        else {
            PRINT "\nWARNING: This product is PRE-CERTIFIED for use on your system hardware.\n");
            PRINT "Installation of the product will continue, but you should contact\n");
            PRINT "Intergraph support for information on a fully certified version\n");
            PRINT "of the product.\n");
 
            LPRINT "\nWARNING: This product is PRE-CERTIFIED for use on your system hardware.\n");
            LPRINT "Installation of the product will continue, but you should contact\n");
            LPRINT "Intergraph support for information on a fully certified version\n");
            LPRINT "of the product.\n");
 
#if defined(__clipper__) || defined(clipper)
            warnings = fopen(warnfile, "a");
            if (warnings) {
                time(&warn_time);
                cftime(warnstr, "%b %e %T", &warn_time);
                fprintf(warnings, "%s : %s (%s): WARNING: \n", warnstr,
                                        pptr->prodname, pptr->prodnumber);
                fprintf(warnings, "\tProduct is PRE-CERTIFIED for use on your system hardware.\n");
                fprintf(warnings, "\tIt should be updated as soon as a fully certified version\n");
                fprintf(warnings, "\tbecomes available.  Please contact Intergraph support for\n");
                fprintf(warnings, "\tinformation on a fully certified version of the product.\n\n");
                fclose(warnings);
            }
#endif
        }
    }

    VPRINT1("Copying the install script.");
    if (get_file(pptr, GET_SCRIPT))
	goto finishup;

    NVPRINT(".\n");
    VPRINT1("Executing the install script.");
    if (srcmedia == TAPE)
	close_tape();
    else if (srcmedia == FLOPPY) {
	fileloc = 1;
	loc_write(fileloc);
    }

    /* set up the environment */
    strcpy(envstr1, "TMPDIR=");
    putenv(strcat(envstr1, tmpdirname));

#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
    /* if not on /usr and we're not on 5.3.0 unix, then SYMLINK=-s */
    if (strncmp(tmpdirname, "/usr/", 5) && strcmp(un.release, "3.0"))
	putenv("SYMLINK=-s");
    else
	putenv("SYMLINK=");
#else
    if (strncmp(tmpdirname, "/usr/", 5))
	putenv("SYMLINK=-s");
    else
	putenv("SYMLINK=");
#endif

    rstat = execute_script(pptr->srcdir, unixdir, installscript);


finishup:
    pptr->pstat &= 0xfff0;	/* clear out lower status bits */

    switch (rstat) {
    case 0:
    case 254: /* success */
	if (rstat == 254)
	    reboot = 1;
	unlink(installscript);

	/*
	 * If the product includes licensing data that must be integrated
	 * into the NetLS license database, do that now.
	 */
	sprintf(post, "%s/%s", tmpdirname, LICENSE_DATA);
	if (!access(post, R_OK)) {
	    PRINT "Installing licensing data.\n");
	    /*
	     * We found a "rule.dat" file.  See if we can install it.
	     */
	    sprintf(lic_data, "%s/%s", BASEDIR, LICENSE_MERGE);
	    if (!access(lic_data, X_OK)) {
		/* execute merging procedure */
		sprintf(command, "%s %s/%s", lic_data, tmpdirname, LICENSE_DATA);
		result = (system(command) >> 8) & 0xff;
		if (result != 0) {
		    /* Find error message corresponding to result */
		    for (i = 0; extract_errs[i].code != -1; i++ )
			if (extract_errs[i].code == result)
			    break;

		    if (extract_errs[i].code != -1) {
		        PRINT "ERROR: Licensing data could not be installed:  %s\n",
    					extract_errs[i].message);
		        LPRINT "ERROR: Licensing data could not be installed:  %s\n",
    					extract_errs[i].message);
		    }
		    else {
		        PRINT "ERROR: Licensing data could not be installed.\n");
		        LPRINT "ERROR: Licensing data could not be installed.\n");
		    }
		    PRINT "       This product cannot be used until the licensing data is\n");
		    PRINT "       properly installed");
		    LPRINT "       This product cannot be used until the licensing data is\n");
		    LPRINT "       properly installed.\n");
		    if (verbose) PRINT ".\n");
		    goto install_errors;
 		}
		/* DON'T REMOVE THE LICENSE DATA AFTERWARDS! */
	    }
	    else {
		/*
		 * "extract" program is missing !
		 */
		PRINT "ERROR: You must have version 06.01.*.* of the I_LICENSE product\n");
		PRINT "       (SS**257) installed on your system before this product can\n");
		PRINT "       be used.  Please install I_LICENSE, and then re-install this\n");
		PRINT "       product");
		LPRINT "ERROR: You must have version 06.01.*.* of the I_LICENSE product\n");
		LPRINT "       (SS**257) installed on your system before this product can\n");
		LPRINT "       be used.  Please install I_LICENSE, and then re-install this\n");
		LPRINT "       product.\n");
		if (verbose) PRINT ".\n");
		goto install_errors;
	    }
	}


	NVPRINT("Cleaning up...\n");
	VPRINT("Moving the files to ", unixdir);
	rstat = move_product(unixdir);
	VPRINT("Removing temporary directory ", tmpdirname);
	my_rmdir(tmpdirname);
	NVPRINT("Cleanup complete.\n");

	/*
	 * Execute and remove a postinstall.sh that may exist.
	 */
	sprintf(post, "%s/%s", unixdir, POSTSCRIPTNAME);
	if (!access(post, R_OK)) {
	    VPRINT1("Executing the post installation script.");
	    if (execute_script(pptr->srcdir, unixdir, post)) {
		PRINT "WARNING: post-installation script did not complete successfully.\n");
	    }
	    unlink(post);
	}

	pptr->pstat |= DOWNLOAD_OK;
	make_config_entry(pptr, unixdir);
	free_space_check(tmpmntpoint, pptr, 1);
	PRINT "Successful installation: %s (%s)\n",
			pptr->prodname, pptr->prodnumber);
	PRINT "Product installed in the %s directory.\n", unixdir);
	if (logf) {
	    fprintf(logf, "Successful installation: %s (%s)\n",
				pptr->prodname, pptr->prodnumber);
	    fprintf(logf,"Product installed in the %s directory.\n",
				unixdir);
	}
	break;

install_errors:
    default:
	if (shared && !vardirexists) {
	    VPRINT1("Removing configuration directory.");
	    my_rmdir(vardirname);
	}
	VPRINT("Removing temporary directory ", tmpdirname);
	my_rmdir(tmpdirname);
	NVPRINT(".\n");
	pptr->pstat |= LOAD_ERRORS;
	PRINT "Unsuccessful installation: %s (%s)\n",
			pptr->prodname, pptr->prodnumber);
	LPRINT "Unsuccessful installation: %s (%s)\n",
			pptr->prodname, pptr->prodnumber);
	if (pptr->load_priority <= 540)
	   PRINT "\nWARNING: Please DO NOT reboot until this product is loaded successfully!\n");
	break;
    }

    PRINT "%s\n\n", dashes);

    if (srcmedia == TAPE && open_tape() < 0) {
	PRINT "Cannot open tape device\n");
	exit(1);
    } else if (srcmedia == FLOPPY)
	fileloc = loc_read();

    return(rstat);
}

int    preprocess(currloc, pptr)
int	currloc;
register struct prodnode *pptr;
{
    int		rstat = -1;
    int		result;
    short	vardirexists = 0;
    char	*c;
    char	tmpdirname[STRSIZ];	/* this is where new product received */
    char	vardirname[STRSIZ];
    char	unixdir[STRSIZ];	/* product's final resting place */
    static char	savefs[STRSIZ] = "";
    static char	envstr1[STRSIZ];
    static char	envstr2[STRSIZ];
    FILE        *warnings = NULL;
    time_t      warn_time;
    char        warnstr[64];

    PRINT "\n%s\n", dashes);
    PRINT "Preprocessing: %s (%s)\n", pptr->prodname, pptr->prodnumber);
    LPRINT "Preprocessing: %s (%s)\n", pptr->prodname, pptr->prodnumber);

    strcpy(savefs, basedir);

    if (currloc && pptr->loadeddir[0] != '\0') {
        strcpy(unixdir, pptr->loadeddir);
        strcpy(basedir, GetMountPoint(unixdir));
    } else if (pptr->unixdir[0] == '/') { /* handle absolute path */
        strcpy(unixdir, pptr->unixdir);
        strcpy(basedir, GetMountPoint(unixdir));
    } else {
        sprintf(unixdir, "%s/%s", basedir, pptr->unixdir);
    }

    VPRINT1("Making temporary directory.");
    if (mktmpdir(pptr->prodnumber, tmpdirname))
    	goto finishup;

    strcpy(ptmpdir, tmpdirname);

    if (shared) {
	c = strrchr(pptr->unixdir, '/');
	if (c == NULL)
	    c = pptr->unixdir;
	else
	    ++c;
#if defined(SVR4) && defined(NEWDIRS)
	sprintf(vardirname, "%s/var/opt/ingr/%s", sharedfs, c);
#else
	sprintf(vardirname, "%s/var/ingr/%s", sharedfs, c);
#endif
	if (access(vardirname, F_OK)) {
	    VPRINT1("Making configuration directory.");
	    makedir(vardirname, 040777, 0, 0);
	} else
		++vardirexists;
	strcpy(envstr2, "VARDIR=");
	putenv(strcat(envstr2, vardirname));
    }

    strcpy(basedir, savefs);

    cdrom_key_ok = 0;
    VPRINT1("Copying the README file.");
    if (get_file(pptr, GET_PS_README)) {
	if (get_file(pptr, GET_README)) {
	    VPRINT1("Copying the fixes file.");
	    if (get_file(pptr, GET_FIXFILE))
		goto finishup;

	    VPRINT1("Copying the features file.");
	    get_file(pptr, GET_FEATURES);
	    
	    VPRINT1("Copying the certnote file.");
	    get_file(pptr, GET_CERTNOTE);
	}
    }

    if (srcmedia != TAPE || (srcmedia == TAPE && tapeversion == 'A')) {
/*
	VPRINT1("Copying the remove script.");
	get_file(pptr, GET_REMOVESH);
*/
	VPRINT1("Copying the product definition file.");
	get_file(pptr, GET_PRODDEF);
    }

    result = check_for_approved_configuration(un.machine);
    if (result != 0) {
        if (result == -1 && enforce_approved_configurations) {
            PRINT "\nERROR: This product is NOT certified for use on your system hardware.\n");
            PRINT "Installation of the product will not continue.  Please contact\n");
            PRINT "Intergraph support for information on a fully certified version\n");
            PRINT "of the product.\n");
 
            LPRINT "\nERROR: This product is NOT certified for use on your system hardware.\n");
            LPRINT "Installation of the product will not continue.  Please contact\n");
            LPRINT "Intergraph support for information on a fully certified version\n");
            LPRINT "of the product.\n");
 
#if defined(__clipper__) || defined(clipper)
            warnings = fopen(warnfile, "a");
            if (warnings) {
                time(&warn_time);
                cftime(warnstr, "%b %e %T", &warn_time);
                fprintf(warnings, "%s : %s (%s): ERROR: Installation aborted\n",
                                warnstr, pptr->prodname, pptr->prodnumber);
                fprintf(warnings, "\tProduct is NOT certified for use on your system hardware.\n");
                fprintf(warnings, "\tPlease contact Intergraph support for information on a\n");
                fprintf(warnings, "\tfully certified version of the product.\n\n");
                fclose(warnings);
            }
#endif
            rstat = -1;
            goto finishup;
        }
	else {
            PRINT "\nWARNING: This product is PRE-CERTIFIED for use on your system hardware.\n");
            PRINT "Installation of the product will continue, but you should contact\n");
            PRINT "Intergraph support for information on a fully certified version\n");
            PRINT "of the product.\n");
	}
    }

    VPRINT1("Copying the install script.");
    if (get_file(pptr, GET_SCRIPT))
	goto finishup;

    VPRINT1("Executing the install script.");
    if (srcmedia == TAPE)
	close_tape();
    else if (srcmedia == FLOPPY) {
	fileloc = 1;
	loc_write(fileloc);
    }

    /* set up the environment */
    strcpy(envstr1, "TMPDIR=");
    putenv(strcat(envstr1, tmpdirname));
    rstat = execute_script(pptr->srcdir, unixdir, installscript);

finishup:
    unlink(installscript);

    PRINT "%s\n\n", dashes);

    if (srcmedia == TAPE && open_tape() < 0) {
	PRINT "Cannot open tape device\n");
	exit(1);
    } else if (srcmedia == FLOPPY)
	fileloc = loc_read();

    return(rstat);
}

/*
 * review the release notes file for the product passed in.
 */
int	review(pptr)
register struct prodnode	*pptr;
{
    char	command[STRSIZ];
    int	file = 0;
    
    chdir("/tmp");
    
    PRINT "Copying the release notes file for %s (%s)\n",
    			pptr->prodname, pptr->prodnumber);
    cdrom_key_ok = 0;
    if (get_file(pptr, GET_PS_README)) {
	if (get_file(pptr, GET_README)) {
	    if (get_file(pptr, GET_FIXFILE)) {
		PRINT "No release notes file provided for this product. Sorry.\n\n");
	        PRINT "Press <Return> to return to the menu: ");
		getchar();
	        fflush(stdin);
    	        return(1);
            }
	    file = 1;
	} else 
    	    file = 2;
    } else
        file = 2;

    if (file) {
#if defined(SVR4) && defined(NEWDIRS)
        sprintf(command, "%s/bin/rm_pg %s", ingrhome, file == 1 ? FIXES_FILE : README_FILE);
#else
        sprintf(command, "/usr/bin/rm_pg %s", file == 1 ? FIXES_FILE : README_FILE);
#endif
	system(command);
	unlink( file == 1 ? FIXES_FILE : README_FILE );
    }
    return(0);
}

/*
 * Show help info from features file
 */
int	showhelp(pptr)
register struct prodnode *pptr;
{
    FILE	*inf, *pgf;
    char	str[STRSIZ];
#ifndef SunOS_4
    char	*command = "/usr/bin/pg -np \"page %d: <Space> = continue, - = go backward, q = quit ---> \"";
#else
    char	*command = "/usr/ucb/more";
#endif
    int	found = 0;
    int	file = 0;
    extern FILE	*popen();

    chdir("/tmp");

    PRINT "Copying the release notes file for: %s (%s)\n",
		pptr->prodname, pptr->prodnumber);
    cdrom_key_ok = 0;
    if (get_file (pptr, GET_PS_README)) {
	if (get_file(pptr, GET_README)) {
	    if (get_file(pptr, GET_FEATURES)) {
		PRINT "No release notes file provided for this product. Sorry.\n\n");
	        PRINT "Press <Return> to return to the menu: ");
	        getchar();
	        fflush(stdin);
	        return(1);
	    }
	    file = 1;
        } else
	    file = 2;
    } else
    	file = 2;

    if (file) {
	PRINT "%s\n", dashes);

	if ((inf = fopen((file == 1 ? FEATURES_FILE : README_FILE), "r"))) {
	    while (!found) {
		if (fgets(str, STRSIZ, inf) == NULL)
		    break;
		if (!strncmp(str, (file == 1 ? "Help Information" : "Installation Help"), 16))
		    ++found;
	    }
	    if (!found)
		PRINT "No help information provided for this product. Sorry.\n\n");
	    else {
		signal(SIGPIPE, SIG_IGN);
		if ((pgf = popen(command, "w"))) {
		    do
			fprintf(pgf, "%s", str);
		    while ((fgets(str, STRSIZ, inf) != NULL) &&
			   (strncmp(str, "End of Installation Help", 23)));
		    pclose(pgf);
		}
		signal(SIGPIPE, lostpeer);
	    }
	    fclose(inf);
	}
	PRINT "%s\n", dashes);
	unlink( file == 1 ? FIXES_FILE : README_FILE );
    }
    fflush(stdin);
    return(0);
}

/*
 * parse info from product.def in unixdir and get the .prod files
 * documented there.
 *
 *
 * This has become VERY interesting with the advent of multi-platform
 * products and the resulting bogosity in the product.def file.
 *
 * Since all the files for all the platforms are in the FILE INFORMATION
 * section, we scan the "Description" field over to the right to discern
 * whether the file is meant for our platform or not.  If so, we get it.
 * This has to be iterated for each different platform we're "makenoding"
 * for...
 */
/*ARGSUSED*/
int	get_prod_files(arch, multi)
char *arch;
int  multi;
{
    char	line[STRSIZ];		/*max line len for install script*/
    char	command[STRSIZ];	/*command string for getfile*/
    char	*filename;		/*unix filename*/
    char	*desc;			/*description of file*/
    char	*str;
    int	found = 0;
    int	getstat;
    FILE	*f;

    if (strcmp(arch, "ALL") == 0) {
	VPRINT1("Copying product files for all platforms.");
    }
    else {
	VPRINT("Copying product files for platform ", arch);
      }

    if ((f = fopen("product.def", "r")) == NULL) {
	PRINT "Cannot open product.def for reading.\n");
	return(1);
    }

    str = ("#FILE INFORMATION");
    while (!found && fgets(line, 80, f))
	if (!strncmp(line, str, 15))
	    ++found;

    if (!found) {
	PRINT "Cannot locate product file name info.\n");
	fclose(f);
	return(1);
    }

    for (;;) {
	fgets(line, STRSIZ, f);
	if (line[0] == '\n' || (line[0] == '#' && line[1] == '#'))
	    continue;
	if (!strncmp(line, "#END OF", 7))
	    break;

	/* skip over leading blanks, #'s and tabs */
	for (filename = line; *filename == '#' || *filename == ' ' ||
			*filename == '\t'; ++filename)
	    ;

	if (*filename == '\n')
	    continue;


	if (filter_arch && multi) {
    	    /* Do this ONLY if the "-a" flag was used to limit the platforms
	     * loaded, AND the product is multi-platform.  (If it's a
             * single platform product, the user must want everything, since
             * he/she chose to load it.)
	     * If the architecture name is not contained within the description,
	     * AND the word "ALL" is not contained either, then skip this entry and
	     * continue to the next one.
	     */
    	    desc = strpbrk(filename, " \"'\t#");
	    if (desc != NULL) {
		if ((strstr(desc, arch) == NULL) && (strstr(desc, "ALL") == NULL))
		    continue;
	    }
	    else
		continue;
	}

	/* put a null at end of filename */
	if ((str = strpbrk(filename, "\n# \t")) != NULL)
	    *str = '\0';

	/*
	 * Don't ignore the fixes.com file. Allow older versions of
	 * newprod to get unixboot and deltools first. bpm -- 12/4/89
	 */
	if (filename[0] == '\n' ||
	    	!strcmp(filename, CERTNOTE_FILE) ||
	    	!strcmp(filename, FEATURES_FILE) ||
	    	!strcmp(filename, "product.def"))
	    continue;

	if (srcmedia == TAPE)
	    close_tape();
	else if (srcmedia == FLOPPY)
	    loc_write(fileloc);

	sprintf(command, "getfile -o %s %s", filename, filename);
	VPRINT("Copying product file -- ", filename);
	getstat = system(command);

	if (srcmedia == TAPE && open_tape() < 0) {
	    PRINT "Cannot open tape device\n");
	    exit(1);
	} else if (srcmedia == FLOPPY)
	    fileloc = loc_read();

	if (getstat) {
	    fclose(f);
	    return(-1);
	}
    }
    fclose(f);
    return(0);
}

/*
 * initialize a product brought down for makenode.
 * open prodlist file for reading
 * read prodlist file into table -- removing duplicate entries
 * replace/add new entry
 * write new table out
 */
void	initialize(arch, unixdir)
char *arch;
char *unixdir;
{
    int		i;
    char	line[ELSIZE], tab[TABSIZE][ELSIZE];
    char	line2[ELSIZE];
    char	*c, *p;
    char	filename[STRSIZ];
   /*
    * num#title#date#size#flags#srcpath#destpath#loadp#name#version#class#attr#arch
    */
    static char	*varname[] = {
	"IDnumber",
	"IDtitle",
	"IDdate",
	"DELsize",
	"DELflags",
	"DELdir",
	"DELloadp",
	"IDname",
	"IDversion",
	"IDclass",
	"DELattr",
	"DELarch",
	""
	};
    char	arch_varname[15][STRSIZ];
    char	vars[15][STRSIZ];
    unsigned	nel = 0;
    FILE	*f;


    /* We're not going to use pptr anymore.
     * Here's the scoop:
     * Open the product.def file.
     * Set all the pptr values from the assignments in the file.
     * variables that start with the arch name take precedence
     * over "Generic" settings.
     */
    
    for (i = 0; *varname[i] != '\0'; i++)
	vars[i][0] = '\0';

    strcpy(filename, unixdir);
    strcat(filename, "/product.def");
    if ((f = fopen(filename, "r")) == NULL) {
        PRINT "Cannot open %s for reading.\n", filename);
        return;
    }

    while (fgets(line, 80, f)) {
	/*
	 * Look for variables:
	 * IDnumber IDname IDtitle IDversion IDdate IDclass
	 * DELsize DELdir DELloadp DELattr DELarch
         */
	for (i = 0; *varname[i] != '\0'; i++) {
	    if (strncmp(line, varname[i], strlen(varname[i])) == 0) {
		/* Strip off trailing newline */
		c = strrchr(line, '\n');
		*c = '\0';

		/* skip over to assignment half of the line */
		c = line + strcspn(line, "=") + 1;

		if (*c == '\0')
		    continue;

		/* 
		 * Copy the variable, disposing of quote marks
		 */
		if (*c == '"') {
		    c++;
		    p = strrchr(c, '"');
		    *p = '\0';
		}
		else if (*c == '\'') {
		    c++;
		    p = strrchr(c, '\'');
		    *p = '\0';
		}
		strcpy(vars[i], c);
	    }
	}
    }
    rewind(f);
    while (fgets(line, 80, f)) {
	/*
	 * Look for variables:
	 * {arch}_IDnumber {arch}_IDname {arch}_IDtitle {arch}_IDversion
	 * {arch}_IDdate {arch}_IDclass {arch}_DELsize {arch}_DELdir
	 * {arch}_DELloadp {arch}_DELattr {arch}_DELarch
         *
         */
	for (i = 0; *varname[i] != '\0'; i++) {
	    sprintf(arch_varname[i], "%s_%s", arch, varname[i]);
	    if (strncmp(line, arch_varname[i], strlen(arch_varname[i])) == 0) {
		
		/* Get rid of trailing newline */
		c = strrchr(line, '\n');
		*c = '\0';

		/* Skip over the assignment half of the line */
		c = line + strcspn(line, "=") + 1;
		if (*c == '\0')
		    continue;
		/* 
		 * Copy the variable, disposing of quote marks
		 */
		if (*c == '"') {
		    c++;
		    p = strrchr(c, '"');
		    *p = '\0';
		}
		else if (*c == '\'') {
		    c++;
		    p = strrchr(c, '\'');
		    *p = '\0';
		}
		strcpy(vars[i], c);
	    }
	}
    }
    fclose(f);

    if ((f = fopen(makenodelist, "r")) == NULL) {
	f = fopen(makenodelist, "w");	/* create the file */
	fclose(f);
	f = fopen(makenodelist, "r");
    }

    while (fgets(line, ELSIZE, f) != NULL && nel < TABSIZE)
	lsearch(line, (char *)tab, &nel, ELSIZE, (int(*)(const void*, const void*))prodcmp);
    fclose(f);

    sprintf(line, "%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s\n",
	    vars[0],
	    vars[1],
	    vars[2],
	    vars[3],
	    vars[4],
	    unixdir,
	    vars[5],
	    vars[6],
	    vars[7],
	    vars[8],
	    vars[9],
	    vars[10],
	    arch);

    sprintf(line2, "%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#\n",
	    vars[0],
	    vars[1],
	    vars[2],
	    vars[3],
	    vars[4],
	    unixdir,
	    vars[5],
	    vars[6],
	    vars[7],
	    vars[8],
	    vars[9],
	    vars[10]);

    /*
     *  Look first to see if there is a pre-existing entry with
     *  the newer (with platform) format.
     */
    if (!lfind(line, (char *)tab, (size_t *)&nel, ELSIZE, (int(*)(const void*, const void*))prodcmp)) {
	/*
	 * We didn't find one, so look now for a pre-existing entry with
	 * the older (sans platform) format.
	 */
	if (lfind(line2, (char *)tab, (size_t *)&nel, ELSIZE, (int(*)(const void*, const void*))prodcmp))
	    c = (char *)lsearch(line2, (char *)tab, &nel, ELSIZE, (int(*)(const void*, const void*))prodcmp);
	else
	    c = (char *)lsearch(line, (char *)tab, &nel, ELSIZE, (int(*)(const void*, const void*))prodcmp);
    }
    else
	c = (char *)lsearch(line, (char *)tab, &nel, ELSIZE, (int(*)(const void*, const void*))prodcmp);


    /*
     * num#title#date#size#flags#srcpath#destpath#loadp#name#version#class#attr
     */

    sprintf(c, "%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s\n",
	    vars[0],
	    vars[1],
	    vars[2],
	    vars[3],
	    vars[4],
	    unixdir,
	    vars[5],
	    vars[6],
	    vars[7],
	    vars[8],
	    vars[9],
	    vars[10],
	    arch);

    f = fopen(makenodelist, "w");	/* open for writing */
    for (i = 0; i < nel; ++i)
	fprintf(f, "%s", tab[i]);
    fclose(f);
}

/*
 * Make a product part of a delivery node.
 */
int    makedelnode(currloc, pptr)
int	currloc;
register struct prodnode *pptr;
{
    int	rstat = -1;    /*load rstat, initialize to failure */
    char	tmpdirname[STRSIZ]; /*this is where new product received*/
    char	unixdir[STRSIZ];    /*product's final resting place*/
    char	tmpmntpoint[STRSIZ];    
    char	savefs[STRSIZ];
    static char	envstr[STRSIZ];
    char	del_arch[STRSIZ], del_arch2[STRSIZ];
    char	line[STRSIZ];
    char	prodname[32], prodver[32], prodarch[32];
    int		i, found, pos, arch_mask;
    int		platforms = 0;
    char	*c, *d;
    FILE	*f;

    /*
     * TR 2893001287
     *
     * Applications demanded that Makenode keep different
     * architectures separated, so downloading one version
     * wouldn't overwrite another.  Instead of making one
     * directory, then loading all the stuff into it, we
     * use a new directory path naming convention that keeps
     * them all separate.  This means that instead of:
     *
     *	    Make "makenode" directory
     *      Get product.def
     *      For each architecture
     *		Get files for that architecture
     *      Move files to final location
     *      For each architecture
     *          "Initialize" (add data to ws_s.prods) for app
     *
     * the model is now
     *
     *      Count architectures in pptr->arch
     *	    For each architecture
     *		Make "makenode" directory
     *		Get product.def
     *          Get files for the architecture
     *		Move files to final location
     *		Initialize for app
     */


    strcpy(savefs, basedir);

    PRINT "\n%s\n", dashes);

    filter_arch = 1;

    /*
     * 11/10/93
     * This isn't good enough, because now products may have
     * only one flag set in their pptr->arch area (separated
     * by platforms), but still refer to multiple architectures
     * in the product.def file.  Need to look for a "DELarch"
     * field in product.def and count the number of platforms
     * named there.
    for (pos = 0; pos < 32; pos++) {
	if (pptr->arch & (1<<pos))
	    platforms++;
    }
     */

    for (pos = 0; pos < NUM_ARCH && cpu_types[pos]; pos++) {

	memset(prodarch, 0, 32);
        arch_mask = (1<<pos);

        if (pptr->arch & arch_mask) {

	    /*
	     * Get name of current architecture
	     */
	    strcpy(prodarch, cpu_types[pos]);

	    /*
	     * Is product already loaded here?
	     */
	    if (currloc && pptr->loadeddir[0] != '\0') {
		strcpy(unixdir, pptr->loadeddir);
		strcpy(basedir, GetMountPoint(unixdir));
		strcpy(mountpoint, basedir);
	    }
	    else {
		/*
		 * Build a new destination directory.
		 * Make it from:
		 *	Product number
		 *	Architecture name
		 *	  (cause processor code 05 can be SUN *or*
		 *		 SPARC_SOLARIS)
		 *	Major/Minor version
		 */

		/*
		 * In 07.05.08.01, we left out the processor code
		 * from the directory name.  This turned out to be
		 * unwise, because there are two different processor
		 * codes (01 and 0J) that both "CLIPPER" architecture.
		 *
		 * This, in addition to the Sun situation above, means
		 * that we have to use processor code AND arch name
		 * when building a path.
		 *
		 * Using the 8th character (if it exists) also lets us
		 * differentiate by "localization".
		 */
		memcpy(prodname, pptr->prodnumber, 8);
		if (pptr->prodnumber[7]) {
		    prodname[7] = pptr->prodnumber[7];
		    prodname[8] = 0;
		}

		strcpy(prodver, pptr->prodversion);
		prodver[5] = 0;

		if (*prodarch)
		    sprintf(unixdir, "%s/%s/%s/%s", basedir, prodname, prodarch, prodver);
		else
		    sprintf(unixdir, "%s/%s/%s", basedir, prodname, prodver);

#ifdef OLD_WAY
		/*
		 * Before making the product directory, convert the
		 * product name to lower case, and change any '/' characters
		 * to '_'
		 */
		strcpy(prodname, pptr->prodname);
		for (c = prodname; *c; c++) {
		    if (*c == '/')
			*c = '_';
		    else
			*c = (char)tolower(*c);
		}
		sprintf(unixdir, "%s/%s", basedir, prodname);
#endif
	    }

	    /*
	     * convert the basename to lower case
	    for (c = strrchr(unixdir, '/'); *c != '\0'; ++c)
		*c = (char)tolower(*c);
	     */


	    PRINT "Making a delivery structure of: %s (%s) for %s\n", pptr->prodname, pptr->prodnumber, prodarch);
	    LPRINT "Making a delivery structure of: %s (%s) for %s\n", pptr->prodname, pptr->prodnumber, prodarch);

	    strcpy(tmpmntpoint, mountpoint);
	    if (free_space_check(mountpoint, pptr, 0)) {
		PRINT "Insufficient free space for loading.\n");
		strcpy(basedir, savefs);
		strcpy(mountpoint, GetMountPoint(basedir));
		goto cleanup;
	    }

	    if (mktmpdir(pptr->prodnumber, tmpdirname)) {
		strcpy(basedir, savefs);
		strcpy(mountpoint, GetMountPoint(basedir));
		goto cleanup;
	    }


	    strcpy(envstr, "TMPDIR=");
	    putenv(strcat(envstr, tmpdirname));

	    /*
	     * restore basedir to be what user requested,
	     * before product was loaded.
	     */
	    strcpy(basedir, savefs);
	    strcpy(mountpoint, GetMountPoint(basedir));

	    cdrom_key_ok = 0;

	    if (srcmedia != TAPE || (srcmedia == TAPE && tapeversion == 'A')) {
		VPRINT1("Copying the product definition file.");
		get_file(pptr, GET_PRODDEF);
	    }

	    /* 11/10/93
	     * Scan the product.def file for the DELarch setting
	     * and count the number of platforms listed there.
	     *
	     */
	    if ((f = fopen("product.def", "r")) == NULL) {
		PRINT "ERROR reading product definition file.\n");
		goto cleanup;
	    }
	    found = 0;
	    del_arch[0] = 0;
	    while (fgets(line, 80, f) != NULL) {
		if (strncmp(line, "DELarch=", 8) == 0) {
		    /* Strip off trailing newline */
		    c = strrchr(line, '\n');
		    if (c)
			*c = '\0';

		    /* skip over to assignment half of the line */
		    c = line + strcspn(line, "=") + 1;
		    if (*c == '"') {
			c++;
			d = strrchr(line, '"');
			if (d)
			    *d = '\0';
		    }

		    strcpy(del_arch, c);
		    found++;
		}
	    }
	    fclose(f);

	   if (!found || del_arch[0] == 0)
		strcpy(del_arch, "CLIPPER");

	    /*
	     * Go through the list of architectures specified in the product.def
	     * DELarch variable.  Count the number of platforms that are listed there.
	     */
	    strcpy(del_arch2, del_arch);
	    c = (char *)strtok(del_arch2, "|;:, ");
	    while (c != NULL) {
		for (i = 0; (i < NUM_ARCH) && (*cpu_types[i] != '\0'); i++) {
		    if (strcmp(c, cpu_types[i]) == 0)
			platforms++;
		}
		c = (char *)strtok(NULL, "|;:, ");
	    }
 	

	    if ((rstat = get_prod_files(prodarch, (platforms > 1))))
		goto cleanup;

	    /*
	     * Move and initialize the product, but first remove anything
	     * that's in the target directory first.
	     */
	    my_rmdir(unixdir);
	    chdir(tmpdirname);
	    rstat = move_product(unixdir);

	    VPRINT("Initializing product for platform ", prodarch);
	    initialize(prodarch, unixdir);


cleanup:
	    my_rmdir(tmpdirname);
#ifdef sun
	    if (strcmp(basedir, "/usr") != 0) {
		sprintf(tmpdirname, "%s/ip32", basedir);
		my_rmdir(tmpdirname);
	    }
#endif
	
	    pptr->pstat &= 0xfff0;	/* clear out lower status bits */
	    pptr->pstat |= (rstat ? LOAD_ERRORS : DELIVTREE);

	    if (rstat) {
		PRINT "Unsuccessful load: %s (%s) for %s\n", pptr->prodname, pptr->prodnumber, prodarch);
		LPRINT "Unsuccessful load: %s (%s) for %s\n", pptr->prodname, pptr->prodnumber, prodarch);
	    } else {
		free_space_check(tmpmntpoint, pptr, 1);
		PRINT "Successful load: %s (%s) for %s\n", pptr->prodname, pptr->prodnumber, prodarch);
		PRINT "Product loaded in the %s directory.\n", unixdir);
		LPRINT "Successful load: %s (%s) for %s\n", pptr->prodname, pptr->prodnumber, prodarch);
		LPRINT "Product loaded in the %s directory.\n", unixdir);
	    }
	}
    }
    PRINT "%s\n\n", dashes);
    return(rstat);
}

/*
 * This subroutine is called to compare the "load_priority" field of
 * two product structures. It is called by the C library routine
 * "qsort(3C)" and returns -1,0, or 1 to indicate if the load
 * priority of the first element is less than, equal, or greater than
 * the load priority of the second element. The arguments passed in
 * are pointers to prodnode structures.
 */
int	compar_priorities(pptr1, pptr2)
struct prodnode **pptr1, **pptr2;
{
    if (!pptr1 || !*pptr1)
	return(1);
    else if (!pptr2 || !*pptr2)
	return(-1);
    else if ((*pptr1)->load_priority < (*pptr2)->load_priority)
	return(-1);
    else if ((*pptr1)->load_priority > (*pptr2)->load_priority)
	return(1);
    else
	return(strcmp((*pptr1)->prodname, (*pptr2)->prodname));
}

int	act_on_products(optionlist, total, action)
struct prodnode	**optionlist;
int	total;
char	action;
{
    register int	i, j;
    int	fd;
    int	bookmark;
    int	bootstat;
    int	rstat = -1;
    int result = 0;
    int	count = 0;
    char	str[STRSIZ];
    char	str1[256], str2[256];
    char	*args[5];
    static char	envstr1[STRSIZ], envstr2[STRSIZ], envstr3[STRSIZ], envstr4[STRSIZ];
    static char	command[256];
    struct prodnode	*pptr;
    FILE	*bomf;
    extern struct prodnode	*map_product();
    extern void make_fslist(), restore_fslist(), capture_fslist(), remove_fslist();
    putenv(verbose ? "VERBOSE=-v" : "VERBOSE=");
    if (action == INSTALL || action == INSTALLBASE || action == PREPROCESS ||
	action == PREPBASE) {
	/*
	 * sort install order by load priorites
	 */
	qsort((char *)optionlist, total, sizeof(struct prodnode *),
		(int (*)(const void *, const void *))compar_priorities);
	
	signal(SIGPIPE, SIG_DFL);
	
	make_fslist();
	
	putenv("PREPROCESS=y");

	for (i = 0; i < total; ++i) {
	    if (!optionlist[i])
		continue;
	    
	    if (!(optionlist[i]->attr & ATTR_PREPROCESS))
		continue;
	    
	    /*
	     * If we've got the DEFAULTS flag set, then we may not
	     * need to do this.  But if it's a BOM product, or the
	     * action we're undertaking is to only preprocess this
	     * product, then we need to do it anyway.
	     */
	    if (takedefaults && !(optionlist[i]->attr & ATTR_BOM) &&
		(action != PREPROCESS) && (action != PREPBASE))
		continue;
	    /*
	     * set up the environment for getfile, getanswer
	     */
	    strcpy(envstr1, "PRODNAME=");
	    putenv(strcat(envstr1, optionlist[i]->prodname));
	    strcpy(envstr2, "PRODNUMBER=");
	    putenv(strcat(envstr2, optionlist[i]->prodnumber));
	    strcpy(envstr3, "SRCDIR=");
	    putenv(strcat(envstr3, optionlist[i]->srcdir));
	    strcpy(envstr4, "PRODVERSION=");
	    putenv(strcat(envstr4, optionlist[i]->prodversion));
	    
	    if (takedefaults)
		putenv("DEFAULTS=y");
	    else
		putenv("DEFAULTS=n");
	    
	    if (action == INSTALLBASE || action == PREPBASE)
		rstat = preprocess(0, optionlist[i]);
	    else
		rstat = preprocess(1, optionlist[i]);
	    
	    putenv("DEFAULTS=n");   /* always turn it off */
	    
	    ++count;
	    
	    switch((unsigned)rstat) {
	    case 0:
		capture_fslist();
		/* Remove the temporary directory here, since
		 * the 'continue' statement short-circuits the
		 * end of the loop
		 */
		if (access(ptmpdir, R_OK) == 0) {
		    VPRINT("Removing temporary directory ", ptmpdir);
		    my_rmdir(ptmpdir);
		}
		continue;
	    case 255:
        LPRINT "act_on_products:Process BOM Product.\n"); 
		/*
		 * process a BOM product
		 * If there's no file "components", then assume it is a
		 * regular product and declare "Unsuccessful installation".
		 * If there is a components file, then append it into the
		 * options list, avoiding duplicate entries.
		 */
		if ((bomf = fopen(BOMFILE, "r")) != NULL) {
		    while (fgets(str, 128, bomf) != NULL) {
			str1[0] = 0;
			str2[0] = 0;
			result = sscanf(str, "%s %s", str1, str2);

			/*
			 *  1/27/94  TR 289404805
			 *
			 *  This is fun.  
			 *
			 *  Since Nancy "nazi pricebook queen"
			 *  Meadlock has been issuing 15 character part
			 *  numbers for UNIX products LONG before we had
			 *  a chance to change DELTOOLS to support them,
			 *  BOM products that have already made the
			 *  change to 15 char PNs have thad to carry
			 *  around 'components' files with 9 character
			 *  PNs in them.
			 *  (Because the older newprod would strip off
			 *  the last 6 characters as it read ws_s.prods.)
			 *
			 *  NOW that we support a full 15-character PN,
			 *  these 9-char component PNs don't get found
			 *  in the list.
			 *
			 *  SO if that's the case, we need to go back
			 *  and try to match again, but truncating
			 *  the comparison at 9 characters.
			 *  
			 *  We've added a flag to "map_product" that
			 *  indicates whether a truncated match should
			 *  be accepted.  We'll try for an exact match
			 *  FIRST, but then try a truncated match if
			 *  the first was unsuccessful.
			 *
			 */

			pptr = map_product(str1, &header, FALSE);
			if (pptr == NULL) {
			    VPRINT("No exact match in product list for product ", str1);
			    VPRINT1("Attempting partial match\n");
			    pptr = map_product(str1, &header, strlen(str1));
			    if (pptr == NULL) {
				PRINT "No match in product list for product: %s\n", str1);
				continue;
			    }
			}

			/*
			 * Add the product to the option
			 * list, but only if it doesn't
			 * exist already.
			 */
			for (j = 0; j < total; ++j)
			    if (optionlist[j] == pptr)
				break;
			if (j == total) {
			    optionlist[j] = pptr;
			    ++total;
			}
			if (*str2 != '\0') {
			    strcat(str2, "/");
			    if (optionlist[j]->unixdir[0] != '/') {
				strcat(str2, optionlist[j]->unixdir);
				strcpy(optionlist[j]->unixdir, str2);
				if (optionlist[j]->loadeddir[0])
				    strcpy(optionlist[j]->loadeddir, str2);
			    }
			}
		    }
		    fclose(bomf);
		    break;
		}
		/*
		 * Fall through -- treat as unsuccessful
		 */
	    default:
		optionlist[i]->pstat &= 0xfff0;	
		optionlist[i]->pstat |= LOAD_ERRORS;
		optionlist[i] = NULL;
		restore_fslist();
		break;
	    }
	    if (access(ptmpdir, R_OK) == 0) {
		VPRINT("Removing temporary directory ", ptmpdir);
		my_rmdir(ptmpdir);
	    }
	}
	putenv("PREPROCESS=n");
	if (action == PREPROCESS || action == PREPBASE) {
	    if (!count)
		PRINT "\n\nNone of the selected products have the capability to preprocess.\n\n");
	    return(rstat);
	}
	
        /*
	 * again, sort install order by load priorites in case a BOM product has been
	 * included.
	 */
	qsort((char *)optionlist, total, sizeof(struct prodnode *),
		(int (*)(const void *, const void *))compar_priorities);
	
	remove_fslist();
    }
    else if (action == MAKENODE || action == MAKEBASE) {
	/*
	 * sort install order by load priorites
	 */
	qsort((char *)optionlist, total, sizeof(struct prodnode *),
		(int (*)(const void *, const void *))compar_priorities);
    }
    putenv("PREPROCESS=n");
    for (i = 0; i < total; ++i) {
	/*
	 * skip over empty elements (possibly put there by ! exception
	 * from the command line)
	 */
	if (!optionlist[i])
	    continue;
	/*
	 * set up the environment for getfile, getanswer
	 */
	strcpy(envstr1, "PRODNAME=");
	putenv(strcat(envstr1, optionlist[i]->prodname));
	strcpy(envstr2, "PRODNUMBER=");
	putenv(strcat(envstr2, optionlist[i]->prodnumber));
	strcpy(envstr3, "SRCDIR=");
	putenv(strcat(envstr3, optionlist[i]->srcdir));
	strcpy(envstr4, "PRODVERSION=");
	putenv(strcat(envstr4, optionlist[i]->prodversion));
	
	switch (action) {
	case INSTALL:
	case INSTALLBASE:
	    /*
	     * If we've already preprocessed the prompts for
	     * this product (see above), then invoke it's install
	     * script with defaults turned on.
	     */
	    if (takedefaults || optionlist[i]->attr & ATTR_PREPROCESS) 
		putenv("DEFAULTS=y");
	    else
		putenv("DEFAULTS=n");
	    result = install(action == INSTALLBASE ? 0 : 1, optionlist[i]);
	    putenv("DEFAULTS=n");	/* always turn it off */
	    if (reboot == 1) { 
		/* This product's install.sh wants us to reboot
		 * Save our place and set up rc2 file to run
		 * newprod again after we start back up
		 */
		NVPRINT("The product just installed indicates that the system\n");
		NVPRINT("should now be rebooted.  This will be performed automatically.\n");
		VPRINT1("Preparing for system reboot...");
		if ((i+1) < total) {
		    sprintf(str1, "%s/%s", BASEDIR, RESTART);
		    if ((fd = open(str1, (O_RDWR|O_CREAT), 0700)) < 0) {
			perror("Can't create temporary file");
			exit(1);
		    }
		    else {
			for (bookmark = (i+1); bookmark < total; bookmark++) {
			    if (!optionlist[bookmark])
				continue;
			    write(fd, (char *)optionlist[bookmark], sizeof(struct prodnode));
			}
			close(fd);
			if ((fd = open("/etc/rc2.d/S99newprod", (O_RDWR|O_CREAT), 0700)) < 0) {
			    perror("Can't create restart file");
			    exit(1);
			}
			
#if defined(SVR4) && defined(NEWDIRS)
			sprintf(command, "%s/bin/newprod -Z ", ingrhome);
#else
			sprintf(command, "/usr/bin/newprod -Z ");
#endif
			
			if (takedefaults)
			    strcat(command, "-y ");
			if (debug)
			    strcat(command, "-X ");
			if (minus_x)
			    strcat(command, "-x ");
			if (verbose)
			    strcat(command, "-v ");
			
			switch (srcmedia) {
			case VAX:
			case WORKSTATION:
			case TCPIP:
			    strcat(command, "-n ");
			    strcat(command, connstr);
			    break;
			case NETCDROM:
			    strcat(command, "-r "); 
			    strcat(command, connstr);
			    break;
			case DIRECTORY:
			    strcat(command, "-D ");
			    strcat(command, localdir);
			    break;
			case FLOPPY:
			    strcat(command, "-f");
			    break;
			case CDROM:
			    strcat(command, "-c");
			    break;
			case TAPE:
			    strcat(command, "-t");
			    break;
			}
			strcat(command, "\n");
			write(fd, command, strlen(command));
			close(fd);
		    }
		}
		sync();
		sync();
		args[0] = shell;
		args[1] = "/etc/shutdown";
		args[2] = "-i6";
		args[3] = NULL;
		bootstat = execv(shell, args);
		if (bootstat < 0) {
		    perror("REBOOT FAILED!");
		    exit(1);
		}
	    }
	    break;
	case MAKENODE:
	case MAKEBASE:
	    result = makedelnode(action == MAKEBASE ? 0 : 1, optionlist[i]);
	    break;
	case REVIEW:
	    result = review(optionlist[i]);
	    break;
	case HELP:
	    result = showhelp(optionlist[i]);
	    break;
	}

	if (rstat == -1) {
	    if (result == 0)
		rstat = 0;
	    else
		rstat = 11;
	}
	else if (rstat == 0 && result != 0)
	    rstat = 1;
    }
    
    if (action == INSTALL || action == INSTALLBASE)
        signal(SIGPIPE, lostpeer);
        return(rstat);
}
