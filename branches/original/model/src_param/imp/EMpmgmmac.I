/* ###################   APOGEE COMPILED   ################## */
class implementation EMSparamgm;

#include "nddef.h"
#include "EMSas.h" /* For EMSasptinfo */
#include "ndmacros.h"
#include "EMcp.h"
#include "godef.h"
#include "parametric.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

from EMScnstr import EMinit;
from EMSasptcnstr import EMalt_init;
from EMSsurface import EMgetactiveid;

method NDcopy_graph(IGRlong *EMmsg;
                    IGRint cp_type;
 		    struct GRmd_env *fr_env,*to_env;
		    struct NDcp_list *nd_cp_list; 
                    int list_size;
		    int position)
/* ****************************************************************
Description
 This override will cause the copy of this entity to occur.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : Failure in copy.

History
 pp : 08/07/91 : Creation
 **************************************************************** */
 
{
 IGRlong status,msg_loc;
 OMuword my_classid, clone_classid, constr_os;
 OM_S_OBJID  cnstr_objid;
 struct GRid new_GRid, existing_clone;
 extern OMuword OPP_EMSparampt_class_id, OPP_EMSparamvc_class_id;
 extern OMuword OPP_EMSparvcnstr_class_id,
                OPP_EMSasptcnstr_class_id,
                OPP_EMSparampt_class_id;

 status = OM_S_SUCCESS;
 *EMmsg = MSSUCC;

 new_GRid.objid = NULL_OBJID;

 existing_clone.objid = nd_cp_list[position].clone;
 existing_clone.osnum = to_env->md_id.osnum;
 constr_os = to_env->md_id.osnum;

 if (existing_clone.objid != NULL_OBJID)
 {
  status = om$get_classid (objid = existing_clone.objid,
                           osnum = to_env->md_id.osnum,
                           p_classid = &clone_classid);
  EMerr_hndlr(!(1&status), *EMmsg, MSFAIL, wrapup);

  status = om$get_classid (objid = my_id,
                           osnum = OM_Gw_current_OS,
                           p_classid = &my_classid);
  EMerr_hndlr(!(1&status), *EMmsg, MSFAIL, wrapup);

  if (clone_classid != my_classid)
  {
   status = om$send (msg = message NDnode.NDcopy(&msg_loc,cp_type,
                         fr_env, to_env, &new_GRid),
                  targetid = my_id);
   EMerr_hndlr(!(1&status&msg_loc), *EMmsg, MSFAIL, wrapup);
   nd_cp_list[position].clone = new_GRid.objid;

   if (EFisAncestryValid(&msg_loc,my_id,OM_Gw_current_OS,
                         OPP_EMSparampt_class_id, FALSE))
   {
    struct EMSasptinfo ptinfo;
    struct ret_struct info_struct;

    ptinfo.type = GRst_KEYPOINT;
    ptinfo.win_pln.objid = NULL_OBJID;
    OM_BLOCK_MOVE(info_struct.var.point_st.pt,ptinfo.pts[0],sizeof(IGRpoint));

    status = om$send (msg = message NDnode.NDgive_structure(&msg_loc,
                            &info_struct, to_env),
                      targetid = existing_clone.objid,
                      targetos = existing_clone.osnum);
    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, MSFAIL, wrapup);

    status = om$construct(classid = OPP_EMSasptcnstr_class_id,
                          msg = message EMSasptcnstr.EMalt_init(&msg_loc,
                                NULL,to_env,
                                1, &existing_clone, NULL,
                                (char *) &ptinfo,1,
                                &new_GRid),
                          osnum = constr_os,
                          p_objid = &cnstr_objid);
    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, MSFAIL, wrapup);
   }
   else if (EFisAncestryValid(&msg_loc, my_id, OM_Gw_current_OS,
            OPP_EMSparamvc_class_id, FALSE))
   {
    status = om$construct (classid = OPP_EMSparvcnstr_class_id,
                           msg = message EMScnstr.EMinit(&msg_loc,
                                 NULL,to_env,1, &existing_clone,
                                 NULL,NULL,1, &new_GRid),
                           osnum = constr_os,
                           p_objid = &cnstr_objid);
    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, MSFAIL, wrapup);
   }
   else
   {
     *EMmsg = MSINARG;
     goto  wrapup;
   }
  }
 }
 else
 {
  status = om$send (msg = message NDnode.NDcopy(&msg_loc,cp_type,
                         fr_env, to_env, &new_GRid),
                  targetid = my_id);
  EMerr_hndlr(!(1&status&msg_loc), *EMmsg, MSFAIL, wrapup);
  nd_cp_list[position].clone = new_GRid.objid;
 }

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSparamgm:NDcopy_graph method error");
 return (status);
}


method ACbecome_macro(IGRlong *msg; 
                      IGRint position;
		      struct GRmd_env *md_env)

/* ***************************************************************************
Description 
 If the position of this element is the root of the graph, return
 invalid for now. Otherwise return that the same is valid for
 drop macro.

Notes
 Upon exit the completion code will be one of the following:
  ND_DROP_MAC : If the manager is not a root or an external element
  ND_INVAL_MAC : Otherwise

History
 pp : 08/08/91 : Creation
*************************************************************************** */

{
  *msg = ND_DROP_MAC | ND_CONS_MAC;

  return (OM_S_SUCCESS);
}

method NDselect_copy(long *msg;
                     int select_type;
		     struct GRid *selected_obj;
                     int *info;
		     int selected_size, 
                     *selected_nb)
/* ********************************************************************
Description
 This method adds all of the handles of the parent constraints onto the 
 list that is going to get copied.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is failure

History
 pp : 07/29/91 : Creation
*********************************************************************** */
{
 IGRlong status,msg_loc;
 IGRint i,ret_count, comp_count;
 OM_S_CHANSELECT to_components;
 struct GRid temp_GRid;
 struct GRid *grid_ptr = NULL;
 extern OMuword OPP_EMSsurface_class_id;

 *msg = MSSUCC;
 status = OM_S_SUCCESS;
 *selected_nb = 0;

 if (selected_size > (*selected_nb))
 {
   selected_obj[0].objid = my_id;
   selected_obj[0].osnum = OM_Gw_current_OS;
 }
 ++(*selected_nb);
 
 status = om$send (msg = message NDnode.NDget_objects(ND_ROOT | ND_IN_BUF,
                         NULL,0,&grid_ptr,0,MAXINT, &ret_count),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *msg, MSFAIL, wrapup);

 EMmake_chanselect(GRcmpowner_to_components, &to_components);
 
 for (i=0;i<ret_count;i++)
 {
  status = om$get_channel_count(p_chanselect = &to_components,
                                objid = grid_ptr[i].objid,
                                count = (OMuint *)&comp_count,
                                osnum = grid_ptr[i].osnum);
  EMerr_hndlr(!(1&status), *msg, MSFAIL, wrapup);
                               
  if (comp_count)
  {
   status = om$get_objid_at_index(objid = grid_ptr[i].objid,
                                  osnum = grid_ptr[i].osnum,
                                  p_chanselect = &to_components,
                                  index = 0,
                                  objidaddr = &temp_GRid.objid,
                                  osnumaddr = &temp_GRid.osnum);
   EMerr_hndlr(!(1&status), *msg, MSFAIL, wrapup);

   if (selected_size > (*selected_nb))
   {
       selected_obj[*selected_nb] = temp_GRid;
       info[*selected_nb] = 0;
   }
   ++(*selected_nb);
  }
 }

 status = om$send (msg = message NDnode.NDget_objects(ND_CHILDREN | ND_IN_BUF,
                         NULL,0,&grid_ptr,0,MAXINT, &ret_count),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *msg, MSFAIL, wrapup);

 for (i=0;i<ret_count;i++)
 {
/*
 * If I am driving a surface/solid, I should add him (activeid) since he
 * is my virtual owner. (Boy the games we play).
 */
  if (EFisAncestryValid(&msg_loc,grid_ptr[i].objid,
                             grid_ptr[i].osnum,OPP_EMSsurface_class_id,FALSE))
  {
   struct GRid activeid;

   status = om$send (msg = message EMSsurface.EMgetactiveid (&msg_loc,
                         &activeid, NULL),
                   targetid = grid_ptr[i].objid,
                   targetos = grid_ptr[i].osnum);
   EMerr_hndlr (!(1&status&msg_loc), *msg, MSFAIL, wrapup);

   if (selected_size > (*selected_nb))
    selected_obj[*selected_nb] = activeid;

   ++(*selected_nb);
  }
 }

wrapup:
 EMWRAPUP (*msg, status, "In EMSparamgm: NDselect_copy method error");
 return (status);
}

method NDgive_structure (IGRlong *msg; struct ret_struct *str;
                         struct GRmd_env *md_env )
{
 str->type = other_generic ;
 *msg = MSSUCC;
 return (OM_S_SUCCESS);
}

method ACcopy_to_Groot(IGRlong *msg;IGRint cp_type;
			 struct GRmd_env *fr_env,*to_env;
  			 struct GRid *newobjid)
/*
 * This implementation creates a point object or a line object for the macro.
 * This entity is only used when displaying the root, while placing the
 * macro.
 * 
 * History
 * pp : 08/10/91 : Creation
 */
{
 IGRlong status;
 IGRint bytes_in, bytes_out,number_of_points;
 IGRlong msg_loc;
 IGRpoint pts[2];
 struct ret_struct info_struct;
 struct IGRdisplay display_stuff;
 struct GRvg_construct construct_list;
 
 *msg = MSSUCC;
 status = OM_S_SUCCESS;

 newobjid->objid = NULL_OBJID;
 newobjid->osnum = to_env->md_id.osnum;
/*
 * Creating a 3d point or a 3d line as the case may be. This serves
 * the purpose of a default template and also is used for displaying
 * templates while placing the macro.
 */

 if (cp_type & ND_TO_DEF_TEMP)
 {
  status = om$send (msg = message NDnode.NDgive_structure(&msg_loc,&info_struct,
                         fr_env),
                   targetid = my_id);
  if (!(1&status&msg_loc)) goto wrapup;

  if (info_struct.type & point_generic)
  {
   number_of_points = 1;
   OM_BLOCK_MOVE(info_struct.var.point_st.pt, pts[0], sizeof (IGRpoint));
  }
  else if (info_struct.type & line_generic)
  {
   number_of_points = 2;
   OM_BLOCK_MOVE(info_struct.var.line_st.p0, pts[0], sizeof (IGRpoint));
   OM_BLOCK_MOVE(info_struct.var.line_st.p1, pts[1], sizeof (IGRpoint));
  }
  else
  {
   *msg = MSINARG;
   goto wrapup;
  }
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
 EMWRAPUP (*msg, status, "In EMSparamgm: ACcopy_to_Groot error");
 return (OM_S_SUCCESS);
}
end implementation EMSparamgm;

