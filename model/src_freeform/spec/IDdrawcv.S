/**@***********************************************************************

 FILE:
	IDdrawcv.S

 ROUTINES:
	None.

 **************************************************************************/

class specification IDdrawcv (1:0) of ECfit;

/*
Abstract
	This command consolidates the existing curve creation commands.
	It has a status form to choose either one of the following ways
	to create a curve:
	points or poles;
	uniform or nonuniform;
	tangent constraint or not.
	
History
	08/18/92	JSY	Creation.
        08/13/94        scw     clarified override of sleep method
*/

#include "IDdyn.h"
#include "FI.h"

instance IDdrawcv
{
  Form stat_form;
  IGRboolean form_displayed;
  IGRshort pts_or_pol, cv_type, tan_cnstr;
  struct DPaddnl_info cv_info;
  struct IGRpolyline ctrl_poly, stat_line;
  struct IGResbc attr;
  struct IGRbsp_curve *bspcv, stat_cv;
  IGRboolean valid_snap;
};

override init,
	 wakeup,
	 delete,
	 pre_sleep,
	 super_cmd.sleep,
	 status_disp,
         output_command_string,
         next_event_processing,
         verify_event,
         perform_dynamics,
         perform_construction;

/**@*********** do_form() *************************************************

 ABSTRACT:
	Process form input data

 SYNOPSIS:
	IGRlong do_form( IGRlong *msg;
	                 IGRint form_label;
			 IGRint gadget_label;
			 IGRdouble value )

	(O)	IGRlong *msg
			Status of the method execution
	(I)	IGRint form_label
			Form label of the status form
	(I)	IGRint gadget_label
			Gadget label
	(I)	IGRdouble value
			Gadget input value

 RETURN:
	OM_S_SUCCESS

 NOTES:
	This is a method

 **************************************************************************/

message do_form( IGRlong *msg; IGRint form_label;
		 IGRint gadget_label; IGRdouble value );

end specification IDdrawcv;

