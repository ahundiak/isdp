/*
	I/VDS	Copy
*/
#ifndef v_measmacros_include
#	define v_measmacros_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef igr_include
#	include "igr.h"
#endif
#ifndef igrdp_include
#	include "igrdp.h"
#endif
#ifndef godef_include
#	include "godef.h"
#endif
#ifndef go_include
#	include "go.h"
#endif
#ifndef v_include
#	include "v_.h"
#endif

/*+M
Macro vd_$get_area_props

Abstract
	Returns integral-calculus area properties of surface.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*surfId		Surface/solid.
	IN	struct GRmd_env	*surfEnv	Surface/solid's mod. env.
	OUT	double		*area
	OUT	IGRpoint	centroid
	OUT	double		moment[6]
-M*/
extern long
VD_getAreaProps			__((	long			*msg,
					struct GRid		*surfId,
					struct GRmd_env		*surfEnv,
					double			*area,
					IGRpoint		centroid,
					double			moment[6] )) ;

#omdef	vd_$get_area_props(	msg,
				surfId,
				surfEnv,
				area	= NULL,
				centroid= NULL,
				moment	= NULL )
	VD_getAreaProps( (msg), (surfId), (surfEnv),
			(area), (centroid), (moment) )
#endomdef

/*+M
Macro vd_$get_mass_props

Abstract
	Returns integral-calculus mass properties of surface/solid.
Arguments
	OUT	long		*msg		Completion code
	IN	struct GRid	*surfId		Surface/solid.
	IN	struct GRmd_env	*surfEnv	Surface/solid's mod. env.
	IN	double		density		Density of object.
	OUT	double		*volume
	OUT	double		*area
	OUT	IGRpoint	centroid
	OUT	double		moment[6]
	OUT	double		*mass
-M*/
extern long
VD_getMassProps			__((	long			*msg,
					struct GRid		*surfId,
					struct GRmd_env		*surfEnv,
					double			density,
					double			*volume,
					double			*area,
					IGRpoint		centroid, 
					double			moment[6],
					double			*mass )) ;

#omdef	vd_$get_mass_props(	msg,
				surfId,
				surfEnv,
				density,
				volume	= NULL,
				area	= NULL,
				centroid= NULL,
				moment	= NULL,
				mass	= NULL )
	VD_getMassProps( (msg), (surfId), (surfEnv), (density),
			(volume), (area), (centroid), (moment), (mass) )
#endomdef

#endif
