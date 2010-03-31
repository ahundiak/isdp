/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
#include "msdef.h" /* MS message codes */
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "EMSbnddef.h"
#include "OMmacros.h"
#include "EMSdpr.h"

extern OMuword OPP_EMSsolid_class_id;

method EMrecompinfodelete(IGRlong *EMmsg; struct GRmd_env *my_env;
                          IGRushort options;
                          union EMSri_table *ri)
/*
Description
     This method will determine if this is a special saveside op.  If
     so it will delete the recompute information stored.  If the option is
     specified to delete component RI then do this also.     

Return values
     *EMmsg  completion code - EMS_S_Success if successful
                             - EMS_E_Fail (severe) if failure

Notes
    If options & RIDEL_DEL_COMP_RI then
         delete the component RI plane.
    if ri is specified, use this ri instead of that from the instance data.
        
History:
    DLB   10/23/89 Added ri parameter.
    DLB   06/01/88 Creation.
*/

{
  IGRlong           OM_stat = OM_S_SUCCESS;
  union EMSri_table *ri_ptr;


  *EMmsg = EMS_S_Success;
  ri_ptr = NULL;

  /*This code is added for the saveside on composite surface.  
   * The plane is stored on the end of the
   * vla and was used to recompute the saveside.
   */
  if ((options & RIDEL_DEL_COMP_RI) ||
      (!EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
                          OPP_EMSsolid_class_id, FALSE)))
  {
    if (!ri)
    {
      OM_stat = om$send(msg = message EMSdpr.EMgetRI(EMmsg, &ri_ptr),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
    else
      ri_ptr = ri;
                        
    if (ri_ptr)
    {
      if (ri_ptr->saveside_info.plane_id != NULL_OBJID)
      {
        OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, my_env),
                          targetid = ri_ptr->saveside_info.plane_id);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }
    }
  }

  wrapup:
   if (ri_ptr && !ri) om$dealloc(ptr = ri_ptr);
   EMWRAPUP(*EMmsg, OM_stat, "In EMSsfboolean.EMrecompinfodelete")
   return(OM_stat);
}
end implementation EMSsfboolean;
