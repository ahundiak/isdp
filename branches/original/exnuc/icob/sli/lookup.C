/* -----------------------  lookup  ----------------------------------*/
#include <sli.h>

symbol	* lookup ( sym, type )
  char	* sym;
  int	  type;
{
  symbol	* sp;

  sp = NULL;
  _COB_for_list ( spp, list, * cur_syms, symbol )
    if ( !strcmp ( spp->name, sym ) && spp->type == type )
      {
	sp = spp;
	break;
      }
  _COB_end_for_list /* ( spp ) */
/*****
  if ( sp && sp != * cur_syms )
    {
      remove_from_list ( sp, list, * cur_syms );
      _insert_head ( sp, list, * cur_syms );
    }
*****/
  return sp;
} /* lookup */
