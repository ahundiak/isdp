#include <math.h>
#include <memory.h>

#include "bsvalues.h"
#include "igrtypedef.h"
#include "igr.h"        /* BS Include Stuff */
#include "bs.h"
#include "bsparameters.h"
#include "bserr.h"
#include "bsgeom_cvsf.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"

#include "bsmdstptcv.h"             /* BS */

#include "PWapi/rngbx.h"
#include "PWapi/mdstptgm.h"

/* Internal Prototypes */

static PWresult proj_pt_ln
(
  double     *pt,
  double     *segpt1,
  double     *segpt2,
  PWboolean  is_3d,
  double     *minpt,
  double     *minpar
);

static double min_dist_sq_pt_seg
(
  double    *pt,
  double    *segpt1,
  double    *segpt2,
  PWboolean is_3d,
  double    *minpt,
  double    *minpar
);

static double min_dist_sq_pt_py
(
  double            *pt,
  int               numpypts,
  double            *pypts,
  PWboolean         is_3d,
  double            *minpt,
  struct PWcvparam  *minpar
);
 
/*
  DESCRIPTION

  Point-to-Point:
  These functions compute the distance or the distance squared between two
  given points (the minimum distance). Separate functions provided for 
  2D and 3D.
*/

double pwDistPtPt2d 
(
  PWpoint2d pt1,
  PWpoint2d pt2
)
{
  double delx, dely;
 
  delx = pt2[X] - pt1[X];
  dely = pt2[Y] - pt1[Y];
  return (sqrt (delx * delx + dely * dely));
}

double pwDistPtPt 
(
  PWpoint pt1,
  PWpoint pt2
)
{
  double delx, dely, delz;
 
  delx = pt2[X] - pt1[X];
  dely = pt2[Y] - pt1[Y];
  delz = pt2[Z] - pt1[Z];
  return (sqrt (delx * delx + dely * dely + delz * delz));
}

double pwDistSqPtPt2d 
(
  PWpoint2d pt1,
  PWpoint2d pt2
)
{
  double delx, dely;
 
  delx = pt2[X] - pt1[X];
  dely = pt2[Y] - pt1[Y];
  return (delx * delx + dely * dely);
}

double pwDistSqPtPt 
(
  PWpoint pt1,
  PWpoint pt2
)
{
  double delx, dely, delz;
 
  delx = pt2[X] - pt1[X];
  dely = pt2[Y] - pt1[Y];
  delz = pt2[Z] - pt1[Z];
  return (delx * delx + dely * dely + delz * delz);
}

/*
  DESCRIPTION

  Point-to-line:
  This function evaluates the point of projection (aka, the minimum distance
  point) from a given point to a line defined by two points. The 
  parameterization of the line is linear, ranging from 0 to 1 between the two
  points and less than 0.0 'below' the first point and greater than 1.0 
  'above' the second point. The parameter corresponding to this projection 
  point is returned. Separate functions provided for 2d and 3d,
  which wrapper the work-horse function to give the caller correct data-typing.

  NOTES

  The minimum distance is NOT returned but can be computed trivially as the
  distance between the input point and the minimum distance point.

  If the two input points are degenerate within MINDOUBLE, then an error code
  indicating degeneracy is returned.
*/

PWresult pwProjPtLn2d
(
  PWpoint2d pt, 
  PWpoint2d segpt1,
  PWpoint2d segpt2,
  PWpoint2d minpt,
  double *minpar
)
{
  return (proj_pt_ln ((double *) pt, (double *) segpt1, (double *) segpt2, 
           FALSE, (double *) minpt, minpar));
}

PWresult pwProjPtLn
(
  PWpoint pt, 
  PWpoint segpt1,
  PWpoint segpt2,
  PWpoint minpt,
  double *minpar
)
{
  return (proj_pt_ln ((double *) pt, (double *) segpt1, (double *) segpt2, 
           TRUE, (double *) minpt, minpar));
}

static PWresult proj_pt_ln
(
  double     *pt,
  double     *segpt1,
  double     *segpt2,
  PWboolean  is_3d,
  double     *minpt, 
  double     *minpar
)
{
  int i, dim;
  double dotp, seglensq;
  PWvector segvec, ptvec;
  PWresult result=PW_K_Success;

  dim = is_3d ? 3 : 2;
  dotp = 0.0;
  seglensq = 0.0;
  for (i=0; i<dim; i++)
  {
    segvec[i] = segpt2[i] - segpt1[i];
    ptvec[i] = pt[i] - segpt1[i];

    dotp += segvec[i] * ptvec[i];
    seglensq += segvec[i] * segvec[i];
  }

  if (seglensq <= MINDOUBLE)
  {
    *minpar = 0.0;
    result = SetInfo (PW_K_PathwayMath, PW_K_Degenerate);
  }
  else
  {
    *minpar = dotp / seglensq;
  }

  for (i=0; i<dim; i++)
  {
    minpt[i] = segpt1[i] + *minpar * segvec[i];
  }

wrapup:
  return (result);
}

/*
  DESCRIPTION

  Point-to-segment:
  This function returns the minimum distance squared between a given point and 
  a line segment. It will always compute the nearest point ON the line segment.
  So, if the min-dist point to the line defined by the segment is outside
  the segment, this function snaps to the appropriate end-point and returns
  the min-dist squared to this end-point. In addition, the corresponding 
  min-par (assuming the segment parameterized from 0 to 1) and the min-point 
  are returned as output arguments. Separate functions provided for 2d and 3d,
  which wrapper the work-horse function to give the caller correct data-typing.

  
  NOTES

  The output was left as the square of the length to avoid an unnecessary
  square-root computation in cases where the caller is simply trying to
  compare minimum distances. In such circumstances, the min-dist squared is
  a sufficient discriminator as the square increases monotonically. Also,
  it is trivial to obtain the true min-dist by taking the square-root.

  If the squared length of the input segment is zero (within MINDOUBLE) then 
  the min-dist point is always evaluated to the stop point.
*/

double pwMinDistSqPtSeg2d
(
  PWpoint2d pt,
  PWpoint2d segpt1,
  PWpoint2d segpt2,
  PWpoint2d minpt,
  double *minpar
)
{
  return (min_dist_sq_pt_seg ((double *) pt, 
          (double *) segpt1, (double *) segpt2, FALSE, 
          (double *) minpt, minpar));
}

double pwMinDistSqPtSeg
(
  PWpoint pt,
  PWpoint segpt1,
  PWpoint segpt2,
  PWpoint minpt,
  double *minpar
)
{
  return (min_dist_sq_pt_seg ((double *) pt, 
          (double *) segpt1, (double *) segpt2, TRUE, 
          (double *) minpt, minpar));
}

static double min_dist_sq_pt_seg 
(
  double    *pt,
  double    *segpt1, 
  double    *segpt2,
  PWboolean is_3d,
  double    *minpt,
  double    *minpar
)
{
  int size;
  double mindistsq;
  PWresult result=PW_K_Success; 

  result = proj_pt_ln (pt, segpt1, segpt2, is_3d, minpt, minpar);

  if (result != PW_K_Success || *minpar > 1.0)
  {
    size = is_3d ? sizeof (PWpoint) : sizeof (PWpoint2d);
    memcpy (minpt, segpt2, size);
    *minpar = 1.0;
    if (is_3d)
      mindistsq = pwDistSqPtPt (pt, segpt2); 
    else
      mindistsq = pwDistSqPtPt2d (pt, segpt2); 
  }
  else if (*minpar < 0.0)
  {
    size = is_3d ? sizeof (PWpoint) : sizeof (PWpoint2d);
    memcpy (minpt, segpt1, size);
    *minpar = 0.0;
    if (is_3d)
      mindistsq = pwDistSqPtPt (pt, segpt1); 
    else
      mindistsq = pwDistSqPtPt2d (pt, segpt1); 
  }
  else
  {
    if (is_3d)
      mindistsq = pwDistSqPtPt (pt, minpt); 
    else
      mindistsq = pwDistSqPtPt2d (pt, minpt); 
  }

  return (mindistsq);
}


/*
  DESCRIPTION

  Point-to-Polyline:
  This function returns the minimum distance squared between a given point and 
  a polyline. It will always compute the nearest point ON the polyline (and
  not on any line extension at the ends thereof). In addition, the 
  corresponding min-par (assuming a span-wise, linear parameterization with 
  each span ranging from 0 to 1) and the min-point are returned as output 
  arguments. Separate functions provided for 2d and 3d, which wrapper the
  work-horse function to give the caller correct data-typing.

  
  NOTES

  The output was left as the square of the length to avoid an unnecessary
  square-root computation in cases where the caller is simply trying to
  compare minimum distances. In such circumstances, the min-dist squared is
  a sufficient discriminator as the square increases monotonically. Also,
  it is trivial to obtain the true min-dist by taking the square-root.
*/

double pwMinDistSqPtPy2d
(
  PWpoint2d pt,
  int numpypts,
  PWpoint2d *pypts,
  PWpoint2d minpt,
  struct PWcvparam *minpar
)
{
  return (min_dist_sq_pt_py ((double *) pt, numpypts, (double *) pypts, FALSE,
           (double *) minpt, minpar));
}

double pwMinDistSqPtPy
(
  PWpoint pt,
  int numpypts,
  PWpoint *pypts,
  PWpoint minpt,
  struct PWcvparam *minpar
)
{
  return (min_dist_sq_pt_py ((double *) pt, numpypts, (double *) pypts, TRUE,
           (double *) minpt, minpar));
}

static double min_dist_sq_pt_py
(
  double            *pt,
  int               numpypts,
  double            *pypts,
  PWboolean         is_3d,
  double            *minpt,
  struct PWcvparam  *minpar
)
{
  PWresult PWsts;
  int      i, dim;
  double   min_sqdist, sqdist, dist, tminpt[3];
  struct   PWcvparam tminpar;

  dim = is_3d ? 3 : 2;

  minpar->spaninx = 0;
  min_sqdist = min_dist_sq_pt_seg (pt, &pypts[0], &pypts[dim], is_3d, minpt, 
                                   &minpar->spanpar);
  dist = sqrt(min_sqdist);

  for (i=1; i < numpypts - 1; i++)
  {
    if (is_3d)
      PWsts = pwProjPtRngPy (pt, 2, (PWpoint *) &pypts[i*dim], 
                             dist, tminpt, &tminpar);
    else
      PWsts = pwProjPtRngPy2d (pt, 2, (PWpoint2d *) &pypts[i*dim], 
                               dist, tminpt, &tminpar);  
    if (!IsError(PWsts)) 
    {
      sqdist = is_3d ? pwDistSqPtPt (pt, tminpt):
                       pwDistSqPtPt2d (pt, tminpt);
      if (sqdist < min_sqdist)
      {
        min_sqdist = sqdist;
        dist = sqrt (min_sqdist);
        memcpy (minpt, tminpt, dim * sizeof(double));
        minpar->spaninx = i;
        minpar->spanpar = tminpar.spanpar;
      }
    }
  }

  return (min_sqdist);
}

/*
  DESCRIPTION

  Point-to-Polyline (point within range):
  This function computes the minimum distance point between a given point
  and a polyline, where the given point is known to be within a given distance 
  of the polyline's geometry. This function is similar to it's counterpart fn,
  where the point's proximity to the polyline is not known. If this function 
  finds that this point is not within the input distance of any segment of
  this  polyline, it returns an error indicating this condition. This is the 
  function to be used whenever the point is known to be sitting on the
  polyline as it is much more efficient in the circumstance. 
  Separate functions provided for 2d and 3d.


  NOTES

  See the description and notes for the counterpart function where nothing
  can be said about the point's distance away from the polyline (the generic,
  vanilla, everyday min-dist function).

  This function does NOT return the minimum distance, but it can be trivially
  computed as the distance between the input point and the output min-dist
  point.
*/

PWresult pwProjPtRngPy2d
(
  PWpoint2d pt,
  int numpts,
  PWpoint2d *pts,
  double rngdist,
  PWpoint2d minpt,
  struct PWcvparam *minpar
)
{
  int i;
  double mindistsq, tmp_mindistsq, tmp_minpar;
  PWboolean valid=FALSE;
  PWrange2d ptrng;
  PWpoint2d tmp_minpt;

  memcpy (ptrng[MINIMUM], pt, sizeof (PWpoint2d));
  memcpy (ptrng[MAXIMUM], pt, sizeof (PWpoint2d));
  pwExpandRange2d (ptrng, rngdist);

  mindistsq = MAXDOUBLE;
  for (i=0; i<numpts-1; i++)
  {
    if (!pwIsOutsideSegRng2d ((PWpoint2d *) pts[i], ptrng))
    {
      if ((tmp_mindistsq = min_dist_sq_pt_seg ((double *) pt, 
                            (double *) pts[i], (double *) pts[i+1], FALSE, 
                            (double *) tmp_minpt, &tmp_minpar)) < mindistsq)
      {
        mindistsq = tmp_mindistsq;
        minpar->spaninx = i;
        minpar->spanpar = tmp_minpar;
        memcpy (minpt, tmp_minpt, sizeof (PWpoint2d));
        valid = TRUE;
      }
    }
  }

  return (valid ? PW_K_Success : SetError (PW_K_PathwayMath, PW_K_NotFound));
}

PWresult pwProjPtRngPy
(
  PWpoint pt,
  int numpts,
  PWpoint *pts,
  double rngdist,
  PWpoint minpt,
  struct PWcvparam *minpar
)
{
  int i;
  double mindistsq, tmp_mindistsq, tmp_minpar;
  PWboolean valid=FALSE;
  PWrange ptrng;
  PWpoint tmp_minpt;

  memcpy (ptrng[MINIMUM], pt, sizeof (PWpoint));
  memcpy (ptrng[MAXIMUM], pt, sizeof (PWpoint));
  pwExpandRange (ptrng, rngdist);

  mindistsq = MAXDOUBLE;
  for (i=0; i<numpts-1; i++)
  {
    if (!pwIsOutsideSegRng ((PWpoint *) pts[i], ptrng))
    {
      if ((tmp_mindistsq = min_dist_sq_pt_seg ((double *) pt, 
                            (double *) pts[i], (double *) pts[i+1], TRUE, 
                            (double *) tmp_minpt, &tmp_minpar)) < mindistsq)
      {
        mindistsq = tmp_mindistsq;
        minpar->spaninx = i;
        minpar->spanpar = tmp_minpar;
        memcpy (minpt, tmp_minpt, sizeof (PWpoint));
        valid = TRUE;
      }
    }
  }

  return (valid ? PW_K_Success : SetError (PW_K_PathwayMath, PW_K_NotFound));
}

/*
 * DESCRIPTION
 *
 *    Given the curve data and a point this function calculates the minimum
 *    distance point from the curve and the corresponding paramaeteric info. 
 *
 */
double pwMinDistSqPtCvdata
(
  double           *p_pt,       /* could be 2d or 3d depending on data type */
  struct PWcvdata  *p_cvdata,
  double           *p_minpt,    /* could be 2d or 3d depending on data type */
  struct PWcvparam *p_minpar
)
{
  /*
   * Validate the incoming arguments
   */
  if (!p_cvdata || !p_pt || !p_minpar)
    return MAXDOUBLE;

  /*
   * Evaluate the point
   */
  switch (p_cvdata->datatype)
  {
    case PWcvdata_pt2d :
    {
      p_minpar->spaninx = 0; 
      p_minpar->spanpar = 0; 
      memcpy (p_minpt, p_cvdata->data.pt2d, sizeof (PWpoint2d));
      return pwDistSqPtPt2d (p_minpt, p_pt); 
    }

    case PWcvdata_pt :
    {
      p_minpar->spaninx = 0; 
      p_minpar->spanpar = 0; 
      memcpy (p_minpt, p_cvdata->data.pt, sizeof (PWpoint));
      return pwDistSqPtPt (p_minpt, p_pt); 
    }

    case PWcvdata_py2d :
    {
      return pwMinDistSqPtPy2d (p_pt, p_cvdata->data.py2d.num_pts, 
                              p_cvdata->data.py2d.p_pts, p_minpt, 
                              p_minpar);
    }    

    case PWcvdata_py :
    {
      return pwMinDistSqPtPy (p_pt, p_cvdata->data.py.num_pts,
                             p_cvdata->data.py.p_pts, p_minpt,
                             p_minpar);
    }

    case PWcvdata_bspcv :
    case PWcvdata_gmbspcv :
    {
      BSrc   rc=BSSUCC;
      struct IGRbsp_curve *p_cv=NULL;
      double mdist=0.0;

      p_minpar->spaninx = 0;

      p_cv = (p_cvdata->datatype == PWcvdata_bspcv) ? p_cvdata->data.p_bspcv :
                                              p_cvdata->data.p_gmbspcv->bspcv;
      
      BSmdstptcv (p_cv, p_pt, &p_minpar->spanpar, p_minpt, &mdist, &rc);
      if (BSERROR(rc))
        return MAXDOUBLE;
      else
        return (mdist * mdist); 
    }
  
    default :
      return MAXDOUBLE;
  }
}
