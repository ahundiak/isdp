/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMSmsgdef.h"
#include "EMSdpr.h"
#include "emsdef.h"
#include "msdef.h"
#if DEBUG
#include "stdio.h"
#endif

method EMcleanupComputeInfo(IGRlong *EMmsg; 
                            IGRushort options; 
                            struct GRmd_env *env; 
                            IGRint num_compute_info; 
                            struct EMScompute_info *compute_info)
/*
Description
    This method will free the fields of the EMScompute_info structure and
    perform a save state delete on the ssi structures (if specified via the
    options).  This is the default method to use IF AND ONLY IF the ssi
    structure was malloc'd in one chunk.  Otherwise, this message should
    be overridden where appropriate.

Return Values
    EMSS_S_Success if all is well

Notes
    About parameters:
        options - EMScleanup_compute_info_FREE_ONLY - don't perform a
                  savestate delete but still free the fields of the 
                  compute_info structure.  This option WILL be specified if
                  the evaluate failed and the old SSI was put back into the
                  model.
                  EMScleanup_compute_info_DONT_SEND_DOWN - don't recurse down
                  the to_comps channel.
                   
    This is the default method to use IF AND ONLY IF the ssi structure was
    malloc'd in one chunk.  Otherwise, this message should be overridden where
    appropriate. 

History
   DLB 11/06/91  Dont send EMsavestatedelete if compute_info[ii].ssi is NULL.
                 In this case, the savestate information has already bee
                 deleted.
   DLB 11/04/90  Added GRdelete of added_geom to support added surfs by local 
                 mods.
   DLB 11/16/89  Removed EMrecompinfodelete send.  This is a temporary
                 solution until it is decided if these will be any information
                 in the RI that needs to be cleaned up.
   DLB 10/14/89  Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            ii;
  IGRushort tmp_options;
  IGRboolean        did_recompute = FALSE;


  *EMmsg = EMS_S_Success;

  /*Am I a recomputed node?*/
  for(ii=0; ii<num_compute_info; ii++)
  {
    if (compute_info[ii].computed_id == my_id)
    {
      did_recompute = TRUE;
      break;
    }
  }

  if (did_recompute)
  {
    if (!(options & EMcleanup_compute_info_FREE_ONLY))
    {
      if(compute_info[ii].ssi)
      {
#       if DEBUG
          fprintf(stderr,"About to delete ssi field of compute_info!\n");
#       endif      

        /*Temporarily set the ACTIVE PATH bit off*/
        ME.EMSdpr->dpr_props &= ~EMSIS_ACTIVE_PATH; 
        OM_stat = om$send(msg = message EMSdpr.EMsavestatedelete(EMmsg, 
                                env, compute_info[ii].ssi),
                          targetid = my_id);
        ME.EMSdpr->dpr_props |= EMSIS_ACTIVE_PATH;
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;                        
      }

      /*Delete my recompute info stuff*/
/************11/16/89 DLB***********************************
      ME.EMSdpr->dpr_props &= ~EMSIS_ACTIVE_PATH;       
      OM_stat = om$send(msg = message EMSdpr.EMrecompinfodelete(EMmsg, env,
                              NULL, compute_info[ii].ri), 
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;  
***********************************************************/

      {
        /*Delete any added surfs. DLB 11/04/90*/
        IGRint jj;

        for(jj=0; jj<compute_info[ii].added_geom.num_added; jj++)
        {
          OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                         targetid = compute_info[ii].added_geom.added_ids[jj]);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;
          *EMmsg = MSSUCC;
        }                         
      }

      ME.EMSdpr->dpr_props |= EMSIS_ACTIVE_PATH;
    }

    if (compute_info[ii].ssi) om$dealloc(ptr = compute_info[ii].ssi);
    compute_info[ii].ssi = NULL;

    if (compute_info[ii].ri) om$dealloc(ptr = compute_info[ii].ri);
    compute_info[ii].ri = NULL;

    if (compute_info[ii].added_geom.added_ids) om$dealloc
                                 (ptr = compute_info[ii].added_geom.added_ids);
    compute_info[ii].added_geom.added_ids = NULL;

    if (compute_info[ii].added_geom.added_inx) om$dealloc
                                 (ptr = compute_info[ii].added_geom.added_inx);
    compute_info[ii].added_geom.added_inx = NULL;

    /*Free the con_top array*/
    OM_stat = om$send(msg = message EMSdpr.EMconnectTopology(EMmsg, 
                            &compute_info[ii].con_top,
                            EMconnect_top_FREE_ONLY),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    compute_info[ii].con_top = NULL;

    compute_info[ii].computed_id = NULL_OBJID;
  }                                                  

  if (!(options & EMcleanup_compute_info_DONT_SEND_DOWN))
  {
    OM_S_CHANSELECT to_comps;

    EMmake_chanselect(GRcmpowner_to_components, &to_comps);
    OM_stat = om$send(msg = message EMSdpr.EMcleanupComputeInfo(EMmsg,
                            options, env, 
                            num_compute_info, compute_info),
                      p_chanselect = &to_comps);
    if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
    else OM_stat = OM_S_SUCCESS;
  }                                                  

  wrapup:
   EMWRAPUP(*EMmsg, OM_stat, "EMSdpr.EMcleanupComputeInfo")
   return(OM_stat);
}
end implementation EMSdpr;
