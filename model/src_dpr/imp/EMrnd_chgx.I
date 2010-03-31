/* ###################   APOGEE COMPILED   ################## */
/*
Description
   The following methods take care of changing the symbology of inactive
   surfaces in fillet with auto trimming.

Return Values
   EMS_S_Success if successful

History
   gupta 12/01/89  Creation.
*/

class implementation EMSsfround;

#include "EMS.h"
#include "msdef.h"

IGRlong static EFsend_for_auttrm(EMmsg, sender_id, mesg)
 IGRlong *EMmsg;
 GRobjid sender_id;
 OM_p_MESSAGE mesg;
{
  IGRlong                  stat_OM; 
  IGRint                   i;
  union EMSssi_table       *ssi;
  struct EMSrndssi_table  *my_info;
  

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  ssi = NULL;
  my_info = NULL;

  stat_OM = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    senderid = sender_id,
                    targetid = sender_id);
  if (!(1 & stat_OM & *EMmsg)) goto wrapup;

  my_info = &ssi->rnd_info;
  
  for(i = 0; i < my_info->num_edges_rounded; i+=3)
   {
    /*Send to all surfaces out.*/
    stat_OM = om$send(msg = mesg,
                      senderid = sender_id,
                      targetid = my_info->rounded_edge_ids[i]);
    if (!(1 & stat_OM)) goto wrapup;
   }

  wrapup:
   if (ssi) om$dealloc(ptr = ssi);
   EMWRAPUP(*EMmsg, stat_OM, "In EFsend_for_auttrm");
   return(stat_OM);
}

method GRchgcolor(IGRlong *msg; IGRuint *rgb_value; 
                  IGRushort *color)
{
  IGRlong stat_OM = OM_S_SUCCESS;
  
  *msg = EMS_S_Success;

  if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
   {
    stat_OM = EFsend_for_auttrm(msg, my_id, OPPmargs);
    if (!(1 & stat_OM & *msg)) goto wrapup;
   }

  stat_OM = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRchgcolor(msg, rgb_value,
                          color),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, stat_OM, "In EMSsfround.GRchgcolor");
  return(stat_OM);
}

method GRputsymb(IGRlong *msg; struct GRsymbology *symb)
{
  IGRlong stat_OM = OM_S_SUCCESS;
  
  *msg = EMS_S_Success;

  if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
   {
    stat_OM = EFsend_for_auttrm(msg, my_id, OPPmargs);
    if (!(1 & stat_OM & *msg)) goto wrapup;
   }

  stat_OM = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRputsymb(msg, symb),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, stat_OM, "In EMSsfround.GRputsymb");
  return(stat_OM);
}

method GRchghprops(IGRlong *msg; IGRshort *action; IGRint *mask)
{
  IGRlong stat_OM = OM_S_SUCCESS;
  
  *msg = EMS_S_Success;

  if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
   {
    stat_OM = EFsend_for_auttrm(msg, my_id, OPPmargs);
    if (!(1 & stat_OM & *msg)) goto wrapup;
   }

  stat_OM = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRchghprops(msg, action,
                          mask), 
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, stat_OM, "In EMSsfround.GRchghprops");
  return(stat_OM);
}

method GRchgdp(IGRlong *msg; struct IGRdisplay *dp_info)
{
  IGRlong stat_OM = OM_S_SUCCESS;
  
  *msg = EMS_S_Success;

  if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
   {
    stat_OM = EFsend_for_auttrm(msg, my_id, OPPmargs);
    if (!(1 & stat_OM & *msg)) goto wrapup;
   }

  stat_OM = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRchgdp(msg, dp_info),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, stat_OM, "In EMSsfround.GRchgdp");
  return(stat_OM);
}

method GRchglevel(IGRlong *msg; IGRshort *level)
{
  IGRlong stat_OM = OM_S_SUCCESS;
  
  *msg = EMS_S_Success;

  if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
   {
    stat_OM = EFsend_for_auttrm(msg, my_id, OPPmargs);
    if (!(1 & stat_OM & *msg)) goto wrapup;
   }

  stat_OM = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRchglevel(msg, level),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, stat_OM, "In EMSsfround.GRchglevel");
  return(stat_OM);
}

method GRchgstyle(IGRlong *msg; IGRuchar *style)
{
  IGRlong stat_OM = OM_S_SUCCESS;
  
  *msg = EMS_S_Success;

  if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
   {
    stat_OM = EFsend_for_auttrm(msg, my_id, OPPmargs);
    if (!(1 & stat_OM & *msg)) goto wrapup;
   }

  stat_OM = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRchgstyle(msg, style),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, stat_OM, "In EMSsfround.GRchgstyle");
  return(stat_OM);
}

method GRchgweight(IGRlong *msg; IGRuchar *weight)
{
  IGRlong stat_OM = OM_S_SUCCESS;
  
  *msg = EMS_S_Success;

  if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
   {
    stat_OM = EFsend_for_auttrm(msg, my_id, OPPmargs);
    if (!(1 & stat_OM & *msg)) goto wrapup;
   }

  stat_OM = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRchgweight(msg, weight),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, stat_OM, "In EMSsfround.GRchgweight");
  return(stat_OM);
}

method GRxform(IGRlong *msg; struct GRmd_env *obj_mdenv;
               IGRshort *matrix_type; IGRmatrix matrix;
               GRobjid *newobjid)
{
  IGRlong stat_OM = OM_S_SUCCESS;
  
  *msg = EMS_S_Success;

  if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
   {
    stat_OM = EFsend_for_auttrm(msg, my_id, OPPmargs);
    if (!(1 & stat_OM & *msg)) goto wrapup;
   }

  stat_OM = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsfregmod.GRxform(msg, obj_mdenv,
                          matrix_type, matrix, newobjid),
                    targetid = my_id);
  wrapup: EMWRAPUP(*msg, stat_OM, "In EMSsfround.GRxform");
  return(stat_OM);
}

method GRaddwrng(IGRlong *msg; struct GRmd_env *md_env)
{
  IGRlong stat_OM = OM_S_SUCCESS;
  
  *msg = EMS_S_Success;

  stat_OM = om$send(mode = OM_e_wrt_message,
                    msg = message GRowner.GRaddwrng(msg, md_env),
                    targetid = my_id);
  if (! (1 & stat_OM & *msg)) goto wrapup;

  if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
   {
    stat_OM = EFsend_for_auttrm(msg, my_id, OPPmargs);
    if (!(1 & stat_OM & *msg)) goto wrapup;
   }

  wrapup: EMWRAPUP(*msg, stat_OM, "In EMSsfround.GRaddwrng");
  return(stat_OM);
}

method GRremwrng (IGRlong *msg; struct GRmd_env *md_env)
{
  IGRlong stat_OM = OM_S_SUCCESS;
  
  *msg = EMS_S_Success;

  stat_OM = om$send(mode = OM_e_wrt_message,
                    msg = message GRowner.GRremwrng(msg, md_env),
                    targetid = my_id);
  if (! (1 & stat_OM & *msg)) goto wrapup;

  if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
  {
    stat_OM = EFsend_for_auttrm(msg, my_id, OPPmargs);
    if (!(1 & stat_OM & *msg)) goto wrapup;
  }

  wrapup: EMWRAPUP(*msg, stat_OM, "sfrnd.GRaddwrng");
  return(stat_OM);
}

end implementation EMSsfround;

