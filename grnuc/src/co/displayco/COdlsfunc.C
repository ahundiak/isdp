/*
  Description
    Form initialization and notification routines for define linestyle.

  Notes

  History
    dhm    07/??/91    Creation date.
    dhm    09/18/91    Conversion date to functions.
    dhm    09/20/91    Erase the form before calling the dpb so that the 
                       dpb will update the adp form.
    bd     12/06/91    Changed name of global variables to dp_bit_pattern and
		       dp_save_pattern to avoid naming conflicts.
    elp    01/12/93    port to NT
    scw    08/03/94    Added X11 to x includes
*/

#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "exmacros.h"

/* prototype file needed for macro definitions to follow */
#include "GRdpbfunc.h"
#include "grdpbmacros.h"

#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "dpdls.h"

#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#ifdef X11
#  include "X11/Xlib.h"
#  include "X11/Xutil.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#  if 0  /* because opp can not handle it */
#     if defined( X11 )
#       include <XFIproto_pub.h>
#     elif defined( ENV5 )
#       include <FIproto_pub.h>
#     elif defined( NT )
#       include <shampub.h>
#     endif
#  else
#    include <FI.h>
#  endif
#else
#  include <FI.h>
#endif

/* prototype files */
#include "dpsetdsp.h"
#include "DPpattern.h"
#include "COdlsfunc.h"

static  IGRshort DLSindex;
static  IGRshort disable;
static  IGRshort copy_mode;
unsigned short dp_bit_pattern[MAX_STYLES];
unsigned short dp_save_pattern[MAX_STYLES];


void dls_form_init(create, dls_form_ptr)

IGRint create;
Form   *dls_form_ptr;

{
  Form       form_ptr=NULL;
  IGRshort   i, shift;
  IGRint     fld_label, display_sts;
  IGRdouble  tmp_dbl;
  IGRchar    pattern_buff[20], msg_buff[100];
  struct IGRdisplay   display_buff;
  int        dls_form_notification(IGRint, IGRint, IGRdouble, Form);

  copy_mode = FALSE;

  /*
   * Create the new form if not already created.
   */

  if (create)
  {
    FIf_new (DLS_FORM, "GRDefineLine", dls_form_notification, dls_form_ptr);
  }
  else
  {
    form_ptr = *dls_form_ptr;
  }

  /* 
   * Erase the other title for this form.
   */

  FIg_erase(form_ptr, UNNECESSARY_TITLE);

  /*
   * Set the number of rows.
   */

  FIfld_set_max_num_rows(form_ptr, LINESTYLE_FIELD, MAX_STYLES);

  /*
   * Get the linestyle patterns.
   */

  for (i = 0; i < MAX_STYLES; i++)
  {
    DPinq_style(i, &dp_bit_pattern[i]);
    dp_save_pattern[i] = dp_bit_pattern[i];
  }

  /*
   * Get the active linestyle.
   */

  gr$get_active_display(buffer = (IGRchar *)&display_buff);

  /*
   * Set the index field and the button bits to reflect the active linestyle.
   */

  tmp_dbl = (IGRdouble) display_buff.style;
  FIfld_set_value(form_ptr, INDEX_FIELD, 0, 0, tmp_dbl, FALSE);

  DLSindex = (short) tmp_dbl;
  shift = dp_bit_pattern[DLSindex];
  fld_label = 19;
  for (i = 0; i < 16; i++)
  {
    if (0x8000 & shift)
      FIg_set_state_on(form_ptr, fld_label);
    else
      FIg_set_state_off(form_ptr, fld_label);

    shift <<= 1;
    fld_label++;
  }

  if (DLSindex < BUILTIN_STYLES)
  {
     disable = TRUE;

     ex$message(msgnumb = GR_E_NoEdit0to7,
                buff = msg_buff);

     FIfld_set_text(form_ptr, DLS_MESSAGE_FIELD, 0, 0, msg_buff, FALSE);

     fld_label = 19;
     for (i = 0; i < 16; i++, fld_label++)
        FIg_disable(form_ptr, fld_label);  /* disable buttons */
  }
  else
     disable = FALSE;

  /*
   * Set the linestyle field with the index and the corresponding linestyle
   * pattern.
   */

  for(i = 0; i < MAX_STYLES; i++)
  {
    tmp_dbl = (IGRdouble) i;
    FIfld_set_value(form_ptr, LINESTYLE_FIELD, i, 0, tmp_dbl, FALSE);

    DPpattern(dp_bit_pattern[i], pattern_buff);

    FIfld_set_text(form_ptr, LINESTYLE_FIELD, i, 1, pattern_buff, FALSE);
  }

  /*
   * Set the active row to the active linestyle.
   */

  FIfld_set_active_row(form_ptr, LINESTYLE_FIELD, DLSindex, 0);

  /*
   * If the form isn't displayed, then display it here
   */

  FIf_is_displayed(form_ptr, &display_sts);

  if (! display_sts )
  {
    FIf_display(form_ptr);
  }


}  /* end dls_form_init */


#argsused
int dls_form_notification(IGRint    form_label,
			  IGRint    gadget_label,
			  IGRdouble value,
			  Form      form_ptr )
{
  IGRshort i;
  IGRint   flag, pos, row, toggle_state, sts, fld_label;
  IGRlong  buff_size, msg;
  IGRchar  pattern_buff[20], msg_buff[100];
  IGRdouble  tmp_dbl;
  struct IGRdisplay  display_buff;
  struct GRevent     event;
  unsigned short     shift;

  /*
   * Be sure the message field is cleared.
   */

  FIfld_set_text(form_ptr, DLS_MESSAGE_FIELD, 0, 0, "", FALSE);


  switch ( gadget_label )
  {
    case INDEX_FIELD:
      /*
       * Get index and set toggles to reflect index chosen.
       */

      FIfld_get_value(form_ptr, INDEX_FIELD, 0, 0, &tmp_dbl, &flag, &pos);

      i = (short) tmp_dbl;

      if (i >= MAX_STYLES)
      {
        ex$message(msgnumb = GR_E_InvIndex,
                   buff = msg_buff);

        FIfld_set_text(form_ptr, DLS_MESSAGE_FIELD, 0, 0, msg_buff, FALSE);
      }
      else
      {
        DLSindex = i;

        shift = dp_bit_pattern[DLSindex];
        fld_label = 19;
        for (i = 0; i < 16; i++)
        {
          if (0x8000 & shift)
            FIg_set_state_on(form_ptr, fld_label);
          else
            FIg_set_state_off(form_ptr, fld_label);

          shift <<= 1;
          fld_label++;
        }

        if ( (DLSindex < BUILTIN_STYLES) && (! copy_mode) )
        {
          disable = TRUE;

          ex$message(msgnumb = GR_E_NoEdit0to7,
                     buff = msg_buff);

          FIfld_set_text(form_ptr, DLS_MESSAGE_FIELD, 0, 0, msg_buff, FALSE);

          fld_label = 19;
          for (i = 0; i < 16; i++, fld_label++)
             FIg_disable(form_ptr, fld_label);  /* disable bit toggles */
        }
        else if ( (disable) && (! copy_mode) )
        {
          disable = FALSE;

          fld_label = 19;
          for (i = 0; i < 16; i++, fld_label++)
             FIg_enable(form_ptr, fld_label);  /* enable bit toggles */
        }

      }  /* end else good index */

      break;


    case BIT1:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x8000;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x8000;
      }
 
      break;


    case BIT2:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x4000;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x4000;
      }

      break;


    case BIT3:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x2000;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x2000;
      }

      break;


    case BIT4:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x1000;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x1000;
      }

      break;


    case BIT5:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x0800;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x0800;
      }

      break;


    case BIT6:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x0400;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x0400;
      }

      break;


    case BIT7:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x0200;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x0200;
      }

      break;


    case BIT8:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x0100;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x0100;
      }

      break;


    case BIT9:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x0080;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x0080;
      }

      break;


    case BIT10:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x0040;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x0040;
      }

      break;


    case BIT11:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x0020;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x0020;
      }

      break;


    case BIT12:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x0010;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x0010;
      }

      break;


    case BIT13:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x0008;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x0008;
      }

      break;


    case BIT14:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x0004;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x0004;
      }

      break;


    case BIT15:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x0002;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x0002;
      }

      break;


    case BIT16:
      toggle_state = (IGRint) value;

      if (toggle_state == 1)
      {
        dp_bit_pattern[DLSindex] |= 0x0001;
      }
      else if (toggle_state == 0)
      {
        dp_bit_pattern[DLSindex] &= ~0x0001;
      }

      break;


    case PROCESS_STYLE:
      FIg_set_state_off(form_ptr, PROCESS_STYLE);

      /*
       * Insert the linestyle pattern into the corresponding index.
       */

      if ( DLSindex < BUILTIN_STYLES || DLSindex >= MAX_STYLES )
      {
        ex$message(msgnumb = GR_E_InvIndex,
                   buff = msg_buff);

        FIfld_set_text(form_ptr, DLS_MESSAGE_FIELD, 0, 0, msg_buff, FALSE);
      }
      else if (dp_bit_pattern[DLSindex] == 0x0000)
      {
        ex$message(msgnumb = GR_E_InvLnStyl,
                   buff = msg_buff);

        FIfld_set_text(form_ptr, DLS_MESSAGE_FIELD, 0, 0, msg_buff, FALSE);
      }
      else
      {
        DPpattern(dp_bit_pattern[DLSindex], pattern_buff);

        FIfld_set_text(form_ptr, LINESTYLE_FIELD, DLSindex, 1, pattern_buff,
                       FALSE);

        FIfld_set_active_row(form_ptr, LINESTYLE_FIELD, DLSindex, 0);

        DPdefine_style(DLSindex, dp_bit_pattern[DLSindex]);

      }

      break;


    case LINESTYLE_FIELD:
      /*
       * Edit Mode:
       * This is a single-select field only.  If selected, then I copy the 
       * index to the index field and set the pattern buttons.
       * Copy Mode:
       * This is a multi-select field only.  If it is selected, then I need to
       * copy the current index pattern to the row the user selected.
       */

      FIfld_get_active_row(form_ptr, LINESTYLE_FIELD, &row, &pos);

      if (row < BUILTIN_STYLES)  /* can't copy into the first eight */
      {
        ex$message(msgnumb = GR_E_NoEdit0to7,
                   buff = msg_buff);

        FIfld_set_text(form_ptr, DLS_MESSAGE_FIELD, 0, 0, msg_buff, FALSE);
      }

      if (copy_mode)
      {
        if (row >= BUILTIN_STYLES)
        {
          DPpattern(dp_bit_pattern[DLSindex], pattern_buff);

          FIfld_set_text(form_ptr, LINESTYLE_FIELD, row, 1, pattern_buff,
                         FALSE);

          dp_bit_pattern[row] = dp_bit_pattern[DLSindex];

          DPdefine_style(row, dp_bit_pattern[row]);
        }
      }
      else
      {
        DLSindex = (IGRshort) row;

        tmp_dbl = (IGRdouble) DLSindex;
        FIfld_set_value(form_ptr, INDEX_FIELD, 0, 0, tmp_dbl, FALSE);

        shift = dp_bit_pattern[DLSindex];
        fld_label = 19;
        for (i = 0; i < 16; i++)
        {
          if (0x8000 & shift)
            FIg_set_state_on(form_ptr, fld_label);
          else
            FIg_set_state_off(form_ptr, fld_label);

          shift <<= 1;
          fld_label++;
        }

        if (row < BUILTIN_STYLES)
        {
          fld_label = 19;
          for (i = 0; i < 16; i++, fld_label++)
             FIg_disable(form_ptr, fld_label);

          disable = TRUE;
        }
        else if (disable)
        {
          fld_label = 19;
          for (i = 0; i < 16; i++, fld_label++)
             FIg_enable(form_ptr, fld_label);

          disable = FALSE;
        }

      }

      break;


    case MODE_TOGGLE:
      toggle_state = (int) value;

      if (toggle_state == 1)  /* edit mode */
      {
        copy_mode = FALSE;

        FIfld_set_mode(form_ptr, LINESTYLE_FIELD, 0, FI_SINGLE_SELECT);
        FIfld_set_mode(form_ptr, LINESTYLE_FIELD, 1, FI_SINGLE_SELECT);

        if (DLSindex >= BUILTIN_STYLES)
        {
          FIg_enable(form_ptr, PROCESS_STYLE);

          fld_label = 19;
          for (i = 0; i < 16; i++, fld_label++)
             FIg_enable(form_ptr, fld_label);

          disable = FALSE;
        }

      }
      else if (toggle_state == 0)  /* copy mode */
      {
        copy_mode = TRUE;

        FIfld_set_mode(form_ptr, LINESTYLE_FIELD, 0, FI_MULTI_SELECT);
        FIfld_set_mode(form_ptr, LINESTYLE_FIELD, 1, FI_MULTI_SELECT);

        if (! disable)
        {
          FIg_disable(form_ptr, PROCESS_STYLE);

          fld_label = 19;
          for (i = 0; i < 16; i++, fld_label++)
             FIg_disable(form_ptr, fld_label);

          disable = TRUE;
        }

      }

      break;


    case CVT_TO_WINDOW:
      /*
       *  Forms code takes care of it.
       */

      break;


    case SAVE_EXIT_BTN:
      /*
       * Erase the form before the dpb call so that the adp form will be
       * updated.   dhm   9/20/91
       */

      FIf_erase(form_ptr);

      /*
       * Set the active linestyle to the current index.
       */

      gr$get_active_display(buffer = (IGRchar *)&display_buff);

      display_buff.style = (IGRuchar) DLSindex;

      gr$put_active_display(buffer = (IGRchar *)&display_buff);

      /* no break here; so can do the exit and return to COB */


    case EXIT_BTN:
      FIf_is_displayed(form_ptr, &sts);

      if (sts)
      {
        FIf_erase(form_ptr);
      }

      /*
       * Set the patterns back to straight lines since the user doesn't 
       * want to change them.    dhm   9/20/91
       */

      if (gadget_label == EXIT_BTN)
      {
        for (i = 8; i < MAX_STYLES; i++)
        {
           DPdefine_style(i, dp_save_pattern[i]);
        }
      }

      /*
       * Put form finished on the queue.
       */

      event.response = EX_FORM_FINISHED;
      buff_size = sizeof(struct GRevent) - (sizeof(IGRint) * 2);

      ex$putque(msg = &msg,
                response = &event.response,
                byte = &buff_size,
                buffer = (IGRchar *)&event.event);

      break;


    default:
      FIf_is_displayed(form_ptr, &sts);

      if (sts)
      {
        FIf_erase(form_ptr);
      }

      break;

  }  /* end switch for gadget_label  */


  return FI_SUCCESS;

}  /* end form_notification */

