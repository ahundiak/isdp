class specification DMweld(2:0) of DMannot;

#include "dimannot.h"
#include "dimweld.h"

override GRvg;

instance DMweld
{
	IGRchar tail;
	IGRchar circle;
	IGRchar flag;
	IGRchar above;
	IGRchar center;
	IGRchar below;
	IGRchar cross_section;
	IGRchar weld_type1;
 	IGRchar weld_type2;
	IGRchar front_len;
	IGRchar rear_len;
	IGRchar inter_len;
	IGRchar ansi_weld;
	IGRchar weld_symb1;
	IGRchar weld_symb2;
	float slant;
	float angle;
	float relief;
	variable IGRdouble vector[];
};

/*
	Instances used from DMannot Classs

	IGRchar leader;		-> dash_line flag
	IGRchar bln_dir;	-> weld symbol direction
	IGRchar dual_mode;	-> dual weld symbol
	IGRchar tol_symbol;	-> Z symbol flag
	
	variable IGRdouble break_pt[]; -> leader line
	
*/

override fill_info;
override txdynamics;
override DMplace, DMcompute_node;
override chg_an_dp;
override make_an_term;
override modify_geom;
override get_dim_attr;

message get_components(
	IGRboolean create;
	struct GRid go_grid[];
	struct GRmd_env *md_env);

message make_weld_line(
	IGRint *msg;
	IGRdouble tail_pt[3];
	IGRdouble flag_pt[3];
	struct DMsenv_param *par_senv;
	struct DMplan_info *plan_info;
	struct GRid go_grid[];
	struct GRmd_env *md_env);

message update_weld_line(
	IGRint *msg;
	IGRdouble start_pt[3];
	IGRdouble end_pt[3];
	struct GRid go_grid[];
	struct GRmd_env *md_env);

message set_weld_text_attr(
	IGRint *msg;
	struct GRid go_grid[];
	struct GRmd_env *md_env);

message make_weld_text(
	IGRint *msg;
	struct DMplan_info *plan_info;
	struct DMsenv_param *par_senv;
	struct GRid comp_grid[];
	struct GRmd_env *md_env);

message position_weld_text(
	IGRint *msg;
	IGRdouble break_pt[3];
	IGRdouble tail_pt[3];
	IGRdouble flag_pt[3];
	struct GRid text_grid[];
	struct DMplan_info *plan_info;
	struct DMsenv_param *par_senv;
	struct GRmd_env *md_env);

message place_weld_cs(
	IGRint *msg;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env);

message set_cross_section(
	IGRint cross_section;
	IGRdouble weld_size;
	IGRdouble *vector);

message get_weld_text(
	IGRint *msg;
	struct DMweld_param *weld_param;
	struct GRmd_env *md_env);

end specification DMweld;

