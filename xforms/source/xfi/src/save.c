#if defined(i86pc)
#include <sys/utsname.h>
#endif

#include "FImin.h"

#include <sys/errno.h>
#include <stdio.h>
#include <setjmp.h>
#if !defined(i86pc)
#include <sys/utsname.h>
#endif
#include <math.h>
#include "FIread.h"
#include "FEI.h"
#include "FIgroup.h"
#include "FItext.h"
#include "FIcklst.h"
#include "FIsym.h"
#include "FIbezel.h"
#include "FItog.h"
#include "FIgraphic.h"
#include "FIrect.h"
#include "FIline.h"
#include "FIdial.h"
#include "FIslider.h"
#include "FIgauge.h"
#include "FItext.h"
#include "FIscroll.h"
#include "FIbtn.h"
#include "FIfield.h"
#include "FImcf.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/* DO THIS FOR THE G-D CLIPPER SHARED LIBRARY !!!!!	*/
/* CAN'T PUT IT IN FIimport.h !!!			*/

#if defined(clipper)
#define	time 		(*libxfi_time)

extern long	(* libxfi_time)();
#endif

#if defined(mips)
/* #define	time 		(*libxfi_time) */

/* extern long	(* libxfi_time)(); */
#endif


void _FI_fld_dump (struct FIfld_obj *field)
{
   int ii;
   int field_flags;

   _FI_dump_short (field->FIfield.field_type);
   _FI_dump_short (field->FIfield.mode);
   _FI_dump_short (field->FIfield.nr);
   _FI_dump_short (field->FIfield.nvr);
   _FI_dump_short (field->FIfield.nc);
   _FI_dump_short (field->FIfield.nvc);
   _FI_dump_short (field->FIfield.default_size);

   _FI_dump_double (field->FIfield.min);
   _FI_dump_double (field->FIfield.max);

   _FI_dump_char ( (char) field->FIgadget.justification);
   _FI_dump_string (field->FIfield.fmt);

   for (ii = 0; ii < field->FIfield.default_size; ii++)
   {
	  _FI_dump_string ( (char *) field->FIfield.defaults[ii].line);
	  _FI_dump_short (field->FIfield.defaults[ii].sel);
   }

   field_flags = 0;

   if (field->FIfield.flags.uds)
      field_flags |= FI_FIELD_UDS;

   if (field->FIfield.flags.lrs)
      field_flags |= FI_FIELD_LRS;

   if (field->FIfield.flags.roll_thru)
       field_flags |= FI_FIELD_ROLL_THRU;

   if (field->FIfield.flags.wrap)
       field_flags |= FI_FIELD_WRAP;

   if (field->FIfield.flags.draw_vscrl)
       field_flags |= FI_FIELD_DRAW_VSCRL;
  
   if (field->FIfield.flags.draw_hscrl)
       field_flags |= FI_FIELD_DRAW_HSCRL;

   if (field->FIfield.flags.clear)
       field_flags |= FI_FIELD_CLEAR;

   if (field->FIfield.flags.no_echo)
       field_flags |= FI_FIELD_NO_ECHO;

   if (field->FIfield.flags.by_line)
       field_flags |= FI_FIELD_BY_LINE;

   if (field->FIfield.flags.ascii_only)
       field_flags |= FI_FIELD_ASCII_ONLY;

   if (field->FIfield.flags.is_a_list)
       field_flags |= FI_FIELD_IS_A_LIST;

   if (field->FIfield.flags.popup_list)
       field_flags |= FI_FIELD_POPUP_LIST;

   if (field->FIfield.flags.dismiss)
       field_flags |= FI_FIELD_DISMISS;

   if (field->FIfield.flags.valid_list)
       field_flags |= FI_FIELD_VALID_LIST;

   if (field->FIfield.flags.is_a_col)
       field_flags |= FI_FIELD_IS_A_COL;

   if (field->FIfield.flags.required)
       field_flags |= FI_FIELD_REQUIRED;

   if (field->FIfield.flags.right_to_left)
       field_flags |= FI_FIELD_RIGHT_TO_LEFT;

   if (field->FIfield.flags.reverse_input)
       field_flags |= FI_FIELD_REVERSE_INPUT;

   if (field->FIfield.flags.reverse_output)
       field_flags |= FI_FIELD_REVERSE_OUTPUT;

   _FI_dump_int (field_flags);

   if (field->FIfield.list_id)
   {
	  _FI_dump_char (1);
	  _FI_g_dump ( (struct FIgadget_obj *) field->FIfield.list_id);
   }
   else
   {
	  _FI_dump_char (0);
   }
}


void _FI_mcf_dump (struct FImcf_obj *mcfield)
{
   int ii;
   struct FIfld_obj *field;
   int mcf_flags;

   _FI_dump_char (mcfield->FIgroup.dont_pass_on);
   _FI_dump_char (mcfield->FIgroup.single_select);

   _FI_dump_int ( (int) mcfield->FIgroup.size);

   /************************************************/
   /* */
   /* save header_mcf label in column 0's instance */
   /* */
   /************************************************/

   field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[0];
   field->FIgadget.off_color2 = OFF_COLOR2(mcfield);
   field->FIgadget.on_color2 = ON_COLOR2(mcfield);

   for (ii = 0; ii < (int)mcfield->FIgroup.size; ii++)
   {
	  _FI_g_dump (mcfield->FIgroup.gadgets[ii]);
   }
   _FI_dump_short ( (short) mcfield->FImcf.ncol);
   _FI_dump_short ( (short) mcfield->FImcf.nvcol);
   _FI_dump_short ( (short) mcfield->FImcf.col_off);

   mcf_flags = 0;

   if (mcfield->FImcf.flags.uds)
       mcf_flags |= FI_MCF_UDS;

   if (mcfield->FImcf.flags.lrs)
       mcf_flags |= FI_MCF_LRS;

   if (mcfield->FImcf.flags.draw_vscrl)
       mcf_flags |= FI_MCF_DRAW_VSCRL;

   if (mcfield->FImcf.flags.draw_hscrl)
       mcf_flags |= FI_MCF_DRAW_HSCRL;

   if (mcfield->FImcf.flags.disable_vscrl)
       mcf_flags |= FI_MCF_DISABLE_VSCRL;

   if (mcfield->FImcf.flags.disable_hscrl)
       mcf_flags |= FI_MCF_DISABLE_HSCRL;

   if (mcfield->FImcf.flags.row_select)
       mcf_flags |= FI_MCF_ROW_SELECT;

   if (mcfield->FImcf.flags.no_row_buttons)
       mcf_flags |= FI_MCF_NO_ROW_BUTTONS;

   _FI_dump_int (mcf_flags);
}


void _FI_f_dump_form (struct FIform_obj *form)
{
   int ii;
   short num_gadgets = 0;

   struct utsname name;

   long date;

   char person[40];
   short temp_short;

#if (defined(sun) || defined(sparc)) && defined(SYSV)
   char *login_name = (char *) NULL;
   char user_name[40];
#endif

   uname (&name);

   strcpy (person, name.nodename);
   strcat (person, ".");

#if (defined(sun) || defined(sparc)) && defined(SYSV)
   /***************************************************/
   /* sml:01-18-94:TR 249400091:xfb core dumps when   */
   /*  saving file.  Use the suggested cuserid func   */
   /*  and do error checking                          */
   /***************************************************/
   login_name = (char *) cuserid(user_name);
   if (user_name && user_name[0])
     strcat (person, user_name);
   else if (login_name && login_name[0])
     strcat (person, login_name);
   else
     strcat(person, "NOBODY");
#else
   strcat (person, getlogin ()); 
#endif

   date = time ( (long *) 0);

   /* store the current machine's screen attributes */

   if (form->initial_creation)
   {
	  form->screen_width = FI_current_screen_width;
	  form->screen_height = FI_current_screen_height;
   }

   _FI_dump_string ("FIform");

   /* Dump version */

   /* Version went to 4 for the form 8-22-89 1.0.0.11 */

	/*** This version doesn't dump the extra bytes.	***/
	/***  It only dumps a hook byte 		***/

   temp_short = FI_CURRENT_FORM_VERSION;
   _FI_dump_short (temp_short);

   _FI_dump_string (person);

   _FI_dump_int ( (int) date);

   _FI_dump_int (form->attr_mask);
   _FI_dump_int (form->level);

   _FI_dump_short (form->xlo);
   _FI_dump_short (form->ylo);
   _FI_dump_short (form->xhi);
   _FI_dump_short (form->yhi);

   _FI_dump_short (form->orig_xsize);
   _FI_dump_short (form->orig_ysize);

   _FI_dump_short (form->screen_width);
   _FI_dump_short (form->screen_height);

   _FI_dump_short (form->collapse_icon_xpos);
   _FI_dump_short (form->collapse_icon_ypos);

   _FI_dump_char ( (char) form->bgcolor);

   _FI_dump_char ( (char) form->collapse_icon_index);
   _FI_dump_string (form->collapse_icon_file);

	/*** JAJ:02/13/92 ***/
  if ( form->screen == FI_HARDCODED_SCRN )
    {
      form->screen = (char) form->Xscreen;
    }

   _FI_dump_char ( (char) form->screen);

   _FI_dump_short (form->num_desc);

  for (ii = 0; ii < form->num_desc; ii++)
    {
	 _FI_dump_string (form->description[ii]);
    }

   /* dump 2 bytes for hook */
   /* This changed in ver 1.0.0.11 */
   /*
    _FI_dump_short(0);
   */
   /* Dump form start sequence label */

   _FI_dump_int (form->seq_label);

   /* dump number of gadgets in the form group only */

   for (ii = 0; ii < (int)form->group->FIgroup.size; ii++)
   {
	  if (! form->group->FIgroup.gadgets[ii])
	    {
		 continue;
	    }

	  num_gadgets++;
   }

   _FI_dump_short (num_gadgets);
}


void _FI_dump_hooks (struct FIgadget_obj *gadget)
{
        /********************************************************/
        /* The size of the hook can be determined by taking     */
        /*   the integer portion and comparing with the chart   */
        /*  below:                                              */
        /*              1, 2            - Double                */
        /*              3, 4, 5         - Integer               */
        /*              6, 7            - Short                 */
        /*              8, 9            - Char                  */
        /********************************************************/


   int type = gadget->FIgadget.type;


   if ((type == FI_SLIDER) || (type == FI_DIAL))
   {
	  double increment = ((struct FIsld_obj *) gadget)->FIrange.increment;


      /* INCREMENT = 1 */

      /* Only dump increment if not equal to 1.0 */

	  if (increment != 1.0)
	  {
         /* 1 is code for increment */

		 _FI_dump_short (1);
		 _FI_dump_double (increment);
	  }


      /* OPPOSITE_DIR = 8 */

	  if ((type == FI_SLIDER) && (((struct FIsld_obj *) gadget)->FIrange.display_mask & FI_MAX_MIN))
	  {
         /* 8 is code for opposite_dir flag */

		 _FI_dump_short (8);

	/*** No need to dump char because if there	***/
	/*** is a hook at all then this means max->min 	***/
	  }

   }
   else if ((type == FI_TOGGLE) || (type == FI_CHECKLIST) || (type == FI_TEXT) || (type == FI_BUTTON))
   {
      /* Oct 11, 1989 */

      /* JUSTIFICATION = 9 */

      /* 9 is code for increment */

	  _FI_dump_short (9);
	  _FI_dump_char ( (char) gadget->FIgadget.justification);
   }




   /* ERASE COLOR = 18 */

   if (gadget->FIgadget.erase_color > -1)
   {
      /* Oct 20, 1989 */

      /* ERASE COLOR = 18 */

      /* 18 is code for erase color */

	  _FI_dump_short (18);
	  _FI_dump_char ( (char) gadget->FIgadget.erase_color);
   }

   _FI_dump_short (0);
}


int _FI_g_dump (struct FIgadget_obj *gadget)
{
   int type = gadget->FIgadget.type;


   _FI_dump_short ( (short) type);

   /*** Change version to include a hook at the ***/
   /*** end of the gadget instance 		***/

   /* Changed with ver 1.0.0.11 */

   /* Changed version for slider 1.0.0.13 */

   if (gadget->FIgadget.type == FI_SLIDER)
     {
	  _FI_dump_short (5);
     }
   else
     {
	  _FI_dump_short (4);
     }

   _FI_dump_int (gadget->FIgadget.label);

   if (type == FI_GROUP)
   {
	  short num_gadgets;

	/*** Loop through the list of gadgets to see how  ***/
	/*** many gadgets are in the group 		  ***/

	  num_gadgets = (short) _FI_grp_count ((struct FIgroup_obj *)gadget);

	  _FI_dump_short (num_gadgets);

	  _FI_dump_char (((struct FIgroup_obj *) gadget)->FIgroup.dont_pass_on);
	  _FI_dump_char (((struct FIgroup_obj *) gadget)->FIgroup.single_select);

      /* This changed with version 4 of the form ver 1.0.0.11 */
      /* dump 2 bytes */

	  _FI_dump_short (0);

      /* Dump all gadgets in the group here */

	  _FI_grp_pass_on_id_int_always (gadget, _FI_g_dump, 0, 0);

   }
   else
   {
      /* dump common instance */

      /* Dump hooks started with version 4 of the form ver 1.0.0.11 */

	  _FI_dump_hooks (gadget);

	  _FI_dump_int (gadget->FIgadget.pass_label);

	  _FI_dump_int (gadget->FIgadget.next_in_seq);

	/*** If the gadget is a button, and the button	***/
	/*** is a menu button then dump a 1		***/

	  if ((type == FI_BUTTON) && (((struct FIbtn_obj *) gadget)->FIbtn.menu_button == 1))
	  {
		 _FI_dump_short (1);
	  }
	  else
	  {
		 _FI_dump_short (0);
	  }

	  _FI_dump_short ( (short) (gadget->FIgadget.xlo + 0.5));
	  _FI_dump_short ( (short) (gadget->FIgadget.ylo + 0.5));
	  _FI_dump_short ( (short) (gadget->FIgadget.xhi + 0.5));
	  _FI_dump_short ( (short) (gadget->FIgadget.yhi + 0.5));

	  _FI_dump_short ( (short) (gadget->FIgadget.orig_xsize));
	  _FI_dump_short ( (short) (gadget->FIgadget.orig_ysize));

	  _FI_dump_int (gadget->FIgadget.attr_mask);

	  _FI_dump_double (gadget->FIgadget.value);

	  _FI_dump_short ( (short) (gadget->FIgadget.bodysize + 0.5));

	  _FI_dump_short ( (short) (gadget->FIgadget.sym_width_scale_factor + 0.5));
	  _FI_dump_short ( (short) (gadget->FIgadget.sym_height_scale_factor + 0.5));

	  _FI_dump_string ((char *)gadget->FIgadget.text);

	  _FI_dump_string (gadget->FIgadget.help_topic);
	  _FI_dump_string (gadget->FIgadget.command);
	  _FI_dump_string (gadget->FIgadget.fontname);

	  _FI_dump_char ( (char) gadget->FIgadget.symbol_ptr.sym_index);
	  _FI_dump_char ( (char) gadget->FIgadget.on_symbol_ptr.sym_index);

	  _FI_dump_char ( (char) gadget->FIgadget.off_color);
	  _FI_dump_char ( (char) gadget->FIgadget.on_color);
	  _FI_dump_char ( (char) gadget->FIgadget.off_color2);
	  _FI_dump_char ( (char) gadget->FIgadget.on_color2);

	  _FI_dump_char (gadget->FIgadget.effect);
   }

   /* dump specific instance */

   switch (type)
   {

   case FI_TEXT:

	  _FI_dump_short (0);	/* >>>NOT USED<<< WAS bodywidth */
	  _FI_dump_short ( (short) ((struct FItext_obj *) gadget)->FItext.rotation);
	  _FI_dump_short ( (short) ((struct FItext_obj *) gadget)->FItext.spacing);
	  _FI_dump_char ( (char) gadget->FIgadget.justification);
	  break;

   case FI_BUTTON:

	  _FI_dump_char (((struct FIbtn_obj *) gadget)->FIbtn.auto_pop_up);

	  if (((struct FIbtn_obj *) gadget)->FIbtn.menu_button)
	  {
         /* Dump palette name for gadget */

		 _FI_dump_string (((struct FIbtn_obj *) gadget)->FIbtn.palette);
	  }
	  break;

   case FI_GAUGE:

	  _FI_dump_char (((struct FIgauge_obj *) gadget)->FIgauge.type);
	  _FI_dump_double (((struct FIgauge_obj *) gadget)->FIgauge.minor_increments);
	  _FI_dump_double (((struct FIgauge_obj *) gadget)->FIrange.high_value);
	  break;

   case FI_SCROLL:

	  _FI_dump_char (((struct FIscrl_obj *) gadget)->FIscroll.type);
	  _FI_dump_double (((struct FIscrl_obj *) gadget)->FIscroll.view);
	  _FI_dump_double (((struct FIscrl_obj *) gadget)->FIrange.high_value);
	  _FI_dump_double (((struct FIscrl_obj *) gadget)->FIrange.low_value);
	  break;

   case FI_FIELD:

	  _FI_fld_dump ( (struct FIfld_obj *) gadget);
	  break;

   case FI_MULTI_COL:

	  _FI_mcf_dump ( (struct FImcf_obj *) gadget);
	  break;

   case FI_RECT:

	  _FI_dump_char (((struct FIline_obj *) gadget)->FIgraphic.line_weight);
	  _FI_dump_short (((struct FIline_obj *) gadget)->FIgraphic.line_style);

	  break;


   case FI_LINE:

	  _FI_dump_char (((struct FIline_obj *) gadget)->FIgraphic.line_weight);
	  _FI_dump_short (((struct FIline_obj *) gadget)->FIgraphic.line_style);
        /********************************************* JAJ:08/27/91 ****
        _FI_dump_char ( ((struct FIline_obj *)gadget)->
                                                FIline.num_vertices );
        ***************************************************************/

        _FI_dump_char ( (char) 0 ); /*** num_vertices is no longer ***/
                                    /*** used -- JAJ:08/27/91      ***/

	  break;

   case FI_TOGGLE:

	  if (IT_HAS_TEXT(gadget))
	    {
		 _FI_dump_string ((char *)((struct FItog_obj *) gadget)->FItog.on_text);
	    }

	  break;

   case FI_SLIDER:

	  _FI_dump_char (((struct FIsld_obj *) gadget)->FIslider.type);
	  _FI_dump_double (((struct FIsld_obj *) gadget)->FIrange.low_value);
	  _FI_dump_double (((struct FIsld_obj *) gadget)->FIrange.high_value);

	  _FI_dump_char (((struct FIsld_obj *) gadget)->FIrange.display_mask);

	  _FI_dump_char (((struct FIsld_obj *) gadget)->FIrange.field_width);
	  _FI_dump_char (((struct FIsld_obj *) gadget)->FIrange.decimal_accuracy);

	  break;

   case FI_DIAL:

	  _FI_dump_char (((struct FIdial_obj *) gadget)->FIdial.direction);
	  _FI_dump_double ( (double) ((struct FIdial_obj *) gadget)->FIdial.offset);
	  _FI_dump_double ( (double) ((struct FIdial_obj *) gadget)->FIdial.scale);

	  _FI_dump_short ( (short) ((struct FIdial_obj *) gadget)->FIdial.minor_tick_inc);
	  _FI_dump_short ( (short) ((struct FIdial_obj *) gadget)->FIdial.major_tick_inc);

	  _FI_dump_char (((struct FIdial_obj *) gadget)->FIrange.display_mask);
	  _FI_dump_char (((struct FIdial_obj *) gadget)->FIdial.border_style);

	  _FI_dump_char ( (char) ((struct FIdial_obj *) gadget)->FIrange.field_width);
	  _FI_dump_char ( (char) ((struct FIdial_obj *) gadget)->FIrange.decimal_accuracy);

	  break;

   }

  return ( FI_SUCCESS );
}



/* This function saves an existing form and all its gadgets */
/* to the file specified. It returns some status code telling */
/* whether or not the save was successfully performed. */

int FIf_save (Form   form,
              char  *path)
{
   FILE *fout;

   int xx;

   jmp_buf env;

   /* error handling */


   xx = setjmp (env);
   if (xx)
     {
	  return (xx);
     }


   fout = fopen (path, "w");
   if (fout)
   {
	  _FI_dump_enter (fout, env);

      /* dump form */

	  _FI_f_dump_form ( (struct FIform_obj *) form);

      /* dump gadgets */

	  _FI_grp_pass_on_id_int_always (
		(struct FIgadget_obj *) ((struct FIform_obj *) form)->group, _FI_g_dump, 0, 0);

      /* end of file marker */

	  _FI_dump_short ( (short) FI_END_OF_FILE);

	  fclose (fout);
   }
   else
   {
	  if (errno == EACCES)
             {
		 return (FI_FORM_FILE_OPEN_DENIED);
             }
	  else
             {
		 return (FI_UNABLE_TO_SAVE_FORM);
             }
   }

   return (FI_SUCCESS);
}
