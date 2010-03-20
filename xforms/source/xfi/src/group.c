#include "FImin.h"
#include "FIgroup.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"


/* This function simply passes the call down sent in via */
/* function_ptr down the group. */


int _FI_grp_count (struct FIgroup_obj *group)
{
   int ii;
   int count = 0;

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
	  if (group->FIgroup.gadgets[ii])
	    {
		 count++;
	    }
   }

   return (count);
}


void _FI_grp_pass_on_double (struct FIgadget_obj *gadget,
                             int (*function_ptr) (),
                             double arg1)
{
   struct FIgroup_obj *group;
   int ii;

   /* determine if the group is the form group or another one */

   if (gadget->FIgadget.label == FI_FORM_GROUP)
    {
	  group = (gadget->FIgadget.form)->group;
    }
   else
    {
	  group = (struct FIgroup_obj *) gadget;
    }


   /* if the pass_on flag is not set, then */
   /* don't send it to each gadget in the grp */

   if (group->FIgroup.dont_pass_on)
     {
	  return;
     }

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
	  if (group->FIgroup.gadgets[ii])
	  {
		 function_ptr (gadget->FIgadget.form, (int) (((struct FIgadget_obj *) group->FIgroup.gadgets[ii])->FIgadget.label), (double) arg1);
	  }
   }
}



void _FI_grp_pass_on_float (struct FIgadget_obj *gadget,
                            int (*function_ptr) (),
                            float arg1)
{
   struct FIgroup_obj *group;
   int ii;

   /* determine if the group is the form group or another one */

   if (gadget->FIgadget.label == FI_FORM_GROUP)
   {
	  group = (gadget->FIgadget.form)->group;
   }
   else
   {
	  group = (struct FIgroup_obj *) gadget;
   }


   /* if the pass_on flag is not set, then */
   /* don't send it to each gadget in the grp */

   if (group->FIgroup.dont_pass_on)
     {
	  return;
     }

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
	  if (group->FIgroup.gadgets[ii])
	  {
		 function_ptr (gadget->FIgadget.form, (int) (((struct FIgadget_obj *) group->FIgroup.gadgets[ii])->FIgadget.label), (float)arg1);
	  }
   }
}



void _FI_grp_pass_on_int (struct FIgadget_obj *gadget,
                          int (*function_ptr) (),
                          int arg1,
                          int arg2)
{
   struct FIgroup_obj *group;
   int ii;

   /* determine if the group is the form group or another one */

   if (gadget->FIgadget.label == FI_FORM_GROUP)
     {
	  group = gadget->FIgadget.form->group;
     }
   else
     {
	  group = (struct FIgroup_obj *) gadget;
     }


   /* if the pass_on flag is not set, then */
   /* don't send it to each gadget in the grp */

   if (group->FIgroup.dont_pass_on)
     {
	  return;
     }

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
	  if (group->FIgroup.gadgets[ii])
	  {
		 function_ptr (gadget->FIgadget.form, (int) (((struct FIgadget_obj *) group->FIgroup.gadgets[ii])->FIgadget.label), (int)arg1, (int)arg2);
	  }
   }
}


void _FI_grp_pass_on_int_float (struct FIgadget_obj *gadget,
                                int (*function_ptr) (),
                                int arg1,
                                float arg2)
{
   struct FIgroup_obj *group;
   int ii;

   /* determine if the group is the form group or another one */

   if (gadget->FIgadget.label == FI_FORM_GROUP)
   {
	  group = (gadget->FIgadget.form)->group;
   }
   else
   {
	  group = (struct FIgroup_obj *) gadget;
   }


   /* if the pass_on flag is not set, then */
   /* don't send it to each gadget in the grp */

   if (group->FIgroup.dont_pass_on)
     {
	  return;
     }

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
	  if (group->FIgroup.gadgets[ii])
	  {
		 function_ptr (gadget->FIgadget.form, (int) (((struct FIgadget_obj *) group->FIgroup.gadgets[ii])->FIgadget.label), (int)arg1, (float)arg2);
	  }
   }
}


/* dmb:10/10/92:Added new function for ANSI */
void _FI_grp_pass_on_int_double (struct FIgadget_obj *gadget,
                                int (*function_ptr) (),
                                int arg1,
                                double arg2)
{
   struct FIgroup_obj *group;
   int ii;

   /* determine if the group is the form group or another one */

   if (gadget->FIgadget.label == FI_FORM_GROUP)
   {
	  group = (gadget->FIgadget.form)->group;
   }
   else
   {
	  group = (struct FIgroup_obj *) gadget;
   }


   /* if the pass_on flag is not set, then */
   /* don't send it to each gadget in the grp */

   if (group->FIgroup.dont_pass_on)
     {
	  return;
     }

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
	  if (group->FIgroup.gadgets[ii])
	  {
		 function_ptr (gadget->FIgadget.form, (int) (((struct FIgadget_obj *) group->FIgroup.gadgets[ii])->FIgadget.label), (int)arg1, (double)arg2);
	  }
   }
}



/* Controls keeping only one item active within the group */

void _FI_grp_notify_selected (struct FIgadget_obj *gadget)
{
   struct FIgroup_obj *group = gadget->FIgadget.group;

   if ( group && group->FIgroup.single_select && (gadget->FIgadget.type != FI_GROUP))
   {
	  int ii;
	  Window window = XWINDOW(gadget);

	/*** Tell everyone in the group to unselected	***/
	/*** except the current selected one		***/

	  for (ii = 0; ii < (int)group->FIgroup.size; ii++)
	  {
         /*** skip entries that aren't valid ***/

		 if (! group->FIgroup.gadgets[ii])
		   {
			continue;
		   }

		 if (group->FIgroup.gadgets[ii]!= gadget)
		 {
			if (group->FIgroup.gadgets[ii]->FIgadget.value == 1.0)
			{
			   group->FIgroup.gadgets[ii]->FIgadget.value = 0.0;

               /* Pass on data to directed gadget */

			   sprintf (FI_data, "%lf", gadget->FIgadget.value);

			   _FI_g_pass_data (gadget);

			   if ((IT_IS_DISPLAYED(group->FIgroup.gadgets[ii])) && (window != None))
			   {
				  _FI_g_display (group->FIgroup.gadgets[ii], window);
			   }
			}
		 }
	  }
   }
}



void _FI_grp_pass_on_id_double (struct FIgadget_obj *gadget,
                                int (*function_ptr) (),
                                double arg1,
                                double arg2)
{
   struct FIgroup_obj *group;
   int ii;

   /* determine if the group is the form group or another one */

   if (gadget->FIgadget.label == FI_FORM_GROUP)
     {
	  group = (gadget->FIgadget.form)->group;
     }
   else
     {
	  group = (struct FIgroup_obj *) gadget;
     }


   /* if the pass_on flag is not set, then */
   /* don't send it to each gadget in the grp */

   if (group->FIgroup.dont_pass_on)
     {
	  return;
     }

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
     if (group->FIgroup.gadgets[ii])
     {
	 function_ptr (group->FIgroup.gadgets[ii], (double)arg1, (double)arg2);
     }
   }
}



void _FI_grp_pass_on_id_double_always (struct FIgadget_obj *gadget,
                                       int (*function_ptr) (),
                                       double arg1,
                                       double arg2)
{
   struct FIgroup_obj *group;
   int ii;

   /* determine if the group is the form group or another one */

   if (gadget->FIgadget.label == FI_FORM_GROUP)
     {
	  group = (gadget->FIgadget.form)->group;
     }
   else
     {
	  group = (struct FIgroup_obj *) gadget;
     }


   /* if the pass_on flag is not set, then */
   /* don't send it to each gadget in the grp */

  /***********************************
   if (group->FIgroup.dont_pass_on)
     {
	  return;
     }
   **********************************/

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
     if (group->FIgroup.gadgets[ii])
     {
	 function_ptr (group->FIgroup.gadgets[ii], (double)arg1, (double)arg2);
     }
   }
}



void _FI_grp_pass_on_id_float (struct FIgadget_obj *gadget,
                               int (*function_ptr) (),
                               float arg1,
                               float arg2)
{
   struct FIgroup_obj *group;
   int ii;

   /* determine if the group is the form group or another one */

   if (gadget->FIgadget.label == FI_FORM_GROUP)
     {
	  group = (gadget->FIgadget.form)->group;
     }
   else
     {
	  group = (struct FIgroup_obj *) gadget;
     }


   /* if the pass_on flag is not set, then */
   /* don't send it to each gadget in the grp */

   if (group->FIgroup.dont_pass_on)
     {
	  return;
     }

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
     if (group->FIgroup.gadgets[ii])
     {
	 function_ptr (group->FIgroup.gadgets[ii], (float)arg1, (float)arg2);
     }
   }
}



void _FI_grp_pass_on_id_float_always (struct FIgadget_obj *gadget,
                                      int (*function_ptr) (),
                                      float arg1,
                                      float arg2)
{
   struct FIgroup_obj *group;
   int ii;

   /* determine if the group is the form group or another one */

   if (gadget->FIgadget.label == FI_FORM_GROUP)
     {
	  group = (gadget->FIgadget.form)->group;
     }
   else
     {
	  group = (struct FIgroup_obj *) gadget;
     }


   /* if the pass_on flag is not set, then */
   /* don't send it to each gadget in the grp */

/**************************************
   if (group->FIgroup.dont_pass_on)
     {
	  return;
     }
***************************************/

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
     if (group->FIgroup.gadgets[ii])
     {
	 function_ptr (group->FIgroup.gadgets[ii], (float)arg1, (float)arg2);
     }
   }
}



int _FI_grp_pass_on_id_int (struct FIgadget_obj *gadget,
                            int (*function_ptr) (),
                            int arg1,
                            int arg2)
{
   struct FIgroup_obj *group;
   int ii;

   /* determine if the group is the form group or another one */

   if (gadget->FIgadget.label == FI_FORM_GROUP)
     {
	  group = (gadget->FIgadget.form)->group;
     }
   else
     {
	  group = (struct FIgroup_obj *) gadget;
     }


   /* if the pass_on flag is not set, then */
   /* don't send it to each gadget in the grp */

   if (group->FIgroup.dont_pass_on)
     {
	  return(FI_SUCCESS);
     }

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
    if (group->FIgroup.gadgets[ii])
     {
	 function_ptr (group->FIgroup.gadgets[ii], (int)arg1, (int)arg2);
     }
   }
   return (FI_SUCCESS);	/* dmb:03/27/91:Added */
}


/************************/
/* */
/* Added 4/26/90 GMD */
/* */
/************************/

void _FI_grp_pass_on_id_int_always (struct FIgadget_obj *gadget,
                                    int (*function_ptr) (),
                                    int arg1,
                                    int arg2)
{
   struct FIgroup_obj *group;
   int ii;

   /* determine if the group is the form group or another one */

   if (gadget->FIgadget.label == FI_FORM_GROUP)
   {
	  group = (gadget->FIgadget.form)->group;
   }
   else
   {
	  group = (struct FIgroup_obj *) gadget;
   }


   /*** Send message to all members of the group, regardless ***/
   /*** of whether the pass-on flag is set or not. ***/

   /**********************************
   if(group->FIgroup.dont_pass_on)
   return;
   **********************************/

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
	  if (group->FIgroup.gadgets[ii])
	  {
		 function_ptr (group->FIgroup.gadgets[ii], (int)arg1, (int)arg2);
	  }
   }
}


int _FI_grp_alloc (struct FIgroup_obj *group,
                   int alloc_size)
{
   if (alloc_size == 0)	/******* JAJ:01/24/91 ****/
   {
	  return (FI_SUCCESS);
   }

   if (group->FIgroup.size)
   {	/* there's already things in the array, so add to it */

      /* get space for the gadget pointers */

	  group->FIgroup.gadgets = (struct FIgadget_obj **) realloc (group->FIgroup.gadgets, (int) (group->FIgroup.size + alloc_size) * sizeof (struct FIgadget_obj *));

	  if (! group->FIgroup.gadgets)
	     {
		 return (FI_NO_MEMORY);
	     }

      /* set the just added memory to 0's */

/*	  memset (&group->FIgroup.gadgets[group->FIgroup.size], 0, alloc_size * sizeof (Gadget)); dmb:04/15/91:exp */
	  memset (&group->FIgroup.gadgets[group->FIgroup.size], 0, alloc_size * sizeof (struct FIgadget_obj *));
      /* adjust the number of elements in these arrays */

	  group->FIgroup.size += alloc_size;
   }
   else	/* it's a whole new group */
   {
      /* get space for the gadget pointers */

	  group->FIgroup.gadgets = (struct FIgadget_obj **) calloc (alloc_size, sizeof (struct FIgadget_obj *));

	  if (! group->FIgroup.gadgets)
	     {
		 return (FI_NO_MEMORY);
	     }

      /* set the number of elements in these arrays */
	  group->FIgroup.size = alloc_size;
   }
   return (FI_SUCCESS);
}



/*** Delete the group gadget, and add its member gadgets back ***/
/*** to the form's group w/o deleting them. ***/

int _FI_grp_delete (struct FIgroup_obj *group)
{
   int slot;

   /*** add the gadgets within the group back to the Form's Group ***/

   _FI_g_add_to_group ( (struct FIgadget_obj *) group, FI_FORM_GROUP, 0);

   /*** deallocate the group's memory ***/

   if (group->FIgroup.gadgets)
     {
	  _FI_s_free ( (char *) group->FIgroup.gadgets);
     }

   /* find the slot that group is in */

   slot = _FI_grp_get_slot (group->FIgadget.group, (struct FIgadget_obj *) group);

   /* Free this location */

   if (slot > -1)
     {
	  group->FIgadget.group->FIgroup.gadgets[slot]= 0;
     }

   _FI_s_free ( (char *) group);

   return (FI_SUCCESS);
}



/** return the next available(not in use)array slot index # **/
/** in the group's gadgets[] array **/

int _FI_grp_get_next_slot (struct FIgroup_obj *group)
{
   int ii;

   for (ii = group->FIgroup.begin_slot; ii < (int)group->FIgroup.size; ii++)
   {
	  if (! group->FIgroup.gadgets[ii])
	  {
		 group->FIgroup.begin_slot = ii;

		 return (ii);
	  }
   }

   /*** save the old number of gadgets ***/
   ii = group->FIgroup.size;

   group->FIgroup.begin_slot = ii;

   /** if this point is reached, then there are no free slots, **/
   /** so make some **/

   _FI_grp_alloc (group, FI_GRP_ALLOC_SIZE);

   return (ii);
}


int _FI_grp_get_slot (struct FIgroup_obj *group,
                      struct FIgadget_obj *gadget)
{
   int ii;

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
	  if (! group->FIgroup.gadgets[ii])
	     {
		 continue;
	     }

	  if (group->FIgroup.gadgets[ii]== gadget)
	  {
		 return (ii);
	  }
   }
   /* Return a -1 for no such gadget found */

   return (-1);
}


/* This function is used to convert the label within a group to a */
/* gadget id. This function returns NULL if no gadget is found */

struct FIgadget_obj *_FI_g_get_id_from_group (struct FIgroup_obj *group,
                                              int             gadget_label)
{
   struct FIgadget_obj *temp_gadget;
   struct FIgadget_obj *search_gadget;
   int ii;

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
      /*** skip entries that aren't valid ***/

	  search_gadget = group->FIgroup.gadgets[ii];

	  if (! search_gadget)
	     {
		 continue;
	     }

	  if (search_gadget->FIgadget.label == gadget_label)
	  {
		 return (search_gadget);
	  }

      /*** recursively look in any group gadgets ***/

	  if ((search_gadget->FIgadget.type == FI_GROUP) || (search_gadget->FIgadget.type == FI_MULTI_COL))
	  {
		 temp_gadget = _FI_g_get_id_from_group ( (struct FIgroup_obj *) search_gadget, gadget_label);

		 if (temp_gadget)
		     {
			return (temp_gadget);
		     }
	  }
   }

   return (NULL);
}




/* This function returns TRUE if the given label is in use */
/* somewhere within the specified group */

int _FI_grp_is_label_used_within_group (struct FIgroup_obj *group,
                                        int label)
{
   /* see if the group's label itself matches the desired label */
   if (group->FIgadget.label == label)
     {
	  return TRUE;
     }

   if (_FI_g_get_id_from_group (group, label))
     {
	  return TRUE;
     }
   else
     {
	  return FALSE;
     }
}



void _FI_grp_change_size (struct FIgroup_obj *group,
                          struct FIgadget_obj *gadget)
{
   int xlo, ylo, xhi, yhi;
 
   /*** if the gadget is a group, have it calculate its size ***/
   if (gadget->FIgadget.type == FI_GROUP)	/*** JAJ:07/11/90 ***/
   {
	  _FI_grp_calculate_size ( (struct FIgroup_obj *) gadget);
   }

   xlo = gadget->FIgadget.xlo;
   ylo = gadget->FIgadget.ylo;
   xhi = gadget->FIgadget.xhi;
   yhi = gadget->FIgadget.yhi;

	/**************************************************/
	/*** If the group gadget is empty, then 	***/
	/*** don't let it affect the size of this group	***/
	/******************************* JAJ:01/09/92	***/
  if ( gadget->FIgadget.type == FI_GROUP )
    {
      if ( ( xlo == 0 ) && ( xhi == 0 ) &&
	   ( ylo == 0 ) && ( yhi == 0 )  )
	{
	  return ;
	}
    }

   if (xlo < group->FIgadget.xlo)
   {
	  group->FIgadget.xlo = xlo;

	  if (group->FIgadget.type == FI_MULTI_COL)
	     {
		 group->FIgadget.xlo -= 12;
	     }
   }

   if (ylo < group->FIgadget.ylo)
   {
	  group->FIgadget.ylo = ylo;

	  if (group->FIgadget.type == FI_MULTI_COL)
	     {
		 group->FIgadget.ylo -= 2;
	     }
   }

   if (xhi > group->FIgadget.xhi)
     {
	  group->FIgadget.xhi = xhi;
     }

   if (yhi > group->FIgadget.yhi)
   {
	  group->FIgadget.yhi = yhi;

	  if (group->FIgadget.type == FI_MULTI_COL)
	     {
		 group->FIgadget.yhi += 2;
	     }
   }
}


void _FI_grp_calculate_size (struct FIgroup_obj *group)
{
   int ii;

   /* Set to largest and smallest values possible */

   group->FIgadget.xlo = MAX_GROUP_WIDTH;
   group->FIgadget.ylo = MAX_GROUP_HEIGHT;
   group->FIgadget.xhi = 0;
   group->FIgadget.yhi = 0;

   for (ii = 0; ii < (int)group->FIgroup.size; ii++)
   {
    if (group->FIgroup.gadgets[ii])
     {
	 _FI_grp_change_size (group, group->FIgroup.gadgets[ii]);
     }
   }

   /* If this group is in a group then re-calculate the grp's group */

   /* DO NOT DO. This will be done when they call FIg_get_location().
    if(group->FIgadget.group)
    _FI_grp_calculate_size(group->FIgadget.group); 
   ******************************************************************/

   if (group->FIgadget.xlo == MAX_GROUP_WIDTH)	/*** JAJ:07/11/90 ***/
     {
	  group->FIgadget.xlo = 0;
     }

   if (group->FIgadget.ylo == MAX_GROUP_HEIGHT)
     {
	  group->FIgadget.ylo = 0;
     }
}



/* This function adds the gadget to the specified group */
/* removing it from its current group(if any, since this */
/* is called by FIg_new to add the new gadget to FORM_GROUP). */
/* If this function is invoked on a group gadget, the members of */
/* the group are added to the new group and removed from that */
/* group. */
/* NOTE: Call this from FIg_new()instead of FIg_add_to_group */

int _FI_g_add_to_group (struct FIgadget_obj *gadget,
                        int group_label,
                        int add_group_itself)
{
   struct FIform_obj *form = gadget->FIgadget.form;
   struct FIgroup_obj *group;
   struct FIgroup_obj *old_group;
   int ii;
   int slot_no;

   /*** if it's a group gadget, then pass on the ***/
   /*** add_to_group function to its members. ***/

   if (gadget->FIgadget.type == FI_GROUP && ! add_group_itself)
   {
	  _FI_grp_pass_on_id_int (gadget, _FI_g_add_to_group, group_label, 0);

	  return (FI_SUCCESS);
   }

   /*** get the group's id ***/

   if (group_label == FI_FORM_GROUP)
   {
	  group = form->group;
   }
   else
   {	/*** get the group ptr ***/

	  group = (struct FIgroup_obj *) _FI_g_get_id (form, group_label);

      /*** it's not a valid group gadget ***/

	  if (! group)
	     {
		 return (FI_NO_SUCH_GROUP);
	     }
   }

   old_group = gadget->FIgadget.group;

   /* if the gadget's already in the group, return */

   if (old_group == group)
     {
	  return (FI_SUCCESS);
     }

   /*** find the next available place to store the gadget id ***/

   slot_no = _FI_grp_get_next_slot (group);

   /*** store the gadget's id in the group ***/

   group->FIgroup.gadgets[slot_no]= gadget;

   /*** 1st time add_to_group is called, group ptr is NULL ***/

   if (old_group)
   {
      /*** remove the gadget from its current group ***/
      /*** find the index where the gadget is stored ***/

	  ii = _FI_grp_get_slot (old_group, gadget);

	  if (ii > -1)
	  {
		 old_group->FIgroup.gadgets[ii]= 0;

		 if (ii < (int)old_group->FIgroup.begin_slot)
		     {
			old_group->FIgroup.begin_slot = ii;
		     }
	  }
   }

   /*** store the group id in the gadget ***/

   gadget->FIgadget.group = group;

   /*** If the group is single_select and added gadget's	***/
   /*** state is set, then make sure group knows		***/

   if (gadget->FIgadget.value)
   {
	  _FI_grp_notify_selected (gadget);
   }

   return (FI_SUCCESS);
}

void _FI_grp_pass_on_int_always (struct FIgadget_obj  *gadget,
                                 int    (*function_ptr)(),
                                 int    arg1,
                                 int    arg2)
{
  struct FIgroup_obj * group;
  int ii;

	/* determine if the group is the form group or another one */

  if ( gadget->FIgadget.label == FI_FORM_GROUP )
    {
	group = gadget->FIgadget.form->group;
    }
  else
    {
	group = ( struct FIgroup_obj * ) gadget;
    }


    /*** Send message to all members of the group, regardless ***/
    /*** of whether the pass-on flag is set or not.           ***/

  /**********************************
  if ( group->FIgroup.dont_pass_on )
    return;
  ***********************************/


  for ( ii = 0; ii < (int)group->FIgroup.size ; ii ++ )
    {
      if ( group->FIgroup.gadgets[ii] )
        {
	  function_ptr ( gadget->FIgadget.form,
			(int)(( (struct FIgadget_obj *)
		  	group->FIgroup.gadgets[ii])->FIgadget.label),
						(int)arg1, (int)arg2 );
	}
    }
}

