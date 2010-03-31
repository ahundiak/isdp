/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
/*
 Histroy

    28 October 87   AIC     Conversion to EMS version 1.1

    AIC, RC   09/22/87      Creation Date
*/

# define EMSmsgCompare(msg1, msg2) \
     ((msg1.select.DefClassid IS msg2.select.DefClassid) && \
      (msg1.select.ReqClassid IS msg2.select.ReqClassid) && \
      (msg1.select.FuncIndex IS msg2.select.FuncIndex) && \
      (msg1.size IS msg2.size) && \
      (msg1.p_arglist IS msg2.p_arglist))

extern OMuword      OPP_EMSgradata_class_id, 
                    OPP_EMSgraloop_class_id;

extern OM_S_MESSAGE OM_GS_NULL_MESSAGE;

from EMSgradata import  EMinit,
                        EMget_class_info, EMdelete_nat_gradata;

method EMmake_frt(IGRlong *EMmsg; GRobjid loop_id)
{
  IGRlong           sts;
  GRobjid           frt_id;
  OMuword           frt_classid = OPP_EMSgradata_class_id, 
                    loop_class_id;

  OM_S_MESSAGE      messg;
  OM_S_CHANSELECT   to_helpers;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  sts = om$get_classid(objid = loop_id,  p_classid = &loop_class_id);
  if(! (1 & sts)) goto wrapup;

  sts = om$is_ancestry_valid(superclassid = OPP_EMSgraloop_class_id,
                             subclassid = loop_class_id);
  if(sts != OM_S_SUCCESS)
  {
    sts = EMmake_chanselect (EMSrequester_to_helpers, &to_helpers);
    if(! (1 & sts)) goto wrapup;

    *EMmsg = EMS_I_NoResponse;
    sts = om$send(msg = message EMSgradata.EMget_class_info(EMmsg, NULL,
                  NULL),p_chanselect = &to_helpers,senderid = loop_id);
    if(*EMmsg IS EMS_I_NoResponse)
    {
      messg = OM_GS_NULL_MESSAGE;

      sts = om$send(msg = message EMSgradata.EMget_class_info(EMmsg,
                    &frt_classid, &messg), p_chanselect = &to_helpers);
      if (sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
      if(! (1 & *EMmsg & sts)) goto wrapup;

      sts = om$construct(classid = frt_classid, p_objid = &frt_id,
            msg = message EMSgradata.EMinit(EMmsg, my_id, loop_id));
      if(! (1 & *EMmsg & sts)) goto wrapup;

      if(! EMSmsgCompare(messg, OM_GS_NULL_MESSAGE))
      {
        sts = om$send (msg = &messg, targetid = frt_id);
        if(! (1 & *EMmsg & sts)) goto wrapup;

        if (messg.p_arglist) om$dealloc (ptr = messg.p_arglist);
      }

      /*
       * delete the natural garphics data object if there is one 
       * hanging from me
       */
      sts = om$send(msg = message EMSgradata.EMdelete_nat_gradata(EMmsg),
                    p_chanselect = &to_helpers);
/*
 * Patch for graphic loops.
 * pp 06/25/91
 */
      if (sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

    }

  } /* if(sts != OM_S_SUCCESS) */
  else
  {
    /*
     * Since the loop is a graphic loop, no gradata object is
     * constructed. The graphic loop itself behaves like one. So just
     * send an EMinit message to it(to connect it to the surface etc.).
     */
    sts = om$send(msg = message EMSgradata.EMinit ( EMmsg,
                            my_id, NULL_OBJID), targetid = loop_id);
/*
 * Patch for point loops.
 * SM 06/30/92
 */
      if (sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

    EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg, EMS_E_Fail, wrapup);
  }

wrapup:
  EMWRAPUP (*EMmsg, sts, "In EMSplane.EMmake_frt");
  return (sts); 
}               

end implementation EMSsubbs;
