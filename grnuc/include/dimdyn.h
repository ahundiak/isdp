#ifndef dimdyn_include

#define dimdyn_include

#include "dim.h"
#include "dimlinear.h"
#include "dimradial.h"
#include "dimangular.h"
#include "dimcoord.h"
#include "dimcenline.h"
#include "dimannot.h"
#include "dimweld.h"
#include "dimsurf.h"
#include "dimplan.h"

#define IN_RTREE	0
#define OUT_RTREE	1

/* - Preprocessing Command Flags - */

#define LEADER_OFF	0x0001
#define SET_STATE	0x0002
#define ERASE_DIM	0x0004
#define TAKE_OFF_RTREE	0x0008
#define CLEAR_OFFSET	0x0010
#define MASK_STATE	0x0020
#define CLEAR_STATE	0x0040
#define JOGGED_OFF	0x0080
#define CLEAR_JOG_PT1	0x0100
#define CLEAR_JOG_PT2	0x0200
#define CLEAR_JOG_PTS	0x0300
#define RETURN_VERTEX	0x0400

/* - Postprocessing Command Flags - */

#define DISP_DIM	0x0100
#define PUT_IN_RTREE	0x0200
#define CHGDP		0x0400

struct DMdim_info
{
	union
	{
		struct DMdyn_linear	linear;
		struct DMdyn_radial	radial;
		struct DMdyn_angular	angular;
		struct DMdyn_coord	coord;
		struct DMdyn_cenlin	cenlin;
		struct DMdyn_weld	weld;
		struct DMdyn_surf	surf;
	} info;
};

#define MAX_GRAPH_SIZE	32
#define MAX_CPX_SIZE	10

struct DMdynamics_info
{
	IGRint msgkey;
	IGRint control;
	struct GRid dim_grid;
	struct GRmd_env *md_env;
	struct DMplan_info plan_info;
	struct DMdim_info *info;
	struct GRid display_list[MAX_GRAPH_SIZE];
	struct GRid compute_list[MAX_GRAPH_SIZE];
	IGRint display_count, compute_count;
};

struct DMtxdynamics_info
{
	IGRint msgkey;
	IGRint control;
	struct GRid dim_grid;
	struct GRmd_env *md_env;
	struct DMplan_info plan_info;
	struct DMdyn_annot info;
	struct DMdyn_weld info1;
	struct GRid display_list[MAX_GRAPH_SIZE];
	struct GRid compute_list[MAX_GRAPH_SIZE];
	IGRint display_count, compute_count;
};


#omdef dm$invoke_dynamics(
		msg,
		dynamics = TRUE,
		msgkey = NULL,
		preproc = 0,
		postproc = 0,
		prestate = 0,
		poststate = 0,
		copy = FALSE,
		cp_grid = NULL,
		control,
		md_env,
		event = NULL,
		dim_grid)

	DMinvoke_dynamics(
		msg,
		dynamics,
		msgkey,
		preproc,
		postproc,
		prestate,
		poststate,
		copy,
		cp_grid,
		control,
		md_env,
		event,
		dim_grid)

#endomdef

#omdef dm$modify_annot(
		msg,
		dynamics = TRUE,
		msgkey = NULL,
		copy,
		cp_grid = NULL,
		control,
		data_point = NULL,
		md_env,
		event = NULL,
		dim_grid)

	DMmodify_annot(
		msg,
		dynamics,
		msgkey,
		copy,
		cp_grid,
		control,
		data_point,
		md_env,
		event,
		dim_grid)
#endomdef

#endif
