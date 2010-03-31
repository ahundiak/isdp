class specification ECrib (1:0) of COconst;

/*
 Description
  
  This class has been created so as to have concise code for
  all types of features.

 History
  Rustagi ???????? Creation
  Rustagi 1/19/94  Increased "disbuf" size in dynfunc_args to '6'. Earlier
                   it was '5'.
  scw     08/14/94 Clarified sleep method

*/

#include "ems_m_inc.h"
#include "FI.h"
#include "dpstruct.h"

struct dynfunc_args
{
 struct IGRbsp_curve curvebuff[2];
 struct IGRbsp_curve *prof_geom;
 struct IGRpolyline arrow_head[2], arrow_vector;
 IGRpoint arrow_points[2][3];
 IGRpoint arrow_vector_pts[2];
 IGRpoint the_point;
 struct GRmd_env modenvcv;
 struct DPele_header disbuf[6];
 IGRdouble length_fraction;
 GRrange range;
 IGRboolean vector_initialised;
 IGRvector curr_vec;
 IGRvector proj_vec;
 struct IGRdisplay *display_stuff;
 struct GRid cmd_id;
};


instance ECrib
{
IGRboolean projection_dist_stored_as_event;
IGRboolean thickness_stored_as_event;
IGRboolean thickness_in_profile_plane;
IGRboolean symmetric;
IGRboolean extend_curve;
IGRboolean is_finite;
IGRdouble thickness;
IGRboolean form_displayed;
IGRvector thick_vector;
IGRvector matadd_vector;
IGRdouble matdepth;
IGRushort const_state;  /* for undo, redo state use */
struct GRlc_stack  locate_stack;
struct GRevent locate_event;
IGRint numobjs;
struct GRevent loc_events[10];
Form form1;
struct GRid window;
IGRpoint pivot_pnt;
IGRboolean associative;
struct GRid construct_id;
IGRvector vec_nor_prfpln;
IGRvector vec_along_prfpln;
IGRboolean flip_thick_side;
IGRboolean flip_prj_side;
};

/* Rejects */

/* overrides */

override
 init,
 wakeup,
 super_cmd.sleep,
 delete,
 execute,
 status_disp;

message do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
                IGRdouble value);
message ECrib_perform_dynamics(IGRlong *msg; 
                               struct dynfunc_args *dynargs;
                               struct GRevent *loc_event);

end specification ECrib;
