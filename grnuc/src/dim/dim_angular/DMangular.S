/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:29 $
$Locker:  $
$Log: DMangular.S,v $
Revision 1.1.1.1  2001/12/17 22:39:29  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:06:48  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:20:44  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:50:17  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.0  1992/12/06  23:40:38  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.0  1992/08/29  06:20:34  root
# COMMENT : Corresponds to Rel201.4 in 2.0.1 RCS
#
Revision 201.4  1992/07/20  07:44:10  poo
COMMENT : ANSI compilance, TR 92N1519, TR92N1741, and updating modified fucnction calls.

*/

class specification DMangular(2:0) of DMdim;

#include "dimangular.h"

override GRvg;

override NDplace ,DMplace;
override DMcompute_node;

/* compute messages */

message get_dim_info(
	IGRlong *msg;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env;
	struct dm_ang_src_st  *angle_st;
	double *trak_dist_prev; 
	struct DMplan_info *plan_info;
	struct DMenv_param *p_env;
	struct DMloc_param *p_loc);

message give_orig_meas(
	IGRlong *rc;
        IGRint  count;
        struct GRid *list;
        struct dm_ang_src_st *angle_st;
        struct DMplan_info *plan_info;
	IGRchar *mea_trak;
	IGRdouble *trak_dist;
	struct GRmd_env *md_env);

message get_dim_sect(
	IGRlong *msg;
	struct dm_ang_src_st *angle_st;
	struct angular_data_st *a_info;
	struct DMplan_info *plan_info;
	struct DMenv_param *p_env);

message compute_breakpt(
	IGRlong *rc;
	struct angular_data_st *a_info;
	struct dm_ang_src_st *angle_st;
	struct DMplan_info *plan_info);

message compute_leader_pt(
	IGRlong *rc;
	struct angular_data_st *a_info;
	struct DMloc_param *p_loc;
	struct DMenv_param *p_env;
	struct DMplan_info *plan_info);

message make_proj_lines(
	IGRlong *msg;
	struct DMenv_param *p_env;
	struct DMloc_param *p_loc;
	struct DMplan_info *plan_info;
	struct dm_ang_src_st *angle_st;
	struct angular_data_st *ang_info;
	struct GRmd_env *md_env);

message make_dim_line(
	IGRlong *msg;
        struct DMenv_param *p_env;
        struct DMloc_param *p_loc;
	struct angular_data_st *ang_info;
       	struct DMplan_info *plan_info;
        struct GRmd_env *md_env);

message make_dim_text(
	IGRlong *msg;
	struct angular_data_st *ang_info;
	struct DMenv_param *p_env;
	struct DMloc_param *p_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env);

message make_dim_term(
	IGRlong *msg;
	struct angular_data_st *ang_info;
	struct DMenv_param *p_env;
	struct DMloc_param *p_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env);
 
message get_mea_trak_info(
	struct DMdim_root *cpx_orig_line;
	IGRchar *mea_trak;
	IGRdouble *trak_dist;
	struct GRmd_env *md_env);

message fill_buff(
	IGRint  *msg;
	IGRint  control;
	IGRint  *level;
	IGRchar info[];
	struct GRmd_env *md_env);

message get_cpx_origin(
	IGRint *msg;
	IGRdouble *origin;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env);

message give_trak_dist(IGRdouble *trak_dist);

message update_src(
	IGRint *msg;
	struct GRid *meas, first;
	struct GRmd_env *md_env);

message give_angle_center(
	IGRint *msg;
	IGRpoint center;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env);

override fill_info;
override give_rel_pos;
override dynamics;
override leader_needed;
override get_dimension_plane;
override change_dimension_measurement;
override change_dimension_origin;
override init_ter_loca;

end specification DMangular;
