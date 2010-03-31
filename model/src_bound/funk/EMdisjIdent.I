/*
 * This function takes in a solid/surface, a set of surface(s) which have
 * been listed as open surfaces. It output the boolean flag indicating
 * whether there is likelyhood of occurence of disjointness.
 *
 * Procedure
 * ---------
 * 1) Get all the surfaces/loops associated with the input solid.
 * 2) Get all the connected loops of a loop which does not belong
 *    to the list of passed surfaces keeping into account
 *    a) The common edges associated with the surfaces passed in the 
 *       list are not considered for getting "across".
 *    b) Take in the other loop which does not belong to the list passed in
 *       as well as output of (a) and find all the adjacent loops. If there
 *       is an existence of such a set, it probably accounts for the
 *       disjointness.
 *
 *    History:
 *    Rustagi  10/19/93   Creation
 */

class implementation Root;

#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "ex.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "emsdef.h"
#include "emsdattyp.h"                  /* enum EMSdata_ etc. */
#include "EMSmsgdef.h"                  /* EMS return codes */
#include "EMSlogic.h"
#include "OMprimitives.h"
#include "OMmacros.h"                   /* OM_BLOCK_MOVE */
#include "emserr.h"                     /* EMerr_hndlr */
#include "bsparameters.h"
#include "bserr.h"
#include "emsinterdef.h"
#include "EMSprop.h"
#include "dpmacros.h"
#include "emscvexten.h"
#include "EMS_S.h"
#include "EMS_E.h"
#include "msmacros.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"

#define NOT_PROCESSED 0
#define PROCESSED 1

/* imports */

from GRowner import GRget_number_components, GRget_components;
from EMSloop import EMget_all_connected_loops, EMget_props, EMset_props;
from EMSloop import EMgetsurface_info;

%safe
static IGRlong  EMget_restricted_loop();
%endsafe

IGRlong EMfind_disjointness(msg,
                            solid_id,
                            opensfs,
                            modenv,
                            num_of_opensfs,
                            options,
                            is_disjoint)
  
IGRlong *msg;
struct GRid *solid_id;
GRobjid *opensfs;
struct GRmd_env *modenv;
IGRint num_of_opensfs;
IGRushort options;
IGRboolean *is_disjoint;
{
IGRlong msg_loc, sts;
IGRint count, returned_count, num_of_sets=0;
IGRint k;
OM_S_CHANSELECT to_loopset, ls_lp_chan;
OM_S_OBJECT_LINKAGE sf_ls_list, ls_lp_list;
OMuint num_ls, num_lp;
struct GRid *objects=NULL;
struct EMSsfinfo *op_sfinfo=NULL, *not_opsfinfo=NULL;
GRobjid **lp_node, temp_id;
struct EMSpartolbasis partolb;
IGRint *lp_count, num_of_restricted_loops, i,j, not_opensf_count, opensf_count;
IGRboolean restriction, surf_belong_to_open_sfs;
GRobjid *restricted_loops=NULL;
GRspacenum os;


 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 lp_node = NULL;
 lp_count = NULL;
 os = solid_id->osnum;
 options = options;  /* To avoid compiler warning */

 partolb.mattyp = &modenv->md_env.matrix_type;
 partolb.mat = modenv->md_env.matrix;
 partolb.in_world = TRUE;
 partolb.is_valid = FALSE;

 if(num_of_opensfs)
  {
  restriction = TRUE;
  /*
   * When a surface is identified, we take the outermost P loop and all
   * the immediate inner C loops as being restricted loops.
   */
  sts = EMget_restricted_loop(&msg_loc,
                              num_of_opensfs,
                              opensfs,
                              modenv,
                              &num_of_restricted_loops,
                              &restricted_loops);
  if(!(1&sts)) goto ret_end;
  }
 else
  {
  restriction = FALSE;
  num_of_restricted_loops = 0;
  }
 /*
  * Find all the components of the input solid
  */
 sts = om$send(msg = message GRowner.GRget_number_components(&msg_loc, 
                                         &count),
                             senderid = NULL_OBJID,
                             targetid = solid_id->objid,
                             targetos = solid_id->osnum);
 EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, ret_end);
 objects = (struct GRid *) om$malloc (size = count * sizeof(struct GRid));
 EMerr_hndlr(!objects, *msg, EMS_E_DynamicMemoryAllocated,ret_end);
 sts = om$send(msg = message GRowner.GRget_components(&msg_loc,
                           modenv, objects, count, &returned_count, 0,
                           MAXINT),
                             senderid = NULL_OBJID,
                             targetid = solid_id->objid,
                             targetos = solid_id->osnum);
 EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, ret_end);

 op_sfinfo=(struct EMSsfinfo *)om$malloc(size = num_of_opensfs
                                       * sizeof(struct EMSsfinfo));
 EMerr_hndlr(!op_sfinfo, *msg, EMS_E_DynamicMemoryAllocated,ret_end);
 for(i=0; i<num_of_opensfs; i++)
  {
  op_sfinfo[i].id.objid = opensfs[i];
  op_sfinfo[i].id.osnum = os;
  op_sfinfo[i].geom = NULL;
  }
 not_opensf_count=1;
 opensf_count=1;
 for(i=0; i<count; i++)
  {
  surf_belong_to_open_sfs = FALSE;
  for(j=0; j<num_of_opensfs; j++)
   { 
   if(objects[i].objid == opensfs[j])
    {
    opensf_count ++;
    surf_belong_to_open_sfs = TRUE;
    break;
    }
   }
  if(!surf_belong_to_open_sfs)
   {
    if(not_opsfinfo == NULL)
     {
     not_opsfinfo=(struct EMSsfinfo *)om$malloc(size=sizeof(struct EMSsfinfo));
     EMerr_hndlr(!not_opsfinfo, *msg, EMS_E_DynamicMemoryAllocated,ret_end);
     }
    else
     {
     not_opensf_count ++;
     not_opsfinfo=(struct EMSsfinfo *)om$realloc(ptr = (IGRchar *)not_opsfinfo,
                   size = not_opensf_count * sizeof(struct EMSsfinfo));
     }
    not_opsfinfo[not_opensf_count - 1].id.objid = objects[i].objid;
    not_opsfinfo[not_opensf_count - 1].id.osnum = objects[i].osnum;
    not_opsfinfo[not_opensf_count - 1].geom =  NULL;
    not_opsfinfo[not_opensf_count - 1].props = NOT_PROCESSED;
   }
  }

  sts = EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);
  sts = EMmake_chanselect(EMSloopset_to_loops, &ls_lp_chan);
  num_of_sets = 1;
  for(i=0; i<not_opensf_count; i++)
   {
   /*
    * Get the total number of distinct sets of connected loops we get
    * during this processing.
    * Here the word distinct is very important .....
    * 1)if the number of elements in the sets are different, they are
    *   distinct.
    * 2)if the number of elements are same then no element in either of the
    *   set should be common.
    * So what we need is:
    * 1) to find how many sets are there.
    * 2) actual set information.
    */
   if(not_opsfinfo[i].props == NOT_PROCESSED)
    {
     sts = om$get_channel_objects (osnum = not_opsfinfo[i].id.osnum,
                                   objid = not_opsfinfo[i].id.objid,
                                   p_chanselect = &to_loopset,
                                   list = &sf_ls_list,
                                   size = 1,
                                   count = &num_ls);
     EMerr_hndlr(!(1&sts) || !num_ls, *msg, EMS_E_OMerror, ret_end);
     sts = om$get_channel_objects (osnum = not_opsfinfo[i].id.osnum,
                                   objid = sf_ls_list.S_objid,
                                   p_chanselect = &ls_lp_chan,
                                   list = &ls_lp_list,
                                   size = 1,
                                   count = &num_lp);
     EMerr_hndlr (!(1&sts), *msg, EMS_E_OMerror, ret_end);
     /*
      * Get all the connected loops of this loop
      */
     if(lp_node == NULL)
      {
      lp_node = (GRobjid **)om$malloc(size = sizeof(GRobjid *));
      EMerr_hndlr(!lp_node, *msg, EMS_E_DynamicMemoryAllocated,ret_end);
      lp_count = (IGRint *)om$malloc(size = sizeof(IGRint));
      EMerr_hndlr(!lp_count, *msg, EMS_E_DynamicMemoryAllocated,ret_end);
      }
     else
      {
      num_of_sets ++;
      lp_node = (GRobjid **)om$realloc(ptr = (IGRchar *)(lp_node),
                            size = num_of_sets * sizeof(GRobjid *));
      lp_count = (IGRint *)om$realloc(ptr = (IGRchar *)(lp_count),
                            size = num_of_sets * sizeof(IGRint));
      }

     lp_node[num_of_sets - 1] = NULL;
     sts = om$send(msg = message EMSloop.EMget_all_connected_loops(&msg_loc,
                                            restriction,
                                            restricted_loops,
                                            num_of_restricted_loops,
                                            &lp_node[num_of_sets - 1],
                                            &lp_count[num_of_sets - 1]),
                                 senderid = NULL_OBJID,
                                 targetid = ls_lp_list.S_objid,
                                 targetos = not_opsfinfo[i].id.osnum);
     EMerr_hndlr (!(1&sts), *msg, EMS_E_OMerror, ret_end); 
     for(j=0; j<lp_count[num_of_sets - 1]; j++)
      {
      /*
       * Get the surfaces of all the associated loops and mark them being 
       * processed.
       */
      sts = om$send(msg = message EMSloop.EMgetsurface_info(&msg_loc,
                                     &temp_id, &partolb),
                                  senderid = NULL_OBJID,
                                  targetid = lp_node[num_of_sets - 1][j],
                                  targetos = not_opsfinfo[i].id.osnum);
      EMerr_hndlr (!(1&sts), *msg, EMS_E_OMerror, ret_end); 
      for(k=0; k<not_opensf_count; k++)
       {
       if(not_opsfinfo[k].props == NOT_PROCESSED)
        {
        if(temp_id == not_opsfinfo[k].id.objid)
         {
         not_opsfinfo[k].props = PROCESSED;
         break;
         }
        }
       }
      }
     }
    } 

   /*
    * At this stage all the sets have been determined. Now follows the 
    * classification for determination of the dis-joint set.
    */
   if(num_of_sets == 1) /* There is no disjointness */
    *is_disjoint = FALSE;
   else
    *is_disjoint = TRUE;

#ifdef DEBUG
   if(*is_disjoint)
   {
   fprintf(stdout, "DISJOINT RESULTS : NUM_OF_SETS = %d\n",num_of_sets);
   }
   else
   {
   fprintf(stdout, "VALID RESULT: NUM_OF_SETS = %d\n",num_of_sets);
   }
#endif

ret_end:
 if(objects) om$dealloc (ptr = objects);
/* fix for mlk */
 if(restricted_loops) om$dealloc (ptr = restricted_loops);
 if(op_sfinfo) om$dealloc (ptr = op_sfinfo);
 if(not_opsfinfo) om$dealloc (ptr = not_opsfinfo);
 if(lp_count) om$dealloc (ptr = lp_count);
 for(i=0; i<num_of_sets; i++)
  if(lp_node[i]) om$dealloc (ptr = lp_node[i]);
 if(lp_node) om$dealloc (ptr = lp_node);
 return(sts);
}

static IGRlong  EMget_restricted_loop(msg,
                                     num_of_opensfs,
                                     opensfs,
                                     modenv,
                                     num_of_restricted_loops,
                                     restricted_loops)
IGRlong *msg;
IGRint num_of_opensfs;
GRobjid *opensfs;
struct GRmd_env *modenv;
IGRint *num_of_restricted_loops;
GRobjid **restricted_loops;
{
IGRlong sts;
IGRint i, num_res_lp, last_count, current_count, mem_cnt, k;
OM_S_CHANSELECT to_loopset, to_loop, to_inner;
OM_S_OBJECT_LINKAGE ls_list, lp_list, *junk_list=NULL;
OMuint count, ret_cnt, cnt;
IGRint last_index, j;
GRspacenum os;

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 last_count = 0;
 current_count = 0;
 num_res_lp = 1;
 os = modenv->md_id.osnum;
 mem_cnt = last_index = 0;

 sts = EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);
 sts = EMmake_chanselect(EMSloopset_to_loops, &to_loop);
 sts = EMmake_chanselect(EMSloop_to_inner, &to_inner);

 for(i=0; i<num_of_opensfs; i++)
  {
  sts = om$get_channel_objects(objid = opensfs[i],
                         osnum = os,
                         p_chanselect = &to_loopset,
                         size = 1,
                         list = &ls_list,
                         count = &count);

  sts = om$get_channel_objects(objid = ls_list.S_objid,
                         osnum = os,
                         p_chanselect = &to_loop,
                         size = 1,
                         list = &lp_list,
                         count = &count);
   /*
    * Get all the C loops associated with this surface immediate to the
    * outer modst P loop.
    */
  sts = om$get_channel_count(objid = lp_list.S_objid,
                         osnum = os,
                         p_chanselect = &to_inner,
                         count = &ret_cnt);
  last_index = mem_cnt;
  mem_cnt = last_index + count + ret_cnt;

  junk_list = (OM_S_OBJECT_LINKAGE *)om$malloc(size =
                           (ret_cnt+1) * sizeof(OM_S_OBJECT_LINKAGE));
  EMerr_hndlr(!junk_list,*msg,EMS_E_DynamicMemoryAllocated,ret_end);
  if(ret_cnt)
  {
  sts = om$get_channel_objects(objid = lp_list.S_objid,
                         osnum = os,
                         p_chanselect = &to_inner,
                         size = ret_cnt,
                         list = junk_list,
                         count = &cnt);
 junk_list[cnt].S_objid = lp_list.S_objid;
  }
 else
  junk_list[0].S_objid = lp_list.S_objid;

 if(*restricted_loops == NULL)
  {
  *restricted_loops = (GRobjid *)om$malloc(size = mem_cnt *  sizeof(GRobjid));
  EMerr_hndlr(!(*restricted_loops),*msg,EMS_E_DynamicMemoryAllocated,ret_end);
  for(j=0; j<ret_cnt+1; j++)
   (*restricted_loops)[j] = junk_list[j].S_objid;
  }
 else
  {
  *restricted_loops = (GRobjid *)om$realloc(
                          ptr = (IGRchar *)(*restricted_loops),
                          size = mem_cnt *  sizeof(GRobjid));
  EMerr_hndlr(!(*restricted_loops),*msg,EMS_E_DynamicMemoryAllocated,ret_end);
  for(j=last_index,k=0; j<mem_cnt && k<ret_cnt+1; j++,k++)
   (*restricted_loops)[j] = junk_list[k].S_objid;
  }
  /*
   * Free the junk_list variable 
   */
   if(junk_list) om$dealloc (ptr = junk_list); junk_list = NULL;
  }
  *num_of_restricted_loops = mem_cnt; 
ret_end:
 if(junk_list)
   {
   om$dealloc(ptr = junk_list);
   junk_list = NULL;
   }
  return(sts);
}

  
end implementation Root;



