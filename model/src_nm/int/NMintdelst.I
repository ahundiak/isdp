class implementation NMinters;

#include "OMmacros.h"

method NMdelete_storage_objs(IGRlong *EMmsg; IGRboolean delete_other)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			num = 0, i;
 OM_S_CHANSELECT	to_other_int;

 *EMmsg = EMS_S_Success;
 num = om$dimension_of(varray = ME.NMinters->storage_objs);
 for(i=0; i<num; i++) 
  sts = om$send(msg = message Root.delete(TRUE), 
        targetid = ME.NMinters->storage_objs[i]);

 if(delete_other)
  {
   NMmake_chanselect(NMinters_to_other_int, &to_other_int);
   sts = om$send(msg = message NMinters.NMdelete_storage_objs(EMmsg, FALSE), 
         p_chanselect = &to_other_int);
  }

return(sts);
}

end implementation NMinters;
