#include <stdio.h>
#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#include "FI.h"

#define FLD1 13
#define FLD2 14
#define FLD3 15





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




/***************************************

	notification_routine()

***************************************/

/* ARGSUSED */
notification_routine ( form_label, gadget_label, value, form )
int	form_label;
int	gadget_label;
double	value;
Form	form;
{
   FIg_get_value ( form, gadget_label, &value );

   switch ( gadget_label )
   {
        case FI_ACCEPT:	
        case FI_CANCEL:	
          FIf_erase ( form );
          break;		

	case FLD1:
		if ( ( value >= 0.0 ) && ( value <= 10.0 ) )
			FIg_set_next_in_seq ( form, FLD1, FLD2 );
		else
			FIg_set_next_in_seq ( form, FLD1, FLD1 );
	  break;

	case FLD2:
		if ( ( value >= 10.0 ) && ( value <= 20.0 ) )
			FIg_set_next_in_seq ( form, FLD2, FLD3 );
		else
			FIg_set_next_in_seq ( form, FLD2, FLD2 );
	  break;

	case FLD3:
		if ( ( value >= 20.0 ) && ( value <= 30.0 ) )
			FIg_set_next_in_seq ( form, FLD3, FLD1 );
		else
			FIg_set_next_in_seq ( form, FLD3, FLD3 );
	  break;
   }     
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

  sts = FIf_new ( 100, "nav.form", notification_routine, &form );
  if ( sts ) 
  {	
    fprintf(stderr,"FORM CREATE ERROR %d\n",sts );
    exit(0);
  }

  FIf_set_start_seq ( form, FLD1 );

  FIf_display ( form );

	if( !sts )
		FI_process_forms( );

	XCloseDisplay( display );
}
