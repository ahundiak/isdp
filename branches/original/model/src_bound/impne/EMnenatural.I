/* ###################   APOGEE COMPILED   ################## */
class implementation EMSnatedge;

#include "EMSopt.h"
#include "EMSbnddef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "emsedgedef.h"

method EMmake_natural_edge(
    IGRlong                 *EMmsg; 
    IGRuchar        location;
    IGRuchar        *curve_type;
    IGRushort       *edge_props)
/*
Notes

History

	AIC	08/27/87	Creation Date
	RC	03/20/87 	Changed argument list to 
				include closed edge test option
				and included the code to the same.
        PP      05/29/87        Changed the method so that a curve type
                                is stored
        RC      11/10/87        Modified code and arguments

Algorithm

	Set the location. 
        Set the curve type if sent in.
        Set EMED_NATURAL, EMED_COMPATIBLE and EMED_OPEN properties.
        Add the incoming properties if any.        	
*/
{
  extern OM_S_OBJID current_creator;


  *EMmsg = EMS_S_Success;

  ME.EMSboundary->creator_id = current_creator;
  ME.EMSedge->ed_props = (edge_props ? *edge_props : NULL);
  ME.EMSedge->ed_props |= EMED_COMPATIBLE | EMED_NATURAL | EMED_OPEN;
  ME.EMSnatedge->location = location;
  ME.EMSedge->curve_type = (curve_type ? *curve_type : NULL);
 
return(OM_S_SUCCESS);
}

end implementation EMSnatedge;
