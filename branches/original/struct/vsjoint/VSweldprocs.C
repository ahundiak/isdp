/*
	I/STRUCT
*/
#include "OMerrordef.h"
#include "msdef.h"
#include "VSmsg.h"
#include "vswelddef.h"

static long	VSweldProcesses[VS_K_MAX_WLD_PROCS] = {

	/* VS_K_wldUndefProc	*/ VS_I_wldUndefProc	,
	/* VS_K_wldCAW		*/ VS_I_wldCAW		,
	/* VS_K_wldCW		*/ VS_I_wldCW		,
	/* VS_K_wldDB		*/ VS_I_wldDB		,
	/* VS_K_wldDFW		*/ VS_I_wldDFW		,
	/* VS_K_wldEBW		*/ VS_I_wldEBW		,
	/* VS_K_wldEW		*/ VS_I_wldEW		,
	/* VS_K_wldEXW		*/ VS_I_wldEXW		,
	/* VS_K_wldFB		*/ VS_I_wldFB		,
	/* VS_K_wldFCAW		*/ VS_I_wldFCAW		,
	/* VS_K_wldFOW		*/ VS_I_wldFOW		,
	/* VS_K_wldFRW		*/ VS_I_wldFRW		,
	/* VS_K_wldFW		*/ VS_I_wldFW		,
	/* VS_K_wldGMAW		*/ VS_I_wldGMAW		,
	/* VS_K_wldGTAW		*/ VS_I_wldGTAW		,
	/* VS_K_wldIB		*/ VS_I_wldIB		,
	/* VS_K_wldIRB		*/ VS_I_wldIRB		,
	/* VS_K_wldIW		*/ VS_I_wldIW		,
	/* VS_K_wldLBW		*/ VS_I_wldLBW		,
	/* VS_K_wldOAW		*/ VS_I_wldOAW		,
	/* VS_K_wldOHFW		*/ VS_I_wldOHFW		,
	/* VS_K_wldPAW		*/ VS_I_wldPAW		,
	/* VS_K_wldPEW		*/ VS_I_wldPEW		,
	/* VS_K_wldPGW		*/ VS_I_wldPGW		,
	/* VS_K_wldRB		*/ VS_I_wldRB		,
	/* VS_K_wldRPW		*/ VS_I_wldRPW		,
	/* VS_K_wldRSEW		*/ VS_I_wldRSEW		,
	/* VS_K_wldRSW		*/ VS_I_wldRSW		,
	/* VS_K_wldSAW		*/ VS_I_wldSAW		,
	/* VS_K_wldSMAW		*/ VS_I_wldSMAW		,
	/* VS_K_wldSW		*/ VS_I_wldSW		,
	/* VS_K_wldTB		*/ VS_I_wldTB		,
	/* VS_K_wldTW		*/ VS_I_wldTW		,
	/* VS_K_wldUSW		*/ VS_I_wldUSW		,
	/* VS_K_wldUW		*/ VS_I_wldUW
} ;
/*----------------------------------------------------------------------------*/
long VSgetWeldProcesses( msg, count, list )

long		*msg,
		**list ;
int		*count ; {

	/*
	 * This function is interfaced by macro `vs$getWeldProcesses' defined
	 * in vsjntmacros.h
	 */


	*list	= VSweldProcesses ;
	*count	= VS_K_MAX_WLD_PROCS ;

	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /* VSgetWeldProcesses */
/*----------------------------------------------------------------------------*/
long VSgetWeldProcessDescr( index ) int index ; {

	return index < VS_K_MAX_WLD_PROCS ? VSweldProcesses[index] : MS_NO_MSG ;

} /* VSgetWeldProcessDescr */
/*----------------------------------------------------------------------------*/

