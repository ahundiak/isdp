 /* ceo/sleep.I */
class implementation CEO;

#include <stdio.h>
#ifdef ENV5
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
#include <FI.h>
#endif



method sleep ( int position )
{
  int	   ii, status;

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct super_cmd_instance	* p_super_cmd = ME.super_cmd;
  struct CEO_instance		* p_CEO = ME.CEO;


  _bugprint(bflag=TFLAG, str = "+CEO.sleep:  position = %d\n",
	var = position )

						/*** JAJ:09-11-89 ***/
  if ( ( p_super_cmd->form_requested ) && ( position == EX_suspend ) )
    {
      if ( p_CEO->status_display_form_ptr )
	{
	  _bugprint(bflag=CEO_debug, str =
		"Calling FIf_erase status_display form_ptr = 0x%x )\n",
		var = `p_CEO->status_display_form_ptr` )
	  status = FIf_erase ( p_CEO->status_display_form_ptr );
#ifdef DEBUG
	  if ( status != FI_SUCCESS )
	    {
	      fprintf ( stderr,
		    "CEO.sleep:  Erase of status_display form '%s' failed;\n  error status = %d.\n",
		    p_super_cmd->active_form_name, status );
	    }
#endif
	}
    }

if ( position == EX_suspend )	/*** JAJ:09_11_89 ***/
 {
  for ( ii=0; ii < p_CEO->number_of_forms; ii++ )
    {
      if ( me->forms[ii].displayed  &&
		me->forms[ii].display_type != _persistent_form )
	{
		/****  DON'T DO THIS NO MO'
		me->forms[ii].displayed = 0;
		******************************/

	  _bugprint(bflag=CEO_debug, str =
		"Calling FIf_erase (me->forms[%d].form_ptr = 0x%x )\n",
		var = `ii, me->forms[ii].form_ptr` )

	  status = FIf_erase ( me->forms[ii].form_ptr );
#ifdef DEBUG
	  if ( status != FI_SUCCESS )
	    {
	      fprintf ( stderr,
		"CEO.sleep:  Erase of form '%s' failed;  error status = %d.\n",
		me->forms[ii].name, status );
	      continue;
	    }
#endif
	}
    }  /*** for loop to erase forms ***/
  }

	/*** "at sleep do" stuff ***/
  _bugprint(bflag=CEO_debug, str =
	"************  Doing AT SLEEP's  ************\n" )

  p_CEO->ret = OM_S_SUCCESS;	/*** this must be done before ***/
				/*** calling COBactions/trans _do_it **/

  _COB_for_list ( act_ptr, list, p_CEO->at_sleep, struct COBact_trans )
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
	"************  Did AT SLEEP's  ************\n" )

quit:
  _bugprint(bflag=TFLAG, str = "-CEO.sleep:  position = %d\n",
	var = position )
  return OM_S_SUCCESS;	/*** don't return "status" -- JAJ:04-06-88 ***/
}  /*** end of CEO.sleep () ***/

end implementation CEO;
