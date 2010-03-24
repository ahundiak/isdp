/* --------------------  sli_response  -------------------------------*/
#include <sli.h>

sli_response ( str, type )
  char		* str;
  int		  type;
{
  symbol	* sp;
  action_rec	* act_ptr;
  extern   char * calloc( );

  strcpy ( str, strip_quotes ( str ));
  push_stack ( sym_stack, cur_syms );
  cur_syms = & var_words;
  sp = (symbol *) lookup ( str, 0 );
  if ( sp ) str = sp->args;
  cur_syms = (symbol **) pop_stack ( sym_stack );
  act_ptr = (action_rec *) calloc ( 1, sizeof ( action_rec ));
  if ( ! act_ptr )
    {
      fprintf(stderr,
	"slic: sli_response() -- No dynamic memory available\n\n");
      exit(1);
    }
  act_ptr->act = _sli_response;
  act_ptr->type = type;
  act_ptr->str = str;
  act_ptr->owner = NULL;

  if ( trans_or_flag )
    {
      _COB_append_to_list ( act_ptr, list, * trans_or_ptr );
    }
  else
    {
      _COB_append_to_list ( act_ptr, list, * cur_act_list );
      push_stack ( act_stack, cur_act_list );
      cur_act_list = & act_ptr->owner;
      trans_or_ptr = & act_ptr->trans_or_list;
    }
}
