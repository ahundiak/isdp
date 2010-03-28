/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: COweld.S,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:07:43  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:21:41  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:51:12  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1994/08/09  21:38:24  grnuc40
# COMMENT : upgraded for v3.1
#
# Revision 240.0  1992/12/06  23:43:50  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.0  1992/08/29  06:23:12  root
# COMMENT : Corresponds to Rel201.1 in 2.0.1 RCS
#
Revision 201.1  1992/01/13  05:59:24  dimdp20
COMMENT : Dimensioning fixes release  - 13th Jan 92

*/

class specification COweld(2:0) of COdim;

instance COweld
{
	struct GRid weld_grid;			/* Dimension in Placement */
	struct GRid prev_weld;			/* Previous annotation in cpx;*/
	struct GRevent loc_event;		/* Event for origin */
	struct DMtxdynamics_info dyn_info;	/* info for dynamics */

	struct  GRid list[MAX_DIM_ROOTS];
	struct  GRid context[MAX_DIM_ROOTS];
	struct  DMobj_info arrow;
	IGRshort create_flag;
	struct DMplan_info plan_info;
	struct annot_attr an_attr;
	IGRdouble vector[6];

	IGRint form_display;
	IGRboolean dynamics_on;
	Form form, subform1, subform2, subform3, subform4;

	/* Instances for form */

	IGRshort above_input;
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

override init, wakeup, super_cmd.sleep, execute, delete, notify_form;
override LC_selection, LC_preproc, LC_postproc, LC_dynamics;

end specification COweld;
