#include <stdio.h>
#include <string.h>
#include <math.h>
#include <errno.h>

#include "../include/FI.h"
#include "../include/FEI.h"

#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#include "../include/XFIproto_pub.h"

extern void exit ();
extern int FSEnter ();

#define USHRT_MAX 65355
#define SLOTS 32

#define FIELD 11 /* gadget in test group */
#define TST_GRP 50
#define DISPLAY 53
#define HILITE 54
#define ENABLE 55

Display *display;

/* Form test_fp; for public consumption... */
/* struct FIform_obj *test_fp;	for old SMART builds */
Form test_fp;	/* for New SMART builds */

char *form_name = "X_form";

void Syntax (char *pn,
             char *arg)
{
  printf ( "%s: bad argument <%s>\n", pn, arg );
  printf ( "-d	<display>      [node:display.screen]\n" );
  printf ( "-f	<form name>\n" );
  printf ( "-k	<auto_scale_factor_x> <auto_scale_factor_y>\n" );
  printf ( "-p	<form search path> \n" );
  printf ( "-s	synchronize X calls \n" );
  printf ( "-?	help -- Prints this message.\n" );
}

/* ARGSUSED */
int note_routine (int       form,
                  int       gadget,
                  double    value,
                  Form      fp)
{
/*   fprintf (stderr, "gadget %d notified\n", gadget); */
   return 0;
}

/* ARGSUSED */
int process_command (int  cmd_type,
                     char *cmd)
{
  if ( ! strcmp (cmd, "display"))
    {
	  FIg_display (test_fp, FI_FORM_GROUP);
    }
  else if ( ! strcmp (cmd, "erase"))
    {
	  FIg_erase (test_fp, FI_FORM_GROUP);
    }
  else if ( ! strcmp (cmd, "enable"))
    {
	  FIg_enable (test_fp, FI_FORM_GROUP);
    }
  else if ( ! strcmp (cmd, "disable"))
    {
	  FIg_disable (test_fp, FI_FORM_GROUP);
    }
  else if ( ! strcmp (cmd, "hilite"))
    {
	  FIg_hilite (test_fp, FI_FORM_GROUP);
    }

  else if ( ! strcmp (cmd, "unhilite"))
    {
	  FIg_unhilite (test_fp, FI_FORM_GROUP);
    }
  else if ( ! strcmp (cmd, "collapse"))
    {
	  FIf_collapse (test_fp);
    }
  else if ( ! strcmp (cmd, "uncollapse"))
    {
	  FIf_uncollapse (test_fp);
    }
  else if ( ! strcmp (cmd, "fdisplay"))
    {
	  FIf_display (test_fp);
    }
  else if ( ! strcmp (cmd, "ferase"))
    {
	  FIf_erase (test_fp);
    }
  else if ( ! strcmp (cmd, "new") && ! test_fp)
    {
      if ( FIf_new (1, form_name, note_routine, &test_fp) == FI_SUCCESS)
	{
		 FIf_display (test_fp);
	}
    }
  else if ( ! strcmp (cmd, "delete") && test_fp )
    {
	  FIf_delete (test_fp);
	  test_fp = 0;
    }
  else if ( ! strcmp (cmd, "exit") )
    {
      if ( MS_save_locations ("./menu_locations") != FI_SUCCESS )
	{
	  printf ("errno = %d\n", errno);
	}

      MS_delete_menus ();

      if ( test_fp )
	{
	  FIf_delete (test_fp);
	}

      XCloseDisplay (display);
      exit (0);
    }

  return 0;
}


void LoadGreyScale (Colormap cmap)
{
  XColor shade;
  unsigned short inc, start = 20000;
  int count, greys = 0;


  inc = (short)(USHRT_MAX - start) / (short)SLOTS;
  shade.red = shade.green = shade.blue = start + inc;

  for ( count = 0 ;  count < SLOTS ;  shade.red += inc ,
		 shade.green += inc , shade.blue += inc , count++)
    {
      if ( XAllocColor ( display, cmap, &shade ) )
	{
	  greys++;
	}
    }

   printf ("Loaded %d grey scale colormap\n", greys);
}


/*=================================== DEBUG ==========================*/

int Sync_on (void)
{
  XSynchronize (display, True);
  printf ("Synchronize--ON\n");

  return (FI_SUCCESS);
}


int Sync_off (void)
{
  XSynchronize (display, False);
  printf ("Synchronize--OFF\n");
  return (FI_SUCCESS);
}

/*=================================== MAIN ===========================*/

int main (int  argc,
      char *argv[])
{
  char		*display_name = "", *ptr, *search_path = ".";
  int		status, ii, sync = 0;
  XEvent	event;
  double	scale_factor_x = 0.0;
  double	scale_factor_y = 0.0;
  Display       **displayPtr = &display;

   /** Find the display argument after 0th argument **/

   /** Set up program name **/


  ptr = strrchr ( argv[0], '/' );
  if ( ptr )
    {
	argv[0]= ptr + 1;
    }

   /*** Parse the command line ***/

  for ( ii = 1; ii < argc; ii++ )
    {
	  if ( argv[ii][0]!= '-' )
	    {
	      Syntax ( argv[0], argv[ii] );
	    }

	  switch ( argv[ii][1] )
	  {
	  case 'd':
		 display_name = argv[ii];
		 break;

	  case 'f':
		 form_name = argv[ii];
		 break;

	  case 'p':
		 search_path = argv[ii];
		 break;

	  case 's':
		 sync = 1;
		 ii--;
		 break;

	  case 'k':
		 sscanf ( argv[ii], "%lf", & scale_factor_x );
		 sscanf ( argv[++ii], "%lf", & scale_factor_y );
		 break;

	  default:
		 Syntax (argv[0], argv[ii]);
	  }
    }	/** END for **/


  if ((display = XOpenDisplay (display_name)) == None)
    {
      fprintf ( stderr, "%s: cannot connect to X server %s\n",
				XDisplayName (display_name));
      exit (-1);
    }

  if ( sync )
   {
      Sync_on ();
   }

  FSEnter ( display, 0 );

  FI_enter ( display,
	DefaultColormap ( display, DefaultScreen ( display ) ), 32 );

  if ( scale_factor_x || scale_factor_y )
    {
      printf ( "Setting auto scale factors to %8.4lf, %8.4lf\n",
      			scale_factor_x, scale_factor_y );

      status = FI_set_auto_scaling_factors ( scale_factor_x,
					   scale_factor_y );
      if ( status != FI_SUCCESS )
	{
	  fprintf ( stderr, "FI_set_auto_scaling_factors: sts = %d\n",
		status );
	}
    }

  FI_set_form_path (search_path);

  FI_modify_env (FI_PROCESS_DATA, process_command);

  MS_enter ();
  MS_set_startup_file ("./menu_locations");
  MS_init_menus ();
  MS_display_menus ();


  status = FIf_new ( 1, form_name, note_routine, &test_fp );

  if ( status == FI_SUCCESS )
    {
      FIf_display (test_fp);

      while ( FI_forms_active () )
	{
	  XNextEvent (display, &event);

	  if ( ! FI_process_event (&event, 0) )
	    {
	      if ( (event.type == ButtonPress)		&&
		   (event.xbutton.button == Button1)	 )
		{
		    /* This call simply displays the loaded pocket */
		    /* menu in the coordinates (xpos and ypos)and  */
		    /* virtual screen(vs). 			   */

		  MS_process_pocket ( 0, event.xbutton.x_root,
					event.xbutton.y_root );
		}
	    }
	}
    }
  else
    {
      printf ( "FIf_new: err = %d\n", status );
    }

  XCloseDisplay (display);
  return 0;
}
