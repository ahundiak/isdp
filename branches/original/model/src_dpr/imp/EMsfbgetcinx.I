/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

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
    09/29/89 DLB Added if !uneval check.  If uneval then the ids are on the 
                 real channel and would have been added during the chan_init.
    05/14/89 DLB Creation date.
*/
{
  IGRlong                       OM_stat=OM_S_SUCCESS;
  IGRint                        ii, jj, kk, *owner_index;
  GRobjid                       *sf_out;
  union EMSssi_table            *ssi=NULL;
  struct EMSboolssi_table       *my_info=NULL;
  OM_S_CHANSELECT               to_owners;
  OMuword                       dumosnum;
  void                          EFinitchan(), EFconnectchan();


  *EMmsg = EMS_S_Success;

  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    
    my_info = &ssi->bool_info;
  
    if (!*chan)
    {
      /*Need to add the comps of this state to the existing list.*/        
      if (!my_info->num_composites) 
      {*EMmsg = EMS_I_NotFound; goto wrapup;}
        
      *chan = (struct EMchanstruct *) om$malloc
              (size = my_info->num_composites * sizeof(struct EMchanstruct));
      if (!*chan) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
  
      *num_chan = my_info->num_composites;
  
      for(ii=0; ii<my_info->num_composites; ii++)
      {
        EFinitchan(EMmsg, &(*chan)[ii], my_info->composite_ids[ii]);
      }
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

  if (my_info && !(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE)) /*Added 9/29/89*/
  {
    /*Now add my surfaces out to the channel.*/

    /*Find the total number of surfs removed.*/
    jj = 0;
    for(ii=0; ii<my_info->num_composites; ii++)
      jj += my_info->num_surfaces_out[ii];

    /*The connect to the pseudo channel should be done in reverse order
     * that they appear on the array.
     */
    sf_out = &my_info->surface_out_ids[jj-1];
    owner_index = &my_info->composite_indices[jj-1];

    for(ii=my_info->num_composites-1; ii>=0; ii--)
    {
      for(jj=0; jj<*num_chan; jj++)
      {
        if ((*chan)[jj].id == my_info->composite_ids[ii]) break;
      }

      if (jj != *num_chan)
      {
        /*Got a composite match.*/
        for(kk=my_info->num_surfaces_out[ii]-1; kk>=0; kk--)
        {
          /*Connect removed surfaces at proper owners index onto simulated
           * chan.
           */ 
          EFconnectchan(EMmsg, &(*chan)[jj], *sf_out, *owner_index);
          owner_index--;
          sf_out--;
        }
      }
      else
      {
        sf_out -= my_info->num_surfaces_out[ii];
        owner_index -= my_info->num_surfaces_out[ii];
      }
    }
  }

wrapup:
  if(ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "sfb.getcinx")
  return(OM_stat);
}
end implementation EMSsfboolean;
