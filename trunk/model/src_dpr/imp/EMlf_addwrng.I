/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMcp.h"
#include "EMSrgmod.h"

/*
 History	
        DLB     04/03/91        Dont do my stuff if I am UNEVALUATED.
        RC      02/27/89        Creation Date
*/

IGRlong static EFsend_for_lift(EMmsg, sender_id, mesg)
 IGRlong *EMmsg;
 GRobjid sender_id;
 OM_p_MESSAGE mesg;
{
  IGRlong                  OM_stat=OM_S_SUCCESS; 
  IGRint                   ii, jj;
  struct EMSlftssi_table   *my_info;
  union  EMSssi_table      *ssi=NULL;
  GRobjid                  *sf_out;
  

  *EMmsg = MSSUCC;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    senderid = sender_id,
                    targetid = sender_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
  my_info = &(ssi->lft_info);
  
  sf_out = my_info->surface_out_ids;

  for(ii=0; ii<my_info->num_composites; ii++)
  {
    for(jj=0; jj<my_info->num_surfaces_out[ii]; jj++)
    {
      OM_stat = om$send(msg = mesg,
                        senderid = sender_id,
                        targetid = *sf_out);
      if (!(1 & OM_stat)) goto wrapup;
      sf_out++;
    }
  }

  wrapup:
   if (ssi) om$dealloc(ptr = ssi);
   EMWRAPUP(*EMmsg, OM_stat, "In EFsend_for_lift")
   return(OM_stat);
}

method GRaddwrng(IGRlong *EMmsg; struct GRmd_env *md_env)
{
  IGRlong OM_stat=OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;

  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message GRowner.GRaddwrng(EMmsg, md_env),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = EFsend_for_lift(EMmsg, my_id, OPPmargs);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "lft.addwrng")
  return (OM_stat);
}

method GRremwrng(IGRlong *EMmsg; struct GRmd_env *md_env)
{
  IGRlong OM_stat=OM_S_SUCCESS;


  *EMmsg = EMS_S_Success;

  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message GRowner.GRremwrng(EMmsg, md_env),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = EFsend_for_lift(EMmsg, my_id, OPPmargs);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "lft.remwrng")
  return (OM_stat);
}

end implementation EMSlift;
