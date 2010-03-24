/* -----------------------  verify_symbol_table  ---------------------*/
#include <sli.h>

int	verify_symbol_table ( table, lev, fp )
  symbol	* table;
  int		  lev;
  FILE		* fp;
{
  int	  ret = 1;
  char	* find_msg ();

  lev = 0; /* only to avoid compiler warning */
  _COB_for_list ( spp, list, table, symbol )
    if ( ! spp->defined ) 
      {
	++ errors;
	if ( fp )
          {
            fprintf ( fp, find_msg ( "msg_undef_sym" ), spp->name );
            putc ( '\n', fp );
          }
        ret = 0;
      }
  _COB_end_for_list /* ( spp ) */
  return ret;
} /* verify_symbol_table */
