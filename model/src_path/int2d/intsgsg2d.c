/*
  DESCRIPTION

  This function is used to determine the geometric interaction between two
  2D-segments. Called the B-segment and the C-segment, respectively.
  The B segment is ordered such that it bounds area on it's right. The
  C segment does not bound any area but it's flow direction is significant
  in that the classification of the interaction points being returned by this
  function will be in terms of this direction.

  The C segment is classified with respect to the B segment when 
  there is an interaction. The classification is in terms of how the C
  segment flows with respect to the area bounded by the B segment. It is
  output in terms of the relative containment of the neighborhoods of the
  interaction point to the left and to the right along C. That is,
  whether it is in(left)->out(right), in(left)->on(right), 
  on(left)->out(right), etc., where, 'in' refers to inside area, 'out' refers
  to outside area (or inside hole), 'on' refers to on the boundary. Thus there
  can be 9 possible classes into which the interactions fit. 

  The interaction point(s) (at most two) are returned with the topological
  property of where they lie (in-middle or at-stop) on both segments,
  respectively. Interaction at the start point of both the segments is 
  ignored. This is done so that when this function is used to process a 
  polyline, the vertex point is not processed twice. The start point of 
  such a polyline will thus have to be processed specially and outside of 
  this function. This is a low level function which typically is never
  called other than by the polyline function.

  Two Boolean flags are also returned that indicate whether the stop-point
  of one segment is within tolerance of the other. This is semantically
  different from the topological position information discussed above.
  Even though this flag may be returned as TRUE, one could have the 
  interaction point returned quite away from the stop-point as this function
  always returns the exact interaction point. This case can be visualized
  by constructing a C segment at a very acute angle to the B segment and
  positioned such that the stop point of B is at a distance 'lentol' away
  from the middle of C. The interaction point is liable to be shifted
  away from the stop point of B. 

  In order to get the correct classification when the interaction point is
  at the stop-point of either of the segments, we need information about
  what direction the polylines are taking immediately beyond this stop-point.
  Thus, the immediately adjacent segment for both the B and C segments are
  passed in. Also, note that due to the fact that we do not return
  interaction points at the start of either B or C segments, even in the
  case of overlap we will only get one point of interaction in most cases.
  The only case where two interaction points are returned will
  be the case when there is an overlap that is bounded by the stop point
  of the B segment and the stop point of the C segment.


  NOTES

  If the orientation classification is ignored, this function behaves like
  a regular intersection function.

  Care is taken to see that the zero-length tolerance being passed in is
  strictly respected.

  If the input segments are degenerate in length, the results are 
  unpredictable.

  The caller must allocate space in the output arguments to accomodate
  data corresponding to two interaction points. 


  ARGUMENTS

  bpt1, bpt2		- I: Together these two points define the B-segment
  bpt_next		- I: Defines the following B segment. 
                           Could be NULL. In that case default virtual segment
                           is constructed and the relative containment
                           classification returned.

  cpt1, cpt2		- I: Together these two points define the C-vector
  cpt_next		- I: Defines the following B segment. 
                           Could be NULL. In that case default virtual segment
                           is constructed and the relative containment
                           classification returned.

  lentol		- I: The zero-length tolerance.

  num_inters		- O: Number of interaction points being returned
                           (at most 2).
  b_inter_pts,		- O: The interaction point(s). The points are
  c_inter_pts              evaluated on the corresponding segments. A near
                           vertical or horizontal segment influences the
                           appropriate co-ordinate towards the mean 
                           co-ordinate. This is done to avoid numerical noise.
                           So, a computation by the parameter on the segment
                           may yield a slightly different answer.
  bpars, cpars		- O: The parameter(s) of the interaction point(s)
                           on the respective segments. The segments are
                           parameterized from 0.0 to 1.0.
  bposs, cposs		- O: The position(s) of the interaction point(s)
                           on the respective segments. Possible values -
                           PWtopopos_middle and PWtopopos_stop (note the
                           absence of PWtopopos_start).
  lfrels, rtrels	- O: The relative containments of the respective
    	                   neighborhoods of the interaction point(s) on C,
			   wrt to the area bounded by B. There are 9 possible
                           values.
  b_atstop_onc,		- O: If the stop end of B (or C) is within tol
  c_atstop_onb             of C (or B). Note that this may be different from
                           bpos (or cpos). Bpos (or cpos) is evaluated ALONG
                           the LENGTH of B (or C). A Boolean flag is returned
                           for every interaction point (max 2). For this flag
                           to be TRUE, the interaction point corresponds to
                           the stop point being within tolerance of the other
                           segment.
                           


  ASSUMPTIONS

  It is assumed that when this function is called iteratively to process
  the segments of a polyline, the polyline is not self-intersecting and
  no segment of the polyline overlap others within it. In other words, 
  the adjacent segment passed into this function does not overlap the 
  input segment. Also, the two points making up the segment are more
  than 'lentol' apart, ie, the segments are not degenerate.


  RETURN VALUE

  This function returns a TRUE if an interaction point has been found; a
  FALSE otherwise.
    

  HISTORY

  SS  :  09/13/94  :  Creation. Borrowed philosophy from the old EM2dsgcutint
*/

#include <math.h>
#include <memory.h>
#include "bsvalues.h"
#include "PWminimum.h"
#include "PWattrib.h"
#include "PWgmdata.h"
#include "PWgmint.h"

#include "PWapi/crossp.h"
#include "PWapi/dotp.h"
#include "PWapi/sortvec.h"
#include "PWapi/mdstptgm.h"

#define  VC  0
#define _VC  0
#define VCA  1
#define _VB  2
#define VBA  3

/*
 * Prototype definition of the statically defined function in support
 * of this function.
 */

static PWboolean compute_overlap
(
  PWpoint2d bpt1,
  PWpoint2d bpt2,
  PWpoint2d cpt1,
  PWpoint2d cpt2,

  PWvector2d  vb,

  double tol,

  int *num_inters,

  PWpoint2d b_inter_pts[2],
  PWpoint2d c_inter_pts[2],
  double *bpars,
  double *cpars,
  enum PWtopopostype bposs[2],
  enum PWtopopostype cposs[2],
  PWboolean b_atstop_onc[2],
  PWboolean c_atstop_onb[2]
);

static void compute_overlap_relcontain
(
  PWpoint2d bpt2,
  PWpoint2d bpt3,
  PWpoint2d cpt1,
  PWpoint2d cpt2,
  PWpoint2d cpt3,

  PWvector2d vb,
  PWvector2d vc,

  enum PWdirtype dir1,

  double lentol,
  int num_inters,
  enum PWtopopostype bposs[2],
  enum PWtopopostype cposs[2],

  enum PWcontaintype lfrels[2],
  enum PWcontaintype rtrels[2]
);

static void compute_midb_midc_relcontain
(
  enum PWdirtype dir1,
  enum PWcontaintype lfrels[2],
  enum PWcontaintype rtrels[2]
);

static void compute_stopb_midc_relcontain
(
  PWpoint2d bpt2,
  PWpoint2d cpt1,
  double *bpt3,
  PWvector2d vb,
  PWvector2d vc,

  enum PWdirtype dir1,
  enum PWdirtype dir3,

  double lentol,

  enum PWcontaintype lfrels[2],
  enum PWcontaintype rtrels[2]
);

static void compute_midb_stopc_relcontain
(
  PWpoint2d cpt2,
  double *cpt3,
  PWvector2d vb,
  PWvector2d vc,

  enum PWdirtype dir1,
  double lentol,

  enum PWcontaintype lfrels[2],
  enum PWcontaintype rtrels[2]
);

static void compute_stopb_stopc_relcontain
(
  PWpoint2d bpt2,
  PWpoint2d bpt3,
  PWpoint2d cpt2,
  PWpoint2d cpt3,

  PWvector2d vb,
  PWvector2d vc,

  enum PWdirtype dir1,
  double lentol,

  PWboolean is_aligned,

  enum PWcontaintype lfrels[2],
  enum PWcontaintype rtrels[2]
);

static void compute_intersection
(
  PWpoint2d mpt1,
  PWpoint2d mpt2,
  PWvector2d vm,
  PWvector2d vmn2,

  double c_m1_n1,
  double c_m1_n2,
  double c_n1_m1,
  double c_n1_m2,
  double lentol,

  double *mpar,
  enum PWtopopostype *mpos,
  PWpoint2d m_inter_pt
);


/*
 * Main function body begins here
 */

PWboolean pwIntSgSg2d 
(
  PWpoint2d bpt1, 
  PWpoint2d bpt2,
  double *bpt_next,
  PWpoint2d cpt1,
  PWpoint2d cpt2,
  double *cpt_next,

  double lentol,

  int *num_inters,
  PWpoint2d b_inter_pts[2],
  PWpoint2d c_inter_pts[2],
  double bpars[2],
  double cpars[2],
  enum PWtopopostype bposs[2], 
  enum PWtopopostype cposs[2],
  enum PWcontaintype lfrels[2], 
  enum PWcontaintype rtrels[2],
  PWboolean b_atstop_onc[2], 
  PWboolean c_atstop_onb[2]
)
{
  double c1, c2, c3, c4;
  PWboolean int_found=FALSE;
  PWvector2d vb, vb1, vb2, vc, vc1, vc2;
  enum PWdirtype dir1, dir2, dir3, dir4;

  *num_inters = 0;

  /*
   * Obtain the cross-products between the B vector and the two
   * vectors that are built by joining the start of B to the end-points
   * of C. 
   */

  vb[X] = bpt2[X] - bpt1[X];
  vb[Y] = bpt2[Y] - bpt1[Y];
  vb1[X] = cpt1[X] - bpt1[X];
  vb1[Y] = cpt1[Y] - bpt1[Y];
  vb2[X] = cpt2[X] - bpt1[X];
  vb2[Y] = cpt2[Y] - bpt1[Y];

  dir1 = pwCrossProd2d (vb, vb1, lentol, &c1);
  dir2 = pwCrossProd2d (vb, vb2, lentol, &c2);

  /*
   * Using the relative directions we can trivially discern either a rejection,
   * or a start point interaction or an overlap. If it is neither of these,
   * then we have to process further.
   */

  if (dir1 == dir2 && dir1 != PWdir_along)
  {
    /*
     * The C points are on the same side of line B and not
     * on line B. Inference: no intersection.
     */

    goto wrapup;
  }

  else if (dir1 == PWdir_along && dir2 != PWdir_along)
  {
    /*
     * The start point of C is on line B and the other point is not
     * on the line B. Regardless of any other consideration, this can
     * only be a start-point intersection, if at all. So return a
     * no intersection.
     */

    goto wrapup;
  }

  else if (dir1 == PWdir_along && dir2 == PWdir_along)
  {
    /*
     * The C points lie on the line B. Collinear situation. But the segments
     * may still not interact. Process for collinearity (or overlap).
     */

    if (compute_overlap (bpt1, bpt2, cpt1, cpt2, vb, lentol,
         num_inters, b_inter_pts, c_inter_pts, bpars, cpars, bposs, cposs,
         b_atstop_onc, c_atstop_onb))
    {
      vc[X] = cpt2[X] - cpt1[X];
      vc[Y] = cpt2[Y] - cpt1[Y];

      compute_overlap_relcontain (bpt2, bpt_next, cpt1, cpt2, cpt_next,
       vb, vc, dir1, lentol, *num_inters, bposs, cposs, lfrels, rtrels);

      int_found = TRUE;
    }
    goto wrapup;
  }

  /*
   * Obtain the cross-products between the C vector and the two
   * vectors that are built by joining the start of C to the end-points
   * of B. 
   */

  vc[X] = cpt2[X] - cpt1[X];
  vc[Y] = cpt2[Y] - cpt1[Y];
  vc1[X] = bpt1[X] - cpt1[X];
  vc1[Y] = bpt1[Y] - cpt1[Y];
  vc2[X] = bpt2[X] - cpt1[X];
  vc2[Y] = bpt2[Y] - cpt1[Y];

  dir3 = pwCrossProd2d (vc, vc1, lentol, &c3);
  dir4 = pwCrossProd2d (vc, vc2, lentol, &c4);

  /*
   * Using the signs we can trivially discern either a rejection, or a start
   * point interaction or an overlap. If it is neither of these, then we have
   * to process further. Note that the possibility of getting an overlap here
   * should have been eliminated by a previous test for overlap. But the test
   * is not removed here for the sake of symmetry and moreover, some tolerance
   * hitch may not detect overlap looking form the B point of view but may 
   * catch the overlap from the C's viewpoint.
   */

  if (dir3 == dir4 && dir3 != PWdir_along)
  {
    /*
     * Both the B points are on the same side of line C and neither on
     * the line C. Inference: no intersection.
     */

    goto wrapup;
  }

  else if (dir3 == PWdir_along && dir4 != PWdir_along)
  {
    /*
     * The start point of B is on line C and the stop point of B is not
     * on the line B. Regardless of any other consideration, this can
     * only be a start-point intersection, if at all. So return a
     * no intersection.
     */

    goto wrapup;
  }

  else if (dir3 == PWdir_along && dir4 == PWdir_along)
  {
    /*
     * The B points lie on the line C. Collinear situation. This should
     * have also meant the C points lie on line B and should have been
     * caught by the previous check. Perhaps due to inexactness it did
     * show up as such. Process for collinearity (or overlap).
     */

    if (compute_overlap (bpt1, bpt2, cpt1, cpt2, vb, lentol,
         num_inters, b_inter_pts, c_inter_pts, bpars, cpars, bposs, cposs,
         b_atstop_onc, c_atstop_onb))
    {
      compute_overlap_relcontain (bpt2, bpt_next, cpt1, cpt2, cpt_next,
       vb, vc, dir1, lentol, *num_inters, bposs, cposs, lfrels, rtrels);

      int_found = TRUE;
    }
    goto wrapup;
  }

  /*
   * Following are conditions when points of a segment are on opposite
   * sides of the other segment or the stop point of a segment lies somewhere
   * on the other segment except at it's start point. A single intersection is
   * guaranteed. Whether the stop of a segment is within tol of the other
   * segment, can be trivially inferred in the individual cases. The relative
   * containment (of C wrt B) at the intersection point is computed uniquely
   * for individual cases. But the actual intersection point computation is
   * common for all cases.
   */

  if (dir1 != PWdir_along && dir2 != PWdir_along)
  {
    /*
     * The C points are on opposite sides of line B and neither on the line.
     * Two cases arise.
     */

    if (dir3 != PWdir_along && dir4 != PWdir_along)
    {
      /*
       * The B points are on opposite sides of line C (and the C points
       * are on opposite sides of line B). Inference: Intersection
       * has occurred in the middle of the C and in the middle of the B
       * segment. The orientation is computed, trivially.
       */

      *b_atstop_onc = FALSE;
      *c_atstop_onb = FALSE;

      compute_midb_midc_relcontain (dir1, lfrels, rtrels);
    }

    else /* if (dir3 != PWdir_along && dir4 == PWdir_along) */
    {
      /*
       * The stop point of B is in the middle of the C segment. 
       * In order to get the correct 'rels we would have to look at bpt_next.
       */
       
      *b_atstop_onc = TRUE;
      *c_atstop_onb = FALSE;

      compute_stopb_midc_relcontain (bpt2, cpt1, bpt_next, vb, vc,
       dir1, dir3, lentol, lfrels, rtrels);
    }
  }

  else /* if (dir1 != PWdir_along && dir2 == PWdir_along) */
  {
    /*
     * The stop point of C is on segment B (and the start point is not on the
     * segment B). Two cases arise.
     */

    if (dir3 != PWdir_along && dir4 != PWdir_along)
    {
      /*
       * The stop point of C is in the middle of the B segment. 
       * In order to get the correct 'relcontain' we would have to look at
       * cpt_next. 
       */

      *b_atstop_onc = FALSE;
      *c_atstop_onb = TRUE;

      compute_midb_stopc_relcontain (cpt2, cpt_next, vb, vc,
       dir1, lentol, lfrels, rtrels);
    }

    else /* if (dir3 != PWdir_along && dir4 == PWdir_along) */
    {
      /*
       * Stop point of C is on the stop point of B. Compute the relative
       * orientation by examining the next segments of B and C.
       */
     
      *b_atstop_onc = TRUE;
      *c_atstop_onb = TRUE;

      compute_stopb_stopc_relcontain (bpt2, bpt_next, cpt2, cpt_next, vb, vc,
       dir1, lentol, FALSE, lfrels, rtrels);
    }
  }

  /*
   * The intersection point is computed for the above four cases. The
   * information about whether a stop-point lies on the other segment is used
   * to snap the intersection points to the correct ends if needed.
   */

  compute_intersection (bpt1, bpt2, vb, vb2, c1, c2, c3, c4, 
   lentol, &bpars[FIRST], &bposs[FIRST], b_inter_pts[FIRST]);
  compute_intersection (cpt1, cpt2, vc, vc2, c3, c4, c1, c2, 
   lentol, &cpars[FIRST], &cposs[FIRST], c_inter_pts[FIRST]);

  *num_inters = 1;
  int_found = TRUE;

wrapup:
  return (int_found);
}

/*
  DESCRIPTION

  Helper function that computes the data related to the overlap between
  the two segments. It is already known that the two LINES are overlapping
  within the specified tolerance. But it may turn out that there is
  no overlap between the 2 segments. If there is an overlap then the
  overlap points are returned.

  The overlap points are obtained by minimum distance computations 
  (ie, perpendicular distance computations).
*/

static PWboolean compute_overlap
(
  PWpoint2d bpt1,
  PWpoint2d bpt2,
  PWpoint2d cpt1,
  PWpoint2d cpt2,

  PWvector2d  vb,

  double tol,

  int *num_inters,

  PWpoint2d b_inter_pts[2],
  PWpoint2d c_inter_pts[2],
  double *bpars,
  double *cpars,
  enum PWtopopostype bposs[2],
  enum PWtopopostype cposs[2],
  PWboolean *b_atstop_onc,
  PWboolean *c_atstop_onb
)
{
  double bseglen, bpartol;
  double par_c1onb, par_c2onb;
  PWboolean overlap_found=FALSE;
  PWpoint2d pt;

  bseglen = sqrt (vb[X] * vb[X] + vb[Y] * vb[Y]);
  bpartol = tol / bseglen;

  pwProjPtLn2d (cpt1, bpt1, bpt2, pt, &par_c1onb);
  if (fabs (par_c1onb) < bpartol)
    par_c1onb = 0.0;
  else if (fabs (par_c1onb - 1.0) < bpartol)
    par_c1onb = 1.0;

  pwProjPtLn2d (cpt2, bpt1, bpt2, pt, &par_c2onb);
  if (fabs (par_c2onb) < bpartol)
    par_c2onb = 0.0;
  else if (fabs (par_c2onb - 1.0) < bpartol)
    par_c2onb = 1.0;

  if (par_c1onb <= 0.0 && par_c2onb <= 0.0 ||
      par_c1onb >= 1.0 && par_c2onb > 1.0)
  {
    /*
     * The end points of C lie on the same side of the B segment and
     * neither is on the segment. So no intersection.
     */

    goto wrapup;
  }

  else if (par_c1onb >= 0.0 && par_c1onb <= 1.0 && par_c2onb <= 0.0)
  {
    /*
     * The start point of C lies on the B segment and start point of B
     * lies on C segment. As both interaction points are at the start
     * of either of the segments, infer no intersection.
     */

    goto wrapup;
  }

  else if ((par_c2onb == 1.0 && par_c1onb > 1.0) ||
           (par_c2onb == 1.0 && par_c1onb < 1.0))
  {
    /*
     * The stop point of C lies at the stop of segment B and the rest
     * of C does not lie on the segment B. NOT a start point interaction,
     * so this is an intersection. Compute it and return.
     */

    bpars[FIRST] = 1.0;
    cpars[FIRST] = 1.0;
    bposs[FIRST] = PWtopopos_stop;
    cposs[FIRST] = PWtopopos_stop;
    b_inter_pts[FIRST][X] = bpt2[X];
    b_inter_pts[FIRST][Y] = bpt2[Y];
    c_inter_pts[FIRST][X] = cpt2[X];
    c_inter_pts[FIRST][Y] = cpt2[Y];
    b_atstop_onc[FIRST] = TRUE;
    c_atstop_onb[FIRST] = TRUE;

    overlap_found = TRUE;
    *num_inters = 1;
    goto wrapup;
  }

  /*
   * At this stage we have elliminated all cases except for the cases where
   * the C segment has a non-zero overlap with the B segment. Note that the
   * if the overlap is bounded by a start point then that bounding point
   * is NOT returned. Thus we may return 0, 1 or 2 overlap points, depending
   * on whether the bounding points are both start points, only one is a
   * start point, or none are start points, respectively.
   */

  if (par_c1onb >= 0.0 && par_c1onb <= 1.0 &&
      par_c2onb >= 0.0 && par_c2onb <= 1.0)
  {
    /*
     * The entire C segment overlaps a portion of or the entire 
     * B segment.
     */
  
    if (par_c2onb == 0.0)
    {
      /*
       * Both the bounds of the overlap are start points.
       * Return no interaction point.
       */

      goto wrapup;
    }

    else
    {
      /*
       * One of the overlap points is not a start point (the
       * stop point of the C segment). Return this interaction point.
       */
 
      bpars[FIRST] = par_c2onb;
      cpars[FIRST] = 1.0;
      bposs[FIRST] = par_c2onb == 1.0 ? 
                      PWtopopos_stop : PWtopopos_middle;
      cposs[FIRST] = PWtopopos_stop;
      b_inter_pts[FIRST][X] = bpt1[X] + par_c2onb * vb[X];
      b_inter_pts[FIRST][Y] = bpt1[Y] + par_c2onb * vb[Y];
      c_inter_pts[FIRST][X] = cpt2[X];
      c_inter_pts[FIRST][Y] = cpt2[Y];
      b_atstop_onc[FIRST] = FALSE;
      c_atstop_onb[FIRST] = TRUE;

      overlap_found = TRUE;
      *num_inters = 1;
      goto wrapup;
    }
  }

  else
  {
    /*
     * The overlap contains only a part of the C segment. That is, the bounds
     * for this overlap will be contributed from endpoints of the B
     * segment and the endpoints of the C segment. Only those bounds that
     * are not either of the start-points will be returned.
     */

    if (par_c1onb > 0.0 && par_c1onb < 1.0)
    {
      /*
       * The start point of the C segment is in the middle of the B segment.
       * This bound for the overlap is not going to be returned. Check if
       * the other bound of the overlap is the stop point of the B segment.
       */

      if (par_c2onb > 1.0)
      {
        /*
         * The C segment flows from the middle of the B segment towards
         * the stop point of the B segment and out. Return the stop point
         * of B as the interaction point.
         */

        bpars[FIRST] = 1.0;
        pwProjPtLn2d (bpt2, cpt1, cpt2, pt, &cpars[FIRST]);
        bposs[FIRST] = PWtopopos_stop;
        cposs[FIRST] = PWtopopos_middle;
        b_inter_pts[FIRST][X] = bpt2[X];
        b_inter_pts[FIRST][Y] = bpt2[Y];
        c_inter_pts[FIRST][X] = pt[X];
        c_inter_pts[FIRST][Y] = pt[Y];
        b_atstop_onc[FIRST] = TRUE;
        c_atstop_onb[FIRST] = FALSE;

        overlap_found = TRUE;
        *num_inters = 1;
        goto wrapup;
      }
    
      else
      {
        /*
         * The C segment flows out the start end of the B segment. Since
         * both the overlap points are bounded by start point, return none.
         */

        goto wrapup;
      }
    }

    else if (par_c2onb > 0.0 && par_c2onb < 1.0)
    {
      /*
       * The stop point of the C segment is in the middle of the B segment.
       * This is definitely an interaction point. Check if the other bound
       * for the overlap is at the stop of the B segment.
       */

      if (par_c1onb > 1.0)
      {
        /*
         * The C segment flows from outside the stop end of the B segment
         * into it's middle. The bounds of the overlap are given by the
         * two stop points.
         */

        bpars[FIRST] = 1.0;
        pwProjPtLn2d (bpt2, cpt1, cpt2, pt, &cpars[FIRST]);
        bposs[FIRST] = PWtopopos_stop;
        cposs[FIRST] = PWtopopos_middle;
        b_inter_pts[FIRST][X] = bpt2[X];
        b_inter_pts[FIRST][Y] = bpt2[Y];
        c_inter_pts[FIRST][X] = pt[X];
        c_inter_pts[FIRST][Y] = pt[Y];
        b_atstop_onc[FIRST] = TRUE;
        c_atstop_onb[FIRST] = FALSE;

        bpars[SECOND] = par_c2onb;
        cpars[SECOND] = 1.0;
        bposs[SECOND] = PWtopopos_middle;
        cposs[SECOND] = PWtopopos_stop;
        b_inter_pts[SECOND][X] = bpt1[X] + par_c2onb * vb[X];
        b_inter_pts[SECOND][Y] = bpt1[Y] + par_c2onb * vb[Y];
        c_inter_pts[SECOND][X] = cpt2[X];
        c_inter_pts[SECOND][Y] = cpt2[Y];
        b_atstop_onc[SECOND] = FALSE;
        c_atstop_onb[SECOND] = TRUE;

        overlap_found = TRUE;
        *num_inters = 2;
        goto wrapup;
      }

      else
      {
        /*
         * The C segment flows from outside the start end of the B segment
         * into it's middle. Only the bound that is the stop point on C
         * will be returned.
         */

        bpars[FIRST] = par_c2onb;
        cpars[FIRST] = 1.0;
        bposs[FIRST] = PWtopopos_middle;
        cposs[FIRST] = PWtopopos_stop;
        b_inter_pts[FIRST][X] = bpt1[X] + par_c2onb * vb[X];
        b_inter_pts[FIRST][Y] = bpt1[Y] + par_c2onb * vb[Y];
        c_inter_pts[FIRST][X] = cpt2[X];
        c_inter_pts[FIRST][Y] = cpt2[Y];
        *b_atstop_onc = FALSE;
        *c_atstop_onb = TRUE;

        overlap_found = TRUE;
        *num_inters = 1;
        goto wrapup;
      }
    }

    else
    {
      /*
       * The C segment flows from outside the B segment on to the 'other'
       * outside of the B segment (overlap ranges from the start of B to the
       * stop of B). Only the stop point of B is returned as the interaction
       * point.
       */

      bpars[FIRST] = 1.0;
      pwProjPtLn2d (bpt2, cpt1, cpt2, pt, &cpars[FIRST]);
      bposs[FIRST] = PWtopopos_stop;
      cposs[FIRST] = PWtopopos_middle;
      b_inter_pts[FIRST][X] = bpt2[X];
      b_inter_pts[FIRST][Y] = bpt2[Y];
      c_inter_pts[FIRST][X] = pt[X];
      c_inter_pts[FIRST][Y] = pt[Y];
      *b_atstop_onc = TRUE;
      *c_atstop_onb = FALSE;

      overlap_found = TRUE;
      *num_inters = 1;
      goto wrapup;
    }
  }

wrapup:
  return (overlap_found);
}

/*
  DESCRIPTION

    Helper function that computes the relative orientation of the C segment
    wrt the B segment at the points of interaction, when the two segments
    are known to share an overlap. There may be at most 2 points of
    interaction and therefore, at most 2 relative orientations returned.
*/

static void compute_overlap_relcontain
(
  PWpoint2d bpt2,
  PWpoint2d bpt3,
  PWpoint2d cpt1,
  PWpoint2d cpt2,
  PWpoint2d cpt3,

  PWvector2d vb,
  PWvector2d vc,

  enum PWdirtype dir1,

  double lentol,
  int num_inters,
  enum PWtopopostype bposs[2],
  enum PWtopopostype cposs[2],

  enum PWcontaintype lfrels[2],
  enum PWcontaintype rtrels[2]
)
{
  int i;
  double dotp, c;
  PWboolean symmetric_flow;
  PWvector2d vba, vca, vcba2;
  enum PWdirtype dir;

  /*
   * Obtain the adjacent segment vectors. If the adjacent segment is not
   * passed in, create a virtual vector that is the same as the segment's, ie,
   * create the adjacent vector as aligned with the given segment.
   */

  vba[X] = bpt3 ? bpt3[X] - bpt2[X] : vb[X];
  vba[Y] = bpt3 ? bpt3[Y] - bpt2[Y] : vb[Y];

  vca[X] = cpt3 ? cpt3[X] - cpt2[X] : vc[X];
  vca[Y] = cpt3 ? cpt3[Y] - cpt2[Y] : vc[Y];

  dotp = vb[X] * vc[X] + vb[Y] * vc[Y];
  if (dotp > 0.0)
    symmetric_flow = TRUE;
  else
    symmetric_flow = FALSE;

  /*
   * Process each interaction point individually.
   */

  for (i=0; i<num_inters; i++)
  {
    /*
     * There can be only two positions for the interaction points on the
     * C segment - MIDDLE and STOP. Each can be processed a little 
     * differently.
     */
   
    if (cposs[i] == PWtopopos_middle)
    {
      /*
       * The interaction point lies in the middle of the C segment. The
       * corresponding B point must be at the stop end of B. The C segment
       * is either coming in from outside the stop end of B into it's
       * middle or is going out from it's middle to outside it's stop end.
       * Obtain the relative orientation from the sign of the cross-product
       * between the adjacent B segment and the C segment. 
       */

      /*
       * Obtain a vector from the start of the C segment to the tip of the
       * adjacent B segment. This will give us a measure of the distance of
       * this tip from the C vector. If no adjacent segment is passed in,
       * create the adjacent vector as aligned with the B segment.
       */

      vcba2[X] = bpt3 ? bpt3[X] - cpt1[X] : vb[X];
      vcba2[Y] = bpt3 ? bpt3[Y] - cpt1[Y] : vb[Y];

      dir = pwCrossProd2d (vc, vcba2, lentol, &c);

      if (symmetric_flow)
      {
        /*
         * The C segment is directed from the middle of the B segment to
         * outside it's stop end. 
         */

        lfrels[i] = PWcontain_on;
        if (dir == PWdir_left)
          rtrels[i] = PWcontain_in;
        else if (dir == PWdir_right)
          rtrels[i] = PWcontain_out;
        else
          rtrels[i] = PWcontain_on;
      }

      else
      {
        /*
         * The C segment flows from outside the stop end of B towards
         * the middle of B. 
         */
       
        if (dir == PWdir_left)
          lfrels[i] = PWcontain_out;
        else if (dir == PWdir_right)
          lfrels[i] = PWcontain_in;
        else
          lfrels[i] = PWcontain_on;
        rtrels[i] = PWcontain_on;
      }
    }
  
    else
    {
      /*
       * The interaction point lies at the stop end of the C segment. The
       * corresponding B point must be either at the stop end of B or in
       * the middle of B.
       */

      if (bposs[i] == PWtopopos_middle)
      {
        /* 
         * The stop C point lies in the middle of B. The relative orienation
         * would be given by the sign of the cross-product between the
         * B segment and the adjacent C segment. A single logic can be derived
         * regardless of symmetric / non-symmetric flow.
         */

        dir = pwCrossProd2d (vb, vca, lentol, &c);

        lfrels[i] = PWcontain_on;
        if (dir == PWdir_left)  
          rtrels[i] = PWcontain_out;
        else if (dir == PWdir_right)
          rtrels[i] = PWcontain_in;
        else
          rtrels[i] = PWcontain_on;
      }

      else
      {
        /* 
         * The stop C point lies at the stop end of B. The relative orientation
         * has to be computed taking into account both the adjacent segments -
         * of B and C. If vb and vc are flowing in the same direction, this
         * fact (aligned vectors) is passed in via the Boolean flag.
         */

        compute_stopb_stopc_relcontain (bpt2, bpt3, cpt2, cpt3, vb, vc,
         dir1, lentol, symmetric_flow, lfrels, rtrels);
      }
    }
  }

  return;
}

/*
  DESCRIPTION

    Helper function that computes the relative orientation when it is known
    that the interaction point is in the middle of B and in the middle of
    C. There is only one interaction point.
*/

static void compute_midb_midc_relcontain
(
  enum PWdirtype dir1,
  enum PWcontaintype lfrels[2],
  enum PWcontaintype rtrels[2]
)
{
  if (dir1 == PWdir_left)
  {
    lfrels[FIRST] = PWcontain_out;
    rtrels[FIRST] = PWcontain_in;
  }
  else
  {
    lfrels[FIRST] = PWcontain_in;
    rtrels[FIRST] = PWcontain_out;
  }
  
  return;
}

/*
  DESCRIPTION

  Helper function that computes the relative orientation when it is known
  that the stop point of B lies in the middle of C and that these two
  segments are not collinear. There is only one interaction point.
*/

static void compute_stopb_midc_relcontain
(
  PWpoint2d bpt2,
  PWpoint2d cpt1, 
  double *bpt3,
  PWvector2d vb,
  PWvector2d vc,

  enum PWdirtype dir1,
  enum PWdirtype dir3,

  double lentol,

  enum PWcontaintype lfrels[2],
  enum PWcontaintype rtrels[2]
)
{
  double c, dotp;
  PWboolean is_convex;
  PWvector2d vba, vcba2;
  enum PWdirtype dir;
  enum PWcontaintype rel;

  /* 
   * Obtain a vector from the start of the C segment to the tip of the
   * adjacent B segment. This will give us a measure of the distance of
   * this tip from the C vector. If no adjacent segment is passed in,
   * create the adjacent vector as aligned with the B segment.
   */

  vcba2[X] = bpt3 ? bpt3[X] - cpt1[X] : vb[X];
  vcba2[Y] = bpt3 ? bpt3[Y] - cpt1[Y] : vb[Y];

  dir = pwCrossProd2d (vc, vcba2, lentol, &c);

  if (dir == PWdir_along)
  {
    /*
     * C runs along the adjacent segment of B. But it may be alligned
     * or anti-alligned, and depending on how C traverses wrt B, which gives
     * us an 'on' containment for the 'left' or the 'right', respectively.
     * Then looking at whether the start-point of C is to right or left of
     * B (dir1) we get the other relative containment.
     */

    vba[X] = bpt3 ? bpt3[X] - bpt2[X] : vb[X];
    vba[Y] = bpt3 ? bpt3[Y] - bpt2[Y] : vb[Y];

    dotp = vc[X] * vba[X] + vc[Y] * vba[Y];
    if (dotp > 0.0)
    {
      rtrels[FIRST] = PWcontain_on;
      lfrels[FIRST] = dir1 == PWdir_left ? PWcontain_out : PWcontain_in;
    }
    else
    {
      lfrels[FIRST] = PWcontain_on;
      rtrels[FIRST] = dir1 == PWdir_left ? PWcontain_in : PWcontain_out;
    }
  }

  else 
  {
    /*
     * We know that the tip of the adjacent B segment is not on C. Therefore,
     * the 'rels involve only IN, OUT (and not ON).
     *
     * Obtain the adjacent B segment vector. If the adjacent segment is not
     * passed in, create a virtual vector that is the same as the segment's, ie,
     * create the adjacent vector as aligned with the given segment.
     */

    vba[X] = bpt3 ? bpt3[X] - bpt2[X] : vb[X];
    vba[Y] = bpt3 ? bpt3[Y] - bpt2[Y] : vb[Y];

    dir = pwCrossProd2d (vc, vba, lentol, &c);

    if (dir == dir3)
    {
      /*
       * C comes in from either 'in' or 'out' and stays 'in' or 'out',
       * since bpt1 and bpt3 are on the same side of C. Depending
       * on whether the B vertex is convex or concave (cross-product between
       * B and BA yields BA as to the right or left, never zero since we 
       * assume B and BA never overlap each other) the 'in' or 'out' is fully 
       * determined.
       */

      if (pwCrossProd2d (vb, vba, lentol, &c) == PWdir_right)
        is_convex = TRUE;
      else
        is_convex = FALSE;

      rel = is_convex ? PWcontain_out : PWcontain_in;
      lfrels[FIRST] = rel;
      rtrels[FIRST] = rel;
    }

    else 
    {
      /*
       * C comes in from either 'in' or 'out' and toggles to 'out' or 'in', 
       * since bpt1 and bpt3 are on opposite sides of C. The left and right
       * orientation can be easily known from the traversal of C wrt B.
       */

      lfrels[FIRST] = dir1 == PWdir_right ? PWcontain_in : PWcontain_out;
      rtrels[FIRST] = dir1 == PWdir_right ? PWcontain_out : PWcontain_in;
    }
  }

  return;
}


/*
  DESCRIPTION

  Helper function that computes the relative orientation when it is known
  that the stop point of C lies in the middle of B and that these two
  segments are not collinear. The reasoning is identical to the function
  for stopb_midc, except the values of the relorients obtained are quite
  different. There is only one interaction point.
*/

static void compute_midb_stopc_relcontain
(
  PWpoint2d cpt2,
  double *cpt3,
  PWvector2d vb,
  PWvector2d vc,

  enum PWdirtype dir1,
  double lentol,

  enum PWcontaintype lfrels[2],
  enum PWcontaintype rtrels[2]
)
{
  double c;
  PWvector2d vca;
  enum PWdirtype dir;
  enum PWcontaintype rel;

  /*
   * Obtain the adjacent B segment vector. If the adjacent segment is not
   * passed in, create a virtual vector that is the same as the segment's, ie,
   * create the adjacent vector as aligned with the given segment.
   */

  vca[X] = cpt3 ? cpt3[X] - cpt2[X] : vc[X];
  vca[Y] = cpt3 ? cpt3[Y] - cpt2[Y] : vc[Y];

  dir = pwCrossProd2d (vb, vca, lentol, &c);

  if (dir == PWdir_along)
  {
    /*
     * B overlaps the adjacent segment of C. Regardless, the right-rel will
     * be ON. The left rel is OUT or IN depending on whether start of C is to
     * the left or right of B (dir1).
     */

    rtrels[FIRST] = PWcontain_on;
    lfrels[FIRST] = dir1 == PWdir_right ? PWcontain_in : PWcontain_out;
  }

  else if (dir == dir1)
  {
    /*
     * C comes in from either 'in' or 'out' and stays 'in' or 'out',
     * since cpt1 and cpt3 are on the same side of B. Depending
     * on whether start C is to the left or right of B the rels are determined
     * (dir1).
     */

    rel = dir1 == PWdir_right ? PWcontain_in : PWcontain_out;
    lfrels[FIRST] = rel;
    rtrels[FIRST] = rel;
  }

  else 
  {
    /*
     * C comes in from either 'in' or 'out' and toggles to 'out' or 'in'
     * since cpt1 and cpt3 are on opposite sides of B. Start of C being 
     * to the right or left of B (dir1) yields the rels.
     */

    lfrels[FIRST] = dir1 == PWdir_right ? PWcontain_in : PWcontain_out;
    rtrels[FIRST] = dir1 == PWdir_right ? PWcontain_out : PWcontain_in;
  }

  return;
}

/*
  DESCRIPTION

  Helper function that returns the correct relative orientation when the
  B and C segments interact at the stop points. The fact that vb and vc
  may be aligned as they both proceed towards each other's stop-points
  is also input (we do not want to re-obtain this toleranced information).
  There is only one interaction point.
*/

static void compute_stopb_stopc_relcontain
(
  PWpoint2d bpt2,
  PWpoint2d bpt3,
  PWpoint2d cpt2,
  PWpoint2d cpt3,

  PWvector2d vb,
  PWvector2d vc,

  enum PWdirtype dir1,
  double lentol,

  PWboolean is_aligned,

  enum PWcontaintype lfrels[2],
  enum PWcontaintype rtrels[2]
)
{
  int poswrtc[4], tposwrtf[3];
  double d, c;
  PWvector2d _vb, _vc, vba, vca, vecs[4], tvecs[3];
  enum PWrelvectype rel_b_ca, rel_c_ba, rel_ba_ca;

  /*
   * Obtain the adjacent segment vectors. If the adjacent segment is not
   * passed in, create a virtual vector that is the same as the segment's, ie,
   * create the adjacent vector as aligned with the given segment.
   */

  vba[X] = bpt3 ? bpt3[X] - bpt2[X] : vb[X];
  vba[Y] = bpt3 ? bpt3[Y] - bpt2[Y] : vb[Y];

  vca[X] = cpt3 ? cpt3[X] - cpt2[X] : vc[X];
  vca[Y] = cpt3 ? cpt3[Y] - cpt2[Y] : vc[Y];

  /*
   * The rels are obtained by doing a polar sort of the vectors (vb, vba,
   * vc and vca) relative to vc. For clarity, the incoming segments at the
   * stop point are reversed so as to get all out-going segments. Typically,
   * vb and vc are reversed. The sort works well only when none of the
   * vectors are aligned. So we have to first weed out cases where there 
   * is alignment. When vb and vc are aligned, we have a special situation
   * and this is treated differently. 
   */

  if (is_aligned)
  {
    /*
     * B and C are aligned. We know the left rel is ON. We have to obtain the
     * right rel only. Note that reversing B and C will still retain an
     * alignment. So a different logic is gone through and only one of them
     * (B) is reversed. Before we get to the typical case, we have to weed out
     * other alignments, specially. Only two are possible - 1) BA and CA
     * are aligned, 2) C and CA are aligned. Other cases of potential
     * alignment need not be considered because of the assumption of no
     * self-intersection.
     */

    lfrels[FIRST] = PWcontain_on;

    if (pwDotLenTol2d (vba, vca, lentol, &d) == PWrelvec_aligned)
    {
      /*
       * BA overlaps CA. The right containment can be trivially returned
       * as ON.
       */

      rtrels[FIRST] = PWcontain_on;
    }

    else if (pwDotLenTol2d (vc, vca, lentol, &d) == PWrelvec_aligned)
    {
      /*
       * The vectors C and CA are aligned and would not yield a good sort
       * on the 4 vectors. Here the relative orientation is obtained by 
       * observing how BA traverses wrt C.
       */

      rtrels[FIRST] = pwCrossProd2d (vc, vba, lentol, &c) == PWdir_right ?
                       PWcontain_out : PWcontain_in;
    }
    else
    {
      /*
       * None of the vectors: -B, C, BA and CA are aligned. The position
       * of these vectors in a sort between them (relative to C) gives
       * the relative orientation being sought.
       */

      memcpy (vecs[VC], vc, sizeof (PWvector2d));
      memcpy (vecs[VCA], vca, sizeof (PWvector2d));
      _vb[X] = -vb[X]; _vb[Y] = -vb[Y];
      memcpy (vecs[_VB], _vb, sizeof (PWvector2d));
      memcpy (vecs[VBA], vba, sizeof (PWvector2d));

      pwSortVec2d (4, vecs, poswrtc);

      if (poswrtc[SECOND] == VCA && poswrtc[THIRD] == _VB ||
          poswrtc[SECOND] == _VB && poswrtc[THIRD] == VBA ||
          poswrtc[SECOND] == VBA && poswrtc[THIRD] == VCA)
      {
        /*
         * C crosses into the 'out' region with the adjacent vector.
         */

        rtrels[FIRST] = PWcontain_out;
      }
      else
      {
        /*
         * C crosses into the 'in' region with the adjacent vector.
         */
 
        rtrels[FIRST] = PWcontain_in;
      }
    }
  }

  else
  {
    /*
     * B and C are not aligned. These vectors are reversed so as to
     * obtain the vectors of out-going segments, away from the stop end.
     * First, the cases where the alignment between BA and CA and -B and -C
     * occurs, is handled specially. Use the fact that the adjacent segment
     * never overlaps the primary one. Four such distinct cases arise and
     * each is detected using dot-products and treated specially. If no
     * alignments are found the vectors are sorted and the orientation 
     * computed.
     */

    _vc[X] = -vc[X]; _vc[Y] = -vc[Y];
    memcpy (vecs[_VC], _vc, sizeof (PWvector2d));
    memcpy (vecs[VCA], vca, sizeof (PWvector2d));
    _vb[X] = -vb[X]; _vb[Y] = -vb[Y];
    memcpy (vecs[_VB], _vb, sizeof (PWvector2d));
    memcpy (vecs[VBA], vba, sizeof (PWvector2d));

    rel_ba_ca = pwDotLenTol2d (vecs[VBA], vecs[VCA], lentol, &d);
    rel_b_ca = pwDotLenTol2d (vecs[_VB], vecs[VCA], lentol, &d);
    rel_c_ba = pwDotLenTol2d (vecs[_VC], vecs[VBA], lentol, &d);

    if (rel_ba_ca == PWrelvec_aligned)
    {
      /*
       * BA and CA are overlapping. The right rel is ON. The left rel
       * is given by whether start of C is to the right or left of B (dir1).
       */

      rtrels[FIRST] = PWcontain_on;
      lfrels[FIRST] = dir1 == PWdir_right ? PWcontain_in : PWcontain_out;
    }
    else if (rel_b_ca == PWrelvec_aligned && rel_c_ba == PWrelvec_aligned)
    {
      /*
       * -B and CA are overlapping and so is -C and BA. The right rel and the
       * lf rel are ON.
       */

      lfrels[FIRST] = PWcontain_on;
      rtrels[FIRST] = PWcontain_on;
    }
    else if (rel_b_ca == PWrelvec_aligned)
    {
      /*
       * -B and CA are aligned but not -C and BA. The right rel is ON and the
       * left rel is given by checking whether in a sort of -B, -C and BA,
       * if -C is before BA. If so, left rel is IN else OUT.
       */
    
      rtrels[FIRST] = PWcontain_on;
      
      memcpy (tvecs[0], vecs[_VB], sizeof (PWvector2d));
      memcpy (tvecs[1], vecs[_VC], sizeof (PWvector2d));
      memcpy (tvecs[2], vecs[VBA], sizeof (PWvector2d));

      pwSortVec2d (3, tvecs, tposwrtf);
      lfrels[FIRST] = tposwrtf[SECOND] == 1 ? PWcontain_in : PWcontain_out;
    }
    else if (rel_c_ba == PWrelvec_aligned)
    {
      /*
       * -C and BA are aligned but not -B and CA. The left rel is ON and the
       * right rel is given by checking whether in a sort of -B, -C and CA,
       * if CA is before -C. If so, right rel is IN else OUT.
       */
 
      lfrels[FIRST] = PWcontain_on;
      
      memcpy (tvecs[0], vecs[_VB], sizeof (PWvector2d));
      memcpy (tvecs[1], vecs[_VC], sizeof (PWvector2d));
      memcpy (tvecs[2], vecs[VCA], sizeof (PWvector2d));

      pwSortVec2d (3, tvecs, tposwrtf);
      rtrels[FIRST] = tposwrtf[SECOND] == 2 ? PWcontain_in : PWcontain_out;
    }
    else
    {
      /*
       * Neither of the four vectors are aligned. A sort may be carried out
       * within the 4 vectors starting at -C. Then depending on how -B,
       * BA and CA are arranged we can get the rels.
       */

      pwSortVec2d (4, vecs, poswrtc);

      if (poswrtc[SECOND] == VCA && poswrtc[THIRD] == _VB ||
          poswrtc[SECOND] == _VB && poswrtc[THIRD] == VBA)
      {
        /*
         * C comes in from 'out' and turns back towards 'out'
         */
  
        lfrels[FIRST] = PWcontain_out;
        rtrels[FIRST] = PWcontain_out;
      }
      else if (poswrtc[SECOND] == VCA && poswrtc[THIRD] == VBA ||
               poswrtc[SECOND] == VBA && poswrtc[THIRD] == _VB)
      {
        /*
         * C comes in from 'in' and turns back towards 'in'.
         */

        lfrels[FIRST] = PWcontain_in;
        rtrels[FIRST] = PWcontain_in;
      }
      else if (poswrtc[SECOND] == _VB && poswrtc[THIRD] == VCA)
      {
        /*
         * C comes in from 'out' and turns into 'in'.
         */
  
        lfrels[FIRST] = PWcontain_out;
        rtrels[FIRST] = PWcontain_in;
      }
      else
      {
        /*
         * This leaves only one possible combination of the sort.
         * C comes in from 'in' and turns into 'out'.
         */
  
        lfrels[FIRST] = PWcontain_in;
        rtrels[FIRST] = PWcontain_out;
      }
    }
  }

  return;
}

/*
  DESCRIPTION

   Helper function that computes the data related to the intersection
   point as it occurs precisely on the given segment (m) wrt to the other (n). 
   It is already known that the two segments have an intersection
   point and that there is no overlap.

   The parameters of the intersection point is obtained using a cross-product
   formula, that can be easily derived by studying the geometric meaning
   of the cross-products. 
*/

static void compute_intersection
(
  PWpoint2d mpt1,
  PWpoint2d mpt2,
  PWvector2d vm,
  PWvector2d vmn2,

  double c_m1_n1,
  double c_m1_n2,
  double c_n1_m1,
  double c_n1_m2,
  double lentol,

  double *mpar,
  enum PWtopopostype *mpos,
  PWpoint2d m_inter_pt
)
{
  double partol;
  enum PWdirtype dir1, dir2, dir3, dir4;
  double dotp=0, sqmag_m=0, diffX=0, diffY=0; 

  /*
   * The parameter is computed based on the geometric interpretation
   * of the cross-products. The computation follows two different paths.
   * First case  is when both the end points of segment n are on the same 
   * side of segment m. The other case is when they are on opposite side of 
   * segment m.
   *
   * First case involves calculation of dot product between the m segment
   * vector and a vector contructed by taking the stop point of segment n and
   * start point of segment m. The required parameter on segment m is obtained
   * by dividing this dot product by squre of magnitude of segment m. This
   * works out to be the projection of the stop point of segment n on segment
   * m.
   *
   * Second case formula is derived using some geometrical interpretation of
   * the input segments. The output parameter value is arrived at using 
   * similar triangles.
   *
   * Note that to avoid numerical instability dealing with near machine
   * zero numbers, the parameter is corrected to the nearest significant
   * number. Of course, a parameter of less than 0 or greater than 1 is
   * snapped back to the ends of the parametric range, maintaining the
   * intersection point on the segment.
   */

  dir1 = c_m1_n1 < 0.0 ? PWdir_right : 
                         (c_m1_n1 > 0.0 ? PWdir_left : PWdir_along);
  dir2 = c_m1_n2 < 0.0 ? PWdir_right : 
                         (c_m1_n2 > 0.0 ? PWdir_left : PWdir_along);
  if (dir1 == dir2)
  {
    /*
     * Here dir1 and dir2 can be either PWdir_left or PWdir_right. This is
     * because PWdir_along (both dir1 and dir2) case is handled previously 
     * in the calling function and control for that case should not come to
     * this function.
     */

    /*
     * Get the dot product between the vectors vm and vmn2
     */
    dotp = fabs (vm[X] * vmn2[X] + vm[Y] * vmn2[Y]);

    /*
     * Get the square of magnitude of 'm' segment. 'm' segment is represented
     * by the two end points 'mpt1' and 'mpt2'
     */
    diffX = mpt2[X] - mpt1[X];
    diffY = mpt2[Y] - mpt1[Y];

    sqmag_m = diffX * diffX  + diffY * diffY;
    *mpar = dotp / sqmag_m;
  }
  else /* (dir1 != dir2) */
  {
    /*
     * The parameter is computed based on the geometric interpretation
     * of the cross-products. The signs of these cross-products have
     * to be corrected when the endpoints of this segment (m) are on the same
     * side of the other segment (n). The formula is derived with the vector
     * lengths, hence a change in direction of measurement (which happens with
     * the segment being on the same side), causes a negative sign to appear
     * on the appropriate cross-product. See notes for further explanation.
     * Further, it is also known that this condition will happen only when the
     * stop point of a segment just falls short of the other segment (as we
     * have ignored the intersection with the start point).
     */
    dir3 = c_n1_m1 < 0.0 ? PWdir_right : 
                           (c_n1_m1 > 0.0 ? PWdir_left : PWdir_along);
    dir4 = c_n1_m2 < 0.0 ? PWdir_right : 
                           (c_n1_m2 > 0.0 ? PWdir_left : PWdir_along);
    if (dir3 == dir4)
    {
      c_n1_m1 = fabs(c_n1_m1);
      c_n1_m2 = -fabs(c_n1_m2);
    }
    else /* (dir3 != dir4) */
    {
      c_n1_m1 = fabs(c_n1_m1);
      c_n1_m2 = fabs(c_n1_m2);
    }
    *mpar = c_n1_m1 / (c_n1_m1 + c_n1_m2);
  }

  if (*mpar < MINDOUBLE)
    *mpar = 0.0;
  else if (*mpar > (1.0 - MINDOUBLE))
    *mpar = 1.0;

  /*
   * The intersection point (on m) is computed using the above param. If the
   * segments are "near" vertical or horizontal, their appropriate, averaged
   * co-ordinates are used to avoid numerical instability that may be incurred
   * while multiplying with a very small number.
   */

  if (fabs (vm[X]) < MINDOUBLE)
    m_inter_pt[X] = (mpt1[X] + mpt2[X]) / 2.0;
  else
    m_inter_pt[X] = mpt1[X] + *mpar * vm[X];

  if (fabs (vm[Y]) < MINDOUBLE)
    m_inter_pt[Y] = (mpt1[Y] + mpt2[Y]) / 2.0;
  else
    m_inter_pt[Y] = mpt1[Y] + *mpar * vm[Y];

  /*
   * Now based on the intersection parameters on the segments,
   * the topological positions are returned w.r.t. to the 
   * length tolerance.
   */

  partol = lentol / sqrt (vm[X] * vm[X] + vm[Y] * vm[Y]);
  if (*mpar <= partol)
    *mpos = PWtopopos_start;
  else if ((1.0 - *mpar) <= partol)
    *mpos = PWtopopos_stop;
  else
    *mpos = PWtopopos_middle;

  return;
}
