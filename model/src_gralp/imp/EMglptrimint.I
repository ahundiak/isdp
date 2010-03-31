/*
Notes
	Ignore the feature loop for any trim intersections.
*/

class implementation EMSgraloop;

#include "emsinter.h"
#include "emssfint.h"

method EMlppytrimint (IGRlong *msg; struct IGRpolyline *inpoly;
                      IGRdouble *inpoly_range; 
                      struct EMSpartolbasis *partol_basis;
                      IGRint tree_depth; IGRushort options;
                      IGRint *num_inters;
                      struct EMSsfintedpar **myinters;
                      struct EMSpypoint  **polyinters) 
{
  
  *msg = EMS_S_Success;
  return (OM_S_SUCCESS);
}

end implementation EMSgraloop;
