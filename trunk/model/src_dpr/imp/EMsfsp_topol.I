/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
#include "EMSdef.h"
#include "emsdef.h"
#include "EMSbnddef.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "OMmacros.h"
#include "emsinter.h"
#include "emssfint.h"

#define INCR_SIZE 4

extern OMuword OPP_EMSpartedge_class_id;

from EMSboundary import EMget_edges;
from EMSboundary import EMget_objid;
from EMSloop import     EMset_props;
from EMSedge import     EMsplit_twin,
                        EMsplityourself,
                        EMset_props,
                        EMget_props,
                        EMget_location,
                        EMis_parm_valid,
                        EMget_range_edges, 
			EMptatpr;
			
method EMest_split_top (IGRlong         *EMmsg;
                        IGRint          option,
                                        num_surf;
                        IGRdouble       *parms;
                        struct GRmd_env *surf_env;
                        struct GRid     insurf_GRid;
                        IGRboolean      *uv_closed;
                        GRobjid         *out_surface)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure
                - EMS_E_NoDynamicMemory - memory allocation failure
                - EMS_E_LoopsetError -- error in loopset method
                - EMS_E_EdgeError -- error in edge method 
Assumption
      
      This will work only for natural and part of natural edges

Bugs

History
	
	  gupta 	05/04/87:	design date
	                10/20/87:   modifications for new class structure and
 	                           implementation of split for composites
	  SM		14-May-88	Made modifications forced by change
					in arguments to EMSedge.EMsplityourself
    DLB 07/26/88  Added code to (re)set surface inactive bit.

Algorithm

      This method establishes the topology of a solid or dpr when
      one of its surfaces has been split into two or more surfaces.

      o Make a natural boundary on each of the split surfaces.

      o Get all the natural and non-degenerate edges of the surface
        which has been split.

      o Based on the location of these edges and the option for split
        -- in U or V
      o get the loop id of the edge
      o get the common edge and its loop id
      o if loop_id and common_loop_id are same (seam edges) -- continue
      o if the edge is a candidate whose common edge needs to be split,
       {
        get all the parameters in parms[] which fall in the range of the
        edge's end point parameters.
      o split the common edge at parameters corresponding to the above
        selected parameters. Store these split edges in 'edges'
      o connect these 'edges' for state tree.
      o get all the edges (corresponding to the edge location) which fall
        in the above range. These edges may be full (natural edge), or 
        part edges (keep_beg_part, keep_end_part or keep_mid_part). These
        edges (keep_ ....) are split at appropriate parameters and the
        portion corresponding to the name are saved in patch_edges[3].
      o connect 'edges' with full_edge, patch_edges[]
       }
       else
       {
      o construct and copy the edge
      o replace the counterpart on the split surface's (will be either
        the first or the last surface) loop by the above copy
      o construct and copy the common edge
      o replace the common edge with its copy in its loop
      o connect the common edge copy for state tree
       }      
      o connect the split surface edges which were not split amongst
        themselves. Connect the common edge copies with the edge copies.
      o connect the split surfaces and the surface which was split, for
        state tree and set the display and locate bits ON/OFF for these
        surfaces
              
*/
                   
{
  IGRlong               stat_OM,msg,msg1;
  IGRushort     edge_prop;
  OMuword               edge_class_id;
  IGRshort              pos;
  IGRint                num_bytes, chan_inx, split_num;
  IGRint                insurf_edge_num, num_parm, i, j;
  IGRint                arr_size, num_valid_parms, num_full_edge;
  IGRint                sel_ord, spl_loc, foo, sav_loc;
  IGRint                EMsend_loops();
  OMuint                c_e_count, edge_index, cnt_inc, count;
  IGRdouble             *valid_parms;
  IGRboolean            rever;
  IGRboolean            ind0, ind1, repeat_loc;
  GRobjid               *full_edge, keep_beg_edge, keep_end_edge,
                        keep_mid_edge;
  GRobjid               p1_loop_id, loop_id, comm_loop_id;
  GRobjid               partb_edge[2], parte_edge[2], patch_edges[3];
  GRobjid               (*pch_edge_ids)[4];
  GRobjid               *edges, sav_loop_id, act_loop_id;
  GRobjid               *insurf_edge_copy, *comm_edge_copy;
  struct GRid           *insurf_edges, temp_id;
  struct EMSpartolbasis my_tol_info;
  struct EMSedgebound   parme,
                        parmb;
  OM_S_CHANSELECT       to_owner,
                        to_loopset,
                        to_edge_s,
                        to_comm_edge,
                        to_cpx,
                        to_comps;
  OM_S_OBJECT_LINKAGE   insurf_owner,
                        comm_edge_list;
  struct EMSsfintedpar	split_info, *split_info_ptr[2];

/*-----------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  split_info_ptr[0] = &split_info;
  split_info_ptr[1] = NULL;
  split_info.info = NULL;
  split_info.next = NULL;

  sav_loc = 99;
  num_parm = num_surf-1;
  insurf_edge_num = 0;
  arr_size = 0;
  ind0 = ind1 = FALSE;
  spl_loc = UNKNOWN;
  edges = NULL;
  full_edge = NULL;
  comm_edge_copy = NULL;
  insurf_edge_copy = NULL;
  chan_inx = 2;

  temp_id.objid = my_id;
  temp_id.osnum = OM_Gw_current_OS;

  my_tol_info.tol = NULL;
  my_tol_info.is_valid = FALSE;
  my_tol_info.in_world = FALSE;
  my_tol_info.mattyp = &surf_env->md_env.matrix_type;
  my_tol_info.mat = surf_env->md_env.matrix;

  /* memory allocation for edges */

  num_bytes =  num_surf * (sizeof (GRobjid));  

  pch_edge_ids = (GRobjid (*)[4]) om$malloc(size = 4*num_bytes);
  edges = (GRobjid *) om$malloc(size = num_bytes);
  full_edge = (GRobjid *) om$malloc(size = num_bytes);

  EMerr_hndlr(! pch_edge_ids || ! edges || ! full_edge, *EMmsg,
              EMS_E_NoDynamicMemory, wrapup);
 
  /* initialize edges */

  for (i=0; i<num_surf; i++)
   {
    edges[i] = NULL_OBJID;
    full_edge[i] = NULL_OBJID;
   }
  for (i=0; i<2; i++);
   {
    partb_edge[i] = NULL_OBJID;
    parte_edge[i] = NULL_OBJID;
   }

  /* channel selectors */

  stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  if (! (1 & stat_OM)) goto wrapup;

  stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edge_s);
  if (! (1 & stat_OM)) goto wrapup;

  stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
  if (! (1 & stat_OM)) goto wrapup;

  stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
  if (! (1 & stat_OM)) goto wrapup;

  stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_comm_edge);
  if (! (1 & stat_OM)) goto wrapup;
  
  stat_OM = EMmake_chanselect (GRconnector_to_owners, &to_cpx);
  if (! (1 & stat_OM)) goto wrapup;

  /* make topology (natural boundary) for the split surfaces */

  for (i=0; i<num_surf; i++)
    {
     /* construct the natural boundary for the surface patch */

     stat_OM = om$send (msg = message EMSsurface.EMmk_nat_bdry(&msg,
                              &surf_env->md_env, &pch_edge_ids[i][0]),
                        targetid = out_surface[i]);
     EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMmk_nat_bdry");
     EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_LoopsetError, wrapup);
   }

  /* get the edge ids which are natural and non-degenerate */

  stat_OM = om$send(msg = message EMSboundary.EMget_edges(&msg,
                          MAXINT, EMS_OPT_NATURAL_NONDEG, &insurf_edges, 
                          &arr_size, &insurf_edge_num),
                    senderid = insurf_GRid.objid,
                    p_chanselect = &to_loopset);
  EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMget_edges");
  EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

  arr_size = 0;

  /* get the edge's active loop_id */
       
  stat_OM = EMsend_loops(&msg,
                     message EMSboundary.EMget_objid (&msg1,
                     &loop_id), insurf_edges[0].objid, 0, OM_K_MAXINT,
                     EMLP_ACTIVE, NULL, NULL);
  EMerr_hndlr(EMis_error(msg1), *EMmsg, msg, wrapup);
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

  for (i=0; i<insurf_edge_num; i++)
   {
    split_num = 0;
    num_full_edge = 0;
  
    for (j=0; j<3; j++)
         patch_edges[j] = NULL_OBJID;

    if (! ((arr_size) % INCR_SIZE))
     {
      if (! arr_size)
       {
        comm_edge_copy = (GRobjid *) om$malloc (size = INCR_SIZE *
                                     sizeof(GRobjid));
        insurf_edge_copy = (GRobjid *) om$malloc (size = INCR_SIZE *
                                     sizeof(GRobjid));
       }
      else
       {
        comm_edge_copy = (GRobjid *) om$realloc 
        		(ptr = (IGRchar *) comm_edge_copy,
                         size = (arr_size + INCR_SIZE) * sizeof(GRobjid));
        insurf_edge_copy = (GRobjid *) om$realloc 
        		(ptr = (IGRchar *) insurf_edge_copy,
                         size = (arr_size + INCR_SIZE) * sizeof(GRobjid));
       }
     }

    stat_OM = om$send(msg = message EMSedge.EMget_location(&msg, &pos),
                      targetid = insurf_edges[i].objid,
                      targetos = insurf_edges[i].osnum);
    EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMget_location");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
   
    repeat_loc = (pos == sav_loc) ? TRUE : FALSE;
    sav_loc = pos;
 
    /* get the edge's common edge */
      
    stat_OM = om$get_channel_count (osnum = insurf_edges[i].osnum,
                                    objid = insurf_edges[i].objid,
                                    p_chanselect = &to_comm_edge,
                                    count = &c_e_count);
    EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.get_chan_count");

    if (! c_e_count)
        continue;

    stat_OM = om$get_channel_objects(osnum = insurf_edges[i].osnum,
                                     objid = insurf_edges[i].objid,
                                     p_chanselect = &to_comm_edge,
                                     list = &comm_edge_list,
                                     size = c_e_count,
                                     count = &count);
    EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.get_chan_objs");
    if (count != c_e_count)
        return EMS_E_ChanCountWrong;

    /* get the common edge's active loop_id */
       
    stat_OM = EMsend_loops(&msg,
                       message EMSboundary.EMget_objid (&msg1,
                       &comm_loop_id), comm_edge_list.S_objid, 0,
                       OM_K_MAXINT, EMLP_ACTIVE, NULL,NULL);
    EMerr_hndlr(EMis_error(msg1), *EMmsg, msg, wrapup);
    EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

    /* if seam edges -- do nothing */

    if (IF_EQ_OBJID (loop_id, comm_loop_id))
       {
        continue;
       }

      if (((option == 0) && (pos == 1 || pos == 3)) ||
          ((option == 1) && (pos == 0 || pos == 2)))
       {
        /* get all the parameters valid for this edge */
        
        stat_OM = om$send(msg = message EMSedge.EMis_parm_valid (
                                &msg, pos, num_parm, parms,
                                &num_valid_parms, &valid_parms),
                          targetid = insurf_edges[i].objid,
                          targetos = insurf_edges[i].osnum); 
        EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMis_parm_valid");
        EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

        if (! num_valid_parms)
         {
          /*
           * this indicates that the parameters do not fall in the range
           * of the common edge and a split should not be performed,
           * hence, copy the common edge and replace the copy into its 
           * loop
           */

          stat_OM = om$construct_and_copy(
                                     osnum = comm_edge_list.osnum,
                                     objid = comm_edge_list.S_objid,
                                     p_objid = &edges[0]);
          EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.construct_copy");
        
          /* get class id of comm_edge id  and move the to_edge channel
           * only if it is a part edge
           */
          
          stat_OM = om$get_classid(objid = comm_edge_list.S_objid,
                                   p_classid = &edge_class_id);
          if (! (1 & stat_OM)) goto wrapup;

          stat_OM = om$is_ancestry_valid (subclassid = edge_class_id,
                            superclassid = OPP_EMSpartedge_class_id);
          if (stat_OM == OM_S_SUCCESS)
           {
            stat_OM = om$send(msg = message Root.move_chan(to_edge_s,
                                    comm_edge_list.S_objid,
                                    OM_Gw_current_OS, to_edge_s),
                              targetid = edges[0]);
            EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.move_chan");
           }
          else if (stat_OM == OM_I_INVANCESTRY)
           {stat_OM = OM_S_SUCCESS;}

          stat_OM = EMsend_loops(&msg,
                         message EMSboundary.EMget_objid (&msg1,
                         &act_loop_id), comm_edge_list.S_objid, 0,
                         OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
          EMerr_hndlr(EMis_error(msg1), *EMmsg, msg, wrapup);
          EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

          stat_OM = om$get_index(osnum_c = OM_Gw_current_OS,
                                 objid_c = act_loop_id,
                                 p_chanselect = &to_edge_s,
                                 objid = comm_edge_list.S_objid,
                                 indexaddr = &edge_index);
          EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.get_index");

          stat_OM = om$send (msg = message Root.disconnect (to_edge_s,
                                   comm_edge_list.S_objid,
                                   OM_Gw_current_OS, to_owner),
                             senderid = comm_edge_list.S_objid,
                             targetid = act_loop_id);
          EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_topol.disconnect");

          stat_OM = om$send (msg = message Root.connect (to_edge_s,
                                   0, edges[0], OM_Gw_current_OS,
                                   to_owner, edge_index),
                             targetid = act_loop_id);
          EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_topol.connect");

/*****************
            stat_OM = om$send(msg = message Root.move_chan(to_owner,
                                    comm_edge_list.S_objid,
                                    OM_Gw_current_OS, to_owner),
                              targetid = edges[0]);
            EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.move_chan");
*****************/
         }
        /*
         * split the common edge at its corresponding parameters.
         * 'edges' has all the part edge ids resulting from splitting
         * the common edge 
         */ 

        stat_OM = om$send(msg = message EMSedge.EMsplit_twin(
                                &msg, num_valid_parms, surf_env,
                                valid_parms, &split_num, edges, &rever),
                          targetid = insurf_edges[i].objid,
                          targetos = insurf_edges[i].osnum); 
        EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMsplit_twin");
        EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);

        if (! num_valid_parms)
            split_num = 1;

        if (split_num > 1)
         {
          stat_OM = om$send(msg = message EMSloop.EMset_props(&msg,
                                  EMLP_NATURAL, EMS_O_OFF),
                            targetid = comm_loop_id);
          EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMset_props");
          EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
         }
   
        /*
         * connect the above part edges appropriately for state tree 
         */

        if (((pos == 0 || pos == 1) && (rever)) ||
            ((pos == 2 || pos == 3) && (! rever)))
          sel_ord = split_num - 1;
        else
          sel_ord = 0;

        if (split_num >= 1)
         {
          stat_OM = OM_SET_DIMENSION(ME.EMSdpr->ids, chan_inx+split_num);
          for (j = chan_inx; j < (chan_inx+split_num); j++)
           {
            ME.EMSdpr->ids[j] = edges[sel_ord]; 

            if (((pos == 0 || pos == 1) && (rever)) ||
                ((pos == 2 || pos == 3) && (! rever)))
                  sel_ord--;
            else
                  sel_ord++;
           }
          chan_inx += split_num;
         }
     
        /* 
         * get all the split surface's edge ids corresponding to the
         * location of insurf_edges[i] and falling within its 
         * parametric range 
         */       

        stat_OM = om$send(msg = message EMSedge.EMget_range_edges (
                                &msg, surf_env, pos, num_parm, parms,
                                pch_edge_ids,partb_edge[1],&num_full_edge,
                                full_edge, &keep_end_edge, &keep_beg_edge,
                                &keep_mid_edge, &parme, &parmb),
                          targetid = insurf_edges[i].objid,
                          targetos = insurf_edges[i].osnum); 
        EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMget_range_edges");
        EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);

        /*
         * this is the case where the begin point of the split surface
         * edge comes before insurf_edges[i] begin point and the end
         * point of the split surface edge falls after insurf_edges[i]
         * end point 
         */ 
     
        if (! IF_NULL_OBJID (keep_mid_edge))
         {
          split_info.edgeid = partb_edge[1];
          split_info.edgepar = parmb;
          split_info.intloc = EMScvint_unknown;
          stat_OM = om$send(msg = message EMSedge.EMptatpr(&msg, 1,
                          &parmb, NULL, split_info.point),
                          targetid = partb_edge[1]);
          EMerr_hndlr(!(1&msg&stat_OM), *EMmsg, EMS_E_EdgeError, wrapup);

          stat_OM = om$send(msg = message EMSedge.EMsplityourself(&msg,
                                  split_info_ptr, NULL, NULL, parte_edge,
                                  NULL, NULL, NULL,
                                  &my_tol_info, surf_env, NULL, NULL, NULL),
                            targetid = partb_edge[1]);
          EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMsplityourself");
          EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
       
          patch_edges[2] = parte_edge[0];
          partb_edge[1] = parte_edge[1];
          ind0 = TRUE;
          if (! IF_NULL_OBJID(parte_edge[0]))
           {
            stat_OM = EMsend_loops(&msg,
                               message EMSboundary.EMget_objid (&msg1,
                               &p1_loop_id), parte_edge[0], 0,
                               OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
            EMerr_hndlr(EMis_error(msg1), *EMmsg, msg, wrapup);
            EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

            stat_OM = om$send(msg = message EMSloop.EMset_props(&msg,
                                    EMLP_NATURAL, EMS_O_OFF),
                              targetid = p1_loop_id);
            EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMset_props");
            EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
           }
          goto make_connections;                           
         }

        /*
         * this is the case where the end point of insurf_edges[i]
         * lies somewhere between the begin point and the end point
         * of split surface edge.
         */ 

        if (! IF_NULL_OBJID (keep_end_edge) && ind0 == FALSE)
         {
          split_info.edgeid = keep_end_edge;
          split_info.edgepar = parme;
          split_info.intloc = EMScvint_unknown;
          stat_OM = om$send(msg = message EMSedge.EMptatpr(&msg, 1,
                          &parme, NULL, split_info.point),
                          targetid = keep_end_edge);
          EMerr_hndlr(!(1&msg&stat_OM), *EMmsg, EMS_E_EdgeError, wrapup);

          stat_OM = om$send(msg = message EMSedge.EMsplityourself(&msg,
                                  split_info_ptr, NULL, NULL, parte_edge,
                                  NULL, NULL, NULL,
                                  &my_tol_info, surf_env, NULL, NULL, NULL),
                            targetid = keep_end_edge);
          EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMsplityourself");
          EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
       
          patch_edges[0] = parte_edge[0];
          ind1 = TRUE;

          if (! IF_NULL_OBJID(parte_edge[0]))
           {
            stat_OM = EMsend_loops(&msg,
                               message EMSboundary.EMget_objid (&msg1,
                               &p1_loop_id), parte_edge[0], 0,
                               OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
            EMerr_hndlr(EMis_error(msg1), *EMmsg, msg, wrapup);
            EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

            stat_OM = om$send(msg = message EMSloop.EMset_props(&msg,
                                    EMLP_NATURAL, EMS_O_OFF),
                              targetid = p1_loop_id);
            EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMset_props");
            EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
           }
         }
        else if (ind0 == TRUE)
         {
          patch_edges[0] = partb_edge[1];
         }
        else
         {
          patch_edges[0] = NULL_OBJID;
          ind1 = FALSE;
         }

        /*
         * this is the case where the begin point of insurf_edges[i]
         * lies somewhere between the begin point and the end point
         * of split surface edge.
         */ 

        if (! IF_NULL_OBJID (keep_beg_edge) && ind1 == FALSE)
         {
          split_info.edgeid = keep_beg_edge;
          split_info.edgepar = parmb;
          split_info.intloc = EMScvint_unknown;
          stat_OM = om$send(msg = message EMSedge.EMptatpr(&msg, 1,
                          &parmb, NULL, split_info.point),
                          targetid = keep_beg_edge);
          EMerr_hndlr(!(1&msg&stat_OM), *EMmsg, EMS_E_EdgeError, wrapup);

          stat_OM = om$send(msg = message EMSedge.EMsplityourself(&msg,
                                  split_info_ptr, NULL, NULL, partb_edge,
                                  NULL, NULL, NULL,
                                  &my_tol_info, surf_env, NULL, NULL, NULL),
                            targetid = keep_beg_edge);
          EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMsplityourself");
          EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
       
          patch_edges[1] = partb_edge[0];
          ind0 = TRUE;
          if (! IF_NULL_OBJID(partb_edge[0]))
           {
            stat_OM = EMsend_loops(&msg,
                               message EMSboundary.EMget_objid (&msg1,
                               &p1_loop_id), partb_edge[0], 0,
                               OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
            EMerr_hndlr(EMis_error(msg1), *EMmsg, msg, wrapup);
            EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

            stat_OM = om$send(msg = message EMSloop.EMset_props(&msg,
                                    EMLP_NATURAL, EMS_O_OFF),
                              targetid = p1_loop_id);
            EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMset_props");
            EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
           }
         }
        else if (ind1 == TRUE)
         {
          patch_edges[1] = parte_edge[1];
         }
        else
         {
          patch_edges[1] = NULL_OBJID;
          ind0 = FALSE;
         }

        /*
         * At this point I have all the part edges of the common edge in
         * 'edges' and the stack of split surface edge's which is stored
         * in full_edge or patch_edges[]. full_edge represent the complete
         * split surface edge and patch_edges[] has the part edges of
         * split surface edges. Make the connections for common edge
         * between 'edges' AND 'full_edge, patch_edges[]'.
         */ 

make_connections:

        EMconn_split_edges (&msg, split_num, option, edges, patch_edges,
                            full_edge, num_full_edge, rever, pos, 
                            uv_closed);
        EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

       } /** if option == 0 --------- || if option == 1 **/

      /*
       * process the edges which do not cause a split in the common
       * edge. These are the left or right side edges and only edges
       * of the first and last split surfaces are concerned here
       */

      if (((option == 0) && (pos == 0 || pos == 2)) ||
          ((option == 1) && (pos == 1 || pos == 3)))
       {
        foo = (pos == 0 || pos == 3) ? 0 : (num_surf-1);
       
        stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                                &edge_prop),
                          targetid = insurf_edges[i].objid,
                          targetos = insurf_edges[i].osnum);
        EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMset_props");
        EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
           
        stat_OM = om$construct_and_copy(
                          osnum = insurf_edges[i].osnum,
                          objid = insurf_edges[i].objid,
                          p_objid = &insurf_edge_copy[arr_size]);
        EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.construct_copy");
 
        if (edge_prop & EMED_REVERSE_CONNECT)
         {
          stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                  EMED_REVERSE_CONNECT, EMS_O_ON),
                            targetid = insurf_edge_copy[arr_size]);
          EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.EMset_props");
          EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
         }

          /* get class id of insurf_edge id  and move the to_edge channel
           * only if it is a part edge
           */
          
          stat_OM = om$get_classid(objid = insurf_edges[i].objid,
                                   p_classid = &edge_class_id);
          if (! (1 & stat_OM)) goto wrapup;

          stat_OM = om$is_ancestry_valid (subclassid = edge_class_id,
                            superclassid = OPP_EMSpartedge_class_id);
          if (stat_OM == OM_S_SUCCESS)
           {
            stat_OM = om$send(msg = message Root.move_chan(to_edge_s,
                                    insurf_edges[i].objid,
                                    OM_Gw_current_OS, to_edge_s),
                              targetid = insurf_edge_copy[arr_size]);
            EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.move_chan");

            stat_OM = OM_SET_DIMENSION(ME.EMSdpr->ids, chan_inx+2);
            ME.EMSdpr->ids[chan_inx] = insurf_edge_copy[arr_size];
            ME.EMSdpr->ids[chan_inx+1] = insurf_edges[i].objid;

            chan_inx +=2;
           }
          else if (stat_OM == OM_I_INVANCESTRY)
           {stat_OM = OM_S_SUCCESS;}

         if (repeat_loc)
          {
           stat_OM = EMsend_loops(&msg,
                       message EMSboundary.EMget_objid (&msg1,
                       &sav_loop_id), insurf_edge_copy[arr_size-1], 0,
                       OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
           EMerr_hndlr(EMis_error(msg1), *EMmsg, msg, wrapup);
           EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

           stat_OM = om$get_index(osnum_c = OM_Gw_current_OS,
                                  objid_c = sav_loop_id,
                                  p_chanselect = &to_edge_s,
                                  objid = insurf_edge_copy[arr_size-1],
                                  indexaddr = &cnt_inc);
           EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.get_index");

           stat_OM = om$send (msg = message Root.connect (to_owner,
                                    cnt_inc+1, sav_loop_id,
                                    OM_Gw_current_OS, to_edge_s, NULL),
                              targetid = insurf_edge_copy[arr_size]);
           EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.connect");
          }
         else
          {
           stat_OM = om$send(msg = message Root.move_chan(to_owner,
                                   pch_edge_ids[foo][pos],
                                   OM_Gw_current_OS, to_owner),
                             targetid = insurf_edge_copy[arr_size]);
           EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.move_cahn");
          }
          stat_OM = om$construct_and_copy(
                                   osnum = comm_edge_list.osnum,
                                   objid = comm_edge_list.S_objid,
                                   p_objid = &comm_edge_copy[arr_size]);
          EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.construct_copy");

          /* get class id of comm_edge id  and move the to_edge channel
           * only if it is a part edge
           */
          
          stat_OM = om$get_classid(objid = comm_edge_list.S_objid,
                                   p_classid = &edge_class_id);
          if (! (1 & stat_OM)) goto wrapup;

          stat_OM = om$is_ancestry_valid (subclassid = edge_class_id,
                            superclassid = OPP_EMSpartedge_class_id);
          if (stat_OM == OM_S_SUCCESS)
           {
            stat_OM = om$send(msg = message Root.move_chan(to_edge_s,
                                   comm_edge_list.S_objid,
                                   OM_Gw_current_OS, to_edge_s),
                             targetid = comm_edge_copy[arr_size]);
            EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.move_chan");
           }
          else if (stat_OM == OM_I_INVANCESTRY)
           {stat_OM = OM_S_SUCCESS;}

          stat_OM = EMsend_loops(&msg,
                         message EMSboundary.EMget_objid (&msg1,
                         &act_loop_id), comm_edge_list.S_objid, 0,
                         OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
          EMerr_hndlr(EMis_error(msg1), *EMmsg, msg, wrapup);
          EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

          stat_OM = om$get_index(osnum_c = OM_Gw_current_OS,
                                 objid_c = act_loop_id,
                                 p_chanselect = &to_edge_s,
                                 objid = comm_edge_list.S_objid,
                                 indexaddr = &edge_index);
          EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.get_index");

          stat_OM = om$send (msg = message Root.disconnect (to_edge_s,
                                   comm_edge_list.S_objid,
                                   OM_Gw_current_OS, to_owner),
                             senderid = comm_edge_list.S_objid,
                             targetid = act_loop_id);
          EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_topol.disconnect");

          stat_OM = om$send (msg = message Root.connect (to_edge_s,
                                   0, comm_edge_copy[arr_size],
                                  OM_Gw_current_OS, to_owner, edge_index),
                             targetid = act_loop_id);
          EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_topol.connect");

/********************
          stat_OM = om$send(msg = message Root.move_chan(to_owner,
                                  comm_edge_list.S_objid,
                                  OM_Gw_current_OS, to_owner),
                            targetid = comm_edge_copy[arr_size]);
          EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.move_chan");
************************/

        /*
         * connect the comm_edge_copy to appropriate channels for
         * state tree
         */

        stat_OM = OM_SET_DIMENSION(ME.EMSdpr->ids, chan_inx+1);
        ME.EMSdpr->ids[chan_inx] = comm_edge_copy[arr_size];

        chan_inx += 1;

        arr_size++;
 
       }            

      /* connect the common edge for state tree */

      stat_OM = OM_SET_DIMENSION(ME.EMSdpr->ids, chan_inx+1);
      ME.EMSdpr->ids[chan_inx] = comm_edge_list.S_objid;
      chan_inx += 1;
  }

  /*
   * connect the comm_edge_copy, insurf_edge_copy, and interior edges
   * of the split surfaces
   */
  
  EMconn_unsplit_edges(&msg, num_surf, option, pch_edge_ids, arr_size,
                       comm_edge_copy, insurf_edge_copy, uv_closed);
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

  /* connect the insurf and split surfaces for state tree */

  if (num_surf > 1)
   {
    /* get the owner of incoming surface - should be a composite */

    stat_OM = om$get_channel_objects(osnum = insurf_GRid.osnum,
                                     objid = insurf_GRid.objid,
                                     p_chanselect = &to_cpx,
                                     list = &insurf_owner,
                                     size = 1,
                                     count = &count);
    EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.get_chan_objs");

    EMerr_hndlr((count != 1), *EMmsg, EMS_E_ChanCountWrong, wrapup);

    /*************************DLB ADDITION*************************/
    {
      IGRint  vla_size;   /*DECLARE*/

      vla_size = om$dimension_of(varray = ME.EMSdpr->ids);

      if (vla_size < 2) 
         stat_OM = om$vla_set_dimension(varray = ME.EMSdpr->ids, size = 2);
      EMerr_hndlr((!(1&stat_OM)), *EMmsg, EMS_E_NoDynamicMemory, wrapup); 
    }
    /***************************************************************/

    ME.EMSdpr->ids[0] = insurf_owner.S_objid;
    ME.EMSdpr->ids[1] = insurf_GRid.objid;

    for (i=0; i<num_surf; i++)
     {
      stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg,
                               &temp_id, (IGRlong *) &i),
                         targetid = out_surface[i],
                         targetos = OM_Gw_current_OS);
      EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_topol.GRrigidconn");
     }
  }

   /* deactivate the incoming surface (which has been split) */

   temp_id.objid = insurf_owner.S_objid;
   temp_id.osnum = insurf_owner.osnum;

   /************************DLB ADDITION*******************/
   /*Get the owner to component (surf in this case) index.*/
   stat_OM = om$get_index(objid_c = temp_id.objid,
                          p_chanselect = &to_comps,
                          objid = insurf_GRid.objid,
                          indexaddr = (OMuint *) &ME.EMSsfsplit->owner_index);
   EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.get_index");   
   /*******************************************************/

   stat_OM = om$send (msg = message GRconnector.GRdisconn (&msg,
                            &temp_id),
                      senderid = insurf_owner.S_objid,
                      targetid = insurf_GRid.objid,
                      targetos = insurf_GRid.osnum);
   EMomerr_hndlr(stat_OM, wrapup, "EMslsp_topol.disconnect");

   EFsetsfstate(&msg, insurf_GRid.objid, insurf_GRid.osnum, EMS_O_OFF);
   EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

   /* activate the split faces */

      for (i=0; i<num_surf; i++)
         {
          EFsetsfstate(&msg, out_surface[i], OM_Gw_current_OS, EMS_O_ON);
          EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);
         }
wrapup:

   if(edges) om$dealloc(ptr = edges);
   if(full_edge) om$dealloc(ptr = full_edge);
   if(pch_edge_ids) om$dealloc(ptr = pch_edge_ids);
   if(comm_edge_copy) om$dealloc(ptr = comm_edge_copy);
   if(insurf_edge_copy) om$dealloc(ptr = insurf_edge_copy);

   return(stat_OM);
}

end implementation EMSsfsplit;
