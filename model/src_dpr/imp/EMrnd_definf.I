/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

/*
  HISTORY

	Sudha   06/23/93     Modified for BSprototype ansification
*/

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "emsinter.h"
#include "EMSprop.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlmdef.h"
#include "EMSlm.h"
#include "OMmacros.h"
#include "emssfint.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bssfkttol2.h"
#include "bssfeval.h"
#include "bsdistptpt.h"

#define NUM_SURF 3
static IGRlong EMfix_defered_info();

from EMSedge import EMendpts;
from EMSedge import EMget_sf_edges;
from EMSedge import EMptatpr;
from EMSedge import EMget_top_part_edges;
from EMSedge import EMsplityourself;
from EMSedge import EMset_props;
from EMSloop import EMset_props;
from EMSloopset import EMset_props;

method EMadd_defered_info (IGRlong 	                 *EMmsg;
                           struct GRmd_env           *my_env;
                           IGRint                    *num_def_info;
                           struct EMdef_con_info     *def_info;
                           IGRint                    *num_pair_info;
                           struct EMedge_con_info    *pair_info;
                           struct EMround_save_state *svst_info)

{
 IGRlong                   stat_OM, msg;
 IGRlong                   srf_size;
 IGRint                    i, j, k, m,
                           num_ed, num_defers,
                           total_edges, next_inx,
                           num_part_edges, buf_size,
                           eval_inx[3];
 IGRdouble                 uv_ends[12][2];
 IGRpoint                  xyz_pts[12];
 GRobjid                   pe_list[4],
                           *defer_edges,
                           *part_edges;
 struct IGRbsp_surface     **surf_geom;
 struct GRid               next_edges[2];
 struct EMSpartolbasis     partol0,
                           partol1;
 IGRboolean                is_in_list,
                           gothru;
 extern IGRboolean         EFtest_for_match();
 struct EMSsfintedpar  	   split_info, *split_info_ptr[2];

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 ex$message ( msgnumb = EMS_S_EstablishingTopology);

 if (! (*num_def_info)) return(OM_S_SUCCESS);

 surf_geom = NULL;
 num_defers = 0;
 defer_edges = NULL;
 split_info_ptr[0] = &split_info;
 split_info_ptr[1] = NULL;
 split_info.info = NULL;
 split_info.next = NULL;

 defer_edges = (GRobjid *) om$malloc (size = 2 * (*num_def_info) *
                                                sizeof (GRobjid));
 if (def_info[0].c_e1_split)
     defer_edges[num_defers++] = def_info[0].com_edge1;

 if ((def_info[0].com_edge1 != def_info[0].com_edge2) &&
     (def_info[0].c_e2_split))       
     defer_edges[num_defers++] = def_info[0].com_edge2;

 for (i=1; i<(*num_def_info); i++)
  {
   if (def_info[i].c_e1_split)
    {
     is_in_list = FALSE; 
     for (j=0; j<num_defers; j++)
      {
       if (IF_EQ_OBJID (def_info[i].com_edge1, defer_edges[j]))
        {
         is_in_list = TRUE;
         break;
        } 
      }
     if (! is_in_list)
         defer_edges[num_defers++] = def_info[i].com_edge1;
    }
   
   if (def_info[i].c_e2_split)
    {
     is_in_list = FALSE; 
     for (j=0; j<num_defers; j++)
      {
       if (IF_EQ_OBJID (def_info[i].com_edge2, defer_edges[j]))
        {
         is_in_list = TRUE;
         break;
        } 
      }
     if (! is_in_list)
         defer_edges[num_defers++] = def_info[i].com_edge2;
    }
  }

 for (i=0; i<(*num_def_info); i++)
  {
   gothru = TRUE;
   surf_geom = (struct IGRbsp_surface **) om$malloc(size = NUM_SURF *
                sizeof(IGRchar *));   

   EMerr_hndlr(! surf_geom, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   for (j=0; j<NUM_SURF; j++)
    {
     stat_OM = om$send(msg = message GRvg.GRgetsize(&msg,
                             &my_env->md_env.matrix_type,
                             my_env->md_env.matrix,
                             &srf_size),
                       senderid = NULL_OBJID,
                       targetid = def_info[i].edge_surf[j]);
             
     surf_geom[j] = (struct IGRbsp_surface *) om$malloc(size = (OMuint)
                     srf_size);
     EMerr_hndlr(! surf_geom[j], *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  
     stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg,
                             &my_env->md_env.matrix_type,
                             my_env->md_env.matrix,
                             (IGRchar *) surf_geom[j]),
                       senderid = NULL_OBJID,
                       targetid = def_info[i].edge_surf[j]);
    }

   eval_inx[0] = 4;

   stat_OM = om$send (msg = message EMSedge.EMget_sf_edges(&msg, 
                            EMS_WHL_EDGE,
                            next_edges, &num_ed),
                      senderid = NULL_OBJID,
                      targetid = def_info[i].def_edge);  
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   total_edges = 0;

   if (def_info[i].c_e1_split)
    {
     BSsfkttol2(surf_geom[1]->u_order, surf_geom[1]->v_order,
                surf_geom[1]->u_knots, surf_geom[1]->v_knots,
                surf_geom[1]->u_num_poles, surf_geom[1]->v_num_poles,
                surf_geom[1]->poles, surf_geom[1]->weights,
                &partol0.tol, &msg);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     partol0.is_valid = TRUE;
     partol0.in_world = TRUE;
     partol0.mattyp = &my_env->md_env.matrix_type;
     partol0.mat = my_env->md_env.matrix;

     split_info.edgeid = def_info[i].com_edge1;
     split_info.edgepar = def_info[i].ce1_param;
     split_info.intloc = EMScvint_middle;
     stat_OM = om$send(msg = message EMSedge.EMptatpr(&msg, 1,
                          &def_info[i].ce1_param, NULL, split_info.point),
                          targetid = def_info[i].com_edge1);
     EMerr_hndlr(!(1&msg&stat_OM), *EMmsg, EMS_E_EdgeError, wrapup);

     stat_OM = om$send(msg = message EMSedge.EMsplityourself(&msg, 
                             split_info_ptr, NULL, NULL,
                             &pe_list[0], NULL, NULL, NULL,
                             &partol0, my_env, NULL, NULL, NULL),
                       targetid = def_info[i].com_edge1);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     next_inx = 2;
     eval_inx[1] = 4;
     total_edges += 2;
    }
   else
    {
     pe_list[0] = def_info[i].com_edge1;
     next_inx = 1;
     eval_inx[1] = 2;
     total_edges += 1;
    }
   if (def_info[i].c_e2_split)
    {
     BSsfkttol2(surf_geom[2]->u_order, surf_geom[2]->v_order,
                surf_geom[2]->u_knots, surf_geom[2]->v_knots,
                surf_geom[2]->u_num_poles, surf_geom[2]->v_num_poles,
                surf_geom[2]->poles, surf_geom[2]->weights,
                &partol1.tol, &msg);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     partol1.is_valid = TRUE;
     partol1.in_world = TRUE;
     partol1.mattyp = &my_env->md_env.matrix_type;
     partol1.mat = my_env->md_env.matrix;

     split_info.edgeid = def_info[i].com_edge2;
     split_info.edgepar = def_info[i].ce2_param;
     split_info.intloc = EMScvint_middle;
     stat_OM = om$send(msg = message EMSedge.EMptatpr(&msg, 1,
                          &def_info[i].ce2_param, NULL, split_info.point),
                          targetid = def_info[i].com_edge2);
     EMerr_hndlr(!(1&msg&stat_OM), *EMmsg, EMS_E_EdgeError, wrapup);

     stat_OM = om$send(msg = message EMSedge.EMsplityourself(&msg, 
                             split_info_ptr, NULL, NULL,
                             &pe_list[next_inx], NULL, NULL,
                             NULL, &partol1, my_env, NULL, NULL, NULL),
                       targetid = def_info[i].com_edge2);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     eval_inx[2] = 4;
     total_edges += 2;
    }
   else
    {
     pe_list[next_inx] = def_info[i].com_edge2;
     eval_inx[2] = 2;
     total_edges += 1;
    }

   for (j=0; j<4; j+=2)
    {
     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                             &uv_ends[j][0],
                             &uv_ends[j+1][0],
                             NULL,NULL,NULL),
                       senderid = NULL_OBJID,
                       targetid = next_edges[j/2].objid);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
    }

   for (j=0; j<(2*total_edges); j+=2)
    {
     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                             &uv_ends[j+4][0],
                             &uv_ends[j+5][0],
                             NULL,NULL,NULL),
                       senderid = NULL_OBJID,
                       targetid = pe_list[j/2]);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
    }

   m = 0;
   for (j=0; j<NUM_SURF; j++)
    {
     for (k=0; k<eval_inx[j]; k++)
      {
       BSsfeval(surf_geom[j], uv_ends[m][0], uv_ends[m][1], 0, (IGRpoint *)xyz_pts[m],
                &msg);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
       m++;
      }
    }

   for (j=0; j<4; j+=2)
    {
     for (k=4; k<m; k+=2)
      {
       if(EFtest_for_match(xyz_pts[j], xyz_pts[j+1], xyz_pts[k],
                           xyz_pts[k+1]))
        {
         pair_info[*num_pair_info].edge = next_edges[j/2].objid;
         pair_info[*num_pair_info].edge_surf = def_info[i].edge_surf[0];
         pair_info[*num_pair_info].comm_edge = pe_list[(k-4)/2];
         pair_info[*num_pair_info].align_normal = FALSE;
         if ((k == 4) || ((k == 6) && (eval_inx[1] == 4)))
            pair_info[*num_pair_info].comm_edge_surf =
                                               def_info[i].edge_surf[1];
         else
            pair_info[*num_pair_info].comm_edge_surf =
                                               def_info[i].edge_surf[2];

         if (def_info[i].c_e1_split)
          {
           if ((k == 4) || (k == 6))
            {

             stat_OM = EMfix_defered_info(&msg, def_info[i].com_edge1,
                    (pair_info[*num_pair_info].comm_edge == pe_list[0]) ?
                    pe_list[1] : pe_list[0],
                    pair_info[*num_pair_info].comm_edge_surf,
                    num_def_info,
                    def_info);
             EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,
                          wrapup);
            }
          }

         if ((def_info[i].c_e2_split) && (gothru))
          {
           if (! def_info[i].c_e1_split)
            {

             stat_OM = EMfix_defered_info(&msg, def_info[i].com_edge2,
                     (pair_info[*num_pair_info].comm_edge == pe_list[1]) ?
                     pe_list[2] : pe_list[1],
                     pair_info[*num_pair_info].comm_edge_surf,
                     num_def_info,
                     def_info);
             EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,
                          wrapup);
            }
           else
            {

             stat_OM = EMfix_defered_info(&msg, def_info[i].com_edge2,
                     (pair_info[*num_pair_info].comm_edge == pe_list[2]) ?
                     pe_list[3] : pe_list[2],
                     pair_info[*num_pair_info].comm_edge_surf,
                     num_def_info,
                     def_info);
             EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,
                          wrapup);
            }
           gothru = FALSE;
          }

         (*num_pair_info)++;
        }
      }
    }
   
   for (j=0; j<NUM_SURF; j++)
    {
     if (surf_geom[j]) om$dealloc(ptr = surf_geom[j]);
     surf_geom[j] = NULL;
    }

   if (surf_geom) om$dealloc(ptr = surf_geom);
  }
 

 wrapup:

 if(num_defers)
  {
   IGRlong locnum = 0;

   svst_info->edge_out_ids = (GRobjid *) om$malloc(size =
                                         num_defers * sizeof (GRobjid));
   svst_info->num_edges_in = (IGRint *) om$malloc(size =
                                          num_defers * sizeof (IGRint));
   svst_info->edge_in_ids = (GRobjid **) om$malloc(size =
                                       num_defers * sizeof (GRobjid *));

   locnum = num_defers;
   num_defers = 0;
   for (i=0; i<locnum; i++)
    {
     IGRlong locsts, locmsg;

     part_edges = NULL;
     num_part_edges = buf_size = 0;

     locsts = om$send (msg = message EMSedge.EMget_top_part_edges(&locmsg,
                            &part_edges, &num_part_edges, &buf_size),
                      targetid = defer_edges[i]);
     if(!(1&locsts&locmsg)) continue;
     if(!num_part_edges) continue;
     if( (num_part_edges == 1) && (IF_EQ_OBJID(part_edges[0], defer_edges[i])))
      continue;

     svst_info->edge_out_ids[num_defers] = defer_edges[i];
     svst_info->num_edges_in[num_defers] = num_part_edges;
     svst_info->edge_in_ids[num_defers++] = part_edges;
    }
  }

 svst_info->num_edges_out = num_defers;

  if (defer_edges) om$dealloc (ptr = defer_edges);
  EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMadd_defered_info");
  return (stat_OM); 
}

IGRboolean EFtest_for_match(beg1, end1, beg2, end2)
 
IGRpoint beg1, end1;
IGRpoint beg2, end2;
 {
  IGRlong msg;
  IGRdouble cht_toler;
  IGRdouble bas_toler;

  BSEXTRACTPAR(&msg, BSTOLCHRDHT, cht_toler);
  BSEXTRACTPAR(&msg, BSTOLLENVEC, bas_toler);
  cht_toler += bas_toler;

  if ((BSdistptpt(&msg, beg1, end1) <= cht_toler) || 
      (BSdistptpt(&msg, beg2, end2) <= cht_toler))
       cht_toler = bas_toler;

  if (((BSdistptpt(&msg, beg1, end2) <= cht_toler) &&
      (BSdistptpt(&msg, end1, beg2) <= cht_toler)) ||
      ((BSdistptpt(&msg, beg1, beg2) <= cht_toler) &&
      (BSdistptpt(&msg, end1, end2) <= cht_toler)))
      return (TRUE);
  else
      return (FALSE);
 }

static IGRlong EMfix_defered_info(EMmsg, old_edge, new_edge, srf_id, 
                                  num_def_info, def_info)

IGRlong                *EMmsg; 
GRobjid                old_edge,
                       new_edge,
                       srf_id;
IGRint                 *num_def_info;
struct EMdef_con_info  *def_info;

{
 IGRlong            stat_OM, msg;
 IGRint             i;
 OM_S_CHANSELECT    to_owner,
                    to_loopset;

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);

 stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
 if (! (1 & stat_OM)) goto wrapup;

 for(i=0; i<(*num_def_info); i++)
  {
   if (IF_EQ_OBJID (def_info[i].com_edge1, old_edge))
       def_info[i].com_edge1 = new_edge;
   if (IF_EQ_OBJID (def_info[i].com_edge2, old_edge))
       def_info[i].com_edge2 = new_edge;
  } 

 stat_OM = EMsend_loops(&msg,
                        message EMSloop.EMset_props (&msg,
                        EMLP_NATURAL, EMS_O_OFF), new_edge, 0,
                        OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

 stat_OM = om$send (msg = message EMSloopset.EMset_props (&msg,
                          EMLS_NATURAL, EMS_O_OFF),
                    senderid = srf_id,
                    p_chanselect = &to_loopset);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopsetError, wrapup);

/*******************************************
 stat_OM = om$send (msg = message EMSedge.EMset_props(&msg,
                          EMED_SPLIT | EMED_BEGINSPLIT | EMED_ENDSPLIT,
                          EMS_O_OFF),
                    senderid = old_edge,
                    p_chanselect = &to_owner);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 stat_OM = om$send (msg = message EMSedge.EMset_props(&msg, EMED_SPLIT,
                          EMS_O_OFF),
                    senderid = NULL_OBJID,
                    targetid = old_edge);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
******************************************/

 wrapup:
  
  EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMfix_defered_info");
  return(stat_OM);
}

end implementation EMSsfround;
