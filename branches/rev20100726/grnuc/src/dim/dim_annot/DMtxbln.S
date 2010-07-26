class specification DMtxbln(2:0) of DMannot;

#include "dimannot.h"

override GRvg;

message position_balloon(
	IGRint *msg;
	IGRint bln_index;
	struct DMsenv_param *par_senv;
	IGRdouble *centerpt;
	struct GRid *bln_grid;
	struct GRmd_env *md_env;
	struct DMplan_info *plan_info);

message stack_balloon(
	IGRint *msg;
	struct GRid *dim_grid;
	struct GRmd_env *md_env);

message get_active_balloon(
	IGRint *msg;
	struct GRid *active_grid);

message give_center_offset(
	IGRint *msg;
	IGRshort flag;
	IGRchar *bln_dir;
	IGRdouble *offset;
	IGRdouble *center;
	struct GRmd_env *md_env);

message initialise_text(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct DMdyn_annot *place_attr);

message give_bln_center(
	IGRint *msg;
	IGRdouble *text_offset;
	IGRdouble *center;
	struct GRid *prev;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env);

override ANadd_text_to_buff;
override fill_info;
override dynamics, txdynamics;
override update_leader;
override get_disp_list;

end specification DMtxbln;

