class implementation SKdumpt;

#include "EMSmsgdef.h"
#include "ECmsg.h"
#include "msdef.h"
#include "msmacros.h"

method GRgetobjinfo (long *msg; struct GRobj_info *info)
{
  *msg = EMS_S_Success;
  ex$message ( buff = info->type, msgnumb = EMS_S_ProfileVertex );
  return OM_S_SUCCESS;
}

method SKget_origin_id (long *msg; struct GRid *origin_id )
{
  *msg = EMS_S_Success;
  origin_id->objid = me->origin_id.objid; 
  origin_id->osnum = me->origin_id.osnum;
  return OM_S_SUCCESS;
}

method SKput_origin_id (long *msg; struct GRid *origin_id )
{
  *msg = EMS_S_Success;
  me->origin_id.objid = origin_id->objid;
  me->origin_id.osnum = origin_id->osnum;
  return OM_S_SUCCESS;
}

end implementation SKdumpt;

