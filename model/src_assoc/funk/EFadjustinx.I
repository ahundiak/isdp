/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
class implementation EMSdpr;

#include "emsdef.h"     
#include "EMSdpr.h"     /* EMchanstruct */
#include "EMSopt.h"

IGRlong EFadjust_inx(EMmsg, objid, osnum, option)
IGRlong           *EMmsg; 
GRobjid           objid;
OMuword           osnum;
IGRushort *option; 
/*
Description
    Fix up the next states indicies on the to_members channels.

Return values
    EMSS_S_Success if all is well.

History
    02/19/91    DLB Creation.
*/
{
  IGRlong               OM_stat=OM_S_SUCCESS;
  IGRint                num_chan=0, ii;
  struct EMchanstruct   *chan=NULL;


  *EMmsg = EMS_S_Success;
  
  /*Adjust this and next states composite to surface indices.*/
  num_chan = 0;
  chan = NULL;
  OM_stat = om$send(msg = message EMSdpr.EMgetCompIndex(EMmsg, &num_chan,
                          &chan, EMget_comp_inx_DONT_SEND_UP),
                    senderid = NULL_OBJID,
                    targetid = objid,
                    targetos = osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
  if (num_chan)
  {
    OM_S_CHANSELECT       to_owners;
    
    EMmake_chanselect(GRconnector_to_owners, &to_owners);
    OM_stat = om$send(msg = message EMSdpr.EMgetCompIndex(EMmsg, &num_chan,
                            &chan, NULL),
                      senderid = objid,
                      targetos = osnum,
                      p_chanselect = &to_owners);
    if(OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;

    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
    OM_stat = om$send(msg = message EMSdpr.EMputCompIndex(EMmsg, num_chan,
                            chan, NULL),
                      senderid = NULL_OBJID,
                      targetid = objid,
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }
  
wrapup:
  for(ii=0; ii<num_chan; ii++)
  {
    if (chan[ii].chan) om$dealloc(ptr = chan[ii].chan);
  }
  if (chan) om$dealloc(ptr = chan);

  EMWRAPUP(*EMmsg, OM_stat, "EFadjust_inx")
  return(OM_stat);
}
end implementation EMSdpr;
