/*
	I/STRUCT
*/
class implementation EMSsubbs ;

/*
Function VSdisplaySurfaceNormal

Abstract
	Displays a surface's normal on the screen.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	*surface	Surface
	IN	int			normalReversed	Is normal reversed ?
	IN	struct IGRdisplay	*display	Display attr. of normal
	IN	enum GRdpmode		mode		Display mode of normal
*/
#include <stdio.h>
#include "msdef.h"
#include "exmacros.h"
#include "growner.h"
#include "EMSssprops.h"
#include "EMSdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "EMSifmacros.h"
#include "EMSpromacros.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
long VSdisplaySurfaceNormal( msg, surface, normalReversed, display, mode )

long			*msg ;
struct GRobj_env	*surface ;
int			normalReversed ;
struct IGRdisplay	*display ;
enum GRdpmode		mode ; {

	long			sts ;		/* OM return code	*/
	struct IGRbsp_surf	*geometry ;	/* surface's geometry	*/
	IGRpoint		point ;		/* Point on surface	*/
	IGRvector		normal ;	/* Normal of surface	*/
	IGRboolean		worldRef ;	/* For GRgetrang	*/
	GRrange			range ;		/* Range of surface	*/
	unsigned char		props ;		/* Props of surface	*/
	struct EMparms		params ;
	struct GRmd_env		dspEnv ;	/* Display environment	*/
/*
 * The paramteric value at which the oriented surface normal is to be drawn.
 * It is off-centre in the hope that the asymmetry will more likely assure a
 * non-cusp point on the surface.
 */
#define DRAW_U 0.48
#define DRAW_V 0.48

	sts = om$send(	msg	= message EMSsurface.EMget_point_on_surface(
                          				msg,
                          				&surface->mod_env,
                          				0, 1, NULL,
                          				&params ),
			senderid= surface->_objid,
			targetid= surface->_objid,
			targetos= surface->_osnum ) ;
	if( !( sts & 1 & *msg ) ) {
		/*
		 * If any error continue ...
		 */
		params.u = DRAW_U ;
		params.v = DRAW_V ;
		*msg = MSSUCC ;
		sts  = OM_S_SUCCESS ;
	}

	sts = om$send(	msg	= message GRvg.GRgenabsg(
							msg,
							&surface->_matrix_type,
							surface->_matrix,
							(char **) &geometry ),
			senderid= surface->_objid,
			targetid= surface->_objid,
			targetos= surface->_osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgenabsg", wrapup ) ;

	EMavgsfnorm( msg, geometry, params.u, params.v, point, normal ) ;

	worldRef = FALSE ;
	sts = om$send(	msg	= message GRvg.GRgetrang(
							msg,
							&surface->_matrix_type,
							surface->_matrix,
							&worldRef,
							range ),
			senderid= surface->_objid,
			targetid= surface->_objid,
			targetos= surface->_osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetrang", wrapup ) ;

	sts = om$send(	msg	= message EMSsubbs.EMget_props( msg, &props ),
			senderid= surface->_objid,
			targetid= surface->_objid,
			targetos= surface->_osnum ) ;
	__CheckRC( sts, *msg, "EMSsubbs.EMget_props", wrapup ) ;

	if( props & EMSIS_NRML_REVERSED ) {
		VSnegvc( normal, normal ) ;
	}
	if( normalReversed ) {
		VSnegvc( normal, normal ) ;
	}

	/*
	 * Must use the module of the master file.
	 */
	dspEnv = surface->mod_env ;
	ex$get_cur_mod( id = &dspEnv._MD_ID, osnum = &dspEnv._MD_OS ) ;
	EFdraw_vector_on_screen( surface->_objid, display, &dspEnv,
				 mode, FALSE, point, normal, range, msg ) ;

	wrapup :
		if( !( sts & 1 ) ) *msg = MSFAIL ;
		return sts ;

} /* VSdisplaySurfaceNormal */
/*----------------------------------------------------------------------------*/

end implementation EMSsubbs ;
