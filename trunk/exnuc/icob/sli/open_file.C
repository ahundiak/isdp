/* -------------------------open_file-----------------------------------*/
#include <sli.h>
#include <string.h>
#include <stdio.h>
open_file ( fyl, ext )
  FILE	** fyl;
  char	*  ext;
{
  char	   name [300];
  char	   string [330];
#ifndef NT
  char	*  find_msg(), * tempnam();
#else
  char	*  find_msg();
#endif

  if (*fyl != NULL) fclose ( * fyl );

  if ( 0 == strcmp ( ext, ".T" ) )
    {
      /***  DON'T DO THIS HERE ANYMORE -- done by "slic" shell script***
      /***				-- JAJ:04-16-89		    ***
      /*** the shell variable "TMPDIR" must NOT be set for tempnam()***
      sts = system ( "unset TMPDIR" );		/*** to work right  ***
      if ( sts )				/*** JAJ:01-26-88   ***
        {
          fprintf ( stderr, find_msg ( "msg_err_enc" ),
						"\"unset TMPDIR\"" );
          putc ( '\n', stderr );
        }
      *****************************************************************/
#ifndef NT
      temptfile = tempnam ( "./", "TFILE" ) ;
#else
      temptfile = _strdup ( "c:\\temp\\tmp" ) ;
#endif
      strcpy ( name, temptfile );
      if ( do_print )
	printf ( "~%s > %s\n", ext , name );
    }
  else
    {
      make_file_name ( name, ext );
      if ( do_print )
	printf ( " .%c > %s\n", ext[ strlen(ext) - 1 ] , name );
    }
  * fyl = fopen ( name, "w" );
  if ( ! * fyl )
    {
      sprintf ( string, find_msg ( "msg_open_err" ), name );
      yyerror ( string );
    }
  flush = 0;
} /* open_file */
#ifdef NT

char *tempnam ( char *dir, char *pfx)
{
 char *tmp;

  tmp = (char *) malloc (strlen(dir) + strlen(pfx) + 20);
   tmp[0]='\0';
  sprintf(tmp,"c:\\temp\\%s\0",pfx);
   return(tmp);
}
#endif
