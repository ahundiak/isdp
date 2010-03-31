/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

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

History
   DLB 06/01/88  Added code to xform the recompute info (the plane).
   DLB 11/03/87  Modified for version 1.1.0
   DLB 05/xx/87  creation.
*/
{
  IGRlong                  OM_stat; 
  IGRint                   i, j;
  union EMSssi_table       *ssi;
  struct EMSboolssi_table  *my_info;
  union EMSri_table        *ri;
  GRobjid                  *sf_out;
  

  *msg = MSSUCC;
  OM_stat = OM_S_SUCCESS;

  ri = NULL;
  ssi = NULL;
  my_info = NULL;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(msg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *msg)) goto wrapup;

  my_info = &ssi->bool_info;
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

  /*This code is added for the saveside on composite surface.
   * The plane is stored on the end of the vla and was used to recompute the
   * saveside. 
   */
  if (!EFisAncestryValid(msg, my_id, OM_Gw_current_OS, 
                         OPP_EMSsolid_class_id, FALSE))
  {
    /*Get the ri plane and xform it.*/
    ri = NULL;
    OM_stat = om$send(msg = message EMSdpr.EMgetRI(msg, &ri),
                      targetid = my_id);
    if (!(1 & OM_stat & *msg)) goto wrapup;

    if (ri)
    {
      OM_stat = om$send(msg = OPPmargs,
                        targetid = ri->saveside_info.plane_id);
      if (!(1 & OM_stat & *msg)) goto wrapup;
    }
  }

  /*Involk the parents method.*/
  OM_stat = om$send(mode = OM_e_wrt_message, 
                    msg = message EMSsfregmod.GRxform(msg, obj_mdenv,
                          matrix_type, matrix, newobjid),
                    targetid = my_id);
  if (! (1 & OM_stat & *msg)) goto wrapup;
  
 wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  if (ri) om$dealloc(ptr = ri);
  EMWRAPUP(*msg, OM_stat, "In EMSsfboolean.GRxform")
  return(OM_stat);
}
end implementation EMSsfboolean;
