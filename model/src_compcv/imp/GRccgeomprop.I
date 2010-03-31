/* ###################   APOGEE COMPILED   ################## */
class implementation GRcompcurve;

#include "EMScc.h"
#include "msdef.h"

/* # include "grdef.h" */

method GRgeomprops(IGRlong *msg;
		   IGRshort *mat_type;
		   IGRmatrix matrix; 
		   struct GRprops *properties)
/*
Abstract
	This method retrives information about the geometry of 
	composite curve

History
	gk	11/18/86	creation date
	rlw	05/08/87	fixed planar properties to use GRvg
*/

{
  *msg = MSSUCC;

  properties->type         = GRCURVE;
  properties->subtype      = GRCC;
  properties->closed       = 0;
  properties->phy_closed   = ME.GRcompcurve->comp_props & GRIS_PHY_CLOSED;
  properties->is_segmented = 0;
  properties->planar       = ME.GRgraphics->properties & GRIS_PLANAR;

  return( OM_S_SUCCESS );

}

end implementation GRcompcurve;
