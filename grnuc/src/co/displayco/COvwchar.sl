/* #######################    APOGEE COMPILED   ######################## */
/* Command definition section */
options	        "t"
product_name    "$GRNUC"
class           COvwchar
super_class     COedtly
super_class     COwindow
start_state     terminate

/* Specification section .. code for .S file */

specification

#include "gr.h"
#include "OMminimum.h"
#include "OMlimits.h"
#include "DIdef.h"
#include "dpdef.h"


instance 
{
  IGRchar name[DI_PATH_MAX];
  IGRint flags;
  IGRlong num_grid_x;
  IGRlong num_grid_y;
  IGRdouble dis_grid[2];
  IGRdouble vw_vol[6];
  IGRdouble wld_to_view[4][4];
  IGRdouble wld_act_z;
  IGRdouble wld_dis_dep[2];
  IGRdouble const_org[3];
  IGRint win_response;
  IGRint win_nbytes;
  char *win_resp_data;
  IGRint toggle_proj;

}


implementation

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


action form_notification extern
action gather_gg_data() extern
action proc_chgs() extern

action sleep
{
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


}
action wakeup
{
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

}
