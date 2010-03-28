/*
Name
        GRswaptask

Description
        This file contains functions relating to swapping tasks.
*/

#include <stdio.h>
#include <string.h>
#include <FI.h>
#include <MI.h>
#include <MS.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "EXproduct.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmsg.h"
#include "adpdef.h"
#include "comisc.h"

extern Form GRgetbarmenu();
extern char EX_runname[];
extern unsigned int OM_Gf_verbose_warning;

static char active_task_key[16];
static char active_bar_menu[16];

/*
Name
        GRactivate_menu

Description
        This function activates the specified menu.  If the menu is already
        displayed, nothing is changed.

Synopsis
        int GRactivate_menu(int type, char *name)

        type    input   menu type (from FI.h)
        name    input   name of menu to activate

Return Values
        GR_E_Error              invalid menu name
        GR_E_MenuNotActivated   requested menu not displayed
        GR_I_MenuActivated      requested menu is displayed
        GR_I_MenuAlreadyActive  requested menu already displayed

History
        mrm     03/12/93    creation
*/

int GRactivate_menu(int type, char *name)
{
    int sts;
    Form form;

    /* check for NULL name (happens when swapping bar but not panel) */
    if (name == NULL || *name == NULL)
        return(GR_E_Error);

    /* check whether the correct menu is already active */
    if (FI_get_form_by_name(name, &form) == FI_SUCCESS)
    {
        if (type == FI_POCKET_MENU_TYPE)
            return(GR_I_MenuAlreadyActive);
        else
        {
            FIf_is_displayed(form, &sts);
            if (sts)
                return(GR_I_MenuAlreadyActive);
        }
    }

    /* swap in the new menu */
    sts = MS_swap_menu(type, name);

    /* check results */
    if (sts == FI_SUCCESS)
        sts = GR_I_MenuActivated;
    else
    {
        sts = GR_E_MenuNotActivated;
        if (OM_Gf_verbose_warning)
            ex$message(msgnumb = sts, type = "%s", var = `name`);
    }

    return(sts);
}

/*
Name
        GRswap_tearoffs

Description
        This function is called for each tearoff bar menu during a task swap
        to make sure the tearoff menus are also swapped to the new task.
        Panel menus are ignored, since tearing off subpanels makes that a
        problem too nasty to touch.

Notes
        Since tearoffs are only an Environ V creation, window manager
        decoration can be safely ignored.

        Menus created here through MIm_new are not marked as tearoffs by
        forms.  Therefore, the user pointer field in the form is used for that
        purpose, to avoid replacing the "real" bar menu.

History
        mrm     09/20/93    creation
*/

#ifdef ENV5

extern int _MS_notify();

void GRswap_tearoffs(Form form, char *name)
{
    int x, y, tearoff, type, displayed;

    FIf_is_displayed(form, &displayed);
    if (!displayed) return;
    FI_get_form_menu_type(form, &type);
    FIf_get_user_pointer(form, (char *)&tearoff);
    if (type == FI_BAR_MENU_TYPE && !tearoff) return;
    FIf_get_location(form, &x, &y);
    FIf_erase(form);
    FIf_delete(form);
    MIm_new(BAR_MENU, TEAR_OFF_BAR_MENU, name, _MS_notify, &form);
    FIf_set_location(form, x, y);
    FIf_set_user_pointer(form, (char *)1);
    MIm_display(form);
}

#endif


/*
Name
        GRswap_task

Description
        This function is used to swap the panel and bar menus when the
        user changes tasks within a product.

History
        prl     12/15/92    creation
        mrm     03/04/93    update the adp gadgets (TR119301604)
        mrm     09/15/93    track bar menu name
*/

int GRswap_task(char *task_key,
                char *panel_menu,
                char *bar_menu,
                char *pocket_menu)
{
    int something_changed = FALSE;
    Form form;
    struct EX_cmd task_str;
 
    if (ex$get_cmd_info(string = task_key,
                        mode = EX_CMD_KEY,
                        cmdstr = &task_str))
    {
        /* swap the menus */

        GRactivate_menu(POCKET_MENU, pocket_menu);

        if (GRactivate_menu(PANEL_MENU, panel_menu) == GR_I_MenuActivated)
            something_changed = TRUE;

        if (GRactivate_menu(BAR_MENU, bar_menu) == GR_I_MenuActivated)
        {
            something_changed = TRUE;

            /* notify any interested parties about the menu swap */
            if (form = GRgetbarmenu())
                GRswap_menu_notification(bar_menu, form);

            // store the name of the active bar menu
            strcpy(active_bar_menu, bar_menu);
#ifdef ENV5
            // swap any tearoff menus
            GRmonkey_with_forms(GR_FI_BAR_MENU_TYPE |
                                GR_FI_TEAR_OFF_BAR_MENU_TYPE,
                                GRswap_tearoffs, bar_menu);
#endif
        }

        if (something_changed)
        {
            /* reattach the menu intercepts for popups */
            GRcustomize_menus();

            /* update the menu bar task button */
            GRswap_task_label(task_key);
        }
    }
    else if (OM_Gf_verbose_warning)
        ex$message(msgnumb = GR_E_NoCmdInfo, type = "%s", var = `task_key`);

    return(TRUE);
}

/*
Name
        GRstore_active_task

Description
        This function is used to store the active task key.  It should be a
        simple strcpy, but the IMTkInit key needs to be changed in to the
        "real" key.  This is done by converting the task key into a command
        string, then back to a command key, which only works as long as
        IMTkInit is found in the command tables after the real key.

History
        mrm     08/25/93    creation
        mrm     09/15/93    track bar menu name
*/

void GRstore_active_task(char *task_key)
{
    if (strcmp(task_key, "IMTkInit") == 0)
    {
        char *m, *e;
        struct EX_cmd cmd, cmd2;

        // determine the "real" task key
        ex$get_cmd_info(string = task_key,
                        mode = EX_CMD_KEY,
                        cmdstr = &cmd);
        ex$get_cmd_info(string = cmd.command_name_ptr,
                        mode = EX_STRING,
                        cmdstr = &cmd2);
        strcpy(active_task_key, cmd2.command_key);

        // determine the "real" bar menu name
        if (m = strstr(cmd2.input_string, "BAR"))
        {
            if (e = strchr(m, (int)' ')) // strip the pocket menu name
                *e = NULL;
        }
        else
            m = "BAR_MODEL";    // well, heck, slant the guess to EMS
        strcpy(active_bar_menu, m);
    }
    else
        strcpy(active_task_key, task_key);
}

/*
Name
        GRget_active_task

Description
        This function returns the active task key

History
        mrm     08/25/93    creation
*/

char *GRget_active_task(char *task_key)
{
    return(strcpy(task_key, active_task_key));
}

/*
Name
        GRswap_task_label_callback

Description
        This function is invoked via GRswap_task_label to change the task
        label on all the bar menus.  There is normally only one bar menu, but
        tearoff menus are possible under Environ V, so going this route makes
        sure all the menus are changed.

History
        mrm     09/20/93    creation
*/

static void GRswap_task_label_callback(Form form, char *label_text)
{
    FIg_set_on_text(form, TASK_LIST_BUTTON, label_text);
    FIg_set_off_text(form, TASK_LIST_BUTTON,  label_text);
    FIg_display(form, TASK_LIST_BUTTON);
}


/*
Name
        GRswap_task_label

Description
        This function is used to to set the text on the swap task button
        located on the bar menu.  Button gadget number is TASK_LIST_BUTTON.

History
        prl     12/15/92    creation
        mrm     03/04/93    strip custom package info (everything to the right
                            of and including the "(") (TR119301775)
        mrm     07/29/93    add tilde-arrowhead
        mrm     09/20/93    Use GRmonkey_with_forms to get tearoffs
*/

int GRswap_task_label(char *task_key)
{
    char *p, label_text[64], logo[32];
    struct EX_cmd task_str;

    // Check for a NULL task_key pointer.  This can be used to signify that
    // the active task key is to be used, such as when a tearoff bar menu is
    // created.
    if (task_key == NULL)
        task_key = active_task_key;

    if (ex$get_cmd_info(string = task_key,
                        mode = EX_CMD_KEY,
                        cmdstr = &task_str))
    {
        /* get the name of the active product */
        p = logo;
        ex$get_prod_info(runname = EX_runname, pstring = &p);

        /* strip off all to left of "_" in logo */
        p = (p = strchr(logo, (int) '_')) ? ++p : logo;
        strcpy(label_text, p);

        /* check for a custom package & strip it off */
        if (p = strchr(label_text, (int)'('))
            strcpy(p, "+");

        /* compose the text for button */
        strcat(label_text, "\n");
        strcat(label_text, task_str.command_name_ptr);

        /* add a tilde, whose definition in mechsws742b.tf has been replaced
           to look like the arrowhead used to indicate the presence of a
           pulldown menu */
        strcat(label_text, "~");

        /* find all the bar menus & change the string */
        GRmonkey_with_forms(GR_FI_BAR_MENU_TYPE | GR_FI_TEAR_OFF_BAR_MENU_TYPE,
                            GRswap_task_label_callback, label_text);

        /* store the active key, in case anyone cares */
        GRstore_active_task(task_key);
    }
    else if (OM_Gf_verbose_warning)
        ex$message(msgnumb = GR_E_NoCmdInfo,
                   type = "%s",
                   var = `task_key`);
    return(TRUE);
}

/*
Name
        GRget_active_bar_menu_name

Description
        What, it's not obvious?  This function get the name of the active bar
        menu.  Since BAR_MENU is not really useful, this function actually
        returns the "real" name of the bar menu of the active task, which gets
        set up in the GRstore_active_task and GRswap_task functions.

History
        mrm     09/15/93    creation
*/

char *GRget_active_bar_menu_name(char *bar_menu_name)
{
    return(strcpy(bar_menu_name, active_bar_menu));
}

/*
Name
        GRget_form_name

Description
        This function returns the name of a form.  What, you say FORMS has a
        function for that?  Well, rest easy, this function uses that but goes
        one step further.  If the name of the form is BAR_MENU, then that gets
        translated into the name of the bar menu used in the default task.
        This information is used as the palette name when locating popup menus
        for the bar menu.

        This is all necessary because we cannot specify the name of the
        default bar menu.  It must be named BAR_MENU.  This is kind of nice in
        that apps can override the EMS menu with ease, but it's kind of a pain
        in the popup files.  There it is necessary to specify a particular
        task's bar menu as the parent palette, or else duplicate all the
        entries again for the default bar menu.

History
        mrm     09/15/93    creation
*/

char *GRget_form_name(Form form, char *name)
{
    FIf_get_name(form, name);
    if (strcmp(name, "BAR_MENU") == 0)
        strcpy(name, active_bar_menu);
    return(name);
}
