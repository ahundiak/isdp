
#ifndef dimradial_include

#define dimradial_include

/******************************************************************	
	Index definitions for the graphic components
	of a radial dimension
*******************************************************************/

#define DIM_RAD_CURVE		3

#define NO_RAD_DIM_ROOTS	4

struct DMdyn_radial
{
	IGRshort   txt_just;
	IGRboolean const_radius;
	IGRint	   num_jog_pts;
	IGRdouble  center[3];
	IGRdouble  term_pt[3];
	IGRdouble  break_pt[3];
	IGRdouble  leader_pt[3];
	IGRdouble  text_dir[3];
	IGRdouble  offs_dir[3];
	IGRdouble  def_offs[3];
	IGRdouble  lea_line[6];
	IGRdouble  dimn_value;
	IGRdouble  proj_offs;
	IGRdouble  proj_extn;
	IGRdouble  jog_line[9];
	struct DMplan_info plan_info;
	struct DMenv_param par_env;
	struct DMloc_param par_loc;
	struct DMmisc_param misc_param;
	struct IGRbsp_curve *bsp_curve;

	IGRdouble norm_to_plane[3];
	IGRdouble pt_on_plane[3];

	IGRdouble mea_axis[3];
	IGRdouble perp_axis[3];
	IGRdouble pt_buffer[12];
	IGRint count;
	struct GRid list[NO_RAD_DIM_ROOTS];
	struct GRid text_grid;
	struct GRid win_grid;
	IGRboolean projection_required;
	struct DPele_header buffer[2];
	struct IGRpolyline linex, liney;
	struct IGRdisplay display;
};

#endif

