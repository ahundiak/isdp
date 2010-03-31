/*
ABSTRACT:
  This is the command object class for the 'Place Offset Surface'
  command.

NOTES:

HISTORY:

  sam      :  20thMar'93  : Creation
  Sudhakar :  30thApr'93  : Added additional instance data for 
                            autodimensioning.
  Sudhakar :  27thJul'93  : Added override of 'do_locate' method.
  scw      :  14  Aug 94  : clarified sleep method

*/
class specification ECcsoffset (1:3) of ECelements;

#include "FI.h"
#include "dp.h"
#include "dpstruct.h"
#include "lcdef.h"
#include "lc.h"
#include "EMSfeadef.h"  /* for struct hole_data */

instance ECcsoffset
{
	IGRboolean 		associative;
	IGRboolean 		onesided_flag;
	IGRboolean 		symmetric_flag;
	IGRboolean 		common_tk_flag;
	IGRboolean 		multiple_tk_flag;
        IGRshort                last_state;   /* stores the previous state */
	struct GRid	        input_obj,	
                                const_obj;    /* constructed object */
	IGRushort 		form_displayed;
	IGRboolean 		inward;
	IGRboolean 		multi_tk;
	IGRdouble 		common_thickness;
	IGRint 			num_spec_tks;
	variable struct  GRevent spec_tk[];
	IGRint 			spec_surf_id_count;
	variable GRobjid 	spec_surf_ids[];
	variable IGRint 	num_sfs_per_tk[];

        GRobjid                 common_surf;
        IGRpoint                common_surf_pt;
        variable IGRpoint       locpts[];

	struct GRid         	win_id;         /* window id */
	Form   			form1;
	IGRdouble   		axis_dir[3];    /* the axis unit vector */
	struct GRevent 		in_thick, out_thick;
};

override
status_disp, init, wakeup, super_cmd.sleep, execute, get_locate_criteria,
  do_locate;     /* Motivation: To get appropriate prompts
                    File :      EMcsofdoloc.I  */

/*
Abstract:
        This method sets up the instance data needed by the form_input method
File:
        EMshslform.I
*/

message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
IGRdouble value);

/* Shell action handler */
message shell_action_handler(struct shell_loc_acthndlr_args *offsurf_locate;
struct GRlc_info *new_entry; struct LC_action_args *loc_args;
enum GRlocate_action *action);

/* perform dynamics for displaying the offset direction arrow */
message dir_dynamics(struct GRid *grid; struct GRevent *event;
struct GRid *cmd);

message element_located(GRobjid id; IGRboolean *located);


end specification ECcsoffset;
