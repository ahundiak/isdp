/**@***********************************************************************

 FILE:
	IDcvbypts.S

 ROUTINES:
	None.

 **************************************************************************/

class specification IDcvbypts (1:0) of ECfit;

/*
Abstract
	This command places a b-spline curve passing through a set of 
        input points. The command is similar to the existing command
        Place Curve by Points. The major difference between the two
        command is that the current command uses Direct Fit to calculate
        the output curve while the previous one used Fitted Curve routine.
        Thus this command is much more efficient than the other one.
        The speed difference can be easily felt when dynamically input
        points while the curve is drawn with the cursor.

History
	02/28/92	JSY	Design and coding.
	04/20/92	JSY	Add code to place uniform B-spline curve.
	06/25/92	JSY	Add code to display curve dynamically
				inside the 3D input generator.
	07/08/92	JSY	Add code to impose tangency constraint
				at the end point of an existing curve.
*/

#include "IDdyn.h"

instance IDcvbypts
{
  struct DPaddnl_info cv_info;
  struct IGRpolyline ctrl_poly, stat_line;
  struct IGResbc attr;
  struct IGRbsp_curve *bspcv;
  IGRboolean snapped;
};

override init,
	 pre_sleep,
	 delete,
         output_command_string,
         next_event_processing,
         verify_event,
	 backup_event,
         perform_dynamics,
         perform_construction;

end specification IDcvbypts;

