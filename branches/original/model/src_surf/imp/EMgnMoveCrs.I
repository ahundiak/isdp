/* ###################   APOGEE COMPILED   ################## */
/*
 DESCRIPTION

 This method creates a surface which passes through the input cross
 section curves.  The curves are moved along the trace in order to
 form this surface.  Refer to the specification file for further details.

 RETURN VALUES

 construct_list->msg    MSSUCC - successfull
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated
                        MSINARG - if invalid number of traces and/or
                          cross sectional curves
                        GRSNOINVTRAN - if input matrix is not invertible
                        GRSDGNEXCEED - if range exceeds design limits

 msg                    same as construct_list->msg

 NOTES

 This object will delete itself if an error occurs.
 The resulting surface is reparameterized.

 HISTORY

 gupta  10/06/86 : The beginning
 rlw    01/08/87 : Modified to free resulting surface
 rlw    03/05/87 : Reworked
 rlw    09/21/87 : Modified to reparameterize and documented.
                   Also fixed a bug whereby some memory was not being freed.
                   Also changed getgeom stuff to use genabsg.
 rlw    10/07/87 : Remove reparameterize logic and put in the construct method.
 rlw	04/26/88 : Modified to use different information to determine whether
                   or not to reverse the incoming curves.
 */

class implementation EMSgenbs;

#include "EMS.h"
#include "bserr.h"
#include "msdef.h"     /* MSINARG ... */
#include "maerr.h"
#include "godef.h"

method EMmove_cross_section(
 IGRlong *msg; 
 struct GRvg_construct *construct_list;
 IGRlong number_of_cross_sections;
 struct GRlc_info cs[];
 IGRlong number_of_trace_curves;
 struct GRlc_info tr[];
 IGRboolean is_scaling_desired;
 IGRboolean are_sections_on_site;
 IGRpoint cross_section_origins[];
 IGRdouble *rotation_matrix;
 IGRpoint x_direction_point, y_direction_point)
{
 extern  void  BSmove_crs();
  extern  void       BSskndsf();
 extern  IGRboolean  BSfreesf();
 extern  IGRboolean  BSfreecv();
 extern  IGRboolean  BSfreesf();
 IGRboolean status;
 IGRlong    sts, loc_msg, i;
 struct     IGRbsp_curve **cross_sections, **trace_curves;
 struct     IGRbsp_surface *surface;
/*
 * Initialize
 */
 *msg = MSSUCC;
 cross_sections = NULL;
 trace_curves = NULL;
 surface = NULL;
/*
 * Input validation
 */
 if ((number_of_trace_curves < 1) ||
     (number_of_trace_curves > 2) ||
     (number_of_cross_sections < 1) ||
     (!are_sections_on_site && (number_of_cross_sections > 2)))
  {
   *msg = MSINARG;
   goto wrapup;
  }
/*
 * Allocate space for the cross sections
 */
 cross_sections = (struct IGRbsp_curve **) malloc(
   (number_of_cross_sections + 1) * sizeof(struct IGRbsp_curve *));
  if (!cross_sections)
   {
    *msg = MANOMEMORY;
    goto wrapup;
   }
 for (i = 0; i <= number_of_cross_sections; i++) cross_sections[i] = NULL;
/*
 * Get the curve defintion for the cross sections
 */
 for (i = 0; i < number_of_cross_sections; i++)
  {
   sts = EMget_the_geometry(
     &cs[i],
     TRUE,
     TRUE,
     TRUE,
     my_id,
     &cross_sections[i],
     msg);
    if (! (1 & sts)) goto wrapup;
  } /* for (i = 0; i < number_of_cross_sections; i++) */
/*
 * Allocate space for the cross sections
 */
 trace_curves = (struct IGRbsp_curve **) malloc(
   (number_of_trace_curves + 1) * sizeof(struct IGRbsp_curve *));
  if (!trace_curves)
   {
    *msg = MANOMEMORY;
    goto wrapup;
   }
 for (i = 0; i <= number_of_trace_curves; i++) trace_curves[i] = NULL;
/*
 * Get the trace curves
 */
 for (i = 0; i < number_of_trace_curves; i++)
  {
   sts = EMget_the_geometry(
     &tr[i],
     TRUE,
     TRUE,
     TRUE,
     my_id,
     &trace_curves[i],
     msg);
    if (! (1 & sts)) goto wrapup;
  } /*  for (i = 0; i < number_of_trace_curves; i++) */
/*
 * Get the surface definition
 */
 if (are_sections_on_site && (number_of_cross_sections > 2))
  {
   BSskndsf(
     trace_curves,
     cross_sections,
     number_of_cross_sections,
     is_scaling_desired,
     &surface,
     &loc_msg);
    if (loc_msg != BSSUCC)
     {
      *msg = MSFAIL;
      goto wrapup;
     }
  }
 else
  {
   BSmove_crs(
     cross_sections[0], 
     cross_sections[1], 
     trace_curves[0], 
     trace_curves[1], 
     is_scaling_desired,
     are_sections_on_site, 
     rotation_matrix, 
     cross_section_origins[0], 
     cross_section_origins[1],
     x_direction_point, 
     y_direction_point,
     &surface, 
     &loc_msg);
    if (loc_msg != BSSUCC)
     {
      *msg = MSFAIL;
      goto wrapup;
     }
  }
/*
 * Fill the instance data
 */
 construct_list->geometry = (IGRchar *) surface;
 sts = om$send(
   msg = message GRgraphics.GRconstruct(
   construct_list),
  targetid = my_id);
 *msg = *(construct_list->msg);
  if (!(1 & sts)) goto wrapup;
/*
 * End of routine
 */
wrapup:
 if (cross_sections)
  {
   for (i = 0; i < number_of_cross_sections; i++) 
    {
     if (cross_sections[i]) status = BSfreecv(&loc_msg, cross_sections[i]);
    }
   free(cross_sections);
  }
 if (trace_curves)
  {
   for (i = 0; i < number_of_trace_curves; i++) 
    {
     if (trace_curves[i]) status = BSfreecv(&loc_msg, trace_curves[i]);
    }
   free(trace_curves);
  }
 if (surface) status = BSfreesf(&loc_msg, surface);
 *(construct_list->msg) = *msg;
 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  {
   sts = om$send(mode = OM_e_wrt_object,
                 msg = message Root.delete(1),
                 senderid = my_id,
                 targetid = my_id);
   return(OM_E_ABORT);
  }
}

end implementation EMSgenbs;
