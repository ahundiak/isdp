/*
	I/STRUCT
*/
class implementation VSbeam ;

#include "OMerrordef.h"
#include "exmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "bstypes.h"
#include "bserr.h"
#include "grdpbdef.h"		/* Constants for DPB		*/
#include "grdpbmacros.h"	/* Macros for DPB		*/
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "EMSifmacros.h"
/*----------------------------------------------------------------------------*/
method VSshowOrientation(	long			*msg ;
				struct GRmd_env		*myEnv ;
				int			wantReverse ;
				enum GRdpmode		pen ;
				struct IGRdisplay	*symbology ) {

	long			sts ;		/* OM completion code	*/
	int			i,		/* Loop index		*/
				myOrient ;	/* My orientation	*/
	GRrange			beamRange ;	/* Of beam segment	*/
	IGRboolean		world = TRUE ;	/* For GRgetrang	*/
	struct GRid		segment ;	/* Id of foot		*/
	IGRpoint		endp[2] ;	/* End points of segment*/
	IGRvector		unit ;		/* Between end points	*/
	struct IGRdisplay	actDisp ;	/* Active display	*/
	struct GRmd_env		dspEnv ;	/* DIsplay environment	*/

	/*
	 * WARNING! `wantReversed' not taken into account here yet!.
	 */

	if( !symbology ) {
		int	size =  sizeof( struct IGRdisplay ),
			nret ;

		symbology = &actDisp ;
		gr$get_active_display(	msg	= msg,
					sizbuf	= &size,
					nret	= &nret,
					buffer	= symbology ) ;
	}

	sts = om$send(	msg	= message VSpart.VSgetOrientation(
							msg, &myOrient ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSpart.VSgetOrientation", wrapup ) ;

	if( !myOrient ) {
		sts = om$send(	msg	= message VSpart.VSshowOrientation(
						msg, myEnv, wantReverse,
						pen, symbology ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		goto wrapup ;
	}
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg,
						VS_K_bmGrCmpName,
						&segment,
						NULL, NULL ),
			targetid= my_id ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	sts = om$send(	msg	= message GRgraphics.GRgetrang(
							msg,
							&myEnv->_MATRIX_TYPE,
							myEnv->_MATRIX,
							&world,
							beamRange ),
			targetid= segment.objid,
			targetos= segment.osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	/*
	 * Artificially increase range to have a bigger-than-life arrow.
	 */
	for( i = 0 ; i < 6 ; i++ ) beamRange[i] *= 2 ;

	sts = om$send(	msg	= message VSbeam.VSgetSegmentEnds(	msg,
									myEnv,
									endp ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSegmentEnds", wrapup ) ;

	if( myOrient == VS_K_RevOrient ) {
		BSmkvec( msg, unit, endp[1], endp[0] ) ;
	} else {
		BSmkvec( msg, unit, endp[0], endp[1] ) ;
	}
	BSnorvec( msg, unit ) ;

	if( *msg == BSDGENRAT ) unit[0] = 1. ;

	/*
	 * Must use the module id of the master file !
	 */
	dspEnv = *myEnv ;
	ex$get_cur_mod( id = &dspEnv._MD_ID, osnum = &dspEnv._MD_OS ) ;
	EFdraw_vector_on_screen(my_id,
				symbology,
				&dspEnv,
				pen,
				myOrient == VS_K_RevOrient,
				endp[0],
				unit,
				beamRange,
				msg ) ;
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;
	wrapup :
		return sts ;

} /* method VSshowOrientation */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
