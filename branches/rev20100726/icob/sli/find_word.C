/*----------------  sli_find_word  -----------------------------------*/
#include <sli.h>

symbol		* lookup ();

sli_find_word ( str )
  char		* str;
{
  symbol	* sp;
  char		  string [180];
  char		* find_msg ();

  push_stack ( sym_stack, cur_syms );
  cur_syms = & keywords;
  sp = lookup ( str, 0 );
  if ( sp ) word_val = sp->offset + _words_offset;
  else
    {
      word_val = 0;
      sprintf ( string, find_msg ( "msg_unk_word" ), str );
      yyerror ( string );
    }
  cur_syms = (symbol **) pop_stack ( sym_stack );
}
