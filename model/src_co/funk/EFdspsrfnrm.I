/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This funtion will display the natural normal of a surface or
 it's reverse.

 Arguments

 loc_info		Surface locate information

 natural_normal		If TRUE  then display the natural normal, else
			display it's opposite.

 my_stupid_id		Callers object id.

 draw_background	If TRUE then draw in background, else erase.

 display_env		Display enviroment.  Should be obtained by calling
			gr$get_display_env().

 display		Active color, weight, etc.  Should be obtained by
			calling gr$get_active_display().

 msg			MSSUCC or MSFAIL

 History

 11/19/87 : rlw : Creation date.  Mostly duplicated from show normals.

 Sudha   06/02/93        modified to include for BSprototype headers
 */

class implementation Root;

#include "EMS.h"

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"		/* Includes everything */
#include "bsbx2.h"

from GRvg import GRgenabsg;

IGRlong EFdisplay_surface_normal(
 loc_info,		/* Which surface? */
 natural_normal,	/* Natural or reversed? */
 my_stupid_id,		/* Your id */
 draw_background,	/* Draw in background or erase? */
 display_env,		/* Display enviroment */
 display,		/* Color, weight, etc. */
 msg)			/* Error return code */

struct		GRlc_info *loc_info;
IGRboolean	natural_normal;
OM_S_OBJID	my_stupid_id;
IGRboolean	draw_background;
struct		GRmd_env *display_env;
struct		IGRdisplay *display;
IGRlong		*msg;

{
 IGRlong	sts;
 IGRpoint	point_on_surface;
 IGRvector	surface_normal;
 GRrange	range;
 struct		IGRbsp_surface *surface;
/*
 * Initialize
 */
 *msg = MSSUCC;
/*
 * Get the surface geometry
 */
 {
  IGRchar	*generic_pointer;
  struct	GRid *id;
  struct	GRmdenv_info *mdenv_info;

  mdenv_info = &loc_info->module_info.md_env;
  id = &loc_info->located_obj;
  sts = om$send(
    msg = message GRvg.GRgenabsg(
     msg,
     &mdenv_info->matrix_type,
     mdenv_info->matrix,
     &generic_pointer),
    senderid = my_stupid_id,
    targetid = id->objid,
    targetos = id->osnum);
   if (! (1 & sts)) goto wrapup;
  surface = (struct IGRbsp_surface *) generic_pointer;
 }
/*
 * Compute the tangent vector of the surface at
 * a predefined parameter value
 */
 {
  void		EMavgsfnorm();
  IGRlong	loc_msg;
  IGRdouble	u = .48, v = .48;

  EMavgsfnorm(
    &loc_msg,
    surface,
    u, v,
    point_on_surface,
    surface_normal);
   if (! (1 & loc_msg))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Get the range of the surface.  This is used to
 * determine the length of the vector drawn on
 * the screen.
 */
 {
  IGRboolean	status;
  IGRlong	loc_msg, total_poles;

  total_poles = surface->u_num_poles * surface->v_num_poles;
  status = BSbx2(
    &loc_msg,
    &total_poles,
    (IGRpoint *)surface->poles,
    (surface->rational ? surface->weights : NULL),
    &range[0],
    &range[3]);
   if (! status)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Finally, let's draw the vector
 */
 {
  void		EFdraw_vector_on_screen();
  IGRboolean	reverse_vector;
  IGRlong	loc_msg;

  reverse_vector = !natural_normal;
  EFdraw_vector_on_screen(
   my_stupid_id,
   display,
   display_env,
   (enum GRdpmode) (draw_background ? GRhd : GRhe),
   reverse_vector,
   point_on_surface,
   surface_normal,
   range,
   &loc_msg);
 }
/*
 * eof
 */
wrapup:
 if (1 & *msg)
  return(TRUE);
 else
  return(FALSE);
}

end implementation Root;
