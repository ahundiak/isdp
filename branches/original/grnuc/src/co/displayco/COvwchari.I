class implementation COvwchar;



#include 	"exdef.h"
#include	"exmacros.h"
#include	"dpdef.h"
#include 	"dp.h"
#include	"dpmacros.h"
#include	"lydef.h"
#include 	"viewdef.h"
#include	"msdef.h"
#include 	"grmessage.h"

%safe
static IGRint MVP_FORM_IS_DISPLAYED = TRUE;
static IGRint LAYER_FORM_IS_DISPLAYED = TRUE;
%endsafe




method sleep ( int pos )
{
  int		  status = OM_S_SUCCESS;

  IGRchar *ly_form_ptr;
  IGRchar *form_ptr;
  IGRint fm_ind, display_status;
  IGRint msg; 

           status = om$send(msg = message CEO.get_form_ptr(VIEW_FORM,
                                   &form_ptr, &fm_ind, &msg),
                             senderid = my_id,
                             targetid = my_id);
            if ( !(1&status) )
            {
                om$report_error(sts = status);
                goto quit;
            }

           status = om$send(msg = message CEO.get_form_ptr(GRLAYERS_FORM,
                                   &ly_form_ptr, &fm_ind, &msg),
                             senderid = my_id,
                             targetid = my_id);
            if ( !(1&status) )
            {
                om$report_error(sts = status);
                goto quit;
            }

    FIf_is_displayed(ly_form_ptr,&display_status);
     if(display_status)
       {
        FIf_erase(ly_form_ptr);
        LAYER_FORM_IS_DISPLAYED = FALSE ;
       }

    FIf_is_displayed(form_ptr,&display_status);
     if(display_status)
       {
        FIf_erase(form_ptr);
        MVP_FORM_IS_DISPLAYED = FALSE ;
       }


quit:
  return OM_S_SUCCESS;
}

method wakeup ( int pos )
{
  int		  status = OM_S_SUCCESS;

  IGRchar *ly_form_ptr;
  IGRchar *form_ptr;
  IGRint fm_ind;
  IGRint msg;

           status = om$send(msg = message CEO.get_form_ptr(VIEW_FORM,
                                   &form_ptr, &fm_ind, &msg),
                             senderid = my_id,
                             targetid = my_id);
            if ( !(1&status) )
            {
                om$report_error(sts = status);
                goto quit;
            }

           status = om$send(msg = message CEO.get_form_ptr(GRLAYERS_FORM,
                                   &ly_form_ptr, &fm_ind, &msg),
                             senderid = my_id,
                             targetid = my_id);
            if ( !(1&status) )
            {
                om$report_error(sts = status);
                goto quit;
            }

  if(!MVP_FORM_IS_DISPLAYED)
    {
       FIf_display( form_ptr );
       MVP_FORM_IS_DISPLAYED = TRUE;
    }

  if(!LAYER_FORM_IS_DISPLAYED)
    {
       FIf_display( ly_form_ptr );
       LAYER_FORM_IS_DISPLAYED = TRUE;
    }

quit:
  return OM_S_SUCCESS;
}

end implementation COvwchar;
