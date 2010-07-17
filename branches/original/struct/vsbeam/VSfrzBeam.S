/*
	I/STRUCT
*/

class specification VSfrzBeam(0:0) of VSsrcBeam ;

instance VSfrzBeam {
	double		length ;
	int		geomType ;
} ;

from ACncpx inherit
		GRcopy ;

from VSpart inherit
	VSsetOrientation,
	VSgetOrientation,
	VShasOrientation ;

override	GRxform,
		ACbecome_foot,
		NDcopy_to_root,
		ACgive_structure,
		VSgetObjDef,
		VSgetUserEditableAttr,
		VSgetBeamLength ;

reject	GRputattr,
	VDget_prefix_name,
	VDget_trans_table_entries,
	VSgetSupports,
	VSgetSupportAxis,
	VSgetSupportSf,
	VScnst_line_rep,
	VScnst_solid_rep ;

/*+d
Message VSformatUsingOriginal

Abstract
	Message send by original beam to this copy of itself so it can further
	format itself possibly using some data of the original beam, since this
	copy is of a class different from the original's.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env		*myEnv		My module environment.
	IN	struct GRobj_env	*original	Original beam.
-d*/
message VSformatUsingOriginal(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRobj_env	*original ) ;

end specification VSfrzBeam ;

