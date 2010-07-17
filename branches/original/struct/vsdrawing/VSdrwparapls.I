/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
int VSdrwArePlatesParallel( msg, plate1, plate2, parallel )

long			*msg ;		/* Completion code	*/
const struct GRobj_env	*plate1 ;	/* First plate		*/
const struct GRobj_env	*plate2 ;	/* Second plate		*/
int			*parallel ; {	/* TRUE/FALSE		*/

	/*
	 * Finds whether two planar plates are parallel.
	 * Return code (*msg) :
	 * - MSINARG	: one of the object is not a plate.
	 * - MSSUCC	: successful completion (even if plates were not planar)
	 */

	long		sts ;
	unsigned long	type ;
	struct IGRplane	plane ;
	IGRpoint	point ;
	IGRvector	normal1,
			normal2 ;

	*parallel = FALSE ;

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, &type ),
			senderid= plate1->_objid,
			targetid= plate1->_objid,
			targetos= plate1->_osnum ) ;
	if( !( sts & 1 & *msg ) || !( type & VS_m_PLATE ) ) {
		*msg = MSINARG ; goto wrapup ;
	}

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, &type ),
			senderid= plate2->_objid,
			targetid= plate2->_objid,
			targetos= plate2->_osnum ) ;
	if( !( sts & 1 & *msg ) || !( type & VS_m_PLATE ) ) {
		*msg = MSINARG ; goto wrapup ;
	}

	plane.point	= point ;
	plane.normal	= normal1 ;

	sts = om$send(	msg	= message GRvg.GRdetplane(
						msg,
						(short*) &plate1->_matrix_type,
						plate1->_matrix,
						&plane ),
			senderid= plate1->_objid,
			targetid= plate1->_objid,
			targetos= plate1->_osnum ) ;
	if( !( sts & 1 & *msg ) ) { *msg = MSSUCC ; goto wrapup ; }

	plane.normal	= normal2 ;

	sts = om$send(	msg	= message GRvg.GRdetplane(
						msg,
						(short*) &plate2->_matrix_type,
						plate2->_matrix,
						&plane ),
				senderid= plate2->_objid,
				targetid= plate2->_objid,
				targetos= plate2->_osnum ) ;
	if( !( sts & 1 & *msg ) ) { *msg = MSSUCC ; goto wrapup ; }

	*parallel = VScolinearVectors( normal1, normal2 ) ;
	*msg = MSSUCC ;

	wrapup :
		return *msg & 1 ;

} /* VSdrwArePlatesParallel */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

