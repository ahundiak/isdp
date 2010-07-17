/*
	I/STRUCT
*/
class implementation VSmrkPlate ;

#include "EMSmsgdef.h"
#ifndef emsmapdef_include
#	include "emsmapdef.h"
#endif
#ifndef emsimpdef_include
#	include "emsimpdef.h"
#endif
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

from   EMSsurface  import	EMimpose_boundaries ;
/*----------------------------------------------------------------------------*/
method VSimposeBoundary(	long			*msg ;
				int			bndryCount ;
				struct GRobj_env	bndryList[],
							*surface ;
				int			surfaceIsPlane ) {

	long		sts ;			/* OM return code	*/
	long		mapOptions ;		/* For impose-boundaries*/
#define MAX VS_K_MAX_BOUNDARIES
	struct GRlc_info
			bndryInfo[MAX] ;
	int		i ;			/* Loop index		*/

	for( i = 0 ; i < bndryCount ; i++ ) {
		bndryInfo[i].located_obj = bndryList[i]._grid ;
		bndryInfo[i].module_info = bndryList[i].mod_env ;
		bndryInfo[i].geom_parms.polygon_inx = FALSE ;
	}
	mapOptions =   EMMapBnd_WantBadCurves
		     | EMMapBnd_StrokeIfNeeded
	             | EMMapBnd_WantStatMsg
	             | EMMapBnd_NoClip
	             | EMMapBnd_NoValidate
	             | EMMapBnd_NoFixing ;
	if( surfaceIsPlane ) mapOptions |= EMMapBnd_SurfIsPlane ;

	sts = om$send( msg = message EMSsurface.EMimpose_boundaries(
					msg,
					bndryCount,
					NULL,	/* No bound. buffers	*/
					bndryInfo,
					NULL,
					FALSE,	/* No area		*/
					&surface->mod_env,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					mapOptions,
					  EMImpBnd_NoStateTree
					| EMImpBnd_PlaceFeatures,
					NULL
					),
                   targetid = surface->_objid, 
		   targetos = surface->_osnum ) ;

	if( *msg == EMS_I_NoMoreLoops ) {
		/*
		 * No valid markings to impose.
		 */
		*msg	= EMS_E_NoMoreLoops ;
		sts	= OM_W_ABORT ;
		goto wrapup ;
	}

	__CheckRC( sts, *msg, "EMSsurface.EMimpose_boundaries", wrapup ) ;

	wrapup :
		return sts ;

} /* method VSimposeBoundary */
/*----------------------------------------------------------------------------*/

end implementation VSmrkPlate ;
