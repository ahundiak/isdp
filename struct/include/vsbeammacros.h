/*
	I/STRUCT
*/
#ifndef vsbeammacros_include
#	define vsbeammacros_include

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
#ifndef vsdpb_include
#	include "vsdpb.h"
#endif
#ifndef vsattr_include
#	include "vsattr.h"
#endif
#ifndef vsbeam_include
#	include "vsbeam.h"
#endif

/*+M
Macro vs$fillBeamAttr

Abstract
	Fills some or all of the fields of a beam attribute structure.
Arguments
	OUT	long	*msg		Completion code.
	IN	int	options		Mask flagging attributes to be filled
					in (ORing of masks in vsoptdef.h).
	IN	char	*partFam	PDM/PDU part family of beam.
	IN	char	*partNum	PDM/PDU part umber of profile.
	IN	char	*matType	Material of beam.
	IN	char	*matGrade	Grade of material.
	IN	int	mbrClass	Member class.
	IN	int	mbrType		Member type.
	IN	char	*usrNote	User notes about parts.
	IN	char	*mtoSrc		MTO source.
	IN	char	*mtoStk		MTO stock
	IN	int	mtoChgNo	MTO change request number.
	IN	double	FireProofing	Thickness of fireproofing material.
	IN	char	*apprvStat	Approval status.
	IN	char	*constStat	Construction status.
	IN	struct GRid
			*usrAttrId	Id of collection of user attributes.
	IN	double	xOffset		X-offset of beam wrt support axis.
	IN	double	yOffset		Y-offset of beam wrt support axis.
	IN	double	RotAngle	Angle of beam wrt support axis.
	IN	enum VScardinal_point
			cardPnt		Cardinal point of cross-section.
	IN	enum VSsymmetry
			symmetry	Symmetry of beam wrt support axis.
	OUT	VSpartAttr
			*partAttr	Part attributes.
	OUT	VSbeamAttr
			*beamAttr	Beam-specific attributes.
Notes
	If an attribute is specified in the options, the corresponding value
	must be input (the default values are meaningless and even dangerous).
	If an input character string attribute was too long, it is truncated and
	`*msg' is set to EMS_I_Fail.
-M*/
extern long
VSfillBeamAttr			__((	long			*msg,
					int			mask,
					char			*partFam,
					char			*partNum,
					char			*matType,
					char			*matGrade,
					int			mbrClass,
					int			mbrType,
					char			*usrNotes,
					char			*mtoSrc,
					char			*mtoStk,
					int			mtoChgNo,
					double			FireProofing,
					char			*apprvStat,
					char			*constStat,
					struct GRid		*usrAttr,
					double			xOffset,
					double			yOffset,
					double			RotAngle,
					enum VScardinal_point	cardPnt,
					enum VSsymmetry		symmetry,
					VSpartAttr		*part,
					VSbeamAttr		*beam )) ;

#omdef vs$fillBeamAttr(	msg,
			options,
			partFam		= NULL,
			partNum		= NULL,
			matType		= NULL,
			matGrade	= NULL,
			mbrClass	= 0,
			mbrType		= 0,
			usrNotes	= NULL,
			mtoSrc		= NULL,
			mtoStk		= NULL,
			mtoChgNo	= 0,
			FireProofing	= 0.,
			apprvStat	= NULL,
			constStat	= NULL,
			usrAttrId	= NULL,
			xOffset		= 0.,
			yOffset		= 0.,
			RotAngle	= 0.,
			cardPnt		= 0,
			symmetry	= 0,
			partAttr,
			beamAttr )
	VSfillBeamAttr(	(msg),
			(options),
			(partFam),	/*  1 PDM/PDU family name	*/
			(partNum),	/*  2 PDM/PDU part number	*/
			(matType),	/*  3 Material			*/
			(matGrade),	/*  4 Grade of material		*/
			(mbrClass),	/*  5 Member class		*/
			(mbrType),	/*  6 Member type		*/
			(usrNotes),	/*  7 User comments		*/
			(mtoSrc),	/*  8 Source number		*/
			(mtoStk),	/*  9 Stock number		*/
			(mtoChgNo),	/* 10 Change-request number	*/
			(FireProofing),	/* 11 Fireproofing thickness	*/
			(apprvStat),	/* 12 Approval status		*/
			(constStat),	/* 13 Construction status	*/
			(usrAttrId),	/* 14 Collection of user attr.	*/
			(xOffset),	/* 15 X offset from beam axis	*/
			(yOffset),	/* 16 Y offset from beam axis	*/
			(RotAngle),	/* 17 Rot. angle wrt local CS	*/
			(cardPnt),	/* 18 Cardinal point		*/
			(symmetry),	/* 19 Symmetry wrt local CS	*/
			(partAttr),
			(beamAttr) )
#endomdef

/*+M
Macro vs$make_beam_segment

Abstract
	Given a cross-section curve, an axis curve and a support surface,
	generates a solid-composite surface such that the solid is along the
	axis and normal to the support surface.
Arguments
	IN	long			*msg		Completion code.
	IN	struct GRobj_env	*xSection	Cross-section curve.
	IN	struct GRobj_env	*surface	Support surface.
	IN	struct GRobj_env	*axis		Axis of segment.
	IN	struct GRvg_construct	*cst		Construction list.
	OUT	struct GRid		*segment	Generated segment.
Note
	The cross-section must be a planar closed composite curve.
	The fields `name', `class_attr', `newflag' and `geometry' of the
	construction list are not used.
-M*/
extern long
VSmake_beam_segment		__((	long			*msg,
					struct GRobj_env	*profile,
					struct GRobj_env	*surface,
					struct GRobj_env	*axis,
					struct GRvg_construct	*cst,
					struct GRid		*p_segment )) ;

#omdef vs$make_beam_segment(	msg,
				xSection,
				surface,
				axis,
				cst,
				segment )

	VSmake_beam_segment(	(msg),
				(xSection),
				(surface),
				(axis),
				(cst),
				(segment) )

#endomdef

/*+M
Macro vs$make_linear_beam_rep

Abstract
	Given a cross-section curve, an axis curve and a support surface,
	generates a complex graphic object representing a beam in linear
	representation.
Arguments
	IN	long			*msg		Completion code.
	IN	struct GRobj_env	*xSection	Cross-section curve.
	IN	struct GRobj_env	*surface	Support surface.
	IN	struct GRobj_env	*axis		Axis of segment.
	IN	int			copyAxis	TRUE/FALSE.
	IN	struct GRvg_construct	*cst		Construction list.
	OUT	struct GRid		*linearRep	Graphic complex.
Note
	The cross-section must be a planar closed composite curve, it will be
	included in the graphic complex, as well as the input axis if `copyAxis'
	is FALSE.
	The fields `name', `class_attr', `newflag' and `geometry' of the
	construction list are not used.
-M*/
extern long
VSmake_linear_beam_rep		__((	long			*msg,
					struct GRid  		*profile,
					struct GRobj_env	*surface,
					struct GRobj_env	*axis,
					int			copyAxis,
					struct GRvg_construct	*cst,
					struct GRid  		*linearRep )) ;

#omdef vs$make_linear_beam_rep(	msg,
				xSection,
				surface,
				axis,
				copyAxis,
				cst,
				linearRep )

	VSmake_linear_beam_rep(	(msg),
				(xSection),
				(surface),
				(axis),
				(copyAxis),
				(cst),
				(linearRep) )

#endomdef

/*+M
Macro vs$mapProfileToSite

Abstract
	Given a profile curve and a mapping matrix, applies the matrix to the
	profile curve, first copying the input profile if requested.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	*originPrfl	Original profile.
	IN	IGRmatrix		mapMx		Mapping matrix.
	IN	short			mxType		Type of mapping matrix.
	IN	struct GRvg_construct	*cst		Construction list for
							on-site profile.
	IN	int			copy		TRUE/FALSE : copy before
							mapping ?
	OUT	struct GRid		*onSitePrfl	On-site profile.
Note
	`cst' is used for its `display', `level' and `env_info' fields.
-M*/
extern long
VSmapProfileToSite		__((	long			*msg,
					struct GRvg_construct	*cst,
					IGRmatrix		mapMx,
					short			*mxType,
					int			copy,
					struct GRobj_env	*originPrfl,
					struct GRid		*onSitePrfl )) ;

#omdef	vs$mapProfileToSite(	msg,
				cst,
				mapMx,
				mxType,
				copy,
				originPrfl,
				onSitePrfl )

	VSmapProfileToSite(	(msg),
				(cst),
				(mapMx),
				(mxType),
				(copy),
				(originPrfl),
				(onSitePrfl) )			
#endomdef

/*+M
Macro vs$listBeamFaces

Abstract
	Returns the list of the faces of a beam : their internal foot names
	and message numbers of their decriptions.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*beam		Id of beam.
	OUT	int		*count		Count of faces.
	OUT	char		***names	Foot names of faces.
	OUT	long		**descrs	Descriptions of faces.
Note
	The memory allocated for `*names' names must be freed with
		VSfreeList( *names ) ;
	The memory allocated for `*descrs' must be freed with
		free( *descrs ) ;
-M*/
extern long
VSlistBeamFaces			__((	long		*msg,
					struct GRid	*beam,
					int		*count,
					char		***names,
					long		**descrs )) ;

#omdef vs$listBeamFaces( msg, beam, count, names, descrs )
	VSlistBeamFaces( (msg), (beam), (count), (names), (descrs) )
#endomdef

/*+M
Macro vs$extendAxisForTrimmingPlane

Abstract
	Extends a beam's axis up and even beyond a plane so that the beam
	constructed on this axis will encounter the plane (ie. fully intersect
	it).
Arguments
	OUT long		*msg		Completion code.
	IN  struct GRid		*beamId		Id of beam.
	IN  struct GRmd_env	*beamEnv	Module environment of beam.
	IN  struct GRobj_env	*supports	Supports of beam.
	IN  struct IGRbsp_curve	*axisGeom	Geometry of beam axis.
	IN  struct IGRbsp_surface
				*planeGeom	Geometry of plane.
	IN  double		whichEnd	Of beam (0. or 1.).
	IN  double 		moreLength	%-age of extra length to add
						to axis. Just in case extension
						won't be enough.
	IN  int			portionOnly	TRUE : return extension only
						FALSE: return whole axis.
	OUT struct IGRbsp_curve	**extension	Geometry of extension.
Note
	- `supports' may be obtained with VSpart.VSget_supports send to beam.
	- `axisGeom' is the geometry of `supports[1]'.
	- `whichEnd' is the end of the beam axis nearest to the plane.
	- `*extension' must be freed with :
				`BSfreecv( &rc, *extension ) ;'
-M*/
extern long
VSext_axis_for_trimming_plane	__((	long			*msg,
					struct GRid		*beamId,
					struct GRmd_env		*beamEnv,
					struct GRobj_env	*supports,
					struct IGRbsp_curve	*axisGeom,
					struct IGRbsp_surface	*planeGeom,
					double			whichEnd,
					double 			moreLength,
					int			portionOnly,
					struct IGRbsp_curve	**extension )) ;

#omdef vs$extendAxisForTrimmingPlane(	msg,
					beamId,
					beamEnv,
					supports,
					axisGeom,
					planeGeom,
					whichEnd,
					moreLength,
					portionOnly,
					extension )
	VSext_axis_for_trimming_plane(	(msg),
					(beamId),
					(beamEnv),
					(supports),
					(axisGeom),
					(planeGeom),
					(whichEnd),
					(moreLength),
					(portionOnly),
					(extension) )
#endomdef

#endif
