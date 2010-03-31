class implementation EMSsurface;

#include "EMSopt.h"
#include "emsdef.h" /*DPR_DISPLAY_BUFF_INCR*/
#include "EMSdpr.h"

method EMreplacePrimitive(IGRlong *EMmsg; struct GRmd_env *my_env;
                          GRobjid new_id; IGRushort options)
/*
Description
    This message should be sent to a primitive to be replaced with new_id.

Return Values
    EMS_S_Success       - all is well.
    EMS_E_Fail          - if a failure occurred.

Notes
    About options parameter:

      EMS_DO_DISPLAY - if set this message will handle the erasing and
                       drawing of the solid. 
      EMS_DONT_REEX  - if set dont recompute the tree.
           
    The following assumptions are made regarding this message:

    1) This message is defined for use by Salvagnini Transferica ONLY. 

    2) This message is only valid for boolean trees.  However, no validity
       check is made.

    3) This message should be sent to a valid primitive (i.e. NOT to a
       surface of a solid).  No validity check is made for this either.
       
History
    DLB 10/28/88 Creation.
    NP  08/24/92 Modified for ANSI compliance. Changed "owner_to_comp_index" to
                 "IGRuint" (as needed by om$get_index) and typecast it as
                 "IGRlong" for GRconnector.GRrigidconn message.
    DLB 10/23/92 Rewritten to use new uneval/eval technology.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            display_count=0;
  GRobjid           *display_ids=NULL, active_id;
  IGRushort         repl_options;
  
  repl_options = (options & EMS_DONT_REEX) ? EMreplace_DONT_EVAL : NULL;
  repl_options |= (options & EMS_DO_DISPLAY) ? 
                  (EMreplace_DO_DISPLAY | EMreplace_DONT_REDRAW) : NULL;

  OM_stat = om$send(msg = message EMSsurface.EMreplace(EMmsg,
                          new_id, my_env, 
                          repl_options, 
                          &display_ids, &display_count, 
                          &active_id),
                    targetid = my_id);

  EMWRAPUP(*EMmsg, OM_stat, "surf.EMreplPrim")
  return(OM_stat);
}
end implementation EMSsurface;
