/* $Id: VRHanInfo.I,v 1.2 2002/04/10 19:45:20 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrhanger / VRHanInfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRHanInfo.I,v $
 *	Revision 1.2  2002/04/10 19:45:20  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:53  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/17  00:03:24  pinnacle
# Replaced: vrhanger/VRHanInfo.I for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96   tlb		Add prototypes
 *      04/05/02   law          TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

class implementation VRHanger;

#include "bserr.h"
#include "VRcompdef.h"
#include "VRparamdef.h"
#include "VRMath.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bscrossp.h"

#define AS_DEBUG
#define VR_EPSILON	(1.e-10)

from 	VRCorrection	import	VRGetCorLength;
from 	VRCorrection	import	VRGetPipeCpts;
from	VRCnrlSeg	import	VRget_terminators;

/***********************************************************************/

method VRGetMatrix ( 	IGRlong *msg; IGRint NbTemp; struct GRid *TempList;
			IGRdouble *dSuppMatrix;  struct GRmd_env *md_env)

{

struct	GRmd_env	LocEnv;
IGRshort	nSysType, nStatus;
IGRlong		retmsg;
register IGRint	i;
IGRint		status, NbCorEntity;
struct GRid	CompId, GoGrid, CorId;
IGRdouble	dCompMatrix [16], dCompOrg [3], dTmpOrg [3];
IGRdouble	dX [3], dY [3], dZ [3];
IGRdouble	dEndPoints [6], dDirectionVector [3], dPipeOffsetVector [3];
IGRdouble	dCorLength;
BSrc		rc;
OM_S_CHANSELECT father;

*msg = MSSUCC;


/* -- get Component id -- */

if ( TempList != NULL )
    {
    /*| Get Component from list (0) */
    CompId = TempList[0];
    }
else
    {
    /*| Get Component from channel */

    father.type = OM_e_name;
    father.u_sel.name = "father";

    status =
    om$get_objid_at_index (	object		= me,
			    p_chanselect	= &father,
			    index 		= 0,
			    objidaddr	= &CompId.objid,
			    osnumaddr	= &CompId.osnum);

    as$status ( action = RET_STATUS );
    } /* end if */

/*"Component id (%d,%d)\n",CompId.osnum,CompId.objid */

/*|  get Component's id - using ACreturn_foot */
status=
om$send (msg = message NDmacro.ACreturn_foot
				(&retmsg,
				"",
				&GoGrid,
				&LocEnv.md_env.matrix_type,
				LocEnv.md_env.matrix),
		targetid = CompId.objid,
		targetos = CompId.osnum);
/*"GoGrid (os,id) = (%d,%d)\n",GoGrid.osnum,GoGrid.objid */
as$status ( action = RET_STATUS );
as$status ( sts = retmsg , action = RET_STATUS );

/*| Get Component matrix && Origin */

status=
om$send( msg=message VRGeneric.VRGetMatrix
		(&retmsg,
		0,
		(struct GRid *) NULL,
		dCompMatrix,
		&LocEnv),
	targetid = GoGrid.objid,
	targetos = GoGrid.osnum);
as$status ( action = RET_STATUS );

/*| Transformation matrix of component for Hanger Orientation */
/*^
printf ("Matrix got from component\n");
for (i=0;i<4;i++)
    printf ("%lf,%lf,%lf,%lf\n",	dCompMatrix [i*4],
					dCompMatrix [i*4+1],
					dCompMatrix [i*4+2],
					dCompMatrix [i*4+3]);
*/

/* Used to inquired pipeid of correction component */
for (i=0;i<4;i++)
    dTmpOrg [i] = dCompMatrix [i*4+3];

/*| Get Component type */

status=
om$send( msg = message VRGeneric.VRGetSysType
		(&retmsg,
		&nSysType),
	targetid = GoGrid.objid,
	targetos = GoGrid.osnum);
as$status ( action = RET_STATUS );

status=
om$send( msg=message VRGeneric.VRGetStatus
		(&retmsg,
		&nStatus),
	targetid = GoGrid.objid,
	targetos = GoGrid.osnum);
as$status ( action = RET_STATUS );


if (nSysType == VR_PIPE)
    {
    /*| This is a support for correction component */
    status = om$send(msg = message VRGeneric.VRGetCorrections (
				&retmsg,
				1,
				&CorId,
				&NbCorEntity),
		targetid = GoGrid.objid,
		targetos = GoGrid.osnum );
    as$status( action = RET_STATUS );
    /*"CorId is %d\n", CorId.objid */

    status = om$send(msg = message VRCorrection.VRGetPipeCpts (
				&retmsg,
				&LocEnv,
				dEndPoints),
		targetid = CorId.objid,
		targetos = CorId.osnum );
    as$status( action = RET_STATUS );
    /*^
    printf ( "By GetPipeCpts dEndPoints [0] = (%lf,%lf,%lf)\n",
    dEndPoints [0],dEndPoints [1],dEndPoints [2]);
    printf ( "dEndPoints [3] = (%lf,%lf,%lf)\n",
    dEndPoints [3],dEndPoints [4],dEndPoints [5]);
    */
    BSmkvec (&rc, dDirectionVector, &dEndPoints [3], &dEndPoints [0]);

    status = om$send(msg = message VRCorrection.VRGetCorLength (
				0,
				&LocEnv,
				&dCorLength),
		targetid = CorId.objid,
		targetos = CorId.osnum );
    as$status( action = RET_STATUS );

    /*"Correction length = %lf\n",dCorLength */
    /*"dFactor     = %lf\n",me->dFactor */

    if (dCorLength < VRGetTol(VR_DIST_TOL))
        {
	dPipeOffsetVector [0] = dPipeOffsetVector [1] = 
				dPipeOffsetVector [2] = 0.0;
	}
    else
	{
	BSnorvec (&rc,dDirectionVector);
	/*^
	printf ("dDirectionVector is (%lf,%lf,%lf)\n",
				dDirectionVector [0],
				dDirectionVector [1],
				dDirectionVector [2]);
	*/

	for (i=0;i<3;i++)
	    {
	    dCompMatrix [i*4+3] = dEndPoints [i] - dDirectionVector [i] 
				* dCorLength * me->dFactor;
	    }
	}

    for (i=0;i<3;i++)
	{
	dSuppMatrix [i*4+3] = dCompMatrix [i*4+3];
	} /* end for */
    }
else
    {

    /*| This is not a support for pipe */
    status=
    om$send( msg=message VRGeneric.VRGetOrigCoor
		    (&retmsg,
		    dCompOrg,
		    &LocEnv),
	    targetid = GoGrid.objid,
	    targetos = GoGrid.osnum);
    as$status ( action = RET_STATUS );

    for (i=0;i<3;i++)
	{
	dSuppMatrix [i*4+3] = dCompOrg [i];
	} /* end for */

    } /* end if this a Support for pipe */

/*^
printf ("Origin Put for Hanger\n");
printf ("%lf,%lf,%lf\n", dSuppMatrix [3], dSuppMatrix [7], dSuppMatrix [11]);
*/


for (i=0;i<3;i++)
    {
    dY [i]	 =	me->dOrientation [0] * dCompMatrix [i*4] + 
			me->dOrientation [1] * dCompMatrix [i*4+1] +
			me->dOrientation [2] * dCompMatrix [i*4+2]; 
    } /* end for */

BSnorvec (&rc,dY);
/*^
	printf ("Orientation of support in Component Ref\n");
	    printf ("%lf,%lf,%lf\n",
	    dY [0], dY [1], dY [2]);
*/

dX [0] = 1.0;
dX [1] = dX [2] = 0.0;

/*| Compute Z axis */
BScrossp (&rc,dX,dY,dZ);
if (rc != BSSUCC)
    {
    /*| ERROR -> Z not COMPUTED */
    return ( OM_E_ABORT );
    }
if ( BSlenvec (&rc, dZ) < VRGetTol(VR_DIST_TOL))
    {
    /*| Trying with last vector */
    dX [1] = 1.0;
    dX [0] = dX [2] = 0.0;
    BScrossp (&rc,dX,dY,dZ);
    if (rc != BSSUCC)
	{
	/*| ERROR -> Z not COMPUTED */
	return ( OM_E_ABORT );
	}
    } /* end if */

/* -- Recompute X axis to get an orthogonal matrix -- */
BSnorvec (&rc,dZ);
BScrossp ( &rc, dY, dZ, dX );
if ( rc != BSSUCC )
    {
    /*| ERROR -> X not COMPUTED */
    return ( OM_E_ABORT );
    }

/* -- Fill In Matrix -- */
for (i=0;i<3;i++)
    {
    dSuppMatrix [i*4] = dX [i];
    dSuppMatrix [i*4+1] = dY [i];
    dSuppMatrix [i*4+2] = dZ [i];
    dSuppMatrix [i+12] = 1.0;
    }

/* -- Homothetie factor -- */
dSuppMatrix [15] = 1;

/*^
	printf ("Matrix Computed for Hanger\n");
	for (i=0;i<4;i++)
	    {
	    printf ("%lf,%lf,%lf,%lf\n",
	    dSuppMatrix [i*4], dSuppMatrix [i*4+1],
	    dSuppMatrix [i*4+2], dSuppMatrix [i*4+3]);
	    }
*/
/*^
printf ("BSlenvec (X,Y,Z) = %lf,%lf,%lf\n",BSlenvec (&rc,dX),
		BSlenvec (&rc,dY), BSlenvec (&rc,dZ));
*/

return ( OM_S_SUCCESS );

} /* end VRGetMatrix */

/***********************************************************************/


method VRGetDefName ( IGRlong   *msg; IGRchar *sMacroName )
{

*msg = MSSUCC;

strcpy ( sMacroName, "Pp_supp" );

return ( OM_S_SUCCESS );

} /* end VRGetDefName */


/***********************************************************************/

method VRGetAttributes ( IGRlong *msg;  struct tagVRSupAttr *VRSupAttr )

{
*msg = MSSUCC;

if ( VRSupAttr != NULL )
    {
    *VRSupAttr = me->VRSupAttr;
    }
else
    {
    /*| ERROR -> NULL GIVEN AS POINTER */
    *msg = MSFAIL;
    return ( OM_E_INVARG );
    }

return ( OM_S_SUCCESS );

} /* end VRGetAttributes */

/***********************************************************************/

method VRGetInstance ( IGRlong	*msg; struct VRGenInfo *Instance )

{
register IGRint  i;
IGRint status;

*msg = MSSUCC;

/* -- Get super class instance -- */
status =
	om$send ( msg = message VRGeneric.VRGetInstance
						    (msg, Instance),
		mode     = OM_e_wrt_message,
		targetid = my_id );
as$status ();

/* -- Give Support Orientation and factor relative to correction length -- */
for (i=0;i<3;i++)
    Instance->Attr.Supp.dOrientation [i] = me->dOrientation [i];

Instance->Attr.Supp.dFactor = me->dFactor;
Instance->VRSupAttr	= me->VRSupAttr;
/*^
printf ("Instances got from support are:\n");
printf ("dFactor=%lf\ndOrientation=(%lf,%lf,%lf)\n",
			Instance->Attr.Supp.dFactor,
			Instance->Attr.Supp.dOrientation [0],
			Instance->Attr.Supp.dOrientation [1],
			Instance->Attr.Supp.dOrientation [2]);
*/


return ( OM_S_SUCCESS );

}/* end VRGetInstance */

/***********************************************************************/

method VRGetParams( IGRlong *msg; 	struct GRid *SysParamId;
					struct GRid *UserParamId;
					struct GRid *MissParamId )

{

	IGRlong		retmsg;
	IGRint		status;

	/* -- Get parameter boxes from the component I am attached to -- */

	*msg = MSSUCC;

	{
		/* -- Get Component Id -- */
		struct GRid		CompId,TempId;
		struct GRmd_env		LocEnv;
		OM_S_CHANSELECT 	father;

		/*| Get Component from channel */

		father.type = OM_e_name;
		father.u_sel.name = "father";

		status =
		om$get_objid_at_index (	object	= me,
				p_chanselect	= &father,
				index 		= 0,
				objidaddr	= &TempId.objid,
				osnumaddr	= &TempId.osnum);
		as$status ( action = RET_STATUS );

		/* -- Return the template component id -- */
		/*|  get Component's id - using ACreturn_foot */
		status=
		om$send (msg = message NDmacro.ACreturn_foot
				(&retmsg,
				"",
				&CompId,
				&LocEnv.md_env.matrix_type,
				LocEnv.md_env.matrix),
			targetid = TempId.objid,
			targetos = TempId.osnum);
		/*"Neigh (os,id) = (%d,%d)\n",CompId.osnum,CompId.objid */
		as$status ( action = RET_STATUS );

		/* -- Resend the message to my component -- */
		status=
		om$send (msg = message VRGeneric.VRGetParams
				(&retmsg, SysParamId, UserParamId, MissParamId ),
			targetid = CompId.objid,
			targetos = CompId.osnum);
		as$status ( action = RET_STATUS );

	}/* end get neighbors info */



return ( OM_S_SUCCESS );

}/* end VRGetParams */

/***********************************************************************/

method VRGetTopo ( IGRlong *msg ; IGRint BufSize;
			IGRint	 	*NbCpts;
			IGRdouble	*dCompOrig;
			IGRdouble	*dCpCoors;
			struct GRid 	*NeiIds;
			IGRshort 	*nNeiCpNum;
			struct GRmd_env *md_env)
{

	IGRint		status;
	IGRlong		retmsg;
	IGRint			Index=-1;
	struct ret_struct	ParamStr;

*msg = MSSUCC;

if ( !NbCpts )
{
	/*| ERROR -> CANNOT RETURN NUMBER OF CPTS */
	return (OM_E_INVARG);
}

	/* -- Return nb cpts -- */
	*NbCpts = 1;

	/* -- Return Origin point -- */
	if ( dCompOrig )
	{
		/*| Return origin point */
		status=
		om$send ( msg = message ACncpx.ACgive_structure(
				(IGRint *)&retmsg,&Index, VR_N_LOC_PT,
				&ParamStr, md_env),
			targetid = my_id);
		as$status ( action = RET_STATUS );
		if ( !(retmsg&1) ) return OM_E_ABORT;
		dCompOrig[0]=ParamStr.var.point_st.pt[0];
		dCompOrig[1]=ParamStr.var.point_st.pt[1];
		dCompOrig[2]=ParamStr.var.point_st.pt[2];
	}

	/* -- Check on bufsize -- */

	if ( (BufSize < 1 ) )
	{
		/*| ERROR -> BUFFER TOO SMALL*/
		*msg=MSFAIL;
		return OM_E_INVARG;
	}

	/* -- Return CptsCoords -- */
	if ( dCpCoors )
	{
		/* -- Return same value as Origin point -- */

		/*| Return Cp Coors */
		status=
		om$send ( msg = message ACncpx.ACgive_structure(
				(IGRint *)&retmsg,&Index, VR_N_LOC_PT,
				&ParamStr, md_env),
			targetid = my_id);
		as$status ( action = RET_STATUS );
		if ( !(retmsg&1) ) return OM_E_ABORT;
		dCpCoors[0]=ParamStr.var.point_st.pt[0];
		dCpCoors[1]=ParamStr.var.point_st.pt[1];
		dCpCoors[2]=ParamStr.var.point_st.pt[2];

	}/* end return connect points' coordinates  */

	if ( nNeiCpNum )
	{
		/* -- a component has no connect point for the supports -- */
		*nNeiCpNum = -1;
	}

	if ( NeiIds )
	{
		struct GRid		CompId;
		struct GRmd_env		LocEnv;
		OM_S_CHANSELECT 	father;

		/*| Get Component from channel */

		father.type = OM_e_name;
		father.u_sel.name = "father";

		status =
		om$get_objid_at_index (	object		= me,
				p_chanselect	= &father,
				index 		= 0,
				objidaddr	= &CompId.objid,
				osnumaddr	= &CompId.osnum);
		as$status ( action = RET_STATUS );

		/* -- Return the template component id -- */
		/*|  get Component's id - using ACreturn_foot */
		status=
		om$send (msg = message NDmacro.ACreturn_foot
				(&retmsg,
				"",
				NeiIds,
				&LocEnv.md_env.matrix_type,
				LocEnv.md_env.matrix),
			targetid = CompId.objid,
			targetos = CompId.osnum);
		/*"Neigh (os,id) = (%d,%d)\n",NeiIds[0].osnum,NeiIds[0].objid */
		as$status ( action = RET_STATUS );

	}/* end get neighbors info */

return ( OM_S_SUCCESS );

}/* end VRGetInstance */

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

	*msg=MSSUCC;

	*NbNeigh=1;

	if (NeiId)
	{
		/* return the component that I support */
		struct GRid		CompId;
		struct GRmd_env		LocEnv;
		OM_S_CHANSELECT 	father;

		/*| Get Component from channel */

		father.type = OM_e_name;
		father.u_sel.name = "father";

		status =
		om$get_objid_at_index (	object		= me,
				p_chanselect	= &father,
				index 		= 0,
				objidaddr	= &CompId.objid,
				osnumaddr	= &CompId.osnum);
		as$status ( action = RET_STATUS );

		/* -- Return the template component id -- */
		/*|  get Component's id - using ACreturn_foot */
		status=
		om$send (msg = message NDmacro.ACreturn_foot
				(&retmsg,
				"",
				NeiId,
				&LocEnv.md_env.matrix_type,
				LocEnv.md_env.matrix),
			targetid = CompId.objid,
			targetos = CompId.osnum);
		as$status ( action = RET_STATUS );
		/*"Neigh (os,id) = (%d,%d)\n",NeiId[0].osnum,NeiId[0].objid */

	}/* end get neighbors info */

	if (nNeiCpNum)	*nNeiCpNum=-1;

return OM_S_SUCCESS;

}/* end VRGetNeighbors */

/***********************************************************************/

end implementation VRHanger;
