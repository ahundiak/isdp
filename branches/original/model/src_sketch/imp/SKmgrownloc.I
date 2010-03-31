/*

Name
  SKmgr.GRlocate_owner

Abstract

Synopsis

Description

Return Value

Notes

Index

Keywords
  profile, locate

History
  08/23/93 : Rajiv Agrawal : Added check for externally constrained grounds for the
                             move command. Added doc header and some cleanup.

 */
class implementation SKmgr;

#include "lcdef.h"
#include "lc.h"
#include <string.h>
#include <alloca.h>
#include "emsdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

extern GRclassid OPP_SKasptgrnd_class_id;

method GRlocate_owner ( IGRlong *msg; 
                        struct GRlc_cvl *cvl;
                        struct GRlc_path *path; 
                        IGRint *path_position)
{
 OMuint			num_constrs, num_parents;
 int			i, stat_OM;
 unsigned long		save_owner_action;
 IGRboolean 		is_extern_constrained = FALSE;
 GRclassid 		cnst_class;
 OM_S_OBJECT_LINKAGE 	*constrs = NULL;
 OM_S_CHANSELECT 	to_constrs, to_father;
  
 if (cvl->attributes.obj_attr.owner_action & LC_MOVE_CMD)
 {
   /*
    * get all the constraints connected to the profile.
    */
    EMmake_chanselect ( SKmgr_to_constrs, &to_constrs );
    EMmake_chanselect ( NDfather_father, &to_father );
    stat_OM = om$get_channel_count ( objid = my_id, p_chanselect = &to_constrs,
                                     count = &num_constrs );
    if (num_constrs)
    {
      constrs = (OM_S_OBJECT_LINKAGE *) alloca ( num_constrs * sizeof (OM_S_OBJECT_LINKAGE));
      EMerr_hndlr ( !constrs, *msg, EMS_E_NoDynamicMemory , ret_end );
      stat_OM = om$get_channel_objects ( p_chanselect = &to_constrs, objid = my_id,
                                         list = constrs, size = num_constrs, 
                                         count = &num_constrs);
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );

      for (i=0; i<num_constrs && !is_extern_constrained; i++)
      {
        om$get_classid ( objid = constrs[i].S_objid, p_classid = &cnst_class );
        if (cnst_class == OPP_SKasptgrnd_class_id)
        {
          stat_OM = om$get_channel_count ( objid = constrs[i].S_objid, 
                                           p_chanselect = &to_father,
                                           count = &num_parents );
          if (num_parents)
            is_extern_constrained = TRUE;
        }
      }
    }
    /*
     * If the profile had assoc grnds constraints dependent on other objects,
     * do not locate the profile.
     */
    if (is_extern_constrained)
    {
      ex$message ( msgnumb = EMS_S_ExternallyConstrained);
      *msg = MSSUCC;
      stat_OM = OM_S_SUCCESS;
      goto ret_end;
    }
 }
   
 if (!strcmp(cvl->attributes.obj_attr.classes,"EMSrigid_comp"))
 {
  save_owner_action = cvl->attributes.obj_attr.owner_action;
  cvl->attributes.obj_attr.owner_action |= LC_RIGID_COMP;

  stat_OM = om$send (mode = OM_e_wrt_message,
                    msg = message GRowner.GRlocate_owner(msg,cvl,path,
                          path_position),
                    targetid = my_id);
  cvl->attributes.obj_attr.owner_action = save_owner_action;
 }
 else
 {
  stat_OM = om$send (mode = OM_e_wrt_message,
                    msg = message GRowner.GRlocate_owner(msg,cvl,path,
                          path_position),
                    targetid = my_id);
 }

ret_end:
 return (stat_OM);
}
end implementation SKmgr;

