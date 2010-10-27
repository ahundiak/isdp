/*
	I/VDS	Copy.
*/
#ifndef v_geommacros_include
#	define v_geommacros_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif
#ifndef igetypedef_include
#	include "igetypedef.h"
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"
#endif
#ifndef gr_include
#	include "gr.h"
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
Macro vd_$is_surface_planar

Abstract
	Tests whether a surface is planar. Either the id and module environment
	of the surface or the geometry of the surface may be input.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*surfId 	Id of surface.
	IN	struct GRmd_env *surfEnv	Module environment of surface.
	IN	struct IGRbsp_surface
				*surfGeom	Geometry of surface.
Note
	Returns TRUE if planar else FALSE :

	is_planar = vd_$is_surface_planar( msg = &msg, etc. ) ;
-M*/
extern int
VD_isSurfacePlanar		__((	long			*msg,
					struct GRid		*surfId,
					struct GRmd_env		*surfEnv,
					struct IGRbsp_surface	*surfGeom )) ;

#omdef	vd_$is_surface_planar(	msg,
				surfId		= NULL,
				surfEnv 	= NULL,
				surfGeom	= NULL )
#	if om$equal( surfGeom, NULL )
#		if om$equal( surfId, NULL ) || om$equal( surfEnv, NULL )
#		omerror "vd_$is_surface_planar: `surfId' or `surfEnv' is NULL."
#		else
			VD_isSurfacePlanar( (msg), (surfId), (surfEnv), NULL )
#		endif
#	else
		VD_isSurfacePlanar( (msg), NULL, NULL, (surfGeom) )
#	endif
#endomdef

/*+M
Macro vd_$is_curve_linear

Abstract
	Tests whether a curve is a line segment. Either the id and module
	environment of the curve or the geometry of the curve may be input.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*curveId	Id of curve.
	IN	struct GRmd_env *curveEnv	Module environment of curve.
	IN	struct IGRbsp_curve
				*curveGeom	Geometry of curve.
Note
	Returns TRUE if linear else FALSE :

	is_linear = vd_$is_curve_linear( msg = &msg, etc. ) ;
-M*/
extern int
VD_isCurveLinear			__((	long			*msg,
					struct GRid		*cvId,
					struct GRmd_env		*cvEnv,
					struct IGRbsp_curve	*cvGeom )) ;

#omdef	vd_$is_curve_linear(	msg,
				curveId 	= NULL,
				curveEnv	= NULL,
				curveGeom	= NULL )
#	if om$equal( curveGeom, NULL )
#		if om$equal( curveId, NULL ) || om$equal( curveEnv, NULL )
#		omerror "vd_$is_curve_linear: `curveId' or `curveEnv' is NULL."
#		else
			VD_isCurveLinear( (msg), (curveId), (curveEnv), NULL )
#		endif
#	else
		VD_isCurveLinear( (msg), NULL, NULL, (curveGeom) )
#	endif
#endomdef

/*+M
Macro vd_$get_geometry

Abstract
	Returns the abstract geometry of a curve or a surface.
Arguments
	OUT	long			*msg		Completion code.
	IN	const struct GRid	*grobjId	Id of surface or curve.
	IN	const struct GRmd_env 	*grobjEnv	Module environment.
	OUT	struct IGRbsp_curve
	-or-	struct IGRbsp_surface	**geometry	Geometry of object.
Note
	`*geometry' is allocated and hence must be freed by the caller
	with `free( *geometry )'.
-M*/
extern int
VD_get_geometry		__((	long			*msg,
				const struct GRid	*grobjId,
				const struct GRmd_env 	*grobjEnv,
				char			**geometry )) ;

#omdef	vd_$get_geometry( msg, grobjId, grobjEnv, geometry )

	VD_get_geometry( (msg), (grobjId), (grobjEnv), (char **) (geometry) )

#endomdef

/*+M
Macro vd_$xform_curve

Abstract
	Given a transformation matrix, applies it to the abstract geometry of
	a B-spline curve.
Arguments
	IN	long			*msg		Completion code.
	IN	short			mxType		Type of transformation.
	IN	IGRmatrix		transMx 	Transformation matrix.
	I/O	struct IGRbsp_curve	*curveGeom	Geometry of curve.
Note
	Since `curveGeom' is modified, care should be exercised that it not
	come from the abstract geometry cache buffer.
+M*/
extern int
VD_xformCurve			__((	long			*msg,
					short			mxType,
					IGRmatrix		mx,
					struct IGRbsp_curve	*curve )) ;

#omdef vd_$xform_curve( msg, mxType, transMx, curveGeom )

	VD_xformCurve( (msg), (mxType), (transMx), (curveGeom) )
#endomdef

/*+M
Macro vd_$make_boolean_difference

Abstract
	Makes a boolean difference between the operand (solid) and the operators
	(solids). Since the boolean difference absorbs the operators, these
	are copied before the boolean operation. The operand is *NOT* copied.
Arguments
	IN	long			*msg		Completion code.
	IN	int			optrCount	Count of operators.
	IN	struct GRobj_env	optrList[]	List of operators.
	IN	struct GRobj_env	*operand	Operand solid.
	IN	int			compress	Compress state tree ?
	IN	int			oneAtATime	TRUE/FALSE, see note.
	IN	struct GRvg_construct	*resCst 	Construction list of
							result.
	OUT	struct GRid		*result 	Result of boolean
							difference.
Note
	If `oneAtATime' is FALSE the operand will be booleaned against all
	operators in one go. If it is TRUE, the operand will be booleaned
	against the first operator, and the result will be boolean against
	the second operator, etc. This is to make do for the case where
	the operators intersect INSIDE the operand, causing EMS to fail,
	which does not happen if the operation is done one at a time.
-M*/
extern long
VD_make_boolean_difference	__((	long			*msg,
					int			optrCount,
					struct GRobj_env	optrList[],
					struct GRobj_env	*operand,
					struct GRvg_construct	*resCst,
					int			compress,
					int			oneAtATime,
					struct GRid		*result )) ;

#omdef vd_$make_boolean_difference(	msg,
					optrCount,
					optrList,
					operand,
					resCst,
					compress	= FALSE,
					oneAtATime	= FALSE,
					result )

	VD_make_boolean_difference(	(msg),
					(optrCount),
					(optrList),
					(operand),
					(resCst),
					(compress),
					(oneAtATime),
					(result) )
#endomdef

/*+M
Macro vd_$make_boolean_intersect

Abstract
	Makes a boolean intersect between the operand (solid) and the operators
	(solids). Since the boolean intersect absorbs the operators, these
	are copied before the boolean operation. The operand is *NOT* copied.
Arguments
	IN	long			*msg		Completion code.
	IN	int			optrCount	Count of operators.
	IN	struct GRobj_env	optrList[]	List of operators.
	IN	struct GRobj_env	*operand	Operand solid.
	IN	int			compress	Compress state tree ?
	IN	int			oneAtATime	TRUE/FALSE, see note.
	IN	struct GRvg_construct	*resCst 	Construction list of
							result.
	OUT	struct GRid		*result 	Result of boolean
							intersect.
Note
	If `oneAtATime' is FALSE the operand will be booleaned against all
	operators in one go. If it is TRUE, the operand will be booleaned
	against the first operator, and the result will be boolean against
	the second operator, etc. This is to make do for the case where
	the operators intersect INSIDE the operand, causing EMS to fail,
	which does not happen if the operation is done one at a time.
-M*/
extern long
VD_make_boolean_intersect	__((	long			*msg,
					int			optrCount,
					struct GRobj_env	optrList[],
					struct GRobj_env	*operand,
					struct GRvg_construct	*resCst,
					int			compress,
					int			oneAtATime,
					struct GRid		*result )) ;

#omdef vd_$make_boolean_intersect(	msg,
					optrCount,
					optrList,
					operand,
					resCst,
					compress	= FALSE,
					oneAtATime	= FALSE,
					result )

	VD_make_boolean_intersect(	(msg),
					(optrCount),
					(optrList),
					(operand),
					(resCst),
					(compress),
					(oneAtATime),
					(result) )
#endomdef

/*+M
Macro vd_$get_volume_intersect

Abstract
	Makes a boolean intersect/save side between the operand (solid) and
	the operator object. Since the intersect absorbs the operators, these
	are copied before the boolean operation. The operand is *NOT* copied.
	Returned is a list of objects copied anc intersect from the original
	objects.

Arguments
	IN	long			*msg		Completion code.
	IN	int			optrCount	Count of operators.
	IN	struct GRobj_env	optrList[]	List of operators.
	IN	struct GRobj_env	*operand	Operand solid.
	IN	struct GRvg_construct	*resCst 	Construction list of
							result.
	OUT	int			*resCount	NUmber of objects.
	OUT	struct GRid		**resList 	Result of boolean
							intersect.
Note
	The objects are intersect with a solid volume. Only object intersecting
	and inside the volume are returned.
-M*/
extern long
VD_get_volume_intersect	__((		long			*msg,
					int			optrCount,
					struct GRobj_env	optrList[],
					struct GRobj_env	*operand,
					struct GRvg_construct	*resCst,
					int			*resCount,
					struct GRid		**resust )) ;

#omdef vd_$get_volume_intersect(	msg,
					optrCount,
					optrList,
					operand,
					resCst,
					resCount,
					result )

	VD_get_volume_intersect(	(msg),
					(optrCount),
					(optrList),
					(operand),
					(resCst),
					(resCount),
					(result) )
#endomdef


/*+M
Macro vd_$getSurfaceRange

Abstract
	Finds a more refined range box than that returned by GRgetrang for
	a simple (ie. not composite) surface. The input surface must be in
	the range tree.
Arguments
	IN	long		*msg		Completion code
	IN	struct GRid	*surface	Id of simple surface in R-tree.
	OUT	GRrange 	range		Range box of surface.
-M*/
extern int
VD_getSfRange			__((	long		*msg,
					struct GRid	*surface,
					GRrange 	range )) ;

#omdef vd_$getSurfaceRange( msg, surface, range )
	VD_getSfRange( (msg), (surface), (range) )
#endomdef

/*+M
Macro vd_$getRangeOfComposite

Abstract
	Finds a more refined range box than that returned by GRgetrang for
	an owner object whose leaves of the ownership graph are simple surfaces
	(ie. a solid, a composite surface). The simple surfaces must be in
	the range tree.
Arguments
	IN	long		*msg		Completion code
	IN	struct GRobj_env*composite	Id of composite object.
	OUT	GRrange 	range		Range box of composite surface.
-M*/
extern long
VD_getRangeOfComposite		__((	long			*msg,
					struct GRobj_env	*composite,
					GRrange 		range )) ;

#omdef vd_$getRangeOfComposite( msg, composite, range )
	VD_getRangeOfComposite( (msg), (composite), (range) )
#endomdef

/*+M
Macro vd_$grCopy

Abstract
	Copies a graphic object optionally transforming the copy and changing
	its symbology.
Arguments
	IN	long			*msg	Completion code.
	IN	struct GRmd_env 	*frEnv	Env. of from-object.
	IN	struct GRid		*frObj	Id of from-object.
	IN	struct GRmd_env 	*toEnv	Env. of to-object.
	IN	short			mxType	Type of transformation matrix.
	IN	IGRmatrix		mx	Transformation matrix (opt).
	IN	struct GRsymbology	*symb	Symbology of copy (opt).
	OUT	struct GRid		*toObj	Id of copy.
-M*/
extern long
VD_grCopy			__((	long			*msg,
					struct GRmd_env 	*frEnv,
					struct GRid		*frObj,
					struct GRmd_env 	*toEnv,
					short			mxType,
					IGRmatrix		mx,
					struct GRsymbology	*symb,
					struct GRid		*toObj )) ;

#omdef vd_$grCopy( msg, frEnv, frObj, toEnv, mxType = 0, mx = NULL, symb = NULL,
		  toObj )

	VD_grCopy( (msg), (frEnv), (frObj), (toEnv), (mxType), (mx), (symb),
		  (toObj) )
#endomdef

/*M+
Macro vd_$get_normal

Abstract
	Returns the normal of a surface.
Arguments
	OUT	long		*msg	Completion code.
	IN	struct GRid	*sfId	Id of surface.
	IN	struct GRmd_env *sfEnv	Module environment of surface.
	IN	double		parm[2] Parameters to compute normal.
	OUT	IGRvector	normal	Normal of surface at parameters.
Note
	U parameter is parm[0] and V parameter is parm[1]. If `parm' is NULL,
	the normal is computed at the midpoint of the surface.
-M*/
extern long
VD_getNormal			__((	long			*msg,
					struct GRid		*sfId,
					struct GRmd_env 	*sfEnv,
					double			atParms[2],
					IGRvector		normal )) ;

#omdef vd_$get_normal( msg, sfId, sfEnv, parm = NULL, normal )
       VD_getNormal( (msg), (sfId), (sfEnv), (parm), (normal) )
#endomdef

/*M+
Macro vd_$makeCompCurve
Abstract
	Makes a composite curve.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	cvList[]	List of input curves.
	IN	int		cvCount 	Count of input curves.
	IN	struct GRmd_env *cvEnv		Env. of all input curves.
	IN	struct GRmd_env *compEnv	Env. of composite curve.
	OUT	struct GRid	*compCv 	Composite curve created.
-M*/
extern long
VD_makeCompCurve			__((	long			*msg,
					struct GRid		listOfCurves[],
					int			countOfCurves,
					struct GRmd_env		*envOfAllCurves,
					struct GRmd_env		*compCvEnv,
					struct GRid		*compCvId )) ;

#omdef	vd_$makeCompCurve( msg, cvList, cvCount, cvEnv, compEnv, compCv )

	VD_makeCompCurve( (msg), (cvList), (cvCount), (cvEnv), (compEnv),
			 (compCv) )
#endomdef

/*+M
Macro vd_$isPlaneClippingCurve

Abstract
	Finds whether an infinite plane is clipping a curve. Returns TRUE if so
	else FALSE.
Arguments
	IN	const struct IGRbsp_curve *cvGeom 	Geometry of curve.
	IN	const struct IGRplane 	  *plane	Definition of plane.
	OUT	IGRpoint		  firstIntPoint	1st intersection point.
	OUT	double			  *firstIntPm	Parameter of above.
Note
	`firstIntPoint', and `firstIntPm' are optional, if specified they will
	be set only if plane clips curve (ie. if macro returns TRUE).
-M*/
extern int
VD_isPlaneClippingCurve	__((	const struct IGRbsp_curve	*cvGeom,	
				const struct IGRplane		*plane,
				IGRpoint			firstIntPoint,
				double				*firstIntPm )) ;

#omdef	vd_$isPlaneClippingCurve(	cvGeom,
					plane,
					firstIntPoint	= NULL,
					firstIntPm	= NULL )
	VD_isPlaneClippingCurve( (cvGeom), (plane),
				(firstIntPoint), (firstIntPm) )
#endomdef


/*+M
Macro vd_$get_components

Abstract
	Returns all components on the "to_components" channel of an object.
Arguments
	OUT	long			*msg		Completion code.
	IN	const struct GRid	*grobjId	Id of object.
	IN	const struct GRmd_env 	*grobjEnv	Env. of object.
	OUT	int			*number 	Number of components.
	OUT	struct GRid		*components[]	List of components.
Note
	`*components' is allocated and hence must be freed by the caller
	with `free( *components )'.
-M*/
extern long
VD_getComponents		__((	long			*msg,
				const struct GRid	*grobjId,
				const struct GRmd_env	*grobjEnv,
				int			*number,
				struct GRid		*components[] )) ;

#omdef	vd_$get_components( msg, grobjId, grobjEnv, number, components )
	VD_getComponents( (msg), (grobjId), (grobjEnv), (number), (components) )
#endomdef

/*+M
Macro vd_$make_natural_boundary

Abstract
        Puts some topology on a surface if it has not got any.
Arguments
        IN      long            *msg            Completion code.
        IN      struct GRmd_env *surfaceEnv     Module environment of surface.
        IN      struct GRid     *surfaceId      Id of surface.
-M*/
#omdef vd_$make_natural_boundary( msg, surfaceEnv, surfaceId )
        VD_make_natural_boundary( (msg), (surfaceEnv), (surfaceId) )
#endomdef
extern long
VD_make_natural_boundary         __((    long                    *msg,
                                        struct GRmd_env         *surfEnv,
                                        struct GRid             *surfId )) ;

/*+M
Macro vd_$extend_curve_to_surface

Abstract
        Extends a curve till it intersects a given surface if possible.
Arguments
        OUT     long                    *msg            Completion code.
        IN      struct IGRbsp_curve     *curveGeom      Curve to extend.
        IN      struct IGRbsp_surface   *surfaceGeom    Surface to go through.
        IN      int                     whichEnd        Where to extend (0/1).
        OUT     struct IGRbsp_curve     **p_curveGeom   Extended curve.
Note
        `*p_curveGeom' is malloced, it is up to the caller to free it with
        a call to `BSfreecv' if not NULL.
-M*/
extern int
VD_extend_curve_to_surface       __((    long                    *msg,
                                        struct IGRbsp_curve     *curve,
                                        struct IGRbsp_surface   *surface,
                                        int                     whichEnd,
                                        struct IGRbsp_curve     **p_extCurve ));

#omdef vd_$extend_curve_to_surface(      msg,
                                        curveGeom,
                                        surfaceGeom,
                                        whichEnd,
                                        p_curveGeom )

        VD_extend_curve_to_surface(      (msg),
                                        (curveGeom),
                                        (surfaceGeom),
                                        (whichEnd),
                                        (p_curveGeom) )
#endomdef

/*+M
Macro vd_$extend_curve_through_surface

Abstract
        Attempts to extend a curve such that the curve will go through the
        surface. This may fail if the extension requested it too large.
Arguments
        OUT     long                    *msg            Completion code.
        IN      struct IGRbsp_curve     *curveGeom      Curve to extend.
        IN      struct IGRbsp_surface   *surfaceGeom    Surface to go through.
        IN      int                     whichEnd        Where to extend (0/1).
        OUT     struct IGRbsp_curve     **p_curveGeom   Extended curve.
Note
        `*p_curveGeom' is malloced, it is up to the caller to free it with
        a call to `BSfreecv' if not NULL.
-M*/
extern int
VD_extend_curve_through_surface  __((    long                    *msg,
                                        struct IGRbsp_curve     *curve,
                                        struct IGRbsp_surface   *surface,
                                        int                     whichEnd,
                                        struct IGRbsp_curve     **thruCurve )) ;

#omdef vd_$extend_curve_through_surface( msg,
                                        curveGeom,
                                        surfaceGeom,
                                        whichEnd,
                                        p_curveGeom )

        VD_extend_curve_through_surface( (msg),
                                        (curveGeom),
                                        (surfaceGeom),
                                        (whichEnd),
                                        (p_curveGeom) )
#endomdef

#endif /* v_geommacros_include */
