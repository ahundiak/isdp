/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method finds all the parts contained in this boundary element
    (in this case, the edge) which are coincident with the given
    reference edge. The "parts" are always edges or pieces thereof. Each
    coincident part is represented by the two bounding points of the part.
    These points are computed for the reference-edge and also for the
    coincident edge.

  BUGS

    This method does not sense a coincident region whose end-points
    are not in the set of points formed by the end-points of the reference 
    edge and the end-points of this edge. There is a lot of room for 
    optimization here. Perhaps even overrides at various types of edges
    may speed things up. Such efficiency has not been warranted yet
    and therefore the method has been written for compactness.

  HISTORY

    SS  :  12/29/88  :  Creation
    SM  :  07-Aug-89 :  Argument change in EMgetcv_ovlap() function. Pass
			NULL for options (last argument).
    Sudha  06/04/93     modified to include BSprototype header files
*/

class implementation EMSedge;

#include "EMS.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "bscveval.h"

/*
 * Number of internal sample points to be used to check the validity
 * of a possible overlap detected between two edges.
 */

#define NUM_SAMPLE_POINTS  3

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMcoincedges (IGRlong *msg; GRobjid ref_edge;
                     struct EMSpartedinfo *ref_partinfo;
                     IGRdouble *ref_range; struct IGRbsp_curve *ref_geom;
                     struct EMSpartolbasis *partolbasis;
                     IGRint *num_coinc;
                     struct EMSpypoint **pts_on_ref;
                     struct EMSsfintedpar **pts_on_coinc)
{
  IGRushort props;
  IGRint i, j, num_ovlap, ref_hitinfo[4], this_edge_hitinfo[4];
  IGRint num_hits, num_misses;
  IGRlong stat_OM, msg_loc;
  IGRdouble ref_range_loc[4], this_edge_range[4], uvlentol;
  IGRdouble ref_ovlap[4], this_edge_ovlap[4];
  IGRdouble uvpoint[3];
  struct IGRbsp_curve cv_loc, this_edge_geom;
  struct EMSproj_info proj_info;
  enum EMScvinttype intloc;
  extern IGRint EMgetcv_ovlap(), EMvalcv_ovlap();
  extern struct EMSpypoint *EMmkpyptlist();
  extern struct EMSsfintedpar *EMmkeparlist();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  cv_loc.poles = NULL;
  cv_loc.knots = NULL;
  cv_loc.weights = NULL;
  this_edge_geom.poles = NULL;
  this_edge_geom.knots = NULL;
  this_edge_geom.weights = NULL;
  
  /*
   * If this edge is the same as the reference edge being passed in
   * skip the processing.
   */

  if (IF_EQ_OBJID (my_id, ref_edge))
    goto ret_end;

  /*
   * Obtain the parametric-tolerance and the reference edge range (incremented)
   * if they have not been supplied.
   */

  if (!partolbasis->is_valid)
    {
    stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
               NULL, partolbasis), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);
    partolbasis->is_valid = TRUE;
    }
  EFextract_par (BSTOLLENVEC, partolbasis->tol, &uvlentol, &msg_loc);

  if (!ref_range)
    {
    stat_OM = om$send (msg = message EMSedge.EMgetrange (&msg_loc, 
               ref_range_loc, ref_partinfo), targetid = ref_edge);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
    ref_range = ref_range_loc;

    EM2dbxinc (ref_range, uvlentol);
    }

  /*
   * Obtain the range of this edge. Do not increment this edge's range;
   * Otherwise the tolerance will work out to twice the required amount.
   */

  stat_OM = om$send (msg = message EMSedge.EMgetrange (&msg_loc, 
             this_edge_range, NULL), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
 
  /*
   * Check if the given reference edge can possibly have coincidence with this
   * edge by a range-box intersection check. If the ranges do not intersect,
   * no more processing for this edge is necessary.
   */

  if (!EM2dbxbxint (ref_range, this_edge_range))
    goto ret_end;

  /*
   * Obtain the geometries of the two edges.
   */

  if (!ref_geom)
    {
    stat_OM = om$send (msg = message EMSedge.EMgetbcgeom (&msg_loc, 0, MAXINT,
               FALSE, ref_partinfo, &cv_loc, NULL, NULL), targetid = ref_edge);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
    ref_geom = &cv_loc;
    }

  stat_OM = om$send (msg = message EMSedge.EMgetbcgeom (&msg_loc, 0, MAXINT,
             FALSE, NULL, &this_edge_geom, NULL, NULL), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

  /*
   * Invoke the functions to check for coincidence between these
   * geometries. If there is a possible overlap, then proceed further
   * else exit.
   */

  stat_OM = EMgetcv_ovlap (&msg_loc, ref_geom, &this_edge_geom, &num_ovlap,
             ref_ovlap, this_edge_ovlap, uvlentol, 
             ref_hitinfo, this_edge_hitinfo, NULL);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  if (msg_loc != EMS_S_Success)
    goto ret_end;

  /*
   * Possible overlap(s) exists. Validate these overlap(s) by picking 
   * NUM_SAMPLE_POINTS for internal coincidence checks. Proceed further
   * only if all of these succeed.
   */

  for (i=0; i<num_ovlap*2; i+=2)
    {
    stat_OM = EMvalcv_ovlap (&msg_loc, ref_geom, &this_edge_geom,
               &ref_ovlap[i], &this_edge_ovlap[i], NUM_SAMPLE_POINTS+2,
               &num_hits, &num_misses, uvlentol, NULL, NULL, NULL);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    
    if (msg_loc != EMS_S_Success)
      break;
    }
  if (msg_loc != EMS_S_Success)
    goto ret_end;

  /*
   * A valid coincidence now is known to exist between the two edges.
   * Format the output, and exit.
   */

  for (i=0; i<num_ovlap*2; i+=2)
    {
    for (j=i; j<i+2; j++)
      {
      if (pts_on_ref)
        {
        BScveval (ref_geom, ref_ovlap[j], 0, (IGRpoint *)uvpoint, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        stat_OM = om$send (msg = message EMSedge.EMptproject (&msg_loc,
                   uvpoint, 1, &proj_info, ref_partinfo, partolbasis), 
                   targetid = ref_edge);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

        props = EMS_PYPT_RELUNKNOWN;
        if (ref_hitinfo[j] == EMS_O_begin)
          props |= EMS_PYPT_ATSTART | EMS_PYPT_ATEND;
        else if (ref_hitinfo[j] == EMS_O_end)
          props |= EMS_PYPT_ATSTOP | EMS_PYPT_ATEND;
        else
          props |= EMS_PYPT_ATMIDDLE;
        
        EMmkpyptlist (&msg_loc, pts_on_ref, proj_info.param.span_inx,
         proj_info.param.param, uvpoint, props, NULL, 2, FALSE);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }

      if (pts_on_coinc)
        {
        BScveval (&this_edge_geom, this_edge_ovlap[j], 0, (IGRpoint *)uvpoint, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        stat_OM = om$send (msg = message EMSedge.EMptproject (&msg_loc,
                   uvpoint, 1, &proj_info, ref_partinfo, partolbasis), 
                   targetid = my_id);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

        if (this_edge_hitinfo[j] == EMS_O_begin)
          intloc = EMScvint_lfend;
        else if (this_edge_hitinfo[j] == EMS_O_end)
          intloc = EMScvint_rtend;
        else
          intloc = EMScvint_middle;
        
        EMmkeparlist (&msg_loc, pts_on_coinc, intloc, my_id, 
         proj_info.param.span_inx, proj_info.param.param, uvpoint, NULL,
         FALSE);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      }
    }
  (*num_coinc) += num_ovlap;

ret_end:
  if (cv_loc.poles)
    om$dealloc (ptr = cv_loc.poles);
  if (cv_loc.knots)
    om$dealloc (ptr = cv_loc.knots);
  if (cv_loc.weights)
    om$dealloc (ptr = cv_loc.weights);

  if (this_edge_geom.poles)
    om$dealloc (ptr = this_edge_geom.poles);
  if (this_edge_geom.knots)
    om$dealloc (ptr = this_edge_geom.knots);
  if (this_edge_geom.weights)
    om$dealloc (ptr = this_edge_geom.weights);

  EMWRAPUP (*msg, stat_OM, "EMSedge.EMcoincedges");
  return (stat_OM);
}

end implementation EMSedge;



