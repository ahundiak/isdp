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

/* =============================================================== */

/*------------------------------------------------------------------
   prnt

   Function to print to standard output and to an optional log 
   file.
------------------------------------------------------------------*/
char *OMpms_searchStr (buf)
char          *buf;
{
  int         ii,  notIt;
  char        *lastNL = buf;
  char        saveEnd;

  while (*buf)
  {
    if (*buf == '\n')
    {
      lastNL = buf++;
      continue;
    }
    if (*buf = OMPMS_pgSeaStr[0])
    {
      notIt = FALSE;
      for (ii=0; ii<OMPMS_pgSeaStrLen; ii++)
      {
        if (*buf++ != OMPMS_pgSeaStr[ii])
        {
          notIt = TRUE;
          break;
        }
      }
      if (notIt) continue;
      OMPMS_pgSearching = FALSE;
      while (*buf && *buf != '\n') buf++;
      saveEnd = *buf;
      *buf = 0;
      printf ("FOUND:/n%s\n", lastNL);
      if (OMPMS_logfile) fprintf (OMPMS_logfile, "FOUND:\n%s\n", lastNL);
      getchar();
      OMPMS_pgCnt = 0;
      if (saveEnd) return (buf++);
      else return (0);
    }
  }
  return (0);
}

#define CR  13

int  OMpms_pause()
/*
    Description:

        gets one of the following Pause Responses from standard input:
          p: invoke PMS again
          s: show menu 
          q: quit current loop
          anything else, continue

    Return value:
        -1 indicates intention to quit
         1 indicates noremal exit
*/
{
  char    response;
  int     OM_PMS ();
  int     saveSea;
  
  if (OMPMS_Gf_pause == TRUE)  
  {

pause_prompt:
    OMPMS_pgCnt = 0;
    printf (" [pause] ");
    ECHO_TO_LOG ("%s", " [pause] ");
    response = getchar();
    OMPMS_pgCnt = 0;
    ECHO_TO_LOG("%c\n",response);
    switch (response)
    {
    case '?':
      PMSPRNT( ("\nResponses:"));
      PMSPRNT( ("\np: invoke PMS again"));
      PMSPRNT( ("\ns: show menu")); 
      PMSPRNT( ("\nq: quit current loop"));
      PMSPRNT( ("\nanything else, continue\n"));
      goto pause_prompt;
    case 'q':
      OMPMS_pgSearching = FALSE;
      return (-1);
    case 'p':
      saveSea = OMPMS_pgSearching;
      OM_PMS();
      OMPMS_pgSearching = saveSea;
      break;
    case 's':
      saveSea = OMPMS_pgSearching;
      OMpms_show ();
      OMPMS_pgSearching = saveSea;
    default:
      return (1);
    } /* switch */
  } /* if OMPMS_gf_pause */
  return(1);
} /* ============================================= routine OMpms_pause */

int OMpms_break()
{
PMSPRNT(("\nIf you were in sdb and had a break point here, it just happend."));
return(1);
} /* ================================================ OMpms_break */


OMpms_show_version_stamps()
{
   /* Print each entry in the application version stamp array.
    * The array may contain empty slots.  OM_Gi_number_of_appl_ids
    * is the number of used slots.  MAXNUMAPPVER is the size of
    * the array.
    */

   int      len, ii, count;

   if (!OM_Gi_number_of_appl_ids)
      PMSPRNT(("\nNo application verion stamps to report.\n"));
   PMSPRNT(("\n"));
   for (ii=count=0; (ii<MAXNUMAPPVER) &&
      (count<OM_Gi_number_of_appl_ids); ++ii)
   {
      if (!OM_GA_appl_version[ii])
         continue;
      count++;
      len = strlen(OM_GA_appl_version[ii]->curr_version);
      if ((!len) || (len >= OM_K_APPVER_LEN))
          continue;
      PMSPRNT(("%s\n", OM_GA_appl_version[ii]->curr_version));
   }
   return(1);
}


/*--------------------------------------------------------------------------
   OMpms_show_OS_mem
   
   Prints statistics about the use of space within an object space.  
   Assumes that OSnum is valid.
---------------------------------------------------------------------------*/

int OMpms_show_OS_mem(OSnum)
OMuword OSnum;  		/* Identifies the object space. */
								/*-fndesc*/
{
   OMuint          ii;            /* Loop counter. */
   OM_p_OSD        p_OSD;         /* OS descriptor. */
   OM_p_OBJECTHDR  p_object;      /* Pointer to each object in OS. */
   OMuword         classid;       /* Active classid. */
   int             fixed,         /* Fixed byte size of one object. */
                   total;         /* Total byte size of one object. */

   struct  class_stats {
      int     count;    	/* No. of objects of this class */
      int     size;     	/* Total bytes used by objs of this class */
      int     fixed;    	/* Bytes of non-vla data */
   } *stat;
   struct class_stats tot;
   int OMpms_show_an_OS();

   if (!OMpms_show_an_OS(OSnum,0)) return (0);
   if (NULL == (stat = (struct class_stats *) 
                        calloc(OM_Gw_numclasses,
                               sizeof(struct class_stats)))) {
      om$report_error(sts=OM_E_NODYNMEM);
      return (0);
   }
   tot.count = 0;
   tot.fixed = 0;
   tot.size = 0;
   for (ii=0, p_OSD=OM_GA_OSDs[OSnum]; ii < p_OSD->CurSpaceMapSize; ++ii)
      if (OM_OBJ_IN_MEM(p_OSD->Spacemap[ii].flags))
      {
         p_object = p_OSD->Spacemap[ii].state.object;
	 if( ( p_OSD->Spacemap[ii].flags & OM_SM_unknown_obj )
		&& p_OSD->Spacemap[ii].p_acld )
	 {
	   ++tot.count;
	   tot.size += OM_GETOBJSIZE(p_object->i_size);
	   tot.fixed += OM_GETOBJSIZE(p_object->i_size);
	 }
	 else
	 {
          classid = p_OSD->Spacemap[ii].p_acld->w_classid;
          if (classid < OM_Gw_numclasses)
            if (classid != 0 && classid != OM_K_NOTUSING_CLASSID) {
               ++stat[classid].count;
               ++tot.count;
               om$vla_get_size_of_object(object=p_object,
                                         p_cld=OM_GA_active_classes[classid],
                                         p_fixed_size=&fixed,
                                         p_total_size=&total);
               stat[classid].size += total;
               tot.size += total;
               stat[classid].fixed += fixed;
               tot.fixed += fixed;
            }
	 }
      }

   PMSPRNT(("\ntotal number of objects:        %10d\n",tot.count));
   PMSPRNT(("total byte size of all objects: %10d\n",tot.size));
   PMSPRNTHDR
(("-Classname-    -classid-  -count-   -size-     -avg-   -%%fixed-   -%%vla-\n-----------    ---------  -------   ------     -----   --------   ------\n"));
   for (ii=0; (OMuword) ii < OM_Gw_numclasses; ++ii)
      if (stat[ii].count) 
      {
         float f_size, f_count, f_fixed, f_vla;
         f_size = (float) stat[ii].size;
         f_count = (float) stat[ii].count;
         f_fixed = (float) stat[ii].fixed;
         f_vla = (float) (stat[ii].size - stat[ii].fixed);
         PMSPRNT(("%-15s %5d    %7d  %7d    %6.1f      %5.1f    %5.1f\n",
              OM_GA_active_classes[ii]->s_name,
              ii,
              stat[ii].count,
              stat[ii].size,
              f_size/f_count,
              100.0 * f_fixed/f_size,
              100.0 * f_vla/f_size
              ));
      }
   OMPMS_pgHdr[0] = 0;
   PMSPRNT(("\n"));
   free(stat);
   return (1);
}                                                                  

/*--------------------------------------------------------------
   OMpms_outputfile

   Allows the output of PMS to go to the specified file
----------------------------------------------------------------*/

int OMpms_outputfile()
								/*-fndesc*/
{
   char cmd[132];

   while(TRUE) {
      PMSPRNT(("\nf: set output file name"));
      PMSPRNT(("\nn: show name of current output file"));
      PMSPRNT(("\ns: stop sending output to a file"));
      PMSPRNT(("\nq: return to pms prompt"));
      printf("\n? ");
      if (OMPMS_pgLimit) OMPMS_pgCnt++;
      ECHO_TO_LOG("%s", "\n? ");
      while (isspace (cmd[0] = getchar()) || (IFDELETE(cmd[0])));
      OMPMS_pgCnt = 0;
      ECHO_TO_LOG("%c\n",cmd[0]);

      switch (cmd[0])
      {
         case 'f':
            printf("\nfile ? ");
            ECHO_TO_LOG ("%s", "file ? ");
#ifndef NT
            ioctl (terminal, TCSETA, &original);
#endif
            scanf("%14s",OMPMS_logname);
            OMPMS_pgCnt = 0;
#ifndef NT
            ioctl (terminal, TCSETA, &termset);
#endif
            getchar();
            ECHO_TO_LOG("%14s\n",OMPMS_logname);
            if (OMPMS_logfile) fclose(OMPMS_logfile);
            if (NULL == (OMPMS_logfile = (FILE *) fopen(OMPMS_logname,"a")))
            {
              PMSPRNT(("\nUnable to open \"%s\"\n",OMPMS_logname));
            }
            PMSPRNT(("\n"));
            return(1);
         case 'n':
            if (OMPMS_logfile)
            {
              PMSPRNT(("\noutput file: %s\n\n",OMPMS_logname));
            }
            else
            {
              PMSPRNT(("\nNo active output file\n\n"));
            }
            return(1);
         case 's':
            if (OMPMS_logfile) 
            {
              PMSPRNT(("\nstopping output to \"%s\"\n\n",OMPMS_logname));
              fclose(OMPMS_logfile);
              OMPMS_logfile = NULL;
              OMPMS_logname[0] = '\0';
            }
            else
            {
              PMSPRNT(("\nNo active output file\n\n"));
            }
            return(1);
         case 'q':
            PMSPRNT(("\n"));
            return(1);
         default:
            break;
      }         
   }
}

/*----------------------------------------------------------------------
    OMpms_xdump

    dumps the given number of long word from given address in hex

-----------------------------------------------------------------------*/
int  OMpms_xdump (addr_p, i_size)
int	**addr_p;			/* starting address to dump */
int	i_size;				/* number of long_words to dump */
					/*-private*/
					/*-fndesc*/
{
#define	IPL	8			/* 8 long_word per line */
	int	i,j;
	int	num_line;

  PMSPRNT(("\n"));
  PMSPRNTHDR
  ((" %d longword Hex dump from addr: 0x%8.8x\n",i_size, addr_p));
  num_line = i_size/IPL;
  for (i=0; i < num_line; i++) 
  {
	for (j=0; j<IPL; j++) 
	{
		PMSPRNT((" %8.8x", *addr_p));
		addr_p++;
	}
	PMSPRNT( ("\n"));
	i_size -= IPL;
  } /* for i<num_line */
  for (j=0; j<i_size; j++) 
  {
	PMSPRNT(( " %8.8x", *addr_p));
	addr_p++;
  }
  OMPMS_pgHdr[0] = 0;
  PMSPRNT( ("\n"));
  return (1);
}


static OMuint OMpms_prntSMflag (flags)
OMuint        flags;
{
  if (flags & OM_SM_array_mod)       
  {
    PMSPRNT(("VLAmod "));
    return (flags & ~OM_SM_array_mod);
  }
  if (flags & OM_SM_Rootdel_pending)
  {
    PMSPRNT(("delPen "));
    return (flags & ~OM_SM_Rootdel_pending);
  }
  if (flags & OM_SM_send_depth)
  {
    PMSPRNT(("inSend "));
    return (flags & ~OM_SM_send_depth);
  }
  if (flags & OM_SM_has_di_name)     
  {
    PMSPRNT(("diName "));
    return (flags & ~OM_SM_has_di_name);
  }
  if (flags & OM_SM_has_msgintrcpt)  
  {
    PMSPRNT(("intcpt "));
    return (flags & ~OM_SM_has_msgintrcpt);
  }
  if (flags & OM_SM_disable_intrcpt)  
  {
    PMSPRNT(("~Icept "));
    return (flags & ~OM_SM_disable_intrcpt);
  }
  if (flags & OM_SM_unknown_obj)     
  {
    PMSPRNT(("unkobj "));
    return (flags & ~OM_SM_unknown_obj);
  }
  return (0);
}

int OMpms_showSMentry (oid, spa_p, prHdr, osnum)
OM_S_OBJID        oid;
OM_p_SPAMAPENT    spa_p;
int               prHdr;
OMuword           osnum;
{
  int             flgCnt;
  OMuint          flags, moreSMflags;
  OM_p_OBJECTHDR  objhdr_p=NULL;
  unsigned char   hdrOidNotRight, moreHdrFlgs, tag;

  if (prHdr)
  {
    PMSPRNTHDR((" Objid     Class      Size-Clus-Slot- pObjHdr- Flags        SpaceMapFlags     \n ----- ------------ ------ ---- ---- -------- ------ -------------------------\n"));
  }
  hdrOidNotRight = FALSE;
  moreHdrFlgs = tag = FALSE;
  moreSMflags = 0;
  PMSPRNT(("%6d ", oid));
  if ((spa_p->flags==0) && (spa_p->p_acld==NULL) && (spa_p-> sdi==0))
  {
    PMSPRNT(("[EmptyEntry]\n"));
    return(1);
  } 
  if(spa_p->flags & OM_SM_unknown_obj)
  {
    PMSPRNT(("UOFC: %6d ",spa_p->p_acld));
  }
  else
  {
    PMSPRNT(("%-12s ",spa_p->p_acld->s_name));
  }
  if (OM_OBJ_IN_MEM(spa_p->flags))
  { /* obj in mem */
    objhdr_p = spa_p->state.object;
    flags = objhdr_p->i_size;
    PMSPRNT (("%6u ", OM_GETOBJSIZE(objhdr_p->i_size)));
    PMSPRNT (("%4d ",OM_GA_CSDarray[spa_p->sdi].p_pcd->p_lcd->w_cluster_num));
    PMSPRNT(("%4d ",spa_p->sdi));
    PMSPRNT(("%8.8x ", objhdr_p));
    if (OM_OBJ_HAS_VLA(flags) && (OM_OBJ_IS_TAGGED(flags)))
    {
      tag = TRUE;
      moreHdrFlgs = TRUE;
      PMSPRNT(("hasVLA "));
    }
    else
    {
      if (OM_OBJ_IS_TAGGED(flags))
      {
        PMSPRNT (("tagged "));
      }
      else if (OM_OBJ_HAS_VLA(flags))
      {
        PMSPRNT(("hasVLA "));
      }
      else
      {
        PMSPRNT(("       "));
      }
    }
    if(oid != objhdr_p->oid) hdrOidNotRight = TRUE;
  } /* obj in mem */
  else 
  { /* in file or swapped */
    PMSPRNT ((" [NIM] "));  /* for size field */
    if(OM_OBJ_IN_FILE(spa_p->flags)) 
    {
      PMSPRNT(("%4d  NIM          ", spa_p->state.filed_obj.clusterid));
    } 
    else
    { /* free */
      PMSPRNT((" NextOid: %8d ", spa_p->state.freeoid));
    }
  }
  flgCnt = 0;
  if (OM_OBJ_IN_MEM(spa_p->flags))
  {
    flgCnt++;
    PMSPRNT(("inMem  "));
  }
  if (OM_OBJ_IN_FILE(spa_p->flags))
  {
    flgCnt++;
    PMSPRNT(("inFile "));
  }
  moreSMflags = spa_p->flags & ~(OM_SM_in_use | OM_SM_in_mem);
  while ((moreSMflags = OMpms_prntSMflag(moreSMflags)) && (++flgCnt < 4));
  PMSPRNT(("\n"));
  if (hdrOidNotRight || moreHdrFlgs || moreSMflags)
  {
    if (hdrOidNotRight) 
    {
      PMSPRNT(("                               HdrOid:%8d ", 
        objhdr_p->oid));
    }
    else
    {
      PMSPRNT(("                                              "));
    }
    if (moreHdrFlgs)
    {
      PMSPRNT (("tagged ")); /* has to be TAGGED */
    }
    else 
    {
      PMSPRNT (("       "));
    }
    if (moreSMflags)
    {
      flgCnt = 0;
      while (moreSMflags)
      {
        while ((moreSMflags = OMpms_prntSMflag(moreSMflags)) && 
               (++flgCnt < 4));
        if (moreSMflags)
        {
          PMSPRNT(("\n"));
        }
        flgCnt = 0;
      }
      PMSPRNT(("\n"));
    }
    PMSPRNT(("\n"));
  }
  if (tag)
  {
     OMuint    tagid;
     OMuword   ver;
     int       sts;

     sts = om$objid_to_tag(osnum=osnum, objid=oid, p_tag=&tagid, p_version=&ver);
     if (1&sts)
     {
        PMSPRNT(("  Tag id: %d   Version: %d\n", tagid, ver));
     }
     else
     {
        PMSPRNT(("  om$objid_to_tag error:\n"));
        om$report_error(sts=sts);
        return 0;
     }
  }
  return(1);
}

/*
    Description:

    display target_channel_number and target_OS_oid of a channel

*/
int OMpms_show_chlink(link)
    OM_p_CHANNEL_LINK link;
{
  int			sts;
  char			chnam[OM_K_MAXCHANNAME_LEN];
  OMuword              	other_os;          /*  Returns from ISO stuff.  */
  OM_S_OBJID           	other_objid;
  OM_S_CHANNUM         	other_chan;
  OMuword              	other_flags;


  if (!(link->hdr.flags & OM_CL_to_object)) 
  {
    sts=som_ISO_fetch(OMPMS_current_OS_number,link->hdr.u1.isoindex,link->objid,
	&other_os, &other_objid, &other_chan, &other_flags);
    if (sts == OM_I_LOGICAL_DISCONNECT) 
    {
      PMSPRNT(("     HOLE (logical)\n"));
      return(1);
    }
    if ( !(1&sts) )
    {
      PMSPRNT( ("\n")); 
      om$report_error(sts=sts);
      OMPMS_pgCnt += 2;
      return(0);
    }
    PMSPRNT(("\n      TARGET_CHANNEL:(num=%d.%d",
            other_chan.classid, other_chan.number));

    sts = om$get_channel_name(channame=chnam, channum=other_chan);
    if (!(sts&1)) strcpy (chnam, "unk");
    PMSPRNT((" name=%s)", chnam));
    PMSPRNT((" To (OS=%d, oid=%d)", other_os, other_objid));
    PMSPRNT(("\n                     through ISO obj_id=%d index=%d",
	   link->objid, link->hdr.u1.isoindex));

  } 
  else 
  {	/* not an ISO connection */
    PMSPRNT(("\n      TARGET_CHANNEL:(num=%d.%d",
                link->channum.classid,link->channum.number));
    other_chan.classid = OM_GA_OSDs[OMPMS_current_OS_number]
			 ->FilToAct[link->channum.classid];
    other_chan.number = link->channum.number;
    sts = om$get_channel_name(channame=chnam, channum=other_chan);
    if (!(sts&1)) strcpy (chnam, "unk");
    PMSPRNT((" name=%s)", chnam));
    PMSPRNT((" To (OS=%d, oid=%d)", OMPMS_current_OS_number, link->objid));
  }
  return (1);
} /* int OMpms_show_chlink() ======================================= */

int OMpms_show_res_link(chdef, objid)
    OM_p_CHANNEL_TYPE_DEFN chdef;
    OM_S_OBJID		   objid;
/*
    Description:

    display target_channel_number and target_OS_oid of a channel

*/
					/*-fndesc*/
					/*-private*/
{
    OM_S_OBJID my_oid;

    PMSPRNT(("\n      TARGET_CHANNEL:(num=%d.%d",
                chdef->channum.classid,chdef->channum.number));

    PMSPRNT((" name=%s)", (char *)chdef->classids));
    if (chdef->w_flags & (CD_1_1|CD_m_1)) my_oid = objid >> 1;
    else my_oid = objid;
    PMSPRNT((" To (OS=%d, oid=%d)", OMPMS_current_OS_number, my_oid));
  return (1);
}

							/*+private*/
							/*+fndesc*/
/*--------------------------------------------------------------------
    OMpms_show_channel

    Displays data about a specific channel.
    If the channel is invalid, hex_dumps.
----------------------------------------------------------------------*/
							/*-fndesc*/
							/*-private*/
int OMpms_show_channel(p_chan_hdr, chdef, channum)
OM_p_CHANNEL_HDR          p_chan_hdr;
OM_p_CHANNEL_DEFN         chdef;
OM_S_CHANNUM              channum;
{
  char			  chnam[OM_K_MAXCHANNAME_LEN];
  OMuint		  ii;
  OM_p_CHANNEL_LINK       link;
  OM_p_CHANNEL_TYPE_DEFN  tdef;
  OM_p_OBJID		  p_objid;
  OM_S_BIG_TAIL	          tail;
  OMuword		  **ppclass;
  int			  sts;
  OM_S_CHANNUM		  chnum;
  OMuint		  collapse_count;
  OMuint		  last_index, chan_count;
  int                     res1chan;

  tdef = chdef->p_type;
  if ((tdef->w_flags & CD_restricted) && (tdef->w_flags & (CD_1_1|CD_m_1)))
     res1chan = 1;
  else
     res1chan = 0;

  PMSPRNT(("C H A N N E L :(num=%d.%d", channum.classid,channum.number));

  chnum.classid = channum.classid;
  chnum.number = channum.number;
  if (p_chan_hdr == NULL) 
  {				/* saw001 ... */
    PMSPRNT(("\n--Empty channel\n"));
    return(1);
  }

  sts = om$get_channel_name(channame=chnam, channum=chnum);
  if (!(sts&1)) 
  {		/* VL 10/10/86 */
    PMSPRNT( ("\n")); 
    om$report_error(sts=sts);
    OMPMS_pgCnt += 2;
    PMSPRNT(("\n Questionable channel at addr: 0x%8.8x",p_chan_hdr));
    if (!OMpms_xdump((int **) p_chan_hdr, 8)) return(0);
    return(1);
  }
  PMSPRNT((" name=%s)  ", chnam));
  if (OMPMS_Gf_brief) return(1);

  if (!res1chan)
  {
    PMSPRNT(("\n      Flags=0x%4.4x [", p_chan_hdr->flags));
  }
  if (res1chan || (p_chan_hdr->flags & OM_CH_singleton))
  {
    PMSPRNT((" singleton"));
  }
  if (tdef->w_flags & CD_1_1)
  {
    PMSPRNT((" 1_1"));
  }
  if (tdef->w_flags & CD_m_1)
  {
    PMSPRNT((" m_1"));
  }
  if (tdef->w_flags & CD_1_m)
  {
    PMSPRNT((" 1_m"));
  }
  if (tdef->w_flags & CD_m_m)
  {
    PMSPRNT((" m_m"));
  }
  if (tdef->w_flags & CD_absordered)
  {
    PMSPRNT((" absordered"));
  }
  if (tdef->w_flags & CD_relordered)
  {
    PMSPRNT((" relordered"));
  }
  if (res1chan || (p_chan_hdr->flags & OM_CH_full))
  {
    PMSPRNT((" full"));
  }
  if (tdef->w_flags & CD_restricted)
  {
    PMSPRNT((" restricted"));
  }
  if (!res1chan && (p_chan_hdr->flags & OM_CH_in_use))
  {
    PMSPRNT((" in_use"));
  }
  if (!res1chan && (p_chan_hdr->flags & OM_CH_tail_exists))
  {
    PMSPRNT((" tail_exists"));
  }
  if (!res1chan && (p_chan_hdr->flags & OM_CH_collapse_count))
  {
    PMSPRNT((" collapse_count"));
  }
  if (!res1chan && (p_chan_hdr->flags & OM_CH_preset))
  {
    PMSPRNT((" preset"));
  }
  if (!res1chan && (p_chan_hdr->flags & OM_CH_bigchan))
  {
    PMSPRNT((" bigchan"));
  }
  
  PMSPRNT((" ]"));
  PMSPRNT(("\n      Offset=%d  Init=%d  Extend=%d",
	 chdef->i_offset,tdef->InitCount,tdef->ExtCount));

  if (tdef->ClassCount) 
  {
    PMSPRNT(("\n      May connect to %d class(es):",tdef->ClassCount));
    if (tdef->w_flags & CD_restricted)
    {
      PMSPRNT((" \"%s\"(id=%d) ", (char *)tdef->classids, 
        tdef->channum.classid));
    }
    else 
    {
      ppclass = tdef->classids;
      for (ii=tdef->ClassCount; ii>0; ii--, ppclass++) 
      {
        if ((ppclass != NULL) && (*ppclass != NULL))
        {
          PMSPRNT((" \"%s\"(id=%d) ", OM_GA_active_classes[**ppclass]->s_name,
            **ppclass));
        }
        else 
        {
          PMSPRNT((" CLASSLIST - PREMATURE END\n"));
          break;
        }
      }
    }
  }
  if (tdef->w_flags & (CD_1_1|CD_m_1)) 
  {
    if (tdef->w_flags & CD_restricted) 
    {
      if (!OMpms_show_res_link(tdef, (OM_S_OBJID) p_chan_hdr)) return(0);
    }
    else 
    {
      link = (OM_p_CHANNEL_LINK)(p_chan_hdr);
      if (IF_NULL_OBJID(link->objid))
      {
        PMSPRNT(("\n      NO CONNECTION"));
      }
      else
      {
        if (!OMpms_show_chlink(link)) return(0);
      }
    }
  }  
  else 
  {  /* not singleton */
    if (p_chan_hdr->flags & OM_CH_tail_exists) 
    {
      OM_GET_TAIL(p_chan_hdr, tail);
      last_index = tail.last_index;
      collapse_count = tail.collapse_count;
    }
    else 
    {
      collapse_count = 0;
      last_index = p_chan_hdr->u1.count;
    }
    if (p_chan_hdr->flags & OM_CH_bigchan) chan_count = tail.size;
    else chan_count = p_chan_hdr->u1.count;

    PMSPRNT(("\n      Collapse_count=%d    Last_index=%d   VLA_sz=%d",
             collapse_count, last_index, chan_count));
    if (p_chan_hdr->flags & OM_CH_restricted ) 
    {
      p_objid = OM_PTR_TO_RESCHAN_LINK(p_chan_hdr);
      for (ii=0; ii < last_index; ii++, p_objid++) 
      {
        if (IF_NULL_OBJID(*p_objid))
        {
          PMSPRNT(("     HOLE\n"));
        }
        else
        {
          if (!OMpms_show_res_link(tdef, *p_objid)) return(0);
        }
      }
    }
    else 
    {
      link = OM_PTR_TO_CHAN_LINK(p_chan_hdr);
      for (ii=0; ii < last_index; ii++, link++) 
      {
        if (IF_NULL_OBJID(link->objid))
        {
  	  PMSPRNT(("     HOLE\n"));
  	}
        else
        {
 	  if (!OMpms_show_chlink(link)) return(0);
 	}
      }
    }
  }
  return (1);
}   /* int OMpms_show_channel (p_chan_hdr, chdef)==================== */

							/*+private*/
							/*+fndesc*/
/*-----------------------------------------------------------------
    OMpms_show_all_channels

    Called by OMpms_show_object.
    Calculates address of channel and channel definition of each
    channel found based on object header and class definition,
    then calls OMpms_show_channel for each channel.
------------------------------------------------------------------*/
							/*-fndesc*/
							/*-private*/
int OMpms_show_all_channels(ins, p_cld)
OM_p_OBJECTHDR ins;			/* ptr to object header */
OM_p_CLASSDEF  p_cld;			/* ptr to class definition */
{
  int sts, ii, jj;
  OM_p_MSGMAP pmap;
  OM_p_CHANNEL_DEFN chdef;
  OM_p_CHANNEL_HDR p_chan_hdr;
  OM_S_CHANNUM	   channum;
  char channame[OM_K_MAXCHANNAME_LEN];

  pmap = p_cld->MsgMap;
  for (ii=0; (OMuword) ii < p_cld->NumMsgClasses; ii++, pmap++)
  {	/* For each class msg */
   if (pmap->NumChan) {
    if (!OMPMS_Gf_brief)
    {
      PMSPRNT(("  %d channel(s) defined by class=%d \"%s\"  Offset=%d\n",
                pmap->NumChan,
                pmap->classid,
                OM_GA_active_classes[pmap->classid]->s_name,
                pmap->offset));
    }
    chdef = pmap->ChanDefns;		    /* Ptr to msg's chan defs     */
    for (jj=0; (OMuword) jj<pmap->NumChan; jj++, chdef++)
    {   /* For each chan def  */
      if (!OMPMS_Gf_brief)
      {
        PMSPRNT(("  (#%d)",jj));
      }

	/* Get each channel header from object header + message map offset
	   + channel definition offset */

       p_chan_hdr = *( (OM_p_CHANNEL_HDR *) ((int) ins + pmap->offset + chdef->i_offset) ); 				/* Ptr to chan header */

       strcpy(channame, OM_GA_active_classes[pmap->classid]->s_name);
       strcat(channame, ".");
       strcat(channame, chdef->s_name);

       sts = om$get_channel_number(channame=channame, p_channum=&channum);
       if (!(sts&1))
       {
          om$report_error(sts=sts);
          OMPMS_pgCnt += 2;
	  return(0);
       }

       if (!OMpms_show_channel(p_chan_hdr, chdef, channum)) return(0);
       if (OMpms_pause() == -1) break;		/* If user wants to quit...   */
       PMSPRNT(("\n"));
    }
   }
  }
  return (1);
} /* int OMpms_show_all_channels (ins, p_cld) =================*/



/*-----------------------------------------------------------------
    OMpms_split_string

    This function separates input string pointed to by p_s into 
    two substrings pointed to by p_s1, p_s2.  The input string is
    a classname & channel name combination or a class id & channel
    number combination.

    Return value :
       
    FALSE input string not in valid format
    TRUE  routine was able to parse input string into 2 strings
-------------------------------------------------------------------*/
bool OMpms_split_string(p_s, p_s1, p_s2)
char   *p_s;					/* input string */
char   *p_s1;					/* output substring 1 */
char   *p_s2;					/* output substring 2 */
{
    char   *p_separator;       /*  Ptr to period between class name and
                                   channel name in the CHAN_NAME string.  */
    int    len_s2;		/* Length of chan name or number string */
    int    len_s1;		/* Length of class name or id string */
    int    ii;

    p_s1[0]='\0';
    p_s2[0]='\0';

    if ((p_separator = (char *)strchr(p_s, '.')) == NULL)
      return(0);
    else {
      len_s1 = p_separator - p_s;
      len_s2 = strlen(p_s) - len_s1 - 1;
      strncpy(p_s1, p_s, len_s1);		/* Extract 1st part of str */
      p_s1[len_s1] = '\0';
      for (ii=0; ii<len_s2; ii++) {		/* Extract 2nd part of str */
        p_s2[ii] = *(++p_separator);
      }
      p_s2[ii]= '\0';

      return(1);
    }
} /* bool OMpms_split_string() ================================ */

/*-------------------------------------------------------------------------
    OMpms_show_spe_channel

    Displays each channel in linked list of user-specified channels,
    which was built by OMpms_get_channel.
---------------------------------------------------------------------------*/
int OMpms_show_spe_channel(ins, p_chanlist)
OM_p_OBJECTHDR		ins;
p_CHAN_NAME		p_chanlist;
{
	OM_p_CHANNEL_DEFN	chdef_p;
	OM_p_CHANNEL_HDR	*pp_chan_hdr, p_chan_hdr;
	OM_S_CHANSELECT		chsel;
	int			sts;
	OM_S_CHANNUM		chnum, channum;
	char			chnam[OM_K_MAXCHANNAME_LEN];
	char	s_class[OM_K_MAXCLASS_LEN];     /* parsed classname */
	char	s_channel[OM_K_MAXCHANNEL_LEN]; /* parsed chan name */

  for( ; p_chanlist; p_chanlist = p_chanlist->next) {
    if (isdigit(p_chanlist->name[0])){
      sts = OMpms_split_string(p_chanlist->name, s_class, s_channel);
      if (!sts) 
      {
        PMSPRNT(("\n\nInvalid channel specification: %s\n",p_chanlist->name));
        continue;
      }
      else 
      {
        chnum.classid = atoi(s_class);
        chnum.number = atoi(s_channel);
        sts = om$get_channel_name(channame=chnam, channum=chnum);
        if (!(sts&1)) 
        {
          PMSPRNT(("\n\nInvalid channel specification: %s\n",p_chanlist->name));
          om$report_error(sts=sts);
          OMPMS_pgCnt += 2;
          continue;
        }
      }
    }
    else strcpy(chnam, p_chanlist->name);	/* User requested channel by
    						   classname & channel name */
    chsel.type = OM_e_name;
    chsel.u_sel.name = chnam;

    sts = om$get_channel(object=ins, p_chanselect = &chsel,
                         pp_channel=&pp_chan_hdr, pp_chandef=&chdef_p,
			 p_channum=&channum);
    if (!(sts&1)) 
    {
      PMSPRNT(("\nInvalid channel specification: %s\n", p_chanlist->name));
      om$report_error(sts=sts);
      OMPMS_pgCnt += 2;
    }
    else 
    {
      PMSPRNT(("\n      "));
      p_chan_hdr = *pp_chan_hdr;
      if (!OMpms_show_channel(p_chan_hdr, chdef_p, channum)) return(0);
      PMSPRNT( ("\n"));
    }
  } /* for loop */

  return (1);
} /* int OMpms_show_spe_channel(ins)============================= */

/*-----------------------------------------------------------------
    OMpms_show_object
 
	This function check the eligibility of the given object id.
	If p_chanlist points to NULL, it displays an object with
	all channels; otherwise only with user specified channels.

    Return value:
      
	either OM_S_SUCCESS or the value returned by 
        om$get_any_instance, om$get_class
-------------------------------------------------------------------*/
							/*-fndesc*/
							/*-private*/
int OMpms_show_object (os, oid, p_chanlist)
OMuword		  os;
OM_S_OBJID	  oid;
p_CHAN_NAME    	  p_chanlist;   /* points to channel_list */
{
  OM_S_RIP	  rip;
  int 		  sts;
  OM_p_OBJECTHDR  ins;
  OM_p_SPAMAPENT  spa;

  sts = om$get_any_instance(osnum=os, objid=oid, p_rip=&rip);
  if (!(sts&1)) 
  {
    PMSPRNT(("\nInvalid object id: %d\n", oid));
    om$report_error(sts=sts);
    OMPMS_pgCnt += 2;
    return(1);
  }
  ins = rip.p_object;
  spa = rip.p_mapentry;
  if (!OMpms_showSMentry (oid, spa, TRUE, os)) return (0);

  if (spa->flags & OM_SM_unknown_obj) {
     om$release_any_instance( osnum = os, rip = rip);
     return(1);
  }

  if (p_chanlist)
  {
    if (!OMpms_show_spe_channel(ins, p_chanlist)) return(0);
  }
  else 
  {
    if (!OMpms_show_all_channels(ins, spa->p_acld)) return(0);
  }

  om$release_any_instance( osnum = os, rip = rip);
  return(1);
} /* int OMpms_show_object (os, oid, p_chanlist) ===================== */

					/*+private*/
					/*+fndesc*/
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
        if ( (spamapent_p->flags != 0) ||		/* If object shows  */
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

/*--------------------------------------------------------------------
    OMpms_get_channel

    This function prompts user for channels to display & builds a
    linked list of their channel names.  Channels can be requested
    by either of the following formats:
         (1) classname + '.' + channel name (e.g. OMCluster.to_OSO)
         (2) class_id + '.' + channel number (e.g. 1.0)

    RETURN STATUS:
	TRUE  was able to build list of channel names
        FALSE failure allocating memory while building list
----------------------------------------------------------------------*/
bool OMpms_get_channel(p_chanlist)
p_CHAN_NAME		*p_chanlist;
{
  char			channame[OM_K_MAXCHANNEL_LEN];
  p_CHAN_NAME		save_ptr, tmp_ptr;

  *p_chanlist = NULL;  
  tmp_ptr=NULL;
  while (TRUE) 
  {
    printf ("\nChannel [#Q to terminate]: ");
    ECHO_TO_LOG ("%s", "\nChannel [#Q to terminate]: ");
#ifndef NT
    ioctl (terminal, TCSETA, &original);
#endif
    scanf ("%s", channame);
    OMPMS_pgCnt = 0;
#ifndef NT
    ioctl (terminal, TCSETA, &termset);
#endif
    getchar();
    ECHO_TO_LOG("%s\n",channame);
    if (!strcmp ("#Q", channame)) return (TRUE);
    save_ptr = tmp_ptr;
    if (NULL == (tmp_ptr = (CHAN_NAME*) om$calloc(size=sizeof(CHAN_NAME)))) 
    {
      PMSPRNT( ("\n")); 
      om$report_error(sts=OM_E_NODYNMEM);
      OMPMS_pgCnt += 2;
      return(FALSE);
    }
    else 
    {					/* Building linked list... */
      if (*p_chanlist == NULL) *p_chanlist = save_ptr = tmp_ptr;
      else save_ptr->next = tmp_ptr;
    }
    strcpy(tmp_ptr->name, channame);		/* Store channel in list */
  } /* while */
} /*  int OMpms_get_channel(p_chanlist) ================= */

/*
    Description:

    This function gets minimum and maxinum value from user input
    if mininum value < lower_bound, 
          set minimum value to be lower_bound
    if maximum value > upper_bound,
          set maximum value to be upper_bound
*/
int OMpms_get_range(lower_bound, upper_bound, min_p,max_p) 
int      lower_bound, upper_bound;  /* lower/upper limit */
int      *min_p, *max_p;	    /* point to minimum/maximum value */
{
    char     cmd[132];

    while (isspace (cmd[0] = getchar()) || (IFDELETE(cmd[0])));
    OMPMS_pgCnt = 0;
    ECHO_TO_LOG("%s\n",cmd);
    while (TRUE) {
      if (cmd[0] == 'y') {
        *min_p = 0;
        break;
      } else if (cmd[0] == 'n') {

        printf("    range from: ");
        ECHO_TO_LOG ("%s", "    range from: ");
#ifndef NT
        ioctl (terminal, TCSETA, &original);
#endif
        scanf("%s",cmd);
#ifndef NT
        ioctl (terminal, TCSETA, &termset);
#endif
        getchar();
        ECHO_TO_LOG("%s\n",cmd);
        while ( !isdigit(cmd[0]) ) {
          printf("    from: (a NUMBER please!) ");
          ECHO_TO_LOG ("%s", "    from: (a NUMBER please!) ");
#ifndef NT
          ioctl (terminal, TCSETA, &original);
          scanf("%s",cmd);
          ioctl (terminal, TCSETA, &termset);
#else
          scanf("%s",cmd);
#endif
          getchar();
          ECHO_TO_LOG("%s\n",cmd);
        }
        *min_p = atoi(cmd);
        if (*min_p < lower_bound)  *min_p = lower_bound;

        printf(  "            to: ");
        ECHO_TO_LOG ("%s", "            to: ");
#ifndef NT
        ioctl (terminal, TCSETA, &original);
        scanf("%s",cmd);
        ioctl (terminal, TCSETA, &termset);
#else
        scanf("%s",cmd);
#endif
        getchar();
        ECHO_TO_LOG("%s\n",cmd);
        while ( !isdigit(cmd[0]) ) {
          printf("    to: (a NUMBER please!) ");
          ECHO_TO_LOG ("%s", "    to: (a NUMBER please!) ");
#ifndef NT
          ioctl (terminal, TCSETA, &original);
          scanf("%s",cmd);
          ioctl (terminal, TCSETA, &termset);
#else
          scanf("%s",cmd);
#endif
          getchar();
          ECHO_TO_LOG("%s\n",cmd);
        }
        *max_p = atoi(cmd);
        if (upper_bound < *max_p)  *max_p = upper_bound;

        if (*max_p < *min_p) 
        {
            PMSPRNT(("\n  Invalid range, try again!"));
            cmd[0]='n';
        } 
        else break;

      } 
      else 
      { /* neither 'y' nor 'n' */
        printf ("\n[y/n] ");
        ECHO_TO_LOG ("%s", "\t[y/n] ");
        while (isspace (cmd[0] = getchar()) || (IFDELETE(cmd[0])));
        ECHO_TO_LOG("%c\n",cmd);
      }
    } /* while */
    return(1);
} /* int OMpms_get_range(lower_bound,upper_bound,min_p,max_p) ====== */

int OMpms_show_spacemap(OSnum)
uword  			OSnum;
/*
    Description:

    shows all object headers in an Object Space
*/
					/*-fndesc*/
					/*-private*/
{
  int             ii, min_entry, max_entry, printedHdr = TRUE;
  OM_p_OSD        p_OSD;
  OM_p_SPAMAPENT  spa_p;

  OMPMS_pgSearching = OMPMS_pgCnt = 0;
  p_OSD = OM_GA_OSDs[OSnum];
  PMSPRNT(("\n"));
  PMSPRNT(("OS: %32s  OS number: %17d\n", p_OSD->name, p_OSD->OSnum));
  if (p_OSD->CurSpaceMapSize) 
  {
    PMSPRNT(("Number of SpaceMap entries: %8d", p_OSD->CurSpaceMapSize));
    PMSPRNT(("  SpaceMap  addr:   0x%8.8x", p_OSD->Spacemap));

    /* find out maximum entry number in use */

    for (ii=p_OSD->CurSpaceMapSize-1, spa_p=p_OSD->Spacemap+ii; 
        ii>=0; ii--, spa_p--)
      if (!(OM_OBJ_INVALID(spa_p->flags))) break;

    max_entry=ii;
    OMPMS_pgSearching = OMPMS_pgCnt = 0;
    printf("\n    To list object_id range from 0 to %d ? [y/n] ", max_entry);
    ECHO_TO_LOG("\n    To list object_id range from 0 to %d ? [y/n] ", 
      max_entry);

    /* input object range */
    OMpms_get_range(0, (int)p_OSD->CurSpaceMapSize, &min_entry, &max_entry);
    PMSPRNT(("\n"));
                                      
    for (ii=min_entry,spa_p=&p_OSD->Spacemap[ii]; 
         ii <= max_entry;  ii++,spa_p++) 
    {
      if (!OMpms_showSMentry((OM_S_OBJID) ii, spa_p, printedHdr, OSnum))
         return (0);
      if (printedHdr) printedHdr = 0;
      if (OMpms_pause() == -1) break;
    } /* for ii < p_OSD->CurSpaceMapSize */
    OMPMS_pgHdr[0] = 0;
  }
  else 
  {
    PMSPRNT(("  NO space map entry"));
  }
  return (1);
} /* OMpms_show_spacemap ========================================== */

/*
    Description:
        gets OS name or number and verify it.

    Global data being changed:
	OMPMS_current_OS_number
	OMPMS_current_OS_name

    Return value:
        TRUE  indicates normal exit
        FALSE indicates #Q terminates
*/
bool OMpms_get_OS (OSnum)
uword   *OSnum;
{
  char    OSname[132];
  int    sts;
  int    input_OS;
  
  while (TRUE)  
  {
    printf ("\nObject Space: [#Q to quit] ");
    ECHO_TO_LOG ("%s", "Object Space: [#Q to quit] ");
#ifndef NT
    ioctl (terminal, TCSETA, &original);
    scanf ("%s", OSname);
    OMPMS_pgCnt = 0;
    ioctl (terminal, TCSETA, &termset);
#else
    scanf ("%s", OSname);
    OMPMS_pgCnt = 0;
#endif
    getchar();
    ECHO_TO_LOG("%s\n",OSname);
    if (!strcmp ("#Q", OSname)) return (FALSE);
    if (!(strcmp ("-", OSname)))    
    {
      if (OMPMS_current_OS_number != (uword)-1)      
      {
        PMSPRNT( ("No current OS defined\n"));
        continue;
      }
      if (!OM_GA_OSDs[OMPMS_current_OS_number]) 
      {   
        PMSPRNT( ("%s no longer exists as an OS\n", OMPMS_current_OS_name));
        OMPMS_current_OS_number = (uword)-1;
        strcpy (OMPMS_current_OS_name, "");
        continue;
      } 
      else strcpy (OSname, OM_GA_OSDs[OMPMS_current_OS_number]->name);
      *OSnum = OMPMS_current_OS_number;
      return (TRUE);
    }  
    else 
    if (isdigit(OSname[0]))  
    {
      *OSnum = input_OS = atoi (OSname);
      if ( (*OSnum >= OM_Gw_maxOS) || !OM_GA_OSDs[*OSnum]) 
      {
        PMSPRNT( ("Invalid OS number\n"));
        om$report_error (sts=OM_E_NOSUCHOS);
        OMPMS_pgCnt += 2;
        continue;
      } 
      else strcpy (OSname, OM_GA_OSDs[*OSnum]->name);
    } 
    else 
    {
      sts = om$os_name_to_number(osname=OSname, p_osnum=OSnum);
      if (!(1& sts))
      {
        PMSPRNT( ("Invalid or Unknown Object Space name\n"));
        om$report_error (sts=OM_E_NOSUCHOS);
        OMPMS_pgCnt += 2;
        continue;
      }
    }
    OMPMS_current_OS_number = *OSnum;
    strcpy (OMPMS_current_OS_name, OSname);
    return (TRUE);
  } /* while */
} /* routine  OMpms_get_OS (OSnum) ========================== */

/*
    Description:

    shows data structure of cluster extents of a given OS

*/
int OMpms_show_cluster_extents(OSnum)
uword           OSnum;
{
  OM_p_OSD        p_OSD;
  int             ii, max_entry, min_entry;
  OM_p_FCD        clustfree_p;
  OM_p_PCD   	  pcd_p;
  OM_p_LCD	  lcd_p;

  p_OSD = OM_GA_OSDs[OSnum];
  PMSPRNT(("\nOS: %32s  OS number: %22d\n", p_OSD->name, p_OSD->OSnum));
  if (p_OSD->ClustersSize)
  {
    PMSPRNT(("Number of Logical Clusters: %8d", p_OSD->ClustersSize));
    PMSPRNT(("  ClustersArray  addr:   0x%8.8x\n", p_OSD->Clusters));

         /* Get number of clusters in use */

    for (max_entry=p_OSD->ClustersSize-1, lcd_p=p_OSD->Clusters[max_entry];
         max_entry>=0; max_entry--, lcd_p=p_OSD->Clusters[max_entry])
      if ( lcd_p ) break;     /* non null pointer */
    OMPMS_pgSearching = OMPMS_pgCnt = 0;
    printf("\n    To list clusters range from 0 to %d ? [y/n] ", max_entry);
    ECHO_TO_LOG ("\n    To list clusters range from 0 to %d ? [y/n] ", 
      max_entry);
    OMpms_get_range(0, (int)p_OSD->ClustersSize, &min_entry, &max_entry);
    PMSPRNT(("\n"));

    for (ii=min_entry,lcd_p=p_OSD->Clusters[ii];
         ii <= max_entry;  ii++,lcd_p=p_OSD->Clusters[ii])
    {
      if(! lcd_p )
      {
        PMSPRNT(("\n Empty Cluster Slot\n"));
      }
      else
      {
          PMSPRNT(("\n\n  Cluster %4d                         Oid:    %25d",
              ii , lcd_p->oid));
          PMSPRNT(("\n    File Ptr:           %12d", lcd_p->i_file_ptr));
          PMSPRNT(("\n    Flags: 0x%8.8x", lcd_p->flags));
          if(lcd_p->flags & OM_FAULTED) 
          {
            PMSPRNT(("  Faulted"));
          }
          if(lcd_p->flags & OM_USERSPEC) 
          {
            PMSPRNT(("  User specified"));
          }
          pcd_p = (OM_p_PCD) lcd_p->pcdq_lh.next;
          while (pcd_p != (OM_p_PCD) &(lcd_p->pcdq_lh.next))
          {
            PMSPRNT(("\n\n    PCD                   0x%8.8x",pcd_p));
            if(pcd_p->p_lcd != lcd_p)
            {
              PMSPRNT(("\n*** PCD has CORRUPT LCD pointer ***"));
            }
            PMSPRNT(("\n    Size:                 %10u",pcd_p->i_totalsize));
            PMSPRNT(("   Size with Sheap:       %10u",pcd_p->i_totalWsheap));
            PMSPRNT(("\n    Num Objs:             %10u   Num Chunks:            %10u",
            pcd_p->i_cur_num_objects, pcd_p->i_cur_num_chunks));
            if(pcd_p->lcfq.next != (OM_p_DLINK) &(pcd_p->lcfq.next))
            {
              PMSPRNT(("\n    On Faulted Queue"));
            }
            else
            {
              PMSPRNT(("\n    Not On Faulted Queue"));
            }
            {
              OM_p_CSD    csd_p;

              if(csd_p = pcd_p->p_csd)
              {
                if(csd_p->p_pcd != pcd_p)
                {
                  PMSPRNT(("\n*** CSD has CORRUPT PCD pointer ***"));
                }
                PMSPRNT(("               Memory Resident"));
                PMSPRNT(("\n\n    CSD                   0x%8.8x", csd_p));
                PMSPRNT(("\n    Start addr:           0x%8.8x", csd_p->p_addr));
                PMSPRNT(("   CSD index:                 %6u", csd_p->index));
                PMSPRNT(("\n    PreSendDepth:         %10u", csd_p->PreSendDepth));
                PMSPRNT(("   PostSendDepth:         %10u", csd_p->PostSendDepth));
                PMSPRNT(("\n    Flag:  0x%4.4x",csd_p->flag));
                if(csd_p->flag & OM_CLUST0)  
                {
                  PMSPRNT(("  Cluster 0"));
                }
                if(csd_p->flag & OM_BIG)  
                {
                  PMSPRNT(("  Big"));
                }
                if(csd_p->flag & OM_INUSE)  
                {
                  PMSPRNT(("  InUse"));
                }
              }
            } /* else */
            clustfree_p = pcd_p->p_fcd;
            if (clustfree_p != NULL)
            {
              PMSPRNT(("\n\n    Free fragments:       %10u",
               pcd_p->i_numfree_chunks));
              PMSPRNT( ("   Total free:%22u\n",pcd_p->i_totalfree));
            }
            while (clustfree_p != NULL)
            {
              PMSPRNT(("\n   %10d bytes at addr 0x%8.8x", 
                ( 0x7fffffff & (clustfree_p->size)), 
                  clustfree_p->freehdr));
              clustfree_p = clustfree_p->nextfcd;
            } /* while */
            pcd_p = (OM_p_PCD) pcd_p->pcdq.next;
          }  /* while */
          if (lcd_p->pcdq_lh.next == (OM_p_DLINK) &(lcd_p->pcdq_lh.next)) 
          {
            PMSPRNT( ("\n    NO physical clusters\n"));
          }
       } /* else print LCD specific info */
    } /* for next Logical Cluster */
    OMPMS_pgHdr[0] = 0;
  }  /* if any clusters */
  else
  {
    PMSPRNT( ("  NO clusters\n"));
  }
  return(1);
} /* routine OMpms_show_cluster_extents(OSnum) */


/*
    Description:

    to show data structure of a given OS with its OSCOs
*/
int OMpms_show_an_OS (OSnum,OSCO_print_flag)
uword             OSnum;
int               OSCO_print_flag;
{
  OM_p_OSD          p_OSD;
  OMuint            jj;
  OMuint            OStype, flags;
  OM_p_LCD     	    lcd_p;  
  OMuword           ii;

  PMSPRNT( ("\n"));

  p_OSD = OM_GA_OSDs[OSnum];
  OStype = p_OSD->type;
  PMSPRNT( ("\nOS: %32s  OS number:          %8d", p_OSD->name, OSnum));
  PMSPRNT( ("\nOSO object id:            %10u  Group_0 object id:%10u"
           , p_OSD-> OSO_Oid, p_OSD->Group0_Oid));
  PMSPRNT( ("\nOS type: (%d)               ", OStype));
  switch (OStype)
  {
  case OM_OSD_MOSDOS:
    PMSPRNT( ("directory  "));
    PMSPRNT( ("Max_OS_size:      %10u\n", p_OSD->MaxOSSize));
    break;
  case OM_OSD_trans:
    PMSPRNT( ("transient  "));
    PMSPRNT( ("Max_OS_size:      %10u\n", p_OSD->MaxOSSize));
    break;
  case OM_OSD_filed:
    PMSPRNT( ("    filed"));
    if (p_OSD->flags & OM_OSD_nowrite)  
    {
      PMSPRNT( ("  (not writeable)"));
    }  
    else  
    {
      PMSPRNT( ("  (writeable)"));
    }

    if (p_OSD->flags & OM_e_loados_ro) 
    {
      PMSPRNT( ("  (read only)"));
    }
    PMSPRNT( ("\nInternal_OSname: %s ", p_OSD->InternalName));
    PMSPRNT( ("\n"));  
    PMSPRNT( ("Max_OS_size:      %18u\n", p_OSD->MaxOSSize));
  break;
  default:
    PMSPRNT( ("UNKNOWN or UNSUPPORTED TYPE (!)       "));
    PMSPRNT( ("Max_OS_size:      %10u\n", p_OSD->MaxOSSize));
    break;
  } /* switch (OStype)  */
  

  flags = p_OSD->flags;
  PMSPRNT( ("Flags:  0x%4.4x   ", flags));

  if ( (OM_OSD_nowrite & flags) && (OM_OSD_inuse & flags) ) 
  {
    PMSPRNT( ("[inuse notwritable]"));
  } 
  else 
  {
    if (OM_OSD_inuse & flags)         
    {
      PMSPRNT( (" [inuse]"));
    }
    if (OM_OSD_nowrite & flags)       
    {
      PMSPRNT( (" [not_writable]"));
    }
  }
  if (OM_OSD_modified & flags)        
  {
    PMSPRNT( (" [OS_modified]"));
  }
  if (OM_OSD_ISOmodified & flags)     
  {
    PMSPRNT( (" [ISO_modified]"));
  }
  if (OM_e_loados_ro & flags)         
  {
    PMSPRNT( (" [os_read_only]"));
  }

  PMSPRNT( ("\nAct/File:                 0x%8.8x  File/Act:         0x%8.8x\n"
           , p_OSD->ActToFil, p_OSD->FilToAct));
  if (NULL != p_OSD->ActToFil)  
  {
    for (ii=0; ii < OM_Gw_next_class_index; ii++) 
    {
      if (((p_OSD->ActToFil[ii] != ii) && 
           (p_OSD->ActToFil[ii] != (uword)-1))
            || 
          ((p_OSD->FilToAct[ii] != ii) &&
           (p_OSD->FilToAct[ii] != (uword)-1)))
      {
        if (p_OSD->ActToFil[ii] != 0) 
        {
          if (0 == OM_GA_active_classes[ii])
          {
            PMSPRNT( ("  Class  (UNKNOWN CLASS) "));
          }
          else 
          {
            PMSPRNT( ("  Class %16s ", 
              OM_GA_active_classes[ii]->s_name));
          }
        PMSPRNT( (" has map differ: A/F[%3d]=%4d, F/A[%3d]=%4d\n", 
          	ii,p_OSD->ActToFil[ii],
		p_OSD->ActToFil[ii], 
		p_OSD->FilToAct[ p_OSD->ActToFil[ii] ]));
        }
      } /* if p_OSD->ActToFil */
    } /* for ii */
  } /* if NULL */

  PMSPRNT( ("Number of spacemap entries:%9u  Space Map addr:   0x%8.8x\n",
           p_OSD->CurSpaceMapSize, p_OSD->Spacemap));

  if (! OSCO_print_flag) return(1);

  if (p_OSD -> ClustersSize) 
  {
    PMSPRNT( ("Number of clusters:  %15d  Clusters addr:    0x%8.8x\n",
           p_OSD->ClustersSize, p_OSD->Clusters));
    if (!OMPMS_Gf_brief)
    {
      PMSPRNTHDR((
"Cluster  Oid                      Flags                            \n------- ------ ----------------------------------------------------\n" ));
      for (jj=0; jj<p_OSD->ClustersSize; jj++) 
      {
         if (lcd_p = p_OSD-> Clusters[jj])
         {
            PMSPRNT(("%7d ", jj));
            PMSPRNT( ("%6u ", lcd_p->oid));
   	    if(lcd_p->flags & OM_FAULTED)
            {
               PMSPRNT(("faulted "));
            }
            if(lcd_p->flags & OM_USERSPEC)
            {
               PMSPRNT(("userSpecified "));
            }
            if (OMpms_pause() == -1) break;
            PMSPRNT(("\n"));
         }
      } /* for next Cluster */
      OMPMS_pgHdr[0] = 0;
    }/* if verbose */
  }/* if there is cluster */

  /* display OSCOs */
  if (OM_Gw_numclasses) 
  {
    OM_p_OSCO  osco_p;
    int        count;

    for (ii=0, count=0; ii<OM_Gw_numclasses; ii++) 
    {
      osco_p = p_OSD -> OSCO_list[ii];
      if (osco_p) count++;       
    }
    PMSPRNT(("\nNumber of OSCOs:               %5d\n\n", count));
    if (!OMPMS_Gf_brief) 
    {
      PMSPRNTHDR((
" OSCO     class       Ver   opp  FilID  ActID   Oid    # childOSCO  # objects\n-----  ------------  -----  ---  -----  -----  ------  -----------  ---------\n"));
      for (ii=0; (OMuword) ii<OM_Gw_numclasses; ii++) 
      {
        osco_p = p_OSD -> OSCO_list[ii];
        if (osco_p)
        {
          PMSPRNT(("%5d  %-12s  %2d.%-2d  %1d.%1d  %5d  %5d  %6d  %11d  %9d\n",
             ii, osco_p->s_name, 
             osco_p->w_major_version, osco_p->w_minor_version, 
             osco_p->w_oppmaj_version, osco_p->w_oppmin_version,
             osco_p->w_classid,
             OM_GA_OSDs[OSnum]->FilToAct[osco_p->w_classid], 
             osco_p->OSCO_oid, 
             osco_p->w_child_refcnt, osco_p->i_refcnt));
          }
        if (OMpms_pause() == -1) break;
      } /* for ii<OM_Gw_numclasses */
      OMPMS_pgHdr[0] = 0;
    } /* if verbose */
  } /* if there is OSCO */
  return(1);
} /* routine OMpms_show_an_OS */

int OMpms_show_all_OS ()
{
  int      null_count, ii;
  char     cmd;
  
  null_count = 0;
  
  for (ii=0; (OMuword) ii < OM_Gw_maxOS; ii++)  
  {
    if ( OM_GA_OSDs[ii] != 0)  
    {
      if (!OMpms_show_an_OS (ii,1)) 
      {
        OMPMS_pgCnt = 0;
        PMSPRNT (("Next OS? "));
        while (isspace (cmd = getchar()) || (IFDELETE(cmd)));
        ECHO_TO_LOG ("%c\n", cmd);
        if (cmd == 'y' || cmd == 'Y') continue;
        return(0);
      }
      if (OMpms_pause() == -1) break;
      if (null_count != 0) 
      {
        PMSPRNT( ("\n(%d unused slots)", null_count));
        null_count = 0;
      }
      continue;
    } 
    else 
    {
      null_count++;
    }
  } /* for ii */
  if (null_count != 0)  
  {
    PMSPRNT( ("\n(%d unused slots)", null_count));
  }
  return(1);
} /* routine  OMpms_show_all_OS() */


int  OMpms_show_class (classid)
uword      classid;
{
  OM_p_CLASSDEF           p_ACLD;
  int                     ii,jj, hdrPrt;
  OM_p_MSGMAP             msgmap_p, p1;
  OM_p_CHANNEL_TYPE_DEFN  ChTyp_p;
  OM_p_CHANNEL_DEFN       ChDf_p, p2;
  OM_S_METHDEFN           *method_p;
  OM_p_FUNCPTR            *methtbl_p  /* points to current method table */
                          , *omethtbl_p /* original method table */
                          ;
  int                     mapidx, num_methods;
  OM_p_CLASSDEF           pcld_p;  /* pointer to parent's CLD */
    

  if (NULL != (p_ACLD = OM_GA_active_classes [classid]))  
  {
    PMSPRNT( ("\n\nClass: %-12s (%2d.%-2d)  ActID: %5d  ",
          p_ACLD->s_name, p_ACLD->w_major_version, 
          p_ACLD->w_minor_version, p_ACLD->w_classid));
    PMSPRNT( ("opp version: %d.%d  DefObjSize: %5d\n",
             p_ACLD->w_oppmaj_version, p_ACLD->w_oppmin_version, 
             p_ACLD->i_instance_size));
    if (classid != p_ACLD->w_classid)    
    {
      PMSPRNT( ("WARNING: active classid NE class index!\n"));
    }

    if (p_ACLD->A_ancestor_list != NULL)    
    {
      PMSPRNT( ("%d immediate parent(s):", p_ACLD->w_numparents));
      for (ii=0; (OMuword) ii < p_ACLD->w_numparents; ii++)      
      {
        jj = *(p_ACLD->A_ancestor_list[ii].p_classid);
        if (ii) 
        {
          PMSPRNT( (", %s",OM_GA_active_classes[jj]->s_name));
        } 
        else 
        {
          PMSPRNT( (" %s", OM_GA_active_classes[jj]->s_name));
        }
      } /* for ii < p_ACLD->numparents */
      PMSPRNT(("\n"));
    } /* there is ancester */
      
    if (OMPMS_Gf_brief == TRUE) return(1);
    
    if (p_ACLD->w_num_varlenarrays) 
    {
      PMSPRNT( ("\nNumber of variable length arrays:%4d\n",
          p_ACLD->w_num_varlenarrays));
      PMSPRNTHDR ((
"VLA#  Offset     (hex)    ElemCnt  ElemSiz    (hex)  \n----  ------  ----------  -------  -------  ---------\n"));
      for (ii=0; (OMuword) ii < p_ACLD->w_num_varlenarrays; ii++) 
      {
        PMSPRNT( ("%4d  %6d  (%8x)  %7d  %7d  (%7x)\n",
          ii, p_ACLD->p_varlenarr_defns[ii].w_offset, 
          p_ACLD->p_varlenarr_defns[ii].w_offset, 
          p_ACLD->p_varlenarr_defns[ii].w_count, 
          p_ACLD->p_varlenarr_defns[ii].w_per_elt_size, 
          p_ACLD->p_varlenarr_defns[ii].w_per_elt_size));
      } /* for ii */
      OMPMS_pgHdr[0] = 0;
    } 
    else 
    {
      PMSPRNT( ("\nClass has NO variable length array\n"));
    }
    
    hdrPrt = FALSE;
    for (msgmap_p = p_ACLD->MsgMap, p1=msgmap_p + p_ACLD->NumMsgClasses
      ; msgmap_p < p1; msgmap_p++)
    {
      if (msgmap_p->NumChan) 
      {
        if (!hdrPrt)
        {
          PMSPRNT(("\n"));
          PMSPRNTHDR((
"    Channel Name      From Class               Connectable Classes            \n-------------------- ------------- -------------------------------------------\n"));
          hdrPrt = TRUE;
        }
        for (ChDf_p = msgmap_p -> ChanDefns, p2=ChDf_p+msgmap_p->NumChan;
             ChDf_p < p2; ChDf_p++) 
        {
          PMSPRNT( ("%-20s ", ChDf_p->s_name));
          if (msgmap_p->classid == p_ACLD ->w_classid) 
          {
            PMSPRNT(("  *ORIGINAL*  "));
          } 
          else 
          {
            PMSPRNT(("%-12s  ", 
              OM_GA_active_classes[msgmap_p->classid]->s_name ));
          }

          ChTyp_p = ChDf_p -> p_type;
          if (ChTyp_p->ClassCount) 
          {
            if ( ChTyp_p->w_flags & CD_restricted )
            {
              PMSPRNT(("%s <RESTRICTED>", (char *)ChTyp_p->classids));
            }
            else
            {
              for (ii=0; ii< (int) ChTyp_p->ClassCount; ii++)
              {
                PMSPRNT(("%s ", 
                  OM_GA_active_classes[*(ChTyp_p->classids[ii])]->s_name));
              } /* for ii */
            }
          } 
          else 
          {
            PMSPRNT(("<<May connect to ANY class>>"));
          } /* if ChTyp_p->ClassCount */
          PMSPRNT(("\n"));
        } /* for ChDf_p */
      } /* if msgmap_p->NumChan */
    } /* for msgmap_p */
    OMPMS_pgHdr[0] = 0;
    PMSPRNT(("\n"));
    
    PMSPRNTHDR((
"      Message Name                   Source           \n------------------------  ----------------------------\n"));
    for (msgmap_p = p_ACLD->MsgMap, p1=msgmap_p+p_ACLD->NumMsgClasses
      ; msgmap_p <p1; msgmap_p++) 
    {
      methtbl_p = msgmap_p -> MethTbl;
      if (methtbl_p) 
      {
        if (msgmap_p ->classid == p_ACLD->w_classid) 
        { /* current CLD */
          method_p = p_ACLD->p_methdefns;
          for (ii=0; (OMuword) ii<p_ACLD->w_nummethods; ii++)
          {
            PMSPRNT(("%-24s           *ORIGINAL*\n", method_p-> s_name));
            method_p = method_p ->next;
          } /* for ii < p_ACLD->w_nummethods */
        } 
        else 
        { /* ancestor's CLD */
          pcld_p = OM_GA_active_classes[msgmap_p->classid];
          num_methods = pcld_p -> w_nummethods;
          if (num_methods) 
          {
            method_p = pcld_p -> p_methdefns;
            if (pcld_p->w_classid == 0) /* Root class */
              mapidx = 0;
            else 
              mapidx = 
                pcld_p->p_transmap[pcld_p->w_classid - pcld_p->w_baseclass];
            if ((mapidx == OM_K_NULL_TRANS) &&
               (pcld_p->w_classid != (OMuword) mapidx))
            {
              PMSPRNT( ("WARNING: classid %d does not contain message map of its own.\n"
                      , pcld_p->w_classid));
            } 
            else 
            {
              omethtbl_p = pcld_p->MsgMap[mapidx].MethTbl;
              if (methtbl_p == omethtbl_p) 
              { /* inherited all */
                for ( ii= 0; ii<num_methods; ++ii) 
                {
                  PMSPRNT( ("%-24s  Inherited from: %s\n", method_p->s_name, 
                    pcld_p->s_name));
                  method_p = method_p->next;
                } /* for ii >= 0 */
              } 
              else 
              { /* overrode some */
                for ( ii= 0; ii<num_methods; ++ii) 
                {
                  PMSPRNT(("%-24s  ", method_p->s_name));
                  if (methtbl_p[ii]==omethtbl_p[ii])
                  { /* inherited */
                    PMSPRNT( ("Inherited from: %s\n", pcld_p->s_name));
                  } 
                  else 
                  { /* overrode */
                    PMSPRNT( ("Overrode  from: %s\n", pcld_p->s_name));
                  } /* if methtbl_p[ii] */
                  method_p = method_p->next;
                } /* for ii */
              } /* if (methtbl_p== */
            } /* if (mapidx == */
          } /* num_methods */
        } /* if msgmap_p-> classid */
      } /* if methtbl_p */
    } /* for msgmap_p */
    OMPMS_pgHdr[0] = 0;
  } 
  else 
  if (OMPMS_Gf_pause == FALSE)
  {
    PMSPRNT( ("\nClassid %d has no ACLD", classid));
  }
  PMSPRNT( ("\n"));
  return(1);
} /* routine OMpms_show_class (classid) */


int  OMpms_show_all_classes ()
{
  int         ii, count;
  char        cmd;
    
  count = 0;
  PMSPRNT(("\n"));
  for (ii=0; (OMuword) ii < OM_Gw_next_class_index; ii++)  
  {
    if (0 == OM_GA_active_classes[ii])    
    {
      count++;
      continue;
    }
    if (count != 0)    
    {
      PMSPRNT( ("\n\n(%d empty ACLD slots)\n", count));
      count = 0;
    }
    if (!OMpms_show_class (ii))
    {
      OMPMS_pgCnt = 0;
      PMSPRNT (("Next Class? "));
      while (isspace (cmd = getchar()) || (IFDELETE(cmd)));
      ECHO_TO_LOG ("%c\n", cmd);
      if (cmd == 'y' || cmd == 'Y') continue;
      return (0);
    }
    if (OMpms_pause() == -1) break;
  }
  return(1);
} /* routine OMpms_show_all_classes () */


int  OMpms_show_queue(hdr, pListhead)
char                    *hdr;
OM_p_DLINK	        pListhead;
{
  OM_p_DLINK	tmp;
  
  if(OM_QUEUE_EMPTY(pListhead))
  {
    PMSPRNT(("\n    %s is empty\n", hdr));
  }
  else
  {
    PMSPRNT(("\n"));
    PMSPRNTHDR(("    %s\n", hdr));
    PMSPRNT (("(ListHead:  next: %8x  prev: %8x)\n",
      pListhead->next,pListhead->prev));
    tmp = pListhead->next;
    while( tmp != pListhead )
    {
      PMSPRNT(("            next: %8x  prev: %8x\n",tmp->next,tmp->prev));
      tmp = tmp->next;
    }
  }
  OMPMS_pgHdr[0] = 0;
  return(1);
}


int OMpms_showSysgen ()
{
  int             ii;
  

  PMSPRNT(("\n"));
  PMSPRNTHDR (("OM Sysgen Variables:\n--------------------\n"));
  for (ii=0; ii<OM_K_NUMBER_PARAMETERS; ii++)
  {
    PMSPRNT (("%-22.22s CurVal: ", OM_GA_param_defs[ii].s_name));
    if (OM_GA_param_defs[ii].w_type == P_STRING)
    {
      if (*OM_GA_param_defs[ii].p_variable)
      {
         PMSPRNT (("%s\n",
            (char *) *((char **) OM_GA_param_defs[ii].p_variable)));
      }
      else
      {
         PMSPRNT(("\n"));
      }
    }
    else
    {
      switch (OM_GA_param_defs[ii].w_type)
      {
      case P_INTEGER:
        switch (OM_GA_param_defs[ii].i_display)
        {
        case PD_DEC:
          PMSPRNT (("%10d MinVal: %10d MaxVal: %10d\n", 
            *((int*)OM_GA_param_defs[ii].p_variable), 
            (int)OM_GA_param_defs[ii].i_minval, 
            (int)OM_GA_param_defs[ii].i_maxval));
          break;
        case PD_BOOL:
          PMSPRNT (("%10s\n", 
            *((int*)OM_GA_param_defs[ii].p_variable) ? "[TRUE]":"[FALSE]"));
          break;
        case PD_PERCENT:
          PMSPRNT (("%9d%% MinVal: %9d%% MaxVal: %9d%%\n", 
            *((int*)OM_GA_param_defs[ii].p_variable), 
            (int)OM_GA_param_defs[ii].i_minval, 
            (int)OM_GA_param_defs[ii].i_maxval));
          break;
        }
        break;
      case P_UINT:
        switch (OM_GA_param_defs[ii].i_display)
        {
        case PD_DEC:
          PMSPRNT (("%10d MinVal: %10d MaxVal: %10d\n", 
            *(OM_GA_param_defs[ii].p_variable), 
            OM_GA_param_defs[ii].i_minval, 
            OM_GA_param_defs[ii].i_maxval));
          break;
        case PD_BOOL:
          PMSPRNT (("%10s\n", 
            *(OM_GA_param_defs[ii].p_variable) ? "[TRUE]":"[FALSE]"));
          break;
        case PD_HEX:
          PMSPRNT (("%#10x MinVal: %#10x MaxVal: %#10x\n", 
            *(OM_GA_param_defs[ii].p_variable), 
            OM_GA_param_defs[ii].i_minval, 
            OM_GA_param_defs[ii].i_maxval));
          break;
        case PD_PERCENT:
          PMSPRNT (("%9d%% MinVal: %9d%% MaxVal: %9d%%\n", 
            *(OM_GA_param_defs[ii].p_variable), 
            OM_GA_param_defs[ii].i_minval, 
            OM_GA_param_defs[ii].i_maxval));
          break;
        }
        break;
      case P_WORD:
        switch (OM_GA_param_defs[ii].i_display)
        {
        case PD_DEC:
          PMSPRNT (("%10d MinVal: %10d MaxVal: %10d\n", 
            *((OMword*)OM_GA_param_defs[ii].p_variable), 
            (OMword)OM_GA_param_defs[ii].i_minval, 
            (OMword)OM_GA_param_defs[ii].i_maxval));
          break;
        case PD_PERCENT:
          PMSPRNT (("%9d%% MinVal: %9d%% MaxVal: %9d%%\n", 
            *((OMword*)OM_GA_param_defs[ii].p_variable), 
            (OMword)OM_GA_param_defs[ii].i_minval, 
            (OMword)OM_GA_param_defs[ii].i_maxval));
          break;
        }
        break;
      case P_UWORD:
        switch (OM_GA_param_defs[ii].i_display)
        {
        case PD_DEC:
          PMSPRNT (("%10d MinVal: %10d MaxVal: %10d\n", 
            *((OMuword*)OM_GA_param_defs[ii].p_variable), 
            (OMuword)OM_GA_param_defs[ii].i_minval, 
            (OMuword)OM_GA_param_defs[ii].i_maxval));
          break;
        case PD_HEX:
          PMSPRNT (("%#10x MinVal: %#10x MaxVal: %#10x\n", 
            *((OMuword*)OM_GA_param_defs[ii].p_variable), 
            (OMuword)OM_GA_param_defs[ii].i_minval, 
            (OMuword)OM_GA_param_defs[ii].i_maxval));
          break;
        }
        break;
      case P_CHAR:
        PMSPRNT (("%10c MinVal: %10c MaxVal: %10c (CHAR)\n", 
          *((char*)OM_GA_param_defs[ii].p_variable), 
          (char)OM_GA_param_defs[ii].i_minval, 
          (char)OM_GA_param_defs[ii].i_maxval));
          break;
      }
    }
  }
  OMPMS_pgHdr[0] = 0;
  return (1);
}

/*
    Description:

    shows global data defined in Specification file
*/

int  OMpms_show_globals()
{
  char       cmd[132];

  PMSPRNT( ("\n\n"));
  PMSPRNT( ("OM Global Variables:\n"));
  PMSPRNT( ("-------------------\n"));
  PMSPRNT(("OM version (major/minor):                              %8d.%1d\n", 
                OM_Gw_major_version, OM_Gw_minor_version));
  PMSPRNT(("Last known version of opp:                             %8d.%1d\n", 
                OM_Gw_min_opp_major_version, OM_Gw_last_opp_minor_version));
  PMSPRNT(("OM_Gf_tagging_enabled:                                 %10d\n", 
                OM_Gf_tagging_enabled));
 
  PMSPRNT(("Number of classes <OM_Gw_numclasses>:                  %10d\n", 
    OM_Gw_numclasses));
  PMSPRNT(("Number reported by opl <OM_Gi_number_of_defns>:        %10d\n", 
    OM_Gi_number_of_defns));
  PMSPRNT(("Next class index <OM_Gw_next_class_index>:             %10d\n", 
    OM_Gw_next_class_index));
  PMSPRNT(("Current OS <OM_Gw_current_OS, OM_Gp_CurOSD->name>:     %10d (%s)\n", 
    OM_Gw_current_OS, OM_Gp_CurOSD->name));
  PMSPRNT(("Current OS object id <OM_GO_current_OS_objid>:         %10d\n",
    OM_GO_current_OS_objid));
  PMSPRNT(("Current Master OS object id <OM_GO_current_MOSD>:      %10d\n",
    OM_GO_current_MOSD));
  PMSPRNT(("Transient OS object id <OM_GO_TransOS_0>:              %10d\n",
    OM_GO_TransOS_0));
  PMSPRNT(("Transient OS number <OM_Gw_TransOSnum_0>:              %10d\n",
    OM_Gw_TransOSnum_0));
  PMSPRNT(("Object space limit <OM_Gw_maxOS>:                      %10d\n",
    OM_Gw_maxOS));
  PMSPRNT(("Process object space limit <OM_Gw_maxOS>:              %10d\n",
    OM_Gw_maxOS));
  PMSPRNT(("Active read-only OS count <OM_Gw_RO_OS_count>:         %10d\n",
    OM_Gw_RO_OS_count));
  PMSPRNT(("Next available OS number <OM_Gw_first_OS_avail>:       %10d\n",
    OM_Gw_first_OS_avail));
  PMSPRNT(("Max number of modules <OM_Gw_max_modules>:             %10d\n",
    OM_Gw_max_modules));
  PMSPRNT(("Max number of reference files <OM_Gw_max_ref_files>:   %10d\n",
    OM_Gw_max_ref_files));
  PMSPRNT(("Total object memory <OM_Gi_totalObjMem>:               %10d\n", 
    OM_Gi_totalObjMem));

  PMSPRNT(("System page size:                                      %10d\n", 
    OM_Gp_SYSINFO->pageSize));
  PMSPRNT(("Physical cluster size:                                 %10d\n", 
    OM_Gi_phyClusterSize));
  PMSPRNT(("Known classes allowed <OM_Gw_known_class_max>:         %10d\n",
    OM_Gw_known_class_max));

  PMSPRNT(("Duplicate channel entry flag <OM_Gf_check_chan_dups>:  %10d\n",
    OM_Gf_check_chan_dups));
  PMSPRNT(("R-tree history flag <OM_Gi_record_ops>:                %10d\n",
    OM_Gi_record_ops));
  PMSPRNT(("R-tree history operations count <OM_Gi_ops_count>:     %10d\n",
    OM_Gi_ops_count));
  PMSPRNT(("R-tree history head operations <OM_Gi_ops_head>:       %10d\n",
    OM_Gi_ops_head));
  PMSPRNT(("R-tree history tail operations <OM_Gi_ops_tail>:       %10d\n",
    OM_Gi_ops_tail));
  PMSPRNT(("Tag hash table size <OM_Gw_tag_hashtable_size>:        %10d\n",
    OM_Gw_tag_hashtable_size)); 
  PMSPRNT(("Tag hash table extent <OM_Gi_percent_extend_tag>:      %10d\n",
    OM_Gi_percent_extend_tag)); 
  PMSPRNT(("Reinstate tagcon slots <OM_Gi_tagcon_slot>:            %10d\n",
    OM_Gi_tagcon_slot));

  PMSPRNT( ("\n\n"));
  PMSPRNT( ("OM Global Pointers:\n"));
  PMSPRNT( ("------------------\n"));

  PMSPRNT(("OSD list <OM_GA_OSDs>:                                 0x%8x\n",
    OM_GA_OSDs));
  PMSPRNT(("Current spacemap <OM_Gp_CurSpaceMap>:                  0x%8x\n",
    OM_Gp_CurSpaceMap));
  PMSPRNT(("Filed-to-active classid map <OM_GA_filed_to_active>:   0x%8x\n",
    OM_GA_filed_to_active));
  PMSPRNT(("Active-to-filed classid map <OM_GA_active_to_filed>:   0x%8x\n",
    OM_GA_active_to_filed));
  PMSPRNT(("Active classids <OM_GA_active_classes>:                0x%8x\n",
    OM_GA_active_classes));
  PMSPRNT(("Known classids <OM_GA_known_classes>:                  0x%8x\n",
    OM_GA_known_classes));
  PMSPRNT(("Max sizes of active classid maps <OM_GA_fa_mapsize>:   0x%8x\n",
    OM_GA_fa_mapsize));
  PMSPRNT(("Tag oids per OS <OM_GA_tag_oids>:                      0x%8x\n",
    OM_GA_tag_oids));
  PMSPRNT(("CSD array <OM_GA_CSDarray>:                            0x%8x\n",
    OM_GA_CSDarray));
  PMSPRNT(("Available regular CSDs queue <OM_GQ_regCSDavail>:      0x%8x\n",
    OM_GQ_regCSDavail));
  PMSPRNT(("Available big object CSDs queue <OM_GQ_bigCSDavail>:   0x%8x\n",
    OM_GQ_bigCSDavail));
  PMSPRNT(("Available PCDs queue <OM_GQ_PCDavail>:                 0x%8x\n",
    OM_GQ_PCDavail));

  PMSPRNT(("Original OS name <OM_Gp_orig_osname>:                  0x%8x\n",
    OM_Gp_orig_osname));

  if (!OMpms_showSysgen ()) return (0);

  printf ("\nShow a queue ? (y/n) ");
  ECHO_TO_LOG ("%s", "\nShow a queue ? (y/n) ");
  while (isspace (cmd[0] = getchar()) || (IFDELETE(cmd[0])));
  OMPMS_pgCnt = 0;
  ECHO_TO_LOG("%c\n",cmd[0]);
  if (cmd[0] == 'y' || cmd[0] == 'Y')
  {
    while(1)
    {
      OMuword	        OSnum;
      OM_p_OSD	        p_OSD;

      OMPMS_pgCnt = 0;
      PMSPRNT( ("\nq: quit"));
      PMSPRNT( ("\nR: show OM_GQ_regCSDavail"));
      PMSPRNT( ("\nB: show OM_GQ_bigCSDavail"));
      PMSPRNT( ("\nP: show OM_GQ_PCDavail"));
      PMSPRNT( ("\nF: show OM Object Spaces' Last Cluster Faulted\n? "));
      OMPMS_pgSearching = OMPMS_pgCnt = 0;
      while (isspace (cmd[0] = getchar()) || (IFDELETE(cmd[0])));
      ECHO_TO_LOG("%c\n",cmd[0]);
      switch (cmd[0]) 
      {
        case 'q':
        case 'Q':
          return (1);
        case 'R': 
        case 'r': 
          if (!OMpms_show_queue("Regular CSD Avail Queue", 
	                      &OM_GQ_regCSDavail)) return(0);
          break;
        case 'B':
        case 'b':
          if (!OMpms_show_queue("BIG CSD Avail Queue", 
	                      &OM_GQ_bigCSDavail)) return(0);
          break;
        case 'P': 
        case 'p': 
          if (!OMpms_show_queue("PCD Avail Queue", 
	                      &OM_GQ_PCDavail)) return(0);
          break;
        case 'F': 
        case 'f': 
          if (OMpms_get_OS(&OSnum))
          {
            p_OSD = OM_GA_OSDs[OSnum];
            PMSPRNT(("\nOS: %32s  OS number: %17d", p_OSD->name, p_OSD->OSnum));
            if (p_OSD->lcfq_lh.next)
            {
              if (!OMpms_show_queue("Last Cluster Faulted Queue", 
                                (OM_p_DLINK) &(p_OSD->lcfq_lh.next))) return(0);
            }
            else
            {
              PMSPRNT
  (("\nOS last cluster faulted queue has zero pointer for next *CORRUPT*"));
            }
          } /* if */
      } /* switch */
    } /* while */
  } /* if show a queue */
  return(1);
} /* routine OMpms_show_globals */

/*
    Description:
	gets object id

    Return value:
        TRUE  indicates normal exit
        FALSE indicates intention to quit
*/

bool OMpms_get_oid(oid_p)
	OM_p_OBJID oid_p;
{
	char       cmd[132];

   OMPMS_pgSearching = OMPMS_pgCnt = 0;
   printf ("\noid: [q to quit] ");
   ECHO_TO_LOG ("%s", "oid: [q to quit] ");
#ifndef NT
   ioctl (terminal, TCSETA, &original);
   scanf("%s",cmd);
   OMPMS_pgCnt = 0;
   ioctl (terminal, TCSETA, &termset);
#else
   scanf("%s",cmd);
   OMPMS_pgCnt = 0;
#endif
   getchar();
   ECHO_TO_LOG("%s\n",cmd);
   while (cmd[0]!='q' && !isdigit(cmd[0]) ) 
   {
     printf("oid: (a NUMBER please!) ");
     ECHO_TO_LOG ("%s", "oid: (a NUMBER please!) ");
#ifndef NT
     ioctl (terminal, TCSETA, &original);
     scanf("%s",cmd);
     OMPMS_pgCnt = 0;
     ioctl (terminal, TCSETA, &termset);
#else
     scanf("%s",cmd);
     OMPMS_pgCnt = 0;
#endif
     getchar();
     ECHO_TO_LOG("%s\n",cmd);
   }

   if (cmd[0]== 'q') return(FALSE);
   else {
     *oid_p = atoi(cmd);
     return(TRUE);
   }
} /* OMpms_get_oid() ============================================ */

/*
    Description:
	gets class_id and does eligible check

    Return value:
	TRUE	indicates normal exit
        FALSE   indicates the intention to quit
*/

bool OMpms_get_class(classid_p)
uword      *classid_p;
{
  short      tf;
  char       classname[132], cmd[4];
  int        input_classid;
  int        sts;

  OMPMS_pgSearching = OMPMS_pgCnt = 0;
  for (tf=FALSE; tf==FALSE;)
  {
    printf ("\nClass name or id: ");
    ECHO_TO_LOG ("%s", "Class name or id: ");
#ifndef NT
    ioctl (terminal, TCSETA, &original);
    scanf ("%s", classname);
    OMPMS_pgCnt = 0;
    ioctl (terminal, TCSETA, &termset);
#else
    scanf ("%s", classname);
    OMPMS_pgCnt = 0;
#endif
    getchar();
    ECHO_TO_LOG("%s\n",classname);
    if (isdigit(classname[0])) 
    {
      *classid_p = input_classid = atoi (classname);
      if (!(1&(sts = om$get_classname 
           (classname = classname, classid = *classid_p)))) 
      {
        PMSPRNT( ("\nInvalid classid %d\n", *classid_p));
        om$report_error (sts=sts);
        OMPMS_pgCnt += 2;
      } 
      else tf=TRUE;
    } 
    else 
    {
      if (!(1&(sts = om$get_classid
           (classname = classname, p_classid = classid_p))))
      {
        PMSPRNT( ("\ninvalid classname\n"));
        om$report_error (sts=sts);
        OMPMS_pgCnt += 2;
      } 
      else tf=TRUE;
    }
    if (!tf)
    {
      printf("  [quit] y/n ? ");
      ECHO_TO_LOG ("%s", "  [quit] y/n ? ");
      while (isspace (cmd[0] = getchar()) || (IFDELETE(cmd[0])));
      OMPMS_pgCnt = 0;
      ECHO_TO_LOG("%c\n",cmd[0]);
      if (cmd[0]=='y') return(FALSE);
    }
  }/* for tf */
  return(TRUE);

} /* OMpms_get_class() ============================================ */


int OMpms_show_an_ISO (OSnum, t_OSnum)
	OMuword		OSnum, t_OSnum;
{
  int		sts;
  OM_S_OBJID	iso_oid;

  extern	int	som_ISO_print();
  OM_S_MESSAGE find_iso_msg;
  struct OM_sd_find_iso_args
  {
     OMuword t_osn;
     OM_p_OBJID p_oid;
  } find_iso_args;

  find_iso_args.t_osn = t_OSnum;
  find_iso_args.p_oid = &iso_oid;
  find_iso_msg.size = sizeof(struct OM_sd_find_iso_args);
  find_iso_msg.p_arglist = (char *) &find_iso_args;
  find_iso_msg.select.FuncIndex = OMObjSpace_OPP_find_iso_method_index;
  find_iso_msg.select.DefClassid = OM_K_OMOBJSPACE_ACTCLASSID;
  find_iso_msg.select.ReqClassid = OM_K_OMOBJSPACE_ACTCLASSID;

  sts = om$send(msg = &find_iso_msg, 
		senderid = NULL_OBJID,
		targetid = OM_GA_OSDs[OSnum]->OSO_Oid, targetos = OSnum);
  if (!(1&sts))
  {
    om$report_error(sts=sts);
    OMPMS_pgCnt += 2;
  }
  som_ISO_print(OSnum, iso_oid);
  return(1);
} /* ==================================== OMpms_show_an_ISO ===== */

int OMpms_show_all_ISO (OSnum)
	OMuword		OSnum;
{
	int	sts;
	int	flag=0;
         OM_S_MESSAGE print_isodir_msg;
         struct OM_sd_print_isodir_args
         {
            int flg;
         } print_isodir_args;

  print_isodir_args.flg = flag;
  print_isodir_msg.size = sizeof(struct OM_sd_print_isodir_args);
  print_isodir_msg.p_arglist = (char *) &print_isodir_args;
  print_isodir_msg.select.FuncIndex=OMObjSpace_OPP_print_isodir_method_index;
  print_isodir_msg.select.DefClassid=OM_K_OMOBJSPACE_ACTCLASSID;
  print_isodir_msg.select.ReqClassid=OM_K_OMOBJSPACE_ACTCLASSID;

  if (OMPMS_Gf_brief)
    flag = 0;
  else 
    flag = 1;

  sts = om$send(msg = &print_isodir_msg, 
	senderid = NULL_OBJID, 
	targetid = OM_GA_OSDs[OSnum]->OSO_Oid, targetos=OSnum);

  if (!(1&sts))
  {
    om$report_error(sts = sts);
    OMPMS_pgCnt += 2;
  }
  return(1);
} /* ==================================== OMpms_show_all_ISO ===== */
					/*+private*/
					/*+fndesc*/
int OMpms_show ()
/*
    Description:

        Shows the following options of user's choice	

        A:  show all object headers in an Object Space
        c:  show a class definition structure
        C:  show all known class definition structures
        e:  show cluster extents of an OS
        G:  show OM globals
        i:  show individual object (header + channels)
        ic: show individual object header + specified channel
	l:  show specified ISO linkage
	L:  show all ISOs in an Object Space
        m:  show memory use of an object space
        o:  show an Object Space descriptor
        O:  show all Object Space descriptors
        p:  recursively invoke PMS
        q:  back to PMS primary command level
        S:  OMPMS state
 
*/
					/*-fndesc*/
					/*-private*/
{
  uword		OSnum;
  uword		t_OSnum;	/* target OS number VL 11/24/86 */
  uword		classid;
  char		cmd[132];
  OM_S_OBJID	oid;
  int       	OM_PMS ();
  p_CHAN_NAME	p_chanlist;

  while (TRUE) {
    OMPMS_pgCnt = 0;
    OMPMS_pgSearching = FALSE;
    OMPMS_pgHdr[0] = 0;
    printf ("\nShow what ? ");
    ECHO_TO_LOG ("%s", "\nShow what ? ");
    while (isspace (cmd[0] = getchar()) || (IFDELETE(cmd[0])));
    ECHO_TO_LOG("%c\n",cmd[0]);
    if (cmd[0] == 'i')
    {
      cmd[1] = getchar ();
      if (cmd[1] == 'c')
      {
        PMSPRNT (("\n"));
        if (OMpms_get_OS (&OSnum)) 
        {
          if (OMpms_get_oid(&oid)) 
          {
            if ( OMpms_get_channel(&p_chanlist) ) 
            {
              if (!OMpms_show_object (OSnum, oid, p_chanlist)) break;
            }
          }
        }
        continue;
      }
    }
    switch (cmd[0]) 
    {
      case '?':
        PMSPRNT( ("\nShow options are:"));
        PMSPRNT( ("\nA: Show all object headers in an Object Space"));
        PMSPRNT( ("\nc: show a class definition structure"));
        PMSPRNT( ("\nC: show all known class definition structures"));
        PMSPRNT( ("\ne: show cluster extents of an OS"));
        PMSPRNT( ("\nG: show OM globals"));
        PMSPRNT( ("\ni: show individual object (header + channels)"));
        PMSPRNT( ("\nic: show individual object header + specified channel"));
 	PMSPRNT( ("\nl: show specified ISO linkage "));
	PMSPRNT( ("\nL: show all ISO linkages in an Object Space "));
        PMSPRNT( ("\nm: show memory use of an Object Space "));
        PMSPRNT( ("\no: show an Object Space descriptor"));
        PMSPRNT( ("\nO: show all Object Space descriptors"));
        PMSPRNT( ("\np: recursively invoke PMS"));
        PMSPRNT( ("\nq: back to PMS primary command level"));
        PMSPRNT( ("\nS: OMPMS state"));
        PMSPRNT( ("\nv: list application version stamps"));
        break;
      case 'A':
        if (OMpms_get_OS(&OSnum)) OMpms_show_spacemap(OSnum);
        break;
      case 'c':
        if (OMpms_get_class(&classid) == TRUE) OMpms_show_class (classid);
        break;
      case 'C':
        OMpms_show_all_classes();
        break;
      case 'e':
        if (OMpms_get_OS(&OSnum)) OMpms_show_cluster_extents(OSnum);
        break;
      case 'G':
        OMpms_show_globals();
        break;
      case 'i':
        if (OMpms_get_OS (&OSnum)) 
        {
         while (TRUE)    
         {
          if (OMpms_get_oid(&oid)==FALSE) break;
          OMpms_show_object (OSnum, oid, (p_CHAN_NAME) NULL);
         }
        }
        break;
      case 'l':		/* 11/24/86 VL */
	PMSPRNT(("\n Target "));
        if (OMpms_get_OS(&t_OSnum)) 
        {
	  PMSPRNT(("\n From "));
	  if (OMpms_get_OS(&OSnum)) OMpms_show_an_ISO (OSnum,t_OSnum);
        }
        break;
      case 'L':		/* 11/24/86 VL */
        if (OMpms_get_OS(&OSnum)) OMpms_show_all_ISO (OSnum);
        break;
      case 'm':
        if (OMpms_get_OS(&OSnum)) OMpms_show_OS_mem(OSnum);
        break;
      case 'o':
        if (OMpms_get_OS(&OSnum)) OMpms_show_an_OS (OSnum,1);
        break;
      case 'O':
        OMpms_show_all_OS ();
        break;
      case 'p':
        OM_PMS();
        break;
      case 'q':
        return(1);
      case 'v':
        OMpms_show_version_stamps();
        break;
      case 'S':
        PMSPRNT( ("\n"));
        PMSPRNT( ("PMS state:\n  Verbose:     "));
        if (OMPMS_Gf_brief == TRUE)   
        {
          PMSPRNT( ("OFF\n"));
        }   
        else   
        {
          PMSPRNT( ("ON\n"));
        }
        PMSPRNT(             ("  Pause:       "));
        if (OMPMS_Gf_pause == TRUE)  
        {
          PMSPRNT( ("ON\n"));
        }   
        else   
        {
          PMSPRNT( ("OFF\n"));
        }
        PMSPRNT(             ("  Current OS:  "));
        if (strlen (OMPMS_current_OS_name) == 0)
        {
          PMSPRNT( ("(No current OS defined.)\n"));
        }  
        else  
        {
          PMSPRNT( ("%s (OSnumber: %d)\n", OMPMS_current_OS_name, 
                   OMPMS_current_OS_number));
        }
        PMSPRNT(             ("  Display:     "));
        if (OMPMS_basePgLimit)
        {
          PMSPRNT(           ("PAGINATE OUTPUT every %d lines\n", 
            OMPMS_basePgLimit));
        }
        else
        {
          PMSPRNT(           ("CONTINUOUS DISPLAY\n"));
        }
        break;
      default:
        PMSPRNT( ("\nbad option, backo"));
        break;
    } /* switch cmd[0] */
  } /* while TRUE */
  return(1);
} /* routine OMpms_show () */


int OMpms_memEdit()
{
  char              cmd;
  char              *addr=NULL;
  OMuint            Value[32];
  
 
  PMSPRNT(("\n"));
  while(TRUE)
  {
    PMSPRNT(("[e] "));
    while (isspace (cmd = getchar()) || (IFDELETE(cmd)));
    ECHO_TO_LOG("%c\n",cmd);
    switch(cmd)
    {
    case 'q':
    case 'Q':
      return(1);
    case 'e':
    case 'E':
      PMSPRNT(("\naddress: "));
      while (cmd != 'q' && cmd != 'Q')
      {
#ifndef NT
        ioctl (terminal, TCSETA, &original);
        scanf ("%x", addr);
        OMPMS_pgCnt = 0;
        ioctl (terminal, TCSETA, &termset);
#else
        scanf ("%x", addr);
        OMPMS_pgCnt = 0;
#endif
        while ((cmd = getchar()) != 'q' && cmd != 'Q')
        {
          PMSPRNT(("%08x: %08x\n", addr, *addr));
          addr += 4;
        }
      }
      break;

    case 'd':
    case 'D':
      PMSPRNT(("\naddress: "));
#ifndef NT
      ioctl (terminal, TCSETA, &original);
      scanf ("%x", addr);
      PMSPRNT(("\nvalue  : "));
      scanf ("%s", Value);
      OMPMS_pgCnt = 0;
      ioctl (terminal, TCSETA, &termset);
#else
      scanf ("%x", addr);
      PMSPRNT(("\nvalue  : "));
      OMPMS_pgCnt = 0;
#endif
      getchar();
      *((int *) addr) = atoi ((char *) &Value[0]);
      break;
      
    case '?':
    case 'h':
    case 'H':
    default:
      PMSPRNT(("\nd[eposit] mode\ne[xamine] mode\nq[uit] editor\n"));
      break;
    }
  }
}
							/*+public*/
							/*+fndesc*/
int OM_PMS()
/*

    Description:

    The purpose of this function is to check Performance and
    Monitoring OM system.  It will take over control to do
    commands according to user's choice.  It will prompt
    one of the following menus whenever user input a "?".

        Commands are:
        b: convenient break point
        B: send a Debug
        f: find objects of a given class
        o: output PMS output to a file
        s: show (show has cmd prompt, also)
        S: set state (either in OS or PMS)
        W: write a filed OS
        q: quit 

        [NOTE] classes and OS may be specified either by name or number
               channel may be specified either by 
                   a classname, followed by a period, 
                                followed by the name of the channel
               or
                   a  class_id, followed by a period,
                                followed by the number of the channel


        Show options are:
        A:  show all object headers in an Object Space
        c:  show a class definition structure
        C:  show all known class definition structures
        e:  show cluster extents of an OS
        G:  show OM globals
        i:  show individual object (header + channels)
        ic: show individual object header + specified channel
        m:  show the memory usage of an object space
        o:  show an Object Space descriptor
        O:  show all Object Space descriptors
        p:  recursively invoke PMS
        q:  a back to PMS primary command level
        S:  OMPMS state
        v:  list application version stamps 


        Set State - 
          B: brief reporting         b: verbose reporting
          P: pause between shows     p: no pause
          W: make OS writeable       w: no write on an OS


        Pause Responses:
          p: invoke PMS again
          s: show menu 
          q: quit current loop
          anything else, continue

*/
							/*-fndesc*/
							/*-public*/
{
  uword             OSnum;
  int               sts;
  char              cmd[132], show_cmd[132], response[10], OSname[132];
  OM_S_OBJID        oid;
  OM_S_MESSAGE      delete_msg;
  struct OM_sd_delete_args
  {
     int f_defer_flag;
  } delete_args;
  OM_S_MESSAGE      set_state_msg;
  struct OM_sd_set_state_args
  {
    int state_flag;
  } set_state_args;
#ifndef NT
  char              *tty;
  int               sav_lflag;
#endif

  set_state_msg.size = sizeof(struct OM_sd_set_state_args);
  set_state_msg.p_arglist = (char *) &set_state_args;
  set_state_msg.select.FuncIndex=OMFiledOS_OPP_set_state_method_index;
  set_state_msg.select.DefClassid=OM_K_OMFILEDOS_ACTCLASSID;
  set_state_msg.select.ReqClassid=OM_K_OMFILEDOS_ACTCLASSID;

  delete_msg.size = sizeof(struct OM_sd_delete_args);
  delete_msg.p_arglist = (char *) &delete_args;
  delete_msg.select.FuncIndex=Root_OPP_delete_method_index;
  delete_msg.select.DefClassid=OM_K_ROOT_ACTCLASSID;
  delete_msg.select.ReqClassid=OM_K_ROOT_ACTCLASSID;


  PMSPRNT( ("\n\nOM PMS [2.0] Environment, OM [v%d.%d]\n\n", 
    OM_Gw_major_version, 
    OM_Gw_minor_version));

  /* initialize terminal ioctl settings for input mode */

#ifndef NT

  tty = (char *) ttyname (0);
  terminal = open (tty, O_RDWR);
  ioctl (terminal, TCGETA, &original);
  ioctl (terminal, TCGETA, &termset);
  sav_lflag = original.c_lflag;
  original.c_lflag |= ICANON;
  termset.c_lflag   &= ~ICANON;
  termset.c_cc[VMIN]  = (char)1;
  termset.c_cc[VTIME] = (char)1;  
  ioctl (terminal, TCSETA, &termset);
#endif
  while (TRUE)  {
    OMPMS_pgCnt = 0;
    OMPMS_pgSearching = FALSE;
    OMPMS_pgHdr[0] = 0;
    printf ("\n[PMS] ");
    ECHO_TO_LOG ("%s", "\n[PMS] ");
    while (isspace (cmd[0] = getchar()) || (IFDELETE(cmd[0])));
    ECHO_TO_LOG("%c\n",cmd[0]);
 
    switch (cmd[0]) 
    {
    case '?':
      PMSPRNT( ("\nCommands are:"));

      PMSPRNT( ("\nb: convenient break point"));
      PMSPRNT( ("\nB: send a Debug"));
      PMSPRNT( ("\nd: delete object"));
      PMSPRNT( ("\nD: delete an OS"));
      PMSPRNT( ("\nf: find objects of a given class"));
      PMSPRNT( ("\nm: Memory Editor"));
      PMSPRNT( ("\no: send PMS output to a file"));
      PMSPRNT( ("\ns: show (show has cmd prompt, also)"));
      PMSPRNT( ("\nS: set state (either in OS or PMS)"));
      PMSPRNT( ("\nW: write a filed OS"));
      PMSPRNT( ("\nq: quit "));

PMSPRNT(("\n   [NOTE]classes and OS may be specified either by name or number"));
PMSPRNT(("\n         channel may be specified either by "));
PMSPRNT(("\n         (1)a classname, followed by a period, "));
PMSPRNT(("\n                         followed by the name of the channel; or"));
PMSPRNT(("\n         (2)an active_class_id, followed by a period,"));
PMSPRNT(("\n                         followed by the number of the channel"));

      break;

    case 'b':
      OMpms_break ();
      break;
    case 'B':
      if ( OMpms_get_OS(&OSnum) ) {
       while (TRUE) {
        OM_S_MESSAGE debug_msg;
        if (OMpms_get_oid(&oid)==FALSE) break;
        debug_msg.size = 0;
        debug_msg.p_arglist = 0;
        debug_msg.select.FuncIndex=Root_OPP_debug_method_index;
        debug_msg.select.DefClassid=OM_K_ROOT_ACTCLASSID;
        debug_msg.select.ReqClassid=OM_K_ROOT_ACTCLASSID;
        sts = om$send(msg=&debug_msg,
                      senderid=NULL_OBJID,
                      targetid=oid, targetos=OSnum);
        if (!(1&sts))
        {
          om$report_error (sts=sts);
          OMPMS_pgCnt += 2;
        }
       } /* while */
      } /* if given OS */
      break;
    case 'd':
      if (OMpms_get_OS (&OSnum)) 
      {
       while (TRUE)      
       {
        if (OMpms_get_oid(&oid)==FALSE) break;
        sts = om$send (msg=&delete_msg, 
                       senderid=NULL_OBJID,
		       targetid=oid, targetos=OSnum);
        if (!(1&sts))
        {
          om$report_error (sts=sts);
          OMPMS_pgCnt += 2;
        }
       } /* while */
      } /* if given OS */
      break;
    case 'D':
      if (OMpms_get_OS (&OSnum)) 
      {
       sts = om$send (msg=&delete_msg, 
            senderid=NULL_OBJID,
            targetid=OM_GA_OSDs[OSnum]->OSO_Oid,
            targetos=OSnum);
       if (!(1&sts))
       {
        om$report_error (sts=sts);
        OMPMS_pgCnt += 2;
       }
      }
      break;
    case 'f':
      if ( OMpms_get_OS(&OSnum)) OMpms_find_objects(OSnum);
      break;
    case 'm':
      OMpms_memEdit();
      break;
    case 'o':
      OMpms_outputfile();
      break;
    case 's':
      OMpms_show ();
      break;
    case 'S':
PMSstate_prompt:
      OMPMS_pgCnt = OMPMS_pgSearching = 0;
      printf ("\n  [state] ");
      ECHO_TO_LOG ("%s", "\n  [state] ");
      while (isspace(show_cmd[0] = getchar()) || (IFDELETE(show_cmd[0])));
      ECHO_TO_LOG("%c\n",show_cmd[0]);
      switch (show_cmd[0]) 
      {
        case '?':
          PMSPRNT( ("\n  Set State - "));
          PMSPRNT( ("\n    B: brief reporting              b: verbose reporting"));
          PMSPRNT( ("\n    P: pause between shows          p: no pause"));
          PMSPRNT( ("\n    W: make OS writeable            w: no write on an OS"));
          PMSPRNT( ("\n    D=cnt: discontinous display     d: continuous display"));
	  goto PMSstate_prompt;
	case 'D':
	  {
	    char      *pEq = NULL;
	  
#ifndef NT
            ioctl (terminal, TCSETA, &original);
            scanf ("%s", show_cmd);
            ioctl (terminal, TCSETA, &termset);
#else
            scanf ("%s", show_cmd);
#endif
            if (pEq = (char *) strchr (show_cmd, '='))
              OMPMS_basePgLimit = atoi (++pEq);
            else 
              OMPMS_basePgLimit = PGLIMIT;
          }
          break;

	case 'd':
	  OMPMS_basePgLimit = 0;
	  break;

        case 'B':
          OMPMS_Gf_brief = TRUE;
          break;
        case 'b':
          OMPMS_Gf_brief = FALSE;
          break;
        case 'P':
          OMPMS_Gf_pause = TRUE;
          break;
        case 'p':
          OMPMS_Gf_pause = FALSE;
          break;
        case 'q':
          break;
        case 'w':
          if ( OMpms_get_OS (&OSnum)) 
          {
            set_state_args.state_flag = 0 ;
            sts = om$send (msg= &set_state_msg, 
                        senderid=NULL_OBJID,
                        targetid=OM_GA_OSDs[OSnum]->OSO_Oid,
                        targetos=OSnum);
            if (!(sts&1))
            {
              om$report_error (sts=sts);
              OMPMS_pgCnt += 2;
            }
          }
          break;
        case 'W':
          if (OMpms_get_OS (&OSnum)) 
          {
            set_state_args.state_flag = 1;
            sts = om$send (msg= &set_state_msg, 
                      senderid=NULL_OBJID,
                      targetid=OM_GA_OSDs[OSnum]->OSO_Oid,
                      targetos=OSnum);
            om$report_error (sts=sts);
            OMPMS_pgCnt += 2;
          }
          break;
        default:
          PMSPRNT( ("\ninvalid option"));
          break;
        }
        break; /* case 'S' */
    case 'W':
      if (FALSE == OMpms_get_OS (&OSnum)) break;
      if (OM_GA_OSDs[OSnum]->type != OM_OSD_filed) 
      {
        OMPMS_pgCnt = OMPMS_pgSearching = 0;
        printf ("\nWarning: OS #%d (%s) is not a filed OS. Continue? ", OSnum);
        ECHO_TO_LOG ("\nWarning: OS #%d (%s) is not a filed OS. Continue? ", OSnum);
	while (isspace(response[0] = getchar()) || (IFDELETE(response[0])));
        ECHO_TO_LOG("%c\n",response[0]);
	if (response[0] != 'y')	break;
      }
      OMPMS_pgCnt = OMPMS_pgSearching = 0;
      printf ("\nDifferent file name? (! for no): ");
      ECHO_TO_LOG ("%s", "Different file name? (! for no): ");
#ifndef NT
      ioctl (terminal, TCSETA, &original);
      scanf ("%s", OSname);
      ioctl (terminal, TCSETA, &termset);
#else
      scanf ("%s", OSname);
#endif
      getchar();
      ECHO_TO_LOG("%s\n",OSname);
      if (!strcmp ("!", OSname))      {
        strcpy (OSname, "");
      }
      {
        OM_S_MESSAGE write_msg;
        struct OM_sd_write_args
        {
          char *osname;
        } write_args;

        write_args.osname = OSname ;
        write_msg.size = sizeof(struct OM_sd_write_args);
        write_msg.p_arglist = (char *) &write_args;
        write_msg.select.FuncIndex=OMFiledOS_OPP_write_method_index;
        write_msg.select.DefClassid=OM_K_OMFILEDOS_ACTCLASSID;
        write_msg.select.ReqClassid=OM_K_OMFILEDOS_ACTCLASSID;
        sts = om$send (msg=&write_msg, 
                       senderid=NULL_OBJID,
     		       targetid=OM_GA_OSDs[OSnum]->OSO_Oid,
                       targetos=OSnum);
        if (!(1&sts))
        {
          om$report_error (sts=sts);
          OMPMS_pgCnt += 2;
        }
      }
      break; /* case 'W' */
    case 'q':
      if (OMPMS_logfile)
      {
         fclose(OMPMS_logfile);
         OMPMS_logfile = NULL;
         OMPMS_logname[0] = '\0';
      }
      PMSPRNT(("\nByeBye...\n"));
#ifndef NT
      original.c_lflag = sav_lflag;
      ioctl (terminal, TCSETA, &original);
#endif
      return(0);
    default:
      PMSPRNT(("\nBad input, try again!"));
      break;
    } /* switch cmd[0] */
  } /* while (TRUE) */
} /* OM_PMS() */

int OMpms_prnt(char *format, ...)
{
  va_list args;

#if 0
  char    pgOpt, prBuf[1000];
#endif 

  va_start(args, format);

    vprintf(format, args);
    if (OMPMS_logfile) vfprintf(OMPMS_logfile,format,args);
#if 0
  if (OMPMS_pgLimit)
  {
    vsprintf (prBuf, format, args);
    format = prBuf;
    if (OMPMS_pgSearching && !(format = OMpms_searchStr (format))) return (1);
    while (*format)
    {
      if ((*format == '\n') && (OMPMS_pgCnt++ > OMPMS_pgLimit))
      {
        OMPMS_pgCnt = 0;
        printf ("\n[more?]");
        pgOpt = getchar();
        if (OMPMS_logfile)
        {
          fprintf (OMPMS_logfile, "\n[more?]");
          fprintf (OMPMS_logfile, "%c", pgOpt);
        }
        if (pgOpt == 'q' || pgOpt == 'Q')
        {
          OMPMS_pgCnt = OMPMS_pgHdr[0] = NULL;
          OMPMS_pgSearching = FALSE;
          return (0);
        }
        if (pgOpt == '/')
        {
          pgOpt = getchar();
          if (pgOpt == '\n')
          {
            if (OMPMS_pgSeaStrLen)
            {
              OMPMS_pgSearching = TRUE;
              if (!(format = OMpms_searchStr (format++))) return (1);
            }
            if (OMPMS_pgHdr[0])
            {
              printf ("%s", OMPMS_pgHdr);
            }
            format++;
            continue;
          }
          OMPMS_pgSeaStr[0] = pgOpt;
#ifndef NT
          ioctl (terminal, TCSETA, &original);
          scanf("%s", &OMPMS_pgSeaStr[1]);
          OMPMS_pgCnt = 0;
          ioctl (terminal, TCSETA, &termset);
#else
          scanf("%s", &OMPMS_pgSeaStr[1]);
          OMPMS_pgCnt = 0;
#endif
          getchar();
          if (OMPMS_pgSeaStr[strlen (OMPMS_pgSeaStr) - 1] == '/')
            OMPMS_pgSeaStr[strlen (OMPMS_pgSeaStr) - 1] = NULL;
          OMPMS_pgSeaStrLen = strlen (OMPMS_pgSeaStr);
          OMPMS_pgSearching = TRUE;
          if (!(format = OMpms_searchStr (format++))) return (1);
        }
        if (OMPMS_pgHdr[0])
        {
          printf ("%s", OMPMS_pgHdr);
        }
        format++;
        continue;
      }
      if (OMPMS_logfile) fprintf (OMPMS_logfile, "%c", *format);
      putchar (*format++);
    }
  }
  else 
  {
    vprintf(format, args);
    if (OMPMS_logfile) vfprintf(OMPMS_logfile,format,args);
  }
#endif
  return (1);
}



int OMpms_prntHdr(char *format, ...)
{
  va_list args;
  int     ii, numCR;
  
  va_start(args, format);
  OMPMS_pgHdr[0] = 0;	/* get rid of old header */
/*  if (!OMpms_prnt (va_alist)) return (0);*/
  if (!OMpms_prnt (format, args)) return (0);
  if (OMPMS_pgLimit)
  {
    vsprintf (OMPMS_pgHdr, format, args);
    numCR = 0;
    for (ii=0; ii<(int) strlen(OMPMS_pgHdr); ii++) 
      if (OMPMS_pgHdr[ii] == '\n') numCR++;
    if (!numCR)
    {
      strcat (OMPMS_pgHdr, "\n");
      numCR = 1;
    }
    if ((OMPMS_pgLimit = OMPMS_basePgLimit - numCR) < 1) 
      OMPMS_pgLimit = numCR + 1;
  }
  return (1);
}

