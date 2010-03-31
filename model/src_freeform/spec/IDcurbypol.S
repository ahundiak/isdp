class specification IDcurbypol (1:0) of ECcurbypol;

/*
Abstract
	This command is the same as ECcurbypol except adding dynamics
	function. The curve gets displayed while creating.

History
	02/24/92	JSY	Design and coding.
	04/12/92	JSY	Add code to place uniform B-spline curve.
*/

#include "IDdyn.h"

instance IDcurbypol
{
  struct DPaddnl_info cv_info;
  struct IGRpolyline ctrl_poly, stat_line;
  struct IGResbc attr;
  struct IGRbsp_curve *bspcv, stat_cv;
};

override init,
         pre_sleep,
         delete,
         output_command_string,
	 next_event_processing,
	 perform_dynamics,
	 perform_construction;

end specification IDcurbypol;

