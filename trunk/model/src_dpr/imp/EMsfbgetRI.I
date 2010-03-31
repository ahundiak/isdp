/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
#include "OMmacros.h"
#if DEBUG
#include "stdio.h"
#endif

method EMgetRI(IGRlong *EMmsg; union EMSri_table **ri)
/*
Description
    This method gets the recompute info structure from the instance
    data of this object.

Return values 
    EMmsg - EMS_S_Success if all goes well.

History
    DLB 11/11/89    Reset OM_stat after is_objid_valid test.
    DLB 06/02/88    Creation.
*/
{
  IGRlong          OM_stat=OM_S_SUCCESS;
  IGRint           count;
  enum EMSbooltype exact_type;


  *EMmsg = EMS_S_Success;
  *ri = NULL;

  /* Get the operation type. */
  OM_stat = om$send(msg = message EMSsfboolean.EMget_operation_type(
                          EMmsg, NULL, &exact_type, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL, NULL),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if(exact_type == EMSbool_saveside)
  {
    *ri = (union EMSri_table *) om$malloc
          (size = sizeof(struct EMSsavesideri_table));
    if (! *ri) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

    (*ri)->saveside_info.plane_id = NULL_OBJID;

    count = om$dimension_of(varray = ME.EMSdpr->ids);  
  
    if (count)
    {
      OM_stat = om$is_objid_valid(objid = ME.EMSdpr->ids[count-1]);
      if (OM_stat == OM_S_SUCCESS)
      {
        (*ri)->saveside_info.plane_id = ME.EMSdpr->ids[count-1];
      }
      else OM_stat = OM_S_SUCCESS;
    }
  }    
#if DEBUG
  else fprintf(stderr,"EMgetRI attempted on non-saveside node\n");
#endif  

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfbool.EMgetRI")
    return(OM_stat);
}
end implementation EMSsfboolean;
