/*
---------------------------------------------------------------------------

	Name:			OMinitialize.c
	Author:			Chuck Puckett
	Creation Date:		jul-9-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

	Revision History:

cgp001	11-nov-1985	version 2.0 mods: Object space support. Wild card
			relation creation. Check opl version for
			compatibility.
		      
grp001  21-nov-1985	Changed cpp symbol from "DOME" to "ODIN".

cgp002	24-nov-1985	insure OSD's are nulled out after allocation.

cgp003	26-nov-1985	Add oid-specific init routine. change
			"import_pass" to "debug_pass" & make it ignore
			return status. Make set_parameters work.

cgp004	29-jan-1986	Make Root like others. Allow NULL terminated 
			parameter definitions.

gja001	18-mar-1986	add code and global definitions for malloc(3x)
			management.


geo001  07-may-1986	add OM_set_dynamic_defaults

jkm001  16-may-1986     added a call to OM_init_intOS_name in 
			OM_runtime_init

jkm002	8-jul-1986	4.0 changes. remove init_relations, remove 
			oid_specific_init, update others..

gja002	30-jul-1986	removed nmaobj from create meta class

ems001  21-may-1987     Removed make_message calls.

geo002	09-jul-1987	Add alternate mode path to runtime_init.
			Have runtime_spawn use execve.
			Add exit function.

geo003	24-jul-1987	Remove 3 runtime parameters: OM_Gs_envr_filename,
			OM_Gf_consistent, OM_Gf_consistent_class.

geo004	20-aug-1987	Changes in swap for /dev/rdsk/... only files
			(char device i/o faster)

geo005	10-dec-1987	Remove prev OM4.5 swap parameters & functions.

saw001  23-feb-1989     OM_Gi_maxSheapSize taken out.  Now the only upper
                        bound on sheap size is OM_Gp_regSlotBottom.
---------------------------------------------------------------------------
*/

#include	<stdio.h>
#include	<errno.h>
#include        <sys/types.h>
#include	<time.h>
#include	<string.h>
#include        <fcntl.h>
#include	<signal.h>
#include        <ctype.h>
#if defined (NT)
#include        <stdlib.h>
#include        <process.h>
#include        <excpt.h>
#include        <windef.h>
#include        <winnt.h>
#include        <winbase.h>
#endif

#if defined (SYSV) || defined (BSD)
#include        <sys/utsname.h>
#endif
#if defined (SVR4)
#include	<unistd.h>
#endif

#ifndef NT
#include        <dload.h>
#include        <block.h>
#endif
#include 	"OMminimum.h"
#include 	"OMmacros.h"
#include	"OMobjectcomm.h"
#include 	"OMparameters.h"
#include        "OMlimits.h"
#include 	"OMmetaclass.h"
#include	"OMspecify.h"
#include	"OMrelation.h"
#include	"OMintprims.h"
#include	"UNIXerrdef.h"
#include        "OMOSfilehdr.h"
#include	"version.h"
#include        "OMOSfilehdr.h"
#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIprims.h"

#ifdef SUNOS4
extern time_t time();
#endif

#if defined (SUNOS5) || defined (IRIX5)
/* On SunOS 5, NSIG is defined within a section of code that is
   prefaced by #if __STDC__ - 1 == 0.  omcpp does not handle this
   correctly, so the section of code is skipped even when __STDC__
   is 1.  As a (bad) solution, we define NSIG ourselves in this
   file, OMppgd.C, and autoreclustr.C which use NSIG.
*/
#define	NSIG	34
#endif
#if defined (IRIX) || defined (SUNOS) || defined (NT)
#define _NSIG   NSIG
#endif

extern  int                     som_modifyAccess();
extern  void			OM_signal_init();
extern  int			OM_init_intOS_name();

#if defined (SVR3) || defined (BSD)
extern  int			gethostname();
#elif defined (NT)
extern  int                     _getpid();
extern  char                    *getenv();
#endif

extern	OMuword			OM_Gw_numclasses;
extern	OM_p_CLASSDEF		*OM_GA_active_classes;
extern	OMuword			*OM_GA_active_to_filed;
extern	OMuword			*OM_GA_filed_to_active;
extern  OMuword			*OM_GA_fa_mapsize;
extern	OMuint			OM_Gf_makedefTransOS;
extern	OMuint			OM_Gf_bugcheck_fatal;
extern	OMuint			OM_Gf_verbose_warning;
extern	OMuint			OM_Gf_verbose_error;
extern	OMuint			OM_Gf_dload_opts;
extern  OMuint                  OM_Gf_validate_OS;
extern  OMuint			OM_Gf_fileLocking;
extern	OMuword			OM_Gw_defrel_objids;
extern	OMuword			OM_Gw_defISO_size;
extern	OMuword			OM_Gw_defISO_ext;
extern	OMuword			OM_Gw_defISOdir_size;
extern	OMuword			OM_Gw_defISOdir_ext;
extern	OMuword			OM_Gw_next_class_index;
extern  OMuint                  *OM_GA_known_classes;
extern  OMuword                 OM_Gw_known_class_max;
extern	OMuword			OM_Gw_current_OS;
extern	OM_S_OBJID		OM_GO_current_OS_objid;
extern	OM_p_OSD		OM_Gp_current_OS_descr;
extern	OMuword  		OM_Gw_maxOS;
extern	OMuword			OM_Gw_max_modules;
extern	OMuword			OM_Gw_max_ref_files;
extern	OMuword			OM_Gw_TransOSnum_0;
extern	OM_S_OBJID		OM_GO_TransOS_0;
extern  OMuint			OM_Gi_transOS_size;
extern	OMuint			OM_Gi_filedOS_size;
extern	int			OM_Gi_transOS_extsize;
extern	int			OM_Gi_filedOS_extsize;
extern	OMuint			OM_Gi_transOS_numobjs;
extern	OMuint			OM_Gi_filedOS_numobjs;
extern	int			OM_Gi_transOS_extobjs;
extern	int			OM_Gi_filedOS_extobjs;
extern	OMuint			OM_Gi_defMOSD_initsize;
extern	int			OM_Gi_defMOSD_extsize;
extern	OMuint			OM_Gi_defMOSD_numobjs;
extern	int			OM_Gi_defMOSD_extobjs;
extern	OM_S_OBJID		OM_GO_current_MOSD;
extern	OMuword			OM_Gw_min_opp_major_version;
extern	OMuword			OM_Gw_last_opp_minor_version;
extern	OM_S_OBJID		NULL_OBJID;
extern	struct OM_sd_param_def	OM_GA_param_defs[];
extern  OMuword                 OMMOSD_OPP_MOSD_init_method_index;
extern  OM_S_CLASS_HASH_ENT     OM_GA_class_hash[];
extern void			(*OM_GA_sig_func[])();
extern int                      OM_Gi_percent_extend_chan;
extern  OMuword                 OMOSCO_OPP_get_res_cnum_method_index;
extern char			*OM_Gp_sysgenPath;
extern int                      OM_Gi_saved_uid;
extern OMuint			OM_Gi_pid;
extern OMuint			OM_Gi_phyClusterSize;
extern struct OM_sd_lockFiles	**OM_GA_lockFiles;
extern struct OM_sd_lockFileRec	*OM_Gp_lockFileRec;
extern char			*OM_Gp_tmpdir;
extern int                      OM_Gi_number_of_defns;
extern OM_p_FUNCPTR             OM_GA_class_definitions[];
extern int                      OM_Gi_number_of_appl_ids;
extern INGR_p_PRODUCT_DEF       OM_GA_appl_version[];
extern int                      *OM_GA_OSflags;
extern OM_S_SYSINFO             *OM_Gp_SYSINFO;

#define DEBUGx

static som_putSysgenValue (ii, envTrans)
int         ii;
char        *envTrans;
{
  char      **pTmpStr;
  int       val;
  OMuint    uVal  ;
  OMword    wVal;
  OMuword   uwVal;

  switch (OM_GA_param_defs[ii].w_type)
  {
  case P_INTEGER :
    val = (int) atoi (envTrans);
    if (val >= OM_GA_param_defs[ii].i_minval  &&
        val <= OM_GA_param_defs[ii].i_maxval)
      *(OM_GA_param_defs[ii].p_variable) = val;
    else return (0);
    break;

  case P_STRING :
    pTmpStr = (char**)(OM_GA_param_defs[ii].p_variable);
    if (*pTmpStr)
    {
      if (strlen (*pTmpStr) < strlen (envTrans))
      {
        om$dealloc (ptr=(char *) *pTmpStr);
        *pTmpStr = om$malloc (size = strlen (envTrans) + 1);
      }
    }
    else *pTmpStr = om$malloc (size = strlen (envTrans) + 1);
    strcpy (*pTmpStr, envTrans);
    break;

  case P_UINT :
    uVal = (OMuint) atoi (envTrans);
    if (uVal >= (OMuint)OM_GA_param_defs[ii].i_minval  &&
        uVal <= (OMuint)OM_GA_param_defs[ii].i_maxval)
    *((OMuint*)OM_GA_param_defs[ii].p_variable) = uVal;
    else return (0);
    break;

  case P_WORD :
    wVal = (OMword) atoi (envTrans);
    if (wVal >= (OMword)OM_GA_param_defs[ii].i_minval  &&
        wVal <= (OMword)OM_GA_param_defs[ii].i_maxval)
      *((OMword*)OM_GA_param_defs[ii].p_variable) = wVal;
    else return (0);
    break;

  case P_UWORD :
    uwVal = (OMuword) atoi (envTrans);
    if (uwVal >= (OMuword)OM_GA_param_defs[ii].i_minval  &&
        uwVal <= (OMuword)OM_GA_param_defs[ii].i_maxval)
      *((OMuword*)OM_GA_param_defs[ii].p_variable) = uwVal;
    else return (0);
    break;

  case P_CHAR :
    if (!strlen (envTrans))
      *(OM_GA_param_defs[ii].p_variable) = 0;
    else if (1 != strlen (envTrans)) return (0);
    else *(OM_GA_param_defs[ii].p_variable) = envTrans[0];
    break;
  }
  return (1);
}

static int processParam (stmt, dyn)
char                *stmt;
int                 dyn;  /* dynamic flag */
{
  char              *eqPtr;
  int               ii, prmLen;
  
  if (NULL == (eqPtr = strchr (stmt, '='))) return(1);
  while (isspace(*stmt)) stmt++;
  if (stmt[0] == '#') return(1);
  *eqPtr = 0;                  /* NULL terminate string */
  for (ii=0; ii<(int)strlen(stmt); ii++)
  {
    if (isspace(stmt[ii]))
    {
      stmt[ii] = 0;
      break;
    }
  }
  prmLen = strlen(stmt);
  for (ii=0; ii<OM_K_NUMBER_PARAMETERS; ii++)
  {
    if ((prmLen >= (int) OM_GA_param_defs[ii].i_namelen) &&
        (!strncmp (OM_GA_param_defs[ii].s_name, stmt, prmLen)))
    {
      if (dyn && ! OM_GA_param_defs[ii].w_dynamic) return (OM_W_WARNING);
      if (!som_putSysgenValue (ii, ++eqPtr)) return (OM_W_WARNING);
      return (OM_S_SUCCESS);
    }
  }
  return (OM_W_WARNING);
}


/*
-------------------------------------------------------------------------------

OM_setdefaults
 
  This routine sets global variables to their values.

-------------------------------------------------------------------------------
*/

int OM_setdefaults	(paramc, param_list)

int	paramc;
char	*param_list[];

{
  FILE			*fParams = NULL;
  int			ii, minUniq, strLen, jj, kk;
  char                  stmt[132];
#ifndef NT
  char                  *envTrans, pName[64], paramFile[256];
#endif
  
/* quickly fix up param defs array with name lengths ... */

  for (ii=0; ii < OM_K_NUMBER_PARAMETERS; ii++)
  {
    strLen = strlen (OM_GA_param_defs[ii].s_name);
    minUniq = 1;
    for (jj=0; jj < OM_K_NUMBER_PARAMETERS; jj++)
    {
      if (jj==ii) continue;
      for (kk=0; kk<strLen; kk++) 
        if (OM_GA_param_defs[ii].s_name[kk] != OM_GA_param_defs[jj].s_name[kk])
        {
          if ((kk+1)>minUniq) minUniq = kk + 1;
          break;
        }
    }
    OM_GA_param_defs[ii].i_namelen = minUniq;
  }

#ifndef NT
  /*=======================================================*/
  /* For compatibility, Look for OMSYSGENPATH in           */
  /* runtime_init		                           */
  /*=======================================================*/

  for (ii=0; ii < paramc; ii++)
  {
    if (NULL == param_list[ii]) break;
    if (!strncmp ("OMSYSGENPATH", param_list[ii], 12))
      processParam (param_list[ii], FALSE);
  } /* for loop about all user specified values */

  /*==================================================*/
  /* Process the OMsysgen.par file.                   */
  /*==================================================*/

  if ( !(envTrans = (char*) getenv ("OMSYSGEN")) ||
       !(strcpy (paramFile, envTrans)) ||
       !(fParams = fopen (paramFile, "r")) )
  {
     if (!(fParams = fopen ("./OMsysgen.par", "r")))
     {
        if (OM_Gp_sysgenPath)
        {
           int   len;
           char  *path, *p, *ptr;
           if (len = (strlen(OM_Gp_sysgenPath)))
           {
              ptr = OM_Gp_sysgenPath;
              while(p = strchr(ptr, ':'))
              {
                 path = om$malloc(size = (int)(p-ptr)+16);
                 strncpy(path, ptr, (int)(p-ptr));
                 path[(int)(p-ptr)] = 0;
                 if (fParams = fopen (strcat(path, "/OMsysgen.par"), "r"))
                 {
                    om$dealloc(ptr = (char *) path);
                    break;
                 }
                 om$dealloc(ptr = (char *) path);
                 ptr = p + 1;
              }
              if (!fParams && ((int)ptr > ((int)OM_Gp_sysgenPath + len)))
              {
                 path = om$malloc(size = (int)(p-ptr)+16);
                 strcpy(path, ptr);
                 fParams = fopen(strcat(path, "/OMsysgen.par"), "r");
                 om$dealloc(ptr = (char *) path);
              }
           }
        }
     }
  }
  if (fParams)
  {
    while (fgets (stmt, 132, fParams))
    {
      if (stmt[0] == '#') continue;
      if (!processParam (stmt, FALSE))
        OMWARNING1
	("OM-W-BADPARAM, bad statement or value specified is outside legal range: %s\n",
         stmt);
    }
    fclose (fParams);
  }

  /*=======================================================*/
  /* Process shell variables                               */
  /*=======================================================*/

  for (ii=0; ii<OM_K_NUMBER_PARAMETERS; ii++)
  {
    if (strncmp ("OM", OM_GA_param_defs[ii].s_name, 2)) strcpy (pName, "OM");
    else pName [0] = 0;
    strcat (pName, OM_GA_param_defs[ii].s_name);
    if (envTrans = (char*) getenv (pName))
      if (!som_putSysgenValue (ii, envTrans))
      {
        strcpy (stmt, OM_GA_param_defs[ii].s_name);
        strcat (stmt, "=");
        strcat (stmt, envTrans);
        OMWARNING1 
          ("OM-W-BADPARAM, value specified is outside legal range: %s\n", stmt);
      }
  }
#endif

  
  /*=======================================================*/
  /* Process parameters to runtime_init			   */
  /*=======================================================*/

  if (paramc)
  {
    for (ii=0; ii < paramc; ii++)
    {
      if (NULL == param_list[ii]) break;
      if (!processParam (param_list[ii], FALSE))
        OMWARNING1 
("OM-W-BADPARAM, bad statement or value specified is outside legal range: %s\n",
         stmt);
    } /* for loop about all user specified values */
  }

  /*
  **	Set up maxOS
  */

  if ((OMuint)OM_Gw_max_modules + 
      (OMuint)OM_Gw_max_ref_files + 
      (OMuint)1 /* MOSDOS */ + 
      (OMuint)(OM_Gf_makedefTransOS?1:0) > (OMuint)OM_K_MAXOSNUMBER)
  {
     OMuword old_max_modules = OM_Gw_max_modules;
     OMuword old_max_ref_files = OM_Gw_max_ref_files;

     while ((OMuint)OM_Gw_max_modules + 
            (OMuint)OM_Gw_max_ref_files + 
            (OMuint)1 /* MOSDOS */ + 
            (OMuint)(OM_Gf_makedefTransOS?1:0) > (OMuint)OM_K_MAXOSNUMBER)
     {
        if (--OM_Gw_max_ref_files == 0)
        {
           OM_Gw_max_ref_files = 1;
           while ((OMuint)OM_Gw_max_modules + 
                  (OMuint)OM_Gw_max_ref_files + 
                  (OMuint)1 /* MOSDOS */ + 
                  (OMuint)(OM_Gf_makedefTransOS?1:0) > (OMuint)OM_K_MAXOSNUMBER)
           {
              --OM_Gw_max_modules;
           }
           OMWARNING2("OM-W-BADPARAM, MAX_MODULES has been truncated from %u to %u\n", old_max_modules, OM_Gw_max_modules);
        }
     }
     OMWARNING2("OM-W-BADPARAM, MAX_REF_FILES has been truncated from %u to %u\n", old_max_ref_files, OM_Gw_max_ref_files);
  }

  OM_Gw_maxOS = OM_Gw_max_modules + OM_Gw_max_ref_files + 1 /* MOSDOS */ + (OM_Gf_makedefTransOS?1:0); 

  /* Make sure OM_Gi_phyClusterSize is multiple of 8 */

  if (OM_Gi_phyClusterSize < (2 * sizeof(OM_S_OBJECTHDR)))
     OM_Gi_phyClusterSize += (2 * sizeof(OM_S_OBJECTHDR));
  if (OM_Gi_phyClusterSize % sizeof(OM_S_OBJECTHDR))
     OM_Gi_phyClusterSize += sizeof(OM_S_OBJECTHDR) -
        (OM_Gi_phyClusterSize % sizeof(OM_S_OBJECTHDR));

  return (OM_S_SUCCESS);
}


/*
-------------------------------------------------------------------------------

som_set_dynamic_defaults

  This routine dynamically changes global variables to new values.

-------------------------------------------------------------------------------
*/

int som_set_dynamic_defaults	(paramc, param_list)

int	paramc;
char	*param_list[];

{
  int                           sts = OM_S_SUCCESS;
  int				ii;

  for (ii=0; ii < paramc; ii++)
  {
    if (NULL == param_list[ii]) break; /* either argc/argv or null term list */
    if (!processParam(param_list[ii], TRUE)) sts = OM_W_WARNING;
  }
  return (sts);
}



/*
-------------------------------------------------------------------------------

OM_create_globals

  Create global arrays of pointers to things.

-------------------------------------------------------------------------------
*/

int OM_create_globals ()

{
   OMuword   ii;
  
   OM_Gw_numclasses = OM_Gi_number_of_defns + OM_K_NUM_META_CLASSES;

   if (!(OM_GA_active_classes = (OM_p_CLASSDEF *) om$malloc
      (size=OM_Gw_numclasses * sizeof(OM_p_FUNCPTR))))
      return (OM_E_NODYNMEM);

   for (ii=0; ii < OM_Gw_numclasses; ii++) /* insure array is null */
   {
      OM_GA_active_classes[ii] = 0;
   }

   if (!(OM_GA_OSDs = (OM_p_OSD *) om$calloc(num=(OMuint) OM_Gw_maxOS,
      size=sizeof (OMuint))))
      return (OM_E_NODYNMEM);

   /* create the array of maximum f/a map sizez */

   if(!(OM_GA_fa_mapsize = (OMuword *) om$calloc(num=(OMuint) OM_Gw_maxOS,
      size=sizeof(OMuword))))
      return(OM_E_NODYNMEM);

   /* initialize the array so that all os's have a f/a maps size of the
      number of classes */

   for(ii=0; ii<OM_Gw_maxOS; ii++)
      OM_GA_fa_mapsize[ii] = OM_Gw_numclasses;

   if (!(OM_GA_OSflags = (int *) om$calloc (num=(OMuint) OM_Gw_maxOS,
     size=sizeof (int))))
     return (OM_E_NODYNMEM);

#ifndef NT     
   OM_Gi_pid = getpid();
#else   
   OM_Gi_pid = _getpid();
#endif   
   if (OM_Gf_fileLocking)
   {
      /* If user wants file locking, each file retrieved by this process
         will have an accompanying lock file.  Lock file name corresponding
         to obj space num is stored in OM_GA_lockFiles[osnum].
         OM_Gp_lockFileRec is record written by this process to these
         lock files any time it accesses an obj space file.
       */

      if (!(OM_GA_lockFiles = (struct OM_sd_lockFiles **) om$calloc
         (num=(OMuint) OM_Gw_maxOS, size=sizeof(struct OM_sd_lockFiles *))))
         return(OM_E_NODYNMEM);
      if (!(OM_Gp_lockFileRec = (struct OM_sd_lockFileRec *)
         om$calloc(num=1, size=sizeof(struct OM_sd_lockFileRec))))
         return(OM_E_NODYNMEM);

      strncpy(OM_Gp_lockFileRec->node, OM_Gp_SYSINFO->nodename, 8);
      sprintf(OM_Gp_lockFileRec->pid, "%5d", OM_Gi_pid);
   }

  return (OM_S_SUCCESS);
}

/*
-------------------------------------------------------------------------------

OM_create_meta_classes

  Create reserved class definitions.

-------------------------------------------------------------------------------
*/


int OM_create_meta_classes()

{
  int		sts;
  extern int    Root_OM_class_init(),
		OMISO_OM_class_init(),
		OMCluster_OM_class_init(),
		OMObjSpace_OM_class_init(),
		OMMOSDOS_OM_class_init(),
		OMTransOS_OM_class_init(),
		OMFiledOS_OM_class_init(),
		OMGroup_OM_class_init(),
		OMSupGroup_OM_class_init(),
		OMOSCO_OM_class_init(),
		OMMOSD_OM_class_init(),
		OMindex_OM_class_init(),

		OMbtree_OM_class_init(),
		OMlnkbtree_OM_class_init(),
		OMrtree_OM_class_init(),
		OMTag_OM_class_init(),
		OMTagCon_OM_class_init(),
		GRoup_OM_class_init(),
		GRoups_OM_class_init(),
		DIbtree_OM_class_init(),
		DIbstob_OM_class_init(),
		DIbst_OM_class_init(),
		DIrectory_OM_class_init(),
		DIstorage_OM_class_init(),
		IGRdir_OM_class_init(),
		DImaster_OM_class_init(),
		DIbstgr_OM_class_init(),
		DIlink_OM_class_init(),
		DIroot_OM_class_init();

  OM_p_CREATECLASS_ARGS	p_args;

#ifdef DEBUG
printf("Entering create_meta_classes\n\n");
#endif

#ifdef DEBUG
printf("Creating class ROOT \n");
#endif

  OM_Gw_next_class_index = OM_K_ROOT_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) Root_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMISO \n");
#endif

  OM_Gw_next_class_index = OM_K_OMISO_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMISO_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMCLUSTER \n");
#endif

  OM_Gw_next_class_index = OM_K_OMCLUSTER_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMCluster_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMOBJSPACE \n");
#endif

  OM_Gw_next_class_index = OM_K_OMOBJSPACE_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMObjSpace_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMMOSDOS \n");
#endif

  OM_Gw_next_class_index = OM_K_OMMOSDOS_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMMOSDOS_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMTRANSOS \n");
#endif

  OM_Gw_next_class_index = OM_K_OMTRANSOS_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMTransOS_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMFILEDOS \n");
#endif

  OM_Gw_next_class_index = OM_K_OMFILEDOS_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMFiledOS_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMGROUP \n");
#endif

  OM_Gw_next_class_index = OM_K_OMGROUP_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMGroup_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMOSCO \n");
#endif

  OM_Gw_next_class_index = OM_K_OMOSCO_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMOSCO_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMMOSD \n");
#endif

  OM_Gw_next_class_index = OM_K_OMMOSD_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMMOSD_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMINDEX \n");
#endif

  OM_Gw_next_class_index = OM_K_OMINDEX_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMindex_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMBTREE \n");
#endif

  OM_Gw_next_class_index = OM_K_OMBTREE_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMbtree_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMLNKBTREE \n");
#endif

  OM_Gw_next_class_index = OM_K_OMLNKBTREE_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMlnkbtree_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMrtree \n");
#endif

  OM_Gw_next_class_index = OM_K_OMRTREE_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMrtree_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMTag \n");
#endif

  OM_Gw_next_class_index = OM_K_OMTAG_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMTag_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMTagCon \n");
#endif

  OM_Gw_next_class_index = OM_K_OMTAGCON_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMTagCon_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class OMSupGroup \n");
#endif

  OM_Gw_next_class_index = OM_K_OMSUPGROUP_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) OMSupGroup_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class IGRdir \n");
#endif

  OM_Gw_next_class_index = OM_K_IGRDIR_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) IGRdir_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class DIlink \n");
#endif

  OM_Gw_next_class_index = OM_K_DILINK_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) DIlink_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class GRoup \n");
#endif

  OM_Gw_next_class_index = OM_K_GROUP_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) GRoup_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class GRoups \n");
#endif

  OM_Gw_next_class_index = OM_K_GROUPS_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) GRoups_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class DIstorage \n");
#endif

  OM_Gw_next_class_index = OM_K_DISTORAGE_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) DIstorage_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class DIbtree \n");
#endif

  OM_Gw_next_class_index = OM_K_DIBTREE_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) DIbtree_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class DIbst \n");
#endif

  OM_Gw_next_class_index = OM_K_DIBST_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) DIbst_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class DIbstob \n");
#endif

  OM_Gw_next_class_index = OM_K_DIBSTOB_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) DIbstob_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class DIbstgr \n");
#endif

  OM_Gw_next_class_index = OM_K_DIBSTGR_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) DIbstgr_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class DImaster \n");
#endif

  OM_Gw_next_class_index = OM_K_DIMASTER_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) DImaster_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class DIrectory \n");
#endif

  OM_Gw_next_class_index = OM_K_DIRECTORY_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) DIrectory_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

#ifdef DEBUG
printf("Creating class DIroot \n");
#endif

  OM_Gw_next_class_index = OM_K_DIROOT_ACTCLASSID;
  p_args = (OM_p_CREATECLASS_ARGS) DIroot_OM_class_init();
  if (!(1&(sts = som_create_class (p_args, p_args->p_class_id))))
  {
    return (sts);
  }

  OM_Gw_next_class_index = OM_K_NUM_META_CLASSES;

#ifdef DEBUG
printf("Next class index = %d\n",OM_Gw_next_class_index);
printf("\nLeaving create_metaclasses \n");
#endif

  return (OM_S_SUCCESS);
}

/*
-------------------------------------------------------------------------------

OM_export_pass

  This routine invokes all application defined classes' init routine with
  "export" flag,  causing them to make known their methods, etc.
  note: all children invoke their parents init method before their
  own, so the loop in this routine might only initialize one class, 
  depending on how opl structures the OMclassinit  array of function ptrs.
-------------------------------------------------------------------------------
*/

int OM_export_pass ()

{
  int		ii, sts;
  OMuint        mask;
  OMuword       k_classid;
  
#ifdef DEBUG
  int last_index,i;
printf("Entering export_pass with %d definitions \n\n",OM_Gi_number_of_defns);
printf("Next class index is %d\n",OM_Gw_next_class_index);
last_index = OM_Gw_next_class_index;  /*initialize 'last class created' */
#endif
  
  for (ii=0; ii < OM_Gi_number_of_defns; ii++)
  {
    OM_p_CREATECLASS_ARGS cca = (OM_p_CREATECLASS_ARGS)
                                   OM_GA_class_definitions[ii]();
    sts = som_create_class (cca, cca->p_class_id);
    if ( ((7&sts) == SEVE) || ((7&sts) == ERRO) )	/* bad error ? */
    {
      return (sts);
    }

    k_classid = (OMuword) ((OMuword) (*cca->p_class_id-OM_K_NUM_META_CLASSES)/
       (OMuword) 32);
    mask = (1<<((OMuword) (*cca->p_class_id-OM_K_NUM_META_CLASSES) %
       (OMuword) 32));
    OM_GA_known_classes[k_classid] |= mask;

#ifdef DEBUG
if(last_index != OM_Gw_next_class_index)  /*new 'last class created' */
{
for(i=last_index; i<OM_Gw_next_class_index; i++)
{
  printf("Dump of created class..\n");
  dump_class(OM_GA_active_classes[i]);
  printf("\n\n");
}
 last_index = OM_Gw_next_class_index;
}
#endif
  }
#ifdef DEBUG
printf("Leaving export_pass \n\n");
#endif

  return (OM_S_SUCCESS);			/* export init finished */
}



/*------------------------------------------------------------------
   This routine initializes the channum field of the channel type 
   definition for all channels of all classes.
------------------------------------------------------------------*/

int OM_channum_init()

{
OM_p_CLASSDEF            p_acld;
int                      sts,i,j,k,len,res_cnt;
char                     chan_name[OM_K_MAXCHANNAME_LEN], *p_buf, *dot;
OMuword                  res_cnum;
OM_S_OBJID               oid;
OM_S_MESSAGE             res_cnum_msg;
OM_p_CHANNEL_TYPE_DEFN   p_typ;
struct sd_res_cnum {
   OMuword  channum;
   OMuword  *p_res_cnum;
} res_cnum_args;

    res_cnum_msg.select.DefClassid = OM_K_OMOSCO_ACTCLASSID;
    res_cnum_msg.select.ReqClassid = OM_K_OMOSCO_ACTCLASSID;
    res_cnum_msg.select.FuncIndex  = OMOSCO_OPP_get_res_cnum_method_index;
    res_cnum_msg.size              = sizeof(struct sd_res_cnum);
    res_cnum_msg.p_arglist         = (char *) &res_cnum_args;

   for ( i=0; (OMuword) i<OM_Gw_next_class_index; i++ )
   {
      p_acld = OM_GA_active_classes[i];
      if ( p_acld == NULL ) continue;
      res_cnt = 0;
      for ( j=0; (OMuword) j < p_acld->w_numchannels; j++ )
      {
         p_typ = p_acld->ChanDefns[j].p_type;
         if (p_typ->w_flags & CD_restricted)
         {
#ifdef DEBUG
            printf("\n*** Initialize restricted chan %s ***\n",p_acld->s_name);
            printf("May connect to class %s\n",(char *)(p_typ->classids) );
#endif
            /*=============================================================*/
            /*  check if this was an unknown class prior to OSCO.set_up    */
            /*  if so and target class exists fill in restricted channame  */
            /*=============================================================*/

            if ( !(dot = strchr((char *) p_typ->classids, '.')))
            {
               sts = om$get_classid ( classname = (char *) p_typ->classids,
                                      p_classid = &p_typ->channum.classid );
               if (!(1&sts))
               {
                  p_typ->channum.classid = 0;
                  continue;
               }
               sts = om$get_channel_name ( channum  = p_typ->channum,
                                           channame = chan_name );
               if (!(1&sts))
               {
                  printf("CHANNUM_INIT::could not get channel name\n");
                  p_typ->channum.classid = 0;
                  continue;
               }
               len = strlen(chan_name);

               if (!( p_buf = (char *) om$malloc ( size = len+1 )))
               {
                  return (OM_E_NODYNMEM);
               }
               strcpy(p_buf, chan_name);
               p_buf[len] = 0;
               om$dealloc ( ptr = (char *) p_typ->classids );
               p_typ->classids = (OMuword **)p_buf;
            }
            else
            {
               sts = om$get_channel_number( channame  = (char *) p_typ->classids,
                                            p_channum = &(p_typ->channum));
               if ( !(sts&1) )
               {
                  /*===================================================*/
                  /*  give unknown classes a chance to be initialized  */
                  /*  remember that the target channel number of the   */
                  /*  restriction is stored in the OSCO's vla          */
                  /*===================================================*/

                  *dot = 0;
                  sts = om$get_classid ( classname = (char *) p_typ->classids,
                                         p_classid = &p_typ->channum.classid );
                  *dot = '.';
                  if (!(1&sts))
                  {
                     p_typ->channum.classid = 0;
                     p_typ->channum.number  = 0;
                  }
                  else   /* send to OSCO to get channel number */
                  {
                    res_cnum_args.channum  = res_cnt;;
                    res_cnum_args.p_res_cnum = &res_cnum;
                    oid = OM_Gp_CurOSD->OSCO_list[p_acld->w_classid]->OSCO_oid;
                    sts = om$send ( msg = &res_cnum_msg,
                                    senderid = oid,
                                    targetid = oid );
                    p_typ->channum.number = res_cnum;
                  }
               }
#ifdef DEBUG
               printf("channum.classid = %d:\n",p_typ->channum.classid);
               printf("channum.number  = %d:\n",p_typ->channum.number);
#endif
            }
            ++res_cnt;
         }
         else   /*  NOT restricted   */
         {
            for ( k=0; k<(int)p_typ->ClassCount; k++ )
            {
               if ( *(p_typ->classids[k]) != OM_K_NOTUSING_CLASSID )
               {
                  p_typ->classids[k] =
                    &(OM_GA_active_classes[*(p_typ->classids[k])]->w_classid);
               }
            }
         }
      }
   }

   return( OM_S_SUCCESS );
}



void som_runtime_exit()
{
   int              ii;

   if (OM_Gf_fileLocking && OM_GA_lockFiles)
   {
      /* There will be an OM_sd_lockFiles node for every file
       * ever associated with an osnum.  For each osnum, void
       * out the entries of each lock file.
       */

      struct OM_sd_lockFiles  *ptr;

      for (ii=0; (OMuword) ii<OM_Gw_maxOS; ii++)
      {
         sprintf(OM_Gp_lockFileRec->osnum, "%5d", ii);
         ptr = OM_GA_lockFiles[ii];
         while(ptr)
         {
            if (ptr->name)
            {
              som_modifyAccess(ptr->name, 'V');
              ptr = ptr->next;
            }
         }
      }
   }

   return;
}


/*
-------------------------------------------------------------------------------

som_runtime_init

Called by application. Must be invoked before any other OM function.

-------------------------------------------------------------------------------
*/

int som_runtime_init (paramc, param_list)

int	paramc;
char	*param_list[];

{
  OMuword				OSnum;
  OM_S_OBJID				d_objid;
  int					sts;
  OM_S_MESSAGE				mosd_init;
  OM_S_NEIGHBOR				neighbor;
#if defined (SYSV) || defined (BSD)
  struct utsname                        un;
#elif defined (NT)
  SYSTEM_INFO				si;
#else
#error OS does not provide system info!!
#endif

/*========================*/
/* set up OM exit handler */
/*========================*/

  OM_Gp_tmpdir = (char *) getenv("TMPDIR");
  if (!OM_Gp_tmpdir)
  {
     if (!(OM_Gp_tmpdir = (char *) om$malloc(size = 4)))
        return(OM_E_NODYNMEM);
     strcpy(OM_Gp_tmpdir, ".");
  }

#if defined (NT)
#warning   exitadd disabled for now ...
#else
  if( exitadd(som_runtime_exit) == -1 ) 
    printf("OM Exit handler could not be added to exit stack");
#endif

/*========================*/
/* set up signal handling */
/*========================*/
#ifndef NT
  OM_signal_init();
#endif

  /*=================================*/
  /*  initialize the classname hash  */
  /*=================================*/

  memset
    ((char *) OM_GA_class_hash, 0,
       (int) OM_K_CLASS_HASH_MAX*sizeof(OM_S_CLASS_HASH_ENT));

/* seed the random number generator with the time of day...jkm001 */

  OM_init_intOS_name ();

/*			set process runtime defaults			*/

  if (!(1&(sts = OM_setdefaults (paramc, param_list)))) return (sts);

/* If user wants all warning or all error messages, turn off dload's
   NOWARNING flag */
#ifndef NT
   if (OM_Gf_verbose_warning || OM_Gf_verbose_error)
      dload_ctrl(CLROPTION, NOWARNING);
   else
      dload_ctrl(SETOPTION, NOWARNING);
#endif
  if (!(OM_Gp_SYSINFO = (OM_S_SYSINFO *) om$calloc(size=sizeof(OM_S_SYSINFO),
     num=1)))
     return(OM_E_NODYNMEM);
#if defined (SYSV) || defined (BSD)
  if (uname(&un) == -1)
  {
     perror("uname");
     return(OM_E_ERROR);
  }
  strncpy(OM_Gp_SYSINFO->processor, un.machine, 8);
  strncpy(OM_Gp_SYSINFO->sysname, un.sysname, 8);
  strncpy(OM_Gp_SYSINFO->release, un.release, 8);
  strncpy(OM_Gp_SYSINFO->version, un.version, 8);
#if defined (SVR4)
  strncpy(OM_Gp_SYSINFO->nodename, un.nodename, 8);
  OM_Gp_SYSINFO->pageSize = (int) sysconf(_SC_PAGESIZE);
#else
  if (sts = gethostname(OM_Gp_SYSINFO->nodename, 64))
  {
     perror("gethostname");
     return(sts);
  }
  OM_Gp_SYSINFO->pageSize = getpagesize();
#endif
#elif defined (NT)
/* UNRESOLVED
  if (!GetComputerName((LPTSTR) OM_Gp_SYSINFO->nodename, (LPDWORD) &sts))
  {
     perror("GetComputerName");
     return(OM_E_ERROR);
  }
  GetSystemInfo(&si);
*/  
  strcpy(OM_Gp_SYSINFO->nodename,"metd14");
  OM_Gp_SYSINFO->pageSize = 4096;
  strcpy(OM_Gp_SYSINFO->processor, "Pentium");

/*  strncpy(OM_Gp_SYSINFO->sysname, un.sysname, 8);
  strncpy(OM_Gp_SYSINFO->release, un.release, 8);
  strncpy(OM_Gp_SYSINFO->version, un.version, 8);
*/
#else
#error OS does not support OM_S_SYSINFO!!
#endif

#ifdef DEBUG
    printf("\n*** CREATE GLOBALS ***\n");
#endif
  if (!(1&(sts = OM_create_globals ()))) return (sts);

#ifdef DEBUG
    printf("\n*** CREATE META CLASSES ***\n");
#endif
  if (!(1&(sts = OM_create_meta_classes ()))) return (sts);

  /*  allocate known class bit array  */

  OM_Gw_known_class_max = (OMuword) ((OMuword) OM_Gi_number_of_defns +
     OM_Gw_numclasses - OM_K_NUM_META_CLASSES);
//  OM_GA_known_classes = (OMuint *) om$calloc
//         (size = ((OMuint) ((OM_Gw_known_class_max/8)+4)/4) * sizeof(OMuint));
  OM_GA_known_classes = (OMuint *) om$calloc
         (size = ((OMuint) (((OM_Gw_known_class_max+1024)/8)+4)/4) * sizeof(OMuint));

#ifdef DEBUG
  printf("\n*** EXPORT PASS ***\n");
#endif
  if (!(1&(sts = OM_export_pass ()))) return (sts);

#ifdef DEBUG
  printf("\n*** CHANNUM INIT ***\n");
#endif
  if (!(1&(sts = OM_channum_init() ))) return(sts);

/* eventually, we check if user specified a environment file, which contains
   (among other things) a list of objspaces to incorporate. For the nonce, we
   merely create MOSD with defaults, which allows user to make up to 32
   ObjSpaces.
   we create the MOSD ObjSpace (we don't care what its OS object oid is). Then
   we create the MOSD object in that space. Then we create the Zeroth
   Transient Space */

  OM_Gw_current_OS = 0;	/* cheat. we know that this will be the first*/

#ifdef DEBUG
    printf("\n*** CONSTRUCT MOSDOS ***\n");
#endif
  if (!(1&(sts = om$construct_os
	(classid=OM_K_OMMOSDOS_ACTCLASSID,osnum=&OSnum,p_objid=&d_objid,
	 osname="OM_MOSD_ObjSpace"))))
  {
      printf ("OM-F-INITFAIL, Failed to create MOSD OS\n");
      return (sts);
  }

/* make MOSDOS current OS space so message send from TRANSOS construct will
   not get confused */
  om$make_current_os (osnum=OSnum);
  mosd_init.select.DefClassid = OM_K_OMMOSD_ACTCLASSID;
  mosd_init.select.ReqClassid = OM_K_OMMOSD_ACTCLASSID;
  mosd_init.select.FuncIndex  = OMMOSD_OPP_MOSD_init_method_index;
  mosd_init.size              = 0;
  mosd_init.p_arglist         = 0;
#ifdef DEBUG
    printf("\n*** CONSTRUCT OM_GO_current_MOSD ***\n");
#endif

  neighbor.clusterid = 0;
  neighbor.groupid = OM_GS_NULL_NEIGHBOR.groupid;
  if (!(1&(sts = om$construct(classid = OM_K_OMMOSD_ACTCLASSID,
			      neighbor = neighbor,
	                      osnum   = OM_Gw_current_OS,
			      p_objid = &OM_GO_current_MOSD,
			      msg     = &mosd_init))))
  {
      printf ("OM-F-INITFAIL, Failed to create MOSD Object\n");
      return (sts);
  }
		/* now create Transient Space Zero...*/

  if (OM_Gf_makedefTransOS)
  {
#ifdef DEBUG
      printf("\n*** CONSTRUCT TRANS 0 ***\n");
#endif
    if (!(1&(sts = om$construct_os
	(classid=OM_K_OMTRANSOS_ACTCLASSID,osname="OM_TransOS_0",
	 p_objid=&d_objid,
	 osnum=&OM_Gw_TransOSnum_0))))
    {
        OMWARNING ("OM-W-INITFAIL, Failed to create Transient OS 0\n");
        return (sts);
    }
    om$make_current_os(osnum=OM_Gw_TransOSnum_0);
  } /* if make_def_trans_OS0 */

  /*===============================*/
  /*  initialize the DI subsystem  */
  /*===============================*/

  sts = di$init();
  if (!(1&sts)) di$report_error(sts=sts);

  return (sts);
}



static char	OM_GA_signames [_NSIG][16];

/***********************************************************************
  This signal handling routine ensures that shared memory is cleaned up
  before the process that received the signal terminates.
 ***********************************************************************/

void sigcatcher(sig)
  int sig;
{
#ifdef DEBUG
	printf("PID %d caught signal %d\n", OM_Gi_pid, sig);
#endif

  printf("\nWARNING! signal trapped: %s. Process terminating.\n", 
    OM_GA_signames[sig]);

  if (OM_GA_sig_func[sig] == (void (*)()) SIG_IGN ||
     OM_GA_sig_func[sig] == (void (*)()) SIG_DFL
#if defined (SYSV) || defined (BSD)
      || OM_GA_sig_func[sig] == (void (*)()) SIG_HOLD
#endif
     )
  {
    printf
      ("\nSIG_IGN, SIG_DFL, or SIG_HOLD set; NO CORE FILE; calling exit...\n");
/*    _exit(1);  Allow iot to perform cleanup   -Mohan */
#ifndef NT
    exit(1);
#else
    _exit(1);
#endif    
    
  }
  else	/* A function was specified as previous sig func value */
  {
    OM_GA_sig_func[sig]( sig );
    som_runtime_exit();
/*    _exit(1);  Allow it to perform cleanup.  -Mohan */
#ifndef NT
    exit(1);
#else
    _exit(1);
#endif    
  }
}


/*******************************************************************
  This routine sets up a signal catching routine - sigcatcher -
  for all the following signals.  The previous values of the signal
  catching routines are stored in the process private global array
  OM_GA_sig_func. 
 *******************************************************************/

void OM_signal_init()
{
  void	(*func)();
  int i;

  /* Initialize OM_GA_sig_func array */

  for (i=0; i<_NSIG; i++)
    OM_GA_sig_func[i] = (void (*)()) SIG_ERR;

  strcpy (OM_GA_signames[0], "SIGUNK_0");
  strcpy (OM_GA_signames[20], "SIGUNK_20");

#if defined (SYSV) || defined (BSD)
  strcpy (OM_GA_signames[SIGHUP], "SIGHUP");
  strcpy (OM_GA_signames[SIGQUIT], "SIGQUIT");
  strcpy (OM_GA_signames[SIGTRAP], "SIGTRAP");
  strcpy (OM_GA_signames[SIGIOT], "SIGIOT");
  strcpy (OM_GA_signames[SIGEMT], "SIGEMT");
  strcpy (OM_GA_signames[SIGKILL], "SIGKILL");
  strcpy (OM_GA_signames[SIGBUS], "SIGBUS");
  strcpy (OM_GA_signames[SIGSYS], "SIGSYS");
  strcpy (OM_GA_signames[SIGPIPE], "SIGPIPE");
  strcpy (OM_GA_signames[SIGALRM], "SIGALRM");
  strcpy (OM_GA_signames[SIGUSR1], "SIGUSR1");
  strcpy (OM_GA_signames[SIGUSR2], "SIGUSR2");
  strcpy (OM_GA_signames[SIGCLD], "SIGCLD");
  strcpy (OM_GA_signames[SIGPOLL], "SIGPOLL");
  strcpy (OM_GA_signames[21], "SIGUNK_21");
#else
  strcpy (OM_GA_signames[1], "SIGUNK_1");
  strcpy (OM_GA_signames[3], "SIGUNK_3");
  strcpy (OM_GA_signames[5], "SIGUNK_5");
  strcpy (OM_GA_signames[6], "SIGUNK_6");
  strcpy (OM_GA_signames[7], "SIGUNK_7");
  strcpy (OM_GA_signames[9], "SIGUNK_9");
  strcpy (OM_GA_signames[10], "SIGUNK_10");
  strcpy (OM_GA_signames[12], "SIGUNK_12");
  strcpy (OM_GA_signames[13], "SIGUNK_13");
  strcpy (OM_GA_signames[14], "SIGUNK_14");
  strcpy (OM_GA_signames[16], "SIGUNK_16");
  strcpy (OM_GA_signames[17], "SIGUNK_17");
  strcpy (OM_GA_signames[18], "SIGUNK_18");
  strcpy (OM_GA_signames[19], "SIGUNK_19");
  strcpy (OM_GA_signames[21], "SIGBREAK");
#endif

  strcpy (OM_GA_signames[SIGINT], "SIGINT");
  strcpy (OM_GA_signames[SIGILL], "SIGILL");
  strcpy (OM_GA_signames[SIGABRT], "SIGABRT");
  strcpy (OM_GA_signames[SIGFPE], "SIGFPE");
  strcpy (OM_GA_signames[SIGSEGV], "SIGSEGV");
  strcpy (OM_GA_signames[SIGTERM], "SIGTERM");

#ifdef SYSV
  strcpy (OM_GA_signames[SIGPWR], "SIGPWR");
#endif

#ifdef SUNOS5
  strcpy (OM_GA_signames[SIGWINCH], "SIGWINCH");
  strcpy (OM_GA_signames[SIGURG], "SIGURG");
  strcpy (OM_GA_signames[SIGIO], "SIGIO");
  strcpy (OM_GA_signames[SIGSTOP], "SIGSTOP");
  strcpy (OM_GA_signames[SIGTSTP], "SIGTSTP");
  strcpy (OM_GA_signames[SIGCONT], "SIGCONT");
  strcpy (OM_GA_signames[SIGTTIN], "SIGTTIN");
  strcpy (OM_GA_signames[SIGTTOU], "SIGTTOU");
  strcpy (OM_GA_signames[SIGVTALRM], "SIGVTALRM");
  strcpy (OM_GA_signames[SIGPROF], "SIGPROF");
  strcpy (OM_GA_signames[SIGXCPU], "SIGXCPU");
  strcpy (OM_GA_signames[SIGXFSZ], "SIGXFSZ");
  strcpy (OM_GA_signames[SIGWAITING], "SIGWAITING");
  strcpy (OM_GA_signames[SIGLWP], "SIGLWP");
#endif

  /* Set up signal handling function to be sigcatcher and store previous 
     value for the following signals. */

#if defined (SYSV) || defined (BSD)

  func = (void (*)()) sigset (SIGHUP, sigcatcher);
  if (func == SIG_ERR) perror("\nError from _signal in som_runtime_init : ");
  OM_GA_sig_func[SIGHUP] = func;

  func = (void (*)()) sigset (SIGINT, sigcatcher);
  if (func == SIG_ERR) perror("\nError from _signal in som_runtime_init : ");
  OM_GA_sig_func[SIGINT] = func;

  func = (void (*)()) sigset (SIGQUIT, sigcatcher);
  if (func == SIG_ERR) perror("\nError from _signal in som_runtime_init : ");
  OM_GA_sig_func[SIGQUIT] = func;

  func = (void (*)()) sigset (SIGILL, sigcatcher);
  if (func == SIG_ERR) perror("\nError from _signal in som_runtime_init : ");
  OM_GA_sig_func[SIGILL] = func;

  func = (void (*)()) sigset (SIGIOT, sigcatcher);
  if (func == SIG_ERR) perror("\nError from _signal in som_runtime_init : ");
  OM_GA_sig_func[SIGIOT] = func;

  func = (void (*)()) sigset (SIGEMT, sigcatcher);
  if (func == SIG_ERR) perror("\nError from _signal in som_runtime_init : ");
  OM_GA_sig_func[SIGEMT] = func;

  func = (void (*)()) sigset (SIGFPE, sigcatcher);
  if (func == SIG_ERR) perror("\nError from _signal in som_runtime_init : ");
  OM_GA_sig_func[SIGFPE] = func;

  func = (void (*)()) sigset (SIGBUS, sigcatcher);
  if (func == SIG_ERR) perror("\nError from _sigset in som_runtime_init : ");
  OM_GA_sig_func[SIGBUS] = func;

  func = (void (*)()) sigset (SIGSEGV, sigcatcher);
  if (func == SIG_ERR) perror("\nError from _sigset in som_runtime_init : ");
  OM_GA_sig_func[SIGSEGV] = func;

  func = (void (*)()) sigset (SIGSYS, sigcatcher);
  if (func == SIG_ERR) perror("\nError from _sigset in som_runtime_init : ");
  OM_GA_sig_func[SIGSYS] = func;

  func = (void (*)()) sigset (SIGPIPE, sigcatcher);
  if (func == SIG_ERR) perror("\nError from _sigset in som_runtime_init : ");
  OM_GA_sig_func[SIGPIPE] = func;

  func = (void (*)()) sigset (SIGPOLL, sigcatcher);
  if (func == SIG_ERR) perror("\nError from _sigset in som_runtime_init : ");
  OM_GA_sig_func[SIGPOLL] = func;

#elif defined (NT)

  func = (void (*)()) signal (SIGINT, (void (*)(int)) sigcatcher);
  if (func == (void (*)()) SIG_ERR)
     perror("\nError from _signal in som_runtime_init : ");
  OM_GA_sig_func[SIGINT] = func;

  func = (void (*)()) signal (SIGILL, (void (*)(int)) sigcatcher);
  if (func == (void (*)()) SIG_ERR)
     perror("\nError from _signal in som_runtime_init : ");
  OM_GA_sig_func[SIGILL] = func;

  func = (void (*)()) signal (SIGFPE, (void (*)(int)) sigcatcher);
  if (func == (void (*)()) SIG_ERR)
     perror("\nError from _signal in som_runtime_init : ");
  OM_GA_sig_func[SIGFPE] = func;

  func = (void (*)()) signal (SIGSEGV, (void (*)(int)) sigcatcher);
  if (func == (void (*)()) SIG_ERR)
     perror("\nError from _signal in som_runtime_init : ");
  OM_GA_sig_func[SIGSEGV] = func;

  func = (void (*)()) signal (SIGBREAK, (void (*)(int)) sigcatcher);
  if (func == (void (*)()) SIG_ERR)
     perror("\nError from _signal in som_runtime_init : ");
  OM_GA_sig_func[SIGBREAK] = func;

#else
#error OS does not support signal or sigset
#endif

#ifdef DEBUG
  printf("*** OM_GA_sig_func ***\n\n");
  for (i=1; i<_NSIG; i++) printf("Signal %2d : %d\n", i, OM_GA_sig_func[i]);
  printf("\n\n");
#endif
}
