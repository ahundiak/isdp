/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method extends a freeform surface.

 History

 gupta : 09/26/86 : creation date
   rlw : 12/30/87 : Totally reworked.
  dhm    04/05/88   add GR_NOTIFY_LISTENERS.
   rlw : 02/01/89 : Modified not to free sf if math fails
    NP : 19/08/92 : ANSI compile error. "surface" was cast to "IGRchar *"
		    instead of "IGRchar **" in GRgetabsg call.

 */

class implementation EMSgenbs;

#include "EMS.h"
#include "bs.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"		/* GRgetasbsg macro */

extern       IGRboolean GRabsg_del_all();

method EMextend_surface(
 struct		GRlc_info *lc_info;
 IGRpoint	side_point;
 IGRpoint	extension_point;
 IGRlong	option;
 IGRlong	*msg)
{
 IGRlong	sts, loc_msg, i;
 struct		IGRbsp_surface *surface, *extended_surface;
/*
 * Initialize
 */
 *msg = MSSUCC;
 extended_surface = NULL;
/*
 * Get my geometry
 */
 {
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
 * Call the math function
 */
 {
  extern   void	BSsfxttpt();

  BSsfxttpt(
    option,
    surface,
    side_point,
    extension_point,
    &extended_surface,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     extended_surface = NULL;  /* Core dumps reported on failure */
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
     (IGRchar *) extended_surface,
     &newobjid),
    targetid = my_id);
   if (! (1 & sts)) goto wrapup;
 }
/*
 * eof
 */
wrapup:
 if (extended_surface)
  {
/*
   extern	IGRboolean GRabsg_del_all();
*/
   extern	IGRboolean BSfreesf();
   IGRboolean	status;

   status = BSfreesf(
    &loc_msg, 
    extended_surface);
   status = GRabsg_del_all();
  }

 GR_NOTIFY_LISTENERS(msg, &sts, GR_GEOM_MODIFIED);

 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}
   
end implementation EMSgenbs;
