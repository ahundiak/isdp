/* ###################   APOGEE COMPILED   ################## */
class implementation EMSptedge;

#include "EMS.h"

#include "emsdattyp.h"

/*
 * History                  
 *		SM	26-Oct-87	Genesis
 */

method EMgetgeom (IGRlong *EMmsg; IGRint from_spaninx; IGRint num_spans;
                    IGRboolean reverse; struct EMSpartedinfo *partinfo;
                    struct EMSaltdataselect *geom)
{
 IGRlong status;
 
 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

geom->datatype = EMSdata_poly2d;

status = om$send (msg = message EMSedge.EMgetpygeom (EMmsg, from_spaninx,
                        num_spans, reverse, partinfo, &geom->data.poly,
                        NULL, NULL),
                  targetid = my_id);
EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);
  
wrapup:
  return (status);
}

end implementation EMSptedge;
