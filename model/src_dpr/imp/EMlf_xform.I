/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#include "EMS.h"
#include "msdef.h"

method GRxform(IGRlong *msg; struct GRmd_env *obj_mdenv;
               IGRshort *matrix_type; IGRmatrix matrix;
               GRobjid *newobjid)
/*
Description
    This method takes care of transforming the inactive surfaces that this
    state ownes.  This must be done since an undo after a transform would 
    put these surfaces back in leaving holes in the solid.

Return Values
    - MSSUCC if successful
    - GRIZRNGCHG (info) if 2-d object transforms to other than a constant 
                        elevation and is adjusted
    - GRSNOINVTRAN (severe) if matrix is env_info is not invertible
    - GRSDGNEXCEED (severe) if design space limits are exceeded
    - MSFAIL (severe) if failure

BUGS
     If the objid of any of the taken out surfaces change and this
     id is stored in any other state tree object's save state info,
     it is not updated.
     
History
         RC  05/27/88   Creation date
*/
{
  IGRlong                     OM_stat; 
  IGRint                      i, j;
  union EMSssi_table          *ssi;
  struct EMSlftssi_table   *my_info;
  GRobjid                     *sf_out;
  
  *msg = MSSUCC;
  OM_stat = OM_S_SUCCESS;

  ssi = NULL;
  my_info = NULL;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(msg, &ssi),
                    targetid = my_id);
  EMerr_hndlr (!(1 & OM_stat & *msg), *msg, EMS_E_Fail, wrapup);

  my_info = &ssi->lft_info;
  sf_out = my_info->surface_out_ids;
  
  for(i = 0; i < my_info->num_composites; i++)
  {
    for(j = 0; j < my_info->num_surfaces_out[i]; j++, sf_out++)
    {
      OM_stat = om$send(msg = OPPmargs, targetid = *sf_out);
      EMerr_hndlr (!(1 & OM_stat & *msg), *msg,EMS_E_SurfaceError,wrapup);
    }
  }

  /*
   * Invoke the parents method
   */

  OM_stat = om$send(mode = OM_e_wrt_message, 
                    msg = message EMSsfregmod.GRxform(msg, obj_mdenv,
                          matrix_type, matrix, newobjid),
                    targetid = my_id);
  EMerr_hndlr (!(1 & OM_stat & *msg), *msg, EMS_E_Fail, wrapup);
  
 wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*msg, OM_stat, "In EMSlift.GRxform")
  return(OM_stat);
}
end implementation EMSlift;
