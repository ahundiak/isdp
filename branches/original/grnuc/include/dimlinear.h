
#ifndef dimlinear_include

#define dimlinear_include

/******************************************************************	
	Index definitions for the graphic components
	of a linear dimension
*******************************************************************/

#define DIM_SGPAR_LINE		3
#define NO_SGPAR_DIM_ROOTS	4

#define DIM_CDIA_CURVE		3
#define NO_CDIA_DIM_ROOTS	4

#define DIM_LDIA_ORIG		3
#define DIM_LDIA_MEAS		4
#define NO_LDIA_DIM_ROOTS	5

#define MAX_LINEAR_ROOTS	5

struct DMdyn_linear
{
	IGRdouble  orig_P[3];
	IGRdouble  meas_P[3];
	IGRdouble  cpx_orig_P[3];

	struct DMplan_info plan_info;
	struct DMenv_param par_env;
	struct DMloc_param par_loc;

	IGRboolean first_in_cpx, aut_cent;
	IGRshort just_pos, just_neg;

	struct GRid text_grid;
	struct GRid ter_grid[2];
	struct GRid proj_grid[2];

	IGRdouble proj_offs, proj_extn;
	IGRdouble dimn_value;
	IGRdouble txt_yoff;
	IGRdouble def_offs[3];
	IGRdouble trak_dist;

	IGRdouble norm_to_plane[3];
	IGRdouble pt_on_plane[3];

	IGRdouble mea_axis[3];
	IGRdouble perp_axis[3];
	IGRdouble text_dir[3];
	IGRdouble offs_dir[3];
	IGRdouble trak_vec[3];

	IGRdouble trak_pt[3];
	IGRdouble break_pt[3];
	IGRdouble dim_line[6];
	IGRdouble lea_line[6];
	IGRdouble term_ori[3];
	IGRdouble term_mea[3];
	IGRdouble proj_vec[3];
	IGRdouble proj_neg[3];
	IGRdouble proj_ori[6];
	IGRdouble proj_mea[6];
	IGRdouble orig_vec[3];
	IGRdouble meas_vec[3];
	IGRdouble trak_dist_prev;
	struct GRid next[2];
};

#endif

