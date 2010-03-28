class implementation COedtly;



#include "OMminimum.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "lydef.h"
#include "grmessage.h"
#include <string.h>
#include <ctype.h>

%safe
#include "GRdpbfunc.h"
%endsafe



method form_init ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  int          msg;
  IGRint       fm_ind;
  IGRchar      *form_ptr;
  IGRdouble    act_layer;

  *sts = OM_S_SUCCESS;
  status = OM_S_SUCCESS;

  /*
   * Get the form pointer.
   */

  status = om$send(msg = message CEO.get_form_ptr(GRLAYERS_FORM, &form_ptr,
                         &fm_ind, &msg),
                   senderid = my_id,
                   targetid = my_id);
  if ( !(1&status) )
  {
    om$report_error(sts = status);
    *sts = status;
    goto quit;
  }

  /*
   * Set the active layer field.
   */

  gr$get_active_layer(buffer = (char *)&me->active_layer);

  act_layer = (IGRdouble) me->active_layer;
  FIfld_set_value(form_ptr, ACT_LAYER, 0, 0, act_layer, FALSE);

  /*
   * Call the parent's form_init.
   */

  status = om$send(mode = OM_e_wrt_message,
                   msg = message COlayer.form_init( (IGRlong *)sts),
                   targetid = my_id);
  if ( !(1&status) )
  {
    om$report_error(sts = status);
  }

quit:
  return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  int		  status = OM_S_SUCCESS;

  int   msg;

  switch(gadget_label)
  {
    case EXIT_SAVE:
      /*
       * Erase the form before updating the dpb so that the adp form will be
       * updated.   dhm  10/24/91
       */

      status = om$send(msg = message CEO.erase_form_by_label(form_label, 1,
                                                             &msg),
                       senderid = my_id,
                       targetid = my_id);
      if (! (1&status) )
      {
        om$report_error(sts = status);
        goto quit;
      }

      gr$put_active_layer(buffer = (char *)&me->active_layer);

      /* no break */

    default:
      status = om$send(mode = OM_e_wrt_message,
                       msg = message COlayer.form_notification(form_label,
                             gadget_label, value, form_ptr),
                       targetid = my_id);
      if ( !(1&status) )
      {
        om$report_error(sts = status);
      }

      break;

  }  /* end switch label */


quit:
  return OM_S_SUCCESS;
}

end implementation COedtly;
