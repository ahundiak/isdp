/*
   ABSTRACT:

     This file contains a collection of implementations that are trivial
*/

class implementation EMSptedge;

method EMgeomattr (IGRlong *msg; IGRushort opts; IGRdouble uvtol;
                   IGRboolean *is_uvdegen, *is_xyzdegen;
                   IGRboolean *is_uvopen, *is_xyzopen)
{
  *msg = EMS_S_Success;

  if (is_uvdegen)
    *is_uvdegen = TRUE;

  if (is_uvopen)
    *is_uvopen = TRUE;
  
  if (is_xyzdegen)
    *is_xyzdegen = TRUE;

  if (is_xyzopen)
    *is_xyzopen = TRUE;
  
  return (OM_S_SUCCESS);
}

end implementation EMSptedge;
