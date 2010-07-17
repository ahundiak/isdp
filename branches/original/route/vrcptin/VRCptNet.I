/* $Id: VRCptNet.I,v 1.1.1.1 2001/01/04 21:12:50 cvs Exp $  */

/* I/ROUTE
 *
 * File:	vrcptin/VRCptNet.I
 *
 * Description:
 *
 *	This contains the implementation for all the methods
 *	accessing the network connections.
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	12/09/94	Bruno		Creation
 *	10/07/94	Manyam		Modified the method SelectCptByGeom
 *					to do required processing for
 *					dangles while routing the message
 *					to the original graphics object.
 */
class implementation VRCptIn;

#define AS_DEBUG	1

/**************************************************************************/

method VRGetCptNum ( IGRshort *nCptNum )
{
	*nCptNum = me->nCpNum;
	return OM_S_SUCCESS;
}

/**************************************************************************/

method VRGetCptGeom (IGRlong *msg ;IGRshort nCpNum;
		     IGRdouble *dCptCoor; IGRdouble *dConAxis;
		     IGRdouble *dOrientation; struct GRmd_env *md_env)

{
	IGRint			status;
	struct GRid		CompId;
	struct GRmd_env		NewEnv;

	/* -- Get real component id -- */

	/* initialize nNewEnv */
	NewEnv=*md_env;

	status= om$send (
		msg = message ASnode.ASreturn_go
			( &CompId, &NewEnv.md_env.matrix_type, NewEnv.md_env.matrix),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	/* -- Send message back to real component -- */

	status =
	om$send ( msg = message VRGeneric.VRGetCptGeom
				( msg, nCpNum, dCptCoor, dConAxis, dOrientation, &NewEnv),
	targetid = CompId.objid,
	targetos = CompId.osnum);

	/* -- KLUDGE for connection to dangles accross ref files -- */

	if ( dConAxis )
	{ 
		IGRshort nType;

		status =
		om$send ( msg      = message VRGeneric.VRGetSysType
					(msg, &nType),
		targetid = CompId.objid,
		targetos = CompId.osnum);

		if ( nType == VR_DANGLING )
		{
			/* -- Return connection axis -- */
			/*| Dangle KLUDGE CptGEOM */
			dConAxis[0] *= -1.0;
			dConAxis[1] *= -1.0;
			dConAxis[2] *= -1.0;
		}
	}/* end kludge dangles */
 
return (status);

} /* end VRGetCptGeom */

/**************************************************************************/

method	VRSelectCptByGeom (
	IGRlong		*msg ;
	IGRdouble	*dConPos; 
	IGRdouble	*dConVect; 
	IGRshort 	*nCpNum;
	struct GRmd_env *md_env
)
{
	IGRint			status;
	struct GRid		CompId;
	struct GRmd_env		NewEnv;

	/*A initialize nNewEnv */
	NewEnv=*md_env;

	/*A Get real component id */
	status= 
	om$send ( msg = message ASnode.ASreturn_go (
			&CompId, &NewEnv.md_env.matrix_type,
			NewEnv.md_env.matrix),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	/*A Handle the dangle in a special manner	*/
	{
		IGRshort	nSysType;

		/*A Get the system type	*/
		status =
		om$send ( msg      = message VRGeneric.VRGetSysType(
				msg, &nSysType),
			targetid = CompId.objid,
			targetos = CompId.osnum);
		as$status ( action = RET_STATUS );

		if ( nSysType == VR_DANGLING )
		{
			/*A Reverse the connection axis */
			dConVect[0] *= -1.0;
			dConVect[1] *= -1.0;
			dConVect[2] *= -1.0;
		}
	}

	/*A Send message back to real component	*/
	status=
	om$send ( msg = message VRGeneric.VRSelectCptByGeom(
			msg, dConPos, dConVect, nCpNum, &NewEnv),
		targetid = CompId.objid,
		targetos = CompId.osnum);

	return (status);

} /* end VRSelectCptByGeom */

/**************************************************************************/

method VRGetNumberOfCpts (IGRlong *msg ;IGRint *NbCpts; struct GRmd_env *md_env )
{
	IGRint			status;
	struct GRid		CompId;
	struct GRmd_env		NewEnv;

	/* -- Get real component id -- */

	/* initialize nNewEnv */
	NewEnv=*md_env;

	status= om$send (
		msg = message ASnode.ASreturn_go
			( &CompId, &NewEnv.md_env.matrix_type, NewEnv.md_env.matrix),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	/* -- Send message back to real component -- */

	status=
	om$send ( msg = message VRGeneric.VRGetNumberOfCpts
				( msg, NbCpts, &NewEnv),
	targetid = CompId.objid,
	targetos = CompId.osnum);

return (status);

}/* end VRGetNumberOfCpts */

/***********************************************************************/

method VRGetCptProp (IGRlong *msg ;IGRshort nCpNum;struct VRcp_attr *ConProp;
			struct GRmd_env *md_env )
{
	/* ---------- METHOD:      VRGetCptProp ---------- */
	IGRint			status;
	struct GRid		CompId;
	struct GRmd_env		NewEnv;

	/* -- Get real component id -- */

	/* initialize nNewEnv */
	NewEnv=*md_env;

	status= om$send (
		msg = message ASnode.ASreturn_go
			( &CompId, &NewEnv.md_env.matrix_type, NewEnv.md_env.matrix),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	/* -- Send message back to real component -- */

	status=
	om$send ( msg = message VRGeneric.VRGetCptProp
				( msg, nCpNum, ConProp, &NewEnv),
	targetid = CompId.objid,
	targetos = CompId.osnum);

return (status);

} /* end VRGetCptProp */

/**************************************************************************/

end implementation VRCptIn;

