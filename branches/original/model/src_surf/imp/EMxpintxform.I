/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsplane;

%safe
#include <math.h>
%endsafe


#include "EMS.h"
# include "msdef.h" /* MS message codes */
# include "ma.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMcp.h"
# include "EMSprop.h"
# include "EMSopt.h"
# include "gocmacros.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "EMSxsection.h"

/*

 History     

        RC     11/29/88      Creation Date

*/
 
method EMxsec_int_xform(IGRlong *EMmsg; struct GRmd_env *md_env;
	IGRshort *matrix_type; IGRmatrix matrix; IGRmatrix inv_matrix;
    GRobjid *newobjid; IGRboolean xform_thru_notification)
{
  IGRmatrix         align_mat, md_align_mat;
  IGRlong           OM_stat, mthd_stat, rc;
  IGRshort          align_mattyp, dim = 4;
  IGRboolean        status;
  extern IGRboolean MAmulmx();
   
  /* ***************************************************************** */

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /*
   * If the transformation is not coming through notification,
   * the cross_section is being transformed without
   * transforming its associated model. In such a case, cross_section 
   * plane's alignment info will no longer be valid. Therefore, need
   * to update my alignment info in such cases.
   */

  if (!xform_thru_notification)
  {
   OM_stat = om$send (msg = message EMSxsplane.EMget_alignment_matrix (
                       &mthd_stat, md_env, align_mat, &align_mattyp),
                      targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

   status = MAmulmx (&rc, &dim, &dim, &dim, align_mat, inv_matrix,
                     md_align_mat);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   OM_stat = om$send (msg = message EMSxsplane.EMput_alignment_info (
                       &mthd_stat, EMS_FMT_MATRIX, NULL, NULL,
                       md_align_mat),
                      targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

  } /* if (!xform_thru_notification) */

  OM_stat = om$send (mode = OM_e_wrt_parent,
                     msg = message EMSxsplane.GRxform (EMmsg, md_env,
                           matrix_type, matrix, newobjid),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat& *EMmsg), *EMmsg, EMS_E_SurfaceError,wrapup);

  wrapup:
   EMWRAPUP (OM_stat, *EMmsg, "In EMSxsplane.EMxsec_int_xform");
   return (OM_stat);
}

end implementation EMSxsplane;
