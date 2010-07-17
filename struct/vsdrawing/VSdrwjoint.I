/*
	I/STRUCT
*/
class implementation VSjoint ;

#include <stdio.h>
#include <malloc.h>
#include "grdpbdef.h"
#include "grdpb.h"
#include "fontdef.h"
#include "font.h"
#include "EMSutlmacros.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsdrw.h"
#include "vsjointdef.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vsgetchanobj.h"

extern void		VSsetGRids() ;
extern long		EFproject_any_curve_on_planen() ;
/*----------------------------------------------------------------------------*/
long VSdrwJoint( msg, inp, xData, outp )

long			*msg ;
VSdrwInputData		*inp ;
VSdrwExecData		*xData ;
VSdrwGraphicGroup	*outp ; {

	/*
	 * This functions extracts the drawing of a joint.
	 */

	long			sts ;		 /* OM completion code.       */
	int			i ;		 /* Loop index. 	      */
	struct GRid		grCmp,		 /* Graphic component of      */
						 /* joint.		      */
				*weldList = NULL,/* List of weld lines of     */
						 /* joint.		      */
				*pjList = NULL ; /* List of projected weld    */
						 /* lines.		      */
	int			weldCount ;	 /* Count of weld lines of    */
						 /* joint.		      */
	struct GRvg_construct	cst ;		 /* Construction list for     */
						 /* projected weld lines.     */
	OMuword 		pjClassid ;	 /* Class of projected weld   */
						 /* lines.		      */

	SetProc( VSdrwJoint ); Begin

	__DBGpr_obj( "Joint to draw", *(inp->elmId) ) ;

	outp->list  = NULL ;
	outp->count = 0 ;

	/*
	 * Construct construction list for projected weld lines.
	 */
	vs$fill_cnst_list( Msg		= msg,
			   Env_info	= inp->drwInfo.drwEnv,
			   Level	= xData->overrides.elmLevel,
			   Display	= &xData->overrides.elmDisplay,
			   Cnst_list	= cst ) ;

	/*
	 * Get graphic component of joint.
	 */
	sts = om$send( msg	= message NDmacro.ACreturn_foot(
							       msg,
							       VS_K_jnGrCmpName,
							       &grCmp,
							       NULL,
							       NULL ),
		       senderid = inp->elmId->objid,
		       targetid = inp->elmId->objid,
		       targetos = inp->elmId->osnum ) ;

	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	__DBGpr_obj( "Graphic component of joint", grCmp ) ;

	/*
	 * Get all weld line(s) of joint.
	 */
	{
	  OM_S_CHANSELECT toCmps ;

	  ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		       chan_selector = &toCmps ) ;

	  sts = VS_GetChanObjWithMalloc( &grCmp, &toCmps,
					 &weldCount, &weldList ) ;
	  __CheckRC( sts, 1, "VS_GetChanObjWithMalloc", wrapup ) ;
	}

	__DBGpr_int( "Count of weld lines", weldCount ) ;

	/*
	 * Project all weld line(s) to drawing plane.
	 */
	if( !( pjList = _MALLOC( weldCount, struct GRid ) ) ) vs$mem_fail() ;
	VSsetGRids( cst.env_info->_MD_OS, weldCount, pjList ) ;

	for( i=0; i<weldCount; i++ ) {

		__DBGpr_obj( "Weld line", weldList[i] ) ;

		sts = EFproject_any_curve_on_planen( msg,
						     &cst,
						     weldList + i,
						     inp->elmEnv,
						     inp->drwInfo.drwPlane,
						     inp->drwInfo.viewVector,
						     pjList + i,
						     &pjClassid ) ;

		__CheckRC( sts, *msg, "EFproject_any_curve_on_planen", wrapup );

		__DBGpr_obj( "-> projection", pjList[i] ) ;
	}

	/*
	 * Remove equal points.
	 */
	sts = VSdrwRmEqualPoints( msg,
				  weldCount,
				  pjList,
				  cst.env_info,
				  &outp->count,
				  &outp->list ) ;

	__CheckRC( sts, *msg, "VSdrwRmEqualPoints", wrapup ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !(sts & 1 & *msg) ) {

			if( pjList )
				vs$bulk_delete( count  = weldCount,
						grids  = pjList,
						theEnv = cst.env_info ) ;

			_FREE( outp->list ) ;
			outp->list  = NULL ;
			outp->count = 0 ;
		}

		_FREE( pjList	) ;
		_FREE( weldList ) ;

		End
		return sts ;

} /* VSdrwJoint */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;
