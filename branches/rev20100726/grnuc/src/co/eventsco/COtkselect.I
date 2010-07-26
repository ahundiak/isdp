 /* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COtkselect

Description
        This is the select function for the tentative keypoint snap
        command.  It places a crosshair on the nearest keypoint on the
        selected element, and allows the user to either accept or reject
        that element.

History
        mrm     02/13/87    creation
                09/17/87    pulled most of this function out of the command
                02/19/88    modified for COB
                06/02/89    always return TRUE to prevent action handler
                            from croaking
        scw     07/13/92    ansi conversion
	Sudha 	06/17/94    Purify fix - added error check after dp$inq_set_gragad()
			    to continue.

*/

class implementation COevgen;

#include "coimport.h"
#include "lcdef.h"
#include "lcmacros.h"
#include "msdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

from GRvg import GRkeypoint;

/* KLUDGE: global to store the window id */
struct GRid GRkeypoint_window_grid;

IGRlong COtkselect (lc_msg, lc_args, locate_event)

IGRlong                 *lc_msg;
struct LC_select_args   *lc_args;
struct GRevent          *locate_event;

{
    IGRchar             object_info[64];    /* object's type, layer, ... */
    IGRint              need_boreline;      /* flag */
    IGRlong             size;               /* sizeof (whatever) */
    IGRlong             sts, msg;           /* return codes */
    IGRlong             mode;               /* display mode */
    IGRlong             which_error;        /* in window param arg list */
    IGRdouble           points[6];          /* points defining boreline */
    IGRpoint            keypoint;           /* on element */
    IGRmatrix           view_matrix;        /* world-to-view rotation matrix */
    struct GRlc_info   *current_object;     /* in locate stack */
    struct EX_button    locate_button;      /* button id'ing element */
    struct IGRline      boreline;           /* normal to view of location */
    struct var_list     var_list[2];        /* for gragad inquiry */

    *lc_msg = LC_NO_OBJ_LOCATED;
    locate_button = locate_event->event.button;
    need_boreline = TRUE;
    mode = GRhd;

    while ((*lc_msg == LC_NO_OBJ_LOCATED) && (lc_args->stack->num_entries))
    {
        current_object =
                      &lc_args->stack->entry [lc_args->stack->num_entries - 1];
#ifdef DEBUG
        {
            int i;
            IGRdouble *mx_ptr;

            printf ("tentative keypoint snap:\n");
            printf ("\tlocated object = ");
            printf ("%d, ", current_object->located_obj.osnum);
            printf ("%d\n", current_object->located_obj.objid);
            printf ("\tlocated object's module = ");
            printf ("%d, ", current_object->module_info.md_id.osnum);
            printf ("%d\n", current_object->module_info.md_id.objid);
            printf ("\tlocated object's module's matrix type = ");
            printf ("%d\n", current_object->module_info.md_env.matrix_type);
            printf ("\tlocated object's module's matrix = \n");
            mx_ptr = current_object->module_info.md_env.matrix;
            for (i = 0; i < 16; i += 4)
                printf ("\t\t%15.8f %15.8f %15.8f %15.8f\n",
                         mx_ptr[i], mx_ptr[i+1], mx_ptr[i+2], mx_ptr[i+3]);
        }
#endif

        if (need_boreline)
        {
            /*
             *  construct a boreline to use to project to the keypoint
             */

            var_list[0].var = WLD_TO_VIEW;
            var_list[0].var_ptr = (IGRchar *)view_matrix;
            var_list[0].num_bytes = sizeof (view_matrix);
            var_list[0].bytes_returned = &size;
            var_list[1].var = END_PARAM;
   
            sts = dp$inq_set_gragad (msg = &msg,
                                   osnum = lc_args->stack->window.osnum,
                                   gragad_objid = lc_args->stack->window.objid,
                                   which_error = &which_error,
                                   var_list = var_list);

	    /* Purify fix - check the return values */

            if (!(sts & msg & 1))
            {
               lc_args->stack->num_entries--;
               continue;
            }

            points[0] = locate_button.x;
            points[1] = locate_button.y;
            points[2] = locate_button.z;
            points[3] = locate_button.x + view_matrix[8];
            points[4] = locate_button.y + view_matrix[9];
            points[5] = locate_button.z + view_matrix[10];
            boreline.point1 = points;
            boreline.point2 = &points[3];
            need_boreline = FALSE;
        }

	/* KLUDGE: store the window id in a global (should be added in
	           the argument list of keypoint (HGB - 04/08/91)
	*/
	GRkeypoint_window_grid = lc_args->stack->window;


        /*
         *  get the keypoint
         */

        sts = om$send (msg = message GRvg.GRkeypoint
                            (&msg,
                             &current_object->module_info.md_env.matrix_type,
                             current_object->module_info.md_env.matrix,
                             &boreline, keypoint, &current_object->geom_parms),
                       senderid = NULL_OBJID,
                       targetid = current_object->located_obj.objid,
                       targetos = current_object->located_obj.osnum);

        if (!(sts & msg & 1))
        {
            lc_args->stack->num_entries--;
#ifdef DEBUG
            printf ("COtenkeypt: GRvg.GRkeypoint failed\n");
            printf ("msg = %#x\n", msg);
            om$report_error (sts = sts);
#endif
            continue;
        }

#ifdef DEBUG
        printf ("\tkeypoint = %g, %g, %g\n", keypoint[0], keypoint[1], keypoint[2]);
#endif

        /*
         *  display the object type, the keypoint and its coordinates;
         *  also store the keypoint in the dpb for precision keyins
         */

        LCget_info (current_object->located_obj.objid,
                    current_object->located_obj.osnum, object_info);
        ex$message (in_buff = object_info, field = ERROR_FIELD);
        locate_button.x = keypoint[0];
        locate_button.y = keypoint[1];
        locate_button.z = keypoint[2];
        size = sizeof (struct EX_button);
        DPdrawcross (&msg, &locate_button);
        COdiscoords (&msg, &locate_button,
                     &current_object->module_info, KEYIN_FIELD, LEFT_JUS);
        gr$put_last_point (msg = &msg, sizbuf = &size,
                           buffer = &locate_button);

        /*
         *  highlight the object
         */

        sts = lc$display (msg = &msg,
                matrix_type = &current_object->module_info.md_env.matrix_type,
                matrix = current_object->module_info.md_env.matrix,
                highlight_mode = &mode,
                window_id = &lc_args->stack->window,
                objid = current_object->located_obj.objid,
                osnum = current_object->located_obj.osnum,
                element = 1,
                window = 0,
                mod_id = &lc_args->stack->module,
                ext_o_element = 1);

        if (!(sts & msg & 1))
        {
            lc_args->stack->num_entries--;
#ifdef DEBUG
            printf ("COtenkeypt: lc$display failed\n");
            printf ("msg = %#x\n", msg);
            om$report_error (sts = sts);
#endif
            continue;
        }

        /*
         *  wait for user input
         */

        co$getevent (msg = &msg,
                     event_mask = lc_args->eventmask | GRm_RJT_MOVEON,
                     prompt = lc_args->acc_prompt,
                     response = lc_args->response,
                     response_data = lc_args->response_data,
                     event = lc_args->accept_event);

/*      ex$message (msgnumb = EX_); */
        UI_echo ("");   /* clear coordinates */


        /*
         *  unhighlight the element
         */

        sts = dp$erase_hilite (msg = &msg,
                               objid = lc_args->stack->module.objid,
                               osnum = lc_args->stack->module.osnum);

        /*
         *  check whether to continue
         */

        switch (lc_args->accept_event->response)
        {
            case EX_DATA:

                /*
                 *  object accepted
                 */

                if ((lc_args->accept_event->subtype != GRst_PREC_WLD) &&
                    (lc_args->accept_event->subtype != GRst_DELTA_WLD) &&
                    (lc_args->accept_event->subtype != GRst_DELTA_VIEW) &&
                    (lc_args->accept_event->subtype != GRst_DIST_DIR))
                {
                    lc_args->accept_event->event.button.x = keypoint[0];
                    lc_args->accept_event->event.button.y = keypoint[1];
                    lc_args->accept_event->event.button.z = keypoint[2];
                    lc_args->accept_event->located_object[0] = *current_object;
                    lc_args->accept_event->num_id = 1;
                    lc_args->accept_event->subtype = GRst_KEYPOINT;
                }
                *lc_msg = LC_OBJ_LOCATED;
                break;

            case EX_RJT_MOVEON:

                /*
                 *  decrement the stack pointer to process the 
                 *  next entry
                 */

                lc_args->stack->num_entries--;
                break;

            case GR_UNKNOWN_TYPE:

            default:

                /*
                 *  return control
                 */

                *lc_msg = LC_UNKNOWN_TYPE;
                break;
        }
    }

/*
    return (sts & msg & 1);
*/
    return (1);
}

end implementation COevgen;
