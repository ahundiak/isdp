/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsolid;

#include "EMS.h"
/*
Description
     This method returns the geometry properties of an object.

Return values
     *msg         MSSUCC allways
     *properties  geometric properties.

history:
     DLB       10/29/87 : creation
*/

#include "msdef.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "EMSopt.h"

method GRgeomprops(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix; 
                   struct GRprops *properties)

{
  *msg = MSSUCC;
  
  properties->type         = GRSURFACE;
  properties->subtype      = GRCS;
  properties->closed       = 0;
  properties->phy_closed   = TRUE;    /*A solid is ALWAYS closed*/
  properties->is_segmented = 0;
  properties->planar       = ME.GRgraphics->properties & GRIS_PLANAR;

 wrapup:
  return(OM_S_SUCCESS);
}
end implementation EMSsolid;
