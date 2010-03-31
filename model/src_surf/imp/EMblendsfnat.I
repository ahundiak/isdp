/* ###################   APOGEE COMPILED   ################## */
/*
DESCRIPTION

This method constructs a surface which blends 2 existing surfaces
along their natural sides taking into account the continuity order
w.r.t the existing surfaces.

RETURN VALUES

construct_list->msg    MSSUCC - successfull
		MSFAIL - if failure
		MANOMEMORY - if no memory could be allocated

NOTES

This object will delete itself if an error occurs.

HISTORY

08/17/92 : Rustagi : Created this file to provide implementation for the
                     new defined message 'EMblend_surf_nat' which takes
                     continuity order besides other parameters to place 
                     the blend surface along the natural boundaries of the
                     existing surfaces. Most of the code is taken from
                     'EMblendsfe.I'. The code has been added to allocate
                     memory for the blending surface and new math function
                     'BSbln2sfcn2()' has been called.
07/06/93   Sudha     Modified for BSprototypes ansification
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
#include "bsbln2sfcn2.h"
#include "bsallocsf.h"
#include "madef.h"

method EMblend_surf_nat(
 struct GRlc_info	*surface_1;
 IGRshort		side_1;
 IGRboolean		is_side_reversed_1;
 IGRpoint 		blend_direction_1;
 IGRint                 conti1;
 IGRdouble               ratio1;
 struct GRlc_info	*surface_2;
 IGRshort		side_2;
 IGRboolean		is_side_reversed_2;
 IGRpoint 		blend_direction_2;
 IGRint                 conti2;
 IGRdouble               ratio2;
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
  IGRlong         ord1, ord2, ord, blend_u_order, blend_v_order;
  IGRlong         np1, np2, blend_u_num_poles, blend_v_num_poles;  

  blend_v_order     = conti1 + conti2 + 2;
  blend_v_num_poles = blend_v_order;

  if ((side_1 == BSULEFTBND) || (side_1 == BSURIGHTBND))
   {
    ord1 = surface1->v_order;
    np1  = surface1->v_num_poles;
   }
  else
   {
    ord1 = surface1->u_order;
    np1  = surface1->u_num_poles;
   }
  if ((side_2 == BSULEFTBND) || (side_2 == BSURIGHTBND))
   {
    ord2 = surface2->v_order;
    np2  = surface2->v_num_poles;
   }
  else
   {
    ord2 = surface2->u_order; 
    np2  = surface2->u_num_poles;
   }

  ord = MAmaximum(ord1, ord2);
  blend_u_order = ord;
  blend_u_num_poles = (np1 + np2 + ord) * (ord - 1); 

  BSallocsf(
     blend_u_order,
     blend_v_order,
     blend_u_num_poles,
     blend_v_num_poles,
     (surface1->rational || surface2->rational),
     0,               /* num boundaries */
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

  BSbln2sfcn2(
     surface1,
     side_1,
     conti1,
     ratio1,
     surface2,
     side_2,
     conti2,
     ratio2,
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
