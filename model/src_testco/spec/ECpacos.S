/* ###################   APOGEE COMPILED   ################## */
class specification ECpacos (1:0) of ECelement;
                    

/*
HISTORY


*/

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "FI.h"

instance ECpacos
   {
   IGRboolean sleep_state; /* PACOS */
   IGRboolean project_onto_refplane; /* PACOS */
   IGRboolean right_side; /* PACOS */
   IGRboolean phy_closed;
   IGRboolean is_planar;
   IGRboolean error_flag; /* PACOS */
   IGRboolean init_on; /* PACOS */
   IGRboolean is_associative; /* PACOS associativity flag */
   IGRboolean make_permanent; /* PACOS */
   IGRpoint vector_first_point; /* PACOS */ 
   IGRpoint vector_second_point; /* PACOS */ 
   IGRvector  vector; /* PACOS */
   struct GRlc_info curve_info; /* PACOS curve */
   struct GRlc_info surface_info; /* PACOS surface/plane */
   struct GRlc_info vector_info; /* PACOS */
   struct compar_struct {
      IGRint projection_type;
      IGRint offset;
      IGRdouble dist_at_stpt;
      IGRdouble dist_at_ept;
      IGRchar   lawcurve_name[MAX_CHAR + 1];
   } compar_var; /* PACOS */
   GRobjid		mc_objid; /* PACOS */
   GRspacenum		osnum; /* PACOS */
   Form oform; /* PACOS option form */
   };

override init, wakeup, sleep, execute, status_disp;

message do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label; IGRdouble value);

end specification ECpacos;
