/* ###################   APOGEE COMPILED   ################## */

class implementation EMScylindr;

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
        of the natural edges belonging to a cylinder.

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

        PP : 03/01/88           Fixed a bug wherein I was assuming that
                                a cylinder will always be closed in u.
        PP : 10/13/87           creation

******************************************************************** */

{
 IGRshort i;
 IGRint seamind0, seamind1, notseam0, notseam1;
 struct IGRbsp_surface surf;
 IGRlong status;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 
 status = om$send (msg = message EMSsubbs.EMgetbsdef (EMmsg, &surf),
                   targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

 if (surf.u_phy_closed)
 {
  seamind0 = 0;
  seamind1 = 2;
  notseam0 = 1;
  notseam1 = 3;
 }
 else if (surf.v_phy_closed)
 {
  seamind0 = 1;
  seamind1 = 3;
  notseam0 = 0;
  notseam1 = 2;
 }
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 if (curve_type)
 {
  curve_type[seamind0] = EMlinesegment;
  curve_type[notseam0] = EMcircle;
  curve_type[seamind1] = EMlinesegment;
  curve_type[notseam1] = EMcircle;
 }

 if (edge_props)
 {
   edge_props[seamind0] = SEAM_EDGE | EMED_SUBORDINATE | EMED_TANGENT;
   edge_props[notseam0] = EMED_XYZ_CLOSED;
   edge_props[seamind1] = SEAM_EDGE | EMED_TANGENT;
   edge_props[notseam1] = EMED_XYZ_CLOSED;
 }

wrapup:
 return (status);

}
end implementation EMScylindr;
