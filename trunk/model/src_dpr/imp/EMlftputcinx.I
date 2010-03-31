/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#define DEBUG 0

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
    06/30/91 DLB Dont get ssi if NULL_STATE.
    04/01/91 DLB Ignore UNKNOWN_MSG.
    10/03/89 DLB Replaced putSSI with direct insertion of indices.
    06/19/89 DLB Creation date.
*/
{
  IGRlong                       OM_stat;
  IGRint                        ii, jj, kk, *comp_index, *curr_inx, curr_chan,
                                total_sf_out;
  GRobjid                       *sf_out, *curr_sf;
  union EMSssi_table            *ssi=NULL;
  struct EMSlftssi_table        *my_info;
  OM_S_CHANSELECT               to_owners;
  IGRboolean                    SSI_modified=FALSE;
  void                          EFdisconnectchan();  


  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
    my_info = &ssi->lft_info;

    sf_out = my_info->surface_out_ids;
    total_sf_out = 0;
    comp_index = my_info->composite_indices;

    for(ii=0; ii<my_info->num_composites; ii++)
    {
      for(jj=0; jj<num_chan; jj++)
      {
        if (chan[jj].id == my_info->composite_ids[ii]) break;
      }
  
      if (jj != num_chan)
      {
        /*Got a composite match.*/
        curr_chan = jj;
        curr_sf = sf_out;
        curr_inx = comp_index;
  
        for(jj=0;jj<my_info->num_surfaces_out[ii]; jj++, curr_sf++, curr_inx++)
        {
          /*Get the surfaces index on the psedo channel.*/
          for(kk=0; kk<chan[curr_chan].chancnt; kk++)
          {
            if (chan[curr_chan].chan[kk] == *curr_sf)
            {
              /*Put this index in owner index.*/
#             if DEBUG
                fprintf(stderr,"Match on sf %d old index %d, new index %d\n", 
                        *curr_sf, *curr_inx, kk);
#             endif              
  
              *curr_inx = kk;
              SSI_modified = TRUE;
  
              /*Now disconnect the surface from the pseudo channel.*/
              EFdisconnectchan(EMmsg, chan, kk);
              if (!(1 & *EMmsg)) goto wrapup;
              break;
            }
          }
        }
      }
      /*Increment ptrs to next composite.*/
      sf_out += my_info->num_surfaces_out[ii];
      total_sf_out += my_info->num_surfaces_out[ii];
      comp_index += my_info->num_surfaces_out[ii];
    }
  
    if (SSI_modified)
    {
#     if DEBUG
        fprintf(stderr,"Lift node %d has comp index modified.\n", my_id);
#     endif    
      
      /*Compute index into in_out array for comp_indices*/
      ii = 1 + total_sf_out;
  
      for(jj=0; jj<total_sf_out; jj++, ii++)
      {
#       if DEBUG
          fprintf(stderr,"in_out=%d, comp_index=%d\n",
                  ME.EMSsfregmod->in_out[ii], 
                  my_info->composite_indices[jj]);
#       endif
        ME.EMSsfregmod->in_out[ii] = my_info->composite_indices[jj];
      }
    }
  }

  if (!(options & EMput_comp_inx_DONT_SEND_UP))
  {
    EMmake_chanselect(GRconnector_to_owners, &to_owners);

    OM_stat = om$send(msg = message EMSdpr.EMputCompIndex(EMmsg, num_chan,
                            chan, options),
                      p_chanselect = &to_owners);
    if (OM_stat == OM_W_UNKNOWN_MSG)OM_stat = OM_S_SUCCESS;
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

wrapup:
  if(ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "EMSlift.EMputCompIndex")
  return(OM_stat);
}
end implementation EMSlift;
