/* ---------------------  sli_do_args  -------------------------------*/
#include <sli.h>

sli_do_args ()
{
  char		* str_ptr;
  extern   char * calloc( );

  str_ptr = (char *) calloc ( 1, strlen ( big_str ) + 1 );
  if ( ! str_ptr )
    {
      fprintf(stderr,
	"slic: sli_do_args() -- No dynamic memory available\n\n");
      exit(1);
    }
  strcpy ( str_ptr, big_str );
  ( * cur_act_list )->list.prev->args = str_ptr;
}
