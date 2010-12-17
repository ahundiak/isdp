#include "FImin.h"

#include "FEI.h"

#include "FIscroll.h"
#include "FIbtn.h"
#include "FImcf.h"
#include "FIfield.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"


static int (*branch_table_activate[]) () =
{
   NULL,
   _FI_sld_activate,
   _FI_tog_activate,
   _FI_fld_activate,
   _FI_cklst_activate,
   _FI_dial_activate,
   _FI_txt_activate,
   _FI_btn_activate,
   NULL,
   NULL,
   NULL,
   _FI_sym_activate,
   _FI_scrl_activate,
   _FI_mcf_activate,
   NULL
};


/* Activates the gadget */

int _FI_g_activate (struct FIgadget_obj *gadget)
{
   int type = gadget->FIgadget.type;

   if (gadget->FIgadget.type == FI_GROUP)
   {
	  _FI_grp_pass_on_id_int_always (gadget, _FI_g_activate, 0, 0);
   }
   else
   {
	  if (branch_table_activate[type])
		 branch_table_activate[type] (gadget);
   }
   return (FI_SUCCESS);
}



void _FI_g_common (struct FIgadget_obj *gadget)
{
   Form form = (Form) gadget->FIgadget.form;
   int mask = gadget->FIgadget.attr_mask;

   if ((mask & FI_HELP_TOPIC) && (gadget->FIgadget.help_topic) && (gadget->FIgadget.help_topic[0]))
   {
	  FI_process_data (FI_HELP_TOPIC_DATA, gadget->FIgadget.help_topic, form);
   }

   if ((mask & FI_CMD_KEY) && (gadget->FIgadget.command) && (gadget->FIgadget.command[0]))
   {
	  FI_process_data (FI_CMD_KEY_DATA, gadget->FIgadget.command, form);
   }

   if ((mask & FI_CMD_STRING) && (gadget->FIgadget.command) && (gadget->FIgadget.command[0]))
   {
	  FI_process_data (FI_CMD_STRING_DATA, gadget->FIgadget.command, form);
   }
}


/* This function sets the gadget's notification flag */

int _FI_g_set_notify (struct FIgadget_obj *gadget,
                      int                  notify_flag)
{
   switch (gadget->FIgadget.type)
   {
   case FI_GROUP:
   case FI_MULTI_COL:

	  _FI_grp_pass_on_id_int (gadget, _FI_g_set_notify, notify_flag, 0);

      /* no break so can set status of mcf gadget */

   default:

	  if (notify_flag == ON)
		 gadget->FIgadget.attr_mask &= ~ FI_NO_COMPLETE_NOTIFY;
	  else
		 gadget->FIgadget.attr_mask |= FI_NO_COMPLETE_NOTIFY;

	  break;
   }

   return (FI_SUCCESS);
}


int _FI_g_reset (struct FIgadget_obj *gadget)
{
   switch (gadget->FIgadget.type)
   {
   case FI_GROUP:

	  _FI_grp_pass_on_id_int (gadget, _FI_g_reset, 0, 0);
	  return (FI_SUCCESS);

   case FI_MULTI_COL:

	  _FI_grp_pass_on_id_int (gadget, _FI_g_reset, 0, 0);

	  _FI_mcf_adjust_cols ((struct FImcf_obj *)gadget);

	  if (IT_IS_DISPLAYED(gadget) && (gadget->FIgadget.default_attr_mask & FI_NOT_DISPLAYED))
		 _FI_g_erase (gadget);

	  gadget->FIgadget.attr_mask = gadget->FIgadget.default_attr_mask;

	  if (((struct FImcf_obj *) gadget)->FImcf.vscrl_id)
		 _FI_g_reset ( (struct FIgadget_obj *) ((struct FImcf_obj *) gadget)->FImcf.vscrl_id);

	  if (((struct FImcf_obj *) gadget)->FImcf.hscrl_id)
		 _FI_g_reset ( (struct FIgadget_obj *) ((struct FImcf_obj *) gadget)->FImcf.hscrl_id);

	  if (IT_IS_DISPLAYED(gadget))
		 _FI_g_display (gadget, XWINDOW(gadget));

	  return (FI_SUCCESS);

   case FI_FIELD:

	  if (IT_IS_DISPLAYED(gadget) && (gadget->FIgadget.default_attr_mask & FI_NOT_DISPLAYED))
		 _FI_g_erase (gadget);

	  _FI_fld_reset ((struct FIfld_obj *)gadget);

	  if (IT_IS_DISPLAYED(gadget))
		 _FI_g_display (gadget, XWINDOW(gadget));
	  break;

   case FI_SCROLL:
	  {
		 int i;

		 _FI_g_reset ( (struct FIgadget_obj *) ((struct FIscrl_obj *) gadget)->FIscroll.puck);

		 for (i = 0; i < 4; i++)
			_FI_g_reset ( (struct FIgadget_obj *) ((struct FIscrl_obj *) gadget)->FIscroll.btns[i]);
	  }

      /* NO BREAK !!!! */

   case FI_SLIDER:
   case FI_DIAL:

	  if (gadget->FIrange.cont_routine)
	  {
		 gadget->FIrange.cont_routine (gadget->FIgadget.form->form_label, gadget->FIgadget.label, gadget->FIgadget.value, gadget->FIgadget.form);
	  }

	  _FI_g_pass_data (gadget);

      /* NO BREAK !!!! */

   default:
	  {
		 struct FIform_obj *form = gadget->FIgadget.form;

		 if ((gadget->FIgadget.label == FI_CVT_TO_PERM_WIN) && ! (form->attr_mask & FI_SAVE_RESTORE))
		 {
            /* Break because the button doesn't need
            resetting */

			break;
		 }

		 if ((gadget->FIgadget.value != gadget->FIgadget.default_value) || (gadget->FIgadget.attr_mask != gadget->FIgadget.default_attr_mask))
		 {
			Window window = form->Xwindow;

			if (IT_IS_DISPLAYED(gadget) && gadget->FIgadget.default_attr_mask & FI_NOT_DISPLAYED)
			{
			   _FI_g_erase (gadget);
			}

			gadget->FIgadget.value = gadget->FIgadget.default_value;

			gadget->FIgadget.attr_mask = gadget->FIgadget.default_attr_mask;

			if (IT_IS_DISPLAYED(gadget))
			{
			   _FI_g_display (gadget, window);
			}
		 }
	  }
	  break;
   }
   return (FI_SUCCESS);	/* dmb:03/27/91:Added */

}

/* This function is used to convert the label on a form to a */
/* gadget id. This function returns NULL if no gadget is found */

struct FIgadget_obj *_FI_g_get_id (struct FIform_obj *form,
                                   int                gadget_label)
{
   _FI_gc = form->Xgc;

  _FI_text_gc = form->Xgc_text;	/*** JAJ:02/14/92 ***/

   if (gadget_label == FI_FORM_GROUP)
	  return ((struct FIgadget_obj *) form->group);

   return ((struct FIgadget_obj *) _FI_g_get_id_from_group 
                                   (form->group, gadget_label));
}


/* This function sets the state of the gadget */
/*
int state; 3/27/91 pds This allows the data to be linked THROUGH a
state gadget.
*/

int _FI_g_set_state (struct FIgadget_obj *gadget,
                     double               state)
{
   switch (gadget->FIgadget.type)
   {
   case FI_GROUP:
   case FI_MULTI_COL:

/*	  _FI_grp_pass_on_id_int (gadget, _FI_g_set_state, state, 0);*/
	  _FI_grp_pass_on_id_double (gadget, _FI_g_set_state, state, 0 );
	  break;

   default:

	  if ( (int) gadget->FIgadget.value != state)
	  {
		 gadget->FIgadget.value = state;

		 if (IT_IS_DISPLAYED(gadget))
		 {
			_FI_g_display (gadget, XWINDOW(gadget));
		 }

         /* If in a single_select group then
         notify of new selection */

		 if (state)
		 {
			_FI_grp_notify_selected (gadget);
		 }

         /* Pass on data to directed gadget */

		 sprintf (FI_data, "%lf", state);

		 _FI_g_pass_data (gadget);
	  }

	  break;
   }
   return (FI_SUCCESS);	/* dmb:03/27/91:Added */

}
