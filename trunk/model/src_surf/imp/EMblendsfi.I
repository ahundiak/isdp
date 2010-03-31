/* ###################   APOGEE COMPILED   ################## */
/*
 DESCRIPTION

 This method constructs a surface which blends 2 existing surfaces
 along interior curves lying on the surfaces.

 RETURN VALUES

 construct_list->msg    MSSUCC - successfull
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated

 NOTES

 This object will delete itself if an error occurs.

 HISTORY


 05/19/87 : dhm : creation date
 07/21/87 : dhm : deallocated curve memory.
 11/18/87 : rlw : Rewritten, renamed, and moved method to class EMSgenbs

 */

class implementation EMSgenbs;

#include "EMS.h"

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"			/* Includes the world */

method EMblend_surface_interior(
 struct GRlc_info	*surface_1;
 struct GRlc_info	*curve_1;
 IGRvector 		blend_direction_1;
 IGRshort		alignment_1;
 struct GRlc_info	*surface_2;
 struct GRlc_info	*curve_2;
 IGRvector 		blend_direction_2;
 IGRshort		alignment_2;
 struct GRvg_construct	*construct_list)
{
  extern  void		BSblend_sfi();
 IGRlong        msg, loc_msg, sts;
 IGRlong	EMget_the_geometry();
 struct		IGRbsp_curve *curve1, *curve2;
 struct		IGRbsp_surface *surface1, *surface2;
 struct		IGRbsp_surface *blending_surface;
/*
 * Initialize
 */
 msg = MSSUCC;
 curve1 = NULL;
 curve2 = NULL;
 surface1 = NULL;
 surface2 = NULL;
 blending_surface = NULL;
/*
 * Get the geometries of the various
 * entities
 */
 sts = EMget_the_geometry(
   surface_1,
   FALSE,			/* Is a curve? */
   NULL,			/* Is directed curve? */
   FALSE,			/* Separate mallocs? */
   my_id,
   &surface1,			/* The geometry */
   &msg);
  if (! (1 & sts))
   {
    surface1 = NULL;
    goto wrapup;
   }
 sts = EMget_the_geometry(
   surface_2,
   FALSE,			/* Is a curve? */
   NULL,			/* Is directed curve? */
   FALSE,			/* Separate mallocs? */
   my_id,
   &surface2,			/* The geometry */
   &msg);
  if (! (1 & sts))
   {
    surface2 = NULL;
    goto wrapup;
   }
 sts = EMget_the_geometry(
   curve_1,
   TRUE,			/* Is a curve? */
   TRUE,			/* Is directed curve? */
   TRUE,			/* Separate mallocs? */
   my_id,
   &curve1,			/* The geometry */
   &msg);
  if (! (1 & sts))
   {
    curve1 = NULL;
    goto wrapup;
   }
 sts = EMget_the_geometry(
   curve_2,
   TRUE,			/* Is a curve? */
   TRUE,			/* Is directed curve? */
   TRUE,			/* Separate mallocs? */
   my_id,
   &curve2,			/* The geometry */
   &msg);
  if (! (1 & sts))
   {
    curve2 = NULL;
    goto wrapup;
   }
/*
 * Call the math
 */
 BSblend_sfi(
   surface1,
   curve1,
   blend_direction_1,
   alignment_1,
   surface2,
   curve2,
   blend_direction_2,
   alignment_2,
   &blending_surface,
   &loc_msg);
  if (loc_msg != BSSUCC)
   {
    blending_surface = NULL;
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
 if (surface1) free(surface1);
 if (surface2) free(surface2);
 if (curve1) BSfreecv(&loc_msg, curve1);
 if (curve2) BSfreecv(&loc_msg, curve2);
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
