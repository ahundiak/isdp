/*
  Abstract:

  This method computes the "area" intersection between a 2-dimensional 
  polyline and this edge bounding this area. The intersection computation
  is sensitive to the area that the edge is considered to be boundary of
  (area on the right-hand-side with a natural traversal). An intersection
  results if and only if the input line string has any part common with the 
  INTERIOR bounded by the edge.

  If the input polyline just "grazes" the edge, no intersection is output;
  if the polyline intersects the edge at one of it's vertex points, only one
  intersection is output; etc.

  At the endpoint of this object, ambiguity can arise as to the extent to which
  the interior fans out. For this purpose a "subsequent" point is obtained,
  from it's subsequent edge which now defines the interior at the endpoint.
  "inpoly" passing through the startpoint of this edge is ignored. Such 
  a "cutting" intersection (if it is indeed "cutting") will be picked
  (or would have been picked up) up when the previous edge receives(d) the
  trim-message.

  Theoretically, this is an n-squared algorithm, but practically it
  works out cheaper as there are two stages wherin non-intersections
  are trivially rejected.

  The output is a linked list of EMSpypoint  and EMintsfedge structures that
  stand for the intersections on the polyline. If output pointers (*polyinters
  and/or *myinters) are not NULL, this method assumes an existing linked-list
  and attaches it's output to the tail.

  NOTES
 
    See emsinterdef.h for options

  HISTORY

    SS  :  10/13/87  :  Modified the code to call a function to do the
                        real trimming
    SS  :  03/27/89  :  Passing the parametric length tolerance to the
			'get-adjacent-span' function in the 'geninfo'
			field.
*/

class implementation EMSlinedge;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsinterdef.h"
#include "emsmacros.h"
#include "emsdef.h"

#define X 0
#define Y 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMedpytrimint (IGRlong *msg; struct IGRpolyline *inpoly;
                      IGRdouble *inpoly_range; 
                      struct EMSpartolbasis *partol_basis;
                      struct EMSpartedinfo *partinfo;
                      IGRushort options;
                      IGRint *num_inters;
                      struct EMSsfintedpar **myinters; 
                      struct EMSpypoint  **polyinters)
{
  IGRboolean stat_func;
  IGRushort wprops;
  IGRint stat_OM;
  IGRint num_cpts, num_wpts;
  IGRlong msg_loc;
  IGRdouble chttol, lentol, uvlentol;
  IGRdouble *wpts, *cpts;
  GRobjid sender_edge, dumid;
  struct IGRpolyline actpoly;
  struct EMSgetadjgeom adjgeom_info;
  IGRint EMadjedpy();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  actpoly.points = NULL;

  if (!partol_basis->is_valid)
    {
    stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info
               (&msg_loc, &dumid, partol_basis), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMis_error (msg_loc), *msg, EMS_E_Fail, ret_end);
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
   * Obtain the active points of this edge. The EMgetpygeom method
   * always returns geometry in keeping with the edges direction.
   * For consistency with the situation when this entire edge is used,
   * it becomes necessary to obtain the part-geometry explicitly reversed,
   * if the edge-direction is reversed.
   */

  if (partinfo)
    {
    actpoly.points = NULL;
    wprops = partinfo->edprops;
    stat_OM = om$send (msg = message EMSedge.EMgetpygeom (&msg_loc,
               0, MAXINT, wprops & EMED_REVERSED, partinfo,
               &actpoly, partol_basis, NULL), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMis_error (msg_loc), *msg, msg_loc, ret_end);
    sender_edge = partinfo->edid;
    }
  else
    {
    actpoly.num_points = ME.EMSlinedge->num_points;
    actpoly.points = ME.EMSlinedge->points;
    wprops = ME.EMSedge->ed_props;
    sender_edge = my_id; 
    }

  num_cpts = inpoly->num_points;
  cpts = (IGRdouble *) inpoly->points;
  num_wpts = actpoly.num_points;
  wpts = (IGRdouble *) actpoly.points;

  /*
   * Call the trimming function that will do the interesection
   * computations. If no output is requested and an intersection
   * has been found, return the code that will stop further search.
   * Set the 'geninfo' to point to the parametric length tolerance.
   */

  adjgeom_info.geninfo = (IGRchar *) &uvlentol;
  stat_func = EM2dpycutint (&msg_loc, num_wpts, wpts, wprops, NULL, num_cpts,
               cpts, inpoly_range, options, uvlentol, EMadjedpy, 
               &adjgeom_info, sender_edge, partinfo, num_inters, myinters,
               polyinters);
  EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
  if (!polyinters && !myinters && (msg_loc == EMS_I_Intersect))
    {
    *num_inters = TRUE;
    stat_OM = OM_I_STOP_SENDING;
    }

ret_end:
  /*
   * Deallocate memory malloced during this method and
   * which will not be output.
   */

  if (partinfo && actpoly.points)
     om$dealloc (ptr = actpoly.points);
  EMWRAPUP (*msg, stat_OM, "EMSlinedge.EMedpytrimint");
  return (stat_OM);
}

end implementation EMSlinedge;

