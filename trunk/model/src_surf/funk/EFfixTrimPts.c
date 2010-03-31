/* ###################   APOGEE COMPILED   ################## */
# define EMmsg_obj_include  /* Prevents including EMSmsg_obj.h
                               from EMSmsgdef.h. The inclusion of
                               this file requires that the code
                               be OPPed.
                            */

# include "EMS.h"
# include "igrtypedef.h"    /* IGR...           */
# include "igr.h"           /* IGRpolyline      */
# include "emsdattyp.h"     /* EMSpypoint       */
# include "emsdef.h"        /* MAXINT           */
# include "EMSlogic.h"      /* IS               */
# include "EMSmsgdef.h"     /* EMS_S_Success    */

# undef EMmsg_obj_include

void EFfixTrimPoints(EMmsg, num_bdrys, bdrys, inpoly)

IGRlong             *EMmsg;
IGRint              num_bdrys;
struct EMSpypoint   *bdrys;
struct IGRpolyline  *inpoly;

/*
Abstract

    This function fixes the point entry in each EMSpypoint
    structure in the list bdrys to the 3d value.

Arguments

    num_bdrys - input
        The number of elements in the list of pypoints (bdrys).

    bdrys - input (output)
        The list of pypoints whose point entries need to be
        fixed.

    inpoly - input
        The 3d linestring for which the polygon pypoints are
        defined.

History

    03 Aug 1988 AIC Genesis
*/

{
  IGRint            i, stop;
  struct EMSpypoint *bdry;

  *EMmsg = EMS_S_Success;

  /*
   * Set the stop index. (num_bdrys is the number of bdry pairs.)
   */
  stop = num_bdrys * 2;

  /*
   * Process each bdry point.
   */
  for(i = 0, bdry = bdrys; i < stop; i ++, bdry = bdry->next)
  {
    IGRint      index;
    IGRdouble   *pts;

    /*
     * Set up the polyline points index. If the trim point is not
     * a span endpoint, then set the index to -1.
     */
    if(bdry->param IS 0.) index = bdry->span_inx * 3;
    else if(bdry->param IS 1.) index = (bdry->span_inx + 1) * 3;
    else index = -1;

    pts = inpoly->points;
    if(index >= 0) /* Begin or end of a span. */
    {
      /*
       * Take the data directly from the input polygon.
       */
      bdry->point[0] = pts[index ++];
      bdry->point[1] = pts[index ++];
      bdry->point[2] = pts[index];
    }
    else /* not a span endpoint */
    {
      IGRdouble *pt1, *pt2, *bpt;

      /*
       * Optimization pointers.
       */
      pt1 = pts + bdry->span_inx * 3;
      pt2 = pt1 + 3;
      bpt = bdry->point;

      /*
       * Calculate the 3d point.
       */
      *bpt++ = *pt1 + (*pt2 - *pt1) * bdry->param;
      pt1 ++; pt2 ++;
      *bpt++ = *pt1 + (*pt2 - *pt1) * bdry->param;
      pt1 ++; pt2 ++;
      *bpt   = *pt1 + (*pt2 - *pt1) * bdry->param;
    }
  }
}
