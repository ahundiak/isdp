/*
   ABSTRACT:

     This file contains a collection of implementations that are trivial
*/

class implementation EMSpartedge;

#include "OMmacros.h"

method EMgeomattr (IGRlong *msg; IGRushort opts; IGRdouble uvtol;
                   IGRboolean *is_uvdegen, *is_xyzdegen;
                   IGRboolean *is_uvopen, *is_xyzopen)
{
  IGRushort ed_props;
  IGRint num_points;
  IGRlong msg_loc;
  IGRdouble *points, *weights;
  struct EMSpartedinfo mypartinfo;
  struct EMSaltdataselect geom;
  extern IGRboolean EFpts_degenerate();
  
  *msg = EMS_S_Success;

  geom.datatype = EMSdata_null;

  /* intialize the geometry pointers. The "EMgetgeom" method will assume 
   * exisiting memory if not set to NULL.
   */
  geom.data.poly.points=NULL; 
  geom.data.curve.poles=NULL; 
  geom.data.curve.weights=NULL; 
  geom.data.curve.knots=NULL; 

  ed_props = ME.EMSedge->ed_props;

  if (is_uvdegen)
    {
    mypartinfo.edprops = ed_props;
    OM_BLOCK_MOVE (ME.EMSpartedge->boundary, mypartinfo.edbdry, 2 * 
     sizeof (struct EMSedgebound));
    mypartinfo.edid = my_id;

    om$send (msg = message EMSedge.EMgetgeom (&msg_loc, 0, MAXINT, FALSE, 
     &mypartinfo, &geom), targetid = my_id);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

    if (geom.datatype == EMSdata_poly2d)
      {   
      num_points = geom.data.poly.num_points;
      points = geom.data.poly.points;
      weights = NULL;
      }
    else if (geom.datatype == EMSdata_curve3d)
      {
      num_points = geom.data.curve.num_poles;
      points = geom.data.curve.poles;
      weights = geom.data.curve.weights;
      }
    else
      {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidCase, ret_end);}

    *is_uvdegen = EFpts_degenerate (num_points, points, weights, 2, uvtol);
    }

  if (is_uvopen)
    *is_uvopen = ed_props & EMED_OPEN ? TRUE : FALSE;
  
  if (is_xyzdegen)
    *is_xyzdegen = ed_props & EMED_DEGENERATE ? TRUE : FALSE;

  if (is_xyzopen)
    *is_xyzopen = ed_props & EMED_XYZ_CLOSED ? FALSE : TRUE;
  
ret_end:
  if (geom.datatype == EMSdata_poly2d)
    om$dealloc (ptr = geom.data.poly.points);
  else if (geom.datatype == EMSdata_curve3d)
    {
    om$dealloc (ptr = geom.data.curve.poles); 
    om$dealloc (ptr = geom.data.curve.knots); 
    if (geom.data.curve.weights)
      om$dealloc (ptr = geom.data.curve.weights); 
    }

  return (OM_S_SUCCESS);
}

end implementation EMSpartedge;
