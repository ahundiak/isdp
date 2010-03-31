class implementation EMScnstr;

#include "msdef.h"

method GRdisplay (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                  enum GRdpmode *dpmode; struct GRid *display_id)
{
  IGRint count;
  IGRlong msg_loc;

  *msg = EMS_S_Success;

  count = 0;
  om$send (msg = message GRowner.GRget_number_components (&msg_loc, &count),
   targetid = my_id);
  if (count)
    om$send (msg = message EMScomposite.GRdisplay (&msg_loc, mattyp, mat,
     dpmode, display_id), mode = OM_e_wrt_message, targetid = my_id);
 
  return (OM_S_SUCCESS);
}

end implementation EMScnstr;
