/* ###################   APOGEE COMPILED   ################## */
class implementation EMSbsedge;

#include "EMS.h"
#include "emsedgedef.h" /* for EMfreeform_curve */

method EMbsinit (IGRlong *EMmsg; 
                 IGRushort ed_props;
                 IGRuchar curve_type;
                 struct IGRbsp_curve *curve;
                 struct EMSpartolbasis *partolbasis)

{
  IGRlong           status;
  extern OM_S_OBJID current_creator;


  *EMmsg   =  EMS_S_Success;
  status = OM_S_SUCCESS;

  ME.EMSboundary->creator_id = current_creator;

/*
 * Currently all bsedges are stored as free form curve types. This
 * will have to change to store the correct type.
 */

  ME.EMSedge->ed_props = ed_props;
  if (curve_type)
   ME.EMSedge->curve_type = curve_type;
  else
   ME.EMSedge->curve_type = EMfreeform_curve;

  if (curve->phy_closed)
  {
    ME.EMSedge->ed_props |= EMED_XYZ_CLOSED;
  }
  else
  {
    ME.EMSedge->ed_props |= EMED_OPEN;
  }


  status = om$send (msg = message EMSedge.EMputbcgeom (EMmsg, 0,
                    ed_props & EMED_REVERSED, curve), 
                    targetid = my_id);
  EMerr_hndlr (!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   

wrapup:
  return (status);
}

end implementation EMSbsedge;
