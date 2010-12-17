
#include "FImin.h"
#include <stdio.h>
#include <errno.h>

#if !defined(licensing_off)
	 /* I/Lic_tool stuff -- JAJ:01/25/92 ***/
#include "api.h"
#endif

#include "getsetdef.h"


#include "XFIproto_pub.h"
#include "XFUproto_pri.h"


void notification_routine(void)
{
}


extern char * sys_errlist[];
extern int    sys_nerr;

#if !defined(licensing_off)
/* I/Lic_tool stuff -- JAJ:01/25/92 ***/
API_HANDLE_SHUTDOWN ()
#endif

main (int    argc,
      char * argv[])
{
/*  struct FIform_obj * form; dmb:09/02/92: */
  Form              form;
  FILE		    * infp;
  char		    * save_form_name;
  int		      status;
  char		    * temp_ch = "";
  Display	    * display;


  if ( argc < 3 )
    {
      fprintf ( stderr,
	 "usage:  %s form_name input_form_text_file [ translated_form_name ]\n",
	 argv[0] );
      fprintf ( stderr,
	"  where:\n" );
      fprintf ( stderr,
	"    form_name			form file to be translated\n" );
      fprintf ( stderr,
	"    input_form_text_file	new text to put into form file\n" );
      fprintf ( stderr,
	"				( output from \"FIf_get_text\" ).\n" );
      fprintf ( stderr,
	"    translated_form_name	OPTIONAL:  pathname of translated form file;\n" );
      fprintf ( stderr,
	"    				if not specified, original form \n" );
      fprintf ( stderr,
	"    				is overwritten.\n\n" );

      exit ( 1 );
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


  status = FIf_new ( 100, argv[1], (int (*)())notification_routine, &form );
  if ( status != FI_SUCCESS ) 
    {
      fprintf ( stderr, "\nERROR %d reading form '%s'.\n\n",
						 status, argv[1] );
      exit ( 3 );
    }

  infp = fopen ( argv[2], "r" );
  if ( ! infp )
    {
      fprintf ( stderr,
	"\nERROR opening text file '%s' for reading.\n",
	 argv[2] );

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

  status = FIf_set_text ( form, infp, argv[1], argv[2] );

  if ( argc >= 4 )
    {
	  /*** write a new form file, leaving original untouched ***/
      save_form_name = argv[3];
    }
  else
    {
	  /*** rewrite the original form ***/
      save_form_name = argv[1];
    }

  if ( status == FI_SUCCESS )
    {

      status = FIf_save ( form, save_form_name );
      if ( status != FI_SUCCESS ) 
        {
          fprintf ( stderr, "\nERROR %d saving form '%s'.\n\n",
					 status, save_form_name );
          exit ( 5 );
        }
    }
  else
    {
      fprintf ( stderr, "\nForm '%s' was not updated.\n\n",
						save_form_name );
    }

  fclose ( infp );

  XCloseDisplay ( display );

  exit ( 0 );
}
