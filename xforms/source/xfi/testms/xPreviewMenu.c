#include <stdio.h>
#include <string.h>

#include "FI.h"
#include "FEI.h"

#include <X11/Xlib.h>


#include "MSext.h"            /* dmb:10/08/92:Added */
#include "MS.h"            /* dmb:10/08/92:Added */
#include "MI.h"            /* dmb:10/08/92:Added */
#include "XFIproto_pub.h"     /* dmb:10/08/92:Added */
/* dmb:10/08/92:Added */
#define NULL_FORM (struct FIform_obj *) 0 
static struct FIform_obj * MS_last_form_ptr = NULL_FORM;
static int         MS_last_gadget_label = -1;

extern int FI_current_screen_width;
/* dmb:10/08/92:Added */

#if !defined(licensing_off)
	 /* I/Lic_tool stuff -- JAJ:01/25/92 ***/
#include "api.h"
#endif

#ifndef TRUE
#define TRUE    1
#endif

#ifndef FALSE
#define FALSE   0
#endif

extern void exit ();

Display *display;



/*======================== ERROR MESSAGE ============================*/

int UnrecognizedArg (pn, arg)
  char *pn, *arg;
{
   fprintf ( stderr, "%s: Unrecognized argument <%s>\n", pn, arg );
   return (FI_SUCCESS);
}


/*========================== USAGE MESSAGE ===========================*/

int HelpMsg (pn)
char *pn;
{
   printf ("Usage: %s [options]\n", pn);
   printf ("Options:\n");
   printf (" -d display_name  X Server display to use\n");
   printf ("                    display_name format is node:display.screen\n");
   printf (" -f form_name     Form to preview\n");
   printf (" -h               Display help message\n");
   printf (" -p form_path     Directory path to the form\n");
   printf (" -s symbol_path   Directory path to symbol files\n");
   printf (" -z               Turn on X Synchronize\n");
   return (FI_SUCCESS);
}


/*======================= NOTIFICATION ROUTINE =======================*/

/* ARGSUSED */
int note_routine (form, gadget_label, value, fp)
  int form, gadget_label;
  double value;
  Form fp;
{
  fprintf ( stderr, "FIf_preview: label = %d\n", gadget_label );
  fflush ( stderr );

  if ( ( gadget_label == FI_ACCEPT ) || ( gadget_label == FI_CANCEL ) )
	FIf_erase ( fp );
  
   return 0;
}


/*========================= DEBUG: SYNC ON ===========================*/

int Sync_on ()
{
   XSynchronize (display, True);
   fprintf ( stderr, "Synchronize--ON\n" );
   return (FI_SUCCESS);
}


/*========================= DEBUG: SYNC OFF ==========================*/

int Sync_off ()
{
   XSynchronize (display, False);
   fprintf ( stderr, "Synchronize--OFF\n" );
   return (FI_SUCCESS);
}

#if !defined(licensing_off)
/* I/Lic_tool stuff -- JAJ:01/25/92 ***/
API_HANDLE_SHUTDOWN ()
#endif



/* ARGSUSED */
int _my_MS_notify (int                form_label,
                int                gadget_label,
                double             value,
                struct FIform_obj *form_ptr)
{
  if (  ( MS_last_form_ptr != form_ptr )    &&
    ( MS_last_form_ptr != NULL_FORM )    )
    {
      MI_pop_up_button ( (Menu) MS_last_form_ptr,
                     MS_last_gadget_label );
    }

  MS_last_form_ptr  = form_ptr;
  MS_last_gadget_label  = gadget_label;

  return ( MS_SUCCESS );
}

/*============================== MAIN ================================*/

main (argc, argv)
int argc;
char *argv[];
{
   char *display_name = "", *ptr;
   char *search_path = ".";
   char *form_name = "DefaultForm";

/* dmb:05/22/91:This will cause X to fail. */
/* dmb:08/28/91: Can we turn this back on now? */
/*   char *symbol_search_path = "."; */
   char *symbol_search_path = "";

   int i;
   int sync = FALSE;

   int status = FI_SUCCESS;

   Form test_fp;

/* dmb:10/08/92:Added */
  int   bar_xlo = 0;
  int   bar_ylo = 0;
  int   bar_xhi = 0;
  int   bar_yhi = 0;
  int   bar_loc_defined = FALSE;
/* dmb:10/08/92:Added */

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
      {
		 UnrecognizedArg (argv[0], argv[i]);
		 HelpMsg (argv[0]);
      }

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
		 symbol_search_path = argv[i];
		 break;

	  case 'z':
		 sync = TRUE;
		 i--;
		 break;

	  case '?':
	  case 'h':
		 HelpMsg (argv[0]);
		 exit (0);

	  default:
		 UnrecognizedArg (argv[0], argv[i-1]);
		 HelpMsg (argv[0]);
		 exit (-1);    /* dmb:05/01/91:Added */
	  }
   }	/** END for **/

#if !defined(licensing_off)
  /* I/Lic_tool stuff -- JAJ:01/25/92 ***/
  API_GET_LICENSE ( "SN01252", "1992" )
#endif

  if ((display = XOpenDisplay (display_name)) == None)
    {
      fprintf ( stderr , "%s: cannot connect to X server %s\n",
         XDisplayName (display_name));
      exit (-1);
   }

  if (sync)
   {
      Sync_on ();
   }

  FSEnter ( display, 0 );

  FI_enter ( display,
        DefaultColormap(display,DefaultScreen(display)), 32 );

  FI_set_form_path ( search_path );

  FI_set_symbol_path ( symbol_search_path );


  MS_enter ();
  MS_set_startup_file ("./menu_locations");
/*   MS_init_menus (); dmb:10/08/92:Its broke in here...  */

/*  This works */
  status = MIm_new ( BAR_MENU, BAR_MENU, "BAR_MENU", _my_MS_notify,
                     (Form *) &MS_bar_menu );
  if ( status )
  {
    MS_bar_menu = NULL_FORM;
  }
/* Added */
    /* Set bar location */

  if ( MS_bar_menu )
  {
    if ( ! bar_loc_defined )
    {
      if ( MS_panel_menu )  /*** JAJ:09/25/91 ***/
      {
        bar_xlo = MS_panel_menu->xlo - MS_bar_menu->orig_xsize;
      }
      else
      {
        bar_xlo = 0;
      }

      bar_ylo = 0;

      bar_xhi = bar_xlo + MS_bar_menu->orig_xsize;
      bar_yhi = /* bar_ylo + */ MS_bar_menu->orig_ysize;
    }

    FIf_set_size ( (Form) MS_bar_menu, (int) ( bar_xhi - bar_xlo ),
                     (int) ( bar_yhi - bar_ylo ) );

/*dmb:10/08/92:    FIf_set_location ( (Form) MS_bar_menu, bar_xlo, bar_ylo ); */

    /*** Make the bar menu be snugly fit up against the ***/
    /*** panel menu ( if any ).             ***/
    /*** Added check for MS_panel_menu -- JAJ:11/12/91  ***/

    MS_bar_menu->orig_xlo = FI_current_screen_width -
                        MS_bar_menu->orig_xsize ;
    if ( MS_panel_menu )
    {
      MS_bar_menu->orig_xlo -= MS_panel_menu->orig_xsize ;
    }

    MS_bar_menu->orig_ylo = bar_ylo;
  }

/* */

  if ( MS_bar_menu )
    {
      MIm_display ( (Form) MS_bar_menu );

      FI_process_forms ( );
    }


/*
  MS_init_menus ();
  MS_display_menus ();
*/

/* dmb:10/08/92:Original */
/*   status = FIf_new ( 1, form_name, note_routine, &test_fp );

  if ( status == FI_SUCCESS )
    {
      FIf_display ( test_fp );

      FI_process_forms ( );
    }
  else
    {
       fprintf ( stderr, "FIf_new: err = %d\n", status );

       exit ( status );
    }
*/

  XCloseDisplay (display);

  exit ( 0 );
}
