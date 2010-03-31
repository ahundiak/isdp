#include <stdio.h>
#include <math.h>
#include <alloca.h>
#include <memory.h>

#include "igrtypedef.h"
#include "igr.h"
#include "bsgeom_cvsf.h"

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWerror.h"

#include "PWapi/rngbx.h"
#include "PWapi/mkvec.h"
#include "PWapi/dotp.h"
#include "PWapi/lenvec.h"

/*
  DESCRIPTION

  These functions accept a set of points and determines the tightest min-max
  box that contains them. Separate functions are provided for 2d and 3d.
*/

void pwGetRange2d 
(
  int num_points,
  PWpoint2d *pts,
  PWrange2d range
)
{
  int i, inx;
  double *min, *max, *pts_tmp;

  /*
   * Initialize the min and max arguments to the first two points.
   * It is possible that we may not have to make any more assignments -
   * specially in the case when 2 points are input, which is quite often.
   */

  range[MINIMUM][X] = pts[FIRST][X];
  range[MINIMUM][Y] = pts[FIRST][Y];
  range[MAXIMUM][X] = pts[SECOND][X];
  range[MAXIMUM][Y] = pts[SECOND][Y];
  min = (double *) range[MINIMUM];
  max = (double *) range[MAXIMUM]; 
  pts_tmp = (double *) pts;

  inx = num_points*2;
  for (i=0; i<inx; i+=2)
  {
    if (pts_tmp[i] < min[X])
      min[X] = pts_tmp[i];
    if (pts_tmp[i+1] < min[Y])
      min[Y] = pts_tmp[i+1];

    if (pts_tmp[i] > max[X])
      max[X] = pts_tmp[i];
    if (pts_tmp[i+1] > max[Y])
      max[Y] = pts_tmp[i+1];
  }

  return;
}
        
void pwGetRange 
(
  int num_points,
  PWpoint *pts,
  PWrange range
)
{
  int i, inx;
  double *min, *max, *pts_tmp;

  /*
   * Initialize the min and max arguments to the first two points.
   * It is possible that we may not have to make any more assignments -
   * specially in the case when 2 points are input, which is quite often.
   */

  range[MINIMUM][X] = pts[FIRST][Y];
  range[MINIMUM][Y] = pts[FIRST][Y];
  range[MINIMUM][Z] = pts[FIRST][Z];
  range[MAXIMUM][X] = pts[SECOND][X];
  range[MAXIMUM][Y] = pts[SECOND][Y];
  range[MAXIMUM][Z] = pts[SECOND][Z];
  min = (double *) range[MINIMUM];
  max = (double *) range[MAXIMUM]; 
  pts_tmp = (double *) pts;

  inx = num_points*3;
  for (i=0; i<inx; i+=3)
  {
    if (pts_tmp[i] < min[X])
      min[X] = pts_tmp[i];
    if (pts_tmp[i+1] < min[Y])
      min[Y] = pts_tmp[i+1];
    if (pts_tmp[i+2] < min[Z])
      min[Z] = pts_tmp[i+2];

    if (pts_tmp[i] > max[X])
      max[X] = pts_tmp[i];
    if (pts_tmp[i+1] > max[Y])
      max[Y] = pts_tmp[i+1];
    if (pts_tmp[i+2] > max[Z])
      max[Z] = pts_tmp[i+2];
  }

  return;
}
        
/*
  DESCRIPTION

  These functions expand the given range box by a given amount. Separate
  functions are available for 2d and 3d.
*/

void pwExpandRange2d 
(
  PWrange2d rng,
  double k
)
{
  rng[MINIMUM][X] -= k;
  rng[MINIMUM][Y] -= k;

  rng[MAXIMUM][X] += k;
  rng[MAXIMUM][Y] += k;

  return;
}

void pwExpandRange 
(
  PWrange rng,
  double k
)
{
  rng[MINIMUM][X] -= k;
  rng[MINIMUM][Y] -= k;
  rng[MINIMUM][Z] -= k;

  rng[MAXIMUM][X] += k;
  rng[MAXIMUM][Y] += k;
  rng[MAXIMUM][Z] += k;

  return;
}

/*
  DESCRIPTION

  Functions that returns TRUE if the two input range boxes intersect or 
  overlap. If the areas (2d) or the volumes (3d) do not intersect, the 
  function returns FALSE.
*/

PWboolean pwIsOverlapRngRng2d 
(
  PWrange2d rng1,
  PWrange2d rng2
)
{
  double *p_rng1, *p_rng2;

  p_rng1 = (double *) rng1;
  p_rng2 = (double *) rng2;

  return (! (p_rng1[2] <= p_rng2[0] ||
             p_rng2[2] <= p_rng1[0] ||
             p_rng1[3] <= p_rng2[1] ||
             p_rng2[3] <= p_rng1[1]));
}

PWboolean pwIsOverlapRngRng 
(
  PWrange rng1,
  PWrange rng2
)
{
  double *p_rng1, *p_rng2;

  p_rng1 = (double *) rng1;
  p_rng2 = (double *) rng2;

  return (! (p_rng1[3] <= p_rng2[0] ||
             p_rng2[3] <= p_rng1[0] ||
             p_rng1[4] <= p_rng2[1] ||
             p_rng2[4] <= p_rng1[1] ||
             p_rng1[5] <= p_rng2[2] ||
             p_rng2[5] <= p_rng1[2]));
}


/*
  DESCRIPTION

  These functions use the Cohen-Sutherland type procedure to determine
  if a 2d (or a 3d) segment can be trivially classified as lying outside a
  given range box.


  NOTES
  
  Only those segments that can be trivially rejected by a simple zone-bit
  check are rejected. This function DOES NOT guarantee the rejection of all
  segments that do not intersect the box.
*/

#define FIRST_BIT   0x01
#define SECOND_BIT  0x02
#define THIRD_BIT   0x04
#define FOURTH_BIT  0x08
#define FIFTH_BIT   0x10
#define SIXTH_BIT   0x20

PWboolean pwIsOutsideSegRng2d 
(
  PWpoint2d seg[2],
  PWrange2d rng
)
{
  unsigned char zone1, zone2;
  double *p_seg, *p_rng;

  p_seg = (double *) seg;
  p_rng = (double *) rng;

  zone1 = 0x0;
  zone2 = 0x0;

  if (p_seg[0] < p_rng[0])
    zone1 = FIRST_BIT;
  else if (p_seg[0] > p_rng[2])
    zone1 = SECOND_BIT;

  if (p_seg[1] < p_rng[1]) 
    zone1 = zone1 | THIRD_BIT;
  else if (p_seg[1] > p_rng[3])
    zone1 = zone1 | FOURTH_BIT;


  if (p_seg[2] < p_rng[0])
    zone2 = FIRST_BIT;
  else if (p_seg[2] > p_rng[2])
    zone2 = SECOND_BIT;

  if (p_seg[3] < p_rng[1])
    zone2 = zone2 | THIRD_BIT;
  else if (p_seg[3] > p_rng[3])
    zone2 = zone2 | FOURTH_BIT;
  
  if (zone1 & zone2)
    return (TRUE);
  else 
    return (FALSE);
}

PWboolean pwIsOutsideSegRng
(
  PWpoint seg[2],
  PWrange rng
)
{
  unsigned char zone1, zone2;
  double *p_seg, *p_rng;

  p_seg = (double *) seg;
  p_rng = (double *) rng;

  zone1 = 0x0;
  zone2 = 0x0;

  if (p_seg[0] < p_rng[0])
    zone1 = FIRST_BIT;
  else if (p_seg[0] > p_rng[3])
    zone1 = SECOND_BIT;

  if (p_seg[1] < p_rng[1]) 
    zone1 = zone1 | THIRD_BIT;
  else if (p_seg[1] > p_rng[4])
    zone1 = zone1 | FOURTH_BIT;

  if (p_seg[2] < p_rng[2]) 
    zone1 = zone1 | FIFTH_BIT;
  else if (p_seg[2] > p_rng[5])
    zone1 = zone1 | SIXTH_BIT;


  if (p_seg[3] < p_rng[0])
    zone2 = FIRST_BIT;
  else if (p_seg[3] > p_rng[3])
    zone2 = SECOND_BIT;

  if (p_seg[4] < p_rng[1]) 
    zone2 = zone2 | THIRD_BIT;
  else if (p_seg[4] > p_rng[4])
    zone2 = zone2 | FOURTH_BIT;

  if (p_seg[5] < p_rng[2]) 
    zone2 = zone2 | FIFTH_BIT;
  else if (p_seg[5] > p_rng[5])
    zone2 = zone2 | SIXTH_BIT;

  
  if (zone1 & zone2)
    return (TRUE);
  else 
    return (FALSE);
}


/*
  DESCRIPTION
 
  Given a B-spline curve, it computes the range box which encloses the curve.

  NOTES

  All the memory must be allocated by the caller. This output range box is not 
  a tighter one. 
*/

void pwGetCvRange
(
  struct IGRbsp_curve *p_cv,
  PWrange             range
)
{
  int    i;
  double val, *pts=NULL, *wts=NULL;

  pts = p_cv->poles; 
  wts = p_cv->rational ? p_cv->weights : NULL;

  if (wts)
  {
    range[MINIMUM][X] = range[MAXIMUM][X] =*pts++ / *wts; 
    range[MINIMUM][Y] = range[MAXIMUM][Y] =*pts++ / *wts; 
    range[MINIMUM][Z] = range[MAXIMUM][Z] =*pts++ / *wts++;

    for (i=1; i<p_cv->num_poles; i++)
    {
      val = *pts++ / *wts;
      if (val < range[MINIMUM][X])
        range[MINIMUM][X] = val;
      else if (val > range[MAXIMUM][X])
        range[MAXIMUM][X] = val;

      val = *pts++ / *wts;
      if (val < range[MINIMUM][Y])
        range[MINIMUM][Y] = val;
      else if (val > range[MAXIMUM][Y])
        range[MAXIMUM][Y] = val;

      val = *pts++ / *wts++;
      if (val < range[MINIMUM][Z])
        range[MINIMUM][Z] = val;
      else if (val > range[MAXIMUM][Z])
        range[MAXIMUM][Z] = val;
    } 
  } 
  else
  {
    range[MINIMUM][X] = range[MAXIMUM][X] =*pts++;
    range[MINIMUM][Y] = range[MAXIMUM][Y] =*pts++;
    range[MINIMUM][Z] = range[MAXIMUM][Z] =*pts++;

    for (i=1; i<p_cv->num_poles; i++)
    {
      val = *pts++;
      if (val < range[MINIMUM][X])
        range[MINIMUM][X] = val;
      else if (val > range[MAXIMUM][X])
        range[MAXIMUM][X] = val;

      val = *pts++;
      if (val < range[MINIMUM][Y])
        range[MINIMUM][Y] = val;
      else if (val > range[MAXIMUM][Y])
        range[MAXIMUM][Y] = val;

      val = *pts++;
      if (val < range[MINIMUM][Z])
        range[MINIMUM][Z] = val;
      else if (val > range[MAXIMUM][Z])
        range[MAXIMUM][Z] = val;
    }
  }
}

void pwGetRangeCvdata
(
  struct PWcvdata *p_cvdata,
  double *range
)
{
  switch (p_cvdata->datatype)
  {
    case PWcvdata_pt2d : 
      memcpy (&range[0], p_cvdata->data.pt2d, sizeof (PWpoint2d));
      memcpy (&range[2], p_cvdata->data.pt2d, sizeof (PWpoint2d));
    break;

    case PWcvdata_pt : 
      memcpy (&range[0], p_cvdata->data.pt, sizeof (PWpoint));
      memcpy (&range[3], p_cvdata->data.pt, sizeof (PWpoint));
    break;

    case PWcvdata_py2d : 
      pwGetRange2d (p_cvdata->data.py2d.num_pts, p_cvdata->data.py2d.p_pts, 
                    (PWpoint2d *) &range[0]);
    break;

    case PWcvdata_py : 
      pwGetRange (p_cvdata->data.py.num_pts, p_cvdata->data.py.p_pts, 
                  (PWpoint *) range);
    break;

    case PWcvdata_bspcv : 
    case PWcvdata_gmbspcv : 
      pwGetCvRange (p_cvdata->datatype == PWcvdata_bspcv ? 
                    p_cvdata->data.p_bspcv : p_cvdata->data.p_gmbspcv->bspcv, 
                    (PWpoint *) range);
    break;

    default : 
    break;

  }
}

void pwGetMaxParCvdata
(
  struct PWcvdata  *p_cvdata,
  struct PWcvparam *p_cvpar
)
{
  struct IGRbsp_curve *p_cv=NULL;

  switch (p_cvdata->datatype)
  {
    case PWcvdata_py2d :
      p_cvpar->spaninx = p_cvdata->data.py2d.num_pts - 2;
      p_cvpar->spanpar = 1.0;
      break;

    case PWcvdata_py:
      p_cvpar->spaninx = p_cvdata->data.py.num_pts - 2;
      p_cvpar->spanpar = 1.0;
      break;

    case PWcvdata_bspcv :
      p_cv = p_cvdata->data.p_bspcv;
      p_cvpar->spaninx = 0;
      p_cvpar->spanpar = (p_cv->knots[p_cv->num_poles]);
      break;

    case PWcvdata_gmbspcv :
      p_cv = p_cvdata->data.p_gmbspcv->bspcv;
      p_cvpar->spaninx = 0;
      p_cvpar->spanpar = (p_cv->knots[p_cv->num_poles]);
      break;

    default :
      p_cvpar->spaninx = 0;
      p_cvpar->spanpar = 1.0;
      break;
  }

  return;
}

void pwGetMinParCvdata
(
  struct PWcvdata  *p_cvdata,
  struct PWcvparam *p_cvpar
)
{
  struct IGRbsp_curve *p_cv=NULL;

  switch (p_cvdata->datatype)
  {

    case PWcvdata_bspcv :
      p_cv = p_cvdata->data.p_bspcv;
      p_cvpar->spaninx = 0;
      p_cvpar->spanpar = (p_cv->knots[p_cv->order-1]);
      break;

    case PWcvdata_gmbspcv :
      p_cv = p_cvdata->data.p_gmbspcv->bspcv;
      p_cvpar->spaninx = 0;
      p_cvpar->spanpar = (p_cv->knots[p_cv->order-1]);
      break;

    default :
      p_cvpar->spaninx = 0;
      p_cvpar->spanpar = 0.0;
      break;
  }

  return;
}


/*
  DESCRIPTION

    Given the minimum and maximum points defining a range box, it rerturns all
    the eight corners defining the given range box.

  NOTES
   
    All the memory for the output must be allocated by the caller.
*/

void pwGetRngPts
(
  PWrange  rngbx,
  PWpoint  rngpts[8]
)
{
  int pt=0;

  for (pt=0; pt<4; pt++)
    memcpy (rngpts[pt], rngbx[0],  sizeof (PWpoint));

  rngpts [1][1] = rngbx[1][1];

  rngpts [2][0] = rngbx[1][0];
  rngpts [2][1] = rngbx[1][1];

  rngpts [3][0] = rngbx[1][0];

  for (pt=4; pt<8; pt++)
    memcpy (rngpts[pt], rngbx[1], sizeof (PWpoint));

  rngpts [4][0] = rngbx[0][0];
  rngpts [4][1] = rngbx[0][1];

  rngpts [5][0] = rngbx[0][0];

  rngpts [7][1] = rngbx[0][1];
}

/*
  DESCRIPTION

    Given N number of points (collinear) and a vector, it sorts the points 
    along this vector and returns the minimum and maximum points.

  NOTES
   
    All the memory for the output must be allocated by the caller.
*/

PWresult  pwMinMaxPtsAlongVec 
(
  int       numpts, 
  PWpoint   *ppoints, 
  PWvector  dirvec,
  PWpoint   maxpt, 
  PWpoint   minpt
)
{
  PWresult   retval=PW_K_Success;
  PWvector   lenvec;
  double     *magvec=NULL, tmpval=0.0;
  int        *index=NULL, ii=0, jj=0;
  double     sign=0.0;

  /*
   * validate the incoming arguments
   */
  if (numpts<1 || !ppoints )
    OnErrorState (TRUE, retval, SetError (PW_K_Pathway, PW_K_InvalidArg),
                  wrapup);
  
  if (numpts==1)
  {
    memcpy (minpt, ppoints[0], sizeof(PWpoint));
    memcpy (maxpt, ppoints[0], sizeof(PWpoint));
    goto wrapup;
  }
    
  
  /*
   * Allocate space for magvec to contain distace of points from the base
   * point and 'index' to contain the lengthvector indices.
   */
  magvec = (double *)alloca (numpts* sizeof (double));
  OnErrorState (!magvec, retval,
                SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);
  index = (int *) alloca (numpts* sizeof (int));
  OnErrorState (!index, retval,
                 SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);

  /*
   * Take the first point as the base point and construct a vector with 
   * with the base point and the next point.
   */
  for (ii=1; ii<numpts; ii++)
  {
    sign = 0.0;
    
    pwMakeVec (ppoints[0], ppoints[ii], lenvec);
    magvec[ii-1] = pwLenVec (lenvec);

    /*
     * Do a dot-product between lenvec and the dirvec to determin the direction
     * of flow.
     */
    sign = (pwDot (dirvec, lenvec) >0.0)?   1.0 :  -1.0;
    magvec[ii-1] = sign*magvec[ii-1];
  }

  /*
   * Initialize the index counter
   */
  for (ii=0; ii<numpts; ii++)
  {
    index[ii] = ii;
  }
  
  /*
   * Do a bubble sort to sort the magnitude list as well as the index list.
   */
  for (ii=0; ii<numpts-2; ii++)
  {
    for (jj=ii+1; jj<numpts-1; jj++)
    {
      if (magvec[ii] > magvec[jj])
      {
        tmpval = magvec[ii];
        magvec[ii] = magvec[jj];
        magvec[jj] = tmpval;

        tmpval = index[ii];
        index[ii] = index[jj];
        index[jj] = tmpval;
      }
    }
  }

  /*
   * At this point the index array will contain the sorted index of the 
   * length vectors
   */
  if (magvec[0] > 0.0)
  {
    memcpy (minpt, ppoints[0], sizeof (PWpoint));
  }
  else
  {
    memcpy (minpt, ppoints[index[0]+1], sizeof (PWpoint));
  }

  if (magvec[numpts -2] < 0.0)
  {
    memcpy (maxpt, ppoints[0], sizeof (PWpoint));
  }
  else
  {
    memcpy (maxpt, ppoints[index[numpts-2]+1], sizeof (PWpoint));
  }

wrapup:

  PW_Wrapup (retval, "pwMinMaxPtsAlongVec");
  return (retval);
} /* end of function pwMinMaxPtsAlongVec */
  
