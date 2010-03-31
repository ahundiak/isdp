class implementation EMSassoc;

#include "EMSopt.h"
#include "EMSasmacros.h"
#include "GRascopy.h"
#include "EMpattern.h"

from EMSdpr import EMmake_primitive1;
from EMSsurface import EMgetactiveid, EMmake_active_state;
from EMSpatfea  import EMcreate_pattern_elements ;

extern OMuword OPP_EMSsurface_class_id,
               OPP_EMSdpr_class_id,
               OPP_EMSsolid_class_id;

IGRint EFpattern(EMmsg, options, old_objid, new_objid,num_parents,
		 parent_info, recomp_info, construct_list, mod_new_id)
     IGRlong *EMmsg;
     IGRuint options;
     GRobjid old_objid;
     GRobjid new_objid;
     IGRint num_parents;
     IGRchar *parent_info;
     IGRchar *recomp_info;
     struct GRvg_construct *construct_list;
     GRobjid *mod_new_id;
/*
  Description
  This is the recomputation/placement function that implements the associative
  pattern.

  Arguments
   These are standard for any recomputation/placement function.

  Notes
   Upon exit the completion code will be one of the following:
   EMS_S_Success : If all goes well
   EMS_E_Fail    : If there is failure of sorts.

  WARNING
   The name of this function should not change ever since the same is stored
   in the instance data of objects. If we have to change the name of the object
   then we need to provide a conversion mechanism to the new name.

  History:
    Creation : PP : 07/29/93
 ********************************************************************** */
{
  OMuword constr_os;
  IGRlong status;
  IGRint i,num_copies;
  union EMSparent_info *roots = NULL;
  IGRuint root_count;
  IGRuint root_type[3];
  GRobjid new_copied_id;
  struct GRid *pattern_GRid;
  struct GRid master_GRid, mod_new_GRid;
  OM_S_OBJID save_creator;
  extern OM_S_OBJID current_creator;

  *EMmsg = EMS_S_Success;
  status = OM_S_SUCCESS;

  root_count = num_parents;

  roots = (union EMSparent_info *)stackalloc(root_count*
				  sizeof(union EMSparent_info));
  EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

  if (root_count > 1)
    {
      *EMmsg = EMS_E_InvalidArg;
      goto wrapup;
    }

  root_type[0] = EMSlcinfo;

  /*
   * Message which gets the real parents of the object.
   */

  status = om$send (msg = message EMSassoc.EMget_parent_info(
					       EMmsg,NULL,
					       root_count, 
					       parent_info, 
					       root_type,
					       roots),
		    senderid = new_objid,
		    targetid = new_objid);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);

  /*
   * pattern_GRid is the objid of the pattern.
   */
  
  pattern_GRid = &roots[0].lc_info.located_obj;

  status = 
  om$send (msg = message EMSpatfea.EMcreate_pattern_elements(EMmsg,
				   &num_copies,
				   (struct GRid **) NULL,
				   &roots[0].lc_info.module_info,
				   &master_GRid),
	   senderid = pattern_GRid->objid,
	   targetid = pattern_GRid->objid,
	   targetos = pattern_GRid->osnum);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  if (num_copies)
    {
      struct GRid *copy_GRid = NULL;

      copy_GRid = (struct GRid *) alloca(sizeof (struct GRid) * num_copies);
      EMerr_hndlr(!copy_GRid, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

      status = 
      om$send (msg = message EMSpatfea.EMcreate_pattern_elements(EMmsg,
				       &num_copies,
				       &copy_GRid,
				       construct_list->env_info,
				       &master_GRid),
	       senderid = pattern_GRid->objid,
	       targetid = pattern_GRid->objid,
	       targetos = pattern_GRid->osnum);
      fe$status();
      EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 
      constr_os = construct_list->env_info->md_id.osnum;


      if (EFisAncestryValid(EMmsg, master_GRid.objid,
			    master_GRid.osnum, OPP_EMSsolid_class_id, FALSE))
	{
	  status = om$change_class(objid = new_objid,
				   osnum = constr_os,
				   sd_override = OM_K_change_class_sd_override,
				   classname = "EMSsolid");
	  fe$status();
	  if (!(1&status)) goto wrapup;
	}
      else if (EFisAncestryValid(EMmsg, master_GRid.objid, master_GRid.osnum,
				 OPP_EMSsurface_class_id, FALSE))
	{
	  status = om$change_class(objid = new_objid,
				   osnum = constr_os,
				   sd_override = OM_K_change_class_sd_override,
				   classname = "EMScompsurf");
	  fe$status();
	  if (!(1&status)) goto wrapup;
	}
      else 
	{
	  status = om$change_class(objid = new_objid,
				   osnum = constr_os,
				   sd_override = OM_K_change_class_sd_override,
				   classname = "EMSagrp");
	  fe$status();
	  if (!(1&status)) goto wrapup;
	}
      *mod_new_id = new_objid;
      mod_new_GRid.objid = *mod_new_id;
      mod_new_GRid.osnum = constr_os;
	  
      for (i=0;i<num_copies;i++)
	{
	  new_copied_id = copy_GRid[i].objid;

	  if (EFisAncestryValid(EMmsg, new_copied_id,
				constr_os, OPP_EMSdpr_class_id, FALSE))
	    {
	      struct GRid new_GRid;
	      save_creator = current_creator;
	      current_creator = NULL_OBJID;
	      status = 
	      om$send (msg = message EMSdpr.EMmake_primitive1(EMmsg,
				  construct_list->env_info, &new_GRid),
			   senderid = new_objid,
			   targetid = new_copied_id,
			   targetos = constr_os);
	      current_creator = save_creator;
	      fe$status();
	      EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	      new_copied_id = new_GRid.objid;
	    }

	  if (EFisAncestryValid(EMmsg, new_copied_id, constr_os, 
				OPP_EMSsolid_class_id, FALSE))
	    {
	      status = 
	      om$change_class(objid = new_copied_id,
			      osnum = constr_os,
			      sd_override = OM_K_change_class_sd_override,
			      classname = "EMScompsurf");
	      fe$status();
	      if (!(1&status)) goto wrapup;
	    }

	  status = om$send (msg = message GRconnector.GRrigidconn(EMmsg,
				&mod_new_GRid, (IGRlong*) &num_copies),
				senderid = *mod_new_id,
				targetid = new_copied_id,
				targetos = constr_os);
	  fe$status();
	  EMerr_hndlr(!(1&status& *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
	}
    }

 wrapup:
  if (!(1&status&*EMmsg)) 
    {
      IGRlong l_msg;
      if (mod_new_GRid.objid != NULL_OBJID)
	status = om$send (msg = message GRgraphics.GRdelete(&l_msg,
			       	    construct_list->env_info),
			  senderid = NULL_OBJID,
			  targetid = mod_new_GRid.objid,
			  targetos = mod_new_GRid.osnum);
      fe$status();
      *mod_new_id = NULL_OBJID;
    }

  if (!(1&status&*EMmsg))
    {
      *mod_new_id = NULL_OBJID;
      return (status);
    }
  else return(OM_S_SUCCESS);
}

end implementation EMSassoc;




