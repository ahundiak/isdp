/*
Name
        GRupdate_adp

Abstract
        This method will update the specified gadget(s) on the Set Active
        Drawing Parameters form.  Any combination of gadgets may be updated.

Synopsis
        VALUE = GRupdate_adp(msg, form_ptr, var_list, error_index)

        IGRlong *msg - output
                return code
                MSSUCC    - if successful
                MSINARG   - if invalid argument
                MSFAIL    - if failure
        Form form_ptr - optional input
                Pointer to the form to be updated; NULL indicates that the
                function should find the bar menu[s].
        struct EX_var_list var_list[] - input
                array of structures indicating which gadgets to update and
                their new values; the following are the valid gadget types
                (defined in adpdef.h): ADP_LAYER_NUM, ADP_COLOR_NUM,
                ADP_WEIGHT_NUM, ADP_STYLE_NUM
        IGRint *error_index - output
                index of invalid array structure

Notes
        The valid types for the var_list structures are defined in adpdef.h.
            - ADP_END_LIST must be the type specified in the last structure
              in the array var_list; this implies the number of structures
              in the array will be one greater than the number of gadgets
              being changed.
            - The structure member num_bytes in struct EX_var_list is not
              used.

History
        WBC  07/31/87 : Design date.
        WBC  07/31/87 : Creation date.
        WBC  12/09/87 : Updated to change any number of parameters
                        with a single call.
        WBC  06/12/89 : Changed from a method to a function.
        dhm  09/19/91 : Changed the linestyle case to do a DPinq_style.
        dhm  07/13/92 : ANSI conversion.
        jdu  05/12/93 : fixed for 2.4 color scheme color pallet only used for 
                        generate set
        mrm  09/20/93 : changed to find bar menu[s] here
*/

#define GRCOLOR_OFFSET  10000

#include "coimport.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "adpdef.h"
#include "FI.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "exmacros.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "wl.h"
#include "comisc.h"

typedef struct
{
    int *error_index, *msg, status;
    struct EX_var_list *var_list;
} adp_data;

static void GRupdate_adp_callback(Form form, adp_data *d)
{
    int i, status;
    int *msg = d->msg;
    int *error_index = d->error_index;
    unsigned short line_style;
    char text_string[8];
    short active_layer, abs_color;
    struct IGRdisplay active_display;
    struct GRid module_grid;
    WLuint32 context_no;
    WLhwin_no hwin_no;
    WLuint16 lscreen_no;
    struct EX_var_list *var_list = d->var_list;

    if (GRverify_adp_gadgets(form) != TRUE)
        return;

    *msg = MSSUCC;
    status = TRUE;

    /*
     * update each specified gadget on the Active Drawing Parameters
     * form with the specified value
     */

    for (i = 0; (var_list[i].var != ADP_END_LIST) && (*msg & 1); i++)
    {
        switch (var_list[i].var)
        {
            case ADP_LAYER_NUM:

                active_layer = *((IGRshort *)var_list[i].var_value);
                sprintf(text_string,"%d",(IGRint)active_layer);
                FIfld_set_text(form,ADP_LAYER_LABEL,0,0,text_string,FALSE);

                break;

            case ADP_WEIGHT_NUM:

                active_display.weight = *((IGRuchar *)var_list[i].var_value);
                sprintf(text_string,"%d",(IGRint)active_display.weight);
                FIfld_set_text(form,ADP_WEIGHT_LABEL,0,0,
                               text_string,FALSE);

                FIg_erase(form,ADP_LINE_LABEL);
                if (active_display.weight < 11)
                {
                   FIg_set_line_weight(form,ADP_LINE_LABEL,
                                       (IGRint)active_display.weight);
                }
                else
                {
                   FIg_set_line_weight(form,ADP_LINE_LABEL,11);
                }
                FIg_display(form,ADP_LINE_LABEL);

                break;

            case ADP_COLOR_NUM:

                active_display.color = *((IGRushort *)var_list[i].var_value);

                /*
                 * must convert the active color to its absolute color index
                 */

                ex$get_cur_mod(id = &module_grid.objid,
                               osnum = &module_grid.osnum);

                FIf_get_window(form, &hwin_no);
                WLget_logical_screen_from_window( hwin_no, &lscreen_no);
                CMget_exnuc_forms_context( lscreen_no, &context_no );

                if (ige$get_abs_color_index(context_no = context_no,
                                            log_color = active_display.color,
                                            abs_color = &abs_color))
                {
                   FIg_erase(form,ADP_LINE_LABEL);
                   FIg_set_color(form,ADP_LINE_LABEL,
                                 (int)(abs_color + GRCOLOR_OFFSET));
                   FIg_display(form,ADP_LINE_LABEL);
                }
                else
                {
                    *msg = MSFAIL;
                    status = FALSE;
                }

                break;

            case ADP_STYLE_NUM:

                active_display.style = *((IGRuchar *)var_list[i].var_value);

                /*
                 *  change the style of the line gadget; must set the
                 *  tools value for line style for now
                 */

                DPinq_style( (IGRshort)active_display.style, &line_style);

                FIg_erase(form,ADP_LINE_LABEL);
                FIg_set_line_style(form,ADP_LINE_LABEL,(IGRint)line_style);
                FIg_display(form,ADP_LINE_LABEL);

                break;

            default:

                *msg = MSINARG;
                status = FALSE;
                *error_index = i;
                break;
        }  /* end switch on parameter type */
    }    /* end for loop */

    d->status = status;
}


IGRint GRupdate_adp(IGRlong            *msg,
                    Form               form_ptr,
                    struct EX_var_list var_list[],
                    IGRint             *error_index)

{
    adp_data d;

    *msg = MSSUCC;
    d.status = TRUE;
    d.msg = (int *)msg;
    d.var_list = var_list;
    d.error_index = error_index;

    if (form_ptr)
        GRupdate_adp_callback(form_ptr, &d);
    else
        GRmonkey_with_forms(GR_FI_BAR_MENU_TYPE | GR_FI_TEAR_OFF_BAR_MENU_TYPE,
                            GRupdate_adp_callback, &d);
    return(d.status);
}
