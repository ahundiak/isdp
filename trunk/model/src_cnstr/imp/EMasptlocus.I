/*
  DESCRIPTION

    This method return the locus of this dimensional constraint
    back to the caller. In this case, it happens to be a point in the
    world coordinate system.

  HISTORY

    SS  :  06/22/91  :  Creation
*/

class implementation EMSasptcnstr;

#include "OMmacros.h"
#include "parametric.h"

#define X 0
#define Y 1
#define Z 2

#define PARENT_PT  0
#define CHILD_PT   1

method EMgetgeomlocus (IGRlong *msg; IGRushort opts;
                       IGRshort *mattyp; IGRmatrix mat;
                       struct EMSgeomdata *geomlocus)
{
  IGRlong msg_loc, stat_OM, stat_func;
  struct GRmd_env md_env;
  struct ret_struct ret_struct;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain my point definition.
   */
 
  if ((md_env.md_env.matrix_type = *mattyp) != MAIDMX)
    OM_BLOCK_MOVE (mat, md_env.md_env.matrix, sizeof (IGRmatrix));

  stat_func = ex$get_modid (mod_osnum = OM_Gw_current_OS, 
               mod_id = &md_env.md_id.objid);
  EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
  md_env.md_id.osnum = OM_Gw_current_OS;

  stat_OM = om$send (msg = message NDnode.NDgive_structure (&msg_loc,
             &ret_struct, &md_env), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (!(ret_struct.type & point_generic), *msg, EMS_E_InvalidCase,
   ret_end);

  OM_BLOCK_MOVE (ret_struct.var.point_st.pt, geomlocus->point,
   sizeof (IGRpoint));
  geomlocus->geomtype = GEOMDATA_POINT;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMasptlocus.I");
  return (stat_OM);
}

end implementation EMSasptcnstr;

