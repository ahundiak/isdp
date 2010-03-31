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
#include "mamulmx.h"
#include "maidmx.h"
#include "maaddvc.h"
#include "bstrans2.h"
#include "bsmkvec.h"
#include "bsbx2.h"

/*
DESCRIPTION:

This function finds the range box for a non-partial ( full ) quadric but
 ( not elliptical ) surface.
 It needs the lenghths of the squares at the ends of the quadric surface.

HISTORY:

SAM	05/20/88	Creation.
Sudha   07/06/93        Modified for BSprototypes ansification
SCW     02/13/97        Included emsmacros_c.h rather than emsmacros.h

*/

IGRboolean EFsam_full_quadric_range_box(square1_dim_2, square2_dim_2,
									    box_center, range)
 IGRdouble square1_dim_2, square2_dim_2, *box_center;
 GRrange range;
{
 IGRint i, j;
 IGRboolean   bssts, scale;
 IGRlong num_pts = 8;
 IGRshort eight = 8, one = 1, four = 4;
 IGRdouble limit_pts[8][4], newlimit_pts[8][4], mat[3][3];
 IGRlong mthd_stat;
 IGRpoint range_pts[8];
 BSrc rc;
 IGRvector vec;
 IGRdouble matrix[16];

 
 if(square1_dim_2 == square2_dim_2) scale = FALSE;
 else scale = TRUE;
 
 bssts = BSmkvec(&rc, vec, &box_center[0], &box_center[3]);
 if(!bssts) return(FALSE);


 (void) BStrans2(vec, TRUE, mat, &rc);
 if(rc != BSSUCC) return(FALSE);


 bssts = MAidmx(&mthd_stat, matrix);
 if(!bssts) return(FALSE);

 for(i= 0; i <=2 ; i++)
 {
  matrix[i] = mat[0][i];
  matrix[i+4] = mat[1][i];
  matrix[i+8] = mat[2][i];
 }

 limit_pts[0][0] = limit_pts[1][0] = -square1_dim_2;
 limit_pts[1][1] = limit_pts[2][1] = square1_dim_2;
 limit_pts[2][0] = limit_pts[3][0] = square1_dim_2;
 limit_pts[3][1] = limit_pts[0][1] = -square1_dim_2;

 for(i=0;i<4;i++)
 {
  limit_pts[i][2] = 0.0;
  limit_pts[i][3] = 1.0;
 }

 if(scale)
 {
  limit_pts[4][0] = limit_pts[5][0] = -square2_dim_2;
  limit_pts[5][1] = limit_pts[6][1] = square2_dim_2;
  limit_pts[6][0] = limit_pts[7][0] = square2_dim_2;
  limit_pts[7][1] = limit_pts[4][1] = -square2_dim_2;

  for(i=0;i<4;i++)
  {
   limit_pts[4+i][2] = 0.0;
   limit_pts[4+i][3] = 1.0;
  }

   bssts = MAmulmx(&mthd_stat,&eight,&four,&four,&limit_pts[0][0], matrix,
	   			   &newlimit_pts[0][0]);
   if(!bssts) return(FALSE);
 }
 else
 {
   bssts = MAmulmx(&mthd_stat, &four, &four, &four, &limit_pts[0][0],
				   matrix, &newlimit_pts[0][0]);
   if(!bssts) return(FALSE);
 }

 
 for(i=0;i<4;i++)
 {
  bssts = MAaddvc(&mthd_stat, &newlimit_pts[i][0], &box_center[0],
                  &range_pts[i][0]);
  if(!bssts) return(FALSE);

  bssts = MAaddvc(&mthd_stat,
                  &newlimit_pts[(scale ? i+4 : i)][0],
                  &box_center[3],&range_pts[i+4][0]);
  if(!bssts) return(FALSE);
 }

 bssts = BSbx2(&rc, &num_pts, range_pts, NULL,
			   &range[0], &range[3]);
 if(!bssts) return(FALSE);

 return(TRUE);
}
