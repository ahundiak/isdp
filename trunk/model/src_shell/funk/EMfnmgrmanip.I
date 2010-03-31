/* ###################   APOGEE COMPILED   ################## */
class implementation EMSfanmgr;

#include "EMS.h"

extern OMuword OPP_EMSfanmgr_class_id;

/*
   HISTORY

     RC   11/23/88     Creation Date
*/

void EFfnmgr_manipulation (EFmsg, os, label, manip_type, key_type, 
                           manip_info, rpl_info)
     IGRlong                *EFmsg;
     GRspacenum             os;
     IGRulong       label;
     IGRushort      manip_type, key_type;
     struct EMSfnmgr_info   *manip_info, *rpl_info;      

{
  IGRlong           OM_stat, mthd_stat, rc;
  extern IGRlong    EMgetmgr();
  GRobjid           MGRobj;

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  /*
   * Obtain the object id of the fan-manager object for this 
   * object-space and tag-number.
   */

  OM_stat = EMgetmgr (&rc, os, OPP_EMSfanmgr_class_id, label, &MGRobj);
  EMerr_hndlr (!(1&OM_stat&rc), *EFmsg, EMS_E_Fail, wrapup);

  /*
   * Having obtained the objid of the manager send the 
   * appropriate message to it to manipulate.
   */

  if (manip_type & EMSFM_MANIP_PUT)
    OM_stat = om$send (msg = message EMSfanmgr.EMputentry (&mthd_stat,
                        key_type, manip_info),
                       senderid = NULL_OBJID, targetid = MGRobj, 
                       targetos = os);

  else if (manip_type & EMSFM_MANIP_GET)
     OM_stat = om$send (msg = message EMSfanmgr.EMgetentry (
                         &mthd_stat, key_type, manip_info),
                        senderid = NULL_OBJID,
                        targetid = MGRobj, targetos = os);

  else if (manip_type & EMSFM_MANIP_DEL)
    OM_stat = om$send (msg = message EMSfanmgr.EMdelentry (&mthd_stat, 
                        key_type, manip_info),
                       senderid = NULL_OBJID,
                       targetid = MGRobj, targetos = os);

  else if (manip_type & EMSFM_MANIP_RPL)
    OM_stat = om$send (msg = message EMSfanmgr.EMrplentry (&mthd_stat, 
                        key_type, manip_info, rpl_info),
                       senderid = NULL_OBJID,
                       targetid = MGRobj, targetos = os);
  else
    EMerr_hndlr (TRUE, *EFmsg, EMS_E_InvalidArg, wrapup);


  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg,EMS_E_Fail,wrapup);

wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "In EFfnmgr_manipulation");

  return;
  
} /* void EMfnmgr_manipulation () */

end implementation EMSfanmgr;
