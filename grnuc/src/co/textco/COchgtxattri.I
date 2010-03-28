/* #######################    APOGEE COMPILED   ######################## */

/*

     Abstract:  This method implements the change text font
                command, operating on text objects.
*/

class implementation COchgtxattr;

#include "msdef.h"
#include "grmessage.h"
#include "msmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "grgsmacros.h"
#include "exmacros.h"
#include "gotextdef.h"

#define LOCATE        0
#define CHANGE        1
#define CHG_FONT      0
#define CHG_JUST      1
#define CHG_LN_SP     2
#define CHG_CHR_SP    3
#define CHG_HT        4
#define CHG_WID       5
#define CHG_SIZE      6

from GRtext     import GRchgtextattr;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              init                                */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method init (IGRint type; IGRchar *string_ptr)
{
    IGRlong                 status;  /* return status      */

    status = om$send(mode = OM_e_wrt_message,
                     msg = message COgsmanip.init(type,string_ptr),
                     targetid = my_id);

    /* 
     * get classid from classname
     */

    om$get_classid(classname = "GRtext",
                   p_classid = &me->classid);

    me->mask2 |= (GRm_SPECIFIED_OBJ | GRm_TEXT_VALUE);
    me->attr.properties |= LC_WRITE_ONLY;
    me->attr.owner_action |= LC_NO_RIGID_COMP;
    me->eligible_classes.w_count = 1;
    me->eligible_classes.w_flags = OM_CLST_subclass;
    me->eligible_classes.p_classes = &me->classid;
    ex$message(msgnumb = GR_P_AccNxtEle,
               buff = me->acc_prompt);

    /*
     * set the message number to the appropriate message (according to what
     * command this is) and me^^COchgtxattr.chg_flag to the bitmask that will
     * change the correct attributes
     */

    switch (me->mytype)
    {
        case CHG_FONT:

            me^^COchgtxattr.msg_number = GRC_M_ChTxtFt;
            me^^COchgtxattr.chg_flag = GRTEXT_FONT;
            break;

        case CHG_JUST:

            me^^COchgtxattr.msg_number = GRC_M_ChTxtJust;
            me^^COchgtxattr.chg_flag = GRTEXT_JUST;
            break;

        case CHG_LN_SP:

            me^^COchgtxattr.msg_number = GRC_M_ChTxtLs;
            me^^COchgtxattr.chg_flag = GRTEXT_LN_SP;
            break;

        case CHG_CHR_SP:

            me^^COchgtxattr.msg_number = GRC_M_ChTxtCs;
            me^^COchgtxattr.chg_flag = GRTEXT_CHAR_SP;
            break;

        case CHG_HT:

            me^^COchgtxattr.msg_number = GRC_M_ChTxtHt;
            me^^COchgtxattr.chg_flag = GRTEXT_HEIGHT;
            break;

        case CHG_WID:

            me^^COchgtxattr.msg_number = GRC_M_ChTxtWd;
            me^^COchgtxattr.chg_flag = GRTEXT_WIDTH;
            break;

#ifndef IDRAW
        case CHG_SIZE:

            me^^COchgtxattr.msg_number = GRC_M_ChTxtSz;
            me^^COchgtxattr.chg_flag = GRTEXT_HEIGHT | GRTEXT_WIDTH;
            break;
#endif

        default:

#ifdef DEBUG
            printf("Unknown change type in COchgtxattri.I wakeup method\n");
#endif
            break;
    }   /* end switch */

    return(OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              wakeup                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup (int pos)
{
    IGRlong                 status;  /* return status      */
    IGRlong                 msg;     /* return status      */
    IGRlong                 nbytes_in_buffer;
    IGRlong                 nbytes_transferred;

    status = om$send(mode = OM_e_wrt_message,
                     msg = message COgsmanip.wakeup(pos),
                     targetid = my_id);

   /*
    * display the appropriate message
    */

   ex$message(msgnumb = me^^COchgtxattr.msg_number);

   /* 
    *  get the text specific default parameter data from the DPB
    */

    nbytes_in_buffer = sizeof(me->text_symb);
    gr$get_text_symb(msg = &msg,
                     sizbuf = &nbytes_in_buffer,
                     buffer = &me->text_symb,
                     nret = &nbytes_transferred);

    return (OM_S_SUCCESS);
}

/***********************************************************************/
/********************* COchgtxattr sleep method ************************/
/***********************************************************************/

method super_cmd.sleep(int pos)
{

    IGRlong msg;

    om$send(mode = OM_e_wrt_message,
            msg = message COgsmanip.wakeup(pos),
            targetid = my_id);

/* GRgslocate doesn't erase the highlight if a group generator is used */

    dp$erase_hilite(msg = &msg);

    return (OM_S_SUCCESS);
}

/***********************************************************************/
/******************** COchgtxattr execute method ***********************/
/***********************************************************************/

method execute (int *response; char *response_data; int pos)
{
    IGRlong                 om_msg;
    IGRlong                 status;         /* function call status         */
    IGRlong                 msg;            /* GO processing message        */
    IGRint                  size;           /* size of struct to put on que */
    IGRboolean              exit = FALSE;   /* command exit flag            */
    struct GRevent          grevent2;       /* accept event                 */
    struct GRevent          locate_event;   /* accept event                 */
    struct GRmd_env         module_env;     /* module environment of the    */
                                            /* text object being changed    */
    OM_S_CHANSELECT         gschansel;      /* graphic set channel selector */

    om$make_chanselect(channame = "COgsmanip.to_graphics",
                       p_chanselect = &gschansel);

    while (!exit)
    {  
        switch (me->state)
        {
            case LOCATE:

                status = gr$gslocate(msg = &msg,
                                     event1 = &me->event1,
                                     event2 = &grevent2,
                                     locate_event = &locate_event,
                                     mask1 = me->mask1,
                                     mask2 = me->mask2,
                                     display_flag = me->display_flag,
                                     locate_prompt = me->loc_prompt, 
                                     acc_prompt = me->acc_prompt,
                                     relocate_prompt = me->reloc_prompt, 
                                     attributes = &me->attr,
                                     stack = &me->locate_stack,
                                     eligible_classes = &me->eligible_classes,
                                     locate_state = &me->locate_state,
                                     num_inputs = 1,
                                     input1_mask = GRm_DATA | GRm_SPECIFIED_OBJ | GRm_TEXT_VALUE,
                                     input1_prompt = me->acc_prompt,
                                     p_chanselect = &gschansel);

                if (!status) 
                {
                    exit = TRUE;
                    me->obj_hilited = FALSE;
                }
                else if (!(msg & 1))
                {
                    exit = TRUE;         /* pass on to executive */
                }
                else if (grevent2.response == DATA)
                {
                    me->obj_hilited = TRUE;
                    me->state = CHANGE;
                }
                break;

            case CHANGE:

                if (me->obj_hilited)
                {
                    om_msg = gr$gsdisplay(msg = &msg,
                                          dpmode = GRbehe,
                                          p_chanselect = &gschansel);

                    if (!(om_msg & msg & 1))
                    {
#ifdef DEBUG
                        printf ("COchgtxattr: gr$gsdisplay GRbehe\n");
                        printf ("msg = 0x%x\n", msg);
                        om$report_error(sts = om_msg);
#endif
                        ex$message(msgnumb = GR_E_ErrEncCmdTrm);
                        *response = TERMINATE;
                        exit = TRUE;
                        break;
                    }
                    me->obj_hilited = FALSE;
                }

                /*
                 *  Change the selected attribute; the bitmask indicating which
                 *  attribute to change is computed by left shifting the number
                 *  one by the value mytype
                 */

                om_msg = gr$gspass(msg = &status,
                                   pass_msg = message GRtext.GRchgtextattr
                                             (&msg,
                                              &module_env,
                                              me^^COchgtxattr.chg_flag,
                                              &me->text_symb),
                                   path = &module_env,
                                   p_chanselect = &gschansel);

                if (!(om_msg & status & msg & 1))
                {
#ifdef DEBUG
                    printf ("COchgtxattr: gr$gspass GRvg.GRchxxx\n");
                    printf ("status = 0x%x\n", status);
                    printf ("msg = 0x%x\n", msg);
                    om$report_error(sts = om_msg);
#endif
                    ex$message(msgnumb = GR_E_ErrEncCmdTrm);
                    *response = TERMINATE;
                    exit = TRUE;
                    break;
                }

                me->state = LOCATE;
                me->event1 = grevent2;
                size = sizeof(struct GRevent) - (sizeof(IGRlong) * 2);

                status = ex$putque(msg = &msg,
                                   response = response,
                                   byte = (long *) &size,
                                   buffer = (IGRchar *) &grevent2.event);

                if (!(status & msg & 1))
                {
                    *response = TERMINATE;
                    exit = TRUE;
                    break;
                }

                om_msg = gr$gsdisplay(msg = &msg,
                                      dpmode = GRbdhe,
                                      p_chanselect = &gschansel);

                if (!(om_msg & msg & 1))
                {
#ifdef DEBUG
                    printf ("COchgtxattr: gr$gsdisplay GRbdhe\n");
                    printf ("msg = 0x%x\n", msg);
                    om$report_error(sts = om_msg);
#endif
                    ex$message (msgnumb = GR_E_ErrEncCmdTrm);
                    *response = TERMINATE;
                    exit = TRUE;
                }

                om_msg = gr$gsempty(msg = &msg,
                                    p_chanselect = &gschansel);

                if (!(om_msg & msg & 1))
                {
#ifdef DEBUG
                    printf ("COchgtxattr: gr$gsempty\n");
                    printf ("msg = 0x%x\n", msg);
                    om$report_error (sts = om_msg);
#endif
                    ex$message (msgnumb = GR_E_ErrEncCmdTrm);
                    *response = TERMINATE;
                    exit = TRUE;
                }
                break;
        }
    }
    return (OM_S_SUCCESS);
}

end implementation COchgtxattr;
