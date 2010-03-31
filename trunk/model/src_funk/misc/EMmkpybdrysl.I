/*
  DESCRIPTION

    Given a list of sorted points lying on a curve or a linestring, generated
    by intersection with an area-bounding geometry, this function converts this
    list into a sorted list of bounds that would represent the portion(s)
    lying within the area. It uses the geometry/topology of the area-geometry
    to determine which portions are in hole and which are in area, disregarding
    the directional information stored in the properties field of the
    intersection points (area-hole, hole-area, ...). If the list is a NULL
    list, the entire geometry is regarded as in area and one boundary will be
    returned.

    At the endpoints of the curve/linestring, point-structures may have to be
    added to output the boundaries. Such point-structures, allocated within
    this function, are returned on the argument list for user-interpretation.
    Some of the input point-structures may have to be deleted but no
    information about such an action is returned.

    The boundary list returned will be NULL-terminated.

  ARGUMENTS

    indata		- Input: The curve or the linestring on which the
                          boundaries are being computed.
    pylist		- Input/Output: The linked list of point-structures
                          that represent the intersections on indata. This
                          list is input sorted in the direction of increasing
                          parameterization. These same points (including
                          the structures) are used for the boundary-pairs.
                          Some might get added or deleted during the course
                          of this function.
    areadata		- Input: Information about the loopset or loop
                           or a closed polyline representing an area,
                           against which these points have been generated.
    options		- Input: Bit fields specifying certain operating
                           characteristics:
                            EMS_INTER_BDRYISAREA - If boundary is to be treated
                             as area or hole.
    ptolbas		- Input: Structure supplying information about the
                           paramteric tolerance to be used.
    func_free_info	- Input: User supplied function that gets called on
                           the "info" field of EMSpypoint structure when
                           the node is being deleted. The "info" pointer
                           is the single argument. If set to NULL, free()
                           is called.
    num_bdrys		- Output: The number of boundary pairs that are output.
    addatstart		- Output: If point-structure had to be added at 
                          the beginning, it's address is returned here. Else
                          a NULL address is returned. Can be set to
                          NULL (by value) by the caller if such information
                          is not required.
    addatstop		- Output: If point-structure had to be added at 
                          the end, it's address is returned here. Else
                          a NULL address is returned. Can be set to
                          NULL (by value) by the caller if such information
                          is not required.

  RETURN VALUE

    This is a function returning void. The return code in the msg argument
    could be one of the following:

    EMS_S_Success
      - If all went well

    EMS_E_InvalidArg
      - If the datatype for the curve/linestring is not 2D or 3D polyline
        or 2D or 3D curve, or
        the datatype of areadata is neither an EMSloopset/EMSloop nor a
        3D-polygon.
      - If the information giving the relative position of the input points
        on the geometry is set to unknown.
    EMS_E_NoDynamicMemory
      - Error encountered while allocating dynamic memory.
    EMS_E_BSerror
      - Error encountered during a math call.


  ASSUMPTIONS

    Information about the relative position of the intersection point on the
    input geometry (atstart, atmiddle or atstop) is expected to be correct.  

  NOTES
  
    Currently only the data types - EMSdata_poly2d and EMSdata_curve3d
    are supported.

  HISTORY

    NP  :  05/25/92  :  Added calls to functions that time the code.
    SS  :  06/27/89  :  Making the classification of a degenerate section
                        (whether representing a section in area/hole) 
                        improved.
    SS  :  03/10/89  :  Point location for degenerate sections carried
			out by special means.
    SS  :  03/09/89  :  The relative orientation property bits in the
                        end-boundaries are more intelligently set when
                        boundary-is-hole and the end-point has been
			artificially added.
    PP  :  02/22/88  :  Added support of loops.
    SS  :  12/10/87  :  Creation
*/

class implementation EMSloopset;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "OMmacros.h"
#include "emsdattyp.h"
#include "emserr.h"
#include "emsmacros.h"
#include "emsinterdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "timerdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
%safe
static void swap();
%endsafe

#define FIRST  0
#define MIDDLE 1
#define LAST   2

#define U 0
#define V 1
#define W 2

#define NUM_SAMPLEPTS 3

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern OMuword OPP_EMSloopset_class_id, OPP_EMSloop_class_id;
extern IGRboolean _use_timers;

from EMSedge import EMptcoinc;
from EMSloop import EMptnesting;
from EMSloop import EMget_props;

%safe
static IGRshort getbdryloc();
%endsafe

IGRlong EMmkpybdrysl (msg, indata, pylist, areadata, options, ptolbas,
                      num_bdrys, func_free_info, addatstart, addatstop)
IGRlong *msg;
struct EMSdataselect *indata;
struct EMSpypoint **pylist;
struct EMSdataselect *areadata;
IGRushort options;
struct EMSpartolbasis *ptolbas;
IGRint *num_bdrys;
void (*func_free_info)();
struct EMSpypoint **addatstart, **addatstop;
{
  IGRboolean bdryisarea, startadded, stopadded, *secinarea;
  IGRboolean prev_inarea, end_reached, set_direction, usebdryarea;
  IGRboolean flip, override_flip, flip_performed, nploop, ploop;
  IGRushort direction_bitsoff = NULL, pyptr_props = NULL;
  IGRushort props, nprops, lprops, nlprops;
  IGRshort loc1, loc2;
  IGRint numsecs, i, j, inx, indicator;
  IGRlong rc, nrc, msg_loc, stat_OM;
  IGRdouble intpts[NUM_SAMPLEPTS][2], tmppts[3*NUM_SAMPLEPTS], *tpts;
  IGRdouble len, cht, lentol, dist, *pt1, *pt2;
  GRobjid coinced, edge;
  struct IGRpolyline *inpoly, tpoly;
  struct IGRbsp_curve *incrv, *tcrv;
  struct EMSpypoint *pyptr, *tpyptr, **pyptrs, *temppy, *curr_pyptr;
  struct EMSdataselect tgeom;
  struct EMSptloc_info ptloc_info;
  struct GRid *areaobj = NULL;
  struct EMSsfintedpar *edpar, *nedpar;
  union EMSdata data;
  enum EMSdatatype datatype;
  OM_S_OBJECT_LINKAGE *nlp;
  extern void BSalloccv();
  extern void EMmkpybdrys(), EMgetactgm(), EMinternalpt(), EMpypoint_free();
  extern IGRboolean BSfreecv();
  extern IGRlong EMcount_loops();
  extern struct EMSpypoint *EMpypoint_malloc();

  /* start timer for EMmkpybdrysl */
  if (_use_timers)
    start_timer (T_EMMKPYBDRYSL);

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (addatstart)
    *addatstart = NULL;
  if (addatstop)
    *addatstop = NULL;
  *num_bdrys = NULL;

  tpts = NULL;
  tcrv = NULL;
  secinarea = NULL;
  pyptrs = NULL;
  nlp = NULL;

  if (!pylist)
    goto ret_end;

  datatype = indata->datatype;
  data = indata->data;
  EMerr_hndlr (datatype != EMSdata_poly2d && datatype != EMSdata_curve3d,
   *msg, EMS_E_InvalidArg, ret_end);

  /*
   * Determine the number of sections that are implied on the geometry
   * by the input point-list. Insert points denoting the beginning and/or
   * the ending of the geometry if such points do not already exist. Such
   * artificailly inserted nodes are returned in the arguments - addatstart 
   * and addatstop.
   */

  numsecs = 0;
  pyptr = *pylist;
  startadded = FALSE;
  stopadded = FALSE;
  do
    {
    if (pyptr)
      {
      pyptr_props = pyptr->props & EMS_PYPT_ATSTART;
      pyptr_props |= pyptr->props & EMS_PYPT_ATSTOP;
      pyptr_props |= pyptr->props & EMS_PYPT_ATMIDDLE;
      }
    EMerr_hndlr (pyptr && !pyptr_props, *msg,
     EMS_E_InvalidArg, ret_end);

    if (!pyptr || (pyptr == *pylist && !(pyptr_props & EMS_PYPT_ATSTART)))
      {
      /* 
       * There is no point-node at the start of
       * the geometry. Add a start node to the list. A section
       * of the incoming geometry has not yet been fully defined;
       * so numsecs is not yet incremented.
       */

      startadded = TRUE;
      tpyptr = EMpypoint_malloc (&msg_loc, 1);
      tpyptr->span_inx = 0;
      tpyptr->param = 0.0;
      if (datatype == EMSdata_poly2d)
        OM_BLOCK_MOVE (data.poly->points, tpyptr->point, 
         2 * sizeof (IGRdouble));
      else
        {
        BScveval (data.curve, 0.0, 0, tpyptr->point, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
        }
      tpyptr->props |= EMS_PYPT_ATSTART | EMS_PYPT_AREAAREA;
      tpyptr->props &= ~EMS_PYPT_EMPTY;
      tpyptr->info = NULL;
      if (addatstart)
        *addatstart = tpyptr;
      *pylist = tpyptr;
      if (pyptr)
        tpyptr->next = pyptr;
      else
        {
        pyptr = tpyptr;
        pyptr_props = tpyptr->props;
        }
      }

    if (pyptr != *pylist)
      {
      /*
       * A section of the incoming geometry has been fully traversed;
       * so increment numsecs.
       */

      numsecs++;
      }

    end_reached = !pyptr->next || (pyptr->props & EMS_PYPT_EMPTY) ||
                  pyptr->span_inx < 0;
    if (end_reached && !(pyptr_props & EMS_PYPT_ATSTOP))
      {
      /*
       * There is no point-node at the end of
       * the geometry. Add a stop-node. A section of the incoming
       * geometry has just been fully traversed; so increment numsecs.
       */
         
      stopadded = TRUE;
      tpyptr = EMpypoint_malloc (&msg_loc, 1);
      tpyptr->span_inx = datatype == EMSdata_poly2d ?  
                          data.poly->num_points-2 : 0;
      tpyptr->param = 1.0;
      if (datatype == EMSdata_poly2d)
        OM_BLOCK_MOVE (&data.poly->points[(data.poly->num_points-1)*2],
         tpyptr->point, 2 * sizeof (IGRdouble));
      else
        {
        BScveval (data.curve, 1.0, 0, tpyptr->point, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
        }
      tpyptr->props |= EMS_PYPT_ATSTOP | EMS_PYPT_AREAAREA;
      tpyptr->props &= ~EMS_PYPT_EMPTY;
      tpyptr->info = NULL;
      if (addatstop)
        *addatstop = tpyptr;
      temppy = pyptr->next;
      pyptr->next = tpyptr;
      pyptr = tpyptr;
      tpyptr->next = temppy;
      numsecs++;
      }

    pyptr = pyptr->next;
    }
  while (pyptr && pyptr->span_inx >= 0 && !(pyptr->props & EMS_PYPT_EMPTY));

  /*
   * Each section is independently checked whether it is in hole or area
   * and an array is maintained with this information.
   */

  secinarea = (IGRboolean *) om$malloc (size = (numsecs + 1) * 
               sizeof (IGRboolean));
  pyptrs = (struct EMSpypoint **) om$malloc (size = (numsecs + 1) *
            sizeof (struct EMSpypoint *));

  if (datatype == EMSdata_poly2d)
    {
    inpoly = data.poly;
    tpts = (IGRdouble *) om$malloc (size = inpoly->num_points * 2 *
            sizeof (IGRdouble));
    tpoly.points = tpts;
    tgeom.datatype = EMSdata_poly2d;
    tgeom.data.poly = &tpoly;
    }
  else
    {
    incrv = data.curve;
    BSalloccv (incrv->order, incrv->num_poles + 2 * incrv->order - 1,
     incrv->rational, NULL, &tcrv, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    tgeom.datatype = EMSdata_curve3d;
    tgeom.data.curve = tcrv;
    }

  bdryisarea = options & EMS_INTER_BDRYISAREA;
  pyptr = *pylist;
  if (options & EMS_INTER_USECHTTOL)
    {
    BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht);
    BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, len);
    lentol = ptolbas->tol * (cht / len);
    }
  else
    lentol = ptolbas->tol;

  for (inx=0; inx<numsecs; inx++)
    {
    EMgetactgm (&msg_loc, indata, pyptr, &tgeom);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    EMinternalpt (&msg_loc, NULL, NULL, &tgeom, EMScvint_middle, NUM_SAMPLEPTS,
     tmppts);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    if (tgeom.datatype == EMSdata_curve3d)
      EM3dto2d (tmppts, NUM_SAMPLEPTS);
    OM_BLOCK_MOVE (tmppts, intpts, NUM_SAMPLEPTS * 2 * sizeof (IGRdouble));

    /*
     * Check to see if the subsequent point defining this section is
     * topologically coincident with the starting point of this section.
     * That is, the internal point is less than tolerance away from the
     * ends of the section and the section ends are within tolerance of
     * each other. This ensures a topological coincidence as opposed to
     * a geometric one (eg, closed curve geometry with the section end-points
     * at the end-points of the curve).
     */

    pt1 = pyptr->point;
    dist = sqrt (EM2ddistptpts (pt1, intpts[MIDDLE]));
    if (dist < lentol)
      {
      pt2 = pyptr->next->point;
      dist = sqrt (EM2ddistptpts (pt2, intpts[MIDDLE]));
      if (dist < lentol)
        {
        dist = sqrt (EM2ddistptpts (pt1, pt2));
        if (dist < lentol)
          pyptr->props |= EMS_PYPT_NXTCOINC;
        }
      }
 
    /*
     * Obtain the location of the internal point
     * w.r.t. to the loopset/geometric-loop.
     */

    getbdryloc (&msg_loc, options, areadata, ptolbas, intpts[MIDDLE],
     &ptloc_info);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * Based on the information returned from the point-location,
     * decide if this section is in area or in hole. If the location indicated
     * is on an existing boundary (edge or a vertex), further checks are
     * necessary to determine whether the section is in area/hole. Such
     * further checks will be limited to the situation when the input of
     * the existing boundary is in the form of a loopset/loop object. When
     * this is not the case, we will revert to using 'bdryisarea' as the
     * discriminator.
     * 
     * SECTION IS DEGENERATE:
     * This section is therefore deduced to lie within a degenerate portion
     * of the existing boundary. We would try and find the other boundary
     * element with which this first point of the section is coincident. We
     * would do this by an indepedent, geometric means. Now, whether this is
     * an area-section or a hole-section depends on the properties of the
     * topology element(s) that bound this section - If the first section-point
     * lies i) on a P-loop adjacent to another P-loop the point-section is in
     * hole, ii) on a C-loop and adjacent to a C-loop, section is in area,
     * iii) on a P-loop (or C-loop) and adjacent to a C-loop (or P-loop),
     * section is in area, iv) on coincident parts of the same loop and this
     * is a P-loop and a neighboring point comes out to be in hole, section is
     * in area else if no neighboring point in hole then section is in hole,
     * v) on coincident parts of the same loop and this is a C-loop
     * and a neighboring point comes out to be in area, section is in hole
     * else if no neighboring point in area then section is in area. The
     * reasoning for iv) and v) have been derived based on the possibility
     * of an inward and an outward degenerate portion on a given loop.
     *
     * SECTION IS NON-DEGENERATE:
     * Two possibilities arise. The more common one is when the entire section
     * is coincident with the boundary (so any internal point picked will come
     * out as lying on the boundary). The second is that this section makes
     * contact with the boundary in a limited portion of itself (so only if
     * the internal point picked happens to be one that lies in this section
     * will se come to this situation). In the former case, we decide whether
     * the section is an area section or not based on whether we are treating
     * the boundary as belonging to a hole or area. In the latter case, the
     * decision needs to be based on finding whether the portion of the section
     * that does not lie on the boundary, lies in a hole or area. Currently a
     * brute force technique is adopted. More internal points on the section
     * are obtained, if these also occur on the boundary then we surmise that
     * it is the former case. If these do not lie on the boundary, then we
     * obtain hole/area from the point-location information.
     */

    if (ptloc_info.location == EMS_L_INAREA)
      secinarea[inx] = TRUE;
    else if (ptloc_info.location == EMS_L_INHOLE)
      secinarea[inx] = FALSE;
    else if (ptloc_info.location == EMS_L_ONEDGE ||
             ptloc_info.location == EMS_L_ONVRTX)
      {
      usebdryarea = TRUE;
      if (areadata->datatype == EMSdata_object)
        {
        areaobj = areadata->data.object;
        if (pyptr->props & EMS_PYPT_NXTCOINC)
          {
          /*
           * Internal point indicates that this point on the section is
           * on boundary and the section is degenerate.
           */

          stat_OM = om$send (msg = message EMSedge.EMptcoinc (&msg_loc,
                     pyptr->point, &coinced, NULL, NULL, NULL, ptolbas),
                     targetid = ptloc_info.edge[FIRST].edge_id,
                     targetos = areaobj->osnum, senderid = NULL_OBJID);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
          if (msg_loc == EMS_I_Found)
            {
            stat_OM = EMcount_loops (&msg_loc, coinced, &indicator, &nlp,
                       EMLP_ACTIVE, NULL, NULL);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc) || !indicator, *msg,
             EMS_E_LoopError, ret_end);

            stat_OM = om$send (msg = message EMSloop.EMget_props (&msg_loc,
                       &nprops), targetid = nlp->S_objid,
                       targetos = areaobj->osnum, senderid = NULL_OBJID);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
            nploop = nprops & EMLP_PLOOP;
  
            if (ptloc_info.loop_id == nlp->S_objid)
              {
              stat_OM = om$send (msg = message EMSedge.EMptcoinc (&msg_loc,
                         pyptr->point, NULL, &loc1, &loc2, NULL, ptolbas),
                         targetid = ptloc_info.edge[FIRST].edge_id,
                         targetos = areaobj->osnum, senderid = NULL_OBJID);
              EMomerr_exit (stat_OM, ret_end);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
  
              if (nploop)
                secinarea[inx] = (loc1 == EMS_L_INHOLE || 
                                  loc2 == EMS_L_INHOLE);
              else
                secinarea[inx] = (loc1 != EMS_L_INAREA && 
                                  loc2 != EMS_L_INAREA);
              }
            else
              {
              stat_OM = om$send (msg = message EMSloop.EMget_props (&msg_loc,
                         &props), targetid = ptloc_info.loop_id,
                         targetos = areaobj->osnum, senderid = NULL_OBJID);
              EMomerr_exit (stat_OM, ret_end);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
              ploop = props & EMLP_PLOOP;
  
              secinarea[inx] = !(nploop && ploop);
              }
            usebdryarea = FALSE;
          
            om$dealloc (ptr = nlp);
            nlp = NULL;
            }
          }
        else
          {
          /*
           * Internal point indicates that this point on the section is
           * on boundary but the section is not degenerate.
           */

          for (i=FIRST, j=0; j<2; i=LAST, j++)
            {
            IGRushort location;

            location = getbdryloc (&msg_loc, options, areadata, ptolbas,
                        intpts[i], NULL);
            if (location == EMS_L_INAREA || location == EMS_L_INHOLE)
              {
              secinarea[inx] = location == EMS_L_INAREA ? TRUE : FALSE;
              usebdryarea = FALSE;
              break;
              }
            }
          }
        }

      if (usebdryarea)
        secinarea[inx] = bdryisarea ? TRUE : FALSE;
      }
    else
      EMerr_hndlr (TRUE, *msg, EMS_E_LoopsetError, ret_end);

    pyptrs[inx] = pyptr;
    pyptr = pyptr->next;
    }
  secinarea[numsecs] = FALSE;
  pyptrs[numsecs] = pyptr;

  /*
   * Adjacent sections which are in hole (or area) are merged by the deletion
   * of the common point between them. Sections at either of the geometry
   * that lie within a hole region are similarly deleted. If this process
   * causes the artificially inserted node at the beginning and/or ending to 
   * get deleted, the addatstart and/or addatstop argument is correctly 
   * updated. The props field in the point-nodes is set to reflect the
   * direction in which the geomtry progresses w.r.t. the area of the
   * loopset/geometric-loop.
   */

  prev_inarea = FALSE;
  direction_bitsoff = (IGRushort) (~(EMS_PYPT_HOLEAREA | EMS_PYPT_AREAHOLE |
                        EMS_PYPT_AREAAREA | EMS_PYPT_HOLEHOLE |
                        EMS_PYPT_RELUNKNOWN));
  curr_pyptr = NULL;
  for (inx=0; inx<numsecs+1; inx++)
    {
    if (prev_inarea && secinarea[inx] ||
        !prev_inarea && !secinarea[inx])
      {
      /*
       * This section lies in the same kind of region (hole or area)
       * as the previous section. The starting node of this section must
       * be removed so as to merge the sections.
       *
       * If the following node (at the end of this section) is coincident
       * with this one, a check is made to see if reversing the order of the
       * two nodes will improve the situation for the subsequent section,
       * taking into account the already present hole-area information in the
       * props field of the nodes. That is, assume that the next section lies
       * in an alternating (area-hole) region. Now check if this reversal will
       * maintain consistency w.r.t. the hole-area transition properties at
       * the end of this section. If it happens to be the last node, this
       * check is never made, since the coincident property will never be set
       * for this case.
       *
       * Iff one of nprops/props has the transition unknown, provide it with
       * the complement of the other. This is done as the best guess for the
       * unknown transition. This boils down to accepting RELUNKNOWN as 
       * a wild card in the if-checks below, but overriding the flip
       * decision if both the props are unknown.
       */
      
      flip_performed = FALSE;
      props = pyptrs[inx]->props;
      if (props & EMS_PYPT_NXTCOINC)
        {
        nprops = pyptrs[inx+1]->props;
        if (prev_inarea)
          flip = 
           ((nprops & EMS_PYPT_HOLEAREA || nprops & EMS_PYPT_AREAAREA ||
             nprops & EMS_PYPT_RELUNKNOWN) && 
            (props & EMS_PYPT_HOLEHOLE || props & EMS_PYPT_AREAHOLE ||
             props & EMS_PYPT_RELUNKNOWN)) ||
                       
           ((nprops & EMS_PYPT_HOLEHOLE ||
             nprops & EMS_PYPT_RELUNKNOWN) &&
            (props & EMS_PYPT_AREAHOLE ||
             props & EMS_PYPT_RELUNKNOWN));
        else
          flip = 
           ((nprops & EMS_PYPT_AREAHOLE || nprops & EMS_PYPT_HOLEHOLE ||
             nprops & EMS_PYPT_RELUNKNOWN) &&
            (props & EMS_PYPT_AREAAREA || props & EMS_PYPT_HOLEAREA ||
             props & EMS_PYPT_RELUNKNOWN)) ||

           ((nprops & EMS_PYPT_AREAAREA ||
             nprops & EMS_PYPT_RELUNKNOWN) &&
            (props & EMS_PYPT_HOLEAREA ||
             props & EMS_PYPT_RELUNKNOWN));
        pyptrs[inx]->props &= ~EMS_PYPT_NXTCOINC;

        if (props & EMS_PYPT_RELUNKNOWN && nprops & EMS_PYPT_RELUNKNOWN)
          override_flip = TRUE;
        else
          override_flip = FALSE;

        if (flip && !override_flip)
          {
          swap (inx, pyptrs, pylist);
          flip_performed = TRUE;
          }
        }

      /*
       * Remove the starting node of this section. Also, update the
       * current output pylist (it's next pointer) and if an artificially
       * added node is the one being removed (atstart or atstop) reflect
       * this in the appropriate return arguments.
       */

      tpyptr = pyptrs[inx];
      if (tpyptr->info)
        {
        if (func_free_info)
          (*func_free_info)(tpyptr->info);
        else
          om$dealloc (ptr = tpyptr->info);
        }
      temppy = tpyptr->next;
      EMpypoint_free (tpyptr, 1);
      pyptrs[inx] = NULL;

      if (curr_pyptr)
        curr_pyptr->next = temppy;

      if (inx == 0 && startadded && !flip_performed)
        {
        startadded = FALSE;
        if (addatstart)
          *addatstart = NULL;
        }
      else if (inx == numsecs && stopadded)
        {
        stopadded = FALSE;
        if (addatstop)
          *addatstop = NULL;
        }
      }
    else
      {
      /*
       * This section's type is the opposite of it's previous section.
       * Hence, it's starting node is a valid part of the output list.
       * Update the output list in "curr_pyptr".
       */

      if (! curr_pyptr)
        {
        curr_pyptr = pyptrs[inx];
        *pylist = curr_pyptr;
        }
      else
        {
        curr_pyptr->next = pyptrs[inx];
        curr_pyptr = curr_pyptr->next;
        }

      /*
       * If the following node (at the end of this section) is coincident
       * with this one, a check is made to see if reversing the order of the
       * two nodes of this section, maintains the toggling sequence of
       * area-hole... with the already present transition properties. In the
       * case where the property-bits indicate a lack of knowledge of
       * transition, we look for edge-incidence information inside the
       * EMSpypoint structures. From these edges the transition can be gleaned.
       * If a reversal is warranted, this is done, else the directions bits are
       * forced in, using the information about which section is in hole and
       * which in area.
       */

      set_direction = TRUE; 
      props = pyptrs[inx]->props;
      if (props & EMS_PYPT_NXTCOINC)
        {
        nprops = pyptrs[inx+1]->props;
        flip = FALSE;

        if (props & EMS_PYPT_RELUNKNOWN && 
            nprops & EMS_PYPT_RELUNKNOWN)
          {
          if (areadata->datatype == EMSdata_object &&
              (edpar = (struct EMSsfintedpar *) pyptrs[inx]->info) &&
              (nedpar = (struct EMSsfintedpar *) pyptrs[inx+1]->info))
            {
            edge = edpar->edgeid;
            lprops = NULL;
            rc = FALSE;
            EMsend_loops (&rc, message EMSloop.EMget_props (&msg_loc,
             &lprops), edge, 0, 0, EMLP_ACTIVE, NULL, NULL);
            
            edge = nedpar->edgeid;
            nlprops = NULL;
            nrc = FALSE;
            EMsend_loops (&nrc, message EMSloop.EMget_props (&msg_loc,
             &nlprops), edge, 0, 0, EMLP_ACTIVE, NULL, NULL);

            if (rc == EMS_S_Success && nrc == EMS_S_Success)
              {
              if (prev_inarea)
                {
                if ((nlprops & EMLP_PLOOP) && !(lprops & EMLP_PLOOP))
                  flip = TRUE;
                }
              else
                {
                if (!(nlprops & EMLP_PLOOP) && (lprops & EMLP_PLOOP))
                  flip = TRUE;
                }
              }
            }
          }

        else if (prev_inarea)
          flip = ((nprops & EMS_PYPT_AREAHOLE &&
                   !(props & EMS_PYPT_AREAHOLE)) ||

                  (props & EMS_PYPT_HOLEAREA &&
                   !(nprops & EMS_PYPT_HOLEAREA)));
        else
          flip = ((nprops & EMS_PYPT_HOLEAREA &&
                   !(props & EMS_PYPT_HOLEAREA)) ||

                  (props & EMS_PYPT_AREAHOLE &&
                   !(nprops & EMS_PYPT_AREAHOLE)));
        pyptrs[inx]->props &= ~EMS_PYPT_NXTCOINC;


        if (flip)
          {
          swap (inx, pyptrs, pylist);
          curr_pyptr = pyptrs[inx];
          set_direction = props & EMS_PYPT_RELUNKNOWN ||
                          nprops & EMS_PYPT_RELUNKNOWN ? TRUE : FALSE;
          }
        }

      if (set_direction)
        {
        pyptrs[inx]->props &= direction_bitsoff;
        if (prev_inarea)
          pyptrs[inx]->props |= (pyptrs[inx]->props & EMS_PYPT_ATSTOP && 
                                 (bdryisarea || stopadded) ?
                                 EMS_PYPT_AREAAREA : EMS_PYPT_AREAHOLE);
        else
          pyptrs[inx]->props |= (pyptrs[inx]->props & EMS_PYPT_ATSTART &&
                                 (bdryisarea || startadded) ?
                                 EMS_PYPT_AREAAREA : EMS_PYPT_HOLEAREA);
        }

      if (prev_inarea)
        (*num_bdrys)++;

      prev_inarea = !prev_inarea;
      }
    }

  /*
   * If no output list was formed for whatever reason, make the return
   * output argument NULL.
   */

  if (! curr_pyptr)
    *pylist = NULL;

ret_end:
  if (tpts)
    om$dealloc (ptr = tpts);
  if (tcrv)
    BSfreecv (&msg_loc, tcrv);
  if (secinarea)
    om$dealloc (ptr = secinarea);
  if (pyptrs)
    om$dealloc (ptr = pyptrs);
  if (nlp)
    om$dealloc (ptr = nlp);

  /* stop timer for EMmkpybdrysl */
  if (_use_timers)
    stop_timer (T_EMMKPYBDRYSL, FALSE, "");

  EMWRAPUP (*msg, stat_OM, "EMmkpybdrysl");
  return (stat_OM);
}

static void swap (inx, pyptrs, head)
IGRint inx;
struct EMSpypoint **pyptrs, **head;
{
  IGRint i;
  struct EMSpypoint *prev, *temp;

  prev = NULL;
  for (i=inx-1; i>=0; i--)
    if (pyptrs[i])
      {
      prev = pyptrs[i];
      break;
      }

  if (prev)
    prev->next = pyptrs[inx+1];
  else
    *head = pyptrs[inx+1];

  temp = pyptrs[inx+1]->next;
  pyptrs[inx+1]->next = pyptrs[inx];
  pyptrs[inx]->next = temp;

  temp = pyptrs[inx+1];
  pyptrs[inx+1] = pyptrs[inx];
  pyptrs[inx] = temp;
}

static IGRshort getbdryloc (msg, options, areadata, ptolbas, pt,
                            ptloc_info)
IGRlong *msg;
IGRushort options;
struct EMSdataselect *areadata;
struct EMSpartolbasis *ptolbas;
IGRpoint pt;
struct EMSptloc_info *ptloc_info;
{
  IGRushort props;
  IGRshort location;
  IGRint indicator;
  IGRlong msg_loc, stat_func;
  IGRpoint locpt;
  GRclassid classid;
  struct GRid *areaobj;
  struct EMSptloc_info *p_ptloc_info, loc_ptloc_info;
  extern void BSpt_in_plg();

  *msg = EMS_S_Success;

  location = EMS_L_UNKNWN;
  if (ptloc_info)
    p_ptloc_info = ptloc_info;
  else
    p_ptloc_info = &loc_ptloc_info;

  if (areadata->datatype == EMSdata_object)
    {
    areaobj = areadata->data.object;
    om$get_classid (osnum = areaobj->osnum, objid = areaobj->objid,
     p_classid = &classid);
   
    if (classid == OPP_EMSloopset_class_id)
      {
      p_ptloc_info->options = EMS_PTLOC_BOXCHECK | EMS_PTLOC_ACTLOOP |
                               EMS_PTLOC_LS_INFINITE |
                               (options & EMS_INTER_USECHTTOL ?
                               EMS_PTLOC_USECHTTOL : NULL);
      om$send (msg = message EMSloopset.EMpt_location (&msg_loc,
       pt, p_ptloc_info, ptolbas), 
       targetid = areaobj->objid, targetos = areaobj->osnum,
       senderid = NULL_OBJID);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);
     
      location = p_ptloc_info->location;
      }
    else if (classid == OPP_EMSloop_class_id)
      {
      p_ptloc_info->options = EMS_PTLOC_BOXCHECK | EMS_PTLOC_ACTLOOP |
                               (options & EMS_INTER_USECHTTOL ?
                               EMS_PTLOC_USECHTTOL : NULL);
      p_ptloc_info->location = EMS_L_UNKNWN;
      p_ptloc_info->num_located_edges = 0;

      om$send(msg = message EMSloop.EMptnesting (&msg_loc,
       pt, p_ptloc_info, ptolbas),
       targetid = areaobj->objid, targetos = areaobj->osnum,
       senderid = NULL_OBJID);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

      location = p_ptloc_info->location;
      if (location == EMS_L_INSIDE)  
        {
        om$send (msg = message EMSloop.EMget_props (&msg_loc,
         &props), targetid = p_ptloc_info->loop_id, targetos = areaobj->osnum,
         senderid = NULL_OBJID);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

        if (props & EMLP_PLOOP)
          location = p_ptloc_info->location = EMS_L_INAREA;
        else
          location = p_ptloc_info->location = EMS_L_INHOLE;
        }
      else if (location != EMS_L_ONEDGE && location != EMS_L_ONVRTX)
        {
        om$send (msg = message EMSloop.EMget_props (&msg_loc, &props),
         targetid = areaobj->objid, targetos = areaobj->osnum,
         senderid = NULL_OBJID);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

        if (props & EMLP_PLOOP)
          location = p_ptloc_info->location = EMS_L_INHOLE;
        else
          location = p_ptloc_info->location = EMS_L_INAREA;
        }
      }
    else
      {
      /*
       * Input object is neither a loopset nor a loop.
       */

      EMerr_hndlr (TRUE, *msg, EMS_E_NotSupported, ret_end);
      }
    }

  else if (areadata->datatype == EMSdata_poly3d)
    {
    locpt[U] = pt[U];
    locpt[V] = pt[V];
    locpt[W] = 0.0;
    BSpt_in_plg (areadata->data.poly, locpt, FALSE, NULL, &indicator, 
     &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    if (indicator == 1)
      location = EMS_L_INAREA;
    else if (indicator == 2)
      location = EMS_L_ONEDGE;
    else
      location = EMS_L_INHOLE;
    }

  else
    {
    /*
     * The input area object is of a type that is not supported
     */

    EMerr_hndlr (TRUE, *msg, EMS_E_NotSupported, ret_end);
    }

ret_end:
  stat_func = TRUE;
  EMWRAPUP (*msg, stat_func, "getbdryloc");
  return (location);
}

end implementation EMSloopset;
