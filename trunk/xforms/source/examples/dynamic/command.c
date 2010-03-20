/*  void process_command ( menu_type, cmd_type, cmd )
 *
 *  This is the function given when the menus are created and
 *  will be called, any time selection is made from one of the
 *  menus.
 */

#include <stdio.h>
#include <X11/Xlib.h>
#include "FI.h"
#include "FI.h"
#include "FIdyn.h"
#include "ex2.h"
#include "ex2gvare.h"

extern Display *display;

extern void notification_routine();

/* ARGSUSED */
process_menu_command ( cmd_type, cmd )
  int  cmd_type;
  char *cmd;
{
  int cmd_num;

/*
 *  The number of the button is passed in as an ascii string,
 *  so change it into integer to do the switch.
 */
  cmd_num = atoi( cmd );	

  switch( cmd_num ) {

    case DEF_FIELD:
      if ( form_created )
        do_field();
      break;

    case DEF_CHECK:
/*
 *  If the form is there, create the checklist gadget.
 */
      if ( form_created )
        do_check();
      break;

/*
 *  If the form is there, create the text gadget.
 */
    case DEF_TEXT:
      if ( form_created )
        do_text();
      break;

/*
 *  If the form is there, create the symbol gadget.
 */
    case DEF_SYM:
      if ( form_created )
        do_sym();
      break;

/*
 *  If the form is there, create the button gadget.
 */
    case DEF_BUTTON:
      if ( form_created )
        do_button();
      break;

/*
 *  If the form is there, create the toggle gadget.
 */
    case DEF_TOGGLE:
      if ( form_created )
        do_toggle();
      break;

/*
 *  If the form is there, create the dial gadget.
 */
    case DEF_DIAL:
      if ( form_created )
        do_dial();
      break;

/*
 *  If the form is there, create the slider gadget.
 */
    case DEF_SLIDER:
      if ( form_created )
        do_slider();
      break;

/*
 *  If the form is there, create the line gadget.
 */
    case DEF_LINE:
      if ( form_created )
        do_line();
      break;

/*
 *  If the form is there, create the bezel gadget.
 */
    case DEF_BEZEL:
      if ( form_created )
        do_bezel();
      break;

/*
 *  If the form is there, create the gauge gadget.
 */
    case DEF_GAUGE:
      if ( form_created )
        do_gauge();
      break;

/*
 *  If the form is there, create the mcf gadget.
 */
    case DEF_MCF:
      if ( form_created )
        do_mcf();
      break;

/*
 *  If the form is there, create the scroll gadget.
 */
    case DEF_SCROLL:
      if ( form_created )
        do_scroll();
      break;

/*
 *  If the form is there, create the control bar gadgets.
 */
    case DEF_CBAR:
      if ( form_created )
        do_cbar();
      break;

/*
 *  Create the form and the group gadget.
 */
    case CREATE_FORM:
      do_form( CREATE_FORM );
      break;
/*
 *  Delete the form and anything associated with it.
 */
    case DELETE_FORM:
      do_form( DELETE_FORM );
/*
 *  Set the gadget defined flags to FALSE so we can create them
 *  again when there is a form.
 */
      field_defined = FALSE;
      check_defined = FALSE;
      text_defined = FALSE;
      sym_defined = FALSE;
      button_defined = FALSE;
      toggle_defined = FALSE;
      dial_defined = FALSE;
      slider_defined = FALSE;
      line_defined = FALSE;
      bezel_defined = FALSE;
      gauge_defined = FALSE;
      mcf_defined = FALSE;
      scroll_defined = FALSE;
      cbar_defined = FALSE;

      break;

/*
 *  Display the form and all gadgets which are set to display.
 *  If any gadgets were defined but erased when the form was
 *  erased, they will not be displayed until explicitly told
 *  to do so.
 */
    case DISPLAY_FORM:
      do_form( DISPLAY_FORM );
      break;

/*  Erase the form.  When it is re-displayed, all gadgets which
 *  were displayed when the form was erased will be displayed
 *  and all gadgets which were erased will not be displayed until
 *  explicitly told to do so.
 */
    case ERASE_FORM:
      do_form( ERASE_FORM );
      break;

/*
 *  Exit.  Kill the menus, forms, exit environ V tools and get out.
 */
    case EXIT:
      do_form( DELETE_FORM );
      MS_delete_menus ();

	  XCloseDisplay (display);

      exit(0);      
      break;

  }
}
