/* -------------------  sli_sub_response  ----------------------------*/
#include <sli.h>

symbol		* lookup ();

sli_sub_response ( str, strip_quotes_flag )
  char		* str;
  int		  strip_quotes_flag;	/*** JAJ:08-07-89 ***/
{
  action_rec	* act_ptr;
  symbol	* sp;
  extern   char * calloc( );

  push_stack ( sym_stack, cur_syms );
  cur_syms = & var_words;
  sp = lookup ( str, 0 );
  if ( sp ) str = sp->args;
  cur_syms = (symbol **) pop_stack ( sym_stack );
  act_ptr = (action_rec *) calloc ( 1, sizeof ( action_rec ));
  if ( ! act_ptr )
    {
      fprintf(stderr,
	"slic: sli_sub_response() -- No dynamic memory available\n\n");
      exit(1);
    }
  act_ptr->act = _sli_sub_response;
  act_ptr->str = str;

  if ( strip_quotes_flag )	/*** JAJ:08-07-89 ***/
    strcpy ( act_ptr->str, strip_quotes ( act_ptr->str ));

  if ( trans_or_flag )
    {
      _COB_append_to_list ( act_ptr, list, * trans_or_ptr );
    }
  else
    {
      _COB_append_to_list ( act_ptr, list, * cur_act_list );
    }
}
