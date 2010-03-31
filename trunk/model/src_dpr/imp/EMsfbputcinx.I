/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#define DEBUG 0

#include "EMS.h"
#include "EMSdpr.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "OMmacros.h"

#if DEBUG
#include "stdio.h"
#endif

extern OMuword OPP_EMSsolid_class_id;

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
    05/14/89 DLB Creation date.
*/
{
  IGRlong                       OM_stat;
  IGRint                        ii, jj, kk, *comp_index, *curr_inx, curr_chan,
                                total_sf_out;
  enum EMSbooltype              exact_type;
  GRobjid                       *sf_out, *curr_sf;
  union EMSssi_table            *ssi=NULL;
  struct EMSboolssi_table       *my_info;
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
    
    my_info = &ssi->bool_info;
  
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
/*
  Before bug fix:
              EFdisconnectchan(EMmsg, chan, kk);

  The indices of the surfaces when they were put back in the
  context of recompute were being messed up.
  
  pp 09/29/92 
*/
  
              /*Now disconnect the surface from the pseudo channel.*/
              EFdisconnectchan(EMmsg, &chan[curr_chan], kk);
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
        fprintf(stderr,"Boolean node %d has comp index modified.\n", my_id);
#     endif    
  
      /*Compute the starting index for the indices in the in_out array.*/
      ii = my_info->num_composites + my_info->num_surfaces * 2;
  
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
    if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

wrapup:
  if(ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "sfb.putcinx")
  return(OM_stat);
}
end implementation EMSsfboolean;
