/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	The ptedge ignores itself for trim intersections.
*/

class implementation EMSptedge;

#include "EMS.h"

method EMedbstrimint (IGRlong *msg; struct IGRbsp_curve *incrv;
                       IGRdouble *incrv_range; 
                       struct EMSpartolbasis *partol_basis;
                       struct EMSpartedinfo *partinfo; 
                       IGRushort options;
                       IGRint *num_inters;
                       struct EMSsfintedpar **my_inters;
                       struct EMSpypoint  **polyinters)
{

    *msg = EMS_S_Success;
    return(OM_S_SUCCESS);
}

end implementation EMSptedge;
