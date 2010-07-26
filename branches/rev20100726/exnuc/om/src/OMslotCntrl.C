/************************************************************************/
/*								        */
/*	OMslotCntrl.C							*/
/*								        */
/*	contains routines to obtain, release, lock, & unlock slots	*/
/*								        */
/*	author:	chuck puckett						*/
/*	date:	21-dec-1987						*/
/*	revision history:						*/
/*								        */
/************************************************************************/

#include	"OMmacros.h"
#include	"OMOSfilehdr.h"

extern int	  som_expandCSDarray();

extern OMuint     OM_Gi_phyClusterSize;
extern OMuint     OM_Gi_totalObjMem;
extern OM_S_DLINK OM_GQ_regCSDavail;
extern OM_S_DLINK OM_GQ_bigCSDavail;
extern OM_S_SYSINFO *OM_Gp_SYSINFO;


/****************************************************************/
/*	getSlot							*/
/****************************************************************/

int som_getSlot(OM_p_CSD *pCSD)
{
  int		  sts, swapmem;

  if (OM_QUEUE_EMPTY (&OM_GQ_regCSDavail))
  {
    if (1&(sts = som_expandCSDarray (&OM_GQ_regCSDavail, 10)))
       OM_DEQUEUE_FROM_HEAD (&OM_GQ_regCSDavail, *pCSD, OM_p_CSD)
    else
    {
      return (OM_E_NODYNMEM);
    } /* else (failed to expand CSD array) */
  } /* if queue of CSD's empty */
  else
    OM_DEQUEUE_FROM_HEAD (&OM_GQ_regCSDavail, *pCSD, OM_p_CSD);

   som_get_mem_info(&swapmem, (int *) 0, (int *) 0, (int *) 0,
      (int *) 0, (int *) 0);
   if ((swapmem -= (200 * OM_Gp_SYSINFO->pageSize)) < OM_Gi_phyClusterSize)
      return(OM_E_NODYNMEM);

  if (!((*pCSD)->p_addr = (char *) (OM_p_OBJECTHDR)
     om$malloc(size=OM_Gi_phyClusterSize)))
     return(OM_E_NODYNMEM);
  OM_Gi_totalObjMem += OM_Gi_phyClusterSize;

  (*pCSD)->PreSendDepth = NULL;
  (*pCSD)->PostSendDepth = NULL;
  (*pCSD)->flag = OM_INUSE;

  return (OM_S_SUCCESS);
}

/************************************************************************/
/*	releaseSlot							*/
/************************************************************************/

void som_releaseSlot(OM_p_CSD pCSD)
{

  pCSD->flag &= ~OM_INUSE;      /* turn off inuse */
  pCSD->p_pcd = NULL;
  if (pCSD->p_addr)
  {
     om$dealloc(ptr=pCSD->p_addr);
     pCSD->p_addr = NULL;
  }
  if (pCSD->flag & OM_BIG)
  {
    OM_QUEUE_AT_TAIL (&OM_GQ_bigCSDavail, pCSD);
    return;
  }
  if (pCSD->flag & OM_CLUST0)
  {
    pCSD->flag &= ~OM_CLUST0;   /* turn off flag */
    OM_QUEUE_AT_TAIL (&OM_GQ_regCSDavail, pCSD);
    return;
  }

/* 	    regular, but not locked; just queue it in avail list	*/

  OM_QUEUE_AT_TAIL (&OM_GQ_regCSDavail, pCSD);
  return;
}
