#include <math.h>
#include <memory.h>
#include "bsvalues.h"
#include "bsdefs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "PWminimum.h"


#include "PWapi/lenvec.h"
#include "PWapi/crossp.h"
#include "PWapi/memfunc.h"

/*
  DESCRIPTION


  NOTES

*/

void pwOrthoVec2d
(
  PWvector2d  vec,
  PWvector2d  orthovec
)
{
  double len=0.0;

  len = pwLenVec2d (vec);
  if (len < MINDOUBLE)
  {
#ifdef DEBUG
   fprintf (stderr, "pwOrthoVec2d : Incoming vector is a degenerate one.\n");
#endif
   memcpy (orthovec, vec, sizeof (PWvector2d));
  }
  else
  {
    orthovec[X] = vec[X] / len;
    orthovec[Y] = vec[Y] / len;
  }
}

void pwOrthoVec
(
  PWvector  vec,
  PWvector  normal,
  PWvector  orthovec
)
{
  long   BSmsg=BSSUCC;
  double partol=0.0, len=0.0;
  int    inx=0, inx0=0, inx1=1, inx2=2;


  if (normal)
  {
    pwCross (vec, normal, orthovec);
    
    len = pwLenVec (vec);
    if (len > MINDOUBLE)
    {
      orthovec [X] /= len;
      orthovec [Y] /= len;
      orthovec [Z] /= len;
    }
  }
  else
  {

    /*
     * get the current parametric tolerance.
     */
    BSEXTRACTPAR (&BSmsg, BSTOLPARAM, partol);

    /*
     * get the vector indices in the ascending order of their values.
     */
    if (fabs (vec[inx0]) > fabs (vec[inx1]))
    {
      pwSwapInt (&inx0, &inx1);
    }
  
    if (fabs (vec[inx1]) > fabs (vec[inx2]))
    {
      pwSwapInt (&inx1, &inx2);
    }
  
    if (fabs (vec[inx0]) > fabs (vec[inx1]))
    {
      pwSwapInt (&inx0, &inx1);
    }
  
    if (fabs (vec[inx2]) > partol)
    {
      len = sqrt (vec[inx1] * vec[inx1] + vec[inx2] * vec[inx2]);
      
      orthovec[inx0] = 0.0;
      orthovec[inx1] = vec[inx2] / len; 
      orthovec[inx2] = - vec[inx1] / len; 
    }
    else
    {
      orthovec[X] = 1.0;
      orthovec[Y] = 0.0;
      orthovec[Z] = 0.0;
    }
  }
}
