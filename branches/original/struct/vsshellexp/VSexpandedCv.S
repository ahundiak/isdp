/*
	I/STRUCT
*/
class specification VSexpandedCv(0:0) of VShelper ;

#include "vsshexpdef.h"

/*+c
	Class for an expanded curve.

	Parent #0	: a shell expansion.
	Parent #1	: a curve to expand.

	The curve constructed is the expansion of the parent curve #1.

	How to construct the expanded curve.

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
	cstargs.newflag 	= FALSE ;
	cstargs.class_attr	= (char *)  &vsargs ;

	parents[0]		= <shell expansion> ;	<id and module env>
	parents[1]		= <curve to expand> ;	<id and module env>

	vsargs.parent_count	= 2 ;

	vsargs.parent_list	= parents ;
	vsargs.representation	= NULL ;
	vsargs.feature_att	= NULL ;

	Then use

	sts = om$construct(	msg = message GRgraphics.GRconstruct( &cstarg ),
				... ) ;

-c*/

override
	ACconstruct_feet,
	VSgetObjDef,

/*+o
Message VSevaluate

Abstract
	Performs the regular VSevalute but takes curve parent's symbology.

Arguments
	See message VSevaluate of class VScpx.
-o*/
	VSevaluate ;

/*+d
Message VSget_hull_surface

Abstract
	Returns the hull surface of the shell expansion parent.

Arguments
	OUT	long			*msg		Completion code.
	OUT	struct GRid		*hlId		Id of hull surface.
	OUT	struct GRmd_env 	*hlEnv		Env of hull surface.
-d*/
message VSget_hull_surface( long		*msg ;
			    struct GRid 	*hlId ;
			    struct GRmd_env	*hlEnv ) ;

/*+d
Message VSget_shell_expansion_type

Abstract
	Returns the type of the shell expansion where the expanded curve is
	placed ( "from", "to", "original" shell expansion, See note ).

Arguments
	OUT	long			*msg		Completion code.
	OUT	enum VSshell_type	*type		Type of shell expansion.

Note
	- '*type' can haves the following value ( defined in vsshexpdef.h ) :

		* "VSoriginal" : The shell expansion parent is not used in
				 a merged shell expansion.

		* "VSfrom"     : The shell expansion parent is used in a merged
				 shell expansion as the "from" shell expansion.

		* "VSto"       : The shell expansion parent is used in a merged
				 shell expansion as the "to" shell expansion.
-d*/
message VSget_shell_expansion_type( long		*msg ;
				    enum VSshell_type	*type ) ;

end specification VSexpandedCv ;
