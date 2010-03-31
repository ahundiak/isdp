class specification ECdraw (2:1) of ECelements;

#include "FI.h"
#include "SKdef.h"
#include "SKinc.h"

#define LINEARC         0
#define VARPROFILE      2
#define MODIFYPROFILE   3
#define ONEPROFILE	4

#define FIRSTPT_STATE          100
#define NEXTPT_STATE           101
#define PROCESS_STATE          102
#define DELCONSTR_STATE        103
#define MODIFY_PROFILE_STATE   104
#define END_PROFILE_STATE      105
#define MODIFY_ABORT_STATE     106

#define KILLFORM_STATE	    4
#define DELALLCONSTR_STATE  19
#define REVCONSTR_STATE     18
#define HORCONSTR_STATE     14
#define VERCONSTR_STATE     15
#define HORVERCONSTR_STATE  145
#define COLLCONSTR_STATE    16
#define ORTHOCONSTR_STATE   17
#define COLORTHCONSTR_STATE 167
#define PARCONSTR_STATE     12
#define NORCONSTR_STATE     13
#define BEGINSYMM1_STATE    11
#define BEGINSYMM2_STATE    111
#define INSYMM_STATE        112
#define ENDSYMM_STATE       113
#define LINE_STATE	    20
#define ARC_STATE	    21
#define AUTOCLOSE_STATE	    22
#define ARCBYRADIUS_STATE   23

instance ECdraw
{ 
  IGRboolean 	dyn_on;
  Form 		form_ptr;

  IGRboolean 	line_state;
  IGRshort 	local_state;   /* = 0 ==> we have entered the arc mode if line_state is FALSE.
                                  = 1 or 2 ==> we are defining the sweep i.e.
                                               the end of the arc/circle.  1 or 2 is used 
                                               to switch between CW and CCW directions.
                                  = 3 or 4 ==> defining the end of a tangent arc.  */
  IGRshort 	return_state;
  IGRshort 	symm_state;
  IGRshort 	horver_state;
  IGRboolean 	have_to_decide; /* to know if wake-up needs to decide */
			     /* which command to execute.	   */

  IGRpoint 	firstpt;
  IGRvector 	firsttan;
  struct GRid 	wingrid;
  IGRvector 	zvec, xvec, yvec;
  IGRdouble 	wintol;
  IGRshort 	constr_color;

  IGRpoint 	prevpts[2];
  IGRvector 	tanvec;     /* Current tangent vector */
  IGRdouble 	dist;
  
  struct IGRline symm_line;
  IGRpoint 	symmpt_store[2];
  IGRmatrix 	symm_mat;
  IGRshort 	symm_mattyp;
  GRobjid 	symm_compobj;
  IGRint 	symm_compinx;
  GRobjid 	symm_firstobj;

  GRobjid 	compobj;	/* id of the composite curve */
  GRobjid 	firstobj;       /* first segment of the composite */
  IGRint 	cur_comp_inx;   /* current index of the composite curve elements */

  IGRint 	num_pts;	/* no. of points in the profile */
  variable struct SKcnstr_ptinfo ptinfo[12];   /* info about the events that happened to define
                                                  profile constraints */

  IGRboolean 	active_tol_constr[4];
  struct IGRline tol_constr_lines[4];
  IGRpoint 	tolpt_store[8];

  IGRboolean 	angle_constr;
  IGRdouble 	angle;
  IGRint 	angle_tol_constr_inx;
  struct IGRline angle_constr_line;
  IGRpoint 	anglept_store[2];

  IGRint 	num_inttol_constr;
  variable struct IGRline inttol_constr_lines[12];
  variable IGRpoint inttolpt_store[24];

  IGRboolean 	change_global_assoc_flag;
  IGRint 	prev_ref_lock_state;

  int     	modify_state;   /* 1 ==> modify segment, 2 ==> modify vertex */
  struct GRid 	modseg[2];  /* Profile segments that are getting modified.  modseg[0] is
                               the segment that gets replaced by the new profile. 
                               modseg[1] is used to check if the user snaps to 
                               end the modification. */
  GRobjid       vertex[2];  /* first and last vertex-ids of the segment being modified */
  IGRpoint 	dyn_point;  /* end-point of the modseg[1] which is needed for dynamics */
  IGRushort     modseg_gmtype[2];  /* type of element */
};

override 
  init, wakeup, super_cmd.sleep, delete, execute, status_disp,
  get_locate_criteria;

message do_form (IGRlong *msg; IGRint gadget_label);

message do_form_disp (IGRlong *msg);

message modify_profile (long *msg; int *response; char *response_data);

message do_modification (long *msg; struct GRid new_skmgr; IGRboolean end_merge); 

end specification ECdraw;

