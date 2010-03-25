#include	<stdlib.h>
#include	<stdio.h>
#include	<sys/types.h>
#ifndef SVR3
#include	<sys/wait.h>
#endif
#if !defined(_AIX) && !defined(SCO)
#include	<sys/mtio.h>
#else
#include	<sys/tape.h>
#endif
#include	<sys/stat.h>
#if defined(SVR4) && !defined(sgi)
#include	<sys/statvfs.h>
/* HP added here -- MVR 30 Apr 1994*/
#elif defined(SunOS_4) || defined(HP_UX)
#include	<sys/vfs.h>
#else
#include	<sys/statfs.h>
#endif
#include	<sys/utsname.h>
#include	<unistd.h>
#include	<utime.h>
#include	<signal.h>
#include	<string.h>
#include	<fcntl.h>
#include	<errno.h>
#include	"defs.h"

#define PRODLIST		"ws_s.prods"
#define	VAX_DIR			"pro_dd_cfg:"
#define	VAX_SCRIPT_DIR		"pro_dd_deltools:"
#define	WS_DIR			"./"
#define SCRIPT			"newprodinfo.sh" /* startup/stop script name */
#define BETA_SCRIPT		"beta.sh"
#define RING			".cmsdr."
#define BEGIN			"BEGIN"
#define END			"END"
#define	EXECUTABLE		0111		/* executable mode*/
#define	UMASK			022		/* rwxr-xr-x */

short	no_ksh = 0;
short	srcmedia;	/* source of product installation*/
short	takedefaults = 0;	/* set if "-y" or "-d" flag in argv*/
short	verbose = 0;	/* set if "-v" flag found in the argv list*/
short	debug = 0;	/* set if "-X" flag found in the argv list*/
short	minus_x = 0;	/* set if "-x" flag found in argv*/
short	minus_b = 0;	/* set if "-b" flag found in argv*/
short	makenode = 0;	/* whether this is the makenode utility or not */
short	waitfor = 0;	/* should we wait for <CR> before run of install.sh */
short	shared = 0;	/* is this a shared delivery? */
short	enforce_approved_configurations = 1;
unsigned short cdtype = 0, sssn = 0;
char	warnfile[STRSIZ]; /* error messages from config check */ 
char	action = INSTALL; /* default action is to install products */
char	progname[STRSIZ];

char	deltools_home[STRSIZ];
char	*ingrhome;

char	basedir[STRSIZ] = "";	/* directory where user wants ws stuff*/
char	mountpoint[STRSIZ];	/* filesys mounted for ws stuff*/
char	sharedfs[STRSIZ];	/* directory to put shared ws stuff*/
char	ws_prodlist[STRSIZ];	/* name of file where prodlist goes*/
char	makenodelist[STRSIZ];	/* product list name */
char	connstr[STRSIZ];	/* logical name/address of delivery node */
char	localdir[STRSIZ];	/* local directory location for -D option */
char	*configfile = NULL;
char	*shell = "/bin/sh";
char	*tape_device = NULL;	/* file spec of the tape device*/
char	*errstr;		/* error string returned by fmu calls*/
FILE	*logf = NULL;		/* log file fd */

unsigned long filter_arch = 1;

#ifdef NEW_ARCHITECTURES

#ifndef USE_DEFINITION_FILE

#if (defined(clipper) || defined(__clipper__)) && defined(SVR3)
unsigned long	my_arch = CLIPPER_ARCH;
char	installscript[15]	= {"install.sh"};
char	removescript[15]	= {"remove.sh"};
char	*machine = "clip";
#define ARCH_MAGIC	0000577
#endif

#if (defined(clipper) || defined(__clipper__)) && defined(SVR4)
unsigned long	my_arch = C_SVR4_ARCH;
char	installscript[15]	= {"install.cv4"};
char	removescript[15]	= {"remove.cv4"};
char	*machine = "cio";
#define	ARCH_MAGIC	0000577
#endif

#if defined(sun) && defined(SunOS_4)
unsigned long	my_arch = SUN_ARCH;
char	installscript[15]	= {"install.sun"};
char	removescript[15]	= {"remove.sun"};
char	*machine = "sun";
#define ARCH_MAGIC	0100403
#endif

/* ifdef HP added here -- MVR 30 Apr 1994 */
#ifdef HP_UX
unsigned long	my_arch = H_HPUX_ARCH;
char	installscript[15]	= {"install.hp"};
char	removescript[15]	= {"remove.hp"};
char	*machine = "hp";
#define ARCH_MAGIC	0001013
#endif

#if defined(sun) && defined(SVR4)
# if defined(sparc)
unsigned long my_arch = S_SOLARIS_ARCH;
char	installscript[15]	= {"install.ssl"};
char	removescript[15]	= {"remove.ssl"};
char	*machine = "ssl";
#define ARCH_MAGIC	077505
# elif defined(i386)
unsigned long my_arch = I_SOLARIS_ARCH;
char	installscript[15]	= {"install.isl"};
char	removescript[15]	= {"remove.isl"};
char	*machine = "isl";
#define ARCH_MAGIC	042577
# endif
#endif

#ifdef _AIX
unsigned long my_arch = RS6000_ARCH;
char	installscript[15]	= {"install.rs6"};
char	removescript[15]	= {"remove.rs6"};
char    *machine = "rs6";
#define ARCH_MAGIC      0000737
#endif

#if defined(sgi)
unsigned long my_arch = M_SVR3_ARCH;
char	installscript[15]	= {"install.sgi"};
char	removescript[15]	= {"remove.sgi"};
char	*machine = "sgi";
#define ARCH_MAGIC	0000540	
#endif

#ifdef SCO
unsigned long my_arch = I_SVR3_ARCH;
char	installscript[15]	= {"install.sco"};
char	removescript[15]	= {"remove.sco"};
char	*machine = "sco";
#define ARCH_MAGIC	0000514
#endif


char	*cpu_types[16] = {
    "CLIPPER",
    "VAX",
    "SUN",
    "RS6000",
    "CLIPPER_SVR4",
    "CLIPPER_NT",
    "SPARC_SOLARIS",
    "INTEL_SOLARIS",
    "INTEL_SCO",
    "INTEL_NT",
    "MIPS_IRIX",
    "MIPS_OSF",
    "MIPS_NT",
    "HPPA_HPUX",
    ""
};

#else 		/* read definition file for architecture info
		   and defined CPU types*/

unsigned long	my_arch;
char	installscript[15];
char	removescript[15];
char	*machine;
char *cpu_types[32];

#endif		/* USE_DEFINITION_FILE */

#else 		/* ! NEW ARCHITECTURES */

#if defined(clipper) || defined(__clipper__)
unsigned long  my_arch = CLIPPER_ARCH;
char	installscript[15]	= {"install.sh"};
char	removescript[15]	= {"remove.sh"};
char    *machine = "clip";
#define ARCH_MAGIC      0000577
#endif

#ifdef sun
unsigned long  my_arch = SUN_ARCH;
char    installscript[15]       = {"install.sun"};
char    removescript[15]        = {"remove.sun"};
char    *machine = "sun";
#define ARCH_MAGIC      0100403
#endif

#ifdef _AIX
unsigned long my_arch = RS6000_ARCH;
char    installscript[15]       = {"install.rs6"};
char    removescript[15]        = {"remove.rs6"};
char	*machine = "rs6";
#define ARCH_MAGIC	0000737
#endif

char    *cpu_types[16] = {
    "CLIPPER",
    "VAX",
    "SUN",
    "MIPS",
    "HP-PA",
    "RS6000",
    "APOLLO",
    ""
};
#endif	/* NEW_ARCHITECTURES */

#define SLOT	623691234

struct prodnode header;	/*head of the product node list*/
struct prodnode classheader;	/*head of the class list*/
struct utsname un;	/*used for system identification */
struct stat statbuf;	/*used to determine if certain executables exist*/

extern int	fileloc;
extern short	allvis;
extern char	cdrel[16];
extern short	iso_9660;
short	foldcase = 0;	/* Set to "1" if we have to use ALL CAPS to access
			 * files on ISO9660 CD/ROMs or "2" if we have to
			 * use all lowercase.
			 */

extern short	curses_is_running;
extern char	*strchr();
extern char	*strrchr();
extern char	*GetMountPoint();
extern char	*find_loaded_location();
extern void	get_tape_file();	/*function for making shell variables */
extern int	mountfs();
extern int	copy_file();
extern void	getmakenodedir();
extern struct prodnode *map_product();

/*
 * This routine is called to create a subprocess to execute the
 * newprod info shell script. It will fork and exec the child
 * process and wait on the return value from the child. The value
 * returned by the child is passed back as the return value of this
 * function.
 */
int	execute_info_script(script, when)
char	*script;
char	*when;
{
	int	rstat;		/* routine retval, also syscall return values*/
	char	*args[4];	/* build execv args here*/

	if (access(script, R_OK) < 0)
		return(0);	/* could not find the script, return ok */
	if ((rstat = fork()) >= 0) {
		if (rstat)
			wait(&rstat);
		else {
			args[0] = shell;
			args[1] = script;
			args[2] = when;
			args[3] = 0;
			rstat = execv(shell, args);
		}
	}
#ifdef SVR3
	return(rstat);
#else
	return(WEXITSTATUS(rstat));
#endif
}

/*
 * This subroutine performs initial checking to ensure the executables
 * used by this utility and the "install.sh" files are present, checks
 * to make sure that we are running as super-user, and checks to make
 * sure that the device that we are to install to is mounted.
 */
int	basic_checks()
{
	char	tmpname[STRSIZ];	/*build name of tmp directory here*/
	char	*result;
	char	*tmp;
	extern char	*ws_mount_check();
#if defined(SVR4) && defined(NEWDIRS)
	int	i;
	static char	*man_sects[32] = {
                "man1",
                "man1b",
                "man1c",
                "man1f",
                "man1m",
                "man1s",
                "man2",
                "man3",
                "man3b",
                "man3c",
                "man3e",
                "man3g",
                "man3i",
                "man3k",
                "man3m",
                "man3n",
                "man3r",
                "man3s",
                "man3x",
                "man4",
                "man4b",
                "man5",
                "man6",
                "man7",
                "man9",
                "man9e",
                "man9f",
                "man9s",
                "manl",
                "mann",
                ""
                };
#endif


	/*
	 * check to make sure that we're super-user
	 */
	if (geteuid() != 0) {
		PRINT "Must be super-user to execute!\n");
		LPRINT "Must be super-user to execute!\n");
		return(1);
	}

#if defined(SVR4) && defined(NEWDIRS)
	/*
	 * Make sure INGRHOME directory exists.
	 */

        if (access(ingrhome, F_OK)) {
            LPRINT "NOTE:  The %s directory does not exist.\n", ingrhome);
            PRINT "NOTE:  The %s directory does not exist.\n", ingrhome);
            PRINT "Do you want it created now?  [y]: ");
            gets(tmpname);
            if (toupper(tmpname[0]) == 'Y')
                makedir(ingrhome, 040755, 0, 0);
            else {
                PRINT "Can't continue without an INGRHOME directory.\n");
                LPRINT "Can't continue without an INGRHOME directory.\n");
                return(1);
            }
        }

        /*
         * Make sure "INGRHOME" directory is writable.
         */

        if (access(ingrhome, W_OK)) {
            PRINT "ERROR: %s directory is not writable\n", ingrhome);
            LPRINT "ERROR: %s directory is not writable\n", ingrhome);
            return(1);
        }

        /*
         * Make sure that common "bin", "man", "lib" and "include"
         * directories  under INGRHOME are present.
         */

        sprintf(tmpname, "%s/bin", ingrhome);
        if (access(tmpname, F_OK))
            makedir(tmpname, 040755, 0, 0);

        sprintf(tmpname, "%s/man", ingrhome);
        if (access(tmpname, F_OK))
            makedir(tmpname, 040755, 0, 0);

        for (i = 0; *man_sects[i]; i++) {
            sprintf(tmpname, "%s/man/%s", ingrhome, man_sects[i]);
            if (access(tmpname, F_OK))
                makedir(tmpname, 040755, 0, 0);
        }

        sprintf(tmpname, "%s/lib", ingrhome);
        if (access(tmpname, F_OK))
            makedir(tmpname, 040755, 0, 0);

        sprintf(tmpname, "%s/include", ingrhome);
        if (access(tmpname, F_OK))
            makedir(tmpname, 040755, 0, 0);

#endif
	/*
	 * make sure base file system is mounted
	 * if the user's loading to a shared fs, then let them load it anywhere
	 */
	if (!shared) {
		result = ws_mount_check(basedir);
		if ( result == NULL)
			return(1);
		else
			strcpy(mountpoint, result);

		/*
		 * Make sure base file system has a tmp directory
		 */
		sprintf(tmpname, "%s/tmp", mountpoint);
		if (makedir(tmpname, 040777, 0, 0)) {
			PRINT "Can't create directory %s!\n", tmpname);
			LPRINT "Can't create directory %s!\n", tmpname);
			return(1);
		}
	}

	/*
	 * make sure we have a mount directory
	 */
	if (srcmedia == FLOPPY || srcmedia == CDROM) {
		tmp = (srcmedia == FLOPPY ? FMNTDIR : MNTDIR);
		if ((makedir(tmp, 040777, 0, 0)) < 0) {
			PRINT "Can't create directory %s!\n", tmp);
			LPRINT "Can't create directory %s!\n", tmp);
			return(1);
		}
	}

#ifndef OSF
	/*
	 * use /bin/ksh if it exists
	 */
	if (access("/bin/ksh", X_OK) == 0) {
		shell = "/bin/ksh";
		putenv("SHELL=/bin/ksh");
		putenv("ENV=");		/* clear the ENV variable */
	}
	else {
		shell = "/bin/sh";
		putenv("SHELL=/bin/sh");
		no_ksh = 1;
	}
#else
	/*
	 * use /usr/sbin/ksh if it exists
	 */
	if (access("/usr/sbin/ksh", X_OK) == 0) {
		shell = "/usr/sbin/ksh";
		putenv("SHELL=/usr/sbin/ksh");
		putenv("ENV=");		/* clear the ENV variable */
	}
	else {
		shell = "/sbin/sh";
		putenv("SHELL=/sbin/sh");
		no_ksh = 1;
	}
#endif

#ifndef KEEP_USR_CLEAN
	/*
	 * force a link between /usr/bin/newprod and /usr/bin/getfile
	 * if no getfile exists do not exit out -- the user may be doing
	 * something wizardly
	 */
	if (access("/usr/bin/getfile", X_OK))
		link("/usr/bin/newprod", "/usr/bin/getfile");
#endif

	/*
	 * check for the cpio utility (at least)
	 */
	if (access(CPIO, X_OK)) {
		PRINT "Error: /bin/cpio non-existent or not executable!\n");
		return(1);
	}

	return(0);
}


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

#ifdef OLD_LOADKEY_METHOD
void	get_ring(source_file, dest_file)
char	*source_file;
char	*dest_file;
{
    int	fd;
    unsigned short magic;
    struct stat sbuf;
    long margin;
#if defined(SVR4) && !defined(sgi)
    struct statvfs sfsbuf;
#else
    struct statfs sfsbuf;
#endif
    char	dest_fs[STRSIZ];
    char	*c;
	
    if (stat(source_file, &sbuf) < 0) {
	PRINT "Warning:  keyed products cannot be loaded.\n");
	return;
    }
    else {
	strcpy(dest_fs, dest_file);
	c = strrchr(dest_fs, '/');
	if (*c)
		*c = '\0';

#if defined(SVR3) || defined(sgi)
	statfs(dest_fs, &sfsbuf, sizeof(struct statfs), 0);
#endif
#if defined(SVR4) && !defined(sgi)
	statvfs(dest_fs, &sfsbuf);
#endif
/* Added HP here -- MVR 7 May 1994 */
#if defined(SunOS_4) || defined(_AIX) || defined(HP_UX)
	statfs(dest_fs, &sfsbuf);
#endif
	margin = sfsbuf.f_bfree - 
		((sbuf.st_size + sfsbuf.f_bsize - 1) / sfsbuf.f_bsize);

	if (margin < 0) {
	    PRINT "Warning:  There is not enough space on the %s file system\n",
				GetMountPoint(dest_file));
	    PRINT "for the utilities needed to install keyed software.\n");
	    PRINT "You will need to free %ld blocks of disk space before \n", -margin);
	    PRINT "you can install keyed products.\n\n");
	    PRINT "Press any key to continue: ");
	    getc(stdin);
	    return;
        }
    }

    
    if ((fd = open(source_file, O_RDONLY)) < 0)
	return;
    else {
	/* Snip the magic number out of the file */
	read(fd, (char *)&magic, sizeof magic);
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
#endif

/*
 * This subroutine is invoked whenever any signals that would normally
 * result in termination are detected. It will close any open files
 * and, if installing from floppy, attempt to unmount the floppy file
 * system. At any rate, this guy calls exit(2) and we are done.
 */
void	terminate(status)
int	status;
{
	extern short	fsmounted;
	char	command[128];
	char	ws_ring[STRSIZ];

	if (curses_is_running)
	    endwin();

	switch (srcmedia) {
	case TAPE:
#ifdef _AIX
                tape_op(STREW, 1, 0);
#elif defined(SCO)
		tape_op(MT_REWIND, 1, 0);
#else
                tape_op(MTREW, 1, 0); /* rewind the tape */
#endif
		close_tape();
		break;

	case FLOPPY:
/* MVR added HP here -- 25 May 1994 */
#if defined(SunOS_4) || defined(HP_UX)
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
/* added HP here - MVR 25 May 1994 */
#elif defined(HP_UX)
			if ((unmountfs(MNTDIR) < 0) && (errno != EINVAL))
				perror("Unmount of /dev/dsk/cdrom failed");
#else
#ifdef sgi
			sprintf(command, "/etc/umount %s", CDROM_DEVICE);
			system(command);
#else
			if ((umount(CDROM_DEVICE) < 0) && (errno != EINVAL))
				perror("Umount of /dev/dsk/cdrom failed") ;
#endif
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

	if (logf)
		fclose(logf);

	sync(); sync();

	exit(status);
}

/*
 *  Special stripped-down "terminate" to use when the connection
 *  to the peer (delserve) is lost...  (terminate calls net_disconnect(),
 *  which tries to write to the peer.  This is senseless if the connection
 *  is gone...
 */
/*ARGSUSED*/
void	lostpeer(sig)
int	sig;
{
    if (curses_is_running)
	endwin();

    PRINT "*** FATAL ERROR: Lost connection to server; exiting...\n");
    if (logf)
	fclose(logf);

    sync(); sync();

    exit(2);
}



int	main(argc, argv)
int	argc;
char	**argv;
{
	int	i = 1;
	int	fd;
	int	exit_status = 0;
	int	next_opt;		/*next free slot in "opt_list"*/
	short	args = 0;   		/*set if prodnumbers on cmdline*/
	short	errflg = 0;		/*set if any "usage" errors occur*/
	char	srcprodlist[STRSIZ];	/*name of source product list file*/
	char	source_script[STRSIZ];	/*name of source script file*/
	char	ws_script[STRSIZ];	/*name of file where script goes*/
	char	source_beta_script[STRSIZ];/*name of source beta script file*/
	char	ws_beta_script[STRSIZ];	/*name of file where beta script goes*/
	char	source_ring[STRSIZ];
	char	ws_ring[STRSIZ];
	char	machines[STRSIZ];	/*list of target architectures for makenode*/
	int	machines_flag = 0;
	char	*mp;
	char	*envstr;		/*temporary string for environment */
	char	*prodlist = NULL;	/*name of product list file*/
	char	*tmpprodlist;
	char	*cp, *c;
	int	result;
	int	resume_flag = 0;
	int	passed_prodlist = 0;
	short	got_prodlist = 0;
	struct prodnode *elem;
	struct prodnode **opt_list;	/*allocated list of selected products*/
	extern char	*version;
	extern char	*optarg;
	extern int	optind, opterr; /*"getopt" variables*/
	extern short	multimenu;
	extern char	*net_connect(), *net_receive(), *net_error();
	extern char	*generate_key_filename();
	extern char	*generate_sn_filename();
	extern unsigned short cdtype;
	char   *lkfn, *snfn;
	FILE	*pfd;
	char	line[STRSIZ];

/* HP added here -- MVR 30 Apr 1994 */
#if defined(sun) || defined(HP_UX)
	int	llen;
#endif
#if defined(__clipper__) || defined(clipper)
	int	oldsize = 0;		/* Previous size of "delwarn" file */
#endif


	if ((envstr = strrchr(argv[0], '/')) != NULL)
		++envstr;
	else
		envstr = argv[0];
	if (!strcmp(envstr, "getfile"))
		exit(getfile(argc, argv));
	if (!strcmp(envstr, "makenode")) {
		++makenode;
		action = MAKENODE;
	}

	strcpy(progname, argv[0]);

	srcmedia = 0;
	multimenu = 1;
	umask(UMASK);
	uname(&un);	/* fill in the uname structure */


#if defined(SVR4) && defined(NEWDIRS)
        if ((c = getenv("INGRHOME")) && *c) {
            ingrhome = c;
            c = strchr(ingrhome, ':');
            if (c)
                *c = '\0';
        }
        else {
            PRINT "NOTE:  The INGRHOME environment variable is not set.\n");
            PRINT "%s will be used as the base directory for configuration files.\n", BASEDIR);
            sleep(5);
            ingrhome = BASEDIR;
            envstr = malloc(strlen(BASEDIR) + 16);
            sprintf(envstr, "INGRHOME=%s", ingrhome);
            putenv(envstr);
        }
        strcpy(basedir, ingrhome);
#elif defined(sun) && !defined(SVR4)
	ingrhome = BASEDIR;
	strcpy(basedir, "/home");
#else
	ingrhome = BASEDIR;
	strcpy(basedir, "/usr");
#endif

	/* If we're running as "makenode", make the default behavior
	 * be to accept products of all architectures.  Turn on all
	 * bits for the "my_arch" mask
	 */
	if (makenode) {
	    my_arch = 0xffffffff;
	    filter_arch = 0;
	}
		
	while ((i = getopt(argc, argv, "b:n:r:F:T:D:l:a:P:SsicdfmRtvwxyVXzZ")) != EOF) {
	    switch (i) {
	    case 's': /* Shared load */
		strcpy(installscript, "share.sh");
		shared++;
		break;

	    case 'S':
		enforce_approved_configurations = 0;
		break;

	    case 'V': /* show version number */
		PRINT "Version %s\n", version);
		exit(255);

	    case 'T': /* -T tapedevice */
		if (srcmedia != 0 && srcmedia != TAPE)
		    ++errflg;
		else {
		    srcmedia = TAPE;
		    if (tape_device = (char *)malloc(strlen(optarg) + 1))
			strcpy(tape_device, optarg);
		}
		break;

	    case 'F': /* -F prodlistname */
		if (prodlist = (char *)malloc(strlen(optarg) + 1)) {
		    strcpy(prodlist, optarg);
		    passed_prodlist++;
		}
		break;

	    case 't': /* tape source media */
		if (srcmedia)
		    ++errflg;
		else
		    srcmedia = TAPE;
		break;

	    case 'f': /* floppy source media */
		if (srcmedia)
		    ++errflg;
		else
		    srcmedia = FLOPPY;
		break;

	    case 'c': /* CDROM source media */
		if (srcmedia)
		    ++errflg;
		else
		    srcmedia = CDROM;
		break;

	    case 'r': /* network cdrom drive */
		if (srcmedia)
		    ++errflg;
		else {
		    srcmedia = NETCDROM;
		    strcpy(connstr, optarg);
		}
		break;

	    case 'n': /* network source media */
		if (srcmedia)
		    ++errflg;
		else {
		    srcmedia = NETWORK;
		    strcpy(connstr, optarg);
		}
		break;

	    case 'D': /* local directory */
		if (srcmedia)
		    ++errflg;
		else {
		    srcmedia = DIRECTORY;
		    strcpy(localdir, optarg);
		}
		break;

	    case 'R': /* review the fixes files instead of install */
		action = REVIEW;
		break;

	    case 'a':
		if (makenode) {
		    ++machines_flag;
		    my_arch = 0;
		    strcpy(machines, optarg);
		}
		else {
		    PRINT "Error: '-a' flag can be used only with makenode.\n");
		    exit(1);
		}
		break;

	    case 'i': /* show invisible products in the menu */
		++allvis;
		break;

	    case 'm': /* turn multi-menu mode off */
		multimenu = 0;
		break;

	    case 'w': /* wait for <RETURN> prior to run of install script*/
		++waitfor;
		break;

	    case 'z': /* pre-process install.sh answers only */
		action = PREPROCESS;
		break;

	    case 'X': /* turn on debug messages */
		++debug;
		putenv("DEBUG=y");
		break;

	    case 'v': /* turn on verbose output */
		++verbose;
		putenv("VERBOSE=-v");
		break;

	    case 'y': /* take defaults to all questions */
	    case 'd':
		++takedefaults;
		break;

	    case 'x': /* execute subshells with "-x" trace mode */
		++minus_x;
		break;

	    case 'l': /* log file */
		if ((logf = fopen(optarg, "a")) == NULL)
		    PRINT "Error opening log file \"%s\" for writing. Logging disabled.\n", optarg);
		break;

	    case 'b': /* destination filesystem */
		++minus_b;
		strcpy(basedir, optarg);
		break;

	    case 'P': /* Product list pathname for makenode */
		if (!makenode) {
		    PRINT "Error: '-P' flag can be used only with makenode.\n");
		    ++errflg;
		}
		else
		    strcpy(makenodelist, optarg);
		break;

	    case 'Z': /* RESUMING from a reboot */
		++resume_flag;
		break;

	    case '?':
		++errflg;
		break;

	    }
	}

	if (errflg) {
	    PRINT "Usage: %s [arguments] [product numbers]\twhere arguments are:\n", argv[0]);
	    PRINT "-n user@node.subdomain.domain:pass\n");
	    PRINT "			specify a network node (fully qualified domain name)\n");
	    PRINT "-n node.user.pass	specify a network node as the delivery source\n");
	    PRINT "-r user@node.subdomain.domain:pass\n");
	    PRINT "			specify a remote CD/ROM node (fully qualified domain name)\n");
	    PRINT "-r node.user.pass	specify a remote CD/ROM node as the delivery source\n");
	    PRINT "-c			deliver from cdrom\n");
	    PRINT "-t			deliver from tape\n");
	    PRINT "-T tapedev		specify the tape device [default = %s]\n", TAPE_DEVICE);
	    PRINT "-f			deliver from floppy\n");
	    PRINT "-D localdirectory	deliver from a local directory\n");
	    if (makenode)
		PRINT "-a			specify target architectures for makenode\n");
	    PRINT "-m			turn off classification menu\n");
	    PRINT "-i			show invisible products in the menu\n");
	    PRINT "-V			display the version\n");
	    PRINT "-v			select verbose mode\n");
	    PRINT "-x			select install script trace mode\n");
	    PRINT "-z			preprocess products (answer prompts only -- no installation)\n");
	    PRINT "-y			use default answers during installation\n");
	    PRINT "-R			review fixes files instead of updating\n");
	    PRINT "-l logfile		log installation status to logfile\n");
	    PRINT "-F prodlist		specify alternate product list file name\n");
	    if (makenode) {
		PRINT "-b basedir               specify directory to load to [default = /usr/ws_s]\n");
		PRINT "-P prodlist              specify location of product list to be updated\n");
		PRINT "                         for downloaded products [default = /ws_s.prods]\n");
	    }
	    else {
		PRINT "-b basefs		specify file system to load to [default = %s]\n", basedir);
	    }
	    exit(255);
	}

	if (basedir[0] == '\0') {
#if defined(SunOS_4) || (defined (sun) && defined(SVR4) && !defined(NEWDIRS))
	if (lstat("/home", &statbuf) == 0) {
	    if (S_ISLNK(statbuf.st_mode)) {
		/*
		 * /home is a symbolic link -- try to follow it.
		 */
		if (!(llen = readlink("/home", basedir, STRSIZ))) {
PRINT "NOTE:  Your /home directory is a symbolic link that could not be followed.\n");
PRINT "The default destination will be set to /usr; however, it is recommended\n");
PRINT "that you load products in file systems other than / and /usr if possible.\n");
		
LPRINT "NOTE:  Your /home directory is a symbolic link that cannot be followed.\n");
LPRINT "The default destination will be set to /usr; however, it is recommended\n");
LPRINT "that you load products in file systems other than / and /usr if possible.\n");
		    strcpy(basedir, "/usr");
		    sleep(5);
		}
		else {
		    /*
		     * We can follow it.  Does the destination exist?
		     */
		    basedir[llen] = '\0';
		    if (stat(basedir, &statbuf) == 0) {
			/*
			 * Is it a directory?
			 */
			 if (S_ISDIR(statbuf.st_mode)) {
			    /*
			     *  Can we write to it?
			     */
			    if (access(basedir, W_OK) == 0) {
PRINT "NOTE:  Since /home is a symbolic link to %s,\n", basedir);
PRINT "the default destination has been set to %s\n", basedir);
LPRINT "NOTE:  Since /home is a symbolic link to %s,\n", basedir);
LPRINT "the default destination has been set to %s\n", basedir);
				sleep(5);
			    }
			    else {
PRINT "NOTE:  /home is a symbolic link to %s, but that\n", basedir);
PRINT "destination cannot be written to.\n");
PRINT "The default destination will be set to /usr; however, it is recommended\n");
PRINT "that you load products in file systems other than / and /usr if possible.\n");

LPRINT "NOTE:  /home is a symbolic link to %s, but that\n", basedir);
LPRINT "destination cannot be written to.\n"); 
LPRINT "The default destination will be set to /usr; however, it is recommended\n");
LPRINT "that you load products in file systems other than / and /usr if possible.\n");
				strcpy(basedir, "/usr");
				sleep(5);
			    }
			}
			else {
PRINT "NOTE:  /home is a symbolic link to %s, but that\n", basedir); 
PRINT "destination is a file, not a directory.\n");
PRINT "The default destination will be set to /usr; however, it is recommended\n");
PRINT "that you load products in file systems other than / and /usr if possible.\n");
	    
LPRINT "NOTE:  /home is a symbolic link to %s, but that\n", basedir);
LPRINT "destination is a file, not a directory.\n");
LPRINT "The default destination will be set to /usr; however, it is recommended\n");
LPRINT "that you load products in file systems other than / and /usr if possible.\n");
			    strcpy(basedir, "/usr");
			    sleep(5);
			}
		    }
		    else {
PRINT "NOTE:  /home is a symbolic link to %s, but that\n", basedir);
PRINT "destination does not exist.\n");
PRINT "The default destination will be set to /usr; however, it is recommended\n");
PRINT "that you load products in file systems other than / and /usr if possible.\n");

LPRINT "NOTE:  /home is a symbolic link to %s, but that\n", basedir);
LPRINT "destination does not exist.\n");
LPRINT "The default destination will be set to /usr; however, it is recommended\n");
LPRINT "that you load products in file systems other than / and /usr if possible.\n");
			strcpy(basedir, "/usr");
			sleep(5);
		    }
		}
	    }
	    else if (strcmp("/home", GetMountPoint("/home")) != 0) {
		strcpy(basedir, "/usr");
		
PRINT "NOTE:  Your /home directory is not on a separate file system.\n");
PRINT "To avoid depleting space in the / (root) file system, the default \n");
PRINT "destination will be set to /usr; however, it is recommended that you\n");
PRINT "load products in file systems other than / and /usr if possible.\n");
		
LPRINT "NOTE:  Your /home directory is not on a separate file system.\n");
LPRINT "To avoid depleting space in the root file system, the default\n");
LPRINT "destination will be set to /usr; however, it is recommended that you\n");
LPRINT "load products in file systems other than / and /usr if possible.\n");
		
		sleep(5);
	    }
	    else
		strcpy(basedir, "/home"); 
	}
	else {
	    strcpy(basedir, "/usr"); 
PRINT "NOTE: You do not appear to have a %s directory.\n", BASEDIR);
PRINT "The default file system will be set to /usr; however, it is\n");
PRINT "recommended that you load products in file systems other than\n");
PRINT "/ (root) and /usr, if possible.\n");
	
LPRINT "NOTE: You do not appear to have a %s directory.\n", BASEDIR);
LPRINT "The default file system will be set to /usr; however, it is\n");
LPRINT "recommended that you load products in file systems other than\n");
LPRINT "/ (root) and /usr, if possible.\n");
	    
	    sleep(5);
	}
#endif /* SunOS_4 || (sun && SVR4 && !NEWDIRS) */

#if defined(SVR4) && defined(NEWDIRS)
	strcpy(basedir, ingrhome);
#endif

#if defined(SVR3) || defined(_AIX)
	strcpy(basedir, "/usr");
#endif
/* ifdef HP added here -- MVR 5 May 1994 */
#ifdef HP_UX
	strcpy(basedir,"/usr");
#endif
    }


        /* check for required utilities, uid, mount, etc... */
        if (basic_checks())
                exit(1);

        strcpy(deltools_home, find_loaded_location("DELTOOLS"));
        if (deltools_home[0] == '\0') {
            strcpy(deltools_home, basedir);
#ifdef SVR4
            strcat(deltools_home, "/deltools");
#else
            strcat(deltools_home, "/ip32/deltools");
#endif

        }



        /*
	 * Get our current processor type, and export it as an
	 * environment variable.
	 */

#if defined(__clipper__) || defined(clipper)
	if ((access("/bin/inqcpuid", X_OK) == 0) &&
			(pfd = popen("/bin/inqcpuid", "r"))) {
	    while (fgets(line, 128, pfd));
	    pclose(pfd);
	    i = strlen(line);
	    if (line[i-1] == '\n')
		line[i-1] = '\0';
	    envstr = (char *)malloc(9+i);
	    strcpy(envstr, "CPUTYPE=");
	    strcat(envstr, line);
	    putenv(envstr);
	}
	else {
	    PRINT "NOTE: Could not determine processor type; assuming C100.\n");
	    putenv("CPUTYPE=C100");
	    /*sleep(5);*/
	}
#endif
#ifdef sun
#  ifdef SunOS_4
#    define PROC_PROG	"/bin/arch"
/* look at /bin/uname for HP -- MVR 5 May 1994*/
#  elif defined(HP_UX)
     defined PROC_PROG  "/bin/uname"
#  else
#    define PROC_PROG	"/sbin/uname -m"
#  endif
	if (pfd = popen(PROC_PROG, "r")) {
	    while (fgets(line, 128, pfd));
	    pclose(pfd);
	    i = strlen(line);
	    if (line[i-1] == '\n')
		line[i-1] = '\0';
	    envstr = (char *)malloc(9+i);
	    strcpy(envstr, "CPUTYPE=");
	    strcat(envstr, line);
	    putenv(envstr);
	}
	else {
	    PRINT "NOTE: Could not determine application architecture; assuming sun4.\n");
	    putenv("CPUTYPE=sun4");
	    sleep(5);
	}
#endif

	if (logf) {
		fprintf(logf, "%s started. Arguments:", argv[0]);
		for (i = 1; i < argc; ++i)
			fprintf(logf, " %s", argv[i]);
		fprintf(logf, "\n");
	}

	if (machines_flag) {
	    filter_arch = 1;
	    mp = (char *)strtok(machines, "| ");
	    while (mp != NULL) {
		for (i = 0; (i < NUM_ARCH) && (*cpu_types[i] != '\0'); i++) {
		    if (strcmp(mp, cpu_types[i]) == 0)
			my_arch |= (1 << i);
		}
		mp = (char *)strtok(NULL, "| ");
	    }
	}

	if (optind < argc)		/*product numbers on the cmd line?*/
		args = optind;

	if (shared) {
	    /*
	     * export the shell variables used by share.sh, getanswer
	     */
	    strcpy(sharedfs, basedir);
	    strcat(basedir, "/usr");
	    
	    envstr = (char *)malloc(strlen(sharedfs) + 6);
	    strcpy(envstr, "ROOT=");
	    putenv(strcat(envstr, sharedfs));
	    
	    envstr = (char *)malloc(strlen(basedir) + 24);
	    sprintf(envstr, "ANSWERS=%s/.defaults", ingrhome);
	    putenv(envstr);
	    
	    if ((configfile = (char *)getenv("INGRCONFIG")) != NULL) {
		if (access(configfile, R_OK)) {
		    if ((fd = open(configfile, O_WRONLY)) < 0) {
			PRINT "ERROR: cannot create config file %s\n", configfile);
			exit(1);
		    }
		    else
			close(fd);
		}
	    }
	    else {
		envstr = (char *)malloc(strlen(basedir) + 28);
		sprintf(envstr, "INGRCONFIG=%s/ingrconfig", ingrhome);
		putenv(envstr);
	    }
	    
	    putenv("INSTALL_SHARED=y");
	}

	if (!srcmedia) {	/*was srcmedia specified on cmd line?*/
		srcmedia = get_src_media();
		fflush(stdin);
	}

	if (!prodlist) /* was prodlist specified on command line?? */
		prodlist = PRODLIST;

	sprintf(ws_prodlist, "/usr/tmp/%s", PRODLIST);
	sprintf(ws_script, "/usr/tmp/%s", SCRIPT);
	sprintf(ws_beta_script, "/usr/tmp/%s", BETA_SCRIPT);
	/*
	 * force their removal so they don't get confused with a previous
	 * delivery.
	 */
	unlink(ws_prodlist);
	unlink(ws_script);
	unlink(ws_beta_script);

	envstr = (char *)malloc(strlen(ws_prodlist) + 10);
	strcpy(envstr, "PRODLIST=");
	putenv(strcat(envstr, ws_prodlist));

	/*exit gracefully if we get one of these guys*/

	signal(SIGINT, terminate);
	signal(SIGQUIT, terminate);
	signal(SIGTERM, terminate);
	signal(SIGHUP, terminate);
	signal(SIGPIPE, lostpeer);

	if (srcmedia == NETWORK || srcmedia == NETCDROM) {
		chek_connstr(connstr);	/*assure reasonable connstr*/
		envstr = (char *)malloc(strlen(connstr) + 9);
		strcpy(envstr, "SRCDATA=");
		putenv(strcat(envstr, connstr));
	}

	switch (srcmedia) {
	case NETWORK:
	case NETCDROM:
	    /*
	     * figure out what protocol to use, FMU or TCP
	     * The srcmedia is also set to the correct type.
	     */
	    if ((errstr = net_connect(connstr))) {
		net_error(NET_CONNECT, errstr, TRUE);
		terminate(1);
	    }

	    switch (srcmedia) {
#ifdef XNS_NET
	    case VAX:
		sprintf(srcprodlist, "%s%s", VAX_DIR, prodlist);
		if (errstr = fmu_receive(srcprodlist, ws_prodlist)) {
		    net_error(NET_READ, errstr, TRUE);
		    terminate(2);
		}
		sprintf(source_beta_script, "%s%s", VAX_SCRIPT_DIR,
			BETA_SCRIPT);
		sprintf(source_script, "%s%s", VAX_SCRIPT_DIR, SCRIPT);
		fmu_receive(source_script, ws_script);
		fmu_receive(source_beta_script, ws_beta_script);
		putenv("SRCMEDIA=-V");
		break;
	    
	    case WORKSTATION:
		sprintf(srcprodlist, "%s%s", WS_DIR, prodlist);
		if (errstr = fmu_receive(srcprodlist, ws_prodlist)){
		    sprintf(srcprodlist, "/%s", prodlist);
		    if (errstr = fmu_receive(srcprodlist, ws_prodlist)) {
			    net_error(NET_READ, errstr, TRUE);
			    terminate(2);
		    }
		}
		sprintf(source_beta_script, "%s%s",WS_DIR, BETA_SCRIPT);
		sprintf(source_script, "%s%s", WS_DIR, SCRIPT);
		fmu_receive(source_script, ws_script);
		fmu_receive(source_beta_script, ws_beta_script);
		putenv("SRCMEDIA=-W");
		break;
#endif

	    case NETCDROM:
	    case TCPIP:
		if (net_get_server_version()) {
		    PRINT "ERROR: Cannot verify server version.\n");
		    terminate(2);
		}
		got_prodlist = 0;
		if (srcmedia == NETCDROM)
		    sprintf(srcprodlist, "%s/%s", MNTDIR, prodlist);
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
		}

		if (!got_prodlist) {
		    if (errstr = net_receive(srcprodlist, ws_prodlist, 0)) {
			if (srcmedia == NETCDROM) {
			    net_error(NET_READ, errstr, TRUE);
			    terminate(2);
			}
			sprintf(srcprodlist, "/%s", prodlist);
			if (errstr = net_receive(srcprodlist, ws_prodlist, 0)) {
			    net_error(NET_READ, errstr, TRUE);
			    terminate(2);
			}
		    }
		}

		if (srcmedia == NETCDROM) {
		    putenv("SRCMEDIA=-R");
		    net_get_load_key_file();
		    if (sssn)
		        net_get_sn_file();
		} else
		    putenv("SRCMEDIA=-N");

		DPRINT("prodlist found at ", srcprodlist);

		sprintf(source_script, "%s%s", WS_DIR, SCRIPT);
		if (net_receive(source_script, ws_script, 0)) {
		    sprintf(source_script, "/%s", SCRIPT);
		    if (net_receive(source_script, ws_script, 0)) {
			if (srcmedia == NETCDROM) {
			    sprintf(source_script, "%s/%s", MNTDIR, SCRIPT);
			    net_receive(source_script, ws_script,0);
			}
		    }
		}

		sprintf(source_beta_script, "%s%s", WS_DIR,BETA_SCRIPT);
		net_receive(source_beta_script, ws_beta_script, 0);
		break;
	    }
	    break;

	case DIRECTORY:
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
		    sprintf(srcprodlist, "%s/%s", localdir, prodlist);
		}
		else
		    got_prodlist++;
	    }
	    else
		sprintf(srcprodlist, "%s/%s", localdir, prodlist);

	    if (!got_prodlist) {
		if (copy_file(srcprodlist, ws_prodlist, TRUE, 0))
		    terminate(4);
	    }
	    sprintf(source_script, "%s/%s", localdir, SCRIPT);
	    copy_file(source_script, ws_script, FALSE, 0);
	    sprintf(source_beta_script, "%s%s", localdir, BETA_SCRIPT);
	    copy_file(source_beta_script, ws_beta_script, FALSE, 0);
	    putenv("SRCMEDIA=-D");
	    break;

	case FLOPPY:
	    if (!args) {
		PRINT "Insert a newprod product floppy and press <RETURN> ---> ");
		getchar();
	    }
	    if (mountfs(FLOP_DEVICE, FMNTDIR, 1))
		terminate(4);
	    fileloc = 1;
	    sprintf(srcprodlist, "%s/%s", FMNTDIR, prodlist);
	    if (copy_file(srcprodlist, ws_prodlist, TRUE, 0))
		terminate(4);
	    sprintf(source_script, "%s/%s", FMNTDIR, SCRIPT);
	    copy_file(source_script, ws_script, FALSE, 0);
	    putenv("SRCMEDIA=-F");
	    break;

	case CDROM:
	    if (!args) {
		PRINT "Insert a newprod CD/ROM and press <RETURN> ---> ");
		getchar();
	    }
	    if (mountfs(CDROM_DEVICE, MNTDIR, 1))
		terminate(4);
/* try these here to fix CD umount TR */
	    signal(SIGINT, terminate);
	    signal(SIGQUIT, terminate);
	    signal(SIGTERM, terminate);
	    signal(SIGHUP, terminate);
	    signal(SIGPIPE, lostpeer);

	    sprintf(srcprodlist, "%s/%s", MNTDIR, prodlist);

	    if (iso_9660) {
		/*
		 * First, see if the CD/ROM is able to support access
		 * to file names using lower case letters (this can
		 * be done if both the CD/ROM and the ISO9660 file
		 * system driver support the Rock Ridge Interchange
		 * Protocol, or if the disc has been mastered using
		 * lower-case file names, or if the file system
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
#if defined (sgi) || defined(SCO)
		    foldcase = LOWER;
		    putenv("FOLDCASE=LOWER");
#else
		    foldcase = 0;
#endif
		}
	    }

	    if (copy_file(srcprodlist, ws_prodlist, TRUE, 0))
		terminate(5);

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
		 *  In the new method, the loadkey verifier is delivered
		 *  with DELTOOLS itself.  We don't copy it off of the
		 *  product CD.
		 */
#endif
	    putenv("SRCMEDIA=-C");
	    break;

	case TAPE:
	    if (!tape_device)
		tape_device = TAPE_DEVICE;
	    get_tape_file();	/*function for making shell variables */

	    if (!args) {
		PRINT "Insert a newprod product tape and press <RETURN> ---> ");
		getchar();
	    }
	    if (open_tape() < 0) {
		PRINT "Error opening tape device %s.\n", tape_device);
		terminate(8);
	    }
	    confirm_delivery_tape(prodlist);
	    read_file_from_tape(ws_prodlist);
	    read_file_from_tape(ws_script);
	    putenv("SRCMEDIA=-T");
	}

	if (makenode)
		getmakenodedir();

	result = execute_info_script(ws_beta_script, BEGIN);
	if (result == 255 || result == -256)
		terminate(7);

	result = execute_info_script(ws_script, BEGIN);
	if (result == 255 || result == -256)
		terminate(7);

	/*
	 * prepare to read product list file
	 */

	classheader.blocksize = 0;
	classheader.prodclass[0] = '\0';
	classheader.flink = &classheader;
	classheader.blink = &classheader;
	header.blocksize = 0;
	header.flink = &header;
	header.blink = &header;

	if (srcmedia == NETCDROM)
		if (sssn)
		    get_key_data("/usr/tmp/keyfile","/usr/tmp/snfile");
		else
		    get_key_data("/usr/tmp/keyfile","'\0'");
	else if (srcmedia == CDROM){
		lkfn = generate_key_filename(srcprodlist);
	    	snfn = generate_sn_filename(srcprodlist);
		get_key_data(lkfn, snfn);
	}
	result = read_prodlist_file(ws_prodlist, &header);
	if (result < 0) {
		PRINT "Error reading product list file %s.\n", ws_prodlist);
		terminate(8);
	}
	else if (result == 0) {
		if (shared)
			PRINT "No shared products available.\n");
		else
			PRINT "There are no products available for your system.\n");
		terminate(8);
	}

	if (logf && (srcmedia == NETCDROM || srcmedia == CDROM))
		fprintf(logf, "CD/ROM release date: %s\n", cdrel);

#if defined(__clipper__) || defined(clipper)
    /*
     * Get current size of "delwarn" file.  We'll check later to see if
     * it grew.
     */
    sprintf(warnfile, "%s/%s", deltools_home, DELWARN);
    if (stat(warnfile, &statbuf) == 0)
        oldsize = statbuf.st_size;
    else
        oldsize = 0;
#endif

	if (!(opt_list = (struct prodnode **)calloc(1, header.blocksize *
		sizeof(struct prodnode *))))
		terminate(8);

	next_opt = 0;
	result = 0;
	if (resume_flag) {
	    sprintf(line, "%s/%s", deltools_home, RESTART);
	    if ((fd = open(line, O_RDONLY)) < 0) {
		perror("Can't open resumption file!");
		exit(1);
	    }
	    else {
		/* The file has a bunch of prodnode structures in it.
		 * Read them all in, and then jump into act_on_products.
		 */
		if ((elem = (struct prodnode *)calloc(1, sizeof(struct prodnode))) == NULL) {
		    perror("Can't malloc for product nodes");
		    exit(1);
		}
		while (read(fd, (char *)elem, sizeof(struct prodnode)) > 0) {
		    opt_list[next_opt++] = elem;
		    elem = (struct prodnode *)calloc(1, sizeof(struct prodnode));
		    if (elem == NULL) {
		       perror("Can't malloc for product nodes");
		       exit(1);
		    }
	        }
		close(fd);
		exit_status = act_on_products(opt_list, next_opt, INSTALL);
	    }
	}
	else if (args) {
		/*
		 * load products specified on command line
		 */
		result = expand_options(&header, opt_list, &next_opt, &argv[args]);
		exit_status = result << 4;

		if (opt_list[0] && next_opt) {
		    result = act_on_products(opt_list, next_opt, action);
		    exit_status = exit_status | (result & 0x0f);
		}
	} else {
		/*
		 * Interactive mode
		 */
		exit_status = process_menu(&header, &classheader, opt_list);
		if (srcmedia != CDROM)	/* already done for CDROM */
		    signal(SIGINT, terminate);
		    signal(SIGQUIT, terminate);
		    signal(SIGTERM, terminate);
		    signal(SIGHUP, terminate);
		    signal(SIGPIPE, SIG_DFL);
	}

#if defined(__clipper__) || defined(clipper)
	if (stat(warnfile, &statbuf) == 0) {
	    if (statbuf.st_size > oldsize ) {
		pfd = fopen("/etc/motd", "a");
		fprintf(pfd, "\nNOTICE:  For recent delivery errors or warnings, please read %s\n\n", warnfile);
		fclose(pfd);
	    }
	}
#endif


	if (srcmedia == CDROM)
		unlink(ws_ring);

	execute_info_script(ws_script, END);
	execute_info_script(ws_beta_script, END);
	sprintf(line, "%s/%s", deltools_home, RESTART);
	if (access(line, F_OK) == 0)
	    unlink(line);
	if (access("/etc/rc2.d/S99newprod", F_OK) == 0)
	    unlink("/etc/rc2.d/S99newprod");
	unlink(ws_script);
	unlink(ws_beta_script);

	terminate(exit_status);
}
