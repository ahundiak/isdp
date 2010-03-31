/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This is the display constructions method
 for blend surface along natural edges.

 History

 12/11/87 : rlw : Creation date
 07/08/88 : rlw : Modified due to function name change is display iso curve
 */

class implementation ECblnd2srf;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"			/* Includes everything */

method display_constructions(
 IGRboolean	draw_background;
 IGRboolean	draw_single)

{
 IGRlong	i, alpha, omega, number_of_points, sts;
 IGRpoint	points[20];		/* A conservative estimate */
/*
 * Initialize
 */
 me->msg = MSSUCC;
/*
 * Set up the loop indices
 */
 omega = me->number_of_events_input;
 if (!omega) goto wrapup;		/* Degenerate case */
 if (draw_single)
  alpha = omega;
 else
  alpha = 1;
/*
 * Enter the loop
 */
 for (i = alpha; i <= omega; i++)
  {
   number_of_points = 0;
   EFextract_points(
    i,				/* me->number_of_events_input */
    me->events,
    points);
/*
 * Branch based on the command state
 */
   switch (i)
    {
     case 1:		/* Draw surface 1 */
     case 5:		/* Draw surface 2 */
/*    noop */
      break;
     case 2:		/* Draw the point and directional arrow */
     case 6:
      {
       IGRboolean	use_u_curve, is_curve_reversed;
       IGRlong		j;
       struct		GRlc_info *surface_lc_info;
       struct		GRlc_info *curve_lc_info;
       struct		GRid *curve_id;

       j = i - 1;
       number_of_points = 1;
       points[0][0] = points[j][0];
       points[0][1] = points[j][1];
       points[0][2] = points[j][2];
       surface_lc_info = &me->events[j - 1].located_object[0];
       curve_lc_info = &me->events[j].located_object[0];
       curve_id = &curve_lc_info->located_obj;
       curve_id->osnum = surface_lc_info->located_obj.osnum;
       switch (curve_lc_info->geom_parms.polygon_inx)
        {
         case BSULEFTBND:
         case BSURIGHTBND:
          use_u_curve = TRUE;
          break;
         default:
          use_u_curve = FALSE;
          break;
        }
       sts = EFdisplay_iso_curve_of_a_surface(
         surface_lc_info,
         &me->display,
         NULL,			/* Don't display it &me->display_env, */
         use_u_curve,
         &curve_lc_info->geom_parms.u,	/* uv coordinate */
         draw_background,
         FALSE,			/* Don't wait */
         my_id,
         &curve_id->objid,
         &me->msg);
        if (! (1 & sts)) return(OM_E_ABORT);
       if (surface_lc_info->geom_parms.polygon_inx)
        is_curve_reversed = FALSE;
       else
        is_curve_reversed = TRUE;
       curve_lc_info->module_info.md_env = surface_lc_info->module_info.md_env;
       sts = EFdisplay_curve_normal_or_tangent(
         curve_lc_info,		/* The curve */
         NULL,			/* Not used for tangents */
         FALSE,			/* Display the tangent vector */
         is_curve_reversed,
         my_id,
         draw_background ? GRbd : GRbe,
         &me->display_env,
         &me->display,
         &me->msg);
        if (! (1 & sts)) return(OM_E_ABORT);
       sts = om$send(
         msg = message Root.delete(0),
         targetid = curve_id->objid,
         targetos = curve_id->osnum);
        if (! (1 & sts)) return(OM_E_ABORT);
      }
      break;
     case 3:		/* Accepted or rejected displayed direction */
     case 7:		/* Ditto */
/*    noop; */
      break;
     case 4:		/* Got the direction point */
      number_of_points = 2;
      points[0][0] = points[1][0];
      points[0][1] = points[1][1];
      points[0][2] = points[1][2];
      points[1][0] = points[3][0];
      points[1][1] = points[3][1];
      points[1][2] = points[3][2];
      break;
     default:
      me->msg = MSFAIL;
      return(OM_E_ABORT);
    } /* switch (end) */
/*
 * Display my constructions
 */
   if (number_of_points)
    {
     IGRlong	sts, ECdisplayPointSetByBuffer();

     sts = ECdisplayPointSetByBuffer(
       &me->msg,
       me->display,
       me->display_env,
       my_id,
       number_of_points,
       points,
       draw_background);
      if (! (1 & sts))
       {
        me->msg = MSFAIL;
        return(OM_E_ABORT);
       }
    } /* if (number_of_points) */
  } /* for (i = start; i <= end; i++) */
/*
 * Eof
 */
wrapup:
 return(OM_S_SUCCESS);
}

end implementation ECblnd2srf;
