/*
	I/STRUCT
*/
class specification VSrflBeam(0:0) of VSsrcBeam ;

/*+c
	Classes for beams which are reference file links (r-f-l), i.e. which
	represent a beam in a reference file. The aim of these rfl beams
	is to :
		- Attach a reference file containing beams.
		- Establish a link in the active file thanks to the rfl beams.
		- Detach the reference file.
		- Go on working with the rfl beams as if the refernce file
		  were attached.

	Since these beams represent other beams in reference files, their
	attributes are not editable.

	How to construct a rfl beam :

	struct GRvg_construct	cstargs ;	<Construction list>
	struct VScnst_list	vsargs ;	<STRUCT-specific arg list>
	struct GRobj_env	plInRef ;	<Beam in reference file>

	Fill

	cstargs.msg
	cstargs.env_info	= <module environment of design file>
	cstargs.newflag		= FALSE ;
	cstargs.class_attr	= (char *)  &vsargs ;

	(Other fields of `cst' are ignored.)

	vsargs.parent_count	= 1 ;
	vsargs.parent_list	= &plInRef ; <id and module env>
	vsargs.representation	= 0 ; <will take rep. of parent beam>
	vsargs.feature_att	= NULL ; <will take attr. of parent beam>

	Then use

	sts = om$construct(	msg = message GRgraphics.GRconstruct( &cstarg ),
-c*/

override

/*+o
Message VSgetObjDef

Abstract
	One template named "beam".
Arguments
	See message VSgetObjDef of class VScpx.
-o*/
	VSgetObjDef,

/*+o
Message ACconstruct_feet

Abstract
	Copies data from beam in reference file to itself.
Arguments
	See message ACconstruct_feet of class ACncpx.
-o*/
	ACconstruct_feet,

/*+o
Message VSgetSupportAxis

Abstract
	Returns the iso curve at u = 0 of a face for its axis.
Arguments
	See message VSgetSupportAxis of class VSbeam.
-o*/
	VSgetSupportAxis,

/*+o
Message VSgetSupportSf

Abstract
	Returns one of its face as support surface.
Arguments
	See message VSgetSupportSf of class VSbeam.
-o*/
	VSgetSupportSf,

/*+o
Message VSgetUserEditableAttr

Abstract
	Not editable at all.
Arguments
	See message VSgetUserEditableAttr of class VSpart.
-o*/
	VSgetUserEditableAttr,

/*+o
Message VScnst_line_rep

Abstract
	Constructs 2D representation not using the support surface and axis
	used for compute (which may be at different location from those of
	the parent beam) but instead supports matching those of parent beam.
	We need the axis at the exact location since it is part of the 2D
	representation.
Arguments
	See message VScnst_line_rep of class VSsrcBeam.
-o*/
	VScnst_line_rep ;

/*+d
Message VSimportData

Abstract
	Copies data from parent beam in a reference file to itself.
Arguments
	OUT long		*msg		Completion code.
	IN  int			placement	TRUE/FALSE (recompute).
	IN  struct GRobj_env	*fromBeam	Parent beam to copy data from.
-d*/
message VSimportData( long *msg ; int placement ; struct GRobj_env *fromBeam );

reject VDget_prefix_name,
       VDget_trans_table_entries ;

end specification VSrflBeam ;

