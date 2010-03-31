/*
 Description

 This method replaces the existing curve with one that
 has reduced data.  Please refer to the specification file
 for a further description of this method.

 History

 rlw : 07/05/88 : Creation Date
 rlw : 08/05/88 : Modified such that the command deletes the input
                  curve, i.e. it is no longer a constrution command.
 rlw : 09/05/88 : Modified to add error reporting (Math was changed)
 Sudha  06/16/93     Modified for BSprototype ansification
 */

class implementation GRsubbc;

#include "EMS.h"
#define DEBUG 1

#if DEBUG
#include <stdio.h>
#endif
#include "bs.h"			/* BSSUCC, etc. */
#include "msdef.h"		/* MSSUCC, MSFAIL */
#include "gocmacros.h"		/* GRgetasbsg macro */
#include "bsfreecv.h"
#include "bsdta_rducv.h"

extern IGRboolean GRabsg_del_all() ;

method EMreduced_fit_curve(
 struct		GRlc_info *lc_info;
 IGRboolean	preserve_beginning_tangent;
 IGRboolean	preserve_ending_tangent;
 IGRdouble	*maximum_error;
 IGRdouble	*average_error;
 IGRpoint	maximum_segment[2];
 IGRlong	*msg)
{
 struct		IGRbsp_curve *curve;
 struct		IGRbsp_curve *reduced_curve;
/*
 * Initialize
 */
 *msg = MSSUCC;
 curve = NULL;
 reduced_curve = NULL;
/*
 * Get my geometry
 */
 {
  IGRlong	i;
  struct	GRmdenv_info *mdenv_info;

  mdenv_info = &lc_info->module_info.md_env;
  GRgetabsg(
    msg,
    &mdenv_info->matrix_type, 
    mdenv_info->matrix,
    (IGRchar **) &curve,
    i);
   if (! (1 & *msg)) goto wrapup;
 }
/*
 * Call the math
 */
 {
  IGRlong	loc_msg, tangent_left_code, tangent_right_code;
  IGRdouble	param_orig, param_reduced;
  IGRvector	left_tangent, right_tangent;

  tangent_left_code = (preserve_beginning_tangent ? 1 : 0);
  tangent_right_code = (preserve_ending_tangent ? 1 : 0);
  BSdta_rducv(
   curve,
   tangent_left_code,
   tangent_right_code,
   left_tangent,		/* The math will set this */
   right_tangent,		/* The math will set this */
   TRUE,			/* Want errors reported */
   maximum_error,
   average_error,
   &param_orig,
   maximum_segment[0],
   &param_reduced,
   maximum_segment[1],
   &reduced_curve,
   &loc_msg);
  if (loc_msg != BSSUCC)
   {
#if DEBUG
    fprintf(stderr, "\nBSdta_rducv failure, rc = %d", loc_msg);
#endif
    *msg = MSFAIL;
    goto wrapup;
   }
 }
/*
 * Post my modified geometry
 */
 {
  GRobjid	newobjid;
  IGRlong	sts;
  struct	GRpost_info info;

  info.construct_flag = FALSE;
  sts = om$send(
    msg = message GRvg.GRpostabsg(
     msg,
     &lc_info->module_info,
     &info,
     (IGRchar *) reduced_curve,
     &newobjid),
    targetid = my_id);
   if (! (1 & sts)) goto wrapup;
 }
/*
 * eof
 */
wrapup:
 if (reduced_curve)
  {
/*
extern IGRboolean GRabsg_del_all() ;
*/
   IGRboolean	status;
   IGRlong	loc_msg;

   status = BSfreecv(
    &loc_msg, 
    reduced_curve);
   status = GRabsg_del_all();
  }
/*
 * Notify those who depend on us and return
 */
 {
  IGRlong	sts;

  if (1 & *msg)
   sts = OM_S_SUCCESS;
  else
   sts = OM_E_ABORT;
  GR_NOTIFY_LISTENERS(msg, &sts, GR_GEOM_MODIFIED);
  return(sts);
 }
}

end implementation GRsubbc;
