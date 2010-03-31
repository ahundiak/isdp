/*
  DESCRIPTION

    Used to generate any number of points on this edge that are internal
    (away from the endpoints). These points are centralized based on
    paramteric space (w-space) of the edge.
*/

class implementation EMSedge;

#include "EMS.h"
#include "OMmacros.h"

#define MAX_LOCAL_PTS   5

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMinternalpt (IGRlong *msg; IGRint numpts; struct EMSproj_info *prjpts;
                     IGRdouble *pts;
                     struct EMSpartedinfo *partinfo; 
                     struct EMSpartolbasis *partolbasis)
{
  IGRshort mattyp;
  IGRmatrix mat;
  IGRlong msg_loc, stat_OM;
  IGRdouble *locpts, ptsmem[MAX_LOCAL_PTS*3];
  struct EMSaltdataselect edgeom;
  struct IGRbsp_curve *cv;
  struct IGRpolyline *py;
  struct EMSdataselect geom;
  void EMidmatrix(), EM3dto2d();
  IGRlong EMinternalpt();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  edgeom.data.curve.poles = NULL;
  edgeom.data.curve.knots = NULL;
  edgeom.data.curve.weights = NULL;
  edgeom.data.poly.points = NULL;  
  edgeom.datatype = EMSdata_null;
  cv = &edgeom.data.curve;
  py = &edgeom.data.poly;
  locpts = NULL;

  stat_OM = om$send (msg = message EMSedge.EMgetgeom (&msg_loc, 0, MAXINT,
             FALSE, partinfo, &edgeom), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

  geom.datatype = edgeom.datatype;
  if (geom.datatype == EMSdata_poly2d)
    geom.data.poly = py;
  else
    geom.data.curve = cv;

  if (numpts > MAX_LOCAL_PTS)
    {
    locpts = (IGRdouble *) om$malloc (size = numpts * 3 * sizeof (IGRdouble));
    EMerr_hndlr (!locpts, *msg, EMS_E_NoDynamicMemory, ret_end);
    }
  else
    locpts = ptsmem;

  EMidmatrix (&msg_loc, &mattyp, mat);
  EMinternalpt (&msg_loc, &mattyp, mat, &geom, EMScvint_middle, numpts, 
   locpts);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  if (! (ME.EMSedge->ed_props & EMED_XYZ))
    EMbnduvpts (numpts, locpts);

  if (geom.datatype == EMSdata_curve3d)
    EM3dto2d (locpts, numpts);

  if (pts)
    OM_BLOCK_MOVE (locpts, pts, numpts * 2 * sizeof (IGRdouble));
  
  if (prjpts)
    {
    stat_OM = om$send (msg = message EMSedge.EMptproject (&msg_loc, locpts,
               numpts, prjpts, partinfo, partolbasis), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
    }
  
ret_end:
  if (locpts && numpts > MAX_LOCAL_PTS)
    om$dealloc (ptr = locpts);
  if (edgeom.datatype != EMSdata_null)
    {
    if (edgeom.datatype == EMSdata_poly2d && py->points)
      om$dealloc (ptr = py->points);
    else if (edgeom.datatype == EMSdata_curve3d)
      {
      if (cv->poles)
        om$dealloc (ptr = cv->poles);
      if (cv->knots)
        om$dealloc (ptr = cv->knots);
      if (cv->rational && cv->weights)
        om$dealloc (ptr = cv->weights);
      }
    }

  EMWRAPUP (*msg, stat_OM, "EMSedge.EMinternalpt");
  return (stat_OM);
}

end implementation EMSedge;
