/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This function creates a graphic group and adds the input objects
 to the group.  It is assumed that the input objects exist in
 the construction object space listed in the construct_list.  The
 graphic group is constructed in that object space.

 History

 11/11/87 : rlw : Creation date - (Just a shell)
 01/13/88 : rlw : Added the code to construct the graphic group
 */

class implementation Root;

#include "EMS.h"

//%safe
#include <math.h>
//%endsafe

#include "ems_m_inc.h"		/* Includes everything */

from GRvg import GRconstruct;
from GRowner import GRadd_components;

extern OMuword OPP_GRgrgrp_class_id;

IGRlong EFbuild_graphic_group(
 number_of_objects,
 objects,
 ids,
 construct_list,
 constructed_object,
 msg)

IGRlong		number_of_objects;
GRobjid		*objects;
struct		GRid *ids;
struct		GRvg_construct *construct_list;
GRobjid		*constructed_object;
IGRlong		*msg;

{
 OMuword	osnum;
 IGRlong	i, sts;
 struct		GRobj_env *obj_env;
/*
 * Initialize
 */
 *msg = MSSUCC;
 obj_env = NULL;
 *constructed_object = NULL;
 osnum = construct_list->env_info->md_id.osnum;
/*
 * Construct the graphic group
 */
 sts = om$construct(
   classid = OPP_GRgrgrp_class_id,
   msg = message GRvg.GRconstruct(
    construct_list),
   p_objid = constructed_object,
   osnum = osnum);
  if (! ( 1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }
/*
 * Build the argument list necessary
 * to add the elements to the graphic 
 * group.
 */
 obj_env = (struct GRobj_env *) malloc(
   number_of_objects * sizeof(struct GRobj_env));
  if (! obj_env)
   {
    *msg = MANOMEMORY;
    goto wrapup;
   }
 for (i = 0; i < number_of_objects; i++)
  {
   if (objects)
    obj_env[i].obj_id.objid = objects[i];
   else
    obj_env[i].obj_id.objid = ids[i].objid;
   obj_env[i].obj_id.osnum = osnum;
   obj_env[i].mod_env = *(construct_list->env_info);
  } /* for (i = 0; i < number_of_objects; i++) */
/*
 * Add the input objects to the graphic group
 */
 sts = om$send(
   msg = message GRowner.GRadd_components(
    msg,
    construct_list->env_info,
    (IGRint *)&number_of_objects,
    obj_env,
    NULL,
    NULL),
   targetid = *constructed_object,
   targetos = osnum,
   senderid = NULL_OBJID);
  if (! ( 1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }
/*
 * eof
 */
wrapup:
 if (obj_env) free(obj_env);
 if (1 & *msg)
  return(TRUE);
 else
  return(FALSE);
}

end implementation Root;
