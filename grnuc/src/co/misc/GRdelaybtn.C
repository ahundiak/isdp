/*
Name
        GRdelay_button

Description
        This function is used to update the Update Associative Element button
        on the menu bar to reflect the status of the batch queue.  The status
        may be immediate (black), delayed (blue), or delayed with something
        pending in the batch (yellow) (those colors sound just like a big ol'
        bruise).

History
        mrm     11/24/93    creation
*/

#include <FI.h>
#include "comisc.h"
#include "nddef.h"
#include "ndmacros.h"

static int button_state = GR_DELAY_UNKNOWN;

void GRdelay_button(int new_state)
{
    if (new_state != button_state)
    {
        int color;
        if (new_state == GR_DELAY_UPDATE)
        {
            if (button_state != GR_DELAY_UNKNOWN)
                new_state = button_state;
            else
            {
                int mode;
                nd$mod_batch(request = ND_INQ, p_ret_mode = &mode);
                new_state = (mode == ND_DEFER) ? GR_DELAY_ON : GR_DELAY_OFF;
            }
        }
        if (new_state == GR_DELAY_OFF)
            color = FI_BLACK;
        else if (new_state == GR_DELAY_ON)
            color = FI_BLUE;
        else
            color = FI_YELLOW;
        GRcolor_menu_button("ASUpAE", color);
        button_state = new_state;
    }
}
