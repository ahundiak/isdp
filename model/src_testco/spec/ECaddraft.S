/* ###################   APOGEE COMPILED   ################## */
class specification ECaddraft (1:0) of ECelements;

/*
HISTORY
  scw  08/14/94  clarified sleep method
*/


# include "EMS.h"
# include <stdio.h>
# include "EMSbnddef.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "EMSbnd.h"
#include "EMSdpb.h"
#include "FI.h"

instance ECaddraft
   {
   struct EMdpbinfo  dpb_info;
   IGRboolean  associative_flag;
   struct GRid surf[2];
   variable struct GRid the_loop[];
   IGRboolean uniform_draft;
   IGRboolean  is_associative;
   IGRdouble draft_angle;
   IGRint num_drafts;
   IGRint num_surfs;
   IGRint num_loops;
   IGRint num_drafts_inc;
   struct GRevent accev, event[2];
   struct EX_button button;
   variable struct GRlc_info loc_info[];
   variable GRobjid loc_loops[];
   struct GRid active_grid;
   IGRint action;
   GRobjid ext_surf_id;
   struct GRid cons_id, int_grid;
   IGRint add_draft_type;
   IGRint cmd_typ;
   Form form1;
   IGRboolean form_displayed;
   IGRchar accept_prompt[54];
   };

message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
IGRdouble value);

override init, wakeup, execute, super_cmd.sleep, status_disp;

end specification ECaddraft;
