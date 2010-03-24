/* ---------------------------  scan_dots  ---------------------------*/
#include "../sli/y.tab.h"
#include <sli.h>

scan_dots ( fp, a_class_sp )
  FILE		* fp;
  symbol	* a_class_sp;
{
  int		  token;
  char		  ident [120];
  char		  message_args [2049];  /* 300 is NOT enough ! */
  char		  str [3];
  char		  found_over = 0;
  char		  found_msg = 0;
  short		  found_arglist = 0;
  short		  bracket_cnt = 0;
  short		  class_spec_of = 0;
  char		* name_ptr = 0;
  char		* args_ptr;
  symbol	* sp;
  list_rec	* lp;
  symbol	* insert_sym ();
  extern   char * calloc( );
  static char	* keywords [] =
                  { "message",
                    "override",
                    "class",
                    "specification",
                    "of",
                    NULL
                  };

  strcpy ( str, " x" );
  push_stack ( sym_stack, cur_syms );
  cur_syms = & a_class_sp->actions;
  do
    {
      token = get_token ( fp, keywords, ident );
      switch ( token )
        {
          case EOF:
            break;

          case KEYWORD: /* message */
            found_msg = 1;
            found_arglist = 0;
            found_over = 0;
            break;

          case KEYWORD + 1: /* override */
            found_over = 1;
            found_msg = 0;
            found_arglist = 0;
            break;

          case ';':
            if ( found_msg )
              if ( found_arglist <= 0 )
                {
                  /****  message_args contains the arg list ****/
                  args_ptr = (char *) calloc ( 1, strlen ( message_args ) + 1 );
		  if ( ! args_ptr )
		    {
		      fprintf(stderr,
			"slic: scan_dots() -- No dynamic memory available 1\n\n");
		      exit(1);
		    }
                  strcpy ( args_ptr, message_args );
                  sp = insert_sym ( name_ptr, ACTION, 0, NULL );
                  sp->owner = a_class_sp;
                  sp->args = args_ptr;
                  found_over = 0;
                  found_msg = 0;
                  found_arglist = 0;
                }
              else
                {
                  str [1] = token;
                  strcat ( message_args, str );
                }
            else if ( found_over )
              {
                found_over = 0;
                found_msg = 0;
                found_arglist = 0;
              }
            ++ class_spec_of;
            break;

          case KEYWORD + 2: /* class */
          case KEYWORD + 3: /* spec */
          case KEYWORD + 4: /* of */
            ++ class_spec_of;
            break;

          case IDENT:
            if ( found_msg )
              if ( found_arglist )
                {
                  strcat ( message_args, " ");
                  strcat ( message_args, ident );
                }
              else /*** is method name  ***/
                {
                  name_ptr = (char *) calloc ( 1, strlen(ident) + 1 );
		  if ( ! name_ptr )
		    {
		      fprintf(stderr,
			"slic: scan_dots() -- No dynamic memory available 2\n\n");
		      exit(1);
		    }
                  strcpy ( name_ptr, ident );
                }
            else if ( found_over )
              {
                name_ptr = (char *) calloc ( 1, strlen ( ident ) + 1 );
		if ( ! name_ptr )
		  {
		    fprintf(stderr,
			"slic: scan_dots() -- No dynamic memory available 3\n\n");
		    exit(1);
		  }
                strcpy ( name_ptr, ident );
                sp = insert_sym ( name_ptr, ACTION, 0, NULL );
                sp->owner = a_class_sp;
                sp->inherited = 1;
              }
            else if ( class_spec_of == 3 &&
                strcmp ( a_class_sp->name, "Root" ))
              {

                name_ptr = (char *) calloc ( 1, strlen ( ident ) + 1 );
		if ( ! name_ptr )
		  {
		    fprintf(stderr,
			"slic: scan_dots() -- No dynamic memory available 4\n\n");
		    exit(1);
		  }
                strcpy ( name_ptr, ident );
                push_stack ( sym_stack, cur_syms );
                cur_syms = & top_syms;
                sp = insert_sym ( name_ptr, _super_word, 1, NULL );
                sp->inherited = a_class_sp != class_sp;
                lp = (list_rec *) calloc ( 1, sizeof ( list_rec ));
		if ( ! lp )
		  {
		    fprintf(stderr,
			"slic: scan_dots() -- No dynamic memory available 5\n\n");
		    exit(1);
		  }
                lp->val = (char *) sp;
                _COB_insert_head_ansi ( lp, list, (list_rec *) a_class_sp->owner,
                 a_class_sp->owner, (struct symbol *));
                cur_syms = (symbol **) pop_stack ( sym_stack );
              }
            break;

          case '{':  /**** eat { }'s } ****/
            bracket_cnt = 1;
            do
              {
                if (( token = get_token ( fp, NULL, ident )) == '{' )
                  bracket_cnt++;
                else if ( token == '}' )
                  bracket_cnt--;
                else if ( token == EOF )
                  break;
              }
            while ( bracket_cnt );
            break;

          case '(':
            if ( found_msg )
              if ( ++ found_arglist == 1 ) strcpy ( message_args, "(" );
              else strcat ( message_args, " (" );
            break;

          case ')':
            if ( found_msg ) -- found_arglist;
            /* _no_break; */

          default:
            if ( found_msg )
              {
                str [1] = token;
                strcat ( message_args, str );
              }
            break;
        } /* end switch */
    } /* end do */
  while ( token != EOF );
  cur_syms = (symbol **) pop_stack ( sym_stack );
} /* end scan_dots */
