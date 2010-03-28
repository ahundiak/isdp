/*
Name
        RAPformIsMenu

Description
        This function uses a form name to determine whether the form is a
        menu.  It is really a trivial function, but it is isolated here from
        the rest of the RAP code since there could be a conflict between the
        old forms data structures and definitions used by RAP, and the new
        I/FORMS code used here.

History
        mrm     02/18/92    creation
*/

#include <stdio.h>
#include <FI.h>

#define FALSE   0
#define TRUE    1


int RAPformIsMenu(formName)
char *formName;
{
    int sts, type;
    Form form;

    /* don't record input from unnamed forms - probably popup palettes */
    if (formName[0] == NULL) return(TRUE);

    /* don't record input from the menus - command keys are saved elsewhere */
    sts = FI_get_form_by_name(formName, &form);
    if (sts == FI_SUCCESS)
    {
        FI_get_form_menu_type(form, &type);
        if (type == FI_BAR_MENU_TYPE ||
            type == FI_PANEL_MENU_TYPE ||
            type == FI_POCKET_MENU_TYPE ||
            type == FI_TEAR_OFF_BAR_MENU_TYPE ||
            type == FI_TEAR_OFF_PANEL_MENU_TYPE)
            return(TRUE);
    }
    return(FALSE);
}
