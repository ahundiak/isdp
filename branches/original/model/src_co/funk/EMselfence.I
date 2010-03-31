/*
 DESCRIPTION

 Given an object, which may be a graphic group or graphics set, this
 routine will return a list of acceptable member objects.  It is intended that
 this be used to break down sets into curves, surfaces, and composites.
 This function is basically a superset of EMunwind_stupid_sets() which
 was written to decompose a fence into a set of processable objects.
 In order for an element to be accepted it must be in the yes list
 and not in the no list.

 INPUT ARGUMENTS

 yes_classes
  A list of classes which you will accept.
  Note that only w_count and p_classes is used, i.e. w_flags is ignored.
 no_classes
  A list of classes which you will not accept.
  Note that only w_count and p_classes is used, i.e. w_flags is ignored.
 set_object
  The object which you desire to be dissected.
 break_down_composites
  If TRUE then EMScomposite objects will be broken down into it's
  members.  This option is provided to support commands such as
  change rule line display and toggle polygon.  Ordinarly one
  should not change elements of a rigid composite.
 is_operation_readonly
  Are you just going to do read operations on the objects I return you.
  If so then I will dissect cells and other rigid IGE sets, if not
  then I will return you the rigid set objects.
 my_stupid_id
  Your id.  Used so that I can pretend I am you.

 OUTPUT ARGUMENTS

 number_of_objects
  Total count of objects returned.
 objects
  The objects themselves.
 msg
  Error return code.  The usual (1 & msg) should work fine.

 HISTORY

 05/20/91 : SS  : If a rigid-owner is about to be accepted and the option is
                  to locate only the topmost node in the ownership tree,
                  check if the rigid owner has any components. If none,
                  then ineligible.
 05/31/88 : rlw : Creation date
 */

class implementation GRvg;

#include "EMS.h"
#include "msdef.h"		/* MSSUCC, MSFAIL */
#include "OMmacros.h"		/* OM_BLOCK_MOVE() macro */
#include "grownerdef.h"
#include "emsdef.h"

extern GRclassid OPP_GRowner_class_id;

from GRowner import GRget_locate_properties, GRget_number_components;

IGRlong EMselective_fence(
 yes_classes,
 no_classes, 
 set_object,
 break_down_composites,
 is_operation_readonly,
 my_stupid_id,
 number_of_objects,
 objects,
 msg)

OM_S_CLASSLIST	*yes_classes;
OM_S_CLASSLIST	*no_classes;
struct   	GRlc_info *set_object;
IGRboolean	break_down_composites;
IGRboolean	is_operation_readonly;
OM_S_OBJID	my_stupid_id;
IGRlong  	*number_of_objects;
struct   	GRlc_info **objects;
IGRlong  	*msg;
{
 OMuword 	classid, yes_classid;
 IGRboolean	accepted;
 IGRlong	sts, msg_loc, i, j;
 IGRint         properties, count;
 GRobjid 	obj, os;
 extern		IGRlong EMunwind_stupid_sets();
/*
 * Initailize
 */
 *msg = MSSUCC;
 *objects = NULL;
 *number_of_objects = 0;
/*
 * Unwind the fence into a set of processable objects
 */
 sts = EMunwind_stupid_sets(
   set_object,
   break_down_composites,
   is_operation_readonly,
   my_stupid_id,
   number_of_objects,
   objects,
   msg);
  if ((! (1 & sts)) ||
      (*number_of_objects == 0)) goto wrapup;
/*
 * Weed out the bad fellows
 */
  for (i = 0; i < *number_of_objects; i++)
   {
    obj = (*objects)[i].located_obj.objid;
    os = (*objects)[i].located_obj.osnum;
    sts = om$get_classid(
      osnum = os, objid = obj,
      p_classid = &classid);
     if (! (1 & sts))
      {
       *msg = MSFAIL;
       goto wrapup;
      }
    accepted = FALSE;
    for (j = 0; (j < yes_classes->w_count) && (!accepted); j++)
     {
      sts = om$is_ancestry_valid(
        subclassid = classid, 
        superclassid = yes_classes->p_classes[j]);
       if (sts == OM_S_SUCCESS)
        {
         accepted = TRUE;
         yes_classid = yes_classes->p_classes[j];
        }
     } /* for (j = 0; j < yes_classes->w_count; j++) */
    if (accepted)
     {
      for (j = 0; (j < no_classes->w_count) && accepted; j++)
       {
        sts = om$is_ancestry_valid(
          subclassid = classid, 
          superclassid = no_classes->p_classes[j]);
         if (sts == OM_S_SUCCESS)
          accepted = FALSE;
       } /* for (j = 0; j < yes_classes->w_count; j++) */
     } /* if (accepted) */
    if (accepted)
     {
      if (! (break_down_composites || is_operation_readonly) &&
          om$is_ancestry_valid (subclassid = yes_classid,
           superclassid = OPP_GRowner_class_id) == OM_S_SUCCESS)
       {
        properties = NULL;
        om$send(msg = message GRowner.GRget_locate_properties(&msg_loc,
         &properties), senderid = my_stupid_id, targetid = obj, targetos = os);

        if (properties & GR_LC_RIGID)
         {
          count = MAXINT;
          om$send(msg = message GRowner.GRget_number_components(&msg_loc,
           &count), senderid = my_stupid_id, targetid = obj, targetos = os);
          if (!count)
            accepted = FALSE;
         }        
       }
     } /* if (accepted) */
    if (! accepted)
     {
      IGRlong	number_remaining;

      number_remaining = *number_of_objects - (i + 1);
      if (number_remaining)
       {
        OM_BLOCK_MOVE(
         &(*objects)[i + 1],
         &(*objects)[i],
         number_remaining * sizeof(struct GRlc_info));
       } /* if (number_remaining) */
      *number_of_objects = *number_of_objects - 1;
      if (*number_of_objects == 0)
       {
        free(*objects);
        *objects = NULL;
       } /* if (*number_of_objects == 0) */
      i--;					/* Stay on this entry */
     } /* if (! accepted) */
   } /* for (i = 0; i < *number_of_objects; i++) */
/*
 * eof
 */
wrapup:
 if (1 & *msg)
  return(TRUE);
 else
  {
   if (*objects)
    {
     free(*objects);
     *objects = NULL;
    }
   *number_of_objects = 0;
   return(FALSE);
  }
}

end implementation GRvg;
