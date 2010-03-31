class implementation EMSsfcapsf;

/*
HISTORY

  07/14/92  : AMD :  Creation

*/

#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmapdef.h"
#include "emsimpdef.h"

#if DEBUG
#define ERROR(sts,msg,error_message,label)      \
    if (EMSmsgReport(sts,error_message,FALSE) || \
        EMSmsgReport(msg,error_message,FALSE))   \
                goto label;
#else
#define ERROR(sts,msg,error_message,label)   if (!(sts & msg & 1)) goto label;
#endif
#define KLUDGE_NECESSARY 0

from GRcurve import EMcvtanorm;
from EMSsubbs import EMsftanorm;
from EMSdprparam import EMget_display_ids, EMput_display_ids;

method EMconstruct_associative(IGRlong *msg;
                               IGRushort options;
                               OM_S_OBJID old_objid;
                               IGRint nparents;
                               IGRchar *parent_info;
                               IGRint type;
                               IGRchar *recomp_info;
                               struct GRvg_construct *construct)

{
   IGRint   i, recompute, num_surfs;
   IGRlong  sts, loc_msg;
   union EMSparent_info *parents = NULL;
   GRobjid   surface;
   struct GRid   active_GRid;
   IGRuint       *parent_types;
   IGRushort     dpr_options=NULL;
   GRobjid       *caps=NULL;
   GRobjid       *display_ids=NULL, param_id;
   IGRint        display_count=0, num_caps;
   OMuint        count;
   OM_S_CHANSELECT to_components;
   OMuword         dumosnum;

   EMmake_chanselect (GRcmpowner_to_components, &to_components);

   /* check options for recompute */

    recompute = options & EMSasconst_recompute;

    /* unwind the parent information */

    parents = (union EMSparent_info *)alloca(sizeof
              (union EMSparent_info) * nparents);
    parent_types = (IGRuint *) alloca(sizeof(IGRint) * nparents);
    for (i = 0; i < nparents; i++) parent_types[i] = EMSgrid;

    sts = om$send(msg = message EMSassoc.EMget_parent_info
                       (msg, NULL, nparents, parent_info,
                        parent_types, parents),
                  targetid = my_id);

    ERROR(sts, *msg, "EMSsfcapsf$EMconstruct_associative", ret_end);
 
    surface = parents[0].grobj.grid.objid;

    active_GRid = parents[1].grobj.grid;

    if (recompute)
    {
     sts = EFsend_to_param(msg, 
                 message EMSdprparam.EMget_display_ids(
                 msg, &display_count, &display_ids, NULL),
                 my_id, OM_Gw_current_OS, &param_id, NULL); 
     if (!(1 & sts & *msg)) goto ret_end;
    }    
    
    sts = om$send(msg = message EMSsfsolid.EMcap_thyself
                           (msg, construct, &surface),
                targetid = my_id);
    EMomerr_hndlr (sts, ret_end, "EMSsfsolid.EMcap_thyself");  

    /* Get the caps. Needed for preparing the dpr state */

    sts = om$get_channel_count ( objid = my_id,
                                 p_chanselect = &to_components,
                                 count = &count);
    EMomerr_hndlr (sts, ret_end, "om$get_channel_count");  

    /* Malloc the space for caps */

    caps = (GRobjid *) om$malloc ( size = count * sizeof(GRobjid));

    for(i=1; i<count; i++)
    {
     sts = om$get_objid_at_index ( objid = my_id,
                                   p_chanselect = &to_components, 
                                   index = i,
                                   objidaddr = &caps[i-1],
                                   osnumaddr = &dumosnum);
     EMomerr_hndlr (sts, ret_end, "om$get_objid_at_index");  
    }

    num_caps = count - 1;

    sts = om$send(msg = message EMSsfcapsf.EMprepare_dpr_state(
                        msg, dpr_options, num_caps, caps),
             targetid = my_id);
    EMomerr_hndlr (sts, ret_end, "EMSsfcapsf.EMprepare_dpr_state");  

    if(recompute)
    {
     /* Put the display_ids in the param object */
     sts = om$send(msg = message EMSdprparam.EMput_display_ids(
                      &loc_msg, display_count, display_ids, NULL),
                 targetid = param_id);
     EMomerr_hndlr (sts, ret_end, "EMSdprparam.EMput_display_ids");  

     display_ids = NULL;
     if (!(1 & loc_msg & sts)) 
      {*msg = loc_msg; goto ret_end;}
    }

ret_end:
  
  if(caps) om$dealloc (ptr = caps);

  return (sts);

}

end implementation EMSsfcapsf;    
