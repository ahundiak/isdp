class implementation EMSassoc;

#include "EMSopt.h"
#include "REgenbs.h"

IGRlong EFcreate_surface_by_3_4_boundaries(EMmsg, options, 
                                cv1,cv2, cv3, cv4,
                                construct_list, res_id)
IGRlong *EMmsg;
unsigned int options;
struct GRlc_info *cv1;
struct GRlc_info *cv2;
struct GRlc_info *cv3;
struct GRlc_info *cv4;
struct GRvg_construct *construct_list;
OM_S_OBJID *res_id;
{
 IGRint num_parents;
 IGRlong status;
 struct EMSobject_info list[4];
 extern OMuword OPP_EMAgenbs_class_id;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 *res_id = NULL_OBJID;

 num_parents = 3;

 list[0].grid = cv1->located_obj;
 list[0].env = cv1->module_info;
 list[1].grid = cv2->located_obj;
 list[1].env = cv2->module_info;
 list[2].grid = cv3->located_obj;
 list[2].env = cv3->module_info;

 if (cv4)
 {
  list[3].grid = cv4->located_obj;
  list[3].env = cv4->module_info;
  ++num_parents;
 }

 status = om$construct (classid = OPP_EMAgenbs_class_id,
                        p_objid = res_id,
                        osnum = construct_list->env_info->md_id.osnum,
                        msg = message EMSassoc.EMinit_associative(EMmsg,
                        NULL, num_parents, list, EMS_ASsurface_by_bound,0,
                        NULL,construct_list));
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

wrapup:
 return (status);
}
end implementation EMSassoc;

