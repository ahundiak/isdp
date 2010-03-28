/*
Name
        GRmonkey_with_forms

Description
        This function finds all forms whose type matches the specified
        bitmask, invoking a caller-supplied function for each one.  This
        allows some freedom from worrying with tear-off menus and such all
        over the place.  The bitmask definitions are in comisc.h; they are
        *not* the same as types defined in FI.h.  That is a darned shame, but
        the FI.h versions are not usable in a bitmask.

Notes
        This function normally ignores forms which are not displayed, since
        FORMS tends to crash when some operations are attempted on them
        (specifically, FIf_process_point on the forms that get left over by
        MS_swap_menus).  If the caller really wants non-displayed forms, the
        flag GR_NON_DISPLAYED_FORMS can be or'ed into the type bitmask.

History
        mrm     08/11/93    creation
        mrm     11/09/93    ignore non-displayed forms
*/

#include <alloca.h>
#include <FI.h>
#include "comisc.h"

void GRmonkey_with_forms(int types,
                         void (*caller_function)(),
                         void *caller_info)
{
    int type, i, n, displayed;
    Form *forms;

    /* get a list of all active forms and menus */
    FI_get_num_forms_menus(&n);
    forms = (Form *)alloca(n * sizeof(Form));
    FI_get_forms_menus(forms, &n);
    
    /* loop through each form... */
    for (i = 0; i < n; i++)
    {
        if ((types & GR_NON_DISPLAYED_FORMS) == 0)
        {
            /* ...ignoring non-displayed forms... */
            FIf_is_displayed(forms[i], &displayed);
            if (!displayed)
                continue;
        }

        /* ...and checking whether it of the requested type... */
        FI_get_form_menu_type(forms[i], &type);
        if (((type == FI_FORM_TYPE) && 
             (types & GR_FI_FORM_TYPE)) ||
            ((type == FI_BAR_MENU_TYPE) &&
             (types & GR_FI_BAR_MENU_TYPE)) ||
            ((type == FI_PANEL_MENU_TYPE) &&
             (types & GR_FI_PANEL_MENU_TYPE)) ||
            ((type == FI_POCKET_MENU_TYPE) &&
             (types & GR_FI_POCKET_MENU_TYPE)) ||
            ((type == FI_TEAR_OFF_BAR_MENU_TYPE) &&
             (types & GR_FI_TEAR_OFF_BAR_MENU_TYPE)) ||
            ((type == FI_TEAR_OFF_PANEL_MENU_TYPE) &&
             (types & GR_FI_TEAR_OFF_PANEL_MENU_TYPE)))
        {
            (caller_function)(forms[i], caller_info);
        }
    }
}
