/* -----------------  sli_args_declare  ------------------------------*/
#include <sli.h>

sli_args_declare ()
{
  char	* str_ptr;
  extern  char * calloc( );

  str_ptr = (char *) calloc ( 1, strlen ( big_str ) + 1 );
  if ( ! str_ptr )
    {
      fprintf(stderr,
	"slic: sli_args_declare() -- No dynamic memory available\n\n");
      exit(1);
    }
  strcpy ( str_ptr, big_str );
  big_str [0] = NULL;
  cur_sym->args = str_ptr;
  _verbose(if(do_debug)
      fprintf(stderr,"act %s args_decl %s\n",cur_sym->name,str_ptr);)
}
