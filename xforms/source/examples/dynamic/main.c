/*  main()
 *
 *  This is the main function.  It performs the neccessary
 *  initialization and creates the menus and then enters a loop
 *  which just passes events to the forms and menus sub-systems.
 */
 
#include <stdio.h>

#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#include "FIdyn.h"
#include "FEI.h"
#include "FI.h"
#include "ex2.h"
#include "ex2gvar.h"

extern void process_menu_command();

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
   XEvent event;

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

  FI_set_symbol_path ( ".:../../sym" );
  FI_modify_env ( FI_PROCESS_DATA, process_menu_command );
  MS_enter();
  MS_init_menus ( );    
  MS_display_menus ( );

	  while (FI_forms_active ())
	  {
		 XNextEvent (display, &event);

		 if (! FI_process_event (&event, 0))
		 {
			if ((event.type == ButtonPress) && (event.xbutton.button == Button1))
			{
			   MS_process_pocket (0, event.xbutton.x_root, event.xbutton.y_root);

               /* This call simply displays the loaded pocket
               menu in the coordinates (xpos and ypos)and 
               virtual screen(vs). */
			}
		 }
	  }
   XCloseDisplay (display);

}



