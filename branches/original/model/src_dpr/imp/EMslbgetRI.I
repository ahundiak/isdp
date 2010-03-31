/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslboolean;

#include "EMS.h"
#include "OMmacros.h"
#if DEBUG
#include "stdio.h"
#endif

method EMgetRI(IGRlong *EMmsg; union EMSri_table **ri)
/*
History
        DLB     05/31/89        Added check for disjoint ipss.
        SM      11-Jan-89       Creation.
*/

{
  IGRlong               sts=OM_S_SUCCESS;
  IGRint                count;
  OM_S_CHANSELECT       to_comps;
  OMuword               junk;
  enum EMSbooltype      exact_type;


  *EMmsg = EMS_S_Success;
  *ri = NULL;

  /* Get the operation type. */
  sts = om$send(msg = message EMSsfboolean.EMget_operation_type(
                      EMmsg, NULL, &exact_type, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL),
                targetid = my_id);
  if (!(1 & sts & *EMmsg)) goto wrapup;

  if(exact_type == EMSbool_saveside)
  {
    *ri = (union EMSri_table *) om$malloc
          (size = sizeof(struct EMSsavesideri_table));
    if (! *ri) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

    (*ri)->saveside_info.plane_id = NULL_OBJID;

    EMmake_chanselect(GRcmpowner_to_components, &to_comps);

    /*Ignore the possibility of no plane on index 1.*/
    om$get_objid_at_index(object = me, 
                          p_chanselect = &to_comps, 
                          objidaddr = &(*ri)->saveside_info.plane_id, 
                          osnumaddr = &junk, 
                          index = 1);
  }
#if DEBUG
  else fprintf(stderr,"EMgetRI attempted on non-saveside node\n");
#endif  

  wrapup:
    EMWRAPUP(*EMmsg, sts, "EMSslboolean.EMgetRI");
    return(sts);
}
end implementation EMSslboolean;
