/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION
----
%HD%
     CLASS NAME:    COtxfrmtxel

     METHOD NAMES:  execute

     Abstract:  This method implements the text from text element input
                generator command, operating on text objects.
----
%MD%
     MODULES AND METHODS INVOKED:

     Modules:
     Methods:
----
%RL%
     RELATIONS REFERENCED:

----
%UI%
     USER INTERFACE DESCRIPTION:

----
%NB%
     NOTES:

----
%CH%
     CHANGE HISTORY:

     WBC  03/29/88:   Design date.
     WBC  03/29/88:   Creation date.
     SCW  08/09/94:   Clarified sleep method
----
%PD%
     PROGRAM DESCRIPTION:


     Method Name: method execute

     Method Description: The execute method prompts for and collects
                         user input, using that input to invoke
                         methods & functions as required to locate
                         a text object and put its contents on the
                         software queue.

----*/
/*EH*/

class implementation COtxfrmtxel;

#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "exmacros.h"
#include "dpmacros.h"
#include "fontdef.h"
#include "gotextdef.h"
#include "igrdef.h"
#include "codef.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "lcmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "exdef.h"
#include "fontmacros.h"
#include "cotxmacros.h"

from GRtext     import GRgettxattr;

/*
 *#define DEBUG
 */

/*---------------------------------------------------------------*/
/*                    method COinit                              */
/*---------------------------------------------------------------*/

method init(IGRint type; IGRchar *string_ptr)
{

#ifdef DEBUG
    printf("Init method.\n");
#endif

    me->mytype = type;

    /* 
     * get classid from classname
     */

    om$get_classid(classname = "GRtext",
                   p_classid = &ME.COtxfrmtxel->classid);

    /*
     *  Initialization
     */

    ME.COtxfrmtxel->attr.properties = 0;
    ME.COtxfrmtxel->attr.owner_action = LC_RIGID_COMP | LC_FLEX_COMP | LC_REF_OBJECTS;
    ME.COtxfrmtxel->locate_stack.num_entries = 0;
    ex$message(msgnumb = GR_P_IdEle,
               buff = ME.COtxfrmtxel->loc_prompt);
    ex$message(msgnumb = GR_E_EleNotFnd,
               buff = ME.COtxfrmtxel->reloc_prompt);
    ex$message(msgnumb = GR_P_Acc,
               buff = ME.COtxfrmtxel->acc_prompt);
    ME.COtxfrmtxel->eligible_classes.w_count = 1;
    ME.COtxfrmtxel->eligible_classes.w_flags = OM_CLST_subclass;
    ME.COtxfrmtxel->eligible_classes.p_classes = &ME.COtxfrmtxel->classid;

    return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------*/
/*                       method COsleep                          */
/*---------------------------------------------------------------*/

method super_cmd.sleep(IGRint pos)
{

# ifdef DEBUG
     printf("Sleep method.\n");
# endif

    ex$message(field = MESSAGE_FIELD,
               in_buff = "");
    ex$message(field = PROMPT_FIELD,
               in_buff = "");
    ex$message(field = ERROR_FIELD,
               in_buff = "");

    return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------*/
/*                       method COwakeup                         */
/*---------------------------------------------------------------*/

method wakeup(IGRint pos)
{
#ifdef DEBUG
    printf("Wakeup method.\n");
#endif

    ex$message(field = PROMPT_FIELD,
               in_buff = "");
    ex$message(field = ERROR_FIELD,
               in_buff = "");
    ex$message(msgnumb = GRC_M_TxFrmTxEl);
    return(OM_S_SUCCESS);
}

/*------------------------------------------------------------------*/
/*                             execute                              */
/*------------------------------------------------------------------*/

method execute(IGRint *response;
               IGRchar *response_data;
               IGRint  pos)
{
    IGRboolean  exit;           /* Boolean to control when to exit       */
    IGRchar     *text_string;   /* pointer to text string                */
    IGRchar     temp_char = '\0';/* temporary character holder            */
    IGRshort    original_length;/* unstripped text length                */
    IGRint      status;         /* routine return status                 */
    IGRint      size;           /* sizeof a structure                    */
    IGRint      i;
    IGRlong     num_bytes;
    IGRlong     display_flag;   /* display flag for locate filter        */
    IGRlong     identify_mask;  /* element location mask for lc$locate   */
    IGRlong     accept_mask;    /* element accept mask for lc$locate     */
    IGRlong     om_msg;         /* OM return code                        */
    IGRlong     msg;            /* function return code                  */
    IGRlong     nbytes_returned;
    IGRlong     nbytes_transferred;
    struct  GRmd_env   locate_env;
    struct  IGRestx    tx_attr; /* text attributes                       */
    struct  vfont_entry font_info; /* font information                   */

#ifdef DEBUG
    printf("COtxfrmtxel_execute_method\n");
#endif

    /*
     * Initialization
     */

    exit = FALSE;
    identify_mask = GRm_DATA | GRm_TEXT_VALUE | GRm_RESET;
    accept_mask = GRm_DATA;
    display_flag = 1;
    size = sizeof(struct GRevent);

    /*
     * loop until exit condition occurs
     */

    do
    {
        /*
         * call locate filter to locate an object
         */

        nbytes_returned = sizeof(struct GRmd_env);

        gr$get_locate_env(msg = &msg,
                          sizbuf = &nbytes_returned,
                          buffer = &locate_env,
                          nret = &nbytes_transferred);

        status = lc$locate(rc = &msg,
                           event1 = &ME.COtxfrmtxel->grevent1,
                           event2 = &ME.COtxfrmtxel->grevent1,
                           mask1 = identify_mask,
                           mask2 = accept_mask,
                           eventsize = &size,
                           display_flag = display_flag,
                           locate_prompt = ME.COtxfrmtxel->loc_prompt,
                           acc_prompt = ME.COtxfrmtxel->acc_prompt,
                           relocate_prompt = ME.COtxfrmtxel->reloc_prompt,
                           attributes = &ME.COtxfrmtxel->attr,
                           stack = &ME.COtxfrmtxel->locate_stack,
                           eligible_classes = &ME.COtxfrmtxel->eligible_classes);

        if (!status)
        {
#ifdef DEBUG
            printf("COtxfrmtxel_execute: Error: COlclocate\n");
#endif
        }
        else if (msg)
        {
            /*
             * erase the highlighted text element
             */
    
            dp$erase_hilite(msg = &msg);

            /*
             * get the text specific attributes and the text string of
             * the text object
             */

            om_msg = om$send(mode = OM_e_wrt_object,
                             msg = message GRtext.GRgettxattr
                                   (&msg,&tx_attr,NULL,(IGRuchar **)&text_string),
                             senderid = my_id,
                             targetid = ME.COtxfrmtxel->grevent1.located_object[0].located_obj.objid,
                             targetos = ME.COtxfrmtxel->grevent1.located_object[0].located_obj.osnum);

            if (om_msg & msg & 1)
            {
                /*
                 * if the text object's text length is not zero and it is not
                 * an empty text object, put the text string on the software
                 * queue
                 */

                if (tx_attr.text_length)
                {
                    original_length = tx_attr.text_length;

                    /*
                     * strip any escape sequences out of the text string
                     */

                    font$get_info(msg = &msg,
                                  font_num = &tx_attr.font,
                                  font_info = &font_info);

                    co$rm_esc_seqs(msg = &msg,
                                   font_num = tx_attr.font,
                                   font_flags = font_info.flags,
                                   text_string = text_string,
                                   text_length = &tx_attr.text_length);

                    /*
                     * if the original text length and the current text length
                     * are the same (no escape sequences were stripped), must
                     * allocate 1 more byte to be used in NULL terminating the
                     * text string; otherwise enough memory exists for the NULL
                     */

                    if (original_length == tx_attr.text_length)
                    {
                        text_string = om$realloc(ptr = text_string,
                                                 size = (IGRint)(original_length + 1));
                    }

                    /*
                     * NULL terminate the text string
                     */

                    text_string[tx_attr.text_length] = '\0';

                    /*
                     * put contents of the text object's text string on the
                     * software queue; a maximum of EX_RESPONSE_DATA_SIZE
                     * bytes may be put on the software queue at a time
                     */

                    *response = STRING;
                    i = 0;

                    while (i < tx_attr.text_length)
                    {
                        if (tx_attr.text_length - i > EX_RESPONSE_DATA_SIZE - 1)
                        {
                            num_bytes = EX_RESPONSE_DATA_SIZE;

                            /*
                             * a text string placed on the software queue must
                             * be NULL terminated; save the first char of the
                             * next string to be placed on the software queue
                             * and replace it with a NULL char, which will be
                             * used as the last char of the current string to
                             * be placed on the software queue
                             */

                            temp_char = text_string[i + num_bytes - 1];
                            text_string[i + num_bytes - 1] = '\0';
                        }
                        else
                        {
                            num_bytes = (tx_attr.text_length - i) + 1;
                        }
                        status = ex$putque(msg = &msg,
                                           pos = BACK,
                                           response = response,
                                           byte = &num_bytes,
                                           buffer = &text_string[i]);

                        if (!(status & msg & 1))
                        {
                            break;
                        }
                        i += num_bytes - 1;
                        text_string[i] = temp_char; /* replace the NULL char */
                    }
                    om$dealloc(ptr = text_string);
                }
            }
            exit = TRUE;  /* text on queue - exit */
            *response = TERMINATE;
        }
        else if (ME.COtxfrmtxel->grevent1.response == RESET)
        {
            /* stay in command on reset -- go back to locate */
        }
        else if (ME.COtxfrmtxel->grevent1.response == GR_UNKNOWN_TYPE)
        {
            exit = TRUE;  /* unrecognized input -- return control */
        }
    }
    while(!exit);

    return(OM_S_SUCCESS);

}   /*  end execute method */

end implementation COtxfrmtxel;
