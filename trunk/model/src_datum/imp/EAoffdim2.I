class implementation EMSdimoff1;

/*
  HISTORY

        dfl   09/94 - method NDparent_deleted to delete myself
                      and inform my children.
*/

#include <alloca.h>
#include "nddef.h"
#include "REdatpln.h"
#include "dimangular.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdistptpt.h"
#include "bscrossp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#define  EMSPARAMVL "EMSparamvl"
#define  ASSOURCE "ASsource"

from EMSparamvl import EMparam_delete;

extern OMuword OPP_DMlinear_class_id;


method NDparent_deleted(IGRlong *msg; 
                         IGRint  count_deleted;
                         struct GRid list_deleted[];
                         struct GRid *new_obj;
                         struct GRmd_env *md_env)
{
 IGRlong stat_OM, msg_loc, status;
 OM_S_OBJID childid;
 OMuword childos;
 OMuword class_id;
 OM_S_CHANSELECT to_children;
 struct GRid owner_GRid;
 /* OMuint owner_count=0, comp_count = 0; */
 OM_S_CHANSELECT to_owners;


 *msg = MSSUCC; 



 /* get the EMsglpara object; only one child can exist */
 EMmake_chanselect(NDchildren_children, &to_children);
 status = om$get_objid_at_index(objid = my_id,
                                     p_chanselect = &to_children,
                                     objidaddr = &childid,
                                     osnumaddr = &childos,
                                     index = 0);
 EMerr_hndlr (!(1&status), *msg, EMS_E_Fail, function_end);

 /* to make it sure look for the correct class id */
 status = om$get_classid(
                     objid = childid,
                     osnum = childos,
                     p_classid = &class_id);
 EMerr_hndlr (!(1&status), *msg, EMS_E_Fail, function_end);
 
 status = om$is_ancestry_valid(subclassid = class_id, 
                     superclassid = OPP_DMlinear_class_id); 
 EMerr_hndlr (!(1&status), *msg, EMS_E_Fail, function_end);

 /* the EMsglpara object has a EMparamvl object as owner; 
    this object contains the offset value  */
 EMmake_chanselect (GRconnector_to_owners, &to_owners);

 status = om$get_objid_at_index(objid = childid,
                           p_chanselect = &to_owners,
                           objidaddr = &owner_GRid.objid,
                           osnumaddr = &owner_GRid.osnum,
                           index = 0);
 EMerr_hndlr (!(1&status), *msg, EMS_E_Fail, function_end);

 /* delete the EMparamvl object */
 stat_OM = om$send (msg = message EMSparamvl.EMparam_delete(&msg_loc,
                          md_env),
                    targetid = owner_GRid.objid,
                    targetos = owner_GRid.osnum);
 EMerr_hndlr (!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, function_end);

 /* delete myself and hopefully all dependents have proper deletes */
 stat_OM = om$send (msg = message Root.delete(1),
                  targetid = my_id);
 EMerr_hndlr (!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, function_end);

 stat_OM = om$send (msg = message Root.delete(1),
                  targetid = owner_GRid.objid,
                  targetos = owner_GRid.osnum);



function_end:
 return(stat_OM);

}



end implementation EMSdimoff1;
