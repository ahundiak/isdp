#include <sys/types.h>
#include <sys/utsname.h>
#include <sys/mtio.h>
#ifndef SVR3
#include <sys/wait.h>
#endif
#include <errno.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include "main.h"
#include "defs.h"

extern char	*find_loaded_location();
extern char	*ws_mount_check();
extern int	connect_note();
extern int	notification_routine();
extern char	*media_connect();
extern int	read_prodlist_file();
extern void	lostpeer();
extern char	*generate_key_filename();
extern char	*generate_sn_filename();

extern char	*version;
extern char	*ldirname;
extern short	allvis;
extern short	multimenu;
extern char	basedir[STRSIZ];
extern char	mountpoint[STRSIZ];
extern char	ws_script[STRSIZ];
extern char	ws_beta_script[STRSIZ];
extern char	connstr[STRSIZ];
extern char	ws_prodlist[STRSIZ];
extern char	host[20], acctnm[20], pass[20];
extern char	*tape_device;
extern int	main_wno;

char	path[MAXPATHLEN];

#ifdef XFORMS
Display *display;
char  *display_name = "";
#endif

int	xcoll = 800, ycoll = 750;  /* initial collapse position */

Form	mainform;
Form	connform;

extern	short	srcmedia;

/* global values used to save and retrieve default values */
char	*ingrhome = BASEDIR;
char	deltools_home[STRSIZ];
char	*def_file;
char	hostname[MAXHOST], acctname[MAXACCT];
char	localcmd[MAXHOST], tapecmd[MAXHOST];

/* global flags added - used by newprod mechanisms */
FILE	*logf = NULL;	/* Log file */
char	*configfile = NULL;
char	*shell = "/bin/sh";
char	*errstr;
char	*prodlist;
char	warnfile[STRSIZ];
unsigned long	filter_arch = 0;
int 	vs;
int	class = 0;
short	no_ksh = 0;
short	foldcase = 0;
short	debug = 0;	/* '-X' option on command line - lots of debug info */
short	shared = 0;	/* if we're installing to diskless */
short	verbose = 0;	/* Print debug information during installation */
short	waitfor = 0;	/* '-w' option forces a wait before running install.sh */
short	makenode = 0;
short	multimenu = 1;
short	local_menu = 1;
short	allvis = 0;
short	minus_x = 0;	/* Execute installation scripts with '-x' option */
short	minus_b = 0;
short	takedefaults = 0;  /* old -'y' option on command line - now on form */
short	passed_prodlist = 0;
short	enforce_approved_configurations = 1;
unsigned short cdtype = 0, sssn = 0;
char   *lkfn, *snfn;

#ifdef XFORMS
short   help_avail = 0;	/* Set to 1 if the 8.0 Help system could initialize and
			 * find our Help document.  Otherwise, 0
			 */
#endif

struct utsname un;      /*used for system identification */
struct prodnode header; /*head of the product node list*/
struct prodnode classheader; /*head of the product class list*/
struct prodnode *curr_hdr; /* either current class header or world header */
struct prodnode *start; /* first product in class, or first of all products*/
struct stat	statbuf;

static char *searchpath[] = {MYSTUFFDIR};
struct prodnode *current_product;

#define RING    ".cmsdr."

#ifdef NEW_ARCHITECTURES

#ifndef USE_DEFINITION_FILE

#if (defined(clipper) || defined(__clipper__)) && defined(SVR3)
unsigned long   my_arch = CLIPPER_ARCH;
char    installscript[15]       = {"install.sh"};
char    removescript[15]        = {"remove.sh"};
char    *machine = "clip";
#define ARCH_MAGIC      0000577
#endif

#if (defined(clipper) || defined(__clipper__)) && defined(SVR4)
unsigned long   my_arch = C_SVR4_ARCH;
char    installscript[15]       = {"install.cv4"};
char    removescript[15]        = {"remove.cv4"};
char    *machine = "cio";
#define ARCH_MAGIC      0000577
#endif

#if defined(sun) && defined(SunOS_4)
unsigned long   my_arch = SUN_ARCH;
char    installscript[15]       = {"install.sun"};
char    removescript[15]        = {"remove.sun"};
char    *machine = "sun";
#define ARCH_MAGIC      0100403
#endif

#if defined(sun) && defined(SVR4)
#  if defined(sparc)
unsigned long my_arch = S_SOLARIS_ARCH;
char    installscript[15]       = {"install.ssl"};
char    removescript[15]        = {"remove.ssl"};
char    *machine = "ssl";
#define ARCH_MAGIC      077505
#  else if defined(i386)
unsigned long my_arch = I_SOLARIS_ARCH;
char    installscript[15]       = {"install.isl"};
char    removescript[15]        = {"remove.isl"};
char    *machine = "isl";
#define ARCH_MAGIC      042577
#  endif
#endif

#ifdef _AIX
unsigned long my_arch = RS6000_ARCH;
char    installscript[15]       = {"install.rs6"};
char    removescript[15]        = {"remove.rs6"};
char    *machine = "rs6";
#define ARCH_MAGIC      0000737
#endif

#ifdef sgi
unsigned long my_arch = M_SVR3_ARCH;
char    installscript[15]       = {"install.sgi"};
char    removescript[15]        = {"remove.sgi"};
char    *machine = "sgi";
#define ARCH_MAGIC      0000540
#endif

char    *cpu_types[16] = {
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
    "",
    ""
};

#else           /* read definition file for architecture info
                   and defined CPU types*/

unsigned long   my_arch;
char    installscript[15];
char    removescript[15];
char    *machine;
char *cpu_types[32];

#endif          /* USE_DEFINITION_FILE */

#else           /* ! NEW ARCHITECTURES */

#if defined(clipper) || defined(__clipper__)
unsigned long  my_arch = CLIPPER_ARCH;
char    installscript[15]       = {"install.sh"};
char    removescript[15]        = {"remove.sh"};
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
char    *machine = "rs6";
#define ARCH_MAGIC      0000737
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
#endif  /* NEW_ARCHITECTURES */


/*
 * This routine is called to create a subprocess to execute the
 * newprod info shell script. It will fork and exec the child
 * process and wait on the return value from the child. The value
 * returned by the child is passed back as the return value of this
 * function.
 */
int     execute_info_script(script, when, pause)
char    *script;
char    *when;
int     pause;
{
        int     rstat;          /* routine retval, also syscall return values*/
        char    cmdname[256];

        if (access(script, 04) < 0)
                return(0);      /* could not find the script, return ok */

	chmod(script, SCRIPTMODE);
        strcpy(cmdname, script);
        strcat(cmdname, " ");
        strcat(cmdname, when);
        rstat = run_shell(cmdname, pause, FALSE);
#ifndef SVR3
	return(WEXITSTATUS(rstat));
#else
        return(rstat);
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
                if (strcpy(mountpoint, ws_mount_check(basedir)) == NULL)
                        return(1);
		/*
		 * Make sure base file system has a tmp directory
		 */
		sprintf(tmpname, "%s/tmp", mountpoint);
		if (makedir(tmpname, 040777, 0, 0)) {
			PRINT "Can't create directory %s!\n", tmpname);
			return(1);
		}
	}

#ifdef VPROD
	/*
	 * make sure we have a mount directory
	 */
	if (srcmedia == FLOPPY || srcmedia == CDROM) {
		tmp = (srcmedia == FLOPPY ? FMNTDIR : MNTDIR);
		if ((makedir(tmp, 040777, 0, 0)) < 0) {
			PRINT "Can't create directory %s!\n", tmp);
			return(1);
		}
	}
#endif
	/*
	 * use /bin/ksh if it exists
	 */
	if (access("/bin/ksh", 01) == 0) {
		shell = "/bin/ksh";
		putenv("SHELL=/bin/ksh");
		putenv("ENV=");		/* clear the ENV variable */
	}
        else {
		shell = "/bin/sh";
		putenv("SHELL=/bin/sh");
		no_ksh = 1;
	}


#if !defined(KEEP_USR_CLEAN) && !defined(VPROD)
	/*
	 * force a link between /usr/bin/newprod and /usr/bin/getfile
	 * if no getfile exists do not exit out -- the user may be doing
	 * something wizardly
	 */
	if (access("/usr/bin/getfile", 01))
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

#ifdef XFORMS
void
Set_form_class(form)
Form form;
{
    Window      wno;
    XClassHint  *classhint;

    FIf_get_window(form, &wno);
    classhint = XAllocClassHint();
    classhint->res_class = "Forms";
    classhint->res_name = "xvprod";
    XSetClassHint(display, wno, classhint);
}
#endif


main(argc, argv)
int argc;
char *argv[];

{
#ifndef XFORMS
	int 	slots;
	struct vlt_slot *vlt;
	struct	scr_info info[MAX_SCREENS];
#endif
	int 	sts;		/* status to check for errors */
	int	i, j, llen;
	int	errflg=0;
	extern  char *optarg;
	extern	short fsmounted;
	char	sm[64];  /* host.acctnm.pass of source machine */
	char	ws_ring[STRSIZ];
	char	errline[STRSIZ];
	char	*errstr;
#if defined(__clipper__) || defined(clipper)
	int	oldsize = 0;
	FILE	*pfd;
#endif
#ifdef sgi

	char	command[STRSIZ];
#endif
	char	*c, *envstr;


#if defined(SVR4) && defined(NEWDIRS)
        if ((c = getenv("INGRHOME")) && *c) {
	    ingrhome = c;
	    c = strchr(ingrhome, ':');
	    if (c)
		*c = '\0';
	}
	else {
	    PRINT "NOTE:  The INGRHOME environment variable is not set.\n");
	    PRINT "%s will be used as the base directory for configuration files.\n",
			BASEDIR);
	    sleep(5);
	    ingrhome = BASEDIR;
	    envstr = malloc(strlen(BASEDIR)+16);
	    sprintf(envstr, "INGRHOME=%s", ingrhome);
	    putenv(envstr);
	}
	strcpy(basedir, ingrhome);
#else
	ingrhome = BASEDIR;
	strcpy(basedir, "/usr");
#endif

	sprintf(def_file=calloc(1, 20), "/.vprod/vprod.def");
	read_def();

	uname(&un);
	srcmedia = 0;

	while ((i = getopt(argc, argv, "VwXvxfctSF:T:D:n:r:"))!=EOF){
		switch (i) {
		case 'V': /* show newprod version number */
			printf("Version %s\n", version);
			exit(255);
		case 'S':
			enforce_approved_configurations = 0;
			break;
		case 'F': /* -F prodlistname */
			if (prodlist = (char *)malloc(strlen(optarg) + 1)) {
				strcpy(prodlist, optarg);
				passed_prodlist++;
			}
			break;
		case 'w': /* wait for <RETURN> prior to run of install script*/
			++waitfor;			
			break;
		case 'X':
			++debug;
			putenv("DEBUG=y");
			break;
		case 'v':
			++verbose;
			putenv("VERBOSE=-v");
			break;
		case 'x':			/*execute subshells with "-x"*/
			++minus_x;			
			break;
		case 'n':
			if (srcmedia)
			    ++errflg;
			else {
			    srcmedia=NETWORK;
			    strcpy(sm, optarg);
			}
			break;
		case 'r':
			if (srcmedia)
			    ++errflg;
			else {
			    srcmedia=NETCDROM;
			    strcpy(sm, optarg);
			}
			break;
		case 'D':
			if (srcmedia)
			    ++errflg;
			else {
			    srcmedia = LOCAL_DIR;
			    strcpy(sm, optarg);
			}
			break;
		case 'f':
			if (srcmedia)
			    ++errflg;
			else 
			    srcmedia = FLOPPY;
			break;
		case 'c':
			if (srcmedia)
			    ++errflg;
			else
			    srcmedia = CDROM;
			break;
		case 't':
			if (srcmedia)
			    ++errflg;
			else {
			    srcmedia = TAPE;
			    strcpy(sm, TAPE_DEVICE);
			}
			break;
		case 'T':
                        strcpy(sm, optarg);
			break;
		case '?':
			++errflg;			
			break;
		}
	}

	if (errflg) {
		PRINT "Usage: %s [arguments] [product numbers]\twhere arguments are:\n", argv[0]);
		PRINT "-V			display the version\n");
		PRINT "-F prodlist		use alternate product list\n");
		PRINT "-v			select verbose mode\n");
		PRINT "-x			select install script debug mode\n");
		PRINT "-n user@node.subdomain.domain:pass\n");
		PRINT "                         specify a network node as the delivery source\n");
		PRINT "-n node.user.pass	specify a network node as the delivery source\n");
		PRINT "-r user@node.subdomain.domain:pass\n");
		PRINT "                         specify a network node as the delivery source\n");
		PRINT "-r node.user.pass	specify a remote CD/ROM node as the delivery source\n");
                PRINT "-c                   deliver from cdrom\n");
                PRINT "-t                   deliver from tape\n");
                PRINT "-T tapedev           specify the tape device [default = %s]\n", TAPE_DEVICE);
                PRINT "-f                   deliver from floppy\n");
                PRINT "-D localdirectory    deliver from a local directory\n");

		exit(255);
	}

	allvis = 0;
	class = 0;      /* not in the classifications menu */


	/*
	 * Set up base directory for installations.
	 */

#ifdef SunOS_4
    /*
     * Default base file system for SunOS 4.x is "/home".  But
     * if the "/home" directory is not on a filesystem of its own,
     * then fall back to using "/usr" (we don't want to fill the
     * root file system up...)
     */

    if (lstat("/home", &statbuf) == 0) {
        if (S_ISLNK(statbuf.st_mode)) {
            /*
             * /home is a symbolic link -- try to follow it.
             */
            if (!(llen = readlink("/home", basedir, STRSIZ))) {
PRINT "NOTE:  Your /home directory is a symbolic link that could not be followed.\n");
PRINT "The default destination will be set to /usr; however, it is recommended\n ");
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
LPRINT "destination will be set to /usr; however, it is recommended that you\n")
;
LPRINT "load products in file systems other than / and /usr if possible.\n");

            sleep(5);
        }
        else
            strcpy(basedir, "/home");
    }
    else {
        strcpy(basedir, "/usr");
PRINT "NOTE: You do not appear to have a /home directory.\n");
PRINT "The default file system will be set to /usr; however, it is\n");
PRINT "recommended that you load products in file systems other than\n");
PRINT "/ (root) and /usr, if possible.\n");

LPRINT "NOTE: You do not appear to have a /home directory.\n");
LPRINT "The default file system will be set to /usr; however, it is\n");
LPRINT "recommended that you load products in file systems other than\n");
LPRINT "/ (root) and /usr, if possible.\n");

        sleep(5);
    }
#endif
	
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

	/* Open the install.log file */
	logf = fopen(LOGFILE, "w");
	if (logf == NULL) {
	    sprintf(errline, "VPROD: Open of log file %s failed", LOGFILE);
	    perror(errline);
	    exit(1);
	}
	setbuf(logf, 0);

#ifdef XFORMS
        if ((display=XOpenDisplay(display_name)) == None) {
	    fprintf(stderr, "%s: cannot connect to X server %s\n", argv[0],
                       XDisplayName(display_name));
	    exit(1);
	} /* if */
#  ifdef HELP_8
	help_avail = 1;
	fprintf(stderr, "Searching for Help server...\n");
	if ((sts = Help_set_Xdisplay(display_name)) != HP_SUCCESS) {
	    fprintf(stderr, "%s: Warning: The Help system could not attach to X server %s\n", argv[0], display_name);
	    help_avail = 0;
	}
	else {
	    doc.logical_name = (char *)strdup(DOC_NAME);
	    doc.language = (char *)strdup(DOC_LANGUAGE);
	    doc.version = (char *)strdup(DOC_VERSION);

	    if ((sts = Help_document(&doc)) != HP_SUCCESS) {
		help_avail = 0;
		fprintf(stderr, "%s: Warning: Help documents could not be attached:\n", argv[0]);
		switch (sts) {
		case HP_ERROR_FINDING_OR_OPENING_DOCUMENT:
		    fprintf(stderr, "  Document could not be located or opened.\n");
		    break;
		case HP_NO_DISPLAYER:
		    fprintf(stderr, "  Cannot locate the display process.\n");
		    break;
		default:
		    fprintf(stderr, "  Unknown error\n");
		    break;
		}
	    }
	}
#  else
        help_avail = 0;
#  endif
        FSEnter(display, 0);
        FI_enter(display, NULL, NULL);
#else
	/* Set up Environ V environment */

	Enter_tools();
	Inq_displayed_vs(&vs);
	Get_fixed_vlt(&vlt,&slots);
	Loadvlt(vs,vlt,slots);

	Enable_events(FI_EVENT_MASK);   

	Inq_displayed_vs(&vs);
	Inq_screen_info(info);
	if (info[vs].vsi_num_planes <= 2)
	{
		printf("vprod: unable to display forms on this screen\n");
		exit(1);
	} /* if */

	/* Initialize forms system */
	FI_enter();
	Help_file_search_path(1, searchpath, "help.hp");
#endif

	FI_set_symbol_path(MYSTUFFDIR);
	FI_set_font_path(MYSTUFFDIR);

#ifdef FILL_FORM
	sprintf(path, "%s/connect.form", MYSTUFFIDR);
	sts = FIf_new(CONNECTFORM, path,
			connect_note, &connform);
	if (chkerror (sts, "creating form"))
		exit(1);
#ifdef XFORMS
	Set_form_class(connform);
	if (!help_avail)
	    FIg_disable(connform, FI_HELP);
#endif /* XFORMS */
#endif /* FILL_FORM */

	if (srcmedia)
	{
	    strcpy(connstr, sm);
	    switch (srcmedia) {
	    case TAPE:
		fprintf(stderr, "Insert a newprod product tape and press <RETURN> ---> ");
		fflush(stderr);
		getchar();
		if (errstr = media_connect(connstr)) {
		    fprintf(stderr, "Connect error: %s\n", errstr);
		    exit(1);
		}
		
		break;
	    case FLOPPY:
		fprintf(stderr, "Insert a newprod product floppy and press <RETURN> ---> ");
		fflush(stderr);
		getchar();
		if (errstr = media_connect("")) {
		    fprintf(stderr, "Connect error: %s\n", errstr);
		    exit(1);
		}
		break;
	    case LOCAL_DIR:
		if (errstr = media_connect(connstr)) {
		    fprintf(stderr, "Connect error: %s\n", errstr);
		    exit(1);
		}
		break;
	    case CDROM:
		fprintf(stderr,"Insert a newprod CD/ROM and press <RETURN> ---> ");
		fflush(stderr);
		getchar();
		if (errstr = media_connect("")) {
		    fprintf(stderr, "Connect error: %s\n", errstr);
		    exit(1);
		}
		break;
	    case NETWORK:
	    case NETCDROM:
		/* break apart the host.acctnm.pass info */

		i = 0;
		while ((sm[i] != '\0')  && (sm[i] != '.'))
		{
			hostname[i] = sm[i];
			i++;
		}
		hostname[i] = '\0';

		if (sm[i] == '.')
			i++;
		j = 0;
		while ((sm[i] != '\0')  && (sm[i] != '.'))
		{
			acctname[j] = sm[i];
			i++;
			j++;
		}
		acctname[j] = '\0';

		if (sm[i] == '.')
			i++;
		j =0;		
		while (sm[i] != '\0')
		{
			pass[j] = sm[i];
			i++;
			j++;
		}
		pass[j] = '\0';

/* define FILL_FORM if you want -n or -r to fill in the fields on the
 * connect form and wait for you to press GO to do the deed.  If not
 * defined, it'll just go ahead and connect to the media.
 */
#ifdef FILL_FORM
		FIg_set_value(connform, srcmedia, (double)1);
		FIg_set_text(connform, HOST_FIELD, hostname);
		FIg_set_text(connform, ACCT_FIELD, acctname);
		FIg_set_text(connform, PASS_FIELD, pass);
#else
		/*
		 * At some point, we should make all of these things
		 * use the same variables.  We use hostname and acctname,
		 * but other places use "host" and "acctnm" to do other things.
		 *
		 */
		strcpy(host, hostname);
		strcpy(acctnm, acctname);
		if (errstr = media_connect(connstr)) {
			fprintf(stderr, "Connect error: %s\n", errstr);
			exit(1);
		}		
#endif
		break;
	    }

	    /*
	     * Connection succeeded.
	     */
	    if (get_prod_list() != 0) {
		fprintf(stderr, "Unable to retrieve product list file %s\n", prodlist);
		terminate(7);
	    }
	    if (execute_info_script(ws_beta_script, BEGIN, FALSE) == 255)
		terminate(7);

	    if (execute_info_script(ws_script, BEGIN, FALSE) == 255)
		terminate(7); 

	    /*
	     * prepare to read product list file
	     */

	    classheader.blocksize = 0;
	    classheader.pstat = 0;
	    classheader.prodclass[0] = '\0';
	    classheader.flink = &classheader;
	    classheader.blink = &classheader;

	    header.blocksize = 0;
	    header.arch = 0;	/* number of products for local platform */
	    header.flink = &header;
	    header.blink = &header;
	    curr_hdr = &header;

	    if (srcmedia == NETCDROM)
		if (sssn)
		    get_key_data("/usr/tmp/keyfile","/usr/tmp/snfile");
		else
		    get_key_data("/usr/tmp/keyfile","'\0'");
	    else if (srcmedia == CDROM){
		lkfn = generate_key_filename(ws_prodlist);
	    	snfn = generate_sn_filename(ws_prodlist);
		get_key_data(lkfn, snfn);
	    }
	    sts = read_prodlist_file(ws_prodlist, &header);
	    if (sts < 0) {
		fprintf(stderr, "Error parsing ws_s.prods file.\n");
		terminate(7);
	    }
	    else if (sts == 0) {
		fprintf(stderr, "Sorry, there are no products available for your platform\n");
		terminate(7);

	    } /* if */

	    /* If there's only one class out there, go into "All Products"
	     * mode to spare the user the hassle of selecting the
	     * only available class...
	     */
	    if (classheader.blocksize == 1) {
		local_menu = 0;
		multimenu = 0;
	    }
	    else {
		local_menu = 1;
		multimenu = 1;
	    }
		
	    if (mainform == NULL) {
		sprintf(path, "%s/vprod.form", MYSTUFFDIR);
		sts = FIf_new(VPRODFORM, path,
			      notification_routine, &mainform);
		if (chkerror (sts, "creating form"))
		    terminate(1);

#ifdef XFORMS
		/*FIg_erase(mainform, FI_COLLAPSE);*/
		Set_form_class(mainform);
		if (!help_avail)
		    FIg_disable(mainform, FI_HELP);
#endif

		sts = FIf_display(mainform);
		if (chkerror (sts, "displaying form"))
		    terminate(1);

#ifndef XFORMS
		FIf_get_window(mainform, &main_wno);
		Set_win_collapse_org(main_wno, xcoll, ycoll);
#endif
		/* Put it in local delivery mode by default */
		FIg_set_state_on(mainform, LOCAL_DEL);
		notification_routine(VPRODFORM, LOCAL_DEL, (double)1, mainform);
	    } /* if */
	    else
	    {
		FIf_reset(mainform);
	    } /* else */
	}
	else
	{
#ifndef FILL_FORM
	    sprintf(path, "%s/connect.form", MYSTUFFDIR);
	    sts = FIf_new(CONNECTFORM, path,
			connect_note, &connform);
	    if (chkerror (sts, "creating form"))
		exit(1);
#ifdef XFORMS
	    Set_form_class(connform);
	    if (!help_avail)
		FIg_disable(connform, FI_HELP);
#endif /* XFORMS */
#endif /* FILL_FORM */

	    /* erase the gadgets for network stuff */
	    FIg_erase(connform, HOST_TEXT);
	    FIg_erase(connform, HOST_FIELD);
	    FIg_erase(connform, ACCT_TEXT);
	    FIg_erase(connform, ACCT_FIELD);
	    FIg_erase(connform, PASS_TEXT);
	    FIg_erase(connform, PASS_FIELD);
	    FIg_erase(connform, LOCAL_TEXT);
	    FIg_erase(connform, DEVICE_TEXT);


	    sts = FIf_display(connform);
	    if (chkerror (sts, "displaying form"))
		exit(1);
	}

	get_this_date();

	signal(SIGPIPE, lostpeer);

#if defined(__clipper__) || defined(clipper)
	/*
	 * Get current size of "delwarn" file.  We'll check later to see if
	 * it grew.
	 */
	sprintf(warnfile, "%s/%s", BASEDIR, DELWARN);
	if (stat(DELWARN, &statbuf) == 0)
	    oldsize = statbuf.st_size;
	else
	    oldsize = 0;
#endif

	FI_process_forms();

	execute_info_script(ws_script, END, TRUE);
	execute_info_script(ws_beta_script, END, FALSE);
	unlink(ws_script);
	unlink(ws_beta_script);

	if (logf)
	    fclose(logf);

#if defined(__clipper__) || defined(clipper)
	if (stat(DELWARN, &statbuf) == 0) {
	    if (statbuf.st_size > oldsize ) {
		pfd = fopen("/etc/motd", "a");
		fprintf(pfd, "\nNOTICE:  For recent delivery errors or warnings, please read %s\n\n", DELWARN);
		fclose(pfd);
	    }
	}
#endif
	switch (srcmedia) {
	case TAPE:
            tape_op(MTREW, 1, 0); /* rewind the tape */
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

	sync(); sync();

#ifdef XFORMS
      XCloseDisplay(display);
#else
	Help_kill(); 
	Exit_tools();					
#endif
} /* main */




