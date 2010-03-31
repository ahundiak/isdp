/* ###################   APOGEE COMPILED   ################## */
class implementation EMSparamgm;

#include "emsdef.h"

method EMis_externally_constrained(IGRlong *EMmsg; 
                                   IGRboolean *is_externally_constrained)
/*
Description
    Return is_externally_constrained set to TRUE if I am externally
    constrained.

Notes
    None.

History
    DLB 04/09/91    Creation.
    jhw 07/25/91    Changed to return constrained if count > 0.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  OMuint          count = 0;
  OM_S_CHANSELECT to_father;

 
  *EMmsg = EMS_S_Success;
  *is_externally_constrained = FALSE;
 
  /*See if any of my parents are externally constrained*/
  EMmake_chanselect(NDfather_father, &to_father);

  OM_stat = om$get_channel_count(object = me,
                                 p_chanselect = &to_father,
                                 count = &count);
  
  *is_externally_constrained = (count) ? TRUE : FALSE;

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "param.EMis_extern_constr")
  return(OM_stat);
}
end implementation EMSparamgm;
