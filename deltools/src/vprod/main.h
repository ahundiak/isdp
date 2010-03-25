#include <stdlib.h>
#include <stdio.h>
#if defined(__clipper__) || defined(clipper)
#include <tools.h>
#endif
#include <FI.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <sys/param.h>
#ifdef XFORMS
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#  ifdef HELP_8
#    include <helpif.h>
#  endif
#else
#include <iHelp.h>
#endif

#define MYSTUFFDIR		"/usr/ip32/deltools/vprod"
#define LOGFILE			"/usr/tmp/install.log"
#define PRODLIST                "ws_s.prods"
#define VAX_DIR                 "pro_dd_cfg:"
#define VAX_SCRIPT_DIR          "pro_dd_deltools:"
#define WS_DIR                  "./"
#define SCRIPT                  "newprodinfo.sh" /* startup/stop script name */
#define BETA_SCRIPT             "beta.sh"
#define BEGIN                   "BEGIN"
#define END                     "END"
#define EXECUTABLE              0111            /* executable mode*/
#define UMASK                   022             * rwxr-xr-x */

#ifdef HELP_8
#define DOC_NAME		"vprod"
#define DOC_LANGUAGE		"english"
#define DOC_VERSION		"06.03.*.*"
#endif

/* form label */

#define VPRODFORM	100
#define DELFORM		101
#define REVIEWFORM	102
#define REM_DELFORM	103
#define REMOTEFORM	105
#define CONNECTFORM	106
#define SHOW_PRODS	107
#define SHOW_SEL	108
#define LOADKEYFORM	110
#define CLASSFORM	111
#define TIMEFORM	112
#define DATEFORM	113
#define MULTNAMEFORM	114
#define STATFORM	115
#define FSFORM		116
#define INSTALLFORM	117
#define SETUPFORM	118
#define GROUPFORM	119
#define PACKFORM	120
#define REM_INFOFORM	121
#define PROMPTFORM	122
#define LOSTPEERFORM	123
/* gadget labels for connect.form */

#define NETWORK		12
#define CDROM		13
#define NETCDROM	14
#define TAPE		15
#define FLOPPY		16
#define LOCAL_DIR	23
#define DIRECTORY	119
#define VAX		113   /* not a button */
#define WORKSTATION	112   /* not a button */
#define TCPIP		111   /* not a button */

#define HOST_TEXT	20
#define LOCAL_TEXT	27
#define DEVICE_TEXT	28
#define HOST_FIELD	17
#define ACCT_TEXT	21
#define ACCT_FIELD	18
#define PASS_TEXT	22
#define PASS_FIELD	19

#define GO		24
#define MESSAGE		25
#define QUIT		130

/* gadget labels for vprod.form */

#define LOCAL_DEL	12
#define REMOTE_DEL	13
#define CHANGE_CONN	14

/* gadget labels for deliver.form */

#define DEL_TITLE	11
#define PROD_SLIDER	49

#define CURR_PROD	22

#define CLASS_TOGGLE	80	/* Show classes/Show all toggle */

/* gadget labels for new_view.form */

#define NAME_TEXT	11
#define NUMBER_TEXT	12
#define RM_TEXT		17
#define TITLE		19
#define BLOCKS		21
#define VERSION		20
#define STATUS		22
#define README		13

#define SECTIONS	18
#define ENTIRE		0
#define SEARCH_TEXT	24
#define SEARCH_PREV	26
#define SEARCH_NEXT	29
#define FORWARD		0
#define REVERSE		1
#define SAVE_FILE	27
#define NUM_SEC_ROWS	8
 
/* gadget lables for show_prod.form*/

#define POP_TOP		18
#define POP_BOTT	17

/* gadget labels for show_prod.form */

#define PROD_LIST	11
#define FS_TITLE	16
#define REMOVE_PROD	20
#define SIZE_PROD	21
#define SIZE_FIELD	22

/* gadget labels for pack.form */

#define PK_FIELD	15
#define PK_ADD		16
#define PK_DEL		17
#define PK_EDIT		24
#define PK_ANSWER	25
#define PK_USEFILE	26
#define PK_SEL		22
#define PK_PRODLIST	13
#define PK_CURRPROD	21
#define PK_README	23
#define PK_RESET	19

/* gadget labels for group.form */
#define GROUP_FIELD	16
#define GROUP_SEL	14
#define GROUP_MACH	25
#define GROUP_ADD	26
#define GROUP_DEL	27
#define GROUP_EDIT	28
#define GROUP_RESET	29


/* gadget labels for rem_mach.form */
#define MA_FIELD	16
#define MA_FS		18
#define MA_PASS		17
#define MA_PLATFORM	19
#define MA_EXCEPT	20
#define MA_SEL		25
#define MA_ADD		26
#define MA_DEL		27
#define MA_EDIT		28
#define MA_RESET	29
#define MA_VALIDATE	43

/* gadget labels for loadkey.form */

#define LK_PROMPT	12
#define LK_PROD		13
#define LK_KEYFIELD	14
#define LK_MSG		15

/* Gadgets for classes.form*/

#define CLASSES       12
#define AUTOCLASS     16
#define UNSELCLASS    18
#define GROUP1        17

/* gadget labels for rem_del.form */

#define RD_PACKAGES	20
#define RD_PRODUCTS	21
#define RD_GROUPS	22
#define RD_MACHINES	23
#define RD_SIMUL_DEL	37

/* gadget labels for time.form */
/* Time gadgets */
#define ST_GROUP	34
#define HDIAL		16
#define MDIAL		18
#define HFIELD		17
#define MFIELD		21
#define MERIDIAN	22

/* 'when' gadgets */
#define NOW		13
#define TODAY		26
#define TOMORROW	27
#define SPECDATE	11

/* Date gadgets */
#define SD_GROUP	32
#define MONTHS		28
#define MON_FIELD	29
#define DATEDIAL	30
#define DATE_FIELD	31

/* gadget labels for multname.form */

#define MN_TITLE	12
#define MN_FIELD	13

/* misc */

#define TRUE		1
#define FALSE		0

#define MAXLINE		500
#define MAXPROD		20
#define MAXHOST		20
#define MAXACCT		20
#define MAX_DEF		8       /* max simultaneous deliveries */

#define MAXROW		5	/* product buttons are 5 x 4 */
#define MAXCOL		4

/* gadget labels for prod_a.form */
#define ASCII_LIST	15
#define CURRENT_PROD	21

#define DO_INSTALL	24
#define REVIEW_PROD	23
#define UNSEL_ALL	19
#define AUTO_SEL	18

/* gadget labels for stat.form */
#define MESSBOX		12

/* gadget labels for fsavail.form */
#define FS1		12
#define FS2		13
#define PERC_USED_1	18
#define PERC_USED_2	20
#define BLOCKS_FREE_1	24
#define BLOCKS_FREE_2	25
#define BLOCKS_SEL_1	17
#define BLOCKS_SEL_2	23
#define FS_SCROLL	19
#define REVIEW_FS	22
#define REVIEW_SELECTED	21
#define REVIEW_AVAIL	27

/* gadget labels for load.form */
#define VERBOSE		12
#define SHOW_SCRIPT	13
#define PREPROC		14
#define DEFAULT		15
#define LOAD_IT		16
#define FORGET_IT	17

/* gadget labels for setup.form */
#define STEP1_MACHINES	12
#define STEP2_GROUPS	13
#define STEP3_PACKAGES	14
#define STEP4_DELIVERY	15
#define STEP5_TIME	16
#define STEP6_EXECUTE	17

/* gadget labels for rem_info.form */
#define INFO_SEL_MACH	20
#define INFO_SEL_GROUPS	21
#define INFO_SEL_PACK	22
#define INFO_MACH	16
#define INFO_GROUPS	17
#define INFO_PACK	18
#define INFO_TIME	19

/* gadget labels for prompt.form */
#define PR_NODE		12
#define PR_ACCT		13
#define PR_PASS		14

static char *statustext[] = {
        "Needs updating",       /* 0 */
        "System newer",         /* 1 */
        "New",                  /* 2 */
        "Up to date",           /* 3 */
        "Installed",            /* 4 */
        "Errors",               /* 5 */
        "Deliverable",          /* 6 */
        "Selected",             /* 7 */
        "Have key",             /* 8 */
        "Not on media"          /* 9 */
};
