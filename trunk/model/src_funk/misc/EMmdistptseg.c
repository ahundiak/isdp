/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */

#include "EMS.h"

/*

 HISTORY

    Sudha  07/09/93  :  Modified for BSprototypes anisfication
    SCW    02/13/97  :  Changed emsmacros inclusion to emsmacros_c



  This function returns the minimum distance-squared to a segment 
  relative to a given point. The parameter on the segment (the 
  parameterization being assumed to be from 0.0 to 1.0) at which the
  minimum distance point is obtained is also returned as an output
  argument. 

  The return code is either EMS_S_Success or EMS_E_InvalidArg. The only
  case where EMS_E_InvalidArg is returned is when the value of "dim" is not
  one of {1, 2, 3}. In that case the value returned is -1, for want of a
  better value to return.
*/

/* include "igr.h"*/

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

#include <math.h>
#include "msdef.h"
#include "emsmacros_c.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "bserr.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "bscrossp.h"

#define X 0
#define Y 1
#define Z 2

IGRdouble EMmdistptseg (msg, segpt1, segpt2, pt, dim, par, lensq, fromstartsq)
IGRlong *msg;
IGRdouble *segpt1, *segpt2, *pt;
IGRshort dim;
IGRdouble *par, *lensq, *fromstartsq;
{
  IGRlong msg_loc;
  IGRdouble segvec[3], ptvec[3];
  IGRdouble dotp, crossp, seglen;

  *msg = EMS_S_Success; 
  if (dim < 1 || dim > 3)
    {
    *msg = EMS_E_InvalidArg;
    return (-1.0); 
    }
  
  if (dim == 1)
    {
    IGRboolean rev;
    IGRdouble pt1, pt2, dist;

    pt1 = segpt1[X];
    pt2 = segpt2[X];
    rev = FALSE;
    if (pt1 > pt2)
      {
      pt1 = segpt2[X];
      pt2 = segpt1[X];
      rev = TRUE;
      }

    dist = (pt2 - pt1) * (pt2 - pt1);
    if (lensq) *lensq = dist;

    if (pt[X] <  pt1) 
      {
      if (par) *par = 0.0;
      if (fromstartsq) *fromstartsq = rev ? dist : 0.0;
      return ((pt1 - pt[X]) * (pt1 - pt[X]));
      }
    else if (pt[X] > pt2)
      {
      if (par) *par = 1.0;
      if (fromstartsq) *fromstartsq = rev ? 0.0 : dist;
      return ((pt[X] - pt2) * (pt[X] - pt2));
      }
    else if (fabs (pt2 - pt1) < MINDOUBLE)
      {
      if (par) *par = 0.0;
      if (fromstartsq) *fromstartsq = 0.0;
      return ((pt1 - pt[X]) * (pt1 - pt[X]));
      }
    else
      {
      if (par) *par = (pt[X] - pt1) / (pt2 - pt1);
      if (fromstartsq) *fromstartsq = (pt[X] - segpt1[X]) * 
                                       (pt[X] - segpt1[X]);
      return (0.0);
      }
    }
  else if (dim == 2)
    {
    segvec[X] = segpt2[X] - segpt1[X];
    segvec[Y] = segpt2[Y] - segpt1[Y];
    ptvec[X] = pt[X] - segpt1[X];
    ptvec[Y] = pt[Y] - segpt1[Y];
    dotp = segvec[X]*ptvec[X] + segvec[Y]*ptvec[Y];
  
    seglen = segvec[X] * segvec[X] + segvec[Y] * segvec[Y];
    if (lensq) *lensq = seglen;
    
    if (dotp < MINDOUBLE)
      {
      /*
       * The given point's projection on
       * the infinite line, falls below the
       * start of the line-segment.
       */

      if (par) *par = 0.0;
      if (fromstartsq) *fromstartsq = 0.0;
      return (EM2ddistptpts (segpt1, pt));
      }
    else
      {
      if (dotp > seglen)
        {
        /*
         * The given point's projection on
         * the infinite line, falls above the
         * end of the line-segment.
         */
  
        if (par) *par = 1.0;
        if (fromstartsq) *fromstartsq = seglen;
        return (EM2ddistptpts (segpt2, pt));
        }
      else
        {
        IGRdouble val;
        /*
         * The given point's projection lies
         * between the two end-points.
         */
  
        if (par || fromstartsq) val = dotp / seglen;
        if (par) *par = val;
        if (fromstartsq) *fromstartsq = val * dotp;
        crossp = ptvec[X]*segvec[Y] - ptvec[Y]*segvec[X];
        crossp *= crossp;
        return (crossp / seglen);
        }
      }
    }
  else if (dim == 3)
    {
    IGRvector crossvec;

    segvec[X] = segpt2[X] - segpt1[X];
    segvec[Y] = segpt2[Y] - segpt1[Y];
    segvec[Z] = segpt2[Z] - segpt1[Z];
    ptvec[X] = pt[X] - segpt1[X];
    ptvec[Y] = pt[Y] - segpt1[Y];
    ptvec[Z] = pt[Z] - segpt1[Z];
    dotp = BSdotp (&msg_loc, segvec, ptvec);
  
    seglen = BSdistptpts (&msg_loc, segpt1, segpt2);
    if (lensq) *lensq = seglen;

    if (dotp < MINDOUBLE)
      {
      /*
       * The given point's projection on
       * the infinite line, falls below the
       * start of the line-segment.
       */

      if (par) *par = 0.0;
      if (fromstartsq) *fromstartsq = 0.0;
      return (BSdistptpts (&msg_loc, segpt1, pt));
      }
    else
      {
      if (dotp > seglen)
        {
        /*
         * The given point's projection on
         * the infinite line, falls above the
         * end of the line-segment.
         */
  
        if (par) *par = 1.0;
        if (fromstartsq) *fromstartsq = seglen;
        return (BSdistptpts (&msg_loc, segpt2, pt));
        }
      else
        {
        IGRdouble val;
        /*
         * The given point's projection lies
         * between the two end-points.
         */
  
        if (par || fromstartsq) val = dotp / seglen;
        if (par) *par = dotp / seglen;
        if (fromstartsq) *fromstartsq = val * dotp;
        BScrossp (&msg_loc, ptvec, segvec, crossvec);
        crossp = BSlenvec (&msg_loc, crossvec);
        crossp *= crossp;
        return (crossp / seglen);
        }
      }
    }
  else
    {
    *msg = EMS_E_Fail;
    return (-1.0);
    }
}

