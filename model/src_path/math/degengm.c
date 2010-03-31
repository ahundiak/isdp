#include <math.h>
#include <memory.h>
#include "igrtypedef.h"
#include "igr.h"
#include "PWminimum.h"
#include "PWgmdata.h"

#include "bs.h"
#include "bserr.h"
#include "bsgeom_cvsf.h"

#include "PWapi/samepts.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/degengm.h"

/* Internal macros */

#define sqr(x)  ((x) * (x))

/* Internal Prototypes */

static int num_degen_spans
(
  int num_pts,
  double *pts,
  PWboolean is_3d,
  double tol
);

static int remove_degen_spans
(
  int num_inpts,
  double *inpts,
  int *num_outpts,
  double *outpts,
  PWboolean is_3d,
  double tol
);

static PWboolean is_degen_py
(
  int numpts,
  double *pts,
  PWboolean is_3d,
  double tol
);


/*
  DESCRIPTION
  
  Given a set of points, this function counts the number of degenerate spans
  w.r.t the given tolerance. Separate functions provided for 2d and 3d,
  which wrapper the work-horse function to give the caller correct data-typing.

  NOTES

  None.
*/

int pwNumDegenSpans2d
(
  int num_pts, 
  PWpoint2d *pts,
  double tol
)
{
  return (num_degen_spans (num_pts, (double *) pts, FALSE, tol));
}

int pwNumDegenSpans
(
  int num_pts, 
  PWpoint *pts,
  double tol
)
{
  return (num_degen_spans (num_pts, (double *) pts, TRUE, tol));
}

static int num_degen_spans 
(
  int num_pts,
  double *pts,
  PWboolean is_3d,
  double tol
)
{
  PWboolean is_degen=FALSE;
  int inx, dim, degen_count;
  double *pt1, *pt2;

  /*
   * Initialize
   */

  dim = is_3d ? 3 : 2;
  pt1 = pts;
  pt2 = pt1 + dim;

  degen_count = 0;

  /*
   * Check each span for degeneracy. If the span is degenerate add to the
   * count.
   */
  
  for (inx=0; inx<num_pts-1; inx++)
  {
    if (!(is_degen = 
           is_3d ? pwIsSamePt (pt1, pt2, tol) : pwIsSamePt2d (pt1, pt2, tol)))
    {
      pt1 = pt2;
    }

    if (is_degen)
      degen_count++;

    pt2 += dim;
  }

  return (degen_count);
}

/*
  DESCRIPTION
 
  Given an input set of points, this function removes all degenerate spans
  (wrt the input tol) and returns the "cleaned" up set of points  in the 
  output array. The memory for the output array is assumed to be sufficiently
  allocated by the caller (to be safe, this memory should be able to hold
  all the input points). This function does not handle the output array
  being the same as the input array. Separate functions provided for 2d and 3d,
  which wrapper the work-horse function to give the caller correct data-typing.

  The first and the last points are always maintained.

  NOTES

  None.
*/

int pwRemoveDegenSpans2d
(
  int num_inpts,
  PWpoint2d *inpts,
  int *num_outpts,
  PWpoint2d *outpts,
  double tol
)
{
  return (remove_degen_spans (num_inpts, (double *) inpts, 
           num_outpts, (double *) outpts, FALSE, tol));
}

int pwRemoveDegenSpans
(
  int num_inpts,
  PWpoint *inpts,
  int *num_outpts,
  PWpoint *outpts,
  double tol
)
{
  return (remove_degen_spans (num_inpts, (double *) inpts, 
           num_outpts, (double *) outpts, TRUE, tol));
}

static int remove_degen_spans 
(
  int num_inpts,
  double *inpts,
  int *num_outpts,
  double *outpts,
  PWboolean is_3d, 
  double tol
)
{
  PWboolean is_degen=FALSE;
  int inx, dim, degen_count;
  double *pt1, *pt2, *outpt;

  *num_outpts = 0;

  /*
   * Initialize
   */

  dim = is_3d ? 3 : 2;
  pt1 = inpts;
  pt2 = pt1 + dim;
  outpt = outpts;

  degen_count = 0;

  /*
   * Add the first point into the output array
   */

  memcpy (outpt, pt1, dim * sizeof (double));
  outpt += dim;
  (*num_outpts)++;

  /*
   * Check each span for degeneracy. If the span is not degenerate add the
   * end-point of this span (pt2) to the output array. 
   */
  
  for (inx=0; inx<num_inpts-1; inx++)
  {
    if (!(is_degen = 
           is_3d ? pwIsSamePt (pt1, pt2, tol) : pwIsSamePt2d (pt1, pt2, tol)))
    {
      memcpy (outpt, pt2, dim * sizeof (double));
      outpt += dim;
      (*num_outpts)++;
      pt1 = pt2;
    }

    if (is_degen)
      degen_count++;

    pt2 += dim;
  }

  /*
   * If the last span was degenerate, change the last point in the output
   * array to the last point of the input array.
   */

  if (is_degen)
  {
    if (degen_count == num_inpts - 1)
    {
      /*
       * All the spans in the input list are degenerate. But, as the startegy
       * is to return first and last points always, increment the number of 
       * output points i.e. made it atleast equal to two.
       */

      (*num_outpts)++;
    }

    memcpy (&outpts[dim*((*num_outpts)-1)], &inpts[dim*(num_inpts-1)], 
     dim * sizeof (double));
  }

  return (degen_count);
}


/*
  DESCRIPTION

  This function checks whether a given polyline is degenerate wrt to an
  input tolerance. Separate functions for 2d and 3d.

  NOTES

  None.
*/

PWboolean pwIsDegenPy2d 
(
  int numpts,
  PWpoint2d *pts,
  double tol
)
{
  return (is_degen_py (numpts, (double *) pts, FALSE, tol));
}

PWboolean pwIsDegenPy
(
  int numpts,
  PWpoint *pts,
  double tol
)
{
  return (is_degen_py (numpts, (double *) pts, TRUE, tol));
}

static PWboolean is_degen_py
(
  int numpts,
  double *pts, 
  PWboolean is_3d, 
  double tol
)
{
  PWboolean is_degen=TRUE;
  int i, dim;
  double *p_pts, cumdist=0.0;

  dim = is_3d ? 3 : 2;
  p_pts = pts;

  for (i=0; i<numpts-1; i++)
  {
    cumdist += (is_3d ? pwDistPtPt (p_pts, p_pts+dim) : 
                        pwDistPtPt2d (p_pts, p_pts+dim));
    if (cumdist > tol)
    {
      is_degen = FALSE;
      break;
    }
    p_pts += dim;
  }

  return (is_degen);
}

/*
  DESCRIPTION
 
  Given a B-spline curve and tolerance, it checks for the degeneracy of
  the curve geometry against the input tolerance tol. Returns TRUE if it
  is degenrate, otherwise FALSE.

  NOTES

  None.
*/

PWboolean pwIsCvDegen
(
  struct IGRbsp_curve  *p_cv,
  double               tol
)
{
  /* local temporary variables */
  int i,j;
  double sqdist, sqtol, origin[3];
 
  sqtol = tol * tol;
  origin[0] = origin[1] = origin[2] = 0.0;

  /* 
   * calculate the average point from the poles which is origin.
   */
  if (p_cv->rational)
  {
    for (i=0; i<p_cv->num_poles; i++)
    {
      for (j=0; j<3; j++)
        origin[j] += p_cv->poles[i*3+j] / p_cv->weights[i];
    }
  }
  else
  {
    for (i=0; i<p_cv->num_poles; i++)
    {
      for (j=0; j<3; j++)
        origin[j] += p_cv->poles[i*3+j];
    }
  }

  for (i=0; i<3; i++)
    origin[i] /= p_cv->num_poles;

  /*
   * If any point is out of the input tolerance from the average point, return
   * FALSE otherwise TRUE.
   */
  if (p_cv->rational)
  {
    for (i=0; i<p_cv->num_poles; i++)
    {
      sqdist = sqr(origin[0] - (p_cv->poles[i*3] / p_cv->weights[i])) +
               sqr(origin[1] - (p_cv->poles[i*3+1] / p_cv->weights[i])) +
               sqr(origin[2] - (p_cv->poles[i*3+2] / p_cv->weights[i]));
      if (sqdist > sqtol)
        return FALSE;
    }
  }
  else
  {
    for (i=0; i<p_cv->num_poles; i++)
    {
      sqdist = sqr(origin[0] - p_cv->poles[i*3]) +
               sqr(origin[1] - p_cv->poles[i*3+1]) +
               sqr(origin[2] - p_cv->poles[i*3+2]);
      if (sqdist > sqtol)
        return FALSE;
    }
  }

  return TRUE;
}

/*
  DESCRIPTION

  Given the curve data and tolerance, it checks for the degeneracy of the 
  curve geometry against the input tolerance tol. Returns TRUE if it is 
  degenrate, otherwise FALSE.

  NOTES

  None.
*/

PWboolean pwIsDegenCvdata
(
  struct PWcvdata *p_cvdata,
  double lentol
)
{
  switch (p_cvdata->datatype)
  {
    case PWcvdata_pt2d :
    case PWcvdata_pt :
      return TRUE;
  
    case PWcvdata_py2d : 
      return pwIsDegenPy2d (p_cvdata->data.py2d.num_pts, 
                            p_cvdata->data.py2d.p_pts, lentol);

    case PWcvdata_py : 
      return pwIsDegenPy2d (p_cvdata->data.py2d.num_pts, 
                            p_cvdata->data.py2d.p_pts, lentol);

    case PWcvdata_bspcv :
      return pwIsCvDegen (p_cvdata->data.p_bspcv, lentol);

    case PWcvdata_gmbspcv :
      return pwIsCvDegen (p_cvdata->data.p_gmbspcv->bspcv, lentol);

    default :
      return FALSE;
  }
}
