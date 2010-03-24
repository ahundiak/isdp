/* ceo/display_form.I */
class implementation CEO;

#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif

from FIform import display_form;


method display_form (
  OM_S_OBJID	form_objid;	/* redundant argument */
  int		origin_x;
  int		origin_y;
  int	      * sts )
{
  int		status;
  int		index;


  _bugprint(bflag=TFLAG, str =
	"+CEO.display_form:  form_objid=%d, x=%d, y=%d,  *sts=%d\n",
	var = `form_objid, origin_x, origin_y, *sts` )

  * sts = OM_S_SUCCESS;

  for ( index = 0; index < me->number_of_forms; index++ )
    {
       if ( me->forms[index].oid  == form_objid )
	 {
	    me->forms[index].displayed = 1;
	    break;
	 }
    }

  if ( form_objid )
    {
      _bugprint(bflag=CEO_debug, str =
	"Sending form_objid = %d FIform.display_form()\n",
	var = form_objid)
      _send ( form_objid,
	      FIform.display_form ( (long *) sts, origin_x, origin_y ));
      if ( ! ( status & *sts & 1 ) )
        {
          strcpy ( me->status,
		"CEO.display_form:  Error in FIform.display_form");
          fprintf(stderr, "\n%s for form '%s'.\n\n", me->status,
		 				me->forms[index].name );
          _send ( my_id, CEO.status ( NULL ));
          om$report_error ( sts = sts );
        }
    }

quit:
  _bugprint(bflag=TFLAG, str =
	"-CEO.display_form:  status = %d,  outgoing *sts = %d\n",
	 var = `status, *sts` )
  return OM_S_SUCCESS;
}

end implementation CEO;
