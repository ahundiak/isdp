class implementation EMSdatpln;

#include "lcdef.h"
#include "lcmsg.h"
#include "msdef.h"
#include "grerr.h"

method GRlocate_owner ( IGRlong *msg; 
                        struct GRlc_cvl *cvl;
                        struct GRlc_path *path; 
                        IGRint *path_position)
{
 IGRlong status;
 *msg = MSSUCC;

 if (cvl->attributes.obj_attr.owner_action & LC_HANDLES)
  return (om$send (mode = OM_e_wrt_parent,
                   msg = message EMSdatpln.GRlocate_owner(msg,
                         cvl,path, path_position),
                   targetid = my_id));
 else
 {

  GRLocInfo(GRObjectIneligible, LC_E_ExternConstrain,
            OM_Gw_current_OS, my_id);

  *msg = GRNO_PROCESSING_NEEDED;
  return (OM_S_SUCCESS);
 }

wrapup:
 return (status);
}
end implementation EMSdatpln;
