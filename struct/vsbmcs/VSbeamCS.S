/*
	I/STRUCT
*/
class specification VSbeamCS(0:0) of VShelper ;

#include "vsbmcs.h"

/*+c
	This class defines coordinate systems put at the end of a beam.

	Parent #0	: a beam

	How to construct a beam coordinate system :

	struct GRvg_construct	cstargs ;	<Construction list>
	struct VScnst_list	vsargs ;	<STRUCT-specific arg list>
	struct GRobj_env	beam ;		<Parent beam>
	VSbmCsPos		csAttr ;	<Attributes of this object>

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

	vsargs.parent_count	= 1 ;
	vsargs.parent_list	= &beam ;		<id and module env>
	vsargs.representation	= AC_NO_REP ;		<No display rep.>
	vsargs.feature_att	= (char *) &csAttr ;

	csAttr.endNo		= <0 or 1>
	csAttr.cardPnt		=   <VS_e_BOT_LEFT or VS_e_BOT_RGHT
				  or VS_e_TOP_LEFT or VS_e_TOP_RGHT>
	Then use

	sts = om$construct(	msg = message GRgraphics.GRconstruct( &cstarg ),
				... ) ;

-c*/
instance VSbeamCS {
	OMbyte
		/*
		 * Which cardinal point. The possible values are four among
		 * those of type `enum VScardinal_point' defined in "vsdpb.h" :
		 * - VS_e_BOT_LEFT
		 * - VS_e_BOT_RGHT
		 * - VS_e_TOP_LEFT
		 * - VS_e_TOP_RGHT
		 */
		cardPnt,
		/*
		 * Which end of beam : 0 ( 1st end ) or 1 ( 2nd end ).
		 */
		endNo ;
} ;

override
	GRputattr,
	GRgetattr,
	ACconstruct_feet,
	VSgetObjDef ;

end specification VSbeamCS ;
