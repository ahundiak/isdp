/*
	I/STRUCT
*/
#include <stdio.h>
#include "bstypes.h"
#include "bserr.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "comiscmac.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bslngen.h"
#include "GRbclnextend.h"
#include "vsmkinfline.h"

extern OMuword		OPP_GR3dinfline_class_id ;
/*----------------------------------------------------------------------------*/
int VSmake_infinite_line(	long			*msg,
				const IGRpoint		point1,
				const IGRpoint		point2,
				struct GRvg_construct	*cst,
				struct GRid		*infLineId ) {

	struct IGRbsp_curve	InfLine ;
	double			InfLinePoles[12] ;
	double			InfLineKnots[6] ;
	int			type ;

	InfLine.poles	= InfLinePoles ;
	InfLine.knots	= InfLineKnots ;

	BSlngen( msg, (double*) point1, (double*) point2, &InfLine, &type ) ;
	if( BSOKAY( *msg ) ) {
		GRbclnextend( msg, &InfLine, &InfLine ) ;
		if( *msg & 1 ) {

			co$construct_object(
				msg		= msg,
				properties	= cst->properties,
				geometry	= &InfLine,
				module		= cst->env_info,
				symbology	= cst->display,
				level		= &cst->level,
				display_obj	= NULL,
				classid		= OPP_GR3dinfline_class_id,
				cob_id		= NULL_OBJID,
				grid		= infLineId ) ;
		}
	} else *msg = EMS_E_BSerror ;

	return *msg & 1 ;

} /* VSmake_infinite_line */
/*----------------------------------------------------------------------------*/
