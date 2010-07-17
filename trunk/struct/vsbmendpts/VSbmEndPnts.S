/*
	I/STRUCT
*/
class specification VSbmEndPnts(0:0) of VShelper ;

/*+c
	This class defines a complex made of two points at each end of a beam.

	Parent #0	: a beam
	How to construct a beam coordinate system :

	struct GRvg_construct	cstargs ;	<Construction list>
	struct VScnst_list	vsargs ;	<STRUCT-specific arg list>
	struct GRobj_env	beam ;		<Parent beam>

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
	vsargs.representation	= AC_NO_REP ;		<no display rep.>
	vsargs.feature_att	= NULL ;		<no attributes>

	Then use

	sts = om$construct(	msg = message GRgraphics.GRconstruct( &cstarg ),
				... ) ;

-c*/
override
	ACconstruct_feet,
	VSgetObjDef ;

end specification VSbmEndPnts ;
