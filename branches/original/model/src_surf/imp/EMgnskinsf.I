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

 rlw    10/25/89 : The beginning.  Took method EMmove_cross_section() and
                   mauled it.
 */

class implementation EMSgenbs;

#include "EMS.h"
#include <stdio.h>
#include "bserr.h"
#include "msdef.h"     /* MSINARG ... */
#include "maerr.h"
#include "godef.h"

method EMplace_skinning_surface(
 IGRlong *msg; 
 struct GRvg_construct *construct_list;
 IGRlong num_trace;
 struct GRlc_info trcobj[];
 IGRlong num_cross;
 struct GRlc_info crsobj[];
 IGRboolean surface_is_open;
 struct GRlc_info tangent_surfaces[4];
 IGRboolean absolute_orientation;
 IGRboolean no_height_scaling;
 struct IGRbsp_curve *shape_law;
 struct IGRbsp_curve *orient_law)
{
 extern		IGRlong EMget_the_geometry();
 IGRboolean     arclnpar=FALSE;
 IGRlong	sts, i;
 struct		IGRbsp_curve **cross_sections, **trace_curves;
 struct		IGRbsp_surface *tangent_sf[4], *surface;
/*
 * Initialize
 */

/*
 * If the incoming message is set to EMS_I_ArcLenPar then it is assumed that
 * the request is to parametrize the sections/traces via arclength.
 */

 if (*msg == EMS_I_ArcLenPar)
  arclnpar = TRUE;

 *msg = MSSUCC;
 cross_sections = NULL;
 trace_curves = NULL;
 tangent_sf[0] = NULL;
 tangent_sf[1] = NULL;
 tangent_sf[2] = NULL;
 tangent_sf[3] = NULL;
 surface = NULL;
/*
 * Input validation
 */
 if ((num_trace < 1) ||
     (num_cross < 1) ||
     ((num_trace > 2) && (num_cross < 2)))
  {
   *msg = MSINARG;
   goto wrapup;
  }
/*
 * Allocate space for the cross sections
 */
 cross_sections = (struct IGRbsp_curve **) malloc(
   (num_cross + 1) * sizeof(struct IGRbsp_curve *));
  if (!cross_sections)
   {
    *msg = MANOMEMORY;
    goto wrapup;
   }
 for (i = 0; i <= num_cross; i++) cross_sections[i] = NULL;
/*
 * Get the curve defintion for the cross sections
 */
 for (i = 0; i < num_cross; i++)
  {
   sts = EMget_the_geometry(
     &crsobj[i],
     TRUE,
     TRUE,
     FALSE,
     my_id,
     &cross_sections[i],
     msg);
    if (! (1 & sts)) goto wrapup;

    if (arclnpar)
    {
     BSarclnparc(msg,cross_sections[i]);
     EMerr_hndlr((*msg != BSSUCC), *msg, MSFAIL, wrapup);
    }

  } /* for (i = 0; i < num_cross; i++) */
 if ((num_cross > 1) &&
     (! surface_is_open))
  {
   sts = EMget_the_geometry(
     &crsobj[0],
     TRUE,
     TRUE,
     FALSE,
     my_id,
     &cross_sections[num_cross],
     msg);
    if (! (1 & sts)) goto wrapup;
    if (arclnpar)
    {
     BSarclnparc(msg,cross_sections[num_cross]);
     EMerr_hndlr((*msg != BSSUCC), *msg, MSFAIL, wrapup);
    }
   num_cross++;
  } /* if ((num_cross > 1) && (! surface_is_open)) */
/*
 * Allocate space for the trace curves
 */
 trace_curves = (struct IGRbsp_curve **) malloc(
   (num_trace + 1) * sizeof(struct IGRbsp_curve *));
  if (!trace_curves)
   {
    *msg = MANOMEMORY;
    goto wrapup;
   }
 for (i = 0; i <= num_trace; i++) trace_curves[i] = NULL;
/*
 * Get the trace curves
 */
 for (i = 0; i < num_trace; i++)
  {
   sts = EMget_the_geometry(
     &trcobj[i],
     TRUE,
     TRUE,
     FALSE,
     my_id,
     &trace_curves[i],
     msg);
    if (! (1 & sts)) goto wrapup;
    if (arclnpar)
    {
     BSarclnparc(msg,trace_curves[i]);
     EMerr_hndlr((*msg != BSSUCC), *msg, MSFAIL, wrapup);
    }
  } /*  for (i = 0; i < num_trace; i++) */
/*
 * Get the supporting tangent surfaces
 */
 if (tangent_surfaces)
  {
   for (i = 0; i < 4; i++)
    {
     if (tangent_surfaces[i].located_obj.objid != NULL_OBJID)
      {
       sts = EMget_the_geometry(
         &tangent_surfaces[i],
         FALSE,
         FALSE,
         FALSE,
         my_id,
         &tangent_sf[i],
         msg);
        if (! (1 & sts)) goto wrapup;
      } /* if (tangent_surfaces[i].located_obj.objid != NULL_OBJID) */
    } /* for (i = 0; i < 4; i++) */
  } /* if (tangent_surfaces) */
/*
 * Get the surface definition
 */
 {
  extern	void BSmvxsectrc();
  IGRlong	loc_msg;

  BSmvxsectrc(
    num_trace,
    trace_curves,
    num_cross,
    cross_sections,
    TRUE,                     /* on site */
    ! no_height_scaling,
    NULL,                     /* trace parameters */
    absolute_orientation,
    NULL,                     /* view matrix */
    NULL,                     /* origins */
    NULL,                     /* x axis */
    NULL,                     /* y axis */
    FALSE,                    /* constant direction */
    ! surface_is_open,
    shape_law,
    &shape_law,
    orient_law,
    &orient_law,
    tangent_sf[0],
    tangent_sf[1],
    tangent_sf[2],
    tangent_sf[3],
    &surface,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     fprintf(stderr, "\nBSmvxsectrc error %d", loc_msg);
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
   for (i = 0; i < num_cross; i++) 
    {
     if (cross_sections[i]) free(cross_sections[i]);
    }
   free(cross_sections);
  }
 if (trace_curves)
  {
   for (i = 0; i < num_trace; i++) 
    {
     if (trace_curves[i]) free(trace_curves[i]);
    }
   free(trace_curves);
  }
 for (i = 0; i < 4; i++)
  {
   if (tangent_sf[i]) free(tangent_sf[i]);
  }
 if (surface)
  {
   extern	IGRboolean BSfreesf();
   IGRboolean	status;
   IGRlong	loc_msg;

   status = BSfreesf(
    &loc_msg, 
    surface);
  }
 *(construct_list->msg) = *msg;
 if (1 & *msg)
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
