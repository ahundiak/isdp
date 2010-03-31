/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;
/*
History
    DLB    05/13/91     Support state parents during recompute.
    DLB    05/03/91     Support new init options and already constructed rnd
                        id.
    DLB    04/20/91     Creation.
*/
#include "EMSasdef.h"
#include "EMSas.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "EMSdpr.h"

from EMSboundary import EMgetsurface_info;

IGRlong EFround_chamfer(EMmsg, init_options, do_chamfer,
                        num_edges, edge_ids, edge_vals, 
                        construct_list, res_id, general_options) 
IGRlong               *EMmsg;
IGRushort     init_options;
IGRboolean            do_chamfer;         /* If true chamfer else round*/ 
IGRint                num_edges;          /* num to rnd/cham           */
GRobjid               *edge_ids;          /* ids to rnd/cham           */
struct EMSvalue_info  *edge_vals;         /* rad/offset values         */
struct GRvg_construct *construct_list;    /* Construction information  */
struct GRid           *res_id;            /* Resultant id              */
IGRushort     general_options;
{
 IGRlong               OM_stat=OM_S_SUCCESS, bs_msg;
 IGRint                obj_type, op_type, num_parents, ii, jj;
 GRobjid               surf_id;
 struct GRid           active_state_GRid, *src_parent_list=NULL;
 struct EMSobject_info *parent_list=NULL;
 struct EMSround_chamfer r_c_info;
 IGRboolean            status, recompute=FALSE, uniform;
 OMuword               osnum;
 extern OMuword        OPP_EMSsfround_class_id, OPP_EMSslround_class_id;
 extern OM_S_OBJID     current_creator;


 *EMmsg = EMS_S_Success;

 if (! num_edges) {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
   
 uniform = general_options & EFrnd_cham_UNIFORM;

 if (do_chamfer)
   op_type = uniform ? EMS_ASchamfer_uniform : EMS_ASchamfer;
 else
   op_type = uniform ? EMS_ASround_uniform : EMS_ASround;
  
 osnum = construct_list->env_info->md_id.osnum;

 if (res_id->objid == NULL_OBJID)
 {
   /*Get the active id*/
   OM_stat = om$send(msg = message EMSboundary.EMgetsurface_info(EMmsg,
                           &surf_id, NULL),
                     senderid = NULL_OBJID,
                     targetid = edge_ids[0],
                     targetos = osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;                   
  
   OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                           &active_state_GRid, NULL),
                     senderid = NULL_OBJID,
                     targetid = surf_id,
                     targetos = osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   /*Determine if should create a surface or solid class*/
   EFclassify_obj_type(EMmsg, &obj_type, &active_state_GRid);
   if (!(1 & *EMmsg)) goto wrapup;

   res_id->osnum = osnum;
   OM_stat = om$construct(classid = (obj_type ? OPP_EMSslround_class_id :
                                                OPP_EMSsfround_class_id),
                          osnum = osnum,
                          p_objid = &res_id->objid);
   if (!(1 & OM_stat)) goto wrapup;
 }
 else recompute = TRUE;

 current_creator = res_id->objid;

 if (uniform)
 {
   /*Uniform value, all edges and active id*/
   num_parents = num_edges + 2;
 }
 else
   /*all value & edge pairs and active id*/
   num_parents = num_edges * 2 + 1;

 parent_list = (struct EMSobject_info *) stackalloc
               (num_parents * sizeof(struct EMSobject_info));
 if (!parent_list) {*EMmsg = EMS_E_NoStackMemory; goto wrapup;}

 /*Construct the EMSparamval parents*/
 for(ii=0, jj=0; ii<(num_parents-1); jj++)  /*NO INC*/
 {
   if (!uniform || ii==0)
   {
     OM_stat = EMgetparval_object(EMmsg, osnum, NULL, &edge_vals[jj],
                                  &parent_list[ii]);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;
     ii++;
   }
   parent_list[ii].grid.objid = edge_ids[jj];
   parent_list[ii].grid.osnum = osnum;
   parent_list[ii].env = *(construct_list->env_info);
   ii++;
 }
  
 if (!recompute)
 {
   /*We want the round object to be a child of the active state.*/
   parent_list[num_parents-1].grid = active_state_GRid;
   OM_BLOCK_MOVE(construct_list->env_info,
                 &parent_list[num_parents-1].env,
                 sizeof(struct GRmd_env)); 
 }
 else
 {
   /*Its a recompute so just NULL out the state parent*/
   parent_list[num_parents-1].grid.objid = NULL_OBJID;
 }

 r_c_info.num_views = 0;

 /*Remember the cht for this op.*/
 status = BSEXTRACTPAR(&bs_msg, BSTOLCHRDHT, r_c_info.cht);
 if (! status) {*EMmsg = EMS_E_BSerror; goto wrapup;}

 if (!recompute)
 {
   /* Tapadia-8/27/91. If general options is non_assoc don't auto dimension */
   if(general_options & EFfunc_PLACE_NON_ASSOC)
	init_options |= EMSasconst_noautodimension;

   /* This function initializes and constructs the associative round object.*/
   OM_stat = om$send(msg = message EMSassoc.EMinit_associative(EMmsg,
                           init_options, 
                           num_parents,
                           parent_list,
                           op_type,
                           sizeof(struct EMSround_chamfer),
                           (IGRchar *) &r_c_info,
                           construct_list),
                     senderid = NULL_OBJID,
                     targetid = res_id->objid,
                     targetos = res_id->osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
   if (general_options & EFfunc_PLACE_NON_ASSOC)
   {
     IGRlong loc_msg=EMS_S_Success, loc_sts=OM_S_SUCCESS;
     loc_sts = om$send(msg = message NDnode.NDmove_to_root(&loc_msg, res_id,
                             construct_list->env_info),
                       senderid = NULL_OBJID,
                       targetid = res_id->objid,
                       targetos = res_id->osnum);
     if (!(1&loc_msg&loc_sts)) {OM_stat=loc_sts; *EMmsg=loc_msg; goto wrapup;}
   }
 }
 else
 {
   if (general_options & EFfunc_CREATE_SOURCE)
   {
     src_parent_list = (struct GRid *) stackalloc
                       (num_parents * sizeof(struct GRid));
     if (!src_parent_list) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}
       
     OM_stat = om$send(msg = message EMSassoc.EMmake_source(EMmsg, NULL, 
                             num_parents, parent_list, src_parent_list),
                       senderid = NULL_OBJID,
                       targetid = res_id->objid,
                       targetos = res_id->osnum);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;                     
   }

   OM_stat = om$send(msg = message EMSdpr.EMevaluateOps(EMmsg,
                           EMeval_op_DO_DISPLAY, construct_list->env_info,
                           num_parents, src_parent_list, 
                           op_type, (IGRchar *) &r_c_info),
                     senderid = NULL_OBJID,
                     targetid = res_id->objid,
                     targetos = res_id->osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 }

wrapup:
 current_creator = NULL_OBJID;
 if (parent_list) stackfree(parent_list);   /*STACKMEM-FREE FIRST ONLY*/
 EMWRAPUP(*EMmsg, OM_stat, "EFround_chamfer")
 return (OM_stat);
}
end implementation EMSsfround;

