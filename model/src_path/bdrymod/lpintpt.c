/* Includes */

#include <math.h>
#include <memory.h>

#include "OMminimum.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igr.h"
#include "bs.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bsvalues.h"

#include "emsdef.h"

/* Pathway */
#include "PWminimum.h"         
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"

/* Prototypes */
#include "PWapi/lpprops.h"
#include "PWapi/partol.h"
#include "PWapi/rngbx.h"
#include "PWapi/lpint.h"
#include "PWapi/sortgmint.h"
#include "PWapi/lpintpt.h"


#define  SAFETY_FACTOR  10
#define  MAX_CALLINX    200

extern double EMsubdivval ();

/*
  DESCRIPTION
  It returns points which are inside the given loop. Internally this function
  constructs horizontal/vertical lines with end points constructed using the
  range box of the loop. Internal point is calculated by taking the mid point
  of the first two intersection points along the constructed line.
  

  NOTES
 
  ARGUMENTS

  lpobj               -I: Object id of the loop for which we want the internal
                          point.
  os,                 -I: Osnum of the input loop.
  p_sfdata            -I: Geometry of the surface to which the input loop 
                          belongs.
  xyztol              -I: model space tolerance
  callinx             -I: Value for constructing the horizontal and vertical
                          rays to be intersected with the loop. This variable
                          is used during the recursive call made by the 
                          function.
  num_pts             -I: Number of input points required.
  *p_pts              -O: Input points.
  

  RETURN VALUE 

  HISTORY

  Subhasish : 5th Feb 1996 : Creation. 

*/

PWresult  pwLpInternalPts
(
  PWobjid          lpobj,
  PWosnum          os,
  struct PWsfdata  *p_sfdata, 
  double           xyztol,
  int              callinx,
  int              num_pts,
  PWpoint2d        *p_pts
)
{
  PWresult         PWsts=PW_K_Success;
  PWboolean        vertical=FALSE;
  int              subinx=0;
  double           uvtol=0.0, safetol=0.0, fraction=0.0, pt1[3], pt2[3];
  PWpoint2d        line[2];
  PWrange2d        lprange, lnrange;
  struct PWid      lpid;
  struct PWcvintpt_list   *p_intlist=NULL;
  struct IGRbsp_surface   *p_sfgeom=NULL;
  struct PWcvdata         linedata;

  /*
   * Validation
   */
  if ( (num_pts <=0) || (callinx > MAX_CALLINX) || !p_sfdata ||
       (p_sfdata->datatype == PWsfdata_plane))
    OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                  wrapup); 

  /*
   * Initializations
   */
  lpid.objid = lpobj;
  lpid.osnum = os;
  memset (&linedata, 0, sizeof (struct PWcvdata));
  memset (lprange, 0, 4*sizeof (double));
  memset (lnrange, 0, 4*sizeof (double));

  p_sfgeom = p_sfdata->datatype == PWsfdata_bspsf ? p_sfdata->data.p_bspsf :
                                            p_sfdata->data.p_gmbspsf->bspsf;

  /* 
   * Get the surface uv tolerance from xyz tolerance
   */
  uvtol = pwGetParTolSf (p_sfgeom, xyztol);
  safetol = uvtol*SAFETY_FACTOR;

  /*
   * Obtain the input loop range
   */
  pwGetLpRange (lpobj, os, lprange);

  /*
   * Obtain the ray/line w.r.t. the range box which will be used
   * to compute the point inside.
   */
  vertical = callinx % 2;
  subinx = callinx / 2;
  fraction = EMsubdivval (0.5, subinx);

  if (vertical)
  {
    line[0][U] = lprange[0][U] + fraction * (lprange[1][U] - lprange[0][U]);
    line[0][V] = lprange[0][V] - safetol;
    line[1][U] = line[0][U];
    line[1][V] = lprange[1][V] + safetol;
  }
  else
  {
    line[0][U] = lprange[0][U] - safetol;
    line[0][V] = lprange[0][V] + fraction * (lprange[1][V] - lprange[0][V]);
    line[1][U] = lprange[1][U] + safetol;
    line[1][V] = line[0][V];
  }
  linedata.datatype = PWcvdata_py2d;
  linedata.data.py2d.num_pts = 2;
  linedata.data.py2d.p_pts = line;

  /*
   * Get the range of this line and increase it by lentol
   */
  pwGetRange2d (2, line, lnrange);
  pwExpandRange2d (lnrange, uvtol);

  /*
   * intersect the line obtained above with the input loop
   */
  PWsts = pwIntersectWithLoop (&lpid, &linedata, NULL, lnrange, p_sfdata,
                               xyztol, &p_intlist);
  OnErrorCode (PWsts, wrapup);

  /*
   * Sort the intpt list
   */
  if (p_intlist)
  {
    PWsts = pwSortCvintptList (&p_intlist, uvtol);
    OnErrorCode (PWsts, wrapup);
  }

  /*
   * Check whether the first node in intlist is a part of ArbSeq
   */

  /*
   * If the intersection point is not coincident with the next intersection
   * point and the region is not 'ON', then get a point in between this
   * point and its next point.
   */
  if (p_intlist &&
      p_intlist->p_next &&
      !(pwIsArbSeqCvintptList (p_intlist)) &&
      !(pwIsCoincCvintptList (p_intlist, NEXT)) &&
      (PWcontain_on != pwGetContainCvintpt (&(p_intlist->intpt), RIGHT)))
  {
    /*
     * Get the current point and the next intersection point on the line
     * to get an internal point.
     */
    memcpy (pt1, p_intlist->intpt.cvpt.pt, 2*sizeof (double)); 
    memcpy (pt2, p_intlist->p_next->intpt.cvpt.pt, 2*sizeof (double));

    p_pts[0][U] = pt1[U] + 0.5 * (pt2[U] -pt1[U]);
    p_pts[0][V] = pt1[V] + 0.5 * (pt2[V] -pt1[V]);

    if (--num_pts)
    {
      (callinx)++;
      if (p_intlist)
      {
        pwFreeCvintptList (p_intlist);
        p_intlist = NULL;
      }
      PWsts = pwLpInternalPts (lpobj, os, p_sfdata, xyztol, callinx, 
                               num_pts, &(p_pts[1]));
      OnErrorCode (PWsts, wrapup);
    }
  }/* intersections are not arbitrary sequenced */
  else
  {
    (callinx)++;
    if (p_intlist)
    {
      pwFreeCvintptList (p_intlist);
      p_intlist = NULL;
    }
    PWsts = pwLpInternalPts (lpobj, os, p_sfdata, xyztol, callinx,
                             num_pts, p_pts);
    OnErrorCode (PWsts, wrapup);
  }
   
 wrapup:
 if (p_intlist)
 {
   pwFreeCvintptList (p_intlist);
   p_intlist = NULL;
 }
 PW_Wrapup (PWsts, "Function:  pwLpInternalPts");
 return PWsts;
}/* end of funtion pwLpInternalPts */
