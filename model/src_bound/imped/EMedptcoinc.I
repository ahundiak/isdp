/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This message is used to detect if this edge has any other edge lying
    next to it (within the given tolerance) at a given point. The coincident
    edge, if one exists, is returned. The coincident edge is searched for
    within the loopset. In addition, the caller can optionally
    obtain information about whether the region slightly away from the given
    point is within area or hole. The algorithm followed takes two points, at
    distances 5 times the param-basis tolerance away from the given point in
    the direction perpendicular to the edge (in either directions) and
    performs a "point-location" query. The result from the query is directly
    returned as EMS_L_... (see EMSbnddef.h). 

  HISTORY

    SS  :  11/21/88  :  Creation
*/

class implementation EMSedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emssfint.h"
#include "emsinterdef.h"
#include "bserr.h"
#include "bsparameters.h"

#define NEIGHBOR_FACTOR  5

#define U 0
#define V 1

#define FIRST  0
#define SECOND 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSloopset_class_id;

from EMSloopset import EMlspytrimint, EMpt_location;

method EMptcoinc (IGRlong *msg; IGRdouble *at_point; 
                  GRobjid *coincedge; IGRshort *neighbor_loc1, *neighbor_loc2;
                  struct EMSpartedinfo *partinfo; 
                  struct EMSpartolbasis *partolb)
{
  IGRshort *outloc;
  IGRint inx, num_inters;
  IGRlong msg_loc, send_rc, stat_OM;
  IGRdouble norm[2], points[2][2], lentol;
  GRobjid ref_edge;
  struct EMSproj_info prjpts;
  struct IGRpolyline poly;
  struct EMSsfintedpar *myinters, *sfinted;
  struct EMSptloc_info ptloc_info;

  *msg = EMS_I_NotFound;
  stat_OM = OM_S_SUCCESS;

  num_inters = 0;
  myinters = NULL;

  /*
   * Obtain the length tolerance
   */

  if (! partolb->is_valid)
    {
    stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
               NULL, partolb), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
    partolb->is_valid = TRUE;
    }
  EFextract_par (BSTOLLENVEC, partolb->tol, &lentol, &msg_loc);

  /*
   * Obtain the unit tangent to this edge at the given point. This
   * tangent is in the direction of the edge.
   */

  stat_OM = om$send (msg = message EMSedge.EMptproject (&msg_loc, at_point,
             1, &prjpts, partinfo, partolb), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

  /*
   * The unit outward normal to this edge, is obtained by crossing the normal
   * to the uv-plane [0,0,1] with the tangent.
   */

  norm[U] = -prjpts.tangent[V];
  norm[V] = prjpts.tangent[U];

  /*
   * A polyline segment centred at the given point is made up using this normal
   * direction. The length of this segment is equal to the given tolerance
   * in both directions.
   */
 
  points[FIRST][U] = at_point[U] - lentol * norm[U];
  points[FIRST][V] = at_point[V] - lentol * norm[V];
  points[SECOND][U] = at_point[U] + lentol * norm[U];
  points[SECOND][V] = at_point[V] + lentol * norm[V];
  poly.num_points = 2;
  poly.points = (IGRdouble *)points;
  ref_edge = partinfo ? partinfo->edid : my_id;

  /*
   * If 'coincedge' has been requested, process to determine atleast one
   * edge that may be coincident with the one located by point-projection
   * of the input point.
   */

  if (coincedge)
    {
    /*
     * Send this polyline to be trimmed against the loopset owning the
     * reference-edge.
     */

    stat_OM = om$send (msg = message EMSboundary.EMtree_traverse (&send_rc,
               message EMSloopset.EMlspytrimint (&msg_loc, &poly, NULL,
               partolb, EMS_INTER_CUTTING | EMS_INTER_STARTPT |
               EMS_INTER_STOPPT, &num_inters, &myinters, NULL), MAXINT, 
               1, &OPP_EMSloopset_class_id, EMStreetrav_up, NULL, NULL, NULL),
               targetid = ref_edge);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (send_rc & msg_loc), *msg, EMS_E_LoopsetError,
     ret_end);

    /*
     * If some intersections have been found, and atleast one of them
     * is not with this edge, then an edge adjacent has been found.
     * Pick this edge-id from the "myinters" list and return it.
     */

    sfinted = myinters;
    for (inx=0; inx<num_inters; inx++)
      {
      if (! IF_EQ_OBJID (sfinted->edgeid, ref_edge))
        {
        *coincedge = sfinted->edgeid;
        *msg = EMS_I_Found;
        break;
        }
      sfinted = sfinted->next;
      }
    }

  /*
   * If the location of neighboring points has been requested, compute
   * the neighboring points and perform the point location query.
   */

  if (neighbor_loc1 || neighbor_loc2)
    {
    for (inx=FIRST; inx<=SECOND; inx++)
      {
      if (inx == FIRST && neighbor_loc1)
        {
        outloc = neighbor_loc1;
        points[inx][U] = at_point[U] - NEIGHBOR_FACTOR * lentol * norm[U];
        points[inx][V] = at_point[V] - NEIGHBOR_FACTOR * lentol * norm[V];
        }
      else if (inx == SECOND && neighbor_loc2)
        {
        outloc = neighbor_loc2;
        points[inx][U] = at_point[U] + NEIGHBOR_FACTOR * lentol * norm[U];
        points[inx][V] = at_point[V] + NEIGHBOR_FACTOR * lentol * norm[V];
        }
      else
        continue;

      ptloc_info.options = EMS_PTLOC_BOXCHECK | EMS_PTLOC_ACTLOOP |
                            EMS_PTLOC_LS_INFINITE;
      stat_OM = om$send (msg = message EMSboundary.EMtree_traverse (&send_rc,
                 message EMSloopset.EMpt_location (&msg_loc, points[inx],
                 &ptloc_info, partolb), MAXINT, 1, &OPP_EMSloopset_class_id,
                 EMStreetrav_up, NULL, NULL, NULL), targetid = ref_edge);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (send_rc & msg_loc), *msg, EMS_E_LoopsetError,
       ret_end);

      *outloc = ptloc_info.location;
      }
    }

ret_end:
  if (myinters)
    EMsfintedpar_free (myinters, MAXINT);

  EMWRAPUP (*msg, stat_OM, "EMSedge.EMptcoinc");
  return (stat_OM);
}

end implementation EMSedge;
