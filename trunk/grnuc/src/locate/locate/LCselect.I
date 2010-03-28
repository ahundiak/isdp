/*
Name
        LCselect

Description
        This routine is called from LCcselect.  It controls the
        accept/reject cycle of the locate filter.  This routine
        handles both element and segment highlight.
            
History
        rc      07/20/87    Started documentation
        mrm     09/07/89    added nbytes, value_type, and scale_flag args
        mrm     10/03/89    display prompt before highlight
        mrm     11/14/89    combined with LCpselect (segment highlight)
        mrm     12/07/89    always highlight in all windows, since the user
                            can stop the highlight with any action
        mrm     09/12/91    restore ability to highlight in a single
                            window (mainly for symbology overrides)
        scw     07/13/92    ansi conversion
        mrm     11/17/92    restored original accept prompt display (which was
                            removed by scw) to ensure that it gets there
                            before locate highlight and dynamics, and removed
                            the prompt from the getevent call to prevent
                            double prompt display
        mrm     05/19/93    fill in the locate event completely before calling
                            the dynamics function
        mrm     08/31/93    added smart sketch
        mrm     10/05/93    pulled smart sketch because of reference file
                            problems (pulled version 240.3 from RCS)
*/

class implementation Root;

#define SUCCESS         1
#define NO_ELEMENTS     2
#define LOOP            3
#define RETCONTROL      4

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "dpdef.h"
#include "dp.h"
#include "exdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "lcdef.h"
#include "lc.h"
#include "msdef.h"
#include "dpmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "execmsg.h"
#include "lcmacros.h"

from GRgraphics import GRdisplay, GRlocaldp;

extern struct GRevent GRlocate_event;

#argsused
IGRint LCselect (msg, mask, size, display_flag, is_bore, response, 
                 response_data, accept_event, acc_event1, obj_hilited, stack,
                 dyn, acc_prompt, unhilite_mode, hilite_mode, acc_key,
                 nbytes, value_type, scale_flag)

IGRlong                 *msg;
IGRlong                 *mask;
IGRint                  *size;
IGRlong                 *display_flag;
IGRboolean              *is_bore;
struct  GRevent         *accept_event;
struct  GRevent         *acc_event1;
IGRint                  *response;
IGRchar                 *response_data;
IGRchar                 *obj_hilited;
struct GRlc_stack       *stack;
struct GRlc_dynamics    *dyn;        
IGRchar			*acc_prompt;                                  
enum   GRdpmode         unhilite_mode, hilite_mode;
IGRlong                 acc_key;
IGRint                  *nbytes;
IGRchar                 *value_type;
IGRint                  scale_flag;
{
    IGRchar info[128];
    IGRint ext_o_element, window;
    IGRint element, flag;
    IGRlong sts, ret_code, exit_code, new_mask;
    struct GRparms *parms;
    struct GRid display_id; 
    struct GRlc_info *entry;
    struct GRmdenv_info *entry_md;
    enum GRdpmode display_mode[2];

    *msg = LC_OBJ_LOCATED;
    ret_code = 0;
    exit_code = LOOP;

    /* Check whether to highlight in a single window or all windows */

    if (*display_flag & ONE_WINDOW)
    {
        display_id = stack->window;
        window = TRUE;
    }
    else
    {
        display_id = stack->module;
        window = FALSE;
    }

    /*
     *	While there are elements to process stay in the loop.  The stack
     *	is of default size of one, but it may be expanded to any number
     *	by an application.
     */

    while ((exit_code == LOOP) && (stack->num_entries))
    {
        /*
         *  use a pointer into the stack for fewer assembler instructions
         */

        entry = &stack->entry[stack->num_entries - 1];
        entry_md = &entry->module_info.md_env;

        /*
         *  Display the element type and layer
         */

        LCget_info (entry->located_obj.objid, entry->located_obj.osnum, info);
        ex$message (msgnumb = LC_NO_MSG, in_buff = info, field = ERROR_FIELD);

        // Display the accept prompt, unless an event is already waiting
        if (!EX_peek_event_queue(NULL))
            ex$message(msgnumb = acc_key,
                       in_buff = acc_prompt, 
                       field = PROMPT_FIELD,
                       justification = RIGHT_JUS);

        /*
         *  Determine highlight mode
         */

	if (*display_flag & LC_HALF_HIGHLIGHT) 
	    display_mode[0] = display_mode[1] = GRhhd;
        else 
	    display_mode[0] = display_mode[1] = hilite_mode;

        /*
         *  Determine additional display info
         */

        if (*display_flag & ELEM_HILIGHT)
        {
            element = 1;
            parms = NULL;
            ext_o_element = 1;
        }
        else /* segment highlight */
        {
            element = 0;
            parms = &entry->geom_parms;
            ext_o_element = 0;
        }

        /*
         *  Highlight the object
         */

        sts = lc$display (msg = msg,
                          matrix_type = &entry_md->matrix_type,
                          matrix = entry_md->matrix,
                          highlight_mode = display_mode,
                          window_id = &stack->window,
                          objid = entry->located_obj.objid,
                          osnum = entry->located_obj.osnum,
                          mod_id = &stack->module,
                          element = element,
                          window = window,
                          parms = parms,
                          ext_o_element = &ext_o_element);

        if (!(sts & 1)) 
        {
            *msg = LC_NO_OBJ_LOCATED;
            return (0);
        }

        *obj_hilited = TRUE;

        /*
         *  Call dynamics function if the pointer is specified
         */  

        if (dyn) 
        {
            dyn->GRlc_event = GRlocate_event;
            dyn->GRlc_event.located_object[0] = *entry;
            dyn->GRlc_object = entry->located_obj;
            (*dyn->GRlc_dyn) (&dyn->GRlc_object,
                              &dyn->GRlc_event, 
                              dyn->add_info);
        }        

        /*
         *  Add reset and backup to the valid responses in the mask to
         *  co$getevent.  These two responses will not accept the element
         *  because they are directly interpreted by this function.
         */

        new_mask = *mask | GRm_RESET | GRm_BACK_UP;

        /*
         *  Modify the cursor if the command requests it.  This is usually
         *  for commands that do a chain locate.
         */

        if (*display_flag & LC_ACCEPT_CURSOR) 
        {
            LCdef_cursor ();
        }

        LCmark_locate (LC_Other_Point);

        /*
            Wait for the user's response - note that no prompt is specified in
            this call, since it was already displayed prior to highlight and
            dynamics.
        */

        co$getevent (msg = &sts,
                     event_mask = new_mask,
                     msgnum = acc_key,
                     response = response,
                     response_data = response_data,
                     nbytes = nbytes,
                     value_type = value_type,
                     scale_flag = scale_flag,
                     event = accept_event);

        /*
         *  Restore the cursor if necessary.
         */

        if (*display_flag & LC_ACCEPT_CURSOR) 
        {
            IGRboolean aflag;
            aflag = pwIsActivationOn();

            if (aflag)
            {
               /** Activate the cursor **/
               rfDefineCursor();
            }
            else
            {
               LCrestore_cursor();    
            } 
        }

        /*
         *  Check the user's response
         */

        switch (accept_event->response) 
        {
            case EX_BACK_UP:

                /*
                 *  Leave the accept/reject cycle, set up the return codes
                 *  to exit the Rtree search, and return to the main filter.
                 *  The filter may then reenter the locate cycle or return
		 *  to the caller, depending on the original locate request.
                 */

                stack->num_entries = 0;
                *msg = LC_BACKUP;
                exit_code = RETCONTROL;
                ret_code = 1;
                break;

            case EX_RJT_MOVEON:

                /*
                 *  The current element is rejected; continue to process
                 *  the remaining elements in the stack.  If there are no
                 *  elements left in the stack, return control to the
                 *  main locate filter to either continue the search through
                 *  the Rtree or return control to the caller of the filter.
                 */

                if (!--stack->num_entries) 
                {
                    exit_code = NO_ELEMENTS;
                    *msg = LC_RELOCATE;
                    ret_code = 1;
                }
                break;

            case GR_UNKNOWN_TYPE:

                /*
                 *  Unknown input type; return control to the caller
                 */

                *msg = LC_UNKNOWN_TYPE;
                exit_code = RETCONTROL;
                ret_code = 1;
                break;

            default:

                /*
                 *  Accept the object with any recognized input type
                 */

                if (accept_event->response == DATA) 
                {
                    /*
                     *  Check to see if projection of accept point is
                     *  requested.  If the third bit is not set in the
                     *  display flag project the accept point onto the
                     *  element using a point or boreline project
                     *  depending on the type of locate that is occuring
                     */

                    if (!(*display_flag & NO_PROJ_ACCEPT_POINT)) 
                    {
                        if (*display_flag & ELEM_HILIGHT)
                        {
                            flag = (*is_bore) ? LC_LNPROJECT : LC_PTPROJECT;
                        }
                        else /* segment highlight */
                        {
                            flag = LC_APPARENT;
                        }

                        if (!LCget_parms (accept_event->event.button.x,
                                          accept_event->event.button.y,
                                          accept_event->event.button.z, flag,
                                          entry->located_obj.objid,
                                          entry->located_obj.osnum,
                                          accept_event->event.button.objid,
                                          accept_event->event.button.osnum,
                                          entry->proj_pnt, &entry->geom_parms,
                                          entry_md->matrix_type, 
                                          entry_md->matrix))
                        {
                            *msg = LC_NO_OBJ_LOCATED;
                            ret_code = 0;
                            goto WRAP;
                        }
                    }
                }

                if (*display_flag & ELEM_HILIGHT)
                {
                    if (unhilite_mode != GRhd)
                    {
                        /*
                         *  Return the object in the requested display mode
                         */

                        om$send (msg = message GRgraphics.GRdisplay
                                      (&sts, &entry_md->matrix_type,
                                       entry_md->matrix,
                                       &unhilite_mode, &display_id),
                                 senderid = NULL_OBJID,
                                 targetid = entry->located_obj.objid,
                                 targetos = entry->located_obj.osnum);
                    }
                }
                else /* segment highlight */
                {
                    /*
                     *  Erase the element extensions, and, if specified,
                     *  leave the element in the requested unhighlight mode
                     */

                    if (unhilite_mode != GRhd) 
                    {
                        display_mode[0] = unhilite_mode;
                        display_mode[1] = GRhe;
                        ext_o_element = 0;
                    }
                    else
                    {
                        display_mode[0] = GRhe;
                        ext_o_element = 1;
                    }

                    /*
                     *  Dehighlight the object
                     */

                    sts = lc$display (msg = msg,
                                      matrix_type = &entry_md->matrix_type,
                                      matrix = entry_md->matrix,
                                      highlight_mode = display_mode,
                                      window_id = &stack->window,
                                      objid = entry->located_obj.objid,
                                      osnum = entry->located_obj.osnum,
                                      mod_id = &stack->module,
                                      element = element,
                                      window = window,
                                      parms = parms,
                                      ext_o_element = &ext_o_element);

                }

                /*
                 *  Set up the return codes to indicate that the object
                 *  was accepted.  Note that acc_event1 is being filled in
                 *  rather than acc_event.
                 */

                exit_code = SUCCESS;
                ret_code = 1;
                *msg = LC_OBJ_LOCATED;
                acc_event1->located_object[0] = *entry;
                acc_event1->num_id = 1;
                stack->num_entries = 0;
                break;
        } /* end switch */

        /*
         *  Erase the highlighted object, if necessary
         */

        if (*obj_hilited && exit_code != SUCCESS)
        {
            if (*display_flag & LC_ERASE_LOC_ELEMENT)
            {
                if (*display_flag & ELEM_HILIGHT)
                {
                    hilite_mode = GRhe;

                    om$send (msg = message GRgraphics.GRdisplay
                                  (&sts, &entry_md->matrix_type,
                                   entry_md->matrix,
                                   &hilite_mode, &display_id),
                             senderid = NULL_OBJID,
                             targetid = entry->located_obj.objid,
                             targetos = entry->located_obj.osnum);
                }
                else /* segment highlight */
                {
                    display_mode[0] = GRhe;
                    display_mode[1] = GRhe;
                    ext_o_element = 0;

                    /*
                     *  Dehighlight the object
                     */

                    sts = lc$display (msg = &sts,
                                      matrix_type = &entry_md->matrix_type,
                                      matrix = entry_md->matrix,
                                      highlight_mode = display_mode,
                                      window_id = &stack->window,
                                      objid = entry->located_obj.objid,
                                      osnum = entry->located_obj.osnum,
                                      mod_id = &stack->module,
                                      element = element,
                                      window = window,
                                      parms = parms,
                                      ext_o_element = &ext_o_element);
                }
            }
            else 
            {
                dp$erase_hilite (msg = &sts,
                                 objid = stack->module.objid,
                                 osnum = stack->module.osnum); 
            }

            *obj_hilited = FALSE;
        }
    }  /* end while */

    if (exit_code == RETCONTROL)
    {
        ex$message (msgnumb = EX_S_Clear);
    }

WRAP:

    return (ret_code);
}
end implementation Root;
