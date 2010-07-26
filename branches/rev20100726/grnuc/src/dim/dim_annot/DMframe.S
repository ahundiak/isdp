class specification DMframe(2:0) of DMannot;

override GRvg;

message update_text_box(
	IGRlong *msg;
	IGRuchar *text_string;
	struct IGRestx *estx;
	struct IGRlbsys *lbs_geom;
	struct GRmd_env *md_env);

message set_datum_term(
	IGRlong *msg;
	struct GRid *term_grid;
	struct GRmd_env *md_env;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc);

message get_tol_just(
	IGRint *rc;				/*  OUTPUT	*/
	IGRdouble *cursor;			/*  INPUT/OUTPUT */
	IGRboolean src_type;			/*  INPUT	*/
	IGRdouble geometry[4][3];		/*  INPUT	*/
	struct DMplan_info *plan_info;		/*  INPUT	*/
	IGRshort *txt_just;			/*  OUTPUT	*/
	IGRchar *annot_dir;			/*  OUTPUT	*/
	IGRboolean *on_element;			/*  OUTPUT	*/
	IGRdouble  ext_line[6];			/*  OUTPUT	*/
	struct DMsenv_param *par_senv;
	struct GRmd_env *md_env);

message make_profile_sym(
	IGRint *msg;
	struct DMsenv_param *p_par_senv;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env);
message set_tol_mode( IGRchar tol_mode);
message set_profile_type(IGRchar profile_type);
message get_profile_type(IGRchar *profile_type);

message check_profile_type(IGRint *msg;
		IGRint tol_sym;
		struct GRmd_env *md_env);

override fill_info;
override txdynamics, put_dim_attr;
override get_disp_list;
override chg_an_dp;

end specification DMframe;
