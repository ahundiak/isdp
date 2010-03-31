/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emsmacros.h"

method EMputpygeom (IGRlong *msg; IGRint before_ptinx; IGRboolean reverse;
                    struct IGRpolyline *inpygeom;
		    IGRboolean check_constraints;
		    struct EMSpartolbasis *partolbasis;
		    struct EMSpartedinfo *part;
		    struct EMSdataselect *surf_data;
		    IGRshort *mattyp;
		    IGRmatrix mat)
{
  OM_S_CHANSELECT		to_edge;
  IGRlong			sts;

  to_edge.type = OM_e_addr;
  to_edge.u_sel.addr = &ME.EMSbd_owner->to_comps;

  if(part)
    sts = om$send(msg = OPPmargs, p_chanselect = &to_edge);
  else
   {
     struct EMSpartedinfo my_info;
     EMput_partinfo (my_info);
     sts = om$send(msg = message EMSedge.EMputpygeom
		(msg, before_ptinx, reverse, inpygeom, check_constraints, 
		 partolbasis, &my_info, surf_data, mattyp, mat), 
		p_chanselect = &to_edge);
   }
  return(sts);
}

end implementation EMSpartedge;
