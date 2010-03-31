/*
 Description

 This function computes an arrow head for a vector that has
 a suitable size. The argument "lenfact_fact" should be set to 1.0 to
 obtain default behaviour for the size of the vector. Factor less than
 1.0 shrink the arrow and factors greater than 1.0 enlarge the arrow.
 The arrow always maintain a slope of 1:2.

 History

 PP  : Unknown  : Creation
 SS  : 08/26/87 : Modified it to accept display_mode and also decide
                   that display length on it's own.
 rlw : 07/21/88 : Fixed a problem in that some calls to fabs() were needed.
                  Also modified to return two orthogonal arrowheads and
                  according renamed the function.
 SS  : 05/02/89 : Changed length factors to change the size of the arrowhead.
 SS  : 09/09/91 : Added arg to control length factor.
 Sudha 07/06/93 : Modified for BSprototypes ansification
*/

#include "EMS.h"
#include <math.h>
#include "emsdef.h"
#include "igrtypedef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bslenvec.h"
#include "bscrossp.h"

#define X 0
#define Y 1
#define Z 2

/*
 * The following factors define the aspect ratio of the arrow head 
 * with respect to the vector. The angle between the vector and a side
 * of the arrow (in the plane defined by the three points):
 * angle in degrees = 180 * arctan (1/2). 
 */

#define LENGTH_FACTOR  0.85

void EMgetarrowheads (msg, vec, arrow, lenfact_fact)
IGRlong *msg;
IGRdouble vec[2][3];
IGRdouble arrow[2][3][3];
IGRdouble lenfact_fact;
{
  IGRboolean stat_func;
  IGRint i, j;
  IGRlong msg_loc;
  IGRdouble delta[3], norm[2][3], veclen, val1, val2, lf1, lf2;

  *msg = EMS_S_Success;

  for (i=X; i<=Z; i++)
   delta[i] = vec[1][i] - vec[0][i];
  veclen = BSlenvec (&msg_loc, delta);

  /*
   * Obtain a unit-normal to the incoming
   * vector.
   */

  norm[0][X] = norm[0][Y] = norm[0][Z] = 0.0;  
  if (fabs(delta[X]) < MINDOUBLE)      /* rlw - 07/21/88 - added fabs() */
    norm[0][X] = 1.0;
  else if (fabs(delta[Y]) < MINDOUBLE)
    norm[0][Y] = 1.0;
  else if (fabs(delta[Z]) < MINDOUBLE)
    norm[0][Z] = 1.0;
  else
    {
    norm[0][X] = 1.0 / delta[X];
    norm[0][Y] = 1.0 / delta[Y];
    norm[0][Z] = - 2.0 / delta[Z];
    stat_func = BSnorvec (&msg_loc, &norm[0][0]);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_NoSolution, ret_end);
    }

  /*
   * Generate another normal which is perpendicular to the normal
   * already computed and to the input vector.
   *
   * 07/21/88 - rlw - Added this stuff
   */

   {
    IGRvector	vector;

    vector[0] = delta[0];
    vector[1] = delta[1];
    vector[2] = delta[2];
    stat_func = BSnorvec (&msg_loc, vector);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_NoSolution, ret_end);
    stat_func = BScrossp (&msg_loc, vector, &norm[0][0], &norm[1][0]);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_NoSolution, ret_end);
   }

  /*
   * Compute the three points defining
   * the arrow.
   */

  lf1 = 1.0 - ((1.0 - LENGTH_FACTOR) * lenfact_fact);
  lf2 = (1 - lf1) / 2.0;
  for (j = 0; j < 2; j++)
   {
    for (i=X; i<=Z; i++)
     {
     val1 = vec[0][i] + lf1 * delta[i];
     val2 = lf2 * veclen * norm[j][i];
     arrow[j][0][i] = val1 + val2;
     arrow[j][1][i] = vec[1][i];
     arrow[j][2][i] = val1 - val2;
     }
   }
    
ret_end:;
}
