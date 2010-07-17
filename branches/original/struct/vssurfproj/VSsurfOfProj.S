/*
	I/STRUCT
*/ 
class specification VSsurfOfProj(0:0) of VShelper ;

/*+c
	Class for a surface of projection parallel to plane. This surface is 
	constructed from 3 elements which are :

	Parent #0	: a plane
	Parent #1	: a curve
	Parent #2	: a expression ( width of surface )
	
	The surface constructed is the result of the projection of the curve
	along a vector which is the cross product between the normal of the 
	plane and the tangent of the curve at parameter 0. The width of 
	the surface is the expression value given in Parent #2.
	
	How to construct the surface :

	struct GRvg_construct	cstargs ;	<Construction list>
	struct VScnst_list	vsargs ;

	Fill

	cstargs.msg,
	cstargs.display,
	cstargs.level,
	cstargs.properties,

	cstargs.env_info	= <module environment of design file>
	cstargs.name		= <full name of object, NULL if unnamed>
	cstargs.geometry	= NULL ; <this field is ignored>
	cstargs.newflag		= FALSE ;
	cstargs.class_attr	= (char *)  &vsargs ;

	parents[0]		= <plate> ;		<id and module env>
	parents[1]		= <curve> ;		<id and module env>
	parents[2]		= <width> ; 		<id and module env>

	vsargs.parent_count	= 3 ;

	vsargs.parent_list	= parents ;
	vsargs.representation	= NULL ;
	vsargs.feature_att	= NULL ;

	Then use

	sts = om$construct(	msg = message GRgraphics.GRconstruct( &cstarg ),
				... ) ;

-c*/

override
	ACconstruct_feet,
	VSgetObjDef;


end specification VSsurfOfProj ;

