/*
  DESCRIPTION

  This function is used to determine the geometric interaction points 
  between a 2D-polyline that bounds an area (B-poly) and another
  2D-polyline (I-poly). The I-poly polyline is typically, the intersection
  curve in the UV-space of a surface as it interacts with another. The B-poly
  is ordered such that it bounds area on it's right. The I-poly does not bound
  any area but it's flow direction is significant in that the classification of
  the interaction points being returned by this function will be in terms of 
  this direction.

  A significant output is the relative containment classification of these
  points. The classification is in terms of how the I-poly flows with
  respect to the area of the B-poly. That is, whether it is in->out,
  in->on, on->out, etc., where, 'in' refers to inside area, 'out' refers to
  outside area (or inside hole), 'on' refers to on the boundary. Thus, there
  can be 9 possible classes into which the interactions fit. 

  This function optionally takes in an additional segment for the B and I
  polylines, respectively, which serves to define the bounded area in the
  immediate vicinity of the logical stop point of B and the way in which the C
  polyline continues on if it was part of a succession of polylines. This
  input when present will help return the correct relative orientation when
  there is an interaction at the logical stop point of either polylines. No
  interaction points are computed against these adjacent segments.

  This function is designed to be called iteratively over the polylines
  that comprise loops (typically closed). For this purpose, the interaction
  points at the logical start of these polylines is ignored. This
  is done so that when this function is used to process a loop, the
  vertex point is not processed twice. This behaviour of ignoring the start
  point interaction can be overriden by saying yes to the Boolean flags in the
  input argument list. Such an override will perhaps be chosen to process
  the first polyline in an open loop.


  NOTES

  It may be noted that if the orientation classification is ignored, 
  this function behaves like a regular intersection function.

  Care is taken to see that the zero-length tolerance being passed in is
  strictly respected.

  If either of the input polylines are closed, the corresponding 
  'process_start' flag is ignored. This, because the start point will get
  processed at the stop point anyway. Also, the adjacent-points are generated
  internally (any input adjacent points are also ignored). Therefore, if the
  caller inputs a closed polyline (within the specified lentol), the
  'adjpt' and 'process_start' arguments should be ignored by the caller.

  In fact, the interaction points at the logical starts of both the I and
  B polylines are always returned, but are marked as 'information only' when
  the request is the ignore the start points. So care must be taken by the
  caller to IGNORE these informational interaction points, in order to get
  the correct picture of interactions.


  ARGUMENTS

  b_numpts		- I: Number of points in B-poly that represent
                           the boundary of an area.
  b_pts			- I: The points of the B polyline.
  b_adjpt		- I: The point defining the segment directly
                           adjacent to the logical stop point of the B-poly
                           in the boundary loop being processed. Could be NULL.
                           (If NULL and the B-poly itself forms a closed area,
                           then the classification is correct as all the
                           information is inherent within this polyline).
  b_range		- I: The min/max range box of the B-poly. This is input
                           so that this function does not compute something
                           already computed once before, which will be 
                           quite often. The justification for this is solely
                           optimization.
  b_reverse		- I: Is the B-poly reversed in direction? If so, the 
                           flow is considered opposite that of the input
                           geometry. But the parameter information returned for
                           the interaction points will still be in terms of
                           the raw input. Also note that the adjacent point, if
                           passed in, applies to the logically flowing, stop 
                           end of the polyline.
  b_process_start	- I: If set to TRUE, then, if there is an
                           interaction at the logical start of the B polyline,
                           return it.

  i_numpts		- I: Number of points in I-poly that represent the
                           other polyline.
  i_pts			- I: The points of the I-poly.
  i_adjpt		- I: The point defining the segment directly adjacent
                           to the logical stop point of I-poly in the loop
                           being processed. Could be NULL. (If NULL and the
                           I polyline itself forms a closed area, then the
                           classification is correct as all the information is
                           inherent within this polyline).
  i_range		- I: The min/max range box of the I-poly. This is input
                           so that this function does not compute something
                           already computed once before, which will be 
                           quite often. The justification for this is solely
                           optimization.
  i_reverse		- I: Is the I polyline reversed in direction? The
                           parameter information returned for the interaction
                           points will always be in terms of the input 
                           polyline. The adjacent point, if passed in, applies
                           to the logical stop end of the polyline.
  i_process_start	- I: If set to TRUE, then, if there is an
                           interaction at the logical start of I_poly,
                           return it.

  lentol		- I: This value defines the distance within which
                           two points are said to be coincident.

  num_inters		- O: The number of interaction points found here. 
                           These include the overlap points. The intersections
                           are returned sorted on the I polyline. The overlap
                           regions are the intervening regions between two
                           adjacent points having the classification type:
                           X->on and on->Y, where X, Y are either 'in', 'out'
                           or 'on'. (We should see an on->on point only at the
                           ends of the polylines).
  inter_pts		- O: A linked list of PWcvinpt_list structures
                           that contain all the information about the
                           interaction points. This structure primarily points
                           to the interaction point on I-poly but also contains
                           similar information about this interaction as seen
                           on B-poly. This similar information is the 'sibling'
                           information. The actual points being returned are
                           computed on the respective polylines. If this list
                           on input is non-NULL, the output points are
                           appended to the list. Note that, 'num_inters' still
                           reflects only the points found within this
                           invocation.


  RETURN VALUE

  This function returns a code that could be one of the following:
  Success
  Failure - Internal
  Failure - Degenerate input.
  Failure - Dynamic Memory
  

  SEE ALSO

  See files PWgmdata.h and PWgmint.h for further explanation of the output
  data-structure


  HISTORY

  SS  :  10/25/94  :  Creation
*/

#include <alloca.h>
#include <math.h>
#include <memory.h>
#include "PWminimum.h"
#include "PWerror.h"
#include "PWattrib.h"
#include "PWgmdata.h"
#include "PWgmint.h"

#include "PWapi/intsgsg2d.h"
#include "PWapi/degengm.h"
#include "PWapi/rngbx.h"
#include "PWapi/samepts.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/posptgm.h"
#include "PWapi/sortgmint.h"
#include "PWapi/adjseg.h"

#define VIRT_SEG_INX -1

/*
 * Prototype(s) of the statically defined function(s) to support
 * the main function(s) defined here.
 */

static PWresult map_back
(
  int num_inpts,
  PWpoint2d *inpts,
  PWboolean sibling,
  double    tol,
  struct PWcvintpt_list *intlist
);


/*
 * Main body of the function
 */

PWresult pwIntPyPy2d 
(
  int b_numpts, 
  PWpoint2d *b_pts,
  struct PWadjseg *b_adjseg,
  PWrange2d b_range,
  PWboolean b_reverse, 
  PWboolean b_process_start,

  int i_numpts, 
  PWpoint2d *i_pts,
  struct PWadjseg *i_adjseg,
  PWrange2d i_range,
  PWboolean i_reverse, 
  PWboolean i_process_start,

  double lentol,

  int *num_inters,
  struct PWcvintpt_list **inter_pts
)
{
  int bseg, iseg, i, j, k;
  int bnumpts, inumpts, numints, count;
  double bpars[2], ipars[2];
  PWboolean bspans_removed, ispans_removed, bclosed, iclosed;
  PWboolean *bseg_in_ibx=NULL;
  PWboolean b_stoponi[2], i_stoponb[2];
  PWresult result=PW_K_Success;
  PWpoint2d *bpts, *ipts;
  double *ipt1, *ipt2, *ipt3, *bpt1, *bpt2, *bpt3,  *pt; 
  double *badjpt, *iadjpt; 
  PWpoint2d bintpts[2], iintpts[2];
  PWrange2d brange, irange, isgrange;
  struct PWcvintpt_list *interpts=NULL, *listnode, *nextnode, *first_iseg_node;
  struct PWcvintpt_list *prev_iinter=NULL;
  enum PWtopopostype bposs[2], iposs[2], poss;
  enum PWcontaintype lfrels[2], rtrels[2], tmprel, curr_rel;

  /*
   * Initialize the output arguments
   */

  *num_inters = 0;

  /*
   * Remove all degenerate spans from the input polylines, if they are present.
   * These cause erroneous intersection results to be produced on account
   * of tolerancing issues. If certain spans were removed from the input
   * data, special processing may be necessary to return the intersection 
   * results relative to the original input. If the removal of degenerate
   * spans nullifies the polyline(s) it means the polyline was degenerate.
   * In such a case, return an error.
   */

  if (pwNumDegenSpans2d (b_numpts, b_pts, lentol))
  {
    OnErrorState (b_numpts == 2, result, SetInfo (PW_K_Trimming, 
     PW_K_Degenerate), wrapup);
    bpts = (PWpoint2d *) alloca (b_numpts * sizeof (PWpoint2d));
    pwRemoveDegenSpans2d (b_numpts, b_pts, &bnumpts, bpts, lentol);
    bspans_removed = TRUE;
  }
  else
  {
    bnumpts = b_numpts;
    bpts = b_pts;
    bspans_removed = FALSE;
  }
  OnErrorState (bnumpts < 2, result, SetError (PW_K_Trimming, PW_K_Degenerate),
   wrapup);

  if (pwNumDegenSpans2d (i_numpts, i_pts, lentol))
  {
    OnErrorState (i_numpts == 2, result, SetInfo (PW_K_Trimming, 
     PW_K_Degenerate), wrapup);
    ipts = (PWpoint2d *) alloca (i_numpts * sizeof (PWpoint2d));
    pwRemoveDegenSpans2d (i_numpts, i_pts, &inumpts, ipts, lentol);
    ispans_removed = TRUE;
  }
  else
  {
    inumpts = i_numpts;
    ipts = i_pts;
    ispans_removed = FALSE;
  }
  OnErrorState (inumpts < 2, result, SetError (PW_K_Trimming, PW_K_Degenerate),
   wrapup);

  /*
   * Expand the input range of the input polylines by "lentol"
   * to be sure no spurious, trivial rejections take place.
   */

  memcpy (brange, b_range, sizeof (PWrange2d));
  pwExpandRange2d (brange, lentol);
  memcpy (irange, i_range, sizeof (PWrange2d));
  pwExpandRange2d (irange, lentol);

  /*
   * Check if the range boxes of the two polylines
   * intersect at all. If not, we are done.
   */

  if (!pwIsOverlapRngRng2d (brange, irange))
    goto wrapup;

  /*
   * Check each B segment against the I polyline range box. If this segment
   * is not contained within the box, we trivially reject this. This
   * trivial rejection is stored in a Boolean array for later use while
   * iterating over the segments. It is possible that neither of the B segments
   * intersect the C box. If so, we are done.
   */

  bseg_in_ibx = (PWboolean *) alloca ((bnumpts - 1) * sizeof (PWboolean));
  count = 0;
  for (bseg=0; bseg<bnumpts-1; bseg++)
    if (bseg_in_ibx[bseg] = !pwIsOutsideSegRng2d ((PWpoint2d *) bpts[bseg],
                              irange))
      count++;

  if (!count)
    goto wrapup;

  /*
   * If an input polyline is closed, the adjacent segment at the stop point
   * is obtained appropriately. Any input adjacent-segment is ignored.
   */

  bclosed = pwIsSamePt2d (bpts[FIRST], bpts[bnumpts-1], lentol);
  if (bclosed)
    badjpt = b_reverse ? bpts[bnumpts-2] : bpts[SECOND];
  else
    badjpt = b_adjseg ? b_adjseg->adjpt : NULL;

  iclosed = pwIsSamePt2d (ipts[FIRST], ipts[inumpts-1], lentol);
  if (iclosed)
    iadjpt = i_reverse ? ipts[inumpts-2] : ipts[SECOND];
  else
    iadjpt = i_adjseg ? i_adjseg->adjpt : NULL;

  /*
   * Perform the intersection calculation, looping over every 
   * B polyline segment for every I polyline segment. 
   */

  /*
   * If the start point of the I polyline has to be processed, then a virtual
   * segment is added to the iteration. This segment is the first logical
   * segment, reversed. This will enable the lower level segment function to
   * detect interactions at the now 'stop' point. Interactions other than at 
   * this 'stop' point will be ignored for this virtual I segment. 
   *
   * In fact, we always process for a start point interaction. If such an
   * interaction is found and the request is NOT to process the start point,
   * we will mark such an interaction as informational and this can then
   * ignored by the caller.
   */

  for (iseg = i_reverse ? inumpts-2 : 0, i=VIRT_SEG_INX;
       i<inumpts-1; 
       (i<0 ? iseg : (i_reverse ? iseg-- : iseg++)), i++)
  {
    /*
     * Obtain the range of the current I segment, widening it to safeguard
     * against spurious rejections. If the current iteration is processing
     * the virtual I segment, the range box used is that of the first (or last)
     * real segment. Such a range box is also guaranteed to contain the virtual
     * start point; which is the only point of interest here.
     */

    pwGetRange2d (2, (PWpoint2d *) ipts[iseg], isgrange);
    pwExpandRange2d (isgrange, lentol);
 
    /*
     * Obtain the I segment points individually, correcting for when the
     * polyline is reversed.
     */

    if (i_reverse)
    {
      ipt1 = ipts[iseg+1];
      ipt2 = ipts[iseg];
      ipt3 = iseg ? ipts[iseg-1] : iadjpt;
    }
    else
    {
      ipt1 = ipts[iseg];
      ipt2 = ipts[iseg+1];
      ipt3 = iseg<inumpts-2 ? ipts[iseg+2] : iadjpt;
    }

    /*
     * If this iteration is over the virtual C segment to take care of the
     * requested start point interaction, create this segment. The third
     * point is NULL.
     */

    if (i == VIRT_SEG_INX)
    {
      pt = ipt1;
      ipt1 = ipt2;
      ipt2 = pt;
      ipt3 = NULL;
    }

    /*
     * Initialize the interaction list pointer holder that will capture the
     * node in the list that is the first one corresponding to the interaction
     * point associated with this I segment.
     */

    first_iseg_node = NULL;

    /*
     * If the start point of the B polyline has to be processed, then a virtual
     * segment is added to the iteration. This segment is the first logical
     * segment, reversed. This will enable the lower level function to detect
     * interactions at the now 'stop' point. Interactions other than at this
     * 'stop' point will be ignored for this virtual B segment. 
     *
     * In fact, we always process for a start point interaction. If such an
     * interaction is found and the request is NOT to process the start point,
     * we will mark such an interaction as informational and this can then
     * ignored by the caller.
     */

    for (bseg = b_reverse ? bnumpts-2 : 0, j=VIRT_SEG_INX;
         j<bnumpts-1;
         (j<0 ? bseg : (b_reverse ? bseg-- : bseg++)), j++)
    {
      /* 
       * Skip those segments that have already been flagged as out of C range.
       * Also perform B segment vs. C segment box checks to further trivially
       * reject pairs.
       */

      if (!bseg_in_ibx[bseg])
        continue;

      if (pwIsOutsideSegRng2d ((PWpoint2d *) bpts[bseg], isgrange))
        continue;

      /*
       * Obtain the B segment points in sequence correcting for when the
       * polyline is reversed.
       */

      if (b_reverse)
      {
        bpt1 = bpts[bseg+1];
        bpt2 = bpts[bseg];
        bpt3 = bseg ? bpts[bseg-1] : badjpt;
      }
      else
      {
        bpt1 = bpts[bseg];
        bpt2 = bpts[bseg+1];
        bpt3 = bseg<bnumpts-2 ? bpts[bseg+2] : badjpt;
      }

      /*
       * If this iteration is over the virtual B segment to take care of the
       * requested start point interaction, create this segment. The third
       * point is NULL.
       */

      if (j == VIRT_SEG_INX)
      {
        pt = bpt1;
        bpt1 = bpt2;
        bpt2 = pt;
        bpt3 = NULL;
      }

      /*
       * Perform the segment-segment intersection. If found, store them in
       * a temporary linked list. Ignore interaction points occuring in the 
       * middle of any virtual segments.
       */

      if (pwIntSgSg2d (bpt1, bpt2, bpt3, ipt1, ipt2, ipt3, lentol,
           &numints, bintpts, iintpts, bpars, ipars, bposs, iposs,
           lfrels, rtrels, b_stoponi, i_stoponb))
      {
        /*
         * Special handling is required when the adjacent segment to the
         * B polyline is a B-spline curve. The following code resets, if
         * necessary, the rels on the B polyline accordingly.
         */

        if ((b_reverse ? !bseg : bseg==bnumpts-2) && b_adjseg &&
             b_adjseg->p_cvdata->datatype != PWcvdata_py2d)
        {
          for (k=0; k<numints; k++)
          {
            /*
             * Ignore the interaction point if it is not at the stop of any
             * virtual segment.
             */

            if ((i == VIRT_SEG_INX && iposs[k] != PWtopopos_stop) || 
                (j == VIRT_SEG_INX))
              continue;
             
            if (bposs[k] == PWtopopos_stop && 
                (lfrels[k] == PWcontain_on || rtrels[k] == PWcontain_on))  
            {
              struct PWcvdata i_data, b_data;
              struct PWcvpt   i_pt, b_pt;
              double          i_par, b_par;
              enum PWcontaintype intrels[2];
      
              i_data.datatype = PWcvdata_py2d;
              i_data.data.py2d.num_pts = inumpts;
              i_data.data.py2d.p_pts = ipts;

              b_data.datatype = PWcvdata_py2d;
              b_data.data.py2d.num_pts = bnumpts;
              b_data.data.py2d.p_pts = bpts;

              if (i == VIRT_SEG_INX && !i_reverse)
                i_par = 1.0 - ipars[k];
              else
                i_par = ipars[k];
                
              if (j == VIRT_SEG_INX && !b_reverse)
                b_par = 1.0 - bpars[k];
              else
                b_par = bpars[k];

              pwInitCvpt (&i_pt, PWtopopos_unknown, iintpts[k], 2, iseg,
                      (i_reverse ? 1.0 - i_par : i_par), PW_K_NullObjid);
              pwInitCvpt (&b_pt, PWtopopos_unknown, bintpts[k], 2, bseg, 
                      (b_reverse ? 1.0 - b_par : b_par), PW_K_NullObjid);

              result = pwClassifyInteractionWithAdjseg (&b_data, b_reverse,
                             b_adjseg->p_cvdata, b_adjseg->reversed, &b_pt,
                             &i_data, i_reverse, NULL, FALSE, &i_pt,  NULL,   
                             lentol, intrels);
              OnErrorState (IsError (result), result, result, wrapup);

              lfrels[k] = intrels[LEFT];
              rtrels[k] = intrels[RIGHT];

              if (i == VIRT_SEG_INX)
              {
                tmprel = lfrels[k];
                lfrels[k] = rtrels[k];
                rtrels[k] = tmprel;
              }
            }
          }
        }

        /*
         * This is the regular handling of the interaction points generated
         */

        for (k=0; k<numints; k++)
        {
          /*
           * Ignore the interaction point if it is not at the stop of any
           * virtual segment.
           */

          if ((i == VIRT_SEG_INX && !i_stoponb[k]) || 
              (j == VIRT_SEG_INX && !b_stoponi[k]))
            continue;

          /*
           * Some special processing is required if this interaction point
           * is related to a virtual segment. The interaction point info
           * has to be massaged to relate it to the real world (recall that
           * the virtual segment is always logically reversed wrt to the
           * real logical segment and would have been constructed, reversed wrt
           * the original geometry, when the logical for the polyline said
           * 'not reversed'). 
           *
           * Also, note that the 'topopos' information relates to the
           * topological position of the INTERACTION point ALONG the
           * segment. This is different from the semantics of 'X_stoponY'; 
           * which simply denotes that the respective stop-point was within
           * tolerance of the other segment. The interaction point computation,
           * which tries to return the exact point of interaction between the
           * two segments, may yield a point that is further away from an 
           * end-point than tolerance. See related document for a further
           * discussion on this issue.
           */

          if (i == VIRT_SEG_INX)
          {
            if (!i_reverse)
              ipars[k] = 1.0 - ipars[k];

            if (iposs[k] == PWtopopos_stop)
              iposs[k] = PWtopopos_start;

            tmprel = lfrels[k];
            lfrels[k] = rtrels[k];
            rtrels[k] = tmprel;
          }

          if (j == VIRT_SEG_INX)
          {
            if (!b_reverse)
              bpars[k] = 1.0 - bpars[k];
 
            if (bposs[k] == PWtopopos_stop)
              bposs[k] = PWtopopos_start;

            if (lfrels[k] == PWcontain_in)
              lfrels[k] = PWcontain_out;
            else if (lfrels[k] == PWcontain_out)
              lfrels[k] = PWcontain_in;

            if (rtrels[k] == PWcontain_in)
              rtrels[k] = PWcontain_out;
            else if (rtrels[k] == PWcontain_out)
              rtrels[k] = PWcontain_in;
          }
         
          listnode = pwCreateCvintptList (&interpts);
          OnErrorState (!listnode, result, SetError(PW_K_Trimming, 
           PW_K_DynamicMemory), wrapup);

          if (!first_iseg_node)
            first_iseg_node = listnode;

          /*
           * The topopos is valid only for the first and last segments. So,
           * consider the rels only when processing the first and last segm-
           * ents.
           */

          if (i_reverse ? 
               ((iseg == 0 && iposs[k] == PWtopopos_stop) ||
                (iseg == (inumpts-2) && iposs[k] == PWtopopos_start)) :
               ((iseg == 0 && iposs[k] == PWtopopos_start) || 
                (iseg == (inumpts-2) && iposs[k] == PWtopopos_stop)))
          {
            /*
             * Processing the FIRST segment and the interaction point is at
             * the START OR Processing the LAST segment and the interaction
             * point is at the STOP. 
             */

            poss = iposs[k];
            if (poss == PWtopopos_start)
            {
              /* 
               * The flow of the I-Poly in the backward direction is unknown
               * as there is no adjacent segment info.
               */

              lfrels[k] = PWcontain_unknown;  
            }
            else if (poss == PWtopopos_stop && !iadjpt)
            {
              /*
               * The flow of the I-Poly in the forward direction is unknown
               * as there is no adjacent segment info.
               */

              rtrels[k] = PWcontain_unknown;  
            }
          }
          else
          {
            /*
             * Processing one of the middle segments OR the interaction point
             * is not at the logical START or STOP of the I-Poly.
             */

            poss = PWtopopos_middle;
          }

          pwInitCvpt (&listnode->intpt.cvpt, poss, iintpts[k], 2,
           iseg, (i_reverse ? 1.0 - ipars[k] : ipars[k]), PW_K_NullObjid);

          /*
           * The topoopos is valid only for the first and last segments. So,
           * consider the rels only when processing the first and last segm-
           * ents.
           */

          if (b_reverse ? 
              ((bseg == 0 && bposs[k] == PWtopopos_stop) ||
               (bseg == (bnumpts-2) && bposs[k] == PWtopopos_start)) :
              ((bseg == 0 && bposs[k] == PWtopopos_start) ||
               (bseg == (bnumpts-2) && bposs[k] == PWtopopos_stop)))
          {
            /*
             * Processing the FIRST segment and the interaction point is at
             * the START OR Processing the LAST segment and the interaction
             * point is at the STOP.
             */

            poss = bposs[k];
          }
          else
          {
            /*
             * Processing one of the middle segments OR the interaction point
             * is not at the logical START or STOP of the I-Poly.
             */

            poss = PWtopopos_middle;
          }

          pwInitCvpt (&listnode->intpt.sibling, poss, bintpts[k], 2,
           bseg, (b_reverse ? 1.0 - bpars[k] : bpars[k]), PW_K_NullObjid);

          pwSetContainCvintpt (&listnode->intpt, LEFT, lfrels[k]);
          pwSetContainCvintpt (&listnode->intpt, RIGHT, rtrels[k]);

          (*num_inters)++;
        }
      }
    }

    /*
     * We have obtained all the interaction points on this I segment with
     * the B polyline. Sort these interaction points along this I segment,
     * taking care to update the start of the 'interpts' linked list if 
     * needed. Remove redundant interaction points that are points within 
     * an overlap. To do the latter:
     * 1) Take care of the nodes that were not fully processed on the previous
     *    segment as info about the subsequent nodes was not available at the 
     *    time. (Go back upto 2 nodes, as three nodes are required to execute
     *    one successful iteration. The centre node is the one being processed
     *    with the two neighbors providing the info).
     * 2) Get the forward (right) containment from the left neighbor and the
     *    backward (left) containment from the right neighbor. If both are 'on'
     *    AND the centre node is ON->ON, then it is deemed that the centre
     *    node is redundant. Hence delete it. 
     * 3) Go on to the next node and look-up it's left and right neighbor
     *    similarly. And so on until there are no left or right neighbors to
     *    look-up.
     * Note that, this algorithm will always leave the first and the last node
     * untouched.
     */

    if (first_iseg_node)
    {
      pwSortCvintptList (&first_iseg_node, lentol);
      if (!first_iseg_node->p_prev)
        interpts = first_iseg_node;

      prev_iinter = pwNodeAtInxCvintptList (first_iseg_node, -2);
      if (!prev_iinter)
        prev_iinter = pwNodeAtInxCvintptList (first_iseg_node, -1);
      if (!prev_iinter)
        prev_iinter = first_iseg_node;

      curr_rel = pwGetContainCvintpt (&prev_iinter->intpt, RIGHT);
      listnode = prev_iinter->p_next;
      while (listnode && listnode->p_next)
      {
        if (curr_rel == PWcontain_on &&
            (pwGetContainCvintpt (&listnode->intpt, LEFT) == 
              PWcontain_on &&
             pwGetContainCvintpt (&listnode->intpt, RIGHT) == 
              PWcontain_on &&
             pwGetContainCvintpt (&listnode->p_next->intpt, LEFT) == 
              PWcontain_on))
        {
          nextnode = listnode->p_next; 
          pwRemoveCvintptList (&interpts, listnode);
          pwFreeCvintptList (listnode);
          listnode = nextnode;

          (*num_inters)--;
        }
        else
        {
          curr_rel = pwGetContainCvintpt (&listnode->intpt, RIGHT);
          listnode = listnode->p_next;
        }
      }
    }
  }

  /*
   * As we always processed the start point of the I-Poly and B-Poly, we need
   * to delete the interaction points if any at the start of the input curves
   * if the process start is set to FALSE.
   */

  if (!i_process_start)
  {
    listnode = interpts;

    while (listnode)
    {
      if (pwGetTopoposCvpt (&listnode->intpt.cvpt) == PWtopopos_start)
        pwSetInfoNodeCvintptList (listnode);  

      listnode = listnode->p_next;
    }
  }

  if (!b_process_start)
  {
    listnode = interpts;

    while (listnode)
    {
      if (pwGetTopoposCvpt (&listnode->intpt.sibling) == PWtopopos_start)
        pwSetInfoNodeCvintptList (listnode);

      listnode = listnode->p_next;
    }
  }

  /*
   * If the input was altered (removal of degenerate spans), we must now
   * process the intersections to have them specified relative to the
   * original input. Note that the topological position information is
   * with respect to the logical flow of the geometry.
   */

  if (*num_inters && (bspans_removed || ispans_removed))
  {
    if (bspans_removed)
    {
      result = map_back (b_numpts, b_pts, TRUE, lentol, interpts);
      OnErrorCode (result, wrapup);
    }

    if (ispans_removed)
    {
      result = map_back (i_numpts, i_pts, FALSE, lentol, interpts);
      OnErrorCode (result, wrapup);
    }
  }

  /*
   * Append the interaction points accumulated here, to the final output
   */

  pwAppendCvintptList (inter_pts, interpts);

wrapup:
  PW_Wrapup (result, "pwIntPyPy2d");
  return (result);
}


/*
  DESCRIPTION
   
  A helper function that finds the new param-span_inx pair (and the
  corresponding point) for the list's, intpt's cvpt or the sibling field.
  The new parameters are determined by projection of the list's points onto
  the input set of points. A flag indicates whether to operate on 'cvpt' or
  the 'sibling' field.
*/

static PWresult map_back
(
  int num_inpts,
  PWpoint2d *inpts,
  PWboolean sibling,
  double tol,
  struct PWcvintpt_list *intlist
)
{
  PWresult result=PW_K_Success;
  PWpoint2d minpt;
  struct PWcvparam minpar;
  struct PWcvpt *cvpt;
  enum PWtopopostype minpos;

  while (intlist)
  {
    cvpt = sibling ? &intlist->intpt.sibling : &intlist->intpt.cvpt;
    result = pwProjPtRngPy2d (cvpt->pt, num_inpts, inpts, tol, 
              minpt, &minpar);
    OnErrorState (IsError (result), result, SetError (PW_K_Trimming,
     PW_K_Internal), wrapup);

    minpos = pwGetTopoposCvpt (cvpt);

    cvpt->cvparam = minpar;
    memcpy (cvpt->pt, minpt, sizeof (PWpoint2d));
    pwSetTopoposCvpt (cvpt, minpos);
 
    intlist = intlist->p_next;
  }

wrapup:
  PW_Wrapup (result, "map_back");
  return (result);
}
