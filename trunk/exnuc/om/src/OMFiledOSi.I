/*======================================================================= 
	OMFiledOSi.I	methods used in reading and writing Object
                        Spaces
	
	6-87 jkm change cluster 0 allocation field at write time to equal
		the size field. This number is used to get memory when the
	 	OS is loaded. Now that the size field is  aligned,
		we don't need a separate number to get memory with.

	11-87 saw001
		Added changes to support autoclustering, new cluster
                data structures to construct_os.

	1-88 saw002
		Added changes to OMFiledOS.write for 4.5.

        5-88 saw003
                Add som_write_reclustered_os function to recluster spatial
                objects and write out object space.  Called by delete method.

        9-88 saw004
                When testing for swapped cluster in write method, cluster
                is swapped its pcd has a lump descriptor and no slot descr.

	9-90 saw005
		Add som_cmpFileTimeStamp to compare the write timestamp
		in the input file to what's in the OSO in memory to prevent
		reading from a file that has been written over since we
		last read from it.
		Change mechanism for copying the tmp file to new OS file
		in write method.

        11-90 saw006
                1.4.1.  Customers want file locking capability for disti-
                buted systems.  If flag on, we make a lockfile for every
                design file that governs who gets what access to design file.

========================================================================*/

class	implementation	OMFiledOS;

#include <errno.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#ifndef NT
#include <sys/param.h>
#else
#define MAXPATHLEN  1024
#endif
#include <assert.h>

#if defined (SYSV) || defined (BSD)
#include <unistd.h>
#elif defined (NT)
#include <stdlib.h>
#include <process.h>
#include <excpt.h>
%safe
#include <windef.h>
#include <winbase.h>
%endsafe
#else
#error OS has no file locking support !!
#endif

#include <sys/stat.h>

#ifdef SYSV
#include <sys/statfs.h>
#endif

#ifdef BSD
#include <sys/vfs.h>
#include <vfork.h>
#endif

#if defined (NT)
#include <io.h>
#include <direct.h>
%safe
#include <process.h>
%endsafe
#endif

#include "UNIXerrdef.h"
#include "OMmacros.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMtags.h"
#include "OMminimum.h"
#include "OMmetaclass.h"
#include "OMOSfilehdr.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "OMparameters.h"
#include "OMobjspace.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "version.h"

/* Define size of buffers used for storing file names.
   If Clix is ever changed to support file names longer
   than 14 characters, then the commented-out code can
   be used.
*/

#define  MAXFILENAMELEN 14

/* #ifdef CLIX
#define  MAXFILENAMELEN 14
#else
*/
/* File names may not exceed OM_K_MAXOSNAME_LEN because that
   length is the size of the file name array within OMObjSpace
   instance data.  Making it larger would change the class
   definition so it could not support older files with the
   current OMObjSpace class structure.
*/
/*
#define  MAXFILENAMELEN OM_K_MAXOSNAME_LEN
#endif
*/

#ifdef BIG_ENDIAN
extern  int     som_bigend_portHdr();
extern  int     som_swapint();
#endif

#ifdef SUNOS
extern  int     link();
extern  time_t  time();
extern  int     write();
extern  int     stat();
extern  int     fstat();
extern  int     statfs();
#endif

extern  int     EX_error_box();
extern  int     OM_get_time();
extern  int     OM_make_internal_OS_name();
extern  int     OM_PMS();
extern  int     load_objspace();
extern  int     som_addLockEntry();
extern  int     som_calcClusterFrag();
extern  int     som_cmpFileTimeStamp();
extern  int     som_copy_filed_cluster();
extern  int     som_create_cluster0_obj();
extern  int     som_csfwrite();
extern  int     som_file_freelist();
extern  int     som_get_fcd();
extern  int     som_makeLockFile();
extern  int     som_modifyAccess();
extern  int     som_validate_tag();
extern  int     som_verify_checksum();
extern  int     som_verify_filename();


extern  OMuint  OM_Gi_transOS_size;
extern  int	OM_Gi_transOS_extsize;
extern  OMuint  OM_Gi_transOS_numobjs;
extern  int	OM_Gi_transOS_extobjs;
extern  OMuint  OM_Gi_defMOSD_initsize;
extern  OMuint  OM_Gi_defMOSD_extsize;
extern  OMuint  OM_Gi_defMOSD_numobjs;
extern  OMuint  OM_Gi_defMOSD_extobjs;
extern  OMuword OM_Gw_RO_OS_count;
extern  int     OM_Gf_autoRecluster;      /* Re-autocluster flag */
extern  OMuint  OM_Gf_validate_OS;
#ifndef NT
extern  int     OM_Gi_ARTpercentFrag;
extern  int     OM_Gi_ARTpercentClusters;
#endif
extern  OMuint  OM_Gf_checksum_OS;
extern  OMuint  OM_Gi_checksum;
extern  OMuint  OM_Gi_pid;
extern  OMuint  OM_Gi_phyClusterSize;
extern  OMuint  OM_Gf_fileLocking;        /* For distributed systems */

extern  int     OM_Gi_number_of_appl_ids;
extern  INGR_p_PRODUCT_DEF OM_GA_appl_version[];
extern  OM_p_ORIGOSNAME OM_Gp_orig_osname;
extern  OM_p_DUPINTOS   OM_Gp_dup_intosname;

extern  char    *OM_Gp_sysgenPath;
extern  char    EX_runname[];
extern	struct OM_sd_lockFiles	**OM_GA_lockFiles;
extern  struct OM_sd_lockFileRec *OM_Gp_lockFileRec;
extern  int     *OM_GA_OSflags;
extern  OM_S_SYSINFO *OM_Gp_SYSINFO;

from OMMOSD	import add_entry,delete_entry,modified_OS_wrt;
from OMGroup	import init_spacemap;
from OMOSCO	import initialize, set_up;
from OMTagCon   import set_up, prep_write, reconnect;
from OMTag      import set_up, get_record_vla;

#define OBJID_SIZE	sizeof(OM_S_OBJID) 



method get_freelist_ptr(OM_S_OSHOLE **freelist)
{
	*freelist = ME.OMObjSpace->OS_holes;
	return(OM_S_SUCCESS);
}

/*****************************************************************/

/*
   Kludge for the umount to work when nested.
*/

static DIumount_os ( osnum )
                     uword osnum /* The object space to be umounted	 IN */;
{
  OM_S_OBJID root_id;
  int   status, i, count;
  char  name [DI_PATH_MAX];

  /*"osnum: %d\n", osnum */  
  DIfind_root ( osnum, &root_id );
  /*"root_id: %d\n", root_id */
  count = 0;
  status = di$start_untrans ( osnum = osnum, objid = root_id, ptr = &count );
  if (status == 1)
     for (i = 0; (count) && (i < 256); i++)
    {
      di$fetch_untrans ( objname = name );
      di$umount ( dirname = (char *) name );
      di$start_untrans ( osnum = osnum, objid = root_id, ptr = &count );
    }

  DIdelete_untree ( osnum );

  return 1;
}

method delete(int defer_flag)

/*======================================================================
/*
/*	Method delete for OMFiledOS
/*
/* arguments:
/*	 defer_flag -- not used; must be present because
/*			 of Root.delete 
/* purpose:
/*	possibly writes, then deletes, a filed object space.
/*
/* used by:
/*	anybody who wants to save the state of the OS they are working
/*	with. A subsequent construct will read the OS back in.
/*
/* logic:
/*	If we are connected to a transient os any iso connections exist, 
/*	dissolve them.
/*	If state and other flags are ok, send a write message to ourselves.
/*	Send a message to the MOSD to delete our entry.
/*	For each cluster, call the cluster_free routine, which de-allocates
/*	the data structures used by the cluster (including the objects)
/*
/* notes:
/*	At the end of this routine, the oso object will still exist.
/*	This object (and all of cluster 0) is deleted by root.delete
/*	once the send depth goes to 0.
/*
==========================================================================*/
{
   int               i, ii, sts, size, num_dup;
   OM_p_TAGCON_LINK  p_link1, p_link2;
   OM_p_ORIGOSNAME   p_oname, p_prev_oname;
   OM_p_DUPINTOS     p_dupint, *pp_prev_dupint;
   OMuword           osnum;

   osnum = OM_Gw_current_OS;

   /*========================================================*/
   /* If OS is going to be written, make sure there's enough */
   /* disk space to hold it before we dissolve the ISO's.    */
   /*========================================================*/
   if ( ( !(ME.OMObjSpace->OSD.flags & OM_e_loados_ro) &&
         !(ME.OMObjSpace->OSD.flags & OM_OSD_nowrite) ) )
      if(!(1&(sts = om$enough_disk_space(osnum = OM_Gw_current_OS))))
	 return(sts);

   /*=======================================================*/
   /*  unmount any IGRdir which is associated with this OS  */
   /*=======================================================*/
   DIumount_os ( OM_Gw_current_OS ) /* this will fix the ordering pblm, henry */;

   /*====================================================================
     Set the flag in our OSD which indicates that we are being deleted.
     ===================================================================*/
   ME.OMObjSpace->OSD.flags |= OM_OSD_Rootdel_pending;

   if (!(ME.OMObjSpace->OSD.flags & OM_e_loados_ro) &&
       !(ME.OMObjSpace->OSD.flags & OM_OSD_nowrite))
   {
      if (ME.OMObjSpace->OSD.type == OM_OSD_filed)
      {
         if (!(1&(sts = om$send(msg = message OMFiledOS.write (NULL),
                       targetid = my_id))))
            return (sts);
      }
   }
   else  /*  The file is not writable - either by loadmode or state  */
   {
      /*=======================================================*/
      /*  Go ahead and cleanup TagCons if OS state is nowrite  */
      /*  This is needed for RW reference file cleanup         */
      /*=======================================================*/

      if (ME.OMObjSpace->OSD.flags & OM_OSD_nowrite) 
      {
         OMuword  ii;
         if (OM_GA_p_tagcon)
         {
           /*=============================================================*/
           /*  First we send TagCon prep_write to all TagCons in this OS  */
           /*  Yea - wipe out those unruly ISOs - that'll teach 'em       */
           /*=============================================================*/

           if (p_link1 = OM_GA_p_tagcon[OM_Gw_current_OS])
              while (p_link1)
              {
                 sts = om$send ( msg = message OMTagCon.prep_write(),
                                 targetid = p_link1->objid );
                 if (!(1&sts))
                 {
                    om$report_error(sts=sts);
                    printf ("OMFiledOS.delete: OMTagCon.prep_write failed\n");
                    return (sts);
                 }
                 p_link1 = p_link1->next;
              }

           /*================================================================*/
           /*  Check TagCon objects in other OS's for connections to objects */
           /*  in this OS.  If any found, send prep_write msg.               */
           /*================================================================*/

            if (OM_GA_tag_oids && !IF_NULL_OBJID(OM_GA_tag_oids[OM_Gw_current_OS]))
               for (ii=0; ii<OM_Gw_maxOS; ++ii)
                  if (p_link1 = OM_GA_p_tagcon[ii])
                     while (p_link1)
                     {
                        if (!strncmp(p_link1->int_osname, 
                                     ME.OMObjSpace->OSD.InternalName,
                                     OM_K_MAXINTOSNAME_LEN))
                        {
                           if (!(1&(sts=om$send(msg=message OMTagCon.prep_write(),
                                                targetid=p_link1->objid,
                                                targetos=ii))))
                           {
                              om$report_error(sts=sts);
                              printf("OMFiledOS.delete:OMTagCon.prep_write fail\n");
                              return(sts);
                           }
                           break;
                        }
                        p_link1 = p_link1->next;
                     }
         }
      }

      size = om$dimension_of(varray=ME.OMObjSpace->iso_d);

      if (size)
      {
         /*=============================================================*/
         /* Dissolve any ISO connections active (i.e., look at all the  */
         /* other OS's and MARK their iso connections as hanging.  Mark */
         /* ours as well.                                               */
         /*=============================================================*/

         if (!(1&(sts = om$send ( msg = message OMObjSpace.dissolve_ISOs(), 
                                  targetid = my_id ))))
            return (sts);
      }
   }

   if (OM_Gf_fileLocking)
   {
      /* There will be an OM_sd_lockFiles node for every file
       * ever associated with an osnum.
       */

      struct OM_sd_lockFiles  *ptr=OM_GA_lockFiles[osnum];

      sprintf(OM_Gp_lockFileRec->osnum, "%5d", osnum);
      while (ptr)
      {
         som_modifyAccess(ptr->name, 'V');
         ptr = ptr->next;
      }
   }

   OM_GA_OSflags[osnum] = 0;	/* Application obj space flags */

 /*==========================================
    Delete this from the entries in the MOSD
   ==========================================*/
  sts = om$send (msg = 	message OMMOSD.delete_entry (osnum),
		 targetid = OM_GO_current_MOSD,
		 targetos = 0);
  if (!(1&sts))
    return (sts);


 /*====================================================*/
 /*  check if there are any TagCon objects in this OS  */
 /*  and clean up any global TagCon data structures    */
 /*====================================================*/

 if ( OM_GA_p_tagcon )
 {
   if ( p_link1 = OM_GA_p_tagcon[OM_Gw_current_OS] )
   {
     while ( p_link1 )
     {
       p_link2 = p_link1->next;
       om$dealloc ( ptr = (char *) p_link1 );
       p_link1 = p_link2;
     }
     OM_GA_p_tagcon[OM_Gw_current_OS] = 0;
   }
 }

 /*======================================================*/
 /*  Remove all references to the OMTag object for this  */
 /*  OS.  (Check to see if it exists first.)             */
 /*======================================================*/

 if (OM_GA_tag_oids)
    if (! IF_NULL_OBJID(OM_GA_tag_oids[OM_Gw_current_OS]))
    {
       OM_GA_tag_oids[OM_Gw_current_OS] = NULL_OBJID;
       om$dealloc(ptr=(char *) OM_GA_p_tag_hashtable[OM_Gw_current_OS]);
       OM_GA_p_tag_hashtable[OM_Gw_current_OS] = NULL;
    }

 /*=======================================================
    Call the cluster trash routine for all but cluster 0
   =======================================================*/

 for(ii=ME.OMObjSpace->OSD.ClustersSize-1; ii>0; ii--)	/* For each cluster */
 {							/* in LCD array */
  if((ME.OMObjSpace->OSD.Clusters[ii])
			 &&
     (ME.OMObjSpace->OSD.Clusters[ii]->flags & OM_FAULTED))
    om$cleanup_cluster(p_clustcmp=ME.OMObjSpace->OSD.Clusters[ii]);
 }

 if(ME.OMObjSpace->OSD.flags&OM_e_loados_ro) OM_Gw_RO_OS_count--;

  /*===========================================================*/
  /*  cleanup any record of the original OS name if it exists  */
  /*===========================================================*/

  p_prev_oname = 0;
  p_oname = OM_Gp_orig_osname;
  while (p_oname)
  {
     if ( p_oname->osnum == OM_Gw_current_OS ) break;
     p_prev_oname = p_oname;
     p_oname = p_oname->next;
  }
  if (p_oname) 
  {
     if ( !p_prev_oname ) 
        OM_Gp_orig_osname = p_oname->next;
     else
        p_prev_oname->next = p_oname->next;
     om$dealloc ( ptr = (char *) p_oname );
  }

  /*===============================================================*/
  /*  check if this OS is represented in dup internal osname list  */
  /*===============================================================*/

  pp_prev_dupint = &OM_Gp_dup_intosname;
  p_dupint = OM_Gp_dup_intosname;
  while (p_dupint) {
     if (p_dupint->osnum == OM_Gw_current_OS) {
        *pp_prev_dupint = p_dupint->next;
        om$dealloc ( ptr = (char *) p_dupint->dup_osnum );
        om$dealloc ( ptr = (char *) p_dupint );
        p_dupint = *pp_prev_dupint;
     }
     else {
        num_dup = p_dupint->num_dup;
        for (i=0; i<num_dup; ++i) {
           if (p_dupint->dup_osnum[i] == OM_Gw_current_OS) {
              if (num_dup == 1) {  /* keep around to say I WAS duplicated */
                 p_dupint->num_dup = 0;
                 pp_prev_dupint = &p_dupint->next;
                 p_dupint = p_dupint->next;
              }
              else {
                 if (i != num_dup-1) {
                    p_dupint->dup_osnum[i] = p_dupint->dup_osnum[num_dup-1];
                 }
                 p_dupint->dup_osnum = (OMuword *) om$realloc (
                    ptr  = (char *) p_dupint->dup_osnum,
                    size = --p_dupint->num_dup * sizeof(OMuword));
                 pp_prev_dupint = &p_dupint->next;
                 p_dupint = p_dupint->next;
              }
              break;
           }
        }
        if (i == num_dup) {
           pp_prev_dupint = &p_dupint->next;
           p_dupint = p_dupint->next;
        }
     }
  }

  /*====================================================
    Sending a root delete message to ouselves ..
    ====================================================*/

  om$send(msg = message Root.delete(TRUE),
   	  mode=OM_e_wrt_message,
	  targetid = my_id);

  return(OM_S_SUCCESS);

} /* end of delete method */


/*============================================================*/
method	set_state	(int state_flag)
/*
/*	Method set_state for OMFiledOS
/*
/*	arguments:
/*			state_flag: the new value which the state flag is
/*				to take on.
/*	purpose:
/*			to set the state flag, which governs whether a filed
/*			object space is writable.
/*	used by:
/*			users who, for instance, wish to make a filed os 
/*			'not writable'.
/*	logic:
/*			if the value of set_state is reasonable, set the
/*				state flag to it.
/*	note:
/*	values for the state flag are:
/*		0	=>	make it unwriteable
/*		1	=>	make it writeable
*/
{
  switch (state_flag)
  {
  case 0:
    ME.OMObjSpace->OSD.flags |= OM_OSD_nowrite;
    break;
  case 1:
    ME.OMObjSpace->OSD.flags = ME.OMObjSpace->OSD.flags &~ OM_OSD_nowrite;
    break;
  default:
    return (OM_E_INVARG);
  }
  return (OM_S_SUCCESS);
}


/*============================================================*/
method	debug	()
/* 
/*	Method debug for OMFiledOS
/*
/*	arguments: none
/*	
/*	purpose: acknowledgement of existence
/*
/*	used by: OM developers, mainly, as a tool for determining validity
/*		 of the system.
/*	logic:	display some of the ME information
/*
*/
{
   return (OM_S_SUCCESS);
}


/***********************************************************************/

/*
/*	Function som_construct_os_by_name
/*
/*	arguments:
/*	   	*classname	 class name of object space
/*		*osnum           pointer to variable for new osnum 
/*		*osname	 	 pointer to name of object space
/*		p_objid	 pointer to variable for objid of the new OSO
/*		initcount	 initial number of objects in group 0
/*		extcount	 extent number of objects for group 0
/*		*resultcount     pointer to number of cnstructed objects
/*		maxobjsize	 maximum object size
/*		loadmode
/*		sameosflag	 if true & no ISOs reload os
/*              di_logical       pathname for IGRdir (named objects)
/*
*/

int  som_construct_os_by_name (
   char		*classname,	/* class name */
   uword	*osnum,         /* place for new osnum */
   char		*osname,	/* pointer to name string */
   OM_p_OBJID	p_objid,
   OMuint	initcount,
   OMuint	extcount,
   OMuint	*resultcount,
   OMuint	maxobjsize,
   OMuint	loadmode,
   char		sameosflag,	/* if true and no ISOs reload os */
   char		*di_logical)
{
   int sts;
   OMuword  classid;

	if(!(1&(sts = om$get_classid(classname=classname,
				     p_classid=&classid))))
	return(OM_E_BADCLASSNAME);

	sts = om$construct_os(classid=classid,
			      osnum=osnum,
			      osname=osname,
			      p_objid=p_objid,
			      initcount=initcount,
			      extcount=extcount,
			      resultcount=resultcount,
			      maxobjsize=maxobjsize,
			      loadmode=loadmode,
			      sameosflag=sameosflag,
                              di_logical=di_logical);
	return(sts);
}


/*************************************************************/

#argsused

int  som_construct_os(
   OMuint  	classid,		/* OS class name */
   uword	*osnum,			/* Returned OS number */
   char		*osname,		/* Ptr to name string */
   OM_p_OBJID	p_objid,		/* Returned ptr to OSO oid */
   OMuint	initcount,		/* Initial number of objects */
   OMuint	extcount,
   OMuint	*resultcount,		/* Returned number of objects */
   OMuint	maxobjsize,		/* Largest object allowed */
   OMuint	loadmode,		/* read/write or read-only */
   char		sameosflag,		/* if true and no ISOs reload os */
   char		*di_logical)		/* pathname for IGRdir(named objects)*/
{
/*=====================================================================*/
/* Routine to construct an object space */
/*
/* o Do basic error checking.
/* o Verify ancestry.  Is this guy a descendent of OMObjSpace?
/* o Malloc the phantom object to get the spacemap.
/* o Fill in a bare oso and osd fields, noting any overrides.
/* o Initialize the real spacemap.  Make oid 0 the spacemap.
/* o Call the cluster memory allocation routine.
/* o With the returned pointer, create the real oso and real
/*   cluster fields.
/* o Cleanout the channels.
/* o Initialize the VLA's.
/* o Initialize fields, set user args if neccessary.
/* o Point oid 0 of the spacemap to the oso and point OM_GA_OSDs to the
/*   real osd.
/*
/*=====================================================================*/

   int               sts, file_stat;
   OMuint            jj, size_of_oso, size_of_group,
                     cluster_offset, objspace_offset,
                     trans_decen, filed_decen, mosdos_decen;
   OM_p_OBJECTHDR    p_oso_hdr;        /* Ptr to OSO object header */
   OM_p_OBJECTHDR    p_group_hdr;      /* Ptr to group object objhdr */
   struct OMObjSpace_instance *p_oso;  /* Ptr to the OS instance data  */
   OM_p_OSD          p_osd;            /* Ptr to its OSD */
   struct OMCluster_instance  *p_cluster; /* Ptr to the cluster part the oso */
   OM_p_LCD          p_ph_lcd;         /* Ptr to phantom lcd */
   OM_p_PCD          p_pcd;            /* Physical cluster descr ptr */
   OM_p_FCD          p_fcd;            /* Ptr to free chunk descr */
   OM_p_CSD          p_csd;            /* cluster slot descriptor */
   OM_p_CLASSDEF     p_acld;
   OM_S_CHANSELECT   ch_from, ch_to;
   OM_S_OBJID        dummy_objid;
   OM_S_NEIGHBOR     neighbor;
   FILE              *fileptr;         /* Used if loading a filed OS */
   OMuword           incoming_osnum,   /* Current_os when this routine */
		     ii, assigned_osnum;   /*  was invoked */
   OM_p_CLUSTFHDR    p_free_space;     /* Initial free space of Cluster0 */
   OM_p_DUPINTOS     p_dupint;            

   /*===============================================*/
   /* 		initialize and verify	            */
   /*===============================================*/
   if (!(sts = strlen(osname)))		  	/* Check out name */
      return(OM_E_NULL_STRING);
   if (sts >= OM_K_MAXOSNAME_LEN)
      return(OM_E_NAMETOOLONG);
   if (osname[sts-1] == '/')
      osname[sts-1] = '\0';

   p_acld = OM_GA_active_classes[classid];	/* Class's acld entry */

  /*====================================================*/
  /* Verify the ancestry by checking if the class is a  */
  /* subclass of OMObjspace; if the class is mosdos and */
  /* is a subclass of mosdos; if the class is not both  */
  /* transient and filed at the same time.              */
  /* We are using the translation map of the acld.      */
  /*====================================================*/
  /* If this turns out to be an ok class, we will need  */
  /* the offset to the objspace instance data later on, */
  /* so get it now.                                     */
  /*====================================================*/

   FIND_ANC_OFFSET(sts,p_acld,OM_K_OMOBJSPACE_ACTCLASSID,objspace_offset)
   if (sts == 2)
      return(OM_E_BADCLASSNAME);
 
   /*=================================================*/
   /* It is illegal to construct an OMObjSpace object */
   /*=================================================*/
   if ((sts == 1) && (classid == OM_K_OMOBJSPACE_ACTCLASSID))
      return(OM_E_BADCLASSNAME);

   FIND_ANC_OFFSET(sts,p_acld,OM_K_OMMOSDOS_ACTCLASSID,jj);
   if (sts == 1)			/* MOSDOS subclass */
      mosdos_decen = 1;
   else mosdos_decen = 0;

   if ((sts == 1) && (classid != OM_K_OMMOSDOS_ACTCLASSID))
      return(OM_E_BADCLASSNAME);

   FIND_ANC_OFFSET(sts,p_acld,OM_K_OMTRANSOS_ACTCLASSID,jj);
   if (sts == 1)
      trans_decen = 1;
   else trans_decen = 0;

   FIND_ANC_OFFSET(sts,p_acld,OM_K_OMFILEDOS_ACTCLASSID,jj);
   if (sts == 1)
      filed_decen = 1;
   else filed_decen = 0;

   if (filed_decen & trans_decen)	/* Can't be filed & transient */
      return(OM_E_BADCLASSNAME);

   if (filed_decen)
   {
      char  *ptr;

#ifdef NT
      if (ptr = (char *) strrchr(osname, '\\'))
#else
      if (ptr = (char *) strrchr(osname, '/'))
#endif
         ++ptr;
      else ptr = osname;
      if (strlen(ptr) > MAXFILENAMELEN)
         return(OM_E_NAMETOOLONG);
   }

   /*=================================================*/
   /* Does an OS exist by this name?  Must be unique. */
   /* Sanity check, convert osname to osnum.          */
   /*=================================================*/
   for (ii=0; ii<OM_Gw_maxOS; ii++)
   {
      if (OM_GA_OSDs[ii] == NULL)
         continue;
      if (!strncmp(OM_GA_OSDs[ii]->name,osname,OM_K_MAXOSNAME_LEN))
      {
         *osnum = ii;				/* So user can see the */
         *p_objid = OM_GA_OSDs[ii]->OSO_Oid;	/* os number and oid */
         return(OM_W_OBJSPACE_EXISTS);		/* Not unique osnum */
      }
   }

   /*===================================================================*/
   /* See if there is any room for one by scanning the list of pointers */
   /* to the osd's and seeing if there any null entries.                */
   /*===================================================================*/
   assigned_osnum = (OMuword) -1;	/* Assume we can't find any */

   for (ii=0; ii<OM_Gw_maxOS; ii++)
      if (OM_GA_OSDs[ii] == NULL)
      {
         assigned_osnum = ii; 
         break; 
      }

   if (assigned_osnum == (OMuword) -1)
      return (OM_E_NO_OS_AVAIL);

   *osnum = assigned_osnum;		/* Return slot index we found */
  
   if (filed_decen)			/* Subclass of filed class? */
   {					/* (is this a filed obj space? */
      /*============================================================*/
      /* Verify that the osname is a filed object space filename by */
      /* trying to open the file.  If open fails, then not a file.  */
      /*============================================================*/
      if (!(1&(file_stat = som_verify_filename(osname))))
         return(file_stat);
#ifndef NT
      if (OM_Gf_fileLocking)
      {
         char  lockFile[MAXPATHLEN+1];
         /* The osnum field makes unique each attachment of a reference
          * file that is attached multiple times.
          */
         sprintf(OM_Gp_lockFileRec->osnum, "%5d", assigned_osnum);
         if (!(1&(sts = som_makeLockFile(osname,
               (file_stat == OM_I_NOEXIST_WRITEABLE_FILE) ? 1 : 0,
               &lockFile[0], loadmode))))
            return(sts);

         if (!(OM_GA_lockFiles[assigned_osnum] = (struct OM_sd_lockFiles *)
            om$malloc(size = sizeof(struct OM_sd_lockFiles))))
            return(OM_E_NODYNMEM);

         if (!(OM_GA_lockFiles[assigned_osnum]->name = (char *)
            om$malloc(size = strlen(lockFile))))
            return(OM_E_NODYNMEM);

         strcpy(OM_GA_lockFiles[assigned_osnum]->name, lockFile);
         OM_GA_lockFiles[assigned_osnum]->next = NULL;
      }
#endif

      /*===============================================================*/
      /* Open file for reading and call routine to load the obj space. */
      /*===============================================================*/
#ifndef NT
      if((fileptr = (FILE *) fopen(osname,"r")) != NULL)
#else
      if((fileptr = (FILE *) fopen(osname,"rb")) != NULL)
#endif
      {
         /*===========================================================*/
         /* Save the object space that is now the globally-accessible */
         /* current object space.  The load_objspace routine uses the */
         /* global variable and blows the real current guy away.      */
         /*===========================================================*/
         incoming_osnum = OM_Gw_current_OS;
	 sts = load_objspace(fileptr,assigned_osnum,p_objid,osname,sameosflag,
                             loadmode);
	 if (!(1&sts))
	 {
	    om$make_current_os(osnum=incoming_osnum);	/* Restore cur OS */
            if (fileptr) fclose(fileptr);
 	    return(sts);
	 }

	 /*========================================*/
	 /* Add us to the list of OS's in the MOSD */
	 /*========================================*/
	 sts = om$send(targetid=OM_GO_current_MOSD,
	 	       targetos=0,
		       senderid=0,
		       msg=message OMMOSD.add_entry(assigned_osnum,
			  OM_GA_OSDs[assigned_osnum]->OSO_Oid,
			  OM_GA_OSDs[assigned_osnum]->name));

	 if (!(1&sts)) 
	 {
	    om$make_current_os(osnum = incoming_osnum);
            if (fileptr) fclose(fileptr);
 	    return(sts);
	 }

	 /*=============================================*/
	 /* Count the number of objects in each cluster */
	 /* of the object space.                        */
	 /*=============================================*/
	 if (resultcount)
	 {
            OMuint  ii;
	    *resultcount = 0;
	    for (ii=0; ii<OM_GA_OSDs[assigned_osnum]->ClustersSize; ii++)
	    {
	       if (p_ph_lcd = OM_GA_OSDs[assigned_osnum]->Clusters[ii])
	       {
		  if (p_pcd = (OM_p_PCD) p_ph_lcd->pcdq_lh.next)
		  {
		     while (p_pcd != (OM_p_PCD) &(p_ph_lcd->pcdq_lh.next))
		     {
		        *resultcount += p_pcd->i_cur_num_objects;
		        p_pcd = (OM_p_PCD) p_pcd->pcdq.next;
		     }
		  }
	       }
	    }
	 }

	 /*=====================================================*/
	 /* Indicate that there is another ro os in the system. */
	 /*=====================================================*/
         if(OM_GA_OSDs[assigned_osnum]->flags&OM_e_loados_ro) 
		OM_Gw_RO_OS_count++;

         /*================================================*/
         /* Check if the user specified an IGRdir pathname */
         /*================================================*/
         if ( di_logical )
         {
            sts = di$mount ( logical = di_logical, osnum = assigned_osnum );
            if (!(1&sts)) 
            {
               fprintf(stderr,"Could not mount directory %s\n",di_logical);
               di$report_error (sts=sts);
            }
         }

	 om$make_current_os(osnum = incoming_osnum);	/* Restore orig. OS */

         p_dupint = OM_Gp_dup_intosname;
         while (p_dupint) {
            if (p_dupint->osnum == assigned_osnum) break;
            p_dupint = p_dupint->next;
         }

	 /*====================================================*/
	 /* We use different return messages here for clarity. */
	 /*====================================================*/
	 if(file_stat == OM_I_EXIST_READONLY_FILE)
	 {
            if (fileptr) fclose(fileptr);
            if (p_dupint) return (OM_I_DUPLICATE_OS_RO);
	    return(OM_I_READ_FROM_RO_FILE);
         }
	 else
	 {
            if (fileptr) fclose(fileptr);
            if (p_dupint) return (OM_I_DUPLICATE_OS);
	    return(OM_I_READ_FROM_FILE);
         }

      }
   }		/*========== End Filed OS Handler ==========*/


   /*=======================================*/
   /*	 Constructing a new object space    */
   /*=======================================*/

   /* Get the size of the objspace/cluster instance data. */

   if (!(1&(sts = om$vla_find_initial_size(p_cld=p_acld,
					   p_size=&size_of_oso)))) 
      return(sts);
   size_of_oso = OM_ALIGN_OBJECT_SIZE(size_of_oso);

   /*===================================================================*/
   /* Construct a 'phantom' cluster descriptor, which we need until we  */
   /* can set up the cluster/objectspace object (which will contain the */
   /* real Cluster 0 descriptor).  An LCD is required by the create_    */
   /* cluster0_obj routine, but we won't have the real Cluster 0 LCD    */
   /* until after the Cluster 0 object exists; so a phantom LCD is used */
   /* until that point.  No LCD information is used before Cluster 0    */
   /* object creation, so none of the phantom LCD fields need to be     */
   /* filled in.  The create_cluster0_obj routine returns the PCD       */
   /* address of the physical cluster it allocates in the phantom LCD's */
   /* p_pcd field.                                                      */
   /*===================================================================*/
   if ((p_ph_lcd = om$malloc(structure=OM_S_LCD)) == NULL)
      return(OM_E_NODYNMEM);

   p_ph_lcd->pcdq_lh.next = p_ph_lcd->pcdq_lh.prev =
      (OM_p_DLINK) &(p_ph_lcd->pcdq_lh.next);
   p_ph_lcd->p_pcd = NULL;

   /*===================================================================*/
   /* Create the real Cluster 0.  om$create_cluster0_obj knows we're    */
   /* in start-up situation and will initialize autoclustering data     */
   /* structures while generating Cluster ).  It will return a pointer  */
   /* to a slot descriptor, which will point to the associated physical */
   /* cluster memory region and its descriptor (PCD).  The PCD will     */
   /* point to the phantom LCD we pass to it.  We also get back a ptr   */
   /* to the Cluster 0 instance data (also pointed to by the CSD).  The */
   /* instance data will reside within the physical cluster which now   */
   /* occupies the slot described by the CSD.  Any objects placed in    */
   /* that cluster will know the slot index (SDI) of that slot.  As the */
   /* physical cluster is filled up with objects, new physical clusters */
   /* will be generated and given their own slots in the OM shared mem. */
   /* region.  Note that the slots occupied by Cluster 0 are never      */
   /* locked slots, as other slots will generally be.  This means       */
   /* Cluster 0 is pageable, although not part of the shmem heap.       */
   /* OM_CLUST0 is set in csd->flag to help insure we stay that way.    */
   /*===================================================================*/

   if (!(1&(sts = som_create_cluster0_obj(p_ph_lcd,
   					 size_of_oso,
   					 &p_oso_hdr,
   					 &p_csd,
   					 &jj))))
      return(sts);

   /*================================================================*/
   /* Although the object allocation routine normally increments the */
   /* i_cur_num_objects field, since we merely malloc-ed to create   */
   /* this object, the OSO, we must set the fields ourselves.        */
   /*================================================================*/
   p_pcd = p_csd->p_pcd;
   p_pcd->i_cur_num_objects = p_pcd->i_cur_num_chunks = 1;

   /*==================*/
   /* Build free list. */
   /*==================*/
   if (!(1&(sts = som_get_fcd(&p_fcd))))
      return(sts);
   p_pcd->p_fcd = p_fcd;				/* Hang it on pcd */
   p_fcd->nextfcd = NULL;				/* Only one descr */
   p_fcd->freehdr = (OM_p_CLUSTFHDR) ((int) p_csd->p_addr + size_of_oso);
   p_fcd->size = p_pcd->i_totalsize - size_of_oso;	/* Size of free area */
   p_pcd->i_numfree_chunks = 1;				/* Only one descr */
   p_pcd->i_totalfree = p_fcd->size;			/* Size of free area */
   p_free_space = (OM_p_CLUSTFHDR)p_fcd->freehdr;	/* Initialize cluster */
   p_free_space->p_fcd = p_fcd;				/*  free header       */
   p_free_space->size = p_fcd->size;
   OM_SETFREEBIT(p_free_space->size)

   /*============================================================*/
   /* Insure that subclasses of os will have 0 in their instance */
   /* data, zero out the object space object.                    */
   /*============================================================*/
   memset((void *) (p_oso_hdr), 0, size_of_oso);

   /*========================================================*/
   /* Need to know instance data offset for cluster objects. */
   /*========================================================*/
   FIND_ANC_OFFSET(sts,p_acld,
		   OM_K_OMCLUSTER_ACTCLASSID,		/* cluster portion */
		   cluster_offset);

   /*============================================================*/
   /* Get handy pointers so we can fill in this object.  It will */
   /* contain the object space instance data, cluster 0 instance */
   /* data, and point to the OSD.                                */
   /*============================================================*/
   p_oso = (struct OMObjSpace_instance *) ((char *) p_oso_hdr +
      objspace_offset);
   p_cluster = (struct OMCluster_instance *) ((char *) p_oso_hdr +
      cluster_offset);
   p_osd = &(p_oso->OSD);

   /*========================================*/
   /* Fill in the object space object header */
   /*========================================*/
   p_oso_hdr->oid = 0;
   p_oso_hdr->i_size = size_of_oso | OM_OHf_has_VLA; /* Obj flags are lower
   							2 bits of i_size */

   /*============================================*/
   /* Initialize the objspace portion of the oso */
   /*============================================*/
   /* Initialize the VLA's                       */
   /*============================================*/
   om$vla_initialize_offsets(p_cld=p_acld, object=p_oso_hdr);

   /* fill in fields in the objspace instance not in the osd */

   OM_get_time(p_oso->CreTimeDate);
   p_oso->TimeDate[0] = 0;
   p_oso->p_filehdr = NULL;
   p_oso->OS_HoleCount = 0;

   /*=============================================*/
   /* Initialize the osd portion of the objspace. */
   /*=============================================*/
   p_osd->lcfq_lh.next = p_osd->lcfq_lh.prev =
      (OM_p_DLINK) &(p_osd->lcfq_lh.next);
   OM_make_internal_OS_name (osname, p_osd->InternalName);
   strncpy(p_osd->name,osname,OM_K_MAXOSNAME_LEN);

   p_osd->OSnum = assigned_osnum;
   p_osd->OSO_Oid = 0;				/* we are oid 0 */
   p_osd->flags = OM_OSD_inuse;        /* this os is open for business */

   /* Find the displacement from the osd to the vla of oids */

   p_osd->OidFreelist = (OMuint) &p_oso->freeoids_descr - (OMuint) p_osd;

   /* we set these 'decen' variables earlier when verifying ancestory */

   if (trans_decen)
      p_osd->type = OM_OSD_trans;
   else if (filed_decen)
      p_osd->type = OM_OSD_filed;
   else if (mosdos_decen)
      p_osd->type = OM_OSD_MOSDOS;

   /* Is this a filed, read only object space? */

   if ((filed_decen) && (loadmode == OM_e_loados_ro)) 
   {
      p_osd->flags = OM_e_loados_ro;
      OM_Gw_RO_OS_count++;
   }

   /*==================================================================*/
   /* The size of the spacemap initialially is the size of the initial */
   /* allocation for group 0.  This figure must be greater than or     */
   /* equal to OM_K_MINOBJS_COUNT.  It can be 0, though...             */
   /*==================================================================*/ 
   if (initcount)
   {
      if (initcount < OM_K_MINOBJS_COUNT)
         initcount = OM_K_MINOBJS_COUNT;
   }
   else
      initcount = trans_decen ? OM_Gi_transOS_numobjs :
         (filed_decen ? OM_Gi_filedOS_numobjs : OM_Gi_defMOSD_numobjs);
   p_osd->CurSpaceMapSize = initcount;
   if (!extcount)
      extcount = trans_decen ? OM_Gi_transOS_extobjs :
         (filed_decen ? OM_Gi_filedOS_extobjs : OM_Gi_defMOSD_extobjs);

   p_osd->ClustersSize = 1;	/* Size of array of LCD's.  Start out with 1 */

   /*====================================*/
   /* Allocate and initialize a spacemap */
   /*====================================*/
   if ((p_osd->Spacemap = om$calloc(num=p_osd->CurSpaceMapSize,
      structure=OM_S_SPAMAPENT)) == NULL)
      return (OM_E_NODYNMEM);

   /*=================================================*/
   /* Fill in our slot (we're oid 0) in the spacemap. */
   /*=================================================*/
   p_osd->Spacemap[0].p_acld = p_acld;
   p_osd->Spacemap[0].sdi = p_csd->index;
   p_osd->Spacemap[0].flags = (OM_SM_in_use|OM_SM_in_mem);
   p_osd->Spacemap[0].state.object = (OM_p_OBJECTHDR) p_oso_hdr;
 
   /*======================================================*/
   /* Initialize active-to-filed and filed-to-active maps. */
   /*======================================================*/

   if (NULL == (p_osd->ActToFil = (OMuword *) om$malloc 
       		(size=OM_Gw_numclasses*sizeof(OMuword))))
      return (OM_E_NODYNMEM);
   if (NULL == (p_osd->FilToAct = (OMuword*) om$malloc 
       		(size=OM_Gw_numclasses*sizeof(OMuword))))
   {
      om$dealloc (ptr=(char *) p_osd->ActToFil); /* If can't alloc both, */
      p_osd->ActToFil = NULL;			/* don't keep either    */
      return (OM_E_NODYNMEM);
   }

   for (ii=0; ii < OM_Gw_numclasses; ii++)
      p_osd->ActToFil[ii] = p_osd->FilToAct[ii] = ii;

   /*=====================================*/
   /* Allocate the list of ptr to osco's. */
   /*=====================================*/
   if((p_osd->OSCO_list = om$calloc(num=OM_Gw_numclasses,
					 structure=OM_p_OSCO)) == NULL)
       return(OM_E_NODYNMEM);

   /*============================================*/
   /* Initialize the cluster portion of the oso. */
   /* Copy the fields from the phantom LCD that  */
   /* had values and initialize the rest.        */
   /*============================================*/
   p_cluster->lcd.pcdq_lh.next = p_cluster->lcd.pcdq_lh.prev =
      (OM_p_DLINK) p_pcd;
   p_cluster->lcd.p_pcd = p_pcd;
   p_cluster->lcd.p_osd = p_osd;
   p_cluster->lcd.i_file_ptr = 0;
   p_cluster->lcd.oid = 0;
   p_cluster->lcd.w_cluster_num = 0;
   p_cluster->lcd.flags=OM_FAULTED;
   p_cluster->lcd.i_cur_bytes_allocated = size_of_oso;
   p_pcd->p_lcd = &p_cluster->lcd;		/* Previously pointed to phantom lcd */
   p_pcd->pcdq.next = p_pcd->pcdq.prev =
      (OM_p_DLINK) &p_cluster->lcd.pcdq_lh.next;

   om$dealloc(ptr=(char *) p_ph_lcd);	/* Free up phantom lcd */

   /*===================================================*/
   /* These fields get their real values at write time. */
   /*===================================================*/
   p_cluster->i_fil_num_objects = 0;
   p_cluster->i_fil_byte_size = 0;

   OM_GA_OSDs[assigned_osnum] = p_osd;

   /*====================================================*/
   /* Set up the Clusters array, which holds pointers to */
   /* LCD of each cluster in the object space.           */
   /*====================================================*/
   if (!(p_osd->Clusters = om$calloc(structure=OM_p_LCD)))
      return(OM_E_NODYNMEM);
   p_osd->Clusters[0] = &(p_cluster->lcd); /* First guy alway Cluster 0 */

   /*==========================================*/
   /* Connect the oso to the cluster 0 object. */
   /*==========================================*/
   ch_from.type = OM_e_name;
   ch_from.u_sel.name = "OMObjSpace.to_ClusDscs";

   ch_to.type = OM_e_name;
   ch_to.u_sel.name = "OMCluster.to_OSO";

   /*===================================================================*/
   /* In order to issue sends (since we are not in a method) we have to */
   /* switch os's to the assigned_osnum.  Later, we will switch back to */
   /* the 'current' osnum, which we will keep in incoming_osnum.        */
   /*===================================================================*/
   incoming_osnum = OM_Gw_current_OS;
   om$make_current_os(osnum=assigned_osnum);

   sts = om$send(msg=message Root.connect(ch_to,0,0,assigned_osnum,
	        ch_from, 0),
	        senderid=0,
	        targetid=0);

   if (!(1&sts)) 
   {
      om$make_current_os(osnum=incoming_osnum);
      return(sts);
   }

  /*===================================*/
  /* Construction of the group object. */
  /*===================================*/
   p_acld = OM_GA_active_classes[OM_K_OMGROUP_ACTCLASSID];

   sts = om$vla_find_initial_size(p_cld=p_acld,		/* How big is it? */
				  p_size=&size_of_group);

   if (!(1&sts))
   {
      om$make_current_os(osnum=incoming_osnum);
      return(sts);
   }

   neighbor.clusterid = 0;
   sts = om$object_alloc(p_osd=OM_GA_OSDs[assigned_osnum],
			 neighbor=neighbor,
			 size=size_of_group,
			 object=&p_group_hdr,
			 sdi=&ii);
   if (!(1&sts))
   {
      om$make_current_os(osnum=incoming_osnum);
      return(sts);
   }

   /*============================================*/
   /* Fill in fields in the group object header. */
   /*============================================*/
   p_group_hdr->oid = 1;

   sts=om$vla_initialize_offsets(p_cld=p_acld,
				 object=p_group_hdr);
   if (!(1&sts)) 
   {
      om$make_current_os(osnum=incoming_osnum);
      return(sts);
   }

   p_oso_hdr = OM_GA_OSDs[assigned_osnum]->Spacemap[0].state.object;

   /*=================================*/
   /* Add Group 0 object to Spacemap. */
   /*=================================*/
   p_osd->Group0_Oid = 1;			/* Group 0 oid is always 1 */
   p_osd->Spacemap[1].p_acld = p_acld;
   p_osd->Spacemap[1].sdi = p_csd->index;
   p_osd->Spacemap[1].flags = (OM_SM_in_use|OM_SM_in_mem);
   p_osd->Spacemap[1].state.object = (OM_p_OBJECTHDR) p_group_hdr;
    
   /*=====================================================*/
   /* Initialize the number of initial and extend objects */
   /*=====================================================*/
   SETARG(initcount,initcount,
	  OM_Gi_transOS_numobjs,
	  OM_Gi_filedOS_numobjs,
	  OM_Gi_defMOSD_numobjs);

   SETARG(extcount,extcount,
	  OM_Gi_transOS_extobjs,
	  OM_Gi_filedOS_extobjs,
	  OM_Gi_defMOSD_extobjs);

   if (!(1&(sts=om$send(targetid=1,
	       targetos=assigned_osnum,
	       senderid=0,
	       msg=message OMGroup.init_spacemap(extcount,initcount,
		  1,p_osd->type,1)))))
   {
	om$make_current_os(osnum=incoming_osnum);
	return(sts);
   }

   /*==================================================================*/
   /* Create OSCO's for all classes we have created so far, which are: */
   /* us (classid) and Groups.  The OSCO OSCO is brute forced, and     */
   /* cluster will be taken care of by virtue of the fact that cluster */
   /* is a parent.                                                     */
   /*==================================================================*/

   neighbor.clusterid = 0;
   neighbor.groupid = OM_GS_NULL_NEIGHBOR.groupid;
   sts = om$construct(classid=OM_K_OMOSCO_ACTCLASSID,
		      neighbor=neighbor,
		      osnum=assigned_osnum,
		      p_objid=&dummy_objid,
		      msg=message OMOSCO.initialize 
			 (OM_GA_active_classes[classid],1));
   if(!(1&sts))
   {
      om$make_current_os(osnum=incoming_osnum);
      return(sts);
   }

   neighbor.clusterid = 0;
   neighbor.groupid = OM_GS_NULL_NEIGHBOR.groupid;
   if (!(1&(sts = om$construct(classid=OM_K_OMOSCO_ACTCLASSID,
		      neighbor=neighbor,
		      osnum=assigned_osnum,
		      p_objid=&dummy_objid,
		      msg=message OMOSCO.initialize 
			 (OM_GA_active_classes[OM_K_OMGROUP_ACTCLASSID],1)))))
   {
      om$make_current_os(osnum=incoming_osnum);
      return(sts);
   }

   /*=======================================================*/
   /* The object space is finally ready.  The last thing to */
   /* do is to pass back to user the number of objects and  */
   /* the object space oid.  Resultcount points to an int;  */
   /* unless the pointer is null, return the count the      */
   /* Cluster 0 LCD.                                        */
   /*=======================================================*/
   if (resultcount)
   {
      *resultcount = 0;
      if (p_pcd = (OM_p_PCD) p_cluster->lcd.pcdq_lh.next)
      {
	 while (p_pcd != (OM_p_PCD) &(p_cluster->lcd.pcdq_lh.next))
	 {
	    *resultcount += p_pcd->i_cur_num_objects;
	    p_pcd = (OM_p_PCD) p_pcd->pcdq.next;
	 }
      }
   }

   *p_objid = 0;  /* Return obj space obj id -- always 0 */

   /*========================================*/
   /* Add us to the list of OS's in the MOSD */
   /*========================================*/
   if (!mosdos_decen)
   if (!(1&(sts = om$send(targetid=OM_GO_current_MOSD,
			  targetos=0,
			  senderid=0,
			  msg=message OMMOSD.add_entry(assigned_osnum,0,
			             OM_GA_OSDs[assigned_osnum]->name)))))
      return(sts);

   /*================================================*/
   /* Check if the user specified an IGRdir pathname */
   /*================================================*/
   if ( di_logical )
   {
      sts = di$mount ( logical = di_logical, osnum = assigned_osnum );
      if (!(1&sts)) 
      {
         fprintf(stderr,"Could not mount directory %s\n",di_logical);
         di$report_error (sts=sts);
      }
   }

   /*===================================*/
   /* Restore the previous 'current os' */
   /*===================================*/
   om$make_current_os(osnum=incoming_osnum);

   return(OM_S_SUCCESS);
}


/********************************************************************/
int som_enough_disk_space(OMuword input_osnum, char *osname,
   char *filename, int filesize)
{

/* Look ahead to see if there is enough room in this file system for
 * this object space.  The calculation for bytes_needed is an
 * approximation.
 */

   FILE     *fp;
/*   int      sts, free_bytes, bytes_needed, i, new_file;*/
    int      sts, i, new_file;
    double   free_bytes;
    unsigned int  bytes_needed;

   OMuword  osnum;
#if defined (SYSV) || defined (BSD)
   struct statfs        stat_buf;
#else
   struct _diskfree_t   diskinfo;
#endif

   /* determine validity of the OS name or number */

   bytes_needed = 0;
   if (!filename)
   {
      if(!osname)
      {
         /* user supplied an osnum */
         if ((input_osnum >= OM_Gw_maxOS) || (OM_GA_OSDs[input_osnum] == NULL))
            return(OM_E_NOSUCHOS);
         osnum = input_osnum;
      }
      else
         /* user supplied an os name */
         if(!(1&(sts = om$os_name_to_number (osname=osname,p_osnum=&osnum))))
            return(sts);

      filename = OM_GA_OSDs[osnum]->name;

   }  /* filename NULL */
   else
      bytes_needed = filesize;   /* Caller specified file name and size */

   /* determine if this is a new or existing file. If it is new, open it
    * for write. if it exists, open it for reading
    * if the file doesnt exist, keep a flag which indicates that. When
    * we close the file after calling statfs, we will unlink
    * the file if it was new. This will result in its deletion. We do this
    * so that a 0 length file isn't left out on disk. we dont do this for
    * existing files since the user may not call delete on that os and we 
    * dont want to trash it 
    */

   new_file = 0;
#if defined (SYSV) || defined (BSD)
   if ((access(filename, 0) == -1) && (errno == ENOENT)) /* File exists? */
      new_file = 1;
   if (!(fp = (FILE *) fopen(filename, "a")))  /* Can file be written? */
      return(UNIX_CONVERT_ERRNO(errno));
   if (sts = statfs(filename,&stat_buf,sizeof(struct statfs),0))
      return(UNIX_CONVERT_ERRNO(errno));
   fclose(fp);
   if (new_file)
      unlink(filename);
   free_bytes = (double)stat_buf.f_bfree * 512.0;     /* Get number of free bytes */

#elif defined (NT)
   if ((_access(filename, 0) == -1) && (errno == ENOENT)) /* File exists? */
      new_file = 1;
   if (!(fp = (FILE *) fopen(filename, "ab")))  /* Can file be written? */
      return(UNIX_CONVERT_ERRNO(errno));
   if (_getdiskfree(0, &diskinfo))
      return(UNIX_CONVERT_ERRNO(errno));
   fclose(fp);
   if (new_file)
      _unlink(filename);

   free_bytes = diskinfo.bytes_per_sector * diskinfo.sectors_per_cluster *
      diskinfo.avail_clusters;     /* Get number of free bytes */
#else
#error OS does not define access or statfs or unlink
#endif

   if (!bytes_needed)
   {
      /* compute the bytes needed */
      for(i=bytes_needed=0; i<(int)OM_GA_OSDs[osnum]->ClustersSize; i++)
      {
         OM_p_LCD  lcd;
         OM_p_PCD  pcd;

         if(lcd = OM_GA_OSDs[osnum]->Clusters[i])
         {
            if (lcd->flags & OM_FAULTED)
            {
               pcd = (OM_p_PCD) lcd->pcdq_lh.next;
               while (pcd != (OM_p_PCD) &lcd->pcdq_lh.next)
               {
                  /* Add used bytes in this physical cluster
                   * less the header size of each chunk (obj or vla)
                   * plus the file header size of each object
                   */
                  bytes_needed += (pcd->i_totalWsheap - pcd->i_totalfree) -
                     (pcd->i_cur_num_chunks * OM_K_OBJHDRSIZE) +
                     (pcd->i_cur_num_objects * sizeof(OM_S_FILEOBJHDR));
                  pcd = (OM_p_PCD) pcd->pcdq.next;
               }
            }
            else
            {
               struct OMCluster_instance   *p_cluster;

               p_cluster = (struct OMCluster_instance *) ((char *)
                  OM_GA_OSDs[osnum]->Spacemap[lcd->oid].state.object + 8);
               bytes_needed += p_cluster->i_fil_byte_size;
            }
         }
      }
   }

   if (free_bytes > ((int)(2*sizeof(OM_S_OS_FILEHDR)) + bytes_needed))
         return(OM_S_SUCCESS);
   else return(OM_E_NO_DISK_SPACE);
}



/*===========================================================================

   Method:     write

   Arguments:  new_osname
                Optional.  Character string containing the Object Space
		external name/file name.  If not given, the name in the
		OSD (Object Space Descr.) is used.

   Function:   Writes the set of logical clusters making up an object
               space to a disk file.  This method may be invoked by the
               delete method as part of deleting an object space, or it
               may have been invoked to save the current state of the object
               space before continuing.

   Logic:      Make sure object space can be written.  Write a logical
               cluster at a time, holding Cluster 0 til last because it
               contains all of the control information.

=============================================================================*/

%undef write

method OMFiledOS.write(char *new_osname)
{
   OMuint            ii, jj, size, i_sp, i, j, len;
   OMuint            bytes_to_file;    /* Bcnt kept as each clust is written */
   OMuint            clust0_size;      /* Byte size of Cluster 0 */
   OMuint            cluster_offset;
   OMuint            clusterThreshold=0; /* Threshold for re-autoclustering */
   int               sts, loc;
   OM_p_LCD          *clustArr=NULL;   /* OSD's array of LCD pointers */
   OM_p_LCD          lcd;
   struct OMCluster_instance   *p_cluster;
   FILE              *fp;              /* Output file descriptor ptr */
   FILE              *infp;            /* Original file descriptor ptr */
   OM_S_OS_FILEHDR   filehdr;
   OMuword           numClusters=0;    /* Size of OSD's LCD ptr array */
   OMuword           same_osname, all_faulted = 1;
   OMword            *wrtnClusters;    /* Array of LCD's as we write them */
   char              tmp_osname[OM_K_MAXOSNAME_LEN+1],
                     osoTimeDate[16], *filename = NULL;
   OMuint            tag_count;        /* TagCon cleanup variables */
   OMuword           tag_osnum;
   OMuword           tag_flags;
   OM_S_OBJID        tag_oid;
   OM_p_TAG_RECORD   p_tag_rec;
   OM_p_TAGCON_LINK  p_tc_link;
   char              **save_path = NULL;
   char              lockFile[MAXPATHLEN];
   char              err_msg[64];
   char              ch_zero=0;
   OMuint            tot_appl_len, diff;
   time_t            clk;
   OM_p_ORIGOSNAME   p_oname;

#if defined (CLIX)
   struct statl      fbuf;    /* CLIX case only */
#elif defined (SUNOS) || defined (IRIX)
   struct stat       fbuf;    /* Non-CLIX SYSV case or BSD case */
#elif defined (NT)
   struct _stat      fbuf;
#endif

   if (OM_Gf_validate_OS && !(1&som_validate_tag(OM_Gw_current_OS)))
   {
      if (OM_Gf_validate_OS == 1)
      {
         OM_PMS();
      }
      else if (OM_Gf_validate_OS == 3)
      {
         assert(0);
      }
   }

   /*===============================================================*/
   /* Watch out for read-only (don't write) obj spaces and no-write */
   /* (don't modify) obj spaces.  Not our problem.                  */
   /*===============================================================*/
   if ((ME.OMObjSpace->OSD.flags & OM_e_loados_ro) ||
       (ME.OMObjSpace->OSD.flags & OM_OSD_nowrite))
      return(OM_E_BADSTATE);

   /*==================================================================*/
   /* See if caller specified a name for this obj space.  If not, use  */
   /* the name in OSD.  If caller specified a name, but it's the same  */
   /* as our default name, pretend we didn't get a name from caller.   */
   /* If name specified is a new name, save the default one and store  */
   /* the new one in the OSD while we set up to store the obj space.   */
   /* We'll restore the default name later on.                         */
   /*==================================================================*/
   if (new_osname)
   {
      if (!(strcmp(new_osname, ME.OMObjSpace->OSD.name)))
            new_osname = NULL;
      else
      {
         strcpy(tmp_osname,ME.OMObjSpace->OSD.name);
         strcpy(ME.OMObjSpace->OSD.name,new_osname);
      }
   }
   fp = infp = NULL;
   same_osname = 0;
   wrtnClusters = 0;

   /*================================================================*/
   /* Verify there's enough disk space to write the file.            */
   /* (om$enough_disk_space requires we put the new name in the OSD. */
   /* If it returns an error, we must restore the default obj space  */
   /* name in the OSD before exiting.)                               */
   /*================================================================*/
   if (!(1&(sts = om$enough_disk_space(osnum = OM_Gw_current_OS))))
   {
      if (new_osname)
          strcpy(ME.OMObjSpace->OSD.name,tmp_osname);
      return(sts);
   }

   if (new_osname)
      strcpy(ME.OMObjSpace->OSD.name,tmp_osname);
   FIND_ANC_OFFSET(sts, p_ACLD, OM_K_OMCLUSTER_ACTCLASSID, cluster_offset);

   /*===========================================================*/
   /*  If we are not deleting the OS:                           */
   /*  For each IGRdir mounted via this OS - unmount it and     */
   /*  save the pathnames in order to remount the directories   */
   /*  after the save to disk                                   */
   /*===========================================================*/
   i_sp = 0;
#ifndef NT
   if (!(ME.OMObjSpace->OSD.flags & OM_OSD_Rootdel_pending))
   {
      save_path = (char **) om$malloc ( size = sizeof(char *) );
      if (!save_path) return (OM_E_NODYNMEM);
      save_path[i_sp] = om$calloc ( num = 1, size = 128 );
      if (!save_path[i_sp]) return (OM_E_NODYNMEM);   
      while (1)
      {
         sts = di$give_pathname ( osnum = OM_Gw_current_OS,
                                  pathname = save_path[i_sp] );
         if (!(1&sts)) break;
         sts = di$umount ( dirname = save_path[i_sp], sleep = 1, keep = 1 );
         ++i_sp;
         save_path = (char **) om$realloc ( ptr = (char *) save_path, 
                                  size = (i_sp+1)*sizeof(char *));
         if (!save_path) return (OM_E_NODYNMEM);
         save_path[i_sp] = om$calloc ( num = 1, size = 128 );
         if (!save_path[i_sp]) return (OM_E_NODYNMEM);   
      }

      if (! i_sp )
      {
         om$dealloc ( ptr = (char *) save_path[0] );
         om$dealloc ( ptr = (char *) save_path );
      }
   }
#endif
   /*=============================================================*/
   /*  For each TagCon object in this OS - send a prep_write msg  */
   /*  to remove ISO and channel linkage overhead in the disk     */
   /*  file when all info is already stored in the TagCon vla     */
   /*=============================================================*/
   if (OM_GA_p_tagcon) {
      if (p_tc_link = OM_GA_p_tagcon[OM_Gw_current_OS]) {
         while (p_tc_link) {
            sts = om$send ( msg      = message OMTagCon.prep_write(),
                            targetid = p_tc_link->objid );
            if (!(1&sts)) {
               om$report_error(sts=sts);
               printf("OMFiledOS.write:OMTagCon.prep_write failed\n");
               goto remount;
            }
            p_tc_link = p_tc_link->next;
         }
      }

      /*=====================================================================*/
      /*  Check all TagCon objects in other OS's to see if they represent    */
      /*  connections to objects in this OS - if so then send prep_write msg */
      /*=====================================================================*/
      if (OM_GA_tag_oids && !IF_NULL_OBJID(OM_GA_tag_oids[OM_Gw_current_OS])) {
         OMuword ii;
         for (ii=0; ii<OM_Gw_maxOS; ++ii) {
            if (p_tc_link = OM_GA_p_tagcon[ii]) {
               while (p_tc_link) {
                  if (!strncmp(p_tc_link->int_osname, 
                               ME.OMObjSpace->OSD.InternalName,
                               OM_K_MAXINTOSNAME_LEN)) {
                     sts = om$send ( msg      = message OMTagCon.prep_write(),
                                     targetid = p_tc_link->objid,
                                     targetos = ii );
                     if (!(1&sts)) {
                        om$report_error(sts=sts);
                        printf("OMFiledOS.write:OMTagCon.prep_write failed\n");
                        goto remount;
                     }
                     break;
                  }
                  p_tc_link = p_tc_link->next;
               }
            }
         }
      }
   }   

   if (ME.OMObjSpace->OSD.flags & OM_OSD_Rootdel_pending)
   {
      size = om$dimension_of(varray=ME.OMObjSpace->iso_d);

      if (size)
      {
         /*=============================================================*/
         /* Dissolve any ISO connections active (i.e., look at all the  */
         /* other OS's and MARK their iso connections as hanging.  Mark */
         /* ours as well.                                               */
         /*=============================================================*/
         if (!(1&(sts = om$send ( msg = message OMObjSpace.dissolve_ISOs(), 
                                  targetid = my_id ))))
            goto remount;
      }
   }

   clustArr = ME.OMObjSpace->OSD.Clusters;    /* Array of ptrs to lcd's */

   /*========================================================================*/
   /* Open the output file.  If obj space has a new name, create a new file. */
   /* If using default name, open file for write if all clusters have been   */
   /* faulted in (entire file is essentially rewritten); open for update if  */
   /* not all clusters have been faulted in.  In the update case, unfaulted  */
   /* clusters do not have to be rewritten; faulted clusters are written     */
   /* back to their original position unless they have grown.  In that case, */
   /* a hole is left in their original position and they are written else-   */
   /* where where there is room.                                             */
   /*========================================================================*/
   numClusters = ME.OMObjSpace->OSD.ClustersSize;
   for (ii=1, all_faulted=1; ii<numClusters; ii++)
   {
      if (!clustArr[ii])
         continue;
       p_cluster = (struct OMCluster_instance *) ((char *)ME.OMObjSpace->
          OSD.Spacemap[clustArr[ii]->oid].state.object + cluster_offset);
      if (!(clustArr[ii]->flags & OM_FAULTED) &&
          p_cluster->i_fil_byte_size)
      {
         all_faulted = 0;  /* At least 1 logical clust was never faulted */
         break;
      }
   }
   p_oname = OM_Gp_orig_osname;
   while (p_oname)
   {
     if (p_oname->osnum == OM_Gw_current_OS) break;
     p_oname = p_oname->next;
   }
   /* Test if the original name for this obj space was changed, but
      has since been changed back.
    */
   if (p_oname && !strcmp(p_oname->orig_name, ME.OMObjSpace->OSD.name))
      p_oname = NULL;
   
   /*  check if file has been renamed - if so open original file  */

   if (ME.OMObjSpace->TimeDate[0])
   {
      /* We've saved a timestamp, so the object space has been
       * saved at least once.  We need to guarantee that the
       * file has not been overwritten by someone else since we
       * last read from it before we write back to the file.
       */

      if (p_oname)
      {
         /* If input file is different from output file,
          * but everything has been read in, we don't care
          * if it's been overwritten.
          * Otherwise, we must check the timestamp of the file.
          */

         if (!all_faulted)
         {
            filename = p_oname->orig_name;
#if defined (SYSV) || defined (BSD)
            if (!(infp = (FILE *) fopen(filename, "r")))
#elif defined (NT)
            if (!(infp = (FILE *) fopen(filename, "rb")))
#else
#error OS does not define fopen !!
#endif
            {
               sts = UNIX_CONVERT_ERRNO(errno);
               goto remount;
            }
         }
      }
      else
      {
         if (!(new_osname && all_faulted))
         {
            filename = ME.OMObjSpace->OSD.name;
#if defined (SYSV) || defined (BSD)
            if (!(infp = (FILE *) fopen(filename, "r")))
#elif defined (NT)
            if (!(infp = (FILE *) fopen(filename, "rb")))
#else
#error OS does not define fopen !!
#endif
            {
               sts = UNIX_CONVERT_ERRNO(errno);
               goto remount;
            }
         }
      }

      if (infp)
         if (som_cmpFileTimeStamp(infp, 'w', filename,
             ME.OMObjSpace->OSD.Spacemap) != OM_S_SUCCESS)
         {
            /* saw005
             * Comparing the start time stamp in the input file with
             * the timestamp in the oso failed.  The input file is not
             * the same as when we first loaded it, meaning someone
             * else has written to it.  We don't want to overwrite
             * their file, so we error off.
             */
            sts = OM_E_ERROR;
            goto remount;
         }
   }
   if (all_faulted && infp )
      fclose(infp);  /* Don't need to read any clusters in from the file */
   else
   {
#if defined (CLIX)
      if (new_osname && !statl(new_osname, &fbuf))
      {
         ii = fbuf.st_ino;
         if (!statl(filename, &fbuf))    /* Get inode of input file */
#elif defined (SYSV) || defined (BSD)
      if (new_osname && !stat(new_osname, &fbuf))
      {
         ii = fbuf.st_ino;
         if (!stat(filename, &fbuf))    /* Get inode of input file */
#elif defined (NT)
      if (new_osname && !_stat(new_osname, &fbuf))
      {
         ii = fbuf.st_ino;
      if (new_osname && !_stat(new_osname, &fbuf))
#else
#error OS does not define stat !!
#endif
            if (ii == fbuf.st_ino)           /* If our input file is same */
               new_osname = NULL;            /* as our "new" file, clear flag */
      }
   }

   /* Open the output file */

   if (OM_Gf_fileLocking)     /* <Grooooan> */
   {
      /* The osnum field makes unique each attachment of a reference
       * file that is attached multiple times.
       */

      sprintf(OM_Gp_lockFileRec->osnum, "%5d", OM_Gw_current_OS);

      lockFile[0] = 0;
      if (new_osname)
      {
         int                      fnd;
         struct OM_sd_lockFiles   *ptrl, *prev=NULL;

         if (!(1&som_makeLockFile(new_osname, 1, &lockFile[0],
               ME.OMObjSpace->OSD.flags)))
         {
            perror("write: Could not open lock file");
            sts = OM_E_ERROR;
            goto remount;
         }

         ptrl = OM_GA_lockFiles[OM_Gw_current_OS];
         fnd = 0;
         while (ptrl)
         {
            if (!strcmp(ptrl->name, &lockFile[0]))
            {
               fnd = 1;
               break;
            }
            prev = ptrl;
            ptrl = ptrl->next;
         }
         if (!fnd)
         {
            if (prev->next = (struct OM_sd_lockFiles *)
               om$malloc(size = sizeof(struct OM_sd_lockFiles)))
            {
               if (prev->next->name = (char *) om$malloc(size =
                  strlen(&lockFile[0])))
                  strcpy(prev->next->name, &lockFile[0]);
               prev->next->next = NULL;
            }
         }
      }
      else if (p_oname)
      {
         if (!(1&som_makeLockFile(ME.OMObjSpace->OSD.name, 1, &lockFile[0],
               ME.OMObjSpace->OSD.flags)))
         {
            perror("write: Could not open lock file");
            sts = OM_E_ERROR;
            goto remount;
         }
      }
      else
      {
         strcpy(lockFile, OM_GA_lockFiles[OM_Gw_current_OS]->name);
         if (!(som_modifyAccess(lockFile, 'W')))
            goto remount;
      }
   }

   if (new_osname)

#if defined (CLIX)
      fp = (FILE *) fopen(new_osname, "w");
   else if (p_oname)       /* File exists under old name */
      fp = (FILE *) fopen(ME.OMObjSpace->OSD.name, "w");
   else
   {
      if (statl(ME.OMObjSpace->OSD.name, &fbuf) != 0)    /* New os */
         fp = (FILE *) fopen(ME.OMObjSpace->OSD.name, "w");
#elif defined (SYSV) || defined (BSD)
      fp = (FILE *) fopen(new_osname, "w");
   else if (p_oname)       /* File exists under old name */
      fp = (FILE *) fopen(ME.OMObjSpace->OSD.name, "w");
   else
   {
      if (stat(ME.OMObjSpace->OSD.name, &fbuf) != 0)    /* New os */
         fp = (FILE *) fopen(ME.OMObjSpace->OSD.name, "w");
#elif defined (NT)
      fp = (FILE *) fopen(new_osname, "wb");
   else if (p_oname)       /* File exists under old name */
      fp = (FILE *) fopen(ME.OMObjSpace->OSD.name, "wb");
   else
   {
      if (_stat(ME.OMObjSpace->OSD.name, &fbuf) != 0)    /* New os */
         fp = (FILE *) fopen(ME.OMObjSpace->OSD.name, "wb");
#else
#error OS does not define stat !!
#endif
      else
      {      
         /* We're writing back to an existing file.  We're first going
          * to write the entire obj space to a temp file.  If the
          * write is successful, we'll move it over the existing file.
          * If the write fails, we haven't screwed up the old file.
          */

         char  *ptr, tname[OM_K_MAXOSNAME_LEN+1];

         same_osname = 1;
         strcpy(tname, ME.OMObjSpace->OSD.name);
#ifndef NT
         if (ptr = strrchr(tname, '/'))
#else
         if (ptr = strrchr(tname, '\\'))
#endif
            ptr++;
         else ptr = tname;
         if (strlen(ptr) >= (MAXFILENAMELEN - 5))
            ptr[MAXFILENAMELEN-6] = '\0';
         ptr = tmp_osname + (strlen(tmp_osname) - 1);
#ifndef NT
         while (!access(tmp_osname, 0))
#else
         while (!_access(tmp_osname, 0))
#endif
         {
            (*ptr)++;
         }
         sprintf(tmp_osname, "%s%05d", tname, OM_Gi_pid);

#if defined (SYSV) || defined (BSD)
         fp = (FILE *) fopen(tmp_osname, "w");
#elif defined (NT)
         fp = (FILE *) fopen(tmp_osname, "wb");
#else
#error OS does not define open !!
#endif
      }
   }
   if (!fp)
   {
      sts = UNIX_CONVERT_ERRNO(errno);
      goto remount;
   }

   /*==================================================*/
   /*  prewrite the OS header with starting time stamp */
   /*==================================================*/
   clk = time(0);
   strcpy(filehdr.start_time, (char *) ctime(&clk));
   filehdr.magic = OM_K_MAGIC;
   filehdr.w_major_version = 0;
   filehdr.w_minor_version = 0;
   filehdr.dros_msgstr[0] = 0;
   filehdr.i_size = 0;

#if defined (SYSV)
   strcpy(filehdr.syst.mach_name.sysname, OM_Gp_SYSINFO->sysname);
#elif defined (SUNOS)
   strcpy(filehdr.syst.mach_name.sysname, "CLIX/Sun");
#elif defined (NT)
   strcpy(filehdr.syst.mach_name.sysname, "CLIX/NT");
#else
#error Need O.S. name in file header!!
#endif
   strncpy(filehdr.syst.mach_name.nodename, OM_Gp_SYSINFO->nodename, 8);
   filehdr.syst.mach_name.nodename[8] = '\0'; 
   strcpy(filehdr.syst.mach_name.release, OM_Gp_SYSINFO->release);
   strcpy(filehdr.syst.mach_name.version, OM_Gp_SYSINFO->version);
   strcpy(filehdr.syst.mach_name.machine, OM_Gp_SYSINFO->processor);

   strcpy(filehdr.image_name, EX_runname);

   /* Porting note:  We don't need to port the initial file header
    * because is it all character strings so far (except for the
    * magic number).  If in the future we store any binary values
    * in the initial file header, we'll need to convert the header,
    * write it, then put them in the header a second time, so
    * they will be in the correct format for the second conversion
    * and write (after all the clusters are written).
    */

   fseek (fp, 0, 0);
   if((i= fwrite(&filehdr, sizeof(OM_S_OS_FILEHDR), 1, fp)) != 1) {
      sts = OM_E_WRITE_ERROR;
      sprintf(err_msg,"Error writing OS header 1");
      fprintf( stderr,"OMFiledOS Error writing OS header 1");
      goto err_exit;
   }
  
   /*============================================================
    *  write all known application version stamps to the OS
    *  Porting note: char strings do not have to be converted
    *  between Clix & SunOS - they are the same on both systems.
    *============================================================
    */
   OM_Gi_checksum = 0;
   if ( OM_Gi_number_of_appl_ids )
      filehdr.fp_appver = sizeof(OM_S_OS_FILEHDR);
   else
      filehdr.fp_appver = 0;

   filehdr.i_num_appver = 0;
   tot_appl_len = 0;

   loc = filehdr.fp_appver;
   for (i=sts=0; (i<MAXNUMAPPVER) && (sts<OM_Gi_number_of_appl_ids); ++i)
   {
      /* 'i' is the array index.  'sts' is count of used entries
       * found.  There may be nulled out entries, which aren't
       * counted in 'sts'.  Bad name for a counter, I know.
       */

      if (!OM_GA_appl_version[i])
         continue;
      sts++;
      len = strlen(OM_GA_appl_version[i]->curr_version);
      if ((!len) || (len >= OM_K_APPVER_LEN) ||
          ((tot_appl_len + len) >= sizeof(OM_S_OS_FILEHDR)))
         continue;
      for (jj=0; jj<(len+1); jj++, loc++)
         OM_Gi_checksum += (unsigned char)
            OM_GA_appl_version[i]->curr_version[jj] + loc;
      if((fwrite(OM_GA_appl_version[i]->curr_version,len+1,1,fp)) != 1)
      {
         sts = OM_E_WRITE_ERROR;
         sprintf(err_msg,"Error writing application version");
         fprintf( stderr,"OMFiledOS Error writing application version");
         goto err_exit;
      }
      for (j=len+1; j<OM_K_APPVER_LEN; ++j) 
      {
         fwrite(&ch_zero,1,1,fp);  /* pad to appl version len */
         OM_Gi_checksum += loc++;
      }
      ++filehdr.i_num_appver;
      tot_appl_len += OM_K_APPVER_LEN;
   }

   /*  pad appl version stamps to an even block boundary  */

   if ( OM_Gi_number_of_appl_ids ) {
      diff =  OM_K_APPVER_BOUND - (tot_appl_len % OM_K_APPVER_BOUND);
      for (j=0; j<diff; ++j)
      {
         fwrite(&ch_zero,1,1,fp);
         OM_Gi_checksum += loc++;
      }
      tot_appl_len += diff;
   }

   /*===================================================================*/
   /* If iso directory(s) exists, set iso header flag of each iso to a  */
   /* transient object space.  Fixup_for_write loops through iso_d vla. */
   /*===================================================================*/
   if (om$dimension_of(varray=ME.OMObjSpace->iso_d))
   {
      if (!(1&(sts = om$send(msg = message OMObjSpace.fixup_for_write(),
			     targetid = my_id ))))
      {
         sprintf(err_msg,"Error from OMObjSpace.fixup_for_write %x",sts);
         fprintf( stderr,"OMFiledOS Error from OMObjSpace.fixup_for_write %x",sts);
         goto err_exit;
      }
   }

   /*================================================================*/
   /* Initialize hole list.  File will always have an obj space file */
   /* header, so first hole will point past that.                    */
   /*================================================================*/
   sts = om$vla_set_dimension(varray=ME.OMObjSpace->OS_holes,
                        size=numClusters/2+3);
   if (!(1&sts))
   {
      sprintf(err_msg,"Error from set_dimension for OS holes 1 %x",sts);
      fprintf( stderr,"OMFiledOS Error from set_dimension for OS holes 1 %x",sts);
      goto err_exit;
   }
   ME.OMObjSpace->OS_holes[0].FilePtr = (OMuint) ftell(fp);
   ME.OMObjSpace->OS_holes[0].size = (OMuint) -1;

   /*==================================================================*/
   /* Select best clusters to write out first (those entirely resident */
   /* in memory) and issue an ordered send to to them to write them-   */
   /* selves out.  Select the next-best set, those entirely resident,  */
   /* but not locked and write them out.  Write out the remaining      */
   /* guys (those that were out-swapped).  This ordering should save   */
   /* some i/o time (e.g., swapping a guy out so we can swap in a guy  */
   /* to write out).                                                   */
   /* Lastly, write Cluster 0 and the file header.                     */
   /*                                                                  */
   /* Note: Each cluster has an associated list of oids and list of    */
   /* filed classids in Cluster 0.  When a filed object space is       */
   /* loaded, each cluster's list of filed classids is used to set up  */
   /* the object space and the deleted (to save memory).  The list of  */
   /* oids is kept until the cluster is faulted into memory; it's      */
   /* used to update the space map and then deleted.                   */
   /*==================================================================*/
   wrtnClusters = (OMword *) om$malloc(size = sizeof(OMword) * numClusters);
   wrtnClusters[0] = 0;		   /* Clust 0 will not have any swapped guys */
   bytes_to_file = 0;              /* Cumulative sum of bytes written to file */
   filehdr.i_num_objs = 0;         /* Number of objects written to the file */
   clusterThreshold = 0;           /* Re-autoclustering threshold */
   filehdr.w_num_clusters = 0;

   for (ii=1; ii<numClusters; ii++)
   {
      if (!(lcd = clustArr[ii]))
         continue;                  /* skip holes in clustcmp array */

      if (all_faulted) lcd->i_file_ptr = 0;
 
      wrtnClusters[ii] = 0;
      if (!(lcd->flags & OM_FAULTED))
      {
         /*=============================================================*/
         /* This cluster was never faulted in.  Its list of oids still  */
         /* remains in Cluster 0, but we'll have to rebuild its list of */
         /* filed classids.                                             */
         /*=============================================================*/

         if (!(1&(sts=om$send(msg=message OMCluster.clwrite((int) fp,
               (OM_S_OSHOLE *)ME.OMObjSpace->OS_holes, (OM_p_CSD) NULL,
               &bytes_to_file), targetid=clustArr[ii]->oid))))
         {
            sprintf(err_msg,"Error from OMCluster.clwrite %x",sts);
            fprintf( stderr,"OMFiledOS Error from OMCluster.clwrite %x",sts);
            goto err_exit;
         }
         wrtnClusters[ii] = -1;

         /*=======================================================*/
         /* Copy cluster from old file to new.  No data structure */
         /* updates required.                                     */
         /*=======================================================*/

         p_cluster = (struct OMCluster_instance *) ((char *)ME.OMObjSpace->
            OSD.Spacemap[lcd->oid].state.object + cluster_offset);
         lcd->i_cur_bytes_allocated = 0;
         if (!(1&(sts = som_copy_filed_cluster(infp, fp, lcd, p_cluster,
                                                  ME.OMObjSpace->OS_holes ))))
         {
            sprintf(err_msg,"Error from som_copy_filed_cluster %x",sts);
            fprintf( stderr,"OMFiledOS Error from som_copy_filed_cluster %x",sts);
            goto err_exit;
         }
         filehdr.w_num_clusters++;     /* Count of clusters written */
         filehdr.i_num_objs += p_cluster->i_fil_num_objects;
      }
      else
      {
         /*================================================================*/
         /* This cluster has previously been faulted in.  Search its pcd   */
         /* list for swapped or paged pcd's.  If all are locked pcd's and  */
         /* none are out-swapped, we'll write this guy immediately.  If    */
         /* any pcd's are swapped, we keep a count of how many.            */
         /* (Currently, we don't do anything with the count.  May help     */
         /* with some future optimization, who knows.)                     */
         /*================================================================*/

         if (!(lcd->flags & OM_USERSPEC))
            clusterThreshold++;        /* Count the auto-clusters */
         lcd->i_file_ptr = 0;

         wrtnClusters[ii] = -1;

         p_cluster = (struct OMCluster_instance *) ((char *)ME.OMObjSpace->
            OSD.Spacemap[lcd->oid].state.object + cluster_offset);
         if (!(1&(sts=om$send(msg=message OMCluster.clwrite((int) fp,
                                 (OM_S_OSHOLE *) ME.OMObjSpace->OS_holes,
                                 (OM_p_CSD) NULL, &bytes_to_file),
                                 targetid=lcd->oid))))
         {
            sprintf(err_msg,"Error from OMCluster.clwrite 2 %x",sts);
            fprintf( stderr,"OMFiledOS Error from OMCluster.clwrite 2 %x",sts);
            goto err_exit;
         }
         filehdr.w_num_clusters++;     /* Count of clusters written */
         filehdr.i_num_objs += p_cluster->i_fil_num_objects;
      }
   }
   if (!all_faulted && infp)
      sts = fclose(infp);  /* We're done with non_faulted clusters */

   /*===========================*/
   /* Finally, write cluster 0. */
   /*===========================*/
   clustArr[0]->i_file_ptr = 0;
   clust0_size = 0;
   strncpy(osoTimeDate, ME.OMObjSpace->TimeDate, 15);
   osoTimeDate[15] = 0;
   strncpy(ME.OMObjSpace->TimeDate, &filehdr.start_time[4], 15);
   ME.OMObjSpace->TimeDate[15] = 0;
   if (!(1&(sts=(int)om$send(msg=message OMCluster.clwrite((int) fp,
                            (OM_S_OSHOLE *) ME.OMObjSpace->OS_holes,
                            (OM_p_CSD) NULL, &clust0_size),
                        targetid=clustArr[0]->oid))))
   {
      sprintf(err_msg,"Error from OMCluster.clwrite 5 %x",sts);
      fprintf( stderr,"OMFiledOS Error from OMCluster.clwrite 5 %x",sts);
      strcpy(ME.OMObjSpace->TimeDate, osoTimeDate); /* Restore timestamp */
      goto err_exit;
   }
   if (!same_osname)
      strncpy(ME.OMObjSpace->TimeDate, osoTimeDate, 15); /* Restore timestamp */
   p_cluster = (struct OMCluster_instance *) ((char *)ME.OMObjSpace->
      OSD.Spacemap[0].state.object + cluster_offset);
   filehdr.w_num_clusters++;     /* Count of clusters written */
   filehdr.i_num_objs += p_cluster->i_fil_num_objects;

   /* It may come in handy sometime to know if someone's using
    * file locking, and if so, at what level.
    */

   filehdr.unused[0] = (char) OM_Gf_fileLocking;

   /*=====================================================================*/
   /* Set up file header.  This will contain system-specific information, */
   /* data describing the object space, and pointers to the file posi-    */
   /* tions of Cluster 0, the LCD's and the OSO.                          */
   /*=====================================================================*/

   filehdr.i_size = sizeof(OM_S_OS_FILEHDR) + tot_appl_len;

   for (ii=0; ME.OMObjSpace->OS_holes[ii].size != (OMuint) -1; ii++)
      filehdr.i_size += ME.OMObjSpace->OS_holes[ii].size;

   /*=====================================================================*/
   /* Need to restore some Cluster 0 data structures IF we just wrote to  */
   /* a new file and there were still some unfaulted clusters at the time */
   /* of the write.  Restore file ptrs for unfaulted clusters that were   */
   /* possibly altered during som_copy_filed_cluster when creating a new  */
   /* file.                                                               */
   /*=====================================================================*/
   if (!all_faulted && (new_osname || p_oname))
   {
      for (ii=1; ii<numClusters; ii++)
      {
         if (lcd=clustArr[ii])
         {
            p_cluster = (struct OMCluster_instance *) ((char *) ME.OMObjSpace->
               OSD.Spacemap[lcd->oid].state.object + cluster_offset);

            if (!(lcd->flags & OM_FAULTED) && lcd->i_cur_bytes_allocated)
               lcd->i_file_ptr = lcd->i_cur_bytes_allocated;
         }
      }
/*
      p_cluster = (struct OMCluster_instance *) ((char *) ME.OMObjSpace->
         OSD.Spacemap[clustArr[0]->oid].state.object + cluster_offset);
      filehdr.i_num_objs += p_cluster->i_fil_num_objects;
*/
   }

   /*===================================================================*/
   /* Compute size of file to store in file header.  Size includes size */
   /* of file header + size of file holes + size of each cluster.  Size */
   /* of a cluster is number of bytes allocated less bytes making up    */
   /* chunk headers.                                                    */
   /*===================================================================*/
   filehdr.i_size += clust0_size + bytes_to_file;
   filehdr.fp_cluster0 = clustArr[0]->i_file_ptr;

   /*===================================================================*/
   /* Store the Object Space classname.  Since it may be subclassed, it */
   /* isn't guaranteed to be OMFiledOS.                                 */
   /*===================================================================*/
   if (!(1&(sts = om$get_classname(object=(OM_p_OBJECTHDR) me,
                                   classname=filehdr.s_OSO_classname))))
      goto remount;

   filehdr.w_major_version = OM_Gw_major_version;
   filehdr.w_minor_version = OM_Gw_minor_version;
   filehdr.fp_OSO = ME.OMCluster->i_my_file_ptr;
   filehdr.fp_OSO_instance = ME.OMCluster->i_my_file_ptr +
      (int) (((char *) ME.OMObjSpace - (char *) me) + 8);
   filehdr.fp_Cluster_instance = ME.OMCluster->i_my_file_ptr +
      (int) (((char *) ME.OMCluster  - (char *) me) + 8);
   filehdr.i_spacemap_size = ME.OMObjSpace->OSD.CurSpaceMapSize;
   filehdr.S_OS_object = ME.OMObjSpace->OSD.OSO_Oid;
   if (ME.OMObjSpace->OSD.Spacemap[filehdr.S_OS_object].flags &
       OM_SM_unknown_obj)
      filehdr.OSOfiledClassid =
         (OMuword) ME.OMObjSpace->OSD.Spacemap[filehdr.S_OS_object].p_acld;
   else
      filehdr.OSOfiledClassid = OM_GA_active_to_filed[
         ME.OMObjSpace->OSD.Spacemap[filehdr.S_OS_object].p_acld->w_classid];
   filehdr.os_flags = OM_GA_OSflags[OM_Gw_current_OS];

   sprintf(err_msg,"Successful write");
   sts = OM_S_SUCCESS;

err_exit:

   /*  ADD stop time stamp to header  */
   clk = time(0);
   strcpy(filehdr.stop_time, (char *) ctime(&clk));
   strcpy(filehdr.write_msgstr,err_msg);

   /*====================================*/
   /* Write header at beginning of file. */
   /*====================================*/
   {
      unsigned char  *ptr;

      filehdr.checksum = OM_Gi_checksum;     /* Store main checksum */
      filehdr.hdr_checksum = 0;              /* Dummy header checksum */
      OM_Gi_checksum = 0;
      fseek(fp, 0, 0);
      ptr = (unsigned char *) &filehdr.magic;
      for (ii=0; ii<434; ii++, ptr++)
         OM_Gi_checksum += ii + *ptr;
      filehdr.hdr_checksum = OM_Gi_checksum;

#ifdef BIG_ENDIAN
      filehdr.magic = OM_K_MAGIC;
      som_bigend_portHdr(&filehdr);
#endif

      if ((i = fwrite(&filehdr,sizeof(OM_S_OS_FILEHDR),1,fp)) != 1)
      {
         sts = OM_E_WRITE_ERROR;
         goto remount;
      }
   }
/***** 
	The following line of code has been added as per recommendations of
	SunSoft      -Mohan
********/

#ifdef X11
   fflush(fp);
   if( fsync((int)fp->_file) ) fprintf( stderr, "Problem writing the file out to disk\n");
#endif

   if (fclose(fp))
   {
      sts = OM_E_IOERR;
      goto remount;
   }

   /*  check for error exit  */

   if (!(1&sts))
   {
      if (same_osname && tmp_osname[0] && (sts == OM_E_NO_DISK_SPACE))
#if defined (SYSV) || defined (BSD)
         unlink(tmp_osname);
/* UNRESOLVED
#elif defined (NT)
         DeleteFile(tmp_osname);	 
#else
#error OS does not define unlink
*/
#endif
      goto remount;
   }

   /*======================================================*/
   /* If not deleting OS then reconnect all TagCon entries */
   /* and collapse the 2 vla's in each cluster object.     */
   /*======================================================*/
   if (!(ME.OMObjSpace->OSD.flags & OM_OSD_Rootdel_pending))
   {
      if ( OM_GA_p_tagcon ) {
         p_tc_link = OM_GA_p_tagcon[OM_Gw_current_OS];
         while (p_tc_link) {
            sts = om$os_internal_name_to_number ( osname=p_tc_link->int_osname,
                                                  p_osnum = &tag_osnum );
            if (1&sts) {
               if (OM_GA_tag_oids && !IF_NULL_OBJID(tag_oid = OM_GA_tag_oids[tag_osnum])) {
                  sts = om$send ( msg = message OMTag.get_record_vla
                                    (&p_tag_rec, &tag_count, &tag_flags),
                                  targetid = tag_oid,
                                  targetos = tag_osnum );
                  sts = om$send ( msg = message OMTagCon.reconnect
                                    (p_tag_rec, tag_count, tag_flags),
                                  targetid = p_tc_link->objid );
               }
            }
            p_tc_link = p_tc_link->next;
         }

         /*===================================*/
         /*  Now check TagCons in other OS's  */
         /*===================================*/

         if (OM_GA_tag_oids && !IF_NULL_OBJID(tag_oid = OM_GA_tag_oids[OM_Gw_current_OS])) {
            OMuword ii;
            sts = om$send ( msg = message OMTag.get_record_vla
                                (&p_tag_rec, &tag_count, &tag_flags),
                            targetid = tag_oid );

            for (ii=0; ii<OM_Gw_maxOS; ++ii) {
               if (p_tc_link = OM_GA_p_tagcon[ii]) {
                  while (p_tc_link) {
                     if (!strncmp(p_tc_link->int_osname, 
                                  ME.OMObjSpace->OSD.InternalName,
                                  OM_K_MAXINTOSNAME_LEN)) {

                        sts = om$send ( msg = message OMTagCon.reconnect
                                          (p_tag_rec, tag_count, tag_flags),
                                        targetid = p_tc_link->objid,
                                        targetos = ii );
                     }
                     p_tc_link = p_tc_link->next;
                  }
               }
            }
         }
      }

      for (ii=0; ii<numClusters; ii++)    /* Re-collapse cluster obj arrays */
      {
         if (clustArr[ii] && (clustArr[ii]->flags & OM_FAULTED) &&
             clustArr[ii]->i_cur_bytes_allocated)
         {
            p_cluster = (struct OMCluster_instance *) ((char *) ME.OMObjSpace->
               OSD.Spacemap[clustArr[ii]->oid].state.object + cluster_offset);
            sts = som_vla_set_dimension((int *) &(p_cluster->
               w_filed_classid_list_descr.i_offset), (unsigned int *) &(p_cluster->
               w_filed_classid_list_descr.i_count), 0, OM_Gw_current_OS,
               clustArr[ii]->oid, ME.OMObjSpace->OSD.Spacemap[clustArr[ii]->
                  oid].p_acld, 0);
            sts = som_vla_set_dimension((int *) &(p_cluster->
               i_filed_oid_list_descr.i_offset), &(p_cluster->
               i_filed_oid_list_descr.i_count), 0, OM_Gw_current_OS,
               clustArr[ii]->oid, ME.OMObjSpace->OSD.Spacemap[clustArr[ii]->
               oid].p_acld, 0);
         }
      }
   }

   sts = OM_S_SUCCESS;

   if (same_osname)
   {
      if (OM_Gf_checksum_OS)
      {
#if defined (SYSV) || defined (BSD)
         if (!(fp = (FILE *) fopen(tmp_osname, "r")))
#elif defined (NT)
         if (!(fp = (FILE *) fopen(tmp_osname, "rb")))
#else
#error OS does not define fopen
#endif
         {
            sts = UNIX_CONVERT_ERRNO(errno);
            goto remount;
         }
         if (!som_verify_checksum(fp))
         {
            printf("OMFiledOS: Checksum failed on temp file <%s>.  Re-try the save.\n", tmp_osname);
            sts = OM_E_ERROR;
            goto remount;
         }
      }     /* if (OM_Gf_checksum_OS)

      /* Move temporary file over original file.  Retain ownership
       * and access mode of original file.
       */

#ifndef NT

#if defined (CLIX)
      if (statl(tmp_osname, &fbuf) == 0)
      {
         if (fbuf.st_size > 0)
         {
            if (statl(ME.OMObjSpace->OSD.name, &fbuf) == 0)
            {
               if (-1 == chmod(tmp_osname, (int) fbuf.st_mode))

#elif defined (SYSV) || defined (BSD)
      if (stat(tmp_osname, &fbuf) == 0)
      {
         if (fbuf.st_size > 0)
         {
            if (stat(ME.OMObjSpace->OSD.name, &fbuf) == 0)
            {
               if (-1 == chmod(tmp_osname, (int) fbuf.st_mode))

#else
#error OS does not define stat or chmod
#endif

               {
                  perror("OMFiledOS.write: chmod of tmp_osname failed");
               }
#ifdef SUNOS
               if (!pathconf(tmp_osname, _PC_CHOWN_RESTRICTED))
               {
                  /* If the POSIX restriction on chown is in effect, we
                     won't be able to chown for files that aren't ours.
                  */
#endif

                  if (-1 == chown(tmp_osname, fbuf.st_uid, fbuf.st_gid))
                  {
                     perror("OMFiledOS.write: chown of tmp_osname failed");
                  }

#ifdef SUNOS
               }
#endif
            }

#if defined (SYSV) || defined (BSD)
            unlink(ME.OMObjSpace->OSD.name);
            link(tmp_osname, ME.OMObjSpace->OSD.name);
            unlink(tmp_osname);
#else
#error !! link or unlink not defined in o.s. !!
#endif

            om$dealloc(ptr=(char *) wrtnClusters);
         }
         else
         {
            printf("write: save error, <%s> has size <%d>\n",
               tmp_osname, fbuf.st_size);
         }
      }
      else
      {
         printf("write: stat call failed for <%s>\n", tmp_osname);
      }
#else
      {
/*
         struct _SECURITY_DESCRIPTOR   descr;
         DWORD                         len;

         if (!GetFileSecurity(ME.OMObjSpace->OSD.name, (SECURITY_INFORMATION)
            (OWNER_SECURITY_INFORMATION | GROUP_SECURITY_INFORMATION |
            DACL_SECURITY_INFORMATION | SACL_SECURITY_INFORMATION), &descr,
            sizeof(struct _SECURITY_DESCRIPTOR), &len))
            perror("GetFileSecurity");
*/

/* UNRESOLVED
         if (!MoveFile(tmp_osname, ME.OMObjSpace->OSD.name))
         {
            perror("MoveFile");
         }
*/
        if ( (remove(ME.OMObjSpace->OSD.name)) != 0 )
		{
			return(UNIX_CONVERT_ERRNO(errno));
		}
		if ( (rename (tmp_osname, ME.OMObjSpace->OSD.name)) != 0 )
		{
		    return(UNIX_CONVERT_ERRNO(errno));
	    }
/*
         if (!SetFileSecurity(ME.OMObjSpace->OSD.name, (SECURITY_INFORMATION)
            (OWNER_SECURITY_INFORMATION | GROUP_SECURITY_INFORMATION |
            DACL_SECURITY_INFORMATION | SACL_SECURITY_INFORMATION), &descr))
            perror("SetFileSecurity");
*/
      }
#endif
   }
   else if (new_osname)
   {
      if (OM_Gf_checksum_OS)
      {
#ifndef NT
         fp = (FILE *) fopen(new_osname, "r");
#else
         fp = (FILE *) fopen(new_osname, "rb");
#endif
         if (!som_verify_checksum(fp))
         {
            printf("write: Checksum failed on new file.  Re-try the save.\n");
            sts = OM_E_ERROR;
/*            goto remount; */
         }
      }
   }
   else
   {
      if (OM_Gf_checksum_OS)
      {
#ifndef NT
         fp = (FILE *) fopen(ME.OMObjSpace->OSD.name, "r");
#else
         fp = (FILE *) fopen(ME.OMObjSpace->OSD.name, "rb");
#endif
         if (!som_verify_checksum(fp))
         {
            printf("write: Checksum failed on new file.  Re-try the save.\n");
            sts = OM_E_ERROR;
/*            goto remount; */
         }
      }
   }

   /*============================================================*/
   /*  if there were any IGRdir objects associated with this OS  */
   /*  then loop thru the saved data structure and remount them  */
   /*============================================================*/

remount:
   if ( i_sp )
   {
      int   di_sts;
      if (save_path[i_sp])
         om$dealloc ( ptr = (char *) save_path[i_sp] );
      for ( ; i_sp > 0; --i_sp )
      {
         di_sts = di$mount (logical = save_path[i_sp-1], osnum =OM_Gw_current_OS);
         if (!(1&di_sts))
            fprintf(stderr,"Could not mount directory %s\n",save_path[i_sp-1]);
         om$dealloc ( ptr = (char *) save_path[i_sp-1] );
      }
      om$dealloc ( ptr = (char *) save_path );
   }

   if (wrtnClusters && !(1&sts))
   {
      /*===================================================================*/
      /* The error occurred during or after the cluster-writing process.   */
      /* If we have copied any clusters from the old file to the new, and  */
      /* we have not reset the copied clusters' file pointers to reflect   */
      /* their position in the old file (they now point to their position  */
      /* in the new file), then we need to reset those file pointers.      */
      /*===================================================================*/
      for (ii=1; ii<numClusters; ii++)
      {
         if( !(lcd = clustArr[ii]))
            continue;                  /* Skip holes in clustcmp array */

         if (!(lcd->flags & OM_FAULTED) && (wrtnClusters[ii] == -1))
         {
            /*===========================================================*/
            /* This cluster's file pointer may have to be fixed.  It is  */
            /* unfaulted, so for it to be written to the new file, it    */
            /* would have to be processed by som_copy_filed_clusters,    */
            /* which would have changed its file pointer to show its     */
            /* position in the new file.  Since wrtnClusters is -1 for   */
            /* this cluster, then the error occurred during or after the */
            /* "write" for this cluster.  See if it's file pointer has   */
            /* been changed, and if so, set it back.                     */
            /*===========================================================*/
            if (lcd->i_cur_bytes_allocated)
               lcd->i_file_ptr = lcd->i_cur_bytes_allocated;
         }
      }
      om$dealloc(ptr=(char *) wrtnClusters);
   }

#ifndef NT
   if ((1 & sts) && OM_Gf_autoRecluster && (all_faulted || new_osname) &&
       (clusterThreshold = (clusterThreshold * OM_Gi_ARTpercentClusters)/100))
   {
      int   count, recluster;

      /*============================================================*/
      /* We'll re-autocluster the object space we just wrote if the */
      /* threshold of allowed fragmentation has been crossed.       */
      /*============================================================*/
      for (ii=1, count=0, recluster=0; ii<numClusters; ii++)
      {
         if ((lcd=clustArr[ii]) && (lcd->flags & OM_FAULTED) &&
             !(lcd->flags & OM_USERSPEC))
         {
            p_cluster = (struct OMCluster_instance *) ((char *) ME.OMObjSpace->
               OSD.Spacemap[clustArr[ii]->oid].state.object + cluster_offset);
            if ((count += som_calcClusterFrag(p_cluster)) > (int) clusterThreshold)
            {
               recluster = 1;    /* The count of fragmented clusters */
               break;            /* exceeded the threshold           */
            }
         }
      }
      if (recluster)
      {
         int            cpid, execSts, status, cpid2=0;
         char           tmpName[OM_K_MAXOSNAME_LEN+1], path[MAXPATHLEN],
                        *osName, *ptr, *alist[6];
#if defined (SYSV) || defined (BSD)
         struct statfs  stat_buf;
#elif defined (NT)
         struct _diskfree_t   diskinfo;
#else
#error OS does not define statfs
#endif

         execSts = 0;
         /* Build the temp file name and the argument list */

         if (new_osname)
            osName = new_osname;
         else
            osName = ME.OMObjSpace->OSD.name;

         /*=================================================*/
         /* Make sure there's enough disk space to write a  */
         /* temporary copy of the reclustered object space. */
         /*=================================================*/
#if defined (SYSV) || defined (BSD)
#ifdef BIG_ENDIAN
         som_swapint(&filehdr.i_size, &cpid);
#endif

         if(status = statfs(osName, &stat_buf, sizeof(struct statfs),0))
         {
            printf("OMFiledOS.write: Could not recluster file <%s>, error: %d\n",
               osName, errno);
         }
#ifdef BIG_ENDIAN
         else if (((double)stat_buf.f_bfree * 512.0) < cpid) /* i_size field is swapped */
#else
         else if (((double)stat_buf.f_bfree * 512.0) < filehdr.i_size)
#endif
#elif defined (NT)
         if (_getdiskfree(0, &diskinfo))
            return(UNIX_CONVERT_ERRNO(errno));

         if ((diskinfo.bytes_per_sector * diskinfo.sectors_per_cluster *
            diskinfo.avail_clusters) < filehdr.i_size)
#else
#error OS does not define statfs
#endif
         {
            printf("OMFiledOS.write: Not enough disk space to recluster file <%s>\n",
               osName);
         }
         else
         {
            char  arg1[10], arg2[OM_K_MAXOSNAME_LEN+1], arg3[OM_K_MAXOSNAME_LEN+1];

            strcpy(tmpName, osName);
#ifndef NT
            if (ptr = strrchr(tmpName, '/'))
#else
            if (ptr = strrchr(tmpName, '\\'))
#endif
               ptr++;
            else ptr = tmpName;
            if (strlen(ptr) >= (MAXFILENAMELEN-5))
               ptr[MAXFILENAMELEN-6] = '\0';
            sprintf(tmp_osname, "%s%05d", tmpName, OM_Gi_pid);
            ptr = tmp_osname + (strlen(tmp_osname) - 1);
#ifndef NT
            while (!access(tmp_osname, 0))
#else
            while (!_access(tmp_osname, 0))
#endif
            {
               (*ptr)++;
               if (*ptr > 0x7e)
                  goto err2;
            }

            sprintf(arg1, "-p%d", OM_Gi_phyClusterSize);
            sprintf(arg2, "-f%s", osName);
            sprintf(arg3, "-o%s", tmp_osname);
            alist[1] = arg1;
            alist[2] = arg2;
            alist[3] = arg3;
            alist[4] = "-C";
            alist[5] = 0;

            /*======================================================*/
            /* Find the autorecluster image so we can exec it.  The */
            /* last entry in the sysgenPath is the exnuc config     */
            /* directory.  We extract it and replace 'config' with  */
            /* 'bin', then append 'autorecluster' to the end.       */
            /*======================================================*/
            path[0] = '\0';
            if (ptr = OM_Gp_sysgenPath)
            {
               char  *p1;
               while ((*ptr != '\0') && (p1 = strchr(ptr, ':')))
               {
                  if (((int) (p1-ptr) > 8) && !strncmp("config/", (p1-7), 7))
                  {
                     strncpy(path, ptr, (p1 - ptr - 7));
                     path[p1 - ptr - 7] = '\0';
                     strcat(path, "bin/autorecluster");
#if defined (SYSV) || defined (BSD)
                     if (!access(path, 01))
#elif defined NT
                     if (!_access(path, 01))
#else
#error !! access not defined in o.s. !!)
#endif
                        break;
                  }
                  ptr = p1 + 1;
               }
            }
            if (path[0] == '\0')
               strcpy(path, "autorecluster");
            alist[0] = path;

            /* Fork and exec autorecluster */

#if defined (IRIX)
            if (0 == (cpid = fork()))
#elif defined (CLIX) || defined (SUNOS)
            if (0 == (cpid = vfork()))
#else
#warning Did not handle fork/vfork !!
#endif
            {
#if defined (SYSV) || defined (BSD)
               if ((status = execv(path, alist)) == -1)
#else
#error !! execv not defined in o.s. !!)
#endif
               {
                  printf("OMFiledOS.write: execv(%s) failed\n", path);
                  perror("");
                  _exit(errno);
               }
            }
            if (cpid == -1)
#if defined (IRIX)
               perror("OMFiledOS.write: fork to recluster failed");
#elif defined (CLIX) || defined (SUNOS)
               perror("OMFiledOS.write: vfork to recluster failed");
#else
#warning Did not handle fork/vfork !!
;
#endif
            else if (cpid)
            {
               while (cpid != cpid2)
               {
                  cpid2 = wait(&execSts);
                  if ((cpid2 == -1) && (errno != EINTR))
                  {
                     perror("OMFiledOS.write: File was written, but autorecluster failed");
                     break;
                  }
               }
               if (cpid == cpid2)
               {
                  if (execSts)
                  {
                     if (!(char)execSts)
                        /* autorecluster itself returned bad status */
                        printf("OMFiledOS.write: File was written, but autorecluster failed.\n");
                     else if ((char)execSts == 0177)
                        /* autorecluster stopped by a signal */
                        printf("OMFiledOS.write: File was written, but autorecluster was stopped by signal %d\n", (OMuword) (execSts >> 8));
                     else
                        /* autorecluster terminated by a signal */
                        printf("OMFiledOS.write: File was written, but autorecluster terminated by signal %d\n", (char) execSts);
                  }
                  else
                  {

#if defined (CLIX)
                     if (statl(tmp_osname, &fbuf) == 0)
#elif defined (SYSV) || defined (BSD)
                     if (stat(tmp_osname, &fbuf) == 0)
#else
#error !! stat not defined in o.s. !!
#endif
                     {
                        if (fbuf.st_size > 0)
                        {
#if defined (CLIX)
                           if (statl(ME.OMObjSpace->OSD.name, &fbuf) == 0)
#elif defined (SYSV) || defined (BSD)
                           if (stat(ME.OMObjSpace->OSD.name, &fbuf) == 0)
#else
#error !! stat not defined in o.s. !!
#endif
                           {
#if defined (SYSV) || defined (BSD)
                              if (-1 == chmod(tmp_osname, (int) fbuf.st_mode))
#elif defined (NT)
                              if (-1 == _chmod(tmp_osname, (int) fbuf.st_mode))
#else
#error !! chmod not defined in o.s. !!
#endif
                              {
                                 perror("OMFiledOS.write: chmod of tmp_osname failed");
                              }
#ifdef SUNOS
                              if (!pathconf(tmp_osname, _PC_CHOWN_RESTRICTED))
                              {
#endif
                                 if (-1 == chown(tmp_osname, fbuf.st_uid, fbuf.st_gid))
                                 {
                                    perror("OMFiledOS.write: chown of tmp_osname failed");
                                 }
#ifdef SUNOS
                              }
#endif
                           }
                        }
                     }

#if defined (SYSV) || defined (BSD)
                     unlink(osName);
                     link(tmp_osname, osName);
                     unlink(tmp_osname);
#else
#error !! link or unlink not defined in o.s. !!
#endif
                  }
               }
            }
err2:
;
         }        /* End of else enough disk space to recluster */
      }           /* End of if (recluster) */
   }
#endif

   if (OM_Gf_fileLocking)  /* Retain modify access until process exits */
      som_modifyAccess(lockFile, 'M');

   return(sts);
}


int som_copy_filed_cluster(in, out, lcd, p_cluster, free_ptr)

FILE        *in;           /* Input file */
FILE        *out;          /* Output file */
OM_p_LCD    lcd;
struct OMCluster_instance *p_cluster;
OM_p_OSHOLE free_ptr;

{
   int            sts;
   OMuint         jj, loc, bcount, bsize;
   char           buf[8192];

   if (!(bcount = p_cluster->i_fil_byte_size))
      return(OM_S_SUCCESS);
   fseek(in, lcd->i_file_ptr, 0);

   lcd->i_cur_bytes_allocated = lcd->i_file_ptr;
   lcd->i_file_ptr = 0;
   sts = som_file_freelist ( free_ptr, &lcd->i_file_ptr,
                       p_cluster->i_fil_byte_size, p_cluster->i_fil_byte_size);
   if (!(1&sts)) return (sts);

   fseek(out, lcd->i_file_ptr, 0);
   loc = lcd->i_file_ptr;

   while (bcount > 0)
   {
      if (bcount > 8192)
         bsize = 8192;
      else
         bsize = bcount;

      if (fread(buf, 1, bsize, in) != bsize)
         return(UNIX_CONVERT_ERRNO(errno));

      if (fwrite(buf, bsize, 1, out) != 1)
         return(UNIX_CONVERT_ERRNO(errno));
      for (jj=0; jj<bsize; jj++, loc++)
         OM_Gi_checksum += (unsigned char) buf[jj] + loc;
      bcount -= bsize;
   }
   return(OM_S_SUCCESS);
}


/*================================================================*/
/* som_calcClusterFrag(pcluster)                                  */
/*                                                                */
/* Called by write method if re-autoclustering flag is on.  This  */
/* routine is called for each autocluster that was written to     */
/* file.  It returns a one if the logical cluster's fragmentation */
/* exceeds a global limit (sysgen parameter ARTpercentFrag); else */
/* it returns a 0.                                                */
/*================================================================*/
som_calcClusterFrag(pcluster)
struct OMCluster_instance  *pcluster;
{
   OMuint      frag;

   /* Determine memory size of cluster -- cluster's file size less
    * the tag & tag version fields of each object header (8 bytes)
    * -- then determine whether it fits neatly within one or more
    * physical clusters without an amount left over that is less
    * than ARTpercentFrag of a physical cluster slot.
    */
#ifndef NT
   frag = OM_Gi_phyClusterSize - ((pcluster->i_fil_byte_size -
      (pcluster->i_fil_num_objects * 8)) % (OM_Gi_phyClusterSize + 1));
   if (frag > ((OM_Gi_phyClusterSize * OM_Gi_ARTpercentFrag)/100))
      return(1);     /* This cluster could benefit from reclustering */
   else
      return(0);
#else
return(1);
#endif
}


som_verify_checksum(fp)
FILE  *fp;
{
   OMuint   bcount, size, ii, main_checksum, hdr_checksum, checksum, loc;
   char     buffer[8192];

   fseek(fp, 0, 2);
   bcount = ftell(fp) - sizeof(OM_S_OS_FILEHDR);   /* Bytes to checksum */
   fseek(fp, 0, 0);
   if ((ii = fread(buffer, sizeof(OM_S_OS_FILEHDR), 1, fp)) != 1)
   {
      printf("OMFiledOS.write: Could not read file to verify checksum.\n");
      goto error;
   }

#ifdef BIG_ENDIAN
   som_swapint(&((OM_S_OS_FILEHDR *)buffer)->checksum, &main_checksum);
   som_swapint(&((OM_S_OS_FILEHDR *)buffer)->hdr_checksum, &hdr_checksum);
#else
   main_checksum = ((OM_S_OS_FILEHDR *)buffer)->checksum;
   hdr_checksum = ((OM_S_OS_FILEHDR *)buffer)->hdr_checksum;
#endif

   for (ii=checksum=0; ii<434; ii++)
      checksum += (unsigned char) buffer[ii] + ii;
   if (checksum != hdr_checksum)
   {
      printf("OMFiledOS.write: Header checksum is not valid.\n");
      goto error;
   }

   checksum = 0;
   loc = sizeof(OM_S_OS_FILEHDR);
   while(bcount)
   {
      if (bcount > 8192)
         size = 8192;
      else
         size = bcount;
      if (fread(buffer, 1, size, fp) != size)
      {
         printf("OMFiledOS.write: Could not read file to verify checksum.\n");
         goto error;
      }
      bcount -= size;
      for (ii=0; ii<size; ii++, loc++)
         checksum += (unsigned char) buffer[ii] + loc;
   }
   if (checksum != main_checksum)
   {
      printf("OMFiledOS.write: File checksum (%d) is not valid.  Should be %d.\n",
         main_checksum, checksum);
      goto error;
   }
   fclose(fp);
   return(1);

error:
   fclose(fp);
   return(0);
}


void som_errorBox(msg)
char  *msg;
{
   /* EX_error_box is a routine under the message directory.
    * The first param is the virtual screen number, but the
    * routine always gets the appropriate screen itself anyway.
    * It also knows when the process is in batch mode.
    *
    * Since autorecluster, copyOS & OMTdrv.x do not link with
    * libexnuc, they provide their own version of EX_error_box.
    */
/*   fflush(stderr);
   fflush(stdout);
*/
   EX_error_box(0, msg, NULL);
}


/*
 * som_cmpFileTimeStamp(inputFilePtr, read-write_mode,
 *    fileName, pSpaceMap)                                  saw005
 *
 * Since Unix has no useful file locking scheme, we cannot be certain
 * that a file we read from previously is still the same file.  After
 * we loaded our object space and conscientiously closed the file (Unix
 * has a very low open-file limit), someone else may have opened the
 * same file & rewritten it.  Our file pointers in memory may no longer
 * match the file.  To detect this situation, before we try to read
 * from an already-loaded file, we compare the timestamp of the last
 * write to the file (start_time in file header) to the timestamp we
 * saved from the header in the OSO object (TimeDate field).  If they
 * match, we can go ahead & use the file.  Else, print a warning &
 * return an error.
 */

som_cmpFileTimeStamp(infp, mode, filename, pSpaceMap)
FILE           *infp;
char           mode, *filename;
OM_p_SPAMAPENT pSpaceMap;
{
   char              *osoTime, *fileTime;
   OM_S_OS_FILEHDR   filehdr;
   char              msg[512];

   if (fread(&filehdr, 1, sizeof(OM_S_OS_FILEHDR), infp) !=
         sizeof(OM_S_OS_FILEHDR))
      goto overwritten;
   fileTime = &filehdr.start_time[4];
   osoTime = ((struct OMObjSpace_instance *) ((char *)
      (pSpaceMap[filehdr.S_OS_object].state.object) + 64 +
      sizeof(OM_S_OBJECTHDR)))->TimeDate;
   if ((strlen(osoTime) == 15) && (strlen(fileTime) == 21))
      if (!strncmp(osoTime, fileTime, 15))
         return(OM_S_SUCCESS);

overwritten:
/*
   fprintf(stderr, "\nWARNING! Your input file <%s> has been rewritten\n     by another process since you last read from it.  You will not\n     be able to ", filename);
*/
   sprintf(msg, "WARNING!  Your input file <%s> has been rewritten by another process since you last read from it.  You will not be able to ", filename);
   if (mode == 'r')
   {
/*
      fprintf(stderr, "read from it again during this session.\n\n");
*/
      strcat(msg, "read from it again during this session.\n\n");
   }
   else  /* mode = 'w' */
   {
/*
      fprintf(stderr, "save to this file nor read further data from it.\n     Try saving to a new file name.\n\n");
*/
      strcat(msg, "save to this file nor read further data from it.  Try saving to a new file name.\n\n");
   }
   som_errorBox(msg);
   return(OM_E_FILEOVRWRTN);
}


/* Customized version of the above routine written for GRNUC people.
 * They needed a way to see if any given reference file needed to be
 * reloaded because the ref file had been updated by another process
 * since it was loaded.
 */
som_checkFileTimeStamp(osnum)
OMuword  osnum;
{
   FILE              *infp;
   char              *osoTime, *fileTime;
   OM_p_ORIGOSNAME   p_oname;
   OM_S_OS_FILEHDR   filehdr;

   p_oname = OM_Gp_orig_osname;
   while (p_oname)
   {
     if (p_oname->osnum == osnum) break;
     p_oname = p_oname->next;
   }
   /* Test if the original name for this obj space was changed, but
      has since been changed back.
    */
   if (p_oname && !strcmp(p_oname->orig_name, OM_GA_OSDs[osnum]->name))
      p_oname = NULL;
#ifndef NT
   if ( p_oname )
   {
      if (!(infp = (FILE *) fopen(p_oname->orig_name, "r")))
         return(UNIX_CONVERT_ERRNO(errno));
   }
   else
   {
      if (!(infp = (FILE *) fopen(OM_GA_OSDs[osnum]->name, "r")))
         return(UNIX_CONVERT_ERRNO(errno));
   }
#else
   if ( p_oname )
   {
      if (!(infp = (FILE *) fopen(p_oname->orig_name, "rb")))
         return(UNIX_CONVERT_ERRNO(errno));
   }
   else
   {
      if (!(infp = (FILE *) fopen(OM_GA_OSDs[osnum]->name, "rb")))
         return(UNIX_CONVERT_ERRNO(errno));
   }
#endif
   if (fread(&filehdr, 1, sizeof(OM_S_OS_FILEHDR), infp) !=
         sizeof(OM_S_OS_FILEHDR))
      return(OM_E_READ_ERROR);
   fileTime = &filehdr.start_time[4];
   osoTime = ((struct OMObjSpace_instance *) ((char *)
      (OM_GA_OSDs[osnum]->Spacemap[filehdr.S_OS_object].state.object) +
      sizeof(struct OMCluster_instance) +
      sizeof(OM_S_OBJECTHDR)))->TimeDate;
   if ((strlen(osoTime) == 15) && (strlen(fileTime) == 21))
      if (!strncmp(osoTime, fileTime, 15))
         return(OM_S_SUCCESS);
   return(OM_E_ERROR);
}


char *som_getLockFileName(filename)
char  *filename;
{
   /* Figure out the name of the lock file based on the file name
    * passed in.  This routine is called by the change_name method
    * to save a name in OM_GA_lockFiles so the delete method and
    * som_runtime_exit can void out entries in all lock files
    * ever associated with an object space.
    */

   int   len;
   char  *ptr,
         buffer[MAXPATHLEN+1],
         lockname[MAXPATHLEN+1];

   lockname[0] = 0;
   strcpy(buffer, filename);
#ifndef NT
   if (buffer[len = (strlen(buffer) - 1)] == '/')  /* if last char is a / */
#else
   if (buffer[len = (strlen(buffer) - 1)] == '\\')
#endif
      buffer[len] = 0x00;                          /* get rid of it */
#ifndef NT
   if (ptr = (char *) strrchr(buffer, '/'))
#else
   if (ptr = (char *) strrchr(buffer, '\\'))
#endif
   {
      ptr++;
      strncpy(lockname, buffer, len = (int)(ptr-buffer));
      lockname[len] = 0;
   }
   else ptr = buffer;
#ifndef NT
   strcat(lockname, "lock/");
#else
   strcat(lockname, "lock\\");
#endif
   return(strcat(lockname, ptr));
}


som_makeLockFile(filename, create, newname, loadmode)
char     *filename;        /* Design file that lock file will govern */
int      create;           /* Flag indicating filename should be new file */
char     **newname;        /* Name of lock file, returned here to caller */
char     loadmode;         /* Whether read-only or read-write */
{
   int   lfd, len;
   char  *ptr, buffer[MAXPATHLEN+1], lockname[MAXPATHLEN+1];
   static char    errmsg[] = {"FileLocking:makeLockFile: "};

   /*  <path>/<file>   ==>   <path>/lock/<file>  */

   newname[0] = 0;
   lockname[0] = 0;
   strcpy(buffer, filename);
#ifndef NT
   if (buffer[len = (strlen(buffer) - 1)] == '/')  /* if last char is a / */
#else
   if (buffer[len = (strlen(buffer) - 1)] == '\\')
#endif
      buffer[len] = 0x00;                          /* get rid of it */
#ifndef NT
   if (ptr = (char *) strrchr(buffer, '/'))
#else
   if (ptr = (char *) strrchr(buffer, '\\'))
#endif
   {
      ptr++;
      strncpy(lockname, buffer, len = (int)(ptr-buffer));
      lockname[len] = 0;
   }
   else ptr = buffer;
#ifndef NT
   if (access(strcat(lockname, "lock/"), 7))
#else
   if (_access(strcat(lockname, "lock\\"), 7))
#endif
   {
      int   savemask;

      if (errno != ENOENT)
      {
         printf("%sCould not access lock directory %s\n", errmsg, lockname);
         perror("");
         som_errorBox("Could not access lock directory.");
         return(OM_E_ERROR);
      }
#ifndef NT 
      savemask = umask(0);
      if(mkdir(lockname, 0777))
#else
      savemask = _umask(0);
      if(_mkdir(lockname))
#endif
      {
         printf("%sCould not create lock directory %s\n", errmsg, lockname);
         perror("");
         som_errorBox("Could not create lock directory.");
         return(OM_E_ERROR);
      }
#ifndef NT
      savemask = umask(savemask);
#else
      savemask = _umask(savemask);
#endif
   }
   strcat(lockname, ptr);

   /* Lock the file.  If this is a new file (create = 1), then
    * either we'll create the lock file, or if it already exists
    * there won't be any entries in it.
    */
#ifndef NT
   if ((lfd = open(lockname, O_RDWR | O_CREAT)) == -1)
#else
   if ((lfd = _open(lockname, _O_RDWR | _O_CREAT)) == -1)
#endif
   {
      printf("%sCould not open lock file %s\n", errmsg, lockname);
      perror("");
      som_errorBox("Could not open lock file.");
      return(OM_E_ERROR);
   }
   if (create)  /* Creating a new design file */
   {
      if (!som_addLockEntry(lfd, lockname, filename, 'W'))
      {
         printf("%sCould not write to lock file <%s>\n", errmsg, lockname);
         som_errorBox("Could not write to lock file.");
         return(OM_E_ERROR);
      }
   }
   else
   {
      if (!som_addLockEntry(lfd, lockname, filename,
            ((loadmode & OM_e_loados_ro) ? 'R' : 'M')))
      {
         printf("%sCould not write to lock file <%s>\n", errmsg, lockname);
         som_errorBox("Could not write to lock file.");
         return(OM_E_ERROR);
      }
   }
#ifndef NT
   chmod(lockname, 0666);
   close(lfd);   
#else
   _chmod(lockname, 0666);
   _close(lfd);
#endif

   strcpy((char *) newname, lockname);
   return(OM_S_SUCCESS);
}



struct OM_sd_lockFileRec *som_getLockFile(fd, count)
int   fd, *count;
{
   int                        bcnt;
#ifndef NT
   struct stat                buf;
#else
   struct _stat               buf;
#endif
   struct OM_sd_lockFileRec   *rec = NULL;

   /* Use fstat to get size of the lock file, allocate memory to
    * holds its contents, and read it in.  Return pointer to
    * memory.
    */

#ifndef NT
   lseek(fd, 0, 0);
   if (!fstat(fd, &buf))
#else
   _lseek(fd, 0, 0);
   if (!_fstat(fd, &buf))
#endif
   {
      bcnt = (*count = buf.st_size / sizeof(struct OM_sd_lockFileRec)) *
         sizeof(struct OM_sd_lockFileRec);
      if (rec = (struct OM_sd_lockFileRec *) om$malloc(size=bcnt))
      {
#ifndef NT
         if (bcnt != read(fd, rec, bcnt))
#else
         if (bcnt != _read(fd, rec, bcnt))
#endif
            rec = NULL;
      }
   }
   return(rec);
}


int som_addLockEntry(fd, lfname, dfname, code)
int   fd;
char  *lfname, *dfname, /* Lock file name, design file name & 'R' or 'W' code */
      code;
{
   int                        sts, myIndex, index, count, ii,
                              writing, modify, faulting, other;
   struct OM_sd_lockFileRec   *rec;
   time_t                     clk;
   static char                errmsg[] = {"FileLocking:addLockEntry: "};
#ifndef NT
   if (lockf(fd, F_TLOCK, 0) == -1)
   {
      printf("%sCould not lock file <%s>\n", errmsg, lfname);
      perror("");
      som_errorBox("Could not open lock file.");
      return(0);
   }

   myIndex = index = writing = modify = faulting = -1;
   count = other = 0;
   if (code == 'M')
   {
      /* If user is requesting modify access, check the Unix access
       * bits to see if this user can write to the file; if not, change
       * 'M' to 'R', so the lockfile looks right.  I.e., if the access
       * mode of the file is r--r--r--, then the lockfile should not
       * have a 'M' in it.  OM will have opened the design file with
       * proper access, but does not save Unix access info anywhere,
       * just the Ems access info (loadmode) which is different.
       */
#ifndef NT
      if (access(dfname, 02))
#else
      if (_access(dfname, 02))
#endif

         code = 'R';
   }
   if (rec = som_getLockFile(fd, &count))
   {
      for (ii=0; ii<count; ii++)
      {
         if (!strcmp(rec[ii].pid, OM_Gp_lockFileRec->pid) &&
             !strcmp(rec[ii].osnum, OM_Gp_lockFileRec->osnum) &&
             !strncmp(rec[ii].node, OM_Gp_lockFileRec->node, 9))
            myIndex = ii;  /* We already had an entry - reuse this record */
         else if (rec[ii].code == 'V')
            index = ii;    /* Can use this void rec if can't find 1 of our own */
         else if (rec[ii].code == 'W')
            writing = ii;
         else if (rec[ii].code == 'M')
            modify = ii;
         else if (rec[ii].code == 'F')
            faulting = ii;
         else
            other++;
      }
      if ((code == 'M') && ((writing != -1) || (modify != -1)))
      {
         /* Request was for write or modify access, but someone already
          * has write or modify access.  Return error.
          */
         sts = 0;
         if (writing != -1)
            ii = writing;
         else
            ii = modify;
         printf("%sProcess %c%c%c%c%c on node %s has modify access to\nfile <%s>.  Only one process at a time may modify a file.\n",
            errmsg, rec[ii].pid[0], rec[ii].pid[1], rec[ii].pid[2],
            rec[ii].pid[3], rec[ii].pid[4], rec[ii].node, dfname);
         goto err;
      }
      else if ((code == 'W') && ((faulting != -1) || (writing != -1) ||
         (modify != -1) || other))
      {
         sts = 0;
         printf("%sCould not create file %s.  Lock file indicates file exists.\n",
            errmsg, dfname);
         goto err;
      }
      else if (((code == 'F') || (code == 'R')) && (writing != -1))
      {
         /* Request was to fault in a cluster or load a read-only
          * file, but file is being rewritten.  Return an error.
          */
         sts = 0;
         printf("%sProcess %c%c%c%c%c on node %s is rewriting\nfile <%s>.\n",
            errmsg, rec[writing].pid[0], rec[writing].pid[1],
            rec[writing].pid[2], rec[writing].pid[3], rec[writing].pid[4],
            rec[writing].node, dfname);
         goto err;
      }
   }

   /* myIndex is location of user's own entry.  index is location
      of a void entry, which may be re-written.  If both of these
      are -1, then we're at the end of the file & don't need to lseek.
    */
   sts = 1;
   OM_Gp_lockFileRec->code = code;
   clk = time(0);
   strcpy(OM_Gp_lockFileRec->timestamp, (char *) ctime(&clk) + 4);
   if (myIndex != -1)
#ifndef NT
      lseek(fd, myIndex * sizeof(struct OM_sd_lockFileRec), 0);
#else
      _lseek(fd, myIndex * sizeof(struct OM_sd_lockFileRec), 0);
#endif
   else if (index != -1)
#ifndef NT
         lseek(fd, index * sizeof(struct OM_sd_lockFileRec), 0);
   if (write(fd, OM_Gp_lockFileRec, sizeof(struct OM_sd_lockFileRec)) == -1)
#else
         _lseek(fd, index * sizeof(struct OM_sd_lockFileRec), 0);
   if (_write(fd, OM_Gp_lockFileRec, sizeof(struct OM_sd_lockFileRec)) == -1)
#endif
   {
      printf("%sWrite to <%s> failed.  Cannot access file <%s>.\n",
         errmsg, lfname, dfname);
      sts = 0;
   }
err:
   if (!sts)
      som_errorBox("Could not add entry to lock file");

   if (lockf(fd, F_ULOCK, 0) == -1)
   {
      printf("%sCould not unlock file <%s>!\n", errmsg, lfname);
      som_errorBox("Could not unlock lock file.");
      perror("");
   }
#endif
   return(sts);
}


som_modifyAccess(lfname, newMode)
char  *lfname, newMode;
{
   char                       buf[2], found, error = 0;
   int                        ii, fd, count;
   struct OM_sd_lockFileRec   *rec;
   static char                errmsg[] =
                                 {"FileLocking:modifyAccess: Could not "};

#ifndef NT
   if (access(lfname, 00))
#else
   if (_access(lfname, 00))
#endif
      return(1);
   buf[0] = newMode;
#ifndef NT
   if (!(fd = open(lfname, O_RDWR)))
#else
   if (!(fd = _open(lfname, _O_RDWR)))
#endif
   {
      printf("%sopen lock file <%s>\n", errmsg, lfname);
      perror("");
      som_errorBox("Could not open lock file");
      return(0);
   }
#ifndef NT
   if (lockf(fd, F_TLOCK, 0) == -1)
   {
      printf("%slock file <%s>\n", errmsg, lfname);
      perror("");
      close(fd);
      som_errorBox("Could not add entry to lock file");
      return(0);
   }
#endif

   /* We found the file.  Read each of its entries and make void
    * any entries with our pid.  Nothing happens if we don't
    * find any.
    */
   if (!(rec = som_getLockFile(fd, &count)))
   {
      printf("%sread lock file <%s>\n", errmsg, lfname);
#ifndef NT
      if (lockf(fd, F_ULOCK, 0) == -1)
      {
         printf("%sunlock file <%s>\n", errmsg, lfname);
         perror("");
      }
      close(fd);
#else
      _close(fd);
#endif

      som_errorBox("Could not read lock file");
      return(0);
   }
   found = 0;
   ii = 0;
   for (; ii<count; ii++)
   {
      if (rec[ii].code == 'V')
         continue;
      if (!strncmp(rec[ii].pid, OM_Gp_lockFileRec->pid, 5))
      {
         if (strncmp(rec[ii].node, OM_Gp_lockFileRec->node, 9))
            continue;
         if (strcmp(rec[ii].osnum, OM_Gp_lockFileRec->osnum))
            continue;
         switch (rec[ii].code)
         {
            case 'F':
               if ((newMode != 'R') && (newMode != 'r') && (newMode != 'V'))
                  error = 1;
               break;
            case 'M':
               if (OM_Gf_fileLocking == 2)
               {
                  /* Special case for Ems seed file -- We can go from
                   * 'M' to read-only.  (See EX_retrii.I)
                   */

                  if ((newMode != 'W') && (newMode != 'V') && (newMode != 'R')
                     && (newMode != 'F') && (newMode != 'r'))
                     error = 1;
               }
               else if ((newMode != 'W') && (newMode != 'V') &&
                  (newMode != 'R'))
                  error = 1;
               break;
            case 'R':
               if (newMode == 'R')
                  goto done;     /* No-op */
               if ((newMode != 'F') && (newMode != 'r') && (newMode != 'V'))
                  error = 1;
               break;
            case 'r':
               if ((newMode == 'R') || (newMode == 'r') || (newMode == 'F'))
                  goto done;     /* No-op */
               if (newMode != 'V')
                  error = 1;
               break;
            case 'W':
               if (newMode == 'W')
                  goto done;     /* No-op */
               if ((newMode != 'M') && (newMode != 'V') && (newMode != 'F'))
                  error = 1;
               break;
         }
         if (error)
            buf[0] = 'V';
#ifndef NT
         lseek(fd, (ii * (sizeof(struct OM_sd_lockFileRec))), 0);
         write(fd, buf, 1);
#else
         _lseek(fd, (ii * (sizeof(struct OM_sd_lockFileRec))), 0);
         _write(fd, buf, 1);
#endif

         goto done;
      }
   }
   if (!found && (newMode != 'V') && (newMode != 'r'))
      printf("%schange file access to %c\n", errmsg, newMode);

   else if (error)
      printf("%schange file access from %c to %c\n",
         errmsg, rec[ii].code, newMode);

done:
   if (error)
      som_errorBox("Invalid file access request.\nAll access removed.");
#ifndef NT
   if (lockf(fd, F_ULOCK, 0) == -1)
   {
      printf("%sunlock file <%s>\n", errmsg, lfname);
      perror("");
      som_errorBox("Could not remove lock on lock file");
   }
   close(fd);
#else
   _close(fd);
#endif

   return(1);
}

end	implementation OMFiledOS;
