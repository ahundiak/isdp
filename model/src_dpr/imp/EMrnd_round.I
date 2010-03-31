/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "ems_m_inc.h"
#include "EMSlm.h"
#include "EMSopt.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "griomacros.h" /* co$getevent */
#include "emsedgedef.h"
#include "bsparameters.h"
#include "bserr.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bscvarrevc.h"
#include "bschangepar.h"

#define INCR_SIZE 50
#define EdDiscon  8

extern OMuword OPP_EMSsubbs_class_id;

from EMSedge import EMconnect_edges,
                    EMvertex_surface,
                    EMget_props,
                    EMset_props,
                    EMget_props_type,
                    EMtst_degn,
                    EMget_bcxyz_geom;

from EMSboundary import EMget_objid;
from EMSsubbs import EMfillet_surface;

method EMround (IGRlong               *EMmsg;
                struct GRmd_env       *my_env;
                struct GRvg_construct *construct_list;
                IGRushort     operation_type;
                IGRboolean            vtx_to_int;
                IGRint                *in_num_edges;
                GRobjid               *in_edge_ids;
                IGRdouble             *in_edge_radius;
                IGRushort     dis_options;
                GRobjid               **display_ids;
                IGRint                *display_count)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
                - EMS_E_Fail (severe) if failure

Assumption

Bugs
    Are you kidding?  This whole file is one huge bug!                

History
Sudha   06/23/93  Modified for BSprototype ansification
SM    : 04/08/92: Cleanup all generated surfaces as part of recovery.
SM    : 03/31/92: Record the old common edge connections which get disconnected
		  in this method and restore them as part of recovery upon
		  failure.

DLB   : 7/3/91 : If round fails return EMS_I_Fail.
DLB   : May 24,91 : Do rigid conn to MAX_INT to support recompute and topology
                    matching.
Inasu : Mar 01,91 : The EMdecide_grexit has been commented and exit_gracefully
		is set to TRUE if the rounding fails. That is, if the rouding
		failed, the user will NOT be prompted for Continue/Recover, 
	        instead	the model is recovered (TR 91n0674).
Inasu : Feb 19,91 : Added check for validity of the rounding radius && prompt
		the user for continuation.

Tapadia 	11th Jan. 91 - Added some NoMemory checks after some mallocs.
22 May 1989 jBk Replaced occurrences of GRm_STRING with
                GRm_TEXT_VALUE.

                Replaced invocations of GRgetevent with uses of
                co$getevent.

      gupta     11/30/87:   design date

Algorithm

*/

{
 IGRlong                   stat_OM, stat_OM1, msg, msg1;
 IGRushort         	   ed_props;
 unsigned short            props_0, props_1;
 extern IGRboolean         IGEstop();
 IGRboolean                interrupt= FALSE, bad_svst_info=FALSE;
 IGRboolean                toggle_normal;
 IGRboolean                response_taken;
 IGRboolean                exit_gracefully;
 IGRboolean 		   valid_flag=TRUE;
 IGRshort                  option, dis_option;
 IGRint                    i, j, k;
 OMuint                    ls_count, c_e_count; /*, owner_index;-DLB*/
 IGRint                    num_surf_ids, arr_size;
 IGRint                    num_edges;
 IGRint                    num_def_info;
 IGRint                    num_pair_info;
 IGRint                    vertex_number;
 IGRint                    EMsend_loops();
 GRobjid                   *edge_ids, loop_id;
 GRobjid                   vtx_surf_id, com_edge;
 enum GRdpmode             display_mode = GRbd;
 IGRpoint                  *dir_point;
 struct EMedge_round_info  *my_info;
 struct EMdef_con_info     *def_info;
 struct GRid               temp_id, *surf_ids;
 struct EMedge_con_info    *pair_info;
 struct EMround_save_state svst_info;
 OM_S_CHANSELECT           to_comps;
 OM_S_CHANSELECT           to_common_edge;
 IGRlong                   max_int;
 GRobjid		   *eddiscon = NULL, *gensf = NULL;
 IGRint			   numeddiscon = 0, disconbufsize = 0, 
			   numgensf = 0;
 IGRushort	   *eddiscon_props = NULL;
 IGRlong		   locsts, locmsg;

/*----------------------------------------------------------------*/
 
 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;
 
 max_int = OM_K_MAXINT;
 k = 0;
 arr_size = 100;
 temp_id.objid = my_id;
 temp_id.osnum = OM_Gw_current_OS;
 my_info = NULL;
 pair_info = NULL;
 def_info = NULL;
 surf_ids = NULL; 
 edge_ids = NULL;
 dir_point = NULL;
 response_taken = FALSE;
 exit_gracefully = TRUE;
 vertex_number = 0;

 svst_info.num_surfaces = 0;
 svst_info.num_edges_out = 0;
 svst_info.num_edges_in = NULL;
 svst_info.edge_in_ids = NULL;
 svst_info.edge_out_ids = NULL;
 svst_info.rounded_edge_ids = NULL;
 svst_info.surface_ids = NULL;
 svst_info.num_regions_in = NULL;
 svst_info.num_regions_out = NULL;
 svst_info.region_in_ids = NULL;
 svst_info.region_out_ids = NULL;
 svst_info.num_edges_rounded = 0;
 
 stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);

 my_info = (struct EMedge_round_info *) om$malloc (size = 
                    (*in_num_edges) * sizeof(struct EMedge_round_info)); 

 for (i=0; i<(*in_num_edges); i++)
  {
   my_info[i].curve = NULL;
   my_info[i].comm_curve = NULL;
   my_info[i].surface = NULL;
   my_info[i].fillet_surface = NULL;
  }

 def_info = (struct EMdef_con_info *) om$malloc (size = 2 *  
                    (*in_num_edges) * sizeof(struct EMdef_con_info)); 
 pair_info = (struct EMedge_con_info *) om$malloc (size =   
                    arr_size * sizeof(struct EMedge_con_info)); 
 EMerr_hndlr(!my_info || !def_info || !pair_info,*EMmsg,
		EMS_E_NoDynamicMemory,wrapup);

 edge_ids = (GRobjid *) om$malloc (size = (*in_num_edges) *
                                                    sizeof(GRobjid)); 
 dir_point = (IGRpoint *) om$malloc (size = (*in_num_edges) *
                                                  sizeof(IGRpoint)); 
 EMerr_hndlr(!edge_ids || !dir_point,*EMmsg,EMS_E_NoDynamicMemory,
		wrapup);
 num_def_info = 0;
 num_pair_info = 0;

 EMfilter_edges (&msg, *in_num_edges, &num_edges, in_edge_ids, edge_ids,
                 in_edge_radius, dir_point, my_info, my_env);
 EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

 if (! num_edges)
  {
   msg = *EMmsg = EMS_I_RndGrExit;
   goto wrapup;
  }

 svst_info.num_edges_rounded = num_edges;

 svst_info.rounded_edge_ids = (GRobjid *) om$malloc(size =
                                          num_edges * sizeof (GRobjid));
 EMerr_hndlr(!svst_info.rounded_edge_ids,*EMmsg,EMS_E_NoDynamicMemory,
		wrapup);
  
 for (i=0; i<num_edges; i++)
      svst_info.rounded_edge_ids[i] = edge_ids[i];

 valid_flag = TRUE;

 gensf = (GRobjid *) om$malloc(size = num_edges * 3 * sizeof(GRobjid));
 EMerr_hndlr(!gensf, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
 numgensf = 0;

 for (i=0; i<num_edges; i++)
  {
   IGRboolean EF_is_round_rad_valid();

   my_info[i].edge_id = edge_ids[i];

   /* Check whether the rounding radius is valid */

  if( valid_flag )
   valid_flag=EF_is_round_rad_valid( &msg, my_env,edge_ids[i],my_info->radius);

   my_info[i].fillet_id = NULL_OBJID;
   stat_OM = om$send(msg = message EMSsubbs.EMfillet_surface (&msg,
                           my_env,
                           &i,
                           &my_id,
                           dir_point[i],
                           construct_list,
                           operation_type,
                           &my_info[i],
                           &num_def_info,
                           def_info,
                           &num_pair_info,
                           pair_info,
                           num_edges,
                           edge_ids,
                           &my_info[i].fillet_id),
                     targetid = my_info[i].surface_id);

   if(!IF_NULL_OBJID(my_info[i].fillet_id))
    gensf[numgensf++] = my_info[i].fillet_id;

   if (! (1 & stat_OM & msg))
   {
     *EMmsg = EMS_E_SurfaceError;
     bad_svst_info = TRUE;
     goto wrapup;
   }

   /* connect the fillet_surface to the Round dpr */
/*******************DLB 8/13/91***************
   stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg,
                            &temp_id, &max_int),
                      targetid = my_info[i].fillet_id,
                      targetos = OM_Gw_current_OS);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
********************************************/

   if ((interrupt = IGEstop()))
    {
     *EMmsg = EMS_I_Interrupt; return (OM_S_SUCCESS);
    }

   if (num_pair_info >= arr_size)
    {
     pair_info = (struct EMedge_con_info *) om$realloc
                 (ptr = (IGRchar *)pair_info,
                  size = (arr_size + INCR_SIZE) * 
                  sizeof(struct EMedge_con_info));
     EMerr_hndlr(!pair_info,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
   
     arr_size += INCR_SIZE;
    }
  }

 if (num_edges > 1)
  {  
   for (i=0; i<num_edges; i++)
    {
     if (num_pair_info >= arr_size-20)
      {
       pair_info = (struct EMedge_con_info *) om$realloc
                   (ptr = (IGRchar *) pair_info,
                    size = (arr_size + INCR_SIZE) * 
                    sizeof(struct EMedge_con_info));
       EMerr_hndlr(!pair_info,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
   
       arr_size += INCR_SIZE;
      }
     option = 0;
     for (j=0; j<2; j++)
      {
       vtx_surf_id = NULL_OBJID;
       stat_OM = om$send (msg = message EMSedge.EMvertex_surface (&msg,
                                &vertex_number,
                                option,
                                my_env,
                                vtx_to_int,
                                construct_list,
                                my_info,
                                &num_pair_info,
                                pair_info,                                
                                num_edges,
                                &vtx_surf_id),
                          targetid = edge_ids[i]);
       if(!IF_NULL_OBJID(vtx_surf_id))
        gensf[numgensf++] = vtx_surf_id;

       if (msg == EMS_E_RndGrExit)
        {
         msg = *EMmsg = EMS_I_RndGrExit;
         goto wrapup;
        }

       EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg, EMS_E_EdgeError, wrapup);

       /* connect the vertex_surface to the Round dpr */

       if (vtx_surf_id != NULL_OBJID)
        {
         /*owner_index = num_edges + k; -DLB*/
         stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg,
                                  &temp_id, &max_int),
                            targetid = vtx_surf_id,
                            targetos = OM_Gw_current_OS);
         EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
         /*k++; -DLB*/
        }
       if ((interrupt = IGEstop()))
        {
         *EMmsg = EMS_I_Interrupt; return (OM_S_SUCCESS);
        }
       option = 1;
      }
    } 
  }

 {  /*DLB 8/13/91*/
   IGRlong inx;
 
/***************
   for(i=0; i<num_edges; i++)
   {
     stat_OM = om$send(msg = message GRconnector.GRdisconn(&msg, &temp_id),
                       targetid = my_info[i].fillet_id);
     if (!(1 & stat_OM & &msg)) goto wrapup;
   }
****************/
  
   if (ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE) inx = 1;
   else inx = 0;

   for(i=num_edges-1; i>=0; i--)
   {
     stat_OM = om$send(msg = message GRconnector.GRrigidconn(&msg,
                             &temp_id, &inx),
                       targetid = my_info[i].fillet_id);
   }
 }

 dis_option = EMS_DO_DISPLAY;

 pair_info = (struct EMedge_con_info *) om$realloc(ptr = (IGRchar *) pair_info,
              size = (arr_size + ME.EMSsfround->no_of_boundaries + 
                     (num_def_info * 4))* sizeof(struct EMedge_con_info));
 EMerr_hndlr(!pair_info,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

 ls_count = OM_DIMENSION_OF(ME.EMSdpr->ids);

 svst_info.surface_ids = (GRobjid *) om$malloc(size =
                      ME.EMSsfround->no_of_boundaries * sizeof (GRobjid));
 EMerr_hndlr(!svst_info.surface_ids,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
 svst_info.num_regions_in = (IGRint *) om$malloc(size =
                       ME.EMSsfround->no_of_boundaries * sizeof (IGRint));
 EMerr_hndlr(!svst_info.num_regions_in,*EMmsg,EMS_E_NoDynamicMemory,
	wrapup);
 svst_info.region_in_ids = (GRobjid **) om$malloc(size =
                    ME.EMSsfround->no_of_boundaries *
                    ME.EMSsfround->no_of_boundaries * sizeof (GRobjid *));
 EMerr_hndlr(!svst_info.region_in_ids,*EMmsg,EMS_E_NoDynamicMemory,
	wrapup);

 svst_info.num_regions_out = (IGRint *) om$malloc(size =
                       ME.EMSsfround->no_of_boundaries * sizeof (IGRint));
 EMerr_hndlr(!svst_info.num_regions_out,*EMmsg,EMS_E_NoDynamicMemory,
	wrapup);

 svst_info.region_out_ids = (GRobjid **) om$malloc(size =
                    ME.EMSsfround->no_of_boundaries *
                    ME.EMSsfround->no_of_boundaries * sizeof (GRobjid *));
 EMerr_hndlr(!svst_info.region_out_ids,*EMmsg,EMS_E_NoDynamicMemory,
	wrapup);

 for (i=0; i<ls_count; i++)
  {
   svst_info.num_regions_in[i] = 0;
   svst_info.num_regions_out[i] = 0;
  }

 stat_OM = om$send (msg = message EMSsfround.EMround_execute (&msg,
                          my_env,
                          my_info, 
                          num_edges,
                          &num_pair_info,
                          pair_info,
                          &num_def_info,
                          def_info,
                          &dis_option, &svst_info, NULL, NULL,
                          &response_taken,
                          &exit_gracefully,
                          dis_options,
                          display_ids,
                          display_count),
                    targetid = my_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 if (msg == EMS_I_RndGrExit)
  {
   *EMmsg = EMS_I_RndGrExit;
   goto wrapup;
  }

 for (i=0; i<num_pair_info; i++)
  {
   /* Disconnect old common edge connections and record the information for
      possible recovery.
   */
   {
    OM_S_OBJECT_LINKAGE junk;
    OMuint count = 0;

    if(disconbufsize < 4)
     {
      if(eddiscon)
       {
	eddiscon = (GRobjid *) om$realloc(ptr = (IGRchar *) eddiscon, size = 
	            (numeddiscon + EdDiscon) * sizeof(GRobjid));
	eddiscon_props = (IGRushort *) om$realloc(ptr = (IGRchar *) eddiscon_props,
	                 size = (numeddiscon + EdDiscon) * sizeof(IGRushort));
       }
      else
       {
	eddiscon = (GRobjid *) om$malloc(size = EdDiscon * sizeof(GRobjid));
	eddiscon_props = (IGRushort *) om$malloc(
	                 size = EdDiscon * sizeof(IGRushort));
       }
      EMerr_hndlr(!eddiscon || !eddiscon_props, *EMmsg, EMS_E_NoDynamicMemory, 
                  wrapup);
      disconbufsize = EdDiscon;
     }

    locsts = om$get_channel_objects(objid = pair_info[i].edge, 
	     p_chanselect = &to_common_edge, list = &junk, size = 1, 
	     count = &count);
    if(count)
     {
      eddiscon[numeddiscon] = pair_info[i].edge;
      eddiscon[numeddiscon+1] = junk.S_objid;
      locsts = om$send(msg = message EMSedge.EMget_props(EMmsg, 
               &eddiscon_props[numeddiscon]), targetid = pair_info[i].edge);
      locsts = om$send(msg = message EMSedge.EMget_props(EMmsg, 
               &eddiscon_props[numeddiscon+1]), targetid = junk.S_objid);
      numeddiscon += 2;
      disconbufsize -= 2;
     }

    count = 0;
    locsts = om$get_channel_objects(objid = pair_info[i].comm_edge, 
	     p_chanselect = &to_common_edge, list = &junk, size = 1, 
	     count = &count);
    if(count)
     {
      eddiscon[numeddiscon] = pair_info[i].comm_edge;
      eddiscon[numeddiscon+1] = junk.S_objid;
      locsts = om$send(msg = message EMSedge.EMget_props(EMmsg, 
               &eddiscon_props[numeddiscon]), targetid=pair_info[i].comm_edge);
      locsts = om$send(msg = message EMSedge.EMget_props(EMmsg, 
               &eddiscon_props[numeddiscon+1]), targetid = junk.S_objid);
      numeddiscon += 2;
      disconbufsize -= 2;
     }
   }

   stat_OM = om$send (msg = message EMSedge.EMconnect_edges (&msg,
                            NULL, TRUE, 
                            pair_info[i].comm_edge,
                            pair_info[i].edge_surf,
                            pair_info[i].comm_edge_surf,
                            &my_env->md_env),
                      targetid = pair_info[i].edge);
   if (msg == EMS_E_InvalidArg)
    {
     stat_OM1 = om$get_channel_count (objid = pair_info[i].edge,
                                      p_chanselect = &to_common_edge,
                                      count = &c_e_count);
     if (! (1 & stat_OM1)) goto wrapup;

     if (c_e_count)
      {
       stat_OM1 = om$send(msg = message EMSboundary.EMget_objid (&msg1,
                                &com_edge),
                          senderid = pair_info[i].edge,
                          p_chanselect = &to_common_edge);
       EMerr_hndlr(! (1 & stat_OM1 & msg1),*EMmsg,EMS_E_EdgeError,wrapup);
       if (com_edge == pair_info[i].comm_edge)
        {
         stat_OM = OM_S_SUCCESS;
         msg = EMS_S_Success;
         continue;
        }
       else if (pair_info[i].align_normal)
        {
         if (pair_info[i].surf_geom->v_phy_closed)
          {
           stat_OM1 = om$send (msg = message Root.wild_disconnect( 
                                     to_common_edge),
                              targetid = pair_info[i].edge);
           if (! (1 & stat_OM1)) goto wrapup;

           loop_id = NULL_OBJID;
           stat_OM1 = EMsend_loops(&msg1,
                             message EMSboundary.EMget_objid (&msg1,
                             &loop_id), pair_info[i].edge, 0, OM_K_MAXINT,
                             EMLP_ACTIVE, NULL, NULL);
           EMerr_hndlr(! (1&stat_OM1&msg1),*EMmsg,EMS_E_EdgeError,wrapup);

           if (loop_id == NULL_OBJID) pair_info[i].edge = com_edge;

           stat_OM1 = om$send (msg = message EMSedge.EMconnect_edges (
                                     &msg1,
                                     NULL, TRUE, 
                                     pair_info[i].comm_edge,
                                     pair_info[i].edge_surf,
                                     pair_info[i].comm_edge_surf,
                                     &my_env->md_env),
                              targetid = pair_info[i].edge);
           EMerr_hndlr(! (1&stat_OM1&msg1),*EMmsg,EMS_E_EdgeError,wrapup);
           stat_OM = OM_S_SUCCESS;
           msg = EMS_S_Success;
          }
        }
      }
    }

   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   if (pair_info[i].align_normal)
    {
     stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                             &ed_props),
                       targetid = pair_info[i].edge);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
     
     props_0 = (pair_info[i].surf_geom->pos_orient) ? 0x1 : 0x0;
     props_1 = (pair_info[i].comm_surf_geom->pos_orient) ? 0x1 : 0x0;

     if (ed_props & EMED_REVERSE_CONNECT)
         toggle_normal =  (props_0 ^ props_1) ? TRUE : FALSE;
     else
         toggle_normal =  (props_0 ^ props_1) ? FALSE : TRUE;

     if (toggle_normal)
      {
       stat_OM = om$send(msg = message EMSsurface.EMrevorient (&msg),
                         targetid = pair_info[i].comm_edge_surf);
       EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
      }

     if (pair_info[i].comm_surf_geom)
         om$dealloc (ptr = pair_info[i].comm_surf_geom);
    }
  }

wrapup:

 EFgetobjids (&msg1, &temp_id, &to_comps, &surf_ids, &num_surf_ids, 
              OPP_EMSsubbs_class_id, NULL, 0);
 EMerr_hndlr(! (1 & msg1), *EMmsg, msg1, wrapup);

 if (dis_options & EMS_DO_DISPLAY)
 {
   for (i=0; i<num_surf_ids; i++)
   {
     if (dis_options & EMS_DONT_REDRAW)
     {
       /*Add the new surface to the display list*/
       stat_OM1 = EFwork_the_display(&msg1, dis_options,
                                     surf_ids[i].objid, display_ids,
                                     display_count, NULL);
       if (!(1 & stat_OM1 & msg1)) goto wrapup1;
     }
     else
     {
       stat_OM1 = om$send(msg = message GRgraphics.GRdisplay(&msg1,
                               &my_env->md_env.matrix_type, 
                               my_env->md_env.matrix, &display_mode,
                               &my_env->md_id),
                         targetid = surf_ids[i].objid);
       EMerr_hndlr(! (1 & stat_OM1 & msg1), *EMmsg, msg1, wrapup1);
     }
   }
 }

 ex$message (msgnumb = EMS_S_ClearStatusField);


wrapup1:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMround");

 exit_gracefully = TRUE;

 if ((1 & stat_OM & msg) && 
     msg != EMS_I_RndGrExit && 
     msg != EMS_I_Interrupt && valid_flag && !bad_svst_info)
 {
   /*DLB 2/18/92 - check for stitchable edges*/
   IGRlong     loc_msg=1, loc_stat=1, rc;
   IGRboolean  is_degen;
   struct GRid *edges=NULL;
   IGRint      ix, buf_size=0, edge_count=0, num_degen=0;
   IGRdouble   disq_tol, cht_tol;
   extern OMuword OPP_EMSslround_class_id;


   if (EFisAncestryValid(&loc_msg, my_id, OM_Gw_current_OS,
                         OPP_EMSslround_class_id, FALSE))
   {
     for(ix=0; ix<svst_info.num_surfaces+1; ix++)
     {
       loc_stat = om$send(msg = message EMSsurface.EMgetedges(&loc_msg,
                                EMS_OPT_CONNECTABLE, &edges, &buf_size,
                                &edge_count, NULL, NULL, NULL, NULL),
                          targetid = (ix == svst_info.num_surfaces ?
                                      my_id :
                                      svst_info.surface_ids[ix]));
       if (!(1 & loc_stat & loc_msg))
       {
         valid_flag = FALSE;
         goto wrapup2;
       }
     }

     if (edge_count)
     {
       valid_flag = FALSE;

       /*
        * need to do the test for degeneracy with cht_tol instead of 
        * dis_tol. Since the math function BStstcvdegn uses BSTOLSQLENVEC,
        * change that to cht_tol*cht_tol, temporarily.
        */

       BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht_tol);
       BSEXTRACTPAR(&rc, BSTOLSQLENVEC, disq_tol);
       BSchangepar(&rc, BSTOLSQLENVEC, cht_tol*cht_tol);
       if (rc != BSSUCC) goto wrapup2;

       for(ix=0; ix<edge_count; ix++)
       {
         loc_stat = om$send(msg = message EMSedge.EMtst_degn(&loc_msg, NULL,
                                  NULL_OBJID, &my_env->md_env, &is_degen),
                            targetid = edges[ix].objid,
                            targetos = edges[ix].osnum);
         if (!(1 & loc_stat & loc_msg)) break;

         if (is_degen)
         {
           loc_stat = om$send(msg = message EMSedge.EMset_props(&loc_msg,
                                    EMED_DEGENERATE, EMS_O_ON),
                             targetid = edges[ix].objid,
                             targetos = edges[ix].osnum);
           if (!(1 & loc_stat & loc_msg)) break;
           num_degen++;
         }
       }

       BSchangepar(&rc, BSTOLSQLENVEC, disq_tol);

       edge_count -= num_degen;

       if (!edge_count) valid_flag = TRUE;

       if (edges) om$dealloc(ptr = edges);
     }
   }
 }         

wrapup2:

 if ((! (1 & stat_OM & msg) && (msg != EMS_E_RndGrExit)) || !valid_flag)
 { 
   ex$message ( msgnumb = EMS_S_RecoveringModel);

   /*
    * If rounding fails at any stage, the model will be always recovered 
    * Therefore exit_gracefully will always be TRUE.
    *
    * if (! response_taken)
    *     EMdecide_grexit(&msg, &exit_gracefully);
    *  
    */
   
   if (exit_gracefully)
   {
     stat_OM = om$send(msg = message EMSsfround.EMround_graceful_exit (
                             &msg, my_env, temp_id, NULL, NULL, NULL,
                             bad_svst_info ? NULL : &svst_info),
                       targetid = my_id);
     if (! (1 & stat_OM & msg)) *EMmsg = EMS_E_RndGrExit;
     else *EMmsg = EMS_I_RndGrExit;
   }

   /*DLB 2/18/92 pulled out round_cleanup code*/
   
   /* SM 03/31/92 Reconnect the edges disconnected and deposit original props.
   */
   for(i=0; i<numeddiscon; i+=2)   
    {
     if( (!EFisAncestryValid(&locmsg, eddiscon[i], OM_Gw_current_OS, 
           OPP_EMSedge_class_id, TRUE)) || 
         (!EFisAncestryValid(&locmsg, eddiscon[i+1], OM_Gw_current_OS, 
           OPP_EMSedge_class_id, TRUE)))
      continue;

     locsts = om$send(msg = message Root.wild_disconnect(to_common_edge), 
              targetid = eddiscon[i]);
     locsts = om$send(msg = message Root.wild_disconnect(to_common_edge), 
              targetid = eddiscon[i+1]);

     locsts = om$send(msg = message Root.connect(to_common_edge, NULL, 
              eddiscon[i+1], OM_Gw_current_OS, to_common_edge, NULL), 
              senderid = eddiscon[i+1], targetid = eddiscon[i]);
     locsts = om$send(msg = message EMSedge.EMset_props(&locmsg, 
              eddiscon_props[i], EMS_O_SET), targetid = eddiscon[i]);
     locsts = om$send(msg = message EMSedge.EMset_props(&locmsg, 
              eddiscon_props[i+1], EMS_O_SET), targetid = eddiscon[i+1]);
    }

   /* SM 04/08/92 Cleanup all the generated surfaces.
   */
   for(i=0; i<numgensf; i++)
    {
     if(!EFisAncestryValid(&locmsg, gensf[i], OM_Gw_current_OS, 
        OPP_EMSsubbs_class_id, TRUE)) continue;
     locsts = om$send(msg = message GRgraphics.GRdelete(&locmsg, my_env), 
              targetid = gensf[i]);
    }

 }

 for (i=0; i<num_edges; i++)
 {
   if (my_info[i].curve) BSfreecv(&msg ,my_info[i].curve);
   if (my_info[i].comm_curve) BSfreecv(&msg, my_info[i].comm_curve);
   if (my_info[i].surface) om$dealloc(ptr = my_info[i].surface);
/*
   if (my_info[i].comm_curve) om$dealloc(ptr = my_info[i].comm_curve);
   if (my_info[i].curve) om$dealloc(ptr = my_info[i].curve);
   if (my_info[i].fillet_surface) om$dealloc(ptr = my_info[i].fillet_surface);
*/
   if (my_info[i].fillet_surface) BSfreesf(&msg, my_info[i].fillet_surface);
 }

 if (my_info) om$dealloc (ptr = my_info);
 if (def_info) om$dealloc (ptr = def_info);
 if (pair_info) om$dealloc (ptr = pair_info);
 if (edge_ids) om$dealloc(ptr = edge_ids);
 if (dir_point) om$dealloc(ptr = dir_point);
 if (surf_ids) om$dealloc(ptr = surf_ids);

 if (svst_info.surface_ids) om$dealloc(ptr = svst_info.surface_ids);
 if (svst_info.num_regions_in) om$dealloc(ptr = svst_info.num_regions_in);
 if (svst_info.region_in_ids) om$dealloc(ptr = svst_info.region_in_ids);
 if (svst_info.num_regions_out)
                             om$dealloc(ptr = svst_info.num_regions_out);
 if (svst_info.region_out_ids) om$dealloc(ptr = svst_info.region_out_ids);
 if (svst_info.edge_in_ids) om$dealloc(ptr = svst_info.edge_in_ids);
 if (svst_info.edge_out_ids) om$dealloc(ptr = svst_info.edge_out_ids);
 if (svst_info.rounded_edge_ids)
     om$dealloc(ptr = svst_info.rounded_edge_ids);
 
 if(eddiscon) om$dealloc(ptr = eddiscon);
 if(eddiscon_props) om$dealloc(ptr = eddiscon_props);
 if(gensf) om$dealloc(ptr = gensf);

 if (*EMmsg == EMS_I_RndGrExit) *EMmsg = EMS_I_Fail;
 return(stat_OM);
}

EMdecide_grexit(EMmsg, exit_gracefully)

IGRlong *EMmsg;
IGRboolean *exit_gracefully;

{
 IGRchar        response_data[256];
 IGRlong        msg, sts;
 /*IGRlong        event_mask;*/
 IGRint         event_size, response;
 struct GRevent event;
 IGRchar        prompt[54];

 /*--------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;

 event_size = sizeof (struct GRevent);

 querry:
/*
 UI_prompt("Failure, Continue Processing(c)/Recover Model(r)[c] ?");

 event_mask = GRm_STRING | GRm_RJT_MOVEON;

 sts = GRgetevent(&msg, &event_mask, &event_size, &event, &response,
                  response_data);
*/
    ex$message ( msgnumb = EMS_P_FailureContinueProc,
                 buff    = prompt);

    sts = co$getevent (
        msg = &msg,
        event_mask = GRm_TEXT_VALUE | GRm_RJT_MOVEON,
        prompt = prompt,
        response = &response,
        response_data = response_data,
        event = &event
    );

 if (! (1 & sts))
  {*exit_gracefully = TRUE; goto wrapup;}

 else if (event.response IS GR_UNKNOWN_TYPE)
          goto querry;
 else if (event.response IS EX_RJT_MOVEON)
          *exit_gracefully = FALSE;
 else if ((event.event.keyin[0] == NULL) ||
          (toupper(event.event.keyin[0]) == 'C'))
          *exit_gracefully = FALSE;
 else if (toupper(event.event.keyin[0]) == 'R')
          *exit_gracefully = TRUE;
 else
          goto querry;
 wrapup:

 ex$message ( msgnumb = EMS_P_ClearPromptField);

 return(sts);
}

/* The following function has been added to check the validity of the rounding
   radius. The rounding radius can be such that the fillet surface created
   can be self intersecting. If such is the case the function would return 
   FALSE else TRUE 
*/

#define NUM_PARMS       3
#define MAX_RAD         1.0e+39

IGRboolean EF_is_round_rad_valid( EMmsg, md_env, edgeid,round_radius)
IGRlong         *EMmsg;
struct GRmd_env *md_env;
GRobjid    edgeid;
IGRdouble  round_radius;
/* History :-
   Inasu : Feb 19,91 : Creation.
*/
{
  IGRboolean status;
  struct IGRbsp_curve  edge_geom;
  static IGRdouble params[NUM_PARMS] = { 0.0, 0.5, 1.0 };
  IGRdouble rad[NUM_PARMS], kurv[NUM_PARMS],min_rad;
  IGRpoint  points[NUM_PARMS][2];
  IGRlong sts,msg;
  IGRint i;
  IGRuchar   curve_type;
  IGRushort   edge_prop;

     status = FALSE;
     *EMmsg = EMS_S_Success;

     sts = om$send(msg = message EMSedge.EMget_props_type (&msg,
                        &edge_prop, &curve_type),
                   senderid = NULL_OBJID,
       	           targetid = edgeid,
		   targetos = md_env->md_id.osnum);
     EMerr_hndlr(! (1 & sts & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     if((curve_type != EMlinesegment ) && (curve_type != EMlinestring))
     {
       edge_geom.weights = NULL;
       edge_geom.poles = NULL;
       edge_geom.knots = NULL;
       edge_geom.bdrys = NULL;

       sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                               &md_env->md_env, NULL, NULL, 0,
                               OM_K_MAXINT, FALSE, NULL, &edge_geom),
                        senderid = NULL_OBJID,
                        targetid = edgeid,
                        targetos = md_env->md_id.osnum);
     EMerr_hndlr (!(1&sts & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     if( edge_geom.order == 2) status = TRUE;
     else
     {
        BScvarrevc(&edge_geom, NUM_PARMS, params,MAX_RAD,kurv,rad,points,&msg);
        EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

        min_rad = rad[0];
        for(i = 1; i < NUM_PARMS; i++) if(min_rad > rad[i]) min_rad = rad[i];

        if ( round_radius < min_rad ) status = TRUE;
     }

     if(edge_geom.poles) om$dealloc(ptr = edge_geom.poles);
     if(edge_geom.knots) om$dealloc(ptr = edge_geom.knots);
     if(edge_geom.weights) om$dealloc(ptr = edge_geom.weights);
     if(edge_geom.bdrys) om$dealloc(ptr = edge_geom.bdrys);
    }
     else status = TRUE;

wrapup:

  return(status);
}
end implementation EMSsfround;

#if HERE_IS_ROUND_CLEANUP_CODE_IF_EVER_NEED_TO_PUT_ROUND_CLEANUP_CODE_BACK_IN
   else /* The else part  will not be executed since exit_gracefully is always
           TRUE */
    {
     stat_OM = OM_S_SUCCESS;
     msg = EMS_S_Success;

     if (1 & (stat_OM = om$is_objid_valid(objid = my_id)))
      {
       stat_OM = om$send(msg = message EMSsfround.EMround_cleanup (&msg,
                               my_env, &num_surf_ids, surf_ids),
                         targetid = my_id);
      }
     else
      stat_OM = OM_S_SUCCESS;

     props = EMED_END_ROUNDED | EMED_BEG_ROUNDED;

     for (j=0; j<num_edges; j++)
      {
       stat_OM = om$send(msg = message EMSedge.EMset_props(&msg, props,
                               EMS_O_OFF),
                         targetid = edge_ids[j]);
       stat_OM = om$send(msg = message EMSedge.EMset_props(&msg, props,
                               EMS_O_OFF),
                         senderid = edge_ids[j],
                         p_chanselect = &to_common_edge);
      }
    }
#endif
