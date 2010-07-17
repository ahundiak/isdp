/*
	I/STRUCT
*/
#ifndef vsmeasmacros_include
#	define vsmeasmacros_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vspart_include
#	include "vspart.h"
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

/*+M
Macro vs$get_area_props

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
VSgetAreaProps			__((	long			*msg,
					struct GRid		*surfId,
					struct GRmd_env		*surfEnv,
					double			*area,
					IGRpoint		centroid,
					double			moment[6] )) ;

#omdef	vs$get_area_props(	msg,
				surfId,
				surfEnv,
				area	= NULL,
				centroid= NULL,
				moment	= NULL )
	VSgetAreaProps( (msg), (surfId), (surfEnv),
			(area), (centroid), (moment) )
#endomdef

/*+M
Macro vs$get_mass_props

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
VSgetMassProps			__((	long			*msg,
					struct GRid		*surfId,
					struct GRmd_env		*surfEnv,
					double			density,
					double			*volume,
					double			*area,
					IGRpoint		centroid, 
					double			moment[6],
					double			*mass )) ;

#omdef	vs$get_mass_props(	msg,
				surfId,
				surfEnv,
				density,
				volume	= NULL,
				area	= NULL,
				centroid= NULL,
				moment	= NULL,
				mass	= NULL )
	VSgetMassProps( (msg), (surfId), (surfEnv), (density),
			(volume), (area), (centroid), (moment), (mass) )
#endomdef

/*+M
Macro vs$placeMomentOfInertia

Abstract
	Creates a graphic object made of the pricipal axes and placed at the
	centroid of the input mass properties of a volume. The created object
	is support-only, ie. vanished when the file is saved or exited.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRvg_construct	*cst		Construction list.
	IN	VSintegral		*mp		Mass propeties.
	OUT	struct GRid		*moment		Graphic object.
-M*/
extern long
VSplaceMomentOfInertia		__((	long			*msg,
					struct GRvg_construct	*cst,
					VSintegral		*mp,
					struct GRid		*moment )) ;

#omdef vs$placeMomentOfInertia( msg, cst, mp, moment )
	VSplaceMomentOfInertia( (msg), (cst), (mp), (moment) )
#endomdef

/*+M
Macro vs$getSfDimensions

Abstract
	An attempt is made to find out two numbers representing the dimensions
	of a surface, like the length and width of a rectangle. This is mainly
	intended to get the dimensions of a plate. Exotic cases of surfaces are
	treated (that is for a plate to lie on ...), but pretty much everything
	is covered (in this latter case we rather get an extent).
	The two output dimensions are such that *width <= *length.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*surfId		Id of surface.
	IN	struct GRmd_env	*surfEnv	Module environment of surface.
	OUT	double		*width		Width of surface.
	OUT	double		*length		Length of surface.
Note
	Only simple surfaces (conics, plane, surfaces of projection/revolution,
	free-form) are covered, not composite surfaces.
-M*/
extern long
VSgetSfDimensions		__((	long			*msg,
					struct GRmd_env 	*sfEnv,
					struct GRid		*sfId,
					double			*width,
					double			*height )) ;

#omdef vs$getSfDimensions( msg, surfEnv, surfId, width, length )
	VSgetSfDimensions( (msg), (surfEnv), (surfId), (width), (length) )
#endomdef

/*+M
Macro vs$lengthAndAreaOfClPlCv

Abstract
	Computes the length and the area enclosed by a closed planar curve.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*curveId	Id of curve.
	IN	struct GRmd_env	*curveEnv	Module environment of curve.
	OUT	double		*length		Length of curve.
	OUT	double		*area		Area of curve.
-M*/
extern long
VSlengthAndAreaOfClPlCv		__((	long			*msg,
					struct GRmd_env		*cvEnv,
					struct GRid		*cvId,
					double			*length,
					double			*area )) ;

#omdef vs$lengthAndAreaOfClPlCv( msg, curveEnv, curveId, length, area )
	VSlengthAndAreaOfClPlCv( (msg), (curveEnv), (curveId), (length), (area))
#endomdef

#endif
