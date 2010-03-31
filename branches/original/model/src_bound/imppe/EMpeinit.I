/* ###################   APOGEE COMPILED   ################## */
/*
Notes
        This method is an initialize method for an part_edge
  object. The initial values for properties, boundaries etc. should be
  input.

History
        SM      03/03/87        Creation date
        SM      08-Dec-87       Added curve_type to argument list.
*/
class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emsedgedef.h" /* for EMfreeform_curve */

method EMpeinit(IGRlong *EMmsg;IGRushort props;
                struct EMSedgebound *boundary;
                IGRuchar curve_type)
{
   extern OM_S_OBJID current_creator;

   *EMmsg = EMS_S_Success;

   ME.EMSboundary->creator_id = current_creator;

/* Transfer the properties bits into my instance data
*/
   ME.EMSedge->ed_props = props;

/* Transfer the boundaries into myself
*/
   OM_BLOCK_MOVE(boundary,ME.EMSpartedge->boundary,
                 2*sizeof(struct EMSedgebound));
                
/* Store the curve type
*/
  if (curve_type)
   ME.EMSedge->curve_type = curve_type;
  else
   ME.EMSedge->curve_type = EMfreeform_curve;

   return(OM_S_SUCCESS);
}

end implementation EMSpartedge;
