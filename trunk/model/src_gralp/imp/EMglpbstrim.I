/*
Notes
      Ignore the feature loop for trim intersections.
*/
class implementation EMSgraloop;

#include "EMS.h"
#include "emsinter.h"

method EMlpbstrimint (IGRlong *EMmsg;
                      struct IGRbsp_curve *incurve;
                      IGRdouble *incurve_range;
                      struct EMSpartolbasis *partol_basis;
                      IGRint tree_depth; IGRushort options;
                      IGRint *num_inters;
                      struct EMSsfintedpar **myinters;
                      struct EMSpypoint **polyinters)
 
{
  *EMmsg = EMS_S_Success;
  return(OM_S_SUCCESS);
}

end implementation EMSgraloop;
