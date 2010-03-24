/* ---------------------  find_definition  ---------------------------*/
#include "../sli/y.tab.h"
#include <sli.h>

symbol * find_definition ( a_class_sp, act_name )
  symbol	* a_class_sp;
  char		* act_name;
{
  symbol	* cp;
  symbol	* ap = NULL;
  symbol	* lookup ();

  push_stack ( sym_stack, cur_syms );
  _COB_for_list ( lp, list, (list_rec *) a_class_sp->owner, list_rec )
    cp = (symbol *) lp->val;
    cur_syms = & cp->actions;
    ap = lookup ( act_name, ACTION );
    if ( ap ) break;
  _COB_end_for_list /* ( lp ) */
  if ( ! ap )
    _COB_for_list ( lp, list, (list_rec *) a_class_sp->owner, list_rec )
      ap = find_definition ( (symbol *)lp->val, act_name );
      if ( ap ) break;
    _COB_end_for_list /* ( lp ) */
  cur_syms = (symbol **) pop_stack ( sym_stack );
  return ap;
} /* find_definition */
