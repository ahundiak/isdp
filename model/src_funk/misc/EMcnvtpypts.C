/*
  DESCRIPTION

    A set of points is input along with the linestring on which these
    lie. This function converts this set of "inpoints" into a linked list
    of type EMpypoints. The point could be 1D, 2D or 3D depending on 
    the value of dimension. The output linked list is assumed to be set up.
    (allocated and connected).

    A characteristic of this function is that if the true minimum distance
    is within "lentol" of an end-point ALONG the polyline, then this function
    will return the logical position of the projected point as lying on
    the respective end. The span_inx, param, etc will still refer to the
    true minimum distance point though.

  HISTORY

    SS  :  Creation  : Quite some time ago.
*/

#include <math.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "emsdattyp.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"

void EMcnvtpypts (msg, inpoly, dim, num_inpoints, inpoints, lentol,
                  outpypoints, mindist)
IGRlong *msg;
struct IGRpolyline *inpoly;
IGRshort dim;
IGRlong num_inpoints;
IGRdouble *inpoints, lentol;
struct EMSpypoint *outpypoints;
IGRdouble *mindist;
{
  IGRboolean degen_sofar, deg_span;
  IGRushort props;
  IGRint i, j, k, ptinx, spaninx, inx, inxlim, numpts;
  IGRint start_nondeg_spaninx, stop_nondeg_spaninx;
  IGRlong msg_loc, mininxdim, minspan_inx;
  IGRdouble lentolsq;
  IGRdouble mindistsq, temp_mindistsq, minparam, temp_minparam;
  IGRdouble minseglensq, temp_seglensq, minfrombegsq, temp_frombegsq;
  IGRdouble seglen, frombeg, start_deglen, stop_deglen;
  IGRdouble lendiffsq, pardiff, par1, par2;
  IGRdouble *pts, *tmppts;
  struct EMSpypoint *outpyptr;
  IGRdouble EMmdistptseg();
 
  /*
   * Initialization of output arguments and
   * validity check on input.
   */

  *msg = EMS_S_Success;

  pts = inpoly->points;
  numpts = inpoly->num_points;
  if (numpts < 2 || dim < 1 || dim > 3 || num_inpoints <= 0)
    {
    *msg = EMS_E_InvalidArg;
    goto ret_end;
    }
  outpyptr = outpypoints;

  /*
   * Loop through every "inpoint" over
   * every "inpoly->point". For each
   * "inpoint" an "outpypoint" node is
   * output. The minimum distance for the
   * point is also output.
   * 
   * When (and if) a reasonable method of
   * zooming in on a smaller set of segments
   * w/o the overhead of computing the
   * minimum distance for every segment is
   * found, it can be incorporated into this
   * loop.
   */

  degen_sofar = FALSE; 
  lentolsq = lentol * lentol;
  for (i=0, ptinx=0; ptinx<num_inpoints; i+=dim, ptinx++)
    {
    mindistsq = EMmdistptseg (&msg_loc, pts, &pts[dim], &inpoints[i],
                 dim, &minparam, &minseglensq, &minfrombegsq);
    mininxdim = 0;
    seglen = sqrt (minseglensq);
    if (seglen < lentol)
      degen_sofar = TRUE; 
    else
      degen_sofar = FALSE;

    start_deglen = stop_deglen = 0.0;
    start_nondeg_spaninx = stop_nondeg_spaninx = 0;
    if (degen_sofar)
      start_deglen = seglen;

    inxlim = (numpts-1)*dim;
    for (j=dim, k=1; j<inxlim; j+=dim, k++)
      {
      temp_mindistsq = EMmdistptseg (&msg_loc, &pts[j], &pts[j+dim],
                        &inpoints[i], dim, &temp_minparam, &temp_seglensq,
                        &temp_frombegsq);
      deg_span = temp_seglensq <= lentolsq;

      if (degen_sofar)
        {
        start_nondeg_spaninx = k;
        if (deg_span)
          start_deglen += sqrt (temp_seglensq);
        }

      if (!deg_span)
        {
        stop_nondeg_spaninx = k;
        stop_deglen = 0.0;
        }
      else
        stop_deglen += sqrt (temp_seglensq);

      if (!deg_span && (degen_sofar || temp_mindistsq < mindistsq))
        {
        mindistsq = temp_mindistsq;
        minfrombegsq = temp_frombegsq;
        minseglensq = temp_seglensq;
        mininxdim = j;
        minparam = temp_minparam;
        degen_sofar = FALSE;
        }

      lendiffsq = (temp_mindistsq > mindistsq ? 
                   temp_mindistsq - mindistsq : mindistsq - temp_mindistsq);
      if (lendiffsq < lentolsq)
        {
        minspan_inx = mininxdim / dim;
        par1 = minspan_inx + minparam;
        spaninx = j / dim;
        par2 = spaninx + temp_minparam;
        pardiff = (par1 > par2 ? par1 - par2 : par2 - par1);
        if (pardiff > MINDOUBLE)
          *msg = EMS_I_Ambiguous;
        }
      }
    minspan_inx = mininxdim / dim;
    outpyptr->span_inx = minspan_inx;
    outpyptr->param = minparam;

    inx = minspan_inx*dim;
    tmppts = &pts[inx];
    for (j=0; j<dim; j++)
      outpyptr->point[j] = tmppts[j] + minparam * (tmppts[dim+j] - tmppts[j]);

    if (degen_sofar)
      props = EMS_PYPT_ATSTART;
    else
      {
      seglen = sqrt (minseglensq);
      frombeg = sqrt (minfrombegsq);

      if ((minspan_inx == 0 && 
           frombeg < lentol) ||
          (minspan_inx == start_nondeg_spaninx && 
           (start_deglen + frombeg) < lentol))
        props = EMS_PYPT_ATSTART;
      else if ((minspan_inx == numpts-2 &&
                seglen-frombeg < lentol) ||
               (minspan_inx == stop_nondeg_spaninx &&
                (stop_deglen + (seglen-frombeg)) < lentol))
        props = EMS_PYPT_ATSTOP;
      else
        props = EMS_PYPT_ATMIDDLE;
      }
    outpyptr->props = props;

    mindist[ptinx] = sqrt (mindistsq);
    outpyptr = outpyptr->next;
    }

  if (degen_sofar)
    *msg = EMS_I_DegenerateEdge;

ret_end:;
}
