/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "EMSerrordef.h"

method EMget_props(IGRlong *EMmsg; IGRuchar *props)
/*
History

	AIC	03/14/88	Creation Date

*/
{
  *EMmsg = EMS_S_Success;

  *props  = ME.EMSsubbs->ss_props;

  return(OM_S_SUCCESS);
}

method GRgethprops(IGRlong *EMmsg; IGRuint *index)
{
    IGRlong sts;

    if(me->hidden_line < 0)
    {
      sts = OM_E_ERROR;
      *EMmsg = EMS_E_OutOfBounds;
    }
    else
    {
      *EMmsg = EMS_S_Success;
      sts = OM_S_SUCCESS;
      *index = (IGRushort) me->hidden_line;
    }

    return sts;
}

end implementation EMSsubbs;
