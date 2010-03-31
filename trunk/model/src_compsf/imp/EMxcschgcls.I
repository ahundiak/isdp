/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxscompsf;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
# include "msdef.h" /* MS message codes */
# include "ma.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMcp.h"
# include "EMSprop.h"
# include "EMSopt.h"
# include "gocmacros.h"

/*
 DESCRIPTION
   This method changes the class of this object to EMSgencompsf
   and its childern to EMSplane.
 
 HISTORY     

        RC     12/09/88      Creation Date

*/

extern OMuword OPP_EMSgencompsf_class_id;

method EMchange_class (
       IGRlong           *EMmsg;
       struct  GRmd_env  *md_env;
       GRobjid           *newobjid)

{
  OM_S_CHANSELECT     to_cmpnt_chan, notification_chan;
  IGRlong             OM_stat, mthd_stat;


  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = EMmake_chanselect (GRnotify_notification, &notification_chan);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = om$send (msg = message EMSxsection.EMchange_class (
                      &mthd_stat, md_env, newobjid),
                     p_chanselect = &to_cmpnt_chan);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
 
  OM_stat = om$construct (classid = OPP_EMSgencompsf_class_id,
                          osnum = OM_Gw_current_OS,
                          p_objid = newobjid);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = om$send (msg = message Root.move_chan (to_cmpnt_chan, my_id, 
                      OM_Gw_current_OS, to_cmpnt_chan),
                     targetid = *newobjid);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror, wrapup);

  OM_stat = om$send (msg = message Root.move_chan (notification_chan, 
                      my_id, OM_Gw_current_OS, notification_chan),
                     targetid = *newobjid);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror, wrapup);

  OM_stat = om$send (mode = OM_e_wrt_message,
                     msg = message Root.delete (1),
                     targetid = my_id); 
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxscompsf.EMchange_class");
   return (OM_stat);

}


end implementation EMSxscompsf;
