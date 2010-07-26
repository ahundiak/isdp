
#ifndef dimcoorddyn_include

#define dimcoorddyn_include

struct DMdyn_coord
{
	IGRboolean first_in_cpx;

	struct DMplan_info plan_info;
	struct DMenv_param par_env;
	struct DMloc_param par_loc;
	struct DMmisc_param par_misc;

	IGRdouble orig_P[3];
	IGRdouble meas_P[3];
	IGRdouble cpx_orig_P[3];
	IGRdouble trak_dist;
	IGRdouble trak_dir[3];
	IGRdouble mea_axis[3];
	IGRdouble perp_axis[3];
	IGRdouble trak_pt[3];
	IGRdouble proj_line[6];
	IGRdouble term_ori[3];
	IGRdouble term_mea[3];
	IGRdouble jog_line[12];
	IGRdouble pri_trak_pt[3];
	IGRdouble sec_trak_pt[3];
	IGRdouble proj_offs, proj_extn;
	IGRchar	  pri_trak_zone;
	IGRchar	  sec_trak_zone;
	IGRboolean sec_trak;
	IGRboolean sec_trak_dim;
	IGRint	num_jog_pts;
};

#endif

