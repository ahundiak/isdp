/*
	I/STRUCT
*/
class implementation VSbeam ;

#include <stdio.h>
#include "DImacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
long VSfindIfXvecOfPrflReversed( msg, bmId, bmOs, bmEnv, sf, axis, reversed )

long			*msg ;
OM_S_OBJID		bmId ;
OMuword			bmOs ;
struct GRmd_env		*bmEnv ;
struct GRobj_env	*sf,
			*axis ;
int			*reversed ; {

	long			sts ;
	struct GRvg_construct	cst ;
	struct IGRdisplay	dsp ;
	struct GRid		xsId,
				beginCap ;
	GRname			name ;
	GRrange			beginCapRng,
				prflRng ;
	IGRboolean		world = TRUE ;
	static char		active = FALSE ;

	if( active ) {
		*reversed = FALSE ; *msg = MSSUCC ; return OM_S_SUCCESS ;
	}
	active = TRUE ;

	xsId.objid = NULL_OBJID ;

	/*
	 * Beam must be in 3d !
	 */

	dsp.color	= 1 ;
	dsp.weight	= 0 ;
	dsp.style	= 0 ;

	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= bmEnv,
				Display		= &dsp,
				Level		= 1,
				Cnst_list	= cst ) ;

	sts = om$send(	msg	= message VSbeam.VSextractProfile(
								msg,
								bmEnv,
								sf,
								axis,
								0.,
								&cst,
								AC_3D_REP,
								&xsId ),
			senderid= NULL_OBJID,
			targetid= bmId,
			targetos= bmOs ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetCrossSectionCS", wrapup ) ;

	DIstmcpy(	name,
			VS_K_bmGrCmpName,
			VS_K_bmBeginCap,
			NULL ) ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							name,
							&beginCap,
							NULL,
							NULL ),
			senderid= NULL_OBJID,
			targetid= bmId,
			targetos= bmOs ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	sts = om$send(	msg	= message GRgraphics.GRgetrang(
						msg,
						&cst.env_info->_MATRIX_TYPE,
						cst.env_info->_MATRIX,
						&world,
						prflRng ),
			senderid= NULL_OBJID,
			targetid= xsId.objid,
			targetos= xsId.osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	sts = om$send(	msg	= message GRgraphics.GRgetrang(
						msg,
						&bmEnv->_MATRIX_TYPE,
						bmEnv->_MATRIX,
						&world,
						beginCapRng ),
			senderid= NULL_OBJID,
			targetid= beginCap.objid,
			targetos= beginCap.osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	if(    VSeqPoints( prflRng + 0, beginCapRng + 0 ) 
	    && VSeqPoints( prflRng + 3, beginCapRng + 3 ) ) {
	    	*reversed = FALSE ;
	} else	*reversed = TRUE ;

	wrapup :
		active = FALSE ;
		vs$bulk_delete(	grids	= &xsId,
				theEnv	= cst.env_info ) ;
		return sts ;

} /* VSfindIfXvecOfPrflReversed */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;

