class implementation GAcompcurve;

#include "EMSkey.h"
#include "nddef.h"

method ACcopy_to_Groot(IGRlong *msg;IGRint cp_type;
			 struct GRmd_env *fr_env,*to_env;
  			 struct GRid *newobjid)
/* **********************************************************************
Description
 This method has been overriden to return the non-associative copy
 of the composite curve. This message is sent for copying the result for the
 purpose of showing the same to the user/ for placing symbol/construction
 macros.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MDFAIL : If there is some form of failure

History
 Creation : PP : 06/25/92
*********************************************************************** */
{
 IGRlong status, msg_loc;
 OM_S_OBJID temp_objid;

 status = OM_S_SUCCESS;
 *msg = MSSUCC;

 status = om$send (msg = message GRgraphics.GRcopy(&msg_loc,fr_env, to_env,
                         &temp_objid),
                   targetid = my_id);
 EMerr_hndlr(!(1&status&msg_loc), *msg, MSFAIL, wrapup);

 if (temp_objid != NULL_OBJID)
 {
   extern OMuword OPP_GRcompcurve_class_id;
   OMuword comp_classid;

   status = om$get_classid (objid = temp_objid,
                           osnum = to_env->md_id.osnum,
                           p_classid = &comp_classid);
   EMerr_hndlr(!(1&status), *msg, MSFAIL, wrapup);

 
   if ((comp_classid == OPP_GRcompcurve_class_id) ||
       (comp_classid == OPP_GAcompcurve_class_id))
   {
    om$change_class(osnum = to_env->md_id.osnum,
                   objid =  temp_objid,
                   classname = "AScompcurve");

    status = om$send (msg = message NDnode.NDchg_state(~0,ND_DEGRADED),
             targetid = temp_objid,
             targetos =  to_env->md_id.osnum);
   }

   newobjid->objid = temp_objid;
   newobjid->osnum = to_env->md_id.osnum;
  }


wrapup:
 EMWRAPUP (*msg, status, "In SKmgr:copy to groot error");
 return (status);
 
}
end implementation GAcompcurve;
