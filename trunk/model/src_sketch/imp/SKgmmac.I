class implementation SKgeometry;

#include "nddef.h"
#include "asbox.h"    /* For NULL_GRID */
#include "asmacros.h"

method ACbecome_macro(IGRlong *msg; 
                      IGRint position;
		      struct GRmd_env *md_env)

/* ***************************************************************************
Description 
 This object returns the type of macros that can be constructed with this
 object. 
*************************************************************************** */
{
 *msg = ND_DROP_MAC | ND_CONS_MAC;
 return (OM_S_SUCCESS);
}

method NDcopy_graph(IGRlong *msg;IGRint cp_type;
 		 struct GRmd_env *fr_env,*to_env;
		 struct NDcp_list *list; int copied_size;
		 int my_index)
/* ************************************************************************
Description
 This object will return success since the copy of the constraint is handled
 by the manager.

History
 pp : 07/24/91 : Creation
 *********************************************************************** */
{
 IGRlong status;
 struct NDcp_list *myinx;
 
 *msg = MSSUCC;
 status = OM_S_SUCCESS;

 myinx = &list[my_index];

 if ((myinx->position & ND_BODY) || (myinx->position & ND_ROOT))
  return (OM_S_SUCCESS);
 else if (myinx->position & ND_EXTERN)
 {
  struct GRid temp_GRid, src_GRid;
  /*
   * Return a source object. Since copy graph machinery will try to
   * connect to the same.
   * Prasad 01/08/92
   */
   
  status = om$send (msg = message GRgraphics.GRcopy(msg,fr_env,to_env,
                         &temp_GRid.objid),
                    targetid = my_id);
  if (!(1&status&*msg)) goto wrapup;

  temp_GRid.osnum = to_env->md_id.osnum;

  status  = as$make_source(go_grid = temp_GRid,
                           as_grid = &src_GRid);
  if (!(1&status)) goto wrapup;

  myinx->clone = src_GRid.objid;
 }
 else
  myinx->clone = NULL_OBJID;

wrapup:
 EMWRAPUP (*msg, status, "In SKgeometry:NDcopy graph error");
 return (status);
}

method ACcopy_to_Groot(IGRlong *msg;IGRint cp_type;
		 struct GRmd_env *fr_env,*to_env;
  		 struct GRid *newobjid)
/*
 * This implementation copies this entity for the purpose of displaying
 * roots.
 * 
 * History
 * pp : 08/10/91 : Creation
 */
{
 IGRlong status;
 
 status = OM_S_SUCCESS;
 *msg = MSSUCC;

 newobjid->objid = NULL_OBJID;
 newobjid->osnum = to_env->md_id.osnum;
/*
 * We copy this entity non-associatively only when it has been specified
 * that this is being done for displaying the template while placing a 
 * macro. 
 * pp 08/25/91
 */

 if (cp_type & ND_TO_DEF_TEMP)
 {
  status = om$send (msg = message GRgraphics.GRcopy(msg, fr_env,
                         to_env, &newobjid->objid),
                   targetid = my_id);
  EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);
 }

wrapup:
 return (status);
}

method NDcopy_to_root(IGRlong *msg;IGRint cp_type;
	              struct GRmd_env *md_env,*new_info;
  		      struct GRid *newobjid)
/*
 * Just copy myself non-associatively.
 * pp 08/16/91
 */
{
 *msg = MSSUCC;
  newobjid->osnum = new_info->md_id.osnum;
  return(om$send (msg = message GRgraphics.GRcopy(msg,md_env, new_info,
                        &newobjid->objid),
                    targetid = my_id));
}
method NDcopy(IGRlong *msg;IGRint cp_type;
 		 struct GRmd_env *fr_env,*to_env;struct GRid *newobjid)
{
/*
 * Return success since my copy is handled by the manager.
 * Actually this message should not hit me.
 * pp 08/16/91
 */

 *msg = MSSUCC;
 newobjid->objid = NULL_OBJID;
 newobjid->osnum = to_env->md_id.osnum;
 return (OM_S_SUCCESS);
}
end implementation SKgeometry;

