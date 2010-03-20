
#include "FImin.h"

#include <stdio.h>

#include "FIappl.h"
#include "FEI.h"
#include "FIseq.h"
#include "FIdial.h"
#include "FIscroll.h"
#include "FIbtn.h"
#include "FIfield.h"
#include "FIslider.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

extern _FI_fld_new_gadget;

int _FI_range_set_notify (struct FIgadget_obj  *gadget,
                          char                 *value)
{
   int status;

   struct FIform_obj *form = gadget->FIgadget.form;

   double gad_value = atof (value);

   /* If disabled return */

   if (IT_IS_DISABLED(gadget))
	  return (FI_SUCCESS);

   switch (gadget->FIgadget.type)
   {
   case FI_DIAL:
	  _FI_dial_set_value ( (struct FIdial_obj *) gadget, gad_value);
	  break;
   case FI_SLIDER:
	  _FI_sld_set_value ( (struct FIsld_obj *) gadget, gad_value);
	  break;
   case FI_SCROLL:
	  _FI_scrl_set_value ( (struct FIscrl_obj *) gadget, gad_value);
	  break;
   }

   value[0]= (char) NULL;

   /* Notify of change in value */

   if ( form->notification_routine && (IT_HAS_COMPLETE_NOTIFY(gadget)) )
   {
     int save_gadget_label = gadget->FIgadget.label;

					/*** JAJ:01/20/92 ***/
      _FI_notification_type = FI_COMPLETION_NOTIFICATION;


	  if (_FI_record_notification_routine)
	  {
		 _FI_record_notification_routine (form->form_label,
		gadget->FIgadget.label, gadget->FIgadget.value, form);
	  }

	  form->notification_routine (form->form_label,
		gadget->FIgadget.label, gadget->FIgadget.value, form);

	  status = FIg_is_valid ((Form)form, save_gadget_label);

	  if (status != FI_SUCCESS)
		 return (status);
   }
   return (FI_SUCCESS);
}


int _FI_add_value (struct FIgadget_obj  *gadget,
                   double                value)
{
   char temp[25];
   int status;

   value += gadget->FIgadget.value;

   sprintf (temp, "%f", value);

   status = _FI_range_set_notify (gadget, temp);

   return (status);
}


int _FI_add_minor (struct FIgadget_obj  *gadget,
                   int                   pos)
{
   double increment;
   double dec_accur = gadget->FIrange.decimal_accuracy;
   int status;

   if (dec_accur == 0)
	  return (FI_SUCCESS);

   increment = 1.0 / pow (10.0, dec_accur);

   if (pos)
	  status = _FI_add_value (gadget, increment);
   else
	  status = _FI_add_value (gadget, -(increment));

   return (status);
}

int _FI_generic_track_kbd (struct FIgadget_obj  *gadget,
                           int                   direction,
                           int                   prev_gadget_label)
{
   struct FIgadget_obj *seq_gadget;
   struct FIform_obj *form = gadget->FIgadget.form;
   XEvent event;
   int prev_in_seq;
   int current_label = gadget->FIgadget.label;
   int type = gadget->FIgadget.type;

   unsigned char data[256];
   char value[32];
   int status;

   value[0]= (char) NULL;

   /* Set prev_in_seq to passed in value */

   if (direction == FI_FORWARD)
	  gadget->FIgadget.prev_in_seq = prev_gadget_label;

   prev_in_seq = gadget->FIgadget.prev_in_seq;

   if (! (IT_IS_DISABLED(gadget)))
	  _FI_g_hilite (gadget);

   for (;;)
   {
          /* replaces XNextEvent   GMD 10/23/91 */
	  FI_next_event (_FI_display, &event);

	  switch (event.type)
	  {
	  case KeyPress:
         /* This map_character call may need */
         /* to be yanked. GMD 3/10/91 */
		 FI_map_character (& (event.xkey), (char *)data);

		 switch (data[0])
		 {
		 case FI_NEXT_IN_SEQ:
		 case CR:
            /* Set the value before going on to the
            next gadget */

			if ((type == FI_DIAL) || (type == FI_SLIDER))
			{
			   if (value[0]!= (char) NULL)
			   {
				  status = _FI_range_set_notify (gadget, value);
				  if (status != FI_SUCCESS)
					 return (status);
			   }
               /** <pds-6/27/90> If increments are set then the value
               must be snapped
               **/

			   if (type == FI_DIAL)
			   {
				  double last_value = gadget->FIgadget.value;

                  /* 09/30/92:Added gadget->FIrange.high_value for ANSI */
				  _FI_snap_value (gadget, &gadget->FIgadget.value, gadget->FIrange.high_value);
				  if (last_value != gadget->FIgadget.value)
				  {
					 _FI_dial_draw_new_needle ((struct FIdial_obj *)gadget, last_value, gadget->FIgadget.value);
					 _FI_g_pass_data (gadget);
				  }
			   }
			}

			_FI_g_unhilite (gadget);

            /* Invalid gadget 12-14-89 */

			if (gadget->FIgadget.next_in_seq < 1)
			   return (FI_SUCCESS);

			seq_gadget = NULL;

			seq_gadget = _FI_g_get_id (form, gadget->FIgadget.next_in_seq);

			if (seq_gadget)
			{
			   status = _FI_g_track_kbd (seq_gadget, FI_FORWARD, current_label);
			   if (status != FI_SUCCESS)
				  return (status);
			}
			return (FI_SUCCESS);

		 case FI_PREV_IN_SEQ:

			_FI_g_unhilite (gadget);

			if (prev_in_seq == 0)
			   return (FI_SUCCESS);

			seq_gadget = NULL;
			seq_gadget = _FI_g_get_id (form, prev_in_seq);

			if (seq_gadget)
			{
			   status = _FI_g_track_kbd (seq_gadget, FI_BACKWARD, current_label);
			   if (status != FI_SUCCESS)
				  return (status);
			}
			return (FI_SUCCESS);

		 default:
			if ((type == FI_DIAL) || (type == FI_SLIDER) || (type == FI_SCROLL))
			{
			   int orientation = 0;

			   switch (type)
			   {
			   case FI_DIAL:
				  if (((struct FIdial_obj *) gadget)->FIdial.direction == 1)
					 orientation = 1;
				  break;
			   case FI_SLIDER:
				  if (((struct FIsld_obj *) gadget)->FIslider.type == FI_HORIZONTAL)
					 orientation = 1;
				  break;
			   case FI_SCROLL:
				  if (((struct FIscrl_obj *) gadget)->FIscroll.type == FI_HORIZONTAL)
					 orientation = 1;
				  break;
			   }

			   if (data[0]== FI_UP)
			   {
				  if (type != FI_DIAL)
				  {
					 if (orientation)
						status = _FI_add_minor (gadget, POSITIVE);
					 else
						status = _FI_add_value (gadget, (double) 1.0);
				  }
				  else
					 status = _FI_add_minor (gadget, POSITIVE);

				  if (status != FI_SUCCESS)
					 return (status);
			   }
			   else if (data[0]== FI_DOWN)
			   {
				  if (type != FI_DIAL)
				  {
					 if (orientation)
					 {
						status = _FI_add_minor (gadget, NEGATIVE);
					 }
					 else
					 {
						status = _FI_add_value (gadget, (double) -1.0);
					 }
				  }
				  else
				  {
					 status = _FI_add_minor (gadget, NEGATIVE);
				  }

				  if (status != FI_SUCCESS)
					 return (status);
			   }
			   else if (data[0]== FI_LEFT)
			   {
				  if (type != FI_DIAL)
				  {
					 if (orientation)
						status = _FI_add_value (gadget, (double) -1.0);
					 else
						status = _FI_add_minor (gadget, NEGATIVE);
				  }
				  else
				  {
					 if (orientation)
						status = _FI_add_value (gadget, (double) 1.0);
					 else
						status = _FI_add_value (gadget, (double) -1.0);
				  }

				  if (status != FI_SUCCESS)
					 return (status);
			   }
			   else if (data[0]== FI_RIGHT)
			   {
				  if (type != FI_DIAL)
				  {
					 if (orientation)
						status = _FI_add_value (gadget, (double) 1.0);
					 else
						status = _FI_add_minor (gadget, POSITIVE);
				  }
				  else
				  {
					 if (orientation)
						status = _FI_add_value (gadget, (double) -1.0);
					 else
						status = _FI_add_value (gadget, (double) 1.0);
				  }

				  if (status != FI_SUCCESS)
					 return (status);
			   }
               /* If the character is a digit then store it */

			   else if ((isdigit(data[0])) || (data[0]== '.') || (data[0]== '-'))
			   {
				  int next = strlen (value);

				  if (next < 19)
				  {
					 value[next]= data[0];
					 value[next + 1]= (char) NULL;
				  }
				  else
				  {
                     /* set value because of overflow */

					 status = _FI_range_set_notify (gadget, value);
					 if (status != FI_SUCCESS)
						return (status);
				  }
			   }
			   else if (data[0]== ENTER)
			   {
				  if (value[0]!= (char) NULL)
				  {
					 status = _FI_range_set_notify (gadget, value);
					 if (status != FI_SUCCESS)
						return (status);
				  }
			   }
			   else if (data[0]== 127)
			   {
				  int index = strlen (value) - 1;

				  if (index >= 0)
					 value[index]= (char) NULL;
			   }
			}
			else	/** Button or Checklist **/
			{
			   if (data[0]== SPACE)
			   {
				  if (IT_IS_DISABLED(gadget))
					 break;

                  /* Toggle the gadgets state */

				  _FI_g_set_state (gadget, (double)(! gadget->FIgadget.value));
				  /* sml:01-28-93	execute cmd key/string */
				  _FI_g_common(gadget);

				  if ((form->notification_routine) && IT_HAS_COMPLETE_NOTIFY(gadget))
				  {
					/*** JAJ:01/20/92 ***/
				      _FI_notification_type = FI_COMPLETION_NOTIFICATION;

					 if (_FI_record_notification_routine)
					 {
					  _FI_record_notification_routine (
					gadget->FIgadget.form->form_label,
						gadget->FIgadget.label,
						gadget->FIgadget.value,
						gadget->FIgadget.form);
					 }

					 form->notification_routine (
						gadget->FIgadget.form->form_label,
						gadget->FIgadget.label,
						gadget->FIgadget.value,
						gadget->FIgadget.form );

					 status = FIg_is_valid ((Form)form, current_label);

					 if (status != FI_SUCCESS)
						return (status);
				  }
			   }
			}
			break;
		 }	/* end switch */
		 break;

	  case ButtonPress:
                 /* GMD 1/24/92 */
		 FI_put_back_event (_FI_display, &event);
		 _FI_g_unhilite (gadget);
		 return (FI_SUCCESS);

	  case Expose:
	  case ConfigureNotify:
	  case ClientMessage:
	  case MapNotify:
	  case UnmapNotify:
	  case DestroyNotify:
		 if (FI_process_event (&event, 0) == TRUE)
			break;
		 else
		 {
                        /* GMD 1/24/92 */
			FI_put_back_event (_FI_display, &event);
			return (FI_SUCCESS);
		 }
	  }	/** END switch(event->type)**/
   }	/** END for(;;)**/

   /* return(FI_SUCCESS); Not Reachable! */
}



int _FI_g_track_kbd (struct FIgadget_obj  *gadget,
                     int                   direction,
                     int                   prev_in_seq)
{
   int status;

   /* If no sequencing return */

   if (gadget->FIgadget.form->seq_off)
	  return (FI_SUCCESS);

   /* If the gadget is not enabled or displayed then return */

   /* CHUNN skip over this gadget ?? */

   if (IT_IS_DISABLED(gadget) || IT_IS_NOT_DISPLAYABLE(gadget))
	  return (FI_SUCCESS);

   /* If the gadget has initial notify set then call it */

   /* This is duplicated elsewhere, so drop it here GMD 11/2/90 */
   /********************************************************************
    if ( form->initial_notification_routine	&&
					(IT_HAS_INITIAL_NOTIFY(gadget)))
    {
      form->initial_notification_routine(form->form_label,
		gadget->FIgadget.label, gadget->FIgadget.value, form);
    }
   *******************************************************************/

  _FI_fld_new_gadget = gadget->FIgadget.label;

   switch (gadget->FIgadget.type)
   {
   case FI_GROUP:
	  break;

   case FI_FIELD:
	  {
		 struct FIfld_obj *field = (struct FIfld_obj *) gadget;

         /* Assign keyboard because field only
         assign in track_mouse */

		 status = _FI_fld_track_kbd (field, direction, prev_in_seq);
		 if (status != FI_SUCCESS)
			return (status);

         /* Take down the assoc list if it is up */

		 if ((_FI_list_up) && (! field->FIfield.flags.is_a_list))
			_FI_fld_process_displayed_list (field->FIfield.list_id);
	  }
	  break;

   case FI_MULTI_COL:
	  status = _FI_mcf_track_kbd ((struct FImcf_obj *)gadget, direction, prev_in_seq);
	  if (status != FI_SUCCESS)
		 return (status);
	  break;

   case FI_TEXT:
   case FI_LINE:
   case FI_RECT:
   case FI_SYM:
   case FI_GAUGE:
   case FI_BEZEL:
      /* These gadgets cannot track kbd */
	  break;

   default:
      /* State gadgets track here */

	  status = _FI_generic_track_kbd (gadget, direction, prev_in_seq);
	  if (status != FI_SUCCESS)
		 return (status);
   }
   return (FI_SUCCESS);
}

