class implementation EMSagrp;

from EMSsubbs import EMisoparcvs;

IGRlong EFiso_parametric_curves(EMmsg, options, trimming_required,
        use_u_curve, surf_info, num_param, start_param, end_param,
        construct_list, res_id)
IGRlong *EMmsg;
unsigned int options;
IGRboolean trimming_required;
IGRboolean use_u_curve;
struct GRlc_info *surf_info;
IGRint num_param;
IGRdouble start_param;
IGRdouble end_param;
struct GRvg_construct *construct_list;
OM_S_OBJID *res_id;
{
 OMuword constros;
 IGRlong status;

 *EMmsg = EMS_S_Success;
 *res_id = NULL_OBJID;
 constros = construct_list->env_info->md_id.osnum;

 if (options & EMSasconst_notassociative)
 {
  IGRint             i,j;
  IGRlong            number_of_objects;
  GRobjid            *objects;
  IGRdouble          incval;
  IGRdouble          *parms;
  struct GRid *id;
  struct GRmdenv_info *mdenv_info;

  id = &surf_info->located_obj;
  mdenv_info = &surf_info->module_info.md_env;

  parms = (IGRdouble *) malloc(num_param * sizeof(IGRdouble));
  if (!parms)
  {
   *EMmsg = MANOMEMORY;
   goto wrapup;
  }

  j = num_param - 1;
  parms[j] = end_param;
  parms[0] = start_param;
  incval = (end_param - start_param) / j;

  for (i = 1; i < j; i++)
    parms[i] = parms[i-1] + incval;

  status = om$send(
       msg = message EMSsubbs.EMisoparcvs(
        EMmsg,
        &mdenv_info->matrix_type,
        mdenv_info->matrix,
        construct_list,
        trimming_required,
        num_param,
        parms,
        use_u_curve,
        &number_of_objects,
        &objects),
       senderid = NULL_OBJID,
       targetid = id->objid,
       targetos = id->osnum);
   if (! (1 & status)) goto wrapup;

   if (number_of_objects && objects)
   {
     if (number_of_objects == 1)
       *res_id = objects[0];
     else
     {
       status = EFbuild_graphic_group(
          number_of_objects,
          objects,
          NULL,
          construct_list,
          res_id,
          EMmsg);
     }
      free(objects);
      free(parms);
    }
 }
 else
 {
  struct EMSobject_info list;
  struct EMSisoparametric_curves info;

  info.props = 0;

  if (trimming_required)
   info.props = EMS_TRIMMING_REQUIRED;

  if (use_u_curve)
   info.props |= EMS_USE_U_DIRECTION;

  info.num_parms = num_param;
  info.start_param = start_param;
  info.end_param = end_param;

  list.grid = surf_info->located_obj;
  list.env = surf_info->module_info;

  status = om$construct(classid = OPP_EMSagrp_class_id,
                       p_objid = res_id,
                       msg = message EMSassoc.EMinit_associative(EMmsg,
                             NULL, 1, &list, EMS_ASiso_parametric_curves,
                             sizeof (struct EMSisoparametric_curves),
                             (char *)&info,
                             construct_list),
                       osnum = constros);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

wrapup:
 if (!(1&status&*EMmsg) && (*res_id != NULL_OBJID))
 {
  om$send (msg = message Root.delete(1),
            senderid = NULL_OBJID,
            targetid = *res_id,
            targetos = constros);
 }
 EMWRAPUP (*EMmsg, status, "In EMiso_parametric_curves error");
 return (status);

}
end implementation EMSagrp;

