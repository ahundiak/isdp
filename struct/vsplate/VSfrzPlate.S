/*
	I/STRUCT
*/
class specification VSfrzPlate(0:0) of VSsrcPlate ;

instance VSfrzPlate {
	unsigned short	map[2] ;
} ;

from ACncpx inherit
		GRcopy ;

override	GRxform,
		ACbecome_foot,
		NDcopy_to_root,
		VSgetObjDef,
		VStopBottomMapping,
		VSgetUserEditableAttr ;

reject	GRputattr,
	VSgetSupports,
	VDget_prefix_name,
	VDget_trans_table_entries ;

/*+d
Message VSformatUsingOriginal

Abstract
	Message send by original plate to this copy of itself so it can further
	format itself possibly using some data of the original plate, since this
	copy is of a class different from the original's.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env		*myEnv		My module environment.
	IN	struct GRobj_env	*original	Original plate.
-d*/
message VSformatUsingOriginal(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRobj_env	*original ) ;

end specification VSfrzPlate ;

