/* ###################   APOGEE COMPILED   ################## */
class specification ECplasofcv (1:0) of ECelement;
                    

/*
HISTORY

   August 1993 dfl 	created;


*/

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "FI.h"

instance ECplasofcv
   {
   IGRboolean sleep_state;
   IGRboolean is_oriented;
   IGRboolean is_refplane;
   IGRboolean fillet;
   IGRboolean remove_loops;
   IGRboolean right_side;
   IGRboolean is_composite;
   IGRboolean is_uniform;
   IGRboolean is_to_project;
   IGRboolean is_linecase;
   IGRboolean phy_closed;
   IGRboolean is_planar;
   IGRboolean error_flag;
   IGRboolean init_on;
   IGRboolean is_associative; /* associativity flag */
   IGRboolean plane_constructed;
   IGRint multiple_dist_toggle; /* option form distance toggle state */
   IGRint projection_toggle; /* option form project toggle state */
   IGRint  num_comps;
   IGRint  next_comp;
   IGRpoint off_dirpt;  
   IGRpoint pt_on_crv;
   IGRvector  vector;
   IGRvector arrvec; /* arrow vector */
   IGRchar fillet_def[5], code_def[5], uniform_def[5];
   struct GRlc_info curve_info; /* curve */
   struct GRlc_info or_pln_info; /* orientation plane */
   struct GRlc_info pro_pln_info; /* projection plane */
   struct GRid plnobj;
   Form oform; /* option form */
   variable GRobjid     comp_ids[8];
   variable IGRdouble   comp_dis[8];
   variable IGRint      off_code[8];
   };

override init, wakeup, sleep, execute, status_disp;

message do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label; IGRdouble value);

end specification ECplasofcv;
