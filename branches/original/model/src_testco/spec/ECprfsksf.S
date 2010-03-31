class specification ECprfsksf (1:0) of ECconstruct;

#include "CSsfdef.h"

instance ECprfsksf
 {
  IGRlong	substate;
  IGRlong       coordsys_case;
  IGRlong       num_trace;
  IGRlong	previous_trace_count;
  variable	struct GRlc_info trcobj[2];
  IGRboolean	traces_are_closed;
  IGRlong       num_cross;
  IGRlong	previous_cross_count;
  variable	struct GRid crspic[20];
  variable      IGRint ascend_pos[20];
  variable	struct GRlc_info crsobj[20];
  variable	struct GRlc_info trcloc[20];
  variable	IGRpoint crsopt[20];
  variable	IGRdouble crsloc[20];
  variable	IGRdouble crsang[20];
  IGRboolean	edges_locatable;
  IGRboolean	crosses_are_closed;
  IGRboolean    smooth;
  IGRboolean    tan_constrnt;

  IGRlong	num_tansf;
  struct	GRlc_info orient_surface;
  struct	CSsf_wrk_t wrk;

  IGRboolean	absolute_orientation;
  IGRboolean	surface_is_open;
  IGRboolean	select_screen_pos;
  IGRboolean	angle_constant;
  IGRboolean	sleep_in_hangup;
 };
 
message display_on_site();

message perform_dyn(struct GRevent dyn_event);

message hang_up_section (IGRboolean *backup; int *myevent_resp; int *response; char *response_data);

message check_ref_plane (IGRboolean testcase; struct GRlc_info *check_info; IGRboolean *on_plane);

message create_form (int form_label;
                     char *form_name; Form *form);

message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
                 IGRdouble value; Form fp);

override execute, display_constructions, update_status_form, status_disp,
         is_associative, init, wakeup, sleep, delete;

end specification ECprfsksf;

