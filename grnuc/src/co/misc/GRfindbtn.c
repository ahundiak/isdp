/*
Name
        GRfind_button_on_menu_bar

Description
        This function will find a button on the menu bar which corresponds to
        the specified command string.  If the menu bar to search is not
        specified by the caller, the routine will search for a displayed menu
        bar, stopping on the first one found.

Synopsis
        int GRfind_button_on_menu_bar(cmd_to_find, menu_bar_arg, button_label)

        int ()                o     TRUE => success, FALSE => failure
        char *cmd_to_find     i     Command string/key to look for.
        Form *menu_bar_arg    i/o   Menu bar id, if known.  May be NULL, or
                                    pointer initialized to NULL.  If the
                                    latter, the menu bar id will be returned.
        int *button_label     o     The label of the button containing
                                    cmd_to_find (-1 on failure).

Notes
        The gadgets on the menu are checked sequentially until a
        matching command is found.  If a gadget label is invalid, the
        search continues up to MAX_INDEX, rather than terminating the
        search.  This allows applications (especially those not using
        menu builder and genmenu) to not have to worry about keeping
        gadget labels in order.

History
        mrm     09/04/91    creation
        mrm     02/18/92    removed dependency on menu names
        mrm     08/31/93    allow wildcard to ignore command prefix
*/

#include <alloca.h>
#include <FI.h>

#define TRUE    1
#define FALSE   0
#define NULL    0

/* gadget label range for the buttons on the menu bar */
#define FIRST_INDEX     11
#define MAX_INDEX       40

int GRfind_button_on_menu_bar(cmd_to_find, menu_bar_arg, button_label)
char *cmd_to_find;
Form *menu_bar_arg;
int *button_label;
{
    int i, n, type, sts, valid = FALSE;
    Form menu_bar, *forms;
    char cmd[128];

    *button_label = -1;

    /* if the caller has not specified the menu bar id, find it */
    if (menu_bar_arg == NULL || *menu_bar_arg == NULL)
    {
        menu_bar = NULL;

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
                FIf_is_displayed(forms[i], &valid);
                if (valid)
                {
                    menu_bar = forms[i];
                    break;
                }
            }
        }

        if (menu_bar)
        {
            /* return the menu_bar if the caller requested it */
            if (menu_bar_arg)
            {
                *menu_bar_arg = menu_bar;
            }
        }
        else
        {
#if DEBUG
            printf("Failed to find menu bar (sts = %d)\n", sts);
#endif
            return(FALSE);
        }
    }
    else
    {
        menu_bar = *menu_bar_arg;
    }

    /* check for leading *'s in the target command; these may be used to
       ignore leading characters, like the package prefix.  This is to
       accomodate apps which alias commands (eg GRDlE -> Z1DlE) */
    for (n = 0; cmd_to_find[n] == '*'; n++)
        ;

    /* find the button on the bar which corresponds to the command */
    for (i = FIRST_INDEX; i < MAX_INDEX; i++)
    {
        sts = FIg_get_command(menu_bar, i, cmd);
        if ((sts == FI_SUCCESS) && (strcmp(&cmd[n], &cmd_to_find[n]) == 0))
        {
            *button_label = i;
            return(TRUE);
        }
    }
    return(FALSE);
}
