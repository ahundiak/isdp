/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfrembnd;

#include "EMS.h"
#include "msdef.h"
#include "OMmacros.h"

extern OMuword OPP_EMSsolid_class_id;

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

HISTORY

    AMD   :  04/18/91   :  Creation
*/
{
  IGRlong                  OM_stat; 
  IGRint                   i, j;
  union EMSssi_table       *ssi;
  struct EMSdbssi_table  *my_info;
  GRobjid                  *sf_out;
  

  *msg = MSSUCC;
  OM_stat = OM_S_SUCCESS;

  ssi = NULL;
  my_info = NULL;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(msg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *msg)) goto wrapup;

  my_info = &ssi->db_info;
  sf_out = my_info->surface_out_ids;
  
  for(i = 0; i < my_info->num_composites; i++)
  {
    for(j = 0; j < my_info->num_surfaces_out[i]; j++)
    {
      /*Send to all surfaces out.*/
      OM_stat = om$send(msg = OPPmargs, targetid = *sf_out);
      if (! (1 & OM_stat & *msg)) goto wrapup;
      sf_out++;
    }
  }

  /*Invoke the parents method.*/
  OM_stat = om$send(mode = OM_e_wrt_message, 
                    msg = message EMSsfregmod.GRxform(msg, obj_mdenv,
                          matrix_type, matrix, newobjid),
                    targetid = my_id);
  if (! (1 & OM_stat & *msg)) goto wrapup;
  
 wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*msg, OM_stat, "In EMSsfrembnd.GRxform")
  return(OM_stat);
}
end implementation EMSsfrembnd;
