class implementation COlocly;



#include "OMminimum.h"
#include "dp.h"
#include "dpdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "lydef.h"
#include "grmessage.h"
#include <string.h>
#include <ctype.h>

%safe
#include "GRsetinq.h"
%endsafe




method form_init ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  IGRlong      msg;
  IGRint       msg1;
  IGRint       fm_ind;
  IGRchar      *form_ptr;
  struct var_list list[2];

  *sts = OM_S_SUCCESS;
  status = OM_S_SUCCESS;

  /*
   * Get the form pointer.
   */

  status = om$send(msg = message CEO.get_form_ptr(GRLAYERS_FORM, &form_ptr,
                         &fm_ind, &msg1),
                   senderid = my_id,
                   targetid = my_id);
  if ( !(1&status) )
  {
    om$report_error(sts = status);
    *sts = status;
    goto quit;
  }

  /*
   * Get the locate layers.
   */

  list[0].var = DPB_GET_LAYER;
  list[0].var_ptr = (char*)me->elig_mask;
  list[1].var = END_PARAM;

  gr$set_inq(msg = &msg, 
             var_list = list);

/******************  Doesn't work yet ***************************
  gr$get_locate_levels(msg = &msg,
                      buffer = me->elig_mask);

*****************************************************************/

  /*
   * Not using the active layer field.
   */

  FIg_erase(form_ptr, ACT_LAYER);
  FIg_erase(form_ptr, ACT_LAYER_TEXT);

  /*
   * Set the text for our locate eligibility field.
   */

  FIg_display(form_ptr, ELIG_TEXT);
  FIg_display(form_ptr, ELIG_TEXT_ROLL);

  /*
   * Call the parent's form_init.
   */

  me->eligibility_enabled = TRUE;
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

  IGRlong   msg;
  struct var_list  list[2];

  switch(gadget_label)
  {
    case EXIT_SAVE:
      list[0].var = DPB_SET_LAYER;
      list[0].var_ptr = (char*)me->elig_mask;
      list[1].var = END_PARAM;

      gr$set_inq(msg = &msg,
                 set_inq = DPB_SET,
                 var_list = list);

/************************ Doesn't work yet **************************

      gr$put_locate_levels(msg = &msg,
                          buffer = &me->elig_mask);
*********************************************************************/

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

end implementation COlocly;
