/* ###################   APOGEE COMPILED   ################## */
class implementation EMScnstr;

#include "nddef.h"
#include "ndmacros.h"
#include "EMcp.h"
#include "godef.h"
#include "parametric.h"
#include "OMmacros.h"
#include "maidmx.h"

extern OMuword OPP_EMSparamgm_class_id;
from EMSexpcnstr import EMmanage_expression_vla;
from EMSsurface import EMgetactiveid;

method ACbecome_macro(IGRlong *msg; 
                      IGRint position;
		      struct GRmd_env *md_env)

/* ***************************************************************************
Description 
 This object returns the type of macros that can be constructed with this
 object. At this time it is only valid for drop macro placement and hence
 will return a completion code of ND_DROP_MAC.

Notes
 Upon exit the completion code will be one of the following:
  ND_DROP_MAC : If the manager is not a root or an external element
  ND_INVAL_MAC : Otherwise

History
 pp : 07/25/91 : Creation
 Sudha   07/06/93        modified for BSprototype includes
*************************************************************************** */
{
 OM_S_CHANSELECT to_components;
 struct GRid dim;
 int el_type;
 OMuint comp_count;
 IGRlong status;

 *msg = ND_DROP_MAC | ND_CONS_MAC;
 status = OM_S_SUCCESS;

 status = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_components);
 if (!(1&status)) goto wrapup;

 status = om$get_channel_count(objid = my_id,
                               p_chanselect = &to_components,
                               count = &comp_count);
 if (!(1&status)) goto wrapup;
 
 if (comp_count)
 {
  status = om$get_objid_at_index(
                                objid = my_id,
                                p_chanselect = &to_components,
                                index = 0,
                                objidaddr = &dim.objid,
                                osnumaddr = &dim.osnum);
  if (!(1&status)) goto wrapup;

  nd$get_type(nb_obj = 1,
             p_object = &dim,
             p_type = &el_type);
  if (el_type == 0)
    status = 0;
 }

wrapup:
 if (!(1&status)) *msg = ND_INVAL_MAC;
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
 This message is overriden to connect the dimensional handle which has
 been copied onto the new constraint object since this connection is
 outside the realm of the graph manager.

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
 IGRlong status,msg_loc;
 OMuint comp_count;
 IGRlong index;
 IGRshort props, clear_bits;
 OM_S_CHANSELECT to_components;
 struct GRid old_dim, new_dim, my_clone_GRid;
 extern OMuint OM_Gf_verbose_warning;
 void EFget_clone();
 
 *msg = MSSUCC;
 status = OM_S_SUCCESS;

/*
 * This message will connect my parents to myself on the parent-child
 * channel.
 */

 status = om$send (msg = message NDnodein.NDconnect_graph(msg,
                         cp_type, fr_env, to_env, cp_list, lsize,
                         nb_root, root_inx, my_inx),
                   mode = OM_e_wrt_message,
                   targetid = my_id);
 EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);

 status = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_components);
 if (!(1&status)) goto wrapup;

 my_clone_GRid.objid = cp_list[my_inx].clone;
 my_clone_GRid.osnum = to_env->md_id.osnum;

 new_dim.osnum = to_env->md_id.osnum;

/*
 * If I have a dimensional handle, then get the clone of
 * my dimensional handle and connect the same to the clone of
 * myself.
 */

   status = om$get_channel_count(objid = my_id,
                                 osnum = OM_Gw_current_OS,
                                 p_chanselect = &to_components,
                                 count = &comp_count);
   if (!(1&status)) goto wrapup;

   if (comp_count == 0)
   {
    status = OM_S_SUCCESS;
    goto wrapup;
   }

   if (comp_count > 0)
   {
    status = om$get_objid_at_index(objid = my_id,
                                  osnum = OM_Gw_current_OS,
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
    }
    else
    {
     clear_bits = 0;
     props = GR_RIGID_RELATIONSHIP;
     status = om$send (msg = message GRvg.GRchgprops (&msg_loc, &clear_bits,
                        &props),
                     targetid = new_dim.objid,
                     targetos = new_dim.osnum);
     EMerr_hndlr (!(1&status&msg_loc), *msg, MSFAIL, wrapup);

     index = 0;
     status = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
                         &my_clone_GRid, &index),
                     targetid = new_dim.objid,
                     targetos = new_dim.osnum);
     EMerr_hndlr (!(1&status&msg_loc), *msg, MSFAIL, wrapup);
    }
   }

  
wrapup:
 EMWRAPUP (*msg, status, "In EMSexpcnstr:NDconnect_graph error");
 return (status);
}



method NDdisplay(IGRint dp_type;enum GRdpmode mode;struct GRmd_env *env)
/*
 * This method has been overriden to display the geometric handle if it
 * exists.
 * 
 * History
 * pp: 08/09/91
 */
{
  IGRlong EMmsg;

  (void) EFdisplay_handle(&EMmsg,dp_type,mode,env,my_id, OM_Gw_current_OS);

 return(OM_S_SUCCESS);
}

IGRint EFdisplay_handle(EMmsg, dp_type, mode, env, obj_id, obj_os)
IGRlong *EMmsg;
IGRint dp_type;
enum GRdpmode mode;
struct GRmd_env *env;
OM_S_OBJID obj_id;
OMuword obj_os;
{
  OMuint comp_count;
  IGRint status;
  IGRlong loc_msg;
  struct GRid mod_grid;
  IGRshort mat_type;
  IGRmatrix mat_ident;
  IGRdouble *mat;
  OM_S_CHANSELECT to_components;
 
  status = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if(env == NULL)
   {
    mat_type = MAIDMX;
    MAidmx(&loc_msg,mat_ident);
    mat = mat_ident;
   }
  else
   { 
    mat_type = env->md_env.matrix_type;
    mat = env->md_env.matrix;
   }

  status = EMmake_chanselect(GRcmpowner_to_components, &to_components);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  status = om$get_channel_count(objid = obj_id,
                                osnum = obj_os,
                                p_chanselect = &to_components,
                                count = &comp_count);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
  
  if (comp_count)
  {
   GRfindmod(&mod_grid);
   status = om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
        		    &mat_type,mat,&mode,&mod_grid),
                    senderid = obj_id,
                    p_chanselect = &to_components,
                    targetos = obj_os);
   EMerr_hndlr (!(1&status&loc_msg), *EMmsg, EMS_E_Fail, wrapup);
  }

wrapup:
 EMWRAPUP (*EMmsg, status, "In EFdisplay_handle error");
 return(status);
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
 IGRshort 	props, clear_bits;
 IGRuint 	comp_count;
 IGRlong 	i, status, msg_loc;
 OM_S_CHANSELECT to_comps;
 struct GRid 	my_copied_GRid, dim_GRid;
 OM_S_OBJID 	copied_dim;
 extern OMuword OPP_DMroot_class_id;
 
 status = OM_S_SUCCESS;
 *msg = MSSUCC;

/*
 * This element should only be copied, if this is a template. 
 */

 newobjid->objid = NULL_OBJID;
 newobjid->osnum = to_env->md_id.osnum;
 
 if (cp_type & ND_TO_DEF_TEMP)
 {
  status = om$construct_and_copy(object = me,
                                 osnum = to_env->md_id.osnum,
                                 p_objid = &my_copied_GRid.objid);
  EMerr_hndlr(!(1&status), *msg, MSFAIL, wrapup);
  my_copied_GRid.osnum = to_env->md_id.osnum;

  clear_bits = 0;
  props = GR_RIGID_RELATIONSHIP;

  status = om$send (msg = message GRvg.GRchgprops(&msg_loc,
                         &clear_bits,&props),
                   targetid = my_copied_GRid.objid,
                   targetos = to_env->md_id.osnum);
  EMerr_hndlr(!(1&status&msg_loc), *msg, MSFAIL, wrapup);

  newobjid->objid = my_copied_GRid.objid;
  
  status = EMmake_chanselect(GRcmpowner_to_components,&to_comps);

  status = om$get_channel_count(object = me,
                                p_chanselect = &to_comps,
                                count = &comp_count);
  EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, wrapup);

  if (!comp_count) goto wrapup;
  for (i=0;i<comp_count;i++)
  {
    status = om$get_objid_at_index(object = me,
                                  p_chanselect = &to_comps,
                                  objidaddr = &dim_GRid.objid,
                                  osnumaddr = &dim_GRid.osnum,
                                  index = i);
    EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, wrapup);

     
     if (EFisAncestryValid(&msg_loc, dim_GRid.objid, dim_GRid.osnum, 
                          OPP_DMroot_class_id, FALSE))
     {
      struct GRid copied_dim_GRid;

      status = om$send (msg = message NDmacro.ACcopy_to_Groot(&msg_loc, cp_type,
                              fr_env,
                          to_env, &copied_dim_GRid),
                      p_chanselect = &to_comps,
                      from = i,
                      to = i);
      EMerr_hndlr(!(1&status&msg_loc), *msg, MSFAIL, wrapup);
      copied_dim = copied_dim_GRid.objid;
     }
     else
     {
      status = om$send (msg = message GRgraphics.GRcopy(&msg_loc, fr_env,
                          to_env, &copied_dim),
                      p_chanselect = &to_comps,
                      from = i,
                      to = i);
      EMerr_hndlr(!(1&status&msg_loc), *msg, MSFAIL, wrapup);
     }

    status = om$send (msg = message GRconnector.GRrigidconn(&msg_loc,
                           &my_copied_GRid, &i),
                     targetid = copied_dim,
                     targetos = to_env->md_id.osnum);
    EMerr_hndlr(!(1&status&msg_loc), *msg, MSFAIL, wrapup);
   }
 }

wrapup:
 return (status);
}
method ASreturn_go ( struct GRid * go;
                     IGRshort    * mat_type;
                     IGRdouble   * matrix )
/*
 * This implementation returns itself as the graphic object. 
 * Changing the behaviour of this message may impact a lot of 
 * things.
 * pp 08/21/91
 */
{
 IGRlong         msg;
 struct GRmd_env mod_env;
 IGRint          sizbuf, nret;

 go->objid = my_id;
 go->osnum = OM_Gw_current_OS;


 if (matrix && mat_type)
 {
    sizbuf = sizeof(struct GRmd_env);

    gr$get_module_env ( msg = &msg,
                        sizbuf = &sizbuf,
                        buffer = &mod_env,
                            nret = &nret );

    *mat_type = mod_env.md_env.matrix_type;    

    memcpy (matrix, mod_env.md_env.matrix, sizeof(IGRmatrix));
 }
  return (OM_S_SUCCESS);
}
end implementation EMScnstr;

