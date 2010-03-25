#ident	"%W%	%G% Copyright (c) 1986 by Intergraph Corp."

/* newprod actions */
#define INSTALL		'u'
#define INSTALLBASE	'U'
#define	MAKENODE	'm'
#define MAKEBASE	'M'
#define	REVIEW		'r'
#define PREPROCESS	'p'
#define PREPBASE	'P'
#define	HELP		'h'

#define	OLD_PRODNUM_LEN	10		/*max length of product number string*/
#define	PRODNAME_LEN	10		/*max size of name */
#define	TITLE_LEN	40		/*max size of title */
#define	VERSION_LEN	12		/*max size of version */
#define	FLAGS_LEN	32		/*max size of flags field*/
#define	FIXDATE_LEN	12		/*max length of fixes date string*/
#define	OLD_DIR_LEN	80		/*max length of VMS/Unix dir string*/
#define	OLD_KEY_LEN	20		/*max length of load key string*/
#define	BUFFSIZ		512		/*default size of character buffer*/
#define	STRSIZ		128		/*default size of string buffer*/

#define PRODNUM_LEN	32		/* expanded for "fat" product numbers */
#define DIR_LEN		128		/* expanded for huge directory depths */
#define KEY_LEN		32		/* expanded for "fat" loadkeys */

#define SERNO_LEN	32		/*Make sernos same as loadkeys*/
#define PRODINDX_LEN	 8		/*length of index in prod struct*/
#define CUSTID_LEN	66		/*length of EvalSN custid*/

#define	SCRIPTMODE	00744		/*file protection modes*/
#define	CREAT_DIRMODE	0040775		/*Unix directory creation mode*/

#define	EOL		'\n'		/*Prodlist file record terminator*/
#ifndef TRUE
#define	TRUE		1
#endif
#ifndef FALSE
#define	FALSE		0
#endif


/*
 * Values for "foldcase" variable, defining how ISO9660 filenames
 * should be treated.
 */

#define UPPER		1
#define LOWER		2

#if defined(clipper) || defined(__clipper__)
#  ifdef SVR4
#    define     BASEDIR                 "/opt/ingr"
#    define	KEYSDIR			"deltools/keys"
#    define	CDPROF			"deltools/cdprof"
#    define	RESTART			"deltools/restart.dat"
#    define     CPIO                    "/usr/bin/cpio"
#  else
#    define     BASEDIR                 "/usr/ip32"
#    define	KEYSDIR			"deltools/keys"
#    define	CDPROF			"deltools/cdprof"
#    define	RESTART			"deltools/restart.dat"
#    define     CPIO                    "/bin/cpio"
#  endif
#  define       FLOP_DEVICE             "/dev/dsk/fl"
#  define       FLOP_RAW_DEVICE         "/dev/rdsk/fl"
#  ifndef CDROM_DEVICE
#    define     CDROM_DEVICE            "/dev/dsk/cdrom"
#  endif
#  define       TAPE_DEVICE             "/dev/rmt/0mn"
#endif

#ifdef SunOS_4
#  define       BASEDIR                 "/usr/ip32"
#  define	KEYSDIR			"deltools/keys"
#  define	CDPROF			"deltools/cdprof"
#  define	RESTART			"deltools/restart.dat"
#  define       CPIO                    "/bin/cpio"
#  define       FLOP_DEVICE             "/dev/fd0"
#  define       FLOP_RAW_DEVICE         "/dev/rfd0"
#  ifndef CDROM_DEVICE
#    define     CDROM_DEVICE            "/dev/sr0"
#  endif
#  define       TAPE_DEVICE             "/dev/nrst8"
#endif

#if defined(sun) && defined(SVR4)
# ifdef NEWDIRS
#  define       BASEDIR                 "/opt/ingr"
#  define	KEYSDIR			"deltools/keys"
#  define	CDPROF			"deltools/cdprof"
#  define	RESTART			"deltools/restart.dat"
# else
#  define       BASEDIR                 "/usr/ip32"
#  define	KEYSDIR			"deltools/keys"
#  define	CDPROF			"deltools/cdprof"
#  define	RESTART			"deltools/restart.dat"
# endif
#  define       CPIO                    "/usr/bin/cpio"
#  define       FLOP_DEVICE             "/dev/diskette"
#  define       FLOP_RAW_DEVICE         "/dev/rdiskette"
#  ifndef CDROM_DEVICE
#   ifdef sparc
#    define     CDROM_DEVICE            "/dev/dsk/c0t6d0s2"
#   else
#    define     CDROM_DEVICE            "/dev/dsk/cdrom"
#   endif
#  endif
#  define       TAPE_DEVICE             "/dev/rst/5mn"
#endif

#ifdef _AIX
#  define       BASEDIR                 "/usr/ip32"
#  define	KEYSDIR			"deltools/keys"
#  define	CDPROF			"deltools/cdprof"
#  define	RESTART			"deltools/restart.dat"
#  define       CPIO                    "/bin/cpio"
#  define       FLOP_DEVICE             "/dev/fd0"
#  define       FLOP_RAW_DEVICE         "/dev/rfd0"
#  ifndef CDROM_DEVICE
#    define     CDROM_DEVICE            "/dev/cd0"
#  endif
#  define       TAPE_DEVICE             "/dev/rmt0.1"
#endif

#if defined(sgi)
#  ifdef SVR4
#    define	BASEDIR                 "/var/opt/ingr"
#  else
#    define	BASEDIR                 "/usr/ip32"
#  endif
#  define	KEYSDIR			"deltools/keys"
#  define	CDPROF			"deltools/cdprof"
#  define	RESTART			"deltools/restart.dat"
#  define       CPIO                    "/bin/cpio"
#  define       FLOP_DEVICE             "/dev/dsk/blah"
#  define       FLOP_RAW_DEVICE         "/dev/rdsk/blah"
#  ifndef CDROM_DEVICE
#    define     CDROM_DEVICE            "/dev/dsk/cdrom"
#  endif
#  define	TAPE_DEVICE		"/dev/nrtape"
#endif

#if defined(SCO)
#  define	BASEDIR                 "/usr/ip32"
#  define	KEYSDIR			"deltools/keys"
#  define	CDPROF			"deltools/cdprof"
#  define	RESTART			"deltools/restart.dat"
#  define       CPIO                    "/bin/cpio"
#  define       FLOP_DEVICE             "/dev/dsk/f0"
#  define       FLOP_RAW_DEVICE         "/dev/rdsk/f0"
#  ifndef CDROM_DEVICE
#    define     CDROM_DEVICE            "/dev/cd0"
#  endif
#  define	TAPE_DEVICE		"/dev/nrct0"
#endif

#define	FMNTDIR		"/mnt"		/*mount directory for floppy filesys */
#define	MNTDIR		"/del"		/*mount directory for filesys media*/
#define CONFIGFILE	"ingrconfig"
#define DELWARN		"delwarn"

#define	NET_CONNECT	"connect"
#define	NET_READ	"read"		/*network operations*/
#define	NET_WRITE	"write"

#ifndef VPROD
#define PRINT		fprintf(stderr,
#else
#define PRINT           messprintf(
#endif
#define LPRINT          if (logf) fprintf(logf,
#define DPRINT(x, y)    if (debug) PRINT "DEBUG: %s%s\n", x, y)
#define DPRINT1(x)      if (debug) PRINT "DEBUG: %s\n", x)
#define DPRINT3(x,y,z)	if (debug) PRINT "DEBUG: %s%s%s\n", x, y, z)
#define DPRINT4(w,x,y,z) if (debug) PRINT "DEBUG: %s%s%s%s\n" w, x, y, z)
#define DPRINTC(x,y)	if (debug) PRINT "DEBUG: %s %c\n", x, y)
#define DPRINTD(x,y)	if (debug) PRINT "DEBUG: %s %d\n", x, y)
#define DPRINTS(x,y)	if (debug) PRINT "DEBUG: %s %s\n", x, y)
#define DPRINTZ(x,y)	if (debug) PRINT "DEBUG: %s %z\n", x, y)
#define VPRINT(x, y)	if (verbose) PRINT "VERBOSE: %s%s\n", x, y)
#define VPRINT1(x)	if (verbose) PRINT "VERBOSE: %s\n", x)
#define VPRINT3(x,y,z)	if (verbose) PRINT "VERBOSE: %s%s%s\n", x, y, z)
#define VPRINT4(w,x,y,z) if (verbose) PRINT "VERBOSE: %s%s%s%s\n" w, x, y, z)
#define VPRINTD(x, y)	if (verbose) PRINT "VERBOSE: %s%d\n", x, y)
#define NVPRINT(x)	if (!verbose) PRINT "%s", x)

#ifdef XNS_NET
char 	*fmu_connect(), *fmu_disconnect(), *fmu_send(), *fmu_receive();
#endif


/* This is definition of a node on a doubly-linked list of products.
*/
struct prodnode {
	struct prodnode	*flink, *blink, *clink;
	char	prodnumber[PRODNUM_LEN];/*product number -- S34567890*/
	char	prodtitle[TITLE_LEN];	/*product title*/
	char	prodclass[TITLE_LEN];	/*product class*/
	char	prodname[PRODNAME_LEN];	/*product name*/
	char	prodversion[VERSION_LEN];	/*product version*/
	char	date[FIXDATE_LEN];	/*fixes.com date on the VAX*/
	char	flags[FLAGS_LEN];	/*product delivery flags */
	char	srcdir[DIR_LEN];	/*location of product on source media*/
	char	unixdir[DIR_LEN];	/*location of product on the ws*/
	char	loadeddir[DIR_LEN];     /*location of product already loaded*/
	char	loadedvers[VERSION_LEN];/*version of product already loaded*/
	int	blocksize;	/*no. of 512 byte blocks taken by prodfile*/
	short	multname;
	unsigned int	attr;		/*product attributes*/
#define	ATTR_BOM		0x00000001
#define	ATTR_INVISIBLE		0x00000002
#define	ATTR_SHARED   		0x00000004
#define ATTR_PREPROCESS		0x00000008
	short	load_priority;	/*provides installation ordering on installs*/
	unsigned short	pstat;		/*product status definitions*/
#define	NEEDS_UPDATING		0x0001
#define	WORKSTATION_NEWER	0x0002
#define	NEW			0x0004
#define	UP_TO_DATE		0x0008
#define	DOWNLOAD_OK		0x0010
#define	LOAD_ERRORS		0x0020
#define	DELIVTREE		0x0040
#define	SELECTED		0x0080	/* whether the product is selected */
#define	HAVEKEY			0x0100	/* is loadkey available on-line? */
	char	destfs[DIR_LEN];
	unsigned long	arch;		/* product target architecture */
#define CLIPPER_ARCH		0x00000001
#define VAX_ARCH		0x00000002
#define SUN_ARCH		0x00000004
#define RS6000_ARCH		0x00000008
#define C_SVR4_ARCH		0x00000010
#define C_NT_ARCH		0x00000020
#define S_SOLARIS_ARCH		0x00000040
#define I_SOLARIS_ARCH		0x00000080
#define I_SVR3_ARCH		0x00000100
#define I_NT_ARCH		0x00000200
#define M_SVR3_ARCH		0x00000400
#define M_OSF_ARCH		0x00000800
#define M_NT_ARCH		0x00001000
#define H_HPUX_ARCH		0x00002000
#define NUM_ARCH		14
	char	prodindx[PRODINDX_LEN];	/* Index for product serialization */
};


struct remote_node
{
	struct	remote_node *next;
	struct	prodnode *prodptr;
	char	nodename[20];
	int	selected;
};

struct group_node
{
	struct	remote_node *members;
	struct	group_node  *next;
	char	groupname[30];
	int	num_members;
	int	selected;
};

struct fsdata {
	char	name[32];
	int	pct;
	int	total;
	int	space;
	int	selected;
	int	current_fs;
};

#define	LKAUTH 			0		/* do loadkey auth  */
#define SNAUTH 			1		/* do serial no. auth */
#define	LKCD 			0		/* non Serialized CD */
#define SNCD			1		/* Serialized products CD */
#define SNLEN			14



