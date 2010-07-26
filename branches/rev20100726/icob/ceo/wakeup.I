/* ceo/wakeup.I */
class implementation CEO;

#include <stdio.h>
#include <COBmsg.h>	/** need this for COB_S_NO_STATUS_DISP	**/
#ifdef ENV5
#include <FI.h>
%safe
#include <FIproto_pub.h>
%endsafe
#elif defined(X11)
%safe
#include <XFIproto_pub.h>
%endsafe
#endif

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif

#ifdef NT
#include <shampub.h>
#endif

method wakeup ( int position )
{
  int	  status;
  int	  ii;

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct super_cmd_instance	* p_super_cmd = ME.super_cmd;
  struct CEO_instance		* p_CEO = ME.CEO;

  _bugprint(bflag=TFLAG, str = "+CEO.wakeup:  position = %d\n",
	var = position )

  _bugprint(bflag=CEO_debug, str = "Sending myself CEO.msg(NULL)\n" )
  _send ( my_id, CEO.msg ( NULL ));
#ifdef DEBUG
  _cob_check ( status, "CEO.wakeup:  CEO.msg failed." );
#endif


  if ( p_super_cmd->state == _terminate )
    {
	goto quit;
    }

  /*** re-display status display form, if it's supposed to be up ***/
						/*** JAJ:09-11-89 ***/
  if ( ( p_super_cmd->form_requested ) && ( position == EX_suspend ) )
    {
      if ( p_CEO->status_display_form_ptr )
	{
	  _bugprint(bflag=CEO_debug, str =
		"Calling FIf_display status disp form_ptr = 0x%x )\n",
		var = `p_CEO->status_display_form_ptr` )

	  status = FIf_display ( p_CEO->status_display_form_ptr );
	  if (	( status != FI_SUCCESS )		&&
		( status != FI_QUIET_MODE_ON )		 )
	    {
	      fprintf ( stderr,
		"CEO.wakeup:  Display of status_display form '%s' failed;\n  error status = %d.\n",
		p_super_cmd->active_form_name, status );
	    }
	}
     else	/*** Status_disp objid is NULL_OBJID - JAJ:02-10-88 ***/
	{
	    /*** "STATUS_DISPLAY form is not defined for this cmd." ***/
	        ex$message( field = ERROR_FIELD,
			msgnumb = COB_S_NO_STATUS_DISP,
			justification = CENTER_JUS );

	    /*** reset this so CEO.delete won't try to delete it ***/
	        p_super_cmd->form_requested = 0;
	}
    }


	/*** "at wakeup do" stuff ***/
  _bugprint(bflag=CEO_debug, str =
	"************  Doing AT WAKEUP's  ************\n" )

  p_CEO->ret = OM_S_SUCCESS;	/*** this must be done before ***/
				/*** calling COBactions/trans _do_it **/

  _COB_for_list ( act_ptr, list, p_CEO->at_wakeup, struct COBact_trans)
    _bugprint(bflag=CEO_debug, str =
	  "Calling COBactions_do_it ( action_ptr=(0x)%x,...)\n",
	    var = `& act_ptr->at.action` )
    status = COBactions_do_it ( & act_ptr->at.action, my_id, &p_CEO->ret );

    _bugprint(bflag=CEO_debug, str =
       "Called COBactions_do_it():  status = %d, ME.CEO->ret = %d\n",
	    var = `status, p_CEO->ret` )

    if ( status == OM_I_STOP_SENDING || !( 1 & status ) )
      {
	break;
      }

    if ( p_CEO->ret == COB_E_ARG_NOT_FOUND )	/*** JAJ:02-01-88 ***/
      {
	p_super_cmd->state = _terminate;
	goto quit;
      }

  _COB_end_for_list
  _bugprint(bflag=CEO_debug, str =
	"************  Did AT WAKEUP's  ************\n" )



if ( position == EX_suspend )	/*** JAJ:09_11_89 ***/
 {
  for ( ii = 0 ; ii < p_CEO->number_of_forms ; ii++ )
    {
      if ( (me->forms[ii].display_type == _manual_display_form &&
		me->forms[ii].displayed == 1 ) 		||
	       (me->forms[ii].display_type == _auto_display_form )  ||
	       (me->forms[ii].display_type == _persistent_form  &&
		me->forms[ii].displayed == 0 )
	  )
	{
	  _bugprint(bflag=CEO_debug, str =
	      "Calling FIf_display (me->forms[%d].form_ptr = 0x%x )\n",
	      var = `ii, me->forms[ii].form_ptr` )

	  status = FIf_display ( me->forms[ii].form_ptr );
	  if (	( status != FI_SUCCESS )		&&
		( status != FI_QUIET_MODE_ON )		 )
	    {
	      fprintf ( stderr,
		  "CEO.wakeup:  Display of form '%s' failed;  error status = %d.\n",
		  me->forms[ii].name, status );
	      continue;
	    }

		      /*** remember that the form is displayed ***/
	  me->forms[ii].displayed = 1;
	}
    }  /*** for loop to display forms ***/
 }

quit:

  _bugprint(bflag=TFLAG, str =
	"-CEO.wakeup:  position = %d;  status = %d\n",
	var = `position, status` )
  return OM_S_SUCCESS;	/*** don't return "status" -- JAJ:04-06-88 ***/
}
end implementation CEO;
