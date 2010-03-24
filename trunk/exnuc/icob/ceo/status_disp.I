/* ceo/status_disp.I -- JAJ:09-08-88 */
class implementation CEO;

#include <stdio.h>
#include <COBmsg.h>	/** need this for COB_S_NO_STATUS_DISP	**/

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
#endif


method status_disp ( )
{
  int	  status;

  _bugprint(bflag=TFLAG, str = "+CEO.status_disp:\n" )

  /*** do status display form ***/
  if ( me->status_display_form_ptr )
    {
      _bugprint(bflag=CEO_debug, str =
		"Calling FIf_display status disp form_ptr = 0x%x )\n",
		var = `me->status_display_form_ptr` )
      status = FIf_display ( me->status_display_form_ptr );
#ifdef DEBUG
      if ( (status != FI_SUCCESS)  &&  (status != FI_QUIET_MODE_ON)  )
	{
	  fprintf ( stderr,
		"CEO.status_disp:  Display of status_display form '%s' failed;\n  error status = %d.\n",
	  me->active_form_name, status );
	  goto quit;
	}
#endif
      me->form_requested = 1;
    }
  else
    {
	    /*** "STATUS_DISPLAY form is not defined for this cmd." ***/
      ex$message( field = ERROR_FIELD,
		msgnumb = COB_S_NO_STATUS_DISP,
		justification = CENTER_JUS );

	    /*** reset this so CEO.delete won't try to delete it ***/
      me->form_requested = 0;
    }


/*quit:*/

  _bugprint(bflag=TFLAG, str =
	"-CEO.status_disp:  status = %d\n", var = `status` )
  return OM_S_SUCCESS;
}
end implementation CEO;
