/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method creates a surface by performing a direct fit
 on an input set of curves.

 History

 ??/??/?? : ??? : I think Govinda originally wrote this but I rewrote
                  it sometime in the past.
 06/17/88 : rlw : Fixed a problem in periodic case.  I was not putting
                  the last curve in the proper place.
 */

class implementation EMSgenbs;

#include "EMS.h"
#include "bserr.h"
#include "msdef.h"
#include "maerr.h"
#include "godef.h"

method EMdirect_fit_surface_by_curves(
 IGRlong	v_order;
 IGRboolean	v_periodic;
 IGRlong	number_of_cross_sections;
 struct		GRlc_info cs[];
 struct		GRvg_construct *construct_list)
{
 extern  IGRboolean  BSfreesf();
 extern  IGRboolean  BSfreecv();
 extern  IGRboolean  BSfreesf();
 IGRboolean status;
 IGRlong    sts, loc_msg, i, *msg;
 struct     IGRbsp_curve **cross_sections, **trace_curves;
 struct     IGRbsp_surface *surface;
/*
 * Initialize
 */
 msg = construct_list->msg;
 *msg = MSSUCC;
 cross_sections = NULL;
 trace_curves = NULL;
 surface = NULL;
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
 * Add a curve, if periodic in v
 */
 if (v_periodic)
  {
   sts = EMget_the_geometry(
     &cs[0],
     TRUE,
     TRUE,
     TRUE,
     my_id,
     &cross_sections[number_of_cross_sections],
     msg);
    if (! (1 & sts)) goto wrapup;
   number_of_cross_sections++;
  }
/*
 * Allocate space for the compatible cross sections
 */
 trace_curves = (struct IGRbsp_curve **) malloc(
   number_of_cross_sections * sizeof(struct IGRbsp_curve *));
  if (!trace_curves)
   {
    *msg = MANOMEMORY;
    goto wrapup;
   }
 for (i = 0; i < number_of_cross_sections; i++) trace_curves[i] = NULL;
/*
 * Make all the input curves compatible
 */
 {
  extern   void		BSmkcvscp();
  IGRlong	loc_msg;

  BSmkcvscp(
    number_of_cross_sections,
    cross_sections,
    trace_curves,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Malloc the surface
 */
 {
  extern   void		BSallocsf();
  IGRlong	loc_msg, v_num_poles;

  v_num_poles = number_of_cross_sections + v_order - 1;
  BSallocsf(
    trace_curves[0]->order,
    v_order,
    trace_curves[0]->num_poles,
    v_num_poles,
    trace_curves[0]->rational,
    0,
    &surface,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  surface->v_order = v_order;
  surface->v_periodic = v_periodic;
 }
/*
 * Get the surface definition
 */
 {
  extern   void		BSsfthrcvs();
  IGRlong	loc_msg;

  BSsfthrcvs(
    number_of_cross_sections,
    trace_curves,
    0,
    surface,
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
 sts = om$send(mode = OM_e_wrt_object,
               msg = message GRgraphics.GRconstruct(
                construct_list),
               senderid = my_id,
               targetid = my_id);
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
     if (trace_curves &&
         trace_curves[i])   status = BSfreecv(&loc_msg, trace_curves[i]);
    }
   free(cross_sections);
   if (trace_curves) free(trace_curves);
  }
 if (surface) status = BSfreesf(&loc_msg, surface);
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
