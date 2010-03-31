/*
  OVERVIEW

  This file contains the APIs to evaluate various geometric quantities 
  associated with a simple surface (not composite). Some of these are
  standard one (eg: surface area, etc.) others are specific to this
  implementation (eg: smallest gap between adjacent poles, etc.).


  HISTORY

  SS  :  05/23/96   :  Creation
*/

#include <alloca.h>
#include <memory.h>
#include <math.h>

#include "bserr.h"
#include "bsparameters.h"
#include "bsvalues.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"

#include "PWapi/sfgmqtys.h"
#include "PWapi/sfgeom.h"
#include "PWapi/mdstptgm.h"

/*
  DESCRIPTION

  The following function looks at the B-spline definition of the given
  simple surface object and computes the minimum distance that occurs between
  any two adjacent poles (U or V direction). It also returns the zero-based
  index pair (U-inx and V-inx) of the first pole involved in the minimum
  distance and a Boolean flag indicating whether to increment the index in the
  U or V direction in order to get the index of the second pole.
*/

PWresult pwGetMinDistAdjPoles
(
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,

  double *mindist,
  int minpoleinx[2],
  PWboolean *in_u_dir
)
{
  PWboolean loc_in_u_dir=TRUE;
  int u_inx, v_inx;
  int min_u_inx=0, min_v_inx=0;
  int u_num_poles, v_num_poles;
  int row_increment, num_doubles_in_row;
  double curr_mindistsq, mindistsq=MAXDOUBLE, *poles, *pole, *pt1, *pt2;
  PWresult result=PW_K_Success;
  struct IGRbsp_surface *sf=NULL;

  result = PW_GetSfBspsfStack (sfobj, os, xmattyp, xmat, sf);
  OnErrorCode (result, wrapup);

  u_num_poles = sf->u_num_poles;
  v_num_poles = sf->v_num_poles;
  poles = sf->poles;

  /*
   * Look for the minimum distance adjacent poles in the U-direction
   */

  loc_in_u_dir = TRUE;
  for (v_inx=0; v_inx<v_num_poles; v_inx++)
  {
    pole = &poles[v_inx * u_num_poles * 3];
    for (u_inx=0; u_inx<u_num_poles-1; u_inx++)
    {
      pt1 = pole;
      pt2 = pole + 3;
      
      if ((curr_mindistsq = pwDistSqPtPt (pt1, pt2)) < mindistsq)
      {
        min_u_inx = u_inx;
        min_v_inx = v_inx;
        mindistsq = curr_mindistsq;
      }
    }
  }

  /*
   * Look for the minimum distance adjacent poles in the V-direction
   */

  loc_in_u_dir = FALSE;
  num_doubles_in_row = u_num_poles * 3;
  for (u_inx=0; u_inx<u_num_poles; u_inx++)
  {
    pole = &poles[u_inx * 3];
    for (v_inx=0; v_inx<v_num_poles-1; v_inx++)
    {
      row_increment = v_inx * num_doubles_in_row;
      pt1 = pole + row_increment;
      pt2 = pt1 + num_doubles_in_row;
      
      if ((curr_mindistsq = pwDistSqPtPt (pt1, pt2)) < mindistsq)
      {
        min_u_inx = u_inx;
        min_v_inx = v_inx;
        mindistsq = curr_mindistsq;
      }
    }
  }

  /*
   * We have gathered up all the information. Now reformat into the
   * output.
   */

  *mindist = sqrt (mindistsq);
  minpoleinx[U] = min_u_inx;
  minpoleinx[V] = min_v_inx;
  *in_u_dir = loc_in_u_dir;

wrapup:
  PW_WrapupId (result, "pwGetMinDistAdjPoles", sfobj);
  return (result);
}

