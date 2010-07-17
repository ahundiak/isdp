class implementation VRflowdir;

/*
#define vdsDEBUG 1 
*/

#include "AS_status.h"
#include "VRcompdef.h"
#include "vrdbgmacros.h"

from	NDnode		import	NDchange_node;
from	VRGeneric	import	VRGetNextOnCpt,
				VRGetNumberOfCpts,
				VRSetFlow;


IGRint VRPropagateFlow (StartId,
			CompId, nCptNum,
			nFlowDir, dFlowRate,
			md_env )
struct GRid	*StartId;	/* Id of the first component to infinite loops */
struct GRid	*CompId;	/* Id of the first component to infinite loops */
IGRshort	nCptNum;	/* Cpt already initialized */
IGRshort	*nFlowDir;	/* Flow direction VR_FLOW_IN or VR_FLOW_OUT */
IGRdouble	*dFlowRate;	/* Flow rate */
struct GRmd_env	*md_env;

{
  IGRshort		NbVia, nNextCptNum, nPropCptNum, nOppFlow;
  IGRint		status, NbCpts;
  IGRlong		retcode;
  struct	GRid	NextId;

/* KDD June 1997.
* As of today we propagate flow direction usign VRCorrection.VRPropagateFlow.
* In other words the function VRflowdir.VRPropagateFlow is not used.
*
* dFlowRate was never used from the caller VRflowdir.VRReverseFlowDir
******/
printf("\nVRflowdir.VRPropagateFlow function is no longer used.\n"
       "Flow direction is propagated using VRCorrection.VRPropagateFlow.\n");

if (1) return OM_S_SUCCESS;




	/* KDD since we set the flow on the next component => invert flow */
	nOppFlow = - (*nFlowDir); 

/* ------------------------------------------------------- */
/* -- Conditions to propagate :				-- */
/* -- 		2 Cpts 					-- */
/* -- 		a component connected to the second cpt	-- */
/* ------------------------------------------------------- */

	/* -- Get component connected on the propagation cpt -- */
	NbVia = 0;
	status =
	om$send( msg      = message VRGeneric.VRGetNextOnCpt
			( &retcode, nCptNum, &NextId,
			&nNextCptNum, 0, &NbVia, NULL, 
			NULL, md_env ),
		senderid = NULL_OBJID,
		targetid = CompId->objid,
		targetos = CompId->osnum );

__DBGpr_obj("VRGetNextOnCpt for component", *CompId);
__DBGpr_obj("Next", NextId);

	as$status( action = RET_STATUS );

/* -- If there is no further component:  END OF PROPAGATION -- */
 	if( NextId.objid == NULL_OBJID ) return (OM_S_SUCCESS) ; 

	/* -- set the opposite flow in my other connection point -- */
	status =
	om$send( msg      = message VRGeneric.VRSetFlow
			( &retcode, nNextCptNum , &nOppFlow,
			dFlowRate, md_env ),
		senderid = NULL_OBJID,
		targetid = NextId.objid,
		targetos = NextId.osnum );
	as$status ( action = RET_STATUS );


	/* -- Notify dependancies to recompute -- */
	status =
	om$send( msg = message NDnode.NDchange_node ( md_env ),
		senderid = NULL_OBJID,
		targetid = NextId.objid,
		targetos = NextId.osnum );
	as$status();

/* -- If Loop on start element		:  END OF PROPAGATION -- */
	if (NextId.objid == StartId->objid ) return OM_S_SUCCESS;

	/* -- Get Number of connection points -- */
	status =
	om$send( msg      = message VRGeneric.VRGetNumberOfCpts
			( &retcode, &NbCpts, md_env ),
		senderid = NULL_OBJID,
		targetid = NextId.objid,
		targetos = NextId.osnum );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );

/* -- If NOT Two Connection points : END OF PROPAGATION -- */
	if ( NbCpts != 2 ) return OM_S_SUCCESS;

	/* -- Compute propagation Cpt Number -- */
	nPropCptNum = NbCpts - nNextCptNum - 1;


/* -- Else : CONTINUE PROPAGATION -- */


	/* -- Continue propagation -- */	
	status =
	VRPropagateFlow(StartId,
			&NextId, nPropCptNum,
			nFlowDir, dFlowRate, md_env);

	return status;

}/* end of VRPropagate Flow */


end implementation VRflowdir;
