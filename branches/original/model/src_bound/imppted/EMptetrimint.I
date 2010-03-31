/* ###################   APOGEE COMPILED   ################## */
/*
	A point edge ignores itself for trimming.
*/
class implementation EMSptedge;

#include "EMS.h"
method EMedpytrimint (IGRlong *msg; struct IGRpolyline *inpoly;
                       IGRdouble *inpoly_range; 
                       struct EMSpartolbasis *partol_basis;
                       struct EMSpartedinfo *partinfo; 
                       IGRushort options;
                       IGRint *num_inters;
                       struct EMSsfintedpar **my_inters;
                       struct EMSpypoint  **polyinters)
{
  
  *msg = EMS_I_DegenerateEdge;
  return (OM_S_SUCCESS);
}

end implementation EMSptedge;

