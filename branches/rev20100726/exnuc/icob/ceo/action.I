/* ceo/action.I */
/*
  perform indicated action
*/
class implementation CEO;

#include <OMmacros.h>		/*** need this for OM_SET_DIMENSION ***/
#include <msmacros.h>		/*** need this for ms$onoff()	    ***/
#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif



method action (
  int	  selector;
  int	  int_or_str_ptr;	/*** JAJ:02-04-88 ***/
  int	* sts )
{
  char			err_stat[255];
  int			status;
  short			erase_form_reset_flag = 0;
			/* 0 = DON'T reset the form when it's erased */
			/* 1 = reset the form when it's erased */
  IGRshort		temp_prev_msg_state;

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct super_cmd_instance	* p_super_cmd = ME.super_cmd;
  struct CEO_instance		* p_CEO = ME.CEO;
  int				  num_states;

  
  _bugprint(bflag=TFLAG, str =
	"+CEO.action:  sel=%d, int_or_str_ptr=[%d], *sts=%d\n",
	var = `selector, int_or_str_ptr, *sts` )
/*
  _bugprint(bflag=TFLAG, str =
	"+CEO.action:  sel=%d, int_or_str_ptr=[%d | '%s'], *sts=%d\n",
	var = `selector, int_or_str_ptr, int_or_str_ptr >=0 ? (char *)int_or_str_ptr : "" , *sts` )
*/

  /* status = OM_S_SUCCESS; */

  switch ( selector )
    {
      case _help:
	_bugprint(bflag=CEO_debug, str =
		"selector = '_help' = %d\n", var = selector)
	_bugprint(bflag=CEO_debug, str =
		"Sending myself CEO.help_topic(0,int_or_str_ptr=|%s|)\n",
		var = `(char *) int_or_str_ptr` )
	_send ( my_id, CEO.help_topic ( 0, (char *) int_or_str_ptr ));
#ifdef DEBUG
	_cob_check ( status, "CEO.action:  CEO.help_topic() failed" );
#endif

	/*** actually update the help window if it is active	***
	/***   EXEC does this now during super_cmd.help_topic() ***
	if ( ex$is_help_active() )	/**** JAJ:08-31-89 ********
	  {
	    status = om$send (  targetid = my_id,
				     msg = message super_cmd.help ( ) );
	  }
        ***********************************************************/

	break;

      case _msg:
	_bugprint(bflag=CEO_debug, str =
		"selector = '_msg' = %d\n", var = `selector`)
	_bugprint(bflag=CEO_debug, str =
		"Sending myself CEO.msg((char *)int_or_str_ptr=|%s|)\n",
		var = `(char *) int_or_str_ptr`)
	_send ( my_id, CEO.msg ( (char *) int_or_str_ptr ));
#ifdef DEBUG
	_cob_check ( status, "CEO.action:  CEO.msg() failed" );
#endif
	break;

      case _msg_key:
	_bugprint(bflag=CEO_debug, str =
		"selector = '_msg_key' = %d\n", var = selector)
	_bugprint(bflag=CEO_debug, str =
		"Doing ex$message(msgnumb = int_or_str_ptr = %d, buff = me->msg = '%s' )\n",
		var = `int_or_str_ptr, p_CEO->msg` )
	ex$message ( msgnumb = int_or_str_ptr,
	    buff = p_CEO->msg );
	_bugprint(bflag=CEO_debug, str =
		"Did ex$message(msgnumb = int_or_str_ptr = %d, buff = me->msg = '%s' )\n",
		var = `int_or_str_ptr, p_CEO->msg` )
	_bugprint(bflag=CEO_debug, str = "Sending myself CEO.msg(NULL)\n" )
	_send ( my_id, CEO.msg ( NULL ));
#ifdef DEBUG
	_cob_check ( status, "CEO.action:  CEO.msg_key( ) failed" );
#endif
	break;

      case _prompt:
	_bugprint(bflag=CEO_debug, str =
		"selector = '_prompt' = %d\n", var = selector)
        _bugprint(bflag=CEO_debug, str =
		"Sending myself CEO.prompt((char *) int_or_str_ptr=|%s|)\n",
		var = `(char *) int_or_str_ptr` )
        _send ( my_id, CEO.prompt ( (char *) int_or_str_ptr ));
#ifdef DEBUG
	_cob_check ( status, "CEO.action:  CEO.prompt( ) failed" );
#endif
        break;

      case _prompt_key:
	_bugprint(bflag=CEO_debug, str =
		"selector = '_prompt_key' = %d\n", var = selector)
        _bugprint(bflag=CEO_debug, str =
		"Doing ex$message(msgnumb = int_or_str_ptr = %d, buff = me->prompt = '%s' )\n",
		var = `int_or_str_ptr, p_CEO->msg` )
        ex$message ( msgnumb = int_or_str_ptr,
			buff = p_CEO->prompt );
        _bugprint(bflag=CEO_debug, str =
		"Did ex$message(msgnumb = int_or_str_ptr = %d, buff = me->prompt = '%s' )\n",
		var = `int_or_str_ptr, p_CEO->msg` )
        break;

      case _do_prompt:
	_bugprint(bflag=CEO_debug, str =
		"selector = '_do_prompt' = %d, me->prompt = '%s'\n",
                var = `selector, p_CEO->prompt` )
        /* UI_prompt ( me->prompt ); 	JAJ:11-17-87 */
	ex$message( field = PROMPT_FIELD, msgnumb = MS_NO_MSG,
		    justification = RIGHT_JUS, in_buff = p_CEO->prompt);
        break;

      case _status:
	_bugprint(bflag=CEO_debug, str =
		"selector = '_status' = %d\n", var = selector)
	_bugprint(bflag=CEO_debug, str =
		"Sending myself CEO.status((char *) int_or_str_ptr=|%s|)\n",
		var = `(char *) int_or_str_ptr` )
	_send ( my_id, CEO.status ( (char *) int_or_str_ptr ));
#ifdef DEBUG
	_cob_check ( status, "CEO.action:  CEO.status() failed" );
#endif
	break;

      case _status_key:
	_bugprint(bflag=CEO_debug, str =
		"selector = '_status_key' = %d\n", var = selector)
	_bugprint(bflag=CEO_debug, str =
		"Doing ex$message(msgnumb = int_or_str_ptr = %d, buff = me->status = '%s' )\n",
		var = `int_or_str_ptr, p_CEO->status` )
	ex$message ( msgnumb = int_or_str_ptr,
	    buff = p_CEO->status );
	_bugprint(bflag=CEO_debug, str =
		"Did ex$message(msgnumb = int_or_str_ptr = %d, buff = me->status = '%s' )\n",
		var = `int_or_str_ptr, p_CEO->status` )
	_bugprint(bflag=CEO_debug, str =
		"Sending myself CEO.status(NULL)\n" )
	_send ( my_id, CEO.status ( NULL ));
#ifdef DEBUG
	_cob_check ( status, "CEO.action:  CEO.status_key() failed" );
#endif
	break;

      case _error_box:	/*** JAJ:08-08-88 ***/
	_bugprint(bflag=CEO_debug, str =
		"selector = '_error_box' = %d\n", var = selector)
	_bugprint(bflag=CEO_debug, str =
		"Sending myself CEO.error_box((char *) int_or_str_ptr=|%s|)\n",
		var = `(char *) int_or_str_ptr` )
	_send ( my_id, CEO.error_box ( (char *) int_or_str_ptr ));
#ifdef DEBUG
	_cob_check ( status, "CEO.action:  CEO.error_box() failed" );
#endif
	break;

      case _error_box_key:	/*** JAJ:08-08-88 ***/
	_bugprint(bflag=CEO_debug, str =
		"selector = 'error_box_key' = %d\n", var = selector)
	_bugprint(bflag=CEO_debug, str =
		"Doing ex$message(msgnumb = int_or_str_ptr = %d, buff = me->error_box = '%s' )\n",
		var = `int_or_str_ptr, me->error_box` )

	ex$message ( msgnumb = int_or_str_ptr,
			buff = err_stat );

	status = om$vla_set_dimension
		( varray = ME.CEO->error_box,
		    size = strlen ( err_stat ) + 1 );
	_cob_check ( status, \
		 "CEO.action:  om$vla_set_dimension 1 failed" );

	strcpy ( me->error_box, err_stat );

	_bugprint(bflag=CEO_debug, str =
		"Did ex$message(msgnumb = int_or_str_ptr = %d, buff = me->error_box = '%s' )\n",
		var = `int_or_str_ptr, me->error_box` )
	_bugprint(bflag=CEO_debug, str =
		"Sending myself CEO.error_box(NULL)\n" )
	_send ( my_id, CEO.error_box ( NULL ));
#ifdef DEBUG
	_cob_check ( status, "CEO.action:  CEO.error_box_key() failed" );
#endif
	break;

      case _ms_on_off:		/*** JAJ:08-08-88 ***/
	_bugprint(bflag=CEO_debug, str =
		"selector = '_ms_on_off' = %d\n", var = selector )
	if ( int_or_str_ptr == COB_MS_PREV_STATE )
	  {
	    temp_prev_msg_state = p_CEO->prev_msg_state;

	    status = ms$onoff ( msg = (IGRlong *)sts,
			    prevstate = & me->prev_msg_state,
			    setstate = MS_SET,
			    type = temp_prev_msg_state );
#ifdef DEBUG
	    if ( ! ( 1 & status & *sts ) )
	      {
		fprintf ( stderr,
		    "\nCEO.action:  ms$onoff( setstate = MS_SET, type = %d ) failed\n\n",
		    temp_prev_msg_state );
	      }
#endif
	  }
	else
	  {
	    status = ms$onoff ( msg = (IGRlong *)sts,
			    prevstate = & me->prev_msg_state,
			    setstate = MS_SET,
			    type = int_or_str_ptr );
#ifdef DEBUG
	    if ( ! ( 1 & status & *sts ) )
	      {
		fprintf ( stderr,
		    "\nCEO.action:  ms$onoff( setstate = MS_SET, type = %d ) failed\n\n",
		    int_or_str_ptr );
	      }
#endif
	  }
	_bugprint(bflag=CEO_debug, str =
	    "NEW  me->prev_msg_state = %d\n", var = p_CEO->prev_msg_state )
	break;

      case _dynamics:
	/** this is repeated in CEO_LOCATE.action **/
	/**   except CEO_LOCATE does a vsd_and_queue_empty check **/
	_bugprint(bflag=CEO_debug, str =
		"selector = '_dynamics' = %d\n", var = selector)

	/*****	if ( vsd_and_queue_empty ) {   *****/
	_bugprint(bflag=CEO_debug, str =
	  "Sending myself CEO.dynamics( dynamics = int_or_str_ptr = %d )\n",
	  var = int_or_str_ptr )
	ex$message( field = PROMPT_FIELD, msgnumb = MS_NO_MSG,
		    justification = RIGHT_JUS, in_buff = p_CEO->prompt);
	_send ( my_id, CEO.dynamics ( int_or_str_ptr, sts ));
#ifdef DEBUG
	_cob_check2(status,*sts, "CEO.action:  CEO.dynamics() failed" );
#endif
	/*****  }  ******/
	break;

      case _filter:
	_bugprint(bflag=CEO_debug, str =
		"selector = '_filter' = %d; int_or_str_ptr =%d\n",
		var = `selector, int_or_str_ptr` )

	_bugprint(bflag=CEO_debug, str =
	  "Sending myself CEO.filter(filter=int_or_str_ptr=%d, me->response = %d, me->response_data = '%s')\n",
	  var = `int_or_str_ptr, p_CEO->response, p_CEO->response_data`)
	_send ( my_id, CEO.filter ( int_or_str_ptr, p_CEO->response,
		p_CEO->response_data ));

	_bugprint(bflag=CEO_debug, str =
	  "Sent CEO.filter(*me->response=%d, me->response_data='%s')\n",
	   var = `*p_CEO->response, p_CEO->response_data` )
#ifdef DEBUG
	_cob_check ( status, "CEO.action:  CEO.filter() failed" );
#endif

	break;

      case _execute:
	_bugprint(bflag=CEO_debug, str =
		"selector = '_execute' = %d\n", var = selector)

	_bugprint(bflag=CEO_debug, str =
		"Sending myself CEO.action(int_or_str_ptr = %d,NULL,*sts)\n",
		var = int_or_str_ptr )
	_send ( my_id, CEO.action ( int_or_str_ptr, NULL, sts ));
	_bugprint(bflag=CEO_debug, str =
		"Sent CEO.action(int_or_str_ptr = %d,NULL, *sts = %d)\n",
		var = `int_or_str_ptr, *sts` )
#ifdef DEBUG
	_cob_check ( status, "CEO.action:  CEO.action() failed" );
#endif
	break;

      case _set_next_state:
	_bugprint(bflag=CEO_debug, str =
		"selector = '_set_next_state' = %d\n", var = selector)
	p_CEO->next_state = int_or_str_ptr;
	_bugprint(bflag=CEO_debug, str =
		"me->next_state = int_or_str_ptr = %d\n", var = p_CEO->next_state )
	break;

      case _go_next_state:
	_bugprint(bflag=CEO_debug, str =
		"selector = '_go_next_state' = %d\n", var = selector)
	_bugprint(bflag=CEO_debug, str =
		"me->next_state = %d\n", var = p_CEO->next_state )

/*******
#ifdef DEBUG
	{
	  int index, jj;

	  jj = om$dimension_of ( varray = me->prev_state );

	  _bugprint(bflag=CEO_debug, str =
		"me->prev_state size=%d, me->prev_counter=%d\n",
		var = `jj, p_CEO->prev_counter`)

	  for ( index = 0 ; index < jj ; index ++ )
	    {
	      _bugprint(bflag=CEO_debug, str =
		"me->prev_state[%d] = %d\n",
		var = `index, me->prev_state[index]` )
	    }
	}
#endif
********/

	if ( p_CEO->next_state == _terminate )
	  {
	    * p_CEO->response = TERMINATE;
	    *sts = 1;	/** do_suspend **/
	  }
	else if ( p_CEO->next_state == _suspend )
	  {
	    *sts = 1;	/** do_suspend **/
	    break;	/** don't change me->state **/
	  }
	else
	  {
	    *sts = 0;	/** DON'T do_suspend **/

	    /*** if current state == next state, don't do anything ***/
						/*** JAJ:02-15-88 ***/
	    if ( p_super_cmd->state == p_CEO->next_state )
	      {
		break;
	      }

	    num_states = om$dimension_of
				( varray = ME.CEO->prev_state );

	    if ( p_CEO->next_state == _previous_state )
	      {
		/**************************************************/
		/*** Go to "state -"				***/
		/*** so, index into ME.CEO->prev_state[] and	***/
		/*** find the previous state.			***/
		/********************************  JAJ:8/2/91  ****/

			/*******************************************/
			/*** sanity check for array index limits ***/
			/*** ( should never happen )		 ***/
			/*******************************************/

		if ( ( p_super_cmd->state < 0 )			||
		     ( p_super_cmd->state >= num_states )	 )
		  {
		    p_super_cmd->state = 0;
		  }

		p_CEO->next_state =
			ME.CEO->prev_state [ p_super_cmd->state ];
	      }
	    else
	      {
		/**************************************************/
		/*** store this state as the next state's	***/
		/*** previous state.				***/
		/**************************************************/

			/*******************************************/
			/*** sanity check for array index limits ***/
			/*** (should always work)		 ***/
			/*******************************************/

		if ( ( p_CEO->next_state >= 0	      )		&&
		     ( p_CEO->next_state < num_states )		 )
		  {
		    ME.CEO->prev_state [ p_CEO->next_state ] =
						p_super_cmd->state;
		  }
	      }
	  }

	p_super_cmd->state = p_CEO->next_state;
	_bugprint(bflag=CEO_debug, str =
		"me->state = %d\n", var = p_super_cmd->state )
	break;


      case _display_form:
	_bugprint(bflag=CEO_debug, str =
		"selector = '_display_form' = %d\n", var = selector)

	_bugprint(bflag=CEO_debug, str =
	      "Calling CEO.display_form_by_label ( %d )\n",
	      var = `int_or_str_ptr` )

	status = om$send ( targetid = my_id,
			msg = message CEO.display_form_by_label
				  ( int_or_str_ptr, sts ) );
#ifdef DEBUG
	    _cob_check2(status,*sts, "CEO.action:  CEO.display_form_by_label() failed" );
#endif
	break;

      case _erase_form_reset:	/*** JAJ:09-28-87 ***/
	erase_form_reset_flag = 1;
	_bugprint(bflag=CEO_debug, str =
		"selector = '_erase_form_reset' = %d\n", var = selector)

      case _erase_form:
	_bugprint(bflag=CEO_debug, str =
		"selector = '_erase_form' = %d\n", var = selector )

	_bugprint(bflag=CEO_debug, str =
	      "Calling CEO.erase_form_by_label ( label = %d, reset_flag = %d )\n",
	      var = `int_or_str_ptr, erase_form_reset_flag` )

	status = om$send ( targetid = my_id,
			msg = message CEO.erase_form_by_label
				  ( int_or_str_ptr,
				    erase_form_reset_flag, sts ) );
#ifdef DEBUG
	_cob_check2(status,*sts, "CEO.action:  CEO.erase_form_by_label() failed" );
#endif
	break;

	/*** this next case occurs also in CEO_LOCATE.action, but   ***/
	/***   with the reference to me->event_mask1 not commented  ***/
      case _filter_mode:	/*** JAJ:08-25-87 ***/
	_bugprint(bflag=CEO_debug, str =
		"selector = _filter_mode = %d\n", var = selector )
	p_CEO->filter_mode = int_or_str_ptr;

	/***** if ( me->filter_mode = EX_ALL_CHAR_MODE )  ***********
		    me->event_mask1 |= GRm_CHAR;
	*************************************************************/

	_bugprint(bflag=CEO_debug, str =
	    "me->filter_mode = int_or_str_ptr = %d\n", var = p_CEO->filter_mode )
	break;

      case _const_class:  /*** moved from CEO_CONST --JAJ: 08-30-87 ***/
	_bugprint(bflag=CEO_debug, str =
	    "selector = _const_class = %d\n", var = selector )
	strcpy ( p_CEO->const_class, (char *) int_or_str_ptr );
	_bugprint(bflag=CEO_debug, str =
	    "Setting me->const_class = '%s'\n", var = p_CEO->const_class )
	break;

      case _event_mask:
	_bugprint(bflag = CEO_debug, str =
	  "selector = _event_mask = %d\n", var = selector )
	/*** doesn't do anything, but needs to be here so that this ***/
	/***   case is covered;			-- JAJ:08-31-88	    ***/
	break;

      case _convert_resp_to_mask:
	_bugprint(bflag=read_debug, str =
	  "selector = _convert_resp_to_mask = %d\n", var = selector )
	/*** doesn't do anything, but needs to be here so that this ***/
	/***   case is covered;  in CEO_LOCATE.action, this converts  */
	/***   the transition's response type into a filter mask      */
	/***   setting;  this was transferred from trans.set during   */
	/***   the COB IGE/COB DRAFT split	-- JAJ:10-21-87	      */

	* sts = 0;	/*** set the mask to 0, to avoid garbage  ***/

	break;

      default:
	_bugprint(bflag=CEO_debug, str =
		"INVALID selector = %d\n", var = selector)
	break;
    }
quit:
  _bugprint(bflag=TFLAG, str =
	"-CEO.action:  outgoing int_or_str_ptr = %d, * sts = %d\n",
	var = `int_or_str_ptr, *sts` )
  return OM_S_SUCCESS;
}
end implementation CEO;
