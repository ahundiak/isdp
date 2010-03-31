/* ###################   APOGEE COMPILED   ################## */
class implementation EMSexpcnstr;

#include "nddef.h"
#include "ndmacros.h"
#include "EMcp.h"
#include "godef.h"
#include "parametric.h"
#include "OMmacros.h"
#include "EMSasnucdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"
#include "exmacros.h"

extern OMuword OPP_EMSparamvl_class_id, OPP_EMSexpcnstr_class_id,
       OPP_EMSangcnstr_class_id;

method NDcopy_graph(IGRlong *EMmsg;
                    IGRint cp_type;
 		    struct GRmd_env *fr_env,*to_env;
		    struct NDcp_list *nd_cp_list; 
                    int list_size;
		    int position)
/* ****************************************************************
Description
 This override will cause the copy of the dimensional constraint
 to occur. The connection to dimensional handles is made using
 NDconnect_graph. If the entity being copied was a root element,
 of the graph then special processing is done to handle this situation.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : Failure in copy.

History
 pp : 08/07/91 : Creation
 **************************************************************** */
 
{
 IGRlong status, msg_loc;
 IGRint cl_size;
 struct NDcp_list *myinx;
 struct GRid new_GRid, my_grid;
 struct ret_struct info_struct;
 extern IGRboolean ASbroadcast_in_progress;
 OMuword clone_classid, my_classid;
 struct GRid old_clone_GRid;

 status = OM_S_SUCCESS;
 *EMmsg = MSSUCC;

 myinx = &nd_cp_list[position];
 new_GRid.objid = NULL_OBJID;
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 if (!ASbroadcast_in_progress) return (OM_S_SUCCESS);
 

 status = om$send (msg = message NDnode.NDcopy(&msg_loc,cp_type,
                          fr_env, to_env, &new_GRid),
                   targetid = my_id);
 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, MSFAIL, wrapup);
  

  old_clone_GRid.objid = nd_cp_list[position].clone;
  old_clone_GRid.osnum = to_env->md_id.osnum;

  if (old_clone_GRid.objid != NULL_OBJID)
  {
   status = om$get_classid (objid = old_clone_GRid.objid,
                            osnum = to_env->md_id.osnum,
                            p_classid = &clone_classid);
   if (!(1&status)) goto wrapup;

   status = om$get_classid (object = me,
                            p_classid = &my_classid);
   if (!(1&status)) goto wrapup;

   if (clone_classid != my_classid)
   {
    status = om$send (msg = message NDnode.NDconnect(1,&old_clone_GRid,
                            my_grid,ND_ADD),
                      targetid = new_GRid.objid,
                      targetos = new_GRid.osnum);
    EMerr_hndlr(!(1&status), *EMmsg, MSFAIL, wrapup);

/*
 * Determine if the old clone is a expression by sending a NDgive_structure.
 * If the completion code and the return status is good then
 * update the value in the copied instance data. If not just continue.
 * The latter scenario is more likely to occur when the copy is
 * taking place for the purposes of creating a macro definition.
 */
/*
    status = om$send (msg = message NDnode.NDgive_structure(EMmsg,
                            &info_struct, to_env),
                      targetos = old_clone_GRid.osnum,
                      targetid = old_clone_GRid.objid);
    if (1&status&*EMmsg)
    {
      if (info_struct.type & parameter_generic)
      {
        om$send (msg = message expression.NDset_value(NULL,
                                info_struct.var.root_pm_st.value,
                                to_env,EMmsg),
                         targetid = new_GRid.objid,
                         targetos = new_GRid.osnum);
      }
    }
    else
    {
      status = OM_S_SUCCESS;
      *EMmsg = EMS_S_Success;
    }
*/

     cl_size = 3;
     status = om$send (msg = message EMSexpcnstr.EMmanage_expression_vla(
                            EMmsg, 0x1,&cl_size,"\\0"),
                      targetid = new_GRid.objid,
                      targetos = new_GRid.osnum);
     EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);
   }
  }

/*
 * Give the newly constructed object a name.
 * Prasad 01/03/92
 */
   {
    IGRlong mthd_stat;
    IGRint type;
    IGRchar newname[DI_PATH_MAX];

    if (EFisAncestryValid(&mthd_stat, my_id, OM_Gw_current_OS,
                              OPP_EMSparamvl_class_id, FALSE))
      type = EMSscalar;
    else if (EFisAncestryValid(&mthd_stat, my_id, OM_Gw_current_OS,
                            OPP_EMSangcnstr_class_id, FALSE))
      type = EMSangle;
    else
      type = EMSdistance;

    EMdefnewname(newname, new_GRid.osnum, type);

    if (newname[0] != '\0')
    {
     IGRchar temp_name[DI_PATH_MAX];
     struct GRid cur_mod;
/*
 * If the expression is being created in the master file then we try
 * to create the same in the current directory. Else if it is in a
 * different object space, then we try to create the same in the
 * default directory of that object space.
 */

     cur_mod.osnum = 0;
     ex$get_cur_mod(id = &cur_mod.objid, osnum = &cur_mod.osnum);

      temp_name[0] = '\0';
     if (cur_mod.osnum != new_GRid.osnum)
     {
      di$give_pathname(osnum = new_GRid.osnum,
                      pathname = temp_name);

      strcat(temp_name, ":");
      strcat(temp_name, newname);
     }
     else 
      strcpy(temp_name, newname);

     om$send (msg = message GRgraphics.GRputname(&mthd_stat,
                         temp_name),
                  targetid = new_GRid.objid,
                  targetos = new_GRid.osnum);
    }
   }

 myinx->clone = new_GRid.objid;

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSexpcnstr:NDcopy_graph method error");
 return (status);
}


method EMmanage_expression_vla(IGRlong *msg; 
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
 EMWRAPUP (*msg, status, "In EMSexpcnstr:EMmanage_expression_vla error");
 return (status);

}
end implementation EMSexpcnstr;

