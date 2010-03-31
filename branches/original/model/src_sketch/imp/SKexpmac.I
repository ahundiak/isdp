class implementation SKexplicit;

#include "nddef.h"
#include "OMmacros.h"
#include "ndmacros.h"

method ACbecome_macro(IGRlong *msg; 
                      IGRint position;
		      struct GRmd_env *md_env)

/* ***************************************************************************
Description 
 This object returns the type of macros that can be constructed with this
 object. At this time it is only valid for drop macro placement and hence
 will return a completion code of ND_DROP_MAC.
*************************************************************************** */
{
 OM_S_CHANSELECT to_components;
 struct GRid dim;
 int el_type;
 OMuint comp_count=0;
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

method NDcopy_graph(IGRlong *msg;IGRint cp_type;
 		 struct GRmd_env *fr_env,*to_env;
		 struct NDcp_list *copied_element; int copied_size;
		 int my_index)
/* ************************************************************************
Description
 This object will return success since the copy of the constraint is handled
 by the manager.

History
 pp : 07/24/91 : Creation
 *********************************************************************** */
{
 *msg = MSSUCC;
 return (OM_S_SUCCESS);
}

method SKmanage_expression_vla(IGRlong *msg; 
                              unsigned int options;
                              IGRint *size;
                              IGRchar *strng)

/* ******************************************************************

 Description
 This message is used to initialise the expression vla instance data.
 It stores the string that is coming in, into the expression vla.

 Arguments
 options : 0x1 : stores the incoming string into the vla.
           0x2 : copies the string stored in the vla into the
                 incoming field.
 size : Size of the string in question.
 strng : Incoming string. If options is 0x2 and this field is NULL then
         only size is returned.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is failure
 MSINARG : If invalid arguments

History
 Creation : PP :07/30/91
******************************************************************** */
{
 IGRint vla_size;
 IGRlong status;

 status = OM_S_SUCCESS;
 *msg = MSSUCC;

 vla_size = OM_DIMENSION_OF(me->pretty_print);
 if (options & 0x1)
 {
  if (vla_size <  (*size))
   OM_SET_DIMENSION(ME.expression->pretty_print,(*size));

  if (strng)
   OM_BLOCK_MOVE(strng,ME.expression->pretty_print,*size);
 }
 else if (options & 0x2)
 {
  *size = vla_size;
  if (strng)
   OM_BLOCK_MOVE(ME.expression->pretty_print,strng,*size);
 }
 else
 {
  *msg = MSINARG;
  goto wrapup;
 }

wrapup:
 EMWRAPUP (*msg, status, "In SKexplicit:SKmanage_expression_vla error");
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
end implementation SKexplicit;

