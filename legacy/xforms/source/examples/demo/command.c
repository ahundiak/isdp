
/* 	command.c 	*/
/* COMMAND INTERPRETER */

#include <stdio.h>

#include <FI.h>
#include <FEI.h>
#include <FIdyn.h>
#include <MI.h>
#include <X11/Xlib.h>

#include "XFIproto_pub.h"

#define FORM	100


Form    form = 0;	/*** pointer to the form ***/

extern Display *display;



void DEMO_do_msg_box()
{
  FI_message_box ( FI_CURRENT_SCREEN, 100, 200,
    "JUST A NOTE", FI_BLUE, "dutch801b", 36.0,
    "This is the message box.\n\nIt allows you to have text:\nLeft Justified\nCenter Justified\nRight Justified\nand Fitted text\n  It also allows you to embed format characters like \"\\n\"\n\nHIT THE ACCEPT BUTTON TO DISMISS.",
    FI_BLACK, "dutch801b", 30.0,
    FI_CENTER_JUSTIFIED, 35 );
}



int DEMO_process_command ( cmd_type, cmd_or_help_topic )
  int    cmd_type;
  char * cmd_or_help_topic;
{



  switch ( cmd_type )
    {
      case FI_CMD_STRING_DATA:
      case FI_CMD_KEY_DATA:

	/*******************************/
	/*** CHECK FOR MENU COMMANDS ***/
	/*******************************/

	if ( strcmp ( cmd_or_help_topic, "bar=no" ) == 0 )
	  {
	    MS_swap_menu ( BAR_MENU, "no" );
	  }
	else if ( strcmp ( cmd_or_help_topic, "swap bar" ) == 0 )
	  {
	    MS_swap_menu ( BAR_MENU, "BAR2" );
	  }
	else if ( strcmp ( cmd_or_help_topic, "panel=no" ) == 0 )
	  {
	    MS_swap_menu ( PANEL_MENU, "no" );
	  }
	else if ( strcmp ( cmd_or_help_topic, "swap panel" ) == 0 )
	  {
	    MS_swap_menu ( PANEL_MENU, "PANEL2" );
	  }
	else if ( strcmp ( cmd_or_help_topic, "pocket=no" ) == 0 )
	  {
	    MS_swap_menu ( POCKET_MENU, "no" );
	  }
	else if ( strcmp ( cmd_or_help_topic, "swap pocket" ) == 0 )
	  {
	    MS_swap_menu ( POCKET_MENU, "POCKET2" );
	  }

		/********************************/
		/*** CHECK FOR OTHER COMMANDS ***/
		/********************************/

	else if ( strcmp ( cmd_or_help_topic, "exit" ) == 0 )
	  {
	  if (MS_save_locations ("./menu_locations") != FI_SUCCESS)
		 printf ("menus not saved properly\n");
	  MS_delete_menus ();

	  if (form)
		 FIf_delete (form);
	  XCloseDisplay (display);
	  exit (0);
	  }
	else if ( strcmp ( cmd_or_help_topic, "message" ) == 0 )
	  {
	    DEMO_do_msg_box();
	  }
	else if ( strcmp ( cmd_or_help_topic, "display form" ) == 0 )
	  {
	    int	  status;
            int   form_displayed = 0;

	    extern  int		DEMO_notification_routine();

		/* If form does not exist then create it */

	    if ( ! form )
	      {
	        status = FIf_new ( FORM, "form1",
				 DEMO_notification_routine, &form );

	        if ( status != FI_SUCCESS )
	          {
		      fprintf(stderr,"FORM CREATE ERROR %d\n",status );
		      return(status);
	          }

	        FIf_set_collapse_symbol ( form, "symbol",
						/* 014 octal*/ 12  );
	      }

		/*** see if the form is displayed ***/
	    FIf_is_displayed ( form, & form_displayed );

	    if ( ! form_displayed )
	      {
		    /* Display the form if it's not already displayed */

		FIf_display ( form );
	      }
          }
	break;


    }  /*** switch ( cmd_type ) ***/
	return (FI_SUCCESS);

}


