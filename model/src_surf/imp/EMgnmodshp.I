/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method modifies the shape of an existing
 surface.  Please refer to the specification file 
 for a further description of this method.

 History

 rlw : 07/11/88 : Creation Date
 rlw : 08/08/88 : Modification code was not initialized in some cases
  NP : 08/19/92 : ANSI compile error. "surface" was typecast to "IGRchar *"
		  instead of "IGRchar **" in call to GRgetabsg.
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

extern IGRboolean    BSfreesf(), GRabsg_del_all();

method EMmodify_surface_shape(
 struct		GRlc_info *lc_info;
 IGRboolean	is_local_modification;
 IGRdouble	point_to_modify[2];
 IGRpoint	new_position;
 IGRdouble	from_point[2];
 IGRdouble	to_point[2];
 IGRboolean	modify_in_u;
 IGRboolean	preserve_u_low_tangents;
 IGRboolean	preserve_u_hig_tangents;
 IGRboolean	modify_in_v;
 IGRboolean	preserve_v_low_tangents;
 IGRboolean	preserve_v_hig_tangents;
 IGRlong	*msg)
{
 struct		IGRbsp_surface *surface, *modified_surface;
/*
 * Initialize
 */
 *msg = MSSUCC;
 surface = NULL;
 modified_surface = NULL;
/*
 * Get my geometry
 */
 {
  extern	IGRlong GRabsg_test();
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
 * Call the math function to change the shape
 */
 if (is_local_modification)
  {
   extern	void BSmodshpsfl();
   IGRlong	loc_msg;

   BSmodshpsfl(
     surface,
     from_point,
     point_to_modify,		/* Middle or direction point */
     to_point,
     point_to_modify,
     new_position,
     preserve_u_low_tangents,
     preserve_u_hig_tangents,
     preserve_v_low_tangents,
     preserve_v_hig_tangents,
     &modified_surface,
     &loc_msg);
    if (loc_msg != BSSUCC)
     {
#if DEBUG
      fprintf(stderr, "\nBSmodshpsfl failure, rc = %d", loc_msg);
#endif
      *msg = MSFAIL;
      goto wrapup;
     }
  } /* if (is_local_modification) */
 else
  {
   extern	void BSmodshpsfg();
   IGRshort	modify_code;
   IGRlong	loc_msg;

   modify_code = 0;
   if (modify_in_u &&
       (! surface->u_phy_closed))
    modify_code |= 1;
   if (modify_in_v &&
       (! surface->v_phy_closed))
    modify_code |= 2;
   BSmodshpsfg(
     surface,
     point_to_modify,
     new_position,
     modify_code,
     preserve_u_low_tangents,
     preserve_u_hig_tangents,
     preserve_v_low_tangents,
     preserve_v_hig_tangents,
     &modified_surface,
     &loc_msg);
    if (loc_msg != BSSUCC)
     {
#if DEBUG
      fprintf(stderr, "\nBSmodshpsfg failure, rc = %d", loc_msg);
#endif
      *msg = MSFAIL;
      goto wrapup;
     }
  } /* ELSE FOR if (is_local_modification) */
/*
 * Normalize the knot vectors
 */
 {
  extern	IGRlong BSnrsfkntvc();

  BSnrsfkntvc(modified_surface);
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
     (IGRchar *) modified_surface,
     &newobjid),
    targetid = my_id);
   if (! (1 & sts)) goto wrapup;
 }
/*
 * eof
 */
wrapup:
 if (modified_surface)
  {
/*
   extern IGRboolean	BSfreesf(), GRabsg_del_all();
*/
   IGRboolean		status;
   IGRlong		loc_msg;

   status = BSfreesf(
    &loc_msg, 
    modified_surface);
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
