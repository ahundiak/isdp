/*
   ABSTRACT:

     This file contains a collection of implementations that are trivial
*/

class implementation EMSnatedge;

method EMgeomattr (IGRlong *msg; IGRushort opts; IGRdouble uvtol;
                   IGRboolean *is_uvdegen, *is_xyzdegen;
                   IGRboolean *is_uvopen, *is_xyzopen)
{
  IGRushort ed_props;
  
  *msg = EMS_S_Success;

  ed_props = ME.EMSedge->ed_props;

  if (is_uvdegen)
    *is_uvdegen = FALSE;

  if (is_uvopen)
    *is_uvopen = TRUE;
  
  if (is_xyzdegen)
    *is_xyzdegen = ed_props & EMED_DEGENERATE ? TRUE : FALSE;

  if (is_xyzopen)
    *is_xyzopen = ed_props & EMED_XYZ_CLOSED ? FALSE : TRUE;
  
  return (OM_S_SUCCESS);
}

end implementation EMSnatedge;
