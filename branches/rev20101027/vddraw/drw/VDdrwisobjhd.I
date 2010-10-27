/* $Id: VDdrwisobjhd.I,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDdrwisobjhd.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwisobjhd.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  21:24:46  pinnacle
# Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1995/08/16  14:52:24  pinnacle
# Replaced: vddraw/drw/VDdrwisobjhd.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			adz		creation date
 *	08/15/95	adz		code correction.
 *	10/30/97	ah		warning messages
 ***************************************************************************/
class implementation VDSroot ;

#include <stdio.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "OMmacros.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "v_vedef.h"
#include "v_globalmsg.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsdotp.h"
#include "bsmkvec.h"
#include "v_drwproto.h"
#include "v_virtualinf.h"
#include "v_visedproto.h"
#include "v_vecmxproto.h"
/*----------------------------------------------------------------------------*/
%safe
static int VD_refineRngRngOrder(	const GRrange	rng1,
				const GRrange	rng2,
				const IGRvector vwvc ) {

	const double*	min1	= rng1 + 0 ;
	const double*	min2	= rng2 + 3 ;
	const double*	max1	= rng1 + 0 ;
	const double*	max2	= rng2 + 3 ;
	double		tmin1 ;
	double		tmax1 ;
	double		tmin2 ;
	double		tmax2 ;
	long		rc ;
	double		min	= MAXDOUBLE ;
	int		i	= 0 ;

/* BS does not know 'const' ! */
#define BSDOTP( m, u, v )  BSdotp( (m), (double *) (u), (double *) (v) )

	tmin1 = BSDOTP( &rc, vwvc, min1 ) ;
	tmin2 = BSDOTP( &rc, vwvc, min2 ) ;
	tmax1 = BSDOTP( &rc, vwvc, max1 ) ;
	tmax2 = BSDOTP( &rc, vwvc, max2 ) ;

	if( tmin1 < min ) { min = tmin1 ; i = 1 ; }
	if( tmax1 < min ) { min = tmax1 ; i = 1 ; }
	if( tmin2 < min ) { min = tmin2 ; i = 2 ; }
	if( tmax2 < min ) { min = tmax2 ; i = 2 ; }

	return i ;

} /* VD_refineRngRngOrder */
%endsafe
/*----------------------------------------------------------------------------*/
long VD_drwIsObjectHiddenByObject( msg, obj1Id, obj1Env,
				       obj2Id, obj2Env, viewVector, hidden )

long			*msg ;
const struct GRid	*obj1Id ;
const struct GRmd_env	*obj1Env ;
const struct GRid	*obj2Id ;
const struct GRmd_env	*obj2Env ;
const IGRvector		viewVector ;
int			*hidden ; {

	long		sts ;		/* OM completion code.		*/
	GRrange 	bmRange ;	/* Range of beam		*/
	GRrange 	plRange ;	/* Range of plate		*/
	short		world = TRUE ;	/* Range in world coords	*/
	int		relationship ;
	int		mustRefine ;
	IGRvector	normal ;	/* Normal of bottom side	*/


	SetProc( VD_drwIsObjectHiddenByObject ); Begin

	sts = OM_S_SUCCESS ;

	__DBGpr_obj( "Object1 #0", *obj1Id ) ;
	__DBGpr_obj( "Object2 #1", *obj2Id ) ;
	__DBGpr_mat( "Mx #0", obj1Env->_MATRIX ) ;
	__DBGpr_mat( "Mx #1", obj2Env->_MATRIX ) ;

	*hidden    = FALSE ;
	mustRefine = FALSE ;

#define OBJ2_ENV ((struct GRmd_env *) obj2Env)
#define OBJ1_ENV ((struct GRmd_env *) obj1Env)
#define TWO_DEGREES ( 2. / 180. * M_PI )

        if( VD_areaOrthoVectors( viewVector, normal, TWO_DEGREES ) )
		goto wrapup ;

	sts = om$send( msg	= message GRgraphics.GRgetrang(
						  msg,
						  &OBJ1_ENV->_MATRIX_TYPE,
						  OBJ1_ENV->_MATRIX,
						  &world,
						  bmRange ),
		       senderid = obj1Id->objid,
		       targetid = obj1Id->objid,
		       targetos = obj1Id->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	sts = om$send( msg	= message GRgraphics.GRgetrang(
						  msg,
						  &OBJ2_ENV->_MATRIX_TYPE,
						  OBJ2_ENV->_MATRIX,
						  &world,
						  plRange ),
		       senderid = obj2Id->objid,
		       targetid = obj2Id->objid,
		       targetos = obj2Id->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	sts = VD_veRangeRangeRelationShip(	msg,
						plRange,	/* Range #0 */
						bmRange,	/* Range #1 */
						viewVector,
						&relationship ) ;
	__CheckRC( sts, *msg, "VD_veRangeRangeRelationShip", wrapup ) ;

	/*
	 * The description of the relationships is as follows:
	 *		.	 .
	 *	(A)	.   (B)  .	(C)
	 *		.	 .
	 *		+--------+
	 *..............|	 |................
	 *		|range 0 |
	 *		+--------+
	 *
	 *		   (E)
	 *		    ^
	 *		    | view vector
	 *
	 * VD_K_0_TOTALLY_HIDES_1  : range #1 in (B)
	 * VD_K_0_PARTIALLY_HIDES_1: range #1 across boundary (A)/(B) ot (B)/(C)
	 * VD_K_0_IN_FRONT_OF_1    : range #1 in (A) or (C)
	 * VD_K_0_AT_THE_BACK_OF_1 : range #1 in (E)
	 * VD_K_INTERSECT	   : range #0 and range #1 intersect
	 */
	switch( relationship ) {

		case VD_K_INTERSECT		:
		/*
		 * Plate range and beam range intersect.
		 */
		*hidden 	= FALSE ;
		mustRefine	= TRUE ;
		break ;

		case VD_K_0_TOTALLY_HIDES_1	:
		/*
		 * Plate range totally hides beam range.
		 */
		*hidden 	= TRUE ;
		mustRefine	= FALSE ;
		break ;

		case VD_K_0_PARTIALLY_HIDES_1	:
		/*
		 * Plate range partially hides beam range.
		 */
		*hidden 	= FALSE ;
		mustRefine	= TRUE ;
		break ;

		case VD_K_0_IN_FRONT_OF_1	:
		/*
		 * Plate range is in front of beam range.
		 */
		*hidden 	= FALSE ;
		mustRefine	= FALSE ;
		break ;

		case VD_K_0_AT_THE_BACK_OF_1	:
		/*
		 * Plate range is at the back of beam range.
		 */
		mustRefine	= FALSE ;
		*hidden 	= FALSE ;
		break ;

	}
	__DBGpr_int( "Range/range relationship", relationship ) ;

	/*
	 * Refine if needed. The plate hides the beam only if the dot product
	 * between the view vector and the vector middle point of beam's range
	 * to middle point of plate's range is >0.
	 *
	 *		^
	 *		|		<- view vector.
	 *
	 *	-------------------
	 *	|		  |	<- range of plate.
	 *	|	^	  |
	 *	--------|----------
	 *	     |	    |		<- range of beam.
	 *	     --------
	 *
	 * The plate hides the beam.
	 *
	 *		^
	 *		|		<- view vector.
	 *
	 *	     --------
	 *	     |	    |		<- range of beam.
	 *	--------|----------
	 *	|	v	  |	<- range of plate.
	 *	|		  |
	 *	-------------------
	 *
	 * The plate doesn't hide the beam.
	 */
	if( mustRefine ) {
/* ALAIN
		long		bsRC ;
		IGRpoint	bmRngMid,
				plRngMid ;
		IGRvector	bmTopl ;

		VD_midpoint( bmRange, bmRange +3, bmRngMid ) ;
		VD_midpoint( plRange, plRange +3, plRngMid ) ;

		BSmkvec( &bsRC, bmTopl, bmRngMid, plRngMid ) ;

		if( BSdotp( &bsRC, viewVector, bmTopl ) > 0. ) {
			__DBGpr_com( "Plate hides beam" ) ;
			*hidden = TRUE ;
		} else {
			__DBGpr_com( "Plate doesn't hide beam" ) ;
			*hidden = FALSE ;
		}
*/
		__DBGpr_com( "Refine" ) ;
		*hidden = 1 == VD_refineRngRngOrder( bmRange, plRange,
							viewVector ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :

		End
		return sts ;
#undef OBJ2_ENV
#undef OBJ1_ENV

} /* VD_drwIsObjectHiddenByObject */

#argsused  // Warning message

/*----------------------------------------------------------------------------*/
int VD_drwIsObjectHidden( msg, inp, xData, hidden )

long			*msg ;
const VD_drwInputData	*inp ;
const VD_drwExecData	*xData ;
int			*hidden ; {

	/*
	 * This function finds whether if the object being drawn is hidden or
	 * not by another  in the list of selected elements.
	 */

	long		sts ;		/* OM completion code.		      */
	int		i ;		/* Loop index.			      */
	struct GRid	virtualId ;	/* Virtual object of the element in   */
					/*   the list of selected elements.   */
	struct GRmd_env virtualEnv ;	/* Env. of the above.		      */

	SetProc( VD_drwIsObjectHidden ); Begin

	__DBGpr_obj( "Object to draw", *(inp->elmId) ) ;
	__DBGpr_mat( "Object mx", inp->elmEnv->_MATRIX ) ;

	*hidden = FALSE ;

	/*
	 * For each element in the list, test if the input object is hidden by
	 * some other object.
	 */
	__DBGpr_int( "Count of elements in list", inp->toBeDrawn.elmCount ) ;

	for( i = 0 ; i < inp->toBeDrawn.elmCount ; i++ ) {
		/*
		 * Get virtual info of element in the list.
		 */
#ifdef vdsDEBUG
	printf( "Processing" ) ; VD_ShowObj( inp->toBeDrawn.elmList + i ) ;
#endif
		sts = VD_getVirtualInfo( msg,
					inp->toBeDrawn.elmList + i,
					&virtualEnv,
					&virtualId ) ;

		__CheckRC( sts, *msg, "VD_getVirtualInfo", wrapup ) ;

#ifdef vdsDEBUG
		printf( "-> " ) ; VD_ShowObj( &virtualId ) ;
#endif

		/*
		 * Here the element is a plate. See if it hides the input beam.
		 */
		sts = VD_drwIsObjectHiddenByObject( msg,
						inp->elmId,
						inp->elmEnv,
						&virtualId,
						&virtualEnv,
						inp->drwInfo.viewVector,
						hidden ) ;

		__CheckRC( sts, *msg, "VD_drwIsObjectHiddenByObject", wrapup ) ;

		if( *hidden ) {
			__DBGpr_com( "Object is HIDDEN by element" ) ;
			break ;
		} else {
			__DBGpr_com( "Object is NOT HIDDEN by element" ) ;
		}
	}

	__DBGpr_int( "Is Object hidden ?", *hidden ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VD_drwIsObjectHidden */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
