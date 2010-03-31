class implementation EMSgraloop;

#include "EMS.h"
method EMlpcleanup (IGRlong *msg; IGRint *numsfs; 
                     struct EMSownercomp **sfloops; IGRint *numowners;
                     struct EMSownercomp **owncomps;
                     IGRushort options)
{
  *msg = EMS_S_Success;
  return(EMS_I_FeatureLoop);
}

end implementation EMSgraloop;

