class specification DMannot(2:0) of DMroot;

#include "dimannot.h"

override GRvg;

instance DMannot
{
	IGRchar leader;
	IGRchar bln_dir;
	IGRchar dual_mode;
	IGRchar tol_symbol;
	
	variable IGRdouble break_pt[];
	variable IGRchar   txexp[];
};

message gather_data(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	IGRdouble start_pt[3];
	IGRdouble end_pt[3];
	struct DMplan_info *plan_info;
	struct DMsenv_param *par_senv;
	struct GRmd_env *md_env);

message get_graphics(
	IGRboolean create;
	struct GRid *text_grid;
	struct GRid *lead_grid;
	struct GRid *term_grid;
	struct GRmd_env *md_env);

message fill_leader_info(
	IGRint *msg;
	IGRpoint start_pt;
	IGRpoint end_pt;
	struct GRid lead_grid;
	struct GRid text_grid;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env);

message make_an_text(
	IGRint *msg;
	struct DMplan_info *plan_info;
	struct DMsenv_param *par_senv;
	struct GRid text_grid;
	struct GRmd_env *md_env);

message make_an_term(
	IGRint *msg;
	struct DMplan_info *plan_info;
	struct DMsenv_param *par_senv;
	struct GRid term_grid;
	struct GRmd_env *md_env);

message make_lead_line(
	IGRint *msg;
	struct DMsenv_param *par_senv;
	struct DMplan_info *plan_info;
	struct GRid lead_grid;
	struct GRmd_env *md_env);

message update_leader(
	IGRint *msg;
	IGRint *num_vertex;
	IGRdouble *geometry;
	struct DMsenv_param *par_senv;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env);

message get_just_attr(IGRchar *just_attr);

message set_text_attr(
	IGRint *msg;
	struct GRid text_grid;
	struct GRmd_env *md_env);

message txdynamics(IGRlong *msg;
	IGRint control;
	IGRint info_flag;
	IGRint *level;
	IGRchar *info;
	struct EX_button *cursor;
	unsigned char *character;
	IGRint numbytes;
	IGRdouble *rot_matrix;
	struct GRmd_env *md_env);

message modify_geom(
	IGRint *msg;
	IGRint control;
	IGRint vertex_no;
	IGRpoint cursor;
	struct GRid *win_grid;
	struct GRmd_env *md_env);

message ANadd_delete_vertex(
	IGRint *msg;
	IGRint flag;
	IGRdouble *vertex;
	struct GRmd_env *md_env);

message ANadd_text_to_buff(
	char *info;
	OM_S_OBJID pnt_objid;
	int control;
	struct GRmd_env *md_env;
	IGRdouble *pnt;
	IGRdouble *rot_matrix;
	char *string;
	int num_bytes);

message get_disp_list(
	IGRint *rc;
	IGRint *count;
	struct GRid *list;
	struct GRmd_env *md_env);


message chg_an_dp(
	IGRint *msg;
	struct DMsenv_param *par_senv);

message put_dim_attr(struct annot_attr *attr);

message get_active_senv(struct DMsenv_param *par_senv);
message get_edit_attr(
	IGRint at_type;		/* - type of attr to get   */
	struct annot_attr *attr);

override NDplace;
override DMplace;
override DMcompute_node;
override DMreturn_roots;
override update_parents;

override get_dim_attr;
override copy_dim_attr;
override get_dim_params;
override set_dim_params;
override get_dimension_plane;

reject txdynamics;
reject ANadd_text_to_buff;

end specification DMannot;

