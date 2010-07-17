// -----------------------------------------------------------------------------
//      Class    :      VLbutLine.S
//
//      Abstract :      Store Data corresponding to butt line;
//			Curve intersection between hull and plane parallel
//			of plane YZ.
//
//      History  :      Created 01-OCT-1992     Ludovic Le CORVEC
//                      Updated 11-APR-1994     Marc FOURNIER
// -----------------------------------------------------------------------------

class specification VLbutLine(0:0) of VLgenLine;

#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

override NDcheck_cmpt_level;

/* -------- compute next butt with respect of max plate ---------------	*/
message ACconstruct_feet10( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list );

override VLgetLoftProps;

override VDgetObjDef;

end specification VLbutLine;

