/*
Name
        GRvalidate_button

Description
        This function is used as a hook to validate a menu button before it is
        displayed.  The hook is set in ??the licensing code??.

History
        mrm     12/02/92    creation
        prl     12/15/92    changed to set button attributes in this function
                            instead of GRmenu_button_creation_routine, changed
                            gadget color to FI_MED_GRAY
*/

#include <stdio.h>
#include <string.h>
#ifdef X11
#include <FI.h>
#endif
#ifdef ENV5
#include <FI.h>
#endif
#include "OMminimum.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"

int GRvalidate_button(command, form, label)
char  *command;
Form  form;
int   *label;
{
    int sts;
    int attr_mask;

    if (command == NULL || *command == NULL)
        return(FALSE);

    /* allow any ci command - no easy way to validate them */
    if (strncmp(command, "ci=", 3) == 0)
        return(TRUE);

    /* check whether this is a command key */
    sts = ex$get_cmd_info(string = command, mode = EX_CMD_KEY);
    if (sts & 1)
        return(TRUE);

    /* check whether this is a command string */
    sts = ex$get_cmd_info(string = command, mode = EX_STRING);
    if (sts & 1)
        return(TRUE);

    /* not an active command, so disable the button */
    FIg_get_attr(form, *label, &attr_mask);
    attr_mask |= FI_NOT_ENABLED;
    FIg_set_attr(form, *label, attr_mask);
    FIg_set_color(form, *label, FI_MED_GREY);

    return(FALSE);
}

/*
Name
        GRmenu_button_creation_routine

Description
        This function is used to set the display characteristics of a disabled
        button.  It is called from the FORMS code via a hook set up in the
        GRcustomize_menus function.

History
        mrm     12/02/92    creation
        prl     12/15/92    This function no longer sets button display
                            attributes.  Display now set in GRvalidate_button.
                            This is to support call to GRvalidate_button from
                            GRcustmenu when menus are initially displayed. 
*/

int GRmenu_button_creation_routine(form, label)
Form form;
int label;
{
	char buf[BUFSIZ];
	int sts;

	*buf = NULL;
	sts = FIbtn_get_palette(form, label, buf);
	if ((sts != FI_SUCCESS) || (*buf == NULL))
		sts = FIg_get_command(form, label, buf);
	if (*buf)
		GRvalidate_button(buf, form, &label);

	return(TRUE);
}
