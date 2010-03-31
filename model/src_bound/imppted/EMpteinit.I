/* ###################   APOGEE COMPILED   ################## */
/*
Notes
        This method initializes the point edge. If the 2D point is passed
  in it stores the point in its instance data.
  The input properties are also stored but the following is done
  unconditionally- 
  1) Mark the edge as EMED_DEGENERATE and EMED_XYZ_CLOSED.
  2) Turn off the EMED_OPEN and EMED_REVERSED bits.
  Also the curve type is set to EMpoint;
*/

class implementation EMSptedge;

#include "EMS.h"
#include "emsedgedef.h"
#include "OMmacros.h"

method EMpteinit(IGRlong *EMmsg; IGRushort props;
                 IGRdouble *point)
{
  extern OM_S_OBJID current_creator;

  *EMmsg = EMS_S_Success;

  ME.EMSboundary->creator_id = current_creator;
  ME.EMSedge->ed_props = props;
  if(point) OM_BLOCK_MOVE(point, ME.EMSptedge->point, 2 * sizeof(IGRdouble));
  ME.EMSedge->curve_type = EMpoint;
  ME.EMSedge->ed_props |= EMED_DEGENERATE | EMED_XYZ_CLOSED;
  ME.EMSedge->ed_props &= ~EMED_OPEN;
  ME.EMSedge->ed_props &= ~EMED_REVERSED;
  return(OM_S_SUCCESS);
}

end implementation EMSptedge;
