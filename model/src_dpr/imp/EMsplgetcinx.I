/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
#include "emsdef.h"
#include "EMSdpr.h"
#include "EMSopt.h"
#include "OMmacros.h"

method EMgetCompIndex(IGRlong *EMmsg; 
                      IGRint *num_chan; struct EMchanstruct **chan;
                      IGRushort options)
/*
Description
    This method will get the simulated channel connections and store them in
    the chan structure.

Returned values
    EMS_S_SUCCESS if all is well.

Notes
    About parameters:
      options - EMget_comp_inx_DONT_SEND_UP - if specified, the message will 
        not recurse up the tree.
      chan and num_chan should be passed as NULL.  The sender need not worry
        about freeing any memory.

History
    04/04/91 DLB Dont get ssi if I'm null.
    09/29/89 DLB Added if !uneval check. See EMsfbgetcinx.I
    06/17/89 DLB Creation date.
*/
{
  IGRlong                       OM_stat=OM_S_SUCCESS;
  IGRint                        ii;
  union EMSssi_table            *ssi=NULL;
  struct EMSsspssi_table        *my_info=NULL;
  OM_S_CHANSELECT               to_owners;
  OMuword                       dumosnum;
  void                          EFinitchan(), EFconnectchan();


  *EMmsg = EMS_S_Success;

  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    
    my_info = &ssi->spl_info;
  
    /*For split there will always be only 1 owner and 1 surface.  This is a bit
     * confusing since the ssi table shows the number of owers as being
     * variable.  This if for future use (I think its very unlikely that this 
     * will change, though).
     */
  
    if (!*chan)
    {
      /*Need to add the comps of this state to the existing list.*/        
      if (!my_info->num_srf_owner) 
      {*EMmsg = EMS_I_NotFound; goto wrapup;}
        
      *chan = (struct EMchanstruct *) om$malloc
              (size = sizeof(struct EMchanstruct));
      if (!*chan) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
  
      *num_chan = 1;
  
      EFinitchan(EMmsg, &(*chan)[0], my_info->srf_owner_ids[0]);
    }
  }

  if (!(options & EMget_comp_inx_DONT_SEND_UP))
  {
    /*Send on up.*/
    EMmake_chanselect(GRconnector_to_owners, &to_owners);

    OM_stat = om$send(msg = message EMSdpr.EMgetCompIndex(EMmsg, num_chan,
                            chan, options),
                      p_chanselect = &to_owners);
    if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
    OM_stat = OM_S_SUCCESS;
  }

  if (my_info && !(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE))
  {
    /*Now add my surface out to the channel.*/

    for(ii=0; ii<*num_chan; ii++)
    {
      if ((*chan)[ii].id == my_info->srf_owner_ids[0]) break;
    }

    if (ii != *num_chan)
    {
      /*Got a composite match.*/
      /*Connect removed surfaces at proper owners index onto simulated
       * chan.
       */ 
      EFconnectchan(EMmsg, &(*chan)[ii], 
                    my_info->srf_ids[0], 
                    my_info->owner_indices[0]);
    }
  }

wrapup:
  if(ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "sfspl.getcinx")
  return(OM_stat);
}
end implementation EMSsfsplit;
