/* $Id: vsgeommacros.h,v 1.3 2001/03/14 00:55:30 jayadev Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        include/vsgeommacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsgeommacros.h,v $
 *      Revision 1.3  2001/03/14 00:55:30  jayadev
 *      vs$make_boolean_difference() args changed
 *
 *      Revision 1.2  2001/01/16 23:53:23  ramarao
 *      *** empty log message ***
 *
 * Revision 1.2  2000/12/09  16:48:14  pinnacle
 * Replaced: struct/include/vsgeommacros.h for:  by jpulapar for Service Pack
 *
 * Revision 1.1  2000/12/02  18:55:48  pinnacle
 * Created: struct/include/vsgeommacros.h by jpulapar for Service Pack
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1998/02/20  16:18:04  pinnacle
 * CR179800676
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/20/98  ah      CR179800676 - Delimit curve can now extend curve as well
 * 12/02/00  Jayadev vs$make_boolean_difference - arguments added
 ***************************************************************************/

#ifndef vsgeommacros_include
#	define vsgeommacros_include

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
#ifndef vs_include
#	include "vs.h"
#endif
#ifndef vsdpb_include
#	include "vsdpb.h"
#endif

/*+M
Macro vs$is_surface_planar

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

	is_planar = vs$is_surface_planar( msg = &msg, etc. ) ;
-M*/
extern int
VSisSurfacePlanar		__((	long			*msg,
					struct GRid		*surfId,
					struct GRmd_env		*surfEnv,
					struct IGRbsp_surface	*surfGeom )) ;

#omdef	vs$is_surface_planar(	msg,
				surfId		= NULL,
				surfEnv 	= NULL,
				surfGeom	= NULL )
#	if om$equal( surfGeom, NULL )
#		if om$equal( surfId, NULL ) || om$equal( surfEnv, NULL )
#		omerror "vs$is_surface_planar: `surfId' or `surfEnv' is NULL."
#		else
			VSisSurfacePlanar( (msg), (surfId), (surfEnv), NULL )
#		endif
#	else
		VSisSurfacePlanar( (msg), NULL, NULL, (surfGeom) )
#	endif
#endomdef

/*+M
Macro vs$is_curve_linear

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

	is_linear = vs$is_curve_linear( msg = &msg, etc. ) ;
-M*/
extern int
VSisCurveLinear			__((	long			*msg,
					struct GRid		*cvId,
					struct GRmd_env		*cvEnv,
					struct IGRbsp_curve	*cvGeom )) ;

#omdef	vs$is_curve_linear(	msg,
				curveId 	= NULL,
				curveEnv	= NULL,
				curveGeom	= NULL )
#	if om$equal( curveGeom, NULL )
#		if om$equal( curveId, NULL ) || om$equal( curveEnv, NULL )
#		omerror "vs$is_curve_linear: `curveId' or `curveEnv' is NULL."
#		else
			VSisCurveLinear( (msg), (curveId), (curveEnv), NULL )
#		endif
#	else
		VSisCurveLinear( (msg), NULL, NULL, (curveGeom) )
#	endif
#endomdef

/*+M
Macro vs$get_geometry

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
VSget_geometry		__((	long			*msg,
				const struct GRid	*grobjId,
				const struct GRmd_env 	*grobjEnv,
				char			**geometry )) ;

#omdef	vs$get_geometry( msg, grobjId, grobjEnv, geometry )

	VSget_geometry( (msg), (grobjId), (grobjEnv), (char **) (geometry) )

#endomdef

/*+M
Macro vs$recomposite_surface

Abstract
	Given a cross-section composite curve and a surface made by moving that
	cross-section normal to a surface or a skinning surface, creates
	a composite surface, geometrically similar to the input general surface
	but with components corresponding to the those of the input composite
	curve.
	This is done by splitting the input general surface along the "u"
	direction then compositing the patches.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env 	*genlSfEnv	Env. of general surface.
	IN	struct GRid		*genlSfId	Id of general surface.
	IN	struct GRmd_env 	*compCvEnv	Env. of composite curve.
	IN	struct GRid		*compCvId	Id of composite curve.
	IN	struct GRmd_env 	*compSfEnv	Env. of composite surf.
	IN	struct GRsymbology	*compSfSymb	Symb. of composite surf.
	OUT	struct GRid		*compSfId	Id of composite surf.
Note
	If `compSfSymb' is NULL, the symbology of the input surface will be
	taken.
-M*/
extern long
VSrecomposite_gensurf_with_compcurve
				__((	long			*msg,
					struct GRmd_env		*genlSfEnv,
					struct GRid		*genlSfId,
					struct GRmd_env		*compCvEnv,
					struct GRid		*compCvId,
					struct GRmd_env		*compSfEnv,
					struct GRsymbology	*compSfSymb,
					struct GRid		*compSfId )) ;

#omdef	vs$recomposite_surface( msg,
				genlSfEnv,
				genlSfId,
				compCvEnv,
				compCvId,
				compSfEnv,
				compSfSymb = NULL,
				compSfId )

	VSrecomposite_gensurf_with_compcurve(	(msg),
						(genlSfEnv),
						(genlSfId),
						(compCvEnv),
						(compCvId),
						(compSfEnv),
						(compSfSymb),
						(compSfId) )
#endomdef

/*+M
Macro vs$split_surface_with_curve

Abstract
	Splits a surface with a curve into two sub-surfaces. The two results
	come out sorted, ie. the first result is that to the left of the
	splitting curve, "left" being defined with respect to the curve's
	orientation.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*surfId 	Id of surface.
	IN	struct GRmd_env *surfEnv	Mod. env. of surface.
	IN	struct GRid	*curveId	Id of splitting curve.
	IN	struct GRmd_env *curveEnv	Module environment of curve.
	IN	struct GRsymbology
				*resultSymb	Symbology of results.
	OUT	struct GRid	resultList[2]	List of sub-surfaces.
Note
	If the input curve is a line segment, it will be considered as an
	infinite line.
-M*/
extern long
VSsplitSurfaceWithCurve		__((	long			*msg,
					struct GRid		*surfId,
					struct GRmd_env		*surfEnv,
					struct GRid		*curveId,
					struct GRmd_env		*curveEnv,
					struct GRsymbology	*resultSymb,
					struct GRid		results[2] )) ;

#omdef	vs$split_surface_with_curve(	msg,
					surfId,
					surfEnv,
					curveId,
					curveEnv,
					resultSymb,
					resultList )
	VSsplitSurfaceWithCurve(	(msg),
					(surfId),
					(surfEnv),
					(curveId),
					(curveEnv),
					(resultSymb),
					(resultList) )
#endomdef

/*+M
Macro vs$extend_curve_to_surface

Abstract
	Extends a curve till it intersects a given surface if possible.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct IGRbsp_curve	*curveGeom	Curve to extend.
	IN	struct IGRbsp_surface	*surfaceGeom	Surface to go through.
	IN	int			whichEnd	Where to extend (0/1).
	OUT	struct IGRbsp_curve	**p_curveGeom	Extended curve.
Note
	`*p_curveGeom' is malloced, it is up to the caller to free it with
	a call to `BSfreecv' if not NULL.
-M*/
extern int
VSextend_curve_to_surface	__((	long			*msg,
 					struct IGRbsp_curve	*curve,
 					struct IGRbsp_surface	*surface,
 					int			whichEnd,
 					struct IGRbsp_curve	**p_extCurve ));

#omdef vs$extend_curve_to_surface(	msg,
					curveGeom,
					surfaceGeom,
					whichEnd,
					p_curveGeom )

	VSextend_curve_to_surface(	(msg),
					(curveGeom),
					(surfaceGeom),
					(whichEnd),
					(p_curveGeom) )
#endomdef

/*+M
Macro vs$extend_curve_through_surface

Abstract
	Attempts to extend a curve such that the curve will go through the
	surface. This may fail if the extension requested it too large.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct IGRbsp_curve	*curveGeom	Curve to extend.
	IN	struct IGRbsp_surface	*surfaceGeom	Surface to go through.
	IN	int			whichEnd	Where to extend (0/1).
	OUT	struct IGRbsp_curve	**p_curveGeom	Extended curve.
Note
	`*p_curveGeom' is malloced, it is up to the caller to free it with
	a call to `BSfreecv' if not NULL.
-M*/
extern int
VSextend_curve_through_surface	__((	long			*msg,
 					struct IGRbsp_curve	*curve,
 					struct IGRbsp_surface	*surface,
 					int			whichEnd,
 					struct IGRbsp_curve	**thruCurve )) ;

#omdef vs$extend_curve_through_surface( msg,
					curveGeom,
					surfaceGeom,
					whichEnd,
					p_curveGeom )

	VSextend_curve_through_surface( (msg),
					(curveGeom),
					(surfaceGeom),
					(whichEnd),
					(p_curveGeom) )
#endomdef

/*+M
Macro vs$mk_portion_of_cv_through_sf

Abstract
	Attempts to extend a curve to a surface and returns a portion of
	extended curve (not the whole curve !).
Arguments
	OUT	long			*msg		Completion code.
	IN	struct IGRbsp_curve	*curveGeom	Curve to extend.
	IN	struct IGRbsp_surface	*surfaceGeom	Surface to go through.
	IN	int			whichEnd	Where to extend (0/1).
	OUT	struct IGRbsp_curve	**p_portionGeom Portion of extended
							curve.
Note
	`*p_portionGeom' is malloced, it is up to the caller to free it with
	a call to `BSfreecv' if not NULL.
-M*/
extern int
VSmk_portion_of_cv_through_sf	__((	long			*msg,
					struct IGRbsp_curve	*curve,
					struct IGRbsp_surface	*surface,
					int			whichEnd,
					struct IGRbsp_curve	**thruPortion )) ;

#omdef vs$mk_portion_of_cv_through_sf(	msg,
					curveGeom,
					surfaceGeom,
					whichEnd,
					p_portionGeom )

	VSmk_portion_of_cv_through_sf(	(msg),
					(curveGeom),
					(surfaceGeom),
					(whichEnd),
					(p_portionGeom) )
#endomdef

/*+M
Macro vs$place_cross_section

Abstract
	Loads a cross-section definition from the Relational Data Base and
	places it on site, given a curve, a surface and position parameters.
Arguments
	OUT	long		*msg		Completion code.
	IN	char		*xMat		Material of desired section.
	IN	char		*xFam		Section family.
	IN	char		*xName		Section name.
	IN	OMuword 	searchOS	Object space of cache.
	IN	double		xOffset
	IN	double		yOffset
	IN	double		rotation
	I/O	IGRboolean	*profOpt	TRUE: use/used detail profile
						FALSE:use/used Envelop profile
	IN	enum VScardinal_point
				cardinal
	IN	enum VSsymmetry symmetry
	IN	struct GRobj_env*surface	Support surface.
	IN	struct GRobj_env*axis		Support axis.
	IN	IGRvector	xDir		Direction of the x-vector cross
						section CS.
	IN	double		dspRatio	Display ratio.
	IN	VSdspRep	dspRep		Display representation.
	IN	struct GRvg_construct
				*cst		Construction list.
	OUT	struct GRid	*xSect		Created section.
Notes
	The fields `name', `class_attr', `newflag' and `geometry' of the
	construction list are not used.

	The argument 'xDir' is the direction of the x-vector of the cross
	section coordinate system ( could be NULL ).

	Though the profile option is set to detail profile, the option may be 
	changed  to envelop profile if cross section cannot be placed with
	the detail profile option. Hence the user has to check the return 
	value of the profile option
-M*/
extern long
VSplace_cross_section		__((	long			*msg,
					char			*xMat,
					char			*xFam,
					char			*xName,
					OMuword 		searchOS,
					double			xOffset,
					double			yOffset,
					double			rotation,
					IGRboolean		*profOpt,
					enum VScardinal_point	cardinal,
					enum VSsymmetry 	symmetry,
					struct GRobj_env	*surface,
					struct GRobj_env	*axis,
					IGRvector		xDir,
					double			dspRatio,
					VSdspRep		dspRep,
					struct GRvg_construct	*cst,
					struct GRid		*xSect )) ;

#omdef vs$place_cross_section(	msg,
				xMat,
				xFam,
				xName,
				searchOS,
				xOffset 	= 0.,
				yOffset 	= 0.,
				rotation	= 0.,
				profOpt		= NULL,
				cardinal,
				symmetry,
				surface,
				axis,
				xDir		= NULL,
				dspRatio	= 1.,
				dspRep,
				cst,
				xSect )

	VSplace_cross_section(	msg,
				xMat,
				xFam,
				xName,
				searchOS,
				xOffset,
				yOffset,
				rotation,
				profOpt,
				cardinal,
				symmetry,
				surface,
				axis,
				xDir,
				dspRatio,
				dspRep,
				cst,
				xSect )
#endomdef

/*+M
Macro vs$cnstBeamArrowHeads

Abstract
	Constructs two arrow heads to be placed at the ends of the beam axis.
	The geometry of the surface may be input if known. Its id must be
	given in any case; the beam axis may be either given by id or
	by geometry.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	*surface	Id of support surface.
	IN	struct IGRbsp_surface	*surfGeom	Geometry of surface.
	IN	struct GRobj_env	*axis		Id of axis.
	IN	struct IGRbsp_curve	*axisGeom	Geometry of axis.
	IN	struct GRvg_construct	*cnst_list	Construction list.
	IN	int			viewIndep	TRUE/FALSE.
	OUT	struct GRid		*startArrow	Arrow head at start pt.
	OUT	struct GRid		*endArrow	Arrow head at end pt.
-M*/
extern long
VScnstBeamArrowHeads		__((	long			*msg,
					struct GRobj_env	*surface,
					struct IGRbsp_surface	*surfGeom,
					struct GRobj_env	*axis,
					struct IGRbsp_curve	*axisGeom,
					struct GRvg_construct	*cnst_list,
					int			viewIndep,
					struct GRid		*startArrow,
					struct GRid		*endArrow )) ;

#omdef vs$cnstBeamArrowHeads(	msg,
				surface,
				surfGeom	= NULL,
				axis		= NULL,
				axisGeom	= NULL,
				cnst_list,
				viewIndep	= TRUE,
				startArrow,
				endArrow )

#	if om$equal( axis, NULL ) && om$equal( axisGeom, NULL )
#	omerror "vs$cnstBeamArrowHeads: must specify `axis' or `axisGeom'"
#	else
		VScnstBeamArrowHeads(	(msg),
					(surface),
					(surfGeom),
					(axis),
					(axisGeom),
					(cnst_list),
					(viewIndep),
					(startArrow),
					(endArrow ) )
#	endif
#endomdef

/*+M
Macro vs$getCS_from_cv_and_sf

Abstract
	Given a curve and a surface, returns a co-ordinate system at a point
	on the axis given by its parameter.

		- the origin is the end point
		- the z-axis is the tangent of the curve (at end point)
		- the y-axis is the normal to the surface (at end point)
		- the x-axis is the cross-product of the two above
	The fact that the surface normal may be reversed is taken into account
	(eg. if it is a solid's face). The curve is supposed to lie on the
	surface or be parallel to it.
	The geometry of the surface may be input if known. Its id must be
	given in any case; the beam axis may be either given by id or
	by geometry.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	*surface	Id of support surface.
	IN	struct IGRbsp_surface	*surfGeom	Geometry of surface.
	IN	struct GRobj_env	*curve		Id of curve.
	IN	struct IGRbsp_curve	*curveGeom	Geometry of curve.
	IN	double			pntParm 	Parameter of point.
	OUT	IGRpoint		origin		Of CS.
	OUT	IGRvector		tangent 	z-axis.
	OUT	IGRvector		normal		y-axis.
	OUT	IGRvector		binormal	x-axis.
-M*/
extern long
VSgetCS_from_cv_and_sf		__((	long			*msg,
					struct GRobj_env	*surface,
					struct IGRbsp_surface	*surfGeom,
					struct GRobj_env	*curve,
					struct IGRbsp_curve	*curveGeom,
					double			pntParm,
					IGRpoint		origin,
					IGRvector		tangent,
					IGRvector		normal,
					IGRvector		binormal )) ;

#omdef vs$getCS_from_cv_and_sf( msg,
				surface,
				surfGeom	= NULL,
				curve		= NULL,
				curveGeom	= NULL,
				pntParm,
				origin,
				tangent,
				normal,
				binormal )

#	if om$equal( curve, NULL ) && om$equal( curveGeom, NULL )
#	omerror "vs$getCS_from_cv_and_sf: must specify `curve' or `curveGeom'"
#	else
	VSgetCS_from_cv_and_sf( (msg),
				(surface),
				(surfGeom),
				(curve),
				(curveGeom),
				(pntParm),
				(origin),
				(tangent),
				(normal),
				(binormal) )
#	endif
#endomdef

/*+M
Macro vs$get_graphic_section

Abstract
	Extracts a graphic cross-section corresponding to the desired display
	representation from the section definition. Note: this is not a copy
	so do not fool around with it !
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*sectDef	Id of section definition.
	IN	VSdspRep	representation	Display representation.
	OUT	struct GRobj_env*section	Id+Env. of cross-section.
-M*/
extern long
VSextractCachedSection		__((	long			*msg,
					struct GRid		*profileDef,
					VSdspRep		profileRep,
					struct	GRobj_env 	*profileCurve )) ;

#omdef vs$get_graphic_section( msg, sectDef, representation, section )

	VSextractCachedSection( (msg),
				(sectDef),
				(representation),
				(section) )
#endomdef

/*+M
Macro vs$xform_curve

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
VSxformCurve			__((	long			*msg,
					short			mxType,
					IGRmatrix		mx,
					struct IGRbsp_curve	*curve )) ;

#omdef vs$xform_curve( msg, mxType, transMx, curveGeom )

	VSxformCurve( (msg), (mxType), (transMx), (curveGeom) )
#endomdef

/*+M
Macro vs$make_offset_surface

Abstract
	Generates an offset surface from the input surface.
	If the surface is planar then the offset plane will be a copy of
	the input plate which is translated by the offset value along the
	input plane's normal.
	If the surface is not planar, an offset surface is generated.
	If the input offset has an absolute value less than the system's
	offset tolerance then the output surface is a copy of the input surface
	at the same location.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env *surfEnv	Module env. of input surface.
	IN	struct GRid	*surfId 	Id of input surface.
	IN	double		offset		Value of the offset.
	IN	int		isPlanar	TRUE/FALSE/DONT_KNOW
						(put DONT_KNOW if you don't
						know).
	IN	int		isNatNorm	TRUE/FALSE whether to offset
						in the direction of the
						surface's normals or the
						reverse direction.
	IN	struct GRvg_construct
				*cst		Construction list for
						output surface.
	OUT	struct GRid	*offSurfId	Id of offset surface.
Note
	The fields `name', `class_attr', `newflag' and `geometry' of the
	construction list are not used.
-M*/
extern long
VSmake_offset_surface		__((	long			*msg,
					struct GRmd_env		*surfEnv,
					struct GRid		*surfId,
					double			offset,
					int			isPlanar,
					int			isNatNorm,
					struct GRvg_construct	*cst,
					struct GRid		*offSfId )) ;

#omdef	vs$make_offset_surface( msg,
				surfEnv,
				surfId,
				offset,
				isPlanar = DONT_KNOW,
				isNatNorm= TRUE,
				cst,
				offSurfId )

#	if om$equal( isPlanar, DONT_KNOW )
		VSmake_offset_surface(	(msg),
					(surfEnv),
					(surfId),
					(offset),
					-1,
					(isNatNorm),
					(cst),
					(offSurfId) )
#	else
		VSmake_offset_surface(	(msg),
					(surfEnv),
					(surfId),
					(offset),
					(isPlanar),
					(isNatNorm),
					(cst),
					(offSurfId) )
#	endif
#endomdef

/*+M
Macro vs$offset_surface_to_solid

Abstract
	Creates an offset solid based on a surface. If the surface is planar
	then a faster algorithm will be used.
	If the input offset has an absolute value less than the system's
	offset tolerance then the offset tolerance will be used.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env *surfEnv	Module env. of input surface.
	IN	struct GRid	*surfId 	Id of input surface.
	IN	double		offset		Value of the offset.
	IN	int		isPlanar	TRUE/FALSE/DONT_KNOW
						(put DONT_KNOW if you don't
						know).
	IN	int		isNatNorm	TRUE/FALSE whether to offset
						in the direction of the
						surface's normals or the
						reverse direction.
	IN	struct GRvg_construct
				*cst		Construction list for
						output solid.
	OUT	struct GRid	*offSolId	Id of offset solid.
Note
	The fields `name', `class_attr', `newflag' and `geometry' of the
	construction list are not used.
-M*/
extern long
VSoffset_surface_to_solid	__((	long			*msg,
					struct GRmd_env		*surfEnv,
					struct GRid		*surfId,
					double			offset,
					int			isNatNorm,
					int			isPlanar,
					struct GRvg_construct	*cst,
					struct GRid		*offSlId )) ;

#omdef vs$offset_surface_to_solid(	msg,
					surfEnv,
					surfId,
					offset,
					isPlanar,
					isNatNorm,
					cst,
					offSolId )

#	if om$equal( isPlanar, DONT_KNOW )
		VSoffset_surface_to_solid(	(msg),
						(surfEnv),
						(surfId),
						(offset),
						-1,
						(isNatNorm),
						(cst),
						(offSolId) )
#	else
		VSoffset_surface_to_solid(	(msg),
						(surfEnv),
						(surfId),
						(offset),
						(isPlanar),
						(isNatNorm),
						(cst),
						(offSolId) )
#	endif
#endomdef

struct VS_s_boolRef{
 int              type; // curve or solid
 struct GRobj_env org;  // original curve or solid
 struct GRobj_env new;  // new solid generated from curve
 int              nb_iter; // no. of iterations for boolean
 GRname           className;
 OMuword          classID; 
};

typedef struct VS_s_boolRef VSboolRef;
 
#define VS_K_blCurve 1
#define VS_K_blSolid 2

/*+M
Macro vs$make_boolean_difference

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
VSmake_boolean_difference	__((	long			*msg,
					int			optrCount,
					struct GRobj_env	optrList[],
					struct GRobj_env	*operand,
					struct GRvg_construct	*resCst,
					int			compress,
					int			oneAtATime,
					struct GRid		*result,
					VSboolRef               *refList,
					int                     refCount,
    					GRrange                 range )) ;

#omdef vs$make_boolean_difference(	msg,
					optrCount,
					optrList,
					operand,
					resCst,
					compress	= FALSE,
					oneAtATime	= FALSE,
					result ,
					refList = NULL,
					refCount= 0 ,
                                        range   = NULL )

#	if om$equal( refList, NULL ) || om$equal( refCount , 0 )
        VSmake_boolean_difference(      (msg),
                                        (optrCount),
                                        (optrList),
                                        (operand),
                                        (resCst),
                                        (compress),
                                        (oneAtATime),
                                        (result) ,
                                        NULL ,
                                        0 ,
 					(range))
#	else
	VSmake_boolean_difference(	(msg),
					(optrCount),
					(optrList),
					(operand),
					(resCst),
					(compress),
					(oneAtATime),
					(result) ,
					(refList) ,
					(refCount),
 					(range))
#	endif

#endomdef

/*+M
Macro vs$cap_surface

Abstract
	Turns a surface into a solid.
Arguments
	IN	long			*msg		Completion code.
	IN	struct GRvg_construct	*cst		Construction list.
	IN	struct GRid		*surface	Surface to cap.
	OUT	struct GRid		*solid		Generated solid.
Note
	The fields `name', `class_attr', `newflag' and `geometry' of the
	construction list are not used.
-M*/
extern long
VScap_surface			__((	long			*msg,
					struct GRvg_construct	*cst,
					struct GRid		*surfId,
					struct GRid		*solidId )) ;

#omdef vs$cap_surface( msg, cst, surface, solid )

	VScap_surface( (msg), (cst), (surface), (solid) )

#endomdef

/*+M
Macro vs$extend_sl_to_sf_and_trim

Abstract
	Given a solid made of a (composite) surface of projection and a surface,
	extends the solid to the surface and trims it against the surface.
Arguments
	IN	long		*msg		Completion code.
	IN	struct GRmd_env *solidEnv	Mod. env. of solid to extend.
	IN	struct GRid	*solidId	Id of solid to extend.
	IN	struct GRobj_env
				*begCapCv	Curve with which the surface of
						projection was made (begin cap
						curve).
	IN	struct GRobj_env
				*trimSf 	Trimming surface.
	IN	int		whichEnd	Where extension is wanted
						(0: begin cap, 1: end cap).
	IN	struct GRvg_construct
				*cst		Construction list of result.
	IN	int		compress	Compress state tree ?
	OUT	struct GRid	*extSolid	Resulting extended and trimmed
						solid.
Note
	The solid is expected to be an EMSsfsolid built on an EMSproject or
	EMSprcompsf surface; the trimming surface is expected to be an EMSsubbs.
	The input trimming surface becomes part of the resulting solid.
-M*/
extern long
VSextend_sl_to_sf_and_trim	__((	long			*msg,
					struct GRmd_env 	*solidEnv,
					struct GRid		*solidId,
					struct GRobj_env	*begCapCv,
					struct GRobj_env	*trimSf,
					int			whichEnd,
					struct GRvg_construct	*cst,
					int			compress,
					struct GRid		*extSolid )) ;

#omdef vs$extend_sl_to_sf_and_trim(	msg,
					solidEnv,
					solidId,
					begCapCv,
					trimSf,
					whichEnd,
					cst,
					compress	= FALSE,
					extSolid )

	VSextend_sl_to_sf_and_trim(	(msg),
					(solidEnv),
					(solidId),
					(begCapCv),
					(trimSf),
					(whichEnd),
					(cst),
					(compress),
					(extSolid) )

#endomdef

/*+M
Macro vs$reverse_sf_orientation

Abstract
	Reverses the orientation of a surface if it is not already reversed,
	or reverses it inconditionally.
Arguments
	IN	long		*msg		Completion code.
	IN	struct GRid	*surfaceId	Id of surface.
	IN	int		ignRevFlag	TRUE/FALSE.
Note
	The surface must be of a class sub-classed off EMSsubbs.
	If `ignRevFlag' is TRUE the surface orientation will be reversed
	even if the surface is already flagged as having its orientation
	reversed.
-M*/
#omdef vs$reverse_sf_orientation( msg, surfaceId, ignRevFlag = FALSE )
	VSreverse_sf_orientation( (msg), (surfaceId), ignRevFlag )
#endomdef
extern long
VSreverse_sf_orientation	__((	long			*msg,
					struct GRid		*surfaceId,
					int			ignRevFlag )) ;

/*+M
Macro vs$make_natural_boundary

Abstract
	Puts some topology on a surface if it has not got any.
Arguments
	IN	long		*msg		Completion code.
	IN	struct GRmd_env *surfaceEnv	Module environment of surface.
	IN	struct GRid	*surfaceId	Id of surface.
-M*/
#omdef vs$make_natural_boundary( msg, surfaceEnv, surfaceId )
	VSmake_natural_boundary( (msg), (surfaceEnv), (surfaceId) )
#endomdef
extern long
VSmake_natural_boundary		__((	long			*msg,
					struct GRmd_env		*surfEnv,
					struct GRid		*surfId )) ;

/*+M
Macro vs$delimit_curve_by_two_surfaces

Abstract
	Delimits a curve with two surfaces. The result is inside the area
	delimited by the input surfaces. The input curve is deleted when a
	result is found.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRobj_env *curve 	Id and mod. env. of curve.
	IN	struct GRobj_env surf[2]	Id and mod. env. of delimiting
						surfaces.

	IN      int              surfFlags[2]   CR179800676, If set then extend curve to surface
                                                Can be NULL

	IN	int		 option 	ORing option.
						( see vssplitdef.h for more
						  details ).
	IN	double		 offset[2]	Offset distances.
	IN	struct GRsymbology
				 *resultSymb	Symbology of result.
	OUT	struct GRid	 *result	Result curve.
Notes
	* If no solution is found `result->objid' is equal to NULL_OBJID.

	* If the input curve is in a reference file and the results have
	  to be used in the active file, the input curve must first be copied to
	  the active file by the caller, since the input curve will be manipu-
	  lated by this macro.

	* The argument 'offset' is the length to keep/remove at each extremity.

		  _________________________ Result curve.
		  |		     |
		  v		     v
		-----|------------|-----      <-- Input curve.
		  <->		   <->
		   ^		    ^
		   | ^		  ^ |
	    offset[0]|		  | offset[1]
		     |		  |
		    surf[0]	 surf[1]

	   Sign :
	   ------
		- offset > 0 ( Keep length )

			----|-----------|----
			 <->		 <->

		- offset < 0 ( Remove length )

			----|-----------|----
			     <->     <->
-M*/
extern int
VSdelimitCurveByTwoSurfacesf	__((	long			*msg,
					struct GRobj_env	*curve,
					struct GRobj_env	surface[2],
					int                     surfFlags[2],  // CR179800676
					int			option,
					double			offsets[2],
					struct GRsymbology	*resultSymb,
					struct GRid		*result )) ;

#omdef	vs$delimit_curve_by_two_surfaces( msg,
					  curve,
					  surf,
					  surfFlags = NULL,                    // CR179800676
					  option = VS_K_CONSASANINFPLANE |
						   VS_K_SETCURVORIENT,
					  offset = NULL,
					  resultSymb,
					  result )
	VSdelimitCurveByTwoSurfaces(	  (msg),
					  (curve),
					  (surf),
                                          (surfFlags),
					  (option),
					  (offset),
					  (resultSymb),
					  (result) )
#endomdef

/*+M
Macro vs$imposeBoundaries

Abstract
	Given a surface and a list of boundary curves, imposes those curves
	onto the surface, such that the areas delimited by those curves become
	holes in the surface.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	*surface	Input surface.
	IN	int			bndryCount	Count of boundaries to
							impose.
	IN	struct GRobj_env	bndryList[]	List of boundaries.
	IN	int			sfIsPlanar	TRUE/FALSE (optional)
Note
	`sfIsPlanar' is an optimization flag, set it to FALSE if you do not
	know whether the input surface is planar or not.
	If all boundaries are outside the natural boundary of the input
	surface, `*msg' is set to EMS_E_NoMoreLoops.
-M*/
extern long
VSimpose_boundaries		__((	long			*msg,
					struct GRobj_env	*surface,
					int			bndryCount,
					struct GRobj_env	bndryList[],
					int			sfIsPlanar )) ;

#omdef	vs$imposeBoundaries(	msg,
				surface,
				bndryCount,
				bndryList,
				sfIsPlanar = FALSE )

	VSimpose_boundaries(	(msg),
				(surface),
				(bndryCount),
				(bndryList),
				(sfIsPlanar) )
#endomdef

/*+M
Macro vs$offsetCurve

Abstract
	Given an input curve, creates an offset curve.
Arguments
	OUT	long		*msg	Completion code.
	IN	struct GRmd_env *cvEnv	Module environment of input curve.
	IN	struct GRid	*cvId	Id of input curve.
	IN	double		offset	Value of offset.
	IN	IGRvector	normal	Normal to input curve (optional).
	IN	struct GRvg_construct
				*cst	Construction list for offset curve.
	OUT	struct GRid	*offCvId
					Id of created offset curve.
Note
	If `offset' is less than the offset tolerance, `*offCvId' is set to
	`*cvId' and `*msg' is set to EMS_I_Fail.
	If `normal' is not specified, it will be computed.
-M*/
extern long
VSoffsetCurve			__((	long			*msg,
					struct GRmd_env		*cvEnv,
					struct GRid		*cvId,
					double			offset,
					IGRvector		normal,
					struct GRvg_construct	*cst,
					struct GRid		*offCvId )) ;

#omdef vs$offsetCurve( msg, cvEnv, cvId, offset, normal = NULL, cst, offCvId )

	VSoffsetCurve(	(msg),
			(cvEnv),
			(cvId),
			(offset),
			(normal),
			(cst),
			(offCvId) )
#endomdef

/*+M
Macro vs$offsetCurveAlongDirectionVector

Abstract
	Given an input curve, creates an offset curve along input direction
	vector.
Arguments
	OUT	long		*msg	Completion code.
	IN	struct GRid	*cvId	Id of input curve.
	IN	struct GRmd_env *cvEnv	Module environment of input curve.
	IN	double		offset	Value of offset.
	IN	IGRvector	direction
					Direction vector.
	IN	struct GRvg_construct
				*cst	Construction list for offset curve.
	OUT	struct GRid	*offCvId
					Id of created offset curve.
Note
	If `offset' is less than the offset tolerance, `*offCvId' is set to
	`*cvId' and `*msg' is set to EMS_I_Fail.
-M*/
extern long
VSoffsetCurveAlongDirectionVector __((	long			*msg,
					struct GRid		*cvId,
					struct GRmd_env		*cvEnv,
					double			offset,
					IGRvector		direction,
					struct GRvg_construct	*cst,
					struct GRid		*offCvId )) ;

#omdef vs$offsetCurveAlongDirectionVector( msg, 
					   cvId, 
					   cvEnv, 
					   offset, 
					   direction, 
					   cst, 
					   offCvId )

	VSoffsetCurveAlongDirectionVector( (msg),
			                   (cvId),
			                   (cvEnv),
			                   (offset),
			                   (direction),
			                   (cst),
			                   (offCvId) )
#endomdef

/*+M
Macro vs$getSurfaceRange

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
VSgetSfRange			__((	long		*msg,
					struct GRid	*surface,
					GRrange 	range )) ;

#omdef vs$getSurfaceRange( msg, surface, range )
	VSgetSfRange( (msg), (surface), (range) )
#endomdef

/*+M
Macro vs$getRangeOfComposite

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
VSgetRangeOfComposite		__((	long			*msg,
					struct GRobj_env	*composite,
					GRrange 		range )) ;

#omdef vs$getRangeOfComposite( msg, composite, range )
	VSgetRangeOfComposite( (msg), (composite), (range) )
#endomdef

/*+M
Macro vs$plane_surface_intersection

Abstract
	Intersects a surface and a plane. The plane is a surface considered as
	an infinite plane. Either the id and module environment of the plane
	or the geometry ( point and normal ) of the plane may be input.
Arguments
	IN	long		   *msg 	Completion code.
	IN	struct GRobj_env   *planeObj	Id and mod. env. of plane.
	IN	struct IGRplane    *planeGeom	Geometry of plane.
	IN	struct GRobj_env   *surface	Id and mod. env. of surface.
	IN	struct GRvg_construct
				   *cst 	Construction list of results.
	OUT	int		   *nb_result	Count of intersections found.
	OUT	struct GRid	   **resultList List of intersections.
-M*/
extern long
VSplaneSurfaceIntersection	__((	long			*msg,
					struct GRobj_env	*plane,
					struct IGRplane 	*planeGeom,
					struct GRobj_env	*surface,
					struct GRvg_construct	*cst,
					int			*nbInts,
					struct GRid		**listOfInts ));

#omdef vs$plane_surface_intersection( msg,
				      planeObj	= NULL,
				      planeGeom = NULL,
				      surface,
				      cst,
				      nb_result,
				      resultList )
#	if om$equal( planeObj, NULL ) && om$equal( planeGeom, NULL )
#	omerror "vs$plane_surface_intersection: must specify `planeObj' or `planeGeom'."
#	else
	       VSplaneSurfaceIntersection( (msg),
					   (planeObj),
					   (planeGeom),
					   (surface),
					   (cst),
					   (nb_result),
					   (resultList) )
#	endif
#endomdef

/*+M
Macro vs$makeInfinitePlane

Abstract
	Given a plane, creates another place encompassing the input plane but
	almost infinite, ie. reaching the limits of the design file.
Arguments
	IN	long			*msg		Completion code
	IN	struct GRobj_env	*inPlane	Input plane.
	IN	struct GRvg_construct	*cst		Construction list.
	OUT	struct GRid		*infPlane	Infinite plane.
*/
#omdef vs$makeInfinitePlane( msg, inPlane, cst, infPlane )
	VSmakeInfinitePlane( (msg), (inPlane), (cst), (infPlane) )
#endomdef
extern long
VSmakeBiggerPlane		__((	long			*msg,
					struct GRobj_env 	*inPlane,
					struct GRobj_env 	*element,
					GRrange			elmBox,
					double			scale,
					struct GRvg_construct	*cst,
					struct GRid		*outPlane )) ;

/*+M
Macro vs$makeBiggerPlane

Abstract
	Given a plane and a graphic element, constructs a plane whose boundaries
	will reach the biggest box containing the range boxes of the input
	plane and graphic element. If specified, a scaling may be applied
	to the union box to have an even bigger plane.
	The purpose of this macro is to have planes considered as infinite in
	some processes (intersection, projection onto a plane, etc.)
Arguments
	IN	long			*msg		Completion code.
	IN	struct GRobj_env	*inPlane	Input plane.
	IN	struct GRobj_env	*element	Input element.
	IN	GRrange 		elementRng	Range of above.
	IN	double			scale		Scaling factor (opt).
	IN	struct GRvg_construct	*cst		Construction list.
	OUT	struct GRid		*bigPlane	Big plane.
Note
	Either `element' or `elementRng' may be input.
-M*/
extern long
VSmakeInfinitePlane		__((	long			*msg,
					struct GRobj_env 	*inPlane,
					struct GRvg_construct	*cst,
					struct GRid		*outPlane )) ;

#omdef vs$makeBiggerPlane(	msg,
				inPlane,
				element 	= NULL,
				elementRng	= NULL,
				scale		= 1.,
				cst,
				bigPlane )

	VSmakeBiggerPlane(	(msg),
				(inPlane),
				(element),
				(elementRng),
				(scale),
				(cst),
				(bigPlane) )
#endomdef

/*+M
Macro vs$grCopy

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
VSgrCopy			__((	long			*msg,
					struct GRmd_env 	*frEnv,
					struct GRid		*frObj,
					struct GRmd_env 	*toEnv,
					short			mxType,
					IGRmatrix		mx,
					struct GRsymbology	*symb,
					struct GRid		*toObj )) ;

#omdef vs$grCopy( msg, frEnv, frObj, toEnv, mxType = 0, mx = NULL, symb = NULL,
		  toObj )

	VSgrCopy( (msg), (frEnv), (frObj), (toEnv), (mxType), (mx), (symb),
		  (toObj) )
#endomdef

/*M+
Macro vs$get_normal

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
VSgetNormal			__((	long			*msg,
					struct GRid		*sfId,
					struct GRmd_env 	*sfEnv,
					double			atParms[2],
					IGRvector		normal )) ;

#omdef vs$get_normal( msg, sfId, sfEnv, parm = NULL, normal )
       VSgetNormal( (msg), (sfId), (sfEnv), (parm), (normal) )
#endomdef

/*+M
Macro vs$mergeCompCurve

Abstract
	Merges the input composite curve into a new curve.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*ccId		Id of composite curve.
	IN	struct GRmd_env *ccEnv		Module env. of composite curve.
	IN	struct GRvg_construct
				*cst		Construction list for new curve.
	IN	int		delInputCv	if TRUE, the input composite
						curve will be deleted if
						operation is successful.
	OUT	struct GRid	*mergedCvId	Id of curve result of merge.
-M*/
extern long
VSmergeCompCurve		__((	long			*msg,
					struct GRid		*ccId,
					struct GRmd_env 	*ccEnv,
					struct GRvg_construct	*cst,
					int			delInputCv,
					struct GRid		*mergedCvId )) ;

#omdef	vs$mergeCompCurve(	msg,
				ccId,
				ccEnv,
				cst,
				delInputCv	= FALSE,
				mergedCvId )
	VSmergeCompCurve( (msg), (ccId), (ccEnv), (cst), (delInputCv),
			  (mergedCvId) )
#endomdef

/*+M
Macro vs$isPlanarCurveClockwise

Abstract
	Determines if the input curve, supposed planar, is oriented clockwise or
	counter-clockwise with respect to the normal vector of its plane.
	This function will fail for line segments or points or non-planar
	curves.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct IGRbsp_curve	*cvGeom 	Geometry of curve.
	IN	struct GRid		*cvId		Id of curve.
	IN	struct GRmd_env 	*cvEnv		Module env. of curve.
	IN	IGRvector		refVector	Reference vector.
	OUT	int			*isClockwise	TRUE/FALSE.
Note
	Either `cvGeom' or `cvId' and `cvEnv' may be input. `refVector' is
	used to decide which normal of the curve's plane will be used to
	determine if it is clockwise or anti-clockwise :
		if dot( refVector, normal-to-curve ) < 0 then
		- normal-to-curve will be used.
-M*/
extern int
VSisPlanarCurveClockwise	__((	long			*msg,
					struct IGRbsp_curve	*cvGeom,
					struct GRid		*cvId,
					struct GRmd_env		*cvEnv,
					IGRvector		refVector,
					int			*isClockwise ));

#omdef vs$isPlanarCurveClockwise(	msg,
					cvGeom		= NULL,
					cvId		= NULL,
					cvEnv		= NULL,
					refVector,
					isClockwise )
	 VSisPlanarCurveClockwise( (msg), (cvGeom), (cvId), (cvEnv),
				   (refVector), (isClockwise) )
#endomdef

/*+M
Macro vs$makeCompCurve

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
VSmakeCompCurve			__((	long			*msg,
					struct GRid		listOfCurves[],
					int			countOfCurves,
					struct GRmd_env		*envOfAllCurves,
					struct GRmd_env		*compCvEnv,
					struct GRid		*compCvId )) ;

#omdef	vs$makeCompCurve( msg, cvList, cvCount, cvEnv, compEnv, compCv )

	VSmakeCompCurve( (msg), (cvList), (cvCount), (cvEnv), (compEnv),
			 (compCv) )
#endomdef

/*+M
Macro vs$makeCompCurve2

Abstract
	Makes a composite curve.
Arguments
	OUT	long		      *msg	Completion code.
	IN	struct GRvg_construct *cst	Construction List.
	IN	struct GRid	      cvList[]	List of input curves.
	IN	int		      cvCount 	Count of input curves.
	IN	struct GRmd_env       *cvEnv	Env. of all input curves.
	IN	struct GRmd_env       *compEnv	Env. of composite curve.
	OUT	struct GRid	      *compCv 	Composite curve created.
-M*/
extern long
VSmakeCompCurve2		__((	long			*msg,
					struct GRvg_construct	*cst,
					struct GRid		listOfCurves[],
					int			countOfCurves,
					struct GRmd_env		*envOfAllCurves,
					struct GRmd_env		*compCvEnv,
					struct GRid		*compCvId )) ;

#omdef	vs$makeCompCurve2( msg, cst, cvList, cvCount, cvEnv, compEnv, compCv )

	VSmakeCompCurve2( (msg), (cst), (cvList), (cvCount), (cvEnv), (compEnv),
			 (compCv) )
#endomdef

/*+M
Macro vs$set_cv_orient_along_UVsf

Abstract
	Sets orientation of a given curve with respect to U or V direction of a
	given surface.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*cvId		Id. of curve.
	IN	struct GRmd_env *cvEnv		Env. of curve.
	IN	struct GRid	*sfId		Id. of surface.
	IN	struct GRmd_env *sfEnv		Env. of surface.
-M*/
extern long
VSsetCurveOrientationAlongUVSf	__((	long			*msg,
					struct GRid		*cvId,
					struct GRmd_env		*cvEnv,
					struct GRid		*sfId,
					struct GRmd_env		*sfEnv )) ;

#omdef	vs$set_cv_orient_along_UVsf( msg, cvId, cvEnv, sfId, sfEnv )

	VSsetCurveOrientationAlongUVSf( (msg), (cvId), (cvEnv), (sfId),
					(sfEnv) )
#endomdef

/*+M
Macro vs$isPlaneClippingCurve

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
VSisPlaneClippingCurve	__((	const struct IGRbsp_curve	*cvGeom,	
				const struct IGRplane		*plane,
				IGRpoint			firstIntPoint,
				double				*firstIntPm )) ;

#omdef	vs$isPlaneClippingCurve(	cvGeom,
					plane,
					firstIntPoint	= NULL,
					firstIntPm	= NULL )
	VSisPlaneClippingCurve( (cvGeom), (plane),
				(firstIntPoint), (firstIntPm) )
#endomdef


/*+M
Macro vs$get_components

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
VSgetComponents		__((	long			*msg,
				const struct GRid	*grobjId,
				const struct GRmd_env	*grobjEnv,
				int			*number,
				struct GRid		*components[] )) ;

#omdef	vs$get_components( msg, grobjId, grobjEnv, number, components )
	VSgetComponents( (msg), (grobjId), (grobjEnv), (number), (components) )
#endomdef

/*+M
Macro vs$projectCompCurveOntoSurface

Abstract
	Project a composite curve onto a surface along a projection vector.
	The projected curve is a composite curve oriented as the original
	composite curve.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRid		*compId 	Id of composite curve
							to project.
	IN	struct GRmd_env 	*compEnv	Env. of composite curve
							to project.
	IN	IGRvector		vector		Vector of projection.
	IN	struct GRid		*surfaceId	Id of surface to
							project onto.
	IN	struct GRmd_env 	*surfaceEnv	Env. of surface to
							project onto.
	IN	struct GRvg_construct	*cst		Construction list for
							projected composite
							curve.
	OUT	struct GRid		*projection	Projected composite
							curve.
-M*/
extern long
VSprojectCompCurveOntoSurface	__((	long			*msg,
					struct GRid		*compId,
					struct GRmd_env 	*compEnv,
					IGRvector		vector,
					struct GRid		*surfaceId,
					struct GRmd_env 	*surfaceEnv,
					struct GRvg_construct	*cst,
					struct GRid		*projection )) ;

#omdef	vs$projectCompCurveOntoSurface( msg,
					compId,
					compEnv,
					vector,
					surfaceId,
					surfaceEnv,
					cst,
					projection )

	VSprojectCompCurveOntoSurface( (msg),
				       (compId),
				       (compEnv),
				       (vector),
				       (surfaceId),
				       (surfaceEnv),
				       (cst),
				       (projection) )
#endomdef

#endif /* vsgeommacros_include */
