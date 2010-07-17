/* $Id: VRNozzInfo.I,v 1.1.1.1 2001/01/04 21:12:59 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrnozzle / VRNozzInfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRNozzInfo.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:59  cvs
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
# Revision 1.3  1996/01/17  00:13:04  pinnacle
# Replaced: vrnozzle/VRNozzInfo.I for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Add prototypes
 *
 *************************************************************************/

class implementation VRNozzle;

#include "bserr.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vrparameters.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsroto.h"

#define AS_DEBUG	1

/***********************************************************************/

method VRGetMatrix ( 	IGRlong *msg; IGRint NbTemp; struct GRid *TempList;
			IGRdouble *dRefMatrix;  struct GRmd_env *md_env)

{
	IGRlong			retmsg;
	IGRint			status;
	struct GRid		RefId;
	struct ret_struct	RefInfo;

/*"Angle to common : %f\n",me->dSecAngle*/


*msg = MSSUCC;

/* -- get referential id -- */

RefId.objid = NULL_OBJID;

if ( TempList != NULL )
{
	/*| Get Referential from list  */
	if ( NbTemp > me->nNbAttr )
		RefId = TempList[me->nNbAttr];
}
else
{
	/*| Get Referential from channel */

	om$send ( msg = message VRNozzle.VRGetRefId
			( &retmsg, &RefId ),
		targetid = my_id);
}

if ( RefId.objid == NULL_OBJID )
{
	status =
	om$send ( msg = message VRGeneric.VRGetMatrix(
					msg,
					NbTemp,
					TempList,
					dRefMatrix,
					md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);

	return status;

}/* end get matrix without topology */

/* -- get Referential's topology -- */

status=
om$send( msg	 = message NDnode.NDgive_structure(&retmsg,&RefInfo,md_env),
	targetid = RefId.objid,
	targetos = RefId.osnum);
as$status ( action = RET_STATUS );


/* -- Fill in Matrix -- */
{
 	register 	IGRint	i;
	IGRdouble 	dX[3],dY[3],dZ[3],dO[3];
	BSrc		rc;

	/* -- fill in temporary variables -- */

	for ( i=0; i<3; i++ )
	{

		/* fill in X temporary axis */
		dX[i] = RefInfo.var.ref_st.t[i*4];

		/* fill in Y temporary axis */
		dY[i] = RefInfo.var.ref_st.t[i*4+1];

		/* fill in Origin temporary point */
		dO[i] = 0;
	}
	
	BSnorvec (&rc, dX);
	BSnorvec (&rc, dY);

	{
		IGRboolean bBooleanVar;

		/* Rotate Y axis */
		bBooleanVar = TRUE;
		BSroto ( &retmsg,dO,dX,&bBooleanVar,&me->dSecAngle,dY,dY );
	}

	if ( retmsg != BSSUCC )
	 {
		/*| ERROR -> Y not ROTATED */
		return ( OM_E_ABORT );
	 }

	/* compute new Z axis */
	BScrossp ( &retmsg, dX, dY, dZ );
	if ( retmsg != BSSUCC )
	 {
		/*| ERROR -> Z not COMPUTED */
		return ( OM_E_ABORT );
	 }

	/* -- modify matrix -- */
 	for ( i=0; i<3; i++ )
	{

		dRefMatrix[i*4]   = dX[i];
		dRefMatrix[i*4+1] = dY[i];
		dRefMatrix[i*4+2] = dZ[i];
		dRefMatrix[i*4+3] = RefInfo.var.ref_st.t[i*4+3];
	}
}/* end fill in matrix */

return ( OM_S_SUCCESS );

}/* end VRGetMatrix */

/***********************************************************************/

method VRGetRefId ( IGRlong *msg; struct GRid *RefId )

{
	/* KLUDGE : MD_ENV SHOULD BE AN OUTPUT ARGUMENT ... */
	IGRint		status;
	OM_S_CHANSELECT father;

/* -- return MSSUCC if I have a non connected connect point -- */
if (me->nNbTopo < me->nNbCpts) 	*msg = MSSUCC;
else				*msg = MSFAIL;

father.type = OM_e_name;
father.u_sel.name = "father";

/* -- The referential is just after the attributes templates -- */
status =
om$get_objid_at_index (	object		= me,
			p_chanselect	= &father,
			index 		= (IGRint) me->nNbAttr,
			objidaddr	= &RefId->objid,
			osnumaddr	= &RefId->osnum);

/*" Coordinate System : <%d,%d>\n",RefId->objid,RefId->osnum */

return ( status );

}


/***********************************************************************/


method VRGetSysType ( IGRlong *msg; IGRshort *nSysType )

{
*msg = MSSUCC;

*nSysType = VR_NOZZLE;

return ( OM_S_SUCCESS );

}/* end VRGetSysType */

/***********************************************************************/


method VRGetIndex ( IGRlong *msg; struct GRid *SegmentId; IGRshort *CompIndex)

{
	IGRint 			status;
	IGRuint			TempIndex;
	IGRint			NbRoots;
	struct GRid		*buffer;
	OM_S_CHANSELECT		father;

father.type = OM_e_name;
father.u_sel.name = "father";


	/* -- Get my templates -- */
	status = 
	om$send( msg	 = message NDnode.NDget_objects(
						ND_ROOT | ND_IN_BUF,
						NULL,
						0,
						&buffer,
						0,
						OM_K_MAXINT,
						&NbRoots ),
	           	targetid = my_id);
	as$status();

	/* -- get specified template index -- */

	status =
	om$get_index ( 	object_c 	= me,
			p_chanselect	= &father,
			objid		= SegmentId->objid,
			indexaddr	= &TempIndex  );
	as$status ( action = RET_STATUS );

	/*" Segment [%d] is querying\n",TempIndex*/
	/*"me->nNbAttr = %d \n",me->nNbAttr*/

	/*" Real Index [%d] in index list\n",TempIndex*/

	if ( 	TempIndex >= (NbRoots - me->nNbTopo) )
	{
		/* -- get index on segment from my list of indexes -- */

		/*"\tMy index is %d\n",me->nIndex[TempIndex]*/

		*msg= MSSUCC;
		*CompIndex = me->nIndex[TempIndex - (NbRoots - me->nNbTopo)];
	}
	else
	{
		/*" ERROR -> Segment index >  (My NbTopo = %d)\n",me->nNbTopo */
		*msg = MSFAIL;
		*CompIndex = -1;
	}

return ( OM_S_SUCCESS );

}/* end VRGetIndex */
/**********************************************************************/

method VRGetInstance ( IGRlong	*msg; struct VRGenInfo *Instance )

{

	IGRint	status;

*msg = MSSUCC;

	/* -- Restore super class instance -- */

	status =
	om$send ( msg = message VRGeneric.VRGetInstance
			(msg, Instance),
		mode     = OM_e_wrt_message,
		targetid = my_id );
	as$status ();


	Instance->Attr.Nozz.dSecAngle = me->dSecAngle;

return ( OM_S_SUCCESS );

}/* end VRGetInstance */

/***********************************************************************/

end implementation VRNozzle;
