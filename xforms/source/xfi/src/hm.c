#include "FImin.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/******************************************************************************

Doc: FIh_attach_to_parent

Abstract:
 The FIh_attach_to_parent function sets up a parent/child
 relationship between the given form and its parent form.

Algorithm:
 1. Initialize the hierarchy data for the given form if it has
 not already been done.
 2. Set the parent form pointer in the given form's hierarchy data.
 3. Add the given form to the parent form's hierarchy data if
 a parent form was specified.

Return Status:
 FI_SUCCESS - Success
 FI_NO_SUCH_FORM - Bad form pointer

******************************************************************************/
/* Form form;	** i - Form to be attached */
/* Form parent_form;	** i - Parent form to attach to */
/*                             NULL --> no parent */


int FIh_attach_to_parent (Form  form,
                          Form  parent_form)
{
   struct FIh_data *hierarchy;

   hierarchy = ((struct FIform_obj *) form)->child_node;

   if (! hierarchy)
   {
	  hierarchy = (struct FIh_data *) malloc (sizeof (struct FIh_data));
	  if (! hierarchy)
		 return (FI_NO_MEMORY);

	  ((struct FIform_obj *) form)->child_node = hierarchy;

	  hierarchy->parentForm = (Form) 0;
	  hierarchy->childForm = (Form *) 0;
	  hierarchy->childCount = 0;
	  hierarchy->childAlloc = 0;
	  hierarchy->replyFunc = 0;
   }

   hierarchy->parentForm = (Form) parent_form;

   if (parent_form)
	  return (_FIh_add_child_form ( (struct FIform_obj *) parent_form, (struct FIform_obj *) form));
   else
	  return (FI_SUCCESS);
}

/******************************************************************************

Doc: FIh_detach_from_parent

Abstract:
 The FIh_detach_from_parent function dissolves the parent/child
 relationship between the given form and its parent form.

Algorithm:
 1. Remove the given form from the parent form's hierarchy data
 if the parent exists.
 2. Null the parent form pointer in the given form's hierarchy data.

Return Status:
 FI_SUCCESS - Success
 FI_NO_SUCH_FORM - Bad form pointer

******************************************************************************/
/* Form form;	** i - Form to be detached */


int FIh_detach_from_parent (Form form)
{
   struct FIh_data *hierarchy;

   hierarchy = ((struct FIform_obj *) form)->child_node;
   if (! hierarchy)
	  return (FI_SUCCESS);

   if (! hierarchy->parentForm)
	  return (FI_SUCCESS);

   return (_FIh_remove_child_form ( (struct FIform_obj *) hierarchy->parentForm, (struct FIform_obj *) form));
}


/******************************************************************************

Doc: _FIh_add_child_form
Private:

Abstract:
 The _FIh_add_child_form function adds the given form to the list
 of child forms in the parent form's hierarchical data.

Return Status:
 FI_SUCCESS - Success
 other - Failure

******************************************************************************/
/* struct FIform_obj *parent_form;	** i - Parent form pointer */
/* struct FIform_obj *child_form;	** i - Child form pointer */


int _FIh_add_child_form (struct FIform_obj  *parent_form,
                         struct FIform_obj  *child_form)
{
   struct FIh_data *hierarchy;
   Form *formBuf;
   unsigned size;
   int sts, index;

   hierarchy = parent_form->child_node;
   if (! hierarchy)
   {
	  sts = FIh_attach_to_parent ( (Form) parent_form, (Form) 0);
	  if (sts != FI_SUCCESS)
		 return (sts);
   }

   for (index = 0; index < hierarchy->childAlloc && hierarchy->childForm[index]!= (Form) 0; index++)
	  ;

   if (index >= hierarchy->childAlloc)
   {
	  hierarchy->childAlloc++;
	  size = hierarchy->childAlloc * sizeof (Form);
	  formBuf = (hierarchy->childAlloc == 1) ? (Form *) calloc (1, size) : (Form *) realloc (hierarchy->childForm, size);
	  if (formBuf)
		 hierarchy->childForm = formBuf;
	  else
		 return (FI_NO_MEMORY);
   }

   hierarchy->childForm[index]= (Form) child_form;
   hierarchy->childCount++;

   return (FI_SUCCESS);
}

/******************************************************************************

Doc: _FIh_remove_child_form
Private:

Abstract:
 The _FIh_remove_child_form function removes the given form from
 the list of child forms in the parent form's hierarchical data.

Return Status:
 FI_SUCCESS - Success
 other - Failure

******************************************************************************/
/* struct FIform_obj *parent_form;	** i - Parent form pointer */
/* struct FIform_obj *child_form;	** i - Child form pointer */


int _FIh_remove_child_form (struct FIform_obj  *parent_form,
                            struct FIform_obj  *child_form)
{
   struct FIh_data *hierarchy;
   int index;

   hierarchy = parent_form->child_node;
   if (! hierarchy)
	  return (FI_SUCCESS);

   for (index = 0; index < hierarchy->childAlloc; index++)
   {
	  if (hierarchy->childForm[index]== (Form) child_form)
	  {
		 hierarchy->childForm[index]= (Form) 0;
		 hierarchy->childCount--;
		 return (FI_SUCCESS);
	  }
   }

   return (FI_SUCCESS);
}

/******************************************************************************

Doc: FIh_callback

Abstract:
 The FIh_callback function calls the given function for every
 form in the hierarchy whose root is the given form. The
 function is called as follows:

 (*routine)(form, user_arg);

 where:
 form Form Input
 Form currently being processed

 user_arg int Input
 Argument passed to FIh_callback

Return Status:
 FI_SUCCESS - Success

******************************************************************************/
/* Form form;	** i - Form at top of the hierarchy */
/* int mode;	** i - Mode of traversing the heirarchy */
/*                     0 - Child forms first */
/*                     1 - Parent form first */
/* int top_flag;	** i - Call the function for the given */
/*                         top form as well? 0: No 1: Yes */
/* int (*routine) ();	** i - Function to call for each form */
/* int user_arg;	** i - Argument to(*routine)() */


int FIh_callback (Form   form,
                  int    mode,
                  int    top_flag,
                  int  (*routine)(),
                  int    user_arg)
{
   struct FIh_data *hierarchy;
   int index;

   if (top_flag == 1 && mode == 1)
	  (*routine) (form, user_arg);

   if (hierarchy = ((struct FIform_obj *) form)->child_node)
   {
	  for (index = 0; index < hierarchy->childAlloc; index++)
	  {
		 if (hierarchy->childForm[index])
			FIh_callback ( (Form) hierarchy->childForm[index], mode, 1, routine, user_arg);
	  }
   }

   if (top_flag == 1 && mode == 0)
	  (*routine) ((Form) form, user_arg);

   return (FI_SUCCESS);
}

/******************************************************************************

Doc: FIh_set_reply_routine

Abstract:
 The FIh_set_reply_routine function sets the routine to be called
 when a child form returns some information to the given form.

Return Status:
 FI_SUCCES - Success
 FI_NO_CONNECTION - Form not connected

******************************************************************************/
/* Form form;	** i - Form to be replied to */
/* int (*reply_routine) ();	** i - Routine to handle child form info*/


int FIh_set_reply_routine (Form   form,
                           int  (*reply_routine)())
{
   struct FIh_data *hierarchy;

   hierarchy = ((struct FIform_obj *) form)->child_node;
   if (! hierarchy)
	  return (FI_NO_CONNECTION);

   hierarchy->replyFunc = reply_routine;

   return (FI_SUCCESS);
}



/* Form form;	** i - Form to be replied to */
/* int (**reply_routine) ();	** O - Func to handle child form info */

int FIh_get_reply_routine (Form    form,
                           int  (**reply_routine)())
{
   struct FIh_data *hierarchy;

   hierarchy = ((struct FIform_obj *) form)->child_node;
   if (! hierarchy)
   {
	  return (FI_NO_CONNECTION);
   }

   *reply_routine = hierarchy->replyFunc;

   return (FI_SUCCESS);
}


/******************************************************************************

Doc: FIh_reply_to_parent

Abstract:
 The FIh_reply_to_parent function calls the parent form's reply
 routine with the given data. The function call is:

 (*reply_routine)(parent_form, user_arg);

 where:
 parent_form Form Input
 Form pointer of the parent

 user_arg int Input
 Argument passed to FIh_reply_to_parent

Return Status:
 FI_SUCCESS - Success
 FI_NO_CONNECTION - Form not connected

******************************************************************************/
/* Form form;	** i - Child form returning information */
/* int user_arg;	** i - Argument to(*reply_routine)()*/


int FIh_reply_to_parent (Form  form,
                         int   user_arg)
{
   struct FIh_data *hierarchy, *parHierarchy;

   hierarchy = ((struct FIform_obj *) form)->child_node;
   if (! hierarchy)
	  return (FI_NO_CONNECTION);

   if (hierarchy->parentForm)
   {
	  parHierarchy = ((struct FIform_obj *) hierarchy->parentForm)->child_node;

	  if (parHierarchy->replyFunc)
		 (*parHierarchy->replyFunc) ((Form) hierarchy->parentForm, user_arg);
   }

   return (FI_SUCCESS);
}

