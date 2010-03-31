class implementation EMAdatpln;

#include "EMSasnuc.h"

IGRint EFcreate_ref_angle_to_plane(EMmsg, options,
       planar_element,
       elem_info,
       value_event,
       props,
       construct_list,
       cons_obj)
IGRlong *EMmsg;
unsigned int options;
struct GRlc_info *planar_element;
struct GRlc_info *elem_info;
struct GRevent *value_event;
IGRint props;
struct GRvg_construct *construct_list;
OM_S_OBJID *cons_obj;

{
 IGRlong status;
 IGRushort const_options;
 IGRint  type, num_parents;
 OMuword constros;
 struct EMSobject_info list[4];
 struct EMSvalue_info val;
 struct EMSdatpln_planar_element_info info;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 *cons_obj = NULL_OBJID;
 constros = construct_list->env_info->md_id.osnum;

 info.props = 0;

 info.props = props;

 list[0].grid = planar_element->located_obj;
 list[0].env =  planar_element->module_info;
 list[1].grid = elem_info->located_obj;
 list[1].env  = elem_info->module_info;

 type = EMS_ASangle_to_planar_element;
 val.type = EMSdatainfo_event;
 val.valevent = value_event;

 if (value_event->subtype != GRst_DEFAULT)
 {
  status = EMgetparval_object (EMmsg, constros, NULL, &val,
                   &list[2]);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  num_parents = 3;
  const_options = NULL;
 }
 else
 {
  num_parents = 2;
  const_options = EMSasconst_no_autodimension;
 }

 status = om$construct(classid = OPP_EMAdatpln_class_id,
                       p_objid = cons_obj,
                       osnum = constros);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$send (msg = message EMSassoc.EMinit_associative(EMmsg,
                            ((options & EMSasconst_notassociative) ?
                              EMSasconst_noautodimension : const_options), 
                             num_parents, list, type,
                             sizeof (struct EMSdatpln_planar_element_info),
                             (char *)&info,
                             construct_list),
                       senderid = NULL_OBJID,
                       targetid = *cons_obj,
                       targetos = constros);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if (options & EMSasconst_notassociative)
 {
  struct GRid src_GRid;

  src_GRid.objid = NULL_OBJID;
  status = om$send (msg = message NDnode.NDmove_to_root(EMmsg,
                               &src_GRid,construct_list->env_info),
                    senderid = *cons_obj,
                    targetid = *cons_obj,
                    targetos = constros);
  if (1&status&*EMmsg)
   *cons_obj = src_GRid.objid;
  else
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }
 }
 

wrapup:
 if (!(1&status&*EMmsg))
 {
  IGRlong cln_sts, cln_msg;

  if (*cons_obj != NULL_OBJID)
  {
   cln_sts = om$send (msg = message GRgraphics.GRdelete(&cln_msg,
                            construct_list->env_info),
                      senderid = NULL_OBJID,
                      targetid = *cons_obj,
                      targetos = constros);
   *cons_obj = NULL_OBJID;
  }
 }
 return (status);
}

IGRint EFcreate_ref_parallel_to_plane(EMmsg, options,
       planar_element,
       elem_info,
       value_event,
       props,
       construct_list,
       cons_obj)
IGRlong *EMmsg;
unsigned int options;
struct GRlc_info *planar_element;
struct GRlc_info *elem_info;
struct GRevent *value_event;
IGRint props;
struct GRvg_construct *construct_list;
OM_S_OBJID *cons_obj;

{
 IGRlong status;
 IGRushort const_options=NULL;
 IGRint  type, num_parents;
 OMuword constros;
 struct EMSobject_info list[4], *next_ptr;
 struct EMSvalue_info val;
 struct EMSdatpln_planar_element_info info;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 *cons_obj = NULL_OBJID;
 constros = construct_list->env_info->md_id.osnum;

 info.props = 0;

 info.props = props;

 list[0].grid = planar_element->located_obj;
 list[0].env =  planar_element->module_info;

 if (elem_info->located_obj.objid != NULL_OBJID)
 {
  list[1].grid = elem_info->located_obj;
  list[1].env  = elem_info->module_info;
  next_ptr = &list[2];
  num_parents = 3;
 }
 else
 {
  next_ptr = &list[1];
  num_parents = 2;
 }

 type = EMS_ASparallel_to_planar_element;
 val.type = EMSdatainfo_event;
 val.valevent = value_event;

 if (value_event->subtype != GRst_DEFAULT)
 {
  status = EMgetparval_object (EMmsg, constros, NULL, &val,
                   next_ptr);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 else
 {
  if (EFisAncestryValid(EMmsg, planar_element->located_obj.objid,       
                         planar_element->located_obj.osnum,
                          OPP_EMSdatpln_class_id, FALSE))
  {
   *cons_obj = planar_element->located_obj.objid;
   return (OM_S_SUCCESS);
  }
  else
  {
   --(num_parents);
   type = EMS_ASfrom_planar_element;
   const_options = EMSasconst_no_autodimension;
  }
 }

 status = om$construct(classid = OPP_EMAdatpln_class_id,
                       p_objid = cons_obj,
                       osnum = constros);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$send (msg = message EMSassoc.EMinit_associative(EMmsg,
                            ((options & EMSasconst_notassociative) ?
                              EMSasconst_noautodimension : const_options), 
                              num_parents, list, type,
                             sizeof (struct EMSdatpln_planar_element_info),
                             (char *)&info,
                             construct_list),
                       senderid = NULL_OBJID,
                       targetid = *cons_obj,
                       targetos = constros);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if (options & EMSasconst_notassociative)
 {
  struct GRid src_GRid;

  src_GRid.objid = NULL_OBJID;
  status = om$send (msg = message NDnode.NDmove_to_root(EMmsg,
                               &src_GRid,construct_list->env_info),
                    senderid = *cons_obj,
                    targetid = *cons_obj,
                    targetos = constros);
  if (1&status&*EMmsg)
   *cons_obj = src_GRid.objid;
  else
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }
 }
 

wrapup:
 if (!(1&status&*EMmsg))
 {
  IGRlong cln_sts, cln_msg;

  if (*cons_obj != NULL_OBJID)
  {
   cln_sts = om$send (msg = message GRgraphics.GRdelete(&cln_msg,
                            construct_list->env_info),
                      senderid = NULL_OBJID,
                      targetid = *cons_obj,
                      targetos = constros);
   *cons_obj = NULL_OBJID;
  }
 }
 return (status);
}
end implementation EMAdatpln;

