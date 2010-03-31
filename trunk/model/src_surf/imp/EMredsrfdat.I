/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method will replace the existing surface
 with one that approximates to within the active
 chord height tolerance.  Please refer to the 
 specification file for a further description 
 of this method.

 History

 rlw : 08/08/88 : Creation Date
 rlw : 09/05/88 : Modified to add error reporting (Math was changed)
 NP  : 08/21/92 : Modified for ANSI compliance.
 */


class implementation EMSgenbs;

#include "EMS.h"
#define DEBUG 1

#if DEBUG
#include <stdio.h>
#endif
#include "bs.h"			/* BSSUCC, etc. */
#include "msdef.h"		/* MSSUCC, MSFAIL */
#include "gocmacros.h"		/* GRgetasbsg macro */

extern       IGRboolean BSfreesf(), GRabsg_del_all();

method EMreduced_fit_surface(
 struct		GRlc_info *lc_info;
 IGRboolean	modify_in_u;
 IGRboolean	preserve_u_low_tangents;
 IGRboolean	preserve_u_hig_tangents;
 IGRboolean	modify_in_v;
 IGRboolean	preserve_v_low_tangents;
 IGRboolean	preserve_v_hig_tangents;
 IGRdouble	*maximum_error;
 IGRdouble	*average_error;
 IGRpoint	maximum_segment[2];
 IGRlong	*msg)
{
 struct		IGRbsp_surface *surface, *reduced_surface;
/*
 * Initialize
 */
 *msg = MSSUCC;
 surface = NULL;
 reduced_surface = NULL;
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
    (IGRchar **) &surface,
    i);
   if (! (1 & *msg)) goto wrapup;
 }
/*
 * Call the math function to reduce the data
 */
 {
  extern	void BSdta_rdusf();
  IGRlong	modify_code, loc_msg;
  BSpair	maxerr_param_original, maxerr_param_reduced;

  modify_code = 0;
  if (modify_in_u)
   {
    modify_code |= 1;
    if (surface->u_phy_closed)
     preserve_u_hig_tangents = preserve_u_low_tangents;
   }
  if (modify_in_v)
   {
    modify_code |= 2;
    if (surface->v_phy_closed)
     preserve_v_hig_tangents = preserve_v_low_tangents;
   }
  if (modify_code) modify_code -= 1;		/* 0 = u, 1 = v, 2 = (u,v) */
  BSdta_rdusf(
    surface,
    modify_code,
    preserve_u_low_tangents,
    preserve_u_hig_tangents,
    preserve_v_low_tangents,
    preserve_v_hig_tangents,
    TRUE,			/* Want errors reported */
    maximum_error,
    average_error,
    maxerr_param_original,
    maximum_segment[0],		/* maxerr_point_original */
    maxerr_param_reduced,
    maximum_segment[1],		/* maxerr_point_reduced */
    &reduced_surface,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
#if DEBUG
     fprintf(stderr, "\nBSdta_rdusf failure, rc = %d", loc_msg);
#endif
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Post the modified geometry into the database
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
     (IGRchar *) reduced_surface,
     &newobjid),
    targetid = my_id);
   if (! (1 & sts)) goto wrapup;
 }
/*
 * eof
 */
wrapup:
 if (reduced_surface)
  {
/*
   extern	IGRboolean BSfreesf(), GRabsg_del_all();
*/
   IGRboolean	status;
   IGRlong	loc_msg;

   status = BSfreesf(
    &loc_msg, 
    reduced_surface);
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
   
end implementation EMSgenbs;
