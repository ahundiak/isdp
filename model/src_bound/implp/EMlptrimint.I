/*
  DESCRIPTION

    The input is a polyline of parametric points (inpoly) in the uv-space of
    this surface. These points are assumed to be 2D. The range box of the
    polyline can be optionally input. This method then returns the "cutting" 
    intersection of the linestring with itself (the loop). The intersection
    on the polyline is returned as a linked list of structures of type 
    EMSpypoint . The intersection on the loop (and it's children, atleast upto
    a depth specified by 'tree_depth') is returned as a linked list of type
    EMsfintedpar.

    If the "*myinters" pointer is not NULL, the method assumes an existing
    linked list and appends it's output at the end of this list. The same
    for the "*polyinters" pointer. If "myinters" (value) is itself NULL
    creation of this linked list is ignored. The same for "polyinters".
    If both are NULL (values), no computation of the intersection points
    is done and the method will return soon after it finds the first
    intersection. If no interection is found num_inters returned is zero
    (if an intersection is found the num_inters returned is non-zero).
    Further, either of these lists

  ARGUMENTS

    inpoly		- Input: The polyline containing the parametric
 			  line-string to be intersected with.
    inpoly_range	- Input: The range of 'inpoly'. Could be
			  NULL.
    partol_basis	- Input/Output: Structure containing the basis
			  tolerance for this parametric space. If it's
			  field ('is_valid') indicates invalid tolerance,
			  this method fetches this value from the
			  surface. After the fetch, 'is_valid' is set to
			  TRUE.
    tree_depth		- Input: The minimum depth in the loop-tree to which
			  this intersection must be carried out. A depth
			  of atleast one should set (for intersection with
			  ths loop).
    options		- Input: Options mask specifying the following:
                            For now nothing
    num_inters		- Number of intersections found.
    my_inters		- The linked list representing intersections on
			  this loop and it's relevant children. 
    polyinters		- The linked list representing the intersections
			  on the input polyline.

  RETURN VALUE

    The message code returned is one of the following:

    Success
    - EMS_S_Success
      All went well
    
    Error condition
    - EMS_E_InvalidArg
      The tree depth was less than or equal to zero
    - EMS_E_NoDynamicMemory
      Tried allocateing dynamic memory but failed
    - EMS_E_LoopError
      Failure in a message sent to a loop.

  ASSUMPTIONS

    The following assumptions are made if this loop is a natural loop:
      a) The surface is normalized w.r.t. it's knot-vectors.
      b) Knowledge of how a natural loop is constructed, viz, what edges are
         connected on what indices, is made use of.
      c) The natural loop is always a P-loop, that always encloses
         area (Otherwise it would be an external C-loop which at most, exists
         in a controlled, transitory situation but not in a stable loopset).

  NOTES

    See emsinterdef.h for options

  HISTORY

    SS  :  11/01/86  :  Creation
    SS  :  10/07/87  :  Modified the argument list to include the options
                        argument.
    SS  :  10/13/87  :  Added code to handle the options to treat boundary
                        as area, to return intersection with the end-points
                        specially.
*/

class implementation EMSloop;

#include "EMS.h"
#include "EMSbnd.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emssfint.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "emserr.h"
#include "emsmacros.h"

#define U 0
#define V 1
#define U_MIN 0
#define V_MIN 1
#define U_MAX 2
#define V_MAX 3
#define START 0
#define STOP  1

#define INIT_HOLD_SIZE 15

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSedge import EMedpytrimint;

method EMlppytrimint (IGRlong *msg; struct IGRpolyline *inpoly;
                      IGRdouble *inpoly_range; 
                      struct EMSpartolbasis *partol_basis;
                      IGRint tree_depth; IGRushort options;
                      IGRint *num_inters;
                      struct EMSsfintedpar **myinters;
                      struct EMSpypoint  **polyinters) 
{
  IGRboolean int_found[2], endpt_atend[2], regular_trim, bdryisarea;
  IGRboolean hold_processing, remzeropt, myold, polyold, doublecheck;
  IGRushort orntprops;
  IGRshort endinx, edge_inx[2], numseg_inters;
  IGRint stat_OM, blk_size, count;
  IGRint num_spans, spaninx, ptinx, wspan, cspan;
  IGRlong msg_loc;
  IGRdouble *inrange, *myrange, range[4], uvlentol, lentol, chttol, checktol;
  IGRdouble *endpts[2], intpar[2], wpar, cpar;
  IGRdouble dumpy[6];
  GRobjid edgeid, dumid;
  GRspacenum dumos;
  struct EMSinthold inthold;
  struct EMSpypoint pypthold_mem[INIT_HOLD_SIZE], *loc_polyinters=NULL;
  struct EMSsfintedpar eparhold_mem[INIT_HOLD_SIZE], *loc_myinters=NULL;
  struct IGRpolyline cpoly;
  enum EMScvinttype wtype, ctype;
  enum EMSrelorient relorient;
  OM_S_CHANSELECT chan_to_edges, chan_to_inner;
  void EM2dbx(), EMmkpyptlist(), EMmkeparlist();
  void EMint_preprocess(), EMint_process(), EMint_afterprocess();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (tree_depth <= 0, *msg, EMS_E_InvalidArg, ret_end);

  inthold.num_inhold = 0;
  inthold.pypts = pypthold_mem;
  inthold.epars = myinters ? eparhold_mem : NULL;
  inthold.malloc_at = INIT_HOLD_SIZE+1;
  edgeid = NULL_OBJID;
  doublecheck = options & EMS_INTER_MOREPRECISE;

  /*
   * Obtain the parametric-zero-length
   * tolerance
   */

  if (!partol_basis->is_valid)
    {
    stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
               &dumid, partol_basis), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    partol_basis->is_valid = TRUE;
    }

  if (options & EMS_INTER_USECHTTOL)
    {
    BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
    BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
    uvlentol = partol_basis->tol * (chttol / lentol);
    EMadjust_paramtol (&msg_loc, NULL, uvlentol, &uvlentol);
    }
  else
    uvlentol = partol_basis->tol;

  /*
   * Obtain the range box for the input
   * polyline, expanded by length tolerance
   */

  blk_size = 4 * sizeof (IGRdouble);
  if (!inpoly_range)
    {
    inrange = range;
    EM2dbx (inpoly->num_points, inpoly->points, inrange);
    EM2dbxinc (inrange, uvlentol);
    }
  else
    inrange = inpoly_range;
  myrange = ME.EMSloop->range;

  /*
   * Determine whether the trim-intersection calculation can
   * be done trivially without having to actually intersect
   * with the edges. This can happen only when the loop is 
   * natural and the incoming linestring is within the normalized
   * parametric range.
   */

  checktol = uvlentol + MINDOUBLE;
  if (ME.EMSloop->lp_props & EMLP_NATURAL && !doublecheck)
    {
    if (inrange[U_MIN] < -checktol ||
        inrange[V_MIN] < -checktol ||
        inrange[U_MAX] > 1.0 + checktol ||
        inrange[V_MAX] > 1.0 + checktol)
      regular_trim = TRUE;
    else
      regular_trim = FALSE;
    }
  else
    regular_trim = TRUE;
  
  /*
   * Perform the intersection calculation and prepare the output
   */

  if (regular_trim)
    { 
    /*
     * This loop is either not a natural loop or the incoming polyline
     * needs to be regularly trimmed. Hence a box-check
     * to trivially reject "inpoly" and not look any further
     * down this branch of the loop-tree, is meaningful.
     */

    if (! EM2dbxbxint (inrange, myrange))
      {
      /*
       * The input polygon's range is completely
       * outside this loop's range. Hence, no 
       * further action needs to be taken.
       */
  
      goto ret_end;
      }

    /*
     * The loop's range and the range of the input
     * polygon intersect. Possibly, intersections exist.
     * Each edge is sent the trim-intersection message. 
     */

    EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edges);

    stat_OM = om$send (msg = message EMSedge.EMedpytrimint (&msg_loc, 
               inpoly, inpoly_range, partol_basis, NULL, options, num_inters,
               myinters, polyinters), p_chanselect = &chan_to_edges);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMis_error (msg_loc), *msg, msg_loc, ret_end);
    }
  else
    {
    /*
     * The loop being natural, processing can be done more trivially, without
     * access to edges. An intersection exists only if the input poly's
     * range box intersects the natural range box.
     */

    if (inrange[U_MIN] <= 0.0 || inrange[V_MIN] <= 0.0 ||
        inrange[U_MAX] >= 1.0 || inrange[V_MAX] >= 1.0)
      {
      /*
       * There is a possibillity of cutting intersections being present.
       * Exclude the start point of the natural-edge when computing
       * intersection with an edge and specifically determine if
       * the intersection is at it's stop point. This avoids
       * counting intersections twice at a vertex and also
       * provides information about the location of the intersection 
       * on the vertex. The various options that might be specified might
       * require special handling.
       */

      if (polyinters && *polyinters && (*polyinters)->span_inx >= 0)
        {
        loc_polyinters = *polyinters;
        while (loc_polyinters->next && loc_polyinters->next->span_inx >= 0)
          loc_polyinters = loc_polyinters->next;
        polyold = TRUE;
        }
      else
        polyold = FALSE;

      if (myinters && *myinters && (*myinters)->edgepar.span_inx >= 0)
        {
        loc_myinters = *myinters;
        while (loc_myinters->next && loc_myinters->next->edgepar.span_inx >= 0)
          loc_myinters = loc_myinters->next;
        myold = TRUE;
        }
      else
        myold = FALSE;

      remzeropt = options & EMS_INTER_REMZEROEND;
      bdryisarea = options & EMS_INTER_BDRYISAREA;
      if (bdryisarea)
        {
        /*
         * If the boundary is to be treated as area then there can be no
         * transition from area to hole or vice versa. Hence no intersections
         * to be output. But the options may specify start-point or stop-point
         * on boundary information. And these are to be determined. It
         * may be noted here that when boundary is not area, the end point
         * options, if set or not, are satisfied by definition.
         *
         * Taking advantage of the manner in which boundary-is-hole gets
         * handled, a linestring is constructed using the end-points that
         * have their options set. Any artificial point that may be introduced
         * is defined at the centre of this parametric space to be
         * most away from the edges.
         */
         
        ptinx = 0;
        num_spans = 0;
        if (options & EMS_INTER_STARTPT)
          {
          dumpy[ptinx++] = inpoly->points[U];
          dumpy[ptinx++] = inpoly->points[V];
          num_spans++;
          }
        dumpy[ptinx++] = 0.5;
        dumpy[ptinx++] = 0.5;
        if (options & EMS_INTER_STOPPT)
          {
          count = (inpoly->num_points-1)*2;
          dumpy[ptinx++] = inpoly->points[count + U];
          dumpy[ptinx++] = inpoly->points[count + V];
          num_spans++;
          }
        cpoly.num_points = num_spans+1;
        cpoly.points = dumpy;
        }
      else
        {
        /*
         * Since boundary is not area, the processing can proceed without
         * any special monitoring.
         */

        num_spans = inpoly->num_points-1;
        cpoly = *inpoly;
        }

      /*
       * In accordance with the definition of a 'cutting' intersection
       * such that boundary is hole, only two cases are acceptable when
       * considering a segment of the incoming polyline:
       *   a) There is only one intersection (at either line-segment
       *      endpoint). In this case, the line-segment crosses from
       *      area to hole (or vice-versa).
       *   b) There are two intersections, but neither lies geometrically
       *      on the same edge. In this case, the line-segment crosses
       *      from hole to area to hole. 
       * N.B.: The case where both intersections are on the same edge,
       *       implies that the line-segment remains in hole. 
       */

      EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edges);

      for (spaninx=0, ptinx=0; spaninx<num_spans; spaninx++, ptinx+=2)
        {
        endpts[START] = &cpoly.points[ptinx];
        endpts[STOP] = &cpoly.points[ptinx+2];
  
        numseg_inters = 0;
        for (endinx=START; endinx<STOP+1; endinx++)
          {
          int_found[endinx] = FALSE;
          if (endpts[endinx][U] <= uvlentol && 
              endpts[endinx][V] >= uvlentol)
            {
            /*
             * An endpoint intersection with the first 
             * edge ([0,0] - [0,1]). Log an intersection only
             * if the other end-point does not exist on this
             * edge. Else, entire segment is in hole.
             */
      
            if (! (endpts[endinx == START ? STOP : START][U] <= uvlentol))
              {               
              numseg_inters++;
              int_found[endinx] = TRUE;
              edge_inx[endinx] = 0;
              intpar[endinx] = endpts[endinx][V];
              endpt_atend[endinx] = 
               (endpts[endinx][V] >= (1.0-uvlentol) ? TRUE : FALSE);
              }
            else
              {
              numseg_inters = 0;
              break;
              }
            }
          else if (endpts[endinx][V] >= (1.0-uvlentol) &&
                   endpts[endinx][U] >= uvlentol)
            {
            /*
             * An endpoint intersection with the first 
             * edge ([0,1] - [1,1]). Log an intersection only
             * if the other end-point does not exist on this
             * edge. Else, entire segment is in hole.
             */
      
            if (! (endpts[endinx == START ? STOP : START][V] >= 
                                                    (1.0-uvlentol)))
              {      
              numseg_inters++;
              int_found[endinx] = TRUE;
              edge_inx[endinx] = 1;
              intpar[endinx] = endpts[endinx][U];
              endpt_atend[endinx] = 
               (endpts[endinx][U] >= (1.0-uvlentol) ? TRUE : FALSE);
              }
            else
              {
              numseg_inters = 0;
              break;
              }
            }
          else if (endpts[endinx][U] >= (1.0-uvlentol) && 
                   endpts[endinx][V] <= (1.0-uvlentol))
            {
            /*
             * An endpoint intersection with the first 
             * edge ([1,1] - [1,0]). Log an intersection only
             * if the other end-point does not exist on this
             * edge. Else, entire segment is in hole.
             */
      
            if (! (endpts[endinx == START ? STOP : START][U] >= 
                                                    (1.0-uvlentol)))
              {      
              numseg_inters++;
              int_found[endinx] = TRUE;
              edge_inx[endinx] = 2;
              intpar[endinx] = 1.0 - endpts[endinx][V];
              endpt_atend[endinx] = 
               (endpts[endinx][V] <= uvlentol ? TRUE : FALSE);
              }
            else
              {
              numseg_inters = 0;
              break;
              }
            }
          else if (endpts[endinx][V] <= uvlentol &&
                   endpts[endinx][U] <= (1.0-uvlentol))
            {
            /*
             * An endpoint intersection with the first 
             * edge ([1,0] - [0,0]). Log an intersection only
             * if the other end-point does not exist on this
             * edge. Else, entire segment is in hole.
             */
      
            if (! (endpts[endinx == START ? STOP : START][V] <= uvlentol))
              {      
              numseg_inters++;
              int_found[endinx] = TRUE;
              edge_inx[endinx] = 3;
              intpar[endinx] = 1.0 - endpts[endinx][U];
              endpt_atend[endinx] = 
               (endpts[endinx][U] <= uvlentol ? TRUE : FALSE);
              }
            else
              {
              numseg_inters = 0;
              break;
              }
            }
          }

        if (numseg_inters)
          {
          /*
           * Cutting intersection(s) have been found w.r.t some natural
           * edge(s). Process these.
           */
  
          for (endinx=START; endinx<STOP+1; endinx++)
            {     
            if (int_found[endinx])
              {
              if (myinters)
                {
                stat_OM = om$get_objid_at_index (objid = my_id, 
                           p_chanselect = &chan_to_edges, index = 
                           edge_inx[endinx], objidaddr = &edgeid,
                           osnumaddr = &dumos);
                EMomerr_exit (stat_OM, ret_end);
                }
  
              wspan = 0;
              cspan = bdryisarea ? (endinx == START ? 
                                    0 : inpoly->num_points-2) :
                                   spaninx;
              wpar = intpar[endinx];
              cpar = endinx == START ? 0.0 : 1.0;
              wtype = endpt_atend[endinx] ? EMScvint_rtend : 
                                            EMScvint_middle;
              ctype = endinx == START ? EMScvint_lfend : EMScvint_rtend;
              relorient = bdryisarea ? EMSrelorient_area_area :
                                       (endinx == START ? 
                                        EMSrelorient_hole_area :
                                        EMSrelorient_area_hole);
              EMint_preprocess (&msg_loc, wspan, cspan, wpar, cpar,
               wtype, &ctype, endpts[endinx], relorient, FALSE, remzeropt,
               inpoly->num_points, edgeid, &orntprops, &inthold, 
               &hold_processing);
              EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
               if (! hold_processing)
                {
                if (!myinters && !polyinters)
                  {
                  *msg = EMS_I_Intersect;
                  *num_inters = TRUE;
                  goto ret_end;
                  }
                                                                    
                EMint_process (&msg_loc, 
                 myold ? &loc_myinters->next : myinters,
                 polyold ? &loc_polyinters->next : polyinters,
                 wspan, cspan, wpar, cpar, wtype, ctype, endpts[endinx],
                 edgeid, orntprops, NULL);
                EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
                (*num_inters)++;
                }
              }
            }
          }
        }

      /*
       * Check to see if any of the intersections required any 
       * post-processing. If so call the post-processor to output any
       * remaining valid intersections.
       */

      if (inthold.num_inhold)
        {
        EMint_afterprocess (&msg_loc, options,
         myold ? &loc_myinters->next : myinters,
         polyold ? &loc_polyinters->next : polyinters,
         num_inters, &inthold, 
         NULL);
        EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
        }
      }
    }

  /*
   * Send to inner loops
   */

  tree_depth--;
  if (tree_depth)
    {  
    EMmake_chanselect (EMSloop_to_inner, &chan_to_inner);

    stat_OM = om$send (msg = message EMSloop.EMlppytrimint (msg,
               inpoly, inpoly_range, partol_basis, tree_depth, options,
               num_inters, myinters, polyinters), 
               p_chanselect = &chan_to_inner);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (*msg), *msg, EMS_E_LoopError, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloop.EMlppytrimint");
  return (stat_OM);
}

end implementation EMSloop;
