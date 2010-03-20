#include "FImin.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/* DISPLAY */

/* delta_x and delta_y are the multiplication factors on the current */
/* x and y dimensions of the gadget */

/* dmmb:10/06/92:Changed floats to doubles for ANSI */
int FIg_adjust_size (Form   form,
                     int    label,
                     double delta_x,
                     double delta_y)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   if (gadget->FIgadget.type == FI_GROUP)
   {
	  _FI_grp_pass_on_id_double (gadget, (int (*)())_FI_g_adjust_size, delta_x, delta_y);
   }
   else
   {
	  _FI_g_adjust_size (gadget, delta_x, delta_y);
   }

   return (FI_SUCCESS);
}


/* This function enables the gadget. It changes look and is now selectable */

int FIg_enable (Form   form,
                int    label)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   _FI_g_enable (gadget);

   return (FI_SUCCESS);
}


/* This function displays the gadget */

int FIg_display (Form   form,
                 int    label)
{
   struct FIgadget_obj *gadget;
   Window window;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   window = XWINDOW(gadget);

   /* This function set the gadget to displayable */

   _FI_g_set_displayable (gadget);

   _FI_g_display (gadget, window);

   return (FI_SUCCESS);
}


/* This function erases the gadget */

int FIg_erase (Form  form,
               int   label)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   _FI_g_erase (gadget);

   return (FI_SUCCESS);
}


/* This function hilites the gadget */

int FIg_hilite (Form   form,
                int    label)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   _FI_g_hilite (gadget);

   return (FI_SUCCESS);
}



int FIg_unhilite (Form   form,
                  int    label)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   _FI_g_unhilite (gadget);

   return (FI_SUCCESS);
}


/* This function disables the gadget. It changes look and is no longer selectable */

int FIg_disable (Form   form,
                 int    label)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   _FI_g_disable (gadget);

   return (FI_SUCCESS);
}


/* MEMORY */

/* This function return the value of the gadget */
/* Note this function returns a double. This will cover all numeric types */

int FIg_get_value (Form     form,
                   int      label,
                   double  *value)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   if (gadget->FIgadget.type == FI_FIELD)
   {
	  char *text;
	  int length;

	  FIg_get_text_length (form, label, &length);
	  text = (char *) calloc (1, length + 1);
	  FIg_get_text (form, label, text);
	  *value = atof (text);
	  _FI_s_free (text);
   }
   else
   {
	  *value = gadget->FIgadget.value;
   }

   return (FI_SUCCESS);
}



/* This function sets the value of the gadget */

int FIg_set_value (Form    form,
                   int     label,
                   double  value)
{
   struct FIgadget_obj *gadget;
   int type;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   type = gadget->FIgadget.type;

   switch (type)
   {
   case FI_GROUP:
   case FI_MULTI_COL:
	  _FI_dont_flush++;
	  _FI_grp_pass_on_double (gadget, FIg_set_value, value);
	  _FI_dont_flush--;
	  break;

   case FI_SCROLL:
	  _FI_scrl_set_value ((struct FIscrl_obj *)gadget, value);
	  break;

   case FI_DIAL:
	  _FI_dial_set_value ((struct FIdial_obj *)gadget, value);
	  break;

   case FI_SLIDER:
	  _FI_sld_set_value ( (struct FIsld_obj *) gadget, value);
	  break;

   case FI_GAUGE:
	  _FI_gauge_set_value ((struct FIgauge_obj *)gadget, value);
	  break;

   case FI_FIELD:
	  FIfld_set_value ( (Form) gadget->FIgadget.form, gadget->FIgadget.label, 0, 0, value, 0);

   default:
      /* If it is a state gadget then set the state */

	  if (STATE_GADGET(type))
		 _FI_g_set_state (gadget, value);
	  else
		 gadget->FIgadget.value = value;
	  break;
   }

   return (FI_SUCCESS);
}


/* This function return the state of the gadget */

int FIg_get_state (Form   form,
                   int    label,
                   int   *state)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (gadget)
   {
	  *state = (int) gadget->FIgadget.value;
	  return (FI_SUCCESS);
   }
   else
	  return (FI_NO_SUCH_GADGET);

}



/* This function sets the state of the gadget to ON */

int FIg_set_state_on (Form  form,
                      int   label)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   _FI_g_set_state (gadget, 1.0);

   return (FI_SUCCESS);
}




/* This function sets the state of the gadget to OFF */

int FIg_set_state_off (Form  form,
                       int   label)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   _FI_g_set_state (gadget, 0.0);

   return (FI_SUCCESS);
}



/* This function gets the off text of the gadget. A NULL is */
/* returned if there is no off text for the gadget. This */
/* returns the same as a FIf_get_text */


int FIg_get_off_text (Form  form,
                      int   label,
                      char *text)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   if ((gadget->FIgadget.type == FI_FIELD) || (gadget->FIgadget.type == FI_MULTI_COL))
   {
	  int sel_flag;
	  int num_char, active_row, r_pos, active_col, col_pos;

	  if (gadget->FIgadget.type == FI_MULTI_COL)
		 FImcf_get_active_col (form, label, &active_col, &col_pos);
	  else
		 active_col = 0;
	  FIfld_get_active_row (form, label, &active_row, &r_pos);
	  FIfld_get_text_length (form, label, active_row, active_col, &num_char);
	  FIfld_get_text (form, label, active_row, active_col, num_char,
        (unsigned char *)text, &sel_flag, &r_pos);
   }
   else
   {
#if defined(hp9000)
	  if (gadget->FIgadget.text)
		 strcpy (text, (char *) gadget->FIgadget.text);
#else
	  if (gadget->FIgadget.text)
		 strcpy (text, gadget->FIgadget.text);
#endif
	  else
		 strcpy (text, "");
   }
   return (FI_SUCCESS);
}


int FIg_set_text (Form form,
                  int label,
                  char *text)
{
   return (FIg_set_off_text (form, label, text));
}



/* This function returns the length of the off text string so */
/* that they can malloc enough space to hold */

int FIg_get_off_text_length (Form  form,
                             int   label,
                             int  *length)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   if ((gadget->FIgadget.type == FI_FIELD) || (gadget->FIgadget.type == FI_MULTI_COL))
   {
	  int r_pos, active_row, active_col, col_pos;

	  if (gadget->FIgadget.type == FI_MULTI_COL)

		 FImcf_get_active_col (form, label, &active_col, &col_pos);
	  else
		 active_col = 0;

	  FIfld_get_active_row (form, label, &active_row, &r_pos);
	  FIfld_get_text_length (form, label, active_row, active_col, length);
   }
   else
   /*** JAJ:12/04/90: added + 1 ***/
	  *length = strlen ((char *)gadget->FIgadget.text) + 1;

   return (FI_SUCCESS);
}


int FIg_get_text (Form  form,
                  int   label,
                  char *text)
{
   return (FIg_get_off_text (form, label, text));
}



int FIg_get_text_length (Form  form,
                         int   label,
                         int  *length)
{
   return (FIg_get_off_text_length (form, label, length));
}




/* This function sets the location of the gadget on the form */

int FIg_set_location (Form  form,
                      int   label,
                      int   xpos,
                      int   ypos)
{
   struct FIgadget_obj *gadget;

   int delta_x;
   int delta_y;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   /* If location is the same then return */

   if ((xpos == gadget->FIgadget.xlo) && (ypos == gadget->FIgadget.ylo))
	  return (FI_SUCCESS);

   if (gadget->FIgadget.type == FI_GROUP)
	  _FI_grp_calculate_size ( (struct FIgroup_obj *) gadget);

   delta_x = xpos - gadget->FIgadget.xlo;
   delta_y = ypos - gadget->FIgadget.ylo;

   _FI_g_change_location (gadget, delta_x, delta_y);

   return (FI_SUCCESS);
}

int FIg_start_seq (Form  form,
                   int   label)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   if (((struct FIform_obj *) form)->Xwindow != None)
   {
	  XEvent event;

      /* Make the label negative. This tells the form
      system to not start up sequence again if the
      form is displayed */

      /* Subtract offset of 10 */

	  ((struct FIform_obj *) form)->seq_label = -(label) - 10;

      /* X11-4/17/90-Signal forms with a clent message */

	  event.xclient.type = ClientMessage;
	  event.xclient.window = ((struct FIform_obj *) form)->Xwindow;
	  event.xclient.message_type = 32;
	  event.xclient.format = 32;
	  event.xclient.data.l[0]= FI_DATA_OFFSET;

          /* GMD 1/24/92 */
	  FI_send_event (_FI_display, ((struct FIform_obj *) form)->Xwindow, True, None, &event);
   }
   else
	  return (FI_FORM_NOT_DISPLAYED);

   return (FI_SUCCESS);
}


/* This function sets the off text of the gadget. */

int FIg_set_off_text (Form  form,
                      int   label,
                      char *string)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   if (gadget->FIgadget.type == FI_FIELD)
   {
	  int active_row, r_pos;
	  int sel_flag;

	  FIfld_get_active_row (form, label, &active_row, &r_pos);
	  FIfld_get_select (form, label, active_row, 0, &sel_flag);
	  FIfld_set_text (form, label, active_row, 0, string, sel_flag);
   }
   else
   {
	  _FI_s_rep ( (char **) &gadget->FIgadget.text, string);

      /* re-calculate the string length */

	  if (gadget->FIgadget.type == FI_TEXT)
		 _FI_txt_adjust ((struct FItext_obj *)gadget, 1.0, 1.0);	  
	  /******************************************************/
	  /* sml:07-30-93 set text length for other gadgets too */
	  /******************************************************/
      else
	  {
	   gadget->FIgadget.text_length = 
			FI_strlen ((char *)string, gadget->FIgadget.font_type);
	  }

	  _FI_g_activate (gadget);

   }

   /* Pass on data to directed gadget */

   strcpy (FI_data, string);

   _FI_g_pass_data (gadget);

   return (FI_SUCCESS);
}
