class	implementation	OMCluster;

/*

	Revision history:

	9-88	saw001	When testing for outswapped cluster, if its pcd
			has a lump descriptor but not a slot descriptor
			then it is swapped out.

        9-89    saw002  Turns out that lcd.i_cur_bytes_allocated is still
                        untrustworthy.  clwrite depends on it to predict
                        cluster file size and to set up file hole list.
                        Since we're currently always rewriting files
                        anyway, we can do without depending on the hole
                        list altogether -- just pick up writing the next
                        cluster where the last one left off.
*/


#include <errno.h>
#include <assert.h>
#include "exsysdep.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMobjectcomm.h"
#include "OMlimits.h"
#include "OMerrordef.h"
#include "UNIXerrdef.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMmetaclass.h"
#include "OMcluster.h"
#include "OMparameters.h"
#include "OMOSfilehdr.h"

#ifdef BIG_ENDIAN
#include "OMport.h"

extern  void   som_swapint();
extern  void   som_swapshort();
extern  OMuint OM_Gf_ioMode;
#endif

extern  int    OM_PMS();
extern  int    OSval_obj();
extern  int    som_aligned_vla_size();
extern  int    som_convert_instance();
extern  int    som_csfwrite();

extern	OMuint			OM_Gf_validate_OS;
extern	OMuint			OM_Gi_checksum;
extern	OMuint			OM_Gi_phyClusterSize;

from OMFiledOS import get_freelist_ptr;



som_file_freelist(ptr_list, cl_start, cl_oldsize, cl_newsize)

OM_p_OSHOLE ptr_list;
OMuint *cl_start,cl_oldsize,cl_newsize;

/*=====================================================================*/
/*
/* Routine to manage the free list of space in the oso.
/*
/* ptr_list -- pointer to the array of structs that comprise the holes
/* cl_start -- pointer to the current starting position of the cluster
/*	       in the file
/* cl_oldsize -- the old byte size of the cluster
/* cl_newsize -- the new byte size of the cluster; space must be found
/*             for this
/*
/* There are 3 conditions that might be true when this routine is invoked:
/*   o  the cluster has grown in size and is searching for a new home
/*   o  the cluster is brand new and no place on the disk file exists.
/*   o  the cluster has decreased in size and it can be moved around.
/* If the cluster is the same size, then it can be rewritten to same spot.
/*
/* If cl_start is 0, then the cluster has no 'old' location
/* otherwise the cl_start will be used in trying to find a slot for the 
/* file.
/* Upon exiting, the cl_start passed back becomes the new 'starting position'
/* for the cluster in the file.
*/
{
   int i,j,k;

/* If the starting position is non-zero, that means that this cluster 
/* changed size and needs another place to be.  That means that its 
/* current location in the file is up for grabs.  So, before looking
/* for another place free up the current slot and consolidate its space
/* with that in the rest of the list.
*/

   if(*cl_start != 0)
   {
      /* Advance to the entry in the list which contains a file pointer
      /* greater than our starting position */

      for (i=0;;i++)
         if(ptr_list[i].FilePtr > *cl_start)
            break;
	
      /*==============================================================*/
      /* One of 6 things is true:   (for the first 4, i is != 0 )     */
      /*    1. This slot does not abut the slots on either side       */
      /*    2. This slot abuts the slot 'below' us but not the slot   */
      /*       'above'.                                               */
      /*    3. This slot abuts the slot 'above' us but not the slot   */
      /*       'below'.                                               */
      /*    4. This slot spans the distance between the two           */
      /*       surrounding slots.                                     */
      /*    5. i = 0 and the slot above abuts us.                     */
      /*    6. i = 0 and the slot above does not abut.                */
      /*                                                              */
      /* i now points to the a place where the file pointer is larger */
      /* than our cluster.                                            */
      /*==============================================================*/

/* --- Case 1. --- */
      /* This slot does not abut the slots on either side */
      if ((i) && (ptr_list[i-1].FilePtr + ptr_list[i-1].size  < *cl_start)
	      && (*cl_start + cl_oldsize  < ptr_list[i].FilePtr))
      {
         /* We have to add a slot. Find the end of the list */
         for(j=i;;j++)
            if(ptr_list[j].size == (OMuint) -1)
               break;

         /* Move all the slots from i to j up one */
         for(k=j; k>=i; k--)
         {
            ptr_list[k+1].FilePtr = ptr_list[k].FilePtr;
            ptr_list[k+1].size = ptr_list[k].size;
         }
         /* Now put this cluster at slot i */
         ptr_list[i].FilePtr = *cl_start;
         ptr_list[i].size = cl_oldsize;
      }

/* --- Case 2. --- */
      else
         /* this slot abuts the slot 'below' us but not the slot 'above'.*/
         if ((i) && (ptr_list[i-1].FilePtr + ptr_list[i-1].size == *cl_start)
                 && (*cl_start + cl_oldsize  < ptr_list[i].FilePtr))
         {
            ptr_list[i-1].size += cl_oldsize; /* Poof. The slot is bigger */ 
         }

/* --- Case 3. --- */
         else
            /* this slot abuts the slot 'above' us  but not the slot 'below'. */
            if ((i) && (ptr_list[i-1].FilePtr + ptr_list[i-1].size  < *cl_start)
                    && (*cl_start + cl_oldsize  == ptr_list[i].FilePtr))
            {
               /* redefine the larger slot. dont adjust size if is at eof */
               ptr_list[i].FilePtr = *cl_start;
               if (ptr_list[i].size != (OMuint) -1)
                  ptr_list[i].size += cl_oldsize;
            }

/* --- Case 4. --- */
            else
               /* This slot spans the distance between the two surrounding
                  slots. */
               if ((i)
                   && (ptr_list[i-1].FilePtr + ptr_list[i-1].size == *cl_start)
                   && (*cl_start + cl_oldsize  == ptr_list[i].FilePtr))
               {
                  /* Collapse the two slots together.  Shift the rest of the */
		  /* slots down one.  If we are at the end of the list we    */
		  /* can just make the previous slot the new end of list.    */
                  if(ptr_list[i].size == (OMuint) -1)
                     ptr_list[i-1].size = (OMuint) -1;
                  else
                  {
                     ptr_list[i-1].size += (ptr_list[i].size + cl_oldsize);
                     for (k=i; ; k++)
                     {
                        ptr_list[k].FilePtr = ptr_list[k+1].FilePtr;
                        ptr_list[k].size = ptr_list[k+1].size;
                        if(ptr_list[k].size == (OMuint) -1)
                           break;
                      }
                  }

               }

/* --- Case 5. --- */
               else
                  /* 5. i = 0 and the slot above abuts us. */
                  if ((!i) && (*cl_start + cl_oldsize == ptr_list[i].FilePtr))
                  {
                     /* Redefine the larger slot.  Don't adjust size if is */
                     /* at eof */
                     ptr_list[i].FilePtr = *cl_start;
                     if (ptr_list[i].size != (OMuint) -1)
                        ptr_list[i].size += cl_oldsize;
                  }

/* --- Case 6. --- */
                  else
                     /* 6. i = 0 and the slot above does not abut. */
                     if ((!i)
                         && (*cl_start + cl_oldsize < ptr_list[i].FilePtr))
                     {
                        /* We have to add a slot.  Find the end of the list */
                        for (j=i; ; j++)
                           if(ptr_list[j].size == (OMuint) -1)
                              break;
                        /* Move all the slots from i to j up one */
                        for(k=j; k>=i; k--)
                        {
                           ptr_list[k+1].FilePtr = ptr_list[k].FilePtr;
                           ptr_list[k+1].size = ptr_list[k].size;
                        }
                        /* Now put this cluster at slot i */
                        ptr_list[i].FilePtr = *cl_start;
                        ptr_list[i].size = cl_oldsize;
                     }

                     else /* --- we are in a bad state --- */
                     {
                        return(OM_F_BUGCHECK);
                     }
   }	/* End of if this cluster had to be added to the free list */


   /*====================================================================*/
   /* Now that we have added that cluster to the free list, we can begin */
   /* begin searching for a spot for it.                                 */
   /*====================================================================*/

   /* Now we look for a slot in the free list */

   for(i=0; ; i++)
   {
      /* if the bytes avail slot == -1, then this 'hole' represents the
      /* end of file and we can update the free list and the file pointer
      /* for the cluster in one fell swoop */
      /* change the newsize parm so it is rounded up to the next dw
      /* boundary*/
      if (ptr_list[i].size == (OMuint) -1)
      {
         *cl_start = ptr_list[i].FilePtr;
         ptr_list[i].FilePtr += cl_newsize;
         return(OM_S_SUCCESS);
      }	
	
      /* if the hole found is bigger than the slot, fill in new
      /* starting position and update that hole's starting position 
      */
      if (ptr_list[i].size > cl_newsize) 
      {
         *cl_start = ptr_list[i].FilePtr;
         ptr_list[i].FilePtr += cl_newsize;
         ptr_list[i].size -= cl_newsize;

         return(OM_S_SUCCESS);
      }

      /* if the hole is exactly the same size, then the slot can be
      /* assigned and the list shortened by one */

      if (ptr_list[i].size == cl_newsize) 
      {
         *cl_start = ptr_list[i].FilePtr;
         /* Move the entries in the list to close up the former hole. */
         for(j=i; ; j++)
         {
            ptr_list[j].FilePtr = ptr_list[j+1].FilePtr;
            ptr_list[j].size = ptr_list[j+1].size;
            if (ptr_list[j].size == (OMuint) -1)
               break;
         }

         return(OM_S_SUCCESS);
      }

   } /* end of loop through the free list looking for a slot */
}


/*=========================================================================*/

method adjust_spacemap()

/* This method will change spacemap entries to reflect oids which are in
 * use, but not faulted in.
 * if this is Cluster 0, just return, take care of p_acld field in spacemap
 * and vla fixup for cluster0's NON metaclass objects.
 * After adjusting the spacemap, get rid of the list of classid's since
 * we won't need it anymore.  Also, zero out pointers.
 */

{
   int    		i, k, sts;
   OMuword		a_classid;

   ME.OMCluster->lcd.p_osd = OM_Gp_CurOSD;  /* update this pointer */
   
   if(!ME.OMCluster->lcd.w_cluster_num)      /* Cluster 0 */
   {
      for(i=0; i < (int) ME.OMCluster->i_fil_num_objects; i++)
      {
        register OM_p_OBJECTHDR obj;

        k = ME.OMCluster->i_filed_oid_list[i]; /* get spacemap index */
        obj = OM_Gp_CurSpaceMap[k].state.object;
        if (obj != (OM_p_OBJECTHDR) me)
           if (ME.OMCluster->w_filed_classid_list[i] >= OM_K_NUM_META_CLASSES)
	   {
	      a_classid = 
               OM_GA_filed_to_active[ME.OMCluster->w_filed_classid_list[i]];
              if (a_classid == OM_K_NOTUSING_CLASSID)
              {
                 OM_Gp_CurSpaceMap[k].p_acld = (OM_p_CLASSDEF) ME.OMCluster->
                    w_filed_classid_list[i];
                 OM_Gp_CurSpaceMap[k].flags |= OM_SM_unknown_obj;
              }
              else
              {
                 OM_Gp_CurSpaceMap[k].p_acld = OM_GA_active_classes[a_classid];
                 om$vla_fixup(p_object=obj, type='r');
              }
	   }
      }
      if(!(1&(sts = om$vla_set_dimension(
			varray=ME.OMCluster->w_filed_classid_list,
                        size=0) )))
         return(sts);
      if(!(1&(sts = om$vla_set_dimension(
			varray=ME.OMCluster->i_filed_oid_list,
                        size=0) )))
         return(sts);
      return(OM_S_SUCCESS);
   }

   /* User clusters */

   for(i=0; i < (int) ME.OMCluster->i_fil_num_objects; i++)
   {
      k = ME.OMCluster->i_filed_oid_list[i]; /* get spacemap index */
      OM_Gp_CurSpaceMap[k].state.filed_obj.clusterid =
         ME.OMCluster->lcd.w_cluster_num;
      OM_Gp_CurSpaceMap[k].flags = OM_SM_in_use;
      a_classid = 
         OM_GA_filed_to_active[ME.OMCluster->w_filed_classid_list[i]];
      if (a_classid == OM_K_NOTUSING_CLASSID)
      {
         OM_Gp_CurSpaceMap[k].p_acld = (OM_p_CLASSDEF) ME.OMCluster->
            w_filed_classid_list[i];
         OM_Gp_CurSpaceMap[k].flags |= OM_SM_unknown_obj;
      }
      else
         OM_Gp_CurSpaceMap[k].p_acld = OM_GA_active_classes[a_classid];
   }

   /* indicate that we are not faulted in .. */
   ME.OMCluster->lcd.flags &= ~OM_FAULTED;

   ME.OMCluster->lcd.pcdq_lh.next = ME.OMCluster->lcd.pcdq_lh.prev = 
	(OM_p_DLINK) &(ME.OMCluster->lcd.pcdq_lh.next);

   if(!(1&(sts = om$vla_set_dimension(varray=ME.OMCluster->w_filed_classid_list,
                        size=0) )))
	return(sts);

   OM_Gp_CurOSD->Clusters[ME.OMCluster->lcd.w_cluster_num] = 
  	&(ME.OMCluster->lcd);
   return(OM_S_SUCCESS);
}



/*========================================================================*/
method clwrite(int fp; OM_S_OSHOLE *free_list; OM_p_CSD csd;
               OMuint *bytes_to_file)

/* The file is the filed Object Space we are writing to.  It should
/* already be open for write.  It may be a pre-existing filed Object
/* Space or a brand new Object Space (never written before).
/*
/* Collapse each object that needs it before doing any serious processing.
/* If we are the oso/cluster 0 object (which means that we are writing 
/* cluster 0) do not collapse 'me' at the same time as everyone else.
/* If we did, there would be a danger of 'us' having moved out from under
/* 'us' and losing access to our control data.
/*
/* 5-87 A change in VLA management left the free_list arg obsolete.
/* 	It will be assigned via a send.
/*
/* 2-88 Rewrote to support autoclustering.
*/ 
{
#define	OM_OBJIDSIZE	4

   int                     adj_size, Clust0, objPos, vlaPos,
                           vlaSize, vlaOffsetSize, fixedSize, totalSize;
   OMuint                  ii, kk, sts, numObjs, chunkSize,
                           bcnt, index = 0;
   OM_p_PCD                pcd;
   OM_p_OBJECTHDR          p_chunk;
   OM_p_OBJECTHDR          p_tmpobj;
   OM_p_VARLENARR_DEFN     vad;
   OM_p_VARLENARR_DEFN     stop_vad;
   OM_p_VARLENARR_DESCR    p_defn;
   OMuint                  *oidList;
   OMuword                 *classidList, numVlas;
   char                    *p_addr;
   int                     *vlaOffsets, regVlaOffsets[1024];
   OM_S_FILEOBJHDR         objHdr;

#ifdef BIG_ENDIAN
#define  OM_K_BIGEND_WRITEBUFFERSIZE   16384
   char                    mallocFlag;
   char                    *p_inObj;
   union
   {
      double               doutputBuffer[OM_K_BIGEND_WRITEBUFFERSIZE/8];
      char                 outputBuffer[OM_K_BIGEND_WRITEBUFFERSIZE];
   } uoutbuf;
   union
   {
      double               dintputBuffer[OM_K_BIGEND_WRITEBUFFERSIZE/8];
      char                 inputBuffer[OM_K_BIGEND_WRITEBUFFERSIZE];
   } uinbuf;
#endif

   /*================================================================*/
   /* For guys that have never been faulted, re-expand their filed-  */
   /* to-active list, then return.  They'll be copied, but not here. */
   /*================================================================*/
   if (!(ME.OMCluster->lcd.flags & OM_FAULTED))
   {
      if(!(1&(sts = om$vla_set_dimension(
			   varray=ME.OMCluster->w_filed_classid_list,
                           size=ME.OMCluster->i_fil_num_objects) )))
         return(sts);
      for (ii=0; ii<ME.OMCluster->i_fil_num_objects; ii++)
      {
         if (OM_Gp_CurSpaceMap[ME.OMCluster->i_filed_oid_list[ii]].flags
             & OM_SM_unknown_obj)
            ME.OMCluster->w_filed_classid_list[ii] = (OMuword)
               OM_Gp_CurSpaceMap[ME.OMCluster->i_filed_oid_list[ii]].p_acld;
         else
            ME.OMCluster->w_filed_classid_list[ii] = OM_Gp_CurOSD->ActToFil
               [OM_Gp_CurSpaceMap[ME.OMCluster->i_filed_oid_list[ii]].
                  p_acld->w_classid];
      }
      *bytes_to_file += ME.OMCluster->i_fil_byte_size;
      return(OM_S_SUCCESS);
   }

   /*=============================================================*/
   /* Construct the filed oid list and the filed classid list.    */
   /* Find current number of objects in this cluster by totalling */
   /* number in each pcd.                                         */
   /*=============================================================*/
   pcd = (OM_p_PCD) ME.OMCluster->lcd.pcdq_lh.next;
   Clust0 = numObjs = 0;

#ifdef BIG_ENDIAN
   OM_Gf_ioMode = WRITE_PORT;
#endif

   while (pcd != (OM_p_PCD) &ME.OMCluster->lcd.pcdq_lh.next)
   {
      /*===================================================*/
      /* Get the number of objects for the entire logical  */
      /* cluster so we know what size to set the filed oid */
      /* and filed classid lists to be.  Can't get the     */
      /* count of chunks yet because the following 2 vla_  */
      /* set_dimension calls may change the count.         */
      /*===================================================*/
      numObjs += pcd->i_cur_num_objects;
      pcd = (OM_p_PCD) pcd->pcdq.next;
   }
   
   /*===================================*/
   /* Grow oid and filed classid vla's. */
   /*===================================*/
   
   if(!(1&(sts = om$vla_set_dimension(varray=ME.OMCluster->w_filed_classid_list,
   			size=numObjs) )))
	return(sts);
   if(!(1&(sts = om$vla_set_dimension(varray=ME.OMCluster->i_filed_oid_list,
      			size=numObjs) )))
	return(sts);
   oidList = ME.OMCluster->i_filed_oid_list;
   classidList = ME.OMCluster->w_filed_classid_list;

   ME.OMCluster->lcd.i_file_ptr = ftell((FILE *) fp);    /* saw002 */
   ME.OMCluster->i_fil_num_objects = numObjs;
   ME.OMCluster->i_fil_byte_size = 0;

   pcd = (OM_p_PCD) ME.OMCluster->lcd.pcdq_lh.next;
   vlaOffsets = &regVlaOffsets[0];
   vlaOffsetSize = 1024;              /* How many descr ptrs array can hold */

   /*======================================================================*/
   /* Loop through logical cluster's pcd list.  For each physical cluster, */
   /* step through the cluster and find each object.  Write the object to  */
   /* the object space file.                                               */
   /*======================================================================*/
   index = 0;
   while (pcd != (OM_p_PCD) &ME.OMCluster->lcd.pcdq_lh.next)
   {
      char *   slotBoundary;
      char     msg[120];

      p_addr = pcd->p_csd->p_addr;
      p_chunk = (OM_p_OBJECTHDR) p_addr;
      if (pcd->p_csd->flag & OM_BIG)
         slotBoundary = (char *) p_chunk + pcd->i_totalsize;
      else
         slotBoundary = (char *) p_chunk + OM_Gi_phyClusterSize;

      numObjs = 0;
      while (numObjs < pcd->i_cur_num_objects)
      {
         if ((char *) p_chunk >= slotBoundary)
         {
            sprintf(msg, "OMclwrite: A PC of Cluster %d contains fewer objects than expected (%d).\n    Aborting save of file.\n",
               ME.OMCluster->lcd.w_cluster_num, pcd->i_cur_num_objects);
            BUGCHECK(msg);
            return(OM_F_BUGCHECK);
         }
         
         /*==========================================================*/
         /* Step through slot looking for objects.  For each object, */
         /* store its oid and filed classid in the cluster object's  */
         /* vla's, then collapse the object into the write buffer,   */
         /* first stripping off its oid (first longword of object    */
         /* header.  Write the object then convert its vla pointers  */
         /* to self-relative offsets.                                */
         /*==========================================================*/
         if (!OM_FREEBIT(p_chunk->i_size) && !OM_FREEBIT(p_chunk->oid))
         {
            /* Found an object */

            if (ME.OMCluster->lcd.oid == p_chunk->oid)
            {
               Clust0 = 1;
               p_chunk = (OM_p_OBJECTHDR)       /* Point to next chunk in PC */
                 ((char *) p_chunk + OM_GETOBJSIZE(p_chunk->i_size));
	       numObjs++;
               continue;                           /* Write OSO last */
            }

#ifdef BIG_ENDIAN
            oidList[index] = p_chunk->oid;
            if (OM_Gp_CurSpaceMap[p_chunk->oid].flags & OM_SM_unknown_obj)
               classidList[index] = (OMuword) OM_Gp_CurSpaceMap
                  [p_chunk->oid].p_acld;
            else
            {
               classidList[index] = OM_Gp_CurOSD->ActToFil
                  [OM_Gp_CurSpaceMap[p_chunk->oid].p_acld->w_classid];
               if (!OM_Gp_CurSpaceMap[p_chunk->oid].p_acld->p_instance_def)
               {
                  fprintf(stderr,
                     "OMCluster.clwrite: Class %s is not in the dictionary.\n  Cannot write file.  Object id: %d  Class id: %d.\n",
                     OM_Gp_CurSpaceMap[p_chunk->oid].p_acld->s_name,
                     p_chunk->oid, classidList[index]);
                  return(OM_E_ERROR);
               }
            }
            som_swapshort((char *) &classidList[index],
               (char *) &objHdr.classid);

            if (OM_OBJ_IS_TAGGED(p_chunk->i_size))
            {
               OMuint  switch1;
               OMuword switch2;
               om$objid_to_tag(osnum=OM_Gw_current_OS, objid=p_chunk->oid,
                  p_tag=&switch1, p_version=&switch2);
               som_swapint(&switch1, &objHdr.tag);
               som_swapshort(&switch2, &objHdr.version);
            }
            else
            {
               objHdr.tag = 0;
               objHdr.version = 0;
            }

            /* Write the first 2 fields of the object header (the
             * tag id, the tag version and the filed class id.
             */

            if ((sts = som_csfwrite(&objHdr, 1, sizeof(OM_S_OBJECTHDR),
               (FILE *) fp)) != sizeof(OM_S_OBJECTHDR))
               return(sts);
            ME.OMCluster->i_fil_byte_size += sizeof(OM_S_OBJECTHDR);
            *bytes_to_file += sizeof(OM_S_OBJECTHDR);

            /* We must have a buffer separate from the in-mem object buffer
             * to perform the big_endian to little_endian conversion and
             * fwrite, but we need to avoid malloc because memory may be
             * tight at this point (user may be saving file because he's
             * running low on memory).  If the object size is smaller than
             * the size of writeBuffer, use writeBuffer as our convert &
             * write buffer.  If the object is the OMTag object, use our
             * hard-coded Tag converter, which won't malloc & will handle
             * any size Tag object.  Otherwise, we have no choice but to
             * malloc a buffer.
             */

            if (classidList[index] == OM_K_OMTAG_ACTCLASSID)
            {
               if (!(1 & (sts =
                  som_bigend_portAndWriteOMTag(p_chunk, fp,
                     &totalSize))))
                  return(sts);
            }
            else
            {
               /* Non-OMTag object case */

               if (!(OM_Gp_CurSpaceMap[p_chunk->oid].flags & OM_SM_unknown_obj))
               {
                  om$vla_get_size_of_object(object=p_chunk,
                                p_cld=OM_Gp_CurSpaceMap[p_chunk->oid].p_acld,
                                p_fixed_size=&fixedSize,
                                p_total_size=&totalSize);

                  if (totalSize > OM_K_BIGEND_WRITEBUFFERSIZE)
                  {
                     if (!(p_tmpobj = (OM_p_OBJECTHDR)
                        ((double *) om$calloc(num=1, size=totalSize))))
                        return (OM_E_NODYNMEM);
                     mallocFlag = 1;
                  }
                  else
                  {
                     p_tmpobj = (OM_p_OBJECTHDR) &uoutbuf.outputBuffer[0];
                     mallocFlag = 0;
                  }
                  OM_BLOCK_MOVE((char *)p_chunk, p_tmpobj, fixedSize);
                  p_tmpobj->i_size = totalSize |
                     OM_GETLOW3BITS(p_chunk->i_size);
                  om$vla_collapse_copy(p_orig_object=p_chunk,
                                 p_copy=p_tmpobj,
                                 p_spacemap=NULL,
                                 p_cld=OM_Gp_CurSpaceMap[p_chunk->oid].p_acld);

                  om$vla_fixup(p_object=p_tmpobj, type='w');

                  if (OM_Gf_validate_OS)
                  {
                     if (OSval_obj(OM_Gw_current_OS,p_chunk->oid,p_tmpobj,
                        totalSize, 1,vlaOffsets))
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
                  }
                  if (mallocFlag)
                  {
                     if (!(p_inObj = (char *)
                        ((double *) om$malloc(size=totalSize))))
                        return(OM_E_NODYNMEM);
                  }
                  else
                     p_inObj = (char *) &uinbuf.inputBuffer[0];
                  OM_BLOCK_MOVE((char *) p_tmpobj, p_inObj, totalSize);
                  if (!(1&(sts = som_convert_instance(p_inObj, p_tmpobj,
                     OM_Gp_CurSpaceMap[p_chunk->oid].p_acld))))
                  {
                     fprintf(stderr, "OMCluster.clwrite: Conversion routine failed for object %d at file location %d,\n   class id %d (%s).  Cannot write file.\n",
                        p_chunk->oid, ftell((FILE *) fp), classidList[index],
                        OM_Gp_CurSpaceMap[p_chunk->oid].p_acld->s_name);
                     return(sts);
                  }
                  if ((sts = som_csfwrite(p_tmpobj, 1, totalSize, (FILE *) fp))
                     != totalSize)
                  {
                     if (!(OM_Gp_CurSpaceMap[p_chunk->oid].flags & OM_SM_unknown_obj))
                        om$dealloc(ptr=(char *) p_tmpobj);
                     return(sts);
                  }
               }
               else
               {
                  /* Unknown object -- don't convert, don't vla_fixup,
                   * just fwrite it to file as is.
                   */

                  p_tmpobj = p_chunk;
                  totalSize = OM_GETOBJSIZE(p_tmpobj->i_size);
                  som_swapint(&p_chunk->oid, &fixedSize);
                  p_chunk->oid = fixedSize;
                  som_swapint(&p_chunk->i_size, &fixedSize);
                  p_chunk->i_size = fixedSize;
                  mallocFlag = 0;
                  sts = som_csfwrite(p_tmpobj, 1, totalSize, (FILE *) fp);

                  /* Restore in-memory version of object header */

                  som_swapint(&p_chunk->oid, &fixedSize);
                  p_chunk->oid = fixedSize;
                  som_swapint(&p_chunk->i_size, &fixedSize);
                  p_chunk->i_size = fixedSize;
                  if (sts != totalSize)
                  {
                     if (!(OM_Gp_CurSpaceMap[p_chunk->oid].flags & OM_SM_unknown_obj))
                        om$dealloc(ptr=(char *) p_tmpobj);
                     return(sts);
                  }
               }

               if (mallocFlag)
               {
                  om$dealloc(ptr=(char *) p_tmpobj);
                  om$dealloc(ptr=(char *) p_inObj);
               }
            }

            ME.OMCluster->i_fil_byte_size += totalSize;
            *bytes_to_file += totalSize;
            numObjs++;
            index++;
#else

            oidList[index] = p_chunk->oid;

            /*=======================================================*
             * For unknown objects, the filed classid is kept in the *
             * p_acld field of the spacemap entry for the object.    *
             *=======================================================*/
            if (OM_Gp_CurSpaceMap[p_chunk->oid].flags & OM_SM_unknown_obj)
               classidList[index] = (OMuword) OM_Gp_CurSpaceMap
                  [p_chunk->oid].p_acld;
            else
               classidList[index] = OM_Gp_CurOSD->ActToFil
                  [OM_Gp_CurSpaceMap[p_chunk->oid].p_acld->w_classid];
            objHdr.oid = p_chunk->oid;
            objHdr.classid = classidList[index++];
            if (OM_OBJ_IS_TAGGED(p_chunk->i_size))
               om$objid_to_tag(osnum=OM_Gw_current_OS, objid=p_chunk->oid,
                  p_tag=&objHdr.tag, p_version=&objHdr.version);
            else
            {
               objHdr.tag = 0;
               objHdr.version = 0;
            }

            /* Write the object header (file version) except for the
             * size field.  Update the bytes-written counters.
             */
            if ((sts = som_csfwrite(&objHdr, 1,
               sizeof(OM_S_FILEOBJHDR)-OM_OBJIDSIZE, (FILE *) fp)) !=
               sizeof(OM_S_FILEOBJHDR)-OM_OBJIDSIZE)
                   return(sts);
            *bytes_to_file += sizeof(OM_S_FILEOBJHDR) - OM_OBJIDSIZE;
            ME.OMCluster->i_fil_byte_size +=
               sizeof(OM_S_FILEOBJHDR) - OM_OBJIDSIZE;

            if (OM_Gp_CurSpaceMap[p_chunk->oid].flags & OM_SM_array_mod)
            {
               om$vla_get_size_of_object(object=p_chunk, p_cld=
                  OM_Gp_CurSpaceMap[p_chunk->oid].p_acld,
                  p_fixed_size=&fixedSize, p_total_size=&totalSize);

               bcnt = 0;            /* vla byte count */
               objPos = ftell((FILE *) fp); /* File pos of fixed part of obj */
               fseek((FILE *) fp, (objPos + fixedSize) - OM_OBJIDSIZE, 0);
               vlaPos = fixedSize;  /* For vla fix-up */
               numVlas = OM_Gp_CurSpaceMap[p_chunk->oid].
                  p_acld->w_num_varlenarrays;
               vad = OM_Gp_CurSpaceMap[p_chunk->oid].p_acld->
                  p_varlenarr_defns;      /* First descriptor in acld */
               stop_vad = numVlas + vad;  /* End of descriptor list */
               if ((int) numVlas > vlaOffsetSize)
               {
                  /* Need to expand temp storage for vla pointers */

                  if (vlaOffsets == regVlaOffsets)
                  {
                     vlaOffsets = (int *) om$malloc(size=(4 * numVlas));
                     if (!vlaOffsets) return (OM_E_NODYNMEM);
                     OM_BLOCK_MOVE(regVlaOffsets, vlaOffsets,
                        (vlaOffsetSize*4));
                  }
                  else
                  {
                     vlaOffsets = (int *) om$realloc(size=(4 * numVlas),
                        ptr=(char *) vlaOffsets);
                     if (!vlaOffsets) return (OM_E_NODYNMEM);
                  }
                  vlaOffsetSize = numVlas;
               }
               /*==================================================*/
               /* Save vla >pointers< in vlaOffsets array, so that */
               /* we may temporarily store vla >offsets< in their  */
               /* place until the object has been written to file. */
               /*==================================================*/
               for (kk=0; vad < stop_vad; ++vad)
               {
                  p_defn = (OM_p_VARLENARR_DESCR)
                     (vad->w_offset + (char *) p_chunk);
                  if (p_defn->i_offset)
                  {
                     vlaOffsets[kk++] = p_defn->i_offset;
                     vlaSize = som_aligned_vla_size(vad, p_defn);
                     if ((int) (sts = som_csfwrite(p_defn->i_offset, 1, vlaSize,
                        (FILE *) fp)) != vlaSize)
                        return(sts);
                     bcnt += sts;
                     p_defn->i_offset = vlaPos - vad->w_offset;
                     vlaPos += vlaSize;
                  }
               }
               chunkSize = p_chunk->i_size;  /* Save size as exists in memory */
               p_chunk->i_size = totalSize | OM_GETLOW3BITS(p_chunk->i_size);
               if (!numObjs)
                  p_chunk->i_size |= 0x00000001; /* Signify first obj in cluster */

               if (OM_Gf_validate_OS)
               {
                  if (OSval_obj(OM_Gw_current_OS,p_chunk->oid,p_chunk,
                     bcnt+fixedSize,0,vlaOffsets))
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
               }

               fseek((FILE *) fp, objPos, 0);
               if ((int) (sts = som_csfwrite(&p_chunk->i_size, 1,
                    fixedSize - OM_OBJIDSIZE, (FILE *) fp))
                  != (int) (fixedSize - OM_OBJIDSIZE))
                   return(sts);
               vad = OM_Gp_CurSpaceMap[p_chunk->oid].p_acld->
                  p_varlenarr_defns;
               for (kk=0; vad < stop_vad; ++vad)
               {
                  p_defn = (OM_p_VARLENARR_DESCR)
                     (vad->w_offset + (char *) p_chunk);
                  if (p_defn->i_offset)
                     p_defn->i_offset = vlaOffsets[kk++];
               }
               p_chunk->i_size = chunkSize;
               totalSize -= OM_OBJIDSIZE;
               fseek((FILE *) fp, (objPos + totalSize), 0);
            }
            else
            {
               if (!(OM_Gp_CurSpaceMap[p_chunk->oid].flags & OM_SM_unknown_obj))
                  om$vla_fixup(p_object=p_chunk, type='w');

               totalSize = OM_GETOBJSIZE(p_chunk->i_size) - OM_OBJIDSIZE;

               if (OM_Gf_validate_OS)
               {
                  if (OSval_obj(OM_Gw_current_OS,p_chunk->oid,
                     p_chunk,totalSize + OM_OBJIDSIZE,1,vlaOffsets))
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
               }

               if ((int) (sts = som_csfwrite(&p_chunk->i_size, 1,
                   totalSize, (FILE *) fp)) != totalSize)
               {
                  /* Reset vla ptrs before returning */
                  if (!(OM_Gp_CurSpaceMap[p_chunk->oid].flags & OM_SM_unknown_obj))
                     om$vla_fixup(p_object=p_chunk, type='r');     /* Reset vla ptrs */
                  return(sts);
               }
               if (!(OM_Gp_CurSpaceMap[p_chunk->oid].flags & OM_SM_unknown_obj)
                   && (OM_Gf_validate_OS ||
                   !(OM_Gp_CurOSD->flags & OM_OSD_Rootdel_pending)))
                  om$vla_fixup(p_object=p_chunk, type='r');     /* Reset vla ptrs */
            }
            *bytes_to_file += totalSize;
            ME.OMCluster->i_fil_byte_size += totalSize;
            numObjs++;
#endif
         }
         p_chunk = (OM_p_OBJECTHDR) ((char *) p_chunk +
            OM_GETOBJSIZE(p_chunk->i_size));
      }                 /* End of while loop */

      /* See if there are still any objects left in this phy cluster */

      if (!(pcd->p_csd->flag & OM_BIG))
      {
         while ((char *) p_chunk < slotBoundary)
         {
            if (!OM_FREEBIT(p_chunk->i_size) && !OM_FREEBIT(p_chunk->oid))
            {
               /* Found another object */
   
               sprintf(msg, "OMclwrite: A PC of Cluster %d contains more objects than expected (%d).\n   Aborting save of file.\n",
                  ME.OMCluster->lcd.w_cluster_num, pcd->i_cur_num_objects);
               BUGCHECK(msg);
               return(OM_F_BUGCHECK);
            }
            p_chunk = (OM_p_OBJECTHDR) ((char *) p_chunk +
               OM_GETOBJSIZE(p_chunk->i_size));
         }
      }
      pcd = (OM_p_PCD) pcd->pcdq.next;      /* Get next phy cluster */
   }

   /*=======================================================================*/
   /* If cluster being written is Cluster 0, we've set a flag and put off   */
   /* writing the OSO til last so that list of oids and filed classid list  */
   /* will be up to date when they're written.  If flag set, write OSO now. */
   /*=======================================================================*/
   if (Clust0)
   {
      ME.OMCluster->i_my_file_ptr = ftell((FILE *) fp);
      p_chunk = (OM_p_OBJECTHDR) me;
      oidList[index] = p_chunk->oid;
      classidList[index] = OM_Gp_CurOSD->ActToFil
         [OM_Gp_CurSpaceMap[p_chunk->oid].p_acld->w_classid];

      objHdr.tag = 0;
      objHdr.version = 0;
      objHdr.oid = p_chunk->oid;

#ifdef BIG_ENDIAN
      /* 'tag' and 'version' fields don't need to be swapped, since
       * they're both zero fields; the oid field gets swapped by 
       * the object's class conversion routine, but the classid
       * field is swapped here manually.
       */

      som_swapshort(&classidList[index++], &objHdr.classid);
#endif
#ifdef LITTLE_ENDIAN
      objHdr.classid = classidList[index++];
#endif

      if ((sts = som_csfwrite(&objHdr, 1, sizeof(OM_S_OBJECTHDR),
            (FILE *) fp)) != sizeof(OM_S_OBJECTHDR))
         return(sts);
      ME.OMCluster->i_fil_byte_size += sizeof(OM_S_OBJECTHDR);
      *bytes_to_file += sizeof(OM_S_OBJECTHDR);
      om$vla_get_size_of_object(object=p_chunk,
                                p_cld=OM_Gp_CurSpaceMap[p_chunk->oid].p_acld,
                                p_fixed_size=&fixedSize,
                                p_total_size=&totalSize);

      ME.OMCluster->i_fil_byte_size += totalSize;
      p_tmpobj = (OM_p_OBJECTHDR) om$calloc(size=totalSize, num=1);
      if (!p_tmpobj) return (OM_E_NODYNMEM);
      OM_BLOCK_MOVE((char *)p_chunk, p_tmpobj, fixedSize);
      p_tmpobj->i_size = totalSize | OM_GETLOW3BITS(p_chunk->i_size);
      om$vla_collapse_copy(p_orig_object=p_chunk,
                           p_copy=p_tmpobj,
                           p_spacemap=NULL,
                           p_cld=OM_Gp_CurSpaceMap[p_chunk->oid].p_acld);

      om$vla_fixup(p_object=p_tmpobj, type='w');     /* Fix up vla ptrs for file copy */

      if (OM_Gf_validate_OS)
      {
         if (OSval_obj(OM_Gw_current_OS,p_chunk->oid,p_tmpobj,totalSize,
            1,vlaOffsets))
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
      }
      fixedSize = p_tmpobj->i_size;

#ifdef BIG_ENDIAN
      if (totalSize > OM_K_BIGEND_WRITEBUFFERSIZE)
      {
         if (!(p_inObj = (char *) ((double *) om$malloc(size=totalSize))))
            return(OM_E_NODYNMEM);
         mallocFlag = 1;
      }
      else
      {
         p_inObj = (char *) &uinbuf.inputBuffer[0];
         mallocFlag = 0;
      }
      OM_BLOCK_MOVE((char *) p_tmpobj, p_inObj, totalSize);
      if (!(1&(sts=som_convert_instance(p_inObj, p_tmpobj,
         OM_Gp_CurSpaceMap[0].p_acld))))
      {
         fprintf(stderr, "\nOMCluster.clwrite: Could not convert OSO! Cannot save file.\n");
         return(sts);
      }
#endif

      if ((int) (sts = som_csfwrite(p_tmpobj, 1, totalSize, (FILE *) fp))
		 != totalSize)
      {
/*         om$vla_fixup(p_object=p_tmpobj, type='r');*/     /* Reset vla ptrs */
         om$dealloc(ptr=(char *) p_tmpobj);
         return(sts);
      }
      *bytes_to_file += totalSize;

/*      if(OM_Gf_validate_OS || ! (OM_Gp_CurOSD->flags & OM_OSD_Rootdel_pending))
         om$vla_fixup(p_object=p_tmpobj, type='r');*/     /* Reset vla ptrs */
      om$dealloc(ptr=(char *) p_tmpobj);

#ifdef BIG_ENDIAN
      if (mallocFlag)
         om$dealloc(ptr=(char *) p_inObj);
#endif

   }

   ME.OMCluster->i_fil_num_objects = index;

   /* saw002 -- All the following does is keep the hole list up to date.
      Currently, we are not using the hole list. */

   adj_size = 0;
   if (sts=om$send(targetid=OM_Gp_CurOSD->OSO_Oid,
                        msg=message OMFiledOS.get_freelist_ptr(&free_list)))
      som_file_freelist(free_list,
                     &adj_size,
                     ME.OMCluster->i_fil_byte_size,
                     ME.OMCluster->i_fil_byte_size);
   return(OM_S_SUCCESS);
}


som_csfwrite(buffer, size, count, fp)
char     *buffer;
OMuint   size;
OMuint   count;
FILE     *fp;
{
   int   sts, ii, fileloc;

   fileloc = ftell(fp);
   for (ii=0; ii < (int) (size * count); ii++, fileloc++)
   {
      OM_Gi_checksum += (unsigned char) buffer[ii] + fileloc;
   }
   if ((sts = fwrite(buffer, size, count, fp)) != (int) count)
   {
      return(OM_E_WRITE_ERROR);
   }
   return(sts);
}

#ifdef BIG_ENDIAN
int som_bigend_portAndWriteOMTag(p_chunk, fp, totalSize)
OM_p_OBJECTHDR p_chunk;
int            fp;
OMuint         *totalSize;
{
   /* Convert the OMTag object and write it to file piece by piece
    * so we avoid malloc-ing a buffer large enough to hold a copy
    * of it.
    */

   struct beOMTag_instance
   {
      OMuint   oid,
               size,
               next_tag,
               num_tags,
               h_free;
      int      next_index;
      OMuword  flags;
      OMuword  f_align;
      int      hash_block_size;
      int      i_offset;
      int      i_count;
      int      toOSO;
      int      align;
   } *intag, tag;
   struct betag_record
   {
      OMuint   tagid;
      OMuint   oid;
      OMuword  version;
      OMuword  align;
   } tag_rec, *tag_vla;
   struct to_oso
   {
      OMuword  short1;
      OMuword  short2;
      OMuword  short3;
      OMuword  short4;
      OMuint   int1;
      int      align;
   } toOso;
   int   ii, vlaSize, alignFlag;

   intag = (struct beOMTag_instance *) p_chunk;
   if ((vlaSize = ((intag->i_count * sizeof(struct betag_record)) + 7) &
      ((OMuint) ~7)) != (intag->i_count * sizeof(struct betag_record)))
      alignFlag = 1;    /* Had to align array by 4 bytes */
   else
      alignFlag = 0;
   som_swapint(&p_chunk->oid, &tag.oid);
   *totalSize = sizeof(struct beOMTag_instance) + vlaSize;

   if (intag->toOSO)
      *totalSize += 16; /* + to_OSO channel */
   ii = *totalSize | 0x02;
   som_swapint(&ii, &tag.size);
   som_swapint(&intag->next_tag, &tag.next_tag);
   som_swapint(&intag->num_tags, &tag.num_tags);
   som_swapint(&intag->h_free, &tag.h_free);
   som_swapint(&intag->next_index, &tag.next_index);
   som_swapshort(&intag->flags, &tag.flags);
   som_swapshort(&intag->f_align, &tag.f_align);
   som_swapint(&intag->hash_block_size, &tag.hash_block_size);
   if (intag->i_offset)
   {
      ii = 16;    /* offset from this field to start of tag_rec vla */
      som_swapint(&ii, &tag.i_offset);
   }
   else
      tag.i_offset = 0;
   som_swapint(&intag->i_count, &tag.i_count);
   if (intag->toOSO)
   {
      ii = 8 + (intag->i_count * sizeof(struct betag_record)) +
         (alignFlag * 4);
      som_swapint(&ii, &tag.toOSO);
   }
   else
      tag.toOSO = 0;
   tag.align = 0;
   if (som_csfwrite(&tag, 1, sizeof(struct beOMTag_instance), fp) !=
      sizeof(struct beOMTag_instance))
      return(OM_E_WRITE_ERROR);

   if (intag->i_offset)
   {
      tag_vla = (struct betag_record *) intag->i_offset;
      for (ii=0; ii<intag->i_count; ii++, tag_vla++)
      {
         som_swapint(&tag_vla->tagid, &tag_rec.tagid);
         som_swapint(&tag_vla->oid, &tag_rec.oid);
         som_swapshort(&tag_vla->version, &tag_rec.version);
         som_swapshort(&tag_vla->align, &tag_rec.align);
         if (som_csfwrite(&tag_rec, 1, sizeof(struct betag_record), fp) !=
            sizeof(struct betag_record))
            return(OM_E_WRITE_ERROR);
      }
      if (vlaSize > (intag->i_count * sizeof(struct betag_record)))
      {
         vlaSize = 0;
         if (som_csfwrite(&vlaSize, 1, 4, fp) != 4)
            return(OM_E_WRITE_ERROR);
      }
   }
   if (intag->toOSO)
   {
      som_swapshort(intag->toOSO, &toOso.short1);
      som_swapshort((int) intag->toOSO + 2, &toOso.short2);
      som_swapshort((int) intag->toOSO + 4, &toOso.short3);
      som_swapshort((int) intag->toOSO + 6, &toOso.short4);
      som_swapint((int) intag->toOSO + 8, &toOso.int1);
      som_swapint((int) intag->toOSO + 12, &toOso.align);
      if (som_csfwrite(&toOso, 1, 16, fp) != 16)
         return(OM_E_WRITE_ERROR);
   }
   return(1);
}
#endif






/* Revision History:

   geo001	1-aug-1986	new for OM 4.0
*/

/* Delete is an illegal method for clusters. 		    */
/* Remove method is for deleting clusters.   		    */
/* This is done to catch an accidental delete of a cluster. */

method delete (int flag)
{
return(OM_E_NO_DELETE_CLUSTER);
}



/* Revision History:

   geo001	1-aug-1986	new for OM 4.0
*/

/* This method prints out cluster's instance data */

method debug ()
{
  OM_p_PCD	pcd;
  OM_p_FCD 	l_free;
  int	 	sts;

  sts = om$send(mode=OM_e_wrt_message, msg=message Root.debug(),
		 targetid=my_id);
  if(!(1&sts)) return(sts);
  printf("cluster number is: %u\n", ME.OMCluster->lcd.w_cluster_num);
  printf("cluster object offset in file is: %u\n", ME.OMCluster->i_my_file_ptr);
  printf("number of objects last filed: %u\n", ME.OMCluster->i_fil_num_objects);
  printf("byte size of cluster last filed: %u\n", ME.OMCluster->i_fil_byte_size);
  printf("oid of OSO connected to: %u\n", 
                   ((OM_p_CHANNEL_LINK)(ME.OMCluster->to_OSO))->objid);
  printf("cluster offset in file is: %u\n", ME.OMCluster->lcd.i_file_ptr);
  printf("cluster's oid is: %u\n", ME.OMCluster->lcd.oid);
  if(ME.OMCluster->lcd.flags & OM_FAULTED)
    printf("cluster is in memory\n");
  else
    printf("cluster is not in memory\n");
  if(ME.OMCluster->lcd.flags & OM_USERSPEC)
    printf("cluster is a user defined cluster\n");
  else
    printf("cluster is not a user defined cluster\n");

  for(pcd=(OM_p_PCD)ME.OMCluster->lcd.pcdq_lh.next;
        pcd != (OM_p_PCD)&(ME.OMCluster->lcd.pcdq_lh.next);
	pcd=(OM_p_PCD)pcd->pcdq.next)
  {
    printf("addr of physical cluster descriptor: %x\n", pcd);
    if(pcd->p_csd)
       printf("addr for extent:              %x\n", pcd->p_csd->p_addr);
    printf("total _free space in extent:   %u\n", pcd->i_totalfree);
    printf("total size of extent:         %u\n", pcd->i_totalsize);
    for(l_free=pcd->p_fcd; l_free; l_free = l_free->nextfcd)
    {
      printf("addr of l_free descriptor:    %x\n", l_free->freehdr);
      printf("size of l_free space:         %u\n", l_free->size);
    }
  }
  return(OM_S_SUCCESS);
}



/* Revision History:

   geo001	01-aug-1986	new for OM 4.0
   geo002	23-nov-1987	OM4.6 cluster changes
*/

/* initializer method for OMCluster class */

method init_OMCluster(OMuword *cluster_num)
{
  OM_S_CHANSELECT	cs_to, cs_from;
  int			i, sts;
  OM_p_LCD		*new_ptr;

  /*==================================================*/
  /* Find Empty Slot in Clusters Array, If One Exists */
  /*==================================================*/
  for(i=0; i<(int) OM_Gp_CurOSD->ClustersSize; i++)
  {
    if(OM_Gp_CurOSD->Clusters[i] == NULL)
    {
	*cluster_num = i;
        break;
    }
  }

  /*===========================================================*/
  /* No Empty Slots in OSD's Clusters and Clusters is Max Size */
  /*===========================================================*/
  if((i==(int) OM_Gp_CurOSD->ClustersSize) &&
     (OM_Gp_CurOSD->ClustersSize >= (OM_K_MAXCLUSTER_NUM)))
  {
    return(OM_E_MAX_CLUSTERS_ALLOWED);
  }

  /*================================================================*/
  /* Increase Size Of Clusters Array In OSD To Hold One New Element */
  /*================================================================*/
  if(i== (int) OM_Gp_CurOSD->ClustersSize)
  {
    if(!(new_ptr=(OM_p_LCD *)om$realloc(ptr=(char *) OM_Gp_CurOSD->Clusters,
	   size=((OM_Gp_CurOSD->ClustersSize+1)*sizeof(OM_p_LCD)))))
    {
	return(OM_E_NODYNMEM);
    }
    OM_Gp_CurOSD->Clusters = new_ptr;
    *cluster_num = OM_Gp_CurOSD->ClustersSize;
    OM_Gp_CurOSD->ClustersSize++;
  }

  /*==========================*/
  /* Initialize Instance Data */
  /*==========================*/
  ME.OMCluster->lcd.w_cluster_num = *cluster_num;
  ME.OMCluster->i_my_file_ptr = 0;
  ME.OMCluster->i_fil_num_objects = 0;
  ME.OMCluster->i_fil_byte_size = 0;
  ME.OMCluster->lcd.pcdq_lh.next = ME.OMCluster->lcd.pcdq_lh.prev = 
     (OM_p_DLINK) &(ME.OMCluster->lcd.pcdq_lh.next);
  ME.OMCluster->lcd.i_file_ptr = 0;
  ME.OMCluster->lcd.oid = my_id;
  ME.OMCluster->lcd.p_pcd = NULL;
  ME.OMCluster->lcd.p_osd = OM_Gp_CurOSD;

  /*==================================================================*/
  /* Internal OM primitives will set ! USERSPEC and FAKELCD flag bits */
  /*==================================================================*/
  ME.OMCluster->lcd.flags = OM_FAULTED | OM_USERSPEC;
  ME.OMCluster->lcd.i_cur_bytes_allocated = 0;

  /*========================================*/
  /* Put My ClustComp Addr Into OSD's Array */
  /*========================================*/
  OM_Gp_CurOSD->Clusters[ME.OMCluster->lcd.w_cluster_num]
		= &(ME.OMCluster->lcd);
  /*==============================================================*/
  /* Initial Extent of Memory Is Linked to LCD at create PCD time */
  /* when the first object is constructed in this cluster         */
  /*==============================================================*/
  /* Connect To OSO */
  /*================*/

  cs_from.type = OM_e_addr;
  cs_to.type = OM_e_name;
  cs_from.u_sel.addr = &(ME.OMCluster->to_OSO);
  cs_to.u_sel.name = "OMObjSpace.to_ClusDscs";
  if(!(1&(sts=om$send(msg=message Root.connect( cs_to, 0,
			my_id, OM_Gw_current_OS, cs_from, *cluster_num),
			targetid=OM_GO_current_OS_objid))))
	return(sts);

  return(OM_S_SUCCESS);
}



/* Revision History:
	geo001	3-sep-1986	created; OM 4.0
*/

/*===========================================================*/
/* This method moves all my objects to cluster number input. */
/*===========================================================*/
method merge(OMuword clustnum)
{
  int		sts;

  if( (! ME.OMCluster->lcd.w_cluster_num) || clustnum >= OM_Gp_CurOSD->ClustersSize )
    	return(OM_E_INVCLUSTERID);

  if(ME.OMCluster->lcd.pcdq_lh.next ==
       (OM_p_DLINK) &(ME.OMCluster->lcd.pcdq_lh.next)) /* nothing to merge */
    	return(OM_S_SUCCESS);

  /*===============================================*/
  /* If Cluster being merged into is not in memory */
  /* Get it faulted in		   	           */
  /*===============================================*/
  if( !(OM_Gp_CurOSD->Clusters[clustnum]->flags & OM_FAULTED) )
  {
    if(!(1&(sts=om$send(msg=message OMCluster.fault(0),
		targetid=OM_Gp_CurOSD->Clusters[clustnum]->oid))))
	return(sts);			
  }

  /*===================================================*/
  /* Queue my pcds to clustnum's queue of pcds         */
  /* Point my pcd to clustnum's lcd & 		       */
  /* Update clustnum's i_cur_bytes_allocated           */
  /*===================================================*/
  while(! OM_QUEUE_EMPTY(&(ME.OMCluster->lcd.pcdq_lh)))
  {
    OM_p_PCD	tmp;

    OM_DEQUEUE_FROM_HEAD(&(ME.OMCluster->lcd.pcdq_lh),tmp, OM_p_PCD);
    OM_QUEUE_AT_HEAD(&(OM_Gp_CurOSD->Clusters[clustnum]->pcdq_lh),
				&(tmp->pcdq))
    tmp->p_lcd = OM_Gp_CurOSD->Clusters[clustnum];
  }

  /*========================================*/
  /* Fix up my lcd information		    */
  /*========================================*/
  ME.OMCluster->lcd.i_cur_bytes_allocated = 0;

  return(OM_S_SUCCESS);
}


/* Revision History:
	geo001	25-aug-1986	created; OM 4.0
*/

/* This method deletes the cluster object and any objects that */
/* remain in it.  Cluster 0 may not be removed.                */
method OMCluster.remove()
{
  int	  		i, sts;
  OMuword 		clustnum;
  OM_p_PCD		tmp_pcd;
  OM_p_OBJECTHDR	tmp_objhdr;

  if(!(clustnum=ME.OMCluster->lcd.w_cluster_num)) /* cluster 0 may not be removed */
    	return(OM_E_INVCLUSTERID);

  /*===========================================*/
  /* If Cluster being removed is not in memory */
  /* and it is not empty, Get it faulted in.   */
  /*===========================================*/
  if( !(ME.OMCluster->lcd.flags & OM_FAULTED) 
			&&
      !(OM_QUEUE_EMPTY(&(ME.OMCluster->lcd.pcdq_lh)))
			&&
      (ME.OMCluster->i_fil_num_objects))
  {
    if(!(1&(sts=om$send(msg=message OMCluster.fault(0),
			targetid=my_id))))
	return(sts);			
  }

  /*==============================================*/
  /* If Cluster is not empty, Pass thru Spacemap, */
  /* deleting all objects of my cluster number;   */
  /* using wrt_object mode so as to use object's  */
  /* delete if its class overrides delete.        */
  /*==============================================*/
  if (ME.OMCluster->lcd.pcdq_lh.next !=
        (OM_p_DLINK) &(ME.OMCluster->lcd.pcdq_lh.next))
  {
    for(tmp_pcd = (OM_p_PCD)ME.OMCluster->lcd.pcdq_lh.next;
        tmp_pcd != (OM_p_PCD)&(ME.OMCluster->lcd.pcdq_lh.next);
        tmp_pcd = (OM_p_PCD)tmp_pcd->pcdq.next)
    {
      for(tmp_objhdr=(OM_p_OBJECTHDR)tmp_pcd->p_csd->p_addr;
	  (char *)tmp_objhdr<tmp_pcd->p_csd->p_addr+tmp_pcd->i_totalsize; )
      {
	if(OM_FREEBIT(tmp_objhdr->i_size))	/* free chunk */
        {
	  tmp_objhdr = (OM_p_OBJECTHDR)((char *)tmp_objhdr+
			           OM_GETFREESIZE(tmp_objhdr->i_size));
	  continue;
	}
	if(OM_FREEBIT(tmp_objhdr->oid))	/* vla outrigger */
        {
	  tmp_objhdr = (OM_p_OBJECTHDR)((char *)tmp_objhdr+tmp_objhdr->i_size);
	  continue;
	}
	i=tmp_objhdr->oid;	/* an OBJECT */
        if(!(1&(sts=om$send(msg=message Root.delete(TRUE),
			targetid=i))))
          return(sts);
        tmp_objhdr = (OM_p_OBJECTHDR)((char *)tmp_objhdr+
				OM_GETOBJSIZE(tmp_objhdr->i_size));
      }
    }

  /*=====================================================*/
  /* If Cluster is still not empty, say override delete  */
  /* constructs new objects in cluster being removed.    */
  /* Pass thru Spacemap 2nd time and delete wrt_message  */
  /* deleting all objects of my cluster number with      */
  /* Root's delete, not overriden delete method          */
  /*=====================================================*/
    for(tmp_pcd = (OM_p_PCD)ME.OMCluster->lcd.pcdq_lh.next;
        tmp_pcd != (OM_p_PCD)&(ME.OMCluster->lcd.pcdq_lh.next);
        tmp_pcd = (OM_p_PCD)tmp_pcd->pcdq.next)
    {
      for(tmp_objhdr=(OM_p_OBJECTHDR)tmp_pcd->p_csd->p_addr;
	  (char *)tmp_objhdr<tmp_pcd->p_csd->p_addr+tmp_pcd->i_totalsize; )
      {
	if(OM_FREEBIT(tmp_objhdr->i_size))	/* free chunk */
        {
	  tmp_objhdr = (OM_p_OBJECTHDR)((char *)tmp_objhdr+
			           OM_GETFREESIZE(tmp_objhdr->i_size));
	  continue;
	}
	if(OM_FREEBIT(tmp_objhdr->oid))	/* vla outrigger */
        {
	  tmp_objhdr = (OM_p_OBJECTHDR)((char *)tmp_objhdr+tmp_objhdr->i_size);
	  continue;
	}
	i=tmp_objhdr->oid;	/* an OBJECT */
        if(!(1&(sts=om$send(msg=message Root.delete(TRUE),
			mode=OM_e_wrt_message,
			targetid=i))))
          return(sts);
        tmp_objhdr = (OM_p_OBJECTHDR)((char *)tmp_objhdr+
				OM_GETOBJSIZE(tmp_objhdr->i_size));
      }
    }
  }

  /*=====================================================*/
  /* Delete myself; send wrt_message Root delete message */
  /*=====================================================*/
  if(!(1&(sts=om$send(msg=message Root.delete(TRUE),
			mode=OM_e_wrt_message,
			targetid=my_id))))
    return(sts);

  /*=====================================================*/
  /* Clear Out Cluster Composite Pointer from OSD Array  */
  /*=====================================================*/
  OM_Gp_CurOSD->Clusters[clustnum] = NULL;

  return(OM_S_SUCCESS);
}



method move(OMuword clusterid; char *list)
{
return(OM_E_NOTIMPL);
}



int OSval_obj ( os, oid, p_obj, size_to_write, collapsed_flag, vlaOffsets )
OMuword         os;
OM_S_OBJID      oid;
OM_p_OBJECTHDR  p_obj;
int             size_to_write;
char            collapsed_flag;       /* If 1, object is in collapsed form */
int             *vlaOffsets;          /* Points to array of vla addresses */
{
   int                   sts;
   OMuint                i, nument, kk, chan_count = 0;
   OMuint                diff, fixed_size, addr, vla_size, linksz, p_channel;
   OMuword               a_classid, f_classid, os2, flags2;
   OM_S_OBJID            oid2;
   OM_p_OBJID            p_oid=NULL;
   OM_S_CHANNUM          chan2, chan_num;
   OM_S_BIG_TAIL         tail;
   OM_p_BIG_TAIL         p_big_tail=NULL;
   OM_p_CLASSDEF         p_acld;
   OM_p_OBJECTHDR        p_object;
   OM_S_CHANSELECT       csel;
   OM_p_CHANNEL_HDR      p_chan=NULL;
   OM_p_CHANNEL_DEFN     p_chdef;
   OM_p_CHANNEL_LINK     p_link=NULL;
   OM_p_VARLENARR_DEFN   p_vad, p_stop_vad;
   OM_p_VARLENARR_DESCR  p;

   /*===================================================================*/
   /* If the collapsed_flag is set, then the p_obj either was collapsed */
   /* by som_vla_collapse_copy (like the OSO object) or was already in  */
   /* collapsed form (no outriggers).  In either case, no part of p_obj */
   /* has been written to file yet.  If collapsed_flag is clear, then   */
   /* p_obj has outriggers and is being written a piece at a time to    */
   /* the filed os.  In this case, the vla's have been written, but the */
   /* fixed part of p_obj has not been written yet.  It may be fixed up */
   /* in PMS if this routine finds a problem, but it is too late to fix */
   /* the vla's, as they are already in the file.  A hole has been      */
   /* reserved in the file just before the vla's to hold the fixed part */
   /* of p_obj.  'size_to_write' in this case is the size of the fixed  */
   /* part plus the number of bytes already written to the file (vla).  */
   /* p_obj points to the fixed part of the object.  Its size field has */
   /* been temporarily changed to equal the full, collapsed size of the */
   /* object.  Some of the tests below will work for either a collapsed */
   /* or non-collapsed object.  Any test expecting all vla's to         */
   /* immediately follow the fixed part of p_obj will not work if the   */
   /* collapsed_flag is clear (p_obj has outriggers).                   */
   /*===================================================================*/

   /*===========================*/
   /*  check for size mismatch  */
   /*===========================*/

   if ( (int) OM_GETOBJSIZE(p_obj->i_size) != size_to_write ) {
      fprintf(stderr,"*** OS Validate - object size to write mismatch\n");
      fprintf(stderr,"***               OS:%d  Oid:%d\n",os,oid);
      fprintf(stderr,"***               size in header : %d\n",OM_GETOBJSIZE(p_obj->i_size));
      fprintf(stderr,"***               size to write  : %d\n",size_to_write);
      return (1);
   }

   /*=============================*/
   /*  check for invalid classid  */
   /*=============================*/
   p_acld = OM_GA_OSDs[os]->Spacemap[p_obj->oid].p_acld;

   if (OM_GA_OSDs[os]->Spacemap[p_obj->oid].flags & OM_SM_unknown_obj)
   {
      if ((f_classid = (OMuword) OM_GA_OSDs[os]->Spacemap[p_obj->oid].p_acld) >
         OM_GA_fa_mapsize[os] ) {
         fprintf(stderr,"*** OS validate - filed classid out of range");
         fprintf(stderr,"***               OS:%d  Oid:%d\n",os,oid);
         fprintf(stderr,"***               fil_classid:%d\n",f_classid);
         return (1);
      }
      return (0);
   }
   else
   {
      a_classid = p_acld->w_classid;
      f_classid = OM_Gp_CurOSD->ActToFil[a_classid];
   }

   if ( f_classid > OM_GA_fa_mapsize[os] ) {
      fprintf(stderr,"*** OS validate - filed classid out of range");
      fprintf(stderr,"***               OS:%d  Oid:%d\n",os,oid);
      fprintf(stderr,"***               fil_classid:%d\n",f_classid);
      return (1);
   }

   if ( a_classid > OM_Gw_numclasses ) {
      fprintf(stderr,"*** OS validate - active classid out of range");
      fprintf(stderr,"***               OS:%d  Oid:%d\n",os,oid);
      fprintf(stderr,"***               fil_classid:%d  act_classid:%d\n",
                                   f_classid,a_classid);
      return (1);
   }
   if ( !p_acld ) {
      fprintf(stderr,"*** OS validate - active class definition not found");
      fprintf(stderr,"***               OS:%d  Oid:%d\n",os,oid);
      fprintf(stderr,"***               fil_classid:%d  act_classid:%d\n",
                                   f_classid,a_classid);
      return (1);
   }

   /*=========================================================*/
   /*  check for vla offsets being within object (collapsed)  */
   /*=========================================================*/

   if ( p_acld->w_num_varlenarrays ) {
      p_vad      = p_acld->p_varlenarr_defns;
      p_stop_vad = p_vad + p_acld->w_num_varlenarrays;
      fixed_size = p_acld->i_instance_size;

      for (kk=0 ; p_vad < p_stop_vad; ++p_vad) {
          p = (OM_p_VARLENARR_DESCR)((char *)p_obj + p_vad->w_offset);
         diff = ((OMuint)p - (OMuint)p_obj);
    
         /*===================================================*/
         /*  make sure VLA descr points within fixed portion  */
         /*===================================================*/

         if ( diff >= fixed_size ) {
            fprintf(stderr,"*** OS validate - VLA descr out of fixed instance\n");
            fprintf(stderr,"***               OS:%d  Oid:%d\n",os,oid);
            fprintf(stderr,"***               fil_classid:%d  act_classid:%d\n",
                                      f_classid,a_classid);
            fprintf(stderr,"***               Class: %s\n",p_acld->s_name);
            fprintf(stderr,"***               VLA descr offset:%d  Fixed size:%d\n",
                                      diff,fixed_size);
            fprintf(stderr,"***               VAD::off:%d count:%d eltsz:%d typ:%d\n",
                                      p_vad->w_offset,p_vad->w_count,
                                      p_vad->w_per_elt_size,p_vad->type);
            return (1);
         }

         /*===============================================================*/
         /*  check if collapsed VLA is inside fixed or beyond total size  */
         /*===============================================================*/
         if ( p->i_offset ) {
            if (!collapsed_flag) {
               /*=========================================================*/
               /* If object isn't really in collapsed form, its real vla  */
               /* ptrs are stored in vlaOffsets.  The fixed part of p_obj */
               /* contains offsets as they would be if object were        */
               /* collapsed.  Here we set addr to the real vla address    */
               /* diff is the offset to where the collapsed vla would be. */
               /*=========================================================*/
               addr = vlaOffsets[kk++];
               diff = ((OMuint)p + p->i_offset) - (OMuint)p_obj;
            }
            else {
               addr = (OMuint)p + p->i_offset;
               diff = addr - (OMuint)p_obj;
            }
            if ( (diff < fixed_size) || ((int) diff >= size_to_write) ) {
               fprintf(stderr,"*** OS validate - collapsed VLA out of bounds\n");
               fprintf(stderr,"***               OS:%d  Oid:%d\n",os,oid);
               fprintf(stderr,"***               fil_classid:%d  act_classid:%d\n",
                                         f_classid,a_classid);
               fprintf(stderr,"***               Class: %s\n",p_acld->s_name);
               fprintf(stderr,"***               fixed size:%d tot_size:%d vla:%d\n",
                                         fixed_size, size_to_write, diff);
               fprintf(stderr,"***               VAD off:%d cnt:%d eltsz:%d typ:%d\n",
                                         p_vad->w_offset,p_vad->w_count,
                                         p_vad->w_per_elt_size,p_vad->type);
               return (1);
            }

            /*=========================*/
            /*  determine size of VLA  */
            /*=========================*/

            if ( p_vad->type ) {
               p_chan = (OM_p_CHANNEL_HDR) addr;
               if ( p_chan->flags & OM_CH_bigchan )
                  p_big_tail = (OM_p_BIG_TAIL)((OMuint)p_chan +
                                      sizeof(OM_S_CHANNEL_HDR));
               if ( p_chan->flags & OM_CH_singleton ) {
                  if ( p_chan->flags & OM_CH_restricted )
                     vla_size = sizeof(OM_S_RESTRICTED_ONECHAN);
                  else
                     vla_size = sizeof(OM_S_CHANNEL_LINK);
               }
               else {
                  vla_size = sizeof(OM_S_CHANNEL_HDR);
                  if ( p_chan->flags & OM_CH_restricted )
                    if ( p_chan->flags & OM_CH_bigchan )
                      vla_size += p_big_tail->size * sizeof(OM_S_OBJID);
                    else
                      vla_size += p_chan->u1.count * sizeof(OM_S_OBJID);
                  else
                    if ( p_chan->flags & OM_CH_bigchan )
                      vla_size += p_big_tail->size * sizeof(OM_S_CHANNEL_LINK);
                    else
                      vla_size += p_chan->u1.count * sizeof(OM_S_CHANNEL_LINK);
               }
            }
            else {
               vla_size = p->i_count * p_vad->w_per_elt_size;
            }
 
            /*==============*/
            /*  align size  */
            /*==============*/

            vla_size = (vla_size+7)&((OMuint)~7);

            if ( (int) (diff + vla_size) > size_to_write ) {
               fprintf(stderr,"*** OS validate - collapsed VLA size out of bounds\n");
               fprintf(stderr,"***               OS:%d  Oid:%d\n",os,oid);
               fprintf(stderr,"***               fil_classid:%d  act_classid:%d\n",
                                         f_classid,a_classid);
               fprintf(stderr,"***               Class: %s\n",p_acld->s_name);
               fprintf(stderr,"***               fixed size:%d tot_size:%d vla:%d\n",
                                         fixed_size, size_to_write, diff);
               fprintf(stderr,"***               VLA size:%d\n",vla_size);
               fprintf(stderr,"***               VAD off:%d cnt:%d eltsz:%d typ:%d\n",
                                         p_vad->w_offset,p_vad->w_count,
                                         p_vad->w_per_elt_size,p_vad->type);
               return (1);
            }
         }

         /*==================================================*/
         /*  if VLA is a channel - validate its connections  */
         /*==================================================*/

         if ( p_vad->type && p->i_offset ) {
            if ( p_chan->flags & OM_CH_singleton ) {
               nument = 1;
               if ( p_chan->flags & OM_CH_restricted ) {
                  p_oid = (OM_p_OBJID)((OMuint)p_chan + 
                                            sizeof(OM_S_CHANNEL_HDR));
               }
               else {
                  p_link = (OM_p_CHANNEL_LINK)p_chan;
               }
            }
            else {
               if ( p_chan->flags & OM_CH_restricted ) {
                  p_oid = (OM_p_OBJID)((OMuint)p_chan + 
                                            sizeof(OM_S_CHANNEL_HDR));
                  linksz = sizeof(OM_S_OBJID);
               }
               else {
                  p_link = (OM_p_CHANNEL_LINK)((OMuint)p_chan + 
                                            sizeof(OM_S_CHANNEL_HDR));
                  linksz = sizeof(OM_S_CHANNEL_LINK);
               }
               
               OM_GET_TAIL(p_chan,tail);
               nument = tail.last_index;
               chan_count = tail.size;
            }
            if ( p_chan->flags & OM_CH_restricted ) {
               p_object = OM_GA_OSDs[os]->Spacemap[oid].state.object;
               p_channel = (OMuint)p_object + p_vad->w_offset;
               sts = om$get_mychan ( p_object   = (int) p_object,
                                     p_cld      = p_acld,
                                     p_channel  = p_channel,
                                     pp_chandef = &p_chdef,
                                     p_channum  = &chan_num );
               if (!(1&sts)) {
                  fprintf(stderr,"*** OS validate - error from get mychan\n");
               }
            
               for ( i=0; i<nument; ++i, ++p_oid ) {
                  if ( IF_NULL_OBJID(*p_oid) ) continue;
                  if ( IF_EQ_OBJID(*p_oid,oid) ) continue;
                  if (!(OM_GA_OSDs[os]->Spacemap[*p_oid].flags & OM_SM_in_mem))
                     continue;
                  csel.type = OM_e_num;
                  csel.u_sel.number = p_chdef->p_type->channum;
                  sts = om$is_objid_on_channel ( osnum_c = os,
                                                 objid_c = *p_oid,
                                                 p_chanselect = &csel,
                                                 objid   = oid,
                                                 osnum2  = os );
                  if ((!(1&sts)) && (sts != OM_E_NOSUCHCLASS)) {
                     fprintf(stderr,"*** OS validate - channel connection invalid\n");
                     fprintf(stderr,"***               OS:%d  Oid:%d\n",os,oid);
                     fprintf(stderr,"***               fil_classid:%d  act_classid:%d\n",
                                               f_classid,a_classid);
                     fprintf(stderr,"***               Class: %s\n",p_acld->s_name);
                     fprintf(stderr,"***               Channel is restricted\n");
                     fprintf(stderr,"***               Chan_off:%d\n",p_vad->w_offset);
                     fprintf(stderr,"***               Chan_hdr flags:%x(x) cnt:%d\n",
                                                     p_chan->flags,chan_count);
                     fprintf(stderr,"***               Last index:%d\n",nument);
                     fprintf(stderr,"***               Current index:%d\n",i);
                     fprintf(stderr,"***               Target oid:%d\n",*p_oid);
                     return (1);
                  }
               }
            }
            else {
               for ( i=0; i<nument; ++i, ++p_link ) {
                  if ( IF_NULL_OBJID(p_link->objid) ) continue;
                  if ( IF_EQ_OBJID(p_link->objid,oid) ) continue;
                  if (!(OM_GA_OSDs[os]->Spacemap[p_link->objid].flags &
                        OM_SM_in_mem))
                     continue;
                  if ( p_link->hdr.flags & OM_CL_to_object ) {
                     csel.type = OM_e_num;
                     csel.u_sel.number.number = p_link->channum.number;
                     csel.u_sel.number.classid = 
                          OM_GA_filed_to_active[p_link->channum.classid];
                     sts = om$is_objid_on_channel ( osnum_c = os,
                                                    objid_c = p_link->objid,
                                                    p_chanselect = &csel,
                                                    objid   = oid,
                                                    osnum2  = os );
                     if ((!(1&sts)) && (sts != OM_E_NOSUCHCLASS)) {
                        fprintf(stderr,"*** OS validate - channel connection invalid\n");
                        fprintf(stderr,"***               OS:%d  Oid:%d\n",os,oid);
                        fprintf(stderr,"***               fil_classid:%d  act_classid:%d\n",
                                                  f_classid,a_classid);
                        fprintf(stderr,"***               Class:%s\n",p_acld->s_name);
                        fprintf(stderr,"***               Chan_off:%d\n",p_vad->w_offset);
                        fprintf(stderr,"***               Chan_hdr flags:%x(x) cnt:%d\n",
                                                     p_chan->flags,chan_count);
                        fprintf(stderr,"***               Last index:%d\n",nument);
                        fprintf(stderr,"***               Current index:%d\n",i);
                        fprintf(stderr,"***               Target oid:%d\n",p_link->objid);
                        fprintf(stderr,"***               Target cnum:(%d,%d)\n",
                               p_link->channum.classid,p_link->channum.number);
                        return (1);
                     }
                  }
                  else {
                     sts = som_ISO_fetch ( os, p_link->hdr.u1.isoindex, 
                                p_link->objid, &os2, &oid2, &chan2, &flags2 );
                     if ( (!(1&sts)) && (sts != OM_W_OSNOTACTIVE) &&
                                        (sts != OM_E_NOSUCHCLASS)) {
                        fprintf(stderr,"*** OS validate - channel connection invalid\n");
                        fprintf(stderr,"***               OS:%d  Oid:%d\n",os,oid);
                        fprintf(stderr,"***               fil_classid:%d  act_classid:%d\n",
                                                  f_classid,a_classid);
                        fprintf(stderr,"***               Class:%s\n",p_acld->s_name);
                        fprintf(stderr,"***               Chan_off:%d\n",p_vad->w_offset);
                        fprintf(stderr,"***               Chan_hdr flags:%x(x) cnt:%d\n",
                                                     p_chan->flags,chan_count);
                        fprintf(stderr,"***               Last index:%d\n",nument);
                        fprintf(stderr,"***               Current index:%d\n",i);
                        fprintf(stderr,"***               Target oid:%d\n",p_link->objid);
                        fprintf(stderr,"***               Target cnum:(%d,%d)\n",
                               p_link->channum.classid,p_link->channum.number);
                        return (1);
                     }
                  }
               }
            }
         }
      }
   }
   
   return (0);
}

end implementation OMCluster;
