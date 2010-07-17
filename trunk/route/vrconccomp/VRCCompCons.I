/* $Id: VRCCompCons.I,v 1.3 2001/02/20 01:12:47 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconccomp / VRCCompCons.I
 *
 * Description:
     All methods managing the constraints.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCCompCons.I,v $
 *	Revision 1.3  2001/02/20 01:12:47  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 15:49:45  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/23  22:32:06  pinnacle
# Created: route/vrconccomp/VRCCompCons.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.3  1997/03/31  14:45:02  pinnacle
# Replaced: vrconccomp/VRCCompCons.I for:  by hverstee for route
#
# Revision 1.2  1997/02/18  20:01:58  pinnacle
# Replaced: vrconccomp/VRCCompCons.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/16  21:52:02  pinnacle
# Replaced: vrconccomp/VRCCompCons.I for:  by r240_int for route240
#
 *
 * History:
	12-Nov-92  Bruno	2.1.0.22
				Creation by getting the methods out of
		  		the VRCCompInfo.I file and removing all
		  		the code calling the ci_macros.
 *	01/16/96   tlb		Add prototypes
 *
 *************************************************************************/

class implementation VRConcComp;

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VRMath.h"
#include "asbox.h"
#include "nddef.h"
#include "bstypes.h"
#include "vrdbgmacros.h"
#include "vrtools_pto.h"
#include "bsdotp.h"
#include "bsmkvec.h"

#define AS_DEBUG	1


/***********************************************************************/

method VRget_nb_constrain( IGRint *nb_cons )
{

	IGRint 		status, NbPlanes;
	IGRlong 	retmsg;
	SetProc( VRCComp_VRget_nb_constrain ); Begin
	/* Only returns constraints when I have planes connected */

	status = 
	om$send( msg	 = message VRGeneric.VRGetPlanes
			( &retmsg, 0, NULL, &NbPlanes, NULL ),
	           	targetid = my_id);
	as$status( action = RET_STATUS );

	if (NbPlanes)
	{
		/* There are 3 planes per cpt and
		   we have each plane of cpt0 constrained
		   with one plane of each other cpt */

		*nb_cons = (me->nNbCpts - 1) * 3;
	}else *nb_cons = 0;
End
return OM_S_SUCCESS;

}/* end VRget_nb_constrain */

/***********************************************************************/

method VRget_constrain( IGRlong *suc; IGRint i; IGRint *cons_type;
                        struct GRid *cons_obj; IGRint *nb_obj; IGRint size_obj;
                        IGRdouble *cons_val; IGRint *nb_val; IGRint size_val )

{
	IGRlong	retmsg;
	IGRint 	status;

	/* declared for comprehension */
	IGRint	ConsIndex,	/* Constraint number */
		CptNum,		/* Cpt involved in the constraint */
		Pl0Index,	/* Plane of cpt0 involved */
		PliIndex;	/* Other plane involved */
        IGRshort  nLOC, iLOC;

	OM_S_CHANSELECT chansel;

        SetProc( VRCComp_VRget_constrain ); Begin
	chansel.type 	= OM_e_name;
	chansel.u_sel.name = "father";

	/*| initialization : pair of planes at a fixed distance */
	*suc		= MSSUCC;
	*cons_type	= VR_CNS_PARA | VR_CNS_VAL;	/* para const */
	*nb_obj		= 2;
	*nb_val		= 1;
        iLOC            = i;

	ConsIndex 	= i;
	CptNum 		= (i/3)+1;
	Pl0Index 	= i%3+me->nNbAttr;
        __DBGpr_int("Constraint number",ConsIndex);
        __DBGpr_int("Cpt involved in the constraint",CptNum);
 
	status =
	om$send (msg = message VRConcComp.VRGetMECI (&retmsg, iLOC, &nLOC),
            targetid = my_id);

	PliIndex	= nLOC + me->nNbAttr;

	/*" Constraint[%d] = cpt0 -> cpt%d\n", i, (i/3)+1 */
	/*" Plane[%d] -> Plane[%d]\n", i%3, PliIndex      */

	/* --------------------------- */
	/* -- Get contrained planes -- */
	/* --------------------------- */

	/* Get plane cpt 0 */
	status =
	om$get_objid_at_index (	object		= me,
				p_chanselect 	= &chansel,
				index		= Pl0Index,
				objidaddr	= &cons_obj[0].objid,
				osnumaddr	= &cons_obj[0].osnum);
	as$status( action = RET_STATUS );
        __DBGpr_obj("cons_obj0",cons_obj[0]);
	/* Get plane cpt i */
	status =
	om$get_objid_at_index (	object		= me,
				p_chanselect 	= &chansel,
				index		= PliIndex,
				objidaddr	= &cons_obj[1].objid,
				osnumaddr	= &cons_obj[1].osnum);
        __DBGpr_obj("cons_obj1",cons_obj[1]);
	as$status( action = RET_STATUS );

	/* ------------------- */
	/* -- Compute value -- */
	/* ------------------- */
	{
	IGRdouble	dCpt0[3], dCpti[3], dVect[3], BSdotp();
	BSrc		rc;
	struct GRmd_env	LocEnv;
	struct IGRplane	Common;

	Common.point  = dCpt0;
	Common.normal = dCpti;

	{/* get module env */
		IGRlong			NumberOfBytes;  /* number of bytes            */
		IGRlong			BytesReceived;   /* number of received bytes  */
		NumberOfBytes = sizeof( struct GRmd_env );
		status = gr$get_model_env( 	msg    = &retmsg,
						sizbuf = &NumberOfBytes,
						buffer = &LocEnv,
						nret   = &BytesReceived );
		as$status( action = RET_STATUS );
		/*"module_info = %d %d\n", LocEnv.md_id.objid, LocEnv.md_id.osnum */
	}/* end get module env */


	/* Get cpt 0 coordinates */

	status=
	om$send ( msg = message VRGeneric.VRGetCptGeom
				(&retmsg , 0,
				dCpt0, NULL, NULL, &LocEnv),
		targetid = my_id );
	as$status ( action = RET_STATUS );

	/* Get cpt i coordinates */

	status=
	om$send ( msg = message VRGeneric.VRGetCptGeom 
				(&retmsg , (IGRshort) CptNum,
				dCpti, NULL, NULL, &LocEnv),
		targetid = my_id );
	as$status ( action = RET_STATUS );

	/* Build vector */

	BSmkvec (&rc, dVect, dCpt0, dCpti);
        __DBGpr_com("Apparently building a vector from cpt0 to cpt1");
        __DBGpr_vec("dVect",dVect);
	/* get first plane's normal */

	status =
	om$send( msg      = message  GRvg.GRdetplane
				( &retmsg, &LocEnv.md_env.matrix_type,
				 	LocEnv.md_env.matrix, &Common ),
		targetid = cons_obj[0].objid,
		targetos = cons_obj[0].osnum );
	as$status( action = RET_STATUS );

	/* Project vector on the normal of the first plane returned */
	*cons_val = BSdotp ( &rc, dVect, Common.normal );
        
	__DBGpr_dbl(" Constraint's value ", cons_val[0]);

	}/* end compute distance */

  /*" Constraint's value : %f\n", cons_val[0] */
  End
  return OM_S_SUCCESS;

}/* end VRget_constrain */

/***********************************************************************/

method VRAddPlanes(	IGRlong			*msg;
			IGRint			NbTopo;
			struct GRid 		*TopoIds;
			IGRshort		*ConstList;
			struct GRmd_env		*md_env )
{

	IGRint 		i,status;
	IGRlong 	retmsg;
        IGRshort        iLOC, nLOC;

	SetProc( VRCComp_VRAddPlanes ); Begin
	/* ----------------------------------------------------------- */
	/*| -- Compute my orientation relative to the first 3 planes -- */
	/* ----------------------------------------------------------- */

	{
	struct IGRplane	Plane;		/* To get the planes geom */
	IGRdouble 	dVec[3],	/* Plane's normal */
			dPt[3],		/* Plane's origin */
			dX[3],		/* My X Axis */
			dY[3];		/* My Y Axis */

	Plane.point 	= dPt;
	Plane.normal 	= dVec;

	/*| -- Compute Relative Orientation -- */
	/*| Get my present orientation at cpt 0 */

	status = 
	om$send ( msg = message VRGeneric.VRGetCptGeom
			( msg, 0, NULL, dX, dY, md_env ),
		targetid = my_id );
	as$status ( action = RET_STATUS );

	/*" DX = %f, %f, %f\n", dX[0], dX[1], dX[2] */
	/*" DY = %f, %f, %f\n", dY[0], dY[1], dY[2] */
        __DBGpr_vec("X vector at CPT0",dX);
        __DBGpr_vec("Y vector at CPT0",dY);
	/*| -- Find relative X orientation / Terminal's normal -- */

	/* Get the terminal plane's normal */

	/*" Term Plane : <%d, %d>\n", TopoIds[2].objid,TopoIds[2].osnum*/
        __DBGpr_obj("terminal plane at cpt0",TopoIds[2]);
	status =
	om$send( msg      = message  GRvg.GRdetplane
				( msg, &md_env->md_env.matrix_type,
				md_env->md_env.matrix, &Plane ),
			targetid = TopoIds[2].objid,
			targetos = TopoIds[2].osnum );
	as$status( action = RET_STATUS );
	/*" Term = %f, %f, %f\n", dVec[0], dVec[1], dVec[2] */

	if (bVRTestVect (&retmsg, dX, Plane.normal, (IGRshort)VR_OPPOSITE))
		me->nOrienToPlanes[0]=1;
	else
		me->nOrienToPlanes[0]=-1;

        __DBGpr_int("instance-nOrienToPlanes[0]",(int) me->nOrienToPlanes[0]);
	/*| -- Find relative Y orientation / Ortho's normal -- */

	/* Get the Ortho plane's normal */
	/*" Orth Plane : <%d, %d>\n", TopoIds[1].objid,TopoIds[1].osnum*/

	status =
	om$send( msg      = message  GRvg.GRdetplane
				( msg, &md_env->md_env.matrix_type,
				 md_env->md_env.matrix, &Plane ),
			targetid = TopoIds[1].objid,
			targetos = TopoIds[1].osnum );
	as$status( action = RET_STATUS );
	/*" Orth = %f, %f, %f\n", dVec[0], dVec[1], dVec[2] */

	me->dAngleToCommon = - VRcompute_angle (Plane.normal, dY, dX );

	/*" Angle found : %f\n", me->dAngleToCommon */

	}/* End compute my orientation */

	/* Allocate my instance size */

	/* ----------------------------------- */
	/*|-- Attach my planes as templates -- */
	/* ----------------------------------- */

	status =
	om$send( msg = message NDnode.NDconnect
			(NbTopo, TopoIds, NULL_GRID, ND_ADD),
		targetid = my_id);
	as$status(action = RET_STATUS);

	/* ------------------------------------- */
	/*|-- Store my constraints definition -- */
	/* ------------------------------------- */

	/* Force justification to be 0 */
	me->nJustif = 0;
        __DBGpr_com("Setting justification to cpt0 here --------------");
	/* Copy the constraints definition */

	for (i = 0; i<(NbTopo-3); i++)
	{
		/*"ConstList[%d] = %d\n", i, ConstList[i] */

		iLOC = i;
		nLOC = ConstList[i];

		status =
		om$send (msg = message VRConcComp.VRSetMECI
						(&retmsg, iLOC, nLOC),
                    targetid = my_id);
	}
  End
  return OM_S_SUCCESS;

}/* end VRAddPlanes */


end implementation VRConcComp;

