/*
	I/STRUCT

	This function interfaced by macro "vs$get_normal".
*/
class implementation EMSsubbs ;

#include <stdio.h>
#include <stdlib.h>
#include "igrtypedef.h"
#include "igr.h"
#include "bserr.h"
#include "bstypes.h"
#include "EMSssprops.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bssfevaln.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
long VSgetNormal( msg, sfId, sfEnv, parm, normal )

long		*msg ;
struct GRid	*sfId ;
struct GRmd_env *sfEnv ;
double		parm[2] ;
IGRvector	normal ; {

	long			bsRC,
				sts = OM_S_SUCCESS ;
	struct GRprops		gprops ;
	int			num ;
	double			u,
				v ;
	IGRpoint		pntOnSurface ;
	unsigned char		props ;
	struct IGRbsp_surface	*sfGeom = NULL ;

	/*
	 * Make sure the input element is a surface, in case of wrong argument
	 * we're in for crash...
	 */
	sts = om$send(	msg	= message GRvg.GRgeomprops(
							msg,
							&sfEnv->_MATRIX_TYPE,
							sfEnv->_MATRIX,
							&gprops ),
		       senderid = NULL_OBJID,
		       targetid = sfId->objid,
		       targetos = sfId->osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgeomprops", wrapup ) ;

	if( gprops.type != GRSURFACE ) vs$inv_arg() ;
			
	/*
	 * Get geometry of surface.
	 */
	vs$get_geometry( msg		= msg,
			 grobjId	= sfId,
			 grobjEnv	= sfEnv,
			 geometry	= &sfGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;
	
	/*
	 * Get normal at given parameters if any. Otherwise get normal in the 
	 * middle of the surface.
	 */
	if( parm ) {
		u = parm[0] ;
		v = parm[1] ;
	} else {
		u = v = 0.5 ;
	}
	
	BSsfevaln( sfGeom,
		   u,
		   v,
		   1,
		   &num,
		   pntOnSurface,
		   (IGRvector *) normal,
		   &bsRC ) ;
	if( BSERROR( bsRC ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	/*
	 * See if surface has a normal reversed.
	 */
	sts = om$send( msg	= message EMSsubbs.EMget_props( msg, &props ),
		       senderid = NULL_OBJID,
		       targetid = sfId->objid,
		       targetos = sfId->osnum ) ;
	__CheckRC( sts, *msg, "EMSsubbs.EMget_props", wrapup ) ;

	if( props & EMSIS_NRML_REVERSED ) VSnegvc( normal, normal ) ;

	wrapup :
		_FREE( sfGeom ) ;
		return sts ;

} /* VSgetNormal */
/*----------------------------------------------------------------------------*/

end implementation EMSsubbs ;

