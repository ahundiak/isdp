/* ###################   APOGEE COMPILED   ################## */
/*
Description
   The following methods take care of changing the symbology of inactive
   surfaces in split face states.

Return Values
   MSSUCC if successful

History
   DLB 06/07/87  Creation.
*/

class implementation EMSsfsplit;

#include "EMS.h"
#include "msdef.h"

IGRlong static EFsend_for_split(EMmsg, sender_id, mesg)
 IGRlong *EMmsg;
 GRobjid sender_id;
 OM_p_MESSAGE mesg;
{
  IGRlong                OM_stat; 
  IGRint                 i;
  union EMSssi_table     *ssi;
  struct EMSsspssi_table *my_info;


  *EMmsg = MSSUCC;
  OM_stat = OM_S_SUCCESS;

  ssi = NULL;
  my_info = NULL;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    senderid = sender_id,
                    targetid = sender_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  my_info = &ssi->spl_info;

  /*Send to all surfaces out.*/
  for (i = 0; i < my_info->num_srf; i ++)
  {
    OM_stat = om$send(msg = mesg,
                      senderid = sender_id,
                      targetid = my_info->srf_ids[i]);
    if (!(1 & OM_stat)) goto wrapup;
  }    
 
  wrapup:
   if (ssi) om$dealloc(ptr = ssi);
   EMWRAPUP(*EMmsg, OM_stat, "In EFsend_for_split")
   return(OM_stat);
}

method GRchgcolor(IGRlong *msg; IGRuint *rgb_value; 
                  IGRushort *color)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  OM_stat = EFsend_for_split(msg, my_id, OPPmargs);
  if (!(1 & OM_stat & *msg)) goto wrapup;
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsflm.GRchgcolor(msg, rgb_value, color),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "In EMSsfsplit.GRchgcolor")
  return(OM_stat);
}

method GRputsymb(IGRlong *msg; struct GRsymbology *symb)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  OM_stat = EFsend_for_split(msg, my_id, OPPmargs);
  if (!(1 & OM_stat & *msg)) goto wrapup;
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsflm.GRputsymb(msg, symb),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "In EMSsfsplit.GRputsymb")
  return(OM_stat);
}

method GRchghprops(IGRlong *msg; IGRshort *action; IGRint *mask)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  OM_stat = EFsend_for_split(msg, my_id, OPPmargs);
  if (!(1 & OM_stat & *msg)) goto wrapup;
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsflm.GRchghprops(msg, action, mask),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "In EMSsfsplit.GRchghprops")
  return(OM_stat);
}

method GRchgdp(IGRlong *msg; struct IGRdisplay *dp_info)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  OM_stat = EFsend_for_split(msg, my_id, OPPmargs);
  if (!(1 & OM_stat & *msg)) goto wrapup;
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsflm.GRchgdp(msg, dp_info),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "In EMSsfsplit.GRchgdp")
  return(OM_stat);
}

method GRchglevel(IGRlong *msg; IGRshort *level)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  OM_stat = EFsend_for_split(msg, my_id, OPPmargs);
  if (!(1 & OM_stat & *msg)) goto wrapup;
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsflm.GRchglevel(msg, level),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "In EMSsfsplit.GRchglevel")
  return(OM_stat);
}

method GRchgstyle(IGRlong *msg; IGRuchar *style)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  OM_stat = EFsend_for_split(msg, my_id, OPPmargs);
  if (!(1 & OM_stat & *msg)) goto wrapup;
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsflm.GRchgstyle(msg, style),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "In EMSsfsplit.GRchgstyle")
  return(OM_stat);
}

method GRchgweight(IGRlong *msg; IGRuchar *weight)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  OM_stat = EFsend_for_split(msg, my_id, OPPmargs);
  if (!(1 & OM_stat & *msg)) goto wrapup;
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsflm.GRchgweight(msg, weight),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "In EMSsfsplit.GRchgweight")
  return(OM_stat);
}

method GRremwrng(IGRlong *msg; struct GRmd_env *md_env)
{
  IGRlong OM_stat = OM_S_SUCCESS;
  
  *msg = MSSUCC;
  OM_stat = EFsend_for_split(msg, my_id, OPPmargs);
  if (!(1 & OM_stat & *msg)) goto wrapup;
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsflm.GRremwrng(msg, md_env),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, OM_stat, "sfspl.GRremwrng")
  return(OM_stat);
}

end implementation EMSsfsplit;
