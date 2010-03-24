/* ceo/real_execute.I */
/*
  do
    send activate to current state
    if a transition "fires", status will be stop_sending
  until input is not used or terminate
*/
class implementation CEO;

#include <stdio.h>
#include <COBmsg.h>	/*** msg # include file -- JAJ:04-01-88 ***/

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif


method real_execute (
  int	* response;
  char	* response_data;
  int	  position;
			/** when called from			     **/
			/**       CEO			CEO_LOCATE   **/
			/**      -----		       ------------  **/
  int  ** ceo_response;)/**  & me->response	& of a ptr to 	     **/
			/**			 me->event1.response **/
{
  int	status;
  int   do_suspend=0;/** 0 - transition to state other than _suspend **/
  		     /** 1 - transition to state _suspend (by choice **/
		     /**     or if no transitions "fire" )	     **/
  int   ignore_msg;  /** msg num of "ignoring ___" response text     **/
  struct COBstate * current_state_ptr;

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct super_cmd_instance	* p_super_cmd = ME.super_cmd;
  struct CEO_instance		* p_CEO = ME.CEO;


  _bugprint(bflag=TFLAG, str =
	"+CEO.real_execute( *resp=%d, resp_data='%s', pos=%d\n",
	var = `*response, response_data, position` )
  _bugprint(bflag=TFLAG, str = "\t**ceo_resp=%d ); me->ret=%d\n",
	var = `**ceo_response, p_CEO->ret` )

  if ( p_super_cmd->state == _terminate )
    {
     /**** delayed error from init or wakeup ****/
      * response = TERMINATE;
      goto quit;
    }

  p_CEO->response = response;
  p_CEO->response_data = response_data;

  do
    {
      ignore_msg = 0;  /*** JAJ:02-10-88 ***/

      /**** hopefully, the next two lines will fix the bug where ****/
      /****    * response is always TERMINATE  if you never  ****/
      /****     have a filter call other than "filter none"  ****/
      * response = -1;

      ** ceo_response = -1;	/*** JAJ:04-07-88 ***/

      p_CEO->ret = OM_S_SUCCESS;

      current_state_ptr = NULL;
      _COB_for_list ( state_ptr, list, p_CEO->states_ptr, \
						struct COBstate )
	if ( state_ptr->state_id == p_super_cmd->state )
	  {	/*** found current state ***/
	    current_state_ptr = state_ptr;
	    break;
	  }
      _COB_end_for_list

      if ( current_state_ptr == NULL )
	{
	  fprintf( stderr,
	    "\nCEO.real_execute():  Error in locating current state %d\n\n",
	    p_super_cmd->state );
	  * p_CEO->response = TERMINATE;
	  goto quit;
	}

      _bugprint(bflag=CEO_debug, str =
	"Calling COBstate.do_it( state_ptr=(0x)%x, my_id=%d, &me->ret=(0x)%x )\n",
	 var = `current_state_ptr, my_id, &p_CEO->ret` )

      status = COBstate_do_it ( current_state_ptr, my_id,
							& p_CEO->ret );

      if ( p_CEO->ret == COB_E_ARG_NOT_FOUND )	/*** JAJ:02-01-88 ***/
	{
	  * response = TERMINATE;
	  goto quit;
	}
      _cob_check ( status, "CEO.real_execute:  Error in COBstate_do_it()." );


      if ( status == OM_I_STOP_SENDING )
	{
	  do_suspend = _false;

	  _bugprint(bflag=CEO_debug, str =
		"Sending myself CEO.action(_go_next_state,NULL,&do_suspend)\n" )
	  _send ( my_id, CEO.action ( _go_next_state, NULL, &do_suspend ));
          _cob_check ( status, "CEO.real_execute:  CEO.action ( go_next_state ) failed." );
	}
      else  /** none of the transitions "fired"; goto cmdserver **/
	{
	  /** don't return responses that cmd_server doesn't process **/
	  if ( *response == EX_RESTART )
	    {
	      ignore_msg = COB_S_Ig_RESTART;
	    }
	  else if ( *response == EX_BACK_UP )
	    {
	      ignore_msg = COB_S_Ig_BACK_UP;
	    }
	  else if ( *response == EX_RJT_MOVEON )
	    {
	      ignore_msg = COB_S_Ig_RJT_MOVEON;
	    }
	  else if ( *response == EX_DATA )
	    {
	      ignore_msg = COB_S_Ig_DATA;
	    }
	  else if ( *response == EX_FORM_FINISHED  )
	    {
	      ignore_msg = COB_S_Ig_FORM_FIN;
	    }
	  /** don't return this if the status_disp form is already up**/
	  else if ( *response == STATUS_DISP  &&
					 p_super_cmd->form_requested )
	    {
	      ignore_msg = COB_S_STATUS_DISP_DISP;
	    }
	  else if ( *response == STATUS_DISP	&&
				     ! p_CEO->status_display_form_ptr  )
	    {
	      ignore_msg = COB_S_NO_STATUS_DISP;
	    }
	  else
	    {
	      do_suspend = _true;
	    }

	  if ( ignore_msg )
	    {
		ex$message ( field  = ERROR_FIELD,
		    msgnumb = ignore_msg, justification = CENTER_JUS );

		_bugprint(bflag=CEO_debug,str="MSG # = %d\n",var=ignore_msg)
	    }
	}

      _bugprint(bflag=CEO_debug, str =
	"Bottom of while (! do_suspend(=%d) &&, *response(=%d) != TERMINATE=%d) loop\n",
	var = `do_suspend, * response, TERMINATE` )
    }
  while ( ! do_suspend && * response != TERMINATE );

quit:
  _bugprint(bflag=TFLAG, str =
	"-CEO.real_execute:  *response=%d, response_data='%s', pos=%d, me->ret=%d\n",
	var = `*response, response_data, position, p_CEO->ret` )

  return OM_S_SUCCESS;
}
end implementation CEO;
