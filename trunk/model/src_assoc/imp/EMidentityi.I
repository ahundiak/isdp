class implementation EMSidentity;

#include "asbox.h" /* For NULL_GRID */
#include "nddef.h" /* For ND_NC_NEW */

method EMinit(IGRlong *EMmsg;
              IGRuint options;
              struct GRid *parent_GRid)
/* *************************************************************

Description
 This method initialises the identity object. It connect itself
 to the parent being passed in on the parent child channel.

Arguments
 options : Set to NULL.
 parent_GRid : Should be an object who has the parent child channel.
            
Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well.
 EMS_E_Fail : If there is failure.

History
 Creation : PP : 06/08/91

  ************************************************************** */
{
  *EMmsg = EMS_S_Success;

  return(om$send (msg = message NDnode.NDconnect (1,parent_GRid,
                   NULL_GRID,
                   ND_ADD), 
                   targetid = my_id));
}

method ASreturn_go ( struct GRid * go;
                     IGRshort    * mat_type;
                     IGRdouble   * matrix )
{
 OM_S_CHANSELECT father;

 EMmake_chanselect(NDfather_father, &father);

 return( om$send (msg = OPPmargs,
                   p_chanselect = &father));
 
}

method ACbecome_macro(IGRlong *msg; 
                      IGRint position;
		      struct GRmd_env *md_env)
{
 OM_S_CHANSELECT father;

 EMmake_chanselect(NDfather_father, &father);

 return( om$send (msg = OPPmargs,
                   p_chanselect = &father));
 
}

method NDupdate(IGRint *msg;
                IGRint cn_type;
                IGRint count;
	        struct GRid *list;
	        IGRint *parent_state;
	        struct GRid *context,*new_objid;
	        struct GRmd_env *md_env)
{
 new_objid->objid = my_id;
 new_objid->osnum = OM_Gw_current_OS;
 *msg = ND_COMP_SUCC;
 return (OM_S_SUCCESS);
}

method NDs_compute_node ( IGRlong *msg; IGRint cn_type;
			     struct GRmd_env *md_env)
{
 *msg = EMS_S_Success;
 return (OM_S_SUCCESS);
}

method NDgive_structure (IGRlong *msg; struct ret_struct *str;
                            struct GRmd_env *md_env )
{
 OM_S_CHANSELECT father;

 EMmake_chanselect(NDfather_father, &father);

 return( om$send (msg = OPPmargs,
                   p_chanselect = &father));
 
}

method NDmove_to_root (IGRlong *msg; struct GRid *src_grid;
			  struct GRmd_env *md_env )
/*
 * This method is overriden to just pass this message to the children
 * if they do exist.
 */

{
 IGRlong status;
 OM_S_CHANSELECT children;
 *msg = EMS_S_Success;

 status = OM_S_SUCCESS;

 EMmake_chanselect(NDchildren_children, &children);

 status = om$send (msg = OPPmargs,
                   p_chanselect = &children);
 EMerr_hndlr (!(1&status), *msg, EMS_E_OMerror, wrapup);
 
 status = om$send (msg = message Root.delete(1),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, wrapup);

wrapup:
 EMWRAPUP (*msg, status, "In EMSpointer:NDmove_to_root error");
 return (status);
}

method NDdisplay(IGRint dp_type;enum GRdpmode pen;struct GRmd_env *env)
{
 OM_S_CHANSELECT father;

 EMmake_chanselect(NDfather_father, &father);

 return( om$send (msg = OPPmargs,
                   p_chanselect = &father));
}

method ACcopy_to_Groot(IGRlong *msg;IGRint cp_type;
			 struct GRmd_env *fr_env,*to_env;
  			 struct GRid *newobjid)
{
 OM_S_CHANSELECT father;

 EMmake_chanselect(NDfather_father, &father);

 return( om$send (msg = OPPmargs,
                   p_chanselect = &father));
}

end implementation EMSidentity;

