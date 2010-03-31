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
#include "masubvc.h"
#include "maaddvc.h"
#include "bsbx2.h"

/*
DESCRIPTION:

This fuction returns the range box of a non-partial (full) elliptical
 quadric surface. It needs the semi_major and semi_minor axis lengths
 at one end, the scale factor at the other end of the quadric and the
 center point around which the box is to be built.

HISTORY:

SAM	05/28/88	Creation.
Sudha   07/06/93	Modified for BSprototype ansification
SCW     02/13/97        included emsmacros_c.h rather than emsmacros.h
*/

IGRboolean EFsam_elliptical_full_quadric_range_box(semi_major, semi_minor,
						 					  scale, box_center, range)
 IGRvector semi_major, semi_minor;
 IGRdouble scale, *box_center;
 GRrange range;
{
IGRboolean   ma_status;
 IGRpoint range_pts[8];
 IGRint i, j;
 BSrc rc;
 IGRlong num_pts = 8, mthd_stat;
 
 ma_status = MAaddvc(&mthd_stat, semi_major, semi_minor,
					 &(range_pts[0][0]));
 if(!ma_status) return(FALSE);

 ma_status = MAsubvc(&mthd_stat, semi_major, semi_minor,
					 &(range_pts[1][0]));
 if(!ma_status) return(FALSE);

 for(i=0;i<3;i++)
 {
  range_pts[2][i] = -range_pts[0][i];
  range_pts[3][i] = -range_pts[1][i];
 }


 for(i=0;i<4;i++)
 {
  for(j=0;j<3;j++)
  {
   range_pts[i+4][j] = (range_pts[i][j]/scale)+ box_center[j+3];
   range_pts[i][j] = range_pts[i][j] + box_center[j];
  }
 }
 ma_status = BSbx2(&rc, &num_pts, range_pts, NULL, 
				   &range[0], &range[3]);
 if(!ma_status) return(FALSE);
 
 return(TRUE);
}

