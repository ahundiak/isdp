// -----------------------------------------------------------------------------
//      Class    :      VLstretchV.S
//
//      Abstract :      Store data corresponding to a I/LOFT stretch values.
//
// -----------------------------------------------------------------------------

class specification VLstretchV(0:0) of VLabstract;

#include	"godef.h"
#include	"gr.h"
#include	"igr.h"
#include	"igrdp.h"
#include	"go.h"

override	ACconstruct_feet;

override 	VDgetObjDef;

message        create (IGRlong *msg; struct GRobj_env *unw; IGRdouble step_in_u;
                       IGRdouble step_in_v; struct GRmd_env *cur_env);

end specification VLstretchV;
