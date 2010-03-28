#include <alloca.h>
#include <FI.h>
#include "igrtypedef.h"
#include "OMminimum.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "EXproduct.h"
#include "comisc.h"

extern int GRmenu_button_creation_routine();
extern int GRmenu_button_intercept_routine();
extern void GRadp_intercept();

/*
Name
        GRinstall_menu_button_intercepts

Description
        This function installs the menu button intercepts on the specified
        form.

History
        mrm     09/15/93    ripped from inside GRcustomize_menus
*/

void GRinstall_menu_button_intercepts(Form form)
{
    int type, label;

    FI_get_form_menu_type(form, &type);
    if (type == FI_BAR_MENU_TYPE || type == FI_TEAR_OFF_BAR_MENU_TYPE)
        FIf_set_button_intercept_routine(form, GRadp_intercept);
    else if (type == FI_PANEL_MENU_TYPE || type == FI_TEAR_OFF_PANEL_MENU_TYPE)
        FIf_set_button_intercept_routine(form,
                                         GRmenu_button_intercept_routine);

    /* Set appropriate bar/panel buttons to disabled state */
    if (type == FI_BAR_MENU_TYPE   || type == FI_TEAR_OFF_BAR_MENU_TYPE   ||
        type == FI_PANEL_MENU_TYPE || type == FI_TEAR_OFF_PANEL_MENU_TYPE ||
        type == FI_POCKET_MENU_TYPE)
    {
        label = 11;
        while (FIg_erase(form, label) == FI_SUCCESS) 
        {  
            GRmenu_button_creation_routine(form, label); 
            FIg_display(form, label);
            label++;
        }
    }
}

/*
Name
        GRtear_off_created

Description
        This function is called by IFORMS when a tear-off menu is created.
        The popup intercept is set here for the new menu.

History
        mrm     09/15/93    creation
*/

void GRtear_off_created(Form form)
{
    GRinstall_menu_button_intercepts(form);
    GRswap_task_label(NULL);
    GRupdate_adp_gadgets();
}

/*
Name
        GRcustomize_menus

Description
        This function is used to customize the default menus.  It sets
        up intercept routines for popups, adjusts the icons on some of
        the bar menu buttons to reflect current settings, and performs
        any other processing necessary when to get the proper look &
        feel on the menus.  It should be called any time there is a
        change in the screen menus (EXNUC changes them at every save or
        retrieve for journaling purposes).  Currently GRdpb$wake_up
        calls this routine.

History
        mrm     11/05/91    creation
                02/18/92    removed dependency on menu names
        prl     12/15/92    Added call to GRmenu_button_creation_routine
                            to validate buttons and set to disabled where
                            appropriate. Added call to GRswap_task_label
                            to initialize text on bar menu swap task button.
	prl	12/31/92    Added check to see if forms are displayed before
                            intercepts are set and form buttons validated.
                            This is requried becasue of an error in forms
			    which dose not cleanup menus after MS_swap_menus.
			    A result of this change is that the pocket menu 
			    is not checked for valid commands.
*/

int GRcustomize_menus()
{
    int i, n, displayed;
    static int first = TRUE;
    Form *forms;

    if (first)
    {
        /* set up a hook to get notified as menu buttons are created */
        MI_set_menu_button_creation_routine(GRmenu_button_creation_routine);
#ifdef ENV5
        /* set up a hook to get notified when a tear-off menu is created */
        MI_set_tear_off_menu_modify_routine(GRtear_off_created);
#endif
        first = FALSE;
    }

    /* set the associative button on the bar menus */
    GRupdate_assoc_buttons();

    /* set up the adp gadgets */
    GRupdate_adp_gadgets();

    /* set the delay toggle */
    GRdelay_button(GR_DELAY_UPDATE);

    /* set the intercept routines on the bar and panel menus */
    FI_get_num_forms_menus(&n);
    forms = (Form *)alloca(n * sizeof(Form));
    FI_get_forms_menus(forms, &n);
    for (i = 0; i < n; i++)
    {
        FIf_is_displayed(forms[i], &displayed);
        if (displayed)
            GRinstall_menu_button_intercepts(forms[i]);
    }

    /* set text on bar menu swap task button when product initially envoked */
    GRswap_task_label("IMTkInit");

    return(TRUE);
}
