/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This function finds the point lying on some line-segment defined
    in the uv-space of a given surface that most closely matches a given
    model-space point. A seed parameter on the input curve geometry is
    given to start the iteration. 

  HISTORY

    SS  :  06/02/88  :  Creation
*/

#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "emserr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bssfeval.h"
#include "bsdistptpt.h"

/*
 * An estimate of the maximum number of steps within which converggence
 * should be reached. If the number of steps required is greater than
 * this the search will stop and the current point is returned as the
 * best one.
 */

#define MAX_ITERATIONS  100

/*
 * If the stepsize is smaller than this value, increase it to atleast this
 * value. This is indicative of the maximum number of divisions that the
 * input segment can be divided into.
 */

#define MIN_STEP_SIZE 0.00001

#define U 0
#define V 1

#define INCR 0
#define DECR 1

void EMsfexactpt (msg, sf, uvseg, xyzpt, itpar, ituvpt, itxyzpt, dist)
IGRlong *msg;
struct IGRbsp_surface *sf;
IGRdouble *uvseg, *xyzpt;
IGRdouble *itpar, *ituvpt, *itxyzpt, *dist;
{
  IGRboolean stat_func, newfound, terminate, revdir;
  IGRshort direction;
  IGRint itercount, blksize2, blksize3;
  IGRlong msg_loc;
  IGRdouble chkuvpt[2];
  IGRpoint  startxyzpt, stopxyzpt, chkxyzpt;
  IGRdouble lentol, len, chkdist, stepsize, newpar;
  
  *msg = EMS_S_Success;

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
  blksize2 = 2 * sizeof (IGRdouble);
  blksize3 = 3 * sizeof (IGRdouble);

  /*
   * Calculate the initial or seed-point in the model-space and also
   * distance between this point and the target xyz-pt.
   */

  ituvpt[U] = uvseg[U] + *itpar * (uvseg[U+2] - uvseg[U]);
  ituvpt[V] = uvseg[V] + *itpar * (uvseg[V+2] - uvseg[V]);
  BSsfeval (sf, ituvpt[U], ituvpt[V], 0, (IGRpoint *)itxyzpt, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidArg, ret_end);
  *dist = BSdistptpt (&msg_loc, xyzpt, itxyzpt);

  /*
   * Obtain step-size by calculating how many "lentols" exist within
   * the iteration-segment, model-space counterpart.
   */

  BSsfeval (sf, uvseg[U], uvseg[V], 0, (IGRpoint *)startxyzpt, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidArg, ret_end);
  BSsfeval (sf, uvseg[U+2], uvseg[V+2], 0, (IGRpoint *)stopxyzpt, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidArg, ret_end);
  len = BSdistptpt (&msg_loc, startxyzpt, stopxyzpt);
  stepsize = 1.0 / (len / lentol);
  if (stepsize < MIN_STEP_SIZE)
    stepsize = MIN_STEP_SIZE;

  /*
   * Stepping alternately in the increasing and decreasing paramteric 
   * direction, try and find the best point. The moment a point is found
   * better than the input, the direction is frozen and the best in this
   * direction is output. The other direction is assumed to be worse
   * than this. A check is made each time to make sure the
   * parameter is restricted to within the 0.0 - 1.0 parameteric space.
   */

  newfound = FALSE;
  terminate = FALSE;
  itercount = 0;
  for (direction=INCR; direction<=DECR; direction++)
    {
    revdir = FALSE;
    while (!revdir && !terminate && itercount < MAX_ITERATIONS)
      {
      newpar = *itpar + (direction == INCR ? stepsize : -stepsize);

      if (newpar >= 0.0 && newpar <= 1.0)
        {
        chkuvpt[U] = uvseg[U] + newpar * (uvseg[U+2] - uvseg[U]);
        chkuvpt[V] = uvseg[V] + newpar * (uvseg[V+2] - uvseg[V]);
        BSsfeval (sf, chkuvpt[U], chkuvpt[V], 0, (IGRpoint *)chkxyzpt, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidArg, ret_end);
        chkdist = BSdistptpt (&msg_loc, xyzpt, chkxyzpt);
        if (chkdist < *dist)
          {
          *itpar = newpar;
          OM_BLOCK_MOVE (chkuvpt, ituvpt, blksize2);
          OM_BLOCK_MOVE (chkxyzpt, itxyzpt, blksize3);
          *dist = chkdist;
          itercount++;
          newfound = TRUE;
          }
        else if (newfound)
          terminate = TRUE;
        else
          revdir = TRUE;
        }
      else if (newfound)
        terminate = TRUE;
      else
        revdir = TRUE;
      }

    if (terminate)
      break;
    }

ret_end:
  stat_func = TRUE;
  EMWRAPUP (*msg, stat_func, "EMsfexactpt");
}

