#include "FImin.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"



int FIgrp_get_single_select (Form  form,
                             int   group_label,
                             int  *status)
{
   struct FIgroup_obj *group;

   group = (struct FIgroup_obj *) _FI_g_get_id ((struct FIform_obj *)form, group_label);

   if (! group)
	  return (FI_NO_SUCH_GROUP);

   *status = group->FIgroup.single_select;

   return (FI_SUCCESS);
}



int FIgrp_set_single_select_on (Form  form,
                                int   group_label)
{
   struct FIgroup_obj *group;

   group = (struct FIgroup_obj *) _FI_g_get_id ((struct FIform_obj *)form, group_label);

   if (! group)
	  return (FI_NO_SUCH_GROUP);

   group->FIgroup.single_select = TRUE;

   return (FI_SUCCESS);
}



int FIgrp_set_single_select_off (Form  form,
                                 int   group_label)
{
   struct FIgroup_obj *group;

   group = (struct FIgroup_obj *) _FI_g_get_id ((struct FIform_obj *)form, group_label);

   if (! group)
	  return (FI_NO_SUCH_GROUP);

   group->FIgroup.single_select = FALSE;

   return (FI_SUCCESS);
}


/* This function adds the GROUP gadget to the specified group */
/* removing it from its current group. */
/* If this function is invoked on a non-group gadget, */
/* then nothing happens. */
/* */
/* NOTE: DO NOT call this from FIg_new(); */
/* call _FI_g_add_to_group instead */


int FIgrp_add_to_group (Form  form,
                        int   group_gadget_label,
                        int   to_group_label)
{
   struct FIgadget_obj *gadget;

   /*** get the group gadget's id ***/
   gadget = _FI_g_get_id ((struct FIform_obj *)form, group_gadget_label);

   /*** it's not a valid group gadget ***/
   if (! gadget || gadget->FIgadget.type != FI_GROUP)
	  return (FI_NO_SUCH_GROUP);

   _FI_g_add_to_group (gadget, to_group_label, 1);

   return (FI_SUCCESS);
}



/* FIgrp_get_pass - get group's "pass on" flag value */
/* -------------------------------------------------------------- */
/* This sets pass_status to TRUE if the group will pass on */
/* functions that are invoked on it, or FALSE if the group */
/* will NOT invoke functions on its gadgets when that function */
/* is invoked on the group. */
/* If group_label is not a valid group, pass_status is set to -1. */


int FIgrp_get_pass (Form  form,
                    int   group_label,
                    int  *pass_status)
{
   struct FIgroup_obj *group;

   group = (struct FIgroup_obj *) _FI_g_get_id ((struct FIform_obj *)form, group_label);

   /*** if group_label is not a valid group, return ***/
   if (! group || group->FIgadget.type != FI_GROUP)
   {
	  return (FI_NO_SUCH_GROUP);
   }

   if (group->FIgroup.dont_pass_on)
	  *pass_status = FALSE;
   else
	  *pass_status = TRUE;

   return (FI_SUCCESS);
}



/* FIgrp_set_pass_on - set group's "pass on" flag value to ON */
/* -------------------------------------------------------------- */
/* This sets group's "pass on" flag to TRUE, making it pass on */
/* functions that are invoked on it to all the gadgets within */
/* the group. */


int FIgrp_set_pass_on (Form  form,
                       int   group_label)
{
   struct FIgroup_obj *group;

   group = (struct FIgroup_obj *) _FI_g_get_id ((struct FIform_obj *)form, group_label);

   /*** if group_label is not a valid group, return ***/
   if (! group || group->FIgadget.type != FI_GROUP)
   {
	  return (FI_NO_SUCH_GROUP);
   }

   /*** actually set the group's pass on flag ***/
   group->FIgroup.dont_pass_on = 0;

   return (FI_SUCCESS);
}


/* FIgrp_set_pass_off - set group's "pass on" flag value to OFF */
/* -------------------------------------------------------------- */
/* This sets group's "pass on" flag to FALSE, preventing it from */
/* passing on functions that are invoked on it to all the */
/* gadgets within the group. */


int FIgrp_set_pass_off (Form  form,
                        int   group_label)
{
   struct FIgroup_obj *group;

   group = (struct FIgroup_obj *) _FI_g_get_id ((struct FIform_obj *)form, group_label);

   /*** if group_label is not a valid group, return ***/
   if (! group || group->FIgadget.type != FI_GROUP)
   {
	  return (FI_NO_SUCH_GROUP);
   }

   /*** actually set the group's pass on flag ***/
   group->FIgroup.dont_pass_on = 1;

   return (FI_SUCCESS);
}



/*** delete the group object, and put all its gadgets back into ***/
/*** the forms group w/o deleting them. ***/


int FIgrp_delete (Form  form,
                  int   group_label)
{
   struct FIgroup_obj *group;

   /*** get the group ptr ***/

   group = (struct FIgroup_obj *) _FI_g_get_id ((struct FIform_obj *)form, group_label);

   /*** it's not a valid group gadget ***/
   if ((! group) || (group->FIgadget.type != FI_GROUP))
	  return (FI_NO_SUCH_GROUP);

   return (_FI_grp_delete (group));
}



int FIgrp_callback (Form   form,
                    int    group_label,
                    int  (*callback_routine) (),
                    int    user_arg)
{
   struct FIgroup_obj *group;
   int ii;

   /*** get the group ptr ***/

   group = (struct FIgroup_obj *) _FI_g_get_id ((struct FIform_obj *)form, group_label);

   /*** it's not a valid group gadget ***/

   if ((! group) || (group->FIgadget.type != FI_GROUP))
	  return (FI_NO_SUCH_GROUP);

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
	  struct FIgadget_obj *gadget = group->FIgroup.gadgets[ii];

	  if (! gadget)
		 continue;

	  if (gadget->FIgadget.type == FI_GROUP)
		 FIgrp_callback (form, gadget->FIgadget.label, callback_routine, user_arg);
	  else
		 callback_routine (form, gadget->FIgadget.label, user_arg);

   }

   return (FI_SUCCESS);
}


