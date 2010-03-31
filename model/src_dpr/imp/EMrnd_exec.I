/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emsmacros.h"
#include "emsdef.h" 
#include "emssfint.h"
#include "EMSerrordef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsimpdef.h"
#include "OMmacros.h"
#include "msmacros.h"
#include "ECmsg.h"

#define INIT_SIZE 15
static IGRlong EMget_loop_bnds();
static IGRlong EMchange_def_info();
static IGRlong EMreevaluate_pt_in_area ();

from EMSedge import EMpt_location,
                    EMsend_dummy_edge,
                    EMget_top_part_edges,
                    EMgettopedge,
                    EMendpts,
                    EMstitch,
                    EMconnect_edges,
                    EMreverse,
                    EMset_props,
                    EMget_props;
from EMSloop import EMset_props,
                    EMget_props,
                    EMendpts,
                    EMtreemod;
from EMSloopset import EMsplityourself,
                       EMtrim_extract,
                       EMget_loops;
from EMSboundary import EMget_objid;
from EMSboundary import EMgetsurface_info;

method EMround_execute (IGRlong                   *EMmsg;
                        struct GRmd_env           *my_env;
                        struct EMedge_round_info  *my_info;
                        IGRint                    num_edges;
                        IGRint                    *num_pair_info;
                        struct EMedge_con_info    *pair_info;
                        IGRint                    *num_def_info;
                        struct EMdef_con_info     *def_info;
                        IGRshort                  *option;
                        struct EMround_save_state *svst_info;
                        IGRboolean                *add_s1_to_tree,
                                                  *add_s2_to_tree,
                                                  *response_taken,
                                                  *exit_gracefully;
                        IGRushort         dis_options;
                        GRobjid                   **display_ids;
                        IGRint                    *display_count)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure

Assumption

Bugs

History
	
gupta 	10/09/87:design date

 RC     01/31/90:Commented the call EMcleanup_surfaces till
                 composite auto_trim is allowed.

TAPADIA 11th Jan. 91 - Fixed TR 90n3345. Memory reallocated for
		variable to_disconnect. Added some NoMemory
		checks after some mallocs.

Inasu:Mar 01,91:The EMdecide_grexit has been commented and exit_gracefully
                is set to TRUE if the rounding fails. That is, if the rouding
                failed, the user will NOT be prompted for Continue/Recover,
                instead the model is recovered (TR 91n0674).

SM     03/24/92: num_orgnl_loops was being set to 0 if failure in
                 EMSloopset.EMsplityourself. This inhibited complete recovery.

scw    06/17/93: Initialized new_edge as not to get a uninitialized memory
                 read.

scw    06/22/93: Changed the order of the if statements checking grp_closed[k]
                 and added dealloc for several chunks of malloced memory.

Algorithm

*/

{
 IGRlong	           stat_OM, msg;
 IGRushort                 edge_prop,
                           split_options;
 enum GRdpmode             display_mode;
 OMuint			   elem_count,ed_count,edg_count, assoc_count, count;
 IGRint                    i, j, k, m, n, 
                           ls_count, inst_no, int_num,
                           num_output_loops, num_sfs, 
                           num_out_loops, num_imp_loops, alloc_num,
                           num_grps, *num_elems_grp = NULL, num_loops,
                           num_saves, num_pe0, num_pe1, num_entry,
                           for_inx, rev_inx, buf_size0, buf_size1;
 IGRint                    depth, buf_size, num_orgnl_loops = 0;
 IGRint                    num_to_impose=0, index, num_rem_loops;
 IGRboolean                info_to_save, is_fillet, *to_disconnect = NULL,
                           **elem_rev=NULL, *grp_closed = NULL, is_c_loop,
                           in_area_trim, def_edge_changed, different_loop;
 IGRboolean                dummy_edge_present, multiple_loops;
 extern IGRboolean         EFextract_par();
 IGRboolean                auto_trim;
 IGRboolean                blend_surface;
 IGRchar                   ***elems=NULL, *elemptrs=NULL;
 IGRdouble                 *end_pts = NULL, uv_tol;
 IGRdouble                 lp_beg[2], lp_end[2];
 OMuword                   dum_os;
 GRobjid                   *edge_ids = NULL, *p_edges0 = NULL, *p_edges1
			   = NULL,
                           in_com_edge, comm_surf, edge_surf,
                           in_edge, *int_edges = NULL, *out_loops = NULL,
                           *output_loops = NULL, *loop_ids = NULL, 
			   *boss_loop = NULL;
 GRobjid                   new_edge, *orgnl_loops = NULL;
 struct GRid               srf_GRid;
 struct EMboundary_info    *bndry_info = NULL;
 struct EMSnest_info       nesting;
 struct EMboundary_info    **loop_bnd_info = NULL;
 struct EMSpartolbasis     partol;
 struct EMSstitch_info     stitch_info;
 struct EMSptloc_info      location;
 struct EMSownercomp       *sfs_loops = NULL;
 struct EMSownercomp       *EMownercomp_malloc();
 struct EMSsfintedpar      **trim_info = NULL;
 OM_S_CHANSELECT           to_edges,
                           to_loops,
                           to_assoc,
                           to_common_edge;
 OM_S_OBJECT_LINKAGE       *assoc_list = NULL;

/*----------------------------------------------------------------*/
 
 *EMmsg = EMS_S_Success;

 stat_OM = OM_S_SUCCESS;

 bndry_info = NULL;
 edge_ids = NULL;
 to_disconnect = NULL;
 num_saves = 0;
 num_entry = 0;

 new_edge = NULL_OBJID;
 
 auto_trim = (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM) ?
                                               TRUE : FALSE;
 if (auto_trim)
  {
   *add_s1_to_tree = FALSE;
   *add_s2_to_tree = FALSE;
  }

 alloc_num = ME.EMSsfround->no_of_boundaries + 4*num_edges;

 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 stat_OM = EMmake_chanselect (GRnotify_notification, &to_assoc);
 stat_OM = EMmake_chanselect (EMSloopset_to_loops, &to_loops);
 if (! (1 & stat_OM)) goto wrapup;

 bndry_info = (struct EMboundary_info *) om$malloc (size = INIT_SIZE *
               sizeof (struct EMboundary_info));
 edge_ids = (GRobjid *) om$malloc(size = alloc_num * sizeof(GRobjid));
 to_disconnect = (IGRboolean *) om$malloc(size = alloc_num *
                                                     sizeof(IGRboolean));
 EMerr_hndlr(!bndry_info || !edge_ids || !to_disconnect,
	*EMmsg,EMS_E_NoDynamicMemory,wrapup);

 ls_count = OM_DIMENSION_OF(ME.EMSdpr->ids);

 for (i=0; i<(ls_count); i++)
  {
   if (num_saves >= (alloc_num - 10))
    {
     alloc_num += 10;
     edge_ids = (GRobjid *) om$realloc (ptr = (IGRchar *) edge_ids, size =
                                           alloc_num * sizeof (GRobjid));
	/* TAPADIA - Fix for TR 90n3345 */
     to_disconnect = (IGRboolean *) om$realloc (ptr = (IGRchar *)to_disconnect,
			size = alloc_num * sizeof(IGRboolean));
     EMerr_hndlr(!edge_ids || !to_disconnect, *EMmsg,
		EMS_E_NoDynamicMemory, wrapup);
    }

   inst_no = 0;
   info_to_save = TRUE;
   multiple_loops = FALSE;
   num_rem_loops = 0;

   for (j=0; j<ME.EMSsfround->no_of_boundaries; j++)
    {
     if (ME.EMSsfround->round_exec_info[j].index == i)
      {
       bndry_info[inst_no] = ME.EMSsfround->round_exec_info[j].bnd_info;
       inst_no++;

        if (! (inst_no % INIT_SIZE)) {
           bndry_info = (struct EMboundary_info *) om$realloc (ptr = 
                        (IGRchar *) bndry_info, size = (inst_no + INIT_SIZE) *
                        sizeof (struct EMboundary_info));
 	   EMerr_hndlr(!bndry_info,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
	}
      }
    }
  
   loop_ids = NULL;

   loop_ids = (GRobjid *) om$malloc(size = inst_no * sizeof(GRobjid));
   EMerr_hndlr(!loop_ids,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

   num_loops = 1;
   loop_ids[0] = bndry_info[0].rnd_loop_id;

   for (m=0; m<inst_no; m++)
    {
     different_loop = TRUE;
     for (n=0; n<num_loops; n++)
      {
       if (IF_EQ_OBJID(bndry_info[m].rnd_loop_id, loop_ids[n]))
        {
         different_loop = FALSE;
         continue;
        }

      }
     if (different_loop)
      {
       loop_ids[num_loops] = bndry_info[m].rnd_loop_id;
       num_loops++;
      }   
    }

   /* get the partol of the surface */

   partol.in_world = FALSE;
   partol.is_valid = FALSE;
   partol.mattyp = &my_env->md_env.matrix_type;
   partol.mat = my_env->md_env.matrix;

   stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                           (&msg, &srf_GRid.objid, &partol),
                      targetid = ME.EMSdpr->ids[i]);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

   srf_GRid.osnum = OM_Gw_current_OS;

   blend_surface = FALSE;

   for (m=0; m<num_edges; m++)
    {
     if (IF_EQ_OBJID(srf_GRid.objid, my_info[m].fillet_id))
      {
       blend_surface = TRUE;
       break;
      }
    }

   if ((*option & EMS_DO_DISPLAY) && (! blend_surface))
   {
     if ((inst_no > 1 ) || (bndry_info[0].bnd_type != EMS_PATCH_BND))
     {
       IGRboolean dont_have_it;

       stat_OM = EFwork_the_display(&msg, dis_options,
                                    srf_GRid.objid,
                                    display_ids, display_count,
                                    &dont_have_it);
       if (!(1 & stat_OM & msg)) goto wrapup;
       
       if (dont_have_it)
       {
         display_mode = GRbehe;
  
         stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                 &my_env->md_env.matrix_type, 
                                 my_env->md_env.matrix, &display_mode,
                                 &my_env->md_id),
                           targetid = srf_GRid.objid);
         EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, msg, wrapup);
       }
     }
   }

   if (orgnl_loops) om$dealloc (ptr = orgnl_loops);
   num_orgnl_loops = 0;
   orgnl_loops = NULL;
   depth = MAXINT;
   buf_size = 0;

   stat_OM = om$send (msg = message EMSloopset.EMget_loops (&msg,
                                EMS_OPT_ALL, &depth, &orgnl_loops, NULL,
                                &buf_size, &num_orgnl_loops),
                          targetid = ME.EMSdpr->ids[i]);
   EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_LoopsetError,wrapup);

   /* impose the various boundaries on the loopset */

   stat_OM = om$get_channel_count(objid = ME.EMSdpr->ids[i],
                                  p_chanselect = &to_loops,
                                  count = &count);
   if (! (1 & stat_OM)) goto wrapup;

   if (count > 1)
    {
     num_rem_loops = num_loops;
     multiple_loops = TRUE;
     num_loops = 1;
    }
     
   for (m=0; m<num_loops; m++)
    {
     int_edges = NULL;
     loop_bnd_info = NULL;
     end_pts = NULL;
     int_num = 0;
     def_edge_changed = FALSE;
     boss_loop = NULL;
    
     loop_bnd_info = (struct EMboundary_info **) om$malloc(size = 
                           inst_no * sizeof (struct EMboundary_info *));

     end_pts = (IGRdouble *) om$malloc(size = 4 * inst_no * sizeof 
                                                  (IGRdouble));
     EMerr_hndlr(!loop_bnd_info || !end_pts, *EMmsg,
                 EMS_E_NoDynamicMemory, wrapup);
      {

       EMget_loop_bnds(&msg, loop_ids[m], loop_bnd_info, bndry_info,
                     inst_no, &num_imp_loops, &is_fillet,&multiple_loops);
       EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
      }

     int_edges = (GRobjid *) om$malloc(size = num_imp_loops *
                                                       sizeof(GRobjid));
     EMerr_hndlr(!int_edges,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
     for (j=0; j<num_imp_loops; j++)
      {
       if (loop_bnd_info[j]->bnd_type == EMS_EDGE_BND)
        {
         stat_OM = om$get_objid_at_index(objid =loop_bnd_info[j]->loop_id,
                                         p_chanselect = &to_edges,
                                         index = 0,
                                         objidaddr = &in_edge,
                                         osnumaddr = &dum_os);
         EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

         stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                                 &edge_ids[num_saves]),
                           senderid = in_edge,
                           p_chanselect = &to_common_edge);
         EMerr_hndlr(! (1&stat_OM&msg), *EMmsg,EMS_E_EdgeError,wrapup);
         if (stat_OM == OM_S_SUCCESS)
          {
           to_disconnect[num_saves] = TRUE;
           int_edges[int_num] = edge_ids[num_saves];
           int_num++;
           num_saves++;
          }
        }
      }
      
     num_to_impose = 1;
     
     if (! is_fillet)
     {
       if( num_elems_grp )  om$dealloc( ptr = num_elems_grp );
       if( grp_closed )   om$dealloc( ptr = grp_closed );
       if( elem_rev )
       {
          for( elem_count=0; elem_count < num_to_impose; elem_count++ )
             if( elem_rev[elem_count] )  
		{
		om$dealloc( ptr = elem_rev[elem_count] );
		elem_rev[elem_count] = NULL;
		}
          om$dealloc( ptr = elem_rev );
	  elem_rev = NULL;
       }

       num_grps = 0;
       num_elems_grp = NULL;
       elems = NULL;
       elem_rev = NULL;
       grp_closed = NULL;

       EMfix_loops(&msg, &num_imp_loops, loop_bnd_info, &is_c_loop,
                   &partol, my_env, end_pts);
       EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);

       elemptrs = (IGRchar *) loop_bnd_info;
       
       EFextract_par(BSTOLLENVEC, partol.tol, &uv_tol, &msg);

       EMgentracer(&msg, num_imp_loops, 2, end_pts, NULL, elemptrs, 
                   uv_tol, NULL, &num_grps, &num_elems_grp, &elems,
                   &elem_rev, &grp_closed); 
       EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
       
       if (multiple_loops)
        {
         num_to_impose = num_grps;
         num_grps = 1;
        }
     }
     else
     {
       num_grps = num_imp_loops;
       
       if (num_grps > 1)
        {

         stat_OM = EMreevaluate_pt_in_area(&msg, loop_bnd_info,
                                           num_imp_loops);
         EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, msg, wrapup);
        }
     }

     boss_loop = (GRobjid *) om$malloc(size = num_to_impose * 
                                            sizeof(GRobjid));
     EMerr_hndlr(!boss_loop,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
     for (k=0; k<num_grps; k++)
      {
       if (! is_fillet)
        {
         svst_info->surface_ids[svst_info->num_surfaces] = srf_GRid.objid;
       
         for (j=0; j<num_to_impose; j++)
          {
           index = (num_to_impose > 1) ? j : k;
           EMcompress_loops(&msg,
                            index,
                            num_elems_grp,
                            elems,
                            elem_rev,
                            loop_bnd_info,
                            &partol,
                            multiple_loops,
                            &boss_loop[j]);
           EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);

           if (grp_closed[index])
            {
             stat_OM = om$send(msg = message EMSloop.EMset_props(&msg,
                                     EMLP_OPEN, EMS_O_OFF),
                               targetid = boss_loop[j]);
             EMerr_hndlr(!(1&stat_OM&msg),*EMmsg,EMS_E_LoopError,wrapup);
           
             stat_OM = om$send(msg = message EMSloop.EMset_props(&msg,
                                     EMLP_PLOOP,
                                     (is_c_loop) ? EMS_O_OFF : EMS_O_ON),
                               targetid = boss_loop[j]);
             EMerr_hndlr(!(1&stat_OM&msg),*EMmsg,EMS_E_LoopError,wrapup);
            }
          }      
         location.location = EMS_L_RIGHT;     
        }
       else
        {
         stat_OM = om$get_channel_count(objid = loop_bnd_info[k]->loop_id,
                                        p_chanselect = &to_edges,
                                        count = &edg_count);
         EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

         if (edg_count == 1)
          {
           location.num_located_edges = 0;
           location.location = EMS_L_UNKNWN;
           location.options = NULL;

           stat_OM = om$send (msg = message EMSedge.EMpt_location (&msg,
                                    loop_bnd_info[k]->point_in_area,
                                    &location,
                                    NULL,
                                    &partol),
                              senderid = loop_bnd_info[k]->loop_id,
                              p_chanselect = &to_edges);
           EMerr_hndlr(!(1&stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);
          }
         else
          {
           for (ed_count=0; ed_count<edg_count; ed_count++)
            {
             location.num_located_edges = 0;
             location.location = EMS_L_UNKNWN;
             location.options = NULL;

             stat_OM = om$send (msg = message EMSedge.EMpt_location (&msg,
                                      loop_bnd_info[k]->point_in_area,
                                      &location,
                                      NULL,
                                      &partol),
                                senderid = loop_bnd_info[k]->loop_id,
                                p_chanselect = &to_edges,
                                from = ed_count,
                                to = ed_count);
             EMerr_hndlr(! (1&stat_OM&msg),*EMmsg,EMS_E_EdgeError,wrapup);

             if (location.location == EMS_L_LEFT)
              {
               stat_OM = om$send (msg = message EMSedge.EMreverse (&msg),
                                  senderid = loop_bnd_info[k]->loop_id,
                                  p_chanselect = &to_edges,
                                  from = ed_count,
                                  to = ed_count);
               EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,
                           wrapup);
              }
            }
           location.location = EMS_L_RIGHT;     
           stat_OM = om$send(msg = message EMSloop.EMendpts(&msg,
                                   lp_beg, lp_end, NULL, NULL),
                             targetid = loop_bnd_info[k]->loop_id);
           EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError,
                       wrapup);

           if (EM2ddistptpts(lp_beg, lp_end) <= partol.tol)
            {
             stat_OM = om$send(msg = message EMSloop.EMset_props(&msg,
                                     EMLP_REVERSED, EMS_O_ON),
                               targetid = loop_bnd_info[k]->loop_id);
             EMerr_hndlr(!(1&stat_OM& msg),*EMmsg,EMS_E_LoopError,wrapup);
            }
          }
         if (loop_bnd_info[k]->bnd_type == EMS_PATCH_BND)
             info_to_save = FALSE;
        }

       /****************************
       depth = MAXINT;
       buf_size = num_orgnl_loops = 0;
       orgnl_loops = NULL;

       stat_OM = om$send (msg = message EMSloopset.EMget_loops (&msg,
                                EMS_OPT_ALL, &depth, &orgnl_loops, NULL,
                                &buf_size, &num_orgnl_loops),
                          targetid = ME.EMSdpr->ids[i]);
       EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_LoopsetError,wrapup);
       ******************************/

       output_loops = NULL;
       out_loops = NULL;
       sfs_loops = NULL;
       num_output_loops = 0;
       num_sfs = 0;

       trim_info = NULL; 
       num_out_loops = 0;
     
       stat_OM = om$send(msg = message EMSloopset.EMtrim_extract(
                               &msg,
                               my_env,
                               my_info,
                               srf_GRid,
                               num_edges,
                               &partol,
                               num_to_impose,
                               (! is_fillet) ? boss_loop : 
                                          &loop_bnd_info[k]->loop_id,
                               &num_out_loops,
                               &out_loops,
                               &in_area_trim,
                               (auto_trim) ? FALSE : info_to_save,
                               &num_saves,
                               edge_ids,
                               to_disconnect,
                               int_num,
                               int_edges,
                               num_pair_info,
                               pair_info,
                               num_def_info,
                               def_info,
                               blend_surface,
                               &trim_info),
                         targetid = ME.EMSdpr->ids[i]);
       EMerr_hndlr(!(1& stat_OM& msg),*EMmsg,EMS_E_LoopsetError, wrapup);

       if ((is_c_loop) && (! is_fillet))
        {
         stat_OM = om$send (msg = message EMSedge.EMget_props (&msg,
                                  &edge_prop),
                            senderid = loop_bnd_info[0]->rnd_loop_id,
                            p_chanselect = &to_edges,
                            from = 0,
                            to = 0);
         EMerr_hndlr(! (1&stat_OM&msg),*EMmsg,EMS_E_EdgeError,wrapup);
 
         if ((edge_prop & EMED_XYZ_CLOSED) &&
             (trim_info[0]->edgeid != NULL_OBJID))
          {
           *EMmsg = EMS_E_RndInterfere;
           goto predetermined_failure;        
          }
        }
      
       if ((! in_area_trim) && (! info_to_save))
        {
         def_edge_changed = TRUE;
  
         stat_OM = om$get_objid_at_index(objid = out_loops[0],
                                         p_chanselect = &to_edges,
                                         index = 0,
                                         objidaddr = &new_edge,
                                         osnumaddr = &dum_os);
         EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);
        }

       if ((! is_fillet) && (is_c_loop) && (grp_closed[k]))
        {
         stat_OM = om$send(msg = message EMSloop.EMtreemod(&msg,
                                 &nesting, EXTRACT, NULL),
                           targetid = loop_bnd_info[0]->rnd_loop_id);
         EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_NestError,wrapup);

         stat_OM = om$send(msg = message EMSloop.EMset_props(&msg,
                                 EMLP_ACTIVE, EMS_O_OFF),
                           targetid = loop_bnd_info[0]->rnd_loop_id);
         EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_NestError,wrapup);
        }

       split_options = (location.location == EMS_L_LEFT) ?
                           EMImpBnd_CloseReverse : EMImpBnd_CloseRegular;

       split_options |= EMImpBnd_MaintainAssoc;

       if (auto_trim)
           split_options |= EMImpBnd_SplitTopology;

       ex$message (msgnumb = EMS_S_SplittingLoopset);

       stat_OM = om$send(msg = message EMSloopset.EMsplityourself(
                               &msg,
                               out_loops,
                               num_out_loops,
                               trim_info,
                               NULL,
                               NULL,
                               &output_loops,
                               &num_output_loops,
                               split_options,
                               &num_sfs,
                               &sfs_loops,
                               &partol,
                               my_env),
                         targetid = ME.EMSdpr->ids[i]);
       if (! (1 & stat_OM & msg))
        {
         predetermined_failure:

         if ((*response_taken) && (! (*exit_gracefully)))
              {
               stat_OM = OM_S_SUCCESS;
               msg = EMS_S_Success;
               display_mode = GRhhd;
               goto display_surface;
              }

         /****** SM 03/24/92 setting num_orgnl_loops=0, causes problems
	  in recovery.
	 */
         /*num_orgnl_loops = 0;*/

         if (! *response_taken)
          {
           *response_taken = TRUE;
	   *exit_gracefully = TRUE;

           /** EMdecide_grexit(&msg, exit_gracefully); ***/

           if (*exit_gracefully)
               goto wrapup;
           else
            {
             stat_OM = OM_S_SUCCESS;
             msg = EMS_S_Success;
             display_mode = GRhhd;
             goto display_surface;
            }
          }
        }

       if (auto_trim)
        {
         if (i) *add_s2_to_tree = TRUE;
         else   *add_s1_to_tree = TRUE;
        }

       if ((! is_fillet) && (is_c_loop) && (grp_closed[k]))
        {
         sfs_loops = EMownercomp_malloc (&msg, 1);
         sfs_loops->comps = (GRobjid *) om$malloc(size = sizeof(GRobjid));
         sfs_loops->ownerindex =(IGRint *) om$malloc(size=sizeof(IGRint));

     	 EMerr_hndlr(!sfs_loops->comps || !sfs_loops->ownerindex,
		*EMmsg, EMS_E_NoDynamicMemory, wrapup);
         sfs_loops->num_comps = 1;
         sfs_loops->owner = srf_GRid.objid;
         sfs_loops->next = NULL;
         sfs_loops->comps[0] = loop_bnd_info[k]->rnd_loop_id;
         sfs_loops->ownerindex[0] = 0;
        }

      if (((! is_fillet) || (def_edge_changed)) && ! auto_trim)
        {

         stat_OM = EMchange_def_info(&msg, num_out_loops, trim_info,
                                     &partol, def_edge_changed, new_edge,
                                     loop_bnd_info[0]->loop_id,
                                     num_def_info, def_info);
         EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
        }

      if (! is_fillet)
        {
         svst_info->num_regions_in[svst_info->num_surfaces] =
                                                        num_output_loops;
         svst_info->region_in_ids[svst_info->num_surfaces] = output_loops;
         if (sfs_loops)
         svst_info->num_regions_out[svst_info->num_surfaces] =
                                                    sfs_loops->num_comps;
         else
         svst_info->num_regions_out[svst_info->num_surfaces] = 0;

         if (sfs_loops)
         svst_info->region_out_ids[svst_info->num_surfaces] =
                                                        sfs_loops->comps;
         svst_info->num_surfaces += 1;

/*
         if (auto_trim)
          {
           stat_OM = om$send(msg = message EMSsfround.EMcleanup_surfaces(
                                   &msg, my_env, 
                                   (sfs_loops) ? sfs_loops->num_comps : 0,
                                   (sfs_loops) ? sfs_loops->comps : NULL,
                                   num_out_loops, trim_info,
                                   my_info, svst_info),
                             targetid = my_id);
           EMerr_hndlr (!(1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
          }
*/
        }

      if (sfs_loops)
       {
        if ((sfs_loops->num_comps > 1) && (! multiple_loops))
         {
          count = 0;
          for (j=0; j<sfs_loops->num_comps; j++)
           {
            dummy_edge_present = FALSE;

            stat_OM = om$send(msg = message EMSedge.EMsend_dummy_edge(
                                    &msg, my_id, OM_Gp_NULL_MESSAGE,
                                    &dummy_edge_present),
                              senderid = sfs_loops->comps[j],
                              p_chanselect = &to_edges,
                              from = 0,
                              to = MAXINT);
            EMerr_hndlr (!(1 & stat_OM & msg), *EMmsg, EMS_E_LoopError,
                         wrapup);
            if (! dummy_edge_present) count ++;
           }
         }
       }

      if (sfs_loops)
       {
        if (((sfs_loops->num_comps > 1) && (! multiple_loops)) ||
            ((sfs_loops->num_comps > num_rem_loops) && (multiple_loops)))
         {
          if ((sfs_loops->num_comps > 1) && (! multiple_loops) &&
              (count <= 1)) goto bad_guess;

          *EMmsg = EMS_E_RndInterfere;
          svst_info->num_surfaces -= 1;
          if (! *response_taken)
           {
            *response_taken = TRUE;
	    *exit_gracefully = TRUE;

            /* EMdecide_grexit(&msg, exit_gracefully); */
 
            if (*exit_gracefully) 
                goto wrapup;
            else
             {
              stat_OM = OM_S_SUCCESS;
              msg = EMS_S_Success;
              display_mode = GRhhd;
              goto display_surface;
             }
           }
         }
       }

      bad_guess:

      /*************
       if (orgnl_loops) om$dealloc (ptr = orgnl_loops);
       num_orgnl_loops = 0;
       orgnl_loops = NULL;
      **************/

       if (! in_area_trim)
        {
         for (j=0; j<int_num; j++)
          {
           stat_OM = om$get_channel_count (objid = int_edges[j],
                                           p_chanselect = &to_assoc,
                                           count = &assoc_count);
           if (assoc_count > 1)
            {
             assoc_list = NULL;
             assoc_list = (OM_S_OBJECT_LINKAGE *) om$malloc(size =
                          assoc_count * (sizeof (OM_S_OBJECT_LINKAGE)));
 	     EMerr_hndlr(!assoc_list, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

             stat_OM = om$get_channel_objects (objid = int_edges[j],
                                               p_chanselect = &to_assoc,
                                               list = assoc_list,
                                               size = assoc_count,
                                               count = &count);
             if (! (1 & stat_OM)) goto wrapup;
             stat_OM = om$send(msg = message Root.move_chan(
                                     to_common_edge,
                                     assoc_list[0].S_objid,
                                     OM_Gw_current_OS,
                                     to_common_edge),
                               senderid = assoc_list[0].S_objid,
                               targetid = assoc_list[1].S_objid);
             if (! (1 & stat_OM)) goto wrapup;
             if (assoc_list) om$dealloc (ptr = assoc_list);
            }
          }
        }

       ex$message (msgnumb = EMS_S_ClearStatusField);

       stat_OM = om$send(msg = message EMSsfround.EMset_tply_props (&msg,
                               ((auto_trim) && (! in_area_trim)) ? TRUE :
                                                                   FALSE,
                               trim_info, num_out_loops, num_output_loops,
                               output_loops, srf_GRid.objid, svst_info),
                         targetid = my_id);
       EMerr_hndlr (!(1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

       if (trim_info)
        {
         for (j = 0; j < num_out_loops; j++)
              EMsfintedpar_free(trim_info[j], 2);
         om$dealloc(ptr = trim_info);
         trim_info = NULL;
        }
       if(sfs_loops)
         {
         om$dealloc(ptr = sfs_loops);
         sfs_loops = NULL;
         }
       if(out_loops)
         {
         om$dealloc(ptr = out_loops);
         out_loops = NULL;
         }
       

     }  /* for (k=0; k<num_grps; k++)  */
     if (int_edges) om$dealloc(ptr = int_edges);
     if (boss_loop) om$dealloc(ptr = boss_loop);
     if (loop_bnd_info) 
        {
        om$dealloc(ptr = loop_bnd_info);
        loop_bnd_info = NULL;
        }
    }   /* for (m=0; m<num_loops; m++) */

   if (loop_bnd_info) 
      {
      om$dealloc(ptr = loop_bnd_info);
      loop_bnd_info = NULL;
      }
   display_mode = GRbd;

   display_surface:

   if ((*option & EMS_DO_DISPLAY) && (! blend_surface))
   {
     if (!(dis_options & EMS_DONT_REDRAW))
     {
       stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg,
                               &my_env->md_env.matrix_type, 
                               my_env->md_env.matrix, &display_mode,
                               &my_env->md_id),
                         targetid = srf_GRid.objid);
       EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, msg, wrapup);
     }
   }
   if (loop_ids) om$dealloc(ptr = loop_ids);
  } /* for ls_count */

 ex$message ( msgnumb = EMS_S_EstablishingTopology);

 if (! auto_trim)
  {
   stat_OM = om$send(msg = message EMSsfround.EMadd_defered_info(&msg,
                           my_env, num_def_info, def_info,
                           num_pair_info, pair_info, svst_info),
                     targetid = my_id);
   if (! (1 & stat_OM)) goto wrapup;
  }

 stat_OM = om$send(msg = message EMSsfround.EMprepare_rnd_ssi(&msg,
                         svst_info),
                   targetid = my_id);
 EMerr_hndlr (!(1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 for (j=0; j<num_saves; j++)
  {
   stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                           &in_com_edge),
                     senderid = edge_ids[j],
                     p_chanselect = &to_common_edge);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                           &edge_prop),
                     targetid = in_com_edge);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   if (to_disconnect[j])
    {
     stat_OM = om$send(msg = message Root.disconnect(to_common_edge,
                             in_com_edge,OM_Gw_current_OS,to_common_edge),
                       senderid = in_com_edge,
                       targetid = edge_ids[j]);
    }
   if (stat_OM  == OM_S_SUCCESS)
    {
     p_edges0 = p_edges1 = NULL;
     num_pe0 = num_pe1 = 0;
     buf_size0 = buf_size1 = 0;
     comm_surf = NULL_OBJID;
     edge_surf = NULL_OBJID;

     stat_OM = om$send (msg = message EMSedge.EMget_top_part_edges(
                              &msg, &p_edges0, &num_pe0, &buf_size0),
                        targetid = in_com_edge);
     EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     if(num_pe0)
      {
       stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                               (&msg, &comm_surf, NULL),
                       targetid = p_edges0[0]);
      }
     if (comm_surf == NULL_OBJID){ stat_OM = OM_S_SUCCESS; continue;}

     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError,
                 wrapup);

     stat_OM = om$send (msg = message EMSedge.EMget_top_part_edges(
                              &msg, &p_edges1, &num_pe1, &buf_size1),
                        targetid = edge_ids[j]);
     EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     if(num_pe1) 
      {
       stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                             (&msg, &edge_surf, NULL),
                       targetid = p_edges1[0]);
      }
     if (edge_surf == NULL_OBJID){ stat_OM = OM_S_SUCCESS; continue;}
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError,
               wrapup);

     if ((num_pe0 == num_pe1) && (! auto_trim))
      {
       rev_inx = num_pe1-1;
       for_inx = 0;
       for (m=0; m<num_pe0; m++)
        {
         if (edge_prop & EMED_SEAM)
          {
           stat_OM = om$send (msg = message EMSedge.EMconnect_edges (&msg,
                                    EMED_SEAM, TRUE, 
                                    (edge_prop & EMED_REVERSE_CONNECT) ?
                                    p_edges1[rev_inx] : p_edges1[for_inx],
                                    comm_surf,
                                    edge_surf,
                                    &my_env->md_env),
                              targetid = p_edges0[m]);
           EMerr_hndlr(!(1& stat_OM& msg),*EMmsg,EMS_E_EdgeError, wrapup);
          }
         else
          {
           if (edge_prop & EMED_REVERSE_CONNECT)
            {
             pair_info[*num_pair_info].edge = p_edges0[m];
             pair_info[*num_pair_info].comm_edge = p_edges1[rev_inx];
             pair_info[*num_pair_info].edge_surf = comm_surf;
             pair_info[*num_pair_info].comm_edge_surf = edge_surf;
             rev_inx--;
             pair_info[*num_pair_info].align_normal = FALSE;
             (*num_pair_info)++;
            }
           else
            {
             pair_info[*num_pair_info].edge = p_edges0[m];
             pair_info[*num_pair_info].comm_edge = p_edges1[for_inx];
             pair_info[*num_pair_info].edge_surf = comm_surf;
             pair_info[*num_pair_info].comm_edge_surf = edge_surf;
             for_inx++;
             pair_info[*num_pair_info].align_normal = FALSE;
             (*num_pair_info)++;
            }
          }
        }
      }
     else
      {
       stitch_info.surf_geom0 = NULL;
       stitch_info.edge_geom0 = NULL;
       stitch_info.surf_geom1 = NULL;
       stitch_info.edge_geom1 = NULL;
       stitch_info.edge0 = in_com_edge;
       stitch_info.surf0 = comm_surf;
       stitch_info.edge1 = edge_ids[j];
       stitch_info.surf1 = edge_surf;
       stitch_info.option = EMSstitch_NoMoveSurfs;
       
       if (! auto_trim)
           stitch_info.option |= EMSstitch_NoOrientSurfs;
            
       stat_OM = om$send(msg = message EMSedge.EMstitch(&msg,
                               &stitch_info, my_env, NULL,
                               NULL, NULL, NULL, NULL),
                         targetid = in_com_edge);
       EMerr_hndlr(!(1&stat_OM&msg),*EMmsg,EMS_E_EdgeError,wrapup);
      }

     if (p_edges0) om$dealloc(ptr = p_edges0);
     if (p_edges1) om$dealloc(ptr = p_edges1);
    }
  }

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMround_execute");

 *exit_gracefully = TRUE;

 if (! (1 & stat_OM & msg))
  {

   ex$message (msgnumb = EMS_S_RecoveringModel);

 /*
  * If rounding fails, the model is always recovered. Hence exit_gracefully
  * is always TRUE
  *
  * if (! *response_taken)
  *  {
  *   EMdecide_grexit(&msg, exit_gracefully);
  *   *response_taken = TRUE;
  *  }
  */
     *response_taken = TRUE;

   
   if (*exit_gracefully)
    {
     stat_OM = om$send(msg = message EMSsfround.EMround_graceful_exit (
                             &msg, my_env, srf_GRid, &partol,
                             num_orgnl_loops, orgnl_loops, svst_info),
                       targetid = my_id);
     if (! (1 & stat_OM & msg)) *EMmsg = EMS_E_RndGrExit;
     else *EMmsg = EMS_I_RndGrExit;
    }
   else
    {
     stat_OM = OM_S_SUCCESS;
     msg = EMS_S_Success;

     stat_OM = om$send(msg = message EMSsfround.EMround_cleanup (&msg,
                             my_env, NULL, NULL),
                       targetid = my_id);

     if (! auto_trim)
      {
       edge_prop = EMED_END_ROUNDED | EMED_BEG_ROUNDED;

       for (j=0; j<num_edges; j++)
        {
         stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                 edge_prop, EMS_O_OFF),
                           targetid = my_info[j].edge_id);
         stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                 edge_prop, EMS_O_OFF),
                           senderid = my_info[j].edge_id,
                           p_chanselect = &to_common_edge);
        }
      }
    }
  }

 if(sfs_loops)
   {
   om$dealloc(ptr = sfs_loops);
   sfs_loops = NULL;
   }
 if (edge_ids) om$dealloc (ptr = edge_ids);
 if (to_disconnect) om$dealloc (ptr = to_disconnect);
 if (bndry_info) om$dealloc (ptr = bndry_info);
 if (orgnl_loops) om$dealloc(ptr = orgnl_loops);
 if( num_elems_grp )  om$dealloc( ptr = num_elems_grp );
 if( grp_closed )   om$dealloc( ptr = grp_closed );
 if( elem_rev )
 {
    for( i=0; i < num_to_impose; i++ )
       if( elem_rev[i] )  om$dealloc( ptr = elem_rev[i] );
    om$dealloc( ptr = elem_rev );
 }

 return(stat_OM);
}

/*----------------------------------------------------------------------*/

static IGRlong EMget_loop_bnds(EMmsg, loop_id, out_info, bnd_info,inst_no,
                               num_imp_loops, is_fillet, multiple_loops)

IGRlong                *EMmsg;
GRobjid                loop_id;
struct EMboundary_info **out_info,
                       *bnd_info;
IGRint                 inst_no,
                       *num_imp_loops;
IGRboolean             *is_fillet;
IGRboolean             *multiple_loops;

{
 IGRlong           stat_OM, msg;
 IGRushort lp_prop;
 IGRint            i;
 IGRint            num_out_info;

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 num_out_info = 0;

 if (*multiple_loops)
  {
   for (i=0; i<inst_no; i++)
    {
     out_info[num_out_info] = &bnd_info[i];
     num_out_info++;
    }
  }
 else
  {
   for (i=0; i<inst_no; i++)
    {
     if (IF_EQ_OBJID(loop_id, bnd_info[i].rnd_loop_id))
      {
       if (loop_id == NULL_OBJID)
        {
         stat_OM = om$send(msg = message EMSloop.EMget_props(&msg,
                                 &lp_prop),
                           senderid = NULL_OBJID,
                           targetid = bnd_info[i].loop_id);
         EMerr_hndlr(!(1&stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
         if (! (lp_prop & EMLP_ACTIVE)) continue;
        }

       out_info[num_out_info] = &bnd_info[i];
       num_out_info++;
      }
    }
  }

 if (loop_id == NULL_OBJID)
   *is_fillet = TRUE;
 else
   *is_fillet = FALSE;

 *num_imp_loops = num_out_info;

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMget_loop_bnds");
 return (stat_OM);
}         

/*---------------------------------------------------------------------*/

static IGRlong EMchange_def_info(EMmsg, num_out_loops, trim_info,
                                 partol, def_edge_changed, new_edge,
                                 old_loop, num_def_info, def_info)
IGRlong                *EMmsg;
IGRint                 num_out_loops;
struct EMSsfintedpar   **trim_info;
struct EMSpartolbasis  *partol;
IGRboolean             def_edge_changed;
GRobjid                new_edge, old_loop;
IGRint                 *num_def_info;
struct EMdef_con_info  *def_info;

{
 IGRlong         stat_OM, msg;
 OMuword         dum_os;
 IGRint          i, j;
 GRobjid         top_edge, old_edge;
 OM_S_CHANSELECT to_edges;

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 if (def_edge_changed)
  {
   stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);

   stat_OM = om$get_objid_at_index(objid = old_loop,
                                   p_chanselect = &to_edges,
                                   index = 0,
                                   objidaddr = &old_edge,
                                   osnumaddr = &dum_os);
   EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

   for (i=0; i<(*num_def_info); i++)
    {
     if (def_info[i].def_edge == old_edge)
      {
       def_info[i].def_edge = new_edge;
       break;  
      }
    }
  }

 for (i=0; i<num_out_loops; i++)
  {
   for (j=0; j<(*num_def_info); j++)
    {
     if (IF_EQ_OBJID(trim_info[i]->edgeid, def_info[j].com_edge1))
      {
       if (def_info[j].c_e1_split)
        {
         stat_OM = om$send(msg = message EMSedge.EMgettopedge (&msg,
                                 &def_info[j].ce1_param, partol,
                                 &top_edge),
                           senderid = NULL_OBJID,
                           targetid = trim_info[i]->edgeid);
         EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);
         def_info[j].com_edge1 = top_edge;
        }
      }

     if(trim_info[i]->next != NULL)
     if (IF_EQ_OBJID(trim_info[i]->next->edgeid, def_info[j].com_edge1))
      {
       if (def_info[j].c_e1_split)
        {
         stat_OM = om$send(msg = message EMSedge.EMgettopedge (&msg,
                                 &def_info[j].ce1_param, partol,
                                 &top_edge),
                           senderid = NULL_OBJID,
                           targetid = trim_info[i]->next->edgeid);
         EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);
         def_info[j].com_edge1 = top_edge;
        }
      }

     if (IF_EQ_OBJID(trim_info[i]->edgeid, def_info[j].com_edge2))
      {
       if (def_info[j].c_e2_split)
        {
         stat_OM = om$send(msg = message EMSedge.EMgettopedge (&msg,
                                 &def_info[j].ce2_param, partol,
                                 &top_edge),
                           senderid = NULL_OBJID,
                           targetid = trim_info[i]->edgeid);
         EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);
         def_info[j].com_edge2 = top_edge;
        }
      }

     if(trim_info[i]->next != NULL)
     if (IF_EQ_OBJID(trim_info[i]->next->edgeid, def_info[j].com_edge2))
      {
       if (def_info[j].c_e2_split)
        {
         stat_OM = om$send(msg = message EMSedge.EMgettopedge (&msg,
                                 &def_info[j].ce2_param, partol,
                                 &top_edge),
                           senderid = NULL_OBJID,
                           targetid = trim_info[i]->next->edgeid);
         EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);
         def_info[j].com_edge2 = top_edge;
        }
      }
    }
  }
wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMchange_def_info");
 return (stat_OM);
}

/*---------------------------------------------------------------------*/

static IGRlong  EMreevaluate_pt_in_area (EMmsg, loop_bnd_info,
                                         num_imp_loops)
IGRlong                *EMmsg;
IGRint                 num_imp_loops;
struct EMboundary_info **loop_bnd_info;

{
 IGRlong                stat_OM, msg;
 IGRint                 i;
 IGRdouble              cumulative_v, average_v;
 IGRdouble              uvbegpt[8];
 OM_S_CHANSELECT        to_edges;

 /*--------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 cumulative_v = 0.0;

 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);

 if (num_imp_loops > 4) goto wrapup;

 for (i=0; i<num_imp_loops; i++)
  {
   stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, &uvbegpt[2*i],
                           NULL, NULL, NULL, NULL),
                     senderid = loop_bnd_info[i]->loop_id,
                     p_chanselect = &to_edges,
                     from = 0,
                     to = 0);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   cumulative_v += uvbegpt[2*i + 1];
  }

 average_v = cumulative_v / num_imp_loops;

 for (i=0; i<num_imp_loops; i++)
      loop_bnd_info[i]->point_in_area[1] = average_v;

 wrapup:

  EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMreevaluate_pt_in_area");
  return (stat_OM);

}

end implementation EMSsfround;
