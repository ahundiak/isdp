/*
	I/STRUCT
*/
class implementation VSbeam ;

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "DImacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsnameproto.h"
/*----------------------------------------------------------------------------*/
method VStransIPATHToName(	long		*msg ;
				VSixPath	*ipath ;
				GRname		name ) {

	long		sts ;		/* OM return code		*/
	VSobjDef	myDef ;		/* My object definition		*/
	GRname		faceName ;	/* Name of found face		*/
	VSdspRep	myRep ;		/* My display representation	*/

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
			targetid= my_id ) ;
	if( myRep == AC_2D_REP ) {
		/*
		 * I _did_ mean "==" not "&" in the above test.
		 */
		sts = om$send(	msg	= message VSfeature.VStransIPATHToName(
							msg, ipath, name ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		goto wrapup ;
	}
	/*
	 * In solid representation, ipath is { n1, n2, n3 }. If bigger then
	 * beam has undergone a boolean operation of some kind ...
	 */
	sts = om$send(	msg	= message VScpx.VSgetObjDef( msg, &myDef ),
			targetid= my_id ) ;

	strcpy( name, myDef.output.names[ipath->ls[0]] ) ;

	if( ipath->sz > 1 ) switch( ipath->ls[1] ) {

	case 0 :
		/*
		 * Body of beam.
		 */
		DIstrcat( name, VS_K_bmBody ) ;

		if( ipath->sz == 2 ) break ;
		if( ipath->sz > 3 ) goto ANCESTOR ;
		/* 
		 * See if index may be translated to the name of a face
		 * of the profile
 		 */

		sts = om$send(	msg	= message VSbeam.VSfaceIndexToName(
					msg, myRep, ipath->ls[2], faceName ),
				targetid= my_id ) ;
		if( !( sts & 1 & *msg ) ) VSgenCmpName( ipath->ls[2], faceName);

		DIstrcat( name, faceName ) ;
		break ;

	case 1 :
		if( ipath->sz == 2 ) {
			/*
			 * Begin cap.
			 */
			DIstrcat( name, VS_K_bmBeginCap ) ;
		} else goto ANCESTOR ;
		break ;

	case 2 :
		if( ipath->sz == 2 ) {
			/*
		 	 * End cap.
		 	 */
			DIstrcat( name, VS_K_bmEndCap ) ;
		} else goto ANCESTOR ;
		break ;

	default	:
	ANCESTOR:
		/*
		 * Could not decipher path (if beam was booleaned, new faces
		 * may have appeared): let ancestor's method do a rough job.
		 */
		sts = om$send(	msg	= message VSfeature.VStransIPATHToName(
						msg, ipath, name ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	}

	wrapup :
		return sts ;

} /* method VStransIPATHToName */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
