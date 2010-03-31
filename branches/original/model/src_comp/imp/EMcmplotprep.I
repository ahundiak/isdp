class implementation EMScomposite;

#include "emsdef.h"
#include "EMSmsgdef.h"

/*
Description
   This is a passes the GRplotprep message to its childern.

History
   RC    01/02/90     Creation Date

*/

method GRplotprep(IGRlong *msg; struct GRmd_env *cur_env; 
       struct GRmd_env *target_env; IGRshort *num_prisms;
       struct IGRcv_prism *prism_array; struct GRid *set_id;
       IGRlong *begin_index, *end_index)
{
  OM_S_CHANSELECT  to_cmpnt_chan;
  IGRlong          OM_stat;
  extern IGRlong   EMmake_chanselect();

  EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);

  OM_stat = om$send (msg = OPPmargs, 
                     p_chanselect = &to_cmpnt_chan);
  EMerr_hndlr (!(1&OM_stat&*msg), *msg, EMS_E_Fail, wrapup);

 wrapup:
  EMWRAPUP(*msg,OM_stat,"EMScomposite.GRplotprep");
  return (OM_stat);

                                
}

end implementation EMScomposite;
