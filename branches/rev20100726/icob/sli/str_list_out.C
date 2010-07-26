/* -----------------------  str_list_out  ----------------------------*/
#include <sli.h>

str_list_out ( str_list, commas )
  str_rec	* str_list;
  int		  commas;
{
  int	  j = 0;

  _COB_for_list ( strp, list, str_list, str_rec )
    fprintf ( tblf, ",%s", strp->str );
    ++ j;
  _COB_end_for_list /* ( strp ) */
  for ( ; j < commas; ++ j ) putc ( ',', tblf );
} /* str_list_out */
