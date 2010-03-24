/* ceo/init_form.I */
class implementation CEO;

#include <stdio.h>
#include <fierr.h>	/*** need this for FI_E_FAILURE ***/

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif

from FIform import init_form;

method init_form (
  OM_S_OBJID	  form_objid;
  int		  form_label;
  int		  form_x;
  int		  form_y;
  char		* form_name;
  int		* sts )
{
  int	  status;
				
  _bugprint(bflag=TFLAG, str =
	"+CEO.init_form:  form_objid=%d, label=%d, x=%d, y=%d, name='%s', *sts=%d\n",
	var = `form_objid, form_label, form_x, form_y, form_name, *sts`)
  _bugprint(bflag=TFLAG, str = "sender_id = %d\n", var = sender_id )

  * sts = OM_S_SUCCESS;

  _bugprint(bflag=CEO_debug, str =
	  "Sending form_objid  FIform.init_form(sender_id=%d,'%s')\n",
	   var = `sender_id, form_name` )
  _send ( form_objid, FIform.init_form ( (long *) sts, form_label,
	  sender_id, OM_Gw_current_OS, & NULL_OBJID, 0, form_name ));
  if ( ! ( status & *sts & 1 ) )
    {
      strcpy ( me->status, "CEO.init_form:  Error in FIform.init_form");
      fprintf(stderr, "\n%s for form '%s'.\n\n", me->status, form_name);
      _send ( my_id, CEO.status ( NULL ));
      om$report_error ( sts = sts );
    }

quit:
  _bugprint(bflag=TFLAG, str =
	"-CEO.init_form:  status = %d,  outgoing *sts = %d\n",
	 var = `status, *sts` )
  return OM_S_SUCCESS;
}
end implementation CEO;
