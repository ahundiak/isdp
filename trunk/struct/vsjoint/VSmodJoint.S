/*
	I/STRUCT
*/
class specification VSmodJoint(0:0) of VSjoint, VSmodFeature ;

override
	ACconstruct_feet,
	VSgetObjDef,
	VSgetJoinedFeatures ;

from ACncpx  inherit
		NDget_virtual_objects ;
from VSjoint inherit
		ACset_db_info,
		ACget_db_info,
		ACcheckin_candidate,
		ACgive_path,
		ACgive_structure,
		VSputJoint,
		VSgetJoints,
		VSputModJoints,
		VSdescribeOutput,
		VSgetMassProperties,
		VDget_prefix_name,
		VDget_trans_table_entries ;

end specification VSmodJoint ;

