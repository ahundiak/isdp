/*
 * This function has been written to find all the adjacent loops of
 * a loop. 
 * History:
 *
 * Rustagi   10/19/93   Creation
 */
class implementation EMSloop;

#include <stdio.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "EMSbnd.h"
#include "gr.h"
#include "gocmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSprop.h"

/* imports */

from EMSedge import EMget_props;

/* externs */

extern IGRint EMsend_loops();

method  EMget_all_connected_loops(IGRlong *msg;
                                  IGRboolean restriction;
                                  GRobjid *restricted_loops;
                                  IGRint num_of_restricted_loops;
                                  GRobjid **lp_node;
                                  IGRint *loop_count)
/*
 Arguments:
 1) restriction: related to the field "restricted_loops". If TRUE,
    "restricted_loops" will not be tresspassed. If FALSE this argument can
    be NULL.
 2) lp_node: output of connected loops.
 3) loop_count: Number of these loops.
 */
{
IGRlong msg_loc, sts;
IGRint depth, buf_size, chansel_label, index;
OMuint count;
GRobjid *loopids, lpobj;
IGRint i, j, ii;
IGRushort lpprops=0;
struct GRid *edge;
IGRint num_edges, array_size;
OM_S_CHANSELECT to_common_edge, chan;
OM_S_OBJECT_LINKAGE  cm_ed_list, *ls_list=NULL;
IGRboolean this_loop_exists, add_this_loop;

 *msg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 depth = MAXINT;
 loopids = NULL;
 buf_size = 0;
 count = 0;
 edge = NULL;
 num_edges = 0;
 array_size = 0;

 if(restriction)
 {
 for(ii=0; ii<num_of_restricted_loops; ii++)
  {
  if(my_id == restricted_loops[ii])
   {
   add_this_loop = FALSE;
   break;
   }
  else
   add_this_loop = TRUE;
  }
 }

 if(*lp_node == NULL)
  {
   if(add_this_loop)
   {
   *loop_count = 0;
   *lp_node = (GRobjid *)om$malloc(size = sizeof(GRobjid ));
   (*lp_node)[0] = my_id;
   (*loop_count)++;
   }
  }
 else
  {
  if(add_this_loop)
   {
   (*loop_count)++;
   *lp_node = (GRobjid *)om$realloc(ptr = (IGRchar *)(*lp_node),
                                  size = *loop_count * sizeof(GRobjid ));
   (*lp_node)[*loop_count-1] = my_id;
   }
  }

 /*
  * o Get all the edges belong to this loop.
  * o Get all the child loops associated with this loop.
  * o Pass the same message to all the child loops recursively and
  *   whenever a new id is come acrossed, it is being added to the 
  *   output list.
  */
 sts = EMmake_chanselect(EMSedge_to_common_edge, &to_common_edge);
 if(!(1&sts)) goto ret_end;
 sts = om$send(msg = message EMSloop.EMget_edges(&msg_loc,
                                                 MAXINT,
                                                 EMS_OPT_ALL,
                                                 &edge,
                                                 &array_size,
                                                 &num_edges),
                                 senderid = NULL_OBJID,
                                 targetid = my_id,
                                 targetos = OM_Gw_current_OS);
  if(!(1&sts)) goto ret_end;
  for(j=0; j<num_edges; j++)
   {
    sts = om$get_channel_objects (objid = edge[j].objid,
                   osnum = edge[j].osnum,
                   p_chanselect = &to_common_edge, size = 1,
                   list = &cm_ed_list, count = &count);
    if(count) /* if not an open edge */
    {
     EMsend_loops(&msg_loc,
                  message EMSboundary.EMget_objid(&msg_loc,
                     &lpobj), cm_ed_list.S_objid, 0, 0, EMLP_ACTIVE,
                     NULL, NULL);
     EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_LoopError, ret_end);
     /*
      * check if this loop is already existing in the loop list. If NOT,
      * add it to the list.
      */
     this_loop_exists = FALSE;
     for(index=0; index<*loop_count; index++)
      {
      if((*lp_node)[index] == lpobj)
       {
       this_loop_exists = TRUE;
       break;
       }
      }
     if(!this_loop_exists)
     {
      if(restriction)
      {
      for(ii=0; ii<num_of_restricted_loops; ii++)
       {
       if(lpobj == restricted_loops[ii])
        {
        add_this_loop = FALSE;
        break;
        }
       else
        add_this_loop = TRUE;
       }
     }
    if(add_this_loop)
     {
      sts = om$send(msg = message EMSloop.EMget_all_connected_loops(&msg_loc,
                                  restriction,
                                  restricted_loops,
                                  num_of_restricted_loops,
                                  lp_node, loop_count),
                               senderid = NULL_OBJID,
                               targetid = lpobj,
                               targetos = OM_Gw_current_OS);
      if(!(1&sts)) goto ret_end;
      }
     }
    }
   }
  chansel_label = ME.EMSloop->lp_props & EMLP_PLOOP ?
                   EMSloop_to_inner : EMSloop_to_outter;
  EMmake_chanselect (chansel_label, &chan);

  if(!(ME.EMSloop->lp_props & EMLP_PLOOP)) /* If it is a C loop */
   {
   ls_list = (OM_S_OBJECT_LINKAGE *) alloca (sizeof (OM_S_OBJECT_LINKAGE));
   sts = om$get_channel_objects(objid = my_id,
                               p_chanselect = &chan,
                               size = 1,
                               count = &count,
                               list = ls_list);
   if(!(1&sts)) goto ret_end;
    /*
     * Check if this P loop is in the loop list. If not then call this
     * method w.r.t this loop.
     */
   this_loop_exists = FALSE;
   for(index=0; index<*loop_count; index++)
    {
    if((*lp_node)[index] == ls_list->S_objid)
     {
     this_loop_exists = TRUE;
     break;
     }
    } 
     if(!this_loop_exists)
     {
      if(restriction)
      {
      for(ii=0; ii<num_of_restricted_loops; ii++)
       {
       if(ls_list->S_objid == restricted_loops[ii])
        {
        add_this_loop = FALSE;
        break;
        }
       else
        add_this_loop = TRUE;
       }
      }
      if(add_this_loop)
      {
      sts = om$send(msg = message EMSloop.EMget_all_connected_loops(&msg_loc,
                                  restriction,
                                  restricted_loops,
                                  num_of_restricted_loops,
                                  lp_node, loop_count),
                              senderid = NULL_OBJID,
                              targetid = ls_list->S_objid,
                              targetos = OM_Gw_current_OS);
      if(!(1&sts)) goto ret_end;
      }
     }
    }
  else /* It is a P loop */
   {
   sts =  om$get_channel_count(objid = my_id,
                        p_chanselect = &chan,
                        count = &count);
   if(!(1&sts)) goto ret_end; 
   if(count)
    {
    ls_list=(OM_S_OBJECT_LINKAGE *)alloca(count * sizeof (OM_S_OBJECT_LINKAGE));
    sts = om$get_channel_objects(objid = my_id,
                                 p_chanselect = &chan,
                                 count = &count,
                                 size = count,
                                 list = ls_list);
    if(!(1&sts)) goto ret_end;
    } 
   for(i=0; i<count; i++)
    {
     if(!(lpprops & EMLP_PLOOP)) /* If it is a C loop */
     {
     this_loop_exists = FALSE;
     for(index=0; index<*loop_count; index++)
      {
      if((*lp_node)[index] == ls_list[i].S_objid)
       {
       this_loop_exists = TRUE;
       break;
       }
      }
     if(!this_loop_exists)
      {
      /*
       * if this loop is not being EMLP_MARKED, call the method recursively.
       */
      if(restriction)
      {
      for(ii=0; ii<num_of_restricted_loops; ii++)
       {
       if(ls_list[i].S_objid == restricted_loops[ii])
        {
        add_this_loop = FALSE;
        break;
        }
       else
        add_this_loop = TRUE;
       }
      }
      if(add_this_loop)
      {
       sts = om$send(msg = message EMSloop.EMget_all_connected_loops(&msg_loc,
                                  restriction,
                                  restricted_loops,
                                  num_of_restricted_loops,
                                 lp_node, loop_count),
                               senderid = NULL_OBJID,
                               targetid = ls_list[i].S_objid,
                               targetos = OM_Gw_current_OS);
       if(!(1&sts)) goto ret_end;
       }
      }
     }
    }
   }
ret_end:
 return(sts);
}

end implementation EMSloop;

