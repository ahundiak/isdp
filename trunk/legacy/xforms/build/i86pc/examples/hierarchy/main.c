/*==============================================================================

	This example assumes that you already know a little about the FORMS
	system.  Things you should know about:

		o Creating a form
		o Form notification routines

==============================================================================*/

#include <stdio.h>
#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#include <FI.h>

#include "main.h"

extern char *strrchr();


Display *display;

/***********************************************************

		function Syntax ()

************************************************************/

/*
 *  This function lists the acceptable command line arguments for this
 *  program.
 */

Syntax (pn, arg)
char *pn, *arg;
{
   printf ("%s: bad argument <%s>\n", pn, arg);
   printf ("-d display. node:display.screen\n");
   printf ("-s synchronize.\n");
   printf ("-? help. Print this message.\n");
}




/*============================================ DEBUG ==========================*/


/***************************************************************

		Sync_on(), Sync_off()

****************************************************************/

/*
 *  Synchronizing can be used to facilitate debugging in XForms, but slows
 *  performance dramatically.
 */

int Sync_on ()
{
   XSynchronize (display, True);
   printf ("Synchronize--ON\n");
   return (FI_SUCCESS);
}

int Sync_off ()
{
   XSynchronize (display, False);
   printf ("Synchronize--OFF\n");
   return (FI_SUCCESS);	
}


/*************************************

	Child_note_routine

*************************************/

/* ARGSUSED */
Child_note_routine ( form_label, gadget_label, value, form )
int	form_label;
int	gadget_label;
double	value;
Form	form;
{
int		x_size, y_size, status;
extern int	FIg_call_notification_routine( );

    switch( gadget_label ) {
    case SUB_FORM_BTN:

	/*** Figure out relative location. ***/

	FIf_get_size( form, &x_size, &y_size );

	/*** Disable gadget to eliminate recursion. ***/

	FIg_disable( form, gadget_label );

	/*** Place the new form below the current form. ***/

	status = New_child( form, gadget_label, 0, y_size );

	/*** Enable the gadget in case the user wants to try again ***/

	if( status )
	{
	    FIg_enable( form, gadget_label );
	    FIg_set_state_off( form, gadget_label );
	}

	break;

    case FI_CANCEL:

	/*** When this form is called back it will look like the cancel
	     button was pressed (extremely optional).
	***/

	FIg_set_state_on( form, FI_CANCEL );
    
    case FI_ACCEPT:

	/*** Call the reply routine with the form_label, which was the gadget
	     label that created this form.  The reply routine will enable
	     that gadget so it can be used again.
	***/

	FIh_reply_to_parent( form, form_label );

	/*** This will FI_CANCEL any of this form's children (starting with the
	     last one.
	***/

	FIh_callback( form, 0, 0, FIg_call_notification_routine,
		FI_CANCEL );

	/*** The following will complete disassociate this form from its
	     parent.
	***/

	FIh_detach_from_parent( form );
	FIf_delete ( form );
	break;
    }
}

/*************************************

		New_child()

*************************************/

int New_child( parent_form, gadget_label, x_rel_loc, y_rel_loc )
Form	parent_form;
int	gadget_label, x_rel_loc, y_rel_loc;
{
Form		child_form;
int		status;
extern int 	Parent_reply( );

    /*** The form label vv is a handy place to store information ***/

    status = FIf_new ( gadget_label, "child_form", Child_note_routine,
								&child_form );
    if ( status ) 
    {
    	fprintf(stderr,"FORM CREATE ERROR %d\n",status );
    	return(-1);
    }

    /*** Create the parent-child relationship ***/

    FIh_attach_to_parent( child_form, parent_form );

    /*** Set up the communication routine between the parent and _all_ of its
	 immediate children.
    ***/

    FIh_set_reply_routine( child_form, Parent_reply );

    /*** Adjust the child form's location relative to the parent's ***/

    FIf_set_rel_location( child_form, x_rel_loc, y_rel_loc, parent_form );

    status = FIf_display( child_form );
    if ( status ) 
    {
    	fprintf(stderr,"FORM DISPLAY ERROR %d\n",status );
	FIh_detach_from_parent( child_form );
    	FIf_delete( child_form );
    	return(-1);
    }

    return status;
}





/********************************************************

		function notification_routine

*********************************************************/

/* ARGSUSED */
notification_routine ( form_label, gadget_label, value, form )
int	form_label;
int	gadget_label;
double	value;
Form	form;
{
int		x_rel_loc, y_rel_loc, x_size, y_size;
extern int	FIg_call_notification_routine( );

    switch ( gadget_label )
    {
    case CHILD_1_BTN:	case CHILD_2_BTN:
    case CHILD_3_BTN:	case CHILD_4_BTN:

	/*** Figure out relative location ***/

	FIg_get_location( form, gadget_label, &x_rel_loc, &y_rel_loc );
	FIg_get_size( form, gadget_label, &x_size, &y_size );

	/*** Disable gadget to eliminate recursion ***/

	FIg_disable( form, gadget_label );

	/*** Create a new child form and place it below the button which
	     was pressed.
	***/

	New_child( form, gadget_label, x_rel_loc, y_rel_loc + y_size );

	break;

    case FI_ACCEPT:	
    case FI_CANCEL:
	/*** This will FI_CANCEL any of this form's children (starting with the
	     last one).
	***/

	FIh_callback( form, 0, 0, FIg_call_notification_routine, FI_CANCEL );
	FIf_delete ( form );
	break;		
    }
}

/********************************************************

		function Parent_reply

*********************************************************/

/*============================================================================*/
/*
    This routine allows the parent's children to communicate to it.

    (user_arg could be a pointer to a structure so more information can be
    transferred back to the parent)
*/
Parent_reply( form, user_arg )
Form	form;
int	user_arg;
{
    /*** Enable gadget (button) which called the child form. ***/

    FIg_enable( form, user_arg );

    /*** Pop the button back up. ***/

    FIg_set_state_off( form, user_arg );
}


/***********************************************

		main()

***********************************************/

main (argc, argv)
int argc;
char *argv[];
{
   char *display_name = "", *ptr;
   int i, sync = 0;
   int	sts;
   Form form;


   /** Find the display argument after 0th argument **/

   /** Set up program name **/


   ptr = strrchr (argv[0], '/');
   if (ptr)
   {
	  argv[0]= ptr + 1;
   }

   /*** Parse the command line ***/

   for (i = 1; i < argc; i++)
   {
	  if (argv[i][0]!= '-')
		 Syntax (argv[0], argv[i]);

	  switch (argv[i++][1])
	  {
	  case 'd':
		 display_name = argv[i];
		 break;

	  case 's':
		 sync = 1;
		 i--;
		 break;

	  default:
		 Syntax (argv[0], argv[i]);
	  }
   }	/** END for **/

   if ((display = XOpenDisplay (display_name)) == None)
   {
	  fprintf (stderr , "%s: cannot connect to X server %s\n", XDisplayName (display_name));
	  exit (-1);
   }

   if (sync)
   {
	  Sync_on ();
   }

   FSEnter ( display, 0 );

   FI_enter (display, DefaultColormap(display,DefaultScreen(display)) , 32);


  FI_set_form_path ( "." );

  /*
   Load form into memory.  The function notification_routine will be called
   whenever a gadget is updated.  The file notify.c defines 
   notification_routine. 
  */

  sts = FIf_new ( 100, "parent_form", notification_routine, &form );
  if ( sts ) 
  {	
    fprintf(stderr,"FORM CREATE ERROR %d\n",sts );
    exit(0);
  }

  /*
   Adjust the location of the new form.
  */

  FIf_set_location( form, X_LOC, Y_LOC );

  /*
   Create the initial parent (root) form, which the other sub-forms will
   be attached.
  */

  FIh_attach_to_parent( form, NULL );

  /*
   Set up the communication routine between the parent and _all_ of its
   immediate children.
  */

  FIh_set_reply_routine( form, Parent_reply );

	/* display the form */

  FIf_display ( form );

  /* This will process all forms until 
     there are no forms left displayed */

	if( !sts )
		FI_process_forms( );

	XCloseDisplay( display );
}
