/* -----------------------  define_actions  --------------------------*/
#include "../sli/y.tab.h"
#include <sli.h>
#include <ode_export.h>
static find_args ();
static int std_args ();
static void check_for_override ();

define_actions ( a_class_sp )
  symbol	* a_class_sp;
{
  /*** for each action for this class:				    ***/
  /***	1.  If the action has an arg list, see if it's an override  ***/
  /***	    Else get the argument list				    ***/
  /***	2.  If the arglist turns out to be the "standard" arg list, ***/
  /***	    make it NULL					    ***/

  _COB_for_list ( spp, list, a_class_sp->actions, symbol )
    if ( spp->args )
      check_for_override ( a_class_sp, spp );
    else
      find_args ( a_class_sp, spp );
    if ( spp->args )
      if ( std_args ( spp->args )) spp->args = NULL;
  _COB_end_for_list
} /* define_actions */

/* -----------------------  find_args  -------------------------------*/
static find_args ( a_class_sp, act_sp )
  symbol	* a_class_sp;
  symbol	* act_sp;
{
  symbol	* cp;
  symbol	* ap;

	/*** save cursyms ***/
  push_stack ( sym_stack, cur_syms );

	/*** for each parent class, see if it defines the action  ***/
	/***   name ( act_sp->name )				  ***/

  _COB_for_list ( lp, list, (list_rec *) a_class_sp->owner, list_rec )
    cp = (symbol *) lp->val;
    if ( do_debug )
      fprintf ( stderr, "find args for %s -- checking class %s\n",
          act_sp->name, cp->name );
    cur_syms = & cp->actions;
    ap = (symbol *) lookup ( act_sp->name, ACTION );
    if ( ap )	/*** cp [class] symbol ptr either defines/overrides ***/
      {		/***   the method				    ***/

	/*** the current class inherits the method from somewhere ***/
        act_sp->inherited = 1;

	/*** act_sp->owner is class where the action is sent when  ***/
	/***   you send "with respect to object" ( perhaps not the ***/
	/***   same as the class originally defining the method )  ***/
        if ( ! act_sp->owner )
	  act_sp->owner = cp;

	/*** if the class where the method is first found ( scanning **/
	/***   up the tree ) ALSO inherits the method, then keep     **/
	/***   looking for the original declaration of the method to **/
	/***   get the argument list				    ***/
        if ( ap->inherited )
	  find_args ( cp, act_sp );
        else	/*** otherwise, you've found the arg list ***/
	  act_sp->args = ap->args;
        break; /* lp for_list */

      }
    else  /*** didn't find the method overridden/declared in this ***/
      {   /***   parent, so look up the tree of ancestor classes  ***/
	  /***   DEPTH-first -- LMB:04-04-88			  ***/
        find_args ( cp, act_sp );
        if ( act_sp->args )	/*** stop when you find the method ***/
            break;		/*** declared			   ***/
      }
  _COB_end_for_list /* ( lp ) */

	/*** restore cursyms ***/
  cur_syms = (symbol **) pop_stack ( sym_stack );

} /* find_args */

/* -------------------------  std_args  ------------------------------*/
static int std_args ( arg_list )
  char	* arg_list;
{

  int		  j;
  char		  ch;
  static symbol	* def_sp = NULL;
  char *	ch1, *ch2;
  char		the_same = 1;

  if ( ! def_sp )
    {
      push_stack ( sym_stack, cur_syms );
      cur_syms = & top_syms;
      def_sp = (symbol *) find_type ( _sli_method_default );
      cur_syms = (symbol **) pop_stack ( sym_stack );
    }
  if ( def_sp )
    {
      _COB_for_list ( strp, list, def_sp->strs, str_rec )
        j = 0;
        while (( ch = strp->str [j] ) && ch != '(' ) ++ j;
        if ( ch == '(' )
	  {
           /*** check the arg lists to see if they're the same  ***/
           /***   except for white space ***/
            for ( ch1 = arg_list, ch2 = & strp->str[j] ; *ch1 && *ch2;)
	      {
	        while ( isspace(*ch1) && *ch1 ) ch1++;
	        while ( isspace(*ch2) && *ch2 ) ch2++;
	        if ( *ch1 != *ch2 )
	          {
		    the_same = 0;
		    break;
	          }
	        ch1++;
	        ch2++;
	      }
	    return the_same ;
	  }
      _COB_end_for_list /* ( strp ) */
    }
  return 0;
} /* std_args */

/* -----------------------  check_for_override  ----------------------*/
static void check_for_override ( a_class_sp, action_sp )
  symbol	* a_class_sp;
  symbol	* action_sp;
{
  symbol	* sp;
  symbol	* find_definition ();
  char *	ch1, *ch2;
  char		the_same = 1;

  sp = find_definition ( a_class_sp, action_sp->name );
  if ( sp )
    {
      /*** check the arg lists to see if they're the same  ***/
      /***   except for white space ***/
      for ( ch1 = action_sp->args, ch2 = sp->args ; * ch1 && * ch2 ; )
	{
	  while ( isspace(*ch1) && *ch1 ) ch1++;
	  while ( isspace(*ch2) && *ch2 ) ch2++;
	  if ( *ch1 != *ch2 )
	    {
		the_same = 0;
		break;
	    }
	  ch1++;
	  ch2++;
	}

	/*** see if they're the same ***/
	if ( the_same )
	  {
	    /*** override this message ***/
	    action_sp->inherited=1;

	    /*** issue an appropriate warning message ***/
	    fprintf(stderr, (char *)find_msg ( "msg_act_over" ),
		sp->owner->name, action_sp->name );
	    putc ( '\n', stderr );
	  }
	else  /*** the arg lists are different ***/
	  {
	    /*** don't override the ancestor's message;  ***/
	    /***   declare a new message "stream" with this arglist ***/

	    /*** issue an appropriate warning message ***/
	    fprintf(stderr, (char *)find_msg ( "msg_new_act" ), action_sp->name );
	    putc ( '\n', stderr );
	  }
    }
} /* check_for_override */
