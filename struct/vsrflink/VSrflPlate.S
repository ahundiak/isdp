/*
	I/STRUCT
*/
class specification VSrflPlate(0:0) of VSsrcPlate ;

/*+c
	Classes for plates which are reference file links (r-f-l), ie. which
	represent a plate in a reference file. The aim of these rfl plates
	is to :
		- Attach a reference file containing plates.
		- Establish a link in the active file thanks to the rfl plates.
		- Detach the reference file.
		- Go on working with the rfl plates as if the refernce file
		  were attached.

	Since these plates represent other plates in reference files, their
	attributes are not editable.

	How to construct a rfl plate :

	struct GRvg_construct	cstargs ;	<Construction list>
	struct VScnst_list	vsargs ;	<STRUCT-specific arg list>
	struct GRobj_env	plInRef ;	<Plate in reference file>

	Fill

	cstargs.msg
	cstargs.env_info	= <module environment of design file>
	cstargs.newflag		= FALSE ;
	cstargs.class_attr	= (char *)  &vsargs ;

	(Other fields of `cst' are ignored.)

	vsargs.parent_count	= 1 ;
	vsargs.parent_list	= &plInRef ; <id and module env>
	vsargs.representation	= 0 ; <will take rep. of parent plate>
	vsargs.feature_att	= NULL ; <will take attr. of parent plate>

	Then use

	sts = om$construct(	msg = message GRgraphics.GRconstruct( &cstarg ),
-c*/

instance VSrflPlate {
	unsigned short	map[2] ;
} ;

override

/*+o
Message VSgetObjDef

Abstract
	One template named "plate".
Arguments
	See message VSgetObjDef of class VScpx.
-o*/
	VSgetObjDef,

/*+o
Message ACconstruct_feet

Abstract
	Copies data from plate in reference file to itself.
Arguments
	See message ACconstruct_feet of class ACncpx.
-o*/
	ACconstruct_feet,

/*+o
Message VSgetSupports

Abstract
	Returns bottom surface of plate.
Arguments
	See message VSgetSupports of class VSpart.
-o*/
	VSgetSupports,

/*+o
Message VSgetUserEditableAttr

Abstract
	Not editable at all.
Arguments
	See message VSgetUserEditableAttr of class VSpart.
-o*/
	VSgetUserEditableAttr,
	VStopBottomMapping ;

/*+d
Message VSimportData

Abstract
	Copies data from parent plate in a reference file to itself.
Arguments
	long			*msg		Completion code.
	int			placement	TRUE/FALSE (recompute).
	struct GRobj_env	*fromPlate	Parent plate to copy data from.
-d*/
message VSimportData( long *msg ; int placement ; struct GRobj_env *fromPlate );

reject VDget_prefix_name,
       VDget_trans_table_entries ;

end specification VSrflPlate ;

