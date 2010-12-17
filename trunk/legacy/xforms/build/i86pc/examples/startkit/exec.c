#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#include <stdio.h>
#include <FI.h>

#include "XFIproto_pub.h"

/*
#include <math.h>
#include <time.h>
#include "exec.h"
*/



extern char *strrchr();


char *form_name = "my_form";
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
   printf ("-f form name.\n");
   printf ("-p form search path.\n");
   printf ("-s synchronize.\n");
   printf ("-? help. Print this message.\n");
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
   switch ( gadget_label )
   {
        case FI_ACCEPT:	
        case FI_CANCEL:	
          FIf_erase ( form );
          break;		
   }     
}    





/***************************************************************

		function InitExec()

***************************************************************/

/*
 *  This function loads and displays the form.
 */

int InitExec( )
{
	Form	fp;
	int		sts;

	sts = FIf_new( 555, form_name, notification_routine, &fp );
	if( sts ) {
		fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
		return sts;
	}
	sts = FIf_display( fp );

	return sts;
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

/***********************************************

		main()

***********************************************/

main (argc, argv)
int argc;
char *argv[];
{
   char *display_name = "", *ptr, *search_path = ".";
   int i, sync = 0;
   int	sts;

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

	  case 'f':
		 form_name = argv[i];
		 break;

	  case 'p':
		 search_path = argv[i];
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

   FI_set_form_path (search_path);

	FI_set_symbol_path( "." );

	sts = InitExec( );

	if( !sts )
		FI_process_forms( );

	XCloseDisplay( display );
}

