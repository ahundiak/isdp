/* ###################   APOGEE COMPILED   ################## */

class implementation EMSelpcyl;

#include "EMS.h"
# include "EMSerrordef.h" /* for EMSerror definitions */
# include "emsedgedef.h" /* for edge type definitions */
# include "EMSconstruct.h" /* for SEAM_EDGE declaration */

method EMget_natedge_info (
    IGRlong                     *EMmsg;
    struct GRmdenv_info         *md_env;
    IGRuchar            *curve_type;
    IGRushort           *edge_props) 

/* *****************************************************************
Description
        The method returns the curve type and the edge properties
        of the natural edges belonging to an elliptical cylinder.

        Input
          md_env   : module enviroment information. May be set to NULL, as the
                     method does not use this information
          
        Output
          curve_type : the curve type of the natural edges. An array of size
                     four is expected to be allocated coming in.
          edge_props : the edge properties of the natural edges. An array of
                     size four is expected to be allocated coming in.
          EMmsg      : completion code

Notes
        Upon exit the completion code will be one of the following:
         EMS_S_Success  : if successful (should be always successful)

History

        PP : 10/13/87           creation

******************************************************************** */

{
 IGRshort i;

 *EMmsg = EMS_S_Success;

 if (curve_type)
 {
  curve_type[0] = EMlinesegment;
  curve_type[1] = EMellipse;
  curve_type[2] = EMlinesegment;
  curve_type[3] = EMellipse;
 }

 if (edge_props)
 {
   edge_props[0] = SEAM_EDGE | EMED_SUBORDINATE | EMED_TANGENT;
   edge_props[1] = EMED_XYZ_CLOSED;
   edge_props[2] = SEAM_EDGE | EMED_TANGENT;
   edge_props[3] = EMED_XYZ_CLOSED;
 }

 return (OM_S_SUCCESS);

}
end implementation EMSelpcyl;
