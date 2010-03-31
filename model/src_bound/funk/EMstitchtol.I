/* ###################   APOGEE COMPILED   ################## */
/*
DESCRIPTION
	This function returns the stitch tolerance to be used while making
two edges common. It computes the stitch tolerance based on the types of
the two edges. It is intended to be a central place to get the tolerance
from rather than having in line computations of the same.

HISTORY
	SM	08-Aug-89	Creation.
*/
class implementation EMSedge;

#ifndef DEBUG
#define DEBUG 0
#endif

#include "EMS.h"
#if DEBUG
#include <stdio.h>
#endif
#include "bserr.h"
#include "bsparameters.h"

extern OMuword OPP_EMSlinedge_class_id;

void EMget_stitchtol(EMmsg, ed1, ed2, stitol)
IGRlong		*EMmsg;
GRobjid		ed1, ed2;
IGRdouble	*stitol;
{
 IGRlong	sts = OM_S_SUCCESS, rc;
 OMuword	bottom_class;
 GRobjid	bottom_edge;
 IGRdouble	cht, distol;
 IGRint		i;

 *EMmsg = EMS_S_Success;
 BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);
 BSEXTRACTPAR(&rc, BSTOLLENVEC, distol);
 *stitol = 0.0;
 for(i=0; i<2; i++)
  {
   sts = om$send (msg = message EMSedge.EMget_bottom_edge(EMmsg, &bottom_edge),
			targetid = i ? ed2 : ed1, senderid = NULL_OBJID);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);

   sts = om$get_classid(objid = bottom_edge, p_classid = &bottom_class);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
   if( (bottom_class == OPP_EMSlinedge_class_id) || 
       ((sts = om$is_ancestry_valid(subclassid = bottom_class, 
	       superclassid = OPP_EMSlinedge_class_id)) == OM_S_SUCCESS)) 
     (*stitol) += cht;
    else (*stitol) += distol;
  }

wrapup:

#if DEBUG
 if(1&*EMmsg&sts) printf("Stitch tol = %3.12lf\n", *stitol);
#endif

return;
}

end implementation EMSedge;
