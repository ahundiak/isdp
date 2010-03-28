
#ifndef dimangular_include

#define dimangular_include

#define CLOCK_WISE	0x01

#define ORIG_START	0x02
#define MEAS_START  	0x04

#define ANGULAR_TERM_TOLERANCE	5
#define v_projpt(vc,s,vr,V) \
{ \
	V[0] = vc[0] + s*vr[0];\
	V[1] = vc[1] + s*vr[1];\
	V[2] = vc[2] + s*vr[2];\
}
#define v_dist(p1,p2)\
	sqrt((p2[0] - p1[0]) * (p2[0] - p1[0]) + \
	     (p2[1] - p1[1]) * (p2[1] - p1[1]) + \
	     (p2[2] - p1[2]) * (p2[2] - p1[2]));

struct DMangular_attr{
	IGRint type;
	}; 

struct DMdim_root{
	IGRdouble point1[3];
	IGRdouble point2[3];
	};

struct  dm_ang_src_st
{
	IGRdouble arc_radius;
	struct DMdim_root orig_line;
	struct DMdim_root meas_line;
	struct DMdim_root cpx_orig_line;
};

struct angular_data_st{
	double breakpt[3];
	double leaderpt[3];
	double orig_ln_orie[3];
	double meas_ln_orie[3];
	double orig_term_pt[3];
	double meas_term_pt[3];
	double orig_term_orie[3];
	double meas_term_orie[3];
	double text_orie_vec[3];
	double *left_term_pt;
	double *right_term_pt;
	double norm_pl[3];
	double arc_rad;
	double min_length;
	double max_length;
	double centerpt[3];
	double dimn_val;
	double *left_ptr;
	double *right_ptr;
	char left;
	char right;
};	


struct DMdyn_angular {
	struct DMplan_info plan_info;
	struct DMenv_param  p_env;
	struct DMmisc_param  p_misc;
	struct DMloc_param  p_loc;
	struct dm_ang_src_st ang_parent_st;
	struct angular_data_st ang_info;
	double trak_dist;
	double trak_dist_prev;
	IGRvector txt_orie_vec;
	IGRdouble lead_orie[3];
	IGRshort txt_just;
	struct GRid text_grid;
	struct GRid ter_grid[2];
	struct GRid proj_grid[2];
	IGRdouble txt_yoff;
	IGRdouble offs_dir[3];
	IGRdouble def_offs[3];
	IGRdouble pt_on_plane[3];
	IGRboolean first_in_cpx;
	IGRdouble orig_P[3];
	IGRdouble meas_P[3];
	IGRdouble orig_vec[3];
	IGRdouble meas_vec[3];
	IGRdouble proj_offs;
	IGRdouble proj_extn;
	struct GRid next[2];
};

#endif

