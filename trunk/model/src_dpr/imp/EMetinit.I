/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedittree;

#include "EMS.h"
#include "emsdef.h"

method EMinit(IGRlong *EMmsg;
              GRobjid node_id;
              OMuword node_os)
{
  IGRlong         OM_stat;
  OM_S_CHANSELECT to_owners;
  OMuword         dumosnum;

  *EMmsg = EMS_S_Success;

  ME.EMSedittree->node_id = node_id;
  ME.EMSedittree->node_os = node_os;

  EMmake_chanselect(GRconnector_to_owners, &to_owners);

  OM_stat = om$get_objid_at_index(objid = node_id,
                                  osnum = node_os,
                                  p_chanselect = &to_owners,
                                  index = 0,
                                  objidaddr = &ME.EMSedittree->nodes_owner_id, 
                                  osnumaddr = &dumosnum);
  if (!(1 & OM_stat))
  {
    /*This should never happen but just in case...*/
    ME.EMSedittree->nodes_owner_id = NULL_OBJID;
  }                                     

  return(OM_S_SUCCESS);
}
end implementation EMSedittree;
