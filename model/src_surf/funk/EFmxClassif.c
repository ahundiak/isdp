/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
# include "emssfdef.h"
# include "bstypes.h"
# include "bserr.h"
# include "bsparameters.h"

# define IS     ==

int EFmatrixClassification(double *mx)

/*
Abstract

    Classify the 4 by 4 matrix as one of the following:

        uniform scale               0 - EMSuniformTransformation
        non-uniform scale           1 - EMSnonuniformTransformation
        distortion                  2 - EMSdistortion
        uniform scale of 1          3 - EMSscale_of_1
Notes

    The following defines are used to classify matrices as they effect
    the classification of surface geometries. These values do not
    conform to the matrix type argument passed in the argument list of
    most graphics messages.

History

    19 Apr 88   AIC     Use BSTOLQSLENVEC.
    10 Mar 88   AIC     Creation Date
*/
{
  int   mx_type = EMSdistortion;

  if((mx[15] IS 1.) && (mx[12] IS 0.) && (mx[13] IS 0.) && (mx[14] IS 0.))
  {
    BSrc    rc;
 extern  double  fabs();
    double  xmag_sq, ymag_sq, zmag_sq, dist_sqtol;

    (void)BSEXTRACTPAR(&rc, BSTOLSQLENVEC, dist_sqtol);
    if(BSERROR(rc)) goto wrapup;
    mx_type = EMSnonuniformTransformation;
    xmag_sq = mx[0] * mx[0] + mx[4] * mx[4] + mx[8] * mx[8];
    ymag_sq = mx[1] * mx[1] + mx[5] * mx[5] + mx[9] * mx[9];
    if(fabs(xmag_sq - ymag_sq) < dist_sqtol)
    {
      zmag_sq = mx[2] * mx[2] + mx[6] * mx[6] + mx[10] * mx[10];
      if(fabs(zmag_sq - xmag_sq) < dist_sqtol)
        mx_type = EMSuniformTransformation;

      if ( fabs(xmag_sq - 1.) <= dist_sqtol  && 
           fabs(ymag_sq - 1.) <= dist_sqtol  && 
           fabs(zmag_sq - 1.) <= dist_sqtol)
       mx_type = EMSscale_of_1;
    }
  }

wrapup:
  return(mx_type);
}
