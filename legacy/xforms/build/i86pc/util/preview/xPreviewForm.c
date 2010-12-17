#include <stdio.h>
#include <string.h>

#include "FI.h"
#include "FEI.h"

#include <X11/Xlib.h>

#include "XFIproto_pub.h"

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
int kill_mode = FALSE;


/*======================== ERROR MESSAGE ============================*/

int UnrecognizedArg (char *pn,
                     char *arg)
{
   fprintf ( stderr, "%s: Unrecognized argument <%s>\n", pn, arg );
   return (FI_SUCCESS);
}


/*========================== USAGE MESSAGE ===========================*/

int HelpMsg (char *pn)
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
   printf (" -k               Kill form immediately after display\n");
   return (FI_SUCCESS);
}


/*======================= NOTIFICATION ROUTINE =======================*/

/* ARGSUSED */
void note_routine (int form,
                  int gadget_label,
                  double value,
                  Form fp)
{
  fprintf ( stderr, "FIf_preview: label = %d\n", gadget_label );
  fflush ( stderr );

  if ( ( gadget_label == FI_ACCEPT ) || ( gadget_label == FI_CANCEL ) )
	FIf_erase ( fp );
  
   return;
}


/*========================= DEBUG: SYNC ON ===========================*/

int Sync_on (void)
{
   XSynchronize (display, True);
   fprintf ( stderr, "Synchronize--ON\n" );
   return (FI_SUCCESS);
}


/*========================= DEBUG: SYNC OFF ==========================*/

int Sync_off (void)
{
   XSynchronize (display, False);
   fprintf ( stderr, "Synchronize--OFF\n" );
   return (FI_SUCCESS);
}

#if !defined(licensing_off)
/* I/Lic_tool stuff -- JAJ:01/25/92 ***/
API_HANDLE_SHUTDOWN ()
#endif

/*============================== MAIN ================================*/

main (int argc,
      char *argv[])
{
   char *display_name = "", *ptr;
   char *search_path = ".";
   char *form_name = "DefaultForm";

/* dmb:05/22/91:This will cause X to fail. */
/* dmb:08/28/91: Can we turn this back on now? */
/*   char *symbol_search_path = "."; */
   char *symbol_search_path = "";

  /* dmb:04/14/93:Fixing symbol path problem */
  /* dmb:04/14/93:Adding INGRHOME logic */
    char tmp_sym_path[1024] = {(char) NULL};
    char ingr_root[256] = {(char) NULL};
  /* dmb:04/14/93:End Fixing symbol path problem */


#ifdef USING_THIS
  /* dmb:04/13/93:Added for testing */
    char cur_sym_path[1024] = {(char) NULL};
    int cur_sym_path_length = 0;
  /* dmb:04/13/93:End Added for testing */
#endif    

   int i;
   int sync = FALSE;

   int status = FI_SUCCESS;

   Form test_fp;

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

	  case 'k':
		 kill_mode = TRUE;
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

  /* dmb:04/14/93:Fixing symbol path problem */
  /* dmb:04/14/93:Adding INGRHOME logic */

  strcpy(tmp_sym_path,symbol_search_path);
  strcat(tmp_sym_path,":");
  strcat(tmp_sym_path,FI_get_ingr_root(ingr_root));
  strcat(tmp_sym_path,"/lib/xformsrt:/usr/lib/xformsrt");

  /* dmb:04/14/93:End Fixing symbol path problem */

  FI_set_symbol_path ( tmp_sym_path );

/* #define USING_THIS 1 */
#ifdef USING_THIS
  /* dmb:04/13/93:Begin Added for testing */

    FI_get_symbol_path (cur_sym_path);
    fprintf(stdout,"Current sym_path is %s\n",cur_sym_path);

    FI_get_symbol_path_length (&cur_sym_path_length);
    fprintf(stdout,"Current sym_path is %d\n",cur_sym_path_length);
  /* dmb:04/13/93:End Added for testing */
#endif

/*  FI_set_symbol_path ( symbol_search_path ); dmb:04/14/93:Original */

  status = FIf_new ( 1, form_name, (int (*)())note_routine, &test_fp );

  if ( status == FI_SUCCESS )
    {
      FIf_display ( test_fp );

	  if (kill_mode == FALSE)
        FI_process_forms ( );
	  else
		FIf_delete(test_fp);
    }
  else
    {
       fprintf ( stderr, "FIf_new: err = %d\n", status );

       exit ( status );
    }

  XCloseDisplay (display);

  exit ( 0 );
}
