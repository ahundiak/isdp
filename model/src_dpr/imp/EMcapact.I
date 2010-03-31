class implementation EMSsfcapsf;

/*

DESCRIPTION

This method will activate me if I am an inactive state.  This is
done by changing topology and/or geometry I have saved with what
is currently active.

RETURNED VALUES

EMS_S_Success is all is well.

HISTORY

  11/10/1992   : AMD :   Creation

*/

#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "emsdef.h" /* DPR_DISPLAY_BUFF_INCR */
#include "EMSopt.h"
#include "EMSlmdef.h"

#define BUFF_INCR DPR_DISPLAY_BUFF_INCR

from EMSloop import EMtreemod,EMgivenestinfo,EMactivate_loop;
from EMSsubbs import EMpartolbasis, EMpassloop;
from EMSboundary import EMget_objid, EMcheck_props;
from EMSloopset import EMnesting,EMtreemod;
from EMSloop import EMset_props;
from EMSedge import EMconnect_edges;



method EMactivate ( IGRlong *EMmsg;
                    IGRshort *option;
                    struct GRmd_env *env;
                    GRobjid **display_ids; 
                    IGRint *display_count)

{
  IGRlong                   sts;
  IGRint                    i,num_cap_edges;
  OMuint                    count;
  union EMSssi_table        *ssi;
  struct EMScapssi_table    *my_info;
  OM_S_CHANSELECT           to_loopset, to_common_edge, to_comps;
  IGRboolean                display;
  GRobjid                   cap;
  GRspacenum                dumosnum;

  /* Initialize */

  *EMmsg = EMS_S_Success;
  ssi = NULL;
  display = *option & EMS_DO_DISPLAY;

  sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  

  my_info = &ssi->cap_info;

  EMmake_chanselect( GRcmpowner_to_components, &to_comps);

  sts = om$get_channel_count( objid = my_id,
                              p_chanselect = &to_comps,
                              count = &count);
  EMomerr_hndlr (sts, wrapup, "om$get_channel_count");  

  for ( i=1; i<count; i++)
  {
   sts = om$get_objid_at_index ( objid = my_id,
                                 p_chanselect = &to_comps,
                                 index = i,
                                 objidaddr = &cap,
                                 osnumaddr = &dumosnum);
   EMomerr_hndlr (sts, wrapup, "om$get_objid_at_index");  

   if (*option & EMS_DO_DISPLAY)
   {
    /* Store added surface */

    EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                          DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
    if (!(1 & *EMmsg)) goto wrapup;

    (*display_ids)[*display_count] = cap;
    (*display_count)++;
   }

   EFsetsfstate ( EMmsg, cap, OM_Gw_current_OS, EMS_O_ON);
  }

  /* Connect the cap edges */

  num_cap_edges = my_info->num_edges;

  for (i=0; i<num_cap_edges; i+=2)
  {
   sts = om$send ( msg = message EMSedge.EMconnect_edges(EMmsg,
                   NULL, TRUE, my_info->edges_connected[i], 
                   NULL_OBJID, NULL_OBJID, &env->md_env),
            targetid = my_info->edges_connected[i+1]);
   EMomerr_hndlr (sts, wrapup, "EMSedge.EMconnect_edges");  
  }   
 
 wrapup:
    if(ssi) om$dealloc(ptr = ssi);
    EMWRAPUP(*EMmsg,sts,"In EMSsfcapsf.EMactivate")
    return(sts);
}

end implementation EMSsfcapsf;
