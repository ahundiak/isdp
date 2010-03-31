/* ###################   APOGEE COMPILED   ################## */

class implementation EMScone;

#include "EMS.h"
# include "EMSerrordef.h" /* for EMSerror definitions */
# include "msdef.h"
# include "gocmacros.h"     /*  GRgetabsg macro */
# include "bserr.h" /* For BSERROR macro */
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
        of the natural edges belonging to a cone.

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
         EMS_E_Fail : if there was error in getting the abstract geometry
         EMS_E_InvalidArg : If invalid arguments in testing degeneracy.
         EMS_S_Success  : if successful 

History

        PP : 03/01/88     Fixed a bug wherin I was assuming that a cone
                          would be always closed in u.
        PP : 01/18/88     Modified the code to set the degenerate bit right
        PP : 10/13/87           creation

******************************************************************** */

{
 IGRlong status;
 IGRint i, seamind0, seamind1, notseam0, notseam1;
 struct IGRbsp_surface *surf;
 IGRchar *cache_ptr = NULL;
 IGRboolean degn1 = FALSE, degn3 = FALSE;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 GRgetabsg (&status, &md_env->matrix_type, md_env->matrix,
              &cache_ptr, i);
 EMerr_hndlr (!(1&status),*EMmsg,EMS_E_Fail,wrapup);

 surf = (struct IGRbsp_surface *) cache_ptr;
 
 if (surf->u_phy_closed)
 {
  seamind0 = 0;
  seamind1 = 2;
  notseam0 = 1;
  notseam1 = 3;
 }
 else if (surf->v_phy_closed)
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

 EMtestdegn (EMmsg, surf, notseam0, &degn1);
 if (!(1&*EMmsg)) goto wrapup;
  

 EMtestdegn (EMmsg, surf, notseam1, &degn3);
 if (!(1&*EMmsg)) goto wrapup;

 if (curve_type)
 {
  curve_type[seamind0] = EMlinesegment;
  if (degn1)
   curve_type[notseam0] = EMpoint;
  else
   curve_type[notseam0] = EMcircle;

  curve_type[seamind1] = EMlinesegment;
  if (degn3)
   curve_type[notseam1] = EMpoint;
  else
   curve_type[notseam1] = EMcircle;
 }

 if (edge_props)
 {
   edge_props[seamind0] = SEAM_EDGE | EMED_SUBORDINATE | EMED_TANGENT;
   edge_props[notseam0] = EMED_XYZ_CLOSED;
   edge_props[seamind1] = SEAM_EDGE | EMED_TANGENT;
   edge_props[notseam1] = EMED_XYZ_CLOSED;
   if (degn1) edge_props[notseam0] |= EMED_DEGENERATE;
   if (degn3) edge_props[notseam1] |= EMED_DEGENERATE;
 }

wrapup:
 if (cache_ptr) GRabsg_del(cache_ptr);
 return (status);

}

end implementation EMScone;
