/*
	I/VDS	Copy

	This function interfaced by macro "vd_$get_normal".
*/
class implementation EMSsubbs ;

#include <stdio.h>
#include <stdlib.h>
#include "igrtypedef.h"
#include "igr.h"
#include "bserr.h"
#include "bstypes.h"
#include "EMSssprops.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bssfevaln.h"
#include "v_vecmxproto.h"
extern double *VD_negvc( const double *in , double *out );

/*----------------------------------------------------------------------------*/
long VD_getNormal( msg, sfId, sfEnv, parm, normal )

long		*msg ;
struct GRid	*sfId ;
struct GRmd_env *sfEnv ;
IGRdouble	parm[2] ;
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
	double                  *sts_dbl=NULL ;

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

	if( gprops.type != GRSURFACE ) vd_$inv_arg() ;
			
	/*
	 * Get geometry of surface.
	 */
	vd_$get_geometry( msg		= msg,
			 grobjId	= sfId,
			 grobjEnv	= sfEnv,
			 geometry	= &sfGeom ) ;
	__CheckRC( 1, *msg, "vd_$get_geometry", wrapup ) ;
	
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

	if( props & EMSIS_NRML_REVERSED ) sts_dbl = VD_negvc( normal, normal ) ;

	wrapup :
		_FREE( sfGeom ) ;
		return sts ;

} /* VD_getNormal */
/*----------------------------------------------------------------------------*/

end implementation EMSsubbs ;

