/* $Id: VRCompInfo.I,v 1.4 2002/03/19 23:24:36 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcomponent / VRCompInfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCompInfo.I,v $
 *	Revision 1.4  2002/03/19 23:24:36  louis
 *	TR5982 - bendsweep corrections
 *	
 *	Revision 1.3  2001/02/20 01:12:36  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 15:37:55  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/23  17:25:06  pinnacle
# Created: route/vrcomponent/VRCompInfo.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/02/18  19:56:42  pinnacle
# Replaced: vrcomponent/VRCompInfo.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.7  1996/06/06  17:43:10  pinnacle
# Replaced: vrcomponent/VRCompInfo.I for:  by r240_int for route240
#
# Revision 1.6  1996/01/16  21:47:12  pinnacle
# Replaced: vrcomponent/VRCompInfo.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
     	1-17-95		Mallik 	TR # 179524361. Modified method VRGetCode.
				If the CompCode is already in the instance 
				then there is no need to access the database.
				This assumes that the auto component codes 
				do not get modified.
 *
 *	01/16/96  	tlb	Add prototypes
 *      03/19/02   law &AdZ     TR5982-bendsweep overhaul for EL45 legacy
 *                              and static attributes
 *
 *************************************************************************/
class implementation VRComponent;

#include <math.h>
#include <stdio.h>
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "bserr.h"
#include "asbox.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VRcompdef.h"
#include "VRparamdef.h"
#include "bsvalues.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsroto.h"
#include "vrdbgmacros.h"

#define AS_DEBUG	1
/*
#define MY_DEBUG	1
*/

from VRProduct 		import 	VRRetrieveTeeCode,
				VRRetrieveElbowCode,
				VRRetrieveGeneralCode;
from VRCnrlSeg		import	VRGetTopo;
from VRCorrection	import 	VRGetMatrix,
				VRGetPipeCpts,
				VRGetCmpNeighbor,
				VRGetDynCpts,
				VRGetHangers;

  extern GRclassid OPP_VRCnrlSeg_class_id;
/***********************************************************************/

method VRGetOrientationDef ( 	IGRlong *msg ; 	struct GRid *PrimaryId;
						IGRshort    *nPosOnPri;
						IGRdouble   *dPrimary;
						struct GRid *SecondaryId;
						IGRshort    *nPosOnSec;
						IGRdouble   *dSecondary)
{
  IGRint     status;
  IGRlong    retmsg;

SetProc( VRComponent_VRGetOrientationDef ); Begin

*msg = MSSUCC;

	/*" ---- %s ----\n",me->szAABBCC */

	/* ------------------------- */
	/* -- Primary information -- */
	/* ------------------------- */

	if (PrimaryId) 
	{
		if ( me->Orientation.nPriIndex > 0 )
		{
			/*" Get Primary segment at index %d\n", me->Orientation.nPriIndex */
			om$get_objid_at_index (object	= me,
					   p_chanselect = &ND_father,
					   index 	= me->Orientation.nPriIndex,
					   objidaddr    = &PrimaryId->objid,
					   osnumaddr    = &PrimaryId->osnum);
		}
		else
		{
			/*| No Primary defined */
			PrimaryId->objid = NULL_OBJID;
		}

		/*" Primary Segmentid = <%d,%d>\n",PrimaryId->objid,PrimaryId->osnum*/
	}/* end return primary Id */

	if (nPosOnPri)
	{
		if ( me->Orientation.nPriIndex > 0 )
		{
                   IGRshort    ii,jj;
		   ii = me->Orientation.nPriIndex- me->nNbAttr;

                   status =
                   om$send (msg = message VRComponent.VRGetMEIX
                                                     (&retmsg, ii, &jj),
                       targetid = my_id);
                                           
		   *nPosOnPri = jj;
		}
		else
		{
			/*| No Primary defined */
		   *nPosOnPri = -1;
		}
		/*" Position %d on Primary\n", *nPosOnPri */

	}/* end return Position on primary */

	if (dPrimary)
	{
		*dPrimary = me->Orientation.dPrimary;
		/*" Orientation %f on Primary\n", *dPrimary */

	}/* end return Orientation on primary */

	/* --------------------------- */
	/* -- Secondary information -- */
	/* --------------------------- */

	if (SecondaryId) 
	{
		if ( me->Orientation.nSecIndex > 0 )
		{
			/*" Get Secondary segment at index %d\n", me->Orientation.nSecIndex */
			om$get_objid_at_index (object	= me,
					   p_chanselect = &ND_father,
					   index 	= me->Orientation.nSecIndex,
					   objidaddr    = &SecondaryId->objid,
					   osnumaddr    = &SecondaryId->osnum);
		}
		else
		{
			/*| No Secondary defined */
			SecondaryId->objid = NULL_OBJID;
		}
		/*" Secondary Segmentid = <%d,%d>\n",SecondaryId->objid,SecondaryId->osnum*/

	}/* end return Secondary Id */

	if (nPosOnSec)
	{
		if ( me->Orientation.nSecIndex > 0 )
		{
                   IGRshort    ii,jj;
                   ii = me->Orientation.nSecIndex- me->nNbAttr;

                   status =
                   om$send (msg = message VRComponent.VRGetMEIX
                                                     (&retmsg, ii, &jj),
                       targetid = my_id);

		   *nPosOnSec = jj;
		}
		else
		{
			/*| No Secondary defined */
			*nPosOnSec = -1;
		}
		/*" Position %d on Secondary\n", *nPosOnSec */

	}/* end return Position on Secondary */

	if (dSecondary)
	{
		*dSecondary = me->Orientation.dSecondary;
		/*" Orientation %f on Secondary\n", *dSecondary */

	}/* end return Orientation on Secondary */

        End
	return OM_S_SUCCESS;
}/* end VRGetOrientationDef */

/***********************************************************************/

method VRGetMatrix ( 	IGRlong *msg; IGRint NbTemp; struct GRid *TempList;
			IGRdouble *dRefMatrix;  struct GRmd_env *md_env)

{
IGRint		status, i;
IGRlong		retmsg;
struct GRid	SegId;
IGRboolean	bBooleanVar=TRUE,bPrimary,bSecondary;
IGRdouble	dPrimary [3], dSecondary [3], dTransformed [3];
IGRdouble	dPointO [3], dPointT [3], dOrg [3];   
IGRdouble	dVecteurO [3], dVecteurT [3];   
struct IGRplane	Ortho,Terminal;
BSrc		rc;

SetProc( VRComponent_VRGetMatrix ); Begin
	/*" ---- %s ----\n",me->szAABBCC */
	/*" Item   = %d\n",me->Desc.nItemNum*/

*msg = MSSUCC;

	/* ---------------------------------------- */
	/* -- Treatment of Correction components -- */
	/* ---------------------------------------- */

if ( me->Status & VR_CORRECTION )
{
	struct GRid MyId;
/*
        IGRdouble   ddCoord[6];
*/

	/* -- Get Matrix from Correction entity -- */
	/*| Correction treatment */


	MyId.objid 	   = my_id;
	MyId.osnum 	   = OM_Gw_current_OS;

	status = 
	om$send ( msg = message VRCorrection.VRGetMatrix
				( &retmsg, &MyId, dRefMatrix, md_env ),
		p_chanselect= &AS_to_owner,
		from	    = 0,
		to	    = 0);
	as$status ( action = RET_STATUS );

        /*  for posting purposes replace orig coords with COG   */
        /*  Re:   TR # 27758                                    */

/*  backed out...........................................................
        status = 
        om$send (msg = message VRCorrection.VRGetPipeCpts
                                         (&retmsg, md_env, ddCoord),
	 p_chanselect= &AS_to_owner,
	 from	     = 0,
	 to	     = 0);

        dRefMatrix[3]  = (ddCoord[0] + ddCoord[3]) / 2.0;
        dRefMatrix[7]  = (ddCoord[1] + ddCoord[4]) / 2.0;
        dRefMatrix[11] = (ddCoord[2] + ddCoord[5]) / 2.0;

    ...................................................................... */
        End
	return OM_S_SUCCESS;
}


	/* ------------------------------------- */
	/* -- Treatment of general components -- */
	/* ------------------------------------- */

/*" Orientation Primary   : Seg at Index %d\n", me->Orientation.nPriIndex*/
/*" Orientation Primary   : %f\n",              me->Orientation.dPrimary*/
/*" Orientation Secondary : Seg at Index %d\n", me->Orientation.nSecIndex*/
/*" Orientation Secondary : %f\n",              me->Orientation.dSecondary*/

bPrimary 	= ( me->Orientation.nPriIndex >= 0 );
bSecondary 	= ( me->Orientation.nSecIndex >= 0 );

if ((!bPrimary && !bSecondary) || !me->nNbTopo)
{
	/* ----- Topo not found call super_class ----- */
	status =
	om$send ( msg = message VRGeneric.VRGetMatrix(
					msg,
					NbTemp,
					TempList,
					dRefMatrix,
					md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
        End		
	return status;

}/* end get matrix without topology */

Ortho.point = dPointO;
Ortho.normal = dVecteurO;
Terminal.point = dPointT;
Terminal.normal = dVecteurT;
dOrg [0] = dOrg [1] = dOrg [2] = 0;

if ( bPrimary )
{
  IGRshort    ii,jj;

	/* ------------------------------------ */
	/* -- Get Primary axis from template -- */
	/* ------------------------------------ */


	/* -- get segment id for primary axis -- */
	if ( TempList )
	    {
	    /*| Get Primary Segment from list */
	    SegId = TempList[me->Orientation.nPriIndex];
	    }
	else
	    {
	    /*| Get Primary Segment from channel */

	    om$get_objid_at_index (object	= me,
				   p_chanselect = &ND_father,
				   index 	= me->Orientation.nPriIndex,
				   objidaddr    = &SegId.objid,
				   osnumaddr    = &SegId.osnum);
	    }

	/*" Primary Segmentid = <%d,%d>\n",SegId.objid,SegId.osnum*/

	/* -- get primary segment's topology -- */
	/*°if both axis are specified in the templates => no needs for the
	   ortho plane */
#ifdef MY_DEBUG
        printf (" ---- TO GETTOPO 1-\n");
#endif
        ii = me->Orientation.nPriIndex- me->nNbAttr;

        status =
        om$send (msg = message VRComponent.VRGetMEIX (&retmsg, ii, &jj),
            targetid = my_id);
                                           
	status =
	om$send ( msg = message VRCnrlSeg.VRGetTopo
		( &retmsg,dPrimary,NULL,
		( bSecondary )?				 NULL      : &Ortho,
		(jj) ? NULL      : &Terminal,
		(jj)? &Terminal : NULL,
		md_env ),
	targetid = SegId.objid,
	targetos = SegId.osnum );
#ifdef MY_DEBUG
        printf (" ---- FROM GETTOPO 1-\n");
#endif
	as$status ( action = RET_STATUS );

	/* -- Primary axis = (Vsegment * relative orientation) -- */
	dPrimary [0] *= me->Orientation.dPrimary;
	dPrimary [1] *= me->Orientation.dPrimary;
	dPrimary [2] *= me->Orientation.dPrimary;

}/* end get specified Primary axis */

if ( bSecondary )
{
  IGRshort    ii,jj;

	/* -------------------------------------- */
	/* -- Get Secondary axis from template -- */
	/* -------------------------------------- */

	/* -- get segment id for secondary axis -- */
	if ( TempList )
	    {
	    /*| Get Secondary Segment from list */
	    SegId = TempList[me->Orientation.nSecIndex];
	    }
	else
	    {
	    /*| Get Secondary Segment from channel */

	    om$get_objid_at_index (object	= me,
				   p_chanselect = &ND_father,
				   index 	= me->Orientation.nSecIndex,
				   objidaddr    = &SegId.objid,
				   osnumaddr    = &SegId.osnum);
	    }
	/*" Secondary Segmentid = <%d,%d>\n",SegId.objid,SegId.osnum*/

	/* -- get secondary segment's topology -- */

#ifdef MY_DEBUG
        printf (" ---- TO GETTOPO 2-\n");
#endif
        ii = me->Orientation.nSecIndex- me->nNbAttr;

        status =
        om$send (msg = message VRComponent.VRGetMEIX (&retmsg, ii, &jj),
            targetid = my_id);
                                           
	status =
	om$send ( msg = message VRCnrlSeg.VRGetTopo
		( &retmsg,dSecondary,NULL,
		( bPrimary )?				 NULL      : &Ortho,
		(jj)? NULL      : &Terminal,
		(jj)? &Terminal : NULL,
		md_env ),
	targetid = SegId.objid,
	targetos = SegId.osnum );
#ifdef MY_DEBUG
        printf (" ---- FROM GETTOPO 2-\n");
#endif
	as$status ( action = RET_STATUS );

	/* -- Secondary axis = (Vsegment * relative orientation) -- */
	dSecondary [0] *= me->Orientation.dSecondary;
	dSecondary [1] *= me->Orientation.dSecondary;
	dSecondary [2] *= me->Orientation.dSecondary;


 }/* end get specified Secondary axis */

	/* -------------------------- */
	/* -- Compute missing axis -- */
	/* -------------------------- */

if (!bPrimary)
{
	/*| Compute Primary Axis */

	/* -- Primary axis = Northo of Secondary segment -- */
	for (i=0;i<3;i++)
	    dPrimary [i] = Ortho.normal[i];

	/* -- Rotate round Y axis -- */
	BSroto ( &rc,dOrg,dSecondary,&bBooleanVar,
		 &me->Orientation.dPrimary,dPrimary,dPrimary );
		if ( rc != BSSUCC )
		{/*| ERROR -> Primary axis not ROTATED */
#ifdef	MY_DEBUG
   		 printf( "1rc %x\n", rc );
#endif
                 End
		 return ( OM_E_ABORT );}
}/* end compute Primary */

if ( ! bSecondary )
{
	/*| Compute Secondary Axis */

	/* -- Secondary axis = Northo of primary segment -- */
	for (i=0;i<3;i++)
	    dSecondary [i] = Ortho.normal[i];

	/* -- Rotate round Y axis -- */
	BSroto ( &rc,dOrg,dPrimary,&bBooleanVar,
		 &me->Orientation.dSecondary,dSecondary,dSecondary );
		if ( rc != BSSUCC )
		{/*| ERROR -> Secondary axis not ROTATED */
#ifdef	MY_DEBUG
   		 printf( "2rc %x\n", rc );
#endif
                 End
		 return ( OM_E_ABORT );}
}/* end compute Secondary */

/*" Primary   : %f ,%f ,%f\n",dPrimary[0],dPrimary[1],dPrimary[2]*/
/*" Secondary : %f ,%f ,%f\n",dSecondary[0],dSecondary[1],dSecondary[2]*/

/* ------------------ */
/* -- Build Z axis -- */
/* ------------------ */

/* -- Z axis = Primary ^ Secondary -- */
BScrossp (&rc,  dPrimary, dSecondary, dTransformed);
	if ( rc != BSSUCC )
	{/*| ERROR ->  Last axis not COMPUTED */
#ifdef	MY_DEBUG
   		 printf( "3rc %x\n", rc );
#endif
        End
	return ( OM_E_ABORT );}
BSnorvec ( &rc,dTransformed );
	if ( rc != BSSUCC )
	{/*| ERROR ->  Last axis not NORMED */
#ifdef	MY_DEBUG
   		 printf( "4rc %x\n", rc );
#endif
         End
	 return ( OM_E_ABORT );}

if ( !bPrimary && bSecondary )
{
	IGRdouble		dAngle;
	IGRint			Index=-1;
	struct ret_struct	AttrSt;

	/*| Only secondary */
	/* -- Get Bend sweep value -- */

	status =
	om$send (msg = message VRComponent.ACgive_structure
				( (IGRint *) &retmsg, &Index,
				 VR_N_BEND_ANG_DB, &AttrSt, md_env ),
				targetid = my_id );
	if ( ! ( status & 1 & retmsg ) ) dAngle = 0.0;
	else				 dAngle =  90.0 - AttrSt.var.root_pm_st.value;

	/*" Bend angle =%lf\n",dAngle*/ 

	/* convert angle to radians */
	dAngle = dAngle /180.0 * M_PI;

	/* -- Rotate the X and Y axis around the Z axis by (90 - Bend_Sweep) -- */

	BSroto ( &rc,dOrg,dTransformed,&bBooleanVar,
		 &dAngle,dPrimary,dPrimary );
		if ( rc != BSSUCC )
		{/*| ERROR -> Y axis not ROTATED */}

	BSroto ( &rc,dOrg,dTransformed,&bBooleanVar,
		 &dAngle,dSecondary,dSecondary );
		if ( rc != BSSUCC )
		{/*| ERROR -> Y axis not ROTATED */}

}/* end rotate with bend sweep */

/* -- Orthogonalise computed axis -- */

if ( bPrimary )
{
	/*| Orthogonalise Secondary axis */

	BScrossp (&rc, dTransformed, dPrimary, dSecondary);
		if ( rc != BSSUCC )
		{/*| ERROR secondary axis not orthogonalise */}
	BSnorvec ( &rc,dSecondary );
		if ( rc != BSSUCC )
		{/*| ERROR ->  Secondary axis not NORMED */
   		 printf( "5rc %x\n", rc );
                 End
		 return ( OM_E_ABORT );}
/*" Ortho Secondary : %f ,%f ,%f\n",dSecondary[0],dSecondary[1],dSecondary[2]*/
}
else if ( bSecondary)
{
	/*| Orthogonalise Primary axis */

	BScrossp (&rc, dSecondary, dTransformed, dPrimary);
		if ( rc != BSSUCC )
		{/*| ERROR Primary axis not orthogonalise */}
	BSnorvec ( &rc,dPrimary );
		if ( rc != BSSUCC )
		{/*| ERROR ->  Primary axis not NORMED */
   		 printf( "6rc %x\n", rc );
                 End
		 return ( OM_E_ABORT );}
/*" Ortho Primary   : %f ,%f ,%f\n",dPrimary[0],dPrimary[1],dPrimary[2]*/
}

	/* -------------------- */
	/* -- Fill in matrix -- */
	/* -------------------- */

__DBGpr_vec("Primary X",dPrimary);
__DBGpr_vec("Secondary Y",dSecondary);
__DBGpr_vec("Transformed Z",dTransformed);
for (i=0;i<3;i++)
	{
	dRefMatrix [i*4] = dPrimary [i];
	dRefMatrix [i*4 + 1] = dSecondary [i];
	dRefMatrix [i*4 + 2] = dTransformed [i];
	dRefMatrix [i*4 + 3] = Terminal.point [i];
	}

/* -- Fill in Perspective and homothety -- */
dRefMatrix [12] = dRefMatrix [13] = dRefMatrix [14] = 0;
dRefMatrix [15] = 1;

End
return ( OM_S_SUCCESS );

}/* end VRGetMatrix */

/***********************************************************************/


method VRGetSysType ( IGRlong *msg; IGRshort *nSysType )
{
/* SetProc( VRComponent_VRGetSysType ); Begin  */
*msg = MSSUCC;

	/*" ---- %s ----\n",me->szAABBCC */

	/*" Item   = %d\n",me->Desc.nItemNum*/

	*nSysType = me->Desc.nItemNum;

if ( !me->Desc.nItemNum )
{
	/* Define, from topology, what the type is */

	if (me->Orientation.nPriIndex > 0 &&
	    me->Orientation.nSecIndex > 0    )
	{

		if (me->nNbCpts == 2)
		{
			/*| 2 Cpts --> Elbow */
			*nSysType = VR_ELBOW;
		}/* end 2 cpts */
		else
		if (me->nNbCpts == 3)
		{
			/*| 3 Cpts --> Branch */
			*nSysType = VR_TEE;
		}/* end 3 cpts */

	}/* end complex topology */

}/* end set type from topology */

/* End  */
return ( OM_S_SUCCESS );

}/* end VRGetSysType */

/***********************************************************************/


method VRGetCode ( IGRlong *msg; IGRchar *szAABBCC )
{
IGRlong retmsg;
IGRint status, NbBytes, SizeOfEnv;
IGRint			Index=-1;
struct ret_struct	AttrSt;
struct GRmd_env	local_env, *md_env;

/* SetProc( VRComponent_VRGetCode ); Begin  */
/*| Get the current module info */

SizeOfEnv = sizeof( struct GRmd_env );
gr$get_module_env( msg    = &retmsg,
		sizbuf = &SizeOfEnv,
		buffer = &local_env,
		nret   = &NbBytes );

if (retmsg != MSSUCC)	md_env = (struct GRmd_env *) NULL;
else			md_env = &local_env;

/* If the Component Code is already in the Instance then don't look up the */
/* Database.								   */

if ( me->szAABBCC[0] != '\0' )
{
        *msg = MSSUCC;
        strcpy ( szAABBCC, me->szAABBCC );
/*        End  */
	return OM_S_SUCCESS;
}/* end keep previous code */


if (	me->Desc.nItemNum != 0 &&
	!(me->Status & VR_FORCED) )
{
	/*| Automatic component : search code in tables */

	switch (me->Desc.nItemNum)
	{

case VR_DANGLING: /*| Dangling Item */
	/* aabbcc code already set */
	strcpy ( szAABBCC, VR_DANGLING_NAME );
	/* set return codes */
	status = OM_S_SUCCESS; retmsg = MSSUCC;
	break;

case VR_ELBOW : /*| Elbow Item */
	/* access bend tables */

	/* -- Get angle from topo -- */
	status =
	om$send (msg = message VRComponent.ACgive_structure
				( (IGRint *) &retmsg, &Index,
				 VR_N_BEND_ANG_DB, &AttrSt, md_env ),
				targetid = my_id );
	as$status ( action = RET_STATUS );

	/*"dAngle computed between axis=%lf\n",AttrSt.var.root_pm_st.value*/ 

	status =
	om$send (msg = message VRProduct.VRRetrieveElbowCode (
			&retmsg, AttrSt.var.root_pm_st.value, &me->nOption,szAABBCC, md_env),
		targetid = my_id );
	break;

case VR_TEE : /*| Tee Item */
	/* access branch tables */

	/* -- Get angle from topo -- */
	status =
	om$send (msg = message VRComponent.ACgive_structure
				( (IGRint *) &retmsg, &Index,
				 VR_N_BEND_ANG_DB, &AttrSt, md_env ),
				targetid = my_id );
	as$status ( action = RET_STATUS );

	/*"dAngle computed between axis=%lf\n",AttrSt.var.root_pm_st.value*/ 

	status =
	om$send (msg = message VRProduct.VRRetrieveTeeCode (
			&retmsg, AttrSt.var.root_pm_st.value, szAABBCC, md_env),
		targetid = my_id );
	break;

case VR_PIPE:
case VR_REDUCER:
case VR_FLGE_COMP:
default :	/*| Other Items */ 
	status =
	om$send (msg = message VRProduct.VRRetrieveGeneralCode (
			&retmsg, me->Desc.nItemNum,szAABBCC, md_env),
		targetid = my_id );

	} /* end switch */

	if ( !(status&1) || (retmsg!=MSSUCC) )
	{
		if ( me->szAABBCC[0] != '\0' )
		{
			/*| ERROR --> Code not found in tables but alreday set */
			*msg = MSSUCC;
			strcpy ( szAABBCC, me->szAABBCC );
		}/* end keep previous code */
		else
		{
			/*| ERROR --> Code not found in tables */
			*msg = MSFAIL;
			szAABBCC[0] = '\0';
		}/* end keep previous code */
		
	}/* End Error treatment */
	else
	{
		*msg = MSSUCC;
		/* -- Save new code in instances -- */
		strcpy ( me->szAABBCC, szAABBCC );
	}
	
} /* end automatic component's AABBCC search */
else
{
	/* Return the stored AABBCC code */
	*msg = MSSUCC;
	strcpy ( szAABBCC, me->szAABBCC );
}


/*" Component aabbcc code = %s\n",me->szAABBCC*/
/*" Returned  aabbcc code = %s\n",szAABBCC*/

/*  End  */
return ( OM_S_SUCCESS );

}/* end VRGetCode */

/***********************************************************************/


method VRGetIndex ( IGRlong *msg; struct GRid *SegmentId; IGRshort *CompIndex)

{
  IGRint       status;
  IGRuint      Temp;
  IGRshort    TempIndex;

  SetProc( VRComponent_VRGetIndex ); Begin
  *msg = MSSUCC;

  /* -- get specifeid template index -- */

  status = 
  om$get_index (object_c   = me,
             p_chanselect  = &ND_father,
                  objid    = SegmentId->objid,
                indexaddr  = &Temp  );
  as$status ( action = RET_STATUS );

  TempIndex = Temp - me->nNbAttr;;

  /*" Index [%d] in index list\n",TempIndex*/

  if ( TempIndex >=0 && TempIndex < me->nNbTopo )
  {
    /* -- get index on segment from my list of indexes -- */

    status =
    om$send (msg = message VRComponent.VRGetMEIX (msg, TempIndex, CompIndex),
        targetid = my_id);
  }
  else
  {
    /*" ERROR -> Segment index >  (My NbTopo = %d)\n",me->nNbTopo */
    *msg = MSFAIL;
    *CompIndex = -1;
  }

  End
  return ( OM_S_SUCCESS );
}/* end VRGetIndex */

/***********************************************************************/

method VRGetAngle (   IGRlong *msg; IGRdouble *dAngle;
			 struct GRmd_env *md_env)

{
IGRint			status;
struct GRid		SegId;
IGRlong			retmsg, retcode;
IGRdouble		dPrimary [3], dSecondary [3], dTransformed [3];
IGRdouble		dTmpAngle ;
BSrc			rc;
IGRshort                nIX, nVIX, cmp_systype;
GRclassid               classId;


extern IGRdouble VRcompute_angle();
SetProc( VRComponent_VRGetAngle ); Begin

*msg = MSSUCC;
#ifdef MY_DEBUG
printf(" Orientation Primary   : Seg at Index %d\n", me->Orientation.nPriIndex);
printf(" Orientation Primary   : %f\n",             me->Orientation.dPrimary);
printf(" Orientation Secondary : Seg at Index %d\n", me->Orientation.nSecIndex);
printf(" Orientation Secondary : %f\n",             me->Orientation.dSecondary);
#endif

/* KLUDGE : angle stored temporarely in the instance during evaluation of auto components */

	/* ------------------------- */
	/* -- RETURN STORED ANGLE -- */
	/* ------------------------- */


if 	(me->Orientation.nPriIndex == -2)
{
	*dAngle = me->Orientation.dPrimary;
#ifdef MY_DEBUG
printf(" Angle (%f) stored in dPrimary\n",*dAngle );
#endif
        End
	return OM_S_SUCCESS;
}
else if (me->Orientation.nSecIndex == -2)
{
	*dAngle = me->Orientation.dSecondary;
#ifdef MY_DEBUG
printf(" Angle (%f) stored in dSecondary\n",*dAngle );
#endif
        End
	return OM_S_SUCCESS;
}

	/* --------------------------------- */
	/* -- COMPUTE ANGLE WITH TOPOLOGY -- */
	/* --------------------------------- */

/* ------------------------ */
/* -- Build Primary axis -- */
/* ------------------------ */

/*" Get Primary Segment from channel at index %d\n", me->Orientation.nPriIndex */

SegId.objid = NULL_OBJID;

om$get_objid_at_index (object	= me,
		   p_chanselect = &ND_father,
		   index 	= me->Orientation.nPriIndex,
		   objidaddr    = &SegId.objid,
		   osnumaddr    = &SegId.osnum);

if (SegId.objid == NULL_OBJID)
    {
    /*| ERROR recovering primary axis Id from channel */
    *msg = MSFAIL;
    End
    return ( OM_E_ABORT );
    }
/* -- get primary segment's topology -- */

#ifdef MY_DEBUG
        printf (" ---- TO GETTOPO 3-\n");
#endif
status = om$send ( msg = message VRCnrlSeg.VRGetTopo
		( &retmsg, dPrimary, NULL,NULL, NULL, NULL, md_env ),
	targetid = SegId.objid,
	targetos = SegId.osnum );
#ifdef MY_DEBUG
        printf (" ---- FROM GETTOPO 3-\n");
#endif

as$status ( action = RET_STATUS );

/*  -- Primary axis = (Vsegment * relative orientation) -- */
dPrimary [0] *= me->Orientation.dPrimary;
dPrimary [1] *= me->Orientation.dPrimary;
dPrimary [2] *= me->Orientation.dPrimary;
#ifdef MY_DEBUG
printf(" Primary : %f ,%f ,%f\n",dPrimary[0],dPrimary[1],dPrimary[2]);
#endif

/* -------------------------- */
/* -- Build Secondary axis -- */
/* -------------------------- */

/*| Get Secondary Segment from channel */
  status = om$send( msg      = message VRGeneric.VRGetSysType( &retcode, &cmp_systype ),
                    targetid = my_id );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );


*dAngle = 0.0;
if ( me->Orientation.nSecIndex >= 0 )
{
    SegId.objid = NULL_OBJID;
    om$get_objid_at_index (object	= me,
			   p_chanselect = &ND_father,
			   index 	= me->Orientation.nSecIndex,
			   objidaddr    = &SegId.objid,
			   osnumaddr    = &SegId.osnum);
    if (SegId.objid == NULL_OBJID)
	{
	/*| ERROR recovering Secondary axis Id from channel */
	*msg = MSFAIL;
        End
	return ( OM_E_ABORT );
	}
}
else if (cmp_systype == VR_ELBOW)
{
    if ( me->Orientation.nPriIndex >= 0 ){
      SegId.objid = NULL_OBJID;
      om$get_objid_at_index (object	= me,
			   p_chanselect = &ND_father,
			   index 	= (me->Orientation.nPriIndex + 1),
			   objidaddr    = &SegId.objid,
			   osnumaddr    = &SegId.osnum);

      if (SegId.objid == NULL_OBJID)
      {
	/*| ERROR recovering Secondary axis Id from channel */
        *dAngle = 0.0;
        *msg = MSFAIL;
        End
        return (OM_S_SUCCESS);
      }
      else{
        status - om$get_classid( objid     = SegId.objid,
                                 osnum     = SegId.osnum,
                                 p_classid = &classId);
	/* Assume it is OK */
        if(classId == OPP_VRCnrlSeg_class_id)
 	   me->Orientation.nSecIndex = me->Orientation.nPriIndex + 1 ;
      }
    }
    else{
      /*| No secondary axis */
      *dAngle = 0.0;
      *msg = MSFAIL;
      End
      return (OM_S_SUCCESS);
    } /* end if */
}
else
{
    /*| No secondary axis */
    *dAngle = 0.0;
    *msg = MSFAIL;
    End
    return (OM_S_SUCCESS);
} /* end if */

#ifdef MY_DEBUG
printf(" Secondary Segmentid = <%d,%d>\n",SegId.objid,SegId.osnum);
#endif

/* -- get secondary segment's vector -- */

#ifdef MY_DEBUG
        printf (" ---- TO GETTOPO 4-\n");
#endif
status = om$send ( msg = message VRCnrlSeg.VRGetTopo
		( &retmsg,dSecondary,NULL,NULL,NULL,NULL,md_env ),
	targetid = SegId.objid,
	targetos = SegId.osnum );
#ifdef MY_DEBUG
        printf (" ---- FROM GETTOPO 4-\n");
#endif
as$status ( action = RET_STATUS );

/*  Secondary axis = Vsegment directed to the center of the segment */

nIX = me->Orientation.nSecIndex - me->nNbAttr;
status =
om$send (msg = message VRComponent.VRGetMEIX (&retmsg, nIX, &nVIX),
    targetid = my_id);

if ( nVIX != 0 )
{
    /*| Reverse secondary segment vector */
    dSecondary [0] *= -1;
    dSecondary [1] *= -1;
    dSecondary [2] *= -1;
}

/* -- Compute Angle between Primary and Secondary axis -- */
/* -- Z axis = Primary ^ Secondary -- */
BScrossp (&rc, dPrimary, dSecondary, dTransformed);
if ( rc != BSSUCC )
    {
    /*| ERROR Last axis not COMPUTED */
    *msg = MSFAIL;
    End
    return ( OM_E_ABORT );
    }
dTmpAngle = VRcompute_angle (dPrimary, 
     			dSecondary,
			dTransformed);

/* -- Convert angle in degrees -- */
dTmpAngle = dTmpAngle / M_PI * 180.0;

*dAngle = dTmpAngle;

End
return ( OM_S_SUCCESS );

} /* end VRGetAngle */

/***********************************************************************/

method VRGetPipeExtensions ( IGRlong *msg ; IGRdouble *dCptsCoor ;
				struct GRmd_env *md_env )

{
IGRint 		status;
IGRlong		retmsg;

/* SetProc( VRComponent_VRGetPipeExtensions ); Begin */

*msg = MSSUCC;

if ( me->Status & VR_CORRECTION )
{
	/*| Pipe Correction getting cpts */

	status = 
	om$send ( msg = message VRCorrection.VRGetPipeCpts
				( &retmsg, md_env, dCptsCoor ),
		p_chanselect= &AS_to_owner,
		from	    = 0,
		to	    = 0);
	as$status ( action = RET_STATUS );
}
else
{
	/*| Pipe Component getting cpts */
	dCptsCoor[0] = -10.0;
	dCptsCoor[3] =  10.0;
	dCptsCoor[1] = dCptsCoor[2] = dCptsCoor[4] = dCptsCoor[5] = 0;

}
/* End */
return ( OM_S_SUCCESS );

}/* end VRGetPipeExtensions */


/***********************************************************************/

method VRGetNumberOfCpts (IGRlong *msg ;IGRint *NbCpts; struct GRmd_env *md_env )
{
	IGRint status;
	IGRlong retmsg;

/* SetProc( VRComponent_VRGetNumberOfCpts ); Begin */
*msg=MSSUCC;

	/* -- get my defined connect points' number -- */
	status=
	om$send ( msg = message VRGeneric.VRGetNumberOfCpts 
			(&retmsg ,NbCpts, md_env ),
		mode     = OM_e_wrt_message,
		targetid = my_id);
	as$status ( action = RET_STATUS );

	/* -- get additionnal connect points from correction -- */
	if ( me->Status & VR_CORRECTION )
	{
		IGRshort	nAddedCpts;
		struct GRid	MyId;

		MyId.objid = my_id; MyId.osnum = OM_Gw_current_OS;

		status =
		om$send ( msg = message VRCorrection.VRGetDynCpts 
					( msg, &MyId,  &nAddedCpts, md_env),
			p_chanselect= &AS_to_owner,
			from	    = 0,
			to	    = 0);
		if ( (status&1) && (*msg==MSSUCC))
		{
			/*" I have %d additional connect points\n",nAddedCpts*/
			*NbCpts += (IGRint) nAddedCpts;
		}

	}/* end correction component management */

	/*"/t Total : %d connect points\n",*NbCpts*/

/* End */
return OM_S_SUCCESS;

}/* end VRGetNumberOfCpts */

/***********************************************************************/

method VRGetNeighbors (	IGRlong 	*msg ;
			IGRint		CpFrom;
			IGRint		CpTo;
			IGRint		*NbNeigh;
			struct GRid	*NeiId;
			IGRshort	*nNeiCpNum;
			struct GRmd_env *md_env)

{
	IGRint		status;
	IGRlong 	retmsg;
	struct GRid	MyId;

SetProc( VRComponent_VRGetNeighbors ); Begin

/* -- Override only for correction components -- */

if ( me->Status & VR_CORRECTION )
{
	IGRint		NbCpts;
	IGRshort	TmpNbNeigh;

	/*" ---- %s ----(CORRECTION)\n",me->szAABBCC */

	/*" Connect points between %d and %d\n",CpFrom, CpTo*/

	*msg=MSFAIL;
	MyId.objid = my_id;
	MyId.osnum = OM_Gw_current_OS;

	status=
	om$send ( msg = message VRGeneric.VRGetNumberOfCpts 
			(&retmsg ,&NbCpts, md_env ),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	/*" Total Number Of Connect Points : %d\n",NbCpts*/

	if ( CpFrom < 0 || CpFrom >= NbCpts || CpFrom > CpTo || !NbNeigh )
	{
		/*| ERROR -> Bad Cpt Number */
                End
		return ( OM_E_INVARG );
	}


	/* -- get neighborid and cpt from my correction owner -- */
	status =
	om$send ( msg = message VRCorrection.VRGetCmpNeighbor
					( msg,
					&MyId,
					CpFrom,CpTo,
					&TmpNbNeigh,
					NeiId,
					nNeiCpNum,
					md_env),
		p_chanselect= &AS_to_owner,
		from	    = 0,
		to	    = 0);

        *NbNeigh = ( IGRint ) TmpNbNeigh;

	/*" Correction found %d neighbors for me\n",*NbNeigh*/

}
else
{
	/* -- Execute generic code -- */
	status =
	om$send (msg = message VRGeneric.VRGetNeighbors (msg ,
					CpFrom, CpTo, NbNeigh, NeiId, nNeiCpNum, md_env),
		mode     = OM_e_wrt_message,
		targetid = my_id );
	
}
End
return ( status );

}/* end VRGetNeighbors */

/***********************************************************************/

method VRGetInstance ( IGRlong  *msg; struct VRGenInfo *Instance )

{
  IGRshort  i, ii;
  IGRint    status;

  *msg = MSSUCC;

  /*" AABBCC = %s\n",me->szAABBCC */
  /*" Item   = %d\n", Instance->Attr.Comp.Desc.nItemNum*/

  /* -- Get super class instance -- */
  status =
  om$send ( msg = message VRGeneric.VRGetInstance (msg, Instance),
       mode     = OM_e_wrt_message,
       targetid = my_id );

  /* -- Restore component index on segments -- */
  for ( i=0; i<me->nNbTopo; i++ ) 
  {
    status =
    om$send ( msg = message VRComponent.VRGetMEIX (msg, i, &ii),
         targetid = my_id );

    Instance->Attr.Comp.nIndex[i] = ii;
  }

  /* -- Restore component description -- */
  Instance->Attr.Comp.Desc = me->Desc;

  /* -- Restore component orientation -- */
  Instance->Attr.Comp.Orientation = me->Orientation;

  return ( OM_S_SUCCESS );

}/* end VRGetInstance */



/***********************************************************************/

method VRGetCorrections (IGRlong *msg; IGRint ArraySize;
			 struct GRid CorIds[]; IGRint *NbCorrections)

{
	IGRint	status;
        SetProc( VRComponent_VRGetCorrections ); Begin
	status = OM_S_SUCCESS;

	*msg = MSFAIL;

	if ( (me->Status & VR_CORRECTION) && (ArraySize >= 1) )
 	{
		struct GRid	MyId;

		MyId.objid = my_id;
		MyId.osnum = OM_Gw_current_OS;

		status = ASget_as_owner( &MyId, CorIds );
		as$status ( action = RET_STATUS );

		*NbCorrections=1;
		*msg=MSSUCC;
 	}
	else
	{
		status =
		om$send ( msg = message VRGeneric.VRGetCorrections
				(msg, ArraySize, CorIds, NbCorrections),
			mode     = OM_e_wrt_message,
			targetid = my_id );
		as$status ();

	}

End
return status;

}/* end VRGetCorrections */

/***********************************************************************/

method VRGetHangers ( IGRlong *msg;  IGRint ArraySize; 
			struct GRid HangerIds[]; IGRint *NbHangers; IGRdouble *dCpCoors;
			struct GRmd_env	*md_env)

{
	IGRint	status;
        SetProc( VRComponent_VRGetHangers ); Begin
	status=OM_S_SUCCESS;

	*msg = MSFAIL;

	if ( me->Status & VR_CORRECTION )
 	{
		struct GRid	MyId,CorId;

		MyId.objid = my_id;
		MyId.osnum = OM_Gw_current_OS;

		status = ASget_as_owner( &MyId, &CorId );
		as$status ( action = RET_STATUS );

		/*" Resend to correction <%d,%d>\n",CorId.objid,CorId.osnum*/
		status=
		om$send ( msg = message VRCorrection.VRGetHangers
				( msg, &MyId, ArraySize, HangerIds, NbHangers,
				  dCpCoors,md_env),
		targetid = CorId.objid,
		targetos = CorId.osnum );
		as$status ( action = RET_STATUS );

 	}
	else
	{
		status =
		om$send ( msg = message VRGeneric.VRGetHangers
				(msg, ArraySize, HangerIds, NbHangers,
				 dCpCoors, md_env),
			mode     = OM_e_wrt_message,
			targetid = my_id );
		as$status ();

	}

End
return status;

}/* end VRGetHangers */

/***********************************************************************/

end implementation VRComponent;


