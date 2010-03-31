/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsection;

%safe
#include <math.h>
%endsafe


#include "EMS.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSxsection.h"

/*
   
 HISTORY

     RC       12/05/88       Creation Date
*/

void EFdel_xsec_assoc_info (EFmsg, objid, cur_os)
     IGRlong     *EFmsg;
     GRobjid     objid;
     GRspacenum  cur_os;
{
  struct EMSfnmgr_info fnmgr_info;
  IGRlong     OM_stat, mthd_stat, rc;
  GRobjid     *act_eds = NULL, *inact_eds = NULL;
  IGRint      num_act_eds = 0, num_inact_eds = 0, act_eds_arrsz = 0,
              inact_eds_arrsz = 0;
  extern void EFfnmgr_manipulation();

  /* ************************************************************* */

  OM_stat = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;

  OM_stat = om$send (msg = message EMSxsection.EMget_associated_edges (
                      &mthd_stat, &act_eds, &inact_eds, &num_act_eds,
                      &num_inact_eds, &act_eds_arrsz, &inact_eds_arrsz,
                      EMSXS_ACT_EDGES | EMSXS_INACT_EDGES, MAXINT),
                     senderid = NULL_OBJID,
                     targetid = objid, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

  if (num_act_eds)
  {
    fnmgr_info.tips = act_eds;
    fnmgr_info.num_tips = num_act_eds;
    EFfnmgr_manipulation (&rc, cur_os, EMSlabel_xsection, EMSFM_MANIP_DEL,
                          EMSFM_KEY_TIP, &fnmgr_info, NULL);
    EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

  } /* if (num_act_eds) */

  if (num_inact_eds)
  {
    fnmgr_info.tips = inact_eds;
    fnmgr_info.num_tips = num_inact_eds;
    EFfnmgr_manipulation (&rc, cur_os, EMSlabel_xsection, EMSFM_MANIP_DEL,
                          EMSFM_KEY_TIP, &fnmgr_info, NULL);
    EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

  } /* if (num_inact_eds) */

  wrapup:
   EMWRAPUP (*EFmsg, OM_stat, "In EFdel_xsec_assoc_info");
   if (act_eds) om$dealloc (ptr = act_eds);
   if (inact_eds) om$dealloc (ptr = inact_eds);
   return;
}


end implementation EMSxsection;
