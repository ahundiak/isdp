/*
 Description

 This method is used to modify the shape of a bspline
 curve.  Please refer to the specification file for
 a further description of this method.

 History

 rlw : 06/13/88 : Creation Date
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
#include "bsmodshpcvl.h"
#include "bsmodshpcvg.h"
#include "bsfreecv.h"

extern IGRboolean GRabsg_del_all() ;

method EMmodify_curve_shape(
 struct		GRlc_info *my_curve;
 IGRdouble	modify_parameter;
 IGRpoint	new_position;
 IGRdouble	u_start;
 IGRdouble	u_end;
 IGRboolean	preserve_beginning_tangent;
 IGRboolean	preserve_ending_tangent;
 IGRboolean	is_global_modification;
 IGRlong	*msg)

{
 struct		IGRbsp_curve *curve;
 struct		IGRbsp_curve *mod_curve;
/*
 * Initialize
 */
 *msg = MSSUCC;
 curve = NULL;
 mod_curve = NULL;
/*
 * Get my geometry
 */
 {
  extern	IGRlong GRabsg_test();
  IGRlong	i;
  struct	GRmdenv_info *mdenv_info;

  mdenv_info = &my_curve->module_info.md_env;
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
  IGRlong	loc_msg;

  if (is_global_modification)
   {

    BSmodshpcvg(
     curve,
     modify_parameter,
     new_position,
     preserve_beginning_tangent,
     preserve_ending_tangent,
     &mod_curve,
     &loc_msg);
   }
  else
   {

    BSmodshpcvl(
     curve,
     u_start,
     modify_parameter,		/* u_middle */
     u_end,
     modify_parameter,
     new_position,
     preserve_beginning_tangent,
     preserve_ending_tangent,
     &mod_curve,
     &loc_msg);
   }
  if (loc_msg != BSSUCC)
   {
#if DEBUG
    fprintf(stderr, "\nBSmodshpcv failure, rc = %d", loc_msg);
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
     &my_curve->module_info,
     &info,
     (IGRchar *) mod_curve,
     &newobjid),
    targetid = my_id);
   if (! (1 & sts)) goto wrapup;
 }
/*
 * eof
 */
wrapup:
 if (mod_curve)
  {
/*extern IGRboolean GRabsg_del_all() ;*/
   IGRboolean		status;
   IGRlong		loc_msg;

   status = BSfreecv(
    &loc_msg, 
    mod_curve);
   status = GRabsg_del_all();
  }
 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

end implementation GRsubbc;
