/* ###################   APOGEE COMPILED   ################## */
/* 
DESCRIPTION

   This method constructs a surface by moving a cross section curve
   along a trace curve which lies on the input surface.  The cross
   section is moved such that remains normal to the input surface. 
   For this routine the cross section must be "on view".  See EMSgenbs.S
   for explanation of the arguments.

HISTORY

   04/15/87 : rlw : creation date
   11/17/89 : rlw : Added argument and renamed.
  
   VDS Overwrite correction:
   03/13/98 : adz : Add Warning checking for bspmath routine correction to
		    support placement of cross-section over cusps 
		    Function BSmvcsnsfvc is also changed for this.
		    TR179800658 & TR179800722.
 */

class implementation EMSgenbs;

#include "EMS.h"
#include <stdio.h>
#include "madef.h"
#include "msdef.h"
#include "bserr.h"
#include "emsgetgeom.h"

method EMmove_cross_section_normal_to_sf(
 IGRlong *msg;                          /* Error return code */
 IGRboolean *was_curve_on_surface;      /* Was trace curve on surface? */
 struct GRvg_construct *arglist;        /* Construct information */
 struct GRlc_info *surface_object;      /* The drive surface */
 struct GRlc_info *trace_object;        /* The trace curve */
 struct GRlc_info *cross_section_object;/* The cross section */
 IGRpoint side_pnt;                     /* Which side of surface? */
 IGRpoint ref_pnt;                      /* w.r.t. cross section */
 IGRboolean is_left_hand_system;        /* Which mirror? */
 IGRdouble *rotation_matrix;            /* View matrix */
 IGRpoint vector_pnts[2];               /* X axis vector */
 IGRpoint absolute_pnts[2])             /* Another X axis vector */
{
 extern		void BSalloccv();
 extern		IGRboolean BSfreesf(), BSfreecv(), BSdirectcv();
 IGRboolean     status;
 IGRlong        sts, loc_msg;
 struct         IGRbsp_curve *trace_curve, *cross_section_curve;
 struct         IGRbsp_curve *reversed_trace_curve;
 struct         IGRbsp_surface *surface, *drive_surface;
/*
 * Initialize
 */
 surface = NULL;
 drive_surface = NULL;
 trace_curve = NULL;
 reversed_trace_curve = NULL;
 cross_section_curve = NULL;
/*
 * Get the geometry of the input objects
 */
 EMS_GET_GEOMETRY(sts, msg, surface_object, FALSE, drive_surface)
  if (!(1 & sts)) goto wrapup;
 EMS_GET_GEOMETRY(sts, msg, trace_object, TRUE, trace_curve)
  if (!(1 & sts)) goto wrapup;
 EMS_GET_GEOMETRY(sts, msg, cross_section_object, TRUE, cross_section_curve)
  if (!(1 & sts)) goto wrapup;
/*
 * We may need to reverse the trace curve since the math computes the matrices
 * at the beginning of the trace.
 */
 BSalloccv(trace_curve->order, 
           trace_curve->num_poles,
           trace_curve->rational,
           0,
           &reversed_trace_curve,
           &loc_msg);
  if (loc_msg != BSSUCC)
   {
    *msg = MANOMEMORY;
    goto wrapup;
   }
 status = BSdirectcv(&loc_msg,
                     trace_object->proj_pnt,
                     trace_curve,
                     reversed_trace_curve);
  if ((!status) || (loc_msg != BSSUCC))
   {
    *msg = MSFAIL;
    goto wrapup;
   }
/*
 * Get the surface definition
 */
 {
  extern	void BSmvcsnsfvc();
  IGRboolean	absolute_orientation;
  IGRvector     x_axis_vector, other_vector;

  x_axis_vector[0] = vector_pnts[1][0] - vector_pnts[0][0];
  x_axis_vector[1] = vector_pnts[1][1] - vector_pnts[0][1];
  x_axis_vector[2] = vector_pnts[1][2] - vector_pnts[0][2];
  if (absolute_pnts)
   {
    absolute_orientation = TRUE;
    other_vector[0] = absolute_pnts[1][0] - absolute_pnts[0][0];
    other_vector[1] = absolute_pnts[1][1] - absolute_pnts[0][1];
    other_vector[2] = absolute_pnts[1][2] - absolute_pnts[0][2];
   } /* if (absolute_pnts) */
  else
   absolute_orientation = FALSE;
  BSmvcsnsfvc(
   drive_surface,
   side_pnt,
   reversed_trace_curve,
   cross_section_curve,
   ref_pnt,
   rotation_matrix,
   x_axis_vector,
   (is_left_hand_system ? FALSE : TRUE),
   absolute_orientation,
   other_vector,
   &surface,
   &was_curve_on_surface,
   &loc_msg);
   if( loc_msg != BSSUCC ){
     if( loc_msg != BSWARN ){
       *msg = MSFAIL;
       goto wrapup;
     }
   }
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
 if (drive_surface) free(drive_surface);
 if (trace_curve) free(trace_curve);
 if (reversed_trace_curve) status = BSfreecv(&loc_msg, reversed_trace_curve);
 if (cross_section_curve) free(cross_section_curve);
 if (surface) status = BSfreesf(&loc_msg, surface);
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
/*
   This routine is used to support the command object.  It returns matrices
   suitable for displaying the cross section on site.
 
   04/15/87 : rlw : creation date
   11/17/89 : rlw : Added argument
 */
IGRboolean EFskinning_matrix_support(
 my_id, 
 surface_object,
 trace_object,
 cross_section_object,
 side_pnt,
 ref_pnt,
 view_matrix,
 vector_pnts,
 absolute_pnts,
 cross_section_matrix,
 rhs_matrix,
 lhs_matrix,
 msg)

OM_S_OBJID      my_id;
struct          GRlc_info *surface_object;
struct          GRlc_info *trace_object;
struct          GRlc_info *cross_section_object;
IGRpoint        side_pnt;
IGRpoint        ref_pnt;
IGRdouble       view_matrix[4][4];
IGRpoint        vector_pnts[2];
IGRpoint	absolute_pnts[2];
IGRdouble       cross_section_matrix[4][4];
IGRdouble       rhs_matrix[4][4];
IGRdouble       lhs_matrix[4][4];
IGRlong         *msg;

{
 extern		void BSalloccv(), BSortcvsfvc();
 extern		IGRboolean BSfreecv(), BSdirectcv();
 IGRboolean     status, absolute_orientation;
 IGRlong        sts, loc_msg, i, j;
 IGRdouble      stupid_matrix[3][3];
 IGRdouble      rhs_view_to_site_matrix[3][3], lhs_view_to_site_matrix[3][3];
 IGRvector      x_axis_vector, other_vector;
 struct         IGRbsp_curve *trace_curve, *cross_section_curve;
 struct         IGRbsp_curve *reversed_trace_curve;
 struct         IGRbsp_surface *drive_surface;
/*
 * Initialize
 */
 drive_surface = NULL;
 trace_curve = NULL;
 reversed_trace_curve = NULL;
 cross_section_curve = NULL;
/*
 * Get the geometry of the input objects
 */
 EMS_GET_GEOMETRY(sts, msg, surface_object, FALSE, drive_surface)
  if (!(1 & sts)) goto wrapup;
 EMS_GET_GEOMETRY(sts, msg, trace_object, TRUE, trace_curve)
  if (!(1 & sts)) goto wrapup;
 EMS_GET_GEOMETRY(sts, msg, cross_section_object, TRUE, cross_section_curve)
  if (!(1 & sts)) goto wrapup;
/*
 * We may need to reverse the trace curve since the math computes the matrices
 * at the beginning of the trace.
 */
 BSalloccv(trace_curve->order, 
           trace_curve->num_poles,
           trace_curve->rational,
           0,
           &reversed_trace_curve,
           &loc_msg);
  if (loc_msg != BSSUCC)
   {
    *msg = MANOMEMORY;
    goto wrapup;
   }
 status = BSdirectcv(&loc_msg,
                     trace_object->proj_pnt,
                     trace_curve,
                     reversed_trace_curve);
  if ((!status) || (loc_msg != BSSUCC))
   {
    *msg = MSFAIL;
    goto wrapup;
   }
/*
 * Get the surface definition
 */
 x_axis_vector[0] = vector_pnts[1][0] - vector_pnts[0][0];
 x_axis_vector[1] = vector_pnts[1][1] - vector_pnts[0][1];
 x_axis_vector[2] = vector_pnts[1][2] - vector_pnts[0][2];
 for (i = 0; i < 3; i++)
  for (j = 0; j < 3; j++)
   stupid_matrix[i][j] = view_matrix[i][j];
  if (absolute_pnts)
   {
    absolute_orientation = TRUE;
    other_vector[0] = absolute_pnts[1][0] - absolute_pnts[0][0];
    other_vector[1] = absolute_pnts[1][1] - absolute_pnts[0][1];
    other_vector[2] = absolute_pnts[1][2] - absolute_pnts[0][2];
   } /* if (absolute_pnts) */
  else
   absolute_orientation = FALSE;
 BSortcvsfvc(
  drive_surface,
  side_pnt,
  reversed_trace_curve,
  cross_section_curve,
  ref_pnt,
  stupid_matrix,
  x_axis_vector,
  absolute_orientation,
  other_vector,
  rhs_view_to_site_matrix,
  lhs_view_to_site_matrix,
  &loc_msg);
 if (loc_msg != BSSUCC)
  {
   fprintf(stderr, "\nBSortcvsfvc error %d", loc_msg);
   *msg = MSFAIL;
   goto wrapup;
  }
/*
 * Finally, let's try and make up some display matrices.
 * We have the following:
 *
 *  view_matrix - Matrix which defines the view.  Note that the origin
 *                is taken as the reference point.
 *
 *  rhs_view_to_site_matrix - Matrix which transforms the view to about
 *                            it's origin to align the view x axis with the
 *                            user's x axis.  It then rotates this system
 *                            about the trace starting point such that it
 *                            appear to be on site.  This is done using
 *                            a right handed system.  
 *
 *  lhs_view_to_site_matrix - Same as rhs except using left handed system.
 *
 * Out of all this crap we want two matrices each of which should display
 * the cross section in the proper orienatation at the end of the trace.
 */
 {
  IGRshort      one = 1, four = 4;
  extern	IGRboolean MAmulmx(), MAidmx();
  IGRboolean    status;
  IGRdouble     rhs_ref_vector[4], lhs_ref_vector[4], homo_ref_pnt[4];
  IGRdouble     rhs_rotated_view_to_site[4][4];
  IGRdouble     lhs_rotated_view_to_site[4][4];

/*
 * Initialize
 */
  status = MAidmx(msg, rhs_rotated_view_to_site);
  status = MAidmx(msg, lhs_rotated_view_to_site);
  for (i = 0; i < 3; i++)
   {
    for (j = 0; j < 3; j++)
     {
      rhs_rotated_view_to_site[i][j] = rhs_view_to_site_matrix[i][j];
      lhs_rotated_view_to_site[i][j] = lhs_view_to_site_matrix[i][j];
     }
   }
  homo_ref_pnt[0] = ref_pnt[0];
  homo_ref_pnt[1] = ref_pnt[1];
  homo_ref_pnt[2] = ref_pnt[2];
  homo_ref_pnt[3] = 1.0;
/*
 * Compute the rhs matrix
 */
  status = MAmulmx(msg, &four, &four, &four,
                   rhs_rotated_view_to_site,
                   view_matrix,
                   rhs_matrix);
  status = MAmulmx(msg, &four, &four, &one,
                   rhs_matrix,
                   homo_ref_pnt,
                   rhs_ref_vector);
  rhs_matrix[0][3] = trace_object->proj_pnt[0] - rhs_ref_vector[0];
  rhs_matrix[1][3] = trace_object->proj_pnt[1] - rhs_ref_vector[1];
  rhs_matrix[2][3] = trace_object->proj_pnt[2] - rhs_ref_vector[2];
/*
 * Compute the lhs matrix
 */
  status = MAmulmx(msg, &four, &four, &four,
                   lhs_rotated_view_to_site,
                   view_matrix,
                   lhs_matrix);
  status = MAmulmx(msg, &four, &four, &one,
                   lhs_matrix,
                   homo_ref_pnt,
                   lhs_ref_vector);
  lhs_matrix[0][3] = trace_object->proj_pnt[0] - lhs_ref_vector[0];
  lhs_matrix[1][3] = trace_object->proj_pnt[1] - lhs_ref_vector[1];
  lhs_matrix[2][3] = trace_object->proj_pnt[2] - lhs_ref_vector[2];

#if DEBUG
{
int i;

for (i = 0; i < 4; i++)
 fprintf(stderr, "\nview_matrix %lf %lf %lf %lf",
  view_matrix[i][0], view_matrix[i][1],
  view_matrix[i][2], view_matrix[i][3]);
for (i = 0; i < 4; i++)
 fprintf(stderr, "\nrhs_rotated_view_to_site %lf %lf %lf %lf",
  rhs_rotated_view_to_site[i][0], rhs_rotated_view_to_site[i][1],
  rhs_rotated_view_to_site[i][2], rhs_rotated_view_to_site[i][3]);
for (i = 0; i < 4; i++)
 fprintf(stderr, "\nlhs_rotated_view_to_site %lf %lf %lf %lf",
  lhs_rotated_view_to_site[i][0], lhs_rotated_view_to_site[i][1],
  lhs_rotated_view_to_site[i][2], lhs_rotated_view_to_site[i][3]);
for (i = 0; i < 4; i++)
 fprintf(stderr, "\nrhs_matrix %lf %lf %lf %lf",
  rhs_matrix[i][0], rhs_matrix[i][1],
  rhs_matrix[i][2], rhs_matrix[i][3]);
for (i = 0; i < 4; i++)
 fprintf(stderr, "\nlhs_matrix %lf %lf %lf %lf",
  lhs_matrix[i][0], lhs_matrix[i][1],
  lhs_matrix[i][2], lhs_matrix[i][3]);
}
#endif
 }
/*
 * End of routine
 */
wrapup:
 if (drive_surface) free(drive_surface);
 if (trace_curve) free(trace_curve);
 if (reversed_trace_curve) status = BSfreecv(&loc_msg, reversed_trace_curve);
 if (cross_section_curve) free(cross_section_curve);
 if (1 & *msg)
  return(TRUE);
 else
  return(FALSE);
}

end implementation EMSgenbs;
