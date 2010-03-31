/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
#include "OMmacros.h"

method EMputRI(IGRlong *EMmsg; union EMSri_table *ri)
/*
Description
  This method stores the recompute info for the special saveside  in 
  instance data of this object.

History
  06/02/88 DLB Creation.
*/
{
  IGRlong                     OM_stat = OM_S_SUCCESS;
  IGRint                      count;


  *EMmsg = EMS_S_Success;

  /*Expand the vla for the ri.*/
  count = om$dimension_of(varray = ME.EMSdpr->ids);  
  
  OM_stat = om$vla_set_dimension(varray = ME.EMSdpr->ids,
                                  size = count + 1);
  if (!(1 & OM_stat)) goto wrapup;   
 
  /*Put the plane in the the vla.*/
  ME.EMSdpr->ids[count] = ri->saveside_info.plane_id;

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfboolean.EMputRI")
    return(OM_stat);
}
end implementation EMSsfboolean;
