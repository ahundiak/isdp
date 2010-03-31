/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "bserr.h"
#include "OMmacros.h"
#include "madef.h"
#include <math.h>
#include "emsmacros_c.h"
#include "EMSsfparms.h"
#include "emssfdef.h"
#include "msdef.h"
#include "bsvalues.h"
#include "ma.h"
#include "maunitvc.h"
#include "matrnmx.h"
#include "masubvc.h"
#include "maptwcang.h"
#include "maelexten.h"
#include "macrossvc.h"
#include "maangptel.h"
#include "maangonar.h"
#include "maaddvc.h"
#include "ma3protmx.h"
#include "bspeconprop.h"
#include "bsbx2.h"

#define AXIS_POLES 2
#define AXIS_KNOTS 4

/*
DESCRIPTION:

This function finds the range box of a partial quadric surface.

HISTORY:

SCW     02/13/97        included emsmacros_c.h rather than emsmacros.h
Sudha	07/06/93	Modified for BSprototypes ansification
NP      08/27/92        Modified for ANSI compliance.
PP      02/02/89        The base point and the height vector were not
                        being returned properly in some cases.
SAM	06/01/88	Creation.
*/


IGRboolean EFsam_partial_quadric_range_box(surf, type, params)
 struct IGRbsp_surface   *surf;
 IGRshort		 type;
 struct EMsurface_params *params;
{

 IGRlong                mthd_stat; /* OM return status */
 IGRlong                i;      /* for loop index */
 
 BSrc                   rc;     /* Math completion code */

 IGRdouble              knots[AXIS_KNOTS]; 
                                /* for storing the knots */
 IGRpoint               poles[AXIS_POLES];
                                /* for storing the poles */
 struct IGRbsp_curve    axis;
                                /* axis of the cylinder */

void   EFdraw_range_box();
                                /* Function declaration */

        IGRboolean ptcone, bssts;

 IGRshort four = 4;

 struct IGRarc arc;

 IGRvector f1a, f2a, f1b, f2b, majv1a, majv2a, majv1b, majv2b, 
           minv1a, minv2a, minv1b, minv2b, x_axis, y_axis, z_axis,
           start, end;
 IGRdouble majl1, minl1, majl2, minl2, *majl[2], *minl[2], thetas[8],
           thetas_on_arc[8], arpts[48], *majv, *center[2], sweep_angle,
		   height, area;

 IGRint temp_n_pts, sizept = sizeof(IGRpoint);
 IGRlong   n_pts;


 axis.poles = (IGRdouble *) poles;
 axis.knots = (IGRdouble *) knots;
 axis.weights = NULL;
 axis.bdrys = NULL;


 (void) BSpeconprop(surf, &axis, &height, &area,
                   f1a, f1b, f2a, f2b, majv1a, majv1b, majv2a, majv2b,
				   minv1a, minv1b, minv2a, minv2b, 
                   &majl1, &majl2, &minl1, &minl2,
                   start, end, &rc);

 if(rc != BSSUCC) return(FALSE);

 ptcone = FALSE;
 
 if((majl1 == 0.0) && (minl1 == 0.0))
 {
  ptcone = TRUE;
  majl[0] = &majl2; minl[0] = &minl2;
  majv = majv2a;
  center[0] = &axis.poles[3];
  center[1] = &axis.poles[0];
 }
 else
 {
  majl[0] = &majl1; minl[0] = &minl1;
  majv = majv1a;
  center[0] = &axis.poles[0];
  center[1] = &axis.poles[3];
 }

 if((majl2 == 0.0) && (minl2 == 0.0))
 {
  ptcone = TRUE;
 }
 else if(!ptcone)
 {
  majl[1] = &majl2; minl[1] = &minl2;
  majv = majv2a;
 }

 
 arc.prim_axis = *majl[0]; arc.sec_axis = *minl[0];

 OM_BLOCK_MOVE(center[0], &arc.origin[0], sizept);

 bssts = MAsubvc(&mthd_stat, &axis.poles[3], &axis.poles[0], z_axis);
 if(!bssts) return(FALSE);

 bssts = MAunitvc(&mthd_stat, majv, x_axis);
 if(!bssts) return(FALSE);

 bssts = MAunitvc(&mthd_stat, z_axis, z_axis);
 if(!bssts) return(FALSE);

 bssts = MAcrossvc(&mthd_stat, z_axis, x_axis, y_axis);
 if(!bssts) return(FALSE);

 bssts = MAaddvc(&mthd_stat, y_axis, center[0], y_axis);
 if(!bssts) return(FALSE);

 bssts = MAaddvc(&mthd_stat, x_axis, center[0], x_axis);
 if(!bssts) return(FALSE);
 
 bssts = MAaddvc(&mthd_stat, start, center[0], start);
 if(!bssts) return(FALSE);

 bssts = MAaddvc(&mthd_stat, end, center[0], end);
 if(!bssts) return(FALSE);
 
 bssts = MAaddvc(&mthd_stat, majv, center[0], majv);
 if(!bssts) return(FALSE);

 bssts = MA3protmx(&mthd_stat, center[0], x_axis, y_axis, arc.rot_matrix);
 if(!bssts) return(FALSE);

 bssts = MAtrnmx(&mthd_stat, &four, arc.rot_matrix, arc.rot_matrix);
 if(!bssts) return(FALSE);

 bssts = MAptwcangel(&mthd_stat, start, (struct IGRellipse *)&arc, &arc.start_angle);
 if(!bssts) return(FALSE);

 bssts = MAptwcangel(&mthd_stat, end, (struct IGRellipse *)&arc, &sweep_angle);
 if(!bssts) return(FALSE);

 arc.sweep_angle = sweep_angle;

 if(arc.sweep_angle < arc.start_angle)
 {
  arc.sweep_angle += 2 * M_PI - arc.start_angle;
 }
 else 
 if(arc.sweep_angle != 0.0)
 {
  arc.sweep_angle  -= arc.start_angle;
 }

/* ALTERNATE CODE WHICH GOES HERE IS AT THE BOTTOM OF THE FUNCTION */

 bssts = MAelextents(&mthd_stat, (struct IGRellipse *)&arc, &arpts[0], &arpts[3], thetas);
 if(!bssts) return(FALSE);

 n_pts = 0;
 for(i=0; i<6; ++i)
 {
  if(MAangonar(&mthd_stat,&thetas[i], &arc.start_angle, &arc.sweep_angle))
  {
   thetas_on_arc[n_pts] = thetas[i];
   MAangptel(&mthd_stat, &thetas[i], (struct IGRellipse *)&arc, &arpts[3*n_pts]);
   ++n_pts;
  }
 }
 
 if(n_pts != 6)
 {
  OM_BLOCK_MOVE(start, &arpts[3*n_pts], sizept);
  thetas_on_arc[n_pts] = arc.start_angle;
  OM_BLOCK_MOVE(end, &arpts[3*(n_pts+1)], sizept);
  thetas_on_arc[n_pts+1] = sweep_angle;
  n_pts = n_pts + 2;
 }
 
 if(ptcone)
 {
  OM_BLOCK_MOVE(center[1], &arpts[3*n_pts], sizept);
  ++n_pts;
 }
 else
 {
  OM_BLOCK_MOVE(center[1], &arc.origin[0], sizept);
 
  arc.prim_axis = *majl[1];
  arc.sec_axis = *minl[1];
  temp_n_pts = n_pts;
  for(i=0; i<temp_n_pts; i++)
  {
   MAangptel(&mthd_stat, &thetas_on_arc[i], (struct IGRellipse *)&arc, &arpts[3*n_pts]);  
   ++n_pts;
  }
 }

 bssts = BSbx2(&rc, &n_pts, (IGRpoint *)arpts, NULL,
			   &params->range[0], &params->range[3]);
 if(!bssts) return(FALSE);

if(type != EMfreeform_surface) /* It is either EMpcylindr OR EMpcone */
{ 
 struct EMpartial_cylinder_params *ptr;
 ptr = (struct EMpartial_cylinder_params *)&params->params.cyl;
 
 OM_BLOCK_MOVE(center[0], &ptr->base_center[0], sizept);

 bssts = MAsubvc(&mthd_stat, center[1], center[0], 
                 &ptr->height[0]);
 if(!bssts) return(FALSE);

 OM_BLOCK_MOVE(start, &ptr->pstart[0], sizept);
 OM_BLOCK_MOVE(end, &ptr->pend[0], sizept);
 
 ptr->sweep_angle = arc.sweep_angle;
 ptr->area = area;

 if(type == EMpcone)
 {
  struct EMpartial_cone_params *ptr;
  ptr = &params->params.pcone;
  ptr->base_radius = majl1;
  ptr->top_radius = majl2;
 }
 else
 {
  struct EMpartial_cylinder_params *ptr;
  ptr = &params->params.pcyl;
  ptr->radius = majl1;
 }

}

 return(TRUE);

}

/*  PLEASE DONOT REMOVE THIS CODE, IT MAY BE OF USE

 end_vec_len = BSlenvec(&rc, end_vec);
 if(rc != BSSUCC) return(FALSE);

 start_vec_len = BSlenvec(&rc, start_vec);
 if(rc != BSSUCC) return(FALSE);

 start_d_end = BSdotp(&rc, start_vec, end_vec);
 if(rc != BSSUCC) return(FALSE);

 cos_inc_angle = start_d_end / (start_vec_len * end_vec_len);
 if(cos_inc_angle < -1.0) cos_inc_angle = -1.0;
 else
 if(cos_inc_angle > 1.0) cos_inc_angle = 1.0;

 included_angle = acos(cos_inc_angle);

 bssts = MAcrossvc(&mthd_stat, start_vec, end_vec, start_x_end);
 if(!bssts) return(FALSE);

 bssts = MAunitvc(&mthd_stat, start_x_end, start_x_end);
 if(!bssts) return(FALSE);

 dotp = BSdotp(&rc, start_x_end, z_axis);
 if(rc != BSSUCC) return(FALSE);

 if(dotp < 0)
 {
  arc.sweep_angle = 2 * M_PI - arc.sweep_angle;
  arc.rot_matrix[1] = -arc.rot_matrix[1];
  arc.rot_matrix[2] = -arc.rot_matrix[2];
  arc.rot_matrix[5] = -arc.rot_matrix[5];
  arc.rot_matrix[6] = -arc.rot_matrix[6];
  arc.rot_matrix[9] = -arc.rot_matrix[9];
  arc.rot_matrix[10] = -arc.rot_matrix[10];
 }
 else
  arc.sweep_angle = arc.sweep_angle;
 */
 
