/* ###################   APOGEE COMPILED   ################## */
/*
   ABSTRACT:

    The purpose of this method is to provide flexible access to the
    edges "active" geometry in a polyline format. If the edge is internally
    represented in the B-spline curve format, it is stroked out with
    appropriate chord-height tolerance and converted to a polyline
    geometry.

    Random access to the spans of the edge polyline geometry is possible. The 
    geometry can be obtained either reversed or as is.
    The minimum of i) the number of spans requested and ii) the number of 
    spans present starting from "from_spaninx", is returned. 

    If the caller nulls out the "points" field in the output IGRpolyline 
    structure, this method mallocs the memory. Else it assumes sufficient
    memory is present. The pointer "pygeom" should always point to a valid
    IGRpolyline structure on input.
*/

class implementation EMSlinedge;

#include "EMS.h"
#include "emssfint.h"
#include "OMmacros.h"
#include "emsinter.h"

#define U 0
#define V 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMgetpygeom (IGRlong *msg; IGRint from_spaninx; IGRint num_spans;
                    IGRboolean reverse; struct EMSpartedinfo *partinfo;
                    struct IGRpolyline *pygeom; struct EMSpartolbasis
                    *partolbasis; IGRushort options)
{
  IGRint stat_OM, i, j, num_points, num_xferpts;
  IGRint bdry_inx, ptinx;
  IGRlong msg_loc;
  IGRdouble *points, param;
  struct EMSpypoint  pybdry[2];
  struct IGRpolyline inpoly, outpoly;
  struct EMSedgebound *edbdry;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  outpoly.num_points = 0;
  outpoly.points = NULL;

  /*
   * If a boundary is to be imposed, that restricts
   * the active portion of this linestring, extract 
   * that linestring.
   */

  if (partinfo)
    {
    edbdry = partinfo->edbdry;
    pybdry[0].next = &pybdry[1];
    num_points = ME.EMSlinedge->num_points;
    points = ME.EMSlinedge->points;
    for (i=0, j=1; i<2; i++, j--)
      {
      if (edbdry[i].span_inx > num_points-2)
        edbdry[1].span_inx = num_points-2;

      bdry_inx = partinfo->edprops & EMED_REVERSED ? j : i;
      pybdry[i].span_inx = edbdry[bdry_inx].span_inx;
      pybdry[i].param = param = edbdry[bdry_inx].param;
      ptinx = edbdry[bdry_inx].span_inx*2;
      if (param == 0.0)
        OM_BLOCK_MOVE (&points[ptinx], pybdry[i].point, 2 *
         sizeof (IGRdouble));
      else if (param == 1.0)
        OM_BLOCK_MOVE (&points[ptinx+2], pybdry[i].point, 2 *
         sizeof (IGRdouble));
      else
        {
        pybdry[i].point[U] = points[ptinx] + param * 
                              (points[ptinx+2] - points[ptinx]);
        pybdry[i].point[V] = points[ptinx+1] + param * 
                              (points[ptinx+3] - points[ptinx+1]);
        }
      }
    inpoly.num_points = ME.EMSlinedge->num_points;
    inpoly.points = points;

    EMgetactpy (&msg_loc, &inpoly, 2, pybdry, &outpoly);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    reverse = partinfo->edprops & EMED_REVERSED ? 
               (reverse ? FALSE : TRUE) :
               (reverse ? TRUE : FALSE);
    num_points = outpoly.num_points;
    points = outpoly.points;
    }
  else
    {
    reverse = ME.EMSedge->ed_props & EMED_REVERSED ? 
               (reverse ? FALSE : TRUE) :
               (reverse ? TRUE : FALSE);
    num_points = ME.EMSlinedge->num_points;
    points = ME.EMSlinedge->points;
    }

  /*
   * If the starting span-index from the geometry
   * extraction is larger than the number of spans
   * an error message is returned.
   */

  EMerr_hndlr (from_spaninx > num_points-2, *msg, EMS_I_OutOfBounds, ret_end);

  /*
   * Determine the index of the point in the active
   * linestring from which the extraction begins. Also
   * obtain the number of points to extract.
   */

  if (from_spaninx +  num_spans > num_points-1)
    num_xferpts = num_points - from_spaninx;
  else
    num_xferpts = num_spans + 1;

  if (reverse)
    ptinx = num_points - (from_spaninx + num_xferpts - 1) - 1;
  else
    ptinx = from_spaninx;

  /*
   * Allocate output memory if no memory has been allocated
   * by the user.
   */

  if (!pygeom->points)
    pygeom->points = (IGRdouble *) om$malloc (size =
                      num_xferpts * 2 * sizeof (IGRdouble));
  EMerr_hndlr (!pygeom->points, *msg, EMS_E_NoDynamicMemory, ret_end);

  /*
   * Move the data into the output
   * buffer.
   */

  pygeom->num_points = num_xferpts;
  OM_BLOCK_MOVE (&points[ptinx*2], pygeom->points, num_xferpts * 2 * 
   sizeof (IGRdouble));

  if (reverse) 
    {
    EMrevpyline (&msg_loc, pygeom, 2, NULL);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  
ret_end:
  if (outpoly.points)
    om$dealloc (ptr = outpoly.points);
  EMWRAPUP (*msg, stat_OM, "EMSlinedge.EMgetpygeom");
  return (stat_OM);
}

end implementation EMSlinedge;
