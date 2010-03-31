# ifndef emsmass_include
# define emsmass_include

/*
 emsmass.h:	include file needed for most of the mass prop/surface
   		properties methods/functions
*/

/* these defines are being used for editind area/mass properties thru
   forms
*/

#define LEN_UNITS             32
#define DENSITY               35
#define AXES_ORIENT           36
#define REF_POINT0            37
#define REF_POINT1            38
#define REF_POINT2            39
#define AXIS0                 18
#define AXIS1                 31
#define AXIS2                 30
#define AXIS3                 26
#define AXIS4                 27
#define AXIS5                 28
#define AXIS6                 29
#define AXIS7                 20
#define AXIS8                 23
#define CENTROIDX             43
#define CENTROIDY             44
#define CENTROIDZ             45
#define VOLUME                46
#define VOLUME_UNIT           58
#define MASS                  47
#define MOMENTX               50
#define MOMENTX_UNIT          54
#define MOMENTY               52
#define MOMENTY_UNIT          55
#define MOMENTZ               53
#define MOMENTZ_UNIT          57
#define MOMENTXY              61
#define MOMENTXY_UNIT         60
#define MOMENTYZ              64
#define MOMENTYZ_UNIT         66
#define MOMENTZX              65
#define MOMENTZX_UNIT         67
#define SURF_AREA             69
#define SURF_AREA_UNIT        71
#define RAD_GYR_X             74
#define RGX_UNIT              77
#define RAD_GYR_Y             75
#define RGY_UNIT              78
#define RAD_GYR_Z             76
#define RGZ_UNIT              79
#define STATUS_FIELD          22
#define PRIN_MOMX             50
#define PRINMOMX_UNIT         54
#define PRIN_MOMY             52
#define PRINMOMY_UNIT         55
#define POLAR_MOM             53
#define POLARMOM_UNIT         57
#define RADGY_POLAR           74
#define RADGYPOLAR_UNIT       79
#define RADGY_X               75
#define RADGYX_UNIT           78
#define RADGY_Y               76
#define RADGYY_UNIT           77
#define OBJECT_NAME           33
#define COOD_SYSTEM           34

/* Depending on integration scheme used, an integration factor
   is to be defined

   2-d Simpson  9.0
   2-d Gaussian 4.0
*/

#define     AREA_PROPERTIES 1
#define     MASS_PROPERTIES 0

#define 	INTEGRATION_FACTOR 4.0
#define 	NUMB_PROPS	20

#define ACTIVE_AT_CENTROID 1
#define PRINCIPAL          2
#define GENERAL            3

/* What follow are outdated, but are retained for historical reasons
   1/12/87
*/

#define		DIJ_PLANE	25

#define		NO_BND_SURF	0
#define		ONE_SEG_BND	1
#define		BSPLN_BND	2
#define		N_SEG_BND	3

/* following defs are used to determine the boundary conditions for
   a patch and facet */

#define BND_ZERO_ZERO       0
#define BND_ZERO_ONE        1
#define BND_ONE_ONE         2
#define BND_ONE_ZERO        3
#define BND_U_ZERO          4
#define BND_U_ONE           5
#define BND_V_ZERO          6
#define BND_V_ONE           7
#define BND_U_ZERO_ONLY     8
#define BND_V_ZERO_ONLY     9
#define BND_U_ONE_ONLY      10
#define BND_V_ONE_ONLY      11
#define BND_U_ZERO_U_ONE    12
#define BND_V_ZERO_V_ONE    13

#define NOT_ON_PATCH_BND    14
#define NOT_ON_FACET_BND    15
#define ON_FACET_BND        16

#define BOUNDARY_POINT 0

/* 11/23/87 struct mass_surf_info contains required surf info */

struct mass_surf_info
{
  IGRlong	numb_along_u;
  IGRlong	numb_along_v;
  IGRlong	mult_u;
  IGRlong	mult_v;
  IGRdouble	*u_vals;
  IGRdouble	*v_vals;
};

/* structure needed for evaluating double integrals */

/* 8/21/87: added extra_pointer in struct mass_prop_struct */

struct mass_prop_struct
{
	IGRdouble	aerr;		/* absolute error */
	IGRdouble	rerr;		/* relative error */

/* This is the function to be integrated by the inside function */

	IGRdouble	(*fun_xy)();	/* the core function */
	
/* The following provide geometric specification */

	IGRdouble	bnd_pts[4];	/* boundary points for bnd case */
	struct IGRbsp_surface	*surf;	/* pointer to be passed to fun_xy */
	IGRchar		*extra_ptr;	/* to send another pointer */

/* The following are needed for BSadsimp */

	IGRlong		numb_div;	/* number of sub-divisions allowed */
	IGRdouble	*work_space;	/* points to memory for BSadsimp */

/* The following are for statistics */

	IGRlong		evals;		/* number of core func evaluations */
	IGRlong		out_calls;	/* number of inside func calls */
};

/*
	We may need to declare fun_c and fun_d. They have been deleted
	from the structure for the time being
	IGRdouble	(*fun_c)();
	IGRdouble	(*fun_d)();
*/

/*
   The following structure stores all the required coefficients
   for exact integration for planar surface with 2x2 poles
*/

struct mass_dij_plane
{
	IGRlong		result_u;	/* number of rows - 1 */
	IGRlong		result_v;	/* number of cols - 1 */
	IGRdouble	result_coi[DIJ_PLANE]; /* plane has <= 5x5 coeffs */
};

struct EMfacet_data
{
 IGRint         num_bdrys;
 IGRint         bdry_inx[6];
 IGRint         num_in_points;
 IGRint         points_inx;
 IGRint         num_int_bdry;
 IGRint         int_bdry_inx[6];
 IGRboolean     u_dir[3];
 IGRdouble      param[3];
};

struct EMpatch_bounds
{
 IGRint     numu;
 IGRdouble  *u_pars;
 IGRint     numv;
 IGRdouble  *v_pars;
};

struct EMpatch_list {
	struct IGRbsp_surface **geometries;
	struct EMpatch_bounds params;
	};

# endif /* emsmass_include */
