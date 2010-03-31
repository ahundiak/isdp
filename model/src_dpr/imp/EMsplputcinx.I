/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
#include "EMSdpr.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "OMmacros.h"

#if DEBUG
#include "stdio.h"
#endif

method EMputCompIndex(IGRlong *EMmsg; 
                      IGRint num_chan; struct EMchanstruct *chan;
                      IGRushort options)
/*
Description
    This method will store the index in the SSI based on the oids position
    on the simulated channel.

Returned values
    EMS_S_SUCCESS if all is well.

Notes
    About parameters:
      options - EMput_comp_inx_DONT_SEND_UP - if specified this message will
        not recurse up the tree.

History
    04/01/91 DLB Ignore UNKNOWN_MSG.
    05/14/89 DLB Creation date.
*/
{
  IGRlong                       OM_stat=OM_S_SUCCESS;
  IGRint                        ii, jj, kk, *comp_index, *curr_inx, curr_chan;
  GRobjid                       *sf_out, *curr_sf;
  union EMSssi_table            *ssi=NULL;
  struct EMSsspssi_table        *my_info;
  OM_S_CHANSELECT               to_owners;
  IGRboolean                    SSI_modified=FALSE;
  void                          EFdisconnectchan();  


  *EMmsg = EMS_S_Success;

  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    
    my_info = &ssi->spl_info;
  
    for(ii=0; ii<num_chan; ii++)
    {
      if (chan[ii].id == my_info->srf_owner_ids[0]) break;
    }
  
    if (ii != num_chan)
    {
      /*Got a composite match.*/
      curr_chan = ii;
  
      /*Get the surfaces index on the psedo channel.*/
      for(ii=0; ii<chan[curr_chan].chancnt; ii++)
      {
        if (chan[curr_chan].chan[ii] == my_info->srf_ids[0])
        {
          /*Put this index in owner index.*/
#         if DEBUG
            fprintf(stderr,"Match on sf %d old index %d, new index %d\n", 
                    my_info->srf_ids[0], my_info->owner_indices[0], ii);
#         endif              
  
          my_info->owner_indices[0] = ii;
          SSI_modified = TRUE;
  
          /*Now disconnect the surface from the pseudo channel.*/
          EFdisconnectchan(EMmsg, chan, ii);
          if (!(1 & *EMmsg)) goto wrapup;
          break;
        }
      }
    }
  
    if (SSI_modified)
    {
#     if DEBUG
        fprintf(stderr,"Split face node %d has comp index modified.\n", my_id);
#     endif    
  
      ME.EMSsfsplit->owner_index = my_info->owner_indices[0];
    }
  }

  if (!(options & EMput_comp_inx_DONT_SEND_UP))
  {
    EMmake_chanselect(GRconnector_to_owners, &to_owners);

    OM_stat = om$send(msg = message EMSdpr.EMputCompIndex(EMmsg, num_chan,
                            chan, options),
                      p_chanselect = &to_owners);
    if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

wrapup:
  if(ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "EMSsfsplit.EMputCompIndex")
  return(OM_stat);
}
end implementation EMSsfsplit;
