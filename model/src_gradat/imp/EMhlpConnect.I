/* ###################   APOGEE COMPILED   ################## */
class implementation EMShelper;

#include "EMS.h"
# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"
# endif

# ifndef emserr_include
# include "emserr.h"
# endif

# include "emsdef.h"

method EMhelperConnect(IGRlong *EMmsg; GRobjid req_id; IGRint index)
{
  IGRlong           sts = OM_S_SUCCESS;
  OM_S_CHANSELECT   to_helpers;
  OM_S_CHANSELECT   to_requesters;

  sts = EMmake_chanselect (EMSrequester_to_helpers, &to_helpers);
  if(! (1 & sts)) goto wrapup;

  sts = EMmake_chanselect (EMShelper_to_requesters, &to_requesters);
  if(! (1 & sts)) goto wrapup;

  sts = om$send(msg = message Root.connect(to_helpers, index, my_id,
                OM_Gw_current_OS, to_requesters, MAXINT), targetid = req_id);

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMShelper.EMhelperConnect")
  return(sts);
}

end implementation EMShelper;
