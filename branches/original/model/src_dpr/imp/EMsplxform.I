/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

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

History
   DLB 11/03/87  Modified for version 1.1.0
   DLB 05/29/87  creation.
*/
{
  IGRlong                OM_stat; 
  IGRint                 i;
  union EMSssi_table     *ssi;
  struct EMSsspssi_table *my_info;


  *msg = MSSUCC;
  OM_stat = OM_S_SUCCESS;

  ssi = NULL;
  my_info = NULL;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(msg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *msg)) goto wrapup;

  my_info = &ssi->spl_info;

  /*Send to all surfaces out.*/
  for (i = 0; i < my_info->num_srf; i ++)
  {
    OM_stat = om$send(msg = OPPmargs, 
                      targetid = my_info->srf_ids[i]);
    if (! (1 & OM_stat & *msg)) goto wrapup;
  }    
 
  /*Involk the parents method.*/
  OM_stat = om$send(mode = OM_e_wrt_message, 
                    msg = message EMSsflm.GRxform(msg, obj_mdenv,
                          matrix_type, matrix, newobjid),
                    targetid = my_id);
  if (! (1 & OM_stat & *msg)) goto wrapup;
  
 wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*msg, OM_stat, "In EMSsfsplit.GRxform")
  return(OM_stat);
}
end implementation EMSsfsplit;
