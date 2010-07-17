/*
	I/STRUCT

	This function interfaced by macro vs$offsetCurveAlongDirectionVector
*/
class implementation GRcurve ;

#include <stdio.h>
#include "bserr.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bscrossp.h"
#include "bscveval.h"

from GRowner	import GRget_number_components ;

extern OMuword	OPP_GRcompcurve_class_id ;
extern long	VSchgEMSseverity __(( long )) ;
/*----------------------------------------------------------------------------*/
long VSoffsetCurveAlongDirectionVector( msg, cvId, cvEnv, offset, direction,
					cst, offCvId )

long			*msg ;
struct GRid		*cvId ;
struct GRmd_env 	*cvEnv ;
double			offset ;
IGRvector		direction ;
struct GRvg_construct	*cst ;
struct GRid		*offCvId ; {

	long			sts,
				bsRC,
				cnt ;
	int			offCode    = BSCONSTOFF,
				*p_offCode = NULL ;
	double			tanAt05[6],
				*p_offset  = NULL ;
	IGRvector		normal ;
	struct IGRbsp_curve	*cvGeom    = NULL ;
	struct IGResbc		esbc ;
	char			*saveClassAttr ;

	/*
	 * Check that offset is beyond offset tolerance and positive.
	 */
	if( offset <= 0. ) offset = 0. ;
	else {
		double	offTol ; /* System's offset tolerance	*/

		BSEXTRACTPAR( msg, BSTOLOFFSET, offTol ) ;
		if( offset <= offTol ) offset = 0. ;
	}

	if( offset == 0. ) {
		*offCvId	= *cvId ;
		*msg		= EMS_I_Fail ;
		sts		= OM_S_SUCCESS ;
		goto wrapup ;
	}

	offCvId->objid = NULL_OBJID ;

	/*
	 * Get geometry of curve to offset.
	 */
	sts = vs$get_geometry( msg	= msg,
			       grobjId	= cvId,
			       grobjEnv = cvEnv,
			       geometry = &cvGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * Compute normal vector to offseting curve. In the message EMcvoffset,
	 * the direction vector is :
	 *  - argument right_side = TRUE  => direction is TANGENT x NORMAL.
	 *  - argument right_side = FALSE => direction is -( TANGENT x NORMAL ).
	 * Thus, normal vector should be DIRECTION x TANGENT with argument
	 * right_side = TRUE.
	 */
	BScveval( cvGeom, 0.5, 1, (IGRpoint *) tanAt05, &bsRC ) ;
	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	BScrossp( &bsRC, direction, tanAt05 + 3, normal ) ;

	/*
	 * Offset curve.
	 */
	if( vs$is_ancestry_valid( object  = cvId,
				  classid = OPP_GRcompcurve_class_id ) ) {
		int	count, i ;

		sts = om$send( msg	=
					message GRowner.GRget_number_components(
								       msg,
								       &count ),
			       senderid = cvId->objid,
			       targetid = cvId->objid,
			       targetos = cvId->osnum ) ;
		__CheckRC( sts, *msg, "GRowner.GRget_number_components",
			   wrapup ) ;

		if( !( p_offCode = _MALLOC( count, int	  ) ) ) vs$mem_fail() ;
		if( !( p_offset  = _MALLOC( count, double ) ) ) vs$mem_fail() ;

		for( i=0; i<count; i++ ) {
			p_offCode[i] = BSCONSTOFF ;
			p_offset[i]  = offset ;
		}
	} else {
		p_offCode = &offCode ;
		p_offset  = &offset ;
	}

	sts = om$send( msg	= message GRvg.GRgetattr( msg,
							  (char *) &esbc ),
		       senderid = cvId->objid,
		       targetid = cvId->objid,
		       targetos = cvId->osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	saveClassAttr	= cst->class_attr ;
	cst->class_attr = (char *) &esbc ;

	sts = om$send( msg	= message GRcurve.EMcvoffset(
							   msg,
							   &cvEnv->_MATRIX_TYPE,
							   cvEnv->_MATRIX,
							   cst,
			/* Offset distance	*/	   p_offset,
			/* Normal vector	*/	   normal,
			/* Right side		*/	   TRUE,
			/* Uniform		*/	   TRUE,
			/* Offset code		*/	   p_offCode,
			/* Fillet		*/	   FALSE,
			/* Remove loops 	*/	   TRUE,
			/* Offset curve 	*/	   offCvId,
			/* # of loops (unused)	*/	   &cnt,
							   NULL,
							   NULL ),
		       senderid = cvId->objid,
		       targetid = cvId->objid,
		       targetos = cvId->osnum ) ;

	cst->class_attr = saveClassAttr ;

	*msg = VSchgEMSseverity( *msg ) ;
	__CheckRC( sts, *msg, "GRcurve.EMcvoffset", wrapup ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		_FREE( cvGeom ) ;
		if( p_offCode && p_offCode != &offCode ) _FREE( p_offCode ) ;
		if( p_offset  && p_offset  != &offset  ) _FREE( p_offset  ) ;

		return sts ;

} /* VSoffsetCurveAlongDirectionVector */
/*----------------------------------------------------------------------------*/

end implementation GRcurve ;
