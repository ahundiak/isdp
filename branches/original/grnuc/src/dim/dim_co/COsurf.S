class specification COsurf(2:0) of COdim;

#include "dimsurf.h"

instance COsurf
{
	struct GRid surf_grid;			/* Dimension in Placement */
	struct GRid prev_surf;			/* Previous annotation in cpx;*/
	struct GRevent loc_event;		/* Event for origin */

	struct  GRid list[MAX_DIM_ROOTS];
	struct  GRid context[MAX_DIM_ROOTS];
	struct  DMobj_info arrow;
	IGRshort create_flag;
	struct DMplan_info plan_info;
	struct annot_attr an_attr;

	IGRint form_display;
	IGRboolean dynamics_on;
	IGRboolean leader;
	Form form, subform;
};

message get_dim_param();

message get_dim_plane();

message place_dimension();

message create_arrow();

message display_dimension(IGRint level; IGRint control);

message delete_dimension();

message set_dim_attr();

message set_dim_state(IGRshort dim_state);

message position_dim(
	IGRint msgkey;
	IGRint dynamics;
	IGRint preproc;
	IGRint prestate;
	IGRint control;
	IGRint postproc;
	IGRint poststate);

message init_type();

message display_form();

message update_src(struct GRevent *event);

override init, wakeup, super_cmd.sleep, execute, delete, notify_form;
override LC_selection, LC_preproc, LC_postproc, LC_dynamics;

end specification COsurf;
