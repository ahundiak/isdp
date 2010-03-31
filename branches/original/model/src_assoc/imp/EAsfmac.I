class implementation EMAsurface;

#include "nddef.h" /* For ND_EXTERN */
#include "ndmacros.h"

extern OMuword OPP_ASsourcein_class_id, OPP_expression_class_id;
extern OMuword OPP_SKexplicit_class_id;
extern OMuword OPP_GAcurve_class_id, OPP_EMSpointer_class_id;
extern OMuword OPP_EMScnstr_class_id, OPP_DMroot_class_id;

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
 pp : 08/21/91 : Creation
*********************************************************************** */
{
 IGRlong status;
 struct GRid my_grid, activeid;

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

 status = om$send (msg = message EMSsurface.EMgetactiveid (msg,
                         &activeid, NULL),
                   targetid = my_id);
 EMerr_hndlr (!(1&status), *msg, EMS_E_Fail, wrapup);
 
 if (activeid.objid != my_id)
 {
   if (selected_size > (*selected_nb))
   {
    selected_obj[*selected_nb].objid = activeid.objid;
    selected_obj[*selected_nb].osnum = OM_Gw_current_OS;
   }
   ++(*selected_nb);
   return (OM_S_SUCCESS);
 }

 EFadd_to_copy_list(msg, my_grid, info, selected_size, selected_nb,
                    select_type, selected_obj);
 EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, wrapup);

wrapup:
 EMWRAPUP (*msg, status, "In EMAsurface: NDselect_copy method error");
 return (status);
}

method ACbecome_macro(IGRlong *msg; 
                      IGRint position;
		      struct GRmd_env *md_env)

/* ***************************************************************************
Description 
 If the surface is rigidly owned, and the position of this element in
 the graph is external, indicate that this is not a valid for macro
 creation. This should never happen, under normal circumstances, and has
 been done to make sure nothing slips through the cracks.

Notes
 Upon exit the completion code will be:
  ND_DROP_MAC : If this is valid for drop macro placement.
  ND_INVAL_MAC : Otherwise
 
History
 Creation : pp : 08/21/91
*************************************************************************** */
{
 IGRint loc_msg;
 IGRlong status;
 IGRboolean invalid_macro = FALSE;
 extern OMuword OPP_EMSparamvl_class_id;

 loc_msg = MSSUCC;
 status = OM_S_SUCCESS;

 *msg = ND_DROP_MAC | ND_CONS_MAC ;

 if ((position & ND_EXTERN) &&
     (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP))
  invalid_macro = TRUE;
 else if (position & ND_ROOT)
 {
  struct GRid *grid_ptr, *cur_ptr;
  IGRint ret_count, comp_count,i;
  OM_S_CHANSELECT to_components;

  status = om$send (msg = message NDnode.NDget_objects(ND_ROOT | ND_IN_BUF,
                         NULL,0,&grid_ptr,0,MAXINT, &ret_count),
                   targetid = my_id);
  EMerr_hndlr(!(1&status), loc_msg, MSFAIL, wrapup);

  status = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_components);
  if (!(1&status)) goto wrapup;

  for (i=0;i<ret_count;i++)
  {
    cur_ptr = &grid_ptr[i];
/*
 * See if my parents have dimensional handles. If so I cannot be a root
 * and be a part of the macro since I am closely tied with my dimensional
 * handles (theoretical rigid ownership).
 */
   if (EFisAncestryValid(&loc_msg, cur_ptr->objid, 
                        cur_ptr->osnum,
                        OPP_EMSparamvl_class_id, FALSE))
   {
    status = om$get_channel_count(objid = cur_ptr->objid,
                                  osnum = cur_ptr->osnum,
                                  p_chanselect = &to_components,
                                  count = (OMuint *)&comp_count);
    if (!(1&status)) goto wrapup;

    if (comp_count != 1)
     continue;
    else
    {
      invalid_macro = TRUE;
      goto wrapup;
    }
   }
  }

  if (!invalid_macro)
  {
   struct GRid activeid;

   status = om$send (msg = message EMSsurface.EMgetactiveid (
                         (IGRlong *)&loc_msg,
                         &activeid, NULL),
                   targetid = my_id);
   EMerr_hndlr (!(1&status&loc_msg), *msg, EMS_E_Fail, wrapup);

/*
 * This means that I am a becoming a template for the purposes of 
 * creation of a feature. In this case, I should only be valid for
 * a drop macro.
 */ 
   if (activeid.objid != my_id)
     *msg = ND_DROP_MAC;

/* end pp 07/22/92 */
    
  }
 }

wrapup:
 if (!(1&status&loc_msg)) invalid_macro = TRUE;

 if (invalid_macro) *msg = ND_INVAL_MAC;


 return (OM_S_SUCCESS);
}

end implementation EMAsurface;

