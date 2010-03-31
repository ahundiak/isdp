/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

/*
   History

	Sudha	06/04/93	modified to add BSproto header files
*/

#include "EMS.h"
#include <stdio.h>
#include "bserr.h"
#include "bsparameters.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bssfeval.h"
#include "bssf3o4cvtn.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"
#include "bschangepar.h"


extern OMuword OPP_EMSgenbs_class_id;

from EMSsurface import EMmk_nat_bdry;
from GRvg import GRgetsize,
                 GRgetgeom;

static IGRlong EMdecide_action(EMmsg, num_concave, num_convex, my_env,
                              edge_index, my_info, edge_ids, which_end,
                              get_action, loc_pnt, other_edge, my_surf_id,
                              vtx_to_int, neutral_edge, action)
IGRlong                  *EMmsg;
IGRint                   num_concave, num_convex;
struct GRmd_env          *my_env;
IGRint                   *edge_index;
struct EMedge_round_info *my_info;
GRobjid                  *edge_ids;
IGRboolean               *which_end;
IGRboolean               get_action;
IGRpoint                 loc_pnt;
GRobjid                  *other_edge, *my_surf_id;
IGRboolean               *vtx_to_int;
IGRboolean               *neutral_edge;
IGRshort                 *action;

{
  IGRlong               stat_OM, msg;
  IGRlong               srf_size;
  IGRint                i, j, inx;
  IGRdouble             check_tol;
  IGRdouble             uvbegpt[2], uvendpt[2];
  IGRpoint              point_on_edge;
  GRobjid               comp_edges[4];
  IGRshort              other_edge_type;
  IGRvector             av_normal;
  IGRboolean            is_in_list;
  struct IGRbsp_surface *surface=NULL;
  OM_S_CHANSELECT       to_common_edge;

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *neutral_edge = FALSE;

  stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
  if (! (1 & stat_OM)) goto wrapup;

  comp_edges[0] = my_info[edge_index[0]].edge_id;
  comp_edges[1] = my_info[edge_index[1]].edge_id;

  stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                          &comp_edges[2]),
                    senderid = comp_edges[0],
                    p_chanselect = &to_common_edge);
  EMerr_hndlr(! (1&stat_OM&msg), *EMmsg,EMS_E_EdgeError,wrapup);

  stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                          &comp_edges[3]),
                    senderid = comp_edges[1],
                    p_chanselect = &to_common_edge);
  EMerr_hndlr(! (1&stat_OM&msg), *EMmsg,EMS_E_EdgeError,wrapup);

  for (i=0; i<6; i++)
   {
    is_in_list = FALSE;
    for (j=0; j<4; j++)
     {
      if (edge_ids[i] == comp_edges[j])
          is_in_list = TRUE;
     }
    if (! is_in_list)
     {
      *other_edge = edge_ids[i];
      inx = i;
      break;
     }
   }

  stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt, uvendpt,
                          NULL, NULL, NULL),
                    senderid = NULL_OBJID,
                    targetid = *other_edge);
  EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

  stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                          (&msg, my_surf_id, NULL),
                    senderid = NULL_OBJID,
                    targetid = *other_edge);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  stat_OM = om$send(msg = message GRvg.GRgetsize(
                          &msg,
                          &my_env->md_env.matrix_type, 
                          my_env->md_env.matrix, 
                          &srf_size),
                    senderid = NULL_OBJID,
                    targetid = *my_surf_id);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

  surface = (struct IGRbsp_surface *) om$malloc(size = (OMuint)srf_size);
  EMerr_hndlr(! surface, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  stat_OM = om$send(msg = message GRvg.GRgetgeom(
                          &msg,
                          &my_env->md_env.matrix_type, 
                          my_env->md_env.matrix, 
                          (IGRchar *) surface),
                    senderid = NULL_OBJID,
                    targetid = *my_surf_id);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

  BSsfeval(surface,
           (which_end[inx]) ? uvendpt[0] : uvbegpt[0],
           (which_end[inx]) ? uvendpt[1] : uvbegpt[1],
            0, (IGRpoint *)loc_pnt, &msg);
  EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  
  if (! get_action)
      goto wrapup;

  check_tol = 0.01;
  stat_OM = om$send(msg = message EMSedge.EMedge_config (&msg, my_env,
                          point_on_edge, *my_surf_id, NULL, av_normal,
                          NULL, check_tol, &other_edge_type),
                    senderid = NULL_OBJID,
                    targetid = *other_edge);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  if (((other_edge_type == EMS_CONVEX_EDGE) && (num_convex == 2)) ||
     ((other_edge_type == EMS_CONCAVE_EDGE) && (num_concave == 2)))
     *action = EMS_TRIM_VERTEX;
  else
    {
     *action = EMS_PATCH_VERTEX;
     if (other_edge_type == EMS_NEUTRAL_EDGE)
      {
       *neutral_edge = TRUE;
       *vtx_to_int = TRUE;
      }
    }

 wrapup:
   EMWRAPUP (*EMmsg, stat_OM, "EMSedge.EMdecide_action");
   if(surface)
     {
/* fix for mlk */
     om$dealloc(ptr = surface);
     surface = NULL;
     }
   return (stat_OM);
}

method EMvertex_surface (IGRlong                  *EMmsg;
                         IGRint                   *vertex_number;
                         IGRshort                 option;
                         struct GRmd_env          *my_env;
                         IGRboolean               vtx_to_int;
                         struct GRvg_construct    *construct_list;
                         struct EMedge_round_info *my_info;
                         IGRint                   *num_pair_info;
                         struct EMedge_con_info   *pair_info;
                         IGRint                   num_edges;
                         GRobjid                  *vtx_surf_id)
{
  IGRlong                 stat_OM, msg;
  IGRchar                 stat_string[80];
  IGRshort                vertex_type;
  IGRshort                action;
  IGRint                  num_vtx_edges;
  IGRint                  num_entries;
  IGRint                  *edge_index;
  IGRint                  num_rnd_edges;
  IGRint                  inx_num, *save_inx;
  IGRint                  num_concave, num_convex;
  IGRint                  i, j, k;
  IGRpoint                center_point;
  IGRdouble               cht_tol, save_cht, bas_tol;
  IGRboolean              opt, *right_vtx, small_curve;
  IGRboolean              status, neutral_edge;
  GRobjid                 *edge_ids;
  GRobjid                 vs_edges[4];
  GRobjid                 saved_objid,
                          other_saved_objid;
  GRobjid                 other_edge_id, other_surf_id;
  struct IGRbsp_surface   *vertex_surface;
  struct IGRbsp_curve     **crv_pointers;
  struct IGRbsp_curve     **curves;
  struct IGRbsp_surface   **surfaces;
  struct EMvertex_curves  *vertex_curves;

/*----------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  *vtx_surf_id = NULL_OBJID;
  num_entries = 0;
  opt = (option == 1) ? TRUE : FALSE;
  saved_objid = NULL_OBJID;;
  other_saved_objid = NULL_OBJID;
  edge_ids = NULL;
  right_vtx = NULL;
  vtx_to_int = FALSE; /* I feel this is not needed */

  if (((option) && (ME.EMSedge->ed_props & EMED_END_ROUNDED)) ||
     ((! option) && (ME.EMSedge->ed_props & EMED_BEG_ROUNDED)))
     return (stat_OM);

  vertex_curves = NULL;
  crv_pointers = NULL;
  curves = NULL;
  surfaces = NULL;
  edge_index = NULL;
  save_inx = NULL;
  num_concave = num_convex = 0;
  num_rnd_edges = 0;
  num_vtx_edges = 0;

  /* get all the edges on various surfaces which is not degenerate and
     shares my xyz vertex point -- begin or end (option) */

  stat_OM = om$send(msg = message EMSedge.EMgetvtxedges(&msg, 
			  EMSvtxedges_nodegenerate, opt, 0,
                          &num_vtx_edges, &edge_ids,
                          &right_vtx),
                    targetid = my_id);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  
  edge_index = (IGRint *) om$malloc(size = num_vtx_edges *
                                           sizeof(IGRint));

  EMerr_hndlr (! (edge_index), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  for (i=0; i<num_vtx_edges; i++)
   {
    for (j=0; j<num_edges; j++)
     {
      if (IF_EQ_OBJID (edge_ids[i], my_info[j].edge_id))
       {
        if (i != 0)
         {
          stat_OM = om$send(msg = message EMSedge.EMset_props (&msg,
                                  (right_vtx[i] ? EMED_END_ROUNDED :
                                  EMED_BEG_ROUNDED), EMS_O_ON),
                            targetid = my_info[j].edge_id);
          EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);
         }
        if (my_info[j].edge_type == EMS_CONVEX_EDGE)
            num_convex++;
        else
        if (my_info[j].edge_type == EMS_CONCAVE_EDGE)
            num_concave++;
        if (my_info[j].edge_type != EMS_NEUTRAL_EDGE)
         {
          edge_index[num_rnd_edges] = j;
          num_rnd_edges ++;
          continue;
         }
       } 
     }
   }

  if ((num_vtx_edges == 2*num_rnd_edges) && (num_vtx_edges == 4))
   {
    (*vertex_number)++;

     ex$message ( msgnumb = EMS_S_TrimmingVertexN,
                 type    = "%d",
                 var     = `i`);

    EMtrim_vertex_with_only_two_edges(&msg,
                                      my_env,
                                      num_vtx_edges,
                                      edge_ids,
                                      right_vtx,
                                      num_pair_info,
                                      pair_info,
                                      edge_index,
                                      my_info,
                                      &sender_id);
    EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
    
    goto wrapup;
   }

  if (num_vtx_edges == 2*num_rnd_edges)
   {
    (*vertex_number)++;

    ex$message ( msgnumb = EMS_S_GeneratingBlendV,
                 type    = "%d",
                 var     = `*vertex_number`);

    EMdecide_action (&msg, num_concave, num_convex, my_env, edge_index,
                     my_info, edge_ids, right_vtx, FALSE, center_point,
                    &other_edge_id, &other_surf_id, &vtx_to_int,
                    &neutral_edge, &action);
    EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);

    if (num_rnd_edges >= 3)
     {
      if (num_convex == num_rnd_edges)
          vertex_type = EMS_3CVX_VTX;
      else
      if (num_concave == num_rnd_edges)
          vertex_type = EMS_3CNV_VTX;
      else
      if ((num_convex == 2) && (num_concave == 1))
          vertex_type = EMS_1CNV_2CVX_VTX;
      else
      if ((num_convex == 1) && (num_concave == 2))
          vertex_type = EMS_1CVX_2CNV_VTX;
     }

    if (option)
     ME.EMSedge->ed_props |= EMED_END_ROUNDED;
    else
     ME.EMSedge->ed_props |= EMED_BEG_ROUNDED;
 
    inx_num = 0;

    save_inx = (IGRint *) om$malloc (size = num_rnd_edges*sizeof(IGRint));

    crv_pointers = (struct IGRbsp_curve **) om$malloc (size = 
                          num_rnd_edges * sizeof (struct IGRbsp_curve *));
    EMerr_hndlr (! save_inx || ! crv_pointers, *EMmsg,
                 EMS_E_NoDynamicMemory, wrapup);

    for (i=0; i<num_rnd_edges; i++)
     {
      for (j=0; j<num_rnd_edges; j++)
       {
        if (i != j)
         {
          if ((my_info[edge_index[i]].surface_id ==  
               my_info[edge_index[j]].surface_id) ||
               (my_info[edge_index[i]].surface_id == other_saved_objid))
           {
              my_info[edge_index[i]].other_curve =
                              my_info[edge_index[j]].curve;
              if ((num_rnd_edges == 4) && (i == 2) && (j == i+1)) break;
              if (saved_objid != NULL_OBJID)
               {
                save_inx[inx_num] = edge_index[i];
                crv_pointers[inx_num] = my_info[edge_index[i]].curve;
                inx_num++;

                my_info[edge_index[i]].curve =
                                    my_info[edge_index[i]].comm_curve;
                other_saved_objid =my_info[edge_index[i]].comm_surface_id;
                for (k=0; k<num_rnd_edges; k++)
                 {
                  if (k != i)
                   {
                    if (my_info[edge_index[i]].comm_surface_id ==  
                              my_info[edge_index[k]].surface_id)
                     {
                        my_info[edge_index[i]].other_curve =
                              my_info[edge_index[k]].curve;
                        j = num_rnd_edges-1;
                        break;
                     }
                    if (my_info[edge_index[i]].comm_surface_id ==  
                              my_info[edge_index[k]].comm_surface_id)
                     {
                        my_info[edge_index[i]].other_curve =
                              my_info[edge_index[k]].comm_curve;
                        j = num_rnd_edges-1;
                        break;
                     }
                   }
                 } 
               }
              saved_objid = my_info[edge_index[i]].surface_id; 
           }
          else
          if (my_info[edge_index[i]].surface_id ==  
                              my_info[edge_index[j]].comm_surface_id)
           {
              my_info[edge_index[i]].other_curve =
                              my_info[edge_index[j]].comm_curve;
              break;
           }
         }
       }
     }    

    vertex_curves = (struct EMvertex_curves *) om$malloc (size = 
                     num_rnd_edges * sizeof (struct EMvertex_curves));
    EMerr_hndlr (!(vertex_curves), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

    for (j=0; j<num_rnd_edges; j++)
    {
         vertex_curves[j].curve = NULL;
         vertex_curves[j].curves_surface = NULL;
    }

    EMvertex_curves_all_edges (&msg,
                               my_env,
                               construct_list, 
                               vertex_type,
                               center_point,
                               my_info,
                               num_pair_info,
                               pair_info,
                               edge_index,
                               &num_rnd_edges,
                               &sender_id,
                               vertex_curves,
                               vtx_surf_id);
    EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
    for( j=0; j < num_rnd_edges; j++ )
       if( !vertex_curves[j].curve || !vertex_curves[j].curves_surface )
       {
          *EMmsg = EMS_E_Fail;
          goto wrapup;
       }

    for (j=0; j<inx_num; j++)
     my_info[save_inx[j]].curve = crv_pointers[j];

   }
  else
  if (num_vtx_edges == 6 && num_rnd_edges == 2)
   {
    if ((num_concave == 1) && (num_convex == 1))
     {
      *EMmsg = EMS_E_InvalidCase;
      goto wrapup;
     }

    (*vertex_number)++;

    EMdecide_action (&msg, num_concave, num_convex, my_env, edge_index,
                     my_info, edge_ids, right_vtx, TRUE, center_point,
                    &other_edge_id, &other_surf_id, &vtx_to_int,
                    &neutral_edge, &action);
    EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);

    if (option)
     ME.EMSedge->ed_props |= EMED_END_ROUNDED;
    else
     ME.EMSedge->ed_props |= EMED_BEG_ROUNDED;

    if (action == EMS_TRIM_VERTEX)
     {   
      ex$message ( msgnumb = EMS_S_TrimmingVertexN,
                   type    = "%d",
                   var     = `*vertex_number`);

      EMvertex_curves_two_edges (&msg,
                                 my_env,
                                 construct_list,
                                 FALSE,
                                 center_point,
                                 my_info,
                                 num_pair_info,
                                 pair_info,
                                 edge_index,
                                 &num_rnd_edges,
                                 other_edge_id,
                                 other_surf_id,
                                 &sender_id);
      EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
     }
    else
    if (action == EMS_PATCH_VERTEX)
     {
      if (vtx_to_int)
       {
        ex$message ( msgnumb = EMS_S_TrimmingVertexN,
                     type    = "%d",
                     var     = `*vertex_number`);

        EMextend_to_intersect (&msg,
                               my_env,
                               construct_list,
                               neutral_edge,
                               my_info,
                               num_pair_info,
                               pair_info,
                               edge_index,
                               center_point,
                               other_edge_id,
                               other_surf_id,
                               &sender_id);
        EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
       }
      else
       {
        ex$message ( msgnumb = EMS_S_GeneratingBlendV,
                     type    = "%d",
                     var     = `*vertex_number`);

        vertex_curves = (struct EMvertex_curves *) om$malloc (size = 
                         num_rnd_edges * sizeof (struct EMvertex_curves));

        EMerr_hndlr (!(vertex_curves), *EMmsg, EMS_E_NoDynamicMemory,
                     wrapup);
        for( j=0; j<num_rnd_edges; j++ )
        {
           vertex_curves[j].curve  = NULL;
           vertex_curves[j].curves_surface = NULL;
        }

        status = EMdeg_swept_surface (&msg,
                                      my_env,
                                      construct_list,
                                      my_info,
                                      num_pair_info,
                                      pair_info,
                                      edge_index,
                                      center_point,
                                      other_edge_id,
                                      other_surf_id,
                                      vtx_surf_id,
                                      &sender_id);
        EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
       }
     }
   }
  else
  if (num_vtx_edges == 8 && num_rnd_edges == 2)
   {
    (*vertex_number)++;

    ex$message ( msgnumb = EMS_S_TrimmingVertexNo,
                 type    = "%d",
                 var     = `*vertex_number`);

    EMdecide_action (&msg, num_concave, num_convex, my_env, edge_index,
                     my_info, edge_ids, right_vtx, FALSE, center_point,
                    &other_edge_id, &other_surf_id, &vtx_to_int,
                    &neutral_edge, &action);
    EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);

    stat_OM = EM4ed_vertex_blend(&msg,
                                 my_env,
                                 construct_list,
                                 my_info,
                                 num_pair_info,
                                 pair_info,
                                 edge_index,
                                 center_point,
                                 num_vtx_edges,
                                 edge_ids,
                                 right_vtx,
                                 vtx_surf_id,
                                 &sender_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, msg, wrapup);

    if (*vtx_surf_id != NULL_OBJID)
     {
      if (option)
       ME.EMSedge->ed_props |= EMED_END_ROUNDED;
      else
       ME.EMSedge->ed_props |= EMED_BEG_ROUNDED;
     }
   }

  if ((vertex_curves) && (*vtx_surf_id == NULL_OBJID))
   {
    num_entries = (num_rnd_edges >= 4) ? 4 : 3;
  
    curves = (struct IGRbsp_curve **) om$malloc(size = num_entries *
                                      sizeof (struct IGRbsp_curve *));
    surfaces = (struct IGRbsp_surface **) om$malloc(size = num_entries *
                                      sizeof (struct IGRbsp_surface *));

    for (j=0; j<num_entries; j++)
     {
      if( !vertex_curves[j].curve || !vertex_curves[j].curves_surface )
      {
         *EMmsg = EMS_E_Fail;
         goto wrapup;
      }
      curves[j] = vertex_curves[j].curve;
      surfaces[j] = vertex_curves[j].curves_surface;
     }

    BSsf3o4cvtn(num_entries, curves, surfaces, &vertex_surface, &msg);

    EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    vertex_surface->pos_orient = FALSE;

    construct_list->geometry = (IGRchar *) vertex_surface;

    stat_OM = om$construct(classid = OPP_EMSgenbs_class_id,
                           p_objid = vtx_surf_id,
                           msg = message GRgraphics.GRconstruct(
                           construct_list));
    EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

    /* construct the natural boundary for the swept surface */

    stat_OM  = om$send (msg = message EMSsurface.EMmk_nat_bdry(&msg,
                              &my_env->md_env, vs_edges),
                        targetid = *vtx_surf_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError,wrapup);

    BSEXTRACTPAR(&msg, BSTOLCHRDHT, cht_tol);
    BSEXTRACTPAR(&msg, BSTOLLENVEC, bas_tol);
    small_curve = FALSE;

    for (i=0; i<num_entries; i++)
     {
      if (BSdistptpt(&msg,
                     &curves[i][0].poles[0],
            &curves[i][0].poles[(curves[i][0].num_poles-1)*3]) <= cht_tol)
       {
        save_cht = cht_tol;
        small_curve = TRUE;
        BSchangepar(&msg, BSTOLCHRDHT, bas_tol);
        break;
       }
     }

    stat_OM = EMfill_pair_info(&msg, vs_edges,vertex_surface,*vtx_surf_id,
                               num_pair_info, pair_info, vertex_curves,
                               num_rnd_edges);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

    if (small_curve)
     {
      BSchangepar(&msg, BSTOLCHRDHT, save_cht);
     }

    if (vertex_curves)
     {
      for (j=0; j<num_rnd_edges; j++)
           if (vertex_curves[j].curve) om$dealloc(ptr =
                                                  vertex_curves[j].curve);
     }
   }

   ex$message ( msgnumb = EMS_S_ClearStatusField);

wrapup:

  EMWRAPUP (*EMmsg, stat_OM,"EMSedge.EMvertex_surface");

  if (edge_index) om$dealloc (ptr = edge_index);
  if (vertex_curves) om$dealloc (ptr = vertex_curves);
  if (save_inx) om$dealloc(ptr = save_inx);
  if (crv_pointers) om$dealloc(ptr = crv_pointers);
  if (curves) om$dealloc(ptr = curves);
  if (surfaces) om$dealloc(ptr = surfaces);
  if (edge_ids) om$dealloc (ptr = edge_ids);
  if (right_vtx) om$dealloc (ptr = right_vtx);

  return (stat_OM);
}

EMfill_pair_info(EMmsg, vs_edges, vs_geom, vs_id, num_pair_info,
                 pair_info, vertex_curves, num_rnd_edges)

IGRlong                   *EMmsg;
GRobjid                   *vs_edges;
struct IGRbsp_surface     *vs_geom;
GRobjid                   vs_id;
IGRint                    *num_pair_info;
struct EMedge_con_info    *pair_info;
struct EMvertex_curves    *vertex_curves;
IGRint                    num_rnd_edges;

{
 IGRlong                  stat_OM, msg;
 IGRint                   i, j, k;
 IGRpoint                 xyz_pts[4];
 IGRpoint                 ss_poles[4];
 IGRdouble                dist_sqtol;
 IGRboolean               aligned;
 IGRlong                  EMgetsf4pols();
 extern	IGRboolean	  EFtest_for_match();

*EMmsg = EMS_S_Success;
stat_OM = OM_S_SUCCESS;

aligned = FALSE;

BSEXTRACTPAR(&msg, BSTOLSQLENVEC, dist_sqtol);

stat_OM = EMgetsf4pols (vs_geom, ss_poles);
if (! (1 & stat_OM)) goto wrapup;

for (i=0; i<4; i++)
 {
  switch (i)
   {
    case 0:
           OM_BLOCK_MOVE(ss_poles[0], xyz_pts[0], sizeof (IGRpoint));
           OM_BLOCK_MOVE(ss_poles[2], xyz_pts[1], sizeof (IGRpoint));
           break;
    case 1:
           OM_BLOCK_MOVE(ss_poles[2], xyz_pts[0], sizeof (IGRpoint));
           OM_BLOCK_MOVE(ss_poles[3], xyz_pts[1], sizeof (IGRpoint));
           break;
    case 2:
           OM_BLOCK_MOVE(ss_poles[3], xyz_pts[0], sizeof (IGRpoint));
           OM_BLOCK_MOVE(ss_poles[1], xyz_pts[1], sizeof (IGRpoint));
           break;
    case 3:
           OM_BLOCK_MOVE(ss_poles[1], xyz_pts[0], sizeof (IGRpoint));
           OM_BLOCK_MOVE(ss_poles[0], xyz_pts[1], sizeof (IGRpoint));
           break;
   }

  if (BSdistptpts(&msg, xyz_pts[0], xyz_pts[1]) < dist_sqtol)
      continue;

  for (j=0; j<num_rnd_edges; j++)
   {
    if (vertex_curves[j].curve->rational)
     {
      for (k=0; k<3; k++)
       {
        xyz_pts[2][k] = vertex_curves[j].curve->poles[k] /
                        vertex_curves[j].curve->weights[0];
        xyz_pts[3][k] = (vertex_curves[j].curve->poles[3 *
                        (vertex_curves[j].curve->num_poles-1) + k]) /
                        (vertex_curves[j].curve->weights[
                        vertex_curves[j].curve->num_poles -1]);
       }
     }
    else
     {
      for (k=0; k<3; k++)
       {
        xyz_pts[2][k] = vertex_curves[j].curve->poles[k];
        xyz_pts[3][k] = vertex_curves[j].curve->poles[3 *
                        (vertex_curves[j].curve->num_poles-1) + k];
       }
     } 
  
    if (EFtest_for_match(xyz_pts[0], xyz_pts[1], xyz_pts[2], xyz_pts[3]))
     {
      pair_info[*num_pair_info].edge = vertex_curves[j].edge_id;
      pair_info[*num_pair_info].edge_surf = vertex_curves[j].fillet_id;
      pair_info[*num_pair_info].surf_geom =
                                       vertex_curves[j].curves_surface;
      pair_info[*num_pair_info].comm_edge = vs_edges[i];
      pair_info[*num_pair_info].comm_edge_surf = vs_id;
      pair_info[*num_pair_info].comm_surf_geom = vs_geom;
                                          
      if (! aligned)
       {
        pair_info[*num_pair_info].align_normal = TRUE;
        aligned = TRUE;
       }
      else
        pair_info[*num_pair_info].align_normal = FALSE;

      (*num_pair_info)++;
      continue;
     }
   } 
 }
wrapup:

 return (stat_OM);  

}

end implementation EMSedge;
