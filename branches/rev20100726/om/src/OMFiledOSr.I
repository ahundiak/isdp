/* 

	OMFiledOSr.I	methods used in reading and writing OS's
	
	change history:
	6-87 jkm change cluster 0 allocation field at write time to equal
		the size field. This number is used to get memory when the
	 	OS is loaded. Now that the size field is  aligned,
		we don't need a separate number to get memory with.

	1-27-88
	sw-cgp	
		split up into OMFiledOSr.I for read/write portions

        2-92   Support reading little endian file (Clipper) into big
               endian memory (Sun).  Changes were to convert the file
               header, the OSO size field and the OSO instance data
               after they were read in.  The rest of the Cluster 0
               objects get read and converted by OMCluster.fault.
*/

class	implementation	OMFiledOS;

#include "exsysdep.h"
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include "UNIXerrdef.h"
#include "OMmacros.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMminimum.h"
#include "OMmetaclass.h"
#include "OMOSfilehdr.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "OMcluster.h"
#include "OMparameters.h"
#include "OMtags.h"
#include "OMobjspace.h"
#include "version.h"

#ifdef BIG_ENDIAN
#include "OMport.h"

extern  int    som_bigend_portHdr();
extern  int    som_convert_instance();
extern  OMuint OM_Gf_ioMode;
#endif

extern  int     OM_channum_init();
extern  int     OM_make_internal_OS_name();

extern  OMuint  OM_Gi_transOS_size;
extern  int  OM_Gi_transOS_extsize;
extern  OMuint  OM_Gi_transOS_numobjs;
extern  int  OM_Gi_transOS_extobjs;
extern  OMuint  OM_Gi_defMOSD_initsize;
extern  OMuint  OM_Gi_defMOSD_extsize;
extern  OMuint  OM_Gi_defMOSD_numobjs;
extern  OMuint  OM_Gi_defMOSD_extobjs;
extern  int     OM_Gi_number_of_appl_ids;
extern  INGR_p_PRODUCT_DEF OM_GA_appl_version[];
extern  int     *OM_GA_OSflags;

extern  OMuword  OM_Gw_RO_OS_count;
extern  OM_p_DUPINTOS  OM_Gp_dup_intosname;
extern  OMuint  OM_Gf_fileLocking;
extern  OMuint  OM_Gf_process_unknowns;

from OMMOSD	import add_entry,delete_entry,modified_OS_wrt;
from OMGroup	import init_spacemap;
from OMOSCO	import initialize, set_up;
from OMTagCon   import set_up;
from OMTag      import set_up;



/* ========================= init =================================*/
method init()
/* 	
	Method init for OMFiledOS

	arguments: none

	purpose:to initialize the OSD after having read in a filed os.

	used by: the load_objspace routine, in response to a construct
		  os by a user on an existing filed object space.

	logic:  follows. This is fairly complicated as a result of the
		bootstrapping that must go on. This bootstrapping is
		spread over several routines.

 this method will be used when reading in a filed object space. it
is called after the object space is loaded.  At invocation, we are not
yet the real oso. Here is the current state of things:
. The real cluster 0 is loaded into storage. The real Cluster 0 object
  points to the cluster decriptor for cluster 0.
. there is a phantom osd pointed to by OM_GA_OSDs
. that phantom osd has a Clusters[0].ClustCmp pointing to the real cluster 0 
  cluster composite structure. There is space allocated for all the
  clusters to fill in their addresses via the establish method.
. that phantom osd has a pointer to the real spacemap
. that spacemap points correctly to us, otherwise we wouldnt be here. That
  spacemap also points correctly to all the objects in cluster 0.
here are the steps we must take to become the real osd:
o  point our Spacemap pointer to the spacemap in the phantom object.The
   real osd will then point to the real spacemap.
o  allocate a pointer to cluster descriptors & cluster swap info pointed 
   to by Clusters.
   (Clusters is a pointer to an array of a pair of pointers)
o  set our Clusters[0].ClustCmp equal to the Clusters[0].ClustCmp 
   in the osd. Then the real
   osd will point to the real Cluster composite for the real cluster 0 
   through the Clusters pointer
o  set our ClustersSize = 1, since we have only one cluster composite
o  point our active to filed and filed to active pointers to the ptrs out of
   the phantom OSD.
o  going through OM_GA_OSDs, free up the phantom OSD.
o  point OM_GA_OSDs to our OSD. We are now the real osd.

other initializations include:
set our flag to inuse
send a message to the OSCO's to adjust the filed to active and active to filed
  maps.
send a message to all cluster objects but 0 to adjust the spacemap to
  show which oids are valid but not faulted in. 
send a message to all clusters to fill their addresses into the clustcmp array.
  note that the cluster 0 is already filled in.
send a message to all the groups to build their free lists
adjust our osnum to the current os.

----------- Revision History ----------------------------------------

Apr-21-87  EMS  add channel send of OMTagCon.set_up

Apr-21-87  RME  add channel send of OMTag.set_up
---------------------------------------------------------------------
*/
{
   int               sts;
   OM_S_CHANSELECT   chan;

   /* we are now the official oso. Tell the OSCOS to adjust the
    * filed to active and active to filed maps. we are doing this
    * first so that the sends to the groups and clusters will not
    * depend on the groups and clusters being metaclasses; that is,
    * if someone has subclassed off of group or cluster then the
    * active to filed maps have to be filled in before the send.
    * Since OSCO is a metaclass its filed to active translation is
    * always the same so thais send will work ok. We dont allow
    * subclassing off of OSCOs.
    *
    * allocate the list of ptr to osco's */

   if((ME.OMObjSpace->OSD.OSCO_list =
      om$calloc(num=OM_Gw_numclasses,structure=OM_p_OSCO)) == NULL)
      return (OM_E_NODYNMEM);

   if ( p_ACLD->w_classid >= OM_K_NUM_META_CLASSES )
      om$vla_fixup(p_object=(OM_p_OBJECTHDR) me,type='r');

   chan.type = OM_e_addr;
   chan.u_sel.addr=&ME.OMObjSpace->to_OSCOs;
   if(!(1&(sts = om$send(p_chanselect=&chan,msg=message OMOSCO.set_up())))) 
      return(sts);

   OM_channum_init();    /* this is for unknown classes */

   /* tell all the cluster objects to update the spacemap to
    * indicate oids which are not in memory
    */

   chan.u_sel.addr=&ME.OMObjSpace->to_ClusDscs;
   if (!(1&(sts=om$send(p_chanselect=&chan,msg=
      message OMCluster.adjust_spacemap()))))
      return(sts);

   /* now tell the groups to build their free lists */

   chan.u_sel.addr=&ME.OMObjSpace->to_GrpDscs;
   sts=om$send(p_chanselect=&chan,msg=
		message OMGroup.init_spacemap(OM_Gi_filedOS_extobjs,
		OM_Gi_filedOS_numobjs,ME.OMObjSpace->OSD.Group0_Oid,
		OM_OSD_filed,0));
   if ((sts != OM_W_UNKNOWN_MSG) && (sts != OM_S_SUCCESS)) return(sts);

   /* Reset the ISO's. */

   sts = om$send(msg      = message OMObjSpace.resolve_ISOs(),
                 targetid = my_id );
   if (!(1&sts)) return(sts);
        
   /*  issue a channel send to set up the TagCon data structures  */

   chan.u_sel.addr = &ME.OMObjSpace->to_GrpDscs;
   sts = om$send ( msg = message OMTagCon.set_up(),
                        p_chanselect=&chan );
   if ((sts != OM_W_UNKNOWN_MSG) && (sts != OM_S_SUCCESS)) return(sts);
        
   /*  issue a channel send to set up the OMTag data structures  */

   sts = om$send ( msg = message OMTag.set_up(),p_chanselect=&chan );
   if ((sts != OM_W_UNKNOWN_MSG) && (sts != OM_S_SUCCESS)) return(sts);

   /* If file locking is on, we may need to do something special for
    * read-only files.
    * At level 1, if we've gotten this far, then our lock file is
    * already set up ok for modify access or read-only access.
    * At level 2, we should fault in all clusters if this is a
    * read-only file.
    */

   if ((OM_Gf_fileLocking == 2) &&
      ((ME.OMObjSpace->OSD.flags & OM_e_loados_ro) ||
       (ME.OMObjSpace->OSD.flags & OM_OSD_nowrite) ||
#ifndef NT
       access(ME.OMObjSpace->OSD.name, 02)))
#else
       _access(ME.OMObjSpace->OSD.name, 02)))
#endif
   {
      OMuint   ii;

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

   return (OM_S_SUCCESS);
}



/**************************************************************/
int load_objspace(osfile,osnum,p_objid, osname, sameosflag, loadmode)
OMuword	osnum;		/* asssigned os number 	*/
FILE	*osfile;	/* already open file	*/
OM_p_OBJID	p_objid;	/* oid of the oso */
char	*osname;	/* name of the file */
char	sameosflag;	/* if true and no ISOs, reload os */
OMuint  loadmode;       /* loading mode (RO or RW) */
{
/* routine to load in an existing objspace */
/* steps:
/* load in the header, verify, get ptrs to the oso and the oso oid.
/* create a phantom oso.
/* create the real spacemap, pointed to by the phantom oso
/* point OM_GA_OSDs to the phantom oso
/* create a phantom LCD (for cluster0) object. 
/* call get_extent to get some memory. It will place values into the phantom
/*	cluster object
/* load in cluster 0 from the file.
/* point the spacemap to the real oso (and thus the real cluster 0)
/* reset the send depth in the osd to 0 (it was elevated at write time)
/* from the ACLD, get the offset to cluster data. Using that, place the
/*	address of the extent descriptor in the real cluster 0.
/* send a fault message to the oso oid. This will
/* o check to see if it cluster 0. It is, so it will not call get_extent
/* o update the spacemap to point to all the objects in cluster 0. It will
/* 	use the address of the extent as recorded in the extent descriptor.
/* toss the vla of oids.
/* (return from message)
/* save the address of the spacemap, obtained by going through the phantom oso
/* going through OM_GA_OSDs, free up the phantom oso.
/* point OM_GA_OSDs to the real oso.
/* send an init message to the oso oid, which will:
/* set its inuse flag to inuse
/* allocate the real Clusters array (size = ClustersSize)
/* send a message to all but cluster 0 objects to initialize their spacemap
/*   entries
/* Send an establish message to all clusters.
/* send a message to all group objects to set up their free lists.
*/

OM_S_OS_FILEHDR hdr;			/* ptr to file hdr read in */
OM_p_LCD	pLCD, pNewLCD;		/* pointers to LCD */
OM_p_PCD        pPCD, pPCD2;            /* temp ptr to PCD */
OMuint          clusterOffset;          /* offset of OMCluster in object */
OMuint 		oso_offset;	        /* offset of OMObjSpace in instance*/
char            *t_oso;                 /* pointer to temp OSO */
struct OMObjSpace_instance *pOSO;	/* ptr to OMObjSpace part of it */
OM_p_OBJECTHDR  pNewObj;
int             osoSize;		/* place for OSO size */

int 		sts, j, found, count, previousEmptyIndex;
char		changeintosname=FALSE;
OMuword 	i, ii, oso_classid, oldOsnum, dup_osnum=0;
char            appver[OM_K_APPVER_LEN];
OM_p_DUPINTOS   p_dupint, p_dupnew;

   /* Read the file header */
	
   fseek(osfile, 0, 0);
   if (fread(&hdr,1,sizeof(OM_S_OS_FILEHDR),osfile) != sizeof(OM_S_OS_FILEHDR))
      return(OM_E_READ_ERROR);

#ifdef BIG_ENDIAN
   /* Call routine to read the file header (in Clipper format),
    * convert it to big endian and put the results in 'hdr'.
    */

   OM_Gf_ioMode = READ_PORT;
   som_bigend_portHdr((OM_S_OS_FILEHDR *) &hdr.magic);
#endif

   /*  check the OM version of the file for compatability  */

   if ((hdr.w_major_version != OM_Gw_major_version) ||
       (hdr.w_minor_version > OM_Gw_minor_version))
      return (OM_F_VERSION_MISMATCH);

   /* Get application flags from file header */

   OM_GA_OSflags[osnum] = hdr.os_flags;

   /* Read in the application version stamps
    * (same for big endian as for little endian)
    */

   if (hdr.i_num_appver)
   {
      fseek(osfile, hdr.fp_appver, 0); /* Point to application version stamps */
      for (i=0; i<hdr.i_num_appver; ++i)
      {
         found = 0;
         if (OM_K_APPVER_LEN != (fread(appver,1,OM_K_APPVER_LEN,osfile)))
         {
            fprintf(stderr,"load_objspace: Error reading appl version\n");
            return (OM_E_READ_ERROR);
         }
         previousEmptyIndex = -1;
         for (j=count=0; (j<MAXNUMAPPVER) && (count<OM_Gi_number_of_appl_ids);
            ++j)
         {
            if (!OM_GA_appl_version[j])
            {
               previousEmptyIndex = j;
               continue;
            }
            count++;
            if (!strncmp(appver,OM_GA_appl_version[j]->curr_version,
                      OM_K_APPVER_ID_LEN))   /* Compare product name string */
            {
               /*  Call the application version compare function  */

               found = 1;
               if ( OM_GA_appl_version[j]->version_check_func )
               {
                  sts = OM_GA_appl_version[j]->version_check_func(
                     OM_GA_appl_version[j]->curr_version, appver );
                  if (!(1&sts)) return (sts);
               }
               break;
            }
         }
         if ((OM_Gf_process_unknowns || (loadmode != OM_e_loados_ro)) &&
            !found && ((previousEmptyIndex != -1) ||
            (OM_Gi_number_of_appl_ids < MAXNUMAPPVER)))
         {
            /* Version stamp in file not currently in array, so
             * store it at end of array & increment counter of
             * application version stamps in memory.
             */

            if (previousEmptyIndex != -1)
               j = previousEmptyIndex;
            if (!(OM_GA_appl_version[j] = (INGR_p_PRODUCT_DEF)
	       om$malloc(size = sizeof(INGR_S_PRODUCT_DEF))))
	       return(OM_E_NODYNMEM);

            if (!(OM_GA_appl_version[j]->curr_version =
	       (char *) om$malloc(size = OM_K_APPVER_LEN)))
               return(OM_E_NODYNMEM);
            OM_GA_appl_version[j]->
               version_check_func = NULL;
            strcpy(OM_GA_appl_version[j]->curr_version, appver);
            OM_GA_appl_version[j]->appl_specifics = (char *)
               0xabadaba;  /* Show that this appver was brought in from file */
            OM_Gi_number_of_appl_ids++;
         }
      }
   }

#ifdef DEBUG
printf("\nload_objspace:  OM_Gi_number_of_appl_ids %d\n",
   OM_Gi_number_of_appl_ids);
for(i=j=0; (i<MAXNUMAPPVER) && (j<OM_Gi_number_of_appl_ids); i++)
{
   if (!OM_GA_appl_version[i])
   {
      printf("[%d]:NULL\n", i);
      continue;
   }
   j++;
   printf("[%d]:%s  0x%x\n",
      i,
      OM_GA_appl_version[i]->curr_version,
      OM_GA_appl_version[i]->appl_specifics);
}
#endif

   /**** Set up the Object Space Object ****/

   /* Get the OSO's active class id */

   if (!(1&(sts = om$get_classid (osnum=osnum,
      classname=hdr.s_OSO_classname, p_classid= &oso_classid))))
      return(sts);

   /* The file header points us to the OSO.  Read its size field (last
    * field in the file object header structure), which is the in-memory
    * size plus some flag bits, allocate a buffer to (temporarily) hold
    * the OSO and read it in.
    */

   fseek(osfile, (hdr.fp_OSO + (sizeof(OM_S_FILEOBJHDR) - sizeof(OMuint))), 0);

   if (sizeof(int) != (fread (&osoSize, sizeof(char), sizeof(int), osfile)))
      return(OM_E_READ_ERROR);

#ifdef BIG_ENDIAN
   som_swapint(&osoSize, &j);   /* Reverse byte order to big endian */
   osoSize = j;
#endif

   osoSize &= 0xfffffff8;     /* Strip off the flag bits */
   if (!(t_oso = om$malloc(size = osoSize)))
      return(OM_E_NODYNMEM);
   fseek(osfile, -((int) sizeof(OM_S_OBJECTHDR)), 1);  /* Back up to oid field */
   if (!((int) fread(t_oso, sizeof(char), osoSize, osfile) == osoSize))
      return(OM_E_READ_ERROR);

#ifdef BIG_ENDIAN

   /* Convert the OSO instance data to big endian */

   if (!(pOSO = (struct OMObjSpace_instance *) om$malloc(size = osoSize)))
      return(OM_E_NODYNMEM);
   blkmv(osoSize, t_oso, (char *) pOSO);
   if (!(1&(sts=som_convert_instance(pOSO, t_oso,
      OM_GA_active_classes[oso_classid]))))
      return(sts);
   om$dealloc(ptr=(char *) pOSO);
#endif

   /* before going further, check to see if the internal os name
    * in the file (inside the OSD) matches any others in the running
    * system. If it does, this is an error. */

   FIND_ANC_OFFSET (sts,OM_GA_active_classes[oso_classid],
		    OM_K_OMOBJSPACE_ACTCLASSID,oso_offset);
   if (sts != 1)
      return(OM_E_BADCLASSNAME);

   pOSO = (struct OMObjSpace_instance *)(t_oso + oso_offset);
  
   FIND_ANC_OFFSET (sts,OM_GA_active_classes[oso_classid],
		    OM_K_OMCLUSTER_ACTCLASSID,clusterOffset);
   if (sts != 1)
      return(OM_E_BADCLASSNAME);

   /* now trudge through the rest of the object spaces, comparing
    * the internal name with this internal name
    * if equivalent internal name found and sameosflag is true
    * and no ISOs exist; change internal name and continue */

   for (i=0; i < OM_Gw_maxOS; i++)
   {
      if (OM_GA_OSDs[i] && !(strcmp(pOSO->OSD.InternalName,
         OM_GA_OSDs[i]->InternalName)))
      {
         if (sameosflag && (! (pOSO->iso_d_descr.i_count)))
         {
            changeintosname = TRUE;
            dup_osnum = i;
            break;
         }
         else
         {
            om$dealloc (ptr = (char *) t_oso);
            return(OM_W_OBJSPACE_EXISTS);
         }
     }
   } /* for */

   /* now construct what will be the real spacemap. the old size
    * of the spacemap is stored in the header in the variable
    * i_spacemap_size. Point to it out of the phantom oso 
    */

   if((pOSO->OSD.Spacemap = om$calloc(structure=OM_S_SPAMAPENT,
                                     num=hdr.i_spacemap_size)) == NULL)
   {
      om$dealloc (ptr = (char *) t_oso);
      return (OM_E_NODYNMEM);
   }

   /* point OM_GA_OSDs to the phantom osd */

   OM_GA_OSDs[osnum] = &(pOSO->OSD);

   /* create a phantom active to filed and filed to active map
    * get some memory for the active to filed  map 
    */

   if (!(OM_GA_OSDs[osnum]->ActToFil = (OMuword *) om$malloc 
       		(size=OM_Gw_numclasses*sizeof(OMuword))))
   {
      om$dealloc (ptr = (char *) t_oso);
      return (OM_E_NODYNMEM);
   }
   /* get some memory for the filed to active  map */
    
   if (NULL == (OM_GA_OSDs[osnum]->FilToAct = (OMuword*) om$malloc 
       		(size=OM_Gw_numclasses*sizeof(OMuword))))
   {
      om$dealloc (ptr=(char *) OM_GA_OSDs[osnum]->ActToFil);
      OM_GA_OSDs[osnum]->ActToFil = NULL;
      om$dealloc (ptr = (char *) t_oso);
      return (OM_E_NODYNMEM);
   }

   /* initialize the active to filed and filed to active maps */
  
   for (ii=0; ii < OM_K_NUM_META_CLASSES;ii++)
   {
      OM_GA_OSDs[osnum]->ActToFil[ii] = ii;
      OM_GA_OSDs[osnum]->FilToAct[ii] = ii;
    }
   for (ii=OM_K_NUM_META_CLASSES; ii < OM_Gw_numclasses; ii++)
   {
      OM_GA_OSDs[osnum]->ActToFil[ii] = 0;
      OM_GA_OSDs[osnum]->FilToAct[ii] = 0;
   }

   /* now, using the oso oid in the file header, point the spacemap 
    * entry corresponding to it to the place where the oso and
    * cluster 0 object are. then we can send a 'fault' message to
    * that cluster. fp_OSO - fp_Cluster0 gives us a displacement
    * from the beginning of the cluster to the oso.
    * These details must be considered.
    *
    * 1.We have
    * to set the CurSpaceMapSize variable in the phantom OSD. the macro
    * get_instance uses this variable as verification so it must be valid.
    * fortunately, we have the value handy from the file header. We wont
    * need to carry that over to the real spacemap since it will already
    * have it.
    *
    * 2. The other detail is that we place, in the file to active
    * and ative to file maps, the translation for the class
    * which represents the oso and the cluster 0 object. We can pull
    * the filed id out of the object header once the spacemap points
    * to it. we will call get_classid to get the active classid. When
    * the initialize oso routine is called, the osco's will adjust
    * the maps themselves 
    *
    * 3. We have to place the oid of the oso/cluster 0 object into the
    * phantom OSD. We do this becausethe cluster object will check to
    *
    * 4. We have to set the send depth in the osd to 0. It was raised
    * at write time.
    */

   OM_GA_OSDs[osnum]->CurSpaceMapSize = hdr.i_spacemap_size;
   OM_GA_OSDs[osnum]->Spacemap[hdr.S_OS_object].p_acld = 
      OM_GA_active_classes[oso_classid];
   OM_GA_OSDs[osnum]->Spacemap[hdr.S_OS_object].sdi = 0;
   OM_GA_OSDs[osnum]->Spacemap[hdr.S_OS_object].flags = 
      (OM_SM_in_mem | OM_SM_in_use);
   OM_GA_OSDs[osnum]->Spacemap[hdr.S_OS_object].state.object = 
      (OM_p_OBJECTHDR) t_oso;

   /* adjust the active to filed and filed to active maps */

   /*  Make sure the filed to active map is big enough first ! */

   if (hdr.OSOfiledClassid >= OM_GA_fa_mapsize[osnum])
   {
      if (!(OM_GA_OSDs[osnum]->FilToAct = 
         (OMuword *)om$realloc(ptr=(char *) OM_GA_OSDs[osnum]->FilToAct,
         size=(hdr.OSOfiledClassid+1) *  sizeof(OMuword)) ))
         return (OM_E_NODYNMEM);
      for (ii = OM_Gw_numclasses; ii < (OMuword) (hdr.OSOfiledClassid + 1);
           ++ii)
         OM_GA_OSDs[osnum]->FilToAct[ii] = 0;
      OM_GA_fa_mapsize[osnum] = hdr.OSOfiledClassid + 1;
   }/* if the oso filed classid is bigger than the size of the map */

   OM_GA_OSDs[osnum]->ActToFil[oso_classid] = hdr.OSOfiledClassid;
   OM_GA_OSDs[osnum]->FilToAct[hdr.OSOfiledClassid] = oso_classid;

   if (!(pOSO->OSD.Clusters = (OM_p_LCD *)
      om$calloc(num=pOSO->OSD.ClustersSize, size = sizeof(OM_p_LCD))))
   {
      om$dealloc (ptr=(char *) OM_GA_OSDs[osnum]->ActToFil);
      OM_GA_OSDs[osnum]->ActToFil = NULL;
      om$dealloc (ptr=(char *) OM_GA_OSDs[osnum]->FilToAct);
      OM_GA_OSDs[osnum]->FilToAct = NULL;
      om$dealloc (ptr = (char *) t_oso);
      return (OM_E_NODYNMEM);
   }
  
   FIND_ANC_OFFSET (sts,OM_GA_active_classes[oso_classid],
		    OM_K_OMCLUSTER_ACTCLASSID,clusterOffset);

   pLCD = (OM_p_LCD)
      &(((struct OMCluster_instance *)((OMuint)t_oso + clusterOffset))->lcd);
   pOSO->OSD.Clusters[0] = pLCD;
   pOSO->OSD.OSnum = osnum;

   /* indicate that we arent being deleted */

   pOSO->OSD.flags &= ~OM_OSD_Rootdel_pending;
   if (loadmode == OM_e_loados_ro ) pOSO->OSD.flags |= OM_e_loados_ro;

   /* fix up PCD listhead in Cluster0 LCD */

   pLCD->pcdq_lh.next = &(pLCD->pcdq_lh);  /* fix up listhead */
   pLCD->pcdq_lh.prev = &(pLCD->pcdq_lh);

   /* send a fault message to the cluster 0 object
    * since we are not in a method, and since previous events
    * could result in us being in a bad state here w.r.t. the 'current'
    * os, we will make_current_os to us if our osnum is the same as
    * the current. Send foreign will not execute make_current_os unless
    * the two are different .. The problems would amount to pointers
    * which are different that should be the same.
    */

   oldOsnum = OM_Gw_current_OS;
   om$make_current_os (osnum=osnum);
   sts = om$send (targetid=hdr.S_OS_object, senderid=NULL_OBJID,
	               msg=message OMCluster.fault ((int) osfile));
   OM_GA_CSDarray[0].PostSendDepth++;  /* fix up temporary borrowing */

   if (!(1&(sts)))
   {
      om$dealloc (ptr = (char *) pOSO->OSD.Clusters);
      om$dealloc (ptr=(char *) OM_GA_OSDs[osnum]->ActToFil);
      OM_GA_OSDs[osnum]->ActToFil = NULL;
      om$dealloc (ptr=(char *) OM_GA_OSDs[osnum]->FilToAct);
      OM_GA_OSDs[osnum]->FilToAct = NULL;
      om$dealloc (ptr = (char *) t_oso);
      om$make_current_os (osnum=oldOsnum);
      return(sts);
   }

   OM_GA_CSDarray
     [OM_GA_OSDs[osnum]->Spacemap[hdr.S_OS_object].sdi].PreSendDepth++;
   pNewObj = OM_Gp_CurSpaceMap[hdr.S_OS_object].state.object;
   strncpy(((struct OMObjSpace_instance *)
      ((OMuint) pNewObj + oso_offset))->TimeDate,
      &hdr.start_time[4], 15);
   OM_GA_OSDs[osnum] = (OM_p_OSD) 
      &(((struct OMObjSpace_instance *) ((OMuint) pNewObj + oso_offset))-> OSD);
   OM_GA_OSDs[osnum]->CurSpaceMapSize = pOSO->OSD.CurSpaceMapSize;
   OM_GA_OSDs[osnum]->Spacemap = OM_Gp_CurSpaceMap;
   OM_GA_OSDs[osnum]->FilToAct = pOSO->OSD.FilToAct;
   OM_GA_OSDs[osnum]->ActToFil = pOSO->OSD.ActToFil;
   OM_GA_OSDs[osnum]->OSnum = osnum;
   OM_GA_OSDs[osnum]->Clusters = pOSO->OSD.Clusters;
   for (i=0; i<OM_K_MAXOSNAME_LEN;i++)
      OM_GA_OSDs[osnum]->name[i] = 0;
   strcpy(OM_GA_OSDs[osnum]->name,osname);
  
   /* null the LCF queue, since no clusters can (by definition) have
      been faulted in yet (except cluster 0, which does not belong
      on this queue) */
           
   OM_GA_OSDs[osnum]->lcfq_lh.next = (OM_p_DLINK)
      &(OM_GA_OSDs[osnum]->lcfq_lh.next);
   OM_GA_OSDs[osnum]->lcfq_lh.prev = (OM_p_DLINK)
      &(OM_GA_OSDs[osnum]->lcfq_lh.next);
   OM_GA_OSDs[osnum]->flags = pOSO->OSD.flags;

   pNewLCD = (OM_p_LCD) &(((struct OMCluster_instance *)
      ((OMuint)pNewObj + clusterOffset))->lcd);

   /* get ptr to (just) established (1st) PCD; then copy old LCD into
      new LCD; then "reinit" new LCD's PCD queue; then point PCDs back
      to new LCD */
      
   pPCD = (OM_p_PCD) (pLCD->pcdq_lh.next);
   pPCD2 = (OM_p_PCD) (pLCD->pcdq_lh.prev);
   *pNewLCD = *pLCD;                                     /* copy into new LCD */
   ((OM_p_DLINK)(pPCD))->prev = &(pNewLCD->pcdq_lh);     /* fix up listhead */
   ((OM_p_DLINK)(pPCD2))->next = &(pNewLCD->pcdq_lh);
   while (pPCD != (OM_p_PCD) &(pNewLCD->pcdq_lh))
   {
      pPCD->p_lcd = pNewLCD;
      pPCD = (OM_p_PCD) (pPCD->pcdq.next);
   }
   OM_GA_OSDs[osnum]->Clusters[0] = pNewLCD;

   /* since we changed the @ of the osd, we have to reset
    * the global ptr to the osd .. */

   om$make_current_os (osnum=osnum);

   /*  get rid of temporary OSO */

   om$dealloc (ptr = (char *) t_oso);

   /*  must change name prior to init method where TagCon and ISOs  */
   /*  rely on unique internal names to exist                       */

   if (changeintosname) {

      /*  build data structure to remember that internal name changed  */
      /*  check if dup_osnum has an entry - if not make one  */

      p_dupint = OM_Gp_dup_intosname;
      while (p_dupint) {
         if (p_dupint->osnum == dup_osnum) break;
         p_dupint = p_dupint->next;
      }
      if (!p_dupint) {
         p_dupnew = (OM_p_DUPINTOS)om$malloc(size = sizeof(OM_S_DUPINTOS));
         if (!p_dupnew) return(OM_E_NODYNMEM);
         p_dupnew->dup_osnum = (OMuword *)om$malloc(size = sizeof(OMuword));
         if (!p_dupnew->dup_osnum) return(OM_E_NODYNMEM);
         p_dupnew->osnum = dup_osnum;
         strncpy(p_dupnew->orig_intname,OM_GA_OSDs[dup_osnum]->InternalName,
                 OM_K_MAXINTOSNAME_LEN);
         p_dupnew->num_dup = 1;
         p_dupnew->dup_osnum[0] = osnum;
         p_dupnew->next = OM_Gp_dup_intosname;
         OM_Gp_dup_intosname = p_dupnew;
      }
      else {
         p_dupint->dup_osnum = (OMuword *)om$realloc ( 
              ptr = (char *) p_dupint->dup_osnum, 
              size = ++p_dupint->num_dup * sizeof(OMuword));
         if (!p_dupint->dup_osnum) return (OM_E_NODYNMEM);
         p_dupint->dup_osnum[p_dupint->num_dup-1] = osnum;
      }

      /*==================================*/
      /*  create a new entry for this os  */
      /*==================================*/

      p_dupnew = (OM_p_DUPINTOS)om$malloc(size = sizeof(OM_S_DUPINTOS));
      if (!p_dupnew) return(OM_E_NODYNMEM);
      p_dupnew->dup_osnum = (OMuword *)om$malloc(size = sizeof(OMuword));
      if (!p_dupnew->dup_osnum) return(OM_E_NODYNMEM);
      p_dupnew->osnum = osnum;
      strncpy(p_dupnew->orig_intname,OM_GA_OSDs[dup_osnum]->InternalName,
              OM_K_MAXINTOSNAME_LEN);
      p_dupnew->num_dup = 1;
      p_dupnew->dup_osnum[0] = dup_osnum;

      /*====================================*/
      /*  check for other dups for this os  */
      /*====================================*/

      p_dupint = OM_Gp_dup_intosname;
      while (p_dupint) {
         for (i=0; i<p_dupint->num_dup; ++i) { 
            if (p_dupint->dup_osnum[i] == dup_osnum) {
               p_dupnew->dup_osnum = (OMuword *)om$realloc ( 
                   ptr = (char *) p_dupnew->dup_osnum, 
                   size = ++p_dupnew->num_dup * sizeof(OMuword));
               if (!p_dupnew->dup_osnum) return (OM_E_NODYNMEM);
               p_dupnew->dup_osnum[p_dupnew->num_dup-1] = p_dupint->osnum;

               p_dupint->dup_osnum = (OMuword *)om$realloc ( 
                   ptr = (char *) p_dupint->dup_osnum,
                   size = ++p_dupint->num_dup * sizeof(OMuword));
               if (!p_dupint->dup_osnum) return (OM_E_NODYNMEM);
               p_dupint->dup_osnum[p_dupint->num_dup-1] = osnum;
            }
         }
         p_dupint = p_dupint->next;
      }

      /*======================*/
      /*  add to linked list  */
      /*======================*/

      p_dupnew->next = OM_Gp_dup_intosname;
      OM_Gp_dup_intosname = p_dupnew;
      OM_make_internal_OS_name(osname, OM_GA_OSDs[osnum]->InternalName);
   }

   /* send an init message to the oso object */

   if (!(1&(sts = om$send(targetid=hdr.S_OS_object, senderid=NULL_OBJID,
	                 msg=message OMFiledOS.init()))))
   {
      om$dealloc (ptr = (char *) pOSO->OSD.Clusters);
      om$dealloc (ptr = (char *) pOSO->OSD.OSCO_list);
      if (OM_GA_OSDs[osnum]->ActToFil)
      {
         om$dealloc (ptr=(char *) OM_GA_OSDs[osnum]->ActToFil);
         OM_GA_OSDs[osnum]->ActToFil = NULL;
      }
      if (OM_GA_OSDs[osnum]->FilToAct)
      {
         om$dealloc (ptr=(char *) OM_GA_OSDs[osnum]->FilToAct);
         OM_GA_OSDs[osnum]->FilToAct = NULL;
      }
      om$make_current_os (osnum=oldOsnum);
      return(sts);
   }

   /* tell the user what oid this oso is.. */
   /* and change the name of the object space to the file name */

   *p_objid = OM_GA_OSDs[osnum]->OSO_Oid;
   om$make_current_os (osnum=oldOsnum);
   return(OM_S_SUCCESS);
}

int dump_dups ()
{
   OMuword       os, i;
   OM_p_DUPINTOS p_dup;

   if (p_dup = OM_Gp_dup_intosname) {
      while (p_dup) {
         printf ("-----------------------------------\n");
         printf (" OSnum .............. %d\n",p_dup->osnum);
         printf (" OSname ............. %s\n",OM_GA_OSDs[p_dup->osnum]->name);
         printf (" InternalName ....... %s\n",OM_GA_OSDs[p_dup->osnum]->InternalName);
         printf (" Orig InternalName... %s\n",p_dup->orig_intname);
         printf (" NumDup ............. %d\n",p_dup->num_dup);
         for (i=0; i<p_dup->num_dup; ++i) {
            os = p_dup->dup_osnum[i];
            printf ("   %d) OSnum:%d  (%s)\n",i,os,OM_GA_OSDs[os]->name);
         }
         printf ("\n");
         p_dup = p_dup->next;
      }
   }
   else {
      printf (" No dups present\n");
   }
   return (OM_S_SUCCESS);
}


int som_inquire_os (
OMuword         osnum,
OM_p_DUPINTOS  *pp_dup)
{
   OM_p_DUPINTOS  p_dup;

   p_dup = OM_Gp_dup_intosname;
   while (p_dup) {
      if (p_dup->osnum == osnum) {
         *pp_dup = p_dup;
         return (OM_S_SUCCESS);
      }
      p_dup = p_dup->next;
   }
   *pp_dup = 0;
   return (OM_E_NO_OBJECT_SPACE);
}

end	implementation	OMFiledOS;


