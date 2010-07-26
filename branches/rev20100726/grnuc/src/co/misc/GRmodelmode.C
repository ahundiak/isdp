/*
Name
        GRget_model_mode

Abstract
        int GRget_model_mode()

Description
        This function determines whether the user is in detailing or modeling
        mode by examining which bar menu is displayed.

Return Values
        The function return values are defined in grdpbdef.h

        GR_DETAIL_MODE      The detail bar menu is displayed
        GR_MODEL_MODE       Some bar menu other than detail is displayed
        GR_UNKNOWN_MODE     No bar menu is displayed

Notes
        Examining the bar menu may not be helpful in batch or when using paper
        menus.

        Another approach might be to get BAR_DETAIL by name, then check
        whether it is displayed.  This approach was rejected because FORMS has
        had a problem with keeping the old menus around after a swap.  If that
        happens, an old detail menu might still be hanging around in limbo
        when this function is called, leading to erroneous results.

History
        mrm     03/05/93    creation
*/

#include <string.h>
#ifdef ENV5
#include <FI.h>
#endif
#ifdef X11
#include <FI.h>
#endif
#include "grdpbdef.h"

extern Form GRgetbarmenu();

int GRget_model_mode()
{
    char name[128];
    Form form;

    if (form = GRgetbarmenu())
    {
        FIf_get_name(form, name);
        if (strcmp(name, "BAR_DETAIL") == 0)
            return(GR_DETAIL_MODE);
        else
            return(GR_MODEL_MODE);
    }
    return(GR_UNKNOWN_MODE);
}
