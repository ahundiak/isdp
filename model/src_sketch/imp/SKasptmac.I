class implementation SKasptgrnd;

#include "nddef.h"
#include "OMmacros.h"
#include "godef.h"
#include "parametric.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

from SKvariable import SKgetvar;

method NDcopy_graph(IGRlong *msg;IGRint cp_type;
 		 struct GRmd_env *fr_env,*to_env;
		 struct NDcp_list *copied_element; int copied_size;
		 int my_index)
{
 *msg = MSSUCC;
 return (OM_S_SUCCESS);
}


method ACcopy_to_Groot(IGRlong *msg;IGRint cp_type;
			 struct GRmd_env *fr_env,*to_env;
  			 struct GRid *newobjid)
/*
 * This implementation just returns success.
 * 
 * History
 * pp : 08/10/91 : Creation
 */
{
 struct ret_struct str;
 IGRpoint pts[2];
 struct IGRdisplay display_stuff;
 struct GRvg_construct construct_list;
 IGRint bytes_in, bytes_out,number_of_points;
 IGRlong status,msg_loc;

 *msg = MSSUCC;
 status = OM_S_SUCCESS;

 newobjid->objid = NULL_OBJID;
 newobjid->osnum = to_env->md_id.osnum;

 status = om$send (msg = message NDnode.NDgive_structure(msg, &str,
                         fr_env),
                   targetid = my_id);
 EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);
          
 if (str.type & point_generic)
 {
  number_of_points = 1;
  OM_BLOCK_MOVE(str.var.point_st.pt, pts[0], sizeof (IGRpoint));

  construct_list.display = &display_stuff;
  construct_list.msg = &msg_loc;
  construct_list.env_info = to_env;
  construct_list.newflag = FALSE;
  construct_list.geometry = NULL;
  construct_list.class_attr = NULL;
  construct_list.name = NULL;
  construct_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  bytes_in = sizeof(construct_list.level);
  gr$get_active_level(
    msg = &msg_loc,
    sizbuf = &bytes_in,
    buffer = &construct_list.level,
    nret = &bytes_out);
  if (!(1&msg_loc)) goto wrapup;

  bytes_in = sizeof(struct IGRdisplay);
  gr$get_active_display(
   msg = &msg_loc,
   sizbuf = &bytes_in,
   buffer = construct_list.display,
   nret = &bytes_out);
  if (!(1&msg_loc)) goto wrapup;

  status = EFplace_line_string(my_id, &construct_list, number_of_points,
           pts,&newobjid->objid,&msg_loc);
  if (!(1&status&msg_loc)) goto wrapup;
 }

 wrapup:
  if (!(1&status&msg_loc))
  {
   newobjid->objid = NULL_OBJID;
  }
  return (status);
}

method NDcopy(IGRlong *msg;IGRint cp_type;
 		 struct GRmd_env *fr_env,*to_env;struct GRid *newobjid)
{
/*
 * Return success since my copy is handled by the manager.
 * pp 08/16/91
 */

 *msg = MSSUCC;
 newobjid->objid = NULL_OBJID;
 newobjid->osnum = to_env->md_id.osnum;
 return (OM_S_SUCCESS);
}

method NDcopy_to_root(IGRlong *msg;IGRint cp_type;
		      struct GRmd_env *md_env,*to_env;
  		      struct GRid *newobjid)
{
/*
 * Return success since my copy is handled by the manager.
 * pp 08/16/91
 */
 *msg = MSSUCC;
 newobjid->objid = NULL_OBJID;
 newobjid->osnum = to_env->md_id.osnum;
 return (OM_S_SUCCESS);
}

method NDcompute_node ( IGRlong *msg; IGRint cn_type;
	                IGRint count; struct GRid list []; 
                        struct GRmd_env *md_env)
{
 IGRlong status;
 IGRint  msg_loc;
 struct GRid new_GRid;

 status = OM_S_SUCCESS;
 *msg = MSSUCC;
 msg_loc = MSSUCC;

 status = om$send (msg = message NDnode.NDupdate(&msg_loc, cn_type,
                         count, list, NULL, NULL, &new_GRid,
                         md_env),
                   targetid = my_id);
 EMerr_hndlr(!(1&status&msg_loc), *msg, MSFAIL, wrapup);

wrapup:
 EMWRAPUP (*msg, status, "In SKasptgrnd: NDcompute_node error");
 return (status);
}

method NDgive_structure (IGRlong *msg; struct ret_struct *str;
                            struct GRmd_env *md_env)
/*
 * This routine returns the structure of this constraint as point_generic
 * and gets the point definition by transforming the xy value of the
 * point variable into the global coordinate system.
 *
 * History
 * pp : 11/13/91 : Creation
 */
{
 IGRlong status;
 IGRuint count;
 IGRlong msg_loc;
 OM_S_CHANSELECT chan_to_cnstrvars;
 OM_S_OBJECT_LINKAGE objlist;
 OM_S_OBJID ptid;

 *msg = MSSUCC;
 status = OM_S_SUCCESS;

 str->type = point_generic;

 EMmake_chanselect (SKconstraint_to_variables, &chan_to_cnstrvars);
 count = 0;
 om$get_channel_objects (object = me, 
                         p_chanselect = &chan_to_cnstrvars,
                         count = &count, size = 1, list = &objlist);
 EMerr_hndlr (count != 1, *msg, EMS_E_InvalidCase, wrapup);
 ptid = objlist.S_objid;

/*
 * Get the world coordinate of my point. 
 */
 status = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
                         NULL, &md_env->md_env.matrix_type,
                         md_env->md_env.matrix, str->var.point_st.pt), 
                   targetid = ptid);
 EMerr_hndlr(!(1&status&msg_loc), *msg, EMS_E_Fail, wrapup);

wrapup:
 return (status);
}
end implementation SKasptgrnd;

