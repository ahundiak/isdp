#include <stdio.h>

#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#include <FI.h>
#include <FEI.h>

#include "XFIproto_pub.h"

#define KEY_BUF_SIZE	256

char	key_buf[ KEY_BUF_SIZE ];



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




/********************************************************

		function test_note

*********************************************************/
/* ARGSUSED */
/*void test_note( f_label, g_label, value, fp ) */
int test_note( f_label, g_label, value, fp )
int	f_label, g_label;
double	value;
Form	fp;
{
	printf( "Gadget Notified #%d\n", g_label );
	switch( g_label ) {
	case FI_ACCEPT:
		FIf_delete( fp );
		break;
	}
	return(FI_SUCCESS);
}

/***************************************************************

		function init_test()

***************************************************************/

/*
 *  This function loads and displays the form.
 */

int init_test( form_name )
char	*form_name;
{	Form	fp;
	int	sts;

	sts = FIf_new( 1, form_name, test_note, &fp );

	if( sts != FI_SUCCESS ) {
		fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
		return	sts;
	}

	sts = FIf_set_location( fp, 0, 0 );

	sts |= FIf_display( fp );

	return sts;
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

int	FEI_map_character( );		/** In dec_fei.c **/




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



    /***
	Override the current routines so the application will be able
	to parse the DEC character sequences.
    ***/

    FI_modify_env ( FI_MAP_CHARACTER, FEI_map_character );

    FI_set_form_path( "." );

    if( init_test( "dec_form" ) == FI_SUCCESS )
	FI_process_forms( );

    XCloseDisplay( display );
}
