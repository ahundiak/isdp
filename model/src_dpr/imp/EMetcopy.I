/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedittree;

#include "EMS.h"
#include "msdef.h" /* MS message codes */
#include "emsdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "EMSdpr.h"
#include "EMSopt.h"
#include "EMSssprops.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#ifdef DEBUG
#include "stdio.h"
#endif

from EMSsurface import EMgetactiveid;
from EMSsubbs   import EMupdateGradata, EMset_props;
from EMSdpr     import EMundo, EMredo;

method GRcopy(IGRlong             *EMmsg;
              struct GRmd_env     *obj_env; 
              struct GRmd_env     *new_env;
              GRobjid             *newobjid)
/*
Description
    This method will copy the unevaluated node in a dpr tree.

Notes
    Since the tree node is copied via undo and redo, no restrictions exist
    relative to local mods. 

History
    DLB 11/08/89    Added code to handle case of active_id == my_id.  This may
                    occur if the node_id has been removed from the model due to
                    a disjoint case.  Basically, I changed EMgetactive id to 
                    send to nodes_owner_id, and changed EMmake_active_state to
                    EMundo and to send to nodes_owner_id.
    DLB 10/07/89    Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  struct GRid       active_GRid;
  IGRushort options;
  IGRuchar  props;


# if DEBUG
  fprintf(stderr,"EMetcopy - copying node %d\n", ME.EMSedittree->node_id);
#endif    

  *EMmsg = MSSUCC;

  ex$message(msgnumb = EMS_I_CopyingSelectedNode)

  /*Remember where I am.*/ 
  OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                          &active_GRid, NULL), 
                    targetid = ME.EMSedittree->nodes_owner_id,
                    targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  options = EMS_TEMP_UNDO;
  OM_stat = om$send(msg = message EMSdpr.EMundo(EMmsg,
                          &options, obj_env, NULL, NULL, NULL, NULL, NULL,
                          NULL),
                    targetid = ME.EMSedittree->nodes_owner_id,
                    targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  OM_stat = om$send(msg = message GRgraphics.GRcopy(EMmsg, obj_env, 
                          new_env, newobjid),
                    targetid = ME.EMSedittree->node_id,
                    targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  /*The copied surfaces may have their range mod bit set but are not in the
   * r-tree (due to nesting etc).  So unconditionally turn off this bit.
   */
  props = (EMSIS_RTREE_RANGE_GOOD | EMSIS_RANGE_MODIFIED);
  OM_stat = om$send(msg = message EMSsubbs.EMset_props(EMmsg, props, 
                          EMS_O_OFF),
                    targetid = *newobjid,
                    targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
  options = NULL;
  OM_stat = om$send(msg = message EMSdpr.EMredo(EMmsg, &options, obj_env,
                          NULL, NULL, NULL),
                       targetid = active_GRid.objid,
                       targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Any topology change causes the gradata objects to be out of date.  This
   * is inefficient but I hope to correct this in the future.  Anyway, the 
   * following will make them up to date.
   */
  OM_stat = om$send(msg = message EMSsubbs.EMupdateGradata(EMmsg,
                          &obj_env->md_env.matrix_type,
                          obj_env->md_env.matrix),
                    targetid = active_GRid.objid,
                    targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  ex$message(msgnumb = EMS_I_ClearStatusField)

  wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "EMSedittree.GRcopy");
    return(OM_stat);
}
end implementation EMSedittree;
