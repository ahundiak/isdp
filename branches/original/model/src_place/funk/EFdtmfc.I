class implementation EMAdatpln;

IGRint EFcreate_datum_plane_from_face(EMmsg, options,
       planar_element,
       elem_info,
       element_type,
       construct_list,
       cons_obj)
IGRlong *EMmsg;
unsigned int options;
struct GRlc_info *planar_element;
struct GRlc_info *elem_info;
IGRint element_type;
struct GRvg_construct *construct_list;
OM_S_OBJID *cons_obj;

{
 IGRlong status;
 IGRint  type;
 OMuword constros;
 struct EMSobject_info list[3];
 struct EMSdatpln_planar_element_info info;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 *cons_obj = NULL_OBJID;
 constros = construct_list->env_info->md_id.osnum;

 info.props = 0;

 info.props = element_type;


 list[0].grid = planar_element->located_obj;
 list[0].env =  planar_element->module_info;
 list[1].grid = elem_info->located_obj;
 list[1].env  = elem_info->module_info;

 type = EMS_ASfrom_planar_element;

 status = om$construct(classid = OPP_EMAdatpln_class_id,
                       msg = message EMSassoc.EMinit_associative(EMmsg,
                             NULL, 2, list, type,
                             sizeof (struct EMSdatpln_planar_element_info),
                             (char *)&info,
                             construct_list),
                       p_objid = cons_obj,
                       osnum = constros);
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

