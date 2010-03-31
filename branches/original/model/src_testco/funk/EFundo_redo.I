class implementation COconst;

#include "EMS.h"
#include <stdio.h>
#include "EMSopt.h"
#include "OMmacros.h"
#include "codef.h"
#include "ECdfh.h"
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
#include "EC_P.h"
#include "EC_S.h"

from GRgraphics import GRdisplay;
from EMSsurface import EMmake_active_state;
from EMSsurface import EMgetactiveid;
from EMSdpr     import EMdeactivate, EMundo, EMredo;

EFundo_to_lm(EMmsg, surf_id, top_lm_id, active_state_id, module_env,
              num_states, active_states)
IGRlong         *EMmsg;
struct GRid     *surf_id, *top_lm_id, *active_state_id;
struct GRmd_env *module_env;
IGRint          *num_states;
struct GRid     **active_states;

{
 IGRint          OM_stat=OM_S_SUCCESS, buff_size = 0, display_count = 0,
                 involk_count = 0;
 GRobjid         *display_ids = NULL;
 enum   GRdpmode DisplayMode;
 IGRushort        undo_option;


 ex$message(msgnumb=EMS_P_ClearPromptField);
 ex$message(msgnumb=EMS_S_UndoMostRecLocModSt);

 OM_stat = dp$erase_hilite(msg = EMmsg);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 /*Make the top local mod active.*/
 undo_option = EMS_TEMP_UNDO | EMS_GET_ACTIVE_STATES | EMS_DO_DISPLAY;
 *num_states = 0;
 *active_states = NULL;

 OM_stat = om$send(msg = message EMSsurface.EMmake_active_state(
                         EMmsg, &undo_option,  
                         module_env,
                         active_states, num_states,
                         &buff_size,
                         &display_ids,
                         &display_count,
                         &involk_count),
                   senderid = NULL_OBJID,
                   targetid = top_lm_id->objid,
                   targetos = top_lm_id->osnum);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup; 

 ex$message(msgnumb=EMS_S_ClearStatusField);

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFundo_to_lm")
  return(OM_stat);
}


EFredo_to_top(EMmsg, active_state_id, module_env, num_states, active_states)
IGRlong         *EMmsg;
struct GRid     *active_state_id;
struct GRmd_env *module_env;
IGRint          *num_states;
struct GRid     *active_states;

{
 IGRint  OM_stat=OM_S_SUCCESS, i, display_count = 0, involk_count = 0;
 GRobjid *display_ids = NULL;
 IGRushort redo_option = EMS_DO_DISPLAY;

 ex$message(msgnumb=EMS_P_ClearPromptField);
 ex$message(msgnumb=EMS_S_RetSolidToActSt);

 OM_stat = dp$erase_hilite(msg = EMmsg);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 /*Make the top state active again*/
 OM_stat = om$send(msg = message EMSdpr.EMredo(EMmsg, &redo_option,
                         module_env, &display_ids, &display_count,
                         &involk_count), 
                   senderid = NULL_OBJID,
                   targetid = active_state_id->objid,
                   targetos = active_state_id->osnum);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 ex$message(msgnumb=EMS_S_ClearStatusField);

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFredo_to_top")
  return(OM_stat);
}

end implementation COconst;
