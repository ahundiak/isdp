/* ###################   APOGEE COMPILED   ################## */
class implementation EMSagrp;

#include "EMS.h"
#include "godef.h"
#include "lcdef.h"
#include "lc.h"
#include <string.h>
#include "EMptrmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

method EMget_parent_type(IGRlong *EMmsg;
                         IGRint primitive_type;
                         IGRuint root_count;
                         IGRuint *root_type)

/* ************************************************************************
Description
 This function gets the root types which is used for getting information
 about the parents. Adequate memory needs to be allocated for root_type 
 enough to suffice the number of parents.

Arguments
 Input
  root_count : number of roots expected. Necessary.
  
 Output
  root_type : Memory allocated to suffice the number of parents.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : If all goes well.
 EMS_E_Fail : If there was an error in getting the root_structures.
 EMS_E_InvalidArg : If the number of roots expected does not match what
                    is returned.
                    Or if the construction code is invalid.
                    Or if root list is not supplied.

History
   07/13/91 : PP  : Creation
 ************************************************************************* */

{
 IGRlong status,i;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
  
 switch (primitive_type)
 {
  case EMS_ASintersect_elements:
  case EMS_ASintersect_elements1:
  for (i=0;i<root_count;i++)
   root_type[i] = EMSlcinfo;
  break;

  case EMS_ASiso_parametric_curves:
   root_type[0] = EMSlcinfo;
  break;

  default:
  {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
  }
 }

wrapup:
 EMWRAPUP (status, *EMmsg, "In EMSagrp:EMget_parent_type error"); 
 return (status);
}

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)

/* ******************************************************
Description
  This routine retrieves information about the object and
  stores it in the input structure.

Notes
 The maximum information that we can put into the type field of
 GRobj_info structure is 30 characters.
 
History
 Creation : PP : 07/13/91
******************************************************** */

{

 *msg = MSSUCC;

 if (me->type != EMS_ASno_type)
  strcpy(info->type,"Associative group");
 else
  strcpy(info->type,"Rigid group");

 return(OM_S_SUCCESS);
}

method GRcopy(IGRlong *msg; struct GRmd_env *obj_mdenv; 
              struct GRmd_env *new_mdenv; GRobjid *newobjid)
{
  IGRlong     OM_stat,
              mthd_stat;
  struct GRid src_GRid;

  *msg = MSSUCC;
  OM_stat = OM_S_SUCCESS;

  /*
   * send a message to myself to perform the copy process
   */

  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message GRowner.GRcopy(msg, obj_mdenv,
                                                 new_mdenv, newobjid),
                    targetid = my_id);
  EMerr_hndlr(!(1 & OM_stat & *msg),*msg, MSFAIL, wrapup);

  OM_stat = om$send(msg = message NDnode.NDmove_to_root(&mthd_stat,
                                                        &src_GRid,
                          new_mdenv),
                    targetid = *newobjid,
                    targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr(!(1 & OM_stat & *msg),*msg, MSFAIL, wrapup);

  *newobjid = src_GRid.objid;

wrapup:
     EMWRAPUP (*msg, OM_stat, "In EMSagrp.GRcopy");
     return(OM_stat);
}

method GRlocate_owner ( IGRlong *msg; 
                        struct GRlc_cvl *cvl;
                        struct GRlc_path *path; 
                        IGRint *path_position)
{
 IGRlong status;
 unsigned long save_owner_action;

 if (!strcmp(cvl->attributes.obj_attr.classes,"EMSrigid_comp"))
 {
  save_owner_action = cvl->attributes.obj_attr.owner_action;
  cvl->attributes.obj_attr.owner_action |= LC_RIGID_COMP;

  status = om$send (mode = OM_e_wrt_message,
                    msg = message GRowner.GRlocate_owner(msg,cvl,path,
                          path_position),
                    targetid = my_id);
  cvl->attributes.obj_attr.owner_action = save_owner_action;
 }
 else
 {
  status = om$send (mode = OM_e_wrt_message,
                    msg = message GRowner.GRlocate_owner(msg,cvl,path,
                          path_position),
                    targetid = my_id);
 }
 return (status);
}

method NDselect_copy(long *msg;
                     int select_type;
		     struct GRid *selected_obj;
                     int *info;
		     int selected_size, 
                     *selected_nb)
/* ********************************************************************
Description
This method adds any dimensional handles(if any) to the list that is
getting copied. We need to do this to preserve integrity of the system
and since theoretically the surface/solid is "owning" those entities.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is failure

History
 pp : 08/13/92 : Creation
*********************************************************************** */
{
 IGRlong status;
 struct GRid my_grid;

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
 EMWRAPUP (*msg, status, "In EMSagrp: NDselect_copy method error");
 return (status);
}

/*
Name

    GRdisyourself

Abstract

        This method will create pointers (class EMSpointer) for each
    component object if a flag indicates this should be done.  The element
    is then displayed.

Synopsis

        Type                   Name           I/O       Description
 --------------------- ---------------------- --- --------------------------
 IGRlong               *rc                     O  Return code.
 IGRshort              *mx_type                I  Type of matrix.
 IGRmatrix             matrix                  I  Environment matrix of the
                                                  element to be displayed.
 enum GRdpmode         *mode                   I  A mode indicating how the
                                                  element is to be displayed.
 struct IGRaltdisplay  *alt_symb               I  Alternate display
                                                  attributes.
 struct DP_information *sp_info                I  Special display
                                                  information.
 OM_p_KEY_DESC         range_key               I  Element's range key;
                                                  send NULL pointer if it's
                                                  unknown.

Description

        In addition to displaying its object, this method also checks to
    see if the flag that indicates pointers (and model space counterparts)
    are to be created is set, and if it is then it creates pointers
    (class EMSpointer) for each component of its object.

Keywords

    display
    method

History

    06/11/93  :  WBC  :  Creation date.
    07/18/94  :  WBC  :  Removed code to create EMSpointers; we are no longer
                         trying to create these on the fly.  Users must
                         explicitly use the command "Enable Read-Only Detailing"
                         to create EMSpointers and MSCs for read-only detailing
                         (TR 119420413 and 119419323).
Justification

    Inherited display method does not create pointers.
*/

method	GRdisyourself(IGRlong *rc; IGRshort *mx_type; IGRmatrix matrix;
		      enum GRdpmode *mode; struct IGRaltdisplay *alt_symb; 
		      struct DP_information *sp_info; 
		      OM_p_KEY_DESC range_key)

{
    IGRlong          status;

    status = om$send(mode = OM_e_wrt_message,
                     msg = message GRowner.GRdisyourself(rc, mx_type,
                                                         matrix, mode,
                                                         alt_symb, sp_info,
                                                         range_key),
                     targetid = my_id);

    return(status);
}

end implementation EMSagrp;

