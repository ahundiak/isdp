/*
---------------------------------------------------------------------------

	Name:			OMppgd.C
	Author:			Grace Oliver
	Creation Date:		23-jul-1987
	Operating System(s):	Unix SYSV, v3
	Abstract:

	This module contains all global variables and data structures used
	by OM which are process private, i.e. are NOT shared across processes
	within a shared memory region.

	Revision History:

	cgp001	11-nov-1987	add CCCP pointers

	geo001	14-dec-1987	update null spamapent initialization &
				remove some runtime parameters. (4.5)

	cgp002	15-dec-1987	okay. i'll ADD some parameters. so there!

	geo002  23-feb-1988	add swap time globals and get statistics
				parameter

	saw001	29-jan-1993	Specify default settings for new dload.
				Add a sysgen parameter to adjust settings.
-------------------------------------------------------------------------------
*/

#include        "OMtypes.h"
#include 	"OMlimits.h"
#include 	"OMparameters.h"
#include 	"OMOSfilehdr.h"
#include	"OMcluster.h"
#include        "OMtags.h"
#include	"OMintercept.h"
#include	"OMindex.h"
#include	<signal.h>
#include        <stdio.h>

#ifndef NT
#include	<dload.h>
#endif /* NT */

#if defined (SUNOS5) || defined (IRIX5)
#define NSIG	34
#endif

extern OMuint OM_Gi_percent_extend_tag;
extern OMuint OM_Gi_phyClusterSize;
extern OMuword OM_Gw_max_modules;
extern OMuword OM_Gw_max_ref_files;
extern char    *OM_Gp_sysgenPath;

/* global to flag class init time to avoid a linear search in get_class */

	int		OM_Gf_class_init = 0;

/* global to flag when in som_dload_class */

	OMuint		OM_Gf_dload_mode = 0;

#ifndef NT
        OMuint          OM_Gf_dload_opts =
                          INCRLOAD | TEXTREF | DATAREF | TEXTREDEF;
#else
        OMuint          OM_Gf_dload_opts = 0;
#endif /* NT */

	OMuint		OM_Gf_dload_unresolved = 0;

/* global to control percent increase for spacemap and channels  */

        int             OM_Gi_percent_extend_sm   = 50;
        int             OM_Gi_percent_extend_chan = 20;

/* global flag to control checking for duplicate channel entries  */

        int             OM_Gf_check_chan_dups = 1;

/* some OS placeholders: These are all things that change when OS changes */
/* OS number of current OS */

	OMuword		OM_Gw_current_OS=0;

/* Contains the number that represents the senders' Object Space.         */

	OMuword		OM_Gw_senders_OS=0;			/* gja002 */
	
/* global objid of current Objspace objspace object (say what?) */

	OM_S_OBJID	OM_GO_current_OS_objid=0;

/* Address of current OS descriptor */

	OM_p_OSD	OM_Gp_CurOSD=0;				/* jaj002 */

/* useful null objid */

	OM_S_OBJID	NULL_OBJID = { (OMuint) -1 };

/* useful null channum */

        OM_S_CHANNUM    NULL_CHANNUM = { 0, 0 };

/* nice global "neighbor" struct */

	OM_S_NEIGHBOR	OM_GS_NULL_NEIGHBOR = { (OMuint)-1, (OMuword)-1 };
	OM_p_NEIGHBOR	OM_Gp_NULL_NEIGHBOR = &OM_GS_NULL_NEIGHBOR;

/* define a null message (used as default for om$construct) */

        OM_S_MESSAGE    OM_GS_NULL_MESSAGE = {{ (OMuword) -1, (OMuword) -1, 
                                                (OMuword) -1 },
                                                NULL, NULL };	
        OM_p_MESSAGE    OM_Gp_NULL_MESSAGE = &OM_GS_NULL_MESSAGE;

/* Space map for current OS */

	OM_p_SPAMAPENT  OM_Gp_CurSpaceMap=0;

/* Bit Array of active classids which are known by this process */

        OMuint          *OM_GA_known_classes=0;	
        OMuword         OM_Gw_known_class_max=0;

/* empty space map entry */

	OM_S_SPAMAPENT	OM_GS_NULL_SPAMAPENT = {0, 0, NULL};
	OM_p_SPAMAPENT	OM_Gp_NULL_SPAMAPENT = &OM_GS_NULL_SPAMAPENT;
	
/* OM major and minor version numbers */
/* also, dependency version numbes */

	OMuword		OM_Gw_major_version = 2;
	OMuword		OM_Gw_minor_version = 0;
	OMuword		OM_Gw_min_opp_major_version = 5;
	OMuword		OM_Gw_last_opp_minor_version = 1;

        OMuint          OM_Gf_validate_OS = FALSE;

/* The following variables are used for the record keeping of R-tree
   operation, i.e R-tree History */

        OM_p_RTREE_OP  OM_GA_rtree_ops=0;
        int  OM_Gi_ops_head=0, OM_Gi_ops_tail=0;
        int  OM_Gi_ops_count = 0;
        int  OM_Gi_record_ops = FALSE;

/* More global variables to keep fault statistics */

	OMuint		OM_Gi_faultinTicks=0;
	OMuint		OM_Gi_faultinBytes=0;
	OMuint		OM_Gi_numFaults=0;

/* some default parameter value holder variables ... */

	OMuint	OM_Gi_transOS_numobjs	= OM_K_DEFTRANS_GROUP_NUMOBJS;
	OMuint	OM_Gi_filedOS_numobjs	= OM_K_DEFFILED_GROUP_NUMOBJS;
	int	OM_Gi_transOS_extobjs	= OM_K_DEFTRANS_GROUP_EXTOBJS;
	int	OM_Gi_filedOS_extobjs	= OM_K_DEFFILED_GROUP_EXTOBJS;
	int	OM_Gi_maxchan_size	= OM_K_MAXCHAN_SIZE;
	int	OM_Gi_defchan_size	= OM_K_DEFCHAN_SIZE;
	int	OM_Gi_defchan_ext	= OM_K_DEFCHAN_EXT;
	OMuword	OM_Gw_defISO_size	= OM_K_DEFISO_SIZE;
	OMuword	OM_Gw_defISO_ext	= OM_K_DEFISO_EXT;
	OMuword	OM_Gw_defISOdir_size	= OM_K_DEFISODIR_SIZE;
	OMuword	OM_Gw_defISOdir_ext	= OM_K_DEFISODIR_EXT;
	OMuint	OM_Gi_defMOSD_numobjs	= OM_K_DEFMOSD_NUMOBJS;
	OMuint	OM_Gi_defMOSD_extobjs	= (OMuint) OM_K_DEFMOSD_EXTOBJS;
	OMuint	OM_Gf_makedefTransOS	= TRUE;
        OMuint  OM_Gf_unk_obj_support   = TRUE;
	OMuint	OM_Gf_bugcheck_fatal	= FALSE;
	OMuint	OM_Gf_verbose_warning	= FALSE;
	OMuint	OM_Gf_verbose_error	= FALSE;
	
	OMuint  OM_Gf_min_caching_send	= OM_K_MIN_CACHING_SEND;

   /* Global used to reinstate tagcon slot# in channel links during */
   /* tagcon reconnect method - checked in som_connect_doconnect    */

      OMuint  OM_Gi_tagcon_slot = 0;
 
   /* Global runtime parameter for extension of tag connect record vla */

      OMuword OM_Gw_tagcon_inc = OM_K_TAGCON_DEF_EXT_SIZE;

   /* Global runtime parameter for extension of tag record vla. */

      OMuword OM_Gw_tag_rec_extendsize = OM_K_TAG_DEF_EXT_SIZE;

   /* Global runtime parameter for extension of tag record vla. */

      OMuword OM_Gw_tag_hash_extendsize = OM_K_TAG_DEF_HASH_EXT_SIZE;

/* This array of signal handlers is initialized in runtime init */

#if defined (CLIX)
void	(*OM_GA_sig_func[_NSIG])() = 
#elif defined (SUNOS) || defined (IRIX) || defined (NT)
void	(*OM_GA_sig_func[NSIG])() = 
#else
#error OS does not uspport ->NSIG<- !!
#endif
			{(void (*)()) SIG_ERR, (void (*)()) SIG_ERR};

OMuint		OM_Gi_LCFqueueDepth = 	(OMuint) OM_K_LCF_QUEUEDEPTH;
OMuint		OM_Gf_errToStdout =	OM_K_ERRTOSTDOUT;

/* Re-auto-clustering globals */

OMuint          OM_Gf_autoRecluster =           TRUE;
OMuint          OM_Gi_ARTpercentFrag =          40;
OMuint          OM_Gi_ARTpercentClusters =      65;

OMuint          OM_Gf_mailbox =                 FALSE;

OMuint		OM_Gf_checksum_OS =		FALSE;
OMuint		OM_Gi_checksum =		0;
OMuint		OM_Gf_fileLocking =		0;    /* New in 1.4.1 */

OMuint		EX_Gf_defmsgfont =		1;
OMuint		EX_Gf_jnlon      =		1;

OMuint		OM_Gi_pid	=		0;
char		*OM_Gp_tmpdir =			NULL;
char            EX_runname[20] = {""};

struct OM_sd_param_def	OM_GA_param_defs[OM_K_NUMBER_PARAMETERS] = 
    			     {
	/*	Memory Management parameters (1)  */

                                {"PHYCLUSTERSIZE", NULL,
                                  (OMuint *)&OM_Gi_phyClusterSize,
                                  4096, 4*1024*1024, FALSE, P_UINT, PD_DEC},

	/*	Object Space parameters	(13)	*/

				{"MAX_MODULES", NULL, 
				  (OMuint *) &OM_Gw_max_modules, 
				   1, 0xffff, FALSE, P_UWORD, PD_DEC},
				{"MAX_REF_FILES", NULL, 
				  (OMuint *) &OM_Gw_max_ref_files, 
				   1, 0xffff, FALSE, P_UWORD, PD_DEC},
				{"DEFTRANS_GROUP_NUMOBJS", NULL, 
				  (OMuint *) &OM_Gi_transOS_numobjs, 
				   2, 0x1fffffff, TRUE, P_UINT, PD_DEC}, 
				{"DEFFILED_GROUP_NUMOBJS", NULL, 
				  (OMuint *) &OM_Gi_filedOS_numobjs, 
				   2, 0x1fffffff, TRUE, P_UINT, PD_DEC}, 
				{"DEFTRANS_GROUP_EXTOBJS", NULL, 
				  (OMuint *) &OM_Gi_transOS_extobjs, 
				   NULL, 0x1fffffff, TRUE, P_UINT, PD_DEC}, 
				{"DEFFILED_GROUP_EXTOBJS", NULL, 
				  (OMuint *) &OM_Gi_filedOS_extobjs, 
				   NULL, 0x1fffffff, TRUE, P_UINT, PD_DEC}, 
				{"DEFISO_SIZE", NULL, 
				  (OMuint *) &OM_Gw_defISO_size, 
				  1, 0x1fff, TRUE, P_UWORD, PD_DEC}, 
				{"DEFISO_EXT", NULL, 
				  (OMuint *) &OM_Gw_defISO_ext,
				  1, 0x1fff, TRUE, P_UWORD, PD_DEC}, 
				{"DEFISODIR_SIZE", NULL, 
				  (OMuint *) &OM_Gw_defISOdir_size,
				  1, 0x1fff, FALSE, P_UWORD, PD_DEC}, 
				{"DEFISODIR_EXT", NULL, 
				  (OMuint *) &OM_Gw_defISOdir_ext,
				  2, 0x1fff, FALSE, P_UWORD, PD_DEC}, 
				{"DEFMOSD_NUMOBJS", NULL, 
				  (OMuint *) &OM_Gi_defMOSD_numobjs,
				  10, 35, FALSE, P_UINT, PD_DEC}, 
				{"DEFMOSD_EXTOBJS", NULL, 
				  (OMuint *) &OM_Gi_defMOSD_extobjs, 
				  NULL, 35, FALSE, P_UINT, PD_DEC}, 
                                {"PERCENT_EXTEND_SM",NULL,
                                  (OMuint *) &OM_Gi_percent_extend_sm,
                                  1, 1000, TRUE, P_UINT, PD_PERCENT},

	/*	Channel Type parameters	(4)	*/

				{"MAXCHAN_SIZE", NULL, 
				  (OMuint *) &OM_Gi_maxchan_size, 
				  1, 0x1fffffff, TRUE, P_UINT, PD_DEC},
				{"DEFCHAN_SIZE", NULL, 
				  (OMuint *) &OM_Gi_defchan_size, 
				  1, 0x1fffffff, TRUE, P_UINT, PD_DEC}, 
				{"DEFCHAN_EXT", NULL, 
				  (OMuint *) &OM_Gi_defchan_ext, 
				  0, 0x1fffffff, TRUE, P_UINT, PD_DEC}, 
                                {"PERCENT_EXTEND_CHAN",NULL,
                                  (OMuint *) &OM_Gi_percent_extend_chan,
                                  1, 1000, TRUE, P_UINT, PD_PERCENT},

	/*	Flags				*/
	/*	Try to group flags meaningfully	*/

	/*	Validation flags (2)		*/

                                {"OM_VALIDATE_OS", NULL, /* Vla chk at write */
                                  (OMuint *)&OM_Gf_validate_OS, 
                                  0, 3, TRUE, P_UINT, PD_DEC}, 
                                {"OM_CHECKSUM_OS", NULL,
                                  (OMuint *)&OM_Gf_checksum_OS,
                                  0, 1, FALSE, P_UINT, PD_BOOL},

	/*	OS flags (3)		*/

				{"MAKEDEF_TRANSOS", NULL,
				  (OMuint *) &OM_Gf_makedefTransOS,
				  0, 1, FALSE, P_UINT, PD_BOOL},
#ifndef NT
                                {"AUTORECLUSTER", NULL,
                                  (OMuint *)&OM_Gf_autoRecluster,
                                  0, 1, FALSE, P_UINT, PD_BOOL},
#endif
                                {"FILELOCKING", NULL,
                                  (OMuint *)&OM_Gf_fileLocking,
                                  0, 2, FALSE, P_UINT, PD_DEC},/* NOT dynamic */

	/*	Error reporting flags 	(4)	*/

				{"BUGCHECK_FATAL", NULL,
				  (OMuint *) &OM_Gf_bugcheck_fatal,
				  0, 1, TRUE, P_UINT, PD_BOOL},
				{"VERBOSE_WARNING", NULL,
				  (OMuint *) &OM_Gf_verbose_warning,
				  0, 1, TRUE, P_UINT, PD_BOOL}, 
				{"VERBOSE_ERROR", NULL,
				  (OMuint *) &OM_Gf_verbose_error,
				  0, 1, TRUE, P_UINT, PD_BOOL},
				{"ERRTOSTDOUT",NULL,
				  (OMuint *) &OM_Gf_errToStdout,
				  0, 1, TRUE, P_UINT, PD_BOOL},

	/*	Miscellaneous Flags	(5)	*/

				{"ENABLETAGGING",NULL,
				  (OMuint *) &OM_Gf_tagging_enabled,
				  0, 1, TRUE, P_UINT, PD_BOOL},
                                {"UNKNOWN_OBJECT_SUPPORT",NULL,
                                  (OMuint *)&OM_Gf_unk_obj_support,
                                  0, 1, TRUE, P_UINT, PD_BOOL},
#ifndef NT
                                {"OMMAILBOX",NULL,
                                  (OMuint *)&OM_Gf_mailbox,
                                  0, 1, FALSE, P_UINT, PD_BOOL},
                                {"DLOADOPTS", NULL,
                                  (OMuint *) &OM_Gf_dload_opts,
                                  0, 0x7fffffff, FALSE, P_UINT, PD_HEX},
 				{"JNLON",NULL,
				  (OMuint *) &EX_Gf_jnlon,
				  0, 10, TRUE, P_UINT, PD_DEC},
#endif

	/*	Miscellaneous	(9)		*/

				{"MIN_CACHING_SEND", NULL,
				  (OMuint *) &OM_Gf_min_caching_send,
				  0, 0x1fffffff, TRUE, P_UINT, PD_DEC},
                                {"TAG_CON_EXTEND_SIZE",NULL,
                                  (OMuint *)((OMuword *) &OM_Gw_tagcon_inc),
                                  1, 4096, TRUE, P_UWORD, PD_DEC},
                                {"TAG_REC_EXTEND_SIZE",NULL,
				  (OMuint *)((OMuword *) &OM_Gw_tag_rec_extendsize),
				  1, 4096, TRUE, P_UWORD, PD_DEC},
                                {"TAG_HASHTABLE_SIZE",NULL,
                                  (OMuint *)((OMuword *) &OM_Gw_tag_hashtable_size),
				  100, 10000, TRUE, P_UWORD, PD_DEC},
				{"TAG_HASH_EXTEND_SIZE",NULL,
				  (OMuint *)((OMuword *) &OM_Gw_tag_hash_extendsize),
				  100, 10000, TRUE, P_UWORD, PD_DEC},
                                {"PERCENT_EXTEND_TAG", NULL,
                                  (OMuint *)&OM_Gi_percent_extend_tag,
                                  0, 1000, TRUE, P_UINT, PD_PERCENT},
				{"LCF_QUEUEDEPTH",NULL,
				  (OMuint *) &OM_Gi_LCFqueueDepth,
				  0, 0x7fffffff, TRUE, P_UINT, PD_DEC},
#ifndef NT
				{"ART_PERCENTFRAG",NULL,
				  (OMuint *) &OM_Gi_ARTpercentFrag,
				  20, 100, TRUE, P_UINT, PD_DEC},
				{"ART_PERCENTCLUSTERS",NULL,
				  (OMuint *) &OM_Gi_ARTpercentClusters,
				  20, 100, TRUE, P_UINT, PD_DEC},
#endif

	/*	Character strings (2)	*/

#ifndef NT
				{"OMSYSGENPATH",NULL,
				  (OMuint *)((char **) &OM_Gp_sysgenPath),
				  NULL, NULL, FALSE, P_STRING, PD_STR},
#endif
				{"DEFMSGFONT",NULL,
				  (OMuint *) &EX_Gf_defmsgfont,
				  0, 10, TRUE, P_UINT, PD_DEC}
			     };
