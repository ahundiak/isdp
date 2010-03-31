/* ###################   APOGEE COMPILED   ################## */
/* 
DESCRIPTION

  This method creates a surface which passes through a network of curves.
  There must be at least four curves by two curves or two curves by four
  curves present.  If any of the input curves are rational then they
  are approximated by stroking them to a fixed number of points by the math
  routine.  The curves should intersect each other at the junction/network
  points.  The input curves must be input in the following order:

                -------> u
            v0     v1      v2      v3
     |  u0  ------------------------
     |      |       |       |      |
     |  u1  |-------|-------|------|
     v      |       |       |      |
        u2  |-------|-------|------|
     v      |       |       |      |
        u3  ------------------------
          
RETURN VALUES

   msg                  MSSUCC if sucess
                        MSINARG if insufficent number of curves input
                        MANOMEMORY if no memory
                        MSFAIL if severe problems (best to
                        abort), note that this most likely
                        implies coding, algorithm, or math
                        problems

HISTORY

   04/17/87 : rlw : creation date
   07/16/87 : rlw : Removed restriction on a min. of 4 curves.  Now it is 2.
   12/19/87 : rlw : Modified to use polygon_inx to determine if curves are
                    reversed or not
 */

class implementation EMSgenbs;

#include "EMS.h"
#include "bserr.h"
#include "msdef.h"
#include "maerr.h"
#include "godef.h"

method EMnetwork_of_curves(
 IGRlong *msg; 
 struct GRvg_construct *arglist;
 IGRlong number_of_cross_sections;
 struct GRlc_info cs[];
 IGRlong number_of_trace_curves;
 struct GRlc_info tr[])
{
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
 if ((number_of_trace_curves < 2) ||
     (number_of_cross_sections < 2))
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
 BSsfnetcvs(
   number_of_cross_sections,
   cross_sections,
   number_of_trace_curves,
   trace_curves,
   &surface,
   &loc_msg);
  if (loc_msg != BSSUCC)
   {
    *msg = MSFAIL;
    goto wrapup;
   }
/*
 * Fill the instance data
 */
 arglist->geometry = (IGRchar *) surface;
 sts = om$send(mode = OM_e_wrt_object,
               msg = message GRgraphics.GRconstruct(
                arglist),
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
