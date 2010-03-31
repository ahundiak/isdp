/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This function takes 3 points(2D), and decides whether they
  make a left turn, right turn or are collinear. The points are taken
  in the order of  input.


History
	SM	03/19/87	Creation date(modified similar math function)
	SM	06/19/87	Made tolerance changes.
	
Algorithm
	If the cross product between the vectors pt1-pt2 and pt2-pt3 is
  within tolerance then the 3 points are collinear.If the cross product 
  is positive then the points make a left turn alse they make a right
  turn.
*/

# include "EMS.h"

# include <math.h>

# include "OMminimum.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "igetypedef.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "EMSbnddef.h"
# include "EMSmsgdef.h"

#define		TOL_FACTOR	25.0
#define		TOL_STEPS	4

IGRshort EMturn(rc,pt1,pt2,pt3,partolcollin)

IGRlong        		*rc;           
IGRdouble     		*pt1,*pt2,*pt3,partolcollin;
{

IGRshort   sts;
IGRdouble    det, scale;
IGRdouble    diff;
IGRint	     i;

*rc = EMS_S_Success;

det = ((pt2[0] - pt1[0]) * (pt3[1] - pt2[1])) - 
      ((pt3[0] - pt2[0]) * (pt2[1] - pt1[1]));

/* If the input points are within tolerance then a turn cannot be
   determined. For this reason the input tolerance is decremented in
   4 steps in an effort to get the turn. This decrease in tolerance will
   make a would be 'collinear' turn into right or left but will not produce
   errorneous results.
*/

diff = fabs(det);
if(diff < partolcollin) 
 {
   i=1;
   while( (i<= TOL_STEPS) && (diff < partolcollin))
    {
      scale = i * TOL_FACTOR;
      partolcollin = partolcollin/scale;
      i++;
    }
   if(diff < partolcollin)
     sts = EMS_L_COLLINEAR;
   else if (det > 0)
     sts = EMS_L_LEFT;
   else
     sts = EMS_L_RIGHT;
 }
else if (det > 0)
   sts = EMS_L_LEFT;
else
   sts = EMS_L_RIGHT;

return(sts);
}
