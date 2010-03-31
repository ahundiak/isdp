class implementation EMSsfround;

#include "EMS.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "OMmacros.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bserr.h"
#include "bsdistptpt.h"

from EMSboundary import EMget_objid,
                        EMgetsurface_info;
from EMSedge import EMedge_config;

IGRlong EMfilter_edges (EMmsg, in_num_edges, out_num_edges, in_edge_ids,
                        out_edge_ids, in_edge_radius, dir_pnt, my_info,
                        my_env)

IGRlong                  *EMmsg;
IGRint                   in_num_edges,
                         *out_num_edges;
GRobjid                  *in_edge_ids,
                         *out_edge_ids;
IGRdouble                *in_edge_radius;
IGRpoint                 *dir_pnt;
struct EMedge_round_info *my_info;
struct GRmd_env          *my_env;

/*
      gupta 	05/02/88:	creation date
      Sudha     06/23/93        Modified for BSprototype ansification

*/

{
 IGRlong                   stat_OM, msg;
 IGRint                    i, j;
 IGRdouble                 delta, check_tol;
 IGRshort                  ed_type;
 IGRpoint                  loc_pnt;
 IGRvector                 av_normal;
 IGRboolean                is_in_list;
 GRobjid                   in_common_edge, surf_id, csurf_id;
 OM_S_CHANSELECT           to_common_edge;

/*----------------------------------------------------------------*/
 
 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 ex$message ( msgnumb = EMS_S_ProcessingFour);

 *out_num_edges = 0;

 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 if (! (1 & stat_OM)) goto wrapup;

 for (i=0; i<in_num_edges; i++)
  {
   stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                           &in_common_edge),
                     senderid = in_edge_ids[i],
                     p_chanselect = &to_common_edge);
   EMerr_hndlr(! (1&stat_OM&msg), *EMmsg,EMS_E_EdgeError,wrapup);
   is_in_list = FALSE;
   
   for (j=0; j<(*out_num_edges); j++)
    {
     if (IF_EQ_OBJID (in_edge_ids[i], out_edge_ids[j]) ||
         IF_EQ_OBJID (in_common_edge, out_edge_ids[j]))
      {
       is_in_list = TRUE;
       break;
      }
    }   
   if (! is_in_list)
    {
     stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                             (&msg, &surf_id, NULL),
                       senderid = NULL_OBJID,
                       targetid = in_edge_ids[i]);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                             (&msg, &csurf_id, NULL),
                       senderid = NULL_OBJID,
                       targetid = in_common_edge);
                       
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     check_tol = 0.02;
     stat_OM = om$send(msg = message EMSedge.EMedge_config (&msg, my_env,
                             loc_pnt, surf_id, csurf_id, av_normal, NULL,
                             check_tol, &ed_type),
                       senderid = NULL_OBJID,
                       targetid = in_edge_ids[i]);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     if ((ed_type == EMS_CONVEX_EDGE) || (ed_type == EMS_CONCAVE_EDGE))
      {
       if (ed_type == EMS_CONVEX_EDGE)
        {
         for (j=0; j<3; j++)
              dir_pnt[(*out_num_edges)][j] = av_normal[j] + loc_pnt[j];
        }
       else
       if (ed_type == EMS_CONCAVE_EDGE)
        {
         for (j=0; j<3; j++)
              dir_pnt[(*out_num_edges)][j] = loc_pnt[j] - av_normal[j];
        }

       if (in_edge_radius[i] <= 1.0)
        {
         delta = BSdistptpt(&msg, dir_pnt[(*out_num_edges)], loc_pnt);

         for (j=0; j<3; j++)
             dir_pnt[(*out_num_edges)][j] =
                     (in_edge_radius[i]*dir_pnt[(*out_num_edges)][j] +
                     (delta-in_edge_radius[i])*loc_pnt[j])/delta;
        }
       
       my_info[(*out_num_edges)].surface_id = surf_id;
       my_info[(*out_num_edges)].comm_surface_id = csurf_id;
       my_info[(*out_num_edges)].edge_type = ed_type;
       my_info[(*out_num_edges)].radius = in_edge_radius[i];
       out_edge_ids[(*out_num_edges)] = in_edge_ids[i];
       (*out_num_edges)++;
      }
    }
  }

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMfilter_edges");

 return(stat_OM);
}

end implementation EMSsfround;
