/*
Name
        GRupdate_adp_gadgets

Description
        This function updates all the gadgets reflecting the Active Drawing
        Parameters.

History
        mrm     03/04/94    created - actually, cloned from existing code to
                            provide a simple, argument-free function to get
                            the adp gadgets updated when swapping tasks.
*/

#ifdef ENV5
#include <FI.h>
#endif
#ifdef X11
#include <FI.h>
#endif
#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "ex.h"
#include "igrdp.h"
#include "adpdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

void GRupdate_adp_gadgets()
{
    int msg, error_index;
    short active_layer;
    struct IGRdisplay active_display;
    struct EX_var_list var_list[5];

    gr$get_active_level(buffer = &active_layer);
    gr$get_active_display(buffer = &active_display);

    var_list[0].var = ADP_LAYER_NUM;
    var_list[0].var_value = (IGRchar *)&active_layer;
    var_list[1].var = ADP_COLOR_NUM;
    var_list[1].var_value = (IGRchar *)&active_display.color;
    var_list[2].var = ADP_WEIGHT_NUM;
    var_list[2].var_value = (IGRchar *)&active_display.weight;
    var_list[3].var = ADP_STYLE_NUM;
    var_list[3].var_value = (IGRchar *)&active_display.style;
    var_list[4].var = ADP_END_LIST;

    GRupdate_adp(&msg, NULL, var_list, &error_index);
}
