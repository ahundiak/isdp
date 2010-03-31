/*
  DESCRIPTION

    This function may be called to re-parameterize a given curve
    given pairs of old points on the curve and the new points that
    they should  now correspond to. The points may either be specified
    using u-paramters of the curve at these points or the xyz-points
    themselves. The preferred way is to specify the u-paramters. Optionally,
    the curves can be reversed and/or reparametrized by arc-length before
    applying any correction implied by the rest of the input.

    The pairs of parameters that result after applying any reversals or
    reparamterizations must be in the ascending order.

  HISTORY

    SS  :  09/03/90  :  If adjacent new-parameters are within partol of each
                        other move them apart bt a little more than partol.
                        Such a happening is made known to the caller through
                        the return code - EMS_I_Degenerate.
    SS  :  01/25/90  :  If the pairs of paramters to reparameterize are not
                        in the ascending order, return a special error
			code - EMS_E_InvalidArg.
    SS  :  08/01/89  :  Added the option to reverse the curve before any
                        performing any change.
    SS  :  04/25/89  :  Creation
    Sudha  06/16/93	Modified for BSprototype ansification

*/

class implementation GRbspline;

#include "EMS.h"
%safe
#include <math.h>
%endsafe
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "bsmodcvparm.h"
#include "bsmdstptcv.h"
#include "bsfreecv.h"
#include "bscvkttol2.h"
#include "bsarclnparc.h"
#include "bsalloccv.h"

#define NUM_STATIC_PARS 10

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_GRsubbc_class_id;

IGRlong EMcvreparam (msg, cvid, md_env, wrt_arclnpar, wrt_revcv,
                     numpts, oldpars, oldpts, newpars, newpts)
IGRlong *msg;
struct GRid *cvid;
struct GRmd_env *md_env;
IGRboolean wrt_arclnpar, wrt_revcv;
IGRint numpts;
IGRdouble *oldpars, *newpars;
IGRpoint *oldpts, *newpts;
{
  IGRint i;
  IGRlong msg_loc, stat_OM;
  IGRdouble npars_mem[NUM_STATIC_PARS], *npars;
  IGRdouble opars_mem[NUM_STATIC_PARS], *opars;
  IGRdouble mdist, cvutol, ufactor, ulow, uhigh;
  IGRpoint mpoint;
  GRclassid classid;
  struct IGRbsp_curve *cv, *newcv;
  struct GRpost_info post_info;
  extern IGRboolean GRabsg_del_all();
  extern IGRlong EMpromote_class(), EMgetvggeom();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  cv = NULL;
  newcv = NULL;
  npars = NULL;
  opars = NULL;

  if (wrt_revcv)
    {
    stat_OM = om$send (msg = message GRcurve.GRrevparm (&msg_loc, md_env),
               targetid = cvid->objid, targetos = cvid->osnum,
               senderid = NULL_OBJID);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);
    }

  /*
   * Further processing takes place only if parameterization changes
   * have been requested.
   */

  if (!wrt_arclnpar && !numpts)
    goto ret_end;

  /*
   * Obtain the geometry of the curve
   */

  stat_OM = EMgetvggeom (&msg_loc, &md_env->md_env.matrix_type,
             md_env->md_env.matrix, cvid, &cv, NULL);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);

  /*
   * If the option is set to first redo parametrization by arc-length
   * then transform the knot-vector of this curve by the math
   * function.
   */

  if (wrt_arclnpar)
    {
    BSarclnparc (&msg_loc, cv);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    }

  /*
   * Obtain the curve parameters that correspond to the old points
   * that have been input (if these params have not already been input).
   */

  if (numpts && !oldpars)
    {
    if (numpts > NUM_STATIC_PARS)
      opars = (IGRdouble *) om$malloc (size = numpts * sizeof (IGRdouble));
    else
      opars = opars_mem;
    EMerr_hndlr (!opars, *msg, EMS_E_NoDynamicMemory, ret_end);

    for (i=0; i<numpts; i++)
      {
      BSmdstptcv (cv, oldpts[i], &opars[i], mpoint, &mdist, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
      }
    }
  else
    opars = oldpars;

  /*
   * Obtain the curve parameters that correspond to the new points
   * that have been input (if these params have not already been input).
   */

  if (numpts && !newpars)
    {
    if (numpts > NUM_STATIC_PARS)
      npars = (IGRdouble *) om$malloc (size = numpts * sizeof (IGRdouble));
    else
      npars = npars_mem;
    EMerr_hndlr (!npars, *msg, EMS_E_NoDynamicMemory, ret_end);

    for (i=0; i<numpts; i++)
      {
      BSmdstptcv (cv, newpts[i], &npars[i], mpoint, &mdist, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
      }
    }
  else
    npars = newpars;

  /*
   * Allocate sufficient space for the re-paramtertized curve and
   * call the math function to give the new geometry. Force the knot-vector
   * to be recorded as non-uniform in case math did not. If no new points have
   * been generated then post the geometry without further ado. Check if
   * if the parameters are in the ascending order; if not exit with appropriate
   * return code.
   */

  if (numpts)
    {
    BSalloccv (cv->order, cv->num_poles + numpts * (cv->order-1), cv->rational,
     NULL, &newcv, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    for (i=0; i<numpts-1; i++)
      EMerr_hndlr (npars[i] > npars[i+1] || opars[i] > opars[i+1], *msg,
                   EMS_E_InvalidArg, ret_end);

    ulow = cv->knots[cv->order-1];
    BScvkttol2 (cv->order, cv->knots, cv->num_poles, cv->poles, cv->weights,
     &cvutol, &msg_loc);
    ufactor = 2 * cvutol;
    for (i=0; i<numpts-1; i++)
      if (fabs (npars[i] - npars[i+1]) <= cvutol)
        {
        EMerr_hndlr (fabs (npars[i] - ufactor) <= ulow, *msg, EMS_E_InvalidArg,
                     ret_end);
        npars[i] -= ufactor;
        }

    uhigh = cv->knots[cv->num_poles];
    EMerr_hndlr (npars[0] <= ulow || npars[numpts-1] >= uhigh, *msg,
                 EMS_E_InvalidArg, ret_end);
    for (i=0; i<numpts-1; i++)
      EMerr_hndlr (fabs (npars[i] - npars[i+1]) <= cvutol, *msg,
                   EMS_E_InvalidArg, ret_end);

    BSmodcvparm (&msg_loc, 1, &cv, numpts, npars, opars, &newcv);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    newcv->non_uniform = TRUE;
    }
   
  /*
   * If the input curve is not a free-form curve, change the
   * class to a free-form one.
   */

  stat_OM = om$get_classid (objid = cvid->objid, osnum = cvid->osnum, 
                 p_classid = &classid);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_GRsubbc_class_id);
  EMomerr_exit (stat_OM, ret_end);
 
  if (stat_OM == OM_I_INVANCESTRY)
    {
    stat_OM = EMpromote_class (TRUE, md_env, cvid, &msg_loc);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * Post the geometry into the free-form curve.
   */

  post_info.construct_flag = FALSE;
  stat_OM = om$send (msg = message GRvg.GRpostabsg (&msg_loc, md_env,
                           &post_info, (char *) (numpts ? newcv : cv), 
                           &cvid->objid),
                     targetid = cvid->objid, targetos = cvid->osnum,
                     senderid = NULL_OBJID);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);

ret_end:
  if (cv)
    om$dealloc (ptr = cv);
  if (newcv)
    BSfreecv (&msg_loc, newcv);
  if (opars && opars != opars_mem && opars != oldpars)
    om$dealloc (ptr = opars);
  if (npars && npars != npars_mem && npars != newpars)
    om$dealloc (ptr = npars);

  if (*msg != EMS_E_InvalidArg)
    EMWRAPUP (stat_OM, *msg, "EMcvreparam");
  return (stat_OM);
}

end implementation GRbspline;
