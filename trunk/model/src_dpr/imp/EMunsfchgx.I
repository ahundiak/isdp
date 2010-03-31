/*
Description
   The following methods take care of changing the symbology of inactive
   surfaces in unite surfaces state.

Return Values
   MSSUCC if successful

HISTORY

   AMD    :  07/14/92  : Creation 
*/

class implementation EMSsfunitesf;

#include "EMS.h"
#include "msdef.h"

IGRlong static EFsend_for_unitesf(EMmsg, sender_id, mesg)
 IGRlong *EMmsg;
 GRobjid sender_id;
 OM_p_MESSAGE mesg;
{
  IGRlong                  OM_stat; 
  IGRint                   i, j;
  union EMSssi_table       *ssi;
  struct EMSunssi_table    *my_info;
  GRobjid                  *sf_out;
  

  *EMmsg = MSSUCC;
  OM_stat = OM_S_SUCCESS;

  ssi = NULL;
  my_info = NULL;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    senderid = sender_id,
                    targetid = sender_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  my_info = &ssi->un_info;
  sf_out = my_info->surface_out_ids;
  
  for(i = 0; i < my_info->num_composites; i++)
  {
    for(j = 0; j < my_info->num_surfaces_out[i]; j++)
    {
      /*Send to all surfaces out.*/
      OM_stat = om$send(msg = mesg,
                        senderid = sender_id,
                        targetid = *sf_out);
      if (!(1 & OM_stat)) goto wrapup;
      sf_out++;
    }
  }

  wrapup:
   if (ssi) om$dealloc(ptr = ssi);
   EMWRAPUP(*EMmsg, OM_stat, "In EFsend_for_unitesf")
   return(OM_stat);
}

method GRchgcolor(IGRlong *msg; IGRuint *rgb_value; 
                  IGRushort *color)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = EFsend_for_unitesf(msg, my_id, OPPmargs);
    if (!(1 & OM_stat & *msg)) goto wrapup;
  }
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRchgcolor(msg, rgb_value,
                          color),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "In EMSsfunitesf.GRchgcolor")
  return(OM_stat);
}

method GRputsymb(IGRlong *msg; struct GRsymbology *symb)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = EFsend_for_unitesf(msg, my_id, OPPmargs);
    if (!(1 & OM_stat & *msg)) goto wrapup;
  }
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRputsymb(msg, symb),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "In EMSsfunitesf.GRputsymb")
  return(OM_stat);
}

method GRchghprops(IGRlong *msg; IGRshort *action; IGRint *mask)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = EFsend_for_unitesf(msg, my_id, OPPmargs);
    if (!(1 & OM_stat & *msg)) goto wrapup;
  }
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRchghprops(msg, action,
                          mask), 
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "In EMSsfunitesf.GRchghprops")
  return(OM_stat);
}

method GRchgdp(IGRlong *msg; struct IGRdisplay *dp_info)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = EFsend_for_unitesf(msg, my_id, OPPmargs);
    if (!(1 & OM_stat & *msg)) goto wrapup;
  }
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRchgdp(msg, dp_info),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "In EMSsfunitesf.GRchgdp")
  return(OM_stat);
}

method GRchglevel(IGRlong *msg; IGRshort *level)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = EFsend_for_unitesf(msg, my_id, OPPmargs);
    if (!(1 & OM_stat & *msg)) goto wrapup;
  }
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRchglevel(msg, level),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "In EMSsfunitesf.GRchglevel")
  return(OM_stat);
}

method GRchgstyle(IGRlong *msg; IGRuchar *style)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = EFsend_for_unitesf(msg, my_id, OPPmargs);
    if (!(1 & OM_stat & *msg)) goto wrapup;
  }
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRchgstyle(msg, style),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "In EMSsfunitesf.GRchgstyle")
  return(OM_stat);
}

method GRchgweight(IGRlong *msg; IGRuchar *weight)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = EFsend_for_unitesf(msg, my_id, OPPmargs);
    if (!(1 & OM_stat & *msg)) goto wrapup;
  }
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRchgweight(msg, weight),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "In EMSsfunitesf.GRchgweight")
  return(OM_stat);
}

method GRremwrng(IGRlong *msg; struct GRmd_env *md_env)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = EFsend_for_unitesf(msg, my_id, OPPmargs);
    if (!(1 & OM_stat & *msg)) goto wrapup;
  }
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRremwrng(msg, md_env),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "sfunitesf.GRremwrng")
  return(OM_stat);
}

end implementation EMSsfunitesf;

