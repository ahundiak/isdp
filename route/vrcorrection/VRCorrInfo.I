/* $Id:*/

/*************************************************************************
* I/ROUTE
*
* File:        vrcorrection / VRCorrInfo.I
*
* Description:	- Methods for direct set/get of VRCorrection me instances.
*		  GRgetattr & GRputattr are overrided from GRvg via ASnode.
*
*	    	- Propagation Methods (VRPropagateFlow) . 
*		- Correction component method (VRGetNumCptOfMyComps).
*
* Dependencies:
*
* Revision History:
*      $Log: VRCorrInfo.I,v $
*      Revision 1.2  2001/02/20 01:13:10  build
*      Replaced v_dbgmacros.h with product specific dbgmacros.h
*
*      Revision 1.1.1.1  2001/01/04 21:12:48  cvs
*      Initial import to CVS
*
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/03/17  18:22:16  pinnacle
# Replaced: vrcorrection/VRCorrInfo.I for:  by kddinov for route
#
# Revision 1.3  1998/03/08  23:17:50  pinnacle
# Replaced: vrcorrection/VRCorrInfo.I for:  by kddinov for route
#
# Revision 1.2  1997/10/20  15:28:58  pinnacle
# Replaced: vrcorrection/VRCorrInfo.I for:  by kddinov for route
#
# Revision 1.4  1997/10/01  22:15:08  pinnacle
# Replaced: vrcorrection/VRCorrInfo.I for:  by kddinov for route
#
# Revision 1.3  1997/07/02  15:52:00  pinnacle
# Replaced: vrcorrection/VRCorrInfo.I for:  by kddinov for route
#
# Revision 1.2  1997/06/24  22:32:44  pinnacle
# Replaced: vrcorrection/VRCorrInfo.I for:  by kddinov for route
#
*
* History:
*      Feb/03/97       kdd     GRgetattr
*	June/97		kdd	VRPropagateFlow
*************************************************************************/

class implementation VRCorrection;

/*
#define vdserrDEBUG 1
#define vdsDEBUG 1
*/

#include "OMerrordef.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "vrdbgmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"
#include "vrparameters.h"
#include "VRcordef.h"
#include "VRcompdef.h"

from    VRGeneric       import  VRGetCorOnCpt;
from    VRGeneric       import  VRGetNumberOfCpts;
from    VRGeneric       import  VRGetParams;
from    VRGeneric       import  VRGetStatus;
from    ACrg_collect    import  ACmod_list_attribute;

/* Macro definition */
#define GRid_equal(x,y) ((((x).objid==(y).objid)&&((x).osnum==(y).osnum))? 1:0)

/******************************************************************************/
method GRgetattr( IGRlong	*msg;
		  IGRchar	*attr) 
{
  struct VRCorrection_common *correction;

SetProc( VRCorrection.GRgetattr );Begin

  *msg = OM_S_SUCCESS;

  correction = (struct VRCorrection_common *) attr;

  switch ( correction->Iwant ) {

    case VRCorrection_FlowValue :
__DBGpr_dbl("VRCorrection.GRgetattr me->FlowValue     =", me->FlowValue);
        correction->FlowValue = me->FlowValue;
        break;

    case VRCorrection_FlowDirection :
__DBGpr_int("VRCorrection.GRgetattr me->FlowDirection =", me->FlowDirection);
	correction->FlowDirection = me->FlowDirection;
	break;
  }

End
return *msg;
}

/******************************************************************************/
/*----------------------------------------
# 2-98 KDD
* Note that by a kludgy design the flow direction and rate are instance data
* for the correction and attributes for the components. 
*---------------------------------------*/
method GRputattr( IGRlong	*msg;
		  IGRchar	*attr) 
{
  IGRdouble		Old_FlowValue;

  IGRshort		Old_FlowDirection,
			stat,
			CmpRealPos;

  IGRint		NbRoots = 0;
  IGRlong		status;

  int			i;

  struct GRid		CompId,
			SysParId,
			*buffer = NULL;

  struct ACrg_coll	Attr[2];

  struct VRCorrection_common *correction;


SetProc( VRCorrection.GRputattr );Begin

  Old_FlowValue     = me->FlowValue;
  Old_FlowDirection = me->FlowDirection;


  *msg = OM_S_SUCCESS;

  correction = (struct VRCorrection_common *) attr;

  switch ( correction->Iwant ) {

     case VRCorrection_FlowValue :
        me->FlowValue = correction->FlowValue;
#ifdef vdsDEBUG
printf("VRCorrection.GRputattr FlowValue [%d] = %f\n", my_id, me->FlowValue); 
#endif
        break;
 

    case VRCorrection_FlowDirection :
        me->FlowDirection = correction->FlowDirection;
#ifdef vdsDEBUG
printf("VRCorrection.GRputattr FlowValue [%d] = %f\n", my_id,me->FlowDirection);
#endif
/* method VRCorrection.VRUpdateFlowArrow deletes the flow arrow, if needed.  */
        break;
  }

wrapup:

End;
return *msg;
}

/******************************************************************************
* method VRPropagateFlow
*
*------------------------------------------------------------------------------
*
* Parameters:
*
* O: IGRlong            *msg            return code
*
* I: struct GRid        *FirstCorr      first correction in the infinite loop.
*                                       May be NULL, then will assume my_id.
*
* I: IGRshort           FlowDirection   flow direction to propagate
*                               The flow direction now (June 97) is defined from
*                               zeroth parent of the correction:
*                               flow_dir vector=(Coord_Par_1 - Coord_Par_0).
*
* I: IGRdouble          FlowRate        flow rate at this point (NULL, OK).
*                                       (Algorithm not implemented).
*
* I: IGRshort           *PropagatePoint   connect point to propagate from.
*
* I: struct GRid        *PropagateParent  parent to propagate from (NULL, OK).
*
* I: struct GRmd_env    *md_env           Pointer to the module environment.
*-------------------------------------------
*
* Note: Whatever the PropagatePoint, remeber that the flow direction is defined
*        as a vector from ConPt_0 to ConPt_1 (or Parent_0 to Parent_1).
*
* Note: Either PropagateParent or PropagatePoint can be specified.
*        If both are given, they must be consistent.
*        If only one is given, I will find the other one.
*------------------------------------------------------------------------------
*
* Note:	
*	- Flow Direction is ALWAYS set at connect point 0 (parent 0) of
*	  the correction. The arrow is set according to the rule:
*	  1  along the vector (parent_1 - parent_0)
*	 -1  opposite to 1 
*	  3  bidirectional symbol along the vector (parent_1 - parent_0).
*	 -3  opposite to 3. 
*
* Note:
*	Never ever even think about "goto quit;" or "return;" statements inside
*	the doby of that method. The call NDnode.NDchange_node() is vital! 
*------------------------------------------------------------------------------
*
* Assumptions:
*	- me->FlowDirection and me->FlowValue are already set by the caller.
*		Use GRputattr method. 
*	- Each correction has exactly 2 parents.
*	- Each parent is subclassed from VRComponent.
*	- Parent 0 is connected to connect point 0 of the correction. 
*	  parent 1 is connected to connect point 1 of the correction. 
*	- This method does NOT set the flow direction of the Correction Itself.
*	  The reason is that we might need to propagate from conn pt 1.
*	- The caller must ensure the correct
*	  Flow Direction in my_id at the time of calling. 
*------------------------------------------------------------------------------
*
* Algorithm:
*	- Propagation continues from the parent connected to PropagatePoint;
*	- Propagation stops at parent with number of connect points != 2, or if
*	  PropagateParent has no correction attached to its other conn point.
*------------------------------------------------------------------------------
*
* Benefits:
*	- If you link 2 networks with opposite flow directions, You need to 
*	  verify the flow direction in one of them to get the correct
*	  flow direction in the combined network. 
*
******************************************************************************/
method VRPropagateFlow( IGRlong			*msg;
			struct GRid		*FirstCorr;
			IGRshort		*FlowDirection;
			IGRdouble		*FlowRate;
			IGRshort		*PropagatePoint_In;
		        struct GRid		*PropagateParent_In;
			struct GRmd_env      	*md_env)
{
  struct GRid	ParentId[2],
		PropagateParent,
		*NextParent,
		*p_FirstCorr, dummyId,
		NextCorr;

  IGRlong	retcode, status;

  IGRshort	NextPropPoint,
		PropagatePoint,
		*p_FlowDirection = NULL,
		ParentCptIndex;

  IGRint	NbCpts, NumComp3Cpt;

  int		NbParents, i;

  struct VRCorrection_common   attr;

SetProc( VRCorrection.VRPropagateFlow );Begin

  if ( !PropagateParent_In  &&  !PropagatePoint_In ) goto wrapup; 

/*-------------------------------------
#0. 2-98 KDD Initialize FirstCorr.
*------------------------------------*/
  if (FirstCorr && (FirstCorr->objid != NULL_OBJID)) p_FirstCorr = FirstCorr;
  else {
	dummyId.objid = my_id;
	dummyId.osnum = OM_Gw_current_OS;

	p_FirstCorr = &dummyId;
  }


/*------------------------------------------ 
#1. get the correct PropagateParent and PropagatePoint 
*-----------------------------------------*/

  if ( PropagateParent_In ) {

     PropagateParent.objid = PropagateParent_In->objid;
     PropagateParent.osnum = PropagateParent_In->osnum;

     if ( !PropagatePoint_In ) { 
        status = om$send( msg = message NDnode.NDget_objects( ND_ROOT, ParentId,
                                2, NULL, 0, OM_K_MAXINT, &NbParents),
                     targetid = my_id );
        if ( NbParents != 2 ) goto error;

        if ( (PropagateParent.objid == ParentId[0].objid) && 
	     (PropagateParent.osnum == ParentId[0].osnum) )  PropagatePoint = 0;
        else  PropagatePoint = 1;   
     }
     else {
	PropagatePoint = *PropagatePoint_In;
     }
  }
  else {
     PropagatePoint = *PropagatePoint_In;
     if ( (PropagatePoint > 1) || (PropagatePoint < 0 ) ) goto wrapup; 

     status = om$send( msg = message NDnode.NDget_objects( ND_ROOT, ParentId,
                             2, NULL, 0, OM_K_MAXINT, &NbParents),
                  targetid = my_id );
     if ( NbParents != 2 ) goto error;

     PropagateParent.objid = ParentId[ PropagatePoint ].objid;
     PropagateParent.osnum = ParentId[ PropagatePoint ].osnum;
  }


/*------------------------------------------
#1.1 PropagateParent MUST have exactly 2 connect points.We came from one of them
*-----------------------------------------*/
  status = om$send( msg      = message VRGeneric.VRGetNumberOfCpts
                                        ( &retcode, &NbCpts, md_env ),
                    targetid = PropagateParent.objid,
                    targetos = PropagateParent.osnum );
  if ( !(status & 1) || (NbCpts != 2) ) { goto wrapup; }

__DBGpr_obj("PropagateParent  ", PropagateParent);
__DBGpr_int("PropagatePoint   ", PropagatePoint);


		/* Ready to propagate   */

/*------------------------------------------ 
#2. Get the connect point index of my ParentId[0] 
*-----------------------------------------*/ 
  status = om$send( msg  = message VRCorrection.VRGetCptIndex( &retcode, 
					&PropagateParent, &ParentCptIndex),
                targetid = my_id );
__DBGpr_int("ParentCptIndex   ", ParentCptIndex);


/*------------------------------------------ 
#3. get the correction at my Parent's other connect point. 
*-----------------------------------------*/ 
  status = om$send( msg  = message VRGeneric.VRGetCorOnCpt ( &retcode, 
				(IGRshort) (ParentCptIndex == 0)? 1 : 0, 
				&NextCorr, md_env ),
		targetid = PropagateParent.objid,
		targetos = PropagateParent.osnum); 

  if ( (NextCorr.objid == NULL_OBJID) || !(status&1)) { goto wrapup; }

/*--------------------- Avoid infinite loops --------------------*/
  if ( GRid_equal( NextCorr, *p_FirstCorr) ) goto wrapup;


__DBGpr_obj("NextCorr         ", NextCorr);

/*------------------------------------------
#3.1. Stop propagation if any of my components has 3+ connect points.
*-----------------------------------------*/
  status = om$send( msg  = message VRCorrection.VRGetNumCptOfMyComps( &retcode, 
			     NULL, NULL, &NumComp3Cpt, NULL, NULL,NULL, md_env),
                targetid = NextCorr.objid,  
                targetos = NextCorr.osnum );
  if ( NumComp3Cpt != 0 ) goto wrapup;

  status = om$send( msg  = message NDnode.NDget_objects( ND_ROOT, ParentId,
                                2, NULL, 0, OM_K_MAXINT, &NbParents),
                targetid = NextCorr.objid,  
                targetos = NextCorr.osnum );
  if ( NbParents != 2 ) goto error;

  if ( (ParentId[0].objid == PropagateParent.objid) && 
       (ParentId[0].osnum == PropagateParent.osnum) ) {

	NextPropPoint = (IGRshort) 1;
	NextParent = &ParentId[1];
  }
  else  {
	NextPropPoint = (IGRshort) 0; 
	NextParent = &ParentId[0];
  }


/*------------------------------------------ 
#4.  Find the Flow Direction to propagate in NextCorr. 
*
*  This picture shows why we need to flip the sign of the flow symbol when
*  PropagatePoint != NextPropPoint
*
*          PropagatePoint = 0                             NextPropPoint   = 1
*         |------------------|     |---------------|     |-------------------|
*         |1 me->correction 0|     |x  component  x|     |0 Next correction 1|
*         |------------------|     |---------------|     |-------------------|
*				    PropagateParent
*-----------------------------------------*/
  if ( FlowDirection ) { 
     attr.Iwant = VRCorrection_FlowDirection;

     if (PropagatePoint == NextPropPoint) attr.FlowDirection = *FlowDirection;
     else                                 attr.FlowDirection = - *FlowDirection;

     status = om$send ( msg = message VRCorrection.GRputattr
  	                               (&retcode, (IGRchar *) &attr),
                   targetid = NextCorr.objid,
                   targetos = NextCorr.osnum );

     p_FlowDirection = &attr.FlowDirection;
  }


/*------------------------------------------
#4.1. Set flow rate in NextCorr
  if ( FlowRate ) {
     attr.Iwant     = VRCorrection_FlowValue;
     attr.FlowValue = *FlowRate; 
 
     status = om$send ( msg = message VRCorrection.GRputattr
                                       (&retcode, (IGRchar *) &attr),
                   targetid = NextCorr.objid,
                   targetos = NextCorr.osnum );
  }
*-----------------------------------------*/

/*-----------------------------
# 3-98 KDD.
# DIRTY update of the dependent components.
*----------------------------*/
  status = om$send( msg      = message VRCorrection.VRSetFlow( &retcode,
                                        NULL, FlowRate, md_env),
                    targetid = NextCorr.objid,
                    targetos = NextCorr.osnum );


__DBGpr_obj("NextParent       ", *NextParent);
__DBGpr_int("NextPropPoint    ", NextPropPoint);
if (p_FlowDirection) __DBGpr_int("NextFlowDirection", (int) *p_FlowDirection);
if (FlowRate)        __DBGpr_dbl("NextFlowRate     ", *FlowRate);

/*-----------------------------------------
#5. Loop over NextCorr.
*----------------------------------------*/
  status = om$send( msg = message VRCorrection.VRPropagateFlow
				(&retcode, p_FirstCorr, p_FlowDirection, 
				 FlowRate, &NextPropPoint, NextParent, md_env),
                targetid = NextCorr.objid,
                targetos = NextCorr.osnum );

  goto wrapup; 

error:
  printf("Correction [%d] has %d parents. Must be 2!\n", my_id, NbParents);
  for (i=0; i < NbParents; i++ )
         printf("Parent %d = [%d]\n", i, ParentId[i].objid);

  status = 0;


wrapup:
        /* -- Notify dependancies to recompute -- */
        status = om$send(    msg = message NDnode.NDchange_node ( md_env ),
                        targetid = PropagateParent.objid,
                        targetos = PropagateParent.osnum );

End; 
  *msg = status;
  return status;
}


/******************************************************************************
* method VRGetNumCptOfMyComps
*
*------------------------------------------------------------------------------
* Description:	This method gets the number of connect points for my components.
*		It sorts them in three groups:
*		- components with 1 connect point;
*		- components with 2 connect points;
*		- components with 3+ connect points;
*------------------------------------------------------------------------------
*
* Parameters:
*
* (O) IGRlong           *msg            return code (always == status).
*
* (O) IGRint            *NumComp1Cpt    If !NULL will have the number of
*                                       components with 1 connect point.
*
* (O) IGRint            *NumComp2Cpt    If !NULL will have the number of
*                                       components with 2 connect points.
*
* (O) IGRint            *NumComp3Cpt    If !NULL will have the number of
*                                       components with 3 or more connect points
*
* (O) struct GRid       *LstComp1Cpt    If !NULL contains list with the ID of my
*                                       components with 1 conect point.
*                                       The list is terminated by
*                                       LstComp1Cpt->objid = NULL_OBJID.
*
* (O) struct GRid       *LstComp2Cpt    If !NULL contains list with the ID of my
*                                       components with 2 conect points.
*                                       The list is terminated by
*                                       LstComp2Cpt->objid = NULL_OBJID.
*
* (O) struct GRid       *LstComp3Cpt    If !NULL contains list with the ID of my
*                                       components with 3+ conect points.
*                                       The list is terminated by
*                                       LstComp3Cpt->objid = NULL_OBJID.
*
* (I) struct GRmd_env   *md_env         module environment.
*------------------------------------------------------------------------------
*
*  Note: Caller MUST provide space for LstComp1Cpt, LstComp2Cpt and LstComp3Cpt.
*        If You have allocated memory for 3 entries in LstComp3Cpt, make sure
*        (LstComp3Cpt +3) = NULL, this will stop me loading the list. 
*------------------------------------------------------------------------------
*
* Return status:
*
* OM_S_SUCCESS	always. 
*
******************************************************************************/
method VRGetNumCptOfMyComps(IGRlong             *msg;
                            IGRint		*NumComp1Cpt;
                            IGRint		*NumComp2Cpt;
                            IGRint		*NumComp3Cpt;
                            struct GRid 	*LstComp1Cpt;
                            struct GRid 	*LstComp2Cpt;
                            struct GRid 	*LstComp3Cpt;
                            struct GRmd_env	*md_env)
{
	IGRlong		status, retcode; 
	IGRint		NumConPts; 
	IGRshort	CmpRealPos;
	struct GRid	CorrCmpId;
	int		i;

SetProc( VRCorrection.VRGetNumCptOfMyComps );Begin

/*
#0. Initialize 
*/
  if (NumComp1Cpt) *NumComp1Cpt = 0; 
  if (NumComp2Cpt) *NumComp2Cpt = 0; 
  if (NumComp3Cpt) *NumComp3Cpt = 0; 

  status = OM_S_SUCCESS;

/*
#1. Find the components 
*/

  for ( i = 0; i < me->my_NbCorCmp; i++ ) {
     CmpRealPos = (me->my_StrCmpList[i]).CmpRealPos; 

     status = om$send( msg = message VRCorrection.VRGetCorCmpId( &retcode, 
					NULL, CmpRealPos, -1, NULL, &CorrCmpId),
                  targetid = my_id);

     status = om$send( msg = message VRGeneric.VRGetNumberOfCpts
						(&retcode, &NumConPts, md_env),
		       targetid = CorrCmpId.objid,
		       targetos = CorrCmpId.osnum); 

     if (NumConPts <= 0) continue; 

     switch (NumConPts) {

	case 1:
		if ( NumComp1Cpt ) (*NumComp1Cpt)++;
		if ( LstComp1Cpt) {
			LstComp1Cpt->objid = CorrCmpId.objid; 
			LstComp1Cpt->osnum = CorrCmpId.osnum; 
			LstComp1Cpt++;
		}
		break;

	case 2:
                if ( NumComp2Cpt ) (*NumComp2Cpt)++;
                if ( LstComp2Cpt) {
                        LstComp2Cpt->objid = CorrCmpId.objid;
                        LstComp2Cpt->osnum = CorrCmpId.osnum;
                        LstComp2Cpt++;
                }
		break; 

	default:
	case 3:
		if ( NumComp3Cpt ) (*NumComp3Cpt)++; 
		if ( LstComp3Cpt) {
			LstComp3Cpt->objid = CorrCmpId.objid; 
			LstComp3Cpt->osnum = CorrCmpId.osnum; 
			LstComp3Cpt++;
		}
		break;
     }
  }

  if (LstComp1Cpt) LstComp1Cpt->objid = NULL_OBJID; 
  if (LstComp2Cpt) LstComp2Cpt->objid = NULL_OBJID; 
  if (LstComp3Cpt) LstComp3Cpt->objid = NULL_OBJID; 

End;
status = OM_S_SUCCESS;
*msg = status; 
return (status);
}









end implementation VRCorrection;









