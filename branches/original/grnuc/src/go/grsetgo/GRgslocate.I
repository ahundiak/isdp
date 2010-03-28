/*
Name
        gr$gslocate

Description
        This locate filter is a super set of the locate filter provided 
        by the locate package.  This locate filter allows for the located
        object to be added to a graphics set.

        To use the results from a group event generate, a command must or in
        GRm_OBJID in the event masks used by this filter.  The GRm_OBJID is
        returned from the group event generator and if it is an allowable
        event type, it is accepted and returned to the command object.

        If the p_chanselect is supplied then a graphics set containing the
        locate object(s) will be connected to the channel.  This channel should
        be a many-to-many and unrestricted.

        If a group event generator is selected by the user, the results
        from the group generator are automatically accepted.  However,
        additional inputs are often needed.  These inputs may be gathered
        by specifing the number of additional inputs needed (num_inputs) and
        the prompts (input1_key, input1_prompt, input2_key, input2_prompt)
        and masks (input1_mask, input2_mask) for each of these inputs.

Synopsis
        See the locate document for the desciption of the first few dozen
        locate arguments.  Note that locate_event is the same as event3, that 
        eventsize is passed by value not by address, and that regex default
        is 1 instead of 0.

        IGRint         *locate_state        Instance variable containting the 
                                            current state of the locate filter.
        IGRint          num_inputs          The number of inputs to be returned
                                            if the first input was a specified
                                            object. (Excluding the first
                                            point).
        IGRlong         input1_mask         Input mask for first event, if 
                                            specified object.
        IGRlong         input2_mask         Input mask for second event, if 
                                            specified object.
        IGRchar        *input1_prompt       Prompt for input event 1.
        IGRlong         input1_key          The message key prompt for input
                                            event 1.
        IGRchar        *input2_prompt       Prompt for input event 2.
        IGRlong         input2_key          The message key prompt for input
                                            event 2.
        GRobjid         senderid            Object id of the calling object.
        GRspacenum      senderos            OS of the calling object.
        OM_p_CHANSELECT chansel             Channel select of calling object
                                            where the save set is connected.

Notes
        The num_inputs argument is used in conjunction with the EX_OBJID
        (SPECIFIED_OBJ) event.  If a SPECIFIED_OBJ is located then:
        num_inputs -   0  Returns the SPECIFIED_OBJ event in the locate_event.
                   -   1  Returns the SPECIFIED_OBJ event in the locate_event.
                          Returns input 1 event in event 2.
                   -   2  Returns the SPECIFIED_OBJ event in the locate_event.
                          Returns input 1 event in event 1.
                          Returns input 2 event in event 2 .

        otherwise the following is returned:
            -   Returns input 1 event in event 1
                Returns input 2 event in event 2 
                Returns the located object in locate_event
   
Return Values
        status : 0 - OM error.
        status : 1 - OM success.
        msg    : 0 - Object not connected to graphics set.
        msg    : 1 - Object connected to graphics set.

History
        Gray Winn   11/02/86    Creation date.
        Gray Winn   06/04/86    Add call to post locate criteria.
        Gray Winn   04/18/88    Add arguments for hilight mode
        mrm         05/22/89    add scale_flag and value_typeX arguments
        msm         07/10/92    ANSI-C conversion.
*/

class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "grgsmacros.h"
#include "OMerrordef.h"
#include "exdef.h"
#include "lcmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exmacros.h"

/* 
 *  Internal command states
 */

#define LOCATE_STATE    0
#define INPUT1_STATE    1
#define INPUT2_STATE    2

/*
 *  Control looping condidtions
 */

#define SUCCESS     1      /* Continue looping                      */
#define RETCONTROL  2      /* Exit command and return(OM_S_SUCCESS) */

int GRgslocate (msg, event1, event2, locate_event, mask1, mask2, eventsize,
                display_flag, response, response_data, locate_prompt, 
                locate_key, acc_prompt, acc_key, relocate_prompt,
                relocate_key, attributes, stack, dyn, type, action_handler,
                action_args, rtree_classes, eligible_classes, select,
                select_args, stack_size, regex, locate_state, num_inputs,
                input1_mask, input2_mask, input1_prompt, input1_key,
                input2_prompt, input2_key, senderid, senderos, chansel,
                hilight_mode, unhilight_mode, nbytes1, nbytes2, range_handler,
                range_args, value_type1, value_type2, scale_flag) 

IGRlong *msg;                       /* return code */
struct GRevent *event1;             /* return from GRgetevent */
struct GRevent *event2;             /* return from GRgetevent */
struct GRevent *locate_event;       /* return from GRgetevent */
IGRlong mask1;                      /* mask to GRgetevent */
IGRlong mask2;                      /* mask to GRgetevent */
IGRint eventsize;                   /* size */
IGRlong display_flag;               /* display all (1) or one (0) window */
                                    /* in one window */
IGRint *response;                   /* response from GRgetevent */
IGRchar *response_data;             /*response data from GRgetevent */
IGRchar *locate_prompt;             /* locate prompt */
IGRlong locate_key;                 /* locate key */
IGRchar *acc_prompt;                /* accept/reject prompt */
IGRlong acc_key;                    /* accept/reject key */
IGRchar *relocate_prompt;           /* when an object is not located */
IGRlong relocate_key;               /* when an object is not located */
struct GRlc_locate *attributes;     /* contains class & level info */
struct GRlc_stack *stack;           /* pointer to "stack" */
struct GRlc_dynamics *dyn;          /* dynamics info */
IGRint type;
IGRint (*action_handler)();
IGRchar *action_args;
OM_p_CLASSLIST rtree_classes;
OM_p_CLASSLIST eligible_classes;    
IGRchar (*select)();
IGRchar *select_args;
IGRint stack_size;
IGRint regex;
IGRint *locate_state;
IGRint num_inputs;
IGRlong input1_mask;
IGRlong input2_mask;
IGRchar *input1_prompt;
IGRlong input1_key;
IGRchar *input2_prompt;
IGRlong input2_key;
GRobjid senderid;
GRspacenum senderos;
OM_p_CHANSELECT chansel;
IGRint hilight_mode;
IGRint unhilight_mode;
IGRint *nbytes1;
IGRint *nbytes2;
IGRint (*range_handler)();
IGRchar *range_args;
IGRint value_type1, value_type2;         
IGRint scale_flag;

{
    IGRlong         om_msg;
    IGRlong         ret_msg;
    IGRlong         status;
    IGRlong         temp_mask;
    IGRint          env_properties;
    IGRint          exit_code;
    IGRint          restart_flag;
    IGRint          state;
    IGRint          end_state;
    IGRint          event_size;
    IGRint          temp_nbytes;
    IGRint          ss_state;
    IGRchar         locate_buf[MS_MAX_MSG_LENGTH];
    IGRchar         acc_buf[MS_MAX_MSG_LENGTH];
    IGRchar         relocate_buf[MS_MAX_MSG_LENGTH];
    IGRchar         prompt_buf[MS_MAX_MSG_LENGTH], *prompt;
    struct GRevent  my_event1, my_event2;
    struct GRmd_env mod_env;
    struct GRid     owner_id;    

    *msg = MSSUCC;
    ret_msg = MSSUCC;
    status = OM_S_SUCCESS;
    om_msg = OM_S_SUCCESS;
    exit_code = SUCCESS;
    restart_flag = FALSE;
    event_size = eventsize;
    if (num_inputs == 0)
    {
        state = LOCATE_STATE;
        end_state = LOCATE_STATE;
    }
    else if (num_inputs == 1)
    {
        state = *locate_state;
        end_state = INPUT1_STATE;      
    }
    else 
    {
        state = *locate_state;
        end_state = INPUT2_STATE;
    }

    // Turn Smart Sketch off unconditionally
    ss_state = SSIsActive();
    SSDeactivate();

    while (exit_code == SUCCESS)
    {
        switch (state)
        {
            case LOCATE_STATE:

                /*
                 *  Post the locate criteria information.
                 */
         
                status = gr$gsput_locate_criteria (msg = msg,
                                        attributes = attributes,
                                        rtree_classes = rtree_classes,
                                        eligible_classes = eligible_classes);

                /*
                 *  Call locate filter.
                 */

                if (!locate_prompt)
                {
                    ex$message (msgnumb = locate_key, buff = locate_buf);
                }

                if (!acc_prompt)
                {
                    ex$message (msgnumb = acc_key, buff = acc_buf);
                }

                if (!relocate_prompt)
                {
                    ex$message (msgnumb = relocate_key, buff = relocate_buf);
                }

                status = lc$locate (rc = msg,
                                    event1 = &my_event1, 
                                    event2 = &my_event2,
                                    event3 = locate_event,
                                    nbytes1 = nbytes1,
                                    nbytes2 = nbytes2,
                                    mask1  = mask1,
                                    mask2  = mask2,
                                    eventsize = &event_size,
                                    display_flag = display_flag,
                                    hilight_mode    = hilight_mode,
                                    unhilight_mode  = unhilight_mode,
                                    response = response,
                                    response_data = response_data,
                                    locate_prompt = (!locate_prompt) ?
                                                    locate_buf : locate_prompt,
                                    acc_prompt = (!acc_prompt) ?
                                                 acc_buf : acc_prompt, 
                                    relocate_prompt = (!relocate_prompt) ?
                                                       relocate_buf :
                                                       relocate_prompt,
                                    attributes = attributes, 
                                    range_handler = range_handler,
                                    range_args = range_args,
                                    stack  = stack,
                                    dyn = dyn,
                                    act_handler = (action_handler) ? 
                                                  action_handler : NULL,
                                    act_args = (action_handler) ? 
                                               action_args : NULL,
                                    select = select,
                                    select_args = select_args,
                                    stack_size = stack_size,
                                    rtree_classes = rtree_classes,
                                    eligible_classes = eligible_classes,
                                    regex = regex,
                                    type = type,
                                    value_type1 = value_type1,
                                    value_type2 = value_type2,
                                    scale_flag = scale_flag);

                /*
                 *  Was an object located?
                 */

                if (status & *msg & 1)
                {
                    /*
                     *  Is the located object to be connected to the 
                     *  graphics set.
                     */
         
                    if (chansel != NULL)
                    {
                        /*
                         *  Add the located object to the graphics set.
                         */

                        env_properties = 0;
                        owner_id.objid = senderid;
                        owner_id.osnum = senderos;      
      
                        om_msg = GRgsadd_object (&ret_msg,
                               &locate_event->located_object[0].located_obj,
                               &locate_event->located_object[0].module_info,
                               &env_properties, &owner_id, chansel);
                    }
                }

                /* 
                 *  State transition
                 */

                if ((status & *msg & om_msg & ret_msg & 1) && 
                    (state != end_state) && 
                    (my_event1.response == EX_OBJID))
                {
                    *event1 = my_event1;
                    state = INPUT1_STATE;
                    if (locate_state) *locate_state = INPUT1_STATE;
                }
                else if ((status & *msg & om_msg & ret_msg & 1) &&
                         (my_event1.response == EX_OBJID))
                {
                    *event1 = my_event1;
                    *event2 = my_event1;
                    exit_code = RETCONTROL;
                }
                else
                {
                    /* 
                     *  If the first event was an GR_UNKNOWN_TYPE, MOVE_ON,
                     *  EX_RJT_MOVEON, EX_BACK_UP, EX_RESTART, EX_OBJID then 
                     *  replace event1 and event2 with the first event.  If 
                     *  not then overwrite event1 and event2.  It is necessary
                     *  to use the temporary events because most people send 
                     *  in the same event structure twice.   Note that RESET 
                     *  and EX_RJT_MOVEON are the same.         
                     */

                    if ( (status & 1) && (! (*msg & 1) ) && 
                        ((my_event1.response == GR_UNKNOWN_TYPE) ||
                         (my_event1.response == MOVE_ON)         ||
                         (my_event1.response == EX_RJT_MOVEON)   ||
                         (my_event1.response == EX_BACK_UP)      ||
                         (my_event1.response == EX_RESTART)      ||
			 (my_event1.response == EX_FORM_FINISHED)||
                         (my_event1.response == EX_OBJID) ) )
                    {
                        *event1 = my_event1;
                        *event2 = my_event1;
                    }
                    else
                    {
                        *event1 = my_event1;
                        *event2 = my_event2;
                    }
                    exit_code = RETCONTROL;
                }
                break;
      
            case INPUT1_STATE:

                /* get the user's response */

                if (input1_prompt)
                {
                    prompt = input1_prompt;
                }
                else
                {
                    ex$message (msgnumb = input1_key, buff = prompt_buf);
                    prompt = prompt_buf;
                }

                temp_mask = input1_mask | GRm_RESTART | GRm_RESET |
                    GRm_BACK_UP;

                om_msg = co$getevent (msg = &ret_msg,
                                      scale_flag = scale_flag,
                                      event_mask = temp_mask,
                                      prompt = prompt,
                                      response = response,
                                      response_data = response_data,
                                      event_size = eventsize,
                                      event = &my_event1,
                                      nbytes = &temp_nbytes);

                if (om_msg & ret_msg & 1)
                {
                    if ((my_event1.response == EX_RESTART) && 
                        !(input1_mask & GRm_RESTART))
                    {
                        restart_flag = TRUE;
                    }
                    else if (my_event1.response == EX_BACK_UP ||
                             my_event1.response == RESET)
                    {
                        restart_flag = TRUE;
                    }
                    else if (my_event1.response == GR_UNKNOWN_TYPE)
                    {
                        exit_code = RETCONTROL;
                        *event2 = my_event1;
                        if (nbytes2) *nbytes2 = temp_nbytes;
                        status = 1;
                        *msg = 0;
                    }
                    else if (state == end_state)
                    {
                        *event2 = my_event1;
                        if (nbytes2) *nbytes2 = temp_nbytes;
                        state = LOCATE_STATE;
                        *locate_state = LOCATE_STATE;
                        exit_code = RETCONTROL;
                        status = 1;
                        *msg = 1;
                    }
                    else
                    {
                        *event1 = my_event1;
                        if (nbytes1) *nbytes1 = temp_nbytes;
                        state = INPUT2_STATE;
                        *locate_state = INPUT2_STATE;
                    }
                }

                break;

            case INPUT2_STATE:

                if (!input2_prompt)
                {
                    ex$message (msgnumb = input2_key, buff = prompt_buf);
                }

                temp_mask = input2_mask | GRm_RESET | GRm_BACK_UP;
                om_msg = co$getevent (msg = &ret_msg,
                            scale_flag = scale_flag,
                            event_mask = temp_mask,
                            prompt = (input2_prompt) ?
                                      input2_prompt : prompt_buf,
                            response = response,
                            response_data = response_data,
                            event_size = eventsize,
                            event = event2,
                            nbytes = &nbytes2);

                if (om_msg & ret_msg & 1)
                {
                    if ((event2->response == EX_RESTART) && 
                        !(input2_mask & GRm_RESTART) ) 
                    {
                        restart_flag = TRUE;
                    }
                    else if (event2->response == RESET ||
                             event2->response == EX_BACK_UP) 
                    {
                        restart_flag = TRUE;
                    }
                    else if (event2->response == GR_UNKNOWN_TYPE)
                    {
                        *msg = 0;
                        status = 1;
                        exit_code = RETCONTROL;
                    }
                    else 
                    {
                        exit_code = RETCONTROL;
                        state = LOCATE_STATE;
                        *locate_state = LOCATE_STATE;
                        status = 1;
                        *msg = 1;
                    }                                    
                }
                break;
        }  /* End of switch statement */

        if (restart_flag)
        {
            restart_flag = FALSE;
            state = LOCATE_STATE;
            if (locate_state) *locate_state = LOCATE_STATE;
            gr$get_module_env(buffer = &mod_env);
            dp$erase_hilite(msg = &ret_msg,
                            objid = mod_env.md_id.objid,
                            osnum = mod_env.md_id.osnum);
            if (chansel)
            {
                gr$gsempty(msg = &ret_msg, senderid = senderid,
                           senderos = senderos, p_chanselect = chansel);
            }
        }
        else if (!(om_msg & ret_msg & 1))
        {
            *msg = 0;
            status = 0;
            exit_code = RETCONTROL;
            if (locate_state) *locate_state = LOCATE_STATE;
            if (chansel)
            {
                om_msg = gr$gsempty(msg = &ret_msg, senderid = senderid,
                             senderos = senderos, p_chanselect = chansel);
            }
        }
    }  /* End of while loop */

    // Restore the Smart Sketch state.
    if (ss_state)
        SSActivate();

    return (status);
}      
end implementation Root;
