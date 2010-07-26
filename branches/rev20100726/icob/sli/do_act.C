/* -----------------------  sli_do_act  ------------------------------*/
#include <sli.h>

sli_do_act ( exec, act )
  char		* exec;
  char		* act;
{
  symbol	* sp;
  action_rec	* act_ptr;
  char		* ex_str;
  char		  string [180];
  symbol	* lookup ();
  char		* find_msg ();
  extern   char * calloc( );

  if ( exec )
    {
      push_stack ( sym_stack, cur_syms );
      cur_syms = & var_words;
      sp = lookup ( exec, 0 );
      if ( sp ) ex_str = sp->args;
      else ex_str = exec ;
      if ( strcmp ( ex_str, "_execute" ))
        {
          sprintf ( string, find_msg ( "msg_inv_exec" ), exec );
          yyerror ( string );
        }
      cur_syms = (symbol **) pop_stack ( sym_stack );
    }
  strcpy ( act, strip_quotes ( act ));
  act_ptr = (action_rec *) calloc ( 1, sizeof ( action_rec ));
  if ( ! act_ptr )
    {
      fprintf(stderr,
	"slic: sli_do_act() -- No dynamic memory available\n\n");
      exit(1);
    }
  act_ptr->act = _sli_do_act;
  act_ptr->type = 1;
  act_ptr->str = act;
  act_ptr->owner = NULL;
  act_ptr->class = NULL;
  act_ptr->args = NULL;
  _COB_append_to_list ( act_ptr, list, * cur_act_list );
}
