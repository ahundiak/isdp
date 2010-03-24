/* ------------------------- slic main ------------------------------ */
#define _is_main

#include <sli.h>
#include <errno.h>

extern FILE * yyin;	/* ptr to .sl file, used by yylex() */


/***********************************************************************
    GENERAL SLIC NOTES:

  Global Variables:
  -----------------
	top_syms:	ptr to a global "symbol" linked list
			  Symbols with a "type" of "_class_word"
			  have the actions defined on that class hung
			  off that symbol record
	keywords:	ptr to a linked list of keywords
			  ( things with a "w" from slikey.ige ) 
	var_words:	ptr to a linked list of variables
			  ( things with a "v"/"V" from slikey.ige/draft)
	messages:	ptr to a linked list of messages
			  ( things with an "m" from slims.ige ),
			  used by find_msg()

	cur_sym		ptr to current symbol being manipulated
			  if you want to change this to something, save
			  the current value first using push_stack(),
			  then do your thing, and then restore its value
			  using pop_stack().

	cur_syms	ptr to ptr to linked list currently being
	       ^	  manipulated;  insert_sym(), lookup(), and
			  find_type() DEPEND ON cur_syms BEING SET
			  BEFORE THEY'RE CALLED!!!!

	sym_stack,	stacks on which push_stack() and pop_stack()
	  act_stack	  work

    Functions:
    ----------
	push_stack	Place a symbol or action record pointer on a
	  		  stack, so that its current value is saved and
			  not permanently lost; uses act_stack for
			  "action" structures or sym_stack for "symbols"

	pop_stack	Restore a symbol or action record pointer's
			  previous value from a stack; uses act_stack
			  for "action" structs or sym_stack for
			  "symbol" structs

***********************************************************************/


main ( argc, argv )
  int	  argc;
  char	* argv [];
{
  int	  j;
  int	  which;
  int	  sts;
  char	  string [300];
  char	  string1 [500];
  char	* find_msg ();
  char  * strrchr(), * ch;

  extern int errno;
  extern char * calloc( );

  level		= (char *) calloc ( 1, 80 );
  big_str	= (char *) calloc ( 1, 2000 );
  rm_temp_str	= (char *) calloc ( 1, 200 );
  if ( ! level || ! big_str || ! rm_temp_str )
    {
      fprintf(stderr,
	"slic: main() -- No dynamic memory available\n\n");
      exit(1);
    }
  sym_stack = (char *) make_stack ( 10 );
  act_stack = (char *) make_stack ( 50 );

  /*** read in all the config/sli* files ***/
  if ( init_sli() )
    goto quit;

  if ( argc <= 1 )
    {
      options ( "?", NULL );
      goto exit;
    }

  which = 0;
  for ( j = 1; j < argc; ++ j )
    if ( argv [j][0] == '-' )
      if ( j == argc - 1 ) options ( argv [j], NULL );
      else j += options ( argv [j], argv [ j + 1 ] );
    else if ( ! which ) which = j;
  if ( errors ) goto quit;
  if ( which <= 0 || which >= argc )
    {
      fprintf ( stderr, find_msg ( "msg_no_file" ));
      putc ( '\n', stderr );
      goto exit;
    }
  file_name = argv [which];
  if ( do_print ) printf ( "   < %s\n", file_name );
  yyin = fopen ( file_name, "r" );
  if ( ! yyin )
    {
      yyerror ( find_msg ( "msg_input_err" ));
      goto quit;
    }

  yyparse ();	/** parse the .sl file **/
  if ( ! errors )
    {
      ignore = 0;
      sliyylex (); /** parse the slimacro.SI file **/
      verify_symbol_table ( top_syms, 0, stderr );
      if ( do_debug && do_print ) dump_symbol_table ( top_syms, 0 );
    }

quit:
  if ( errors == 1 )
    {
      fprintf ( stderr, "%s\n", find_msg ( "msg_1fatal" ));
    }
  else if ( errors )
    {
      fprintf ( stderr, find_msg ( "msg_fatal" ), errors );
      putc ( '\n', stderr );
    }
  else if ( do_dott )
    {
      sli_cpp_tfile ( big_str, rm_temp_str );
      if ( big_str [0] )
        {
          if ( do_print )
            printf ( "%s\n  %s\n", find_msg ("msg_cpp_ing"), big_str );
          sts = system ( big_str );
          if ( sts )
            {
              fprintf ( stderr, find_msg ( "msg_cpp_err" ), sts );
              putc ( '\n', stderr );
            }
	  else	/*** link pseudo-files to the real cpp-ed ".T" file, **/
	    {   /***   one for each synonym key			     **/
	      _COB_for_list ( sp, list, top_syms, symbol )
		if ( sp->type == _synonym_word )
		  {
		    make_file_name ( big_str, ".T" );
		    strcpy ( string, big_str );
#ifdef NT
		    ch = strrchr ( string, '\\' );
#else
		    ch = strrchr ( string, '/' );
#endif
		    strcpy ( ++ch, sp->strs->list.next->str );

		    if ( strcmp ( big_str, string ) )
		      {

                        if ( do_print )
			  {
	                    printf ( find_msg ("msg_ln_ing1"), big_str);
			    printf ( "\n\t" );
	                    printf ( find_msg ("msg_ln_ing2"), string );
			    printf ( "\n" );
			  }

			/* unlink the target file first--JAJ:10-06-88**/
#ifdef NT
                        sts = _unlink ( string );
#else
                        sts = unlink ( string );
#endif
                        if ( sts == -1 && errno != ENOENT )
                          {
			    sprintf ( string,
				find_msg ( "msg_unlink_err" ), errno );
                            perror ( string );
                          }

			/*** link the original .t file to syn file ***/
#ifdef NT
                        sprintf(string1,"copy %s %s",big_str,string);
                        sts = system (string1 );
#else
                        sts = link(big_str,string);
#endif
                        if ( sts == -1  /* &&  errno != EEXIST */ )
                          {
			    sprintf ( string, find_msg ( "msg_ln_err" ),
						errno );
                            perror ( string );
                          }
		      }
		  }
	      _COB_end_for_list /* (sp) */
	    }

	  /*** remove the temporary un-cpped ".T" file ***/
          if ( do_print )
            printf ( "%s\n", rm_temp_str );
          sts = system ( rm_temp_str );
          if ( sts )
            {
              fprintf ( stderr, find_msg("msg_temp_err"), rm_temp_str );
              putc ( '\n', stderr );
	    }
        }
      if ( do_cmd_table )
	{
          if ( do_print )
            printf ( "\n%s\n", find_msg ("msg_cmd_table") );
	  if ( ! make_cmd_table() )
	    {
              fprintf ( stderr, find_msg ("msg_err_enc"), 
				find_msg ("msg_cmd_table") );
              putc ( '\n', stderr );
	    }
	}
    }
exit:
  if ( errors ) return (1);
  else return (0);
}
