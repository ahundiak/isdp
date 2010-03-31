/* ###################   APOGEE COMPILED   ################## */
/*
 DESCRIPTION

 This method constructs a surface which blends 2 existing surfaces
 along their natural sides.

 RETURN VALUES

 construct_list->msg    MSSUCC - successfull
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated

 NOTES

 This object will delete itself if an error occurs.

 HISTORY

 10/14/86 : pp  : Design date.
 10/22/86 : pp  : Change made to the allocation of memory for
                  the abstract geometries to permit
                  reallocation in the math routine.
 12/23/86 : rlw : Change to allocate weights when rational.
 07/15/87 : aic : Do not generate element specific attributes.
 11/18/87 : rlw : Rewritten, renamed, and moved method to class EMSgenbs
 12/11/87 : rlw : Was calling reverse u when I should have been calling
                  reverse v and visa versa.
 04/20/90 : RC  : Modification to the calculation of num_poles of 
                  the blended surface. See comments
 07/06/93  Sudha  Modified for BSprototypes ansification
 */

class implementation EMSgenbs;

#include "EMS.h"

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"			/* Includes the world */
#include "bsrevsf_v.h"
#include "bsrevsf_u.h"
#include "bsfreesf.h"
#include "bsblend_sfe.h"
#include "bsallocsf.h"
#include "madef.h"

method EMblend_surface(
 struct GRlc_info	*surface_1;
 IGRshort		side_1;
 IGRboolean		is_side_reversed_1;
 IGRpoint 		blend_direction_1;
 struct GRlc_info	*surface_2;
 IGRshort		side_2;
 IGRboolean		is_side_reversed_2;
 IGRpoint 		blend_direction_2;
 struct GRvg_construct	*construct_list)
{
 IGRlong        msg, loc_msg, sts;
 IGRlong	EMget_the_geometry();
 struct		IGRbsp_surface *surface1, *surface2;
 struct		IGRbsp_surface *blending_surface;
/*
 * Initialize
 */
 msg = MSSUCC;
 surface1 = NULL;
 surface2 = NULL;
 blending_surface = NULL;
/*
 * Get the first surface
 */
 sts = EMget_the_geometry(
   surface_1,
   FALSE,			/* Is a curve? */
   NULL,			/* Is directed curve? */
   TRUE,			/* Separate mallocs? */
   my_id,
   &surface1,			/* The geometry */
   &msg);
  if (! (1 & sts))
   {
    surface1 = NULL;
    goto wrapup;
   }
/*
 * Reverse surface 1, if required
 */
 if (is_side_reversed_1)
  {
   IGRboolean	status;

   if ((side_1 == BSULEFTBND) ||
       (side_1 == BSURIGHTBND))
    status = BSrevsf_v(
      &loc_msg,
      surface1);
   else
    status = BSrevsf_u(
      &loc_msg,
      surface1);
   if (!status)
    {
     msg = MSFAIL;
     goto wrapup;
    }
  }
/*
 * Get the second surface
 */
 sts = EMget_the_geometry(
   surface_2,
   FALSE,			/* Is a curve? */
   NULL,			/* Is directed curve? */
   TRUE,			/* Separate mallocs? */
   my_id,
   &surface2,			/* The geometry */
   &msg);
  if (! (1 & sts))
   {
    surface2 = NULL;
    goto wrapup;
   }
/*
 * Reverse surface 2, if required
 */
 if (is_side_reversed_2)
  {
   IGRboolean	status;

   if ((side_2 == BSULEFTBND) ||
       (side_2 == BSURIGHTBND))
    status = BSrevsf_v(
      &loc_msg,
      surface2);
   else
    status = BSrevsf_u(
      &loc_msg,
      surface2);
   if (!status)
    {
     msg = MSFAIL;
     goto wrapup;
    }
  }
/*
 * Allocate space for the blending surface
 */
 {
  IGRlong	order1, order2, v_order;
  IGRlong	num_poles1, num_poles2, v_num_poles;

  order1 = MAmaximum(surface1->u_order, surface1->v_order);
  order2 = MAmaximum(surface2->u_order, surface2->v_order);
  v_order = MAmaximum(order1, order2);
  num_poles1 = MAmaximum(surface1->u_num_poles, surface1->v_num_poles);
  num_poles2 = MAmaximum(surface2->u_num_poles, surface2->v_num_poles);
  v_num_poles = 2 * MAmaximum(num_poles1, num_poles2) + v_order;

  /*
   * Added the following statement -- RC  4/20/90
   */

  v_num_poles = (v_order - 1) * v_num_poles;

  BSallocsf(
    4,				/* u order */
    v_order,
    4,				/* u num poles */
    v_num_poles,
    (surface1->rational || surface2->rational),
    0,				/* num boundaries */
    &blending_surface,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     msg = MANOMEMORY;
     blending_surface = NULL;
     goto wrapup;
    }
 }
/*
 * Call the math
 */
 BSblend_sfe(
   surface1,
   side_1,
   blend_direction_1,
   surface2,
   side_2,
   blend_direction_2,
   blending_surface,
   &loc_msg);
  if (loc_msg != BSSUCC)
   {
    msg = MSFAIL;
    goto wrapup;
   }
/*
 * Fill the instance data and such
 */
 construct_list->geometry = (IGRchar *) blending_surface;
 sts = om$send(
   msg = message GRgraphics.GRconstruct(construct_list),
   targetid = my_id);
 if (!(1 & sts))
  {
   msg = *(construct_list->msg);
   goto wrapup;
  }
/*
 * End of routine
 */
wrapup:
 *(construct_list->msg) = msg;
 if (surface1) BSfreesf(&loc_msg, surface1);
 if (surface2) BSfreesf(&loc_msg, surface2);
 if (blending_surface) BSfreesf(&loc_msg, blending_surface);
 if (1 & msg)
  return(OM_S_SUCCESS);
 else
  {
   sts = om$send(
    msg = message Root.delete(1),
    targetid = my_id);
   return(OM_E_ABORT);
  }
}

end implementation EMSgenbs;
