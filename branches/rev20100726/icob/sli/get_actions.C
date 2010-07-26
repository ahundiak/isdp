/* ----------------------  get_actions  ----------------------------- */
#include "../sli/y.tab.h"
#include <sli.h>
static int try_file ();

get_actions ()
{

  char		* str_ptr;
  list_rec	* lp;
  char		  path [132];
  char		  class_name [16];
  char		  found_file = 0;
  extern char	* expand_shell_vars (), * strip_quotes (),
		* find_msg (), * calloc ( );

  need_actions = 0;
  if ( ! super_sp )
    {

      str_ptr = (char *) calloc ( 1, 4 );
      if ( ! str_ptr )
        {
          fprintf(stderr,
	    "slic: get_actions() -- No dynamic memory available 1\n\n");
          exit(1);
        }
      strcpy ( str_ptr, "CEO" );
      super_sp = (symbol *) insert_sym ( str_ptr, _super_word, 1,
          "duplicate super class" );
      lp = (list_rec *) calloc ( 1, sizeof ( list_rec ));
      if ( ! lp )
        {
          fprintf(stderr,
	    "slic: get_actions() -- No dynamic memory available 2\n\n");
          exit(1);
        }
      lp->val = (char *) super_sp;
      _COB_insert_head_ansi ( lp, list, (list_rec *) class_sp->owner, class_sp->owner, (struct symbol *));
    }
  _COB_for_list ( sp, list, top_syms, symbol )
    if ( sp->type == _super_word || ( ! do_dots && sp->type == _class_word ))
      {
        found_file = 0;
        strcpy ( class_name, strip_quotes ( sp->name ));
        _COB_for_list ( ppp, list, top_syms, symbol )
          if ( ppp->type == _spec_path_word || ppp->type == _path_word )
            {
              found_file = try_file ( expand_shell_vars ( strip_quotes (
                  ppp->name )), class_name, sp );
              if ( found_file ) break; /* ppp for_list */
            }
        _COB_end_for_list /*  ppp  */

        if ( ! found_file && cob_env )
          {
            strcpy ( path, cob_env );
#ifndef NT
            strcat ( path, "/spec/" );
#else
            strcat (path,"\\spec\\");
#endif
            found_file = try_file ( path, class_name, sp );
          }

        if ( ! found_file )		/*** JAJ:01-18-90 ***/
          {
            strcpy ( path, ige_env );
#ifndef NT
       strcat ( path, "/spec/" );
#else
       strcat(path,"\\spec\\");
#endif
            found_file = try_file ( path, class_name, sp );
          }
					/*** JAJ:01-18-90 ***/
	if ( ! found_file  &&  draft_env  &&  strcmp ( draft_env, "" ) )
          {
            strcpy ( path, draft_env );
#ifndef NT
            strcat ( path, "/spec/" );
#else
            strcat(path,"\\spec\\");
#endif
  found_file = try_file ( path, class_name, sp );
          }

	if ( ! found_file  &&  draft_env  &&  strcmp ( draft_env, "" ) )
          {
            strcpy ( path, draft_env );
#ifndef NT
        strcat ( path, "/dcob/spec/" );
#else
        strcat(path,"\\dcob\\spec\\");
#endif
    found_file = try_file ( path, class_name, sp );
          }

        if ( ! found_file )
          {
            strcpy ( path, ige_env );
#ifndef NT
      strcat ( path, "/icob/spec/" );
#else
      strcat (path,"\\icob\\spec\\");
#endif
   found_file = try_file ( path, class_name, sp );
          }

        if ( ! found_file )
          {
            strcpy ( path, ige_env );
#ifndef NT
            strcat ( path, "/exec/spec/" );
#else
            strcat (path,"\\exec\\spec\\");
#endif
            found_file = try_file ( path, class_name, sp );
          }

        if ( ! found_file )
          {
            strcpy ( path, ige_env );
#ifndef NT
            strcat ( path, "/om/spec/" );
#else
            strcat (path,"\\om\spec\\");
#endif
            found_file = try_file ( path, class_name, sp );
          }

        if ( ! found_file )
          {
#ifndef NT
            strcpy ( path, "./" );
#else
            strcpy(path,".\\");
#endif
            found_file = try_file ( path, class_name, sp );
          }
        if ( ! found_file )
          {
            sprintf ( path, find_msg ( "msg_no_path" ), class_name );
            yyerror ( path );
          }
      }
  _COB_end_for_list /*  sp  */
  /*** sli_declare ( "action", ACTION );  make method "action"	***/
  /*** cur_sym->begin = 1;					***/
} /* get_actions */

/* ----------------------- try_file --------------------------------- */
static int try_file ( path, class_name, a_class_sp )
  char		* path;
  char		* class_name;
  symbol	* a_class_sp;
{
  FILE	* fp;
  char	  filename [140];

  strcpy ( filename, path );
#ifndef NT
  if ( filename [ strlen ( filename ) - 1 ] != '/' )
  strcat (filename,"/");
#else
  if (filename [strlen (filename) -1] != '\\')
  strcat (filename,"\\");
#endif
    strcat ( filename, class_name );
  strcat ( filename, ".S" );
  fp = fopen ( filename, "r" );
  if ( fp )
    {
      if ( do_print )
        printf ( "^^ < %s\n", class_name );
      scan_dots ( fp, a_class_sp );
      if(fp != NULL) fclose ( fp );
      return 1;
    }
  return 0;
} /* try_file */
