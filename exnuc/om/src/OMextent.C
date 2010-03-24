/*
--------------------------------------------------------------------------
File Name:	OMextent.c
Abstract:
		Primitives to manage extents of virtual memory and are
		the building blocks of clusters within an object space.


		rme001	17-apr-1987	Added check for tagged object to
					som_delete_object.

		rme002	29-apr-1987	Added new flag for free_space
					so that part of an existing outrigger
					can be set free.

		rme003	05-may-1987	Removed resize object.

                ems001  21-may-1987     Removed make_message calls

		geo001  17-nov-1987	Massive changes for 4.5:
					Extents become Physical Clusters
					which have a size of a multiple
					of LUMP (62K)

		geo002  05-oct-1988	Validate objects' sizes compared
					to lcd's file size indicator
					(i_cur_bytes_allocated)
--------------------------------------------------------------------------
*/

#include	<stdio.h>
#include	<memory.h>
#include 	"OMminimum.h"
#include	"OMprimitives.h"
#include	"OMcluster.h"
#include	"OMerrordef.h"
#include	"OMmacros.h"
#include	"OMspecify.h"
#include	"OMrelation.h"
#include	"OMintprims.h"
#include	"OMmetaclass.h"
#include	"OMOSfilehdr.h"
#include	"DIdef.h"
#include	"DItypedef.h"
#include 	"DIprims.h"

extern int som_dealloc_sheap_vlas();
extern int som_create_cluster0_obj();
extern int som_create_user_cluster_obj();
extern int som_auto_cluster();
extern int som_getSlot();
extern void som_releaseSlot();
extern int som_init_pc();
extern int som_compress_pcd();
extern OM_S_SYSINFO  *OM_Gp_SYSINFO;

#define	OM_MORE_FCDs_INCREMENT	1000

extern OM_p_FCD		OM_Gp_FCD_HEAD;
extern OMuint   	OM_Gi_FCDs_ALLOCATED;
extern OMuint		OM_Gi_FCDs_USED;

extern OMuword  OMCluster_OPP_fault_method_index;
extern OMuword  OMCluster_OPP_init_OMCluster_method_index;
extern OMuword  OMCluster_OPP_remove_method_index;
extern OMuword  Root_OPP_delete_method_index;   
extern OMuword  Root_OPP_wild_disconnect_method_index;   

extern OMuint   OM_Gi_totalObjMem;
extern OMuint	OM_Gi_LCFqueueDepth;
extern OMuint	OM_Gi_phyClusterSize;
extern OMuint   OM_Gi_CSDarraySize;
extern OM_S_DLINK OM_GQ_regCSDavail;	/* regular CSD avail queue */
extern OM_S_DLINK OM_GQ_bigCSDavail;	/* bigobject CSD avail queue */
extern OM_S_DLINK OM_GQ_PCDavail;	/* PCD avail queue */
extern OMuint	OM_Gi_CSDarrayNextSlot;


/*=================================================*/
/* Internal function to return next available      */
/* free chunk descriptor; allocates more if needed */
/*=================================================*/

som_get_fcd (OM_p_FCD *pp_fcd)
{
   OM_p_FCD	tmpfcd;


if(! OM_Gp_FCD_HEAD)		/* system fcd queue is empty; get more */
{
  if(!(OM_Gp_FCD_HEAD = (OM_p_FCD)om$malloc(size=OM_MORE_FCDs_INCREMENT 
				* sizeof(OM_S_FCD))))
	return(OM_E_NODYNMEM);

  /* queue up all fcds to system free queue */

  for(tmpfcd=OM_Gp_FCD_HEAD; 
      tmpfcd < OM_Gp_FCD_HEAD + OM_MORE_FCDs_INCREMENT;
      tmpfcd++)
  {
    tmpfcd->nextfcd = tmpfcd + 1;
  }
  OM_Gp_FCD_HEAD[OM_MORE_FCDs_INCREMENT-1].nextfcd = NULL;
  OM_Gi_FCDs_ALLOCATED += OM_MORE_FCDs_INCREMENT;
}

*pp_fcd = OM_Gp_FCD_HEAD;
OM_Gp_FCD_HEAD = OM_Gp_FCD_HEAD->nextfcd;
OM_Gi_FCDs_USED++;

return(OM_S_SUCCESS);
}

	
/*====================================================*/
/* Internal function to return to system free queue a */
/* free chunk descriptor		              */
/*====================================================*/

void som_return_fcd (OM_p_FCD p_fcd)
{
   p_fcd->nextfcd = OM_Gp_FCD_HEAD;
   OM_Gp_FCD_HEAD = p_fcd;
   OM_Gi_FCDs_USED --;
}


/*=================================================*/
/* Internal function to coalesce higher address    */
/* free chunk descriptors as can                   */
/* p_instance is following object, outrigger, or   */
/* freespace which is behing a new free chunk      */
/*=================================================*/

som_coalesce(OM_p_PCD p_pcd, OM_p_CLUSTFHDR p_instance)
{
OM_p_CLUSTFHDR  p_tmp;
OMuint size, newsize;

if ((p_instance < (OM_p_CLUSTFHDR) p_pcd->p_csd->p_addr) ||
    (p_instance >= (OM_p_CLUSTFHDR) (p_pcd->p_csd->p_addr +
    p_pcd->i_totalsize)))
	return(OM_S_SUCCESS);

if ( ! OM_FREEBIT( p_instance->size) ) 
	return(OM_S_SUCCESS); /* Get out quick */

p_tmp = (OM_p_CLUSTFHDR) ( (char *)p_instance +
                                OM_GETFREESIZE(p_instance->size) );
if (p_tmp >= (OM_p_CLUSTFHDR) (p_pcd->p_csd->p_addr + p_pcd->i_totalsize)) 
	return(OM_S_SUCCESS);

while ( OM_FREEBIT(p_tmp->size) )
    {
    /* Check the next block to see if it is a free chunk.  If so, add it
     * to the first one and remove it from the free list in the extent 
     */
    size = OM_GETFREESIZE(p_tmp->size);
    newsize = (p_instance->p_fcd->size += size);
    p_instance->size = newsize;
    OM_SETFREEBIT(p_instance->size);
        /* Need to get rid of the free chunk descriptor.  Since free chunks
         * are kept in ascending sequence by address, the FCD to be freed
         * should be the next one. If not, mucho problemo.
         */
        if (p_instance->p_fcd->nextfcd != p_tmp->p_fcd)
            {
            return(OM_E_INTERNALS_CORRUPT);  /* Panic here */
            }
        else
            {
            p_instance->p_fcd->nextfcd = p_tmp->p_fcd->nextfcd;
            som_return_fcd( p_tmp->p_fcd );
	    p_pcd->i_numfree_chunks--;
            }
    p_tmp = (OM_p_CLUSTFHDR) ( (char *)p_tmp + OM_GETFREESIZE(p_tmp->size) );
    if (p_tmp >= (OM_p_CLUSTFHDR) (p_pcd->p_csd->p_addr + p_pcd->i_totalsize))
       break;
    }
return(OM_S_SUCCESS);
}


/*==================================================*/
/* Internal function used by free_space, and        */
/* and swap_out to insert fcd into proper spot      */
/* of linked list, coalescing with other free space */
/*==================================================*/

som_insert_fcd (OM_p_OBJECTHDR p_instance, OM_p_PCD pcd)
{
 OM_p_CLUSTFHDR rear_object;
 OM_p_FCD	fcd, *ppfcd;
 int		inserted_fcd=FALSE;
 OMuint		sts, a_size;


    /*================================*/
    /* coalesce with rear if possible */
    /*================================*/
    a_size = OM_GETOBJSIZE(p_instance->i_size);
    rear_object = (OM_p_CLUSTFHDR)((char *)p_instance + a_size);
    if((rear_object < (OM_p_CLUSTFHDR) (pcd->p_csd->p_addr + pcd->i_totalsize))
    				&&
       (OM_FREEBIT(rear_object->size)))  /* coalesce with free space */
    {
	/* free space descriptor exists for rear free space */
	if(!(1&(sts=om$coalesce(p_extent=pcd,
				p_instance= rear_object))))
	    return(sts);
	rear_object->p_fcd->size += a_size;
	rear_object->p_fcd->freehdr = (OM_p_CLUSTFHDR) p_instance;
	((OM_p_CLUSTFHDR)p_instance)->p_fcd = rear_object->p_fcd;
	((OM_p_CLUSTFHDR)p_instance)->size = rear_object->p_fcd->size;
	OM_SETFREEBIT(p_instance->i_size)
    }
    else
	/* get free cluster descriptor, add to list in order,	*/
	/* check previous coalesce situation			*/
    {
	if(!(1&(sts=som_get_fcd(&fcd))))
	  return(sts);
	pcd->i_numfree_chunks++;
	fcd->freehdr = (OM_p_CLUSTFHDR)p_instance;
	fcd->size = a_size;
	((OM_p_CLUSTFHDR)p_instance)->p_fcd = fcd;
	((OM_p_CLUSTFHDR)p_instance)->size = a_size;
	OM_SETFREEBIT(p_instance->i_size)
	/*==============================================*/
	/* Loop thru pcd's free list to find where      */
	/* this new fcd should be inserted into list.   */
	/* check for previous coalescing as go.		*/
	/*==============================================*/
	ppfcd = &(pcd->p_fcd);
	while (*ppfcd)
   	{
	  if((*ppfcd)->freehdr > (OM_p_CLUSTFHDR) p_instance ) /* insert */
	  {
	    fcd->nextfcd = *ppfcd;
	    *ppfcd = fcd;
	    inserted_fcd = TRUE;
	    break;
	  }
	  else	/* coalesce previous space case */
	  {
	    if((OMuint)(*ppfcd)->freehdr+(*ppfcd)->size == (OMuint)p_instance)
	    {	
	      som_return_fcd(fcd);
	      pcd->i_numfree_chunks--;
      	      (*ppfcd)->size += a_size;
	      (*ppfcd)->freehdr->size = OM_GETFREESIZE((*ppfcd)->freehdr->size)
				        + a_size;
	      OM_SETFREEBIT((*ppfcd)->freehdr->size);
	      inserted_fcd = TRUE;
	      break;
	    }
	    else	/* continue traversing list */
	    {
	      ppfcd = &((*ppfcd)->nextfcd);
	    }	
	  }
	}
	if(! inserted_fcd)	/* add to end of list */
	{
	  *ppfcd = fcd;
	  fcd->nextfcd = NULL;
	}
    }
    pcd->i_totalfree += a_size;

return(OM_S_SUCCESS);
}


/*=============================================*/
/* Internal function used by delete object,    */
/* and vla management to free space            */
/* coalescing with any following free space    */
/*=============================================*/

som_free_space (
   OM_p_LCD	  lcd,
   OM_p_OBJECTHDR p_instance,
   OMuint	  flag,	/* this is an object, or vla outrigger, or part of
                           a vla outrigger being set free. */
   OMuword	  OSnum,
   OM_p_PCD	  pcd
)
{
   OM_p_FCD	fcd, nextfcd;
   OMuint	sts, a_size;

   /*===========================================================*/
   /* Put Instance Into Free List Of Its Owning Cluster Extent; */
   /* Combining It With Any That It Might Ajoin at the Rear.    */
   /* find extent descriptor within which this object resides.  */
   /*===========================================================*/

   /* Is This An Outrigger In Sheap */

   if ((!(pcd->p_csd->flag & OM_BIG) && (p_instance < (OM_p_OBJECTHDR)
         pcd->p_csd->p_addr) || (p_instance >=
         (OM_p_OBJECTHDR) (pcd->p_csd->p_addr + pcd->i_totalsize)))
       ||
        ((pcd->p_csd->flag & OM_BIG) && (p_instance != (OM_p_OBJECTHDR)
          pcd->p_csd->p_addr)))

      /* Translation: In non-big-object case, is the chunk outside
         the bounds of the cluster slot?, or, in the big-object
         case, is the chunk not the big object itself, but instead
         a vla of the big object?
       */
   {
      if (flag == OM_K_OBJECT)
      {
         return(OM_E_INVARG);
      }
      else /* outrigger sheap portion of an object */
      {
         /*=========================================================*/
         /* If entire outrigger chunk, free its sheap.              */
         /* If partial outrigger chunk, vla_set_dimension reallocs. */
         /*=========================================================*/

         a_size = OM_GETOBJSIZE(p_instance->i_size);
         if (flag == OM_K_OUTPART)
            return(OM_E_INVARG);
         /* set dimension realloc's in sheap & fixes up pcd & lcd fields */
         else     /* entire outrigger */
            om$dealloc(ptr=(char *) p_instance);	/* free memory */
         pcd->i_cur_num_chunks--;
         pcd->i_totalWsheap -= a_size;

         return (OM_S_SUCCESS);
      }
   }

   /*==================================================*/
   /* When Last Object In PCD; Free PCD & Fix PCD List */
   /*==================================================*/

   a_size = OM_GETOBJSIZE(p_instance->i_size);

   if( pcd->i_totalfree + a_size == pcd->i_totalsize)
   {
      OM_DEQUEUE_ELEMENT(&(pcd->pcdq))
      if( pcd->lcfq.next != (OM_p_DLINK) &(pcd->lcfq.next) )
         OM_DEQUEUE_ELEMENT(&(pcd->lcfq))
      OM_QUEUE_AT_HEAD(&OM_GQ_PCDavail,&(pcd->pcdq))

      /* Last Object So Must Be a real object */

      /* Loop Thru Extents FCD list & return all to free queue */
      fcd = pcd->p_fcd;
      while (fcd)
      {
         nextfcd = fcd->nextfcd;
         som_return_fcd (fcd);
         fcd = nextfcd;
      }
      if(pcd->i_totalsize != pcd->i_totalWsheap)
      {	/* this last object has vla(s) in sheap */
         som_dealloc_sheap_vlas(pcd->p_csd);
      }
      som_releaseSlot(pcd->p_csd);
      if( lcd->p_pcd == pcd )
      {
         if( OM_QUEUE_EMPTY(&(lcd->pcdq_lh)) )  /* last pcd of lcd */
            lcd->p_pcd = NULL;
         else
            lcd->p_pcd = (OM_p_PCD) lcd->pcdq_lh.prev;
      }
      if (!(lcd->flags & OM_USERSPEC))	/* an auto cluster */
      {
         if( OM_QUEUE_EMPTY(&(lcd->pcdq_lh)) )  /* last pcd of lcd */
         {
            /*===========================================*/
            /* Delete lcd; send OMCluster remove message */
            /*===========================================*/
            OM_S_MESSAGE		msg;

            msg.select.DefClassid = OM_K_OMCLUSTER_ACTCLASSID;
	    msg.select.ReqClassid = OM_K_OMCLUSTER_ACTCLASSID;
            msg.select.FuncIndex  = OMCluster_OPP_remove_method_index;
            msg.size              = 0;
            msg.p_arglist         = NULL;

            if (!(1&(sts=om$send(msg=&msg, senderid=NULL_OBJID,
               targetid=lcd->oid,
               targetos=OSnum))))
		return(sts);
         }
      }
   }
   else	
   {
      /*===============================================*/
      /* pcd not empty; coalesce with rear if possible */
      /*===============================================*/
      if (!(1&(sts = som_insert_fcd(p_instance, pcd) )))
         return(sts);
   }

   if(flag == OM_K_OBJECT)
      pcd->i_cur_num_objects--;

   /*  If the flag == OM_K_OUTPART, the chunk being set free is in reality  */
   /*  part of an existing outrigger.  To make an outrigger smaller, the    */
   /*  vla set dimension routine will create an object hdr in the existing  */
   /*  outrigger and call this routine.  Therefore, the number of chunks    */
   /*  should not be decremented because the chunk being set free was not   */
   /*  allocated as a separate chunk in the first place.                    */

   if (flag != OM_K_OUTPART)
   {
      pcd->i_cur_num_chunks--;
   }
   return (OM_S_SUCCESS);
}


/*=============================================*/
/* Internal function used by find_space_in_lcd */
/*  and create_outrigger                       */
/* to find first space of needed size in this  */
/* pcd.  if found then fill in addr & fix fcds */
/* & return ptr to csd if p_csd is not NULL.   */
/* Return zero in p_instance arg if NOT found. */
/*=============================================*/

void som_find_space_in_pcd (
   OM_p_PCD          pcd,
   OMuint            align_size,
   OM_p_OBJECTHDR    *p_instance, /* return pointer to instance */
   OM_p_CSD	     *p_csd,      /* return pointer to csd */
   int	             *fcd_count
)

{
   register OM_p_FCD    fcd;
   OM_p_FCD		tmp_fcd;
   OM_p_FCD  		*prevfcd;	/* keeps previous fcd pointer location */
   int			found=0;	/* flag to end search-for-space loop */
   OMuint		freeAmtLeft=pcd->i_totalfree;

   /*==================================================*/
   /* Loop Thru Free Chunk Descrs. Searching For A Fit */
   /*==================================================*/
   prevfcd = &(pcd->p_fcd);
   fcd = pcd->p_fcd;
   do
   {
      /*============================================*/
      /* First handle previous space coalescing job */
      /*============================================*/
      (*fcd_count)++;
      while ((fcd->nextfcd) && ((char *)(fcd->freehdr) +
         fcd->size == (char *)(fcd->nextfcd->freehdr)))
      {
         fcd->size += fcd->nextfcd->size;
         tmp_fcd = fcd->nextfcd;
         fcd->nextfcd = fcd->nextfcd->nextfcd;
         fcd->freehdr->size = fcd->size;
         OM_SETFREEBIT(fcd->freehdr->size);
         som_return_fcd (tmp_fcd);
         pcd->i_numfree_chunks--;
      }
      if (fcd->size >= align_size)	/* FOUND */
      {
         *p_instance = (OM_p_OBJECTHDR)fcd->freehdr;
         if (fcd->size > align_size)
         {
            fcd->freehdr = (OM_p_CLUSTFHDR) ((char *)fcd->freehdr + align_size);
	    fcd->size -= align_size;
	    fcd->freehdr->p_fcd = fcd;
	    fcd->freehdr->size = fcd->size;
	    OM_SETFREEBIT(fcd->freehdr->size)
         }
         else	
         {    /* size equals free header size; so fix up linked list */
	    *prevfcd = fcd->nextfcd;
	    som_return_fcd(fcd);	/* return fcd to free queue */
	    pcd->i_numfree_chunks--;
         }
         pcd->i_totalfree -= align_size;
         found = 1;
         if(p_csd)
         {
	    *p_csd = pcd->p_csd;
         }
      }
      else	/* Does Not Fit */
      {
         freeAmtLeft -= fcd->size;
         prevfcd = &(fcd->nextfcd);
         fcd = fcd->nextfcd;
      }
   } while ( (! found) && fcd && (freeAmtLeft >= align_size) );
}



/*=========================================*/
/* Internal function used by construct:    */
/*  autoclustering, cluster0 objs. & user  */
/*  specified cluster objects	           */
/* to find first space of needed 	   */
/* align_size for this object if available */
/* return zero in p_instance arg if NOT    */
/*=========================================*/

som_find_space_in_lcd (
   OM_p_LCD	  lcd,
   OMuint	  align_size,
   OM_p_OBJECTHDR *p_instance, /* return pointer to instance */
   OM_p_CSD	  *p_csd      /* return pointer to csd */
)
{
   register OM_p_PCD    pcd;
   int			fcd_count=0;	/* number of fcds	*/
					/* traversed in order 	*/
					/* to find space 	*/
   pcd = lcd->p_pcd;

   /*=============================================================*/
   /* Loop Thru Cluster's PCDs Til Find First Fit Location For    */
   /* New Object; If Not Found, Return NULL in p_instance         */
   /*=============================================================*/
   do
   {
      if( pcd == (OM_p_PCD) &(lcd->pcdq_lh) )
      {
         pcd = (OM_p_PCD) lcd->pcdq_lh.next;
         continue;
      }
      if (pcd->i_totalfree >= align_size)
      {
         som_find_space_in_pcd(pcd, align_size, p_instance, p_csd, &fcd_count);
      }
      pcd = (OM_p_PCD) pcd->pcdq.next;       /* next pcd */
   } while ( (!(*p_instance)) && (pcd != lcd->p_pcd) );

   if(*p_instance)		/* space was found */
      lcd->p_pcd = (*p_csd)->p_pcd; /* listhead of list of pcds
                                       points to pcd where space last found */

   return (OM_S_SUCCESS);
}



/*
--------------------------------------------------------------------------
Abstract:

 This routine finds cluster space for an object, returning pointer to
instance header and clearing out object header stuff and initializing
object header object size field.  At this point the physical cluster
and slot and free space (i.e. new instance) has been selected and 
is in memory.  
 
Sample Invocation:

	om$object_alloc (p_osd=p_osd, neighbor=neighbor, size=size, 
			 p_instance=p_instance, p_sdi=p_sdi)
--------------------------------------------------------------------------
*/

int som_object_alloc (
   OM_p_OSD	  p_osd,		/* pointer to OSD */
   OM_S_NEIGHBOR  neighbor,	/* construct's neighbor parameter */
   OMuint	  size,		/* byte size of object */
   OM_p_OBJECTHDR *p_instance,	/* return object's addr */
   OMuword	  *p_sdi		/* return slot descr. index */
)
{
   OMuword		clusterid;
   OM_p_CSD		p_csd=NULL;
   OM_p_PCD		p_pcd;
   OM_p_LCD		p_lcd=NULL;
   int  		sts;
   int			amountofdata;
   int		        flag=0;		/* true if new phy. cluster */
   int			*instancedata;
   OM_p_FCD		fcd;		/* new fcd if needed */

   *p_instance = NULL;

   /*=============================================================*/
   /* Compute align_size to be multiple of OM_K_CLUSTER_OBJ_ALIGN */
   /* and validate clusternum if not auto clustering              */
   /*=============================================================*/
   size = OM_ALIGN_OBJECT_SIZE(size);

   if(size > OM_K_MAXOBJ_SIZE) return(OM_E_OBJSIZE_TOOBIG);

   clusterid = neighbor.clusterid;
   if ( (neighbor.clusterid != OM_GS_NULL_NEIGHBOR.clusterid) &&
       ( (clusterid >= p_osd->ClustersSize) || 
         !(p_lcd = p_osd->Clusters[clusterid]) ) )
   {
      return (OM_E_INVCLUSTERID);   /* nosuchcluster */
   }

   /*========================================================*/
   /* 4 possible cases big object; user-specified; Cluster0; */
   /*  and autoclustering.                                   */
   /*========================================================*/
   if(size > OM_Gi_phyClusterSize)	/* big object */
   {
      if(!(1&(sts = som_create_big_object(clusterid, size, p_osd,
					p_instance, &p_csd))))
         return(sts);

      flag = FALSE;	/* big objects never have free space */
      p_lcd = p_csd->p_pcd->p_lcd;
   }
   else
   {		
      /* user specified logical cluster */
      if(neighbor.clusterid != OM_GS_NULL_NEIGHBOR.clusterid)
      {
         if(! clusterid)	/* CLUSTER 0 object */
         {
            if (!(1&(sts=som_create_cluster0_obj(p_lcd, size, p_instance,
						&p_csd, &flag ))))
		return(sts);
         }
         else				/* USER SPECIFIED CLUSTER */
         {
            if(!(1&(sts=som_create_user_cluster_obj(p_lcd, size, p_osd, 
					p_instance, &p_csd, &flag) )))
		return(sts);
         }	  
      }
      else		/* AUTO-CLUSTERING */
      {
         if(!(1&(sts=som_auto_cluster(p_osd, size, p_instance, &p_csd, &flag) )))
            return(sts);
         p_lcd = p_csd->p_pcd->p_lcd;
      }
   }

   /* Allocate Object */
  
   p_pcd = p_csd->p_pcd;
   if(flag)	/* new physical cluster */
   {
      if ( p_pcd->i_totalfree = p_pcd->i_totalsize - size )
      {		/* i_totalfree is not zero, so set up free header */
         if(!(1&(sts=som_get_fcd(&fcd))))
            return(sts);
         fcd->nextfcd = NULL;
         fcd->freehdr = (OM_p_CLUSTFHDR)(&((p_csd->p_addr)[size]));
         fcd->size = fcd->freehdr->size = p_pcd->i_totalfree;
         OM_SETFREEBIT(fcd->freehdr->size)
         p_pcd->p_fcd = fcd->freehdr->p_fcd = fcd;
         p_pcd->i_numfree_chunks++;
      }
   }

   if(!p_lcd->p_pcd || p_lcd->p_pcd->i_totalfree < p_pcd->i_totalfree)
      p_lcd->p_pcd = p_pcd;
   p_pcd->i_cur_num_objects++;
   p_pcd->i_cur_num_chunks++;
   (*p_instance)->i_size = size;
   *p_sdi = p_csd->index;

   /*===============================*/
   /* Zero Fill Object; Past Header */
   /*===============================*/
   instancedata = (int *)((int)(*p_instance) + sizeof(OM_S_OBJECTHDR));
   amountofdata = size - sizeof(OM_S_OBJECTHDR);
   memset(instancedata, 0, amountofdata);

   return (OM_S_SUCCESS);
}



/*
--------------------------------------------------------------------------
Abstract:

 This routine frees up object space based on Objid .

Sample Invocation:

	om$delete_object (osnum=OSnum, p_instance=p_instance, objid=objid)

	PRIVATE MACRO used by Root delete method & construct, if error
		      occurs during construction.
--------------------------------------------------------------------------
*/

int   som_delete_object (
   OMuword	  OSnum,
   OM_p_OBJECTHDR p_instance,
   OM_S_OBJID	  objid
)
{
   OM_p_PCD          pcd;
   OM_p_CLASSDEF     p_acld;
   OMuint	     sts;
   int		     i, ii, count, flag=TRUE;
   OM_p_MSGMAP	     p_msgmap;
   OM_p_SPAMAPENT    p_spacemap;
   OMuword           classid;    /* active classid */
   OM_S_MESSAGE	     msg;
   char		     group[DI_PATH_MAX];

   struct  OM_sd_Root_wild_disconnect_arglst
   {
      OM_S_CHANSELECT		cs;
   } wild_arglst;

   if (!(1&(sts=om$get_class(osnum=OSnum, object=p_instance,
                             p_classid=&classid, pp_cld=&p_acld))))
      return(sts);

   p_spacemap = &OM_GA_OSDs[OSnum]->Spacemap[objid];
  
   /*=====================================*/
   /* If object has a name then remove it */
   /*=====================================*/

   if ( p_spacemap->flags & OM_SM_has_di_name )
   {
      DIsu(group);
      sts = di$rm_objid ( objid = objid, osnum = OSnum );
      DIback_su(group);
      if (!(1&sts))
      {
         fprintf (stderr,
            "Error removing name as object (%d,%d) is being deleted\n",
            OSnum,objid);
         di$report_error(sts=sts);
      }
   }

   /*=============================================*/
   /* If object is tagged remove its tag record.  */
   /*=============================================*/

   if(OM_OBJ_IS_TAGGED(p_instance->i_size))
   {
      sts = om$remove_tag(osnum=OSnum, objid=objid);
      if (!(1&sts))
         return (sts);
   }

   /*==========================================*/
   /* Wild Disconnect On All Object's Channels */
   /*==========================================*/
   msg.select.DefClassid = OM_K_ROOT_ACTCLASSID;
   msg.select.ReqClassid = OM_K_ROOT_ACTCLASSID;
   msg.select.FuncIndex  = Root_OPP_wild_disconnect_method_index;
   msg.size              = sizeof(wild_arglst);
   msg.p_arglist         = (char *)&wild_arglst;

   p_msgmap = p_acld->MsgMap;
   for(i=0; (OMuword) i<p_acld->NumMsgClasses; i++, p_msgmap++)
   {  		/* looping thru classmap array */
      OM_p_CHANNEL_DEFN    p_chandef;

      p_chandef = p_msgmap->ChanDefns;
      for (ii=0; (OMuword) ii<p_msgmap->NumChan; ii++, p_chandef++)
      {
         /* looping thru each classes channel definitions */
         wild_arglst.cs.type = OM_e_addr;
         wild_arglst.cs.u_sel.addr = (OM_p_CHANNEL_HDR *)((char *)p_instance +
			p_msgmap->offset + p_chandef->i_offset);
         if (!(1&(sts=om$get_channel_count(osnum=OSnum, objid=objid,
			p_chanselect=&(wild_arglst.cs),
			count=(OMuint *) &count))))
         {
            return(sts);
         }
         if(count)
         {
            /* wild disconnect if channel connected to anyone */
            if(!(1&(sts=om$send(msg=&msg, senderid=objid, targetid=objid,
			targetos=OSnum))))
            {
               return(sts);
            }
         }
      }    
   }					

   /*============================================================*/
   /* Remove The Outriggers From This Object.			*/
   /*============================================================*/

   pcd = OM_GA_CSDarray[p_spacemap->sdi].p_pcd;
   if ( p_spacemap->flags & OM_SM_array_mod )
   {
      if(!(1&(sts = som_vla_remove_outriggers(OSnum,p_spacemap,p_acld,pcd->p_lcd))))
         return(sts);
   }

   /*===========================================================*/
   /* Put Instance Into Free List Of Its Owning Cluster Extent; */
   /*===========================================================*/

   if(!(1&(sts = om$free_space(p_clustcmp=pcd->p_lcd,
			      p_instance= p_instance,
			      flag=(OMuint)OM_K_OBJECT,
			      osnum= OSnum, p_extent=pcd))))
      return(sts);

   OM_FREE_OBJID( objid, OSnum );

   /*=====================================================*/
   /* Decrement OSCO ref cnt; if zero send delete to OSCO */
   /*=====================================================*/

   if(!(--(OM_GA_OSDs[OSnum]->OSCO_list[classid]->i_refcnt))
			&&
       (!(OM_GA_OSDs[OSnum]->OSCO_list[classid]->w_child_refcnt)))
   {
      msg.select.DefClassid = OM_K_ROOT_ACTCLASSID;
      msg.select.ReqClassid = OM_K_OMOSCO_ACTCLASSID;
      msg.select.FuncIndex  = Root_OPP_delete_method_index;
      msg.size              = sizeof(OMuint);
      msg.p_arglist         = (char *)&flag;

      if(!(1&(sts=om$send(msg=&msg, senderid=NULL_OBJID,
		targetid=OM_GA_OSDs[OSnum]->OSCO_list[classid]->OSCO_oid,
		targetos=OSnum))))
      {
         return(sts);
      }
   }
   return (OM_S_SUCCESS);
}



/*			
---------------------------------------------------------------------------
Abstract:

	Create a new physical cluster.  

	Used by construct auto-cluster object, user-defined cluster
	object.
------------------------------------------------------------------------
*/

som_create_pc (OM_p_LCD lcd, OM_p_PCD *pp_pcd)    /* return pcd */
{					
   OM_p_CSD		csd;
   OM_p_DLINK		p_pcd;
   OMuint		sts;
   int			growsize=100;

   /*---------------------------------------------------*/
   /* Get a regular slot which returns a csd            */
   /*---------------------------------------------------*/

   if(!(1&(sts=som_getSlot(&csd))))
      return(sts);

   /*---------------------------------------------------*/
   /* Allocate PCD, if queue of available is empty      */
   /* carve up a new hunk and link to pcd avail queue   */
   /* keeping first one for one needed now.             */
   /*---------------------------------------------------*/

   if(OM_QUEUE_EMPTY(&OM_GQ_PCDavail))
   {
      /*    put macro in line in order to cleanup on error        */
      /*    OM_GROW_QUEUE(&OM_GQ_PCDavail,growsize,OM_S_PCD,pcdq) */

      OM_S_PCD    *p_tmp;

      if(!(((OM_p_DLINK)(&OM_GQ_PCDavail))->next=
         (OM_p_DLINK) om$malloc(size=(growsize)*sizeof(OM_S_PCD))))
      {
         som_releaseSlot(csd);
         return(OM_E_NODYNMEM);
      }
      for(p_tmp=(OM_S_PCD *)((OM_p_DLINK)(&OM_GQ_PCDavail))->next;
         p_tmp < ((OM_S_PCD *)((OM_p_DLINK)(&OM_GQ_PCDavail))->next)+(growsize);
         p_tmp++)
      {
         p_tmp->pcdq.next = (OM_p_DLINK) &((p_tmp+1)->pcdq.next);
         p_tmp->pcdq.prev = (OM_p_DLINK) &((p_tmp-1)->pcdq.next);
      }

      ((OM_p_DLINK)(&OM_GQ_PCDavail))->next = (OM_p_DLINK)
         ((char *) (((OM_p_DLINK) &OM_GQ_PCDavail)->next) +
         ((char *) &p_tmp->pcdq.next - (char *) p_tmp));

      ((OM_p_DLINK)(&OM_GQ_PCDavail))->prev =
         (OM_p_DLINK) &((p_tmp-1)->pcdq.next);
      ((OM_p_DLINK)(&OM_GQ_PCDavail))->prev->next =
         ((OM_p_DLINK)(&OM_GQ_PCDavail));
      ((OM_p_DLINK)(&OM_GQ_PCDavail))->next->prev =
         ((OM_p_DLINK)(&OM_GQ_PCDavail));
   }

   OM_DEQUEUE_FROM_HEAD(&OM_GQ_PCDavail,p_pcd, OM_p_DLINK) /* get 1st avail pcd */

   som_init_pc(p_pcd,lcd,csd);
   csd->p_pcd = (OM_p_PCD) p_pcd;
   *pp_pcd = (OM_p_PCD) p_pcd;

   return(OM_S_SUCCESS);
}



/*			
---------------------------------------------------------------------------
Abstract:

	Initialize a new physical cluster descriptor.

	Used by construct big obj & cluster0 obj, & create phy. cluster.
------------------------------------------------------------------------
*/

som_init_pc (OM_p_PCD pcd, OM_p_LCD lcd, OM_p_CSD csd)
{
   OM_QUEUE_AT_HEAD(&(lcd->pcdq_lh),&(pcd->pcdq)) /* queue to lcd's pcd list */
   pcd->p_lcd = lcd;
   pcd->p_fcd = NULL;
   pcd->lcfq.next = pcd->lcfq.prev = (OM_p_DLINK) &(pcd->lcfq.next);
   pcd->p_csd = csd;
   pcd->i_totalfree = pcd->i_numfree_chunks = 0;
   pcd->i_totalsize = pcd->i_totalWsheap = OM_Gi_phyClusterSize;
   pcd->i_cur_num_objects = pcd->i_cur_num_chunks = 0;
   return(OM_S_SUCCESS);
}


/*			
---------------------------------------------------------------------------
Abstract:

	Free all things related to this logical cluster.

	Used by remove_cluster and delete_os (Root.delete & OMFiledOS.delete).
------------------------------------------------------------------------
*/

som_cleanup_cluster (OM_p_LCD lcd)
{
   OM_p_PCD    pcd;
   OM_p_FCD    fcd;
   OM_p_CSD    csd;
  
   pcd = (OM_p_PCD) lcd->pcdq_lh.next;
   while(pcd != (OM_p_PCD) &(lcd->pcdq_lh) )	/* Loop Thru LCD's PCDs */
   {
      OM_p_PCD    nextpcd;

      nextpcd = (OM_p_PCD) pcd->pcdq.next;
      csd = pcd->p_csd;
      if((pcd->i_totalWsheap > pcd->i_totalsize) || csd->flag & OM_BIG )
      {	/* frees all sheap memory */
         som_dealloc_sheap_vlas(csd);
      }
      som_releaseSlot(csd);

      /* Loop Thru Extents FCD list & return all to free queue */
      fcd = pcd->p_fcd;

      while (fcd)
      {
         OM_p_FCD	nextfcd;

         nextfcd = fcd->nextfcd;
         som_return_fcd (fcd);
         fcd = nextfcd;
      }

      OM_DEQUEUE_ELEMENT(&(pcd->pcdq))
      OM_QUEUE_AT_HEAD(&OM_GQ_PCDavail,&(pcd->pcdq))
      pcd = nextpcd;
   }
   return(OM_S_SUCCESS);
}


/*			
---------------------------------------------------------------------------
Abstract:

	Expand CSD array.

	Used by get a regular slot & get a paged slot.
------------------------------------------------------------------------
*/

som_expandCSDarray (OM_p_DLINK availQlisthead, OMuint growsize)
	/* growsize = OM_Gi_slotGrowthFactor if regCSDavail
				   queue is growing the CSD array */
{
   int         ii;
   OM_p_CSD    p_tmp, newCSDarray;

   if (!OM_GA_CSDarray)
   {
      OM_GA_CSDarray = (OM_p_CSD) om$malloc(size=
         (OM_Gi_CSDarraySize + growsize) * sizeof(OM_S_CSD));
      newCSDarray = OM_GA_CSDarray;
   }
   else
   {
      newCSDarray = (OM_p_CSD) om$realloc (ptr=(char *) OM_GA_CSDarray,
         size=((OM_Gi_CSDarraySize + growsize) * sizeof(OM_S_CSD)));
   }

   /*=============================*/
   /* Initialize new CSDs         */
   /* First, relink existing CSD  */
   /*=============================*/

   OM_GQ_regCSDavail.next = (OM_p_DLINK) &(OM_GQ_regCSDavail.next);
   OM_GQ_regCSDavail.prev = (OM_p_DLINK) &(OM_GQ_regCSDavail.next);
   OM_GQ_bigCSDavail.next = (OM_p_DLINK) &(OM_GQ_bigCSDavail.next);
   OM_GQ_bigCSDavail.prev = (OM_p_DLINK) &(OM_GQ_bigCSDavail.next);

   for (p_tmp = newCSDarray, ii=0; ii < (int) OM_Gi_CSDarraySize; p_tmp++, ii++)
   {
      if (p_tmp->flag & OM_BIG  &&  (! (p_tmp->flag & OM_INUSE)) )
      {
         OM_QUEUE_AT_TAIL (&OM_GQ_bigCSDavail,&(p_tmp->lcq));
      }
      if ( !(p_tmp->flag & OM_BIG) && !(p_tmp->flag & OM_INUSE))
      {
         OM_QUEUE_AT_TAIL (&OM_GQ_regCSDavail,&(p_tmp->lcq));
      }

      /*=================================================*/
      /* If CSD has PCD, fix its PCDs ptr to CSD.        */
      /*=================================================*/
      if ( p_tmp->p_pcd && (p_tmp->flag & OM_INUSE))
         p_tmp->p_pcd->p_csd = p_tmp;
   }

   /* now add new guys to end of queue */
  
   for(p_tmp = &newCSDarray[OM_Gi_CSDarrayNextSlot], ii=0;
      (OMuint) ii < growsize;
      p_tmp++, ii++)
   {
      OM_QUEUE_AT_TAIL(availQlisthead,&(p_tmp->lcq));
      p_tmp->index = OM_Gi_CSDarrayNextSlot++;
      p_tmp->p_pcd = NULL;
      if(availQlisthead == &OM_GQ_regCSDavail)
      {
         p_tmp->flag = 0;
         p_tmp->p_addr = NULL;
      }
      else	/* big CSD avail queue */
      {
         p_tmp->flag = OM_BIG;
         p_tmp->p_addr = NULL;
      }
   }
   OM_GA_CSDarray = newCSDarray;
   OM_Gi_CSDarraySize += growsize;
   return(OM_S_SUCCESS);
}


/*			
---------------------------------------------------------------------------
Abstract:

	Create a Cluster0 object.  Return new instance address and
	ptr to csd of new instance and flag=TRUE if new PCD else
	flag=FALSE.

	Used by object_alloc and construct_os and load_os.
------------------------------------------------------------------------
*/

som_create_cluster0_obj(
   OM_p_LCD	  lcd,		/* ptr to cluster0 lcd */
   OMuint	  size,		/* requested new object size */
   OM_p_OBJECTHDR *p_instance,	/* return new instance ptr */
   OM_p_CSD	  *p_csd,	/* return csd pointer */
   int		  *flag	/* True if new slot, else False */
)
{
   int	    growsize=100;
   OMuint   sts;
   int	    startupcase=0;

   *p_instance = NULL;

   /*=====================================================*/
   /* Do Any PCDs exist in this LCD (OR Start Up), If So  */
   /* Look for Contiguous Space in Existing Cluster0 PCDs */
   /*=====================================================*/

   if (!OM_QUEUE_EMPTY(&lcd->pcdq_lh))
   {
      if (!(1&(sts=om$find_space_in_lcd (p_clustcmp=lcd, size=size,
         pp_instance=p_instance, pp_csd=p_csd) )))
         return(sts);
   }
   else	
      startupcase=1;

   /*=========================================================*/
   /* If Needed Space is not found, add new PCD               */
   /*=========================================================*/

   if(! (*p_instance) )
   {
      *flag = TRUE;

      /*-------------------------------------------------*/
      /* Get a paged slot which returns a csd            */
      /*-------------------------------------------------*/

      if(!(1&(sts=som_getSlot(p_csd))))
         return(sts);

      *p_instance = (OM_p_OBJECTHDR) (*p_csd)->p_addr;

      /*=============================================*/
      /* Initialize newly allocated CSD              */
      /*=============================================*/

      (*p_csd)->flag = OM_CLUST0 | OM_INUSE;

      /*---------------------------------------------------*/
      /* Allocate PCD, if queue of available is empty      */
      /* carve up a new hunk and link to pcd avail queue   */
      /* keeping first one for one needed now.             */
      /*---------------------------------------------------*/
      if(OM_QUEUE_EMPTY(&OM_GQ_PCDavail))
      {
         /*    put macro in line in order to cleanup on error        */
         /*    OM_GROW_QUEUE(&OM_GQ_PCDavail,growsize,OM_S_PCD,pcdq) */

         OM_S_PCD	*p_tmp;

         if(!(((OM_p_DLINK)(&OM_GQ_PCDavail))->next=
            (OM_p_DLINK)om$malloc(size=(growsize)*sizeof(OM_S_PCD))))
         {
            som_releaseSlot(*p_csd);
            return(OM_E_NODYNMEM);
         }
         for(p_tmp=(OM_S_PCD *)((OM_p_DLINK)(&OM_GQ_PCDavail))->next;
            p_tmp < ((OM_S_PCD *)((OM_p_DLINK)(&OM_GQ_PCDavail))->next)+(growsize);
            p_tmp++)
         {
            p_tmp->pcdq.next = (OM_p_DLINK) &((p_tmp+1)->pcdq.next);
            p_tmp->pcdq.prev = (OM_p_DLINK) &((p_tmp-1)->pcdq.next);
         }

         ((OM_p_DLINK)(&OM_GQ_PCDavail))->next = (OM_p_DLINK)
            ((char *) (((OM_p_DLINK) (&OM_GQ_PCDavail))->next) +
            ((char *) &p_tmp->pcdq.next - (char *) p_tmp));

         ((OM_p_DLINK)(&OM_GQ_PCDavail))->prev =
            (OM_p_DLINK)&((p_tmp-1)->pcdq.next);
         ((OM_p_DLINK)(&OM_GQ_PCDavail))->prev->next =
            ((OM_p_DLINK)(&OM_GQ_PCDavail));
         ((OM_p_DLINK)(&OM_GQ_PCDavail))->next->prev =
            ((OM_p_DLINK)(&OM_GQ_PCDavail));
      }
      /* get 1st avail pcd */
      OM_DEQUEUE_FROM_HEAD(&OM_GQ_PCDavail, (*p_csd)->p_pcd, OM_p_PCD)

      /*---------------------------------------------------*/
      /* Initialize new PCD                                */
      /*---------------------------------------------------*/
      som_init_pc((*p_csd)->p_pcd,lcd,(*p_csd));
   }
   else
   {
      *flag = FALSE;
   }

   return(OM_S_SUCCESS);
}


/*			
---------------------------------------------------------------------------
Abstract:

	Create an outrigger vla.

	Used by vla set dimension.
------------------------------------------------------------------------
*/
som_create_outrigger(
   OM_p_LCD	  lcd,		/* ptr to object's lcd */
   OM_p_PCD	  pcd,		/* ptr to object's pcd */
   OMuint	  size,		/* vla code has aligned size */
   OM_p_OBJECTHDR *pp_outrigger	/* return outrigger addr */
)
{
   int	    fcd_count=0;	/* number of fcds	*/
				/* traversed in order 	*/
				/* to find space 	*/

   *pp_outrigger = NULL;

   /*===============================*/
   /* Fits Within Physical Cluster  */
   /*===============================*/
   if (OM_QUEUE_EMPTY(&(lcd->pcdq_lh)))
      return(OM_E_INVARG);
  
   if(pcd->i_totalfree >= size)		/* may fit in slot */
   {
      som_find_space_in_pcd(pcd, size, pp_outrigger, (OM_p_CSD *) NULL, &fcd_count);
   }

   /*===============================================*/
   /* No Room, So Put in UNIX Pagable Shared Memory */
   /*===============================================*/
   if(! (*pp_outrigger) )
   {
      if(!(*pp_outrigger = (OM_p_OBJECTHDR)om$malloc(size=size)))
         return(OM_E_NODYNMEM);
      pcd->i_totalWsheap += size;
   }

   /*============================================================*/
   /* Initialize outrigger header's size & bump number of chunks */
   /* & increment current bytes allocated.                       */
   /*============================================================*/
   pcd->i_cur_num_chunks++;
   (*pp_outrigger)->i_size = size;

   return(OM_S_SUCCESS);
}



/*			
---------------------------------------------------------------------------
Abstract:

	Create a Big Object.

	Used by object_alloc.
------------------------------------------------------------------------
*/

som_create_big_object(
   OMuword	  clusterid,	/* neighbor's clusterid */
   OMuint	  size,		/* aligned new object size */
   OM_p_OSD	  p_osd,	/* OSD pointer */
   OM_p_OBJECTHDR *p_instance,	/* return new object's addr here */
   OM_p_CSD	  *p_csd	/* return new object's csd here */
)
{
   OM_p_LCD    p_lcd;
   OM_p_PCD    p_pcd;
   int	       growsize=100;
   int	       sts, swapmem;

   if (clusterid == OM_GS_NULL_NEIGHBOR.clusterid)
   {
      /*====================================================*/
      /* NOT User Specified Cluster, Create Logical Cluster */
      /*====================================================*/
      OMuint		oid;
      OM_S_MESSAGE	msg;
      OM_S_NEIGHBOR	neighbor;
      char		*p_clusterid= (char *) &clusterid;

      msg.select.DefClassid = OM_K_OMCLUSTER_ACTCLASSID;
      msg.select.ReqClassid = OM_K_OMCLUSTER_ACTCLASSID;
      msg.select.FuncIndex  = OMCluster_OPP_init_OMCluster_method_index;
      msg.size              = sizeof(OMuword *);
      msg.p_arglist         = (char *) &p_clusterid;
      neighbor.clusterid = 0;
      neighbor.groupid = OM_GS_NULL_NEIGHBOR.groupid; /* defaults to
							   Group0_oid */

      if (!(1&(sts=om$construct(msg=&msg, neighbor=neighbor,
				classid=OM_K_OMCLUSTER_ACTCLASSID,
				osnum=p_osd->OSnum, p_objid=(OM_p_OBJID) &oid))))
      {
         return(sts);
      }
   }
   p_lcd = p_osd->Clusters[clusterid];

   /*====================================================*/
   /* Allocate PCD, if queue of available is empty       */
   /* carve up a new hunk and link to pcd avail queue    */
   /* keeping first one for one needed now.              */
   /*====================================================*/
   if (OM_QUEUE_EMPTY(&OM_GQ_PCDavail))
   {
      /*    put macro in line in order to cleanup on error        */
      /*    OM_GROW_QUEUE(&OM_GQ_PCDavail,growsize,OM_S_PCD,pcdq) */

      OM_S_PCD	*p_tmp;

      if (!(((OM_p_DLINK) (&OM_GQ_PCDavail))->next =
         (OM_p_DLINK) om$malloc(size = (growsize)*sizeof(OM_S_PCD))))
      {
         /* Couldn't get the memory to expand the queue, so can't get a pcd */

         if (clusterid == OM_GS_NULL_NEIGHBOR.clusterid) /* Did we create lcd? */
         {
            /*===========================================*/
            /* Delete lcd; send OMCluster remove message */
            /*===========================================*/
            OM_S_MESSAGE   msg;

            msg.select.DefClassid = OM_K_OMCLUSTER_ACTCLASSID;
            msg.select.ReqClassid = OM_K_OMCLUSTER_ACTCLASSID;
            msg.select.FuncIndex  = OMCluster_OPP_remove_method_index;
            msg.size              = 0;
            msg.p_arglist         = NULL;

            if(!(1&(sts=om$send(msg=&msg, senderid=NULL_OBJID,
               targetid=p_lcd->oid,
               targetos=p_osd->OSnum))))
               return(sts);
         }
         return(OM_E_NODYNMEM);
      }
      for(p_tmp=(OM_S_PCD *)((OM_p_DLINK)(&OM_GQ_PCDavail))->next;
         p_tmp < ((OM_S_PCD *)((OM_p_DLINK)(&OM_GQ_PCDavail))->next)+(growsize);
         p_tmp++)
      {
         p_tmp->pcdq.next = (OM_p_DLINK) &((p_tmp+1)->pcdq.next);
         p_tmp->pcdq.prev = (OM_p_DLINK) &((p_tmp-1)->pcdq.next);
      }

      ((OM_p_DLINK) (&OM_GQ_PCDavail))->next = (OM_p_DLINK)
         (((char *) (((OM_p_DLINK)(&OM_GQ_PCDavail))->next)) +
         ((char *) &p_tmp->pcdq.next - (char *) p_tmp));

      ((OM_p_DLINK)(&OM_GQ_PCDavail))->prev = (OM_p_DLINK)&((p_tmp-1)->pcdq.next);
      ((OM_p_DLINK)(&OM_GQ_PCDavail))->prev->next = ((OM_p_DLINK)(&OM_GQ_PCDavail));
      ((OM_p_DLINK)(&OM_GQ_PCDavail))->next->prev = ((OM_p_DLINK)(&OM_GQ_PCDavail));
   }
   OM_DEQUEUE_FROM_HEAD(&OM_GQ_PCDavail, p_pcd, OM_p_PCD)	/* get 1st avail pcd */

   /*=======================================*/
   /* Allocate CSD from BigObjectCSDs.      */
   /*=======================================*/
   if (OM_QUEUE_EMPTY(&OM_GQ_bigCSDavail))
   {
      if(!(1&(sts=som_expandCSDarray(&OM_GQ_bigCSDavail, growsize))))
      {
         /* Couldn't get a csd, so free up pcd and maybe lcd */

         OM_QUEUE_AT_HEAD(&OM_GQ_PCDavail, &(p_pcd->pcdq))
         (*p_csd) = NULL;
         if (clusterid == OM_GS_NULL_NEIGHBOR.clusterid) /* Did we create lcd? */
         {
            /*===========================================*/
            /* Delete lcd; send OMCluster remove message */
            /*===========================================*/
            OM_S_MESSAGE   msg;

            msg.select.DefClassid = OM_K_OMCLUSTER_ACTCLASSID;
            msg.select.ReqClassid = OM_K_OMCLUSTER_ACTCLASSID;
            msg.select.FuncIndex  = OMCluster_OPP_remove_method_index;
            msg.size              = 0;
            msg.p_arglist         = NULL;

            if(!(1&(sts=om$send(msg=&msg, senderid=NULL_OBJID,
               targetid=p_lcd->oid,
               targetos=p_osd->OSnum))))
               return(sts);
         }
         return(sts);
      }
   }
   OM_DEQUEUE_FROM_HEAD(&OM_GQ_bigCSDavail, (*p_csd), OM_p_CSD)	/* get 1st avail csd */

   /*=======================================*/
   /* Allocate big object memory from SHEAP */
   /*=======================================*/

   som_get_mem_info(&swapmem, (int *) 0, (int *) 0, (int *) 0,
      (int *) 0, (int *) 0);
   if ((swapmem -= (200 * OM_Gp_SYSINFO->pageSize)) < size)
      return(OM_E_NODYNMEM);

   if (!(*p_instance = (OM_p_OBJECTHDR) om$malloc(size=size)))
   {
      som_releaseSlot(*p_csd);
      OM_QUEUE_AT_HEAD(&OM_GQ_PCDavail, &(p_pcd->pcdq))
      (*p_csd) = NULL;
      if (clusterid == OM_GS_NULL_NEIGHBOR.clusterid)  /* Did we create lcd? */
      {
         /*===========================================*/
         /* Delete lcd; send OMCluster remove message */
         /*===========================================*/
         OM_S_MESSAGE   msg;

         msg.select.DefClassid = OM_K_OMCLUSTER_ACTCLASSID;
         msg.select.ReqClassid = OM_K_OMCLUSTER_ACTCLASSID;
         msg.select.FuncIndex  = OMCluster_OPP_remove_method_index;
         msg.size              = 0;
         msg.p_arglist         = NULL;

         if(!(1&(sts=om$send(msg=&msg, senderid=NULL_OBJID,
                             targetid=p_lcd->oid,
                             targetos=p_osd->OSnum))))
            return(sts);
      }
      return(OM_E_NODYNMEM);
   }
   (*p_csd)->flag = OM_BIG | OM_INUSE;
   if (! clusterid)
      (*p_csd)->flag |= OM_CLUST0;
   (*p_csd)->p_addr = (char *) *p_instance;
   (*p_csd)->p_pcd = p_pcd;

   /*====================*/
   /* Initialize the PCD */
   /*====================*/
   som_init_pc(p_pcd,p_lcd,(*p_csd));
   p_pcd->i_totalsize = p_pcd->i_totalWsheap = size;

   return(OM_S_SUCCESS);
}


/*			
---------------------------------------------------------------------------
Abstract:

	Create a User Designated Logical Cluster Object.

	Used by object_alloc.
------------------------------------------------------------------------
*/
som_create_user_cluster_obj(
   OM_p_LCD	  p_lcd,	/* ptr to cluster0 lcd */
   OMuint	  size,		/* aligned new object size */
   OM_p_OSD	  p_osd,	/* pointer to OSD */
   OM_p_OBJECTHDR *p_instance,	/* return new instance ptr */
   OM_p_CSD	  *p_csd,	/* return csd pointer */
   int		  *flag	/* True if new slot, else False */
)
{
   OMuint		sts;
   OM_S_MESSAGE  	fault_msg;
   OM_p_PCD		p_pcd;
   OM_p_CLUSTFHDR	freehdr;

   /*===============================================*/
   /* Has Logical Cluster Been Faulted In From File */
   /*===============================================*/
   if(!(p_lcd->flags & OM_FAULTED))
   {
      int   arg=0;

      fault_msg.select.DefClassid = OM_K_OMCLUSTER_ACTCLASSID;
      fault_msg.select.ReqClassid = OM_K_OMCLUSTER_ACTCLASSID;
      fault_msg.select.FuncIndex  = OMCluster_OPP_fault_method_index;
      fault_msg.size              = sizeof(int);
      fault_msg.p_arglist         = (char *) &arg;

      if (!(1&(sts = om$send ( msg=&fault_msg, senderid=NULL_OBJID,
                             targetid=p_lcd->oid, targetos=p_osd->OSnum ))))
      {
         return (sts);
      }
   }

   /*===============================================*/
   /* If no physical cluster exists; create one     */
   /*===============================================*/
   if(OM_QUEUE_EMPTY(&p_lcd->pcdq_lh))
   {
      if(!(1&(sts = som_create_pc(p_lcd, &p_pcd) )))
         return(sts);
      *flag = TRUE;
      *p_csd = p_pcd->p_csd;
      *p_instance = (OM_p_OBJECTHDR) (*p_csd)->p_addr;
   }
   else
   {
      /*======================================================*/
      /* PCDs Exist in this LCD, So Look For Contiguous Space */
      /*======================================================*/
      om$find_space_in_lcd (p_clustcmp=p_lcd, size=size,
			pp_instance=p_instance, pp_csd=p_csd);
      *flag = FALSE;
   }

   /*=======================================================*/
   /* If Needed Space is not found Look for mem-resident pc */
   /* with room if pc is compressed; if found compress pc.  */
   /*=======================================================*/
   if(! (*p_instance) )
   {
      p_pcd = p_lcd->p_pcd;
      do		  /* may fit in this pcd and NOT swapped and send depth zero */
      {
         if( size + (p_pcd->i_totalWsheap - p_pcd->i_totalsize)
			 <= p_pcd->i_totalfree &&
            (p_pcd->p_csd->PreSendDepth == p_pcd->p_csd->PostSendDepth) )
         {
            if(!(1 & (sts = som_compress_pcd(p_pcd, p_osd, p_instance) )))
		return(sts);
         }
         else
         {
            p_pcd = (OM_p_PCD) p_pcd->pcdq.next;       /* next pcd */
            if (p_pcd == (OM_p_PCD) &(p_lcd->pcdq_lh))
               p_pcd = (OM_p_PCD) p_pcd->pcdq.next;    /* Skip queue listhead */
         }
      } while ( (!(*p_instance)) && (p_pcd != p_lcd->p_pcd) );
      if(*p_instance)	/* found */
      {
         *flag = FALSE;
         *p_csd = p_pcd->p_csd;
         /*!!!!!!! have to set up free chunk here !!!!!!!!!!!!*/
         if( p_pcd->i_totalfree -= size)
         {
            freehdr = (OM_p_CLUSTFHDR)((char *)(*p_instance) + size);
            if(!(1&(sts = som_get_fcd(&(freehdr->p_fcd)) )))
               return(sts);
            p_pcd->p_fcd = freehdr->p_fcd;
            p_pcd->i_numfree_chunks = 1;
            freehdr->size = freehdr->p_fcd->size = p_pcd->i_totalfree;
            OM_SETFREEBIT(freehdr->size)
            freehdr->p_fcd->freehdr = freehdr;
            freehdr->p_fcd->nextfcd = NULL;
         }
      }
   }

   /*================================================================*/
   /* If Needed Space is STILL not found, create a new physical      */
   /* cluster for this user-defined logical cluster.                 */
   /*================================================================*/
   if(! (*p_instance) )
   {
      if(!(1&(sts = som_create_pc(p_lcd, &p_pcd) )))
         return(sts);
      *flag = TRUE;
      *p_csd = p_pcd->p_csd;
      *p_instance = (OM_p_OBJECTHDR) (*p_csd)->p_addr;
   }
   return(OM_S_SUCCESS);
}


/*			
---------------------------------------------------------------------------
Abstract:

	Create an Auto Cluster Object.

	Used by object_alloc.
------------------------------------------------------------------------
*/
som_auto_cluster(
   OM_p_OSD	  p_osd,
   OMuint	  size,
   OM_p_OBJECTHDR *p_instance,
   OM_p_CSD	  *p_csd,
   int		  *flag
)
{
   OM_p_LCD		p_lcd;
   OM_p_PCD		p_pcd;
   OMuint		sts, count;
   OM_p_CLUSTFHDR	freehdr;
   int			fcd_count=0;	/* number of fcds	*/
					/* traversed in order 	*/
					/* to find space 	*/

   /*========================================================*/
   /* Locate CSD within LastClusterFaulted Queue with enough */
   /* space for this new object being created.               */
   /* Search stops after looking at X (system parameter)     */
   /* number of PCDs.        				    */
   /*========================================================*/
   if( ! OM_QUEUE_EMPTY(&(p_osd->lcfq_lh)))
   {
      for(p_pcd = (OM_p_PCD) p_osd->lcfq_lh.next, count=0;
         (!(*p_instance)) && (p_pcd != (OM_p_PCD) &(p_osd->lcfq_lh)) 
	                 && count < OM_Gi_LCFqueueDepth;
         count++, p_pcd = (OM_p_PCD) p_pcd->lcfq.next)
      {

         p_pcd = (OM_p_PCD) ((char *) p_pcd - ((char *) &p_pcd->lcfq.next -
            (char *) p_pcd));

         if (p_pcd->i_totalfree >= size)
         {
            som_find_space_in_pcd(p_pcd, size, p_instance, p_csd, &fcd_count);
            if( *p_csd ) break;
         }
      }

      /*==========================================================*/
      /* If enough contiguous space not found, then look for      */
      /* slot with zero send depth and enough space if compressed */
      /*==========================================================*/
      if(! *p_csd)
      {
         for(p_pcd = (OM_p_PCD)p_osd->lcfq_lh.next, count=0;
            (!(*p_instance)) && (p_pcd != (OM_p_PCD) &(p_osd->lcfq_lh)) 
 	                   && count < OM_Gi_LCFqueueDepth;
            count++, p_pcd = (OM_p_PCD)p_pcd->lcfq.next)
         {

            p_pcd = (OM_p_PCD) ((char *) p_pcd - ((char *) &p_pcd->lcfq.next -
               (char *) p_pcd));
            if( size + (p_pcd->i_totalWsheap - p_pcd->i_totalsize)
			 <= p_pcd->i_totalfree &&
               (p_pcd->p_csd->PreSendDepth == p_pcd->p_csd->PostSendDepth))
            {
               if(!(1 & (sts = som_compress_pcd(p_pcd, p_osd, p_instance) )))
                  return(sts);
               if (*p_instance)   /* found */
               {
                  *flag = FALSE;
                  *p_csd = p_pcd->p_csd;
                  if (p_pcd->i_totalfree -= size)
                  {
                     freehdr = (OM_p_CLUSTFHDR)((char *)(*p_instance) + size);
                     if (!(1&(sts = som_get_fcd(&(freehdr->p_fcd)))))
			return(sts);
                     p_pcd->p_fcd = freehdr->p_fcd;
                     p_pcd->i_numfree_chunks = 1;
                     freehdr->size = freehdr->p_fcd->size = p_pcd->i_totalfree;
                     OM_SETFREEBIT(freehdr->size)
                     freehdr->p_fcd->freehdr = freehdr;
                     freehdr->p_fcd->nextfcd = NULL;
                  }
                  break;	/* get out of for loop; found */
               }
            } /* space avail and send depth 0 so must compress */
         }	/* for loop thru lcf queue */
      }	/* contiguous space not found */
   }	/* lcf queue not empty */

   /*========================================================*/
   /* If no CSD found with enough space, then create a new   */
   /* logical cluster and physical cluster initializing      */
   /* CSD, PCD and LCD fields as needed and Queue PCD to     */
   /* head of last cluster faulted queue.                    */
   /*========================================================*/
   if(! *p_csd)
   {
      OMuint		oid;
      OM_S_MESSAGE	msg;
      OMuword		clusterid;
      char		*p_clusterid= (char *) &clusterid;
      OM_S_NEIGHBOR	neighbor;

      msg.select.DefClassid = OM_K_OMCLUSTER_ACTCLASSID;
      msg.select.ReqClassid = OM_K_OMCLUSTER_ACTCLASSID;
      msg.select.FuncIndex  = OMCluster_OPP_init_OMCluster_method_index;
      msg.size              = sizeof(OMuword *);
      msg.p_arglist         = (char *) &p_clusterid;

      neighbor.clusterid = 0;
      neighbor.groupid = OM_GS_NULL_NEIGHBOR.groupid;
      if (!(1&(sts=om$construct(msg=&msg, neighbor=neighbor,
				classid=OM_K_OMCLUSTER_ACTCLASSID,
				osnum=p_osd->OSnum, p_objid=(OM_p_OBJID) &oid))))
      {
         return(sts);
      }
      p_lcd = p_osd->Clusters[clusterid];
      p_lcd->flags &= ~OM_USERSPEC;	/* NOT USER SPECIFIED */

      if(!(1&(sts = som_create_pc(p_lcd, &p_pcd) )))
         return(sts);
      *flag = TRUE;
      *p_csd = p_pcd->p_csd;
      *p_instance = (OM_p_OBJECTHDR) (*p_csd)->p_addr;
      OM_QUEUE_AT_HEAD(&(p_osd->lcfq_lh),&(p_pcd->lcfq))
   }
   return(OM_S_SUCCESS);
}


/*			
---------------------------------------------------------------------------
Abstract:

	Compress a Physical Cluster.

	Used by auto construct object and construct user-defined-
	cluster object.
------------------------------------------------------------------------
*/
som_compress_pcd(
   OM_p_PCD	  p_pcd,
   OM_p_OSD	  p_osd,
   OM_p_OBJECTHDR *p_instance	/* return new instance ptr
					   which is new free chunk at end */
)
{
   OMuint	     tmpSize,
                     amtOfFreeSpace=0;
   OM_p_OBJECTHDR    ptr=(OM_p_OBJECTHDR)(p_pcd->p_csd->p_addr);
   OM_p_OBJECTHDR    endOfPcd=(OM_p_OBJECTHDR)((OMuint)(p_pcd->p_csd->p_addr)
				 + p_pcd->i_totalsize);
   OMuword	     sdi = p_pcd->p_csd->index;

   /*=======================================================*/
   /* 1st pass: keep a running total of free space found.   */
   /*           replace 1st long word of outriggers with    */
   /*           their new address after compressed          */
   /*           (current address - current free space found)*/
   /*           & set outriggers bit in i_size field (2nd   */
   /*           long word of header) to indicate its an     */
   /*           outrigger.                                  */
   /*=======================================================*/
   for (; ptr < endOfPcd; 
      ptr=(OM_p_OBJECTHDR)((OMuint)ptr + (OM_GETOBJSIZE(ptr->i_size))))
   {
      if(OM_FREEBIT(ptr->i_size))	/* this is free space */
      {
         amtOfFreeSpace += OM_GETFREESIZE(ptr->i_size);
         continue;
      }
      if(OM_FREEBIT(ptr->oid))	/* this is an outrigger */
      {
         ptr->oid = ((OMuint)&(ptr->oid)) - amtOfFreeSpace
				 + sizeof(OM_S_OBJECTHDR);
         ptr->i_size |= OM_OHf_outrigger;
      }
   }	/* 1st loop thru pcd */
   if(amtOfFreeSpace != p_pcd->i_totalfree)
      return(OM_E_INTERNALS_CORRUPT);

   /*=======================================================*/
   /* 2nd pass: keep a running total of free space found.   */
   /*           find and fix all references to VLAs within  */
   /*           objects.  restore outrigger's VLA element   */
   /*           size and high oid bit on (indicating such   */
   /*           is an outrigger); which replaces what 1st   */
   /*           pass overwrote.                             */
   /*=======================================================*/
   amtOfFreeSpace = 0;
   for(ptr=(OM_p_OBJECTHDR)(p_pcd->p_csd->p_addr); 
      ptr < endOfPcd; 
      ptr=(OM_p_OBJECTHDR)((OMuint)ptr + (OM_GETOBJSIZE(ptr->i_size))))
   {
      if(OM_FREEBIT(ptr->i_size))	/* this is free space */
      {
         amtOfFreeSpace += OM_GETFREESIZE(ptr->i_size);
         continue;
      }
      if(!(ptr->i_size & OM_OHf_outrigger)	/* this is a known object */
         && !(p_osd->Spacemap[ptr->oid].flags & OM_SM_unknown_obj) )
      {
         OM_p_CLASSDEF	         acld;
         OMuint		         count;
         int		         ii;
         OM_p_VARLENARR_DESCR    vadr;
         OM_p_VARLENARR_DEFN     vad;

         acld = p_osd->Spacemap[ptr->oid].p_acld;
         count = acld->w_num_varlenarrays;
         vad = acld->p_varlenarr_defns;
         for (ii=0; (OMuint) ii<count; ii++)
         {
            vadr = (OM_p_VARLENARR_DESCR)(vad[ii].w_offset+(char *)ptr);

            /* If VLA OUTSIDE OBJECT update ptr to where outrigger */
            /* will be moved after compress (1st pass put in hdr's oid field */

            if( vadr->i_offset && ( (vadr->i_offset < (int)ptr) ||
               (vadr->i_offset > (int) ((int)ptr + OM_GETOBJSIZE(ptr->i_size)))) )
            {
               OM_p_OBJECTHDR    outhdr;

               /*===========================================*/
               /* CHECK FOR OUTRIGGER IN SHEAP CASE !!!!    */
               /*===========================================*/
               if(vadr->i_offset < (int)p_pcd->p_csd->p_addr ||
                  vadr->i_offset > (int)endOfPcd )
                  continue;
               outhdr = (OM_p_OBJECTHDR)((char *)vadr->i_offset -
                  sizeof(OM_S_OBJECTHDR));
               vadr->i_offset = outhdr->oid;
               outhdr->oid = vad[ii].w_per_elt_size;
               OM_SETFREEBIT(outhdr->oid)
            }
            else
            {
               if (vadr->i_offset)  /* Not empty, so inrigger */
               {
                  vadr->i_offset = (OMuint) ((char *) vadr->i_offset -
                     amtOfFreeSpace);
               } /* an inrigger */
            }   /* not an outrigger */
         }    /* an outrigger */
      }	      /* an object */
   }	      /* 2nd loop thru pcd */

   /*=======================================================*/
   /* 3rd pass: keep a running total of free space found.   */
   /*           move the objects and outriggers to effect   */
   /*           a compress and update spacemap for each oid.*/
   /*=======================================================*/
   amtOfFreeSpace = 0;
   for(ptr=(OM_p_OBJECTHDR)(p_pcd->p_csd->p_addr); 
      ptr < endOfPcd; 
      ptr=(OM_p_OBJECTHDR)((OMuint)ptr + tmpSize))
   {
      tmpSize = OM_GETOBJSIZE(ptr->i_size);
      if(OM_FREEBIT(ptr->i_size))	/* this is free space */
      {
         amtOfFreeSpace += OM_GETFREESIZE(ptr->i_size);
         som_return_fcd( ((OM_p_CLUSTFHDR)(ptr))->p_fcd );
         p_pcd->i_numfree_chunks--;
         continue;
      }
      else	/* object or outrigger */
      {
         if( OM_FREEBIT(ptr->oid) )	/* outrigger */
            ptr->i_size &= ~OM_OHf_outrigger;
         else				/* object */
         {
            p_osd->Spacemap[ptr->oid].state.object = (OM_p_OBJECTHDR)
               ((char *)ptr - amtOfFreeSpace);
            p_osd->Spacemap[ptr->oid].sdi = sdi;
         }

         OM_BLOCK_MOVE(ptr, (char *)ptr - amtOfFreeSpace,
		    OM_GETOBJSIZE(ptr->i_size) );

      }     /* object or outrigger */
   }	/* 3rd loop thru pcd */
   p_pcd->p_fcd = NULL;

   /*=======================================================*/
   /* return new instance's address; end of compressed area */
   /*=======================================================*/

   *p_instance = (OM_p_OBJECTHDR)((OMuint)endOfPcd - amtOfFreeSpace);

   return(OM_S_SUCCESS);
}


/*---------- Function Description --------------------------------------------

   Function to search a cluster for variable length arrays residing in
   the shared memory heap and deallocate them.  This is called by
   som_swap_out and som_cleanup_cluster, when a cluster is being removed
   from memory.  This routine does not deallocate vla's residing within
   a slot.  Those vla's and the fixed part of all objects will be invalidated
   by som_release_slot.
   
----------------------------------------------------------------------------*/

int som_dealloc_sheap_vlas ( OM_p_CSD csd )
{
   OMuint               ii;
   OM_p_PCD             pcd;            /* Physical cluster residing in slot */
   OM_p_SPAMAPENT       SpaceMap;       /* Pointer to space map */
   OM_p_OBJECTHDR       p_chunk;        /* For stepping thru chunks in slot */
   OM_p_VARLENARR_DEFN  vad;            /* Ptr to an obj's vla definition */
   OM_p_VARLENARR_DEFN  stop_vad;       /* Ptr to last vla def for an obj */
   OM_p_VARLENARR_DESCR p_defn;         /* Vla header */
   char                 *slot_boundary; /* Ending address of slot */

   pcd = csd->p_pcd;
   p_chunk = (OM_p_OBJECTHDR) csd->p_addr;
   slot_boundary = csd->p_addr + pcd->i_totalsize;
   SpaceMap = pcd->p_lcd->p_osd->Spacemap;
   ii = 0;

   while (ii < pcd->i_cur_num_objects)
   {
      if (!OM_FREEBIT(p_chunk->i_size) && !OM_FREEBIT(p_chunk->oid))
      {
         /*================================================*/
         /* Found an object.  Does it have any outriggers? */
         /*================================================*/
         if (SpaceMap[p_chunk->oid].flags & OM_SM_array_mod)
         {
            vad = SpaceMap[p_chunk->oid].p_acld->p_varlenarr_defns;
            stop_vad = SpaceMap[p_chunk->oid].p_acld->w_num_varlenarrays + vad;
            for (; vad < stop_vad; ++vad)
            {
               /*==================================================*/
               /* if vla is not collapsed AND                      */
               /* If this outrigger in shared mem heap, delete it. */
               /*==================================================*/
               p_defn = (OM_p_VARLENARR_DESCR) (vad->w_offset +
                  (char *) p_chunk);
               if (((char *) p_defn->i_offset) &&
                   (((char *) p_defn->i_offset < csd->p_addr) ||
                   ((char *) p_defn->i_offset >= slot_boundary)))
               {
                    om$dealloc(ptr=((char *) p_defn->i_offset -
                                      OM_K_OBJHDRSIZE));
               }
            }
         }
         ii++;                   /* Inc object counter */
      }
      p_chunk = (OM_p_OBJECTHDR) ((char *) p_chunk +
         OM_GETOBJSIZE(p_chunk->i_size));
   }
   return(OM_S_SUCCESS);
}
