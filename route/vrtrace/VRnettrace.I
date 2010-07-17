/* $Id: VRnettrace.I,v 1.4 2002/04/02 17:22:19 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File	:	vrtrace/VRnettrace.I
 *
 * Description:	This file is for "Trace Network" command.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRnettrace.I,v $
 *      Revision 1.4  2002/04/02 17:22:19  anand
 *      SP -> Pload changes.
 *
 *      Revision 1.3  2001/05/09 23:44:06  louis
 *      TR5100-avoid mode was not performing correctly on 3D hvac PID files.
 *             Was connecting wrong branches as loops.
 *
 *      Revision 1.2  2001/01/16 22:14:20  anand
 *      SP merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:13:13  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/08/15  14:19:42  pinnacle
# Replaced: route/vrtrace/VRnettrace.I for:  by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/04/10  23:46:18  pinnacle
# Replaced: vrtrace/VRnettrace.I for:  by lawaddel for route
#
# Revision 1.1  1997/02/13  20:01:14  pinnacle
# initial revision
#
 *
 * History :
 *
 *	Name		|  Date		|  Description.
 *	
 *	Waddell		| 2/13/97	|  TR # 179603292
 *                                      |  Installation of sort for trace-
 *                                      |  network functionality to order
 *                                      |  the presentation of components
 *	
 *      Waddell         | 3/05/97       |  TR # 179603615
 *                                      |  Skip ref-file connectors in trace.
 *
 *      Waddell         | 7/6/00        |  TR # 179901801
 *                                      |  Part network could not manage loops.
 *                                      |  VRpartnet_trace was rewritten
 *      Waddell         | 5/9/01	|  TR5100-The vr_brch_intersect loop detector was
 *					|  matching 0 objids to connect branches. Apparently
 *					|  only happening in HVAC 3d PID files.
 *************************************************************************/

class implementation Root;

/*******************************************************************
The following block of lines were extracted from APIvRRep.u from which
"VRtrace_network sorting filters were constructed
Note that the hanger collection is retained but disabled and untested
*******************************************************************/

#include <stdio.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "ACattrib.h"

#include "sys/stat.h"
#include "sys/types.h"
#include "time.h"

extern stat();

#include "VDmem.h"
#include "vdparmacros.h"
#include "vrdef.h"
#include "vrparameters.h"
#include "vrmacros.h"

from VRGeneric  import  VRGetTopo;
from VRGeneric  import  VRGetNumberOfCpts;
from VRGeneric  import  VRGetHangers;

#if ISDP_MAKE_SP
extern
#endif
OM_S_OBJID my_id;

/* Stores Component Item modified for 179603615 */
struct COMP_ITEM
{
  unsigned int	ItemNum;
  int branchno; /* TypeNum */
  int Type; /* Type */
  int num_neigh; /* TypeMax */
  GRclassid comp_class;
  int comp_hit_flg; /* Selected component of network */
  struct COMP_ITEM *pNext; /* next component in net */ /* pNext */
  struct COMP_ITEM *pPrev; /* previous component in net */
  struct GRid CompId; /* CompId */
};

#if ISDP_MAKE_SP
extern
#endif
struct COMP_ITEM *VRtrcg_pCompListHead;
#if ISDP_MAKE_SP
extern
#endif
struct COMP_ITEM *VRtrcg_pCompListTail;

#if ISDP_MAKE_SP
extern
#endif
int network_branches; /* Added for 179603615 */

struct DBLLNK
  {
    struct DBLLNK *pNext;
    struct DBLLNK *pPrev;
    unsigned int  ItemNum;
    struct GRid CompId;
  };

/* Component item types */
#define START_BRANCH  2
#define BEGIN_BRANCH  3
#define END_BRANCH    4
#define UNCONNECTED_END    5
#define LOOP_DETECTED 6

/* Support components */
struct COMP_HNGR
{
  struct COMP_HNGR *pNext;
  struct GRid CompId;
  struct GRid HngrId;
  int ItemNum;
} ;
struct brnchrecstr
{
   int no_comps;
   struct GRid *comps;
   struct COMP_ITEM *startcmp; 
   struct GRid f_grid;
   struct GRid t_grid; 
   int no_f_connects;          /* Not Used- Intended for optimization */
   int no_t_connects;          /* Not Used- Intended for optimization */
   int f_branch_connect[10];   /* Not Used- Intended for optimization */
   int t_branch_connect[10];   /* Not Used- Intended for optimization */
   int no_tgts;
   int tgt_1_ndx;
   int tgt_2_ndx;
};

#if ISDP_MAKE_SP
extern
#endif
struct COMP_HNGR *VRtrcg_pHngrListHead;
#if ISDP_MAKE_SP
extern
#endif
struct COMP_HNGR *VRtrcg_pHngrListTail;

/* Each component gets a sequentially generated item number */
#if ISDP_MAKE_SP
extern
#endif
int VRtrcg_ItemNum;  /* Global item Number Counter */
#if ISDP_MAKE_SP
extern
#endif
int VRtrcg_ItemNumLoop;

#if ISDP_MAKE_SP
extern
#endif
struct GRmd_env *VRtrcg_pMdEnv;

/* Process Component Stack Elements */
/*
#define DEBUG_MEM 0
#define DEBUG_OBJ 1
*/

/***************************************************************************

The VRtrace_network() routine traces the component network from the selected
object. The ordered list is then passed through a filter to remove any objects
not in the random list. The resulting output list contains an odered list of
objects not "avoided" in the network. If the output list does not include ALL
of the objects in the random list, a processing error is reported and the
RANDOM list is returned for review. This error would result from the "random"
list including objects NOT connected in the network.

VRtrcBldCmpList is then called to traverse the distributive system network.
VRtrcBldCmpList assigns each component an unique item number then stores each 
component in a linked list .  If a component has more than one neighbor, 
VRtrcBldCmpList traverses each branch in turn.  VRtrcBldCmpList also detects 
"loops" in the system.  A "type" variable in the component list structure
flags the beginning and ending of branches as well as loops.  
VRtrcBldCmpList also generates a list of any support (hangers) components for 
each component.

Note that VRtrcBldCmpList does not work across reference files.
***************************************************************************/
/* ------------------------------------------- */
/* Returns 1 if id already processed (loop) */
int VRCheckCompLoop(pCompId)
struct GRid *pCompId;
{
  struct COMP_ITEM *pItem;

  if (pCompId->objid == NULL_OBJID) return 0;
  if (pCompId->objid == 0) return 0;

  for(pItem = VRtrcg_pCompListHead; pItem; pItem = pItem->pNext)
  {
    if ((pCompId->objid == pItem->CompId.objid) &&
        (pCompId->osnum == pItem->CompId.osnum))
    {
      VRtrcg_ItemNumLoop = pItem->ItemNum;
      return 1;
    }
  }
  return 0;
}

/* ------------------------------------------- */
/* Adds Item to List */
int VRAddCompToList(pCompId,a_ItemNum,a_Type,a_TypeNum,a_TypeMax)
struct GRid *pCompId;
int a_ItemNum;
int a_Type,a_TypeNum,a_TypeMax;
{
  struct COMP_ITEM *pItem;        /* Added for 179603615 */
  struct COMP_ITEM *p1Item;        /* Added for 179603615 */
  GRclassid ClassId; /* Added for 179603615 */
  int status; /* Added for 179603615 */

  /* Major error check */
  if (pCompId == NULL)
  {
    return 0;
  }

  /* Verify have a component by looking for comp_code */
  if (VRtrcGetCompAttrValue(pCompId,VRtrcg_pMdEnv,VR_N_COMP_CODE_AN) != 1)
  {
#if DEBUG_OBJ
    printf("NOT COMP: %u,%u\n",pCompId->osnum,pCompId->objid);
#endif
    return 0;
  }
#if DEBUG_OBJ
    printf("IS  COMP: %u,%u\n",pCompId->osnum,pCompId->objid);
#endif
  /* Added for TR#179603615 - law - 03/03/97 */
  status = om$get_classid ( objid = pCompId->objid,
                            osnum = pCompId->osnum,
                            p_classid = &ClassId);

  /* Add to comp list modified for 179603615 */
  pItem = _CALLOC(1,struct COMP_ITEM);
  pItem->ItemNum  = a_ItemNum;
  pItem->Type     = a_Type;
  pItem->branchno = a_TypeNum;
  pItem->num_neigh= a_TypeMax;
  pItem->comp_class   = ClassId; /* Added for TR#179603615 */
  pItem->CompId.objid = pCompId->objid;
  pItem->CompId.osnum = pCompId->osnum;
  pItem->pNext = NULL;
  
  if( pItem->Type == END_BRANCH)
  {
     pItem->CompId.objid = VRtrcg_pCompListTail->CompId.objid;
     pItem->CompId.osnum = VRtrcg_pCompListTail->CompId.osnum;
  }
        /* Added for TR#179603615 */
  if (VRtrcg_pCompListHead == NULL)
  {
     int TotalCps;
//   printf("ADDING START & ELEMENT records to branch 0\n");
     pItem->Type = START_BRANCH;
     VRtrcg_pCompListHead = pItem;
     VRtrcg_ItemNum = 0;
     VRAddCompToList(pCompId,VRtrcg_ItemNum,START_BRANCH,0,0);
     VRtrcg_ItemNum = 1;
     /****** Added to force an element record for 1st select ********/
     p1Item = _CALLOC(1,struct COMP_ITEM);
     p1Item->ItemNum  = VRtrcg_ItemNum;
     p1Item->Type     = 0;
     p1Item->branchno = 0;
     p1Item->num_neigh= 2;
     p1Item->comp_class   = ClassId; /* Added for TR#179603615 */
     p1Item->CompId.objid = pCompId->objid;
     p1Item->CompId.osnum = pCompId->osnum;
     pItem->pNext = p1Item;
     p1Item->pNext = NULL;

     pItem = p1Item;
     VRtrcg_ItemNum = 2;
     VRtrcg_pCompListTail = p1Item;
     /****** Added to process the choice of a branch as the first comp *****/
     {
       int NeiNum, BuffSize;
       struct GRid *pNeiId;
       long msg;

       VRtrcGetCompNbOfNeighbours(pCompId,VRtrcg_pMdEnv,&NeiNum);

       /* Happens with ACpretend */
       if (NeiNum <= 0)
       {
//        printf("Do not pick this object as first select\n");
          return 0;
       }

       TotalCps = 0;
       /*** DO NOT KNOW WHY WOULD HAPPEN ***/
       if(NeiNum > 0)
       {
          /* Get all the connect points */
          pNeiId = _CALLOC(NeiNum, struct GRid);

          BuffSize = sizeof( struct GRid ) * NeiNum;

          status = om$send( msg	   = message VRGeneric.VRGetTopo(
					       &msg,
					       BuffSize,
					       &TotalCps,
					       NULL,
					       NULL,
					       pNeiId,
					       NULL,
					       VRtrcg_pMdEnv ),
		  targetid = pCompId->objid,
		  targetos = pCompId->osnum ) ;
          _FREE (pNeiId);
       }
     }
     if(TotalCps > 1)
     {
        p1Item = _CALLOC(1,struct COMP_ITEM);
        p1Item->ItemNum  = VRtrcg_ItemNum;
        p1Item->Type     = 4;
        p1Item->branchno = 0;
        p1Item->num_neigh= TotalCps;
        p1Item->comp_class   = ClassId; /* Added for TR#179603615 */
        p1Item->CompId.objid = pCompId->objid;
        p1Item->CompId.osnum = pCompId->osnum;
        pItem->pNext = p1Item;
        p1Item->pNext = NULL;

        VRtrcg_ItemNum = 3;
        VRtrcg_pCompListTail = p1Item;
     }
  }
  else if (VRtrcg_pCompListTail != NULL)
  {
    VRtrcg_pCompListTail->pNext = pItem;
    VRtrcg_pCompListTail = pItem;
  }

  return 1;
}

/*  pBranchNum added for 179603615                 */
/* -------------------------------------------     */
/* Process a Component(recursive)                  */
/* Tried passing by value but did not seem to work */
        /* branchnumber modified for 179603615 */
int VRtrcProcComp( pCompId,pPrevCompId,pBranchNum)
struct GRid  *pCompId;
struct GRid  *pPrevCompId;
int *pBranchNum;
{
  struct GRid  CompId;
  struct GRid  PrevCompId;
  int   i;
  int   TotalCps;
  int   ItemNum;
  int   NeiNum;
  int   BranchNum;
  struct GRid *pNeiId;

  /* Variables that will not change from a recusrion call   */
  /* Need not be stacked, when in doubt, stack              */
  int BuffSize;
  long msg;
  int status;

  /* Added for TR#179603615 - law - 03/03/97 */
  /* Skip if connect object */
  status = VRtrckeep_object(0,0,pCompId);
  if( ! status )
  {
    goto VRProcComp_Ret;
  }

  /* Xfer arguments */
  CompId.objid     = pCompId->objid;
  CompId.osnum     = pCompId->osnum;
  PrevCompId.objid = pPrevCompId->objid;
  PrevCompId.osnum = pPrevCompId->osnum;
  /* Start by seeing if this is a loop */
  /* branchnumber modified for 179603615 */
  BranchNum = *pBranchNum;
//printf("Doing branch %d comp %d\n",BranchNum,CompId.objid);
  if (VRCheckCompLoop(&CompId)) 
  {
    VRAddCompToList(&CompId,VRtrcg_ItemNumLoop,LOOP_DETECTED,BranchNum,0);
    goto VRProcComp_Ret;
  }

  /* Add Item to List */
  VRtrcg_ItemNum = VRtrcg_ItemNum + 1;
  if (VRAddCompToList(&CompId,VRtrcg_ItemNum,0,BranchNum,0) != 1)
  {
    /* Not a desired component */
    goto VRProcComp_Ret;
  }

  /* Pull any supports Call Disabled */
  /*  VRtrcGetCompSupport(&CompId,VRtrcg_ItemNum); */

  /* Get Number of connect points */
  VRtrcGetCompNbOfNeighbours(&CompId,VRtrcg_pMdEnv,&NeiNum);

  /* Happens with ACpretend */
  if (NeiNum <= 0) goto VRProcComp_Ret;

  /* Get all the connect points */
  pNeiId = _CALLOC(NeiNum, struct GRid);

  BuffSize = sizeof( struct GRid ) * NeiNum;

  status = om$send( msg	   = message VRGeneric.VRGetTopo(
					       &msg,
					       BuffSize,
					       &TotalCps,
					       NULL,
					       NULL,
					       pNeiId,
					       NULL,
					       VRtrcg_pMdEnv ),
		  targetid = CompId.objid,
		  targetos = CompId.osnum ) ;

  if (!(status & msg & 1))
  {
#if DEBUG_OBJ
    printf("GetTopo Error: %x,%x\n",status,msg);
#endif
    _FREE(pNeiId);
    goto VRProcComp_Ret;
  }
#if DEBUG_OBJ
    printf("GetTopo A_OK : %x,%x\n",status,msg);
#endif

#if DEBUG_OBJ
  if (TotalCps != NeiNum)
  {
//    printf("TotalCps: %u \n",TotalCps);
  }
#endif

  /* Count actual unprocessed neighbours */
  NeiNum = 0;
// printf("for branch %d-comp %d- total cpts is %d\n",*pBranchNum,CompId.objid,TotalCps);
  for(i = 0; i < TotalCps; i = i + 1)
  {
//   printf("pNeiId of cpt %d is %d\n",i, pNeiId[i].objid);
    /* See if previous */
    if ((pNeiId[i].objid == PrevCompId.objid) &&
        (pNeiId[i].osnum == PrevCompId.osnum))
    {
      ItemNum  = VRtrcg_ItemNum;
      if(TotalCps > 2)
      {
        VRAddCompToList(&CompId,   ItemNum,
            END_BRANCH,*pBranchNum,0);
//      printf("Comp %d is the end of branch %d\n",CompId.objid,*pBranchNum);
      }
      else if(TotalCps == 1)
      {
         VRAddCompToList(&CompId,   ItemNum,UNCONNECTED_END,*pBranchNum,0);
      }
//    printf("pNeiId %d is set to NULL_OBJID as same as previous\n",pNeiId[i].objid);
      pNeiId[i].objid = NULL_OBJID;
    }
    /* Any left are real */
    if (pNeiId[i].objid != NULL_OBJID)
    {
//    printf("pNeiId %d is real\n",pNeiId[i].objid);
      NeiNum = NeiNum + 1;
    }
  }
    if(NeiNum == 0 && TotalCps > 1)
    {
//     printf("Compid %d made to be an UNCONNECTED_END for branch %d\n",CompId.objid,*pBranchNum);
      VRAddCompToList(&CompId,   ItemNum,UNCONNECTED_END,*pBranchNum,0);
    }

#if DEBUG_OBJ
  printf("NUM NEIG: %u,%u,%u\n",
    CompId.osnum,CompId.objid,NeiNum);
#endif

  /* If more than 1 neighbour, have a branch */
  if (NeiNum > 1 )
  {
//  printf("new branch\n");
    /* Branch Counter */
    ItemNum  = VRtrcg_ItemNum;

    for(i = 0; i < TotalCps; i = i + 1) 
    {
        if (VRCheckCompLoop(&pNeiId[i]))
      {
         /*** If a component is selected as start next to a branch ***/
         /*** the hookup going from the branch to start is not made ***/
         if(pNeiId[i].objid != VRtrcg_pCompListHead->CompId.objid)
         {
//          printf("LOOP ALREADY PROCESSED FOR CPT %d of %d going to %d\n",i,CompId.objid,pNeiId[i].objid);
            pNeiId[i].objid = NULL_OBJID;
         }
      }
      if(pNeiId[i].objid != NULL_OBJID) 
      {
        /* branchnumber modified for 179603615 */
        /* New branch */
        network_branches = *pBranchNum + 1 ;
        *pBranchNum = network_branches;

        if(BranchNum == 1) 
        {
             VRAddCompToList(&CompId,   ItemNum,
                 START_BRANCH,network_branches,NeiNum);
//           printf("WHEN DO WE COME THRU HERE----------------------------\n");
        }
        else
        {
             VRAddCompToList(&CompId,   ItemNum,
            BEGIN_BRANCH,network_branches,NeiNum);
        }
        VRtrcProcComp (&pNeiId[i],&CompId,pBranchNum);
      }
    }
  }
  /* No Branches */
  if (NeiNum == 1)
  {
    /* Find the actual neighbour */
    for(i = 0; i < TotalCps; i = i + 1)
    {
      if (pNeiId[i].objid != NULL_OBJID)
      {
        /* Modified for partial networks for 179603615 */
        VRtrcProcComp(&pNeiId[i],&CompId,pBranchNum);
      }
    }
  }
  _FREE(pNeiId);

/* Takes care of popping the stack */
VRProcComp_Ret:

  /* Done */
  return 1;
}

/* -------------------------------------------    */
/* pBranchNum added for 179603615                 */
/* Traverse the network and build list            */
int VRtrcBldCmpList (pCompId,pMdEnv,pBranchNum)
struct GRid       *pCompId;
struct GRmd_env   *pMdEnv;
int *pBranchNum; /* Modified for 179603615 */
{

  struct GRid PrevCompId;

  /* Master Component Item Counter */
  VRtrcg_ItemNum = 0;

  /* Save md_env               */
  VRtrcg_pMdEnv = pMdEnv;

  /* Clear Previous Comp Id    */
  PrevCompId.objid = NULL_OBJID;

  /* Free any existing list    */
  VRtrcFreeCompList();

  /* Make sure starts out null */

  /* Process the Component */
  UI_status("Processing...");

  /* Modified for partial networks for 179603615 */
  *pBranchNum = 0 ;
  VRtrcProcComp(pCompId,&PrevCompId,pBranchNum);
  UI_status("Processing complete.");

  /* Done */
  return 1;
}

/* ---------------------------------------------------------------      */
/* num_sel added   for 179603615  CompId and numnpt are pointers        */
/* Main routine, route type and report file name are optional args      */
int VRtrace_network(num_sel,pCompId,pnum_npt,nptlist,no_avoids,orig_avoid,
                                                           MdEnv,outlist)
  int num_sel;
  struct GRid *pCompId;
  int *pnum_npt;
  struct  GRid      *nptlist;
  int no_avoids;
  struct COMP_ITEM *orig_avoid;
  struct  GRmd_env  *MdEnv;
  struct GRid **outlist;

{

struct GRid CompId;
struct DBLLNK newlist;
int freestatus;
int outstatus;
int num_npt;
struct GRid *tmplist;
int sortpts;
int verify;

#if DEBUG_MEM
  VD_memReset();
  VD_memOn();
#endif

#if DEBUG_OBJ
  printf("\n VRtrace_network");
#endif

  UI_status(" I/ROUTE building network trace ");

  /* Make sure globals are NULL */
  VRtrcg_pCompListHead = NULL;
  VRtrcg_pCompListTail = NULL;
  VRtrcg_pHngrListHead = NULL;
  VRtrcg_pHngrListTail = NULL;

  /* CompId is first point. */
  /* Generate list of id's  */

  /* Modified for partial networks for 179603615 */
  CompId.objid = pCompId->objid;
  CompId.osnum = pCompId->osnum;
  network_branches = 0;
  VRtrcBldCmpList(&CompId,MdEnv,&network_branches);
#if DEBUG_OBJ
    VRrptbranch(); /* Added for TR#179603615 */
#endif
  /* Added for TR#179603615 */
  if((num_sel > 1) || (no_avoids > 0))
  {
    int i;
    network_branches = network_branches + 1;

    outstatus = VRpartnet_trace (network_branches,VRtrcg_pCompListHead,
                                    num_sel,pCompId,pnum_npt,no_avoids,
                                    orig_avoid,&tmplist);
    *outlist=&tmplist[0];
  }
  else
  { /* Only full network goes here - TR#179603615 */
    /* resort the lists       */
    VRtrcDbl_link_sort(&sortpts,&newlist);

    /* verify newlist against input list and generate output list */
    num_npt = sortpts;
    verify = FALSE; /* verify against ranlist disabled for TR179603615 */
    *pnum_npt = sortpts;

    outstatus = VRtrcGen_outlist(num_npt,newlist,verify,no_avoids,orig_avoid,
                          nptlist,&tmplist);
    *outlist=tmplist;
    freestatus = VRtrcFree_dbl_lnk(newlist.pNext);
  }
  /* Free the lists */
  freestatus = VRtrcFreeCompList();
  if( ! outstatus ) return 0; 
#if DEBUG_MEM
  /* Check for leaks */
  VD_memStatus();
#endif

  return 1;
}

/* ------------------------------------------ */
/* Verify turned off for TR179603615, ranlist not used */
int VRtrcGen_outlist(num_out_pts,newlist,verify,
                   no_avoids,orig_avoid,ranlist,outlist)
  int num_out_pts;
  struct DBLLNK newlist;
  int verify;
  int no_avoids;
  struct COMP_ITEM *orig_avoid;
  struct GRid *ranlist;
  struct GRid **outlist;
{
  int no_pts_fnd;
  int pt_not_fnd;
  int npt;
  int status;
  struct DBLLNK *next_pt;
  struct GRid *tmplist;
  struct GRid tmpGRid;

  tmplist = _CALLOC(num_out_pts,struct GRid);
  no_pts_fnd=0;
  next_pt = &newlist;
  while(next_pt)
  {
    tmpGRid.objid = next_pt->CompId.objid;
    tmpGRid.osnum = next_pt->CompId.osnum;
    status = VRtrckeep_object(no_avoids,orig_avoid,&tmpGRid);
    if(status)
    {
       pt_not_fnd = 1;
       for(npt=0;(npt < num_out_pts && pt_not_fnd); npt = npt + 1)
       {
         if(verify)
         {
            if(next_pt->CompId.objid == (ranlist+npt)->objid)
            {
               pt_not_fnd = 0;
               (tmplist + no_pts_fnd)->objid = (ranlist+npt)->objid;
               (tmplist + no_pts_fnd)->osnum = (ranlist+npt)->osnum;
               no_pts_fnd = no_pts_fnd +1;
            }
         }
         else
         {
           pt_not_fnd = 0;
           (tmplist+no_pts_fnd)->objid = (next_pt->CompId.objid);
           (tmplist+no_pts_fnd)->osnum = (next_pt->CompId.osnum);
           no_pts_fnd = no_pts_fnd +1;
         }
       }
       next_pt = next_pt->pNext;
    }
    else
    {
      /* avoid found-trying to skip around avoid */
       next_pt = next_pt->pNext;
    }
  }
  *outlist = tmplist;

  if(no_pts_fnd != num_out_pts)
  {
     UI_status("\n Query confused, random select");
     return 0;
  }
return 1;
}
/* ------------------------------------------                */
/* Looks up given attribute value                            */
/* Look up "spec_code" as a way of verifying route parameter */
int VRtrcGetCompAttrValue(pCompId,pMdEnv,pAttrName)
struct GRid *pCompId;
struct GRmd_env *pMdEnv;
char *pAttrName;
{
  long msg;
  int status;

  struct ACrg_coll RgColl;

  /* Get the data */
  strcpy(RgColl.name,pAttrName);
  status = vd$review_parameters(
    pMsg = &msg, 
    pComponent =  pCompId,
    NbParams   =  1,
    pList      = &RgColl,
    pMdEnv     =  pMdEnv);

  if (status != 1)
  {
    return 0;
  }
  return 1;
}

/* --------------------------------------------------
  Returns the number of neighbors for given comp id.
  Returns 0 if fails.
*/
int VRtrcGetCompNbOfNeighbours(pCompId,pMdEnv,pNbOfNeighbours)
struct GRid     *pCompId;
struct GRmd_env *pMdEnv;
int             *pNbOfNeighbours;
{
  long msg;
  int status;

  status = om$send( msg = message VRGeneric.VRGetNumberOfCpts(
						       &msg,
						       pNbOfNeighbours,
						       pMdEnv ),
		  targetid = pCompId->objid,
		  targetos = pCompId->osnum ) ;

  if (status != 1)
  {
    *pNbOfNeighbours = -1;
    return 0;
  }

#if DEBUG_OBJ
  printf("NUM COMP: %u,%u,%u\n",
                      pCompId->osnum,pCompId->objid,*pNbOfNeighbours);
#endif

  return 1;
}

/* ------------------------------------------------ */
/* Stores any support id's                          */
int VRtrcGetCompSupport(pCompId, ItemNum)
struct GRid *pCompId;
int ItemNum;
{
  IGRlong 	msg;
  IGRlong       status;
  IGRint 	NbHangers, i;
  IGRdouble	d30CpCoors[30];
  struct GRid	s10HangerIds[10];
  struct COMP_HNGR   *pHngr;

  status = om$send(msg=message VRGeneric.VRGetHangers(&msg,10, s10HangerIds,
			 &NbHangers, d30CpCoors, VRtrcg_pMdEnv),
		  targetid = pCompId->objid,
		  targetos = pCompId->osnum ) ;

  for(i = 0; i < NbHangers; i = i + 1)
  {
    pHngr = _CALLOC(1,struct COMP_HNGR);
    pHngr->CompId.objid = pCompId->objid;
    pHngr->CompId.osnum = pCompId->osnum;
    pHngr->HngrId.objid = s10HangerIds[i].objid;
    pHngr->HngrId.osnum = s10HangerIds[i].osnum;
    pHngr->ItemNum = ItemNum;

    if (VRtrcg_pHngrListHead == NULL) VRtrcg_pHngrListHead = pHngr;
    if (VRtrcg_pHngrListTail != NULL) VRtrcg_pHngrListTail->pNext = pHngr;
    VRtrcg_pHngrListTail = pHngr;
  }

  return 1;
}

/* -------------------------------------------------*/
/* Frees up allocated component list and hanger list */
int VRtrcFreeCompList()
{
  struct COMP_ITEM *pComp,*pCompNext;
  struct COMP_HNGR *pHngr,*pHngrNext;

  for(pComp = VRtrcg_pCompListHead; pComp; pComp = pCompNext)
  {
    pCompNext = pComp->pNext;
    _FREE(pComp);
  }
  VRtrcg_pCompListHead = NULL;
  VRtrcg_pCompListTail = NULL;

  for(pHngr = VRtrcg_pHngrListHead; pHngr; pHngr = pHngrNext)
  {
    pHngrNext = pHngr->pNext;
    _FREE(pHngr);
  }
  VRtrcg_pHngrListHead = NULL;
  VRtrcg_pHngrListTail = NULL;

  return 1;
}

/* ---------------------------------------------------------- */
/* Sorts list into list for review network                    */
int VRtrcFree_dbl_lnk(tmp_ptr)

struct DBLLNK *tmp_ptr;
{
  struct DBLLNK *next_ptr;
  while(tmp_ptr)
  {
    next_ptr = tmp_ptr->pNext;
    _FREE(tmp_ptr);
    tmp_ptr = next_ptr;
  }
  return 1;
}
/* Added no_rtn for TR179603615 */
int VRtrcDbl_link_sort(no_rtn,rtnlst)
int *no_rtn;
struct DBLLNK *rtnlst;
{
struct DBLLNK *prev_rec;
struct DBLLNK *pcheck;
struct DBLLNK *tmp_ptr;
struct DBLLNK *lnklst;
struct COMP_ITEM *pItem;
int no_duplicate;
int not_finished;

/* Calloc and store the first object */

 if(VRtrcg_pCompListHead)
 {
  rtnlst->ItemNum      = VRtrcg_pCompListHead->ItemNum;
  rtnlst->pPrev        = rtnlst;
  rtnlst->CompId.objid = VRtrcg_pCompListHead->CompId.objid;
  rtnlst->CompId.osnum = VRtrcg_pCompListHead->CompId.osnum;
  *no_rtn = 1; /* added for TR179603615 */
  lnklst = rtnlst;
  rtnlst->pNext = NULL;

  prev_rec = lnklst;

  for(pItem = VRtrcg_pCompListHead->pNext; pItem; pItem = pItem->pNext)
  {
     no_duplicate = 1;
     pcheck = prev_rec;
     /* single item lists are trapped by the for loop */
     not_finished = 1;
     /* Branch number set to -1 for skip items */
     if(pItem->branchno == -1)
     {
       no_duplicate = FALSE;
     }
/*   skip if next object was previously visited in net Added for TR179603615 */
     while (not_finished && no_duplicate)
     {
       if(pcheck->CompId.objid != pItem->CompId.objid)
       {
         /* Caution!, the first item must be compared before exiting. */
         if(pcheck == lnklst) not_finished = 0;
         pcheck = pcheck->pPrev;
         if(pcheck == NULL) not_finished = 0; /* end add for TR#179603615 */
       }
       else
       {
         no_duplicate = 0;
       }
     }
     if(no_duplicate)
     {
       tmp_ptr = _CALLOC(1,struct DBLLNK);
       prev_rec->pNext = tmp_ptr;
       tmp_ptr->pPrev = prev_rec;
       prev_rec = tmp_ptr;
       prev_rec->ItemNum      = pItem->ItemNum;
       prev_rec->CompId.objid = pItem->CompId.objid;
       prev_rec->CompId.osnum = pItem->CompId.osnum;
       *no_rtn = *no_rtn + 1; /* Added for TR#179603615 */
     }
/*   If last item was a duplicate, calloc stored a NULL in prev_rec->pNext */
  }
 }
 return 1;
}
/* Added for debuggin-by TR#179603615 */
int VRrptbranch()
{
/* module to simply report branch and members */

struct COMP_ITEM *itemlist;
int not_finished;

  itemlist = VRtrcg_pCompListHead;
  not_finished = TRUE;

  while (not_finished)
  {
    if(itemlist->branchno == 0)
      printf("\n begin network");
    if(itemlist->Type == START_BRANCH)
      printf("\n start branch %d for object %ld",
                itemlist->branchno,itemlist->CompId.objid);
    else if(itemlist->Type == BEGIN_BRANCH)
      printf("\n begin branch %d for object %ld",
                itemlist->branchno,itemlist->CompId.objid);
    else if(itemlist->Type == END_BRANCH)
      printf("\n end branch %d for object %ld",
                itemlist->branchno,itemlist->CompId.objid);
    else if(itemlist->Type == LOOP_DETECTED)
      printf("\n loop component branch %d is object %ld",
                itemlist->branchno,itemlist->CompId.objid);
    else if(itemlist->Type == UNCONNECTED_END)
      printf("\n branch %d object %ld is an unconnected end",
                itemlist->branchno,itemlist->CompId.objid);
    else
      printf("\n element of branch %d is object %ld",
                itemlist->branchno,itemlist->CompId.objid);
    if(itemlist->pNext == NULL)
      not_finished = FALSE;
    else
      itemlist = itemlist->pNext;
  }
return 1;
}
/************************************************************************/
int VRtrckeep_object(no_avoids,orig_avoid,p_object)
int no_avoids;
struct COMP_ITEM *orig_avoid;
struct GRid *p_object;
{
  struct COMP_ITEM *this_avoid;
  int not_finished;
  /* Added for TR#179603615 - law - 03/03/97 */
  GRclassid ClassId;
  extern GRclassid OPP_VRCptIn_class_id;
  int status;

  if(no_avoids)
  {
    this_avoid = orig_avoid;
    not_finished = 1;
    while(not_finished)
    {
      /* modified for TR#179603615 */
      if((this_avoid->CompId.objid == p_object->objid) &&
         (this_avoid->CompId.osnum == p_object->osnum))
      {
        return (0);
      }
      this_avoid = this_avoid->pNext;
      if(this_avoid == NULL) not_finished = 0;
    }
  }
  /* Added for TR#179603615 - law - 03/03/97 */
  status = om$get_classid ( objid = p_object->objid,
                            osnum = p_object->osnum,
                            p_classid = &ClassId);

  if ( ClassId == OPP_VRCptIn_class_id )
  {
      return (0);
  }

  return (1);
}

/* VRpartnet_trace added for 179603615, rewritten for TR179901801 */
/*********************************************************************
****
Note that instead of a matrix of mat, we call a function vr_brch_intersect
****

column of mat is the branch path index with tgt being the target branch

'F','T' is the from/to direction of travel along the original packing of the
   branch. The value in the branch column is the arrival end. The value in the//   branch row is the direction to unparse the branch components ('T' means
   traverse the branch comps from the end backwards

 TE is the target end of the target branch. 'F' is the from end,
                                            'T' is the "to",
                                            'A' is any end.
 *** We dont track the targets by direction-the flag still is populated ***
 incoming is the from/to direction of connecting to the next branch. If the
          connecting end is 'T', then incoming is from 'F' (dir of the branch
          is the same as incoming, 'T' means the branch comps have to be loaded
          in reverse.)
 mat[a,b] is the charcteristics of the branch 'b' end that connects to the next
          branch 'a' ('T' being the last loaded comp in the branch, 'F' being
          the  first. mat[b,a] is the direction of loading the comps in the 'a'
          branch to get to the connected end of 'b' ('T' means load in reverse
          order). Therefore mat[b,a] is the value for incoming when analyzing
          the connected branchs at the other end.i
By definition,
for going from branch 0 to branch 1:

 mat[1,0] is 'T' meaning branch 1 is located on the terminating end of branch 0.

 if loading branch 0, to get to branch 1, load dir as 'F' (forward) being the
 reverse of the value of mat[1,0]. Note that incoming is the same as dir.

**************************************************************************/


int VRpartnet_trace (total_branches,input_list,no_sel_comp,sel_comp,poutcnt,
                    navoids,orig_avoid,outlist)

int total_branches;
struct COMP_ITEM *input_list;
int no_sel_comp;
struct GRid *sel_comp;
int *poutcnt;
int navoids;
struct COMP_ITEM *orig_avoid;
struct GRid **outlist;

{
extern char vr_brch_intersect();

/**** start by creating the branch and target buffers ****/
struct tgtbuff
{
   struct GRid CompId;
   int brnchndx;
   int dir;
};
struct GRid tempobj;
struct GRid *output_list;
struct brnchrecstr *branchlist;
struct tgtbuff *tgtlist;
int sizearray,tgtfound,possible,notinlist;
int first_comp,outcount,cmpcnt;
int i,j,k,tgtndx,notgts,active_branch,branch_cmpcnt,possible_stones;
int status;
struct COMP_ITEM *next_avoid,*pItem;

/**************************************************************************/
   if(total_branches <= 0) return 0;
   branchlist = _CALLOC(total_branches, struct brnchrecstr);
   sizearray = total_branches * total_branches;
// printf("navoids %d\n",navoids);
// printf("no_sel_comp %d\n",no_sel_comp);
   if(navoids)
      notgts = navoids + 1;
   else
      notgts = no_sel_comp;
   if(notgts)   /**** This is not supposed to happen ****/
   tgtlist = _CALLOC(notgts,struct tgtbuff);
// printf("First select is %d\n", VRtrcg_pCompListHead->CompId.objid);

   tgtlist[0].brnchndx = 0;
   tgtlist[0].CompId = VRtrcg_pCompListHead->CompId;
   tgtlist[0].dir = 'B';
   next_avoid = orig_avoid;
   for(i=1; i<notgts; i++)
   {
      if(navoids)
      {
         tgtlist[i].CompId.objid = next_avoid->CompId.objid;
         tgtlist[i].CompId.osnum = next_avoid->CompId.osnum;
//       printf("avoid is %d\n",tgtlist[i].CompId.objid);
         next_avoid = next_avoid->pNext;
      }
      else
      {
         tgtlist[i].CompId = sel_comp[i];
//       printf("target %d is %d\n",i,tgtlist[i].CompId.objid);
      }
   }
   /*************** CREATE THE branchlist BUFFER *************/
   first_comp = 1;
   active_branch = VRtrcg_pCompListHead->branchno;
   for(pItem = VRtrcg_pCompListHead; pItem; pItem = pItem->pNext)
   {
//   printf("pItem is pItem %d of branch %d of type %d\n",pItem->CompId.objid,pItem->branchno,pItem->Type);
     if( pItem->Type == START_BRANCH || pItem->Type == BEGIN_BRANCH)
     {
       first_comp = 1;
       active_branch = pItem->branchno;
       tgtfound = 0;
       if(active_branch != 0)
       branchlist[pItem->branchno].f_grid = pItem->CompId;
//     printf("1 branch %d fgrid is %d\n",active_branch,pItem->CompId.objid);
       if(active_branch == 0)
       {
          tgtfound = 1;
          branch_cmpcnt = 0; /* was equal to one */
          first_comp = 0;
          branchlist[active_branch].startcmp = pItem;
       }
       else
          branch_cmpcnt = 0;
/*************  Not Used- Intended for optimization ********************
       for(i = 0; i<active_branch; i++)
       {
         if(branchlist[i].f_grid.objid == pItem->CompId.objid)
         { 
           j = branchlist[active_branch].no_f_connects;
           branchlist[active_branch].f_branch_connect[j] = i;
           branchlist[active_branch].no_f_connects++;
           j = branchlist[i].no_f_connects;
           branchlist[i].f_branch_connect[j] = active_branch;
           branchlist[i].no_f_connects++;
         }
         if(branchlist[i].t_grid.objid == pItem->CompId.objid)
         { 
           j = branchlist[active_branch].no_f_connects;
           branchlist[active_branch].f_branch_connect[j] = i;
           branchlist[active_branch].no_f_connects++;
           j = branchlist[i].no_t_connects;
           branchlist[i].t_branch_connect[j] = active_branch;
           branchlist[i].no_t_connects++;
         }
       }
***********************************************************************/
     }
     else if( pItem->Type == END_BRANCH || pItem->Type == UNCONNECTED_END ||
              pItem->Type == LOOP_DETECTED)
     {
       int cmpcnt;
       struct COMP_ITEM *p1Item;
   
       branchlist[pItem->branchno].t_grid = pItem->CompId;
       branchlist[active_branch].no_comps = branch_cmpcnt;
       /*** To prevent callocing 0 bytes and to give comps an address ***/
       cmpcnt = branch_cmpcnt;
       if(cmpcnt == 0)
         cmpcnt = 1;
       branchlist[active_branch].comps = _CALLOC(cmpcnt,struct GRid);

//     printf("branch_cmpcnt of branch %d is %d\n",active_branch,branch_cmpcnt);
       cmpcnt = 0;
       for(p1Item = branchlist[active_branch].startcmp; cmpcnt < branch_cmpcnt;
                                                      p1Item = p1Item->pNext)
       {
//        printf("pItem %d of branch %d of type %d is %d\n",cmpcnt, active_branch, p1Item->Type, p1Item->CompId.objid);
          if( p1Item->Type == 0)
          {
            branchlist[active_branch].comps[cmpcnt] = p1Item->CompId;
            cmpcnt++;
          }
       }
/*************  Not Used- Intended for optimization ********************
       for(i = 0; i<active_branch; i++)
       {
          if(branchlist[i].f_grid.objid == pItem->CompId.objid)
          { 
            j = branchlist[active_branch].no_t_connects;
            branchlist[active_branch].t_branch_connect[j] = i;
            branchlist[active_branch].no_t_connects++;
            j = branchlist[i].no_f_connects;
            branchlist[i].f_branch_connect[j] = active_branch;
            branchlist[i].no_f_connects++;
          }
          if(branchlist[i].t_grid.objid == pItem->CompId.objid)
          { 
            j = branchlist[active_branch].no_t_connects;
            branchlist[active_branch].t_branch_connect[j] = i;
            branchlist[active_branch].no_t_connects++;
            j = branchlist[i].no_t_connects;
            branchlist[i].t_branch_connect[j] = active_branch;
            branchlist[i].no_t_connects++;
          }
        }
**********************************************************************/
      }
      else
      {
        if(first_comp)
        {
           first_comp = 0;
           branchlist[active_branch].startcmp = pItem;
        }
        branch_cmpcnt++;
        for (j=1;j<notgts;j++)
        {
//         printf("comparing %d of branch %d to target %d which is %d\n",pItem->CompId.objid, active_branch, j,tgtlist[j].CompId.objid);
           if(pItem->CompId.objid == tgtlist[j].CompId.objid)
           {
//           printf("target %d- %d found in %d\n",j,tgtlist[j].CompId.objid,active_branch);
             tgtlist[j].brnchndx = active_branch;
             if(branchlist[active_branch].no_tgts)
             {
                branchlist[active_branch].no_tgts = 2;
                branchlist[active_branch].tgt_2_ndx = j;
                tgtlist[j].dir = 'T';
                k = branchlist[active_branch].tgt_1_ndx;
                tgtlist[k].dir = 'F';
             }
             else
             {
                branchlist[active_branch].no_tgts = 1;
                branchlist[active_branch].tgt_1_ndx = j;
                branchlist[active_branch].tgt_2_ndx = j;
                tgtlist[j].dir = 'B';
             }
           }
        }
      }
   }

  /********** CREATE THE STEPPING STONE LIST (ss) ****************/ 
  {
    int og = 0;
    char TE;
    char incoming = 'F';
    int no_ss,ss_notused,no_rows,frm,i,j,k;
    int search_notcomplete;
    char direction;
    int nohits;
    int targetfound;
    struct GRid target1,target2;
    int endbr;
    struct brchbuff
    {
       int  branchndx;
       char dir;
    };
    struct brchbuff *hits;
    struct brchbuff *ss;
    int total_count, nuno_ss,nu_frm,nu_i,brnchendhit;

    /************************ INIT ***************************************/
    frm = 0; 
    i = 0;
    possible_stones = total_branches + notgts;
    ss = _CALLOC(possible_stones,struct brchbuff);
    hits = _CALLOC(possible_stones,struct brchbuff);
    ss[0].branchndx = 0;
    ss[0].dir = 'B';
    no_ss = 1;
    search_notcomplete = 1;
    no_rows = total_branches;
    nohits = 1;
    hits[0].branchndx = 0;
    hits[0].dir = 'F';
    for(tgtndx = 1; tgtndx<notgts; tgtndx++)
    {
      if(tgtlist[tgtndx].brnchndx == 0)
      {
//       printf("Found the target %d in branch 0\n",tgtlist[tgtndx].CompId.objid);
         hits[0].dir = 'P';
         search_notcomplete = 0;
      }
    }
    total_count = branchlist[0].no_comps;
    /***********************************************************************/
    /***** STEPPING STONE FABRICTOR *****/
    /**** PRIMARY MAZE WIZARD *******/
    possible = 0;
    do
    {
      if(search_notcomplete)
      {
        char dummy;
//      printf("first try from %d is %d\n",frm,i);
//      printf("incoming for %d is %c\n",frm,ss[no_ss-1].dir);
        do
        {
          dummy = vr_brch_intersect(branchlist,i,frm);
          incoming = ss[no_ss-1].dir; 
//        printf("trying to go from %d to %d\n",frm,i);
//        printf("incoming for %d is %c with mat being %c\n",frm,incoming,dummy);
          brnchendhit = 0;
          targetfound = 0;
          /* If a target is a branch comp belonging to another branch ********/
          /* Then we need to store i,frm, and no_ss for later ***********/
          for(tgtndx = 1; (tgtndx < notgts) && (!targetfound); tgtndx++)
          {
            if((incoming == 'F' && 
                branchlist[frm].t_grid.objid == tgtlist[tgtndx].CompId.objid) ||
               (incoming == 'T' && 
                branchlist[frm].f_grid.objid == tgtlist[tgtndx].CompId.objid) )
            {
//            printf(" target at end of %d is detected\n",tgtlist[tgtndx].CompId.objid, frm);
              if(tgtlist[tgtndx].brnchndx != frm)
              {
//               printf("target has to terminate this branch-store no_ss,i,frm for later\n");
                 i = tgtlist[tgtndx].brnchndx;
                 brnchendhit = 1;
                 nuno_ss = no_ss;
                 if(no_ss < 1)
                 {
                    search_notcomplete = 0;
                 }
                 else
                 {
                    nu_i = no_rows;
                    nu_frm = ss[no_ss-1].branchndx;
                 }
              }
            }
          }

          if((incoming == 'F' && vr_brch_intersect(branchlist,i,frm) == 'T') ||
             (incoming == 'T' && vr_brch_intersect(branchlist,i,frm) == 'F') ||
             (incoming == 'B' && vr_brch_intersect(branchlist,i,frm) != 'O') ||
                                 vr_brch_intersect(branchlist,i,frm) == 'B')
          {
//           possible++;
//           printf("from %d, trying path %d\n",frm,i); fflush(stdout);
             /*  a possible path has been mapped  */
             ss_notused = 1;
             for(j=0; j<no_ss && ss_notused; j++)
             {
               /* make sure step-stone not already in path */
//             printf("stepping stone %d is %d\n",j,ss[j].branchndx);
               if(ss[j].branchndx == i)
               {
//               printf("stepping stone used in this path, try another\n");fflush(stdout);
                 ss_notused = 0;
               }
             }
             if (ss_notused)
             {
               int jj, oldfrm, loopflg,tmphits;
               char tmpdir;

               /* Set up the stepping stone for the search for the next step */
//             printf("%d is a possible stepping stone\n",i);fflush(stdout);
               ss[no_ss].branchndx = i;

               dummy = vr_brch_intersect(branchlist,frm,i);
//             printf("The direction of %d is supposed to be %c\n",i,dummy);
//             printf("for %d- f_grid is %d and t_grid is %d\n",frm,branchlist[frm].f_grid.objid,branchlist[frm].t_grid.objid);
//             printf("for %d- f_grid is %d and t_grid is %d\n",i,branchlist[i].f_grid.objid,branchlist[i].t_grid.objid);

               if (vr_brch_intersect(branchlist,frm,i) == 'F' ||
                   vr_brch_intersect(branchlist,frm,i) == 'B')
                 ss[no_ss].dir = 'F';
               else
                 ss[no_ss].dir = 'T';
               oldfrm = frm;
               frm = i;
//             printf("stone is mapped as no_ss %d, setup next stone\n",no_ss);
               no_ss++;
               /* Flag hits array if any targets are found in branch */
               targetfound = 0;
//             printf("notgts is %d\n",notgts);
               for(tgtndx=1; (tgtndx<notgts) && (!targetfound); tgtndx++)
               {
//                printf("tgtndx %d-branch %d- ss %d\n",tgtndx,tgtlist[tgtndx].brnchndx, i);
                  TE = tgtlist[tgtndx].dir;
                  if(frm == tgtlist[tgtndx].brnchndx)
                  {
//                   printf("target %d has been found\n",i);fflush(stdout);
                     targetfound = 1;
//                   printf("at least one target found branch %d \n",i);
                     /*********** LOLLIPOP LOOP CHECKER ******************/
//                   printf("t_grid is %d ----------------------- f_grid is %d for %d\n",branchlist[i].t_grid.objid,branchlist[i].f_grid.objid,i);
                     loopflg = 0;
                     if(branchlist[i].t_grid.objid ==
                                                    branchlist[i].f_grid.objid)
                     {
                        loopflg = 1;
                        tmpdir = ss[no_ss-1].dir;
//                      printf("Closed loop detected\n");
                     }
                     /*** CHECK FOR LOOP BYPASS OF BRANCH ***/
                     if(((branchlist[i].t_grid.objid ==
                                           branchlist[oldfrm].f_grid.objid) &&
                         (branchlist[i].f_grid.objid ==
                                           branchlist[oldfrm].t_grid.objid)) ||
                        ((branchlist[i].f_grid.objid ==
                                           branchlist[oldfrm].f_grid.objid) &&
                         (branchlist[i].t_grid.objid ==
                                           branchlist[oldfrm].t_grid.objid)))
                     {
//                      printf("Branches %d and %d intersect at %d and %d\n",oldfrm,i,branchlist[oldfrm].f_grid.objid,branchlist[oldfrm].t_grid.objid);
                        loopflg = 1;
//                      printf("Apparent direction of loop is opposite %c\n",ss[no_ss-1].dir);
                        tmpdir=ss[no_ss-1].dir;
                     }
                     /***** FROM THE STEPPING STONE BUILD THE HITS LIST ******/
                     /* Restack the ss array into the hits array as unique */
                     for(k=0; k<no_ss; k++)
                     {
                       if(ss[k].dir == 'F')
                       {
//                        printf("branch %d forward\n",ss[k].branchndx); fflush(stdout);
                          direction = 'F';
                       }
                       else
                       {
//                        printf("branch %d reverse\n",ss[k].branchndx); fflush(stdout);
                          direction = 'T';
                       }
                       notinlist = 1;

                       for (j=0; (j< nohits) && notinlist; j++)
                       {
                          /* If a target and not same direction as previous,
                                                                    keep hit */ 
                          if(k == (no_ss-1))
                          {
//                           printf("Checking branch %d-stone %d for being in the hit list\n",ss[k].branchndx,k);
                             if(ss[k].dir == 'F')
                                direction = 'P';
                             else if(ss[k].dir == 'T')
                                direction = 'R';

                             if(ss[k].branchndx == hits[j].branchndx)
                             {
                               if(ss[k].dir == 'F' && hits[j].dir == 'P')
                               {
                                  notinlist = 0;
                               }
                               else if(ss[k].dir == 'T' && hits[j].dir == 'R')
                               {
                                  notinlist = 0;
                               }
                             }
                          }
                          else if(ss[k].branchndx == hits[j].branchndx)
                             notinlist = 0;
                       }
                       if(notinlist)
                       {
                          int brndx;
                          brndx = ss[k].branchndx;
                          hits[nohits].branchndx = ss[k].branchndx;
                          hits[nohits].dir = direction;
//                        printf("hit %d branch %d has dir %c\n",nohits,ss[k].branchndx,direction);
                          total_count += branchlist[brndx].no_comps;
//                        printf("total_count is %d\n",total_count);
                          nohits++;
                       }
                       if(loopflg)
                       {
                          if(tmpdir == 'P' || tmpdir == 'F')
                            tmpdir = 'R';
                          else
                            tmpdir = 'P';

                          notinlist = 1;
//                        printf("Checking if %d dir %c is in hits list\n",i,tmpdir);
                          for(tmphits = 0; tmphits<nohits;tmphits++)
                          {
                             if(hits[tmphits].branchndx == i && 
                                              hits[tmphits].dir == tmpdir)
                             {
                                notinlist = 0;
                             }
                          }
                          if(notinlist)
                          {
                             int brndx;
//                           printf("hit in closed loop detected for branch %d\n",i);
//                           printf("hit branch processed is %d\n",i);
                             brndx = i;
                             hits[nohits].branchndx = i;
                             hits[nohits].dir = tmpdir;
//                           printf("direction for branch %d is %c\n",brndx,tmpdir);
                             total_count += branchlist[brndx].no_comps;
                             nohits++;

                          }
                       }
                     }
                     /* if the hit is on the terminal of the previous branch */
                     /* back off past the end of that branch                 */
/************ WILL TRY TO DELETE THIS SECTION **********/
                     if(brnchendhit)
                     {
//                      printf("target found at end of %d *******************************\n",nu_frm); 
//                      printf("new frm is %d,new i is %d\n",nu_frm,nu_i);
                        i = nu_i;
                        no_ss = nuno_ss;
                        frm = nu_frm;
                     }
                     else
                     {
                        frm = i;
                        i = no_rows;
                     }
                  }
               } /* end scanning target list */
               if(!targetfound)
               {
//                printf("start over with row 0\n"); fflush(stdout);
                  i = 0;
               }
               /* if target found, path added hit, else if navoid add anyway */
//             printf("navoids %d-targetfound %d *\n",navoids,targetfound);
               if(navoids && !targetfound)
               {
                  notinlist = 1;
                  for(k=0; k<nohits && notinlist; k++)
                  {
                    if(ss[no_ss-1].branchndx == hits[k].branchndx)
                       notinlist = 0;
                  }
                  if(notinlist)
                  {
                    int brndx;
                    brndx = ss[no_ss-1].branchndx;
//                  printf("nohit branch processed is %d\n",ss[no_ss-1].branchndx);
                    hits[nohits].branchndx = ss[no_ss-1].branchndx;
                    hits[nohits].dir = ss[no_ss-1].dir;
                    total_count += branchlist[brndx].no_comps;
//                  printf("total_count is %d\n",total_count);
                    nohits++;
                  }
               }
             }
          }
          i++;
        } while (i<no_rows);
//      printf("no_steppingstones tried is %d\n",no_ss);
//      printf("Path ended trying to proceed from %d,look for alternate paths\n",frm);
        i = frm + 1;
        /******* END OF PATH BACK UP TO TRY ANOTHER ******/
//      printf("try the next stepping stone being %d\n",i);
        if(i >= no_rows)
        {
//        printf("not that many stepping stones- back up another another ss\n");
          do
          {
             no_ss = no_ss-1;
             if(no_ss < 1)
             {
//              printf("Out of alternates, quitting\n");
                search_notcomplete = 0;
             }
             else
             {
                i = ss[no_ss].branchndx + 1;
                frm = ss[no_ss-1].branchndx;
//              printf("found an alternate, trying paths from %d\n",frm);
//              printf("possible next ss is &d\n",i);
             }
          } while( i >= no_rows && search_notcomplete );
        }
        else
        {
          no_ss--;

//        printf("backed up to %d\n",ss[no_ss-1].branchndx);
          if(no_ss < 1)
          {
//           printf("back to the begining, no more alternates\n");
            search_notcomplete = 0;
          }
          else
          {
            if(no_ss < 1)
               search_notcomplete = 0;
            else
            {
               frm = ss[no_ss - 1].branchndx;

//             printf("backing up one stone to %d to try a different path\n",frm);fflush(stdout);
            }
          }
//        printf("continue flag is %d\n",search_notcomplete); fflush(stdout);
        }
      }
    } while ( search_notcomplete );

    /************* CREATE THE OUTPUT LIST **********************/
    outcount = 0;
//    printf("final total_count %d\n",total_count);
    /*** To give output_list an address ***/
    j = total_count;
    if(j == 0) j = 1;
    output_list = _CALLOC(j, struct GRid);
    for(j=0;j<nohits;j++)
    {   
      i = hits[j].branchndx;
//    printf("branch %d direction is %c\n",i,hits[j].dir);
      if(hits[j].dir == 'T') 
      {
         int ndx;

//       printf("branch %d is to be listed in reverse order-%d comps\n",hits[j].branchndx,branchlist[i].no_comps);
         for(cmpcnt = branchlist[i].no_comps;cmpcnt > 0; cmpcnt--)
         {
           ndx = cmpcnt - 1;
           (output_list+outcount)->objid = branchlist[i].comps[ndx].objid;
           (output_list+outcount)->osnum = branchlist[i].comps[ndx].osnum;
//         printf("%d outcount %d for %d-%d\n",i,outcount,branchlist[i].comps[ndx].objid,branchlist[i].comps[ndx].osnum);
           outcount++;
         }
      }
      else if(hits[j].dir == 'R') 
      {
         int ndx;
         endbr = 0;
         target1 = tgtlist[branchlist[i].tgt_1_ndx].CompId;
         target2 = tgtlist[branchlist[i].tgt_2_ndx].CompId;

         for(cmpcnt = branchlist[i].no_comps;cmpcnt > 0; cmpcnt--)
         {
           ndx = cmpcnt - 1;
           if(target1.objid == branchlist[i].comps[ndx].objid) endbr = 1;
           if(target2.objid == branchlist[i].comps[ndx].objid) endbr = 1;
           if(navoids && endbr)
           {
              cmpcnt = branchlist[i].no_comps - cmpcnt;
//            printf("branch %d is to be partially listed in reverse order-%d comps\n",hits[j].branchndx,ndx);
              cmpcnt = 0;
           }
           else
           {
              (output_list+outcount)->objid = branchlist[i].comps[ndx].objid;
              (output_list+outcount)->osnum = branchlist[i].comps[ndx].osnum;
//            printf("%d outcount %d for %d-%d\n",i,outcount,branchlist[i].comps[ndx].objid,branchlist[i].comps[ndx].osnum);
              outcount++;
              if(endbr) cmpcnt = 0;
           }
         }
      }
      else if(hits[j].dir == 'P') 
      {
         endbr = 0;
         target1 = tgtlist[branchlist[i].tgt_1_ndx].CompId;
         target2 = tgtlist[branchlist[i].tgt_1_ndx].CompId;
         for(cmpcnt = 0; cmpcnt < branchlist[i].no_comps; cmpcnt++)
         {
           if(target1.objid == branchlist[i].comps[cmpcnt].objid) endbr = 1;
           if(target2.objid == branchlist[i].comps[cmpcnt].objid) endbr = 1;
           if(navoids && endbr)
           {
              cmpcnt = branchlist[i].no_comps - cmpcnt;
//            printf("branch %d is to be partially listed in forward order-%d comps\n",hits[j].branchndx,cmpcnt);
              cmpcnt = branchlist[i].no_comps;
           }
           else
           {
              (output_list+outcount)->objid = branchlist[i].comps[cmpcnt].objid;
              (output_list+outcount)->osnum = branchlist[i].comps[cmpcnt].osnum;
//            printf("%d outcount %d for %d-%d\n",i,outcount,branchlist[i].comps[cmpcnt].objid,branchlist[i].comps[cmpcnt].osnum);
              outcount++;
//            printf("outcount %d\n",outcount);
              if(endbr) cmpcnt = branchlist[i].no_comps ;
           }
         }
      }
      else
      {
//       printf("branch %d is to be listed in forward order with %d comps\n",hits[j].branchndx,branchlist[i].no_comps);
         for(cmpcnt = 0; cmpcnt < branchlist[i].no_comps; cmpcnt++)
         {
            (output_list+outcount)->objid = branchlist[i].comps[cmpcnt].objid;
            (output_list+outcount)->osnum = branchlist[i].comps[cmpcnt].osnum;
//          printf("%d outcount %d for %d-%d\n",i,outcount,branchlist[i].comps[cmpcnt].objid,branchlist[i].comps[cmpcnt].osnum);
            outcount++;
         }
      }
    }
    if(possible_stones && ss) _FREE(ss);
    if(possible_stones && hits) _FREE(hits);
  }
//  printf("total possible paths %d\n",possible);
  /********* FREE THESE ARRAYS ************/

  if(total_branches && branchlist)
  {
     int brndx;
     for(brndx = 0; brndx<total_branches; brndx++)
     {
        if(branchlist[brndx].comps)
          _FREE(branchlist[brndx].comps);
     }
     _FREE(branchlist);
  }
  if(notgts && tgtlist)
     _FREE(tgtlist);
  /**** Remove duplicate entries ****/
  /* i = prime list - j = output list */
  j = 1;
  for(i = 1; i<outcount; i++)
  {
    notinlist = 1;
    for(k = 0; k<j; k++)
    {
      if(output_list[i].objid == output_list[k].objid)
        notinlist = 0;
    }
    if(notinlist)
    {
       output_list[j].objid = output_list[i].objid;
       output_list[j].osnum = output_list[i].osnum;
//     printf("out %d is %d\n",j,output_list[j].objid);
       j++;
    }
//    else
//    {
//      printf("output_list %d had duplicate entries for %d\n",i,output_list[i].objid);
//    }
  }
  
  *outlist = output_list;
  *poutcnt = j;
//   printf("actual count in output is %d\n",j);

  return(1);
}


/********** FUNCTION vr_brch_intersect ***************************
Inputs a array of branch nodes, numberbranches, and 2 branch indexes (a,b),
 the return is a character value:

O means the branches do not intersect.
F means that b intersects a on the F(front or first) end of b.
T means that b intersects a on the T(tail or terminal) end of b.
B means that b intersects a on both ends of b.
********************************************************************/

char vr_brch_intersect(brch_array,a,b)

struct brnchrecstr *brch_array;
int a,b;

{
char code;
if(a == b) code = 'O';
else if((brch_array[a].t_grid.objid == brch_array[b].f_grid.objid) &&
        (brch_array[a].t_grid.objid == brch_array[b].t_grid.objid))
   code = 'B';

else if((brch_array[a].f_grid.objid == brch_array[b].f_grid.objid) &&
        (brch_array[a].f_grid.objid == brch_array[b].t_grid.objid))
   code = 'B';

else if((brch_array[a].f_grid.objid == brch_array[b].f_grid.objid) &&
        (brch_array[a].t_grid.objid == brch_array[b].t_grid.objid))
   code = 'B';

else if((brch_array[a].f_grid.objid == brch_array[b].t_grid.objid) &&
        (brch_array[a].t_grid.objid == brch_array[b].f_grid.objid))
   code = 'B';

else if((brch_array[a].t_grid.objid == brch_array[b].f_grid.objid) &&
        (brch_array[a].f_grid.objid == brch_array[b].t_grid.objid))
   code = 'B';

else if((brch_array[a].f_grid.objid == brch_array[b].f_grid.objid) ||
        (brch_array[a].t_grid.objid == brch_array[b].f_grid.objid))
   if(brch_array[b].f_grid.objid > 0) code = 'F';  /*** TR5100 ***/
   else code = 'O';

else if((brch_array[a].f_grid.objid == brch_array[b].t_grid.objid) ||
        (brch_array[a].t_grid.objid == brch_array[b].t_grid.objid))
   if(brch_array[b].t_grid.objid > 0) code = 'T';  /*** TR5100 ***/
   else code = 'O';

else code = 'O';

return (code); 
}
end implementation Root;
