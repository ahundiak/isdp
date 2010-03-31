/*
   ABSTRACT:

     This file contains a collection of implementations that are trivial
*/

class implementation EMSlinedge;

method EMgeomattr (IGRlong *msg; IGRushort opts; IGRdouble uvtol;
                   IGRboolean *is_uvdegen, *is_xyzdegen;
                   IGRboolean *is_uvopen, *is_xyzopen)
{
  IGRushort ed_props;
  IGRint num_points;
  IGRdouble *points;
  extern IGRboolean EFpts_degenerate();
  
  *msg = EMS_S_Success;

  num_points = ME.EMSlinedge->num_points;
  points = ME.EMSlinedge->points;
  ed_props = ME.EMSedge->ed_props;

  if (is_uvdegen)
    *is_uvdegen = EFpts_degenerate (num_points, points, NULL, 2, uvtol);

  if (is_uvopen)
    *is_uvopen = ed_props & EMED_OPEN ? TRUE : FALSE;
  
  if (is_xyzdegen)
    *is_xyzdegen = ed_props & EMED_DEGENERATE ? TRUE : FALSE;

  if (is_xyzopen)
    *is_xyzopen = ed_props & EMED_XYZ_CLOSED ? FALSE : TRUE;
  
  return (OM_S_SUCCESS);
}

end implementation EMSlinedge;
