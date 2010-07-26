/* ---------------------  trans_list_out  ----------------------------*/
#include <sli.h>
static all_states_out ();

/*** trans_list_out --  Output one state's actions and transitions ***/
/*** 			to the .T file				   ***/

trans_list_out ( act_list, state_name )
  action_rec	* act_list;
  char		* state_name;
{
  char	  found_on_else = 0;	/** 1 = reached "on ELSE" line	   **/
  char	  need_acts = 1;	/** haven't output state * actions **/
  char	  need_trans = 1;	/** haven't output state * trans   **/
  extern char	* find_msg ();

  _verbose(if(do_debug)
      fprintf(stderr,"trans_list_out %d\n",act_list);)
  _COB_for_list ( app, list, act_list, action_rec )
    if ( app->act == _sli_response )
      {
        if ( !strcmp ( app->str, "_ceo_else" ) )  /*** JAJ:12-05-88 ***/
          {
	    if ( ! found_on_else )
	      {
		found_on_else = 1;
	      }
	    else  /** already had one ON ELSE in state, ***/
	      {   /***   so ignore this one		***/
		fprintf ( stderr, find_msg ( "msg_mult_on_else" ),
							state_name );
		putc ( '\n', stderr );
		continue;
	      }
          }
        if ( need_acts && all_sp )
          {
	    /** output the state * actions (before the 1st trans) **/
            all_states_out ( act_list, _sli_do_act );
            need_acts = 0;
          }
        if ( !strcmp ( app->str, "_ceo_else" ) && all_sp )
          {
	    /** output the state * trans (before the "on ELSE")  **/
            all_states_out ( act_list, _sli_response );
            need_trans = 0;
          }
        trans_out ( app );	/*** output the current trans ***/
      }
    else act_out ( app );	/*** output the current action ***/
  _COB_end_for_list /* ( app ) */

  if ( need_acts && all_sp )
    /*** if state *'s actions haven't been output yet, do it ***/
    all_states_out ( act_list, _sli_do_act );

  if ( need_trans && all_sp )
    /*** if state *'s trans haven't been output yet, do it ***/
    all_states_out ( act_list, _sli_response );

} /* trans_list_out */

/* ------- all_states_out ------- */
/** this is static so that only the funcs in this file know about it **/
static all_states_out ( act_list, act )
  action_rec	* act_list;
  int		  act;	/** 0 = _sli_response ==> transition type **/
			/** 1 = _sli_do_act   ==> action type **/
{
  char	  need;	/* 0 = state *'s action/trans is already in this state*/
	        /* 1 = state *'s action/trans is NOT in this state */

  _COB_for_list ( app, list, all_sp->acts, action_rec )
    if ( app->act == act )
      {
        need = 1;
	/** compare the state *'s act/trans with each of **/
	/**   this state's act/trans **/ 
        _COB_for_list ( sapp, list, act_list, action_rec )
          if ( sapp->act == act )
            if ( !strcmp ( sapp->str, app->str ))
              {
                need = 0;
                break;
              }
        _COB_end_for_list /* ( sapp ) */

	/* if state "*" has an "on X or Y" in it, output it even */
	/*   if some of the X's or Y's have been seen already	 */
	if (  app->act == _sli_response  &&  app->trans_or_list )
	    need = 1;				/* JAJ:01-18-88  */

        if ( need )
          if ( act == _sli_response ) trans_out ( app );
          else act_out ( app );
      }
  _COB_end_for_list /* ( app ) */
} /* all_states_out */
