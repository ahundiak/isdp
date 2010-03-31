class implementation GRcompcurve;

#include "EMS.h"
#include "OMminimum.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ma.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "bsdistptpt.h"

IGRlong EMclose_composite(msg, env, comp_curve, s_tol, c_tol)

IGRlong    *msg;
struct GRmd_env   *env;
struct GRid       comp_curve;
IGRdouble  s_tol;
IGRdouble  c_tol;

/*
Abstract
    Test to see if there is a gap at the endpoints of the composite.
    If there is a gap, then try to close if off.  Post the geometry as a
    closed curve.

Arguments
     *msg    IGRlong          completion code
     *env    struct GRmd_env  composite's module env
     comp_curve  struct GRid  composite's objid and osnum
     s_tol   IGRdouble        search tolerance
     c_tol   IGRdouble        connect tolerance

Return Values
   - MSSUCC if successful.
   - MSFAIL (severe) if other error.
   - EMS_E_NoIntersection  couldn't extend it.
   - EMS_I_OutOfBounds   if ext_pnt is outside search tolerance.

Files
	EMclosecomp.I

History
	dhm		7/20/88		Creation date.
	Sudha           7/02/93         Modified for BSprototypes ansification

*/

{

  IGRint       ret_count, count, i;
  IGRlong      msg_loc, status, EMextend_to_int();
  IGRpoint     start_pnt, end_pnt, ext_pnt;
  IGRdouble    dist_tol_sq, dist;
  struct GRid  obj1, obj2;
  struct GRparms  parm1, parm2;
  IGRchar         *geometry;
  struct GRpost_info  info;

  /*
   * Initialize
   */

  *msg = MSSUCC;
  status = OM_S_SUCCESS;

  /*
   * Get the end points of the composite curve and
   * the distance between them.  Test to see if the
   * gap between them if within the tolerances.
   */

  status = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                         &env->md_env.matrix_type, env->md_env.matrix,
                         start_pnt, end_pnt),
                   senderid = NULL_OBJID,
                   targetid = comp_curve.objid,
                   targetos = comp_curve.osnum);
  EMomerr_hndlr(status, wrapup, "EMclosecomp : GRendpts\n");
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, wrapup);

  dist = BSdistptpt(&msg_loc, start_pnt, end_pnt);

  if (dist <= s_tol)
  {
    if (dist > c_tol)
    {
      status = om$send(msg = message GRowner.GRget_components(&msg_loc,
                             env, &obj1, 1, &ret_count, 0, 0),
                       senderid = NULL_OBJID,
                       targetid = comp_curve.objid,
                       targetos = comp_curve.osnum);
      EMomerr_hndlr(status, wrapup, "EMclosecomp : GRget_comp\n");
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, wrapup);

      status = om$send(msg = message GRowner.GRget_number_components(
                             &msg_loc, &count),
                       senderid = NULL_OBJID,
                       targetid = comp_curve.objid,
                       targetos = comp_curve.osnum);
      EMomerr_hndlr(status, wrapup, "EMclosecomp : GRget_comp\n");
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, wrapup);

      i = count - 1; /* last component */
      status = om$send(msg = message GRowner.GRget_components(&msg_loc,
                             env, &obj2, 1, &ret_count, i, i),
                       senderid = NULL_OBJID,
                       targetid = comp_curve.objid,
                       targetos = comp_curve.osnum);
      EMomerr_hndlr(status, wrapup, "EMclosecomp : GRget_comp\n");
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, wrapup);

      parm1.u = 0.0;
      parm2.u = 1.0;
      dist_tol_sq = s_tol * s_tol;
      status = EMextend_to_int(&msg_loc, env, &obj1, &obj2, &parm1, &parm2,
                               dist_tol_sq, TRUE, TRUE, start_pnt,
                               end_pnt, ext_pnt);
      EMomerr_hndlr(status, wrapup, "EMextoint error\n");
      EMerr_hndlr(EMis_error(msg_loc), *msg, msg_loc, wrapup);

    }  /* end if dist > c_tol */

    /*
     * Post the abstract data
     */

    geometry = NULL;
    info.construct_flag = FALSE;
    status = om$send(msg = message GRvg.GRpostabsg(&msg_loc, env, &info,
                           geometry, &obj1.objid),
                     senderid = NULL_OBJID,
                     targetid = comp_curve.objid,
                     targetos = comp_curve.osnum);
    EMomerr_hndlr(status, wrapup, "EMclosecomp : GRpostabsg\n");
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, wrapup);

  }  /* end if dist <= s_tol */
  else
    *msg = EMS_I_OutOfBounds;


wrapup:
  return(status);
}

end implementation GRcompcurve;
