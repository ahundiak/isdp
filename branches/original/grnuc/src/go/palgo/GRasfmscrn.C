/*
Name
        GRassign_form_screen

Description
        This function places a form on the same physical screen as a
        second form, which is assumed to already be displayed.

Algorithm
        This is trickier than it might seem, since asking a form what
        screen it is on with FIf_get_screen will just return
        FI_CURRENT_SCREEN, which is useless.  Therefore, some Environ V
        functions must be used to determine where the form resides.
        First, it is determined whether there is actually more than one
        physical screen.  If so, then the form's Environ V window number
        is used to determine its virtual screen.  That is compared to
        the virtual screen number of the right physical screen to
        determine where to place the first form.

History
        mrm     02/06/92    creation
        elp     01/06/93    port to NT
*/

#include <FI.h>
#include "igrtypedef.h"
#include "igr.h"
#include "igewindef.h"
#include "igewinmacros.h"

IGRint GRassign_form_screen(existing_form, form_to_assign)
Form existing_form, form_to_assign;
{
#ifdef X11
    /* no action required (yet) */
#else
    IGRint phy_screens, wno, vs1, vs2, screen;

    ige$get_num_phy_screens(num_phy_screens = &phy_screens);
    if (phy_screens > 1)
    {
        FIf_get_window(existing_form, &wno);
        Inq_win_vs(wno, &vs1);
        ige$inq_term_info(screen_no = IGE_RIGHT_SCREEN, vs_no = &vs2);
        screen = (vs1 == vs2) ? FI_RIGHT_SCREEN : FI_LEFT_SCREEN;
#if ! defined( NT )
        FIf_set_screen(form_to_assign, screen);
#endif
    }
#endif
    return(TRUE);
}
