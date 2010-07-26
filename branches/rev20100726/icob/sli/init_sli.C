/* ------------------------init_sli-----------------------------------*/
#include "../sli/y.tab.h"
#include <sli.h>

extern FILE * sliyyin;	/* ptr to slimacro.SI file, used by sliyylex()*/

symbol		* insert_sym ();

int init_sli ( )
{
  char		  string [200];
  char		* getenv ();
  FILE		* infp;


  ige_env = getenv ( "EXNUC" );
  if ( ! ige_env )
    {
      fprintf ( stderr, "Environment variable 'EXNUC' not set\n" );
      errors ++;
      ige_env = "";
      goto exit;
    }

  cob_env = getenv ( "COB" );
 /******************************************** JAJ:01-18-90 **********
  if ( ! cob_env )
    {
     /* Environment variable 'COB' not set *
      cob_env = (char *) calloc ( 1, strlen ( ige_env ) + 6 ) ;
      strcpy ( cob_env, ige_env );
#ifndef NT
      strcat ( cob_env, "/icob" );
#else
      strcat ( cob_env, "\\icob" );
#endif
    }
 *********************************************************************/

	/**** read in the COB translatable "message" file ****/
  strcpy ( string, ige_env );
#ifndef NT
  strcat ( string, "/config/slims.ige" );
#else
  strcat ( string, "\\config\\slims.ige" );
#endif
  infp = fopen ( string, "r" );
  if ( ! infp )
    {
      fprintf ( stderr, "Unable to open file '%s'\n", string );
      errors ++;
      goto exit;
    }
  else
    {
      scan_slifile ( infp );
   if(infp != NULL)   fclose ( infp );
    }

	/*** set up the sliyyin file ptr for sliyylex() ***/
  strcpy ( string, ige_env );
#ifndef NT
  strcat ( string, "/config/slimacro.SI" );
#else
  strcat ( string, "\\config\\slimacro.SI" );
#endif
  sliyyin = fopen ( string, "r" );
  if ( ! sliyyin )
    {
      fprintf ( stderr, (char *)find_msg( "msg_open_err"), "slimacro.SI" );
      fputc ( '\n', stderr);
      errors ++;
      goto exit;
    }

	/**** read in the IGE COB slic keywords ****/
  strcpy ( string, ige_env );
#ifndef NT
  strcat ( string, "/config/slikey.ige" );
#else
  strcat ( string, "\\config\\slikey.ige" );
#endif
  infp = fopen ( string, "r" );
  if ( ! infp )
    {
      fprintf ( stderr, (char *)find_msg( "msg_open_err"), "slikey.ige" );
      fputc ( '\n', stderr);
      errors ++;
      goto exit;
    }
  else
    {
      scan_slifile ( infp );
 if(infp != NULL)      fclose ( infp );
    }

  draft_env = getenv ( "GRNUC" );
  if ( ! draft_env )
    {
      fprintf ( stderr, "%s\n",  (char *)find_msg ( "msg_no_draft" ));
      draft_env = "";
    }
  else
    { /** read in the DRAFT COB slic keywords (iff $GRNUC is set) **/
      strcpy ( string, draft_env );
      /*strcat ( string, "/dcob/config/slikey.draft" );--JAJ:09-19-88*/
#ifndef NT
      strcat ( string, "/config/slikey.draft" );
#else
      strcat ( string, "\\config\\slikey.draft" );
#endif
      infp = fopen ( string, "r" );
      if ( ! infp )
        {
	  fprintf ( stderr, (char *)find_msg( "msg_open_err"), "slikey.draft" );
	  fputc ( '\n', stderr);
	  errors ++;
	  goto exit;
        }
      else
        {
          scan_slifile ( infp );
          fclose ( infp );
        }
    }

exit:
  return errors;

} /* init_sli */


scan_slifile(infp)
  FILE * infp;
{
  int		  i;
  char		  ch;
  char		  string [200];
  char		  name [80];
  symbol	* sp;
  char		* name_ptr;
  char		* str_ptr;
  str_rec	* srec_ptr;

  while ( 1 )
    {
      if ( EOF != fscanf ( infp, "%s", name ) )
        {
          name_ptr = (char *) calloc ( 1, strlen ( name ) + 1 );
	  if ( ! name_ptr )
	    {
	      fprintf(stderr,
		"slic: scan_slifile() -- No dynamic memory available 1\n\n");
	      exit(1);
	    }
          strcpy ( name_ptr, name );
          fscanf ( infp, " %c", & ch );
          switch ( ch )
            {
              case 'm':
              case 'M':
                i = getc ( infp );
                fgets ( string, sizeof ( string ), infp );
                string [ strlen ( string ) - 1 ] = '\0';
                srec_ptr = (str_rec *) calloc ( 1, sizeof ( str_rec ) +
				                    strlen ( string ));
	        if ( ! srec_ptr )
	          {
	            fprintf(stderr,
		      "slic: sli_do_args() -- No dynamic memory available 2\n\n");
	            exit(1);
	          }
                strcpy ( srec_ptr->str, string );
                cur_syms = & messages;
                sp = insert_sym ( name_ptr, 0, 1, NULL );
                _COB_append_to_list ( srec_ptr, list, sp->strs );
                break;
              case 's':
              case 'S':
                fscanf ( infp, " %d", & i );
                fgets ( string, sizeof ( string ), infp );
                cur_syms = & top_syms;
                sp = insert_sym ( name_ptr, STATE, 1, NULL );
                sp->offset = i;
                break;
              case 'v':
              case 'V':
                i = getc ( infp );
                fgets ( string, sizeof ( string ), infp );
                str_ptr = (char *) calloc ( 1, strlen ( string ));
	        if ( ! str_ptr )
	          {
	            fprintf(stderr,
		      "slic: sli_do_args() -- No dynamic memory available 3\n\n");
	            exit(1);
	          }
                string [ strlen ( string ) - 1 ] = '\0';
                strcpy ( str_ptr, string );
                cur_syms = & var_words;
                sp = insert_sym ( name_ptr, 0, 1, NULL );
                sp->args = str_ptr;
                if ( ch == 'V' ) sp->offset = 1;
                break;
              case 'w':
              case 'W':
                fscanf ( infp, " %d", & i );
                fgets ( string, sizeof ( string ), infp );
                cur_syms = & keywords;
                sp = insert_sym ( name_ptr, 0, 1, NULL );
                sp->offset = i;
                break;
              default:
                sp = NULL;
                break;
            }
          if ( ! sp ) 
            {
	      errors++ ;
              /* ret = 0; */
              break;
            }
        }
      else
	break;
    }

} /* scan_files() */
