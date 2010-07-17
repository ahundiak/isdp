/*
	I/STRUCT
*/
class specification VSimbPlate(0:0) of VSmodPlate ;

/*+c
	Class for a plate which is the result of an impose-boundary operation.
-c*/

override

/*+o
Message VSgetObjDef

Abstract
	Returns the object definition of a VSimbPlate object.
Arguments
	See message VSgetObjDef of class VScpx.
-o*/
	VSgetObjDef,

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
	Consumes parent plate, imposes boundaries on consumed plate and
	generate its output according to the its representation.
Arguments
	See message ACconstruct_feet of class ACncpx.
-o*/
	ACconstruct_feet ;

/*+d
Message VSimposeBoundary

Abstract
	Performs the impose-boundary operation on the surface which will be
	used to generate an output, this operation may cover several kinds of
	features ( holes, markings, ... ) according to the class implementing
	the message.
Arguments
	OUT	long			*msg		Completion code.
	IN	int			bndryCount	Count of boundaries.
	IN	struct GRobj_env	bndryList[]	List of boundaries.
	IN	struct GRobj_env	surface		Surface.
	IN	int			surfaceIsPlane	Optimization flag.
-d*/	
message VSimposeBoundary(	long			*msg ;
				int			bndryCount ;
				struct GRobj_env	bndryList[],
							*surface ;
				int			surfaceIsPlane ) ;
reject	VSimposeBoundary ;

end specification VSimbPlate ;

