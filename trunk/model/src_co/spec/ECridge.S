class specification ECridge (1:0) of COconst;

/*
 Description :
  
  This class has been created serves the purpose of command object interface
  for Place Protrusion / Cutout (Add/Remove Material feature) command. 

 History
  Rustagi  :      ????????  :           Creation
  Sanjay   :      04/xx/94  :           Modification of instance data and
                                        removed unncessery fields of dyn-
                                        func_args structure.
  scw      :      08/14/94  :		Clarified sleep method
*/

#include "ems_m_inc.h"
#include "FI.h"
#include "dpstruct.h"

struct dynfunc_args
{
 IGRdouble               pln_poles[4][3], pln_u_knots[4], pln_v_knots[4];
 IGRdouble               axis_ends[2][3], win_tol;
 IGRpoint                arrow_points[2][3];
 IGRpoint                arrow_vector_pts[2];
 IGRpoint                the_point;
 IGRpoint                center;
 IGRpoint                end_pt; 
 IGRvector               vec_nor_prfpln;
 IGRvector               vec_along_prfpln;
 IGRvector               proj_vec;
 IGRvector               curr_vec;
 IGRvector               tmp_vec;
 IGRboolean              tmp_bool;
 struct GRid             cmd_id;
 struct GRmd_env         modenvcv;
 struct IGRdisplay       *display_stuff;
 struct IGRpolyline      arrow_head[2], arrow_vector;
 struct DPele_header     disbuf[5];
 struct IGRbsp_curve     curvebuff[3];
 struct IGRbsp_surface   plane_surf;
};


instance ECridge
{
IGRint                numobjs;
IGRpoint              pivot_pnt;
IGRvector             matadd_vector;
IGRvector             projection_vec;
IGRvector             vec_nor_prfpln;
IGRvector             vec_along_prfpln;
IGRushort             const_state;  /* for undo, redo state use */
IGRdouble             proj_dist;
IGRdouble             axis_vec[3];
IGRdouble             sweep_angle;
IGRboolean            projected;
IGRboolean            revolved;
IGRboolean            skinned;
IGRboolean            thru_all;
IGRboolean            thru_next;
IGRboolean            to_next;
IGRboolean            from_to;
IGRboolean            finite;
IGRboolean            symmetric;
IGRboolean            normal;
IGRboolean            is_close;
IGRboolean            form_displayed;
IGRboolean            associative;
struct GRid           from_surf_id;
struct GRid           to_surf_id;
struct GRid           window;
struct GRid           construct_id;
struct GRevent        locate_event;
struct GRevent        loc_events[6];
struct GRlc_stack     locate_stack;
Form                  form1;
};

/* Rejects */

/* overrides */

override
 init,
 wakeup,
 super_cmd.sleep,
 execute,
 delete,
 status_disp;

message do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
                IGRdouble value);
message ECridge_perform_dynamics(IGRlong *msg; 
                               struct dynfunc_args *dynargs );

end specification ECridge;
