/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              Intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*
    Implementation file for COsetadp
 
 Abstract:
   This command object constructs, initializes and displays the Set Active
Drawing Parameters form object (in transient object space) if it does not
exist, then exits.  If the form already exists the command object displays
a message explaining that the form has already been displayed and exits.

    methods overriden: execute


    History:

       WBC - 12/02/87   created
       WBC - 01/23/90   Changed so that the form will be command driven
                        while it's a save/restore form

 */

/* EH - End of Header  */


class implementation COsetadp;

#include "coimport.h"
#include "exdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "msmacros.h"
#include "grmessage.h"
#include "FI.h"

method execute(int *response; char *response_data; int pos)
{
    IGRint         GRdisp_set_adp();
    IGRint         GRdisplay_setadp_subforms();

    IGRlong        msg;
    IGRint         nbytes;
    Form           form_ptr;
    struct GRevent event;

    if (GRdisp_set_adp())
    {
        IGRint   not_finished;

        not_finished = TRUE;
        ex$message(msgnumb = GRC_M_SetADP);

        do
        {
            /*
             * if the input is not an EX_FORM_FINISHED or something that will
             * cause the command to suspend, ignore the input and call
             * co$getevent again
             */

            co$getevent(msg = &msg,
                        event_mask = GRm_FORM_FINISHED | GRm_STRING,
                        nbytes = &nbytes,
                        response = response,
                        response_data = response_data,
                        event = &event);

            if (*response == EX_FORM_FINISHED)
            {
                /*
                 * the form has been converted from save/restore to a permanent
                 * form; this command should be terminated and the form is on
                 * its own (it's now persistent)
                 */

                *response = TERMINATE;
                not_finished = FALSE;
            }
            else if ((*response == TERMINATE) ||
                     (*response == CLEAR_STACK) ||
                     (*response == TOGGLE_COMMAND) ||
                     (*response == EX_CMD_KEY) ||
                     (*response == STRING))
            {
                /*
                 * this command is going to be terminated or suspended; the
                 * Set Active Drawing Parameters form and its subfoms (if any)
                 * need to be erased
                 */

                GRdisplay_setadp_subforms(FALSE);
                GRcreate_setadp(&msg,FALSE,&form_ptr);
                FIf_erase(form_ptr);
                not_finished = FALSE;
            }
        }  while (not_finished);
    }
    else  /* Set Active Drawing Parameters form has already been displayed */
    {
        *response = TERMINATE;
    }

    return(OM_S_SUCCESS);
}

end implementation COsetadp;
