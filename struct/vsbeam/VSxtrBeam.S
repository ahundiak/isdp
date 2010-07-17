/*
	I/STRUCT
*/
class specification VSxtrBeam(0:0) of VSdprPart, VSmodBeam ;

#include "OMmacros.h"
#include "emsbool.h"
#include "vs.h"
#include "vsbeamdef.h"
#include "vsbeam.h"

/*+c
	Class of a beam obtained by extending that beam and trimming it against
	a surface.
-c*/

instance VSxtrBeam {
	/*
	 * Which end of beam does extend/trim occurs ?
	 */
	char extEnd ;
} ;

override

/*+o
Message GRconstruct

Abstract
	Essentially gets info stating which end is to be extended and trimmed,
	sends message to self with respect to parent class.
Arguments
	See message GRconstruct of class GRvg.

	How to fill the arguments :
		struct GRvg_construct	cstargs ;
		struct VScnst_list	vsargs ;
		struct GRobj_env	parentBeam,
					trimSurface,
					parentList[2] ;
		int			extEnd ;

		Fill	cstargs.msg.
		The fields
			cstargs.display,
			cstargs.level,
			cstargs.properties
			cstargs.name
		are ignored.

		cstargs.env_info	= <mod. env. of design file>
		cstargs.geometry	= NULL ; <this field is ignored>
		cstargs.newflag		= FALSE ;
		cstargs.class_attr	= (char *)  &vsargs ;

		parentList[0]		= parentBeam ; <id and module env>
		parentList[1]		= trimSurface; <id and module env>
		extEnd			= <0 or 1>
		vsargs.parent_count	= 2 ;
		vsargs.parent_list	= parentList ;
		vsargs.feature_att	= (char *) &extEnd ;

	Then input `&cstargs' to message GRconstruct.
Note
	In case of error, the objects deletes itself.
-o*/
	GRconstruct,

/*+o
Message NDdelete

Abstract
	Sends VSfeature.VSdelete to self. See VSfeature.S.
-o*/
	NDdelete,

/*+o
Message NDmove_to_root

Abstract
	Sends VSfeature.VSmove_to_root to self. See VSfeature.S.
-o*/
	NDmove_to_root,

/*+o
Message NDparent_deleted

Abstract
	Sends VSfeature.VSparentsDeleted to self. See VSfeature.S.
-o*/
	NDparent_deleted,
	ACconstruct_feet,

/*+o
Message VSgetSupportAxis

Abstract
	The axis of this beam is extended to the trimming surface.
Arguments
	See message VSgetSupportAxis of class VSbeam.
-o*/
	VSgetSupportAxis,
	VSgetObjDef ;

from VSdprPart inherit	VSget_sub_cmp_ix ;

/*+d
Message VSextendAxis

Abstract
	Takes the original beam axis and produces a copy of it, extended to
	the trimming surface.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	*trimSurf	Surf. to extend axis to.
	IN	struct GRvg_construct	*cst		Construction list for
							extended axis.
	OUT	struct GRid		*extAxis	Id of extension.
-d*/
message VSextendAxis(	long			*msg ;
			struct GRobj_env	*trimSurf ;
			struct GRvg_construct	*cst ;
			struct GRid		*extAxis ) ;

/*+d
Message VScnst_linear_rep

Abstract
	Construct beam's linear ("light" or "external") representation.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env		*myEnv		Beam's module environment.
	IN	struct GRobj_env	*trimSurf	Surf. to extend axis to.
	IN	struct GRvg_construct	*cst		Construction list for
							light graphics.
	OUT	struct GRid		*linearRep	Object representing the
							light representation.
Note
	The construction list is only used for the display, level, properties
	and environment info fields.
-d*/
message VScnst_linear_rep(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRobj_env	*trimSurf ;
				struct GRvg_construct	*cst ;
				struct GRid		*linearRep ) ;

/*+d
Message VScnst_solid_rep

Abstract
	Constructs beam's solid representation by extending parent beam's
	solid.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env		*myEnv		Beam's module environment.
	IN	long			parentType	Type of parent.
	IN	struct GRobj_env	*trimSurf	Sf. to extend solid to.
	IN	VSdspRep		sectRep		Rep. of section.
	IN	struct GRvg_construct	*cst		Construction list for
							solid graphics.
	IN	struct GRmd_env		*solidEnv	Env. of solid.
	IN	struct GRid		*solidToExtend	Parent's solid.
	OUT	struct GRid		*solidRep	Object representing the
							light representation.
Note
	The construction list is only used for the display, level, properties
	and environment info fields.
-d*/
message	VScnst_solid_rep(	long			*msg ;
				struct GRmd_env		*myEnv ;
				long			parentType ;
				struct GRobj_env	*trimSurf ;
				VSdspRep		sectRep ;
				struct GRvg_construct	*cst ;
				struct GRmd_env		*solidEnv ;
				struct GRid		*solidToExtend,
							*solidRep ) ;

/*+d
Message VSgetExtendedEnd

Abstract
	Returns which end (0 or 1) where beam has been extended.
Arguments
	OUT	long	*msg		Completion code.
	OUT	int	*p_extEnd	Index of end of extension.
-d*/
message VSgetExtendedEnd( long *msg ; int *p_extEnd ) ;

end specification VSxtrBeam ;

