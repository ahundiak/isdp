/*
	I/STRUCT
*/
#include "OMerrordef.h"
#include "msdef.h"
#include "VSmsg.h"
#include "vswelddef.h"

static	long	VSweldCodes[VS_K_MAX_WLD_TYPES]	= {

	/* Internal code		Message key of description	*/
	/*								*/
	/* VS_K_wldFillet	*/	VS_I_wldFillet		,
	/* VS_K_wldPlugSlot	*/	VS_I_wldPlugSlot	,
	/* VS_K_wldSpotPrj	*/	VS_I_wldSpotPrj		,
	/* VS_K_wldSeam		*/	VS_I_wldSeam		,
	/* VS_K_wldGrvSqr	*/	VS_I_wldGrvSqr		,
	/* VS_K_wldGrvV		*/	VS_I_wldGrvV		,
	/* VS_K_wldGrvBvl	*/	VS_I_wldGrvBvl		,
	/* VS_K_wldGrvU		*/	VS_I_wldGrvU		,
	/* VS_K_wldGrvJ		*/	VS_I_wldGrvJ		,
	/* VS_K_wldGrvFlrV	*/	VS_I_wldGrvFlrV		,
	/* VS_K_wldGrvFlrBvl	*/	VS_I_wldGrvFlrBvl	,
	/* VS_K_wldBacking	*/	VS_I_wldBacking		,
	/* VS_K_wldSurfacing	*/	VS_I_wldSurfacing	,
	/* VS_K_wldFlgEdge	*/	VS_I_wldFlgEdge		,
	/* VS_K_wldFlgCorner	*/	VS_I_wldFlgCorner	,
} ;
/*----------------------------------------------------------------------------*/
long VSgetWeldCodes( msg, count, list )

long		*msg,
		**list ;
int		*count ; {

	/*
	 * This function is interfaced by macro `vs$getWeldCodes' defined
	 * in vsjntmacros.h
	 */

	*list	= VSweldCodes ;
	*count	= VS_K_MAX_WLD_TYPES ;

	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /* VSgetWeldCodes */
/*----------------------------------------------------------------------------*/
long VSgetWeldCodeDescr( index ) int index ; {

	return index < VS_K_MAX_WLD_TYPES ? VSweldCodes[index] : MS_NO_MSG ;

} /* VSgetWeldCodeDescr */
/*----------------------------------------------------------------------------*/

