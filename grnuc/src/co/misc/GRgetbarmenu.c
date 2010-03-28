/*
Name
        GRgetbarmenu

Description
        This function will return a pointer to the active bar menu.  Active is
        defined as the first displayed form encountered which is of type
        FI_BAR_MENU_TYPE or FI_TEAR_OFF_BAR_MENU_TYPE.  The function returns
        NULL if no menu can be found.

History
        mrm     07/24/92    creation
*/

#include <alloca.h>
#include <stdlib.h>
#include <FI.h>

Form GRgetbarmenu()
{
    int i, n, type, displayed;
    Form *forms;

    /* get a list of forms and menus */
    FI_get_num_forms_menus(&n);
    forms = (Form *)alloca(n * sizeof(Form));
    FI_get_forms_menus(forms, &n);
    for (i = 0; i < n; i++)
    {
        FI_get_form_menu_type(forms[i], &type);
        if (type == FI_BAR_MENU_TYPE || type == FI_TEAR_OFF_BAR_MENU_TYPE)
        {
            /* make sure this is the active menu */
            FIf_is_displayed(forms[i], &displayed);
            if (displayed)
                return(forms[i]);
        }
    }
    return(NULL);
}
