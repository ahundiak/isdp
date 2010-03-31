class implementation EMSsfround;

#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSdpr.h"
#include "EMSprop.h"
#include "bserr.h"
#include "bsparameters.h"
#include <stdio.h>
#include "EMSas.h"
#include "bsparameters.h"
#include "bschangepar.h"

%safe
static IGRlong get_real_edges();
%endsafe

#define ARR_INCR  16

from EMSdprparam import EMget_display_ids, EMput_display_ids;
from EMSboundary import EMget_edges;

method EMconstruct_associative(IGRlong               *EMmsg;
                               IGRushort     options;
                               GRobjid               old_objid;
                               IGRint                nb_root;
                               IGRchar               *parent_info;
                               IGRint                type;
                               IGRchar               *recomp_info;
                               struct GRvg_construct *construct_list)
/*
Description
 This method does the actual round operation.

Arguments
Input
  options: ubiquitous argument. Currently not supported and is set to
           NULL.
  nb_root : number of parents.
  list : GRid of parents.
  type : Type to interpret the recomputation information.
  recomp_info: Recomputation information. 
  construct_list: construction information.

Output
 EMmsg: Completion code.

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_Fail : For fatal errors whose exact cause cannot be determined.

Recomputation informaton for round:
 IGRdouble  cht

Objects connected on the parent channel:
 EMSparameter values containing the radius/offset values for each of the edges.
 Solid or surface on which the round was done.

History
    WBC   12/16/93     Need to check at the end of the method and
                       make sure the display_ids have been posted in case
                       they have changed.
    DLB    08/15/91    Info is now a struct which holds cht & view index.
    DLB    07/08/91    Dont EMadd if EMS-I-RndGrExit was returned.
    DLB    05/17/91    Put edge ids on parent channel.
    DLB    04/23/91    Check for EMS_I_NotFound if tag has no objid.    
    DLB    04/20/91    Creation
*/
{
 IGRdouble            save_cht, *edge_vals=NULL, *new_edge_vals=NULL;
 IGRlong              OM_stat, loc_msg;
 IGRint               ii, jj;
 IGRint               display_count=0;
 IGRuint      *parent_type=NULL;
 OMuint               new_num_edges, edge_val_count, parent_count;
 union EMSparent_info *parents = NULL;
 GRobjid              *display_ids=NULL, param_id,
                      *edge_ids=NULL, *new_edge_ids=NULL;
 struct EMSround_chamfer *r_c_info;
 IGRushort    op_type;
 IGRboolean           recompute, uniform, update_display_ids = FALSE;
 

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 recompute = options & EMSasconst_recompute;

 /*
  * Number of rad/offset value & edge pairs that I am associatied with is 
  * (nb_root - 1)/2  since one of my parents is a component parent (the last
  * parent). 
  */
 parent_count = nb_root - 1;

 r_c_info = (struct EMSround_chamfer *) recomp_info;

 if (type == EMS_ASround || type == EMS_ASround_uniform)
 {
   op_type = EMS_ROUND_OPR;
   uniform = (type == EMS_ASround_uniform);
 }
 else if (type == EMS_ASchamfer || type == EMS_ASchamfer_uniform)
 {
   op_type = EMS_CHAMFER_OPR;
   uniform = (type == EMS_ASchamfer_uniform);
 }

 parent_type = (IGRuint *) stackalloc(parent_count * sizeof(IGRint));
 if (!parent_type) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

 for(ii=0; ii<parent_count;)  /*NO INC*/
 {
   if (!uniform || ii==0)
     parent_type[ii++] = EMSdistance;

   parent_type[ii++] = EMSgrid;
 }

 parents = (union EMSparent_info *) stackalloc 
           (parent_count * sizeof(union EMSparent_info)); 
 if (!parents) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

 OM_stat = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg, NULL,
                         parent_count, parent_info,
                         parent_type, parents),
                   targetid = my_id);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 edge_val_count = uniform ? parent_count-1 : parent_count/2;

 edge_vals = (IGRdouble *) stackalloc(edge_val_count * sizeof(IGRdouble)); 
 if (!edge_vals) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

 /*Get the objid from the tag for each edge*/
 edge_ids = (GRobjid *) stackalloc(edge_val_count * sizeof(GRobjid)); 
 if (!edge_ids) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

 for(ii=0,jj=0; ii<parent_count; jj++) /*NO INC*/
 {
   if (uniform)
   {
     edge_vals[jj] = parents[0].value; /*1 val if uniform*/
     if (ii == 0) ii++;
   }
   else
     edge_vals[jj] = parents[ii++].value;
   edge_ids[jj] = parents[ii++].grobj.grid.objid;

   if (edge_ids[jj] == NULL_OBJID)
   {
     /*Must have been a mismatch on the edge id.*/
     *EMmsg = EMS_I_CantRecompute;
     goto wrapup;
   }
 }

 /*Get the real edges to round (some of the so-called edges may really be
  * loops.
  */
 OM_stat = get_real_edges(EMmsg, edge_val_count, edge_ids, edge_vals,
                            &new_num_edges,
                            &new_edge_ids, &new_edge_vals,
                            OM_Gw_current_OS, NULL);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 if (recompute)
 {
   IGRlong bs_msg;   
   IGRboolean bs_sts;
 
   /*Save the current tolerance */
   bs_sts = BSEXTRACTPAR(&bs_msg, BSTOLCHRDHT, save_cht);
   if (! bs_sts) {*EMmsg = EMS_E_BSerror; goto wrapup;}
 
   /*Set the proper tolerance for this operation*/
   bs_sts = BSchangepar(&bs_msg, BSTOLCHRDHT, r_c_info->cht);
   if (! bs_sts) {*EMmsg = EMS_E_BSerror; goto wrapup;}
 
   /*Get the display array*/ 
   OM_stat = EFsend_to_param(EMmsg, message EMSdprparam.EMget_display_ids(
                                    EMmsg, &display_count, &display_ids,
                                    NULL), 
                            my_id, OM_Gw_current_OS, &param_id, NULL); 
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   update_display_ids = TRUE;
 } 

 /*Just do it!*/
 OM_stat = om$send(msg = message EMSsfround.EMround(EMmsg,
                         construct_list->env_info, construct_list,
                         op_type, TRUE,
                         (IGRint *)&new_num_edges,
                         new_edge_ids,
                         new_edge_vals,
                         EMS_DO_DISPLAY | (recompute ? EMS_DONT_REDRAW : NULL),
                         recompute ? &display_ids : NULL, 
                         recompute ? &display_count : NULL),
                   targetid = my_id);

 if (recompute)
 {
   /*Put the display_ids in the param object.*/
   IGRboolean bs_sts;    

   /*Reset tolerance.*/
   bs_sts = BSchangepar(&loc_msg, BSTOLCHRDHT, save_cht);
   if (! bs_sts) {*EMmsg = EMS_E_BSerror; goto wrapup;}

   OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(&loc_msg,
                           display_count, display_ids, NULL),
                    targetid = param_id);
   display_ids = NULL;
   update_display_ids = FALSE;
   if (!(1 & loc_msg & OM_stat)) {*EMmsg = loc_msg; goto wrapup;}
 }
 else if ((1 & OM_stat & *EMmsg) && 
          (*EMmsg != EMS_I_RndGrExit) &&
          (*EMmsg != EMS_I_Fail))
 {
   IGRushort null=NULL;
   struct GRid *parent;
   
   parent = (struct GRid *) parent_info;
   OM_stat = om$send(msg = message EMSsfdpr.EMadd(&loc_msg, 
                           &parent[nb_root-1], NULL, 
                           construct_list->env_info, &null),
                     targetid = my_id);
   if (!(1 & OM_stat & loc_msg)) {*EMmsg = loc_msg; goto wrapup;}
 }

if(!recompute)
 if( (*EMmsg == EMS_I_Fail) || (*EMmsg == EMS_I_RndGrExit))
   *EMmsg = EMS_E_Fail;

wrapup:

 /* post the display_ids to the param object in case an error occurred
  * before the ids were posted in the "normal" flow of the code
  */

 if (update_display_ids)
 {
   OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(&loc_msg,
                                          display_count, display_ids, NULL),
                     targetid = param_id);
 }

 if (parent_type) stackfree(parent_type);
 if (new_edge_ids) om$dealloc(ptr = new_edge_ids);
 if (new_edge_vals) om$dealloc(ptr = new_edge_vals);
 EMWRAPUP(*EMmsg, OM_stat, "sfrnd:const_ass")
 return(OM_stat);
}

/*
History
    DLB     06/29/91    Change to get top edges from loop rather than from
                        an inactive edge.
    DLB     02/20/91    Creation.
*/    
static IGRlong get_real_edges(EMmsg, num_edges, edge_ids, edge_radii,
                         num_new_edges, new_edge_ids, new_edge_radii,
                         osnum, options)
IGRlong           *EMmsg;
IGRint            num_edges;
GRobjid           *edge_ids;    /*May actually be loop ids */
IGRdouble         *edge_radii;
IGRint            *num_new_edges;
GRobjid           **new_edge_ids;
IGRdouble         **new_edge_radii;
OMuword           osnum;
IGRushort options;
{
 IGRlong                OM_stat=OM_S_SUCCESS;
 IGRint                 ii, jj;
 IGRint                 num_edge_GRids=0, edge_buff_size=0; 
 struct GRid            *edge_GRids=NULL;
 extern OMuword         OPP_EMSloop_class_id; 


 *EMmsg = EMS_S_Success;

 *num_new_edges = 0;
 *new_edge_ids = NULL;

 if (options & EMS_RND_SAMERADIUS)
   (*new_edge_radii)[0] = *edge_radii;
 else
    *new_edge_radii = NULL;

 /* Get all the top edge ids and corresponding radii/offset. */
 for(ii=0; ii<num_edges; ii++)
 {
   num_edge_GRids = 0;
   OM_stat = om$send(msg = message EMSboundary.EMget_edges(EMmsg, 1, 
                           EMS_OPT_NONDEG,
                           &edge_GRids, &edge_buff_size, &num_edge_GRids), 
                     senderid = NULL_OBJID,
                     targetid = edge_ids[ii],
                     targetos = osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   for(jj=0; jj<num_edge_GRids; jj++)
   {
     (void) EFrealloc_if_needed(EMmsg, new_edge_ids, *num_new_edges, 
                                ARR_INCR, sizeof(GRobjid));
     if (!(1 & *EMmsg)) goto wrapup;

     if (! (options & EMS_RND_SAMERADIUS))
     {
       (void) EFrealloc_if_needed(EMmsg, new_edge_radii, *num_new_edges, 
                              ARR_INCR, sizeof(IGRdouble));
       if (!(1 & *EMmsg)) goto wrapup;
       (*new_edge_radii)[*num_new_edges] = edge_radii[ii];          
     }

     (*new_edge_ids)[*num_new_edges] = edge_GRids[jj].objid;
     (*num_new_edges)++;
   }                                                
 }

wrapup:
 if (edge_GRids) om$dealloc(ptr = edge_GRids);
 EMWRAPUP(*EMmsg, OM_stat, "get_real_edges")
 return(OM_stat);
}


end implementation EMSsfround;

