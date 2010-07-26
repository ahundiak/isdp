/*
Name
        GRdisplay_associative_button

Description
        This function is used to turn the associative button on
        or off.  If "on" is true, then the button on the menu bar
        is highlighted.  If "on" is false, then the associative
        button is returned to the default menu colors.

History
        pp      04/26/91    creation as EFdisplay_associative_button
        mrm     08/16/91    renamed and moved from MODEL to GRNUC,
                            rewrote for menu bar
        mrm     09/04/91    changed to not hardcode menu bar button index
        mrm     11/05/91    added GRupdate_assoc_buttons
        mrm     02/18/92    removed dependency on menu names
        mrm     08/12/93    use GRcustom_hilite_button for brighter display

*/

#include <FI.h>
#include "igrtypedef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

/* indices for the on and off symbols in GRbar.sym */
#define ON_SYMBOL               21
#define OFF_SYMBOL              22
#define ACTIVE_SYMBOL           23
#define INACTIVE_SYMBOL         82

/* command key for the Toggle Associativity command */
static char *ASSOC_CMD = "GRTgAs";

IGRint GRdisplay_associative_button(on)
IGRint on;
{
    IGRboolean dpb_state;
    IGRint outline_color, fill_color, filled_index = -1, outline_index = -1;

    gr$get_associative_flag(buffer = &dpb_state);
    if (on)
    {
        if (dpb_state)
        {
            filled_index = ACTIVE_SYMBOL;
            fill_color = FI_BLUE;
            outline_index = ON_SYMBOL;
            outline_color = FI_LT_GREY;
        }
        else
        {
            filled_index = INACTIVE_SYMBOL;
            fill_color = FI_RED;
            outline_index = OFF_SYMBOL;
            outline_color = FI_BLACK;
        }
    }
    else
    {
        if (dpb_state)
        {
            filled_index = ACTIVE_SYMBOL;
            outline_index = ON_SYMBOL;
        }
        else
        {
            filled_index = -1;
            outline_index = OFF_SYMBOL;
        }
        fill_color = FI_LT_GREY;
        outline_color = FI_BLACK;
    }

    GRcustom_hilite_button(ASSOC_CMD, 1, filled_index, fill_color, 
                           outline_index, outline_color);
    
    return(TRUE);
}

#if 0   /* obsolete */
IGRint EFdisplay_associative_button(on)
IGRint on;
{
    printf("Replace call to EFdisplay_associative_button with ");
    printf("GRdisplay_associative_button\n");
    return(GRdisplay_associative_button(on));
}
#endif

/*
Name
        GRupdate_assoc_button

Description
        This function will update the associative button on the active
        menu bar to reflect the dpb state of the associative flag.

History
        mrm     08/11/93    gutted to call GRdisplay_associative_button
*/

void GRupdate_assoc_button()
{
    GRdisplay_associative_button(0);
}

/*
Name
        GRupdate_assoc_buttons

Description
        This function will update the associative buttons on all menu
        bars to reflect the dpb state of the associative flag,
        regardless of whether the menu is displayed.

History
        mrm     08/11/93    gutted to call GRdisplay_associative_button
*/

void GRupdate_assoc_buttons()
{
    GRdisplay_associative_button(0);
}
