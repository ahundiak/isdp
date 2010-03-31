/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method either increases or changes the order of an
 existing freeform surface.

 History

 ss  : 09/30/86 : Design date.
 rlw : 05/26/87 : Changed "EMSbssubbs" to "EMSsubbs"
 rlw : 12/28/87 : Totally reworked.
 dhm : 04/05/88 : added GR_NOTIFY_LISTENERS.
 */

class implementation EMSgenbs;

#include "EMS.h"
#include "bs.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method EMmodify_order(
 IGRboolean	increase_it;
 struct		GRlc_info *lc_info;
 IGRlong	u_order;
 IGRlong	v_order;
 IGRlong	*msg)
{
 IGRboolean	change_u, change_v;
 IGRlong	sts, loc_msg;
 struct		IGRbsp_surface *surface;
/*
 * Initialize
 */
 *msg = MSSUCC;
 surface = NULL;
/*
 * Get my geometry
 */
 sts = EMget_the_geometry(
   lc_info,
   FALSE,		/* It is a surface */
   FALSE,		/* Garbage */
   TRUE,		/* Separate malloc's */
   my_id,
   &surface,
   msg);
  if (! (1 & sts)) goto wrapup;
/*
 * Determine which orders are being changed
 */
 if (u_order &&
     (u_order != surface->u_order))
  change_u = TRUE;
 else
  change_u = FALSE;
 if (v_order &&
     (v_order != surface->v_order))
  change_v = TRUE;
 else
  change_v = FALSE;
/*
 * Call the math function to change
 * the order.
 */
 if (increase_it)
  {
  extern    void	BSsfincord();
  extern void   BSsfincvord();
  extern void   BSsfincuord();

   if (change_u && change_v)
    BSsfincord(
     u_order,
     v_order,
     surface,
     &loc_msg);
   else if (change_v)
    BSsfincvord(
     v_order,
     surface,
     &loc_msg);
   else if (change_u)
    BSsfincuord(
     u_order,
     surface,
     &loc_msg);
   else
    loc_msg = BSSUCC;
  }
 else
  {
  extern    void		BSchgsford();
   IGRlong	key;

   if (change_u && change_v)
    key = 2;
   else if (change_v)
    key = 1;
   else if (change_u)
    key = 0;
   else
    key = 3;
   if (key == 3)
    loc_msg = BSSUCC;
   else
    BSchgsford(
     key,
     u_order,
     v_order,
     surface,
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
     (IGRchar *) surface,
     &newobjid),
    targetid = my_id);
   if (! (1 & sts)) goto wrapup;
 }
/*
 * eof
 */
wrapup:
 if (surface)
  {
 extern  IGRboolean  GRabsg_del_all();
 extern  IGRboolean  BSfreesf();
   IGRboolean	status;

   status = BSfreesf(
    &loc_msg, 
    surface);
   status = GRabsg_del_all();
  }

 GR_NOTIFY_LISTENERS(msg, &sts, GR_GEOM_MODIFIED);

 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}
   
end implementation EMSgenbs;
