/* $Id: VRCCompInfo.I,v 1.3 2001/02/20 01:12:49 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconccomp / VRCCompInfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCCompInfo.I,v $
 *	Revision 1.3  2001/02/20 01:12:49  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 15:49:53  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/23  22:32:32  pinnacle
# Created: route/vrconccomp/VRCCompInfo.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/02/18  20:01:32  pinnacle
# Replaced: vrconccomp/VRCCompInfo.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/16  21:52:06  pinnacle
# Replaced: vrconccomp/VRCCompInfo.I for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96   tlb		Add prototypes
 *
 *************************************************************************/

class implementation VRConcComp;

#include "bserr.h"
#include "bstypes.h"
#include "bsconic.h"
#include "VRparamdef.h"
#include "VRDbParamDef.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsroto.h"
#include "vrdbgmacros.h"

#define AS_DEBUG	1


/***********************************************************************/

method VRGetInstance ( IGRlong	*msg; struct VRGenInfo *Instance )

{
	IGRshort	i;
	IGRint 		status;

	SetProc( VRConcComp_VRGetInstance ); Begin
	*msg = MSSUCC;

	/* -- Init super class instance -- */
	status =
	om$send ( msg = message VRGeneric.VRGetInstance
			(msg, Instance),
		mode     = OM_e_wrt_message,
		targetid = my_id );
	as$status ();
__DBGpr_int("nNbTopo",(int) me->nNbTopo);
	/* -- Return component index on segments -- */
	for ( i=0; i<me->nNbTopo; i++ ) 
        {
          IGRshort   nLOC;

          status =
          om$send (msg = message VRConcComp.VRGetMEIX (msg, i, &nLOC),
                       targetid = my_id);
          __DBGpr_int("topo index",(int) i);
          __DBGpr_int("comp index on seg",(int) nLOC);
	  Instance->Attr.CComp.nIndex[i] = nLOC;
        }
        

	/* -- Return component orientation angle -- */
        __DBGpr_dbl("orient angle",me->dAngleToCommon);
	Instance->Attr.CComp.dAngleToCommon = me->dAngleToCommon;
	End
	return ( OM_S_SUCCESS );

}/* end VRGetInstance */

/***********************************************************************/


method VRGetMatrix ( 	IGRlong *msg; IGRint NbTemp; struct GRid *TempList;
			IGRdouble *dRefMatrix;  struct GRmd_env *md_env)

{
	IGRboolean	bBooleanVar;
	IGRint		status=OM_S_SUCCESS, i, Flag;
	IGRlong		retmsg;
	IGRdouble	dX[3], dY[3], dZ[3], dOrg[3], dAngle;
	struct IGRplane	Common    , Ortho     , Terminal;
	IGRdouble	dVectC[3] , dVectO[3] , dVectT[3];
	IGRdouble	dPointC[3], dPointO[3], dPointT[3];   
	struct GRid	PlaneId;
	BSrc		rc;
	OM_S_CHANSELECT chansel;

	SetProc( VRConcComp_VRGetMatrix ); Begin
	/*" AABBCC = %s\n",me->szAABBCC */

	*msg = MSSUCC;


	/* ------------------------------------- */
	/* -- Treatment of general components -- */
	/* ------------------------------------- */

/*" Common index   	 : %d\n", (me->nNbAttr) */
/*" Angle/Common         : %f\n", me->dAngleToCommon*/
/*" Orientation/Terminal : %d\n", me->nOrienToPlanes[0]*/
/*" Orientation/Ortho    : %d\n", me->nOrienToPlanes[1]*/


Ortho.point 	= dPointO;
Ortho.normal 	= dVectO;
Common.point 	= dPointC;
Common.normal 	= dVectC;
Terminal.point 	= dPointT;
Terminal.normal = dVectT;
chansel.type 	= OM_e_name;
chansel.u_sel.name = "father";
dOrg [0] = dOrg [1] = dOrg [2] = 0;

	/* ------------------------------------------ */
	/* -- Get Primary axis from Terminal plane -- */
	/* ------------------------------------------ */

	status = OM_S_SUCCESS;	

	/* -- get Terminal Plane id -- */


	if ( TempList )
	{
		/* are the planes in the template list ? */
		if ( NbTemp >= 2+me->nNbAttr)
		{
			/*| Get Plane from list */
			PlaneId = TempList[2+me->nNbAttr];
		}
		else	status = OM_E_ABORT;
	}
	else
	{

	    /*| Get Plane from channel */
		status =
		om$get_objid_at_index ( object		= me,
					p_chanselect 	= &chansel,
					index		= (2+me->nNbAttr),
					objidaddr	= &PlaneId.objid,
					osnumaddr	= &PlaneId.osnum);
	}
	/*" Terminal plane id = <%d,%d>\n",PlaneId.objid,PlaneId.osnum*/

	if ( !(status&1) )
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

	/* -- get X axis -- */
	status =
	status = om$send( msg	= message  GRvg.GRdetplane
                                            ( &retmsg,
	  		       		      &md_env->md_env.matrix_type,
			       		      md_env->md_env.matrix,
                                              &Terminal ),
		targetid = PlaneId.objid,
		targetos = PlaneId.osnum );
	as$status ( action = RET_STATUS );

	/* -- X axis = (Terminal's normal * relative orientation) -- */
        __DBGpr_dbl("nOrienToPlanes",(IGRdouble) me->nOrienToPlanes[0]);
	dX [0] = me->nOrienToPlanes[0] * Terminal.normal[0];
	dX [1] = me->nOrienToPlanes[0] * Terminal.normal[1];
	dX [2] = me->nOrienToPlanes[0] * Terminal.normal[2];
        __DBGpr_vec("X vector-terminal normal corrected for orientation",dX);
	/* --------------------------------- */
	/* -- Get Y axis from Ortho plane -- */
	/* --------------------------------- */

	/* -- get Ortho id -- */

	if ( TempList )
	{
		/*| Get Plane from list */
		PlaneId = TempList[1+me->nNbAttr];
                __DBGpr_obj("PlaneId",PlaneId);
	}
	else
	{
		/*| Get Plane from channel */

		om$get_objid_at_index (	object		= me,
					p_chanselect 	= &chansel,
					index 		= (1+me->nNbAttr),
					objidaddr    	= &PlaneId.objid,
					osnumaddr    	= &PlaneId.osnum);
	}
	/*" Ortho plane id = <%d,%d>\n",PlaneId.objid,PlaneId.osnum*/

	/* get normal */

	status = om$send( msg	= message  GRvg.GRdetplane
                                            ( &retmsg,
	  		       		      &md_env->md_env.matrix_type,
			       		      md_env->md_env.matrix,
                                              &Ortho ),
		targetid = PlaneId.objid,
		targetos = PlaneId.osnum );
	as$status ( action = RET_STATUS );

	/* Y axis = (Ortho's normal) -- */

	dY [0] =  Ortho.normal[0];
	dY [1] =  Ortho.normal[1];
	dY [2] =  Ortho.normal[2];
        __DBGpr_vec("Y vector-no orientation- from ortho plane",dY);
	/* ------------------ */
	/* -- Build Z axis -- */
	/* ------------------ */

	/* -- Z axis = dX ^ dY -- */
	BScrossp (&rc,  dX, dY, dZ);
		if ( rc != BSSUCC )
		{/*| ERROR ->  Z axis not COMPUTED */
                   End
                   return ( OM_E_ABORT );}
	BSnorvec ( &rc,dZ );
		if ( rc != BSSUCC )
		{/*| ERROR ->  Z axis not NORMED */
                   End
                   return ( OM_E_ABORT );}
        __DBGpr_vec("Z vector-computed from X Y",dZ); 
	/*| BEFORE ROTATION */
	/*" dX   : %f ,%f ,%f\n",dX[0],dX[1],dX[2]*/
	/*" dY   : %f ,%f ,%f\n",dY[0],dY[1],dY[2]*/
	/*" dZ   : %f ,%f ,%f\n",dZ[0],dZ[1],dZ[2]*/

	/* -- Rotate dY round dX axis -- */
	dAngle = me->dAngleToCommon;
	bBooleanVar = TRUE;
	BSroto ( &rc,dOrg,dX,&bBooleanVar,
		 &dAngle,dY,dY );
		if ( rc != BSSUCC )
		{/*| ERROR -> Y axis not ROTATED */
                 End
		 return ( OM_E_ABORT );}

	/*| ReCompute Rotated Z axis */

	/* -- Z axis = dX ^ dY -- */
	BScrossp (&rc,  dX, dY, dZ);
		if ( rc != BSSUCC )
		{/*| ERROR ->  Z axis not RECOMPUTED */
                   End
                   return ( OM_E_ABORT );}
__DBGpr_com("After rotation");
__DBGpr_vec("VRCComp X vector",dX); 
__DBGpr_vec("VRCComp Y vector",dY); 
__DBGpr_vec("VRCComp Z vector",dZ); 

	/*| AFTER ROTATION */
	/*" dX   : %f ,%f ,%f\n",dX[0],dX[1],dX[2]*/
	/*" dY   : %f ,%f ,%f\n",dY[0],dY[1],dY[2]*/
	/*" dZ   : %f ,%f ,%f\n",dZ[0],dZ[1],dZ[2]*/

	/* ----------------------------- */
	/* -- Compute placement point -- */
	/* ----------------------------- */

	/* -- get Common id for placement point -- */

	if ( TempList )
	{
		/*| Get Plane from list */
		PlaneId = TempList[me->nNbAttr];
	}
	else
	{
		/*| Get Plane from channel */

		om$get_objid_at_index (object		= me,
					p_chanselect 	= &chansel,
					index 		= (me->nNbAttr),
					objidaddr    	= &PlaneId.objid,
					osnumaddr    	= &PlaneId.osnum);
	}
	/*" Common plane id = <%d,%d>\n",PlaneId.objid,PlaneId.osnum*/

	/* -- get geometry -- */
	status =
	status = om$send( msg	= message  GRvg.GRdetplane
                                            ( &retmsg,
	  		       		      &md_env->md_env.matrix_type,
			       		      md_env->md_env.matrix,
                                              &Common ),
		targetid = PlaneId.objid,
		targetos = PlaneId.osnum );
	as$status ( action = RET_STATUS );


	/* -- Compute intersection -- */

	BSpl_pl_pl ( 	Common.point, Common.normal,
			Ortho.point , Ortho.normal,
			Terminal.point, Terminal.normal,
			&Flag, dOrg, dOrg, dOrg, dOrg, dOrg, &rc );
		if ( rc != BSSUCC  || Flag != BSCPOINTINTER )
		{/*| ERROR ->  Origin Point not found */
                   End
                   return ( OM_E_ABORT );}

	/* -------------------- */
	/* -- Fill in matrix -- */
	/* -------------------- */

	for (i=0;i<3;i++)
	{
		dRefMatrix [i*4]     = dX [i];
		dRefMatrix [i*4 + 1] = dY [i];
		dRefMatrix [i*4 + 2] = dZ [i];
		dRefMatrix [i*4 + 3] = dOrg [i];
	}

	/* -- Fill in Perspective and homothety -- */
	dRefMatrix [12] = dRefMatrix [13] = dRefMatrix [14] = 0;
	dRefMatrix [15] = 1;
        __DBGpr_mat("Ref Matrix",dRefMatrix);
End
return ( OM_S_SUCCESS );

}/* end VRGetMatrix */

/***********************************************************************/


method VRGetSysType ( IGRlong *msg; IGRshort *nSysType )
{
SetProc( VRConcComp_VRGetSysType ); Begin
*msg = MSSUCC;

	/*" ---- %s ----\n",me->szAABBCC */

	*nSysType = VR_CONC_COMP;

End
return ( OM_S_SUCCESS );

}/* end VRGetSysType */

/***********************************************************************/

end implementation VRConcComp;
