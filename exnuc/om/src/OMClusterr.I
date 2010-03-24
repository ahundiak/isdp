class   implementation  OMCluster;

#include	<stdio.h>
#include	<errno.h>
#include	<fcntl.h>
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "UNIXerrdef.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMcluster.h"
#include "OMmetaclass.h"
#include "OMOSfilehdr.h"

#ifdef BIG_ENDIAN
#include "OMport.h"

extern int              som_convert_instance();

extern OMuint           OM_Gf_ioMode;
#endif

extern  OMuint          som_cmpFileTimeStamp();
extern int		som_create_pc();
extern int		som_get_fcd();
extern int		som_getSlot();
extern int		som_init_pc();
extern int		som_modifyAccess();
extern int		som_releaseSlot();
extern int              som_return_fcd();
extern int              som_swapint();

extern  OMuint          OM_Gf_fileLocking;
extern  OM_p_ORIGOSNAME OM_Gp_orig_osname;
extern	struct OM_sd_lockFiles	**OM_GA_lockFiles;
extern	struct OM_sd_lockFileRec *OM_Gp_lockFileRec;
extern  OMuint          OM_Gi_phyClusterSize;
extern  OM_S_DLINK      OM_GQ_PCDavail;
extern  OMuint          OM_Gi_CSDarraySize;



/* 
revision history:

  GEO001 02-FEB-1988	om4.5 rewrite

  SAW001 Aug 1988       Add support for unknown classes in cluster fault
                        method.  New spacemap flag is set for objects of
                        unknown class. No vla fixup is done during fault
                        (or ever) for unknown objects.  Filed classid of
                        unknown objects is kept in spacemap acld field.

   SAW002 Feb 1992      "Port" to Sun big endian memory format.  Will
                        maintain same file format on all systems, but
                        Sun is big endian and requires porting of data
                        read in from file.
*/

method fault(int fp)

/* method to read in the cluster from the disk */
/* we get the osnum from OM_Gw_current_OS */

{
   int 			      zz, ii;
   OMuint		      sts,
                              objSize,    /* As in object header */
                              AobjSize;	  /* Size without flag bits */
   OM_S_OBJID                 oid;
   char			      *objects;
   OM_p_OBJECTHDR	      curObj=NULL;
   OM_p_PCD		      p_pcd;
   struct OMCluster_instance  *p_cluster;
   OM_p_CSD		      p_csd;
   OM_p_ORIGOSNAME            p_oname;
   char                       *filename=NULL;

#ifdef BIG_ENDIAN
   OMuword                    classid;
   char                       *p_temp;
#endif

   if (OM_Gf_fileLocking)
      sprintf(OM_Gp_lockFileRec->osnum, "%5d", OM_Gw_current_OS);
   if (ME.OMCluster->lcd.w_cluster_num)   /* Any other than Cluster 0 */
   {

      if (ME.OMCluster->lcd.flags & OM_FAULTED)
         return(OM_S_SUCCESS);

      /* open the file */
      p_oname = OM_Gp_orig_osname;
      while (p_oname)
      {
         if (p_oname->osnum == OM_Gw_current_OS)
            break;
         p_oname = p_oname->next;
      }
#ifndef NT
      if (p_oname)
      {
         filename = p_oname->orig_name;
         fp = (int) fopen(p_oname->orig_name,"r");
      }
      else
      {
         filename = OM_Gp_CurOSD->name;
         fp = (int) fopen(OM_Gp_CurOSD->name,"r");
      }
#else
      if (p_oname)
      {
         filename = p_oname->orig_name;
         fp = (int) fopen(p_oname->orig_name,"rb");
      }
      else
      {
         filename = OM_Gp_CurOSD->name;
         fp = (int) fopen(OM_Gp_CurOSD->name,"rb");
      }
#endif      
      if (!fp)
         return(UNIX_CONVERT_ERRNO(errno));
      if ((sts = som_cmpFileTimeStamp((FILE *) fp, 'r', filename,
         OM_Gp_CurSpaceMap))
          == OM_E_FILEOVRWRTN)
      {
         fclose((FILE *) fp);
         return(sts);
      }
#ifndef NT
      if (OM_Gf_fileLocking && ((OM_Gp_CurOSD->flags & OM_e_loados_ro) ||
         (OM_Gp_CurOSD->flags & OM_OSD_nowrite) || access(filename, 02)))
#else
      if (OM_Gf_fileLocking && ((OM_Gp_CurOSD->flags & OM_e_loados_ro) ||
         (OM_Gp_CurOSD->flags & OM_OSD_nowrite) || _access(filename, 02)))
#endif
      {
         /* Read-only file */

         if (!som_modifyAccess(OM_GA_lockFiles[OM_Gw_current_OS]->name, 'F'))
         {
            fclose((FILE *) fp);
            return(OM_E_ERROR);
         }
      }

      if(!(1&(sts = som_create_pc(&(ME.OMCluster->lcd), &p_pcd) )))
      {
         fclose((FILE *) fp);
         return(sts);
      }
      ME.OMCluster->lcd.p_pcd = p_pcd;
      p_cluster = ME.OMCluster;
   }        /* non-Cluster0 processint */

   else 	/* Cluster0 */
   {
      /*===========================================================*
       * Cluster 0 is in temporary storage (phantom) at this time. *
       * Treat Cluster 0 the same as other clusters except for vla *
       * fixup, spacemap acld initialization, using paged slots    *
       * instead of locked slots, and keeping the file open.       *
       *===========================================================*/

      if (!fp) /* We don't know the filename yet - has to be passed in */
         return(OM_E_INVARG);

      if (!(1&(sts=som_getSlot(&p_csd))))
         return(sts);

      p_csd->flag = OM_CLUST0 | OM_INUSE;

      /*---------------------------------------------------*/
      /* Allocate PCD, if queue of available is empty      */
      /* carve up a new hunk and link to pcd avail queue   */
      /* keeping first one for one needed now.             */
      /* Put macro in line for error handling on no dyn mem*/
      /*---------------------------------------------------*/

      if(OM_QUEUE_EMPTY(&OM_GQ_PCDavail))
      {
         OM_S_PCD	*p_tmp;
         if(!(((OM_p_DLINK)(&OM_GQ_PCDavail))->next=
            (OM_p_DLINK)om$malloc(size=100*sizeof(OM_S_PCD))))
         {
            som_releaseSlot(p_csd);
            return(OM_E_NODYNMEM);
         }
         for(p_tmp=(OM_S_PCD *)((OM_p_DLINK)(&OM_GQ_PCDavail))->next;
            p_tmp < ((OM_S_PCD *)((OM_p_DLINK)(&OM_GQ_PCDavail))->next)+(100);
            p_tmp++)
         {
            p_tmp->pcdq.next = (OM_p_DLINK) &((p_tmp+1)->pcdq.next);
            p_tmp->pcdq.prev = (OM_p_DLINK) &((p_tmp-1)->pcdq.next);
         }
         (((OM_p_DLINK)(&OM_GQ_PCDavail))->next) =
            (OM_p_DLINK)((int) (((OM_p_DLINK)(&OM_GQ_PCDavail))->next) +
            (OM_SD_FIELD_OFFSET(OM_S_PCD, pcdq)));

         ((OM_p_DLINK) (&OM_GQ_PCDavail))->prev =
            (OM_p_DLINK) &((p_tmp-1)->pcdq.next);

         ((OM_p_DLINK)(&OM_GQ_PCDavail))->prev->next =
            ((OM_p_DLINK)(&OM_GQ_PCDavail));
         ((OM_p_DLINK)(&OM_GQ_PCDavail))->next->prev =
            ((OM_p_DLINK)(&OM_GQ_PCDavail));
      }
      OM_DEQUEUE_FROM_HEAD(&OM_GQ_PCDavail, p_pcd, OM_p_PCD)    /* get 1st avail pcd */

      som_init_pc(p_pcd, &(ME.OMCluster->lcd),p_csd);
      p_cluster = ME.OMCluster;
      p_cluster->lcd.p_pcd = p_csd->p_pcd = p_pcd;
      om$vla_fixup(p_object=(OM_p_OBJECTHDR) me, type='r');
   }

#ifdef BIG_ENDIAN
   OM_Gf_ioMode = READ_PORT;
#endif

   /*==================================================================*
    * resume processing common to all clusters:                        *
    * got memory for objects so ... read one object at a time into     *
    * memory inserting its oid into the objecthdr (which was           *
    * stripped out when written - however object size in the objecthdr *
    * is its quad aligned size, including entire objecthdr size)       *
    * .. update objects spacemap .. fixup its vlas		       *
    *==================================================================*/

   objects = p_pcd->p_csd->p_addr;
   p_pcd->i_totalfree = p_pcd->i_totalsize;
   p_cluster->lcd.i_cur_bytes_allocated = 0;

   /* position at the place where the cluster is located */

   if (fseek((FILE *) fp, p_cluster->lcd.i_file_ptr, 0))
   {
      if (ME.OMCluster->lcd.w_cluster_num)
         fclose((FILE *) fp);
      OM_DEQUEUE_ELEMENT(&(p_pcd->pcdq))
      OM_QUEUE_AT_HEAD(&OM_GQ_PCDavail, &(p_pcd->pcdq))
      som_releaseSlot(p_pcd->p_csd);
      return(UNIX_CONVERT_ERRNO(errno));
   }

   for(ii=0; ii < (int) ME.OMCluster->i_fil_num_objects; ii++)
   {
      /*============================================================*/
      /* Read the objects into memory 1 at a time.  First read size */
      /* field, find room for object, then read in object instance. */
      /*============================================================*/

      oid = ME.OMCluster->i_filed_oid_list[ii];

#ifdef BIG_ENDIAN

      if (OM_Gp_CurSpaceMap[oid].flags & OM_SM_unknown_obj)
         classid = (OMuword) OM_Gp_CurSpaceMap[oid].p_acld;
      else
      {
         if (!ME.OMCluster->lcd.w_cluster_num)
             OM_Gp_CurSpaceMap[oid].p_acld = (OM_p_CLASSDEF)
             OM_GA_active_classes[classid=ME.OMCluster->w_filed_classid_list[ii]];
         else
            classid = OM_Gp_CurSpaceMap[oid].p_acld->w_classid;
      }

      if (!(OM_Gp_CurSpaceMap[oid].flags & OM_SM_unknown_obj) &&
         (!OM_Gp_CurSpaceMap[oid].p_acld ||
         !OM_Gp_CurSpaceMap[oid].p_acld->p_instance_def))
      {
         fprintf(stderr, "OMCluster.fault: Class %s is not in the dictionary.\n  Cannot convert object %d at file location %d, filed class id %d.\n  Cannot retrieve file.\n",
            OM_Gp_CurSpaceMap[oid].p_acld->s_name, oid,
            ftell((FILE *) fp), classid);
         sts = OM_E_ERROR;
         goto err;
      }
#endif

      fseek((FILE *) fp, sizeof(OM_S_FILEOBJHDR) - sizeof(OMuint), 1);
      if ((zz = fread (&objSize, 1, sizeof(OMuint), (FILE *) fp)) !=
      sizeof(OMuint))
      {
         sts = OM_E_READ_ERROR;
         goto err;
      }

#ifdef BIG_ENDIAN
      som_swapint(&objSize, &sts);
      objSize = sts;
#endif

      if (!(AobjSize = OM_GETOBJSIZE(objSize)))    /* Get the object size */
      {
         sts = OM_E_ERROR;
         goto err;
      }

      if (AobjSize > OM_Gi_phyClusterSize)    /* Big object? */
      {
         OM_p_CSD	      p_csd;
         OM_p_OBJECTHDR       p_newObj;
         OM_p_PCD             p_bigPCD;

         if (!(1&(sts=som_create_big_object(p_cluster->lcd.w_cluster_num, 
                      AobjSize, OM_Gp_CurOSD, &p_newObj, &p_csd))))
            goto err;
         fseek((FILE *) fp, -((int)sizeof(OM_S_OBJECTHDR)), 1); /* Back up to oid field */

#ifdef BIG_ENDIAN

         if (!(OM_Gp_CurSpaceMap[oid].flags & OM_SM_unknown_obj))
         {
            if (!(p_temp = (char *) om$malloc(size=AobjSize)))
            {
               sts = OM_E_NODYNMEM;
               goto err;
            }
            zz = fread((char *)p_temp, 1, AobjSize, (FILE *) fp);
            if (zz != AobjSize)
            {
               sts = OM_E_READ_ERROR;
               goto err;
            }

            OM_BLOCK_MOVE(p_temp, p_newObj, AobjSize);
            if (!(1&(sts = som_convert_instance(p_temp, p_newObj,
               OM_Gp_CurSpaceMap[oid].p_acld))))
            {
               fprintf(stderr, "OMCluster.fault: Conversion failed for object %d at file location %d,\n   class id %d (%s).  Cannot retrieve file.\n",
                  oid, ftell((FILE *) fp) - AobjSize, classid,
                  OM_Gp_CurSpaceMap[oid].p_acld->s_name);
               goto err;
            }
            else
            {
               om$dealloc(ptr=p_temp);
               p_newObj->i_size &= 0xfffffffe;/* Make sure low flag is clr */
            }
         }
         else     /* Unknown object */
         {
            zz = fread((char *)p_newObj, 1, AobjSize, (FILE *) fp);
            if (zz != AobjSize)
            {
               sts = OM_E_READ_ERROR;
               goto err;
            }
            som_swapint(&p_newObj->oid, &sts);
            p_newObj->oid = sts;
            som_swapint(&p_newObj->i_size, &sts);
            p_newObj->i_size = sts;
            p_newObj->i_size &= 0xfffffffe;/* Make sure low flag is clr */
         }
#else
         zz = fread((char *)p_newObj, 1, AobjSize, (FILE *) fp);
         if (zz != (int) AobjSize)
         {
            sts = OM_E_READ_ERROR;
            goto err;
         }

         p_newObj->i_size &= 0xfffffffe;/* Make sure low flag is clr */
#endif
         curObj = p_newObj;
         p_bigPCD = p_csd->p_pcd;
         p_bigPCD->i_cur_num_chunks++;
         p_bigPCD->i_cur_num_objects++;
         OM_Gp_CurSpaceMap[oid].state.object = p_newObj;
         OM_Gp_CurSpaceMap[oid].flags |= (OM_SM_in_use|OM_SM_in_mem);
         OM_Gp_CurSpaceMap[oid].sdi = p_bigPCD->p_csd->index;
      }
      else	/* NOT BIG OBJECT */
      {
         if(p_pcd->i_totalfree >= AobjSize) /* FITS */
         {
            fseek((FILE *) fp, -((int)sizeof(OM_S_OBJECTHDR)), 1);  /* Back up to oid */

#ifdef BIG_ENDIAN

            if (!(OM_Gp_CurSpaceMap[oid].flags & OM_SM_unknown_obj))
            {
               if (!(p_temp = (char *) om$malloc(size=AobjSize)))
               {
                  sts = OM_E_NODYNMEM;
                  goto err;
               }
               zz = fread(p_temp, 1, AobjSize, (FILE *) fp);
               if( zz != AobjSize) 
               {
                  sts = OM_E_READ_ERROR;
                  goto err;
               }
               curObj = (OM_p_OBJECTHDR) objects;
               OM_BLOCK_MOVE(p_temp, objects, AobjSize);
               if (!(1&(sts = som_convert_instance(p_temp, objects,
                  OM_Gp_CurSpaceMap[oid].p_acld))))
               {
                  fprintf(stderr, "OMCluster.fault: Conversion failed for object %d at file location %d,\n   class id %d (%s).  Cannot retrieve file.\n",
                     oid, ftell((FILE *) fp) - AobjSize, classid,
                     OM_Gp_CurSpaceMap[oid].p_acld->s_name);
                  goto err;
               }
               else
               {
                  om$dealloc(ptr=p_temp);
                  curObj->i_size &= 0xfffffffe;/* Make sure low flag is clr */
               }
            }
            else  /* Unknown object */
            {
               zz = fread(objects, 1, AobjSize, (FILE *) fp);
               if( zz != AobjSize) 
               {
                  sts = OM_E_READ_ERROR;
                  goto err;
               }
               curObj = (OM_p_OBJECTHDR) objects;
               som_swapint(&curObj->oid, &sts);
               curObj->oid = sts;
               som_swapint(&curObj->i_size, &sts);
               curObj->i_size = sts;
               curObj->i_size &= 0xfffffffe;/* Make sure low flag is clr */
            }
#else
            zz = fread(objects, 1, AobjSize, (FILE *) fp);
            if( zz != (int) AobjSize) 
            {
               sts = OM_E_READ_ERROR;
               goto err;
            }
            curObj = (OM_p_OBJECTHDR) objects;
            curObj->i_size &= 0xfffffffe;/* Make sure low flag is clr */
#endif

         }
         else	/* Does Not Fit in Current Physical Cluster */
         {
            OM_p_PCD	nextpcd;
            int		fits;

            /*================================================================*/
            /* Fill in fcd for current pcd, since a new current pcd is about  */
            /* to be created and this one may be swapped out so must be valid */
            /*================================================================*/

            if(p_pcd->i_totalfree)
            {
               OM_p_FCD	fcd;
               OM_p_CLUSTFHDR p_obj;

               p_obj = (OM_p_CLUSTFHDR) objects;
               if(!(1&(sts=som_get_fcd(&fcd))))
                  goto err;
               fcd->nextfcd = NULL;
               fcd->freehdr = p_obj;
               fcd->size = p_obj->size = p_pcd->i_totalfree;
               OM_SETFREEBIT(p_obj->size)
               p_pcd->p_fcd = p_obj->p_fcd = fcd;
               p_pcd->i_numfree_chunks++;
            }
            /*===============================================================*/
            /* When LCD has >1 PCD, try to fit this object into previous PCD */
            /* AND this is not a fakecluster( not implemented )		 */
            /*===============================================================*/

            fits = FALSE;
            if( p_cluster->lcd.pcdq_lh.next != p_cluster->lcd.pcdq_lh.prev )
            {
               nextpcd = (OM_p_PCD)(p_cluster->lcd.pcdq_lh.next);
               while( nextpcd != (OM_p_PCD) &(p_cluster->lcd.pcdq_lh.next) )
               {
                  if(nextpcd->i_totalfree >= AobjSize)
                  {
                     curObj = (OM_p_OBJECTHDR)nextpcd->p_fcd->freehdr;
                     fseek((FILE *) fp, -((int) sizeof(OM_S_OBJECTHDR)), 1);

#ifdef BIG_ENDIAN
                     if (!(OM_Gp_CurSpaceMap[oid].flags & OM_SM_unknown_obj))
                     {
                        if (!(p_temp = (char *) om$malloc(size=AobjSize)))
                        {
                           sts = OM_E_NODYNMEM;
                           goto err;
                        }
                        zz = fread((char *) p_temp, 1, AobjSize, (FILE *) fp);
                        if( zz != AobjSize)
                        {
                           sts = OM_E_READ_ERROR;
                           goto err;
                        }
                        OM_BLOCK_MOVE(p_temp, curObj, AobjSize);
                        if (!(1&(sts = som_convert_instance(p_temp, curObj,
                           OM_Gp_CurSpaceMap[oid].p_acld))))
                        {
                           fprintf(stderr,
                              "OMCluster.fault: Conversion failed for object %d at file location %d,\n   class id %d (%s).  Cannot retrieve file.\n",
                              oid, ftell((FILE *) fp) - AobjSize, classid,
                              OM_Gp_CurSpaceMap[oid].p_acld->s_name);
                           goto err;
                        }
                        else
                        {
                           om$dealloc(ptr=p_temp);
                           curObj->i_size &= 0xfffffffe;/* Make sure low flag is clr */
                        }
                     }
                     else
                     {
                        zz = fread((char *) curObj, 1, AobjSize, (FILE *) fp);
                        if( zz != AobjSize)
                        {
                           sts = OM_E_READ_ERROR;
                           goto err;
                        }
                        som_swapint(&curObj->oid, &sts);
                        curObj->oid = sts;
                        som_swapint(&curObj->i_size, &sts);
                        curObj->i_size = sts;
                        curObj->i_size &= 0xfffffffe;/* Make sure low flag is clr */
                     }
#else
                     zz = fread((char *) curObj, 1, AobjSize, (FILE *) fp);
                     if( zz != (int) AobjSize)
                     {
                        sts = OM_E_READ_ERROR;
                        goto err;
                     }
                     curObj->i_size &= 0xfffffffe;/* Make sure low flag is clr */
#endif

                     objects = (char *) curObj;
                     p_pcd = nextpcd;	/* New Current PCD */
                     som_return_fcd(nextpcd->p_fcd);
                     nextpcd->p_fcd = 0;
                     nextpcd->i_numfree_chunks--;
                     fits = TRUE;
                     break;
                  }
                  nextpcd = (OM_p_PCD) nextpcd->pcdq.next;
               }
            }

            if (! fits)
            {
               /* Non-cluster0 case */
               if( p_cluster->lcd.w_cluster_num )
               {
                  if(!(1&(sts = som_create_pc(&(p_cluster->lcd), &p_pcd) )))
                     goto err;
               }
               else	/* cluster 0 */
               {
                  /*--------------------------------------*/
                  /* Get a paged slot which returns a csd */
                  /*--------------------------------------*/

                  if(!(1&(sts=som_getSlot(&p_csd))))
                     goto err;

                  /*================================*/
                  /* Initialize newly allocated CSD */
                  /*================================*/

                  p_csd->flag = OM_CLUST0 | OM_INUSE;

                  /*---------------------------------------------------*/
                  /* Allocate PCD, if queue of available is empty      */
                  /* carve up a new hunk and link to pcd avail queue   */
                  /* keeping first one for one needed now.             */
                  /*---------------------------------------------------*/

                  if(OM_QUEUE_EMPTY(&OM_GQ_PCDavail))
                  {
                     OM_S_PCD	*p_tmp;
                     if(!(((OM_p_DLINK)(&OM_GQ_PCDavail))->next=
                        (OM_p_DLINK)om$malloc(size=100*sizeof(OM_S_PCD))))
                     {
                        som_releaseSlot(p_csd);
                        sts = OM_E_NODYNMEM;
                        goto err;
                     }
                     for(p_tmp=(OM_S_PCD *)((OM_p_DLINK)(&OM_GQ_PCDavail))->
                        next;
                        p_tmp < ((OM_S_PCD *)((OM_p_DLINK)(&OM_GQ_PCDavail))->
                           next)+(100);
                        p_tmp++)
                     {
                        p_tmp->pcdq.next = (OM_p_DLINK) &((p_tmp+1)->pcdq.next);
                        p_tmp->pcdq.prev = (OM_p_DLINK) &((p_tmp-1)->pcdq.next);
                     }
                     (((OM_p_DLINK)(&OM_GQ_PCDavail))->next) =
                     (OM_p_DLINK)((int) ((OM_p_DLINK)(&OM_GQ_PCDavail))->next) +
                        OM_SD_FIELD_OFFSET(OM_S_PCD, pcdq);
                     ((OM_p_DLINK)(&OM_GQ_PCDavail))->prev =
                        (OM_p_DLINK) &((p_tmp-1)->pcdq.next);
                     ((OM_p_DLINK)(&OM_GQ_PCDavail))->prev->next =
                        ((OM_p_DLINK)(&OM_GQ_PCDavail));
                     ((OM_p_DLINK)(&OM_GQ_PCDavail))->next->prev =
                        ((OM_p_DLINK)(&OM_GQ_PCDavail));
                  }
                  OM_DEQUEUE_FROM_HEAD(&OM_GQ_PCDavail, p_pcd, OM_p_PCD)

                  /*--------------------*/
                  /* Initialize new PCD */
                  /*--------------------*/
                  som_init_pc(p_pcd, &(ME.OMCluster->lcd),p_csd);
                  p_csd->p_pcd = p_pcd;
               }
               objects = p_pcd->p_csd->p_addr;
               fseek((FILE *) fp, -((int) sizeof(OM_S_OBJECTHDR)), 1);

#ifdef BIG_ENDIAN
               if (!(OM_Gp_CurSpaceMap[oid].flags & OM_SM_unknown_obj))
               {
                  if (!(p_temp = (char *) om$malloc(size=AobjSize)))
                  {
                     sts = OM_E_NODYNMEM;
                     goto err;
                  }
                  zz = fread((char *) p_temp, 1, AobjSize, (FILE *) fp);
                  if( zz != (int) AobjSize)
                  {
                     sts = OM_E_READ_ERROR;
                     goto err;
                  }
                  curObj = (OM_p_OBJECTHDR) objects;
                  OM_BLOCK_MOVE(p_temp, curObj, AobjSize);
                  if (!(1&(sts = som_convert_instance(p_temp, curObj,
                     OM_Gp_CurSpaceMap[oid].p_acld))))
                  {
                     fprintf(stderr,
                        "OMCluster.fault: Conversion failed for object %d at file location %d,\n   class id %d (%s).  Cannot retrieve file.\n",
                        oid, ftell((FILE *) fp) - AobjSize, classid,
                        OM_Gp_CurSpaceMap[oid].p_acld->s_name);
                     goto err;
                  }
                  else
                  {
                     om$dealloc(ptr=p_temp);
                     curObj->i_size &= 0xfffffffe;/* Make sure low flag is clr */
                  }
               }
               else     /* Unknown object */
               {
                  zz = fread((char *) objects, 1, AobjSize, (FILE *) fp);
                  if( zz != AobjSize)
                  {
                     sts = OM_E_READ_ERROR;
                     goto err;
                  }
                  curObj = (OM_p_OBJECTHDR) objects;
                  som_swapint(&curObj->oid, &sts);
                  curObj->oid = sts;
                  som_swapint(&curObj->i_size, &sts);
                  curObj->i_size = sts;
                  curObj->i_size &= 0xfffffffe;/* Make sure low flag is clr */
               }
#else
               zz = fread((char *) objects, 1, AobjSize, (FILE *) fp);
               if( zz != (int) AobjSize)
               {
                  sts = OM_E_READ_ERROR;
                  goto err;
               }
               curObj = (OM_p_OBJECTHDR) objects;
               curObj->i_size &= 0xfffffffe;/* Make sure low flag is clr */
#endif
               p_pcd->i_totalfree = p_pcd->i_totalsize;
            }  /* FITS into previous physical cluster */
         }   /* does not FIT in current physical cluster */

         /* SPACEMAP AND VLA FIXUP */
         /* .. point the spacemap to the object  and  fill in its objhdr */
         OM_Gp_CurSpaceMap[oid].state.object = (OM_p_OBJECTHDR) objects;
         OM_Gp_CurSpaceMap[oid].flags |= (OM_SM_in_use|OM_SM_in_mem);
         OM_Gp_CurSpaceMap[oid].sdi = p_pcd->p_csd->index;
         ((OM_p_OBJECTHDR) objects)->oid = oid;
         ((OM_p_OBJECTHDR) objects)->i_size = objSize & 0xfffffffe;/* Clr low flg */

         p_pcd->i_totalfree -= AobjSize;
         p_pcd->i_cur_num_objects++;
         p_pcd->i_cur_num_chunks++;

         /* update the object pointer */
         objects += AobjSize;
      }        /* Not Big Object */

      /*===================================================================*/
      /* Change vla offsets back to direct pointers.  There are two cases: */
      /* if this is cluster 0: any class that is not a metaclass should    */
      /* not be fixed because the filed to active maps are not set up for  */
      /* any classes except metaclasses.  The non-metaclass objects in     */
      /* cluster 0 are fixed in the FiledOS.init method (after the OSCOs   */
      /* restore the filed to active maps) as well as the SpaceMap p_acld. */
      /* If this is not cluster 0, the filed to active maps have been      */
      /* set-up so we can fill in SpaceMap p_acld & fix all the objects in */
      /* this cluster.                                                     */
      /*===================================================================*/

      if (! ME.OMCluster->lcd.w_cluster_num)
      {
         if (ME.OMCluster->w_filed_classid_list[ii] < OM_K_NUM_META_CLASSES)
         {
            /* metaclasses active classids == filed classids */

            if (OM_Gp_CurSpaceMap[oid].flags & OM_SM_unknown_obj)
                OM_Gp_CurSpaceMap[oid].p_acld = (OM_p_CLASSDEF)
                ME.OMCluster->w_filed_classid_list[ii];
            else
            {
               OM_Gp_CurSpaceMap[oid].p_acld = OM_GA_active_classes
                  [ME.OMCluster->w_filed_classid_list[ii]];
               om$vla_fixup(p_object=curObj, type='r');
            }
         }
      }
      else   /* SpaceMap's p_acld is initialized at Clust0 time */
      {
         if (!(OM_Gp_CurSpaceMap[oid].flags & OM_SM_unknown_obj))
            om$vla_fixup(p_object=curObj, type='r');
      }
   }        /* For Each Object Within Logical Cluster */

   /*===============================*/
   /* fix last current pcd's fcd    */
   /*===============================*/

   /* check for case where cluster had all BIG objects and pcd is empty */
   if(p_pcd->i_totalfree == p_pcd->i_totalsize)
   {
      som_releaseSlot(p_pcd->p_csd);
      OM_DEQUEUE_ELEMENT(&(p_pcd->pcdq))
      OM_QUEUE_AT_HEAD(&OM_GQ_PCDavail,&(p_pcd->pcdq))
   }
   else
   {
      OM_p_FCD       fcd;
      OM_p_CLUSTFHDR p_obj;

      if(p_pcd->i_totalfree)
      {
         p_obj = (OM_p_CLUSTFHDR)objects;
         if(!(1&(sts=som_get_fcd(&fcd))))
            goto err;
         fcd->nextfcd = NULL;
         fcd->freehdr = p_obj;
         fcd->size = p_obj->size = p_pcd->i_totalfree;
         OM_SETFREEBIT(p_obj->size)
         p_pcd->p_fcd = p_obj->p_fcd = fcd;
         p_pcd->i_numfree_chunks++;
      }
   }

   /* set lcd ptr to pcd to the one with most free bytes */

   p_pcd = (OM_p_PCD)(p_cluster->lcd.pcdq_lh.next);
   p_cluster->lcd.p_pcd = p_pcd;	/* 1st pcd */
   while( p_pcd != (OM_p_PCD) &(p_cluster->lcd.pcdq_lh.next) )
   {
      /*=========================================*/
      /* update OSD's last cluster faulted queue */
      /*=========================================*/
      if (ME.OMCluster->lcd.w_cluster_num && 
          !(p_cluster->lcd.flags & OM_USERSPEC) && p_pcd->i_totalsize)
      {
         OM_QUEUE_AT_HEAD(&(OM_Gp_CurOSD->lcfq_lh),&(p_pcd->lcfq))
      }

      if( p_pcd->i_totalfree > p_cluster->lcd.p_pcd->i_totalfree )
         p_cluster->lcd.p_pcd = p_pcd;
      p_pcd = (OM_p_PCD) p_pcd->pcdq.next;
   }

   /* mark ourselves as faulted. */
   ME.OMCluster->lcd.flags |= OM_FAULTED;

   /*=======================================================*/
   /* if not cluster 0, close the file and since            */
   /* we don't need the list of oids anymore, throw it away */
   /*=======================================================*/
   if(ME.OMCluster->lcd.w_cluster_num)
   {
      fclose((FILE *) fp);	
      om$vla_set_dimension(varray=ME.OMCluster->i_filed_oid_list, size=0);
   }
#ifndef NT
   if (OM_Gf_fileLocking && ((OM_Gp_CurOSD->flags & OM_e_loados_ro) ||
      (OM_Gp_CurOSD->flags & OM_OSD_nowrite) ||
      (ME.OMCluster->lcd.w_cluster_num && access(filename, 02))))
#else
   if (OM_Gf_fileLocking && ((OM_Gp_CurOSD->flags & OM_e_loados_ro) ||
      (OM_Gp_CurOSD->flags & OM_OSD_nowrite) ||
      (ME.OMCluster->lcd.w_cluster_num && _access(filename, 02))))
#endif
   {
      char  all_faulted;

      if (!ME.OMCluster->lcd.w_cluster_num)
         all_faulted = 0;
      else
      {
         for (all_faulted=1,ii=0; ii<(int)OM_Gp_CurOSD->ClustersSize; ii++)
         {
            if (OM_Gp_CurOSD->Clusters[ii] && !(OM_Gp_CurOSD->Clusters[ii]->
                flags & OM_FAULTED))
               all_faulted = 0;
         }
      }
      if (all_faulted)
         som_modifyAccess(OM_GA_lockFiles[OM_Gw_current_OS]->name, 'r');
      else        /* Turn off 'F' access */
         som_modifyAccess(OM_GA_lockFiles[OM_Gw_current_OS]->name, 'R');
   }

   return(OM_S_SUCCESS);

err:
   if(ME.OMCluster->lcd.w_cluster_num)
      fclose((FILE *) fp);
   p_pcd = (OM_p_PCD)(p_cluster->lcd.pcdq_lh.next);
   while( p_pcd != (OM_p_PCD) &(p_cluster->lcd.pcdq_lh.next) )
   {
      OM_p_PCD next;

      if(p_pcd && p_pcd->p_csd >= &(OM_GA_CSDarray[0]) &&
         p_pcd->p_csd < &(OM_GA_CSDarray[OM_Gi_CSDarraySize]) &&
         p_pcd->p_csd->flag & OM_INUSE)
         som_releaseSlot(p_pcd->p_csd);
      next = (OM_p_PCD) p_pcd->pcdq.next;
      OM_DEQUEUE_ELEMENT(&(p_pcd->pcdq))
      OM_QUEUE_AT_HEAD(&OM_GQ_PCDavail, &(p_pcd->pcdq))
      p_pcd = next;
   }
   for(ii=0; ii < (int) ME.OMCluster->i_fil_num_objects; ii++)
   {
      oid = ME.OMCluster->i_filed_oid_list[ii]; 
      OM_Gp_CurSpaceMap[oid].state.filed_obj.clusterid = 
         ME.OMCluster->lcd.w_cluster_num;
      OM_Gp_CurSpaceMap[oid].flags = OM_SM_in_use;
   }
   return(sts);
}

end implementation OMCluster;
