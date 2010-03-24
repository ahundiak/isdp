/* ------------------------ options --------------------------------- */
#include <sli.h>

/*** this next bit field structure is to fix slic so that options ***/
/***   given via the command line aren't later overridden by	  ***/
/***   options embedded within the .sl file			  ***/
struct options_bits	/*** JAJ:03-22-88 ***/
{
  unsigned int do_debug:1;
  unsigned int do_dot_i:1;
  unsigned int output_name:1;
  unsigned int do_dot_s:1;
  unsigned int do_dot_t:1;
  unsigned int do_cmd_table:1;
  unsigned int do_verbose:1;
  unsigned int print_version:1;
};

int options ( str, str_next )
  char	* str;
  char	* str_next;
{
  int		  	   used_next = 0;
  char			 * ptr;
  char		  	   ch;
static struct options_bits been_here = { 0 };	/*** JAJ:03-22-88 ***/
  extern char		 * find_msg ();
  symbol		 * sp;

  ptr = str;
  while ( ch = * ptr ++ )
    switch ( ch )
      {
	case 'd':
	case 'D':
	  if ( ! been_here.do_debug )
	    {
	      do_debug = isupper ( ch );
	      if ( do_debug )	/*** -D => -V  --JAJ:03-23-88 ***/
		{
		  do_print = 1;
		  been_here.do_verbose = 1;
		}
	      if ( do_debug && ! been_here.print_version )
		{
		  print_version ();
		  been_here.print_version = 1;
		}
	      been_here.do_debug = 1;
	    }
	  break;
	case 'i':
	case 'I':
	  if ( ! been_here.do_dot_i )
	    {
	      do_doti = isupper ( ch );
	      been_here.do_dot_i = 1;
	    }
	  break;
	case 'o':
	case 'O':
	  if ( * ptr )	/*** "-o../whatever" w/o a space ***/
	    {
	      if ( ! been_here.output_name )
	        {
	          sli_declare ( ptr, _output_name_word );
	          been_here.output_name = 1;
	        }
	    }
	  else if ( str_next ) /*** "-o ../whatever" WITH a space ***/
	    {
	      if ( ! been_here.output_name )
	        {
	          sli_declare ( str_next, _output_name_word );
	          been_here.output_name = 1;
	        }
	      used_next = 1;
	    }
	  else
	    {
	      fprintf ( stderr, "%s\n", find_msg ( "msg_inv_out" ));
	      ++ errors;
	    }
	  goto quit;
	  /*break;*/
	case 'p':
	case 'P':
	  if ( * ptr ) /*** user typed "-p../whatever" w/o a space ***/
	    sli_declare ( ptr, _spec_path_word );
	  else if ( str_next ) /*** "-p ../whatever" WITH a space ***/
	    {
	      sli_declare ( str_next, _spec_path_word );
	      used_next = 1;
	    }
	  else
	    {
	      fprintf ( stderr, "%s\n", find_msg ( "msg_inv_path" ));
	      ++ errors;
	    }
	  goto quit;
	  /*break;*/
	case 's':
	case 'S':
	  if ( ! been_here.do_dot_s )
	    {
	      do_dots = isupper ( ch );
	      been_here.do_dot_s = 1;
	    }
	  break;
	case 't':
	case 'T':
	  if ( ! been_here.do_dot_t )
	    {
	      do_dott = isupper ( ch );
	      been_here.do_dot_t = 1;
	    }
	  break;
	case 'c':
	case 'C':
	  if ( ! been_here.do_cmd_table )
	    {
	      do_cmd_table = isupper ( ch );
	      been_here.do_cmd_table = 1;
	    }
	  break;
	case 'v':
	case 'V':
	  if ( ! been_here.do_verbose )
	    {
	      do_print = isupper ( ch );
	      if ( do_print && ! been_here.print_version )
		{
		  print_version ();
		  been_here.print_version = 1;
		}
	      been_here.do_verbose = 1;
	    }
	  break;
	case 'z':
	case 'Z':
	  if ( ! been_here.print_version )
	    {
	      if ( isupper(ch) ) print_version ();
	      been_here.print_version = 1;
	    }
	  break;
	case '-':
	case '\'':
	case '"':
	  break;
	case '?':
	  push_stack ( sym_stack, cur_syms );
	  cur_syms = & messages;
	  sp = (symbol *) lookup ( "msg_usage", 0 );
	  if ( sp ) put_strs ( sp->strs, stdout );
	  else printf ( "no help available\n" );
	  cur_syms = (symbol **) pop_stack ( sym_stack );
	  break;
	default:
	  fprintf ( stderr, find_msg ( "msg_unk_opt" ), ch );
	  putchar ( '\n' );
	  ++ errors;
	break;
      }
quit:
  if ( do_debug ) fprintf ( stderr, "options: %s\n", str );
  return used_next;
} /* options */
