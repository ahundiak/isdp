class implementation NMtrim;

#include "EMSas.h"
#include "EMSdpr.h"
#include "EMSprop.h"
#include "bserr.h"
#include "bsparameters.h"
#include <stdio.h>
#include "emssfintdef.h"

from EMSdprparam import EMget_display_ids, EMput_display_ids;

method EMconstruct_associative(IGRlong *EMmsg;
                               IGRushort options;
                               GRobjid  old_objid;
                               IGRint nb_root;
                               IGRchar *parent_info;
                               IGRint type;
                               IGRchar *recomp_info;
                               struct GRvg_construct *construct_list)
{
 IGRlong              OM_stat=OM_S_SUCCESS;
 GRobjid              *display_ids=NULL, param_id;
 IGRint               display_count=0;
 IGRushort    bool_options = EMSsfbool_opt_display;
 IGRboolean           recompute,
                      update_display_ids = FALSE;
 

 *EMmsg = EMS_S_Success;

 recompute = options & EMSasconst_recompute;

 if (recompute)
 {
   OM_stat = EFsend_to_param(EMmsg, message EMSdprparam.EMget_display_ids(
                                    EMmsg, &display_count, &display_ids, NULL),
                             my_id, OM_Gw_current_OS, &param_id, NULL); 
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   bool_options |= EMSsfbool_opt_noredraw;
   update_display_ids = TRUE;
 }

 bool_options |= EMSsfbool_opt_SingleTopology | EMSsfbool_opt_OpenIntPossible |
           EMSsfbool_opt_IncompleteInt;
    
/* Perform trimming
*/  
 OM_stat = om$send(msg = message NMtrim.NMtrim_element(EMmsg, 
           construct_list->env_info, bool_options, NULL, NULL, NULL, 
	   &display_ids, &display_count), targetid = my_id);

wrapup:

 if (update_display_ids)
 {
   /*Put the display_ids in the param object.*/
   IGRlong loc_msg;
   om$send(msg = message EMSdprparam.EMput_display_ids(&loc_msg,
                 display_count, display_ids, NULL),
           targetid = param_id);
 }

 EMWRAPUP (*EMmsg,OM_stat, "NMtrim.EMconstruct_associative")
 return (OM_stat);
}

end implementation NMtrim;

