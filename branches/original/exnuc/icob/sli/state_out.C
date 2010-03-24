/* ---------------------  state_out  ---------------------------------*/
#include "../sli/y.tab.h"
#include <sli.h>

symbol		* lookup ();

state_out ( state_sp )
  symbol	* state_sp;
{

  char		  string [180];

  _verbose(if(do_debug)
   fprintf(stderr,"state_out %s %d\n",state_sp->name,state_sp->offset);)
  sprintf ( string, state_name_sp->strs->str, state_sp->name );
  fprintf ( tblf, "%ss(%s)\n", level, string );
  fprintf ( tblf, "%s  {\n", level );
  strcat ( level, "    " );
/*************************  LMB:09-16-87 *******************************
  _for_list ( action_rec, state_sp->acts, app )
    act_out ( app );
  _end_for_list ( app )
***********************************************************************/
  cur_sym = state_sp;
	/** send the state action/trans list **/
  trans_list_out ( state_sp->acts, state_sp->name );
  level [ strlen ( level ) - 4 ] = NULL;
  fprintf ( tblf, "%s  }\n", level );
} /* state_out */
