/* $Id: VRLnUtil.I,v 1.2 2002/04/10 20:44:48 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRLnUtil.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRLnUtil.I,v $
 *	Revision 1.2  2002/04/10 20:44:48  louis
 *	TR5649-Standardize tolerance
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:12  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/18  00:31:32  pinnacle
# Replaced: vrtools/VRLnUtil.I for:  by r240_int for route240
#
 *
 * History:
	01/17/96   tlb	Add prototypes
 *      04/08/02    law TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

/****************************************************************************/
/*     FILE NAME   -  VRLnUtil.I                                            */
/*                                                                          */
/*     CHANGE HISTORY                                                       */
/*                                                                          */
/*     01-DEC-93  hv       Initial Version                                  */
/*                                                                          */
/****************************************************************************/

class implementation Root;

#include <stdio.h>
#include <float.h>
#include <math.h>
#include "igrtypedef.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsvalues.h"
#include "bsparameters.h"
#include "VRMath.h"
#include "VRparamdef.h"
#include "VRDbStruct.h"
#include "VRdimdef.h"
#include "VRdef.h"
#include "VRcompdef.h"
#include "VRStLn.h"
#include "bslenvec.h"
#include "bsnorvec.h"
#include "bsmkvec.h"

/*
#define MY_DEBUG
*/

#define M_PI_4          (M_PI/4.0)

int VR_colinear(IGRdouble *p1, IGRdouble *p2, IGRdouble *p3)
{
  IGRdouble       Vec1[3],Vec2[3];
  BSrc            rc;
  IGRint          i;
  int             bRet = TRUE;

  BSmkvec (&rc, Vec1, p1, p2);
  BSnorvec (&rc, Vec1);
  BSmkvec (&rc, Vec2, p2, p3);
  BSnorvec (&rc, Vec2);

  for (i=0; i<3; i++)
    if (fabs (Vec1[i] - Vec2[i]) > VRGetTol(VR_DELTA_TOL)) bRet = FALSE;

  return (bRet);
}


void VR_enforceMinDist( IGRdouble *p1, IGRdouble *p2, IGRdouble minDist )
{
  IGRint          i;
  BSrc            rc;
  IGRdouble       Vec1[3];
  IGRdouble       dLen;

  IGRdouble       BSlenvec();

  /*C  Make a vector p1 to p2 */

  BSmkvec (&rc, Vec1, p1, p2);
  dLen = BSlenvec (&rc, Vec1);

  if (dLen <= minDist)
  {
    BSnorvec (&rc, Vec1);

    for (i=0; i<3; i++)
      p2[i] = p1[i] + Vec1[i] * minDist;
  }

  return;
}

/***************************************************************************
        Utility function: snap radians to multiples of M_PI_4
***************************************************************************/
IGRboolean VR_snapAngleRad( angleRad, deltaRad )
IGRdouble *angleRad;
IGRdouble deltaRad;
{
    IGRdouble x,next,nearest;
    IGRboolean yes;

    /*C Force within (-M_PI, M_PI) range   */

    x = *angleRad;

    while ( x > M_PI )
        x = x - M_PI;
    while ( x <= (- M_PI))
        x = x + M_PI;

    /*C avoid function calls such as fmod */

    /*C snap if within deltaRad of 45 degree angles */
    yes = FALSE;
    for( nearest = next = -M_PI; next <= M_PI; next = next + M_PI_4 )
    {
        if( fabs(x - next) <= deltaRad )
        {
           yes = TRUE;
           if( fabs(x - next) < fabs(x - nearest) ) nearest = next;
        }
    }
    if ( yes ) *angleRad = x;

    return( yes );

}

/***************************************************************************
        Enforce slope constraint on line
***************************************************************************/
void VR_lineSnap_mod45(point1, point2)
IGRdouble       *point1;
IGRdouble       *point2;

{
  IGRdouble dx,dy,dz;
  IGRdouble sx,sy,sz;
  IGRdouble dLgt, dFac;

  /*C Allow point2 at 45 degree angles w.r.t point1 */

  dx = point2[0] - point1[0];
  dy = point2[1] - point1[1];
  dz = point2[2] - point1[2];

#ifdef MY_DEBUG
  printf (" coords in  %f %f %f\n",point2[0],point2[1],point2[2]);
#endif

  /*   get sign   */
  sx = (dx>0) ? 1.0 : -1.0;
  sy = (dy>0) ? 1.0 : -1.0;
  sz = (dz>0) ? 1.0 : -1.0;

  /*   normalize  */
  dx *= sx;
  dy *= sy;
  dz *= sz;

  dLgt = sqrt(dx*dx + dy*dy + dz*dz);
  dFac = dLgt / 15.0;   /*  snap factor ??   */

  /*  snap to 90 deg    */

  if (dx < dFac) dx = 0.0;
  if (dy < dFac) dy = 0.0;
  if (dz < dFac) dz = 0.0;

  /*  snap to 45 deg   */

  if (fabs(dx-dy) < dFac)
  {
    if (dx > dy) dx = dy;
    else         dy = dx;
  }

  if (fabs(dx-dz) < dFac)
  {
    if (dx > dz) dx = dz;
    else         dz = dx;
  }

  if (fabs(dz-dy) < dFac)
  {
    if (dz > dy) dz = dy;
    else         dy = dz;
  }

  point2[0] = point1[0] + dx * sx;
  point2[1] = point1[1] + dy * sy;
  point2[2] = point1[2] + dz * sz;

#ifdef MY_DEBUG
  printf (" coords out %f %f %f\n",point2[0],point2[1],point2[2]);
#endif

  return;
}

end implementation Root;

