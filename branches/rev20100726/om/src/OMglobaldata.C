/*
---------------------------------------------------------------------------

	Name:			OMglobaldata.c
	Author:			Chuck Puckett
	Creation Date:		22-aug-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

	This module contains all global variables and data structures used
	by OM.

	Revision History:

cgp001	14-oct-1985	Begin to set up to reflect "objspaces". Add
			current objspace indicator, current objspace
			descriptor, & send depth.

cgp002	26-oct-1985	add some relation specification support. Also,
			flag "consistent".

cgp003	11-nov-1985	Objspace support.

cgp004	26-nov-1985	Make all parameter defined variables "uints" to
			insure no clobbering when they are set at
			runtime init.

cgp005	6-feb-1986	add system limit variables.

gja001	18-mar-1986	add global variables for malloc(3x) management

gja002	18-apr-1986	added global variable "OM_Gw_senders_OS"

geo001  07-may-1986	add OM_sd_param_defs[] here because of new function
			OM_set_dynamic_defaults

cgp006	18-mar-1986	Add VERBOSE_WARNING runtime parameter

jaj001  27-jun-1986	Added global array "OM_GA_primitives", an array 
			of pointers to functions, which are macro-ized
			for OM 4.0, at the very end of this file.

jaj002  27-jun-1986	Deleted the following:
			  1) *OM_GA_act_to_fil_relid, *OM_GA_fil_to_act_relid;  ( relation stuff )
			  2) OM_GS_Wildcard_relation

			Changed the following types and declarations
				 from:			   to:
			  1) OM_S_OS_DESCR 		 OM_S_OSD
			     *OM_GA_OS_descriptors	*OM_GA_OSDs
			  2) OMp_OS_DESCR		 OM_p_OSD
			     OM_Gp_current_OS_descr	 OM_Gp_CurOSD	
			  3) 3.2 version number		 4.0	

ems001  30-jun-1986     Added OMVMOMdata.c contents to this file.
                        OMVMOMdata.c disappears for OM 4.0 

jaj003  01-jul-1986	Added OM_Gf_consistent_class flag

jkm001  18-jul-1986	changed refereences to os parms (extsize,extobjs,etc)
			to cluster 0 and group 0 references
jkm002  14-aug-1986     removed malloc initialization stuff..

geo002	10-nov-1986	add swap clusters counter and markers

ems002  28-nov-1986     added global for read only OS count

geo003  15-dec-1986	group and cluster sizes and extends are not dynamic

gja003	5-Jan-1987	added OM_GA_primnames for use within ODEN

rme001  6-april-1987    added globals for tagged connections.

ems003  10-apr-1987     added more globals for tagged connects

rme002  23-apr-1987     added globals for tag record runtime parameters.

rme003	05-may-1987	remove three primitives: vla_collapse,movary, and
			resize_object.  VLA_COLLAPSE runtime parameter deleted.
sss001  07-may-1987     add globals and includ OMindex.h for R-tree History

ems004  25-may-1987     added global for classname hash

geo004	07-jul-1987	move oden globals to ODglobaldata.C;
			remove opl versions & opsys and machine globals;
			remove runtime parameters opp & opl versions;
			remove num_relations globals

geo005	24-jul-1987	remove process private globals (now in OMppgd.C)

cgp008	20-nov-1987	add CCCP control variables

geo006	09-dec-1987	add OMtime for physical cluster time stamp and
			remove previous swapping globals

geo007	28-dec-1987	initialize all uninitialized new globals

geo008  04-jan-1988	add global variable to indicate current size
			of CSDarray & next slot index

geo009  18-may-1988	add recluster globals

saw001	14-sep-1988	Add no-write non-modified clusters on swap primitives.

ems005  18-nov-1988     Add globals: OM_Gf_exec_control and OM_Gi_spawn_semid

hgb001  28-jan-1989	Add IGRdir & Group stuff + 1K buffer

saw002	25-sep-1991	Add global array of OSflags (1 int per obj space)
			for applications' use.  Flags are written to obj
			space file header on write.  Flags cleared on delete.

ems006  14-may-1992     Change PATH_MAX to DI_PATH_MAX

-------------------------------------------------------------------------------
*/

#include        <stdio.h>

#include 	"OMlimits.h"
#include 	"OMparameters.h"
#include 	"OMOSfilehdr.h"
#include	"OMcluster.h"
#include        "OMtags.h"
#include	"OMintercept.h"
#include	"OMindex.h"
#include	"DIdef.h"

/* number of classes and relations known to OM */

	OMuword		OM_Gw_numclasses=0;
	
/* List of OS descriptors */

	OM_p_OSD	*OM_GA_OSDs=0;				/* jaj002 */
	int		*OM_GA_OSflags=0;			/* saw002 */

/* pointer to array of pointers to active classes */

	OM_p_CLASSDEF	*OM_GA_active_classes=0;

/* map of indices from active to filed classid. This is actually made
   current when current OS changes. */

	OMuword		*OM_GA_active_to_filed=0;
	OMuword		*OM_GA_filed_to_active=0;

/* max size of filed to active map per object space */

	OMuword		*OM_GA_fa_mapsize=0;

/* hash table declaration for classnames */

        OM_S_CLASS_HASH_ENT   OM_GA_class_hash[OM_K_CLASS_HASH_MAX]={0};

/* system head of queue of free chunk descriptors */
/* add FCD monitoring globals */

        OM_p_FCD        OM_Gp_FCD_HEAD = NULL;
	OMuint		OM_Gi_FCDs_ALLOCATED = 0; /* # allocated */
	OMuint		OM_Gi_FCDs_USED = 0;	     /* # in use    */

/* array of message intercept information structures, indexed by osnum */

	OM_p_INTRCPT_HT	OM_GA_IntrcptHshTbl = NULL;


/*-------------------------------------------------------------------------*/
/* counter of used class indices (and thus, next available index) */

       OMuword	OM_Gw_next_class_index=0;

/* some default parameter value holder variables ... */

       OMuword	OM_Gw_maxOS = 			OM_K_MAXOSNUMBER;
       OMuword 	OM_Gw_tag_hashtable_size =	OM_K_TAG_DEF_HASH_SIZE;

/* Some Master ObjSpace Directory items */
/* objid (in MOSD objspace) of current MOSD object */

	OM_S_OBJID	OM_GO_current_MOSD=0;

/* Global for count of active Read Only Object Spaces */

        OMuword         OM_Gw_RO_OS_count = 0;

/* THE list of available objspaces. This is listhead. xffff implies none
   available. */

	OMuword		OM_Gw_first_OS_avail = 0;
	
/* Objid of Transient Space Zero OS object */

	OM_S_OBJID	OM_GO_TransOS_0=0;
	OMuword		OM_Gw_TransOSnum_0=0;


/*------------------------------------------------------------------------*/

/*----------------------*/
/* Tagged object stuff. */
/*----------------------*/

   /* Flag, true if tagged connects are enabled. */

      OMuint OM_Gf_tagged_connects = FALSE;

   /* Flag, true if tagging is enabled. */

      OMuint OM_Gf_tagging_enabled = FALSE;

   /* Osnum of object space to be considered the reference OS in a tagged
      connection.  */

      OMuword OM_Gw_tagged_osnum = OM_K_NOT_AN_OS;

   /* Global array of pointers to hash tables for OMTag objects, 
      indexed by osnum. */

      OM_p_TAG_HASHENT *OM_GA_p_tag_hashtable = NULL;

   /* Global array of oids for OMTag objects, indexed by osnum. */

      OM_p_OBJID OM_GA_tag_oids = 0;

   /* Global array of pointers to tag connect links */

      OM_p_TAGCON_LINK *OM_GA_p_tagcon = NULL;

/*----------------------------------------------------------------------*/

/* OMsysgen.par file path, when provided as param to runtime_init */

char		*OM_Gp_sysgenPath = NULL;


OM_S_CSD	*OM_GA_CSDarray=0;	/* ptr to array of CSDs */
OMuint		OM_Gi_CSDarraySize=0;	/* current size of CSDarray */
OMuint		OM_Gi_CSDarrayNextSlot=0;/* next slot index of CSDarray */
OM_S_DLINK	OM_GQ_regCSDavail={&OM_GQ_regCSDavail,&OM_GQ_regCSDavail};/* regular CSD avail queue */
OM_S_DLINK	OM_GQ_bigCSDavail={&OM_GQ_bigCSDavail,&OM_GQ_bigCSDavail};/* bigobject CSD avail queue */
OM_S_DLINK	OM_GQ_PCDavail={&OM_GQ_PCDavail,&OM_GQ_PCDavail};/* PCD avail queue */

OMuint          OM_Gi_phyClusterSize =    OM_K_PHYCLUSTERSIZE;


/* 
   IGRdir globals
   ==============
*/
/* the following define is needed to avoid multiple declarations */
#define  igrdir
#include "OMminimum.h"
#include "DItypedef.h"
#include "DIdef.h"

/* The directory delimiter character */
DIchar DIR_G_car_dir     = ':';
DIchar DIR_G_str_dir [2] = { ""};

/* The current directory name and id */
DIchar      DIR_G_cur_dir_name [DI_PATH_MAX] = { ""};
DIobjid     DIR_G_cur_dir_id = (OM_S_OBJID) -1;
DIspacenum  DIR_G_cur_dir_os = (uword) -1;

/* The initialisation flag */
DIint DIR_G_init = 0;

/* The previous current directory name and id */
DIchar     DIR_G_prev_cur_name [DI_PATH_MAX] = {""};
DIobjid    DIR_G_prev_cur_id = (OM_S_OBJID) -1;
DIspacenum DIR_G_prev_cur_os = (uword) -1;

/* The home directory */
DIchar DIR_G_home_name [DI_PATH_MAX] = {""};

/* The master directory id */
DIobjid    DIR_G_master_id = (OM_S_OBJID) -1;
DIspacenum DIR_G_master_os = (uword) -1;

/* The root directory id */
DIobjid    DIR_G_root_id = (OM_S_OBJID) -1;
DIspacenum DIR_G_root_os = (uword) -1;

/* The last accessed name and its objid */
DIobjid    DIR_G_last_id = 0;
DIobjid    DIR_G_last_dir = 0;
DIchar     DIR_G_last_name [DI_PATH_MAX] = {""};
DIspacenum DIR_G_last_os = 0;

/* To save the result of a di$start_ls */
DIchar **DIR_G_dump_lines = NULL;
DIgrid *DIR_G_dump_grids  = NULL;
DIint  DIR_G_dump_count   = 0;

/* To save the result of a di$start_find */
DIchar **DIR_G_find_lines = NULL;
DIgrid *DIR_G_find_grids  = NULL;
DIint  DIR_G_find_count   = 0;

/* To save the result of an untranslate */
DIchar **DIR_G_untr_dirnames = NULL;
DIchar **DIR_G_untr_objnames = NULL;
DIint  DIR_G_untr_count      = 0;

/* The trailers */
DIint  DIR_G_trailer_ids [TRAILER_MAX] = {0};
DIint  DIR_G_trailer_index = 0;
DIchar *DIR_G_trailers [TRAILER_MAX] = {""};

/* The classids */
DIclassid DIR_G_IGRdir_clid    = 0;
DIclassid DIR_G_DIrectory_clid = 0;
DIclassid DIR_G_DIlink_clid    = 0;
DIclassid DIR_G_DImaster_clid  = 0;
DIclassid DIR_G_DIroot_clid    = 0;

/* The cd path (search path for cd */
DIchar DIR_G_cdpath [DI_PATH_MAX] = {""};

/* The following Globals are transmitted to the DIls_driver */

OM_p_CLASSLIST DIR_G_classlist = 0;	/* classlist of elements to be listed	*/
DIchar	       ***DIR_G_lines = 0;	/* buffer to malloc			*/
DIgrid	       **DIR_G_grids = 0;	/* buffer to malloc			*/
DIchar	       DIR_G_options = 0;	/* options to be considered		*/
DIint          DIR_G_count = 0;	    	/* number of processed itmes		*/
DIint          DIR_G_level = 0; 	/* number of levels in the reg. exp.	*/


#if defined (BSD) || defined (NT)
/* following are added for the regexp.h   */
DIint sed = 0;
DIint nbra = 0;
DIint circf = 0;
DIchar *loc1 = 0;
DIchar *loc2 = 0;
DIchar *locs = 0;
#elif defined (SYSV)
#else
#warning No provision for regexp.h on this OS !!
#endif


/*
   GRoup globals
   =============
*/


#include "OMminimum.h"
#include "GRtypedef.h"
#include "DIdef.h"

GRint      GR_system    	      /* The system group index               */
		 = 0;
GRint      GR_cur_gr_ind	      /* The current group index              */
		 = 0;
GRchar     GR_cur_gr_type	      /* The cur group type (read only ...    */
		 = 1;
GRobjid    GR_cur_gr_id		      /* The current group objid	      */
		 = (OM_S_OBJID) -1;
GRspacenum GR_cur_gr_os		      /* The current group osnum              */
		 = (uword) -1;
GRchar     GR_cur_gr_name [DI_PATH_MAX]  /* The current group name	              */
		 = { "sys" };
GRchar     GR_prev_gr_name [DI_PATH_MAX] /* The previous group name              */
		 = { "usr" };
GRchar     GR_G_root [DI_PATH_MAX]	      /* The groups directory 	              */
	         = { ":groups:" };
GRint      GR_validate                /* The flag for valid operation         */
                 = 1;

/*  global to keep up with original OS names if they change  */

OM_p_ORIGOSNAME OM_Gp_orig_osname = 		0;


OMuint		OM_Gi_totalObjMem = 		0;
OMuint		OM_Gi_percent_extend_tag = 	OM_K_PERCENT_EXTEND_TAG;

OMuword		OM_Gw_max_modules = 		OM_K_DEF_MAX_MODULES;
OMuword		OM_Gw_max_ref_files =		OM_K_DEF_MAX_REF_FILES;

OM_p_DUPINTOS   OM_Gp_dup_intosname =           0;
int		OM_Gi_saved_uid =		0;

struct OM_sd_lockFiles	**OM_GA_lockFiles =	0; /* ptr to array of
                                                      lockfile names struct */
struct OM_sd_lockFileRec   *OM_Gp_lockFileRec = 0;

/* Global structure holding system specific info, like page size
   and nodename
 */

OM_S_SYSINFO	*OM_Gp_SYSINFO = NULL;

OMuint		OM_Gf_process_unknowns = 	0; /* force load products
                                                      based on file version
                                                      stamps */

