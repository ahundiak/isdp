/*
Name
        GRadp.wakeup

Description
        This routine constructs, initializes and displays an active drawing 
        parameters form when initially creating an object space.

History
        WBC  11/30/87 : Design date.
        WBC  11/30/87 : Creation date.
        dhm  07/13/92 : ANSI conversion.
        mrm  07/24/92   Changed to use the menu bar rather than a separate form
        mrm  09/08/92   Always update form on wakeup
*/

class implementation   GRadp;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "gr.h"
#include "OMerrordef.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "adpdef.h"
#include "FI.h"

extern void     GRadp_swap_menu_callback();
extern void     GRadp_intercept();            /* intercepts buttons on form */
extern IGRint   GRcreate_adp();
extern IGRint   GRcreate_setadp();
extern IGRint   GRdisplay_setadp_subforms();
extern IGRint   GRupdate_adp();
extern IGRint   GRupdate_setadp();
extern IGRint   GRupdate_setadp_subforms();
extern IGRint   EX_clear_command_on_save();   /* TRUE when journaling is on */

%safe
static int setadp_displayed = 0;
static int swap_callback_set = 0;
%endsafe

method wake_up()
{
    Form                   form_ptr;         /* pointer to the ADP form      */
    IGRlong                msg;              /* return code of modules       */
    IGRlong                buffersize;       /* buffersize for the dpb       */
    IGRlong                nobytes;
    IGRint                 error_index;
    IGRint                 temp_wakeup = 0;
    IGRint                 index;
    IGRshort               active_layer;
    IGRdouble              active_angle;
    struct  EX_var_list    var_list[9];
    struct GRdpb_scale     active_scale;
    struct  IGRdisplay     active_display;

    /*
     * If a visible object space is being brought up in interactive mode,
     * update the active drawing parameters menu form if it is displayed.
     * Initialize and display this form using the active drawing
     * parameters of the object space being brought up.  If an invisible
     * object space is being brought up, do nothing.
     */

    if (!ex$is_invis(mod_osnum = OM_Gw_current_OS) && !ex$is_batch())
    {
        /*
         * if the Active Drawing Parameters form has not been constructed,
         * construct and initialize it
         */

        if (GRcreate_adp(&msg,TRUE,&form_ptr))
        {
#if 0
            /* This code obsoleted by placing gadgets on the menu bar */

	    /* if this is X, always want to set temp_wakeup to 0 so that the
	     * form is initialized because it was deleted during sleep
	     */
#ifdef X11
	    temp_wakeup = 0;
#else
	    temp_wakeup = (ex$is_temp_wakeup()) ? 1 : 0;
#endif
#else
            /*
                Always set temp_wakeup to FALSE, since the ADP gadgets are now
                on the menu bar, which is deleted/recreated in both the X and
                Environ V versions.
            */
            temp_wakeup = 0;
#endif
            if (! (temp_wakeup))
            {
#if 0
                /* This code obsoleted by placing gadgets on the menu bar */
                /*
                 * intercept buttons to the form; if a single click of the
                 * middle button is received, call a function to initialize and
                 * display the Set Active Drawing Parameters form
                 */

                FIf_set_button_intercept_routine(form_ptr,GRadp_intercept);

#endif

                /*
                 * the following function is called to find the height and
                 * width of the form - these are saved as static variables to
                 * use in determining if the intercepted button should bring
                 * up the Set Active Drawing Parameters form or the window
                 * control box
                 */

                GRget_adp_size(form_ptr);

#if 0
                /* 
                    This code is no longer necessary.  The adp gadgets are
                    refreshed from GRcustomize_menus.  --Mike 3/12/93
                */

                gr$get_active_level(buffer = &active_layer);
                gr$get_active_display(buffer = &active_display);

                var_list[0].var = ADP_LAYER_NUM;
                var_list[0].var_value = (IGRchar *)&active_layer;
                var_list[1].var = ADP_COLOR_NUM;
                var_list[1].var_value = (IGRchar *)&active_display.color;
                var_list[2].var = ADP_WEIGHT_NUM;
                var_list[2].var_value = (IGRchar *)&active_display.weight;
                var_list[3].var = ADP_STYLE_NUM;
                var_list[3].var_value = (IGRchar *)&active_display.style;
                var_list[4].var = ADP_END_LIST;

                /*
                 * initialize the gadgets on the form
                 */

                GRupdate_adp(&msg,form_ptr,var_list,&error_index);

                /* arrange to be notified when the bar menu is swapped */
                if (!swap_callback_set)
                {
                    GRregister_swap_menu_callback(GRadp_swap_menu_callback);
                    swap_callback_set = 1;
                }

#endif          /* end 3/12/93 mods */

            }
#if 0
            /* This code obsoleted by placing gadgets on the menu bar */
            FIf_display(form_ptr);
#endif
        }

        /*
         * if the Set Active Drawings Parameter form was being displayed
         * and this is not a temp wakeup (save), update the form and any
         * subform that was displayed and redisplay the forms
         */

        if ((setadp_displayed) &&
            (GRcreate_setadp(&msg,TRUE,&form_ptr)))
        {        
            if (!temp_wakeup)
            {
                buffersize = sizeof(active_angle);
                gr$get_active_angle(msg = &msg,
                                    sizbuf = &buffersize,
                                    buffer = &active_angle,
                                    nret = &nobytes);

                buffersize = sizeof(active_scale);
                gr$get_active_scale(msg = &msg,
                                    sizbuf = &buffersize,
                                    buffer = &active_scale,
                                    nret = &nobytes);

                var_list[4].var = ADP_LAYER_NAME;
                var_list[4].var_value = (IGRchar *)&active_layer;
                var_list[5].var = ADP_COLOR_NAME;
                var_list[5].var_value = (IGRchar *)&active_display.color;
                var_list[6].var = ADP_ANGLE_NUM;
                var_list[6].var_value = (IGRchar *)&active_angle;
                var_list[7].var = ADP_SCALE_NUM;
                var_list[7].var_value = (IGRchar *)&active_scale;
                var_list[8].var = ADP_END_LIST;

                GRupdate_setadp(&msg,form_ptr,var_list,&index);

                /*
                 * if there is an active Set Drawing Parameters
                 * subform, update it
                 */

                GRupdate_setadp_subforms(&active_display);

                /*
                 * display the form and subform
                 */
                FIf_display(form_ptr);
                GRdisplay_setadp_subforms(TRUE);
            }
            else if (EX_clear_command_on_save())
            {
                /*
                 * journalling is on; need to redisplay the subforms since
                 * they were erased during the GRadp.sleep method
                 */
                 FIf_display(form_ptr);
                GRdisplay_setadp_subforms(TRUE);
            }
        }
    }
    return(OM_S_SUCCESS);
}


/*
Name
        GRadp.sleep

Description
        This method handles cleanup during saves, retrieves, etc.

History
        wbc     idunno      creation
        mrm     02/03/93    delete subforms during sleep, added header
        scw     08/09/94    clarified sleep method
*/

method global_class.sleep (IGRint sleep_type)
{
    Form             form_ptr;  /* pointer to the ADP form */
    IGRlong          msg;

    /*
     * If currently in a visible object space and this is a real sleep (not a
     * save) or journalling is on, need to erase the active drawing parameters
     * forms.  Erasing the forms during a real sleep is done since the values
     * on the forms have no meaning once the current module is closed.  Erasing
     * the forms while journalling is on is done because journalling would have
     * a problem with the forms' window numbers if they weren't erased and then
     * redisplayed when the next module was sent a wake_up.
     */

    if ((!ex$is_invis(mod_osnum = OM_Gw_current_OS)) && !ex$is_batch() &&
        ((sleep_type == EX_REAL_SLEEP) || (EX_clear_command_on_save())))
    {
        if (GRcreate_setadp(&msg,FALSE,&form_ptr))
        {
 	    FIf_is_displayed(form_ptr,&setadp_displayed);
#ifdef X11
            GRdisplay_setadp_subforms(FALSE);
            GRdelete_setadp();          /* necessary for journaling */
            GRdelete_adp_subforms();    /* necessary for journaling */
#else
            if (setadp_displayed)
            {
                GRdisplay_setadp_subforms(FALSE);
                FIf_erase(form_ptr);
            }
#endif
        }

#if 0
        /* This code obsoleted by placing gadgets on the menu bar */
        if (GRcreate_adp(&msg,FALSE,&form_ptr))
        {
#ifdef X11
            GRdelete_adp();   /* necessary for journalling */
#else
            FIf_erase(form_ptr);
#endif
        }
#endif
    }
    return(OM_S_SUCCESS);
}

end implementation GRadp;
