class 	implementation	OMObjSpace;
#include <stdio.h>
#include <string.h>

#if defined (NT)
#include <io.h>
#endif

#include "OMmacros.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMmetaclass.h"
#include "UNIXerrdef.h"
#include "OMtags.h"
#include  <errno.h>

extern int		OM_make_internal_OS_name();
extern int		som_build_internal_classlist();
extern int		som_getLockFileName();

extern OM_p_ORIGOSNAME  OM_Gp_orig_osname;
extern OMuint           OM_Gf_dload_mode;
extern OMuint           OM_Gf_fileLocking;
extern struct OM_sd_lockFiles  **OM_GA_lockFiles;

from OMGroup	 import my_name;
from OMGroup	 import pass;
from OMOSCO	 import add_class;
from OMISO       import is_readonly;
from OMCluster   import fault;
   
/*
Class:		OMObjSpace

This file contains methods for following messages:

		delete
		pass
		intialize
		execute
		cleanup
		fix_osd
		
Author:		Chuck Puckett
Creation Date:	Nov. 1985
Imported Methods:


Change History:

jkm001  2-jul-1986	add the construct os routines (NOT METHODS)

rme001  11-aug-1986     add Named Object Directory Methods.

rme002  22-apr-1986     Since OMTag and OMTagCon objects are connected to
                        the "to_GrpDscs" channel on the oso, any channel
                        sends down that channel (intended for OMGroup 
                        objects) could potentially return unknown msg
                        status.  Fix all sends down that channel to accept
                        unknown msg as success.
*/

method change_name(char *name; OM_e_OVRWRT_FLG overwrite)

{
FILE		*OSfile;
int		sts,i,j, tk=0, from_saveas77=0, from_saveas78=0;
char            save_intos_name[OM_K_MAXINTOSNAME_LEN];
OMuword         osnum, *os_keep=0;
OM_p_ORIGOSNAME p_oname, p_prev_oname;
static char     saveas_intosname[OM_K_MAXINTOSNAME_LEN];

  /*======================================================================*/
  /*  This following chunk-o-code is a kludge to determine if we are      */
  /*  changing the name of this OS in the Save As command - if so, then   */
  /*  we will be chaning it back after the save and will be reinstating   */
  /*  the internalOS name                                                 */
  /*======================================================================*/

  if (overwrite == (OM_e_OVRWRT_FLG) 77) {
     from_saveas77 = 1;
     overwrite = OM_e_overwrite;
  }
  else if (overwrite == (OM_e_OVRWRT_FLG) 78) {
     from_saveas78 = 1;
     overwrite = OM_e_overwrite_rrr;
  }

  /* are there iso's? */

   i = om$dimension_of(varray=ME.OMObjSpace->iso_d);
   if(i) {  

     /*  malloc array to hold os numbers for notification  */

     os_keep = (OMuword *)om$malloc ( size = sizeof(OMuword) * OM_Gw_maxOS );
     if (!os_keep) return (OM_E_NODYNMEM);

     /*  check if all ISOs are to transient OSs  */

     for (j=0; j<i; ++j) {
       sts = om$os_internal_name_to_number ( 
                         osname  = ME.OMObjSpace->iso_d[j].s_int_os_name,
                         p_osnum = &osnum );
       if (sts==OM_S_SUCCESS) {
         if (OM_GA_OSDs[osnum]->type == OM_OSD_filed) {
            sts = om$send ( msg = message OMISO.is_readonly(),
                            targetid = ME.OMObjSpace->iso_d[j].iso_u.s_objid );
            if (sts == OM_W_ISODIRONOS) {
               om$dealloc ( ptr = (char *) os_keep );
               return (sts);
            }
            os_keep[tk++] = osnum;
         }
         else if (OM_GA_OSDs[osnum]->type == OM_OSD_trans) {
            os_keep[tk++] = osnum;
         }
       }
       else if (sts==OM_E_NOSUCHOS) {
         om$dealloc ( ptr = (char *) os_keep );
         return (OM_W_ISODIRONOS);
       }
     }
   }

   sts=OM_S_SUCCESS;				/* initialize return status */
   if ((ME.OMObjSpace->OSD.type != OM_OSD_trans) &&
       (overwrite != OM_e_overwrite_rrr))
   {
    if (OSfile = (FILE *) fopen (name, "r"))    /* does the file exist      */
     {						/* YES it exists	    */
      if( overwrite == OM_e_no_ovrwrt )		/* user want to overwrite?? */
       {					/* NO!! do not overwrite    */
        fclose(OSfile);
        if (os_keep) om$dealloc (ptr = (char *) os_keep);
        return(OM_E_FILEEXISTS);		/* return warning	    */
       }
      else
       {
        fclose(OSfile);				/* close file                */
        if (!(OSfile = (FILE *) fopen(name, "a"))) /* re-open with append access*/
         {					/* to verify write permission*/
          if (!(ME.OMObjSpace->OSD.flags & OM_e_loados_ro)) {
            if (os_keep) om$dealloc (ptr = (char *) os_keep);
            return (UNIX_CONVERT_ERRNO(errno));	/* error opening!!	     */
          }
         }					/* return error and exit     */
        fclose(OSfile);				/* successful open. close it */
        sts=OM_I_FILEOVRWRTN;
       }
     }
/*	The read has failed.  This indicates that either the file does
	not exist or an error  has occured accessing the file (invalid
	file name, access permission denied, etc.).   Before going any
	further	determine if the file can be opened for write.   If it
	cannot, the latter  of  the  aforementioned  errors is assumed.
	Otherwise the file had not existed and  the creation for write
	was successful.  The file is then removed unitl it is ready to
	be written later on.
*/
    else
     {
      if (!(OSfile = (FILE *) fopen(name, "w+")))  /* open file for write      */
       {					/* error opening for write  */
        if (!(ME.OMObjSpace->OSD.flags & OM_e_loados_ro)) 
         {
          if (os_keep) om$dealloc (ptr = (char *) os_keep);
          return (UNIX_CONVERT_ERRNO(errno));	/* return error             */
         }
       }
      else					/* successful open          */
       {
        fclose( OSfile );			/* close file		    */
#if defined (SYSV) || defined (BSD)
        unlink(name);				/* remove file until ready  */
#elif defined (NT)
        _unlink(name);				/* remove file until ready  */
#else
#error !! unlink not defined in o.s. !!
#endif
       }					/*   to write               */
     }	
  }

  /*===================================================================*/
  /*  since OS name has changed - if it is not transient - set up a    */
  /*  data structure to remember the original name for cluster faults  */
  /*===================================================================*/

  if ( ME.OMObjSpace->OSD.type != OM_OSD_trans ) 
  {  
     /*  check if already changed  */
     p_prev_oname = 0;
     p_oname = OM_Gp_orig_osname;
     while (p_oname)
     {
        if ( p_oname->osnum == OM_Gw_current_OS ) break;
        p_prev_oname = p_oname;
        p_oname = p_oname->next;
     }
     if ( !p_oname )
     {
        p_oname = om$malloc ( structure = OM_S_ORIGOSNAME );
        if (!p_oname) {
           if (os_keep) om$dealloc (ptr = (char *) os_keep);
           return (OM_E_NODYNMEM);
        }

        p_oname->osnum = OM_Gw_current_OS;
        strncpy (p_oname->orig_name, ME.OMObjSpace->OSD.name, 
                 OM_K_MAXOSNAME_LEN);
        p_oname->next = OM_Gp_orig_osname;
        OM_Gp_orig_osname = p_oname;

        if (OM_Gf_fileLocking)
        {
           /* We already have either read or modify access to the old
            * file, and that access should stay the same  for level 1.
            * The old file name is saved in the OM_Gp_orig_osname
            * list & will be used to void out the lock file entry at
            * delete or runtime_exit.
            */

           if (OM_Gf_fileLocking == 2)
           {
              /* At level 2, we need to make sure we've got all the
               * data out of the original file.
               */
              OMuint  ii;
              for (ii=1; ii < OM_Gp_CurOSD->ClustersSize; ii++)
              {
                 if (ME.OMObjSpace->OSD.Clusters[ii] &&
                    !(ME.OMObjSpace->OSD.Clusters[ii]->flags & OM_FAULTED))
                 {
                    if (!(1&(sts=om$send(msg=message OMCluster.fault(0),
                       targetid=ME.OMObjSpace->OSD.Clusters[ii]->oid))))
                        return(sts);
                 }
              }
           }
        }
     }
     else
     {
        /*  check if changing back to original name  */
 
        if (!strcmp(p_oname->orig_name,name))
        {
           if (p_prev_oname)
           {
              p_prev_oname->next = p_oname->next;
           }
           else
           {
              OM_Gp_orig_osname = p_oname->next;
           }
           om$dealloc(ptr = (char *) p_oname);
        }
     }
  }
   
  /*===============================*/
  /*  make the name transfer here  */
  /*===============================*/

  if (OM_Gf_fileLocking)
  {
     int                      found;
     struct OM_sd_lockFiles   *ptr, *prev=NULL;
     char                     buf[256];

     ptr = OM_GA_lockFiles[OM_Gw_current_OS];
     found = 0;
     strcpy(&buf[0], (char *) som_getLockFileName(name));
     while (ptr)
     {
        if (!strcmp(ptr->name, &buf[0]))
        {
           found = 1;
           break;
        }
        prev = ptr;
        ptr = ptr->next;
     }
     if (!found)
     {
        if (prev->next = (struct OM_sd_lockFiles *)
           om$malloc(size = sizeof(struct OM_sd_lockFiles)))
        {
           if (prev->next->name = (char *) om$malloc(size = strlen(&buf[0])))
              strcpy(prev->next->name, &buf[0]);
              prev->next->next = NULL;
        }
     }
  }

  strncpy (ME.OMObjSpace->OSD.name, name, OM_K_MAXOSNAME_LEN);

  if (from_saveas77)
     strncpy ( saveas_intosname,  ME.OMObjSpace->OSD.InternalName, 
               OM_K_MAXINTOSNAME_LEN );

  strncpy (save_intos_name, ME.OMObjSpace->OSD.InternalName,
           OM_K_MAXINTOSNAME_LEN);

  OM_make_internal_OS_name( name, ME.OMObjSpace->OSD.InternalName);

  if (from_saveas78)
     strncpy ( ME.OMObjSpace->OSD.InternalName,  saveas_intosname, 
               OM_K_MAXINTOSNAME_LEN );

  /*===============================================================*/
  /*  send to any transient OSO to change ISOdir internal OS name  */
  /*  which maps that ISO to this OS                               */
  /*===============================================================*/

   for (i=0; i<tk; ++i) {
     sts = om$send ( msg = message OMObjSpace.update_isodir 
                          ( save_intos_name, ME.OMObjSpace->OSD.InternalName),
                     targetid = OM_GA_OSDs[os_keep[i]]->OSO_Oid,
                     targetos = os_keep[i] );
     if (!(1&sts)) {
        om$report_error(sts=sts);
        printf ("OMObjSpace.change_name:failed to update transient ISOdir\n");
        om$dealloc ( ptr = (char *) os_keep );
        return (sts);
     }
   }

  if (os_keep) om$dealloc (ptr = (char *) os_keep);
  return(sts);
}

/* we put in method place holders for all OS subclasses */

method	delete	(int flag)
{
  return (OM_S_SUCCESS);
}

method 	pass 		(OM_S_CLASSLIST *classlist;
		         OM_E_WRT_FLAG  wrt_flag;
			 OM_S_MESSAGE   *msg)
{
int             sts;
OMbyte          *internal_classlist;
OM_S_CLASSLIST  save_classlist;
OM_S_CHANSELECT	to_chan;

#ifdef DEBUG
printf("OMObjSpace.pass -- executing pass method for os %d \n",
	OM_Gw_current_OS);
#endif

        /*----------------------------------------------------------------*/
	/* insure that the message to be passed is NOT the OS pass method */
        /*----------------------------------------------------------------*/

	if((msg->select.DefClassid == OM_K_OMOBJSPACE_ACTCLASSID) &&
	   (msg->select.FuncIndex  == OMObjSpace_OPP_pass_method_index))
        return(OM_E_NOPASSPASS);

        /*-------------------------------------------------------------*/
        /*  only build the internal classlist once and pass it to the  */
        /*  groups - this saves each group from having to build it.    */
        /*  som_build_internal_classlist will set the high order bit   */
        /*  in the w_flags field (OM_CLST_internal) to indicate that   */
        /*  the internal list is passed in                             */
        /*-------------------------------------------------------------*/

        if ((classlist) && (classlist->w_count))
        {
           sts = som_build_internal_classlist ( classlist, 
                                                &internal_classlist);
           if (!(1&sts)) return (sts);
           save_classlist = *classlist;
           classlist->w_flags |= OM_CLST_internal;
           classlist->p_classes = (OMuword *)internal_classlist;
        }

	to_chan.type = OM_e_addr;
	to_chan.u_sel.addr = & (ME.OMObjSpace->to_GrpDscs);

	sts = om$send(	p_chanselect = &to_chan,
			msg = message OMGroup.pass(msg,classlist,wrt_flag));

        if (sts == OM_W_UNKNOWN_MSG)
           sts = OM_S_SUCCESS;

        if ((classlist) && (classlist->w_count))
        {
           if ( classlist->w_flags & OM_CLST_internal )
           {
              om$dealloc (ptr=(char *) internal_classlist);
           }
           *classlist = save_classlist;
        }

        return (sts);
}


method	init_OMObjSpace ()
{
  return (OM_S_SUCCESS);
}

method	execute ()
{
  return (OM_E_MSGNOTSUPP);
}

method	cleanup ()
{
  return (OM_S_SUCCESS);
}

/*  Revision History:
    15-aug-1986    geo	OM 4.0 created
*/

/* Fix OSD */
/* This method fixes global pointers to OSO after it is resized. */

method fix_osd ()
{
  OM_Gp_CurOSD = OM_GA_OSDs[OM_Gw_current_OS] = &(ME.OMObjSpace->OSD);

  /* there is now a descrepency in the SendDepth field in the OSD. This
  /* is because the act of sending caused it to be incremented. the new
  /* OSD does not agree with the old OSD. We will therefore increment the
  /* new OSD SendDepth to bring them in sync..
  */

  return(OM_S_SUCCESS);
}
   


/*  Revision History:

    25-aug-1986    geo	OM 4.0 created
*/


/* This method does channel send to all OSO's groups to translate */
/* input arg name into its group objid, of matching group object. */

method translate_group_name(char *name; OM_p_OBJID p_oid)
{
  OM_S_CHANSELECT	cs;
  OMuint		sts;

  if (name == NULL)  return(OM_E_INVARG);
  /* channel send thru to_GrpDscs */
  cs.type = OM_e_addr;
  cs.u_sel.addr = &ME.OMObjSpace->to_GrpDscs;
  sts = om$send(msg=message OMGroup.my_name(name, p_oid), p_chanselect=&cs,
	  mode=OM_e_wrt_message);
  if (sts == OM_W_UNKNOWN_MSG)
     sts = OM_S_SUCCESS;
  return(sts);
}


/* This method takes a class name and active class id as input and 
   stretches the OSCO list and active to filed map.

   Revisions:

	rme	04/20/1988	Fixed problem in mapping active to
				filed.  At this point, no instance of
				the object exists so do not map the
				active to any filed id.
*/

method add_class( char *name; OMuword classid )

{
  int                   sts;
  OM_S_CHANSELECT	csel;
  char			*new_p;

#ifdef DEBUG
printf("\n*** Entering OMObjSpace.add_class method ***\n\n");
printf("classname: %s\n", name);
printf("classid: %d\n", classid);
#endif

   if (name == NULL)  
      return(OM_E_INVARG);

   /*=======================================================================*/
   /* If during a dynamic load of classes then we must check if this class  */
   /* is already represented in this OS via an existing OSCO - if so then   */
   /* OSCO.add_class will  1) adjust ActToFil                               */
   /*                      2) init ActToFil[classid]                        */
   /*                      3) adjust FilToAct (if needed)                   */
   /*                      4) init FilToAct[fil_classid]                    */
   /*                      5) adjust OSCO_list and init entry               */
   /*=======================================================================*/

   if (OM_Gf_dload_mode) {
      csel.type = OM_e_addr;
      csel.u_sel.addr = &ME.OMObjSpace->to_OSCOs;

      sts = om$send ( msg = message OMOSCO.add_class ( name, classid ),
                      senderid = my_id,
                      p_chanselect = &csel );
      if (sts == OM_I_STOP_SENDING) {
         return (OM_S_SUCCESS);
      }
   }

   /* Adjust the A->F; numclasses already incremented by one */

#ifdef DEBUG
printf("\n*** Adjust a->f ***\n\n");
#endif

   new_p = om$realloc(ptr=(char *) OM_GA_active_to_filed,
                         size=OM_Gw_numclasses*sizeof(OMuword) );

   if ( new_p == NULL )
      return(OM_E_NODYNMEM);

   OM_GA_active_to_filed = (OMuword *)(new_p);
   ME.OMObjSpace->OSD.ActToFil = (OMuword *)(new_p);

   /*  NOTE:  All new classes are initially mapped to filed id 0.
              When an instance of the class is created, it will be
              assigned a filed classid.

              (som_build_internal_classlist assumes every active class
               has a filed classid, it therefore assumes that these
               classes have a filed id of 0.)
   */

   OM_GA_active_to_filed[OM_Gw_numclasses-1] = 0;

   /* Grow the OSCO list */

   new_p = om$realloc(ptr=(char *) ME.OMObjSpace->OSD.OSCO_list,
                         size=OM_Gw_numclasses*sizeof(OM_p_OSCO ) );

   if ( new_p == NULL )
      return(OM_E_NODYNMEM);

   ME.OMObjSpace->OSD.OSCO_list = ( OM_p_OSCO *)(new_p);
   ME.OMObjSpace->OSD.OSCO_list[OM_Gw_numclasses-1] = NULL;

#ifdef DEBUG
printf("\n*** Exiting OMObjSpace.add_class method ***\n\n");
#endif

   return(OM_S_SUCCESS);
}


method get_status (OM_p_OSSTATUS p_stat)
{
   /*   
        Description:
        
        Returns statistics about this instance of an object space.
        The info. is returned in the OM_S_OSSTATUS structure.  The
        type of info. returned is based on the variable stattype.
   */

   switch (p_stat->stattype)
   {
      case OM_OS_STATUS_MISC:
      
         /*------------------------------------*/
         /*  Return miscellaneous statistics.  */
         /*------------------------------------*/
   
         /*  Get the number of objects in the OS from the OSCO list.  */
         {
            OM_p_OSCO         *OSCO_list;
            OMuword           ii;

            p_stat->stat.misc.num_OMobjects = 0;
            p_stat->stat.misc.num_UserObjects = 0;

            OSCO_list = ME.OMObjSpace->OSD.OSCO_list;

            for (ii=0; ii < OM_Gw_next_class_index; ii++)
            {
               if ( OSCO_list[ii] )
               {
                  if (ii > 64)/*  User defined class. */
                  {
                     p_stat->stat.misc.num_UserObjects += 
                                            OSCO_list[ii]->i_refcnt;
                  }
                  else /* OM defined class. */
                  {
                     p_stat->stat.misc.num_OMobjects += 
                                            OSCO_list[ii]->i_refcnt;
                  }
               }
            }
            if (p_stat->stat.misc.num_UserObjects && OM_GA_p_tagcon)
            {
               OM_p_TAGCON_LINK  p_tc_link = OM_GA_p_tagcon[OM_Gw_current_OS];
               struct sd_my_tagcon
               {
                 char root[8];
                 OMuword first_tag;
                 OMuword first_free;
                 char osname[OM_K_MAXINTOSNAME_LEN];
                 OMuint count;
                 OMuint chan;
                 OMuint vla_ptr;
                 OMuint vla_cnt;
               } *p_my_tagcon;

               while (p_tc_link)
               {
                  p_my_tagcon = (struct sd_my_tagcon *)
                     OM_Gp_CurSpaceMap[p_tc_link->objid].state.object;
                  p_stat->stat.misc.num_UserObjects -= p_my_tagcon->count;
                  p_tc_link = p_tc_link->next;
               }
            }
         }/* Object Count */

         /*  Fill in the rest from the OSD and instance.  */

         p_stat->stat.misc.OStype = ME.OMObjSpace->OSD.type;
         p_stat->stat.misc.OSflags = ME.OMObjSpace->OSD.flags;

         strncpy(p_stat->stat.misc.CreTimeDate,ME.OMObjSpace->CreTimeDate,16);
         strncpy(p_stat->stat.misc.TimeDate,ME.OMObjSpace->TimeDate,16);

         return (OM_S_SUCCESS);
         
      case OM_OS_STATUS_CLUSTERS:

         /*-------------------------------------------------*/
         /*  Return information about clusters in this OS.  */
         /*-------------------------------------------------*/

         p_stat->stat.cluster.total_num = 0;
         p_stat->stat.cluster.num_faulted = 0;
         p_stat->stat.cluster.mem_allocated = 0;
         p_stat->stat.cluster.num_chunks = 0;

         /*  Get all info from the OSD array of cluster composites.  */
         {
            OMuint           ii, size;  /*  Loop counter and array size.  */
            OM_p_LCD         *Clusters; /*  Array of clusters structure.  */

            size = ME.OMObjSpace->OSD.ClustersSize;
            Clusters = ME.OMObjSpace->OSD.Clusters;

            for (ii=0; ii < size; ii++)
            {
		OM_p_PCD	pcd;

               if ( Clusters[ii] )
               {
                  p_stat->stat.cluster.total_num++;

                  if (Clusters[ii]->flags & OM_FAULTED)
                  {
                     p_stat->stat.cluster.num_faulted++;
                  }
                  
	          pcd = (OM_p_PCD)Clusters[ii]->pcdq_lh.next;
		  while(pcd != (OM_p_PCD)&Clusters[ii]->pcdq_lh.next)
      		  {
                     p_stat->stat.cluster.num_chunks += pcd->i_cur_num_chunks;
                     pcd = (OM_p_PCD) pcd->pcdq.next;
		  }
                  p_stat->stat.cluster.mem_allocated += 
                             Clusters[ii]->i_cur_bytes_allocated;
               }
            }
         }/* Cluster stuff */

         return (OM_S_SUCCESS);

      case OM_OS_STATUS_GROUPS:

         /*--------------------------------*/
         /*  Return the number of groups.  */
         /*--------------------------------*/
         {
            int               sts;       /* OM return sts. */
            OM_S_CHANSELECT   group_cs;  /* Channel selector for group.  */
            OMuint            count;     /* Returned number of groups.  */

            group_cs.type = OM_e_addr;
            group_cs.u_sel.addr = &ME.OMObjSpace->to_GrpDscs;

            sts = om$get_channel_count(p_chanselect = &group_cs,
                                       objid = my_id,
                                       count = &count);
            if (!(1&sts)) return (sts);

            /*------------------------------------------------------------*/
            /*  Have to subtract the count of OMTag and OMTagCon objects  */
            /*  that are connected to the "to_GrpDscs" channel.           */
            /*------------------------------------------------------------*/

            if (OM_GA_tag_oids)
               if (! IF_NULL_OBJID(OM_GA_tag_oids[OM_Gw_current_OS]))
                  --count;

            if (OM_GA_p_tagcon)
            {
               OM_p_TAGCON_LINK p_cur;

               p_cur = OM_GA_p_tagcon[OM_Gw_current_OS];

               while (p_cur)
               {
                  --count;
                  p_cur = p_cur->next;
               }
            }

            p_stat->stat.group.total_num = count;
         }
     
         return (OM_S_SUCCESS);
      
      default:

         return (OM_E_INVSTSTYPE);
   }
};



method update_isodir ( char *old_int_name,  *new_int_name )
{
   int i, j;

   i = om$dimension_of(varray=ME.OMObjSpace->iso_d);
   for (j=0; j<i; ++j) {
      if (!strncmp(ME.OMObjSpace->iso_d[j].s_int_os_name,old_int_name,
                   OM_K_MAXINTOSNAME_LEN)) {
         strncpy ( ME.OMObjSpace->iso_d[j].s_int_os_name, new_int_name,
                   OM_K_MAXINTOSNAME_LEN);
         return (OM_S_SUCCESS);
      }
   }
   return (OM_W_NAMENOTFOUND);
}


/*=====================================================================*/
/*  This functions is used to set/get the value of the user definable  */
/*  OS flags field in the OS header.  This was originally designed to  */
/*  be a value oriented field but as of the 2.4 release it has been    */
/*  changed to be a bit-oriented field.  This means that a "set"       */
/*  operation will bitwise OR the value of *p_num to set the desired   */
/*  bit(s).  The get operation will operate as is always has in that   */
/*  it will simply retrieve the 32-bit value                           */
/*=====================================================================*/


void som_set_os_type (OMuword osnum, int *p_num, unsigned char flag)
{
   extern int  *OM_GA_OSflags;

   /*  make a quick osnum check - do nothing if invalid  */

   if (osnum > OM_Gw_maxOS) return;

   if (flag == 1)
      OM_GA_OSflags[osnum] |= *p_num;
   else if (flag == 2)
      OM_GA_OSflags[osnum] &= ~(*p_num);
   else
      *p_num = OM_GA_OSflags[osnum];
}



/****************************************************************/
/* routine to display the formatted contents of a file header */
void dump_filehdr(p_filehdr)
struct OM_sd_OS_filehdr_OM *p_filehdr;

{
   printf("OM: %d.%d     File size: %d bytes\n",
      p_filehdr->w_major_version,p_filehdr->w_minor_version,p_filehdr->i_size);

   printf("Processor: %s, %s     Node: %s\n",
      p_filehdr->syst.mach_name.sysname,p_filehdr->syst.mach_name.machine,
      p_filehdr->syst.mach_name.nodename);
   printf("Unix System V/%s, version %s\n",p_filehdr->syst.mach_name.release,
      p_filehdr->syst.mach_name.version);
   printf("OSO classname: %s\n",p_filehdr->s_OSO_classname);
   printf("OSO/Cls 0 fp: %d     ",p_filehdr->fp_OSO);
   printf("OSO oid: %d\n",p_filehdr->S_OS_object);

   printf("Spacemap: %d entries     ",p_filehdr->i_spacemap_size);
   printf("Cls 0 Desc fp: %d\n",p_filehdr->fp_cluster0);
   printf("checksum: %d\n",p_filehdr->checksum);
}

/*****************************************************************/
/* routine to display the formatted contents of an osd entry. */

void dump_osd(p_osd)
OM_p_OSD p_osd;		/* pointer to the osd entry */

{
int i;
char buffer[OM_K_MAXOSNAME_LEN];

	if(!p_osd) return;	/* dont try to print off of null ptr */

i=strlen(p_osd->InternalName);
if (i > OM_K_MAXOSNAME_LEN)
{
   printf("Warning. Name is longer than allowed max \n");
   strncpy(buffer,p_osd->InternalName,OM_K_MAXOSNAME_LEN);
   printf("Int name: %s\n",buffer);
}
else  printf("Int name: %s\n",p_osd->InternalName);
	printf("osname: %s\n", p_osd->name);

printf("OSO oid: %d Group 0 oid: %d osnum: %d \n",
	p_osd->OSO_Oid,p_osd->Group0_Oid,p_osd->OSnum);

	printf("Type:");
	switch(p_osd->type)
	{
	   case (OM_OSD_MOSDOS):	printf(" MOSDOS"); 	break;
	   case (OM_OSD_trans):	printf(" Transient");	break;
	   case (OM_OSD_filed):	printf(" Filed");	break;
	   default:		printf(" Unknown OSD type(%X) (hex)",p_osd->type);
	}

	if (p_osd->flags)
	{
	  printf("Flag(s): ");
	  if(p_osd->flags&OM_OSD_inuse)		  printf("Inuse ");
	  if(p_osd->flags&OM_OSD_nowrite)	  printf("Nowrite ");
	  if(p_osd->flags&OM_OSD_compress_on_wrt) printf("Compress_on_wrt ");
	  if(p_osd->flags&OM_OSD_modified)	  printf("Modified ");
	  if(p_osd->flags&OM_OSD_ISOmodified)     printf("ISOmodified ");
	  if(p_osd->flags&OM_e_loados_ro)         printf("read only ");
	  if(p_osd->flags&OM_OSD_Rootdel_pending) printf("Delete pending ");
	}
	else printf("None");

	printf("A/F: %8X ",p_osd->ActToFil);
	printf("F/A: %8X \n",p_osd->FilToAct);
	printf("Spacemap @: %8X size: %d\n",
		p_osd->Spacemap,p_osd->CurSpaceMapSize);
	printf("# clusters: %d Clusters %8X\n",	
		p_osd->ClustersSize,p_osd->Clusters);

}

/************************************************************************/
/* routine to dump an OSO instance definition. */
void dump_oso(p_oso)
struct OMObjSpace_instance *p_oso;

{
printf("Creation _time and date  = %16s\n",	p_oso->CreTimeDate);
printf("Time and date of last write = %16s\n",	p_oso->TimeDate);

/* display the osd portion of the oso */

dump_osd(&p_oso->OSD);

}

end	implementation	OMObjSpace;
