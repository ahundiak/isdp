// -----------------------------------------------------------------------------
//      Class    :      VLunwrap.S
//
//      Abstract :      Store data corresponding to a I/LOFT unwrap.
//
// -----------------------------------------------------------------------------

class specification VLunwrap(0:0) of VLabstract;

#include	"godef.h"
#include	"gr.h"
#include	"igr.h"
#include	"igrdp.h"
#include	"go.h"
#include	"vlstructure.h"

override	ACconstruct_feet,NDdelete;

override	VDgetObjDef;

message        create (IGRlong *msg; struct GRobj_env *surf; 
                       struct GRobj_env *cs; double *options; 
                       struct GRmd_env *cur_env);

message        getRoots (IGRlong *msg;
                         struct GRmd_env *cur_env;
                         struct mise_a_plat *dev; 
                         struct GRobj_env *plate;
                         int *exp_type; 
                         double *x_expansion; 
                         double  *y_expansion;
                         int    *UnwSrfWanted; 
                         double *RefMat;
                         struct GRid *box);

end specification VLunwrap;
