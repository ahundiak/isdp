class implementation EMSassoc;

#include "EMSopt.h"
#include "parametric.h"
#ifndef M_PI
#define M_PI	3.14159265358979323846
#endif
#include "grdpbdef.h"
#include "grdpbmacros.h"

from EMSdpr import EMmake_primitive1;
from EMSsurface import EMgetactiveid, EMmake_active_state;

extern OMuword OPP_EMSsurface_class_id,
               OPP_EMSsolid_class_id;

IGRint EFrotate_copy(EMmsg, options, old_objid, new_objid,num_parents,
                     parent_info, recomp_info, construct_list, mod_new_id)
IGRlong *EMmsg;
IGRuint options;
GRobjid old_objid;
GRobjid new_objid;
IGRint num_parents;
IGRchar *parent_info;
IGRchar *recomp_info;
struct GRvg_construct *construct_list;
GRobjid *mod_new_id;
{
 OMuword constr_os;
 IGRboolean undone = FALSE;
 IGRlong status,msg_loc;
 IGRint i, ref_pln_inx,num_to_place;
 union EMSparent_info *roots = NULL;
 IGRint inx;
 IGRushort undo_option;
 IGRuint root_count;
 IGRuint root_type[5];
 IGRvector line_dir;
 IGRmatrix rot_mx;
 GRobjid new_copied_id;
 struct GRid *copyee_GRid, active_GRid,mod_new_GRid;
 extern IGRboolean MAgrefmx(), MAidmx();
 OM_S_OBJID save_creator;
 struct ret_struct info_struct;
 extern OM_S_OBJID current_creator;
 struct GRid *parent_ptr;
 struct GRmd_env env;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 active_GRid.objid = NULL_OBJID;
 mod_new_GRid.objid = NULL_OBJID;
 parent_ptr = (struct GRid *)parent_info;

 root_count = num_parents;

 roots = (union EMSparent_info *)stackalloc(root_count*
         sizeof(union EMSparent_info));
 EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

 if (root_count == 4)
 {
  root_type[0] = EMSlcinfo;
  root_type[1] = EMSlcinfo;
  root_type[2] = EMSlcinfo;
  root_type[3] = EMSscalar;
 }
 else 
 {
  root_type[0] = EMSlcinfo;
  root_type[1] = EMSlcinfo;
  root_type[2] = EMSscalar;
 }

 status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg,NULL,
                   root_count, parent_info, root_type,roots),
                   senderid = new_objid,
                   targetid = new_objid);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);

/*
 * copyee_GRid is the entitiy getting mirror copied.
 */

 copyee_GRid = &roots[0].lc_info.located_obj;

 inx = 1;
 constr_os = construct_list->env_info->md_id.osnum;

 if (EFisAncestryValid(EMmsg, copyee_GRid->objid,
                       copyee_GRid->osnum, OPP_EMSsurface_class_id, FALSE))
 {
   status = om$send (msg = message EMSsurface.EMgetactiveid(EMmsg,
                           &active_GRid,NULL),
                     senderid = new_objid,
                     targetid = copyee_GRid->objid,
                     targetos = copyee_GRid->osnum);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
    ++inx;

   if (active_GRid.objid != roots[1].lc_info.located_obj.objid)
   {
    undo_option = EMS_UNDO_SAVE;
    ++inx;
    status = om$send (msg = message EMSsurface.EMmake_active_state(EMmsg,
                            &undo_option,
                            &roots[0].lc_info.module_info, NULL,NULL,
                             NULL,NULL,NULL,NULL),
                       senderid = new_objid,
                       targetid = roots[1].lc_info.located_obj.objid,
                       targetos = roots[1].lc_info.located_obj.osnum);
    if (!(1&status&*EMmsg)) goto wrapup;
    undone = TRUE;
   }
  }

  if (EFisAncestryValid(EMmsg, copyee_GRid->objid,
                       copyee_GRid->osnum, OPP_EMSsolid_class_id, FALSE))
  {
     status = om$change_class(objid = new_objid,
                              osnum = constr_os,
                              sd_override = OM_K_change_class_sd_override,
                              classname = "EMSsolid");
     if (!(1&status)) goto wrapup;
  }
  else if (EFisAncestryValid(EMmsg, copyee_GRid->objid,
                       copyee_GRid->osnum, OPP_EMSsurface_class_id, FALSE))
  {
     status = om$change_class(objid = new_objid,
                              osnum = constr_os,
                              sd_override = OM_K_change_class_sd_override,
                              classname = "EMScompsurf");
     if (!(1&status)) goto wrapup;
  }
  else 
  {
     status = om$change_class(objid = new_objid,
                              osnum = constr_os,
                              sd_override = OM_K_change_class_sd_override,
                              classname = "EMSagrp");
     if (!(1&status)) goto wrapup;
  }
  *mod_new_id = new_objid;
  mod_new_GRid.objid = *mod_new_id;
  mod_new_GRid.osnum = constr_os;

  {
        IGRint bytes_in, bytes_out;
        bytes_in = sizeof (struct GRmd_env);

/*
 * This should return a identity environment. In case of connections
 * across reference files it does not matter.
 */
        status = gr$get_module_env(msg = EMmsg,
                            sizbuf = &bytes_in,
                            buffer = &env,
                            nret = &bytes_out);
    }

   status = om$send (msg = message NDnode.NDgive_structure (&msg_loc, 
                           &info_struct,
                           &env),
                     senderid = NULL_OBJID,
                     targetid = parent_ptr[inx].objid,
                     targetos = parent_ptr[inx].osnum);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);                             
   status = BSmkvec(&msg_loc,line_dir,info_struct.var.line_st.p0,
                    info_struct.var.line_st.p1);
   ++inx;

   num_to_place = roots[inx].value;

   for (i=0;i<num_to_place;i++)
   {
    IGRdouble angle;

    angle = (360.0/num_to_place)*i;
    angle = M_PI*angle/180.0;

    MAgrotmx(&msg_loc,line_dir,info_struct.var.line_st.p0,&angle,rot_mx);
    EMerr_hndlr(!(1&msg_loc), *EMmsg, MSFAIL, wrapup);

    save_creator = current_creator;
    current_creator = NULL_OBJID;
    status = om$send (msg = message GRgraphics.GRcptform(EMmsg,
                        &roots[0].lc_info.module_info,rot_mx,
                        construct_list->env_info,&new_copied_id),
                  senderid = new_objid,
                  targetid = roots[0].lc_info.located_obj.objid,
                  targetos = roots[0].lc_info.located_obj.osnum);
    current_creator = save_creator;
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    if (EFisAncestryValid(EMmsg, new_copied_id,
                       constr_os, OPP_EMSdpr_class_id, FALSE))
    {
      struct GRid new_GRid;
      save_creator = current_creator;
      current_creator = NULL_OBJID;
      status = om$send (msg = message EMSdpr.EMmake_primitive1(EMmsg,
                          construct_list->env_info, &new_GRid),
                    senderid = new_objid,
                    targetid = new_copied_id,
                    targetos = constr_os);
      current_creator = save_creator;
      EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

      new_copied_id = new_GRid.objid;
    }

    if (EFisAncestryValid(EMmsg, new_copied_id, constr_os, 
                          OPP_EMSsolid_class_id, FALSE))
    {
     status = om$change_class(objid = new_copied_id,
                              osnum = constr_os,
                              sd_override = OM_K_change_class_sd_override,
                              classname = "EMScompsurf");
     if (!(1&status)) goto wrapup;
    }

    status = om$send (msg = message GRconnector.GRrigidconn(&msg_loc,
                            &mod_new_GRid, (IGRlong*) &num_to_place),
                      senderid = *mod_new_id,
                      targetid = new_copied_id);
    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
   }


wrapup:
 if (undone)
 {
  IGRlong l_msg;
/*
 * Restore the state.
 */
  undo_option = EMS_UNDO_SAVE;

  om$send (msg = message EMSsurface.EMmake_active_state(&l_msg,
                 &undo_option, &roots[0].lc_info.module_info,NULL,NULL,
                 NULL,NULL,NULL,NULL),
           senderid = new_objid,
           targetid = active_GRid.objid,
           targetos = active_GRid.osnum);
 }
 if (!(1&status&*EMmsg)) 
 {
   IGRlong l_msg;
   if (mod_new_GRid.objid != NULL_OBJID)
   status = om$send (msg = message GRgraphics.GRdelete(&l_msg,
                       construct_list->env_info),
                     senderid = NULL_OBJID,
                     targetid = mod_new_GRid.objid,
                     targetos = mod_new_GRid.osnum);
   *mod_new_id = NULL_OBJID;
 }
 return (status);
}

IGRlong EFplace_rotate_copy(EMmsg, options, copyee_info,
                            axis_info,num_info,
                            construct_list, res_id)
IGRlong *EMmsg;
unsigned int options;
struct GRlc_info *copyee_info;
struct GRlc_info *axis_info;
struct GRevent *num_info;
struct GRvg_construct *construct_list;
OM_S_OBJID *res_id;
{
 OMuword constros;
 IGRint num_parents = 1;
 IGRlong status;
 GRobjid loc_obj_id, new_objid;
 struct GRid active_GRid;
 struct EMSobject_info list[5];
 struct EMSvalue_info valinfo;
 extern OMuword OPP_EMSparamvl_class_id;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 *res_id = NULL_OBJID;

 list[0].grid = copyee_info->located_obj;
 list[0].env = copyee_info->module_info;
 num_parents = 1;
 constros = construct_list->env_info->md_id.osnum;

 if (EFisAncestryValid(EMmsg,list[0].grid.objid,list[0].grid.osnum,
                       OPP_EMSsurface_class_id,FALSE))
 {
  status = om$send (msg = message EMSsurface.EMgetactiveid(EMmsg,
                          &active_GRid,NULL),
                    senderid = NULL_OBJID,
                    targetid = list[0].grid.objid,
                    targetos = list[0].grid.osnum);
  if (!(1&status&*EMmsg)) goto wrapup;

  list[1].grid = active_GRid;
  list[1].env = copyee_info->module_info;

  ++(num_parents);
 }

 list[num_parents].grid = axis_info->located_obj;
 list[num_parents].env = axis_info->module_info;
 ++num_parents;

 valinfo.type = EMSdatainfo_event;
 valinfo.valevent = num_info; 

 status = EMgetparval_object(EMmsg,constros,NULL,&valinfo,&list[num_parents]);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
/*
 * We need to do this since we cannot locate paramvl without any handles
 */

 if (EFisAncestryValid(EMmsg, list[num_parents].grid.objid,
                       list[num_parents].grid.osnum, OPP_EMSparamvl_class_id, 
                       FALSE))
 {
     status = om$change_class(objid = list[num_parents].grid.objid,
                              osnum = list[num_parents].grid.osnum,
                              sd_override = OM_K_change_class_sd_override,
                              classname = "expression");
     if (!(1&status)) goto wrapup;
 }
 ++num_parents;


 status = om$construct(classid = OPP_EMSassoc_class_id,
                       p_objid = &loc_obj_id,
                       osnum = constros);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 *res_id = loc_obj_id;

 status = om$send (msg = message EMSassoc.EMinit_associative_function(EMmsg,
                         NULL,num_parents,list,"EFrotate_copy",
                         0,NULL,construct_list, &new_objid),
                   senderid = NULL_OBJID,
                   targetid = loc_obj_id,
                   targetos = constros);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 *res_id = new_objid;

 if (options & EMSasconst_notassociative)
 {
  struct GRid src_GRid;
  src_GRid.objid = NULL_OBJID;
  status = om$send (msg = message NDnode.NDmove_to_root(EMmsg,
                          &src_GRid, construct_list->env_info),
                    senderid = new_objid,
                    targetid = new_objid,
                    targetos = constros);
  if (1&status&*EMmsg)
   *res_id = src_GRid.objid;
  else
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }
 }

wrapup:
 if (!(1&status&*EMmsg))
 {
  IGRlong l_msg;

  if (*res_id != NULL_OBJID)
  {
   om$send (msg = message GRgraphics.GRdelete(&l_msg,
                  construct_list->env_info),
            senderid = NULL_OBJID,
            targetid = *res_id,
            targetos = constros);
   *res_id = NULL_OBJID;
  }
 }
 return (status);
}
end implementation EMSassoc;

