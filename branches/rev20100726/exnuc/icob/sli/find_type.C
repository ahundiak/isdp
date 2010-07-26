/* -----------------------  find_type  -------------------------------*/
#include <sli.h>

symbol	* find_type ( type )
  int	  type;
{
  symbol	* sp;

  sp = NULL;
  _COB_for_list ( spp, list, * cur_syms, symbol )
    if ( spp->type == type )
      {
	sp = spp;
	break;
      }
  _COB_end_for_list /*  spp  */
  return sp;
} /* find_type */
