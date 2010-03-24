/* -------------------------iws_out-----------------------------------*/
#include "../sli/y.tab.h"
#include <sli.h>

iws_out ( state_sp )
  symbol	* state_sp;
{

  int		  resp_cnt = 0;

  fprintf ( tblf, "%s%s()\n", level, & state_sp->name [3]);
  fprintf ( tblf, "%s  {\n", level );
  strcat ( level, "    " );
  _COB_for_list ( app, list, state_sp->acts, action_rec )
    if ( app->act == _sli_response )
      {
        if ( ++ resp_cnt == 1 ) trans_out ( app );
      }
    else if ( app->act == _sli_next ) -- resp_cnt;
    else if ( ! resp_cnt ) act_out ( app );
  _COB_end_for_list /* ( app ) */
  level [ strlen ( level ) - 4 ] = NULL;
  fprintf ( tblf, "%s  }\n", level );
} /* iws_out */
