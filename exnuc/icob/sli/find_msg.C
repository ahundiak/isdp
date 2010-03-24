/* ---------------------find_msg--------------------------------------*/
#include <sli.h>

char * find_msg ( msg_str )
  char		* msg_str;
{
  symbol	* sp;

  push_stack ( sym_stack, cur_syms );
  cur_syms = & messages;
  sp = (symbol *) lookup ( msg_str, 0 );
  cur_syms = (symbol **) pop_stack ( sym_stack );
  if ( sp ) return sp->strs->str;
  else return msg_str;
}
