#include <alloca.h>
#include <math.h>
#include "bsvalues.h"
#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/normvec.h"
#include "PWapi/angmeas.h"
#include "PWapi/memfunc.h"
#include "PWapi/angtol.h"
#include "PWapi/angle.h"

/*
  DESCRIPTION

  These functions take in an array of 'numvecs' vectors that need not
  be normalized and sorts them with respect to the first vector of the array
  in a counter-clockwise manner. Separate functions are provided to handle
  the 2d and 3d vectors. In the case of 3d, ambiguity arises as to the viewing
  direction of the plane to determine clockwise from counter-clockwise.
  In this case, a view vector pointing towards the eye of the observer is
  also input. This view vector need not be exactly perpendicular to the
  plane, but must have a component in the correct perpendicular direction.
  No default is accepted for the view vector and it must be provided.

  The output of the sort is the array of indices of
  the input vectors being returned in the order of the sort. The index
  contained in the first element will always be 0. Thus the nth vector in the
  sort will be vecs[sort_indices[n]].

  The caller must allocate space for numvecs integers in the output
  argument - sort_indices.

  If any of the input vectors was degenerate, an error code is returned
  indicating degeneracy and no valid output should be expected in this case.

  NOTES

  If some of the input vectors have the same direction their relative position
  in the sort is arbitrary with respect to each other.
*/

PWresult pwSortVec2d 
(
  int numvecs,
  PWvector2d *vecs,
  int *sort_indices
)
{
  int i, j;
  double *angle=NULL, angtol;
  PWresult result=PW_K_Success;

  /*
   * Obtain the angle-measures of each of the vectors w.r.t to the
   * first one.
   */

  angle = (double *) alloca ((numvecs + 1) * sizeof (double));

  angle[0] = 0.0;

  for (i=0, j=1; j<numvecs; i++, j++)
  {
    result = pwAngle2d (vecs[0], vecs[j], &angle[j]);
    OnErrorCode (result, wrapup);
  }

  angle[numvecs] = 2.0*M_PI;

  /*
   * Re-arrange the initialized sort-index array in accordance with
   * a bubble-sort on the angle-measures. Only the elements indexed
   * from 1 onwards are considered.
   */

  for (i=0; i<numvecs; i++)
  {
    sort_indices[i] = i;
  }

  for (i=1; i<numvecs-1; i++)
  {
    for (j=i+1; j<numvecs; j++)
    {
      if (angle[i] > angle[j])
      {
        pwSwapDouble (&angle[i], &angle[j]);
        pwSwapInt (&sort_indices[i], &sort_indices[j]);
      }
    }
  }

  /*
   * get the angle tolerance and check whether the angle measures are cloes by
   */
  angtol = pwGetZeroAngTolRad();

  for (i=0; i<numvecs; i++)
    if (fabs (angle[i+1] - angle[i]) < angtol)
      return SetInfo (PW_K_PathwayMath, PW_K_Ambiguous);


wrapup:
  return (result);
}

PWresult pwSortVec 
(
  int numvecs,
  PWvector *vecs,
  PWvector dirvec,
  int *sort_indices
)
{
  int      i, j;
  double   *angle=NULL, angtol;
  PWvector ndirvec;
  PWresult result=PW_K_Success;

  /*
   * Obtain the angle-measures of each of the vectors w.r.t to the
   * first one.
   */
  angle = (double *) alloca ((numvecs+1) * sizeof (double));
  OnErrorState (!angle, result, SetError (0, PW_K_DynamicMemory), wrapup);

  result = pwNormVec (dirvec, ndirvec);
  OnErrorCode (result, wrapup);

  angle[0] = 0.0;

  for (i=0, j=1; j<numvecs; i++, j++)
  {
    result = pwAngle (vecs[0], vecs[j], ndirvec, &angle[j]);
    OnErrorCode (result, wrapup);
  }

  angle[numvecs] = 2.0*M_PI; 

  /*
   * Re-arrange the initialized sort-index array in accordance with
   * a bubble-sort on the angle-measures. Only the elements indexed
   * from 1 onwards are considered.
   */

  for (i=0; i<numvecs; i++)
  {
    sort_indices[i] = i;
  }

  for (i=1; i<numvecs-1; i++)
  {
    for (j=i+1; j<numvecs; j++)
    {
      if (angle[i] > angle[j])
      {
        pwSwapDouble (&angle[i], &angle[j]);
        pwSwapInt (&sort_indices[i], &sort_indices[j]);
      }
    }
  }

  /*
   * get the angle tolerance and check whether the angle measures are cloes by
   */
  angtol = pwGetZeroAngTolRad();

  for (i=0; i<numvecs; i++)
    if (fabs (angle[i+1] - angle[i]) < angtol)
      return SetInfo (PW_K_PathwayMath, PW_K_Ambiguous);

wrapup:
  return (result);
}

