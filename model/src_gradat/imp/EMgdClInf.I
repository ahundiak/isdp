/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

#include "EMS.h"
/*
History

    RC,AIC    09/23/87  Creation Date
*/

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"
# endif

extern  OMuword  OPP_EMSgradata_class_id;

method EMget_class_info(IGRlong *EMmsg; OMuword *frt_classid;
                        OM_p_MESSAGE messg)
{
  *EMmsg = EMS_S_Success;
  if(frt_classid) *frt_classid = OPP_EMSgradata_class_id;
  if(messg) *messg = OM_GS_NULL_MESSAGE;

  return (OM_I_STOP_SENDING);
}

end implementation EMSgradata;
