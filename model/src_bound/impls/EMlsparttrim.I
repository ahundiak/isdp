/*
  DESCRIPTION:

   The input is geometry (ingeom) in the uv-space of this surface.
   This geometry is assumed to be 2D. This method then applies 
   the surface boundaries to this geometry and returns pairs of points that 
   represent the solid portions on the input geometry. These solid portions 
   are the pieces that would remain were the geometry to be clipped or 
   trimmed with respect to these boundaries. The pairs are consecutive elements
   on a linked list made up of EMSpypoint  structures. Associated with each 
   boundary element is some information that tells the caller the geometric 
   element of the surface (the edge) that caused this boundary to be created; 
   also the exact location on the edge, where the intersection took place. If
   this boundary was caused due to some reason other than an edge of the
   surface in question, the edge-id returned is NULL_OBJID.
  
   If zero pairs are returned (num_bdrys == 0), it means that no portion of
   the linestring is within a solid region on the surface. If the entire
   geometry is within the solid portion (no part is trimmed off), one
   pair of boundaries on the geometry will be returned. This pair represents
   the end-points of the geometry in that case.

   An option is available to do some special processing for overlap cases.
   If this option is chosen along with the option to treat boundary as area,
   the boundaries generated will treat the overlapping section as a distinct
   area section. If boundary is being treated as hole then this option is
   ignored. This option is also ignored if no boundaries are asked for
   on the input geometry.
   
  ARGUMENTS

    ingeom		- Input: The data containing the parametric line
 			  definition on this surface that has to be trimmed
			  w.r.t. to the surface boundaries.
    num_bdrys		- Output: The number of boundary pairs that define the
			  portion on the line data that is to be KEPT.
    bdrys 		- Output: Linked lists containing the ordered lists of 
    			  trim points for my_uvdata.
    bdry_parms		- Output: Linked lists containing information on
    			  the surface-edges that generated these trim points.
                          If a specific trim point was not generated explicitly
			  by an edge on this surface (perhaps by because it is 
			  a dangling end-point) the edgeid field in the node
                          would have been set to NULL_OBJID.

  RETURN VALUE

    Upon exit the completion code will be one of the following

      - EMS_I_InHoleTrim
          if entire geometry is in hole
      - EMS_I_InAreaTrim
          if entire geometry is within an area
      - EMS_I_IntersectTrim
          if part of the geometry is in area

      - EMS_E_InvalidArg 
          if the other surface data is neither an OM-object or a
           surface buffer or,
          the 'interpolate' flag is FALSE.
      - EMS_E_NoDynamicMemory
          if dynamic memory allocation was tried but failure occurred.
      - EMS_E_SurfaceError
          if a failure occurred when a call to a surface method was
          made.
      - EMS_E_LoopsetError
          if a failure occurred when a call to a surface-loopset method was
          made, or if an invalid loopset is seen to exist.
      - EMS_E_Fail
          Most probably a failure in a call to a math-function.
          In some cases the reason for failure was not understood in greater
          detail. 
      - EMS_I_NoMoreLoops
	  The loopset was found to be empty. 
	    
  SEE ALSO

    The file containing the surface method - EMparttrim. The file
    emsinterdef.h contains the options.

  BUGS
    
    This method assumes that the surface parameterization ranges from
    zero to one. The processing for PROCOVERLAP option will not work
    well if the following two conditions exist: i) If a degenerate
    boundary is returned while processing with boundary-as-hole and ii)
    at the same time no EMsfintedpar output is requested. The latter is
    used to resolve ambiguities about the degenerate boundaries.

  HISTORY

    SS  :  11/01/86  :  Creation
    SM  :  09/09/87  :  Added code for following -
			If the loopset  is empty, return the results as if
			the entire input geometry was in area and set the
			return code to EMS_I_NoMoreLoops.
    SM  :  13-jan-88 :  OM returns an error when send on empty channel.
			Handle that.
    SS  :  02/29/88  :  Postponement of the remove-zero-end option. This
                        allows the loopset to decide whether to remove
                        the intersection-point or not.
    SS  :  02/16/89  :  Added the special processing for overlap if that
                        option is set and boundary is being treated as
                        area.
    SS  :  08/03/89  :  Using EMendint_process instead of special_end_process
			Removed the function special_end_process.
    SS  :  09/11/89  :  Specially marked those pairs of boundary-points that
		 	are adjacent to each other but lie on topologically
			distinct points on the loopset, as ends of some
                        sequence.
    SS  :  09/27/89  :  The sample point for doing the point-location
                        while determining the topological positioning of the
                        input geometry, has been changed to use an internal
                         point.
    NP  :  05/25/92  :  Added "timer" function calls to time this method.
    NP  :  09/17/92  :  When using a sample point to check if the input data
			lies completely in area or completely in hole (when the
			input data has no intersection with the loopset), the
			mid point is NOT chosen. Choosing mid-pt causes 
                        problems
			with intersections overlapping boundary (i.e. along an
			edge and extending beyond it) if that mid-pt lies at an
			endpt of the edge.
    SS :  02/27/95   :  Removed reference to INT_OVERLAP property. Proved 
                        useless. 
			
*/
   
class implementation EMSloopset;

#include "EMS.h"
%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "emsdattyp.h"
#include "emserr.h"
#include "emsmacros.h"
#include "emsinterdef.h"
#include "emssfint.h"
#include "msdef.h"
#include "EMSbnd.h"
#include "EMSbnddef.h" 
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "timerdef.h"
#include "emsinter.h"
#include "emsgeteddef.h"


#define U 0
#define V 1

/*
 * If a point on a curve has to be regarded as internal to the curve it
 * must be away from the end-points by atleast a distance equal to
 * (MIDDLE_FACTOR * length_tolerance).
 */

#define MIDDLE_FACTOR 10

#define START 0
#define STOP  1

#define FIRST  0
#define SECOND 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSloop import EMlppytrimint, EMlpbstrimint, EMget_props;
from EMSloop import  EMnext_edge;

extern IGRboolean _use_timers;

method EMlsparttrim (IGRlong *msg; struct EMSdataselect *ingeom; 
                     struct EMSpartolbasis *tol_basis;
                     IGRushort options;
                     IGRint *num_bdrys; struct EMSpypoint **bdrys;
                     struct EMSsfintedpar **bdry_parms)
{
  IGRboolean data_in_hole, doublecheck, bdryisarea;
  IGRboolean ambiguous_state, special_bdry_handling;
  IGRboolean addtolist, possible_duplicate, on_interval, in_middle, on_start;
  IGRboolean equivalent_lists;
  IGRushort props, loc_options;
  IGRint stat_OM, num_inters, i, j, inxlim = 0, toginfo, samplept_loc = 0;
  OMuint num_loops;
  IGRint num_ovbdrys;
  IGRlong bsrc, msg_loc;
  IGRdouble samplept[6], ingeom_range[6], uvlentol, uvlentolsq, wlentol;
  IGRdouble p1u, p1v, p2u, p2v, d1, d2, chttol, lentol, *chkpt;
  GRobjid ovinced, pyinced;
  struct EMSpypoint *addpy[2], *rempystart, *rempystop;
  struct EMSpypoint *polyinters, *ovpolyinters, *pyptr, *ovpyptr, *tpyptr;
  struct EMSpypoint *prev_pyptr;
  struct EMSsfintedpar *addep[2];
  struct EMSsfintedpar *myinters, *ovmyinters, *epptr, *ovepptr, *tepptr;
  struct EMSsfintedpar *prev_epptr;
  struct EMSptloc_info ptloc_info;
  struct IGRpolyline *inpoly = NULL;
  struct IGRbsp_curve *incrv = NULL;
  struct GRid loopsetid;
  struct EMSdataselect loopdata;
  struct EMSedgebound startpar, stoppar, chkpar;
  struct EMSpartolbasis ovtol_basis;
  enum EMSdatatype geomtype;
  enum EMScvinttype pyloc, ovloc;
  OM_S_CHANSELECT chan_to_loops;
  extern IGRboolean BSbx2();
  extern void EM2dbx(), EMsortpypts(), EMmkpybdrys(), EMendint_process();
  extern void EMpypoint_free(), EMsfintedpar_free(), EMwpartol();
  extern IGRboolean EMpar_on_edintvl();
  extern IGRlong EMinternalpt(), EMmkpybdrysl();
  extern struct EMSpypoint *EMpypoint_malloc();
  extern struct EMSsfintedpar *EMsfintedpar_malloc();
 
  if (_use_timers)
    start_timer (T_EMLSPARTTRIM);
 
  *msg = EMS_I_InHoleTrim;
  stat_OM = OM_S_SUCCESS;

  *num_bdrys = 0;
  if (bdrys)
    *bdrys = NULL;
  if (bdry_parms)
    *bdry_parms = NULL;

  msg_loc = EMS_S_Success;
  myinters = NULL;
  polyinters = NULL;
  ovpolyinters = NULL;
  ovmyinters = NULL;
  doublecheck = options & EMS_INTER_MOREPRECISE;

  geomtype = ingeom->datatype;
  EMerr_hndlr (geomtype != EMSdata_poly2d && geomtype != EMSdata_curve3d,
   *msg, EMS_E_InvalidArg, ret_end);
  if (geomtype == EMSdata_poly2d)
    inpoly = ingeom->data.poly;
  else
    incrv = ingeom->data.curve;

  /*
   * Get this surfaces parametric-basis tolerance, if
   * it has not been passed in.
   */

  if (! tol_basis->is_valid)
    {
    stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
               NULL, tol_basis), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);
    tol_basis->is_valid = TRUE;
    }

  if (options & EMS_INTER_USECHTTOL)
    {
    BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
    BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
    uvlentol = tol_basis->tol * (chttol / lentol);
    EMadjust_paramtol (&msg_loc, NULL, uvlentol, &uvlentol);
    }
  else
    uvlentol = tol_basis->tol;

  /*
   * Get the range of input geometry. 
   */

  if (geomtype == EMSdata_poly2d)
    {
    EM2dbx (inpoly->num_points, inpoly->points, ingeom_range);
    EM2dbxinc (ingeom_range, uvlentol);
    }
  else
    {
    BSbx2 (&bsrc, &incrv->num_poles, incrv->poles, 
     incrv->rational ? incrv->weights : NULL, 
     &ingeom_range[0], &ingeom_range[3]);
    ingeom_range[0] -= uvlentol;
    ingeom_range[1] -= uvlentol;
    ingeom_range[3] += uvlentol;
    ingeom_range[4] += uvlentol;
    }

  /*
   * Obtain the "cutting" intersections on this input polyline with all
   * the boundaries, be they holes or areas on the surface. Only those
   * points on the polyline that transit from area ot hole or vice versa are
   * treated as intersections. For further details on this intersection
   * see the documentation for the function EM2dsgcutint.
   */

  if (_use_timers)
    start_timer (T30_TRIM_AGAINST_BOUNDARY);

  EMmake_chanselect (EMSloopset_to_loops, &chan_to_loops);
  num_inters = 0;
  options |= EMS_INTER_CUTTING | EMS_INTER_STARTPT | EMS_INTER_STOPPT;
  if (geomtype == EMSdata_poly2d)
    {
    stat_OM = om$send (msg = message EMSloop.EMlppytrimint (&msg_loc,
               inpoly, ingeom_range, tol_basis, MAXINT, options,
               &num_inters, bdry_parms ? &myinters : NULL, &polyinters), 
               p_chanselect = &chan_to_loops);
    if (stat_OM == OM_E_NOSUCHOBJ) 
      stat_OM = OM_S_SUCCESS;
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
    }
  else
    {
    stat_OM = om$send (msg = message EMSloop.EMlpbstrimint (&msg_loc,
               incrv, ingeom_range, tol_basis, MAXINT, options,
               &num_inters, bdry_parms ? &myinters: NULL, &polyinters), 
               p_chanselect = &chan_to_loops);
    if (stat_OM == OM_E_NOSUCHOBJ) 
      stat_OM = OM_S_SUCCESS;
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
    }

  if (_use_timers)
    stop_timer (T30_TRIM_AGAINST_BOUNDARY, FALSE, "");

  /*
   * The option to remove "zero-ends" was not excercised when computing
   * intersections. This was done to postpone the decision so that the
   * global topology (of the loopset) w.r.t. to the input-geometry is
   * made use of. Basically: a) if there is more than one intersection
   * at the end-point then no "zero-ends" are removed from that end-point.
   * The boundary forming is performed via the special-boundary-handling
   * function which takes into account the loopset-topology; b) but if
   * there is only one intersection at an end-point and it is a "zero-end",
   * it is removed and the logic proceeds normally.
   * N.B.: For an explanation of what is a "zero-end", see the include
   *       file - emsinterdef.h
   */

  EMendint_process (&msg_loc, &num_inters, &polyinters);
  special_bdry_handling = msg_loc == EMS_I_Ambiguous;

  ambiguous_state = FALSE;
  if (num_inters)
    {
    /* 
     * Sort the raw intersection linked list returned from the intersection
     * method. The linked list now represents a set of points ordered along
     * the geometry.
     */
  
    toginfo = EMS_L_UNKNWN;
    EMsortpypts (&msg_loc, &polyinters, 2, &toginfo, &uvlentol);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    ambiguous_state = (msg_loc == EMS_I_Ambiguous ||
                      doublecheck) ? TRUE : FALSE;
    special_bdry_handling = (special_bdry_handling || 
                             msg_loc == EMS_I_InvalidArg ||
                             doublecheck) ? TRUE : FALSE;
    }

  if (! num_inters || ambiguous_state)
    {
    /*
     * It needs to be determined whether the first point is in hole
     * or within an area in order to correctly evaluate the regions
     * that lie inside an area.
     */

    stat_OM = om$get_channel_count (object = me, p_chanselect = &chan_to_loops,
               count = &num_loops);
    EMomerr_exit (stat_OM, ret_end);				

    if (! num_loops)
      {
      *msg = EMS_I_NoMoreLoops;
      samplept_loc = EMS_L_INAREA;
      }
    else
      {
      /*
       * A sample point is obtained that lies at the starting endpoint of
       * the data if "ambiguous_state" has to be resolved, else an internal
       * point is used. Using this point a point location is done.
       * Get TWO internal points, but use the FIRST one in the point location.
       * This is to ensure that the exact middle point is not used, which is
       * not a good sample point. This is when num_inters=0.    NP 9/10/92.
       */

      stat_OM = EMinternalpt (&msg_loc, NULL, NULL, ingeom,
                 !num_inters ? EMScvint_middle : EMScvint_lfend,
                 !num_inters ? 2 : 1, samplept);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
      if (geomtype == EMSdata_curve3d)
        EM3dto2d (samplept, 2);

      bdryisarea = options & EMS_INTER_BDRYISAREA;
      if (ME.EMSloopset->ls_props & EMLS_NATURAL)
        {
        /*
         * Since there is only the natural boundary on
         * this surface, the location of the first point
         * of the input linestring can be determined more
         * trivially. 
         */

        if (samplept[U] <= uvlentol || samplept[U] >= (1.0 - uvlentol) ||
            samplept[V] <= uvlentol || samplept[V] >= (1.0 - uvlentol))
          {
          if (!num_inters && bdryisarea &&
              (samplept[U] >= -uvlentol && samplept[U] <= (1.0 + uvlentol) &&
               samplept[V] >= -uvlentol && samplept[V] <= (1.0 + uvlentol)))
            samplept_loc = EMS_L_INAREA;
          else
            samplept_loc = EMS_L_INHOLE;
          }
        else
          samplept_loc = EMS_L_INAREA;
        }
      else
        {
        /*
         * Determine if the sample point of inpoly lies inside an area or
         * not. There should be only three possibilities:
         *   i) The location is explicitly in area.
         *  ii) The location is unknown in the sense it is outside the loopset.
         *      In this case the situations is resolved depending on
         *      whether the external loops are P-loops or C-loops. This is
         *      accomplished by setting the bit that treats the loopset
         *      as a subset of an infinite plane.
         * iii) The location is explicitly in hole or it lies on some
         *      boundary. In the case where ambiguity has to be resolved it is
         *      regarded as in hole, else if the sample-point is on boundary,
         *      depending on whether boundary-is-area, the location is either
         *      in area or hole. 
         *      Caveat: If there were no intersections, then
         *      the characterization of the entire input geometry is done by 
         *      'samplept_loc'. The reasonable assumption being that if this
         *      were not true we should have obtained an intersection. Now,
         *      because of tolerancing issues and glancing situations (eg:
         *      the entire input geom is in hole except for a tangent point and
         *      samplept[FIRST] happens to be this or very close to the tangent
         *      point) we may end up making a wrong decision. To counter this,
         *      do a re-assurance check for a pt-location with the second
         *      samplept. If a pt-location can be generated that is
         *      unambiguosly in hole or area then that is location we want.
         */
  
        if (_use_timers)
          start_timer (T30_PT_LOCATION);

        ptloc_info.options = EMS_PTLOC_BOXCHECK | EMS_PTLOC_ACTLOOP |
                              EMS_PTLOC_LS_INFINITE |
                              (options & EMS_INTER_USECHTTOL ? 
                              EMS_PTLOC_USECHTTOL : NULL);
        for (i=FIRST, j=0; i<=SECOND; i++, j+=2)
          {
          stat_OM = om$send (msg = message EMSloopset.EMpt_location (&msg_loc,
                     &samplept[j], &ptloc_info, tol_basis), targetid = my_id);
          if (EMSerror (stat_OM & msg_loc) || 
              ptloc_info.location == EMS_L_UNKNWN ||
              (!num_inters ? 
                ptloc_info.location == EMS_L_ONEDGE ||
                 ptloc_info.location == EMS_L_ONVRTX :
                FALSE))
            continue;
          else
            break;
          }
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_LoopsetError,
         ret_end);

        if (_use_timers)
          stop_timer (T30_PT_LOCATION, FALSE, "");

        if (ptloc_info.location == EMS_L_INAREA)
          samplept_loc = EMS_L_INAREA;
        else if (!num_inters && 
                 (ptloc_info.location == EMS_L_ONEDGE ||
                  ptloc_info.location == EMS_L_ONVRTX))
          samplept_loc = bdryisarea ? EMS_L_INAREA : EMS_L_INHOLE;
        else
          samplept_loc = EMS_L_INHOLE;
        }
      }
    }
  data_in_hole = num_inters ? FALSE : samplept_loc == EMS_L_INHOLE;
  if (ambiguous_state && toginfo == samplept_loc)
    ambiguous_state = FALSE;
      
  /*
   * Format and return the output requested.
   */

  if (num_inters)
    *msg = EMS_I_IntersectTrim;
  else if (!data_in_hole)
    *msg = EMS_I_InAreaTrim;

  if (!bdrys && !bdry_parms)
    {
    *num_bdrys = (data_in_hole ? FALSE : TRUE);
    goto ret_end;
    }
  else if (! data_in_hole)
    {    
    if (ambiguous_state)
      {
      /* 
       * Sort the once-sorted intersection list again as the first sort
       * had some ambiguity. The toginfo is now well known and should not
       * yield any ambiguity.
       */
  
      toginfo = samplept_loc;
      EMsortpypts (&msg_loc, &polyinters, 2, &toginfo, &uvlentol);
      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
      if (!special_bdry_handling && msg_loc == EMS_I_InvalidArg)
        special_bdry_handling = TRUE;
      }

    if (! special_bdry_handling)
      {
      /*
       * Call the function that makes boundaries out of the intersection
       * on the curve/poly data. This function makes use of the props field
       * in the EMSpypoint structure to determine the correct area boundaries.
       * None of the intersections should require to be deleted.
       */
  
      EMmkpybdrys (&msg_loc, ingeom, &polyinters, num_bdrys, &addpy[START],
       &addpy[STOP], &rempystart, &rempystop);
      EMerr_hndlr (!*num_bdrys || rempystart || rempystop, *msg,
       EMS_E_Intersect, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
      }
    else
      {
      /* The props-field in the intersection point-structures did not show
       * consistency. Probable tolerancing errors in classifying intersections
       * has occurred. Use a different algorithm to output bdrys that
       * would be independent of this toggling characteristic.
       */
 
      loopsetid.objid = my_id;
      loopsetid.osnum = OM_Gw_current_OS;
      loopdata.datatype = EMSdata_object;
      loopdata.data.object = &loopsetid;

      if (_use_timers)
        start_timer (T30_MKPYBDRYSL);

      EMmkpybdrysl (&msg_loc, ingeom, &polyinters, &loopdata, options,
       tol_basis, num_bdrys, NULL, &addpy[START], &addpy[STOP]);
      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

      if (_use_timers)
        stop_timer (T30_MKPYBDRYSL, FALSE, "");

      if (! *num_bdrys)
        goto ret_end;
      }

    /*
     * Some post-processing may be required if 'bdry_parms' has been 
     * requested. If both 'bdrys' and 'bdry_parms' are requested, check
     * if adjacent boundary-points occupy different topological
     * positions; if so mark them as logical ends of a stream.
     */
   
    if (bdrys)
      *bdrys = polyinters;

    if (bdry_parms)
      {
      for (i=START; i<=STOP; i++)
        {
        if (addpy[i])
          {
          epptr = EMsfintedpar_malloc (&msg_loc, 1);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
          epptr->edgeid = NULL_OBJID;
          addpy[i]->info = (IGRchar *) epptr;
          }
        }
      inxlim = (*num_bdrys * 2) - 1;
      pyptr = polyinters;
      *bdry_parms = epptr = (struct EMSsfintedpar *) pyptr->info;
      for (i=0; i<inxlim; i++)
        {
        epptr->next = (struct EMSsfintedpar *) pyptr->next->info;
        pyptr = pyptr->next;
        epptr = epptr->next;
        }
      epptr->next = NULL;
      pyptr->next = NULL;
      }

    if (bdrys && bdry_parms)
      {
      uvlentolsq = uvlentol * uvlentol;
      pyptr = *bdrys;
      for (i=0; i<inxlim; i++)
        {
        chkpt = pyptr->point;
        p1u = chkpt[U];
        p1v = chkpt[V];
        chkpt = pyptr->next->point;
        p2u = chkpt[U];
        p2v = chkpt[V];
        d1 = p1u - p2u;
        d2 = p1v - p2v;
        if (d1*d1 + d2*d2 <= uvlentolsq)
          {
          epptr = (struct EMSsfintedpar *) pyptr->info;
          if (!IF_EQ_OBJID (epptr->edgeid, epptr->next->edgeid))
            {
            pyptr->props |= EMS_PYPT_ENDMARKER;
            pyptr->next->props |= EMS_PYPT_ENDMARKER;
            }
          }
        pyptr = pyptr->next;
        }
      }
    }

  /*
   * If the special processing for overlap is on and boundary is being treated
   * as area, search for any overlap-points that may exist internal to the 
   * area sections just computed. Break up the area section into two at this
   * point. The way such overlap points can be detected is to invoke this 
   * method again with the option to treat boundary as hole. Check to see
   * if any new point (wrt to the previous boundary set) has been generated
   * within an area section, if so an internal overlap-point has been found.
   */

  if (options & EMS_INTER_PROCOVERLAP &&
      options & EMS_INTER_BDRYISAREA &&
      bdrys)
    {
    ovtol_basis.tol = MIDDLE_FACTOR * tol_basis->tol;
    ovtol_basis.is_valid = TRUE;

    loc_options = options & ~(EMS_INTER_BDRYISAREA | EMS_INTER_PROCOVERLAP);
    stat_OM = om$send (msg = message EMSloopset.EMlsparttrim (&msg_loc, ingeom,
               &ovtol_basis, loc_options, &num_ovbdrys,
               &ovpolyinters, bdry_parms ? &ovmyinters : NULL),
               targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_LoopsetError, 
     ret_end);

    /*
     * Trivially check for equivalence between the pyptr and the
     * ovpyptr lists. If found so, then no need to indulge in the
     * subsequent rigmarole (the rigmarole is probably fraught with
     * logic errors and needs to be re-written).
     */

    pyptr = *bdrys;
    epptr = bdry_parms ? *bdry_parms : NULL;
    ovpyptr = ovpolyinters;
    ovepptr = ovmyinters;
    possible_duplicate = FALSE;
    equivalent_lists = TRUE;

    if (*num_bdrys != num_ovbdrys)
      equivalent_lists = FALSE;
    else
      {
      for (i=0; i<num_ovbdrys; i++)
        {
        for (j=START; j<=STOP; j++)
          {
          /* 
           * Check geometric equivalence
           */

          startpar.param = pyptr->param;
          startpar.span_inx = pyptr->span_inx;
          stoppar.param = pyptr->next->param;
          stoppar.span_inx = pyptr->next->span_inx;

          tpyptr = j == START ? ovpyptr : ovpyptr->next;
          chkpar.param = tpyptr->param;
          chkpar.span_inx = tpyptr->span_inx;

          on_interval = EMpar_on_edintvl (&msg_loc, NULL_OBJID, &startpar,
                         pyptr->point, &stoppar, pyptr->next->point, 
                         &chkpar, tpyptr->point, &ovtol_basis,
                         &on_interval, &in_middle, &on_start);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

          if (!on_interval || in_middle || (j == START ? !on_start : on_start))
            {
            equivalent_lists = FALSE;
            break;
            }

          /*
           * Check topological equivalence
           */

          tepptr = j == START ? epptr : epptr->next;
          ovloc = tepptr->intloc;
          ovinced = tepptr->edgeid;

          tepptr = j == START ? ovepptr : ovepptr->next;
          pyloc = tepptr->intloc;
          pyinced = tepptr->edgeid;
          
          if (!EMis_sametopology (pyloc, pyinced, ovloc, ovinced, 
                OM_Gw_current_OS, NULL))
            {
            equivalent_lists = FALSE;
            break;
            }
          }

        if (!equivalent_lists)
          break;
        pyptr = pyptr->next->next;
        ovpyptr = ovpyptr->next->next;
        if (bdry_parms)
          {
          epptr = epptr->next->next;
          ovepptr = ovepptr->next->next;
          }
        }
      }

    /*
     * Indulge in the following rigmarole if the two lists are found
     * to be non-equivalent.
     */
 
    if (!equivalent_lists)
      {    
      pyptr = *bdrys;
      epptr = bdry_parms ? *bdry_parms : NULL;
      ovpyptr = ovpolyinters;
      ovepptr = ovmyinters;
      possible_duplicate = FALSE;
  
      while (pyptr && ovpyptr)
        {
        startpar.param = pyptr->param;
        startpar.span_inx = pyptr->span_inx;
        stoppar.param = pyptr->next->param;
        stoppar.span_inx = pyptr->next->span_inx;

        while (ovpyptr)
          {
          chkpar.param = ovpyptr->param;
          chkpar.span_inx = ovpyptr->span_inx;

          on_interval = EMpar_on_edintvl (&msg_loc, NULL_OBJID, &startpar,
                         pyptr->point, &stoppar, pyptr->next->point, &chkpar,
                         ovpyptr->point, &ovtol_basis,
                         &on_interval, &in_middle, &on_start);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  
          addtolist = FALSE;
          if (on_interval)
            {
            if (in_middle)
              addtolist = TRUE;
            else if (bdry_parms)
              {
              tpyptr = on_start ? pyptr : pyptr->next;
              pyinced = ((struct EMSsfintedpar *) tpyptr->info)->edgeid;
              ovinced = ((struct EMSsfintedpar *) ovpyptr->info)->edgeid;
              if (!IF_EQ_OBJID (pyinced, ovinced))
                {
                possible_duplicate = TRUE;
                addtolist = TRUE;
                }
              }
            }

          if (addtolist) 
            {
            for (i=0; i<2; i++)
              {
              addpy[i] = EMpypoint_malloc (&msg_loc, 1);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_NoDynamicMemory,
               ret_end);
              props = addpy[i]->props;
              *(addpy[i]) = *ovpyptr;
              addpy[i]->props = props | 
                                EMS_PYPT_AREAAREA | 
                                (ovpyptr->props & EMS_PYPT_POSINFOMASK);

              addpy[i]->props &= ~EMS_PYPT_EMPTY;
  
              if (ovepptr)
                {
                addep[i] = EMsfintedpar_malloc (&msg_loc, 1);
                EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_NoDynamicMemory,
                 ret_end);
                *(addep[i]) = *ovepptr;
                addpy[i]->info = (char *)addep[i];
                }
              }

            tpyptr = pyptr->next;
            pyptr->next = addpy[FIRST];
            addpy[FIRST]->next = addpy[SECOND];
            addpy[SECOND]->next = tpyptr;
  
            if (ovepptr)
              {
              tepptr = epptr->next;
              epptr->next = addep[FIRST];
              addep[FIRST]->next = addep[SECOND];
              addep[SECOND]->next = tepptr;
              }

            ovpyptr = ovpyptr->next;
            if (ovepptr)
              ovepptr = ovepptr->next;
            (*num_bdrys)++;
            break;
            }
          else if (chkpar.param + chkpar.span_inx >
                   stoppar.param + stoppar.span_inx)
            break;
          else
            {
            ovpyptr = ovpyptr->next;
            if (ovepptr)
              ovepptr = ovepptr->next;
            }
          }
  
        pyptr = pyptr->next->next;
        if (epptr)
          epptr = epptr->next->next;
        }
      }

    /*
     * It is possible that unnecessary degenerate boundaries have been
     * introduced. These are guaged by the fact that such boundaries
     * will be on the same topological point, ie, same edge and same
     * point.
     */

    if (possible_duplicate)
      {
      pyptr = *bdrys;
      epptr = *bdry_parms;
      prev_pyptr = NULL;
      prev_epptr = NULL;
      while (pyptr && epptr)
        {
        if (IF_EQ_OBJID (epptr->edgeid, epptr->next->edgeid))
          {
          EMwpartol (&msg_loc, ingeom, pyptr->span_inx, uvlentol, &wlentol);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  
          if (fabs ((pyptr->param + pyptr->span_inx) - 
                    (pyptr->next->param + pyptr->next->span_inx)) < wlentol)
            {
            tpyptr = pyptr->next->next;
            tepptr = epptr->next->next;

            if (prev_pyptr)
              prev_pyptr->next = tpyptr;
            else
              *bdrys = tpyptr;
            if (prev_epptr)
              prev_epptr->next = tepptr;
            else
              *bdry_parms = tepptr;
  
            EMpypoint_free (pyptr, 2);
            EMsfintedpar_free (epptr, 2);

            pyptr = tpyptr;
            epptr = tepptr;
            (*num_bdrys)--;
            continue;
            }
          }
        prev_pyptr = pyptr->next;
        prev_epptr = epptr->next;
        pyptr = prev_pyptr->next;
        epptr = prev_epptr->next;
        }
      }
    }

ret_end:
  if (! bdrys)
    EMpypoint_free (polyinters, MAXINT);

  EMpypoint_free (ovpolyinters, MAXINT);
  EMsfintedpar_free (ovmyinters, MAXINT);

  /*
   * On failure without the option to do go through the doublechecking
   * algorithm, call this method recursively, setting the doublechecking
   * option.
   */

  if (EMSerror (*msg) && !doublecheck)
    stat_OM = om$send (msg = message EMSloopset.EMlsparttrim (msg, ingeom,
               tol_basis, options | EMS_INTER_MOREPRECISE, num_bdrys,
               bdrys, bdry_parms), targetid = my_id);
  
  if (_use_timers)
    stop_timer (T_EMLSPARTTRIM, FALSE, "");
 
  EMWRAPUP (*msg, stat_OM, "EMSloopset.EMlsparttrim");
  return (stat_OM);
}

end implementation EMSloopset;
