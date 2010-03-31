/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
# include "EMSbnddef.h"     /* EMLP_PLOOP                   */

from EMSgradata import EMinit, EMget_class_info;
from EMSsubbs import EMmake_frt;

method EMmakeFRT(IGRlong *EMmsg; GRobjid surf_id)
{
  IGRlong           sts;
  OM_S_CHANSELECT   to_inner;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if(surf_id ISNT NULL_OBJID)
  {
    to_inner.type = OM_e_addr;
    to_inner.u_sel.addr = &ME.EMSloop->to_inner;

    /*
     * Send the message on to the inner loops
     */
    sts = om$send(msg = message EMSloop.EMmakeFRT(EMmsg, surf_id),
                  p_chanselect = &to_inner);
    if(! (1 & *EMmsg & sts)) goto wrapup;

    if(ME.EMSloop->lp_props & EMLP_PLOOP)
    {
      OM_S_CHANSELECT     to_helpers;

      /*
       * Make shure I have a graphics data object
       */
      *EMmsg = EMS_I_NoResponse;
      sts = EMmake_chanselect (EMSrequester_to_helpers, &to_helpers);
      if(! (1 & sts)) goto wrapup;

      sts = om$send(msg = message EMSgradata.EMget_class_info(EMmsg,
                    NULL, NULL), p_chanselect = &to_helpers);
      if(sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
      if(! (1 & *EMmsg & sts)) goto wrapup;

      if(*EMmsg IS EMS_I_NoResponse)
      {
        extern OMuword    OPP_EMSgradata_class_id;
        GRobjid           gradata_id;

        sts = om$send(msg = message EMSsubbs.EMmake_frt(EMmsg, my_id),
                      targetid = surf_id);
      }
      else /* there is a graphics data object */
      {
        sts = om$send(msg = message EMSgradata.EMinit(EMmsg, surf_id,
                      NULL_OBJID), p_chanselect = &to_helpers);
      }
    }
  }

wrapup:
  EMSmsgReport(sts, "EMSloop.EMmakeFRT", FALSE);
  if EMSmsgReport(*EMmsg, "EMSloop.EMmakeFRT", FALSE) sts = OM_E_ABORT;
  return(sts);
}

end implementation EMSloop;
