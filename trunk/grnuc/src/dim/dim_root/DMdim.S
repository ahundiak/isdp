/*
_Author: dimdp20 _
_Revision: 201.6 _
_Date: 1992/02/12 07:19:30 _
_Locker: scott _
_Log: DMdim.S,v _
Revision 201.6  1992/02/12  07:19:30  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - 12 Feb. 1992

*/

/*
	Abstract Class. All dimensioning classes subclass from
	this class. Supports the basic messages used by all.
*/

class specification DMdim(2:0) of DMroot;

override GRvg;

instance DMdim
{
	IGRdouble dim_value;
	IGRdouble brk_dist;
	IGRdouble lead_dist;
	IGRdouble trak_dist;
	float  offs_pt[2];
	float  prj_offs[2];

	IGRuchar mea_trak;
	IGRuchar brk_pos;
	IGRuchar leader;
	IGRuchar ter_loca;
	variable IGRuchar dim_override[];
};

override DMplace;
override position_text;

override get_dim_params;
override set_dim_params;

override get_dim_attr;
override copy_dim_attr;

override get_trak_info;
override set_trak_info;

override get_info;
override leader_off;
override clear_offset;
override toggle_ter_loca;
override update_parents;

override GRchgname;

message get_real_parents(
	IGRint count;
	struct GRid list[]);

message make_text_string(
	IGRint *msg;
	IGRdouble dimn_value;
	struct GRmd_env *md_env;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMmisc_param *par_misc);

message compute_offset(
	IGRint *msg;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	IGRdouble off_dir[3];
	IGRdouble app_pos[3];
	IGRdouble act_pos[3]);

message get_active_params(
	IGRint *msg;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc);

message get_text_extents(
	IGRint *msg;
	IGRdouble box[12];
	struct GRmd_env *md_env);

message adjust_trak_dist(
	IGRchar mask;
	IGRdouble *trak_dist);

message get_orig_trak_pt(
	IGRdouble trak_pt[3];
	struct GRmd_env *md_env);

message get_orig_trak_info(
	IGRdouble trak_pt[3];
	struct DMtrak_info *trak_info;
	struct GRmd_env *md_env);

message get_dim_value(IGRdouble *dim_value);

end specification DMdim;


