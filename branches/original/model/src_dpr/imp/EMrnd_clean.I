/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSerrordef.h"

extern OMuword OPP_EMSsubbs_class_id;

from EMSsubbs import EMget_edges;

method EMround_cleanup (IGRlong               *EMmsg;
                        struct GRmd_env       *my_env;
                        IGRint                *num_surf_ids;
                        struct GRid           *surf_ids)

/*
History
    DLB     04/26/91    If EMS_UNEVAL_STATE then don't delete me.
    gupta   09/21/88:   creation
*/

{
 IGRlong                   stat_OM, msg;
 IGRint                    i, j;
 IGRint                    num_surfs, num_edges;
 IGRint                    buf_size;
 struct GRid               *edge_ids;
 struct GRid               temp_id;
 OM_S_CHANSELECT           to_comps;
 OM_S_CHANSELECT           to_common_edge;

/*----------------------------------------------------------------*/
 
 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;
 
 temp_id.objid = my_id;
 temp_id.osnum = OM_Gw_current_OS;

 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 if (! surf_ids)
  {
   stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);

   EFgetobjids (&msg, &temp_id, &to_comps, &surf_ids, &num_surfs, 
                OPP_EMSsubbs_class_id, NULL, 0);
   EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
  }
 else
  num_surfs = *num_surf_ids;

 for (i=0; i<num_surfs; i++)
  {
   num_edges = 0;
   buf_size = 0;
   edge_ids = NULL;

   stat_OM = om$send(msg = message EMSsubbs.EMget_edges(&msg,
                           MAXINT, EMS_OPT_NON_DEG_STITCHED, my_env,
                           &edge_ids, &buf_size, &num_edges),
                     targetid = surf_ids[i].objid,
                     targetos = surf_ids[i].osnum);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

   for (j=0; j<num_edges; j++)
    {
     stat_OM = om$send(msg = message Root.wild_disconnect(to_common_edge),
                       targetid = edge_ids[j].objid);
     EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_Fail, wrapup);
    }

   if (edge_ids) om$dealloc(ptr = edge_ids);
  }

 for (i=0; i<num_surfs; i++)
  {
   stat_OM = om$send (msg = message GRconnector.GRdisconn (&msg,
                            &temp_id),
                      targetid = surf_ids[i].objid,
                      targetos = surf_ids[i].osnum);
   EMerr_hndlr(! (1 & stat_OM), *EMmsg, msg, wrapup);
  }

 if (!(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE)) /*DLB 04/26/91*/
 {
   stat_OM = om$send(mode = OM_e_wrt_message,
                     msg = message Root.delete(1),
                     targetid = my_id);
   EMerr_hndlr(! (1 & stat_OM), *EMmsg, msg, wrapup);
 }

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMround_cleanup");

 if (surf_ids) 
  {
   om$dealloc(ptr = surf_ids); 
   surf_ids = NULL;
  }

 return(stat_OM);
}

end implementation EMSsfround;
