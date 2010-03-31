/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/
#include "EMSopt.h"
     
#define DEBUG 0

from EMSboundary import EMget_edges,EMgetsurface_info, EMget_objid;
from EMSloop import EMget_props;

#define AFF_BY_LPIN_BUFF_INCR 50 /*guess of # loops in of set 1 node.*/
#define OUT_INFO_BUFF_INCR 50    /*guess of size of comed info stuff.*/

struct affect_struct
{
  GRobjid loop_in;          /*The loop in on the surf.*/
  GRobjid surf_mod;         /*The surf mod doe to loop in.*/
  IGRint  num_nodes;        /*The num nodes causing the loop in.*/
  GRobjid *nodes;           /*The nodes causing the loop in.*/
  IGRint  num_loop_out;     /*The num loops out due to the loop in.*/
  GRobjid *loop_out;        /*The loops out due to the loop in.*/
};

struct loop_out_struct
{
  GRobjid surf_mod;       /*The surface modified due to the loop out.*/
  GRobjid loop_out;       /*The loop out due to a com edge loop out.*/
};

static void EFget_parent(EMmsg, comm_edge, comm_surf, comm_loop, ssi_info,
                         belongs_to_out_surface)
IGRlong                 *EMmsg;
GRobjid                 comm_edge;
GRobjid                 *comm_surf;
GRobjid                 *comm_loop;
struct EMSboolssi_table *ssi_info;
IGRboolean              *belongs_to_out_surface;
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            ii, jj, kk, lpout_index;
  OMuint            edge_owner_cnt;
  OM_S_CHANSELECT   to_owner;
  IGRushort lpprops;
  IGRboolean        EFisAncestryValid();


  *EMmsg = EMS_S_Success;    

  *comm_surf = NULL_OBJID;
  *comm_loop = NULL_OBJID;
  *belongs_to_out_surface = FALSE;

  EMmake_chanselect(EMSedge_to_owner, &to_owner);
  OM_stat = om$get_channel_count(objid = comm_edge,
                                 p_chanselect = &to_owner,
                                 count = &edge_owner_cnt);
  if (!(1 & OM_stat)) goto wrapup;

  for(ii=0; ii<edge_owner_cnt; ii++)
  {
    OM_stat = om$send(msg = message EMSboundary.EMget_objid(EMmsg,
                            comm_loop),
                      senderid = comm_edge,
                      p_chanselect = &to_owner,
                      from = ii,
                      to = ii);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    /*In the following message send an OM bug exists.  Although I specify
     * EMSloop as the class defining the message, it will be delivered 
     * successfully to a partedge.  I believe this occurs because the
     * EMget_props message is also declared at the EMSedge class and OM
     * doesn't look at the defining class when sending wrt object.  Because of
     * this problem I must make sure that the object returned is a loop.
     */
    if (! EFisAncestryValid(EMmsg, *comm_loop, OM_Gw_current_OS, 
                            OPP_EMSloop_class_id, FALSE) ) 
    {
      *comm_loop = NULL_OBJID;
      continue;
    }

    OM_stat = om$send(msg = message EMSloop.EMget_props(EMmsg, &lpprops),
                      senderid = NULL_OBJID,
                      targetid = *comm_loop);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (!(lpprops & EMLP_ACTIVE))
    {
      /*Got an inactive loop so see if this one is in the loop out list.*/
      lpout_index = 0;
      for(jj=0; jj<ssi_info->num_surfaces; jj++)
      {
        for(kk=0; kk<ssi_info->num_regions_out[jj]; kk++, lpout_index++)
        {
          if (ssi_info->region_out_ids[lpout_index] == *comm_loop) break;
        }
        if (kk != ssi_info->num_regions_out[jj]) break;
      }

      if (jj != ssi_info->num_surfaces)
      {
        /*This loop is removed so the current surface is the comm surf.*/
        *comm_surf = ssi_info->surface_ids[jj];
        break;
      }
      else
      {
        /*This loop is not removed so see if it belongs to a surf removed.*/
        *comm_surf = NULL_OBJID;
        OM_stat = om$send(msg = message EMSboundary.EMgetsurface_info(
                                EMmsg, comm_surf, NULL),
                          senderid = NULL_OBJID,
                          targetid = *comm_loop);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        if (*comm_surf != NULL_OBJID) 
        {
          *belongs_to_out_surface = TRUE;
          break;
        }
      }
    }
    else
    {
      *comm_loop = NULL_OBJID;
    }
  }  

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EFget_parent")
    return;
}  

static void EFget_comed_out_info(EMmsg, ref_loop_out, loop_out_cnt, loop_out,
                                 surf_out_cnt, surf_out, ssi_info,
                                 this_side_loop_out_cnt, this_side_loop_out,
                                 other_side_loop_out_cnt, other_side_loop_out)
IGRlong                 *EMmsg;
GRobjid                 ref_loop_out;
IGRint                  *loop_out_cnt;
struct loop_out_struct  **loop_out;
IGRint                  *surf_out_cnt;
GRobjid                 **surf_out;
struct EMSboolssi_table *ssi_info;
IGRint                  this_side_loop_out_cnt;
GRobjid                 *this_side_loop_out;
IGRint                  other_side_loop_out_cnt;
GRobjid                 *other_side_loop_out;
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  IGRint          ii, jj;
  IGRint          edge_cnt, edge_buff_size;
  GRobjid         comm_surf, comm_edge, comm_loop;
  struct GRid     *edge;
  OM_S_CHANSELECT to_common_edge;
  IGRboolean      belongs_to_out_surface;


  *EMmsg = EMS_S_Success;

  edge_cnt = 0;
  edge_buff_size = 0;
  edge = NULL;
  OM_stat = om$send(msg = message EMSboundary.EMget_edges(EMmsg,
                          1, EMS_OPT_STITCHED, &edge, 
                          &edge_buff_size, &edge_cnt),
                    senderid = NULL_OBJID,
                    targetid = ref_loop_out);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  EMmake_chanselect(EMSedge_to_common_edge, &to_common_edge);

  for(ii=0; ii<edge_cnt; ii++)
  {
    /*Get this edges common edge.*/
    OM_stat = om$send(msg = message EMSboundary.EMget_objid(EMmsg,
                            &comm_edge),
                      senderid = edge[ii].objid,
                      p_chanselect = &to_common_edge);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    comm_surf = NULL_OBJID;
    comm_loop = NULL_OBJID;
    EFget_parent(EMmsg, comm_edge, &comm_surf, &comm_loop, ssi_info, 
                 &belongs_to_out_surface);
    if (!(1 & *EMmsg)) goto wrapup;

    if (comm_loop == NULL_OBJID)
    {
      /*The common edge does not have a loop out due to this state.*/
      continue;
    }

    if (belongs_to_out_surface)
    {
      /*Got a common edge that belongs to a surface removed.*/

      /*See if already have surface out.*/
      for(jj=0; jj<*surf_out_cnt; jj++)
      {
        if (comm_surf == (*surf_out)[jj]) break;
      }

      if (jj == *surf_out_cnt)
      {
        /*Nope so store the surface removed.*/
        EFrealloc_if_needed(EMmsg, surf_out, *surf_out_cnt, 
                            OUT_INFO_BUFF_INCR, sizeof(GRobjid)); 
        if (!(1 & *EMmsg)) goto wrapup;
    
        (*surf_out)[*surf_out_cnt] = comm_surf;
        (*surf_out_cnt)++;

        /*Recurse on the loop owning the edge and belonging to the removed
         * surface.
         */ 
        EFget_comed_out_info(EMmsg, comm_loop, loop_out_cnt, loop_out,
                             surf_out_cnt, surf_out, ssi_info,
                             this_side_loop_out_cnt, this_side_loop_out,
                             other_side_loop_out_cnt, other_side_loop_out);
        if (!(1 & *EMmsg)) goto wrapup;
      }
    }
    else
    {
      /*Got a common edge that belongs to a loop removed.*/

      /*See if already have the loop out.*/
      for(jj=0; jj<*loop_out_cnt; jj++)
      {
        if (comm_loop == (*loop_out)[jj].loop_out) break;
      }

      if (jj == *loop_out_cnt)
      {
        /*Its not in the list being gathered currently.*/
        for(jj=0; jj<this_side_loop_out_cnt; jj++)
        {
          if (comm_loop == this_side_loop_out[jj]) break;
        }

        if (jj == this_side_loop_out_cnt)
        {
          /*Its not in this side list.*/
          for(jj=0; jj<other_side_loop_out_cnt; jj++)
          {
            if (comm_loop == other_side_loop_out[jj]) break;
          }

          if (jj == other_side_loop_out_cnt)
          {
            /*Its not in the other side list either so store the loop
             * removed.
             */ 
            EFrealloc_if_needed(EMmsg, loop_out, *loop_out_cnt, 
                                OUT_INFO_BUFF_INCR, 
                                sizeof(struct loop_out_struct)); 
            if (!(1 & *EMmsg)) goto wrapup;
    
            /*Store the surface mod and the loop out.*/
            (*loop_out)[*loop_out_cnt].surf_mod = comm_surf;
            (*loop_out)[*loop_out_cnt].loop_out = comm_loop;
            (*loop_out_cnt)++;

            /*Recurse on the found loop.*/
            EFget_comed_out_info(EMmsg, comm_loop, loop_out_cnt, loop_out,
                               surf_out_cnt, surf_out, ssi_info,
                               this_side_loop_out_cnt, this_side_loop_out,
                               other_side_loop_out_cnt, other_side_loop_out);
            if (!(1 & *EMmsg)) goto wrapup;
          }
        }
      }
    }          
  }

  wrapup:
    if (edge) om$dealloc(ptr = edge);
    EMWRAPUP(*EMmsg, OM_stat, "EFget_comed_info")
    return;
}


method EMattemptBreakup(IGRlong *EMmsg; GRobjid uneval_id;
                        IGRboolean *did_breakup; GRobjid *new_state_id;
                        struct GRmd_env *env; IGRushort options)
/*
Description
    This message will attempt to break up this state into multiple
    independent states.  This is useful if this state is a multiple boolean
    and only part of the boolean is affected by the unevaluation.  The
    unaffected part of this state will be placed in a sperate state object 
    and connected on my to_owners channel as the next state.  This node (me)
    and the new parent node will remain active.

Return Values    
    EMS_S_Success if all is well.

Notes
    About parameters:
        uneval_id - The objid of the node causing the unevaluation
                    of this node (usually the sender_id).
        did_breakup - TRUE if this state is broken up.
        new_state_id - objid of the new state created as a result of the
                       breakup.
        options - currently unused.

    Since this message relies on this state to be the active state it will
    make itself active.  This is a somewhat painful step but if it saves
    a recompute then it is worthwhile.  It is assumed that the sender will
    handle restoring the top state to active.

History
    DLB 01/08/90 Added EMnodeBrokeApart send in order to notify next states
                 that a composite has split into two.
    DLB 10/23/89 not an mbool if comp_count <= 2 instead of == 2.
    DLB 06/21/89 Fixed a bug in when checking for in and out loop
                 intersection.  I was gettting the edges of the in loop and
                 determining if the out loop owned the same edges.  This
                 logic is incorrect if all shared edges get split.  So
                 the logic has changed to get the edges of the out loop and
                 see if the in loop owns these edge either directly or
                 indirectly (via partedges).
    DLB 03/30/89 Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS, new_node_index;

  OMuint                  comp_cnt, tmpindex;
  IGRint                  ii, jj, kk, ll, 
                          num_chan, total_sf_out,
                          lpin_index, lpout_index, 
                          oldindex, 
                          my_new_in_index, my_new_out_index, 
                          other_new_in_index, other_new_out_index, 
                          set2_cnt,
                          node_cnt, edge_cnt,
                          temp_node_cnt, 
                          edge_buff_size,
                          surf_mod_cnt, 
                          aff_cnt, 
                          loop_in_cnt, loop_out_cnt,
                          unaff_loop_out_cnt,
                          aff_comed_loop_out_cnt,
                          unaff_comed_loop_out_cnt,
                          aff_comed_surf_out_cnt,
                          unaff_comed_surf_out_cnt,
                          total_loop_out,
                          num_comp_moved_ids;

  GRobjid                 set1_id, set2_id, comm_surf_id,
                          *node=NULL, 
                          *surf_mod=NULL,
                          *loop_in=NULL, 
                          *loop_out=NULL,
                          *unaff_loop_out=NULL,
                          *aff_comed_surf_out=NULL, 
                          *unaff_comed_surf_out=NULL,
                          *comp_moved_ids=NULL;
                           
  struct affect_struct    *aff_by_lpin=NULL;

  struct loop_out_struct  *aff_comed_loop_out=NULL, 
                          *unaff_comed_loop_out=NULL;

  union EMSssi_table      *ssi=NULL,
                          *my_new_ssi=NULL,
                          *other_new_ssi=NULL;

  struct EMSboolssi_table *my_info=NULL,
                          *my_new_info=NULL,
                          *other_new_info=NULL;

  union EMSssiSizeData    size_data;

  struct GRid             *edge=NULL, node_GRid, new_node_GRid;

  OM_S_CHANSELECT         to_comps, to_common_edge, to_owner,
                          to_edges;

  struct EMchanstruct     *chan=NULL;

  IGRushort       remember_props, mask;

  IGRboolean              action, overlap, restart, 
                          got_mine, got_other, 
                          goes_to_my_new_info,
                          EFis_edge_owned_by_edlp();

  OMuword                 dumosnum;



  *EMmsg = EMS_S_Success;

  *did_breakup = FALSE;
  *new_state_id = NULL_OBJID;
  
  aff_cnt = 0;
  num_chan = 0;

  remember_props = ME.EMSdpr->dpr_props;

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  /*See if this is a multiple boolean.  If not then no need to proceed.*/
  OM_stat = om$get_channel_count(object = me,
                                 p_chanselect = &to_comps,
                                 count = &comp_cnt);
  if (!(1 & OM_stat) || (comp_cnt <= 2)) goto wrapup;

  set2_cnt = comp_cnt - 1;

  /*Next see if node to uneval is in set1. If so must uneval all in set2.*/
  OM_stat = om$get_index(object_c = me,
                         p_chanselect = &to_comps,
                         objid = uneval_id,
                         indexaddr = &tmpindex);
  if (!(1 & OM_stat) || (tmpindex == 0))
  {
#   if DEBUG
      fprintf(stderr,"EMattemptBreakUp-Uneval node (%d) is in set 1\n",my_id);
#   endif
    goto wrapup;
  }

  /*Will be using the EMgetactiveid message which will traverse up the tree
   * until the active guy is hit.  Trick this message by setting the
   * component nodes to active.  This requires that I also be set to
   * inactive because the comp. node could be a primitive in which case the
   * EMgetactiveid code will have to look at this state to determine the
   * active one.
   */
  ME.EMSdpr->dpr_props &= ~(EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH);

  action = TRUE;
  mask = EMSIS_ACTIVE_STATE;
  OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action,
                          &mask),
                    p_chanselect = &to_comps);
  if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
                          
  /*Get the set 1 id.*/
  OM_stat = om$get_objid_at_index(object = me,
                                  p_chanselect = &to_comps,
                                  index = 0,
                                  objidaddr = &set1_id,
                                  osnumaddr = &dumosnum);
  if (!(1 & OM_stat)) goto wrapup;                                  

  /*Get the SSI stuff.*/
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->bool_info;

  if (!my_info->num_surfaces && !my_info->num_composites)
  {
    /*Got a case where no surfaces or composites are modified.  This (I think)
     * will always denote some sort of disjoint boolean processing.  For such
     * cases a break apart is not necessary since the recompuation of this
     * node (if any) will be lighting fast.
     */
    goto wrapup;
  }

  /*Need to get nodes affected by each other.  Once this is gotten then can
   * find those affected by the uneval node.  Those may, in turn, affect
   * others who must also uneval.  Do this by putting the nodes affected on
   * the same loop into one array: affected[n].affected_nodes.  Also store
   * the surface modified for this loop.
   */
  EMmake_chanselect(EMSedge_to_common_edge, &to_common_edge);
  EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);

  edge_buff_size = 0;
  edge_cnt = 0;

  lpin_index = 0;
  lpout_index = 0;
  for(ii=0; ii<my_info->num_surfaces; ii++)
  {
    /*For each surface modified, see if its in set 1.*/
    OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                            &node_GRid, NULL),
                      targetid = my_info->surface_ids[ii]);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (node_GRid.objid == set1_id)
    {
      /*Surf mod is in set 1 so cycle for each loop added to this surface.*/
      for(jj=0; jj<my_info->num_regions_in[ii]; jj++, aff_cnt++, lpin_index++)
      {
        /*For each loop in, get its edges and find affected nodes.*/
        EFrealloc_if_needed(EMmsg, &aff_by_lpin, aff_cnt, 
                            AFF_BY_LPIN_BUFF_INCR, sizeof(struct
                            affect_struct)); 
        if (!(1 & *EMmsg)) goto wrapup;

        aff_by_lpin[aff_cnt].surf_mod = my_info->surface_ids[ii];
        aff_by_lpin[aff_cnt].loop_in = my_info->region_in_ids[lpin_index];

        aff_by_lpin[aff_cnt].num_loop_out = 0;
        aff_by_lpin[aff_cnt].loop_out = NULL;

        /*The max # of nodes is the # of set2 nodes.*/
        aff_by_lpin[aff_cnt].num_nodes = 0;
        aff_by_lpin[aff_cnt].nodes = (GRobjid *) om$malloc
                                  (size = set2_cnt * sizeof(GRobjid));
        if (!aff_by_lpin[aff_cnt].nodes) 
        {*EMmsg = EMS_E_NoDynamicMemory;goto wrapup;}
            
        edge_cnt = 0;
        OM_stat = om$send(msg = message EMSboundary.EMget_edges(EMmsg,
                                1, EMS_OPT_STITCHED, &edge, 
                                &edge_buff_size, &edge_cnt),
                          targetid = my_info->region_in_ids[lpin_index]);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;

        for(kk=0; kk<edge_cnt; kk++)
        {
          /*For each edge, get the common surface id.*/
          OM_stat = om$send(msg = message EMSboundary.EMgetsurface_info(EMmsg,
                                  &comm_surf_id, NULL),
                            senderid = edge[kk].objid,
                            p_chanselect = &to_common_edge);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        
          /*Get the node id for this surface.*/
          OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                                  &node_GRid, NULL),
                            targetid = comm_surf_id);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;
                
          if (node_GRid.objid != set1_id)
          {
            /*See if this node is on my to_comps chan.  If not throw it
             * away since this node is not part of this boolean.
             */  
            OM_stat = om$is_objid_on_channel(object_c = me,
                                             p_chanselect = &to_comps,
                                             objid = node_GRid.objid);
            if (OM_stat == OM_S_SUCCESS)
            {
              /*This loop of set 1 node has been cut by the set 2 node.
               * See if already have this loop in aff_by_lpin[aff_cnt].nodes.
               */
              for(ll=0; ll<aff_by_lpin[aff_cnt].num_nodes; ll++)
              {
                if (aff_by_lpin[aff_cnt].nodes[ll] == node_GRid.objid) break;
              }
              if (ll == aff_by_lpin[aff_cnt].num_nodes)
              {
                /*Add this node to aff_by_lpin array.*/
                aff_by_lpin[aff_cnt].nodes[aff_by_lpin[aff_cnt].num_nodes] =
                                                              node_GRid.objid;
                aff_by_lpin[aff_cnt].num_nodes++;
              }
            }
            else OM_stat = OM_S_SUCCESS;
          }    
        }

        if (my_info->num_regions_out[ii])
        {
          /*This surface has loops out so so now get the loops out that
           * intersect this loop in.
           */
          aff_by_lpin[aff_cnt].loop_out = (GRobjid *) om$malloc
                (size = my_info->num_regions_out[ii] * sizeof(GRobjid));
          if (!aff_by_lpin[aff_cnt].loop_out)
          {*EMmsg = EMS_E_NoDynamicMemory;goto wrapup;}

          tmpindex = lpout_index;
          for(kk=0; kk<my_info->num_regions_out[ii]; kk++, tmpindex++)
          {
            /*First see if this out loop is already in aff_by_lpin array.*/
            for(ll=0; ll<aff_by_lpin[aff_cnt].num_loop_out; ll++)
            {
              if (aff_by_lpin[aff_cnt].loop_out[ll] == 
                  my_info->region_out_ids[tmpindex]) break; 
            }
            if (ll != aff_by_lpin[aff_cnt].num_loop_out) continue;

            /*Changed EMget_edges send to get the out loop's edges.*/
            edge_cnt = 0;
            OM_stat = om$send(msg = message EMSboundary.EMget_edges(EMmsg,
                                    1, EMS_OPT_ALL, &edge, 
                                    &edge_buff_size, &edge_cnt),
                              targetid = my_info->region_out_ids[tmpindex]);
            if (!(1 & OM_stat & *EMmsg)) goto wrapup;

            /*See if the out loop and in loop intersect.  If so
             * then this in loop caused the current out loop to be taken out
             * so save.
             */
            for(ll=0; ll<edge_cnt; ll++)
            {
              if (EFis_edge_owned_by_edlp(EMmsg, edge[ll].objid,
                                          my_info->region_in_ids[lpin_index],
                                          OM_Gw_current_OS))
              {
                aff_by_lpin[aff_cnt].loop_out
                                        [aff_by_lpin[aff_cnt].num_loop_out] = 
                                            my_info->region_out_ids[tmpindex];
                aff_by_lpin[aff_cnt].num_loop_out++;
                break;
              }
              else if (!(1 & *EMmsg)) goto wrapup;
            } 
          }
        }
      }
    }
    else
    {
      lpin_index += my_info->num_regions_in[ii];
    }
    lpout_index += my_info->num_regions_out[ii];      
  }

  /*Now have array of affected node ids for each loop in.
   * Take the uneval_id and search thru the lists.  When a match is found
   * add all nodes for the loop to the node array and start over.  If the
   * number of nodes affected exceeds the total nuber of set 2 nodes then
   * all will uneval so stop.
   */

  /*Allocate node list for total set 2 nodes (maximum it can be).*/
  node = (GRobjid *) om$malloc(size = set2_cnt * sizeof(GRobjid)); 
  if (!node) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

  node[0] = uneval_id;
  node_cnt = 1;

  /*As the nodes affected by the uneval id are computed also know the surf mod
   * and loops in and out for the affected surface.
   */
  surf_mod = (GRobjid *) om$malloc
             (size = my_info->num_surfaces * sizeof(GRobjid));    
  if (!surf_mod) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
  surf_mod_cnt = 0;

  loop_in = (GRobjid *) om$malloc(size = lpin_index * sizeof(GRobjid));
  if (!loop_in) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}             
  loop_in_cnt = 0;

  loop_out = (GRobjid *) om$malloc(size = lpout_index * sizeof(GRobjid));
  if (!loop_out) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}             
  loop_out_cnt = 0;

  unaff_loop_out = (GRobjid *) om$malloc(size = lpout_index*sizeof(GRobjid)); 
  if (!unaff_loop_out) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}  
  unaff_loop_out_cnt = 0;

  restart = FALSE;
  overlap = FALSE;
  for(ii=0; ii<aff_cnt;)   /*NO INCREMENT - see below*/
  {
    for(jj=0; jj<aff_by_lpin[ii].num_nodes && !overlap; jj++)
    {
      for(kk=0; kk<node_cnt; kk++)
      {
        if (node[kk] == aff_by_lpin[ii].nodes[jj])
        {
          overlap = TRUE;
          break;
        }
      }
    }
   
    if (overlap)
    {
      /*The affected node list has an uneval node so add new ones to node
       * list (if any).
       */ 
      temp_node_cnt = node_cnt;
      for(jj=0; jj<aff_by_lpin[ii].num_nodes; jj++)
      {
        for(kk=0; kk<temp_node_cnt; kk++)
        {
          if (node[kk] == aff_by_lpin[ii].nodes[jj]) break;
        }

        if (kk == temp_node_cnt)
        {
          /*Dont have this node so add it to the node list.*/
          node[node_cnt] = aff_by_lpin[ii].nodes[jj];
          node_cnt++;

          /*Got a new affected node so go back to beginning of affected list
           * and search again.
           */
          restart = TRUE;
        }
      }

      if (node_cnt == set2_cnt)
      {
        /*It turns out that all nodes in set 2 cut the same loop in
         * set 1 so just forget the whole thing.
         */
#        if DEBUG
           fprintf(stderr,"Uneval node affects all other set2 nodes.\n");
#        endif            
         goto wrapup;
      }

      /*Add surf mod to array.*/
      surf_mod[surf_mod_cnt] = aff_by_lpin[ii].surf_mod;
      surf_mod_cnt++;

      /*Add loops in to array.*/
      loop_in[loop_in_cnt] = aff_by_lpin[ii].loop_in;
      loop_in_cnt++;

      /*Add loops out to array.*/
      for(jj=0; jj<aff_by_lpin[ii].num_loop_out; jj++)
      {
        for(kk=0; kk<loop_out_cnt; kk++)
        {
          if (loop_out[kk] == aff_by_lpin[ii].loop_out[jj]) break; 
        }
        if (kk == loop_out_cnt)
        {
          loop_out[loop_out_cnt] = aff_by_lpin[ii].loop_out[jj];
          loop_out_cnt++;
        }
      }
      overlap = FALSE;
    }
    else
    {
      /*No overlap so add loops out to unaff_loop_out list.*/
      for(jj=0; jj<aff_by_lpin[ii].num_loop_out; jj++)
      {
        for(kk=0; kk<unaff_loop_out_cnt; kk++)
        {
          if (unaff_loop_out[kk] == aff_by_lpin[ii].loop_out[jj]) break; 
        }
        if (kk == unaff_loop_out_cnt)
        {
          unaff_loop_out[unaff_loop_out_cnt] = aff_by_lpin[ii].loop_out[jj];
          unaff_loop_out_cnt++;
        }
      }
    }      

    if (restart)
    {
      ii = 0;
      restart = FALSE;
    }
    else ii++;
  }
  
  aff_comed_loop_out_cnt = 0;
  aff_comed_loop_out = NULL;
  aff_comed_surf_out_cnt = 0;
  aff_comed_surf_out = NULL;
  for(ii=0; ii<loop_out_cnt; ii++)
  {
    /*For each affected known loop out get the rest of the loops out and the
     * surfaces out. 
     */
    EFget_comed_out_info(EMmsg, loop_out[ii], &aff_comed_loop_out_cnt,
                         &aff_comed_loop_out, &aff_comed_surf_out_cnt, 
                         &aff_comed_surf_out, my_info, 
                         loop_out_cnt, loop_out, 
                         unaff_loop_out_cnt, unaff_loop_out);
    if (!(1 & *EMmsg)) goto wrapup;
  }

  unaff_comed_loop_out_cnt = 0;
  unaff_comed_loop_out = NULL;
  unaff_comed_surf_out_cnt = 0;
  unaff_comed_surf_out = NULL;
  for(ii=0; ii<unaff_loop_out_cnt; ii++)
  {
    /*For each unaffected known loop out get the rest of the loops out and the
     * surfaces out. 
     */
    EFget_comed_out_info(EMmsg, unaff_loop_out[ii], &unaff_comed_loop_out_cnt,
                         &unaff_comed_loop_out, &unaff_comed_surf_out_cnt, 
                         &unaff_comed_surf_out, my_info, 
                         unaff_loop_out_cnt, unaff_loop_out,
                         loop_out_cnt, loop_out); 
    if (!(1 & *EMmsg)) goto wrapup;
  }

  /*Add loops out in aff_comed_loop_out array to loop out array.*/
  for(ii=0; ii<aff_comed_loop_out_cnt; ii++)
  {
    loop_out[loop_out_cnt] = aff_comed_loop_out[ii].loop_out;
    loop_out_cnt++;
  }

  /*Add surfs mod in aff_comed_loop_out array to the surf_mod array.*/
  for(ii=0; ii<aff_comed_loop_out_cnt; ii++)
  {
    for(jj=0; jj<surf_mod_cnt; jj++)
    {
      if (aff_comed_loop_out[ii].surf_mod == surf_mod[jj]) break;
    }
    if (jj == surf_mod_cnt)
    {
      /*Got a new affected surface modified.*/
      surf_mod[surf_mod_cnt] = aff_comed_loop_out[ii].surf_mod;
      surf_mod_cnt++;
    }
  }

  /*Now see if the affected surface modified has all of its out loops
   * accounted for.  If not then this is an ambiguous case so just die.
   */
  for(ii=0; ii<surf_mod_cnt; ii++)
  {
    total_loop_out = 0;
    for(jj=0; jj<aff_cnt; jj++)
    {
      if (aff_by_lpin[jj].surf_mod == surf_mod[ii])
      {
        total_loop_out += aff_by_lpin[jj].num_loop_out;
      }
    }

    for(jj=0; jj<aff_comed_loop_out_cnt; jj++)
    {
      if (aff_comed_loop_out[jj].surf_mod == surf_mod[ii])
      {
        total_loop_out += 1;
      }
    }

    for(jj=0; jj<unaff_comed_loop_out_cnt; jj++)
    {
      if (unaff_comed_loop_out[jj].surf_mod == surf_mod[ii])
      {
        total_loop_out += 1;
      }
    }

    for(jj=0; jj<my_info->num_surfaces; jj++)
    {
      if (my_info->surface_ids[jj] == surf_mod[ii])
      {
        if (total_loop_out != my_info->num_regions_out[jj])
        {
          /*Some out loops are unaccounted for so this signifies an ambiguous
           * condition so die.
           */ 
#         if DEBUG         
            fprintf(stderr, "surf id %d has unaccounted for out loops.\n",
                    surf_mod[ii]);
#         endif
          goto wrapup;
        }
      }
    }
  }

  /*Next see if have a surface out in the aff and unaff comed surf out arrays.
   * If so this signifies an ambiguous case.  PERHAPS THIS CAN BE HANDLED??
   */
  for(ii=0; ii<aff_comed_surf_out_cnt; ii++)
  {
    for(jj=0; jj<unaff_comed_surf_out_cnt; jj++)
    {
      if (aff_comed_surf_out[ii] == unaff_comed_surf_out[jj])
      {
        /*Surface was removed as a result of both affected and unaffected 
         * nodes.  This signifies an ambiguous condition so die.
         */ 
#       if DEBUG         
          fprintf(stderr, "surf id %d was removed by aff and unaff nodes.\n",
                  aff_comed_surf_out[ii]);
#       endif
        goto wrapup;
      }
    }
  }   
   
# if DEBUG
    fprintf(stderr,"Breaking apart boolean node %d\n", my_id);
# endif

  /*Houston, we are go for boolean break apart...*/

  if (aff_comed_surf_out_cnt && unaff_comed_surf_out_cnt)
  {
    /*Since the break apart will change the order that surfaces are
     * removed, must compute and store the proper composite to surface index. 
     */
    num_chan = 0;
    chan = NULL;
    OM_stat = om$send(msg = message EMSdpr.EMgetCompIndex(EMmsg, &num_chan,
                            &chan, NULL),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    /*Get total number of surfaces removed.*/
    total_sf_out = 0;
    for(ii=0; ii<my_info->num_composites; ii++)
      total_sf_out += my_info->num_surfaces_out[ii];

    /*For all surfs on the pseudo channel if in affected surf out list adjust
     * indices.
     */
    for(ii=0; ii<total_sf_out; ii++)
    {
      for(jj=0; jj<num_chan; jj++)
      {
        for(kk=0; kk<chan[jj].chancnt; kk++)
        {
          if (chan[jj].chan[kk] == my_info->surface_out_ids[ii]) break;
        }
        if (kk != chan[jj].chancnt) break;
      }

      if (jj != num_chan)
      {
        /*Got a match of pseudo channel and surf out list now see if its in
         * aff list.  If so then can remove this from chan else leave will be
         * handled as unaff surf out.
         */
        for(ll=0; ll<aff_comed_surf_out_cnt; ll++)
        {
          if (chan[jj].chan[kk] == aff_comed_surf_out[ll])
          {
            my_info->composite_indices[ii] = kk;
            EFdisconnectchan(EMmsg, chan, kk);
            if (!(1 & *EMmsg)) goto wrapup;
            break;
          }
        }
      }
    }

    /*For all surfs on the pseudo channel if NOT in affected surf out list
     * adjust indices.
     */
    for(ii=0; ii<total_sf_out; ii++)
    {
      for(jj=0; jj<num_chan; jj++)
      {
        for(kk=0; kk<chan[jj].chancnt; kk++)
        {
          if (chan[jj].chan[kk] == my_info->surface_out_ids[ii]) break;
        }
        if (kk != chan[jj].chancnt) break;
      }

      if (jj != num_chan)
      {
        /*Got a match of pseudo channel and surf out list now see if its in
         * unaff list.  If so then can remove this from chan else leave cause
         * have already processed this one.
         */
        for(ll=0; ll<unaff_comed_surf_out_cnt; ll++)
        {
          if (chan[jj].chan[kk] == unaff_comed_surf_out[ll])
          {
            my_info->composite_indices[ii] = kk;
            EFdisconnectchan(EMmsg, chan, kk);
            if (!(1 & *EMmsg)) goto wrapup;
            break;
          }
        }
      }
    }
  }


  /*Break the SSI into two pieces:
   *
   *Get the new SSI buffers.  Can get a reasonable size SSI
   * struct by using the same size as the current SSI struct. 
   */
  OM_stat = om$send(msg = message EMSdpr.EMgetSSIsize(EMmsg, &size_data),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSIbuffer(EMmsg, &size_data,
                          &my_new_ssi), 
                    targetid = my_id); 
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  my_new_info = &(my_new_ssi->bool_info);
  my_new_info->num_composites = 0;
  my_new_info->num_surfaces = 0;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSIbuffer(EMmsg, &size_data,
                          &other_new_ssi), 
                    targetid = my_id); 
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  other_new_info = &(other_new_ssi->bool_info);
  other_new_info->num_composites = 0;
  other_new_info->num_surfaces = 0;

  oldindex = 0;
  my_new_out_index = 0;
  other_new_out_index = 0;

  /*For each composite...*/
  for(ii=0; ii<my_info->num_composites; ii++)
  {
    got_mine = FALSE;
    got_other = FALSE;
    
    my_new_info->num_surfaces_out[my_new_info->num_composites] = 0;
    other_new_info->num_surfaces_out[other_new_info->num_composites] = 0;

    for(jj=0; jj<my_info->num_surfaces_out[ii]; jj++, oldindex++)
    {
      for(kk=0; kk<aff_comed_surf_out_cnt; kk++)
      {
        if (aff_comed_surf_out[kk] == 
            my_info->surface_out_ids[oldindex]) break;
      }
      if (kk != aff_comed_surf_out_cnt)
      {
        /*The surf out of this composite belongs to this (new) state.*/
        goes_to_my_new_info = TRUE;
      }
      else
      {
        /*This surface out is not part of the set 1 to remain in this state. 
         * Now see if the surface belongs to a node in set 1.  If so then this
         * surface out will go in the new state.
         */
        OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                                &node_GRid, NULL),
                          targetid = my_info->composite_ids[ii]);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
          
        OM_stat = om$get_index(object_c = me,
                               p_chanselect = &to_comps,
                               objid = node_GRid.objid,
                               indexaddr = &tmpindex);
        if (!(1 & OM_stat)) goto wrapup;
          
        if (tmpindex == 0)
        {
          /*The surf out of this composite (set 1) belongs to the other
           * (new) state.
           */ 
          goes_to_my_new_info = FALSE;
        }
        else
        {
          /*The surface out belongs to a node of set 2.  See if its an
           * affected node.  If so then this surface out belongs to this
           * state. 
           */
          for(kk=0; kk<node_cnt; kk++)
          {
            if (node[kk] == node_GRid.objid) break;
          }
          if (kk != node_cnt)
          {
            /*This surface out belongs to an affected node so it goes with 
             * this state.
             */
            goes_to_my_new_info = TRUE;
          }
          else
          {
            /*This surface out belongs to an unaffected node so it goes with
             * the other (new) state.
             */
            goes_to_my_new_info = FALSE;
          }
        }
      }

      if (goes_to_my_new_info)
      {
        /*The surface out goes to my_new_info ssi.*/
        my_new_info->surface_out_ids[my_new_out_index] =
                                       my_info->surface_out_ids[oldindex]; 
        my_new_info->composite_indices[my_new_out_index] =
                                         my_info->composite_indices[oldindex];
        my_new_out_index++;
        my_new_info->num_surfaces_out[my_new_info->num_composites]++;
        got_mine = TRUE;
      }
      else
      {
        /*The surface out goes to other_new_info ssi.*/
        other_new_info->surface_out_ids[other_new_out_index] =
                                          my_info->surface_out_ids[oldindex]; 
        other_new_info->composite_indices[other_new_out_index] =
                                         my_info->composite_indices[oldindex];
        other_new_out_index++;
        other_new_info->num_surfaces_out[other_new_info->num_composites]++;
        got_other = TRUE;
      }
    } 

    /*Note: For cases where surfaces are removed from from set 1.  These
     * may be removed due to both affected and unaffected nodes.  When this
     * happens the composite id goes in both ssi's. Hence the reason for
     * two independent got_mine & got_other flags.
     */
    if (got_mine)
    {
      /*Got a surf out for this comp. so add composite id to my new info.*/
      my_new_info->composite_ids[my_new_info->num_composites] = 
                                                  my_info->composite_ids[ii];
      my_new_info->num_composites++;
    }
    if (got_other)
    {
      /*Got a surf out for this comp so add comp id to other new info.*/
      other_new_info->composite_ids[other_new_info->num_composites] = 
                                                  my_info->composite_ids[ii];
      other_new_info->num_composites++;
    }
  }

  my_new_in_index = 0;
  other_new_in_index = 0;
  my_new_out_index = 0;
  other_new_out_index = 0;

  lpin_index = 0;
  lpout_index = 0;
  for(ii=0; ii<my_info->num_surfaces; ii++)
  {
    got_mine = FALSE;
    got_other = FALSE;
  
    my_new_info->num_regions_in[my_new_info->num_surfaces] = 0;
    other_new_info->num_regions_in[other_new_info->num_surfaces] = 0;    

    /*Fill ssi's with loops in.*/
    for(jj=0; jj<my_info->num_regions_in[ii]; jj++, lpin_index++)
    {
      /*See if this loop in is in the loop in list. If so then it goes with
       * this state. 
       */
      for(kk=0; kk<loop_in_cnt; kk++)
      {
        if (loop_in[kk] == my_info->region_in_ids[lpin_index]) break;
      }

      if (kk != loop_in_cnt)
      {
        /*Got a loop in for this state.*/
        goes_to_my_new_info = TRUE;
      }
      else
      {
        /*See if this surface mod is part of set 1.  If so the loop in
         * will go to the new state.
         */
        OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                                &node_GRid, NULL),
                          targetid = my_info->surface_ids[ii]);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
          
        OM_stat = om$get_index(object_c = me,
                               p_chanselect = &to_comps,
                               objid = node_GRid.objid,
                               indexaddr = &tmpindex);
        if (!(1 & OM_stat)) goto wrapup;
          
        if (tmpindex == 0)
        {
          /*The loop in goes to other_new_info ssi.*/
           goes_to_my_new_info = FALSE;
        }        
        else
        {
          /*The surface mod belongs to a node of set 2.  If its set 2 node is 
           * one of the affected nodes then this loop belongs to this state.
           */
          for(kk=0; kk<node_cnt; kk++)
          {
            if (node[kk] == node_GRid.objid) break;
          }
          if (kk != node_cnt)
          {
            /*This loop in belongs to this state.*/
            goes_to_my_new_info = TRUE;
          }
          else
          {
            /*This loop in belongs to the (new state) other new info ssi.*/
            goes_to_my_new_info = FALSE;
          }
        }
      }

      if (goes_to_my_new_info)
      {
        /*This loop in goes to my_new_info ssi.*/
        my_new_info->region_in_ids[my_new_in_index] = 
                                           my_info->region_in_ids[lpin_index];
        my_new_in_index++;
        my_new_info->num_regions_in[my_new_info->num_surfaces]++;
        got_mine = TRUE;
      }
      else
      {
        /*This loop in goes to other_new_info ssi.*/
        other_new_info->region_in_ids[other_new_in_index] = 
                                           my_info->region_in_ids[lpin_index];
        other_new_in_index++;
        other_new_info->num_regions_in[other_new_info->num_surfaces]++;
        got_other = TRUE;
      }
    }        

    my_new_info->num_regions_out[my_new_info->num_surfaces] = 0;
    other_new_info->num_regions_out[other_new_info->num_surfaces] = 0;    

    /*Fill ssi's with loops out.*/    
    for(jj=0; jj<my_info->num_regions_out[ii]; jj++, lpout_index++)
    {
      /*See if this loop out is in the loop out list. If so then it goes with
       * this state. 
       */
      for(kk=0; kk<loop_out_cnt; kk++)
      {
        if (loop_out[kk] == my_info->region_out_ids[lpout_index]) break;
      }

      if (kk != loop_out_cnt)
      {
        /*Got a loop out for this state.*/
        goes_to_my_new_info = TRUE;
      }
      else
      {
        /*See if this surface mod is part of set 1.  If so the loop out
         * will go to the new state.
         */
        OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                                &node_GRid, NULL),
                          targetid = my_info->surface_ids[ii]);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
          
        OM_stat = om$get_index(object_c = me,
                               p_chanselect = &to_comps,
                               objid = node_GRid.objid,
                               indexaddr = &tmpindex);
        if (!(1 & OM_stat)) goto wrapup;
          
        if (tmpindex == 0)
        {
          /*The loop out goes to other_new_info ssi.*/
           goes_to_my_new_info = FALSE;
        }        
        else
        {
          /*The surface mod belongs to a node of set 2.  If its set 2 node is 
           * one of the affected nodes then this loop belongs to this state.
           */
          for(kk=0; kk<node_cnt; kk++)
          {
            if (node[kk] == node_GRid.objid) break;
          }
          if (kk != node_cnt)
          {
            /*This loop out belongs to this state.*/
            goes_to_my_new_info = TRUE;
          }
          else
          {
            /*This loop out belongs to the (new state) other new info ssi.*/
            goes_to_my_new_info = FALSE;
          }
        }
      }

      if (goes_to_my_new_info)
      {
        /*This loop out goes to my_new_info ssi.*/
        my_new_info->region_out_ids[my_new_out_index] = 
                                         my_info->region_out_ids[lpout_index];
        my_new_out_index++;
        my_new_info->num_regions_out[my_new_info->num_surfaces]++;
        got_mine = TRUE;
      }
      else
      {
        /*This loop out goes to other_new_info ssi.*/
        other_new_info->region_out_ids[other_new_out_index] = 
                                         my_info->region_out_ids[lpout_index];
        other_new_out_index++;
        other_new_info->num_regions_out[other_new_info->num_surfaces]++;
        got_other = TRUE;
      }
    }        

    /*Note: For cases where surfaces are modified in set 1.  These
     * may be modified due to both affected and unaffected nodes.  When this
     * happens the surface mod id goes in both ssi's. Hence the reason for
     * two independent got_mine & got_other flags.
     */
  
    if (got_mine)
    {
      my_new_info->surface_ids[my_new_info->num_surfaces] = 
                                                     my_info->surface_ids[ii];
      my_new_info->num_surfaces++;
    }

    if (got_other)
    {
      other_new_info->surface_ids[other_new_info->num_surfaces] = 
                                                     my_info->surface_ids[ii];
      other_new_info->num_surfaces++;
    }
  }

  /*This state is ready to be broken up so create the new unaffected boolean
   * state that will be this states next state.
   */
  /*Just do a construct and copy.*/
  OM_stat = om$construct_and_copy(object = me,
                                  p_objid = new_state_id);

# if DEBUG
    fprintf(stderr,"Created new boolean node %d\n", *new_state_id);
# endif      

  action = TRUE;
  OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action,
                          &remember_props),
                    targetid = *new_state_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  remember_props &= ~EMSIS_ACTIVE_STATE;

  /*The SSI structures are filled so deposit them in each state.*/
  OM_stat = om$send(msg = message EMSdpr.EMputSSI(EMmsg, my_new_ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  OM_stat = om$send(msg = message EMSdpr.EMputSSI(EMmsg, other_new_ssi),
                    targetid = *new_state_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Break apart the state tree.*/
  /*Set the following up because of stupid GRrigidconn & GRdisconn msgs.*/
  node_GRid.objid = my_id;
  node_GRid.osnum = OM_Gw_current_OS;
  new_node_GRid.objid = *new_state_id;
  new_node_GRid.osnum = OM_Gw_current_OS;
  new_node_index = 0;
  action = FALSE;
  mask = EMSIS_ACTIVE_STATE;

  comp_moved_ids = (GRobjid *) om$malloc(size = comp_cnt * sizeof(GRobjid));
  if (!comp_moved_ids) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}  
  num_comp_moved_ids = 0;
  
  /*For all of the set 2 nodes not affected by the uneval node, connect them
   * to the new boolean. 
   */
  for(ii=1; ii<comp_cnt;)  /*Counts change inside for loop.*/
  {
    OM_stat = om$get_objid_at_index(object = me,
                                    p_chanselect = &to_comps,
                                    index = ii,
                                    objidaddr = &set2_id,
                                    osnumaddr = &dumosnum);
    if (!(1 & OM_stat)) goto wrapup;
    for(jj=0; jj<node_cnt; jj++)
    {
      if (set2_id == node[jj]) break;
    }
    if ((jj == node_cnt) && (set2_id != uneval_id))
    {
      /*Have an unaffected node so connect to new bool.*/
      OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg,
                              &node_GRid),
                        targetid = set2_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg, 
                              &new_node_GRid, &new_node_index),
                        targetid = set2_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      comp_moved_ids[num_comp_moved_ids] = set2_id;
      num_comp_moved_ids++;

      OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action,
                              &mask), 
                        targetid = set2_id);
      if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG))
        goto wrapup;
      OM_stat = OM_S_SUCCESS;
      
      comp_cnt--;   /*FOR LOOP LIMITER CHANGE!!*/
    }
    else ii++;    /*Or this cause its a RELATIVE channel!*/
  }

  /*Define channel structure.*/
  EMmake_chanselect(GRconnector_to_owners, &to_owner);

  /*Move my owners to the new state.*/
  OM_stat = om$send(msg = message Root.move_chan(to_owner, my_id,
                          OM_Gw_current_OS, to_owner),
                    targetid = *new_state_id);
  if (!(1 & OM_stat)) goto wrapup;
                      
  /*And finally, connect me to the new state at index 0.*/
  ME.GRgraphics->properties &= ~GR_RIGID_RELATIONSHIP;

  new_node_index = 0;
  OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg, 
                          &new_node_GRid, &new_node_index),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  *did_breakup = TRUE;

  /*Notify my next states of the breakup.*/
  OM_stat = om$send(msg = message EMSdpr.EMnodeBrokeApart(EMmsg,
                          my_id, *new_state_id,
                          num_comp_moved_ids,
                          comp_moved_ids, NULL),
                    senderid = *new_state_id,
                    p_chanselect = &to_owner);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  wrapup:
    { /*Intentional block(head).*/
      IGRlong loc_msg=EMS_S_Success;
      
      action = FALSE;
      mask = EMSIS_ACTIVE_STATE;
      om$send(msg = message EMSdpr.EMsetprops(&loc_msg, &action, &mask),
              p_chanselect = &to_comps);
    }
    ME.EMSdpr->dpr_props = remember_props;

    if (comp_moved_ids) om$dealloc(ptr = comp_moved_ids);
    if (ssi) om$dealloc(ptr = ssi);
    if (my_new_ssi) om$dealloc(ptr = my_new_ssi);
    if (other_new_ssi) om$dealloc(ptr = other_new_ssi);
    if (edge) om$dealloc(ptr = edge);
    if (node) om$dealloc(ptr = node);
    if (loop_out) om$dealloc(ptr = loop_out);
    if (unaff_loop_out) om$dealloc(ptr = unaff_loop_out);
    if (loop_in) om$dealloc(ptr = loop_in);
    if (aff_comed_surf_out) om$dealloc(ptr = aff_comed_surf_out);    
    if (unaff_comed_surf_out) om$dealloc(ptr = unaff_comed_surf_out);    
    if (aff_comed_loop_out) om$dealloc(ptr = aff_comed_loop_out);    
    if (unaff_comed_loop_out) om$dealloc(ptr = unaff_comed_loop_out);    
    for(ii=0; ii<aff_cnt; ii++)
    {
     if (aff_by_lpin[ii].nodes) om$dealloc(ptr = aff_by_lpin[ii].nodes);
     if (aff_by_lpin[ii].loop_out) om$dealloc(ptr = aff_by_lpin[ii].loop_out);
    }
    if (aff_by_lpin) om$dealloc(ptr = aff_by_lpin);

    for(ii=0; ii<num_chan; ii++)
    {
      if (chan[ii].chan) om$dealloc(ptr = chan[ii].chan);
    }
    if (chan) om$dealloc(ptr = chan);

    EMWRAPUP(*EMmsg, OM_stat, "EMSsfboolean.EMattemptBreakup")
    return(OM_stat);
}


end implementation EMSsfboolean;
