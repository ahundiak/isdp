class implementation COconst;

#include "EMS.h"
#define DEBUG 0  /*Set to 1 if want error strings*/

#include "EMSopt.h"
#include "OMmacros.h"
#include "codef.h"
#include "ECdlb.h"
#include "EMSbnddef.h"
#include "EMSmsgdef.h"
#include "EMSlogic.h"
#include "EMScmacros.h"
#include "dpmacros.h"
#include "grdpbmacros.h" 
#include "exmacros.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include "EMStypedef.h"

from EMSsurface import EMisClassInTree;
from EMSsubbs   import EMis_surf_modif;
from EMSedge    import EMis_edge_modif;

IGRlong EFis_surf_modif(EMmsg, target_GRid, option, is_modif)

IGRlong     *EMmsg;
struct GRid target_GRid;
IGRshort    option;
IGRboolean  *is_modif;

{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *EMmsg = EMS_S_Success;
  
  OM_stat = om$send(msg = message EMSsubbs.EMis_surf_modif(EMmsg, option,
                          is_modif), 
                    senderid = NULL_OBJID,
                    targetid = target_GRid.objid,
                    targetos = target_GRid.osnum);
  ERROR(OM_stat, *EMmsg, "EFis_surf_modif send", wrapup);

  wrapup:
    return(OM_stat);  
}

IGRlong EFis_edge_modif(EMmsg, target_GRid, option, which_end_pt, is_modif)

IGRlong     *EMmsg;
struct GRid target_GRid;
IGRshort    option;
IGRshort    which_end_pt;
IGRboolean  *is_modif;

{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *EMmsg = EMS_S_Success;
  
  OM_stat = om$send(msg = message EMSedge.EMis_edge_modif(EMmsg, option,
                          which_end_pt, is_modif), 
                    senderid = NULL_OBJID,
                    targetid = target_GRid.objid,
                    targetos = target_GRid.osnum);
  ERROR(OM_stat, *EMmsg, "EFis_surf_modif send", wrapup);

  wrapup:
    return(OM_stat);  
}

IGRlong EFisClassInTree(EMmsg, target_GRid, classid, num_classid,
                        in_the_tree, search_up)

IGRlong           *EMmsg;
struct GRid       target_GRid;
OMuword           *classid;
IGRushort num_classid;
IGRboolean        *in_the_tree;
IGRboolean        search_up;

{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *EMmsg = EMS_S_Success;
  
  OM_stat = om$send(msg = message EMSsurface.EMisClassInTree(EMmsg, classid,
                          num_classid, in_the_tree, search_up), 
                    senderid = NULL_OBJID,
                    targetid = target_GRid.objid,
                    targetos = target_GRid.osnum);
  ERROR(OM_stat, *EMmsg, "EFisClassInTree send", wrapup);

  wrapup:
    return(OM_stat);  
}

end implementation COconst;
