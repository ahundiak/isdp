class specification IDinspolcv (1:0) of ECmodify;

/*
Abstract
	This command is similar to command Insert Pole without Changing
	Shape. The difference is that this command has an option to
	change the shape of the curve after a new pole is inserted.

History
	03/12/92	JSY	Design and coding.
*/

#include "dpstruct.h"

/* define a structure used in performing dynamics */
struct DP_inspol
{
  struct DPele_header header[2];
  struct IGRbsp_curve ln, *bspcv;
};

message IDins_pl_chg_shp( struct GRlc_info *lc_info;
			  IGRpoint point;
			  IGRlong *msg );
/*
Abstract

    This method inserts a pole into a free form curve and modify the
    curve shape.

Arguments

    (I) lc_info		the located curve
    (I) point		the pole to be inserted
    (O) msg		return code: MSSUCC: successful; MSFAIL; fail

Return

    OM_S_SUCCESS: successful; OM_E_ABORT: fail
*/

override output_command_string,
	 next_event_processing,
	 verify_event,
         perform_dynamics,
	 perform_modification,
	 perform_duty;

end specification IDinspolcv;

