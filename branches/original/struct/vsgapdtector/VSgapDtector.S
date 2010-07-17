/*
	I/STRUCT
*/
class specification VSgapDtector(0:0) of VShelper ;

/*+c
	This class defines a "gap detector" for beam. Its purpose is to
	check that a beam is not placed too far away from its support
	surface:
	                                 +----+
                                         |    |
					 +-+  | . .
					   |  |. .
					^  +--. .
				gap	|   . .
					V . .
					. .

	The gap must remain below the maximum admissible gap. If so then the
	gap detector remains silent, i.e. does not manifest itself graphically,
	otherwise, the zones where the gap exceeds the admissible maximum,
	a shown graphically.

	Parent #0	: a beam
	Parent #1	: a numeric expression indicating the maximum
			  admissible gap

	How to construct a gap detector :

	struct GRvg_construct	cstargs ;	<Construction list>
	struct VScnst_list	vsargs ;	<STRUCT-specific arg list>
	struct GRobj_env	beam ;		<Parent beam>
	struct GRobj_env	maxAdmGap ;	<Maximum admissible gap>
	struct GRobj_env	parents[2] ;

	Fill

	cstargs.msg,
	cstargs.display,
	cstargs.level,
	cstargs.properties,

	cstargs.env_info	= <module environment of design file>
	cstargs.name		= <full name of object, NULL if unnamed>
	cstargs.geometry	= NULL ; <this field is ignored>
	cstargs.newflag 	= FALSE ;
	cstargs.class_attr	= (char *)  &vsargs ;

	parents[0]		= beam ;	<Id and module env>
	parents[1]		= maxAdmGap ;	<Id and module env>
	vsargs.parent_count	= 2 ;
	vsargs.parent_list	= parents ;
	vsargs.representation	= AC_NO_REP ;		<No display rep.>
	vsargs.feature_att	= NULL ;

	Then use

	sts = om$construct(	msg = message GRgraphics.GRconstruct( &cstarg ),
				... ) ;

-c*/

#include "vsgddef.h"

instance VSgapDtector {

	double	maxAdmissibleGap ;
	/*
	 * If `excessGap' is > 0 then the we are above the maximum admissible
	 * gap (the largest value of the gap being maxAdmissibleGap + excessGap)
	 * otherwise we are below the maximum accessible gap.
	 */
	double  excessGap ;

} ;

override
	ACgive_structure,
	ACconstruct_feet,
	ACreturn_foot,
	VSdescribeOutput,
	VSgetObjDef ;

end specification VSgapDtector ;
