class implementation SKmgr;

#include "nddef.h"
#include "ndmacros.h"
#include "EMcp.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "SKdef.h"

extern OMuword OPP_ASsourcein_class_id, OPP_expression_class_id;
extern OMuword OPP_DMroot_class_id;
extern OMuword OPP_GAcurve_class_id, OPP_EMSpointer_class_id;
extern OMuword OPP_EMScnstr_class_id;
extern OMuword OPP_EMSsurface_class_id;

from SKexplicit import SKputval;
from SKvariable import SKputvar;

#define OLD_SELECT_COPY 0

from SKexplicit import SKstoreval;

method NDcopy_graph(IGRlong *EMmsg;
                    IGRint cp_type;
 		    struct GRmd_env *fr_env,*to_env;
		    struct NDcp_list *nd_cp_list; 
                    int list_size;
		    int myinx)
/* ****************************************************************
Description
 This override will cause the copy of the entire variational profile
 to occur and it only makes sense in the context of graph copy.
 This includes the copy of the manager, the constraint objects,
 the graphic handles for geometric constraints if they exist
 and the connection of the same with respect to each other on all
 private channels. However this does not include the copy of the
 dimensional handles and this is assumed to be done by the overrides
 of NDcopy_graph by dimensions. The connection to dimensional handles
 is made using NDconnect_graph method.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSINARG : If the manager was not a body element
 MSFAIL : Failure in copy.

History
 pp : 07/24/91 : Creation
 **************************************************************** */
 
{
 OM_S_OBJID newobjid;
 IGRlong status;
 struct EMcp_info copy_info;
 extern IGRboolean ASbroadcast_in_progress;

 status = OM_S_SUCCESS;
 *EMmsg = MSSUCC;

 copy_info.num_entries = 0;
 copy_info.array_size = 0;
 copy_info.objid_array = NULL;
 copy_info.graph_info.graph_count = list_size;
 copy_info.graph_info.graph_array = nd_cp_list;

 if (!ASbroadcast_in_progress) return (OM_S_SUCCESS);
 

 if (nd_cp_list[myinx].position & ND_BODY)
 {
  IGRlong msg_loc;

  status = om$send (msg = message SKmgr.SKintcopy(EMmsg,
                          SK_OPT_COPY_ASSOCIATIVE, fr_env, to_env,
                          &newobjid, &copy_info),
                    targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);
  nd_cp_list[myinx].clone = newobjid;
/*
 * Set the properties of the copied manager to be out of date to be
 * safe. This is the best place I could think of sending this message
 * and causing the least amount of trouble. A compute usually
 * follows a copy. The below "may" cause problems when the above 
 * assumption is not true.
 * pp 12/2/91
 */
    om$send (msg = message SKmgr.SKmgrprops(&msg_loc,SK_CHGPROPS_ON,
                   SK_MGR_OUTOFDATE | SK_MGR_PLN_OUTOFDATE,NULL),
             targetid = newobjid,
             targetos = to_env->md_id.osnum);
/* end pp */
 }
 else
  *EMmsg = MSINARG;

wrapup:
 if (copy_info.objid_array) om$dealloc (ptr = copy_info.objid_array);
 EMWRAPUP (*EMmsg, status, "In SKmgr:NDcopy method error");
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
 IGRlong status;
 *msg = MSSUCC;
 status = OM_S_SUCCESS;

 return (om$send (msg = message NDnodein.ACcopy_to_Groot(msg,NULL,
                         md_env, new_info, newobjid),
                   targetid = my_id));
}

method ACbecome_macro(IGRlong *msg; 
                      IGRint position;
		      struct GRmd_env *md_env)

/* ***************************************************************************
Description 
 This object returns the type of macros that can be constructed with this
 object. 

Notes
 Upon exit the completion code will be one of the following:
  ND_DROP_MAC : If the manager is not a root or an external element
  ND_INVAL_MAC : Otherwise

History
 pp : 07/25/91 : Creation
*************************************************************************** */

{
/*
 * The macro can only be valid if the manager is being driven by something.
 * It being a template (root of the macro) or an external element does
 * not make sense. Hence declare the macro creation as invalid if this
 * occurs.
 * pp 07/25/91
 */
 if (position & ND_BODY)
  *msg = ND_DROP_MAC | ND_CONS_MAC ;
 else
  *msg = ND_INVAL_MAC;

 return (OM_S_SUCCESS);
}

method NDconnect_graph(IGRlong *msg; 
                       IGRint cp_type;
                       struct GRmd_env *fr_env,*to_env;
                       struct NDcp_list *cp_list; 
                       int lsize;
                       int nb_root, *root_inx;
                       int my_inx)
/* ***********************************************************************
Description 
 This message is called for re-establishing graph connections during
 a graph copy.

 This implementation connects the datum planes if they exist
 to the clone entity and connects the dimensional handles to
 the dimensional constraints since this part is non-standard and
 hence is not handled by the graph manager.

Arguments
 msg : Completion code
 cp_type : Currently unused
 fr_env : Environment from where the copy has taken place.
 to_env : To environment for the copy.
 cp_list : The list of the entites and their clones that are being
           graph copied.
 lsize : Number of elements that are being copied after graph
 nb_root : Number of parents
 root_inx : Indices of my parents in cp_list
 my_inx : My index in cp_list

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is failure
 MSINARG : Invalid arguments.

History
 pp : 07/26/91 : Creation

************************************************************************* */
{
 IGRshort 	props, clear_bits;
 IGRuint 	comp_count;
 IGRint 	i;
 IGRlong 	index, status, msg_loc;
 OM_S_CHANSELECT to_components;
 struct GRid 	old_dim, new_dim, my_clone_GRid;
 struct GRid 	clone_GRid, original_GRid;
 extern OMuint 	OM_Gf_verbose_warning;
 void 		EFget_clone();
 
 extern OMuword OPP_SKexplicit_class_id, OPP_EMSdatpln_class_id;
 extern OMuword OPP_ACpretend_class_id;

 *msg = MSSUCC;
 status = OM_S_SUCCESS;

 status = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_components);
 if (!(1&status)) goto wrapup;

 my_clone_GRid.objid = cp_list[my_inx].clone;
 my_clone_GRid.osnum = to_env->md_id.osnum;

 new_dim.osnum = to_env->md_id.osnum;
 original_GRid.osnum = fr_env->md_id.osnum;
 clone_GRid.osnum = to_env->md_id.osnum;

 for (i=0;i<nb_root;i++)
 {
  original_GRid.objid = cp_list[root_inx[i]].original;
  clone_GRid.objid = cp_list[root_inx[i]].clone;

/*
 * If I have a dimensional constraint as a parent, then get the clone of
 * the original dimensional handle and connect the same to the clone of
 * the parent dimensional constraint.
 */

  if (EFisAncestryValid(&msg_loc, original_GRid.objid, 
                        original_GRid.osnum,
                        OPP_SKexplicit_class_id, FALSE))
  {
   if (!(me->props & SK_INVISIBLEHNDL))
   {
    status = om$get_channel_count(objid = original_GRid.objid,
                                 osnum = original_GRid.osnum,
                                 p_chanselect = &to_components,
                                 count = &comp_count);
    if (!(1&status)) goto wrapup;

    if (comp_count != 1)
    {
     if (OM_Gf_verbose_warning)
     {
       fprintf (stderr,"Dimensional constraint has %d comps\n", comp_count);
     }
       status = OM_E_ABORT;
       goto wrapup;
    }
   }

   status = om$get_objid_at_index(osnum = original_GRid.osnum,
                                  objid = original_GRid.objid,
                                  p_chanselect = &to_components,
                                  index = 0,
                                  objidaddr = &old_dim.objid,
                                  osnumaddr = &old_dim.osnum);
   if (!(1&status)) goto wrapup;
   new_dim.objid = NULL_OBJID;

   EFget_clone(&msg_loc, NULL, lsize, cp_list, old_dim.objid, &new_dim.objid);
   if (new_dim.objid == NULL_OBJID)
   {
    if (OM_Gf_verbose_warning)
     fprintf (stderr,"Copy of old dimension %d  %d does not exist\n",
        old_dim.objid, old_dim.osnum);
     status = OM_E_ABORT;
     goto wrapup;
   }

   clear_bits = 0;
   props = GR_RIGID_RELATIONSHIP;
   status = om$send (msg = message GRvg.GRchgprops (&msg_loc, &clear_bits,
                        &props),
                     targetid = new_dim.objid,
                     targetos = new_dim.osnum);
   EMerr_hndlr (!(1&status&msg_loc), *msg, MSFAIL, wrapup);

   index = 0;
   status = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
                           &clone_GRid, &index),
                     targetid = new_dim.objid,
                     targetos = new_dim.osnum);
   EMerr_hndlr (!(1&status&msg_loc), *msg, MSFAIL, wrapup);
  }

/*
 * Else if one of my parents is a datum plane then connect the same to
 * me on the parent-child channel.
 */
  else 
  {
   struct ret_struct ret_struct;

/*
   ret_struct.type = NULL;
   om$send (msg = message NDnode.NDgive_structure (&msg_loc, &ret_struct,
      fr_env), 
   targetid = original_GRid.objid,
   targetos = original_GRid.osnum);
*/

/*
 * It is assumed that the reference plane is connected on index 9.
 * pp 10/02/92
 */

   if (i == 0)
   {
    status = om$send (msg = message NDnode.NDconnect(1,&clone_GRid,
                           original_GRid, ND_ADD),
                     targetid = my_clone_GRid.objid,
                     targetos = my_clone_GRid.osnum);
    if (!(1&status)) goto wrapup;
   }
  }
 }

  
wrapup:
 EMWRAPUP (*msg, status, "In SKmgr:NDconnect_graph error");
 return (status);
}

void EFget_clone(msg, options, cp_size, cp_list, original_obj, clone_obj)
IGRlong *msg;
unsigned int options;
int cp_size;
struct NDcp_list *cp_list;
OM_S_OBJID original_obj;
OM_S_OBJID *clone_obj;
{
 IGRint i;
 *msg = MSSUCC;
 
 *clone_obj = NULL_OBJID;

 for (i=0;i<cp_size;i++)
 {
  if (cp_list[i].original == original_obj)
  {
   *clone_obj = cp_list[i].clone;
   break;
  }
 }

 return;
}

method NDselect_copy(long *msg;
                     int select_type;
		     struct GRid *selected_obj;
                     int *info;
		     int selected_size, 
                     *selected_nb)
/* ********************************************************************
Description
This method adds all the roots of the manager into the list that is
getting copied.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is failure

History
 pp : 07/29/91 : Creation
*********************************************************************** */
{
 IGRlong status,msg_loc;
 struct GRid  my_grid;

 *msg = MSSUCC;
 status = OM_S_SUCCESS;
 *selected_nb = 0;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

/*
 * Add myself.
 */
 *selected_nb = 0;

 if (selected_size > (*selected_nb))
 {
  selected_obj[*selected_nb].objid = my_id;
  selected_obj[*selected_nb].osnum = OM_Gw_current_OS;
 }
 ++(*selected_nb);

 EFadd_to_copy_list(msg, my_grid, info, selected_size, selected_nb,
                    select_type, selected_obj);
 EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, wrapup);

wrapup:
 EMWRAPUP (*msg, status, "In EMAsurface: NDselect_copy method error");
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
/* **********************************************************************
Description
 This method has been overriden to return the non-associative copy
 of the profile. This message is sent for copying the result for the
 purpose of showing the same to the user/ for placing symbol/construction
 macros.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MDFAIL : If there is some form of failure

History
 Creation : PP : 08/10/91
*********************************************************************** */
{
 IGRshort 	props, clear_bits;
 IGRuint 	comp_count;
 IGRlong 	i, status, msg_loc;
 OM_S_OBJID 	temp_objid;
 OM_S_CHANSELECT to_components;
 struct GRid 	grp_GRid;
 extern OMuword OPP_ASgroup_class_id, OPP_GRcompcurve_class_id;

 status = OM_S_SUCCESS;
 *msg = MSSUCC;
 grp_GRid.objid = NULL_OBJID;

 status = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_components);
 if (!(1&status)) goto wrapup;

 status = om$get_channel_count(p_chanselect = &to_components,
                               objid = my_id,
                               osnum = OM_Gw_current_OS,
                               count = &comp_count);
 if (!(1&status)) goto wrapup;

 for (i=0;i<comp_count;i++)
 {
  temp_objid = NULL_OBJID;
  if ((i==0) && (comp_count > 1))
  {
   status = om$construct(classid = OPP_ASgroup_class_id,
                         p_objid = &grp_GRid.objid,
                         osnum = to_env->md_id.osnum);
   if (!(1&status)) goto wrapup;
   grp_GRid.osnum = to_env->md_id.osnum;
  }

  status = om$send (msg = message GRgraphics.GRcopy(&msg_loc,fr_env, to_env,
                          &temp_objid),
                    p_chanselect = &to_components,
                    from = i,
                    to = i);
  EMerr_hndlr(!(1&status&msg_loc), *msg, MSFAIL, wrapup);

  /* temp_objid is NULL_OBJID for SKpoint */
  if (temp_objid != NULL_OBJID)
  {

    if (EFisAncestryValid(&msg_loc, temp_objid, 
                        to_env->md_id.osnum,
                        OPP_GRcompcurve_class_id, FALSE))
    {
     status = om$change_class(objid = temp_objid,
                              osnum = to_env->md_id.osnum,
                              classname = "AScompcurve");
     EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, wrapup);
    }
   }

   if ((grp_GRid.objid != NULL_OBJID) && (temp_objid != NULL_OBJID))
   {

    clear_bits = 0;
    props = GR_RIGID_RELATIONSHIP;
    status = om$send (msg = message GRvg.GRchgprops (&msg_loc, &clear_bits,
                           &props),
                     targetid = temp_objid,
                     targetos = to_env->md_id.osnum);
    EMerr_hndlr (!(1&status&msg_loc), *msg, MSFAIL, wrapup);

    status = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
                           &grp_GRid, &i),
                     targetid = temp_objid,
                     targetos = to_env->md_id.osnum);
    EMerr_hndlr (!(1&status&msg_loc), *msg, MSFAIL, wrapup);
   }
 }

 if (grp_GRid.objid != NULL_OBJID)
  *newobjid = grp_GRid;
 else
 {
  newobjid->objid = temp_objid;
  newobjid->osnum = to_env->md_id.osnum;
 }
  

wrapup:
 EMWRAPUP (*msg, status, "In SKmgr:copy to groot error");
 return (status);
 
}

method NDcopy(IGRlong *msg;IGRint cp_type;
 		 struct GRmd_env *fr_env,*to_env;struct GRid *newobjid)
{
/*
 * Return success. This should never hit me (just to be safe).
 * pp 08/16/91
 */

 *msg = MSSUCC;
 newobjid->objid = NULL_OBJID;
 newobjid->osnum = to_env->md_id.osnum;
 return (OM_S_SUCCESS);
}

method NDchange_connect(int nb_change; struct GRid *old,*new)
{
 IGRlong status;
 IGRlong msg_loc;
 IGRint sizbuf, nret,i;
 extern OMuword OPP_SKasptgrnd_class_id, OPP_SKexplicit_class_id;
 struct GRmd_env env;
 struct ret_struct info_struct;

 status = OM_S_SUCCESS;

/*
 * Set the properties of the copied manager to be out of date so that
 * the profile recomputes based on the new plane. 
 * pp 12/3/91
 */
    om$send (msg = message SKmgr.SKmgrprops(&msg_loc,SK_CHGPROPS_ON,
                              SK_MGR_PLN_OUTOFDATE,NULL),
                    targetid = my_id);
/* end pp */

 sizbuf = sizeof(struct GRmd_env);

 gr$get_module_env ( msg = &msg_loc,
                     sizbuf = &sizbuf,
                     buffer = &env,
                     nret = &nret );
 if (!(1&msg_loc)) goto wrapup;

 for (i=0;i<nb_change;i++)
 {
  if (EFisAncestryValid(&msg_loc, old[i].objid, old[i].osnum, 
                          OPP_SKexplicit_class_id, FALSE))
  {
    status = om$send (msg = message NDnode.NDgive_structure(&msg_loc,
                            &info_struct, &env),
                      targetid = new[i].objid,
                      targetos = new[i].osnum);
    if (info_struct.type & parameter_generic)
    {
     status = om$send (msg = message SKexplicit.SKputval(&msg_loc,NULL,
                              info_struct.var.root_pm_st.value,NULL),
                      targetid = old[i].objid,
                      targetos = old[i].osnum);
     EMerr_hndlr(!(1&status&msg_loc), msg_loc, EMS_E_Fail, wrapup);
    }
  }
  else if (EFisAncestryValid(&msg_loc,old[i].objid, old[i].osnum,
                       OPP_SKasptgrnd_class_id, FALSE))
  {
    status = om$send (msg = message NDnode.NDgive_structure(&msg_loc,
                            &info_struct, &env),
                      targetid = new[i].objid,
                      targetos = new[i].osnum);
    if (info_struct.type & point_generic)
    {
     OM_S_CHANSELECT chan_to_variables;
     int cn_type;
     struct GRid new_GRid;

     EMmake_chanselect(SKconstraint_to_variables, &chan_to_variables);

     status = om$send (msg = message SKvariable.SKputvar(&msg_loc,NULL,
                             &env.md_env.matrix_type,
                             env.md_env.matrix,
                             info_struct.var.point_st.pt),
                       senderid = old[i].objid,
                       p_chanselect = &chan_to_variables);
     EMerr_hndlr(!(1&status&msg_loc), msg_loc, EMS_E_Fail, wrapup);

     status = om$send (msg = message SKmgr.SKmgrprops (&msg_loc, SK_CHGPROPS_ON,
                             SK_MGR_OUTOFDATE,NULL),
                       targetid = my_id);
     EMerr_hndlr(!(1&status&msg_loc), msg_loc, EMS_E_Fail, wrapup);


     cn_type = ND_COMP;
     nd$wait_batch(type = GR_GEOM_POSTED,
                   l_object = &old[i],
                   l_obj_info = &cn_type,
                   nb_obj   = 1);
    }
  }
  else
  {
   status = om$send (msg = message EMSassoc.NDchange_connect(1,
                         &old[i], &new[i]),
                   mode = OM_e_wrt_message,
                   targetid = my_id);
   EMerr_hndlr(!(1&status), msg_loc, MSFAIL, wrapup);
  }
 }

wrapup:
 EMWRAPUP (msg_loc, status, "In SKmgr:NDchange_connect error");
 return (status);
}

EFadd_to_copy_list(msg, my_grid, info, selected_size, selected_nb,
                   select_type, selected_obj)
IGRlong *msg;
int select_type;
struct GRid my_grid;
int *info;
int selected_size;
int *selected_nb;
struct GRid *selected_obj;
{
 IGRuint comp_count;
 IGRlong status,msg_loc;
 IGRint i, num_roots;
 struct GRid temp_GRid, *roots = NULL;
 struct GRid *cur_ptr;
 OM_S_CHANSELECT to_components;
 OM_S_CHANSELECT children;

 status = OM_S_SUCCESS;
 *msg = MSSUCC;

 status = nd$get_graph(nb_tip = 1,
                       p_tip = &my_grid);

 status = nd$get_list_in_graph( acc_type = ND_EXTERN,
                                rej_type = ND_TIP | ND_BODY,
                                p_count = &num_roots,
                                buf_addr = &roots);
 EMmake_chanselect(NDchildren_children, &children);
 EMmake_chanselect(GRcmpowner_to_components, &to_components);

 for (i=0;i<num_roots;i++)
 {
   if (selected_size > (*selected_nb))
     selected_obj[*selected_nb] = roots[i];
   ++(*selected_nb);

  cur_ptr = &roots[i];

  if (EFisAncestryValid(&msg_loc, cur_ptr->objid, cur_ptr->osnum,
                        OPP_ASsourcein_class_id, FALSE))
  {
   IGRuint child_count;
   IGRint ii;
   struct GRid child_GRid;

   status = om$get_channel_count(objid = cur_ptr->objid,
                                 osnum = cur_ptr->osnum,
                                 p_chanselect = &children,
                                 count = &child_count);
   EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, wrapup);

   for (ii=0;ii<child_count;ii++)
   { 
    status = om$get_objid_at_index(objid = cur_ptr->objid,
                                   osnum = cur_ptr->osnum,
                                   p_chanselect = &children,
                                   index = ii,
                                   objidaddr = &child_GRid.objid,
                                   osnumaddr = &child_GRid.osnum);
   EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, wrapup);

    if (EFisAncestryValid(&msg_loc, child_GRid.objid, child_GRid.osnum,
                        OPP_expression_class_id, FALSE))
     *cur_ptr = child_GRid;
    break;
   }
  }

  if (EFisAncestryValid(&msg_loc, cur_ptr->objid, 
                        cur_ptr->osnum,
                        OPP_EMSsurface_class_id, FALSE))
  {
   IGRuint child_count;
   int     j, child_type;
   /*
    * Get the children and return those children,
    * who are pointers, and model space counterparts
    * which exist in the graph that was just obtained.
    *
    * This means there exists an implied dependency between 
    * the mscs/pointers and the solid and hence the same
    * need to be prompted for while placing a macro.
    */
    EMmake_chanselect(NDchildren_children, &children);

    status = om$get_channel_count(p_chanselect = &children,
                                  objid = cur_ptr->objid,
                                  osnum = cur_ptr->osnum,
                                  count = &child_count);
    if (!(1&status)) goto wrapup;

    for (j=0;j<child_count;j++)
    {
     status = om$get_objid_at_index(objid = cur_ptr->objid,
                                     osnum = cur_ptr->osnum,
                                     p_chanselect = &children,
                                     index = j,
                                     objidaddr = &temp_GRid.objid,
                                     osnumaddr = &temp_GRid.osnum);
     if (!(1&status)) goto wrapup;


     if ((EFisAncestryValid(&msg_loc, temp_GRid.objid, 
                        temp_GRid.osnum,
                        OPP_GAcurve_class_id, FALSE)) ||
         (EFisAncestryValid(&msg_loc, temp_GRid.objid, 
                        temp_GRid.osnum,
                        OPP_EMSpointer_class_id, FALSE)))
     {
      nd$get_type(p_object = &temp_GRid,
                  p_type = &child_type,
                  nb_obj = 1);
         
      if (child_type & ND_BODY) 
      {
       if (selected_size > (*selected_nb))
       {
         selected_obj[*selected_nb] = temp_GRid;
         info[*selected_nb] = ND_ROOT;
       }

       ++(*selected_nb);
      }
     }
    }
   }

  if ((EFisAncestryValid(&msg_loc, cur_ptr->objid, 
                        cur_ptr->osnum,
                        OPP_EMScnstr_class_id, FALSE)) ||
      (EFisAncestryValid(&msg_loc,cur_ptr->objid,
                        cur_ptr->osnum,
                        OPP_SKexplicit_class_id, FALSE)))
  {
   status = om$get_channel_count(objid = cur_ptr->objid,
                                 osnum = cur_ptr->osnum,
                                 p_chanselect = &to_components,
                                 count = &comp_count);
   if (!(1&status)) goto wrapup;

   if (comp_count != 1)
   {
    if (OM_Gf_verbose_warning)
     fprintf (stderr,"Constraint has %d comps\n", comp_count);
    continue;
   }

   status = om$get_objid_at_index(objid = cur_ptr->objid,
                                  osnum = cur_ptr->osnum,
                                  p_chanselect = &to_components,
                                  index = 0,
                                  objidaddr = &temp_GRid.objid,
                                  osnumaddr = &temp_GRid.osnum);
   if (!(1&status)) goto wrapup;

   if (selected_size > (*selected_nb))
   {
    if (!(EFisAncestryValid(&msg_loc, temp_GRid.objid,
                        temp_GRid.osnum,
                        OPP_DMroot_class_id, FALSE)))
     info[*selected_nb] = 0;

    selected_obj[*selected_nb] = temp_GRid;
   }

   ++(*selected_nb);
  }
 }

 status = nd$get_list_in_graph (acc_type = ND_BODY,
                                rej_type = ND_TIP | ND_EXTERN,
                                p_count = &num_roots,
                                buf_addr = &roots);

 for (i=0;i<num_roots;i++)
 {
  cur_ptr = &roots[i];
  if ((EFisAncestryValid(&msg_loc, cur_ptr->objid, 
                        cur_ptr->osnum,
                        OPP_EMScnstr_class_id, FALSE)) ||
      (EFisAncestryValid(&msg_loc,cur_ptr->objid,
                        cur_ptr->osnum,
                        OPP_SKexplicit_class_id, FALSE)))
  {
   status = om$get_channel_count(objid = cur_ptr->objid,
                                 osnum = cur_ptr->osnum,
                                 p_chanselect = &to_components,
                                 count = &comp_count);
   if (!(1&status)) goto wrapup;

   if (comp_count != 1)
   {
    if (OM_Gf_verbose_warning)
     fprintf (stderr,"Constraint has %d comps\n", comp_count);
    continue;
   }

   status = om$get_objid_at_index(objid = cur_ptr->objid,
                                  osnum = cur_ptr->osnum,
                                  p_chanselect = &to_components,
                                  index = 0,
                                  objidaddr = &temp_GRid.objid,
                                  osnumaddr = &temp_GRid.osnum);
   if (!(1&status)) goto wrapup;

   if (selected_size > (*selected_nb))
   {
    selected_obj[*selected_nb] = temp_GRid;
    if (!(EFisAncestryValid(&msg_loc, temp_GRid.objid,
                        temp_GRid.osnum,
                        OPP_DMroot_class_id, FALSE)))
     info[*selected_nb] = 0;
   }

   ++(*selected_nb);
  }
 }

wrapup:
 return (status);
}
end implementation SKmgr;

