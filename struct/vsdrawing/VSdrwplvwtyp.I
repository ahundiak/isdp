/* $Id: VSdrwplvwtyp.I,v 1.1.1.1 2001/01/04 21:10:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSdrwplvwtyp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwplvwtyp.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:34  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.3  1996/01/31  07:07:16  pinnacle
# Replaced: vsdrawing/VSdrwplvwtyp.I for:  by svkadamb for struct
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/STRUCT
*/
class implementation VSplate ;

#include <stdio.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "bserr.h"
#include "bstypes.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "EMSmsgdef.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsdrw.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "bsdotp.h"
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
long VSdrwGetViewTypeFromPlate( msg, inp, xData )

long		*msg ;		/* OUT : completion code	*/
VSdrwInputData	*inp ;		/* I/O : input data		*/
VSdrwExecData	*xData ; {	/* IN  : execution data		*/

	/*
	 * This function returns the view type of a plate.
	 *
	 * SIDE / TOP / BOTTOM :
	 * =====================
	 *
	 *		   ^
	 *		   |			<- view vector. ( view type is
	 *							  TOP )
	 *	-------------------------
	 * <-	|			|	<- plate.
	 *  ^	-------------------------
	 *  |	-------------------------	<- support surface.
	 * view vector
	 * ( view type is  |			<- view vector. ( view type is
	 *   SIDE )	   v					  BOTTOM )
	 *
	 */

	long			sts ;		/* OM completion code.	*/
	BSrc			rc ;		/* BS return code.	*/
	struct GRid		*plId ;		/* Id of plate		*/
	struct GRmd_env 	*plEnv ;	/* Mod. env. of plate	*/
	double			*viewVector,	/* View vector		*/
				angle ;		/* Half of vw cone angle*/
	IGRvector		normal ;	/* Normal of bottom surf*/

	SetProc( VSdrwGetViewTypeFromPlate ); Begin

	plId		= inp->elmId ;
	plEnv		= inp->elmEnv ;
	viewVector	= inp->drwInfo.viewVector ;
	inp->viewType	= VSunknownViewType ;
	angle		= 0.5 * xData->overrides.viewConeAngle ;

	/*
	 * `xData->overrides.viewConeAngle' is in degrees, convert `angle' to
	 * radians.
	 */
	angle		= angle * M_PI / 180. ;

	__DBGpr_obj( "Plate", *plId ) ;
	__DBGpr_vec( "View vector", viewVector ) ;

	/*
	 * Get bottom side of plate.
	 */
	sts = om$send(	msg	= message VSfeature.VSforwardToSource(
				&rc,
				OM_e_wrt_object,
				message VSfeature.VSgetNormalOfComponent(
					msg, plEnv, VS_K_plBotSfPath,
					0.5, 0.5, normal ) ),
			senderid= plId->objid,
			targetid= plId->objid,
			targetos= plId->osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSforwardToSource", wrapup ) ;

	__DBGpr_vec( "Normal of bottom surface", normal ) ;

	/*
	 * See if the normal of bottom surface is colinear to view vector.
	 * Thus, in this case if the dot product between the view vector
	 * and the normal is >0, the view type is 'Top', otherwise the view
	 * type is 'Bottom'.
	 *
	 *		^
	 *		|	      <- view vector ( view type is 'Top' ).
	 *
	 *	-------------------
	 *	|	^	  |   <- plate.
	 *	|	|(n)	  |   <- (n) normal of bottom surface.
	 *	-------------------   <- bottom surface.
	 *
	 *		|	      <- view vector ( view type is 'Bottom' ).
	 *		v
	 */
	if( VSareaColinearVectors( normal, viewVector, angle ) ) {
		if( BSdotp( &rc, normal, viewVector ) >0 ) {
			__DBGpr_com( "View type is TOP" ) ;
			inp->viewType = VSfromTop ;
		} else {
			__DBGpr_com( "View type is BOTTOM" ) ;
			inp->viewType = VSfromBottom ;
		}

		goto wrapup ;
	}

	/*
	 * Here the normal of bottom surface isn't colinear to view vector.
	 * See if is orthogonal to view vector, thus, in this case the view
	 * type is 'Side'.
	 *
	 *		  ^
	 *		   \  <- view vector #0
	 *
	 *	  ------------------------		     view vector #1
	 *	  |\			  \			     |
	 *	  \ \			   \			     v
	 * <-	   \ \			    \	 <- plate.	     ->
	 *  ^	    \ \ 	^	     \
	 *  |	     \ \	| (n)	      \  <- (n) normal of bottom
	 * view       \ \		       \	surface.
	 * vector #3   \ ------------------------
	 *		\|			|
	 *		 ------------------------ <- bottom surface.
	 *
	 *			    \  <- view vector #2
	 *			     v
	 *
	 * For the 4 view vectors the view type is 'Side'.
	 */
	if( VSorthoVectors( normal, viewVector ) ) {
		__DBGpr_com( "View type is SIDE" ) ;
		inp->viewType = VSfromSide ;
	} else vs$inv_arg() ;

	wrapup :
		if( *msg == EMS_E_InvalidArg ) {
			__DBGpr_com( "Invalid case !!!" ) ;
		}

		End
		return sts ;

} /* VSdrwGetViewTypeFromPlate */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
