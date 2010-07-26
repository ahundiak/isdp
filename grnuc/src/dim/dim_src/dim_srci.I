class implementation dim_src;

#define AS_DEBUG 1

#include "madef.h"
#include "dimdef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

%safe
#include "math.h"
%endsafe

#include "dimco.h"

method DMgive_tangent(
	IGRint *msg;
	IGRboolean *src_type;
	IGRdouble tangent[3];
	IGRdouble box[4][3];
	struct GRmd_env *md_env)
{
	if(src_type) *src_type = POINT_TYPE;

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

end implementation dim_src;
