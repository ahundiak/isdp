/*
	I/STRUCT
*/
class specification VSsubJoint(0:0) of VSsrcJoint, VSsubFeature ;

override
	VSgetObjDef,
	ACconstruct_feet,
	VSgetOperationMgr,
	VSgetJoinedFeatures ;

from VSsrcJoint inherit
			GRgetattr,
			GRputattr,
			ACset_db_info,
			ACget_db_info,
			ACcheckin_candidate,
			ACgive_structure,
			ACreturn_foot,
			ACgive_path,
			VSdescribeOutput,
			VSgetMassProperties,
			VDget_prefix_name,
			VDget_trans_table_entries ;

end specification VSsubJoint ;

