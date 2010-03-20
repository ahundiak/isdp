/*  main()
 *
 *  This is the main function.  It performs the neccessary initialization
 *  and creates the menus and then enters a loop which just passes events
 *  to the forms and menus sub-systems.
 */

#include <stdio.h>
#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#include "FI.h"
#include "FIdyn.h"
#include "ex1.h"
#include "ex1gvar.h"


struct standard_st std_var;


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

	FI_set_form_path( "." );

  FI_set_symbol_path ( ".:../../sym" );
  sts = wall_form();

 	if( !sts )
		FI_process_forms( );

	XCloseDisplay( display );

}
