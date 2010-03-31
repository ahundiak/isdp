/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdpr;

# include <stdio.h>
# include "igrtypedef.h"
# include "igr.h"
# include "gocmacros.h"
# include "OMmacros.h"
# include "msdef.h"
# include "memory.h"
# include "emsdef.h"
# include "emserr.h"
# include "EMSdpr.h"
# include "EMSutlmacros.h"

method EMget_construction_info(IGRlong *EMmsg;
                               struct GRvg_construct *construct_list)
{
  IGRlong OM_stat=OM_S_SUCCESS;
  IGRint            num_ids=0;
  GRobjid           *ids=NULL;


  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSdpr.EMgetInGeomIds(EMmsg, NULL_OBJID,
                          FALSE, &num_ids, &ids, NULL),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    
/***************************************************************************
  OM_stat = EFget_construction_info_from_id(EMmsg, construct_list,
                                            (num_ids ? ids[0] : my_id),
                                            OM_Gw_current_OS);
***************************************************************************/
  OM_stat = ems$get_construction_info_from_id(
                               msg = EMmsg,
                               construction_args = construct_list,
                               objid = (num_ids ? ids[0] : my_id));
                      

wrapup:
  if (ids) om$dealloc(ptr = ids);
  EMWRAPUP(*EMmsg, OM_stat, "EMget_construction_info")
  return(OM_stat);
}
end implementation EMSsfdpr;

