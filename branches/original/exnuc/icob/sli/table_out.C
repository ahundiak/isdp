/* -----------------------  table_out  -------------------------------*/
#include "../sli/y.tab.h"
#include <sli.h>

int	num_states		   = 0;
int	num_actions		   = 0;
int	num_action_args		   = 0;
int	num_trans		   = 0;
int	num_trans_pods	 	   = 0;
int	num_state_star_actions     = 0;
int	num_state_star_action_args = 0;
int	num_state_star_trans	   = 0;
int	num_state_star_trans_pods  = 0;

/*** this counts the UPPER LIMIT on the # of actions,	***/
/***   transitions, action arguments, and transition	***/
/***   <predicate, operator, data> triples in the	***/
/***   state table					***/
static count_act_trans ( state_offset, act_list )
  int		state_offset;
  action_rec   *act_list;
{
  char		*ch;

  _COB_for_list ( at_ptr, list, act_list, action_rec )
    if ( at_ptr->act == _sli_do_act )	/* ACTION */
      {
	if ( state_offset != -990 )	/* regular action */
	  {
	    num_actions ++;
	  }
	else
	  {
	    num_state_star_actions ++;	/* "state *" action */
	  }

		/*** count the # of arguments to the action ***/
	if ( at_ptr->type )	/* 1 => user action */
				/* 0 =>  ceo action */
	  {
	    if ( at_ptr->args )	/*** non-default arg list ***/
	      {
		/*** count the commas in the argument list ***/
	        for ( ch = at_ptr->args ;  *ch  ;  ch ++ )
	          {
		    if ( *ch == ',' )
		      {
		        if ( state_offset != -990 )  /* reg act args*/
			    num_action_args ++;
		        else			/* "state *" act args */
			    num_state_star_action_args ++;
		      }
	          }
		    /*** add one ( # args = # commas + 1 ) ***/
	        if ( state_offset != -990 )	/* regular action */
	          {
	            num_action_args ++;
	          }
	        else
	          {
	            num_state_star_action_args ++;
	          }
	      }
	    else	/*** default "sts" arg list; arg num = 1 ***/
	      {
	        if ( state_offset != -990 )	/* regular action */
	          {
	            num_action_args ++;
	          }
	        else
	          {
	            num_state_star_action_args ++;
	          }
	      }
	  }
	else	/*** CEO.action call; always has 3 arguments ***/
	  {
	    if ( state_offset != -990 )	/* regular action */
	      {
	        num_action_args += 3;	/* for <_filter>,<2>,<*sts> */
	      }
	    else
	      {
	        num_state_star_action_args += 3; /* for <_filter>,<2>,<*sts> */
	      }
	  }
      }
    else if ( at_ptr->act == _sli_response )	/* TRANS  */
      {
	if ( state_offset != -990 )	/* regular trans */
	  {
	    num_trans ++;
	  }
	else
	  {
	    num_state_star_trans ++;	  /* "state *" trans */
	  }

	   /*** count the OR'ed <predicate,operator,data> triples ***/
	_COB_for_list( t_or_ptr, list, at_ptr->trans_or_list,\
							 action_rec )
	    if ( t_or_ptr->act == _sli_response )
	      {
		if ( state_offset != -990 )	/* regular trans */
		  num_trans_pods ++;
		else
		  num_state_star_trans_pods ++;	/* "state *" trans */
	      }

	_COB_end_for_list /* ( at_ptr ) */


	/*** count the actions/trans which are 	***/
	/***   "owned" by this trans		***/
	if ( at_ptr->owner )
	  count_act_trans ( state_offset, at_ptr->owner );
      }
  _COB_end_for_list /* ( state_spp ) */
}



table_out ()
{
  symbol	* sp;
extern  char	* give_version();
  symbol	* lookup ();

  _verbose(if(do_debug)fprintf(stderr,"table_out\n");)
  if ( dot_t_sp ) copy_lines ( tblf, dot_t_sp, STATE_TABLE );

	/*** say "include ___.h" instead of		 	 ***/
	/***     "include <exnuc>/include/xxx.h" -- JAJ:01_24_90 ***/
  fprintf ( tblf, "#include \"ode_export.h\"\n" );
  fprintf ( tblf, "#include \"exdef.h\"\n"      );
  fprintf ( tblf, "#include \"msdef.h\"\n"      );

  if ( draft_env  &&  strcmp ( draft_env, "" ) )
    {
      fprintf ( tblf, "#include \"griodef.h\"\n" );
      fprintf ( tblf, "#include \"lcdef.h\"\n"   );
    }
  level [0] = NULL;

    /*********************************************** JAJ:11-21-88 ***/
    /*** count the # of states, actions, and transitions	  ***/
  _COB_for_list ( spp, list, top_syms, symbol )
    if ( spp->type == STATE )
      {
	if ( spp->offset >= 0 )		/* regular state */
	  num_states ++;

	count_act_trans ( spp->offset, spp->acts );
      }
  _COB_end_for_list /* ( spp ) */

    /*** adjust the counters to account for "state *" ***/
    /***   (this may not be exact, but it WILL be an upper limit ***/
  num_actions	  += ( num_state_star_actions	  * num_states );
  num_action_args += ( num_state_star_action_args * num_states );
  num_trans	  += ( num_state_star_trans	  * num_states );
  num_trans_pods  += num_trans + ( num_state_star_trans_pods * num_states );

    /*** Prevent CEO.init from calloc'ing 0 bytes -- JAJ:01-05-89 ***/
  if ( ! num_actions	 )	num_actions = 1;
  if ( ! num_action_args )	num_action_args = 1;
  if ( ! num_trans	 )	num_trans = 1;
  if ( ! num_trans_pods  )	num_trans_pods = 1;

/*
  fprintf ( stderr, "\nnum_states = %hd\n", num_states );
  fprintf ( stderr, "num_actions = %hd\n", num_actions );
  fprintf ( stderr, "num_action_args = %hd\n", num_action_args );
  fprintf ( stderr, "num_trans = %hd\n", num_trans );
  fprintf ( stderr, "num_trans_pods = %hd\n", num_trans_pods );
  fprintf ( stderr, "num_state_star_actions = %hd\n",
					num_state_star_actions );
  fprintf ( stderr, "num_state_star_action_args = %hd\n",
					num_state_star_action_args );
  fprintf ( stderr, "num_state_star_trans = %hd\n",
					num_state_star_trans );
  fprintf ( stderr, "(extra) num_state_star_trans_pods = %hd\n\n",
					num_state_star_trans_pods );
*/

  /*** the next line gets deleted from the tfile (along with all ***/
  /***   lines above it) by a sed script sli_cpp_tfile()  ***/
  fprintf ( tblf, "\nXxXxXx\nCOB_TFILE_STARTS_HERE\n" );  /** JAJ:12-20-87**/
  fprintf ( tblf, "CDO(%s,%hd,%hd,%hd,%hd,%hd)\n{\n",
		give_version(), num_states,
		num_actions, num_action_args,
		num_trans, num_trans_pods );
  strcat ( level, "  " );

  _COB_for_list ( spp, list, top_syms, symbol )
    if ( spp->type == _form_word )
      {
        fprintf ( tblf, "%sform(%s", level, spp->name );
        str_list_out ( spp->strs, 4 );
        fprintf ( tblf, ")\n" );
      }
    else if ( spp->type == _status_display_word )
      {
        fprintf ( tblf, "%sstatus_display(%s", level, spp->name );
        str_list_out ( spp->strs, 1 );
        fprintf ( tblf, ")\n" );
      }
  _COB_end_for_list /* ( spp ) */
  sp = lookup ( "at init", STATE );
  if ( sp ) iws_out ( sp );
  sp = lookup ( "at wakeup", STATE );
  if ( sp ) iws_out ( sp );
  sp = lookup ( "at sleep", STATE );
  if ( sp ) iws_out ( sp );
  sp = lookup ( "at delete", STATE );
  if ( sp ) iws_out ( sp );
  _COB_for_list ( spp, list, top_syms, symbol )
    if ( spp->type == STATE )
      if ( spp->offset >= 0 )
        state_out ( spp );
  _COB_end_for_list /* ( spp ) */
  fprintf ( tblf, "}\n" );
} /* table_out */
