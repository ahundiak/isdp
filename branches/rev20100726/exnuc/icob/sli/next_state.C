/* ------------------  sli_next_state  -------------------------------*/
#include <sli.h>

symbol		* lookup ();

sli_next_state ( str )
  char		* str;
{
  action_rec	* act_ptr;
  extern   char * calloc( );

  cur_act_list = (action_rec **) pop_stack ( act_stack );
  strcpy ( str, strip_quotes ( str ));
  act_ptr = (action_rec *) calloc ( 1, sizeof ( action_rec ));
  if ( ! act_ptr )
    {
      fprintf(stderr,
	"slic: sli_next_state() -- No dynamic memory available\n\n");
      exit(1);
    }
  act_ptr->act = _sli_next;
  act_ptr->str = str;
  _COB_append_to_list ( act_ptr, list, * cur_act_list );
}
