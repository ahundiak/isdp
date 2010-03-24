/* ------------------------  act_out  --------------------------------*/
#include "../sli/y.tab.h"
#include <sli.h>
#include <ode_export.h>

void act_out ( act_ptr )
  action_rec	* act_ptr;
{
  char		  string [180];
  char		* str_ptr;
  symbol	* csp = NULL;	/* class symbol ptr */
  symbol	* asp = NULL;	/* a symbol ptr */
  symbol	* lookup(), *insert_sym(),
		* find_definition(), *find_type();
  char		* find_msg ();

  if ( act_ptr->act != _sli_do_act ) return;

  if ( act_ptr->type )	/* 1 = user action; 0 = ceo action selector */
    {
      push_stack ( sym_stack, cur_syms );
      if ( act_ptr->class ) /* user said "<class>.<action>" */
	{
          if ( !strcmp ( act_ptr->class, class_sp->name ))
		csp = class_sp;		/* <class> == current class */
          else
            {	/* lookup the class name */
              cur_syms = & top_syms;
              csp = lookup ( act_ptr->class, _super_word );
              if ( ! csp )
                csp = lookup ( act_ptr->class, _sli_do_class );
              if ( ! csp )
                csp = insert_sym ( act_ptr->class, _sli_do_class, 1, NULL );
            }
	}
      else	/* no class name given for action */
        {
          cur_syms = & class_sp->actions;
	    /** see if this action is defined by the current class **/
          csp = lookup ( act_ptr->str, ACTION );
          if ( ! csp ) /** search for class defining this action **/
            csp = find_definition ( class_sp, act_ptr->str );
          if ( csp )	/* find_def returns ptr to action, not class */
	    csp = csp->owner;	/* point csp at action's owner class */
          else
            {
              sprintf ( string, find_msg ( "msg_undef_act" ), act_ptr->str );
              yyerror ( string );
              csp = class_sp;
            }
        }
      if ( ! act_ptr->args )	/* there's no argument list */
	{
          cur_syms = & csp->actions;
		/** lookup the action to see if it needs an arg list **/
          asp = lookup ( act_ptr->str, ACTION );
          if ( asp )
	   {
	    if ( asp->args )
	      {
	        sprintf ( string, find_msg ( "msg_needs_args" ),
							asp->name );
	        yyerror ( string );
	      }
	    /***********************************************************
            if ( csp->type == _super_word )
		/** assign action # for action defined by parent
              act_ptr->type = asp->offset + csp->num * ( _ceo_max_action + 1 );
            else
		act_ptr->type = asp->offset;
	    ***********************************************************/
	   }
          else
            {
              sprintf ( string, find_msg ( "msg_undef_act" ), act_ptr->str );
              yyerror ( string );
            }
        }
      cur_syms = (symbol **) pop_stack ( sym_stack );

      if ( act_ptr->args )
	{
	  str_ptr = & act_ptr->args[strlen(act_ptr->args)-1];

	  if ( *str_ptr == ')' )	/*** JAJ:11-05-88 ***/
	    {
		/* strip beginning '(' and ending ')' from arg list */
	      *str_ptr = '\0';
	    }
	  str_ptr = & act_ptr->args[1];
	}
      else	/* stick on default argument list */
	{
	  asp = find_type ( _sli_args_default );
	  if ( asp )
	    str_ptr = asp->strs->str;
	  else
	    str_ptr = "";
	}

      fprintf ( tblf, "%sa(%s,%s,%s)\n", level,
		( csp == class_sp ) ? "" : csp->name,	/* class  name*/
		act_ptr->str,				/* action name*/
		str_ptr );				/* action args*/
    }
  else	/** it's not a user action **/
    {
       /*** if ( act_ptr->args ) ***/
    fprintf ( tblf, "%sa(,,%s,%s,sts)\n",
		level, act_ptr->str, act_ptr->args );
    /*** else fprintf ( tblf, "%sa(,,%s)\n", level, act_ptr->str ); ***/
    }

} /* act_out */
