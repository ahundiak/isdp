/*
  ALGORITHM

    This loop that is being visited is added to the list of loops already
    visited. 

    For every edge of this loop find the adjacent loop. If this adjacent
    loop has not already been visited, it is to be processed further. If the
    edge being crossed over belongs to the EMSinters list, it means we are
    crossing into an adjacent region. In this case, toggle the "in_hole" flag
    and send this message across to the loop. If the edge does not belong to
    the EMSinters list, then maintain this flag and send this same message.

    If this is a P-loop consider it's inner loops and if it is a C-loop
    consider it's outer loop. If this loop(s) has been visited, ignore
    it. If it hasn't, then send this same message to it, maintaining the
    "in_hole" flag.

    If the input to this message was an "in_hole" set to TRUE and this loop
    is NEW then remove this loop from the tree and optionally delete it. If the
    "sfloops" argument is non-NULL, then add this loop's id to the output
    list.

  HISTORY

    Vadi : 30/09/93  :  Modified to nest the old C-loops back into the 
                        old P-loops, which they came from.
    SS  :  03/04/93  :  Creation
*/

class implementation EMSloop;

#include "OMmacros.h"
#include "EMSbnd.h"
#include "gr.h"
#include "gocmacros.h"          /* GRgetabsg macro  */
#include "grdpbdef.h"
#include "grdpbmacros.h"

#define BUFF_INCR 10

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSloop_class_id;

%safe
static IGRboolean already_visited(), edge_in_inters_list();
%endsafe

from EMSloopset import EMnesting, EMget_loops;

method EMremove_adjacent_holes (IGRlong *msg; IGRulong options; 
                                IGRboolean in_hole;
                                struct EMSinters *inters;
                                struct EMSownercomp **sfloops; 
                                IGRint *num_loops_visited; 
                                GRobjid **loops_visited)
{
  IGRboolean loc_in_hole, list_extended;
  IGRuint count, has_common_edge;
  IGRint chansel_label;
  IGRlong msg_loc, stat_OM, i;
  GRobjid lpobj, sfobj;
  struct EMSnest_info nestinfo;
  OM_S_OBJECT_LINKAGE *edges, *loops, common_edge;
  OM_S_CHANSELECT chan_to_common, chan_to_comps, chan;
  IGRlong EMsend_loops();

  struct EMSnest_info temp_nesting;
  /*  parent_nesting; */
  GRobjid parent, *parent_lps = NULL;
  OM_S_OBJECT_LINKAGE *child_lps = NULL;
  IGRushort child_props, *parent_props = NULL;
  OM_S_CHANSELECT to_inner, to_outter, to_loops;
  struct EMSpartolbasis partol_basis;
  OMuint dum_count;
  IGRint parent_count, m, depth, buf_size;
  struct GRmd_env md_env;
  IGRlong nret;  
  IGRboolean external = FALSE;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  buf_size = sizeof(struct GRmd_env);
  gr$get_module_env(msg = &msg_loc,
                    sizbuf = &buf_size,
                    buffer = &md_env,
                    nret = &nret);
  /*
   * Add this loop to the list of loops visited
   */

  if (! ((*num_loops_visited) % BUFF_INCR))
    {
    if (! *num_loops_visited)
      *loops_visited = (GRobjid *) om$malloc (size = BUFF_INCR * 
                        sizeof (GRobjid));
    else
      *loops_visited = (GRobjid *) om$realloc (ptr = (IGRchar *)*loops_visited,
                        size = (*num_loops_visited + BUFF_INCR) *
                                sizeof (GRobjid));
    EMerr_hndlr (! *loops_visited, *msg, EMS_E_NoDynamicMemory, ret_end);
    }
  (*loops_visited)[(*num_loops_visited)] = my_id;
  (*num_loops_visited)++;

  /*
   * For every edge of this loop, check it's adjacent loop. If it has not
   * been visited, send this message with the in_hole flag toggled or
   * not toggled depending on whether the edge we are crossing belongs
   * to the EMSinters list or not.
   */

  EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_comps);
  EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);

  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_comps,
   count = &count);
  EMerr_hndlr (!count, *msg, EMS_E_InvalidCase, ret_end);

  edges = (OM_p_OBJECT_LINKAGE) alloca (count * sizeof (OM_S_OBJECT_LINKAGE));
  om$get_channel_objects (object = me, p_chanselect = &chan_to_comps,
   count = &count, size = count, list = edges);

  for (i=0; i<count; i++)
    {
    has_common_edge = FALSE;
    om$get_channel_objects (objid = edges[i].S_objid, 
     p_chanselect = &chan_to_common, count = &has_common_edge, size = 1, 
     list = &common_edge);

    if (has_common_edge)
      {
      EMsend_loops (&msg_loc, message EMSboundary.EMget_objid (&msg_loc,
       &lpobj), common_edge.S_objid, 0, 0, EMLP_ACTIVE, NULL, NULL);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

      if (!already_visited (lpobj, *num_loops_visited, *loops_visited))
        {
        if (edge_in_inters_list (edges[i].S_objid, inters))
          loc_in_hole = !in_hole;
        else
          loc_in_hole = in_hole;

        stat_OM = om$send (msg = message EMSloop.EMremove_adjacent_holes
                   (&msg_loc, options, loc_in_hole, inters, sfloops, 
                    num_loops_visited, loops_visited), targetid = lpobj);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_LoopError,
         ret_end);
        }
      }
    }

  /*
   * If this is a P-loop pick up it's inner loops, if it is a C-loop,
   * pick up it's outer loop. If this loop(s) has not been visited,
   * send it this same message with the in_hole flag as received into
   * this method.
   */

  chansel_label = ME.EMSloop->lp_props & EMLP_PLOOP ?
                   EMSloop_to_inner : EMSloop_to_outter;
  EMmake_chanselect (chansel_label, &chan);

  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan,
   count = &count);
  if (count)
    {
    loops = (OM_p_OBJECT_LINKAGE) alloca (count * 
             sizeof (OM_S_OBJECT_LINKAGE));
    om$get_channel_objects (object = me, p_chanselect = &chan,
     count = &count, size = count, list = loops);

    for (i=0; i<count; i++)
         {
      if (!already_visited (loops[i].S_objid, *num_loops_visited,
           *loops_visited)) {
      stat_OM = om$send (msg = message EMSloop.EMremove_adjacent_holes
                 (&msg_loc, options, in_hole, inters, sfloops, 
                 num_loops_visited, loops_visited), 
                 targetid = loops[i].S_objid);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_LoopError,
       ret_end);
              }
          }
    }

  /*
   * If this loop is new and the in_hole flag is set to TRUE, remove
   * this loop.
   */

  if (ME.EMSloop->lp_props & EMLP_NEW && in_hole)
    {
    partol_basis.mattyp = &md_env.md_env.matrix_type;
    partol_basis.mat = md_env.md_env.matrix;
    partol_basis.in_world = TRUE;
    partol_basis.is_valid = FALSE;
  
    stat_OM = om$send (msg = message EMSloop.EMgetsurface_info (&msg_loc,
               &sfobj, &partol_basis), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_LoopError, ret_end);

    stat_OM = EMmake_chanselect(EMSloop_to_inner, &to_inner);
        EMerr_hndlr(!(1&stat_OM),*msg,EMS_E_OMerror,ret_end);

    stat_OM = om$get_channel_count(object=me,p_chanselect=&to_inner,
                                        count=&count);
                  EMerr_hndlr(!(1&stat_OM),*msg,EMS_E_OMerror,ret_end);

    if((ME.EMSloop->lp_props & EMLP_EXTERNAL) && 
        (ME.EMSloop->lp_props & EMLP_PLOOP) && (count != NULL)) {
        stat_OM = EMmake_chanselect(EMSloop_to_outter, &to_outter);
        EMerr_hndlr(!(1&stat_OM),*msg,EMS_E_OMerror,ret_end);
        stat_OM = EMmake_chanselect(EMSloopset_to_loops, &to_loops);
        EMerr_hndlr(!(1&stat_OM),*msg,EMS_E_OMerror,ret_end);

        parent = NULL_OBJID;
        stat_OM = om$send(msg=message EMSboundary.EMget_objid
                          (&msg_loc,&parent),p_chanselect=&to_outter);
                 EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);
        child_lps = (OM_S_OBJECT_LINKAGE *) om$malloc(size = count *
                        sizeof(OM_S_OBJECT_LINKAGE));
        EMerr_hndlr (!child_lps, *msg, EMS_E_NoDynamicMemory, ret_end);
        stat_OM = om$get_channel_objects(object = me,
                                         p_chanselect=&to_inner,
                                         list = child_lps,
                                         size = count, count = &dum_count);
        EMerr_hndlr(!(1&stat_OM),*msg,EMS_E_OMerror,ret_end);
        external = TRUE;
        } 

    stat_OM = om$send (msg = message EMSloop.EMtreemod (&msg_loc, &nestinfo,
               EXTRACT, NULL), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_LoopError, ret_end);

    /*
       Nest the old C-loops back into the old P-loops from which they came
       - this is to overcome the problem during clean up.
    */

    if((ME.EMSloop->lp_props & EMLP_PLOOP) && (count != NULL)
        && external) {
       for(i=0;i<count;i++) {
       stat_OM = om$send (msg = message EMSloop.EMget_props(&msg_loc,
                          &child_props), 
                          targetid = child_lps[i].S_objid,
                          targetos = child_lps[i].osnum,
                          senderid = NULL_OBJID);
              EMomerr_exit(stat_OM, ret_end);
              EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_LoopError, ret_end);

              if(!(child_props & EMLP_PLOOP) && !(child_props & EMLP_NEW))
                  {
                  stat_OM = om$send(msg=message Root.disconnect(to_outter,
                                        parent,OM_Gw_current_OS,to_loops),
                                        targetid = child_lps[i].S_objid,
                                        targetos = child_lps[i].osnum,
                                        senderid = NULL_OBJID);
                        EMerr_hndlr(!(1&stat_OM),*msg,EMS_E_OMerror,ret_end);

                  stat_OM = om$send(msg = message EMSloop.EMgivenestinfo
                                         (&msg_loc, &temp_nesting),
                                         targetid = child_lps[i].S_objid,
                                         targetos = child_lps[i].osnum,
                                         senderid = NULL_OBJID);
            EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);

                  stat_OM = om$send(msg=message EMSloopset.EMnesting
                                (&msg_loc,&temp_nesting,&partol_basis),
                        targetid = parent,
                        targetos = OM_Gw_current_OS,
                        senderid = NULL_OBJID);
            EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopsetError,ret_end);  
           
            if(IF_EQ_OBJID(parent,temp_nesting.parent)) {
                          depth = 2;
                          buf_size = 0;
                          parent_count = 0;
            
              stat_OM = om$send(msg=message EMSloopset.EMget_loops
                               (&msg_loc,EMS_OPT_ALL,&depth,&parent_lps,
                               &parent_props,&buf_size,&parent_count),
                               targetid = parent,
                               targetos = OM_Gw_current_OS,
                               senderid = NULL_OBJID);
              for(m=0; m<parent_count; m++) {
                  if(!IF_EQ_OBJID(parent,parent_lps[m])) {
               
               temp_nesting.parent = NULL_OBJID;
               stat_OM = om$send(msg = message EMSloop.EMnesting
                                (&msg_loc,&temp_nesting,&partol_basis),
                                 targetid = parent_lps[m],
                                 targetos = OM_Gw_current_OS,
                                 senderid = NULL_OBJID);
               EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);
               
               if(stat_OM == EMS_I_OutOfBounds ||
                  msg_loc == EMS_I_Ambiguous) continue;

             if((parent_props[m] & EMLP_SPLIT) && !(parent_props[m] & EMLP_NEW)
                && (parent_props[m] & EMLP_EXTERNAL) && 
                   (parent_props[m] & EMLP_PLOOP)) {
                      stat_OM = om$send(msg = message EMSloop.EMtreemod
                                 (&msg_loc,&temp_nesting,
                                 ADD_CHILD,&partol_basis),
                                 targetid = parent_lps[m],
                                 targetos = OM_Gw_current_OS,
                                 senderid = NULL_OBJID);
               EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);
                    
                          break;
                                             }   

                                         }
            if(child_props & EMLP_EXTERNAL) {
            stat_OM = om$send(msg=message EMSloop.EMset_props
                              (&msg_loc,EMLP_EXTERNAL,EMS_O_OFF),
                               targetid = child_lps[i].S_objid,
                               targetos = child_lps[i].osnum,
                               senderid = NULL_OBJID);
               EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);
                                        }
                                      }
                                 }
                         }
                  }
              }
    if (sfloops)
      {
      EMmkownlist (&msg_loc, sfloops, sfobj, NULL, my_id, FALSE,
       &list_extended); 
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_DynamicMemoryAllocated,
       ret_end);
      }    

    if (options & EMS_O_Delete)
      om$send (msg = message Root.delete (TRUE), targetid = my_id);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloop.EMremove_adjacent_holes");
  return (stat_OM);
}



static IGRboolean already_visited (obj, num_visited_objs, visited_objs)
GRobjid obj, *visited_objs;
IGRint num_visited_objs;
{
  IGRint i;
  
  for (i=0; i<num_visited_objs; i++)
    if (obj == visited_objs[i])
      return (TRUE);
  return (FALSE);
}


static IGRboolean edge_in_inters_list (edge, inters)
GRobjid edge;
struct EMSinters *inters;
{
  IGRboolean found;
  struct EMSinters *loc_inters;
  struct EMSintobj *loc_intobj;
  struct EMSdataselect *uvdata;

  found = FALSE;
  loc_inters = inters;
  while (loc_inters && !found)
    {
    loc_intobj = loc_inters->cvs;
    while (loc_intobj && !found)
      {
      uvdata = &loc_intobj->this_uvintobj;
      if (uvdata->datatype == EMSdata_object &&
          uvdata->data.object->objid == edge)
        found = TRUE;
      loc_intobj = loc_intobj->next;
      }
    loc_inters = loc_inters->next;
    }
  return (found);
}

end implementation EMSloop;
