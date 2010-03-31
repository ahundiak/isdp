/*
Name
        ECbarmenu

Description
        This command object is used to swap the bar menus from modeling
        to detailing.  It is anticipated that I/FORMS changes will
        eventually make this command obsolete.

History
        mrm     09/17/91    creation (from ppl commands)
        pp      10/01/91    Turning the reference plane lock to on
                            when the design bar menu is poked
        mrm     01/02/92    Add logic to swap pocket menus
        mrm     01/03/92    Add command to swap to DRAFT menu
        scw     02/02/92    Added reference plane lock checking
        mrm     02/29/92    Leap Day - Oh boy!! Ignore help message, since
                            there is no help for these commands
        scw     03/27/92    Added check for batch mode in execute method
        mrm     07/23/92    Added swap notification
*/

class implementation ECbarmenu;

#include "DIdef.h"
#include "FI.h"
#include "MS.h"
#include "MI.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#define MODEL 1

#define SWITCH_TO_DESIGN_MENU   0
#define SWITCH_TO_DETAIL_MENU   1
#define SWITCH_TO_DRAFT_MENU    2

extern int GRmenu_button_intercept_routine();
extern void GRadp_intercept();

method help()
{
    return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
    int sts;
    char *bar_menu, *pocket_menu;
    Form fp;

    /* Check to see if we are running in BATCH mode .      */
    /* If so we want to skip out of this command. 03/27/92 */
    if (ex$is_batch())     
    {
        goto finish;
    }

#if 0
    /* set the intercept routine for the panel menu */
    if (FI_get_form_by_name("PANEL_MENU", &fp) == FI_SUCCESS)
    {
        FIf_set_button_intercept_routine(fp, GRmenu_button_intercept_routine);
    }
#endif

    /* decide which menu to switch to */
    if (me->mytype == SWITCH_TO_DESIGN_MENU)
    {
        bar_menu = "BAR_MENU";
        pocket_menu = "POCKET_MENU";
    }
    else if (me->mytype == SWITCH_TO_DETAIL_MENU)
    {
        bar_menu = "BAR_DETAIL";
        pocket_menu = "POCKET_DETAIL";
    }
    else if (me->mytype == SWITCH_TO_DRAFT_MENU)
    {
        bar_menu = "BAR_MENU";
        pocket_menu = "POCKET_MENU";
    }
    else
    {
        goto finish;
    }

    /* check whether the correct bar is already active */
    if (FI_get_form_by_name(bar_menu, &fp) == FI_SUCCESS)
    {
        FIf_is_displayed(fp, &sts);
        if (sts) goto finish;   /* form is already displayed */
    }

    /* swap in the proper bar menu */
    sts = MS_swap_menu(BAR_MENU, bar_menu);
    if (sts == MS_SUCCESS)
    {
        /* set the interception routine */
        FI_get_form_by_name(bar_menu, &fp);
        FIf_set_button_intercept_routine(fp, GRadp_intercept);

        /* swap in the proper pocket menu */
        sts = MS_swap_menu(POCKET_MENU, pocket_menu);
        if (sts != MS_SUCCESS)
        {
            UI_status("Failed to swap pocket menu");
        }

#if MODEL
        /* turn off reference plane lock for detailing */
        if (me->mytype == SWITCH_TO_DETAIL_MENU)
        {
            IGRint     mode;
            IGRboolean dpb_state;

            ems$ref_plane_lock( msg = &sts,
                                options = EMS_REF_PLANE_LOCK_INQ,
                                mode = &mode );

            if( mode == EMS_REF_PLANE_LOCK_ON )
               dpb_state = TRUE;
            else
               dpb_state = FALSE;
           
            gr$put_mrp_lock( buffer = &dpb_state );

            ems$ref_plane_lock( msg = &sts,
                                options = EMS_REF_PLANE_LOCK_OFF |
                                          EMS_REF_PLANE_LOCK_SET );
        }
        else
        {
            IGRuint options;
            IGRboolean   dpb_state;

            gr$get_mrp_lock( buffer = &dpb_state );

            if( dpb_state == TRUE )
               options = EMS_REF_PLANE_LOCK_ON | EMS_REF_PLANE_LOCK_SET;
            else
               options = EMS_REF_PLANE_LOCK_OFF | EMS_REF_PLANE_LOCK_SET;

            ems$ref_plane_lock( msg = &sts,
                                options = options );
        }
#endif

        /* make sure the assoc button is correctly displayed */
        GRupdate_assoc_button();

        /* notify any interested parties about the menu swap */
        GRswap_menu_notification(bar_menu, fp);
    }
    else
    {
        UI_status("Failed to swap bar menu");
    }

finish:

    *response = TERMINATE;
    return(OM_S_SUCCESS);
}

end implementation ECbarmenu;
