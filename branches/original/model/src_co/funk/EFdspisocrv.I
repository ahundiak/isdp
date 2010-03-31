/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This function extracts and displays an isoparametric curve of
 the input surface.  The extracted curve is created in the object space
 of the surface, is marked as non-locatable, and is not placed in the
 R-tree.  If desired, the curve is deleted (after displaying it) by
 this routine.

 Arguments

 lc_info		Surface locate information
 display		Active color, level, weight.
 display_env		Enviroment in which displays should take place,
                        if NULL then no display is performed.
 use_u_curve		U iso curve or V iso curve?
 uv_coordinate		U coordinate followed by V coordinate
 draw_background	Draw via GRbd or GRbe?
 wait_for_input		If TRUE then the curve is displayed in GRhhd,
                        the function waits for user input, then the
                        curve is erased.  If anyone intends to use this
                        option please see me (rlw) first.
 my_stupid_id		Caller's object id.
 curve_object_id	If pointer is NULL then the curve is not returned.
 msg			Error return code

 History

 11/16/87 : rlw : Creation date
 03/18/88 : rlw : Modified such that curve is constructed on the same level
                  as the surface.  Earlier I was using level 0 under the
                  assumption that level 0 is always displayed.
 07/08/88 : rlw : Added wait for input argument and changed function
                  name such that callers would be aware of this.
 07/26/88 : rlw : Removed function I put in bottom because Herman Tsai
                  added it to the system.
 11/28/88 : rlw : Modified due to changes in the iso curve method arguments.
 */
class implementation Root;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"			/* Includes everthing */

from EMSsubbs import EMisoparcvs;
from GRvg import GRgetsymb;
from GRgraphics import GRdisplay;

IGRlong EFdisplay_iso_curve_of_a_surface(
 lc_info,		/* The surface */
 display,		/* Active color, level, weight, etc. */
 display_env, 		/* Active display module */
 use_u_curve,		/* Display u iso curve? */
 uv_coordinate,		/* A u,v pair */
 draw_background,	/* Draw the curve in background, or erase */
 wait_for_input,	/* Draw, wait for input, then erase */
 my_stupid_id,		/* Your id */
 curve_object_id,	/* Returned curve object, if not NULL */
 msg)			/* Error return code */

struct		GRlc_info *lc_info;
struct		IGRdisplay *display;
struct		GRmd_env *display_env;
IGRboolean	use_u_curve;
BSpair		uv_coordinate;
IGRboolean	draw_background;
IGRboolean	wait_for_input;
OM_S_OBJID	my_stupid_id;
GRobjid		*curve_object_id;
IGRlong		*msg;
{
 OM_S_OBJID	constructed_object;
 IGRlong	sts;
 struct		GRvg_construct construct_list;
 struct		GRid *id;
 struct		GRmd_env md_env;
 struct		GRmdenv_info *mdenv_info;
 struct		IGRdisplay my_display;
/*
 * Initialize
 */
 *msg = MSSUCC;
 id = &lc_info->located_obj;
 mdenv_info = &lc_info->module_info.md_env;
 md_env = lc_info->module_info;
 md_env.md_id.objid = NULL_OBJID;
 my_display = *display;
 my_display.weight += 3;
/*
 * Setup the construct list
 */
 construct_list.msg = msg;
 construct_list.env_info = &md_env;
 construct_list.newflag = FALSE;
 construct_list.properties = GRIS_DISPLAYABLE;
 construct_list.geometry = NULL;
 construct_list.display = &my_display;
 construct_list.class_attr = NULL;
 construct_list.name = NULL;
/*
 * 3/18/88 - Logic to get the surfaces level
 */
 {
  struct	GRsymbology symbology;

  sts = om$send(
    msg = message GRvg.GRgetsymb(
     msg,
     &symbology),
    senderid = my_stupid_id,
    targetid = id->objid,
    targetos = id->osnum);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  construct_list.level = symbology.level;	/* Always displayed */
 }
/*
 * Extract the iso curve
 */
 {
  IGRlong	number_of_curves;
  GRobjid	*curves;

  curves = NULL;
  sts = om$send(
    msg = message EMSsubbs.EMisoparcvs(
     msg,
     &mdenv_info->matrix_type,
     mdenv_info->matrix,
     &construct_list,
     FALSE,			/* Ignore the boundaries */
     1,				/* Number of curves to get */
     (use_u_curve ? &uv_coordinate[0] : &uv_coordinate[1]),
     use_u_curve,
     &number_of_curves,
     &curves),
    senderid = my_stupid_id,
    targetid = id->objid,
    targetos = id->osnum);
   if (! ((1 & sts) && curves))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  constructed_object = curves[0];
  free(curves);
 }
/*
 * Display the iso curve, if desired
 */
 if (display_env)
  {
   enum		GRdpmode mode[2];
   IGRlong	count, i;

   if (wait_for_input)
    {
     count = 2;
     mode[0] = GRhhd;
     mode[1] = GRhe;
    }
   else
    {
     count = 1;
     mode[0] = (draw_background ? GRbd : GRbe);
    }
   for (i = 0; i < count; i++)
    {
     sts = om$send(
       msg = message GRgraphics.GRdisplay(
        msg,
        &mdenv_info->matrix_type,
        mdenv_info->matrix,
        &mode[i],
        &display_env->md_id),
       senderid = my_stupid_id,
       targetid = constructed_object,
       targetos = id->osnum);
      if (! (1 & sts)) goto wrapup;
     if (wait_for_input &&
         (i == 0))
      {
       extern	int EX_check_input();

       EX_check_input();
      }
    } /* for (i = 0; i < count; i++) */
  } /* if (display_env) */
/*
 * Return the constructed object, or delete it
 */
 if (curve_object_id)
  *curve_object_id = constructed_object;
 else
  {
   sts = om$send(
     msg = message Root.delete(0),
     senderid = my_stupid_id,
     targetid = constructed_object,
     targetos = id->osnum);
    if (! (1 & sts))
     {
      *msg = MSFAIL;
      goto wrapup;
     }
  }
/*
 * eof
 */
wrapup:
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}

end implementation Root;
