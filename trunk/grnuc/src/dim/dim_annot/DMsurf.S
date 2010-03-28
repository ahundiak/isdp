class specification DMsurf(2:0) of DMannot;

#include "dimannot.h"
#include "dimsurf.h"


instance  DMsurf
{
	IGRuchar front_len;
	IGRuchar rear_len;
	IGRuchar dir_sym;
	IGRuchar sym_posn;
};

/*
	Instances used from DMannot Classs

	IGRchar leader;		-> leader ;
	IGRchar bln_dir;	-> symbol direction
	IGRchar dual_mode;	-> line on  
	IGRchar tol_symbol;	-> basic sym
	
	variable IGRdouble break_pt[]; -> leader line
	
*/

message compute_symbol_positions(
	IGRint *msg;
	IGRpoint point;
	IGRdouble *xaxis;
	struct DMsenv_param *par_senv;
	struct DMplan_info *plan_info;
	IGRdouble *sym_posn);

message position_surf_text(
	IGRint *msg;
	struct GRid text_grid[];
	IGRdouble *txt_orie;
        struct DMsenv_param *par_senv;
        struct DMplan_info *plan_info;
        IGRdouble *sym_posn;
        struct GRmd_env *md_env);

message position_surf_symbol(
        IGRint *msg;
        IGRdouble *points;
        IGRdouble *txt_dir;
        struct GRid *go_grid;
        struct DMsenv_param *par_senv;
	struct DMplan_info *plan_info;
        struct GRmd_env *md_env);

message get_components(
        IGRboolean create;
        struct GRid go_grid[];
        struct GRmd_env *md_env);

message make_surf_text(
        IGRint *msg;
        struct DMplan_info *plan_info;
        struct DMsenv_param *par_senv;
        struct GRid go_grid[];
        struct GRmd_env *md_env);

message set_surf_text_attr(
        IGRint *msg;
        struct GRid *text_grid;
        struct GRmd_env *md_env);

message get_surf_text(
	IGRint *msg;
	struct DMsurf_param *par_surf;
	struct GRmd_env *md_env);

override dynamics;
override GRvg;
override fill_leader_info;
override chg_an_dp;
override make_lead_line;
override DMplace;
override DMcompute_node;
override fill_info;
override modify_geom;
override get_dim_attr;

end specification DMsurf;


