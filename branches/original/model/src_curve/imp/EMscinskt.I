/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method inserts a knot into a freeform curve.

 History

 ss  : 09/29/86 : Design date.
 rlw : 12/29/87 : Totally reworked.
 dhm : 04/05/88 : Added GR_NOTIFY_LISTNERS
 Sudha  06/16/93     Modified for BSprototype ansification

 */

class implementation GRsubbc;

#include "EMS.h"
#include "bs.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "bsfreecv.h"
#include "bsadd_kt2.h"

method EMinsert_knot(
 struct		GRlc_info *lc_info;
 IGRdouble	knot_value;
 IGRlong	multiplicity;
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
 * Call the math function to insert
 * the knot(s).
 */
 {
  IGRboolean	status;

  status = BSadd_kt2(
    &loc_msg,
    curve,
    &knot_value,
    (IGRint *)&multiplicity);
   if (loc_msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
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
