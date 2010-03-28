/*
Name
        GRcreadp.C

Description
        This file contains functions used to track the Active Drawing
        Parameters form.
*/

#include <FI.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "ex.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "adpdef.h"
#include "msdef.h"

extern Form GRgetbarmenu();

static Form adp_form_ptr = 0;

/*
Name
        GRverify_adp_gadgets

Description
        This function verifies the presence of the ADP gadgets on a form.
*/

int GRverify_adp_gadgets(form)
Form form;
{
    int sts, type;

    sts = FIg_get_type(form, ADP_LINE_LABEL, &type);
    if ((sts != FI_SUCCESS) || (type != FI_LINE))
        return(FALSE);

    sts = FIg_get_type(form, ADP_WEIGHT_LABEL, &type);
    if ((sts != FI_SUCCESS) || (type != FI_FIELD))
        return(FALSE);

    sts = FIg_get_type(form, ADP_LAYER_LABEL, &type);
    if ((sts != FI_SUCCESS) || (type != FI_FIELD))
        return(FALSE);

    return(TRUE);
}

#if 0   /* obsolete code follows */

/*
Name
        GRadp_swap_menu_callback

Description
        This function is called when the bar menu is swapped.  The callback is
        registered in GRadp.wakeup.  The function will determine whether the
        new bar menu contains the ADP gadgets, and if so it will update them
        to the active values.

Notes
        This function is no longer registered or invoked.  Instead, the
        function GRcustomize_menus calls GRupdate_adp_gadgets.

History
        mrm     07/29/92    creation
*/

#argsused
void GRadp_swap_menu_callback(name, form)
char *name;
Form form;
{
    /* check whether the ADP gadgets are on the menu */
    if (GRverify_adp_gadgets(form))
    {
        IGRint msg, error_index;
        IGRshort active_layer;
        struct EX_var_list var_list[9];
        struct IGRdisplay active_display;

        /* retrive the active parameters */
        gr$get_active_level(buffer = &active_layer);
        gr$get_active_display(buffer = &active_display);
 
        /* build an update list */
        var_list[0].var = ADP_LAYER_NUM;
        var_list[0].var_value = (IGRchar *)&active_layer;
        var_list[1].var = ADP_COLOR_NUM;
        var_list[1].var_value = (IGRchar *)&active_display.color;
        var_list[2].var = ADP_WEIGHT_NUM;
        var_list[2].var_value = (IGRchar *)&active_display.weight;
        var_list[3].var = ADP_STYLE_NUM;
        var_list[3].var_value = (IGRchar *)&active_display.style;
        var_list[4].var = ADP_END_LIST;
 
        /* set the new values */
        GRupdate_adp(&msg, form, var_list, &error_index);

        /* store the form pointer for later use */
        adp_form_ptr = form;
    }
    else
    {
        /* invalidate the locally-stored form pointer */
        adp_form_ptr = NULL;
    }
}

#endif  /* end obsolete code */

/*
Name
        GRcreate_adp
 
Abstract
        This function returns the form pointer to the active drawing
        parameters form.  It creates the form if it does not exist.

Description
        This function returns the form pointer to the active menu bar, if it
        contains the ADP gadgets.  The create argument is ignored; if the
        gadgets are not present, then the function does not create them; it
        returns a failure status.  This allows applications to do as they wish
        with respect to their menu and adp interface.

Synopsis
        IGRint GRcreate_adp(msg,create,form_ptr)
        IGRlong *msg    output  MSSUCC - if successful
                                MSFAIL - if the form cannot be created
        IGRint create   input   TRUE - create the form if it does not exist
                                FALSE - do not create the form if it does not
                                exist
        Form *form_ptr  output  a pointer to the form

History
        WBC  06/12/89 : Design date.
        WBC  06/12/89 : Creation date.
        mrm  10/28/91   Sun/X Window changes
        mrm  07/24/92   Changed to use the menu bar rather than a separate form
*/

#argsused
IGRint GRcreate_adp(msg,create,form_ptr)
IGRlong       *msg;       /* return code */
IGRint        create;     /* whether or not to create the form - ignored! */
Form          *form_ptr;  /* a pointer to the form */
{
    IGRint sts = TRUE;

    *msg = MSSUCC;

#if 0
    /* check whether form pointer is already set up */
    if (adp_form_ptr)
    {
        /* make sure this is the displayed menu, and one of "ours"  */
        int displayed = FALSE;

        if ((FIf_is_displayed(adp_form_ptr, &displayed) == FI_SUCCESS) &&
            displayed && GRverify_adp_gadgets(adp_form_ptr))
        {
            *form_ptr = adp_form_ptr;
            return(TRUE);
        }
    }
#endif

    /* get the displayed bar menu */
    if (adp_form_ptr = GRgetbarmenu())
    {
        /* make sure the gadgets are there */
        if (GRverify_adp_gadgets(adp_form_ptr))
            *form_ptr = adp_form_ptr;
        else
            sts = FALSE;
    }
    else
    {
        /* no bar menu around */
        sts = FALSE;
    }

    return(sts);
}

/*
Name
        GRdelete_adp

Description
        This function is used to delete the adp form.  It is a holdover from
        the old days when the adp gadgets were on their own form.  Since they
        are now on the bar menu, this function is reduced to a noop.
*/

IGRint GRdelete_adp()
{
#if 0
    if (adp_form_ptr = GRgetbarmenu())
    {
        FIf_delete(adp_form_ptr);
        adp_form_ptr = NULL;
    }
#endif
    return(TRUE);
}
