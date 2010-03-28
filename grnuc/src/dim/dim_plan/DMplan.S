class specification DMplan (2:0) of dim_plan, DMproot;

override GRvg;

instance DMplan
{
	OM_S_OBJID win_objid;
	IGRdouble xaxis[3];
	IGRdouble yaxis[3];
	IGRdouble mea_angle;
};

message translate(OM_S_OBJID win_objid; struct GRid *plan_grid);

message translate_local(
		IGRint *msg;
		OM_S_OBJID win_objid;
		IGRdouble matrix[16];
		IGRint count;
		struct GRid *list;
		IGRdouble axis[6];
		struct GRmd_env *md_env;
		struct GRid *plan_grid);

message update_plan(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct GRid *new_plan);

message matcmp(IGRint *msg; IGRdouble matrix[16]);

override change_copy;
override NDplace;
override NDcompute_node;
override give_plane, give_axis, give_parents;
override NDmake_source;

end specification DMplan;
