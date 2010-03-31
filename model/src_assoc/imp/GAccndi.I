class implementation GAcompcurve;

#include "EMSkey.h"

from EMSpointer import EMinit;

method NDmake_source(IGRlong *EMmsg;
		     struct GRid *located_obj,*context_GRid;char *path;
		     GRspacenum as_osnum; struct GRid *as)
{
 struct GRid my_GRid;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 if (located_obj->objid == my_id)
 {
  return (om$send (mode = OM_e_wrt_message,
                   targetid = my_id,
                   msg = message EMSassoc.NDmake_source(EMmsg,located_obj,
                         context_GRid, path, as_osnum, as)));
 }

 return (EFmake_pointer_to_comp(EMmsg, located_obj, context_GRid, path, 
                       as_osnum, as,
                       &my_GRid));
}

end implementation GAcompcurve;
