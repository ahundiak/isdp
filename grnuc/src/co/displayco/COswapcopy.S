class specification COswapcopy (1:0) of CEO_LOCATE;



#include "igrdp.h"
#include "dpstruct.h"
#include "dp.h"


instance COswapcopy
{
	struct GRid        ids[2];
	struct gragad_inst wireframe_inst[2];
	};


message load_window_prompt ( IGRint *sts; IGRint which_one );

message get_selected_window ( IGRint *sts; IGRint which_one );

message get_or_set_instance_data ( IGRint get0_set1; IGRint which_id; IGRint which_instance; );

message process_windows ( long * sts );

end specification COswapcopy;
