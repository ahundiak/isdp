/* -----------------------  insert_sym  ------------------------------*/
#include <sli.h>

symbol	* insert_sym ( sym, typ, is_def, msg )
  char		* sym;
  short		  typ;
  char		  is_def;
  char		* msg;
{
  symbol	* sp;
  char		  err_msg [200];
  extern   char * calloc( );

  sp = (symbol *) lookup ( sym, typ );
  if ( sp )
    {
      if ( sp->defined )
	{
	  if ( is_def && msg )
	    {
	      sprintf ( err_msg, "%s: %s", msg, sym );
	      yyerror ( err_msg );
	    }
	}
      else if ( is_def )
	{
	  sp->type = typ;
	  sp->defined = is_def;
	}
    }
  else
    {
      if ( msg && ! is_def )
	{
	  sprintf ( err_msg, "%s: %s", msg, sym );
	  yyerror ( err_msg );
	}
      sp = (symbol *) calloc ( 1, sizeof (symbol) );
      if ( ! sp )
        {
          fprintf(stderr,
	    "slic: insert_sym() -- No dynamic memory available\n\n");
          exit(1);
        }
      _COB_append_to_list ( sp, list, * cur_syms );
      sp->name = sym;
      sp->type = typ;
      sp->defined = is_def;
    }
  return sp;
} /* insert_sym */
