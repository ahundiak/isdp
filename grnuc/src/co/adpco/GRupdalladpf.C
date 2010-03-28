/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     FUNCTION NAME:           GRupdate_adp_forms
 
     Abstract:

        This routine updates all active drawing parameters forms that are
displayed.
-----
%SC%

     VALUE =  GRupdate_adp_forms(msg,param_type,param_value)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------
     param_type   IGRint         type of parameter(s) being changed:
                                 grdpb_active_display,
                                 grdpb_active_level,
                                 grdpb_active_angle,
                                 grdpb_active_scale
                                 (these parameter types are defined
                                  in grdpbdef.h)
     *param_value IGRchar        parameter value(s):
                                 grdpb_active_display => struct IGRdisplay
                                 grdpb_active_level => IGRshort
                                 grdpb_active_angle => IGRdouble
                                 grdpb_active_scale => struct GRdpb_scale
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        completion code
     VALUE (IGRlong) =    MSSUCC    - if successful
                          MSFAIL    - if failure
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
        
        WBC  12/10/87 : Design date.
        WBC  12/10/87 : Creation date.
        WBC  06/19/89 : Updated to handle c-based forms.
        dhm  07/13/92 : ANSI conversion.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine updates all active drawing parameters forms that are
displayed.
----*/
/*EH*/

#include "coimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "adpdef.h"
#include "FI.h"
#include "igewinmacros.h"

static IGRint (*display_func)() = 0;

IGRint (*GRadp_display_notify(notify_func))()

IGRint (*notify_func)();
{
    IGRint    (*prev_func)();

    prev_func = display_func;
    display_func = notify_func;
    return(prev_func);
}


IGRint GRupdate_adp_forms(msg,param_type,param_value)

IGRlong     *msg;
IGRint      param_type;
IGRchar     *param_value;

{
    struct IGRdisplay      *active_display;
    struct  EX_var_list    var_list[5];
    Form                   setadp_form_ptr;
    IGRlong                temp_msg;         /* return code of modules       */
    IGRint                 status;
    IGRint                 error_index;

    *msg = MSSUCC;

    /*
     * If a save/restore window is active, cannot update the form(s) since this
     * may not be the most recently displayed save/restore window
     */

    if (!(ige$SR_active()))
    {
        /*
         *  get the pointer to the Active Drawing Parameters form if it exists
         */

        /*
         *  update the Active Drawing Parameters form if a display or layer
         *  parameter has been changed
         */

        if ((param_type == grdpb_active_display) ||
            (param_type == grdpb_active_level))
        {
            if (param_type == grdpb_active_display)
            {
                active_display = (struct IGRdisplay *)param_value;

                var_list[0].var = ADP_COLOR_NUM;
                var_list[0].var_value = (IGRchar *) &active_display->color;
                var_list[1].var = ADP_WEIGHT_NUM;
                var_list[1].var_value = (IGRchar *) &active_display->weight;
                var_list[2].var = ADP_STYLE_NUM;
                var_list[2].var_value = (IGRchar *) &active_display->style;
                var_list[3].var = ADP_END_LIST;
            }
            else
            {
                var_list[0].var = ADP_LAYER_NUM;
                var_list[0].var_value = (IGRchar *) param_value;
                var_list[1].var = ADP_END_LIST;
            }

            GRupdate_adp(&temp_msg, NULL, var_list, &error_index);
        }

        if (display_func)
        {
            (*display_func)();
        }

        /*
         * get the pointer to the Set Active Drawing Parameters
         * form if it exists
         */

        if (GRcreate_setadp(&temp_msg,FALSE,&setadp_form_ptr))
        {
            /*
             *  is the Set Active Drawing Parameters form displayed?
             */

            FIf_is_displayed(setadp_form_ptr,&status);

            if (status)
            {
                /*
                 *  Form is displayed; update it
                 */

                switch (param_type)
                {
                    case grdpb_active_angle:

                        var_list[0].var = ADP_ANGLE_NUM;
                        var_list[0].var_value = (IGRchar *)param_value;
                        var_list[1].var = ADP_END_LIST;
                        break;

                    case grdpb_active_display:

                        active_display = (struct IGRdisplay *)param_value;

                        var_list[0].var = ADP_COLOR_NUM;
                        var_list[0].var_value = (IGRchar *) &active_display->color;
                        var_list[1].var = ADP_WEIGHT_NUM;
                        var_list[1].var_value = (IGRchar *) &active_display->weight;
                        var_list[2].var = ADP_STYLE_NUM;
                        var_list[2].var_value = (IGRchar *) &active_display->style;
                        var_list[3].var = ADP_COLOR_NAME;
                        var_list[3].var_value = (IGRchar *) &active_display->color;
                        var_list[4].var = ADP_END_LIST;
                        break;

                    case grdpb_active_scale:

                        var_list[0].var = ADP_SCALE_NUM;
                        var_list[0].var_value = (IGRchar *)param_value;
                        var_list[1].var = ADP_END_LIST;
                        break;

                    case grdpb_active_level:

                        var_list[0].var = ADP_LAYER_NUM;
                        var_list[0].var_value = (IGRchar *)param_value;
                        var_list[1].var = ADP_LAYER_NAME;
                        var_list[1].var_value = (IGRchar *)param_value;
                        var_list[2].var = ADP_END_LIST;
                        break;

                    default:

                        *msg = MSFAIL;
                        break;
                }

                if (*msg & 1)
                {
                    GRupdate_setadp(&temp_msg,setadp_form_ptr,
                                    var_list,&error_index);
                }
            }
        }

        if (param_type == grdpb_active_display)
        {
            /*
             * if there is an active Set Drawing Parameters
             * subform, update it
             */

            GRupdate_setadp_subforms(param_value);
        }
    }
    return(TRUE);
}
