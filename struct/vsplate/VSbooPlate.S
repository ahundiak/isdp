/*
	I/STRUCT
*/
class specification VSbooPlate(0:0) of VSdprPart, VSmodPlate ;

/*+c
	This class defines objects which are plates having undergone a boolean
	difference to cut them out.

	Parents : #0		a plate				(operand)
		  #1 to n	a solid			OR	(operator)
				a surface		OR
				a planar curve	

	Note :
		If a parent is a surface, the boolean difference will be
	performed so that the part of the plane which is on the same side
	as the normal of the surface will be removed.

		If parent is a closed curve, a surface of projection will
	be created, using the normal of the plane of the curve, big enough
	so as to traverse the plate. Then the boolean difference will be
	performed so that the part of the plate which is on the same side
	as the center of the planar curve will be removed.

		The maximum number of operator parents allowed is
	`VS_K_bpMAX_NOTCHES' #define'd in "vsplatedef.h".
-c*/

from VSdprPart inherit VSget_sub_cmp_ix ;

override

/*+o
Message VSgetObjDef

Abstract
	Returns the class definition of a VSbooPlate object.
Arguments
	See message VSgetObjDef of class VScpx.
-o*/
	VSgetObjDef,

/*+o
Message GRgetrang
 
 Abstract
	 Sends range of parent plate. See GRgraphics.S.
 -o*/
		 GRgetrang,

/*+o
Message NDmove_to_root

Abstract
	Sends VSfeature.VSmove_to_root to self.
Arguments
	See message NDmove_to_root of class NDnode.
-o*/
	NDmove_to_root,

/*+o
Message NDparent_deleted

Abstract
	Sends VSfeature.VSparentsDeleted to self. See VSfeature.S.
-o*/
	NDparent_deleted,

/*+o
Message NDdelete

Abstract
	Sends VSfeature.VSdelete to self.
Arguments
	See message NDdelete of class NDnode.
-o*/
	NDdelete,

/*+o
Message ACconstruct_feet

Abstract
	Consumes parent plate, makes boolean difference between consumed plate
	and parent solids.
Arguments
	See message ACconstruct_feet of class ACncpx.
-o*/
	ACconstruct_feet,

/*+o
Message ACset_NV_rep

Abstract
	We want parent consumed plate to have the same consumed representation
	as our new representation: we need either a solid or a surface to
	operate on if we are either in 2D or 3D.
Arguments
	See message ACset_NV_rep of class ACncpx.
-o*/
	ACset_NV_rep,
	VSgetFaceCount ;

/*+d
Message VSconstruct_3D_rep

Abstract
	Constructs the 3D representation of the boolean plate, ie. performs
	a boolean difference between the parent plate's solid (operand) and
	the input solids (operators).
Arguments
	IN	long			*msg		Completion code.
	IN	int			optrCount	Count of operators.
	IN	struct GRobj_env	optrList[]	List of operators.
	IN	struct GRobj_env	*operand	Operand solid.
	IN	struct GRvg_construct	*resCst		Construction list of
							result.
	OUT	struct GRid		*result		Result of boolean
							difference.
-d*/
message VSconstruct_3D_rep(	long			*msg ;
				int			optrCount ;
				struct GRobj_env	optrList[],
							*operand ;
				struct GRvg_construct	*resCst ;
				struct GRid		*result ) ;

/*+d
Message VSconstruct_2D_rep

Abstract
	Constructs the 2D representation of the boolean plate, ie. performs
	the intersection between the operand (surface) and the operators
	(solid) and impose the intersection curves as boundaries on the operand.
Arguments
	IN	long			*msg		Completion code.
	IN	int			optrCount	Count of operators.
	IN	struct GRobj_env	optrList[]	List of operators.
	IN	struct GRobj_env	*operand	Operand surface.
	IN	struct GRvg_construct	*resCst		Construction list of
							result.
	OUT	struct GRid		*result		Result of operation.
-d*/
message VSconstruct_2D_rep(	long			*msg ;
				int			optrCount ;
				struct GRobj_env	optrList[],
							*operand ;
				struct GRvg_construct	*resCst ;
				struct GRid		*result ) ;
end specification VSbooPlate ;

