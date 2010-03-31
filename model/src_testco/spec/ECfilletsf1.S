/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This command object serves as interface for the create blend between
    fillet surfaces. It is used when automatic rounding failed.

  HISTORY

    JSY  :  02/12/93
    scw  :  08/14/94  clarified sleep method
*/

class specification ECfilletsf1 (1:2) of ECelements;

#include "FI.h"

instance ECfilletsf1
{
  Form stat_fm, sub_fms[4];
  IGRdouble rho_value, radius, radius1, radius2, maxmin_radius;
  IGRdouble ext_distance, ext_radius_ratio;
  IGRboolean associative, ext_opt, orient[3], fm_disp;
  IGRboolean get_rad, get_rad1, get_rad2, get_maxmin_rad;
  IGRboolean closed, equal_radii, reverse, fillet_constructed, undo_fillet;
  IGRint fill_type, sub_type, vrad_type, int_opt, prof_type;
  IGRint count, which_point, prev_state;
  IGRpoint start_pt, end_pt;
  IGRvector fillet_dir;
  struct GRlc_info lc_elems[4];
  struct GRevent rad_ev, rad1_ev, rad2_ev, endpts[2], maxmin_rad_ev;
  struct GRid fillet_GRid;
  struct IGRbsp_curve *ctrline_cv;
  IGRshort ctrline_type;
};

override init,
         wakeup,
         super_cmd.sleep,
         delete,
         execute,
         status_disp;

message do_form(IGRlong *msg; IGRint form_label, gadget_label; IGRdouble value);

message comp_fillet_direction(IGRlong *msg);
message show_fillet_direction(IGRlong *msg; enum GRdpmode mode);

message comp_fillet_ctrline(IGRlong *msg);
message perform_construction(IGRlong *msg);

end specification ECfilletsf1;
