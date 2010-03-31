/*
  DESCRIPTION
    Changes a wireframe composite curve and its elements into the corresponding
    profile elements.  It also moves any dependents over.
    
  HISTORY
    ???? : ??? : Creation
    Rajiv : 11/19/92 : Major cleanup.  
  
  BUGS  
    An extra ASsource object gets created if the composite curve did not have one.
    Thats the flaw of as$make_source macro.

*/

class implementation SKcompcurve;

#include "nddef.h"
#include "ndmacros.h"
#include "asmacros.h"
#include "asbox.h"

extern OMuword OPP_GR3dlineseg_class_id, OPP_GR3dcirarc_class_id,
               OPP_GR3dpoint_class_id, OPP_GR3dcircle_class_id;

#define BUFF_SIZE 10

EFchange_to_sketch(EMmsg, comp_curve, md_env, sketch_curve)
IGRlong *EMmsg;
struct GRid *comp_curve;
struct GRmd_env *md_env;
struct GRid *sketch_curve;
{
 IGRlong 	  status;
 IGRint 	  count, nret,i;
 GRclassid 	  class_id, comp_cv_classid;
 struct GRid 	  comps_buff[BUFF_SIZE];
 struct GRid 	  *comps_ptr, geom_src;
 OM_S_CHANSELECT  to_children;
 char             skclass_name[OM_K_MAXCLASS_LEN];

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 comps_ptr = NULL;
 sketch_curve->objid = NULL_OBJID;

 count = 0;

 status = om$get_classid (objid = comp_curve->objid,
             osnum = comp_curve->osnum,
             p_classid = &comp_cv_classid);
 EMerr_hndlr (!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 if (EFisAncestryValid(EMmsg, comp_curve->objid, comp_curve->osnum, 
                          OPP_GRcompcurve_class_id, FALSE))
 {
  status = om$send (msg = message GRowner.GRget_number_components(EMmsg,
                         &count),
                   senderid = NULL_OBJID,
                   targetid = comp_curve->objid,
                   targetos = comp_curve->osnum);
  EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  if (count > BUFF_SIZE)
  {
   comps_ptr = (struct GRid *) om$malloc (size = sizeof (struct GRid) * 
                                                         count);
   EMerr_hndlr(!comps_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
  }
  else
   comps_ptr = comps_buff;
  
  nret = 0;
  status = om$send (msg = message GRowner.GRget_components(EMmsg, md_env,
                         comps_ptr, count, &nret,0, MAXINT),
                   senderid = NULL_OBJID,
                   targetid = comp_curve->objid,
                   targetos = comp_curve->osnum);
  EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 } /* if (comp_cv_classid == OPP_GRcompcurve_class_id) */
 else
 {
  count = 1;
  comps_ptr = comps_buff;
  comps_ptr[0] = *comp_curve;
 }

 for (i=0;i<count;i++)
 {
   status = om$get_classid (osnum = comps_ptr[i].osnum,
       objid = comps_ptr[i].objid,
       p_classid = &class_id);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 
   status = SKgetskclass (class_id, NULL, skclass_name);
   EMerr_hndlr (!status, *EMmsg, EMS_E_InvalidArg, wrapup);
 
   status = om$change_class (osnum = comps_ptr[i].osnum,
                             objid = comps_ptr[i].objid,
                             classname = skclass_name);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
  
   status = as$make_source (go_grid = comps_ptr[i],
                            as_os = comps_ptr[i].osnum,
                            as_grid = &geom_src);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_ASerror, wrapup);
 
   status = om$make_chanselect (channame = "NDchildren.children",
       p_chanselect = &to_children);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 
   status = om$send (msg = message Root.move_chan(to_children, geom_src.objid,
       geom_src.osnum, to_children),
       senderid = geom_src.objid,
       targetid = comps_ptr[i].objid,
       targetos = comps_ptr[i].osnum);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
#if 0   
   status = om$send ( msg = message Root.delete(TRUE),
                      targetid = geom_src.objid,
                      targetos = geom_src.osnum,
                      senderid = NULL_OBJID);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
#endif
 }

 if (EFisAncestryValid(EMmsg, comp_curve->objid, comp_curve->osnum, 
                          OPP_GRcompcurve_class_id, FALSE))
 {
   status = as$make_source (go_grid = *comp_curve,
                           as_os = comp_curve->osnum,
                           as_grid = &geom_src);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_ASerror, wrapup);

   status = om$change_class(osnum = comp_curve->osnum,
                           objid = comp_curve->objid,
                           classname = "SKcompcurve");
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

   status = om$make_chanselect (channame = "NDchildren.children",
                               p_chanselect = &to_children);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

   status = om$send (msg = message Root.move_chan(to_children, geom_src.objid,
                    geom_src.osnum, to_children),
                  senderid = geom_src.objid,
                  targetid = comp_curve->objid,
                  targetos = comp_curve->osnum);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
#if 0
   status = om$send ( msg = message Root.delete(TRUE),
                      targetid = geom_src.objid,
                      targetos = geom_src.osnum,
                      senderid = NULL_OBJID);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
#endif
 }
 else 
  *comp_curve = comps_ptr[0];

 *sketch_curve = *comp_curve;

wrapup:
 if (comps_ptr && (comps_ptr != comps_buff))
  om$dealloc(ptr = comps_ptr);

 EMWRAPUP (*EMmsg, status, "In EFchange_to_sketch_error");
 return (status);
}

end implementation SKcompcurve;
