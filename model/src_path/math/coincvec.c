#include <alloca.h>
#include <math.h>
#include "bsvalues.h"
#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/normvec.h"
#include "PWapi/dotp.h"
#include "PWapi/angtol.h"

/* Internal Prototypes */

static PWresult coinc_vec
(
  int numvecs,
  double *vecs,
  PWboolean is_3d,
  int *num_coinc_sets,
  int *num_vecs_in_set,
  int *vecs_in_set
);

/*
  DESCRIPTION

  These functions take in an array of 'numvecs' vectors that need not
  be normalized and checks them for duplicates or coincident within the system 
  angle-tolerance. If any duplicates are found these are returned as sets.
  'num_coinc_sets' returns the number of coincident sets that exist,
  'num_vecs_in_set' is an output array of numbers indicating how many vectors
  there are in each such set and 'vecs_in_set' is a contiguous array of
  indices indicating the vectors in each set. So if you wanted to know the
  vectors in the nth set, 
     you would find that,
       number of vectors in that set = num_vecs_in_set[n], say N.
     Let, number of vectors in all the n-1 set preceding this one be T.
     then, 
       indices of the vectors in the nth set are:
        vecs_in_set[T], vecs_in_set[T+1], ..., vecs_in_set[T+N-1]

  The memory for num_vecs_in_set is a maximum of 'numvecs/2'.
  The memory for vecs_in_set can be set to a maximum of 'numvecs'.


  NOTES

  All output memory must be allocated by the caller.
*/

PWresult pwCoincVec2d 
(
  int numvecs,
  PWvector2d *vecs,
  int *num_coinc_sets,
  int *num_vecs_in_set,
  int *vecs_in_set
)
{
  return (coinc_vec (numvecs, (double *) vecs, FALSE, 
           num_coinc_sets, num_vecs_in_set, vecs_in_set));
}

PWresult pwCoincVec
(
  int numvecs,
  PWvector *vecs,
  int *num_coinc_sets,
  int *num_vecs_in_set,
  int *vecs_in_set
)
{
  return (coinc_vec (numvecs, (double *) vecs, TRUE, 
           num_coinc_sets, num_vecs_in_set, vecs_in_set));
}

static PWresult coinc_vec
(
  int numvecs,
  double *vecs,
  PWboolean is_3d,
  int *num_coinc_sets,
  int *num_vecs_in_set,
  int *vecs_in_set
)
{
  int i, di, j, dj, n, dim, tmp_num_coinc, already_coinc;
  double dotp, costol, *nvecs;
  PWboolean newset;
  PWresult result=PW_K_Success;

  *num_coinc_sets = 0;

  dim = is_3d ? 3 : 2;

  /*
   * Normalize all the input vectors and stpre these in a local
   * array.
   */

  nvecs = (double *) alloca (numvecs * sizeof (double) * dim);
  for (i=0, di=0; i<numvecs; i++, di+=dim)
  {
    if (is_3d)
      result = pwNormVec (&vecs[di], &nvecs[di]);
    else
      result = pwNormVec2d (&vecs[di], &nvecs[di]);
    OnErrorCode (result, wrapup);
  }

  /*
   * Cycle through these vectors successively determining which pairs of them
   * give a dot-product of 1.0 (within tol). These are recorded as the
   * coincident ones and the output args updated correctly.
   */

  tmp_num_coinc = 0;
  costol = pwGetCosZeroAngTol();
  for (i=0, di=0; i<numvecs-1; i++, di+=dim)
  {
    for (already_coinc=FALSE, n=0; n<tmp_num_coinc && !already_coinc; n++)
      if (vecs_in_set[n] == i)
        already_coinc = TRUE;

    if (already_coinc)
      continue;

    newset = TRUE;
    for (j=i+1, dj=di+dim; j<numvecs; dj+=dim)
    {
      for (already_coinc=FALSE, n=0; n<tmp_num_coinc && !already_coinc; n++)
        if (vecs_in_set[n] == i)
          already_coinc = TRUE;
  
      if (already_coinc)
        continue;

      if (is_3d)
        dotp = pwDot (&nvecs[di], &nvecs[dj]);
      else
        dotp = pwDot2d (&nvecs[di], &nvecs[dj]);
      if (dotp <= costol)
      {
        if (newset)
        {
          (*num_coinc_sets)++;
          num_vecs_in_set[*num_coinc_sets-1] = 2;
          vecs_in_set[tmp_num_coinc] = i;
          tmp_num_coinc++;
          newset = FALSE;
        }
        else
        {
          num_vecs_in_set[*num_coinc_sets-1]++;
        }
        vecs_in_set[tmp_num_coinc] = j;
        tmp_num_coinc++;
      }
    }
  }

wrapup:
  return (result);
}
