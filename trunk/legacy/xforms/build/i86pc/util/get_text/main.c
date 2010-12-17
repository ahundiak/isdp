/************************************
		
			main.c

*************************************/

/*
  History
	06-18-92	sml		added -f flag to get text for fields and
						  mcf's ONLY
*/

#include "FImin.h"
#include <stdio.h>
#include <errno.h>
#include "BAGgetopt.h"

#include "XFIproto_pub.h"
#include "XFUproto_pri.h"

#if !defined(licensing_off)
	 /* I/Lic_tool stuff -- JAJ:01/25/92 ***/
#include "api.h"
#endif
char command_name[80];

extern char * sys_errlist[];
extern int    sys_nerr;

/* sml:06-18-92		add global flag to change font for fields only */
int fields_only = 0;

void notification_routine(void)
{
}

void print_usage(void)
{
      fprintf ( stderr,
	 "usage:  %s [-f] form_name output_form_text_file\n",
	 command_name );
      fprintf ( stderr,
	"  where:\n" );
      fprintf ( stderr,
	"    form_name			form file to be translated\n" );
      fprintf ( stderr,
	"    output_form_text_file	text abstracted from form file\n" );
      fprintf ( stderr,
	"				( input to \"FIf_set_text\" )\n" );
      fprintf ( stderr,
	"	-f                  option to process fields only\n" );

      exit ( 1 );
}

#if !defined(licensing_off)
/* I/Lic_tool stuff -- JAJ:01/25/92 ***/
API_HANDLE_SHUTDOWN ()
#endif

main (int  argc,
      char * argv[])
{
/*  struct FIform_obj * form; dmb:09/02/92:*/
  Form                form;
  FILE		    * outfp;
  char		    * temp_ch = "";
  int		      status;
  Display	    * display;


  /* add for use with BAGgetopt() */
  char form_name[80], out_filename[80];
  int opt;


	strcpy(command_name, argv[0]);
	if ( argc < 3 || argc > 4 )
	print_usage();

	BAGopterr = 0;
	strcpy(form_name, "");
	strcpy(out_filename, "");

	while ( ( ( opt = BAGgetopt( argc, argv, "f" ) ) != NONOPT )
		|| (BAGoptarg != NULL ) ) 
	{
		if ( opt == ( int )'f' )
			fields_only = 1;
		else if (opt == NONOPT) /* form name or output filename */
		{
			/* check if form_name has not been set */
			if (strcmp(form_name, "") == 0)
			{
			  strcpy(form_name, BAGoptarg);
			}
			/* check if out_filename has not been set */
			else if (strcmp(out_filename, "") == 0)
			{
			  strcpy(out_filename, BAGoptarg);
			}
			else
			{
			  print_usage();
			}
		}
		/* check if valid option */
		else if (opt != (int)'f')
		{
		  print_usage();
		}
	}

#if !defined(licensing_off)
  /* I/Lic_tool stuff -- JAJ:01/25/92 ***/
  API_GET_LICENSE ( "SN01252", "1992" )
#endif

  display = XOpenDisplay ( "" );
  if ( display == None )
    {
      fprintf ( stderr,
	"%s: FATAL ERROR: cannot open X display.\n\n", argv[0] );

      exit ( 2 );
    }

  FSEnter ( display, 0 );

  FI_enter ( display,
	DefaultColormap ( display, DefaultScreen(display) ), 32 );

  status = FIf_new ( 100, form_name, (int (*)())notification_routine, &form );
  if ( status != FI_SUCCESS ) 
    {
      fprintf ( stderr, "\nERROR %d reading form '%s'.\n\n",
						 status, form_name );
      exit ( 3 );
    }

  outfp = fopen ( out_filename, "w" );
  if ( ! outfp )
    {
      fprintf ( stderr,
	"\nERROR opening text file '%s' for writing.\n", out_filename );

      if ( errno < sys_nerr )
	{
	  temp_ch = sys_errlist[errno] ;

	  if ( ! temp_ch )
	    {
	      temp_ch = "";
	    }
	}

      fprintf ( stderr, "\"errno\" = %d, %s.\n\n", errno, temp_ch );

      exit ( 4 );
    }

  FIf_get_text ( form, outfp, form_name );

  fclose ( outfp );

  XCloseDisplay ( display );

  exit ( 0 );
}
