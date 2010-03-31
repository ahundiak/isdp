/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method either increases or changes the order of an
 existing freeform curve.

 History

 ss  : 09/29/86 : Design date.
 rlw : 12/28/87 : Totally reworked.
 dhm : 04/05/88 : Added GR_NOTIFY_LISTNERS
 Sudha  06/16/93     Modified for BSprototype ansification

 */

class implementation GRsubbc;

#include "EMS.h"
#include "bs.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "bsupthe_deg.h"
#include "bsfreecv.h"
#include "bschgcvord.h"

method EMmodify_order(
 IGRboolean	increase_it;
 struct		GRlc_info *lc_info;
 IGRlong	order;
 IGRlong	*msg)
{
 IGRlong	sts, loc_msg;
 struct		IGRbsp_curve *curve;
/*
 * Initialize
 */
 *msg = MSSUCC;
 curve = NULL;
/*
 * Get my geometry
 */
 sts = EMget_the_geometry(
   lc_info,
   TRUE,		/* It is a curve */
   FALSE,		/* It's not directed */
   TRUE,		/* Separate malloc's */
   my_id,
   &curve,
   msg);
  if (! (1 & sts)) goto wrapup;
/*
 * Call the math function to change
 * the order.
 */
 if (increase_it)
  {
   IGRboolean	status;
   IGRshort	degree;

   degree = order - 1;
   status = BSupthe_deg(
    &loc_msg,
    curve,
    &degree);
  }
 else
  {

   BSchgcvord(
    order,
    curve,
    &loc_msg);
  }
 if (loc_msg != BSSUCC)
  {
   *msg = MSFAIL;
   goto wrapup;
  }
/*
 * Post the modified geometry into the database
 */
 {
  GRobjid	newobjid;
  struct	GRpost_info info;

  info.construct_flag = FALSE;
  sts = om$send(
    msg = message GRvg.GRpostabsg(
     msg,
     &lc_info->module_info,
     &info,
     (IGRchar *) curve,
     &newobjid),
    targetid = my_id);
   if (! (1 & sts)) goto wrapup;
 }
/*
 * eof
 */
wrapup:
 if (curve)
  {
 extern  IGRboolean  GRabsg_del_all();
   IGRboolean	status;

   status = BSfreecv(
    &loc_msg, 
    curve);
   status = GRabsg_del_all();
  }

 GR_NOTIFY_LISTENERS(msg, &sts, GR_GEOM_MODIFIED);

 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}
   
end implementation GRsubbc;
