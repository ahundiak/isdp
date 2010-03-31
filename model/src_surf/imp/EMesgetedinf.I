/* ###################   APOGEE COMPILED   ################## */

class implementation EMSelpsoid;

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
        of the natural edges belonging to a ellipsoid.

        Input
          md_env   : module enviroment information. May be set to NULL, as the
                     method does not use this information
          
        Output
          curve_type : the curve type of the natural edges. An array of size
                     four is expected to be allocated coming in.
          edge_props : the edge properties of the natural edges. An array of
                     size four is expected to be allocated coming in.
          EMmsg      : completion code

Assumptions
        It is assumed that the ellipsoid is placed by rotating a semi-ellipse
        arc through 360 degrees. So if the math change, their way of placing
        an ellipsoid, this method will not be true any more. This 
        assumption is being made for efficiency reasons.

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
  curve_type[0] = EMpoint;
  curve_type[1] = EMelliptical_arc;
  curve_type[2] = EMpoint;
  curve_type[3] = EMelliptical_arc;
 }

 if (edge_props)
 {
   edge_props[0] = EMED_DEGENERATE;
   edge_props[1] = SEAM_EDGE | EMED_SUBORDINATE | EMED_TANGENT;
   edge_props[2] = EMED_DEGENERATE;
   edge_props[3] = SEAM_EDGE | EMED_TANGENT;
 }

 return (OM_S_SUCCESS);

}
end implementation EMSelpsoid;
