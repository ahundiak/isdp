/* ------------------------- sli_cpp_tfile ---------------------------*/
#include "../sli/y.tab.h"
#include <sli.h>

void sli_cpp_tfile ( cmd_str, rm_temp_str )
  char		* cmd_str, * rm_temp_str;
{
  char		  string [300], *ch;
  extern char	* find_msg ();

  * cmd_str = NULL;
  if ( outf )
    {
      fclose ( outf );
      outf = NULL;
    }
  if ( ! class_sp )
    {
      yyerror ( find_msg ( "msg_no_class" ) );
      goto quit;
    }

  /*****
    strcpy ( cmd_str, "/lib/cpp -P $COBCPPOPT " );
    strcat ( cmd_str, temptfile );
  /*** run a sed script to remove the 380+ blank lines at  **
  /*** the beginning of the .T file 			 **
    strcat ( cmd_str, " | sed -n '/^CDO/,\$p' > " );
  /**** use omcpp instead of cpp (not enough #defines) JAJ:12-18-87  **/
  /****  Modified to use EXTARG rather than EXNUC -- scw 06-04-97  ****/

    ch = (char *) getenv ( "EXTARG" );
    if ( ch )
      {
	strcpy ( cmd_str, ch );
        strcat ( cmd_str, "/bin/" );
	if ( do_debug )
	    printf("\n EXTARG cmd_str='%s'\n\n", cmd_str );
      }
    else
      {
	fprintf( stderr,
	  "slic:  Can't access \"EXTARG\" shell variable\n" );
	exit ( 1 );
      }

  strcat ( cmd_str, "omcpp -l $COBCPPOPT < " );
  strcat ( cmd_str, temptfile );
  strcat ( cmd_str, " | sed '1,/COB_TFILE_STARTS_HERE/d' | " );
  strcat ( cmd_str, "sed 's/[ 	][ 	]*([ 	][ 	]*/(/' | " );
  strcat ( cmd_str, "sed 's/[ 	][ 	]*,[ 	][ 	]*/,/' | " );
  strcat ( cmd_str, "sed '/[\"].*[\"]/!s/[ 	][ 	]*//g' > " );

  make_file_name ( string, ".T" );

  strcat ( cmd_str, string );

  if ( do_debug )  /*** keep a copy of the un-cpp_ed .T file  ***/
      strcpy ( rm_temp_str, "mv " );
  else
      /*** delete the temporary .T file from the current dir ***/
      strcpy ( rm_temp_str, "rm " );
  strcat ( rm_temp_str, temptfile );
  if ( do_debug )
      strcat ( rm_temp_str, " /tmp" );

quit:
  return;
} /* cpp_t_file */
