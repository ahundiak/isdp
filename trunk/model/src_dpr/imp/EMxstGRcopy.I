/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsec_st;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "EMSssi.h"
#include "OMprimitives.h"
#include "OMmacros.h"

/*
 DESCRIPTION
   This method perform copy process of cross sectiuon state.
   It is assumed that this method will be invoked directly and not
   through the associated model. In such a case the copy should be in
   the compressed format and also of class EMSgencompsf with
   childern of class EMSplane.
 
 HISTORY     

        RC     12/09/88      Creation Date

*/

method GRcopy(
  IGRlong             *EMmsg;
  struct GRmd_env     *obj_mdenv; 
  struct GRmd_env     *new_mdenv;
  GRobjid             *newobjid)

{
  OM_S_CHANSELECT  to_cmpnt_chan;
  struct GRid      new_GRid, cmpnt_GRid;
  IGRlong          OM_stat, mthd_stat;
  OMuint           num_cmpnts, i;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /*
   * o Copy as my parent does.
   * o compress my self.
   * o Change my and my childern class.
   */

  OM_stat = om$send (mode = OM_e_wrt_parent,
                     msg = message EMSxsec_st.GRcopy (EMmsg, 
                      obj_mdenv, new_mdenv, newobjid),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_SurfaceError,wrapup);

  OM_stat = om$send (msg = message EMSdpr.EMmake_primitive1 (&mthd_stat,
                      new_mdenv, &new_GRid),
                     targetid = *newobjid, 
                     targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$get_channel_count (objid = new_GRid.objid,
                                  osnum = new_GRid.osnum,
                                  p_chanselect = &to_cmpnt_chan,
                                  count = &num_cmpnts);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  for (i = 0; i < num_cmpnts; i++)
  {
    OM_stat = om$get_objid_at_index (objid = new_GRid.objid,
                 osnum = new_GRid.osnum, p_chanselect = &to_cmpnt_chan,
                 index = i, objidaddr = &cmpnt_GRid.objid,
                 osnumaddr = &cmpnt_GRid.osnum);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    OM_stat = om$send (msg = message EMSxsection.EMchange_class (
                        &mthd_stat, new_mdenv, newobjid),
                       targetid = cmpnt_GRid.objid,
                       targetos = cmpnt_GRid.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
 
  } /* for (i = 0; i < num_cmpnts; i++) */

  *newobjid = new_GRid.objid;

  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxsec_st.GRcopy");
   return (OM_stat);
}

end implementation EMSxsec_st;
