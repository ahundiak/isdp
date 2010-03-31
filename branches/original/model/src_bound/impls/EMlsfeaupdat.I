/* ###################   APOGEE COMPILED   ################## */
/*

*/
    
class implementation EMSloopset;

#include "OMmacros.h"

method EMupdate_features (IGRlong *EMmsg;
		    GRobjid **added_obj;
		    IGRint *num_added_obj;
		    IGRint *numsfs; 
                    struct EMSownercomp **sfloops; 
		    IGRint *numowners;
                    struct EMSownercomp **owncomps;
		    IGRboolean insert_into_loopset;
		    struct EMSpartolbasis *partolbasis)
{
  IGRlong		sts;

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /* For AUTOFACT, this method has been left in place. After AUTOFACT,
    it will be removed. */

  return (sts);
}

end implementation EMSloopset;
