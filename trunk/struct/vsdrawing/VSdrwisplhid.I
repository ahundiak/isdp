/*
	I/STRUCT
*/
class implementation VSplate ;

#include <stdio.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsvedef.h"
#include "vsglobalmsg.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vsvirtualinf.h"
#include "vsvisedproto.h"
/*----------------------------------------------------------------------------*/
int VSdrwIsPlateHidden( msg, inp, xData, hidden )

long			*msg ;
const VSdrwInputData	*inp ;
const VSdrwExecData	*xData ;
int			*hidden ; {

	/*
	 * This function finds whether if the plate being drawn is hidden or
	 * not by a plate in the list of selected elements. The test will be
	 * performed only if the plate in the list is orthogonal to the plate
	 * being drawn.
	 */

	long		sts ;		/* OM completion code.		      */
	int		i,		/* Loop index.			      */
			relationship,	/* Relation ship between two ranges.  */
			orthogonal ;	/* Is it two orthogonal plates ?      */
	struct GRid	virtualId ;	/* Virtual object of the element in   */
					/* the selected list.		      */
	struct GRmd_env virtualEnv ;	/* Env. of the above.		      */
	unsigned long	resultType ;	/* Result type of the element in the  */
					/* selected list.		      */
	short		world = TRUE ;	/* Range in world coordinates.	      */
	GRrange 	plRange,	/* Range of plate to draw.	      */
			elRange ;	/* Range of element in the list.      */

	SetProc( VSdrwIsPlateHidden ); Begin

	__DBGpr_obj( "Plate to draw", *(inp->elmId) ) ;
	__DBGpr_mat( "Plate mx", inp->elmEnv->_MATRIX ) ;

	/*
	 * Input element must be a plate.
	 */
	if( xData->parsedElmType != VS_gI_Plate ) vs$inv_arg() ;

	*hidden = FALSE ;

	/*
	 * Get range of plate to draw.
	 */
#define ENV ((struct GRmd_env*) inp->elmEnv)
	sts = om$send( msg	= message GRgraphics.GRgetrang(
						     msg,
						     &ENV->_MATRIX_TYPE,
						     ENV->_MATRIX,
						     &world,
						     plRange ),
		       senderid = inp->elmId->objid,
		       targetid = inp->elmId->objid,
		       targetos = inp->elmId->osnum ) ;

	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	/*
	 * For each element in the list, if the element isn't the input plate
	 * and is orthogonal to input plate, test if the input plate is hidden
	 * by it.
	 */
	__DBGpr_int( "Count of elements in list", inp->toBeDrawn.elmCount ) ;

	for( i=0; i<inp->toBeDrawn.elmCount; i++ ) {
		/*
		 * Get virtual info of element in the list.
		 */
#ifdef vsDEBUG
	printf( "Processing" ) ; ShowObj( inp->toBeDrawn.elmList + i ) ;
#endif
		sts = VSgetVirtualInfo( msg,
					inp->toBeDrawn.elmList + i,
					&virtualEnv,
					&virtualId ) ;
		if( !( sts & 1 & *msg ) ) continue ;

		__DBGpr_obj( "Element", virtualId ) ;
		__DBGpr_com( "Can hide plate ?" ) ;

		/*
		 * See if the element isn't the input plate.
		 */
		if( IF_EQ_GRID( *(inp->elmId), virtualId ) ) {
			__DBGpr_com( "\t-> No" ) ;
			continue ;
		}

		/*
		 * See if the element is a plate ( Initialize 'msg' to MSFAIL
		 * because images (sub-class of VDrel_hdr) elements return
		 * success if the graphic model does not know the message ).
		 */
		*msg = MSFAIL ;
		sts = om$send( msg	= message VSfeature.VSgetResultType(
								  msg,
								  &resultType ),
			       senderid = virtualId.objid,
			       targetid = virtualId.objid,
			       targetos = virtualId.osnum ) ;

		if( !(sts & 1 & *msg) ) {
			__DBGpr_com( "\t-> No" ) ;
			continue ;
		} else {
			if( !(resultType & VS_m_PLATE) ) {
				__DBGpr_com( "\t-> No" ) ;
				continue ;
			}
		}
		__DBGpr_mat( "Virt mx", virtualEnv._MATRIX ) ;

		/*
		 * Here the element is a plate and not the input plate. See if
		 * it can hide the input plate.
		 */
		sts = om$send( msg	= message GRgraphics.GRgetrang(
						       msg,
						       &virtualEnv._MATRIX_TYPE,
						       virtualEnv._MATRIX,
						       &world,
						       elRange ),
			       senderid = virtualId.objid,
			       targetid = virtualId.objid,
			       targetos = virtualId.osnum ) ;

		if( sts & 1 & *msg ) {
			sts = VSveRangeRangeRelationShip(
							msg,
							elRange,
							plRange,
							inp->drwInfo.viewVector,
							&relationship ) ;

			if( (sts & 1 & *msg) &&
			    ( relationship == VS_K_0_IN_FRONT_OF_1    ||
			      relationship == VS_K_0_AT_THE_BACK_OF_1 ) ) {
				__DBGpr_com( "\t-> No" ) ;
				continue ;
			} else	__DBGpr_com( "\t-> Yes" ) ;
		} else __DBGpr_com( "\t-> Yes" ) ;

		/*
		 * See if the element which can hide the plate is orthogonal
		 * to the input plate.
		 */
		__DBGpr_com( "Is an orthogonal plate ?" ) ;
		sts = VSdrwIsPlateOrthogonalToPlate( msg,
						     inp->elmId,
						     inp->elmEnv,
						     &virtualId,
						     &virtualEnv,
						     &orthogonal ) ;

		__CheckRC( sts, *msg, "VSdrwIsPlateOrthogonalToPlate", wrapup );

		if( !orthogonal ) {
			__DBGpr_com( "\t-> No" ) ;
			continue ;
		}

		__DBGpr_com( "\t-> Yes" ) ;

		/*
		 * Here the element is a plate orthogonal to the the input
		 * plate. See if the input plate is hidden by it.
		 */
		sts = VSdrwIsPlateHiddenByPlate( msg,
						 inp->elmId,
						 inp->elmEnv,
						 &virtualId,
						 &virtualEnv,
						 inp->drwInfo.viewVector,
						 hidden ) ;

		__CheckRC( sts, *msg, "VSdrwIsPlateHiddenByPlate", wrapup ) ;

		if( *hidden ) {
			__DBGpr_com( "Plate is HIDDEN by element" ) ;
			break ;
		} else {
			__DBGpr_com( "Plate is NOT HIDDEN by element" ) ;
		}
	}

	__DBGpr_int( "Is plate hidden ?", *hidden ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VSdrwIsPlateHidden */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
