/* ###################   APOGEE COMPILED   ################## */
/*
	
*/

class implementation EMSptedge;

#include "EMS.h"

method EMobint (IGRlong *msg; struct EMSpartolbasis *mytol; 
                 GRobjid other_obj; struct EMSpartolbasis *othertol;
                 IGRushort options;
                 IGRint *num_inters; struct EMSsfintedpar **my_inters,
                 **other_inters)
{
  *msg = EMS_S_Success;
  return (OM_S_SUCCESS);
}

end implementation EMSptedge;
