/* $Id: VDpms_find.C,v 1.2 2001/01/12 19:13:25 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintf/cmd / VDpms_find.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDpms_find.C,v $
 *	Revision 1.2  2001/01/12 19:13:25  hans
 *	SP16 import to CVS
 *	
 *	Revision 1.1  2001/01/10 17:46:22  art
 *	ah
 *
 *	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
 *	Initial import to CVS
 *
 * Revision 1.4  2000/02/11  22:43:02  pinnacle
 * (No comment)
 *
 * Revision 1.3  2000/02/10  21:43:22  pinnacle
 * (No comment)
 *
 * Revision 1.2  1999/09/13  13:40:40  pinnacle
 * Replaced: vdintf/cmd/VDpms_find.C for:  by impd251 for vds
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/10/30  23:23:20  pinnacle
 * UnInit Warnings
 *
 * Revision 1.1  1997/08/04  18:32:18  pinnacle
 * Created: vdintf/cmd/VDpms_find.C by jwfrosch for vds
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/16/97	HF		Based on OMpms_find.C extracted form OMpms.C
 *					Very fast function to find ALL objects of a particular CLASSID
 *					in the specified object space (no locate required !!!).
 *	10/30/97	ah		UnInit warning
 *      01/10/01        ah              Moved from cmd directory
 * -------------------------------------------------------------------*/
/*
	Revision History:

This file contains all performance and monitoring routines used by pms.


saw001	Sept 1987	Made changes to support revised channel & channel
			link data structures.

geo001	14-dec-1987	OM4.5 clustering changes.

saw002  Sept 1988       Add new flags to lcd and csd for no write of
                        non-modified clusters during swap.
*/

#include  <ctype.h>
#include  <stdarg.h>
#include  <stdio.h>
#include  <string.h>
#ifndef NT
#include  <termio.h>
#else
#include  <stdlib.h>
#include  <malloc.h>
#endif
#include  <fcntl.h>

#include  "OMobjectcomm.h"
#include  "OMparameters.h"
#include  "OMmacros.h"
#include  "OMmetaclass.h"
#include  "OMminimum.h"
#include  "OMtypes.h"
#include  "OMspecify.h"
#include  "OMrelation.h"
#include  "OMintprims.h"
#include  "OMlimits.h"
#include  "OMcluster.h"
#include  "OMOSfilehdr.h"
#include  "DItypedef.h"
#include  "GRtypedef.h"
#include  "DIdef.h"
#include  "version.h"

#define	bool			int
#define OMPMS_K_ALLOBJSPACES	-1

#define ECHO_TO_LOG(format, arg) if (OMPMS_logfile) fprintf(OMPMS_logfile,format,arg)

extern  int     OMpms_show();
extern  bool    OMpms_get_class();

extern	OMuword OMObjSpace_OPP_find_iso_method_index;
extern	OMuword OMObjSpace_OPP_print_isodir_method_index;
extern	OMuword Root_OPP_debug_method_index;
extern	OMuword Root_OPP_delete_method_index;
extern	OMuword OMFiledOS_OPP_set_state_method_index;
extern	OMuword OMFiledOS_OPP_write_method_index;
extern	OMuword	OM_Gw_min_opp_major_version, OM_Gw_last_opp_minor_version;
extern	OMuint	OM_Gi_transOS_numobjs;
extern	OMuint	OM_Gi_filedOS_numobjs;
extern	int	OM_Gi_transOS_extobjs;
extern	int	OM_Gi_filedOS_extobjs;
extern	OMuword	OM_Gw_major_version;
extern	OMuword	OM_Gw_minor_version;
extern  OMuint	OM_Gi_maxchan_size;
extern  OMuint	OM_Gi_defchan_size;
extern  OMuint	OM_Gi_defchan_ext;
extern  OMuword	OM_Gw_defISO_size;
extern  OMuword	OM_Gw_defISO_ext;
extern  OMuword	OM_Gw_defISOdir_size;
extern  OMuword	OM_Gw_defISOdir_ext;
extern  OMuint	OM_Gi_defMOSD_numobjs;
extern  OMuint	OM_Gi_defMOSD_extobjs;
extern	OMuint	OM_Gf_makedefTransOS;
extern  OM_S_CSD *OM_GA_CSDarray;
extern  OM_S_DLINK OM_GQ_PCDavail;
extern  OM_S_DLINK OM_GQ_regCSDavail;
extern  OM_S_DLINK OM_GQ_bigCSDavail;
extern  OMuint  OM_Gi_phyClusterSize;
extern  int     OM_Gi_number_of_appl_ids;
extern  INGR_p_PRODUCT_DEF OM_GA_appl_version[];
extern  int     OM_Gi_number_of_defns;
extern  OM_p_FUNCPTR OM_GA_class_definitions[];

extern  OMuint	OM_Gf_min_caching_send;
extern  OMuword	OM_Gw_tagcon_inc;
extern  OMuword	OM_Gw_tag_rec_extendsize;
extern  OMuword	OM_Gw_tag_hashtable_size;
extern  OMuword	OM_Gw_tag_hash_extendsize;
extern	OMuint	OM_Gi_LCFqueueDepth;
extern	OMuint	OM_Gf_errToStdout;
extern	OMuint	OM_Gf_getStatistics;

extern	OMuint		OM_Gi_totalObjMem;
extern	OMuint		OM_Gf_validate_OS;
extern	struct OM_sd_param_def	OM_GA_param_defs[];
extern  OMuint          OM_Gi_CSDarraySize;
extern  OMuint          OM_Gi_CSDarrayNextSlot;
extern  OMuword         OM_Gw_first_OS_avail;
extern  OMuword		OM_Gw_max_modules;
extern  OMuword		OM_Gw_max_ref_files;
extern  OMuword		OM_Gw_known_class_max;
extern  int             OM_Gf_check_chan_dups;
extern  int             OM_Gi_ops_head;
extern  int             OM_Gi_ops_tail;
extern  int             OM_Gi_ops_count;
extern  int             OM_Gi_record_ops;
extern  OMuint          OM_Gi_percent_extend_tag;
extern  OMuint          OM_Gi_tagcon_slot;
extern  OMuint          *OM_GA_known_classes;
extern  OM_S_SYSINFO	*OM_Gp_SYSINFO;

extern  OMuint          *OM_Gp_objStorage;
extern  OM_p_ORIGOSNAME OM_Gp_orig_osname;
extern  DIchar          *DIR_G_cur_dir_name;
extern  DIobjid         DIR_G_cur_dir_id;
extern  DIspacenum      DIR_G_cur_dir_os;
extern  DIint           DIR_G_init;
extern  DIint           DIR_G_dump_count;
extern  DIint           DIR_G_find_count;
extern  DIchar          *DIR_G_prev_cur_name;
extern  DIobjid         DIR_G_prev_cur_id;
extern  DIspacenum      DIR_G_prev_cur_os;
extern  DIchar          *DIR_G_home_name;
extern  DIobjid         DIR_G_master_id;
extern  DIspacenum      DIR_G_master_os;
extern  DIobjid         DIR_G_root_id;
extern  DIspacenum      DIR_G_root_os;
extern  DIobjid         DIR_G_last_id;
extern  DIobjid         DIR_G_last_dir;
extern  DIchar          *DIR_G_last_name;
extern  DIspacenum      DIR_G_last_os;
extern  DIint           DIR_G_untr_count;
extern  DIint           *DIR_G_trailer_ids;
extern  DIint           DIR_G_trailer_index;
extern  DIchar          *DIR_G_trailers[];
extern  DIchar          *DIR_G_cdpath;
extern  DIchar	        DIR_G_options;
extern  DIint           DIR_G_count;
extern  DIint           DIR_G_level;
extern  GRint           GR_system;
extern  GRint           GR_cur_gr_ind;
extern  GRchar          GR_cur_gr_type;
extern  GRobjid         GR_cur_gr_id;
extern  GRspacenum      GR_cur_gr_os;
extern  GRchar          *GR_cur_gr_name;
extern  GRchar          *GR_prev_gr_name;
extern  GRchar          *GR_G_root;
extern  GRint           GR_validate;

static 	FILE 		*OMPMS_logfile = 0;
static 	char 		OMPMS_logname[15] = "";
static	int		OMPMS_Gf_brief = 0;
static	int		OMPMS_Gf_pause = 0;
static	char		OMPMS_current_OS_name[OM_K_MAXOSNAME_LEN] = "";
static	OMuword		OMPMS_current_OS_number = 0;

#define	PGLIMIT	20
#define IFDELETE(c) ((c) == 127 || (c) == 8)

static	int		OMPMS_pgLimit = PGLIMIT;
static	int		OMPMS_basePgLimit = PGLIMIT;
static	int		OMPMS_pgCnt = 0;
static	int		OMPMS_pgSearching = 0;
static  char            OMPMS_pgSeaStr[64];
static  char            OMPMS_pgHdr[512];
static	int		OMPMS_pgSeaStrLen;

#ifndef NT
static	int		terminal;
static  struct  termio  termset;     /* ioctl terminal setup data             */
static  struct  termio  original;    /* ioctl terminal setup data to reset    */
#endif

/*---------------------------------------------------------------------
    chan_name

    This data structure is required by OMpms to store user-specified
    channels by name in a NULL-terminated linked list.
-----------------------------------------------------------------------*/
struct chan_name
{
  char			name[OM_K_MAXCHANNEL_LEN];
  struct chan_name	*next;
};
typedef	struct chan_name	CHAN_NAME;
typedef	struct chan_name	*p_CHAN_NAME;

/*------------------------------------------------------------------
    OMpms_find_objects

    Displays every object of a class within an OS.
    Each object's channels are also displayed.

--------------------------------------------------------------------*/
int VDpms_find_objects ( OSnum, classid, cnt, list)
  uword		 OSnum;				/* Object space number	 */
  uword		 classid;			/* Class to find	 */
  int		*cnt;				/* Number found		 */
  OM_S_OBJID	*list;				/* Optional list of OID's */
{
  char		  classname[132];
  uword		  filedid;
  int		  max_entry;	        /* Last object space map entry	 */
  OMuint	  flags;		/* Space map entry flags	 */
  OM_p_OSD	  p_OSD;		/* Ptr to object space descriptor */
  OM_p_SPAMAPENT  spamapent_p;	        /* Ptr to space map entry	 */
  OM_S_OBJID	  oid;		        /* Object id (of space map entry) */
  int		  obj_count;	        /* Number of objects in object space
					   & number of objs being displayed */

  *cnt = 0;

  obj_count = 0; // Bad class would be bad without this

  if ( 1 & ( om$get_classname (classname = classname, classid = classid ) ) )
  {
    filedid = OM_GA_OSDs[OSnum]->ActToFil[classid];	/* Get the class id used in
  							   the filed object space */
    obj_count = 0;
    p_OSD = OM_GA_OSDs[OSnum];				/* Ptr to our obj space entry in
  							   obj space descr table */
    if (p_OSD->CurSpaceMapSize)
    {
      for (max_entry = p_OSD->CurSpaceMapSize-1,	/* Start at end of map */
           spamapent_p = &p_OSD->Spacemap[max_entry];
           max_entry >= 0; max_entry--, spamapent_p-- )
      {
        if ( ! OM_OBJ_INVALID(spamapent_p->flags)) break; /* Find last entry */
      }

//      PMSPRNT(("Locating objects of class %s in OS #%d, %s\n",
//        OM_GA_active_classes[classid]->s_name,
//        OMPMS_current_OS_number,
//        OMPMS_current_OS_name));

      for (oid=0, spamapent_p = p_OSD->Spacemap;	/* For each valid   */
           (int) oid <= max_entry;  oid++, spamapent_p++)
      {							/* entry...         */
        if ( (spamapent_p->flags  != 0) &&		/* If object shows  */
             (spamapent_p->p_acld != NULL) )
        {						/*  signs of life   */
          flags = spamapent_p->flags;

          if ( !(spamapent_p->flags & OM_SM_unknown_obj) &&
                 classid == spamapent_p->p_acld->w_classid)
          {						/* Obj in our class? */

	    if ( list ) list[obj_count] = oid;

            obj_count++;				/* Displayed count   */
          }
          if (OMpms_pause() == -1) break;		/* End loop if user sez quit */
        }
      }							/* End of for loop */
      OMPMS_pgHdr[0] = 0;
    }
  }							 /* if given a valid class */

  *cnt = obj_count;

  return (1);
}
/*------------------------------------------------------------------
    OMpms_find_objects

    Displays every object of a class within an OS.  Each object's
    channels are also displayed.

--------------------------------------------------------------------*/
int OMpms_find_objects(OSnum)
uword	OSnum;				/* Object space number */
					/*-fndesc*/
					/*-private*/
{
  int             printedHdr = TRUE;
  uword		  classid, filedid;
  int		  max_entry;	        /* Last object space map entry */
  OMuint	  flags;		/* Space map entry flags */
  OM_p_OSD	  p_OSD;		/* Ptr to object space descriptor */
  OM_p_SPAMAPENT  spamapent_p;	        /* Ptr to space map entry */
  OM_S_OBJID	  oid;		        /* Object id (of space map entry) */
  int		  obj_count;	        /* Number of objects in object space
					   & number of objs being displayed */

  if (OMpms_get_class(&classid) == TRUE)
  {	/* Ask user for classname/id */
    filedid = OM_GA_OSDs[OSnum]->ActToFil[classid]; /* Get the class id used in
  						     the filed object space */
    obj_count = 0;
    p_OSD = OM_GA_OSDs[OSnum];			/* Ptr to our obj space entry in
  						   obj space descr table */
    PMSPRNT(("\n"));
    if (p_OSD->CurSpaceMapSize)
    {
      for (max_entry = p_OSD->CurSpaceMapSize-1,  /* Strt at end of map */
           spamapent_p = &p_OSD->Spacemap[max_entry];
           max_entry >= 0; max_entry--, spamapent_p--)
        if (!OM_OBJ_INVALID(spamapent_p->flags)) break; /* Find last entry */

      PMSPRNT(("Locating objects of class %s in OS #%d, %s\n",
        OM_GA_active_classes[classid]->s_name,
        OMPMS_current_OS_number,
        OMPMS_current_OS_name));
      for (oid=0, spamapent_p = p_OSD->Spacemap;	/* For each valid   */
           (int) oid <= max_entry;  oid++, spamapent_p++)
      {	/* entry...         */
        if ( (spamapent_p->flags != 0) &&		/* If object shows  */
             (spamapent_p->p_acld != NULL) )
        {            /*  signs of life   */
          flags = spamapent_p->flags;
          if ( !(spamapent_p->flags & OM_SM_unknown_obj) &&
                 classid == spamapent_p->p_acld->w_classid)
          {/* Obj in our class? */
            if (!OMpms_showSMentry (oid, spamapent_p, printedHdr, OSnum)) return(0);
            if (printedHdr) printedHdr = 0;
            obj_count++;				/* Displayed count   */
          }
          if (OMpms_pause() == -1) break;		/* End loop if user sez quit */
        }
      }						/* End of for loop */
      OMPMS_pgHdr[0] = 0;
    }
    else
    {
      PMSPRNT(("  NO space map entry"));
    }
    PMSPRNT( ("\n"));
    if (obj_count)
    {
      PMSPRNT( ("  --  Total %d object(s) found  --\n", obj_count));
    }
    else
    {
      PMSPRNT( ("  --  NO objects found  --\n"));
    }
  } /* if given a valid class */
  return (1);
} /* OMpms_find_objects =============================================== */
