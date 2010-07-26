/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     FUNCTION NAME:             GRdisp_set_adp
 
     Abstract:

       This routine displays the Set Active Drawing Parameters form.
If the form does not already exist, it is created and initialized and
its name is added to the transient object space's named object directory.
-----
%SC%

     VALUE = GRdisp_set_adp()
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                    DESCRIPTION
     ----------   ------------        ----------------------------------------

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%MD%

     MODULES AND METHODS INVOKED:

     modules:
     methods:

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        WBC  08/14/89 : Design date.
        WBC  08/14/89 : Creation date.
        WBC  01/23/90 : Changed function so it returns FALSE if the form has
                        already been displayed.
        dhm  07/13/92 : ANSI conversion.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
       This routine displays the Set Active Drawing Parameters form.
If the form does not already exist, it is created and initialized
and its name is added to the transient object space's named object
directory.
----*/
/*EH*/

#include "coimport.h"
#include "tools.h"
#include "FI.h"
#include "igrtypedef.h"
#include "ex.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "adpdef.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "msmacros.h"
#include "grmessage.h"

IGRint GRdisp_set_adp()

{
    IGRlong                msg;               /* msg returned from methods   */
    IGRlong                buffersize;
    IGRlong                nobytes;
    IGRlong                form_mask;
    IGRint                 form_displayed;    /* drawing parameters form     */
                                              /* displayed?                  */
    IGRint                 status;
    IGRint                 error_index;
    IGRdouble              active_angle;
    IGRshort               active_layer;
    Form                   form_ptr;
    struct  EX_var_list    var_list[MAX_ADP_VAR_LIST];
    struct IGRdisplay      active_display;
    struct GRdpb_scale     active_scale;

    /*  EV - end of local variables   */

    /*
     * Create the Set Active Drawing Parameters form if it has not already
     * been constructed.  If the form has been created but is not displayed,
     * update the form with the current DPB values and display the form.
     * Otherwise, display a message to inform the user the form is currently
     * being displayed.
     */

    status = TRUE;

    if (GRcreate_setadp(&msg,TRUE,&form_ptr))
    {
        /*
         *  Is the set active drawing parameters form already displayed?
         */

        FIf_is_displayed(form_ptr,&form_displayed);

        if (form_displayed)
        {
            ex$message(msgnumb = GR_E_DrwParFmExst);
            status = FALSE;
        }
        else
        {
            /*
             * update the form with the current DPB values and display the form
             */

            buffersize = sizeof(active_layer);
            gr$get_active_level(msg = &msg,
                                sizbuf = &buffersize,
                                buffer = &active_layer,
                                nret = &nobytes);

            buffersize = sizeof(active_display);
            gr$get_active_display(msg = &msg,
                                  sizbuf = &buffersize,
                                  buffer = &active_display,
                                  nret = &nobytes);

            buffersize = sizeof(active_angle);
            gr$get_active_angle(msg = &msg,
                                sizbuf = &buffersize,
                                buffer = &active_angle,
                                nret = &nobytes);

            buffersize = sizeof(active_scale);
            gr$get_active_scale(msg = &msg,
                                sizbuf = &buffersize,
                                buffer = &active_scale,
                                nret = &nobytes);

            var_list[0].var = ADP_LAYER_NUM;
            var_list[0].var_value = (IGRchar *) &active_layer;
            var_list[1].var = ADP_LAYER_NAME;
            var_list[1].var_value = (IGRchar *) &active_layer;
            var_list[2].var = ADP_COLOR_NUM;
            var_list[2].var_value = (IGRchar *) &active_display.color;
            var_list[3].var = ADP_COLOR_NAME;
            var_list[3].var_value = (IGRchar *) &active_display.color;
            var_list[4].var = ADP_WEIGHT_NUM;
            var_list[4].var_value = (IGRchar *) &active_display.weight;
            var_list[5].var = ADP_STYLE_NUM;
            var_list[5].var_value = (IGRchar *) &active_display.style;
            var_list[6].var = ADP_ANGLE_NUM;
            var_list[6].var_value = (IGRchar *) &active_angle;
            var_list[7].var = ADP_SCALE_NUM;
            var_list[7].var_value = (IGRchar *) &active_scale;
            var_list[8].var = ADP_END_LIST;

            GRupdate_setadp(&msg,form_ptr,var_list,&error_index);

            /*
             * if the form has been converted to a permanent
             * form, convert it back to a save/restore form
             */

            FIf_get_attr(form_ptr,&form_mask);

            if (! (form_mask & FI_SAVE_RESTORE))
            {
                form_mask |= FI_SAVE_RESTORE;
                FIf_set_attr(form_ptr,form_mask);
            }

            FIf_display(form_ptr);
        }
    }
    else  /* GRcreate_setadp() failed */
    {
        status = FALSE;
    }

    return(status);
}
