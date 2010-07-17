/* $Id: VSbbgetrange.I,v 1.1.1.1 2001/01/04 21:10:11 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsbeam/VSbbgetrange.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * Created: vsbeam/VSbbgetrange.I by svkadamb for struct
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      03/31/98        suresh          creation
 ***************************************************************************/ 
/*
	I/STRUCT
*/ 
class implementation VSbooBeam ;

#include <string.h>
#include "EMSmsgdef.h"
#include "vsipthmacros.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsmkpenetcyl.h"
#include "vsprtinasbly.h"
#include "vsvirtualinf.h"

// from	VSfeature	import	VSforwardToSoure ;
/*----------------------------------------------------------------------------*/
method GRgetrang (IGRlong 		*msg ;
		  IGRshort 		*matrix_type ;
		  IGRmatrix 		matrix ;
		  IGRboolean 		*world ;
		  GRrange 		range) {

	long 		sts;
	long 		notUsed ;
 
	sts = om$send(  msg = message VSfeature.VSforwardToSource(
					&notUsed,
					OM_e_wrt_object,
					message GRgraphics.GRgetrang(
							msg, 
							matrix_type, 
							matrix,
							world, 
							range)) ,
			targetid = my_id );
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	return sts;
 
wrapup:
	sts = om$send( msg = message GRowner.GRgetrang(
						msg, 
						matrix_type, 
						matrix,
						world, 
						range),
			mode = OM_e_wrt_message,
			targetid= my_id ) ;
	return sts;

} /* method GRgetrang */
/*----------------------------------------------------------------------------*/

end implementation VSbooBeam ;
