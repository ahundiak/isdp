
#ifndef dimcenline_include

#define dimcenline_include

/******************************************************************	
	Index definitions for the graphic components
	of a center line dimension
*******************************************************************/

#define DIM_CEN_CURVE		2

#define NO_CEN_DIM_ROOTS	3

struct DMdyn_cenlin
{
	IGRint count;

	struct GRid list[NO_CEN_DIM_ROOTS];
	struct DMplan_info plan_info;
	struct DMenv_param par_env;
	struct DMdim_line cenline_info[6];

	IGRdouble center[3];
	IGRdouble pri_radius;
	IGRdouble sec_radius;
};

#endif

